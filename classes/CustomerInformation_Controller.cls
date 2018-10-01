/*------------------------------------------------------------
Author: Komsan
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
23/06/2015  Komsan.Wi           First Create
14/03/2016  Charnun.T           Refactor Code
------------------------------------------------------------*/
public without sharing class CustomerInformation_Controller {
    public String currentCis;
    public Map<String, Object> responseMap {get; private set;}
    public String responseMapJson {get; private set;}
    public Map<String, String> requestLabelMap {get; private set;}

    public static final String GOOD_BANK = 'Good Customer';
    public static final String YES = 'Yes';
    public enum CircleStatus{good,bad}
    public String errorMessage{get;set;}
    public class AccountObj{

        public Account acc{get;set;}
        //public String accName{get{return acc.;}}
        
        public  String stockDayOnHand {get {
            return this.acc.Stock_Day_on_Hand_Days__c != null ? String.valueOf(this.acc.Stock_Day_on_Hand_Days__c)  : '';
            }}
        public String icrRatio {get {
            return (this.acc.ICR_Ratio__c  != null) ? String.valueOf(this.acc.ICR_Ratio__c) : '';
            }}
        public String deRatio {get {
            return (this.acc.DE_Ratio__c != null) ? String.valueOf(this.acc.DE_Ratio__c) : ''; }}
        public String currentRatio {get {
            return (this.acc.Current_Ratio__c != null) ? String.valueOf(this.acc.Current_Ratio__c) : ''; }}
        public Double kBankSOWExposure {get { return this.acc.SOW_Exposure__c != null ? this.acc.SOW_Exposure__c : 0; }}
        public Double otherSOWExposure {get {return 100 - this.kBankSOWExposure; }}
        public Double kBankSOWOutstanding { get { return this.acc.SOW_Outstanding__c != null ? this.acc.SOW_Outstanding__c : 0; }}
        public Double otherSOWOutStanding { get { return 100 - this.kBankSOWOutstanding; }}
        public String amountCollateral {get; set;}
        public String valueCollateral {get; set;}
        public Map<String, List<Integer>> bScoreMap {get; set;}
        public List<String> bScoreHeader {get; set;}
        //public Double Amount_Guarantee__c Amount_Guarantor__c
        
        public AccountObj(Account acc){
            this.acc = acc;
        }
    } 
    transient AccountObj accObj;
    transient Boolean hasError;
    public AccountObj getObj(){
        return accObj;
    }
    public Boolean getHasError(){
        return hasError;
    }
    public String getLt(){
        return '<';
    }   
    public String getGt(){
        return '>';
    }   
    public String accountId {get; private set;}

    public CustomerInformation_Controller(ApexPages.StandardController controller){
        this.responseMap = new Map<String, Object>();
        accountId = ApexPages.currentPage().getParameters().get('id');
        if(accountId != null){
            try{
                UserRecordAccess userRecObj = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId = :accountId LIMIT 1];
                
                if(!userRecObj.HasReadAccess){
                    hasError = true;
                    errorMessage = 'Insufficient access on this record.';
                }
                
                accObj = new AccountObj([SELECT Id, CIS__c, Name_TH__c, Name_Surname_TH__c, Main_Bank_Symbol__c, MBB_Symbol__c, MOB_Symbol__c, Credit_Status_Symbol__c, NPL_Symbol__c, Criminal_Offense_Symbol__c, Industry_Risk_Symbol__c, Debt_Restructuring_Symbol__c, Watch_List_Symbol__c, LiabilitiesTotalLiability__c, TotalShareholdersEquity__c, AssetCurrentAsset__c, LiabilitiesCurrentLiability__c, Wallet_Size_Limit__c, Criminal_Offense__c, SOW_Exposure__c, SOW_Outstanding__c, Name, Status__c,NPL__c,Industry_Risk__c,Watch_List__c, ICR_Ratio__c, DE_Ratio__c, Current_Ratio__c, Stock_Day_on_Hand_Days__c FROM Account WHERE Id=:accountId]);

                setupBehaviorScore(accObj);
                setupCollateralList(accObj);
                
            }catch(Exception ex){
                System.debug('Exception :'+ex);
                errorMessage = ex.getMessage();
                hasError = true;    
            }  
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Customer Id not Found.'));
            errorMessage = 'Customer Id not Found.';
            hasError = true;
        }
    }

    public Object requestCustomerInformation() {
        this.requestLabelMap = new Map<String, String>();
        currentCis = Apexpages.currentPage().getParameters().get('cis');
        System.debug('cis : '+currentCis);
        Continuation con = new Continuation(120);
        con.continuationMethod = 'handleResponseCustomerInformation';
        this.requestLabelMap.put('interactionHistory', con.addHttpRequest(SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.TRANSACTBP_ENDPOINT)));
        this.requestLabelMap.put('totalDebt', con.addHttpRequest(SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.CREDIT_OUTSTANDING_ENDPOINT)));
        System.debug('request Label Map : '+this.requestLabelMap);
        return con;
    }

    public Object handleResponseCustomerInformation() {
        this.responseMap = new Map<String, Object>();
        for(String key : requestLabelMap.keySet()) {
            HttpResponse response = Continuation.getResponse(this.requestLabelMap.get(key));
            System.debug('response : '+response);
            if(key == 'interactionHistory') {
                handleInteractionHistoryResponse(response);
            } else if(key == 'totalDebt') {
                handleTotalDebt(response);
            } 
        }

        this.responseMapJson = JSON.serializePretty(responseMap);
        return null;
    }

    public Boolean validateResponse(String key, HttpResponse response) {
      String responseStr = response.getBody();

      if(response.getStatusCode() == 404) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', 'Adapter is not available');
          this.responseMap.put(key, errorMap);
          return false;

      } else if(response.getStatusCode() == 503) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', 'Host is not available');
          this.responseMap.put(key, errorMap);
          return false;
      }


      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
      if(responseMap.containsKey('error')) {
          String error = (String)((Map<String,Object>)responseMap.get('error')).get('message');
          String errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+error+'Response:'+responseStr;
          GlobalUtility.logMessage('ERROR',key,key,null,null,errorMessage,null,null,null);
          //throw new CIWebserviceException(errorMessage);
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', error);
          this.responseMap.put(key, errorMap);
          return false;
      } 
      return true;
    }

    public void handleInteractionHistoryResponse(HttpResponse response) {
        if(!validateResponse('interactionHistory', response)) return;
        String responseOfTransactBP = response.getBody();
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(responseOfTransactBP);
      
        InteractionHistory_Model interactionHistoryData = new InteractionHistory_Model(currentCis, responseOfTransactBP);
        this.responseMap.put('interactionHistory', interactionHistoryData.getDataMap());
    }

    public void handleTotalDebt(HttpResponse response) {
        if(!validateResponse('totalDebt', response)) return;
        String responseOfTotalDebt = response.getBody();
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(responseOfTotalDebt);
        Map<String, List<String>> responseData = this.getDataMapOfFinancialInformation(currentCis);

        SME_CreditOutStandingResultResponse responseModel = SME_CreditOutStandingResultResponse.parse(responseOfTotalDebt);
        if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.outstanding != null) {
            Decimal pnOutstanding = 0;
            Decimal odOutstanding = 0;
            Decimal tfOutstanding = 0;
            Decimal totalOutstanding = 0;

            System.debug('responseModel : '+responseModel);
            
            for(SME_CreditOutStandingResultResponse.creditOutStandingResponse_model dataModel : responseModel.returnResponse.outstanding) {
                if(dataModel.AR_TYPE == 'PN') {
                    pnOutstanding = Decimal.valueOf(dataModel.OST);
                } else if(dataModel.AR_TYPE == 'OD') {
                    odOutstanding = Decimal.valueOf(dataModel.OST);
                } else if(dataModel.AR_TYPE == 'TF') {
                    tfOutstanding = Decimal.valueOf(dataModel.OST);
                }
            }

            totalOutstanding = pnOutstanding + odOutstanding + tfOutstanding; 
            System.debug('totalOutstanding : '+totalOutstanding);
            responseData.put('total_outstanding', new List<String>{GlobalUtility.toCurrency(totalOutstanding)});
            responseData.put('pn_outstanding', new List<String>{String.valueOf(pnOutstanding)});
            responseData.put('od_outstanding', new List<String>{String.valueOf(odOutstanding)});
            responseData.put('tf_outstanding', new List<String>{String.valueOf(tfOutstanding)});
        }

        this.responseMap.put('totalDebt', responseData);
    }



    public Map<String, List<String>> getDataMapOfFinancialInformation(String cis) {
        Map<String, List<String>> dataMap = new Map<String, List<String>>();
        dataMap.put('total_limit', new List<String>{'0.00'});
        dataMap.put('pn_limit', new List<String>{'0'});
        dataMap.put('od_limit', new List<String>{'0'});
        dataMap.put('tf_limit', new List<String>{'0'});
        
        for(Financial_Information__c ficancialInfo : [SELECT Id, PN_Limit__c, OD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c = :cis]) {
            //System.debug('financial info : '+ficancialInfo);

            Decimal pnLimit = ficancialInfo.PN_Limit__c != null ? ficancialInfo.PN_Limit__c : 0;
            Decimal odLimit = ficancialInfo.OD_Limit__c != null ? ficancialInfo.OD_Limit__c : 0;
            //Decimal liLimit = ficancialInfo.LI_Limit__c != null ? ficancialInfo.LI_Limit__c : 0;
            Decimal tfLimit = ficancialInfo.TF_Limit__c != null ? ficancialInfo.TF_Limit__c : 0;
            dataMap.put('pn_limit', new List<String>{String.valueOf(pnLimit)});
            dataMap.put('od_limit', new List<String>{String.valueOf(odLimit)});
            //dataMap.put('li_limit', new List<String>{String.valueOf(liLimit)});
            dataMap.put('tf_limit', new List<String>{String.valueOf(tfLimit)});

            Decimal totalLimit = pnLimit + odLimit + tfLimit;
            dataMap.put('total_limit', new List<String>{GlobalUtility.toCurrency(totalLimit)});
        }

        Utilization_Model utilizationModel = new Utilization_Model(cis);
        for(String product : utilizationModel.utilizationNameList) {
            dataMap.put(product.toLowerCase()+'_header_list', utilizationModel.headerList);
            dataMap.put(product.toLowerCase()+'_limit_list', utilizationModel.getLimitList(product));
            dataMap.put(product.toLowerCase()+'_outstanding_list', utilizationModel.getOutstandingList(product));
            dataMap.put(product.toLowerCase()+'_limit_value_list', utilizationModel.getLimitValueList(product));
            dataMap.put(product.toLowerCase()+'_outstanding_value_list', utilizationModel.getOutstandingValueList(product));
        }

        return dataMap;
    }

    public void setupBehaviorScore(AccountObj accObj) {
        Date todayDate = System.today();
        List<Behaviour_Score__c> bScoreList = [SELECT Id, SME_Score__c, HL__c, CC__c, Name FROM Behaviour_Score__c WHERE CIS__c =:accountId ORDER BY Name];
        accObj.bScoreMap = new Map<String, List<Integer>>();
        accObj.bScoreHeader = new List<String>();
        accObj.bScoreMap.put('SME', new List<Integer>());
        accObj.bScoreMap.put('HL', new List<Integer>());
        accObj.bScoreMap.put('CC', new List<Integer>());
        for(Behaviour_Score__c bScore : bScoreList) {
            Date thisDate = date.newinstance(todayDate.year(), todayDate.month() -Integer.valueOf(bScore.Name) , 1);
         //   Integer year = thisDate.year() > 2400 ? thisDate.year() - 543 : thisDate.year();
            Integer year = GlobalUtility.getYearInChristianCalendar(thisDate);
            String yearStr = String.valueOf(year).substring(2);
            String monthHeader = GlobalUtility.MONTH_STR_MAP.get(thisDate.month())+'-'+yearStr;

            accObj.bScoreHeader.add(monthHeader);
            accObj.bScoreMap.get('HL').add(bScore.HL__c == 'Pass' ? 5 : 1);
            accObj.bScoreMap.get('CC').add(bScore.CC__c == 'Pass' ? 5 : 1);
            Integer smeScore = 0; 
            if(bScore.SME_Score__c == 'VH') smeScore = 5;
            else if(bScore.SME_Score__c == 'H') smeScore = 4;
            else if(bScore.SME_Score__c == 'M') smeScore = 3;
            else if(bScore.SME_Score__c == 'L') smeScore = 2;
            else if(bScore.SME_Score__c == 'VL') smeScore = 1;
            accObj.bScoreMap.get('SME').add(smeScore);
        }
    }

    public void setupCollateralList(AccountObj accObj) {
        List<Collateral__c> collateralList = [SELECT Id, Amount_Guarantee__c, Amount_Guarantor__c, Value__c FROM Collateral__c WHERE CIS_ID__c =:accountId];
        accObj.amountCollateral = '0';
        accObj.valueCollateral = '0';
        Decimal sumAmountCollateral = 0;
        Decimal sumValueCollateral = 0;
        for(Collateral__c collateral : collateralList) {
            sumAmountCollateral += (collateral.Amount_Guarantee__c != null ? collateral.Amount_Guarantee__c : 0)
                                        + (collateral.Amount_Guarantor__c != null ? collateral.Amount_Guarantor__c : 0);
            sumValueCollateral += collateral.Value__c != null ? collateral.Value__c  : 0;
        }
        accObj.amountCollateral = String.valueOf(sumAmountCollateral);
        accObj.valueCollateral = String.valueOf(sumValueCollateral);
    }
}