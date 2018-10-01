/*------------------------------------------------------------
Author: Komsan Wi
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
21/07/2015  Komsan.wi           First Create
14/03/2016  Charnun.T           Refactor Code to callout
15/09/2016  Anan.B              Add CC , KEC
------------------------------------------------------------*/
public with sharing class FinancialInformation_Controller {
    public String currentCis;
    public String responseMapJsonFCD {get;private set;}
    public String responseMapJson {get; private set;}
    public Map<String, String> requestLabelMap {get; private set;}
    public Map<String, Object> responseMap {get; private set;}

    public String AMOUNT_INFLOW = 'Amount Inflow';
    public String AMOUNT_OUTFLOW = 'Amount Outflow';
    public String CASA_AVG = 'CASA Avg. Balance';
    public String CHEQUE = 'Cheque (Items)';
    public String CHEQUE_AMOUNT = 'Cheque Amount';
    public String CHEQUE_RETURN = 'Cheque Return (Items)';
    public String CHEQUE_RETURN_AMOUNT = 'Cheque Return Amount';
    public String TXN_INFLOW = 'TXN Inflow';
    public String TXN_OUTFLOW = 'TXN Outflow';

    public List<KBANK_STM__c> kbankSTMList{get;set;}

    public String cis {get;set;}
    public String primarySegment {get;set;}
    public Boolean isAccountOwnerOrOwnerManager {get;set;}
    public Boolean isAllowShowComponent {get;set;}

    public Account accountObj{get;set;}

    public List<String> kbankSTMHeader {get; private set;}
    public List<List<String>> kbankSTMData {get; private set;}
    public Id accountId;
    private Map<Integer, String> monthStrMap;
    private Map<Integer, String> monthThaiStrMap;

    public List<String> utilizationProductList {get; private set; }
    public FinancialInformation_Model financialInformationData {get; private set;}
    public Utilization_Model utilizationData {get; private set;}
    public List<String> statementList {get; private set;}
    public Boolean isThaiLang;
    public String language;

    @TestVisible 
    private Datetime currentDate;
    private Map<String,String> ccTPMap;
    private Map<String,String> kecTPMap;
    private Map<String,String> cardSTMap;
    public String MAINCARD = 'บัตรหลัก';
    public String ALTCARD  = 'บัตรเสริม';

    public String ADAPTER_NOT_AVAILABLE{
      get {return ExceptionMessage.ADAPTER_NOT_AVAILABLE;}
      private set;
    }
    public String HOST_EXCEPTION{
      get {return ExceptionMessage.HOST_EXCEPTION;}
      private set;
    }


    public void requestFCDDetailData(){
    }
    
    public FinancialInformation_Controller(ApexPages.StandardController controller){
        monthStrMap = new Map<Integer, String>{1 =>'Jan', 2=>'Feb', 3=>'Mar',4 =>'Apr', 5=>'May', 6=>'Jun',7 =>'Jul', 8=>'Aug', 9=>'Sep',10 =>'Oct', 11=>'Nov', 12=>'Dec'};
        monthThaiStrMap = new Map<Integer, String>{1 =>'ม.ค.',2=>'ก.พ.', 3=>'มี.ค.',4 =>'เม.ย.', 5=>'พ.ค.', 6=>'มิ.ย.',7 =>'ก.ค.', 8=>'ส.ค.', 9=>'ก.ย.',10 =>'ต.ค.', 11=>'พ.ย.', 12=>'ธ.ค.'};
        ccTPMap = new Map<String,String>{'1' => 'Visa Gold','2'=>'Visa Classic','3'=>'MasterCard Gold','4'=> 'MasterCard Classic','5'=>'KBank Gold','6'=>'KBank Classic','7'=>'KBank Visa Gold','8'=>'KBank Visa Classic','9'=>'Platinum'};
        kecTPMap = new Map<String,String>{'01' => 'ROBINSON CARD','02' => 'DIAMOND CARD', '03' => 'MERCEDES CARD', '04' => 'MUAENG THAI CARD','05' => 'VIBHAVADI CARE CARD', '06' => 'SHELL CARD','07' => 'THAI DAIMARU EXCEL CARD','08' => 'PACIFIC COOPERATION CARD','09' => 'FTI CARD','10' => 'THE MALL CARD',          
        '12' => 'ABACA CARD','13' => 'RED CROSS',  '14' => 'CGA CARD','15' => 'PHYATHAI HOSPITAL CARD', '16' => 'VILLA MARKET CARD', '17' => 'CLUB CARD',  '18' => 'U CARD',  '19' => 'KLANG PLAZA CARD', '20' => 'SHINAWATRA THAI CARD','21' => 'AMWAY KBANK VISA CARD', 
        '22' => 'TOT WU-KBANK CARD','23' => 'PEA LU-KBANK CARD','24' => 'EGAT LU-KBANK CARD','25' => 'THAMMASAT CARD','26' => 'MERCEDES CARD', '27' => 'SUANKULARB CARD','28' => 'NAIIN','29' => 'Carefour','30' => 'Ananda','31' => 'Property # 1','32' => 'Property # 2','33' => 'Property # 3','34' => 'Property # 4','35' => 'PTT',
        '36' => 'Thai Air Asia','43' => 'BDMS-KBANK VISA CHIP CARD','44' => 'ROBINSON-KBANK VISA CHIP CARD','46' => 'Muangthai-KBANK VISA CHIP CARD','59' => 'TCC-KBank Credit Card','61' => 'DISTRIBUTION KBANK BOONRAWD CARD'};
        
        cardSTMap = new Map<String,String>{'0' =>'NEW-ACCOUNT','1' =>'ACTIVE-ACCOUNT','2'=>'INACTIVE-ACCOUNT','3'=>'CONVERSION-ACCOUNT','4'=>'TRANSFERED','5'=>'CHARGED-OFF-ACCOUNT','6'=>'TRANSFER-OUT-TODAY','7'=>'TRANSFER-IN-TODAY','8'=>'CLOSED-ACCOUNT','9'=>'ACCOUNT-TO-BE-PURGED'};
        utilizationProductList = new List<String> {'OD', 'PN', 'TF'};
        statementList = new List<String>{AMOUNT_INFLOW, AMOUNT_OUTFLOW, CASA_AVG, CHEQUE, CHEQUE_AMOUNT, CHEQUE_RETURN, CHEQUE_RETURN_AMOUNT, TXN_INFLOW, TXN_OUTFLOW};

        accountId = ApexPages.currentPage().getParameters().get('id');
        accountObj = [SELECT Id, CIS__c, OwnerId, Owner.Profile.Name, Primary_Segment_Code__c, Is_SME_Customer__c, Is_CBS_Customer__c, is_RBS__c, Is_AF_Customer__c FROM Account WHERE Id=:accountId];
        cis = accountObj.CIS__c;
        primarySegment = accountObj.Primary_Segment_Code__c;
        kbankSTMList = new List<KBANK_STM__c>();
        kbankSTMList = [SELECT Id FROM KBANK_STM__c WHERE CIS_ID__c =:accountId];

        //List<AccountTeamMember> listAccountTeamMember = [SELECT Id FROM AccountTeamMember WHERE AccountAccessLevel != 'None' AND AccountId = :accountId AND UserId =:UserInfo.getUserId()];
        User ownerAccountWithManager = [SELECT Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId FROM User WHERE Id =:accountObj.OwnerId];
        if(//listAccountTeamMember.size() > 0 || 
          (accountObj.OwnerId == UserInfo.getUserId())
          || (!String.isBlank(ownerAccountWithManager.ManagerId) && ownerAccountWithManager.ManagerId == UserInfo.getUserId())
          || (!String.isBlank(ownerAccountWithManager.Manager.ManagerId) && ownerAccountWithManager.Manager.ManagerId == UserInfo.getUserId())
          || (!String.isBlank(ownerAccountWithManager.Manager.Manager.ManagerId) && ownerAccountWithManager.Manager.Manager.ManagerId == UserInfo.getUserId())){
          isAccountOwnerOrOwnerManager = true;
        }
        ProductUsageVisibilityService visibilityService = new ProductUsageVisibilityService(accountObj.Id);
        isAllowShowComponent = visibilityService.isVisible();

        this.requestLabelMap = new Map<String, String>();
        this.responseMap = new Map<String, Object>();
        this.language = UserInfo.getLanguage();
        this.isThaiLang = this.language == 'th' ? true : false ;
        this.currentDate = datetime.now();
    }

    public Object requestFinancialInformation() {
      this.responseMap.clear();
      currentCis = Apexpages.currentPage().getParameters().get('cis');
      Continuation con = new Continuation(120);
      String jsonRequestString = '{"IP_ID":"'+currentCis+'"}';
      con.continuationMethod = 'handleResponseFinancialInformation';
      this.requestLabelMap.put('creditData', con.addHttpRequest(SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.CREDIT_OUTSTANDING_ENDPOINT)));
      this.requestLabelMap.put('nonCreditData', con.addHttpRequest(SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.NON_CREDIT_OUTSTANDING_ENDPOINT)));
      this.requestLabelMap.put(financialInformationData.FCD, con.addHttpRequest(SME_CIRestWebservice.createHttpRequestWithJsonBody(jsonRequestString,SME_CIRestWebservice.FCD_ENDPOINT)));
      return con;
    }

    public Object handleResponseFinancialInformation() {
      HttpResponse creditResponse = Continuation.getResponse(this.requestLabelMap.get('creditData'));
      HttpResponse fcdResponse = Continuation.getResponse(this.requestLabelMap.get(financialInformationData.FCD));
      HttpResponse nonCreditResponse = Continuation.getResponse(this.requestLabelMap.get('nonCreditData'));
      handleCreditData(creditResponse);
      handleNonCreditData(nonCreditResponse,fcdResponse);

      this.responseMapJson = JSON.serializePretty(responseMap);
      return null;
    }

    public Object requestCreditDetailData() {
      // Add more script to check profile to call to backend system
      // if(GlobalUtility.getProfileNameWithId(UserInfo.getProfileId()).contains('CBS')){
      //   return 'Permission Denine to Access this Session'
      // }
      this.responseMap.clear();
      currentCis = Apexpages.currentPage().getParameters().get('cis');
      String productName = Apexpages.currentPage().getParameters().get('productName');
      Continuation con = new Continuation(120);
      con.continuationMethod = 'handleResponseCreditDetail';
      HttpRequest req;
      productName = productName.replace(' ', '_');
      if(productName == 'CC') {
        req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.CREDIT_CARD_ENDPOINT);
      } else if(productName == 'KEC') {
        req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.K_EXPRESS_CASH_ENDPOINT);
      } 
      this.requestLabelMap.put(productName, con.addHttpRequest(req));
      return con;
    }

    public Object requestNonCreditDetailData() {
      this.responseMap.clear();
      currentCis = Apexpages.currentPage().getParameters().get('cis');
      String productName = Apexpages.currentPage().getParameters().get('productName');
      Continuation con = new Continuation(120);
      con.continuationMethod = 'handleResponseNonCreditDetail';
      HttpRequest req;
      productName = productName.replace(' ', '_');
      if(productName == 'Current') {
          req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.CURRENT_ENDPOINT);
      } else if(productName == 'Fixed_Deposit') {
          req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.FIXED_ENDPOINT);
      } else if(productName == 'Saving') {
          req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.SAVING_ENDPOINT);
      } else if(productName == 'Taweesup') {
          req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.TAWEESUP_ENDPOINT);
      } else if(productName == 'Mutual_Fund') {
          req = SME_CIRestWebservice.createHttpRequestWithCIS(currentCis,SME_CIRestWebservice.MUTUALFUND_ENDPOINT);
      } 
      this.requestLabelMap.put(productName, con.addHttpRequest(req));
      return con;
    }

    public Object handleResponseCreditDetail() {
      for(String productName : requestLabelMap.keySet()) {
        HttpResponse response = Continuation.getResponse(this.requestLabelMap.get(productName));
        System.debug('handleResponseCreditDetail response :'+response);
        if(response == null) continue;
        if(productName == 'CC') {
          handleCreditCardResponse(response);
        } else if(productName == 'KEC') {
          handleKExpressCashResponse(response);
        } 
        //else if(productName == 'HL') {
        //    handleHLResponse(response);
        //} else if(productName == 'LN') {
        //    handleLNResponse(response);
        //} else if(productName == 'OD') {
        //    handleODResponse(response);
        //} else if(productName == 'PN') {
        //    handlePNResponse(response);
        //} else if(productName == 'TF') {
        //    handleTFResponse(response);
        //} else if(productName == 'LI') {
        //    handleLIResponse(response);
        //} 
        //else if(productName == 'K_Group') {
        //    handleKGroupResponse(response);
        //}

        this.requestLabelMap.remove(productName);
      }

      this.responseMapJson = JSON.serializePretty(responseMap);
      return null;
    }

    public Object handleResponseNonCreditDetail() {
      for(String productName : requestLabelMap.keySet()) {
        HttpResponse response = Continuation.getResponse(this.requestLabelMap.get(productName));
        System.debug('handleResponseNonCreditDetail response :'+response);
        if(response == null) continue;
        if(productName == 'Current') {
            handleCurrentResponse(response);
        } else if(productName == 'Fixed_Deposit') {
            handleFixedResponse(response);
        } else if(productName == 'Saving') {
            handleSavingResponse(response);
        } else if(productName == 'Taweesup') {
            handleTaweesupResponse(response);
        } else if(productName == 'Mutual_Fund') {
            handleMutualFundResponse(response);
        } 
        //else if(productName == 'K_Asset') {
        //    handleKAssetResponse(response);
        //} else if(productName == 'BA') {
        //    handleBAResponse(response);
        //}

        this.requestLabelMap.remove(productName);
      }

      this.responseMapJson = JSON.serializePretty(responseMap);
      return null;
    }

    public Boolean validateResponse(String key, HttpResponse response) {
      String responseStr = response.getBody();

     if(response.getStatusCode() == 404) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', ExceptionMessage.ADAPTER_NOT_AVAILABLE);
          this.responseMap.put(key, errorMap);
          return false;

      } else if(response.getStatusCode() == 503) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error',  ExceptionMessage.ADAPTER_NOT_AVAILABLE);
          this.responseMap.put(key, errorMap);
          return false;

      }
      else if(response.getStatusCode() == 500) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', ExceptionMessage.ADAPTER_NOT_AVAILABLE);
          this.responseMap.put(key, errorMap);
          return false;
      }else if(response.getStatusCode() == 504) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', ExceptionMessage.DATABASE_NOT_AVAILABLE);
          this.responseMap.put(key, errorMap);
          return false;
      }else if(response.getStatusCode() == 2000) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', ExceptionMessage.APPLICATION_TIMEOUT);
          this.responseMap.put(key, errorMap);
          return false;
      }

      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
      if(responseMap.containsKey('error')) {
          String error = (String)((Map<String,Object>)responseMap.get('error')).get('message');
          String errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+error+'Response:'+responseStr;
          GlobalUtility.logMessage('ERROR',key,key,null,null,errorMessage,null,null,null);

          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', error);
          this.responseMap.put(key, errorMap);
          return false;
      } 
      return true;
    }

    /**
    Handle Credit Response
    - handleCCResponse
    - handleKExpressCashResponse
    - handlePODResponse
    - handleHLResponse
    - handleLNResponse
    - handleODResponse
    - handlePNResponse
    - handleTFResponse
    - handleLIResponse
    - handleKGroupResponse
    **/

    public void handleCreditCardResponse(HttpResponse response) {
      if(!validateResponse('CC', response)) return;
      String responseStr = response.getBody();
      List<List<String>> dataList = new List<List<String>>();

      SME_CreditCardResultResponse responseModel = SME_CreditCardResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_CreditCardResultResponse.creditcard_model dataModel : responseModel.returnResponse.creditcard) {
            List<String> colsList = new List<String>();
            String imageURLMainCard;
            String imageURLALTCard;
            String PRINCIPLE_CARD_FLAG;
            CustomerSearch_Controller.Customer customer;
            Boolean isMainCard = dataModel.ISMAIN == '0000000000000000' ? true : false;
            if(isMainCard){
              if(dataModel.IP_ID_MAINCARD != null && dataModel.IP_ID_MAINCARD != ''){
                customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_MAINCARD,!isThaiLang,!isThaiLang);
                imageURLMainCard =  customer.fullName != null ? customer.fullName : '';
                imageURLALTCard = imageURLMainCard;
              }
              PRINCIPLE_CARD_FLAG = toValue(MAINCARD);
            }else{
              if(dataModel.IP_ID_MAINCARD != null && dataModel.IP_ID_MAINCARD != ''){
                 customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_MAINCARD,!isThaiLang,!isThaiLang);
                 imageURLMainCard =  customer.fullName != null ? customer.fullName : '';
              }
              if(dataModel.IP_ID_ALTCARD != null && dataModel.IP_ID_ALTCARD != ''){
                customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_ALTCARD,!isThaiLang,!isThaiLang);
                 imageURLALTCard =  customer.fullName != null ? customer.fullName : '';
              }
              PRINCIPLE_CARD_FLAG = toValue(ALTCARD);
            }
 
            colsList.add(toValue(dataModel.CARD_NO_MASK));
            colsList.add(toValue(ccTPMap.get(getFirstIndex(dataModel.CARD_TP1)) ));      
            colsList.add(toValue(changeDateformat(dataModel.OPN_DT)) );    
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CR_LMT_AMT)));

            Decimal bal;
            if(dataModel.CR_LMT_AMT != null && dataModel.CRN_BAL != null ) {
              bal = Decimal.valueOf(dataModel.CR_LMT_AMT) - Decimal.valueOf(dataModel.CRN_BAL);
            } 

            colsList.add(toValue( GlobalUtility.toCurrency(bal )) );                    
   
            colsList.add(toValue( GlobalUtility.toCurrency(dataModel.CRN_BAL) ));       
            colsList.add(toValue(changeStatementDateFormat(dataModel.DUE_DT)) );  

            colsList.add(PRINCIPLE_CARD_FLAG);                     

            if( checkValidDateFormat(dataModel.EXP_DT))
              colsList.add(toValue(getCardExpireDateFormat(dataModel.EXP_DT)) );
            else      
              colsList.add('');

            colsList.add(toValue(cardSTMap.get(getFirstIndex(dataModel.ST_CD)) ));  
    
            colsList.add(toValue('<img src='+imageURLMainCard+'>')  );
            colsList.add(toValue('<img src='+imageURLALTCard+'>' )  );
    
 
            dataList.add(colsList);
        }
      }
      responseMap.put('CC',dataList);
    }

    public void handleKExpressCashResponse(HttpResponse response) {
      if(!validateResponse('KEC', response)) return;
      String responseStr = response.getBody();
      List<List<String>> dataList = new List<List<String>>();

      SME_CreditCardResultResponse responseModel = SME_CreditCardResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_CreditCardResultResponse.creditcard_model dataModel : responseModel.returnResponse.kec) {
            List<String> colsList = new List<String>();
            String imageURLMainCard;
            String imageURLALTCard;
            String PRINCIPLE_CARD_FLAG;
            CustomerSearch_Controller.Customer customer;
            Boolean isMainCard = dataModel.ISMAIN == '0000000000000000' ? true : false;
            if(isMainCard){
              if(dataModel.IP_ID_MAINCARD != null && dataModel.IP_ID_MAINCARD != ''){
                customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_MAINCARD,!isThaiLang,!isThaiLang);
                imageURLMainCard =  customer.fullName != null ? customer.fullName : '';
                imageURLALTCard = imageURLMainCard;
              }
              PRINCIPLE_CARD_FLAG = toValue(MAINCARD);
            }else{
              if(dataModel.IP_ID_MAINCARD != null && dataModel.IP_ID_MAINCARD != ''){
                 customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_MAINCARD,!isThaiLang,!isThaiLang);
                 imageURLMainCard =  customer.fullName != null ? customer.fullName : '';
              }
              if(dataModel.IP_ID_ALTCARD != null && dataModel.IP_ID_ALTCARD != ''){
                customer = new CustomerSearch_Controller.Customer(dataModel.IP_ID_ALTCARD,!isThaiLang,!isThaiLang);
                 imageURLALTCard =  customer.fullName != null ? customer.fullName : '';
              }
              PRINCIPLE_CARD_FLAG = toValue(ALTCARD);
            }
 
            colsList.add(toValue(dataModel.CARD_NO_MASK));
            colsList.add(toValue(kecTPMap.get((dataModel.CARD_TP1)) ));  
            colsList.add(toValue(changeDateformat(dataModel.OPN_DT)) );    
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CR_LMT_AMT)));

            Decimal bal;
            if(dataModel.CR_LMT_AMT != null && dataModel.CRN_BAL != null ) {
              bal = Decimal.valueOf(dataModel.CR_LMT_AMT) - Decimal.valueOf(dataModel.CRN_BAL);
            } 

            colsList.add(toValue( GlobalUtility.toCurrency(bal)) );                    

            colsList.add(toValue( GlobalUtility.toCurrency(dataModel.CRN_BAL) ));       
            colsList.add(toValue(changeStatementDateFormat(dataModel.DUE_DT)) );  

            colsList.add(PRINCIPLE_CARD_FLAG);                     

            if( checkValidDateFormat(dataModel.EXP_DT))
              colsList.add(toValue(getCardExpireDateFormat(dataModel.EXP_DT)) );
            else      
              colsList.add('');

            colsList.add(toValue(cardSTMap.get(getFirstIndex(dataModel.ST_CD)) ));  
    
            colsList.add(toValue('<img src='+imageURLMainCard+'>')  );
            colsList.add(toValue('<img src='+imageURLALTCard+'>' )  );

            dataList.add(colsList);
        }
      }
      responseMap.put('KEC',dataList);
    }

    //public void handlePODResponse(HttpResponse response) {
    //  if(!validateResponse('POD', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_CreditCardResultResponse responseModel = SME_CreditCardResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_CreditCardResultResponse.creditcard_model dataModel : responseModel.returnResponse.kec) {
    //        List<String> colsList = new List<String>();
    //        Boolean isMainCard = dataModel.ISMAIN == '0000000000000000' ? true : false;
 
    //        colsList.add(toValue(dataModel.CARD_NO_MASK));
    //        colsList.add(toValue(kecTPMap.get((dataModel.CARD_TP1)) ));      // convert to String
    //        colsList.add(toValue(changeDateformat(dataModel.OPN_DT)) );       // change format
    //        colsList.add(toValue(dataModel.CR_LMT_AMT));

    //        Decimal bal;
    //        if(dataModel.CR_LMT_AMT != null && dataModel.CRN_BAL != null && (dataModel.CR_LMT_AMT>=dataModel.CRN_BAL)) {
    //          bal = Decimal.valueOf(dataModel.CR_LMT_AMT) - Decimal.valueOf(dataModel.CRN_BAL);
    //        } 

    //        colsList.add(toValue(bal));                      //คำนวณเอง
    //        colsList.add(toValue(dataModel.MN_PYMT_AMT));
    //        colsList.add(toValue(dataModel.CRN_BAL));       //
    //        colsList.add(toValue(changeDateformat(dataModel.DUE_DT)) );        //format
    //        if(isMainCard)
    //          colsList.add(toValue('บัตรหลัก'));                     //บัตรหลักเสริม
    //        else 
    //          colsList.add(toValue('บัตรเสริม'));
    //        if( checkValidDateFormat(dataModel.EXP_DT))
    //          colsList.add(toValue(getCardExpireDateFormat(dataModel.EXP_DT)) );
    //        else       // chanhe format
    //          colsList.add('');
    //        colsList.add(toValue(cardSTMap.get(getFirstIndex(dataModel.ST_CD)) ));          //c conver to string
    
    //        CustomerSearch_Controller.Customer tempCustomer = new CustomerSearch_Controller.Customer(dataModel.IP_ID,FALSE,TRUE);
    //        String imgurl = tempCustomer.fullName != null ? tempCustomer.fullName : '';

    //        if(isMainCard){
    //          colsList.add(toValue('<img src='+imgurl+'>' )  );
    //          colsList.add(toValue(''));
    //        }else{
    //          colsList.add(toValue(''));
    //          colsList.add(toValue('<img src='+imgurl+'>' )  );
    //        }

    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('POD',dataList);
    //}

    //public void handleHLResponse(HttpResponse response) {
    //  if(!validateResponse('HL', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('HL',dataList);
    //}

    //public void handleLNResponse(HttpResponse response) {
    //  if(!validateResponse('LN', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('LN',dataList);
    //}

    //public void handleODResponse(HttpResponse response) {
    //  if(!validateResponse('OD', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('OD',dataList);
    //}

    //public void handlePNResponse(HttpResponse response) {
    //  if(!validateResponse('PN', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('PN',dataList);
    //}

    //public void handleTFResponse(HttpResponse response) {
    //  if(!validateResponse('TF', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('TF',dataList);
    //}

    //public void handleLIResponse(HttpResponse response) {
    //  if(!validateResponse('LI', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('LI',dataList);
    //}

    //public void handleKGroupResponse(HttpResponse response) {
    //  if(!validateResponse('K_Group', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('K_Group',dataList);
    //}

    /**
    Handle Non-Credit Response
    - handleCurrentResponse
    - handleFixedResponse
    - handleSavingResponse
    - handleTaweesupResponse
    - handleMutualFundResponse
    - handleDepositResponse
    - handleKAssetResponse
    - handleBAResponse
    **/

   public void handleCurrentResponse(HttpResponse response) {
      if(!validateResponse('Current', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_CurrentResultResponse responseModel = SME_CurrentResultResponse.parse(responseStr);
        if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.current != null) {
          for(SME_CurrentResultResponse.current_model dataModel : responseModel.returnResponse.current) {
              List<String> colsList = new List<String>();
              colsList.add(toValue(dataModel.AR_ID));
              colsList.add(toValue(dataModel.AR_NM_TH));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
              colsList.add(GlobalUtility.toAccountType(toValue(dataModel.OWN_TP_CD)));
              dataList.add(colsList);
          }
        }
      this.responseMap.put('Current', dataList);
    }

    public void handleFixedResponse(HttpResponse response) {
      if(!validateResponse('Fixed_Deposit', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();

      SME_FixedResultResponse responseModel = SME_FixedResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_FixedResultResponse.fixed_model dataModel : responseModel.returnResponse.fixed) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.SUB_AR));
            colsList.add(toValue(dataModel.AR_NM_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colsList.add(toValue(dataModel.OPN_DT));
            colsList.add(toValue(dataModel.EFF_RATE_PCT));
            colsList.add(toValue(dataModel.AR_TERM));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
            colsList.add(GlobalUtility.toAccountType(toValue(dataModel.OWN_TP_CD)));
            dataList.add(colsList);
        }
      }
      responseMap.put('Fixed_Deposit',dataList);
    }

    public void handleSavingResponse(HttpResponse response) {
      if(!validateResponse('Saving', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_SavingResultResponse responseModel = SME_SavingResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.saving != null) {
        for(SME_SavingResultResponse.saving_model dataModel : responseModel.returnResponse.saving) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.AR_NM_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
            colsList.add(GlobalUtility.toAccountType(toValue(dataModel.OWN_TP_CD)));
            dataList.add(colsList);
        }
      }
      responseMap.put('Saving',dataList);
      
    }
    public void handleTaweesupResponse(HttpResponse response) {
      if(!validateResponse('Taweesup', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_TaweesupResultResponse responseModel = SME_TaweesupResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.taweesup != null) {
        for(SME_TaweesupResultResponse.taweesup_model dataModel : responseModel.returnResponse.taweesup) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(null));
            colsList.add(toValue(null));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colsList.add(toValue(dataModel.OPN_DT));
            colsList.add(toValue(dataModel.EFF_RATE_PCT));
            colsList.add(toValue(null));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HLD_BAL_AMT)));
            colsList.add(GlobalUtility.toAccountType(toValue(dataModel.OWN_TP_CD)));
            dataList.add(colsList);
        }
      }
      responseMap.put('Taweesup',dataList);
    }

    public void handleMutualFundResponse(HttpResponse response) {
      if(!validateResponse('Mutual_Fund', response)) return;
      String responseStr = response.getBody();
      List<List<String>> dataList = new List<List<String>>();

      SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.SUB_AR));
            colsList.add(toValue(dataModel.AR_NM_TH));

            colsList.add(toValue(dataModel.FND_CD));
            colsList.add(toValue(dataModel.FND_DSC_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
            colsList.add(toValue(dataModel.NAV_DT));
            colsList.add(toValue(dataModel.NAV));

            Decimal bal;
            if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
              bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
            } 
            colsList.add(toValue(bal));
            colsList.add(toValue(dataModel.FND_TP_CD));
            colsList.add(toValue(dataModel.AR_OWN_TP_CD));
            dataList.add(colsList);
        }
      }
      responseMap.put('Mutual_Fund',dataList);
    }


    //public void handleKAssetResponse(HttpResponse response) {
    //  if(!validateResponse('K_Asset', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('K_Asset',dataList);
    //}

    //public void handleBAResponse(HttpResponse response) {
    //  if(!validateResponse('BA', response)) return;
    //  String responseStr = response.getBody();
    //  List<List<String>> dataList = new List<List<String>>();

    //  SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
    //  if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
    //    for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
    //        List<String> colsList = new List<String>();
    //        colsList.add(toValue(dataModel.AR_ID));
    //        colsList.add(toValue(dataModel.SUB_AR));
    //        colsList.add(toValue(dataModel.AR_NM_TH));

    //        colsList.add(toValue(dataModel.FND_CD));
    //        colsList.add(toValue(dataModel.FND_DSC_TH));
    //        colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
    //        colsList.add(toValue(dataModel.NAV_DT));
    //        colsList.add(toValue(dataModel.NAV));

    //        Decimal bal;
    //        if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
    //          bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
    //        } 
    //        colsList.add(toValue(bal));
    //        colsList.add(toValue(dataModel.FND_TP_CD));
    //        colsList.add(toValue(dataModel.AR_OWN_TP_CD));
    //        dataList.add(colsList);
    //    }
    //  }
    //  responseMap.put('BA',dataList);
    //}

    /**
    Finish Group of Non-Credit
    **/

    

    public void handleNonCreditData(HttpResponse nonCreditResponse,HttpResponse fcdResponse) {
      //Noncredit Part
      //if(!validateResponse('nonCreditData', nonCreditResponse)) return;
      Map<String, Object> dataMap = new Map<String, Object>();
      boolean isNonCreditProductValid = validateResponse('nonCreditData', nonCreditResponse);
      if(isNonCreditProductValid){
        String responseStr = nonCreditResponse.getBody();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        //Map<String, Object> dataMap = new Map<String, Object>();
        SME_NonCreditOutStandingResultResponse responseModel = SME_NonCreditOutStandingResultResponse.parse(responseStr);
        if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.outstanding != null) {
              for(SME_NonCreditOutStandingResultResponse.nonCreditOutStandingResponse_model dataModel : responseModel.returnResponse.outstanding) {
                  String arType = '';
                  if(dataModel.AR_TYPE == 'SA')   arType = 'Saving_Outstanding';
                  else if(dataModel.AR_TYPE == 'CA')  arType = 'Current_Outstanding';
                  else if(dataModel.AR_TYPE == 'KA')  arType = 'Mutual_Fund_Outstanding';
                  else if(dataModel.AR_TYPE == 'FD')  arType = 'Fixed_Deposit_Outstanding';
                  else if(dataModel.AR_TYPE == 'TW')  arType = 'Taweesup_Outstanding';
                  //else if(dataModel.AR_TYPE == 'KS')  arType = 'K_Asset_Outstanding';
                  else arType = dataModel.AR_TYPE;
                  dataMap.put(arType, GlobalUtility.toCurrency(dataModel.OST));
              }
        }
      }
      //FCD part
      boolean isFCDvalid = validateResponse(financialInformationData.FCD, fcdResponse);

      String fcdResponseStr = fcdResponse.getBody();
      List<List<String>> dataList = new List<List<String>>();
      double OTSND_BAL_SUM = 0.00;
      if(isFCDvalid){
        SME_FCDResultResponse.FCD_Model  fcdResponseModel = (SME_FCDResultResponse.FCD_Model) System.JSON.deserialize(fcdResponseStr, SME_FCDResultResponse.FCD_Model.class);
        if(fcdResponseModel != null  && fcdResponseModel.Detail !=null  && fcdResponseModel.Detail.AR_DTL_LIST !=null  && fcdResponseModel.Detail.AR_DTL_LIST.FCD_AR_DTL_INF !=null && fcdResponseModel.Detail.AR_DTL_LIST.FCD_AR_DTL_INF.size() >0) {
          for(SME_FCDResultResponse.FCD_AR_DTL_INF eachFCD :  fcdResponseModel.Detail.AR_DTL_LIST.FCD_AR_DTL_INF){
            if(eachFCD.CNVR_OTSND_BAL != null ){
              OTSND_BAL_SUM = OTSND_BAL_SUM + GlobalUtility.toDecimal(eachFCD.CNVR_OTSND_BAL);
            }
            String outstandingCCYinCurrencyFormat = GlobalUtility.toCurrency(eachFCD.CCY_OTSND_BAL);
            String outstandingTHBinCurrencyFormat = GlobalUtility.toCurrency(eachFCD.CNVR_OTSND_BAL);
            List<String> colsList = new List<String>();
            colsList.add( eachFCD.AR_ID_TXT);
            colsList.add( eachFCD.OPN_DT);
            colsList.add( eachFCD.CLS_DT);
            colsList.add( eachFCD.FCD_TP_CD);
            colsList.add( eachFCD.PD_TP_CD_TXT);
            colsList.add( eachFCD.CCY_CD);
            colsList.add( outstandingCCYinCurrencyFormat);
            colsList.add( outstandingTHBinCurrencyFormat);
            colsList.add( eachFCD.AR_LCS_TP_CD_TXT);
            dataList.add(colsList);
          }
        }

      }

      if(!isNonCreditProductValid){
        //String errorMsg = (Map<String,Object>)(this.responseMap.get('nonCreditData')).get('error');
        String errorMsgJSON = JSON.serialize(this.responseMap.get('nonCreditData'));
        List<String> splitErrMsgs = errorMsgJSON.split(':');
        String errMsg = splitErrMsgs[1].remove('"').remove('}');
        dataMap.put('error',errMsg);
        //this.responseMap.get('nonCreditData');
        //dataMap.put('error', errorMsg);
      }
      if(!isFCDvalid){
        dataMap.put('FCD_Outstanding','');
      }else{
        dataMap.put('FCD_Outstanding', GlobalUtility.toCurrency(OTSND_BAL_SUM));
      }
      Map<String,Object> fcdResponseMapTemp = new  Map<String,Object>();
      fcdResponseMapTemp.put(financialInformationData.FCD,dataList);
      this.responseMapJsonFCD = JSON.serializePretty(fcdResponseMapTemp);
      this.responseMap.put('nonCreditData', dataMap);
    }

    public void handleCreditData(HttpResponse response) {
      if(!validateResponse('creditData', response)) return;
      String responseStr = response.getBody();
      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

      FinancialInformation_Model financialModel = new FinancialInformation_Model(currentCis,this.language);
      Map<String, String> dataMap = financialModel.getCreditLimitDataMap();

      SME_CreditOutStandingResultResponse responseModel = SME_CreditOutStandingResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.outstanding != null) {
        for(SME_CreditOutStandingResultResponse.creditOutStandingResponse_model dataModel : responseModel.returnResponse.outstanding) {
            String arType = '';
            if(dataModel.AR_TYPE == 'POD')  arType = 'KEC_Outstanding';
            else if(dataModel.AR_TYPE == 'KG')  arType = 'K_Group_Outstanding';
            else if(dataModel.AR_TYPE == 'POD_Limit') arType = 'KEC_Limit';
            else if(dataModel.AR_TYPE == 'CC_Limit') arType = 'CC_Limit';
            else arType = dataModel.AR_TYPE + '_Outstanding';
            dataMap.put(arType, GlobalUtility.toCurrency((dataModel.OST) ));
        }
      }
      this.responseMap.put('creditData', dataMap);
    }

    public void initData() {
        setupUtilizationData();
        setupKBankStmData();
        setupFinancialData();
    }

    public void setupFinancialData() {
        financialInformationData = new FinancialInformation_Model(this.cis,this.language);
    }

    public void setupUtilizationData() {
        utilizationData = new Utilization_Model(this.cis);
    }

    public void setupKBankStmData() {
        //INC000000530441 Fixed query statement by change from DESC to ASC
        List<KBANK_STM__c> stmList = [SELECT Id, Name, Amount_Inflow__c, Amount_Outflow__c, CASA_Average_Balance__c, Cheque_Paid_Items__c, Cheque_Paid_Amount__c, Cheque_Return_Items__c, Cheque_Return_Amount__c, TXN_Inflow__c, TXN_Outflow__c FROM KBANK_STM__c WHERE CIS_ID__c = :accountId ORDER BY Name,As_of_Date__c ASC];
        Date todayDate = System.today();
        kbankSTMHeader = new List<String>();
        kbankSTMHeader.add('Statement');
        kbankSTMHeader.add('Summary 12 Months');

        Map<String, List<String>> dataMap = new Map<String, List<String>>();
        Map<String, Decimal> summaryMap = new Map<String, Decimal>();
        for(String statement : statementList) {
            dataMap.put(statement, new List<String>{statement});
            summaryMap.put(statement, 0);
        }

        Decimal inflowSummary = 0;
        Decimal outflowSummary = 0;

        Map<String, sObject> stmMapByMonth = GlobalUtility.toMap('Name', stmList);

        for(Integer i=1; i<=12; i++) {
            KBANK_STM__c stm;
            String key = i > 9 ? String.valueOf(i) : '0'+String.valueOf(i);
            if(stmMapByMonth.containsKey(key))      stm = (KBANK_STM__c)stmMapByMonth.get(key);
            else                                    stm = new KBANK_STM__c();

            Date thisDate = date.newinstance(todayDate.year(), todayDate.month() - i , 1);
           // Integer year = thisDate.year() > 2400 ? thisDate.year() - 543 : thisDate.year();
            Integer year = GlobalUtility.getYearInChristianCalendar(thisDate);
            String yearStr = String.valueOf(year).substring(2);
            kbankSTMHeader.add(monthStrMap.get(thisDate.month())+'-'+yearStr);

            summaryMap.put(AMOUNT_INFLOW, summaryMap.get(AMOUNT_INFLOW) + GlobalUtility.toDecimal(stm.Amount_Inflow__c));
            dataMap.get(AMOUNT_INFLOW).add(stm.Amount_Inflow__c == null ? '' : GlobalUtility.toCurrency(stm.Amount_Inflow__c));

            summaryMap.put(AMOUNT_OUTFLOW, summaryMap.get(AMOUNT_OUTFLOW) + GlobalUtility.toDecimal(stm.Amount_Outflow__c));
            dataMap.get(AMOUNT_OUTFLOW).add(stm.Amount_Outflow__c == null ? '' : GlobalUtility.toCurrency(stm.Amount_Outflow__c));

            summaryMap.put(CASA_AVG, summaryMap.get(CASA_AVG) + GlobalUtility.toDecimal(stm.CASA_Average_Balance__c));
            dataMap.get(CASA_AVG).add(stm.CASA_Average_Balance__c == null ? '' : GlobalUtility.toCurrency(stm.CASA_Average_Balance__c));

            summaryMap.put(CHEQUE, summaryMap.get(CHEQUE) + GlobalUtility.toDecimal(stm.Cheque_Paid_Items__c));
            dataMap.get(CHEQUE).add(stm.Cheque_Paid_Items__c == null ? '' : stm.Cheque_Paid_Items__c);

            summaryMap.put(CHEQUE_AMOUNT, summaryMap.get(CHEQUE_AMOUNT) + GlobalUtility.toDecimal(stm.Cheque_Paid_Amount__c));
            dataMap.get(CHEQUE_AMOUNT).add(stm.Cheque_Paid_Amount__c == null ? '' : GlobalUtility.toCurrency(stm.Cheque_Paid_Amount__c));

            summaryMap.put(CHEQUE_RETURN, summaryMap.get(CHEQUE_RETURN) + GlobalUtility.toDecimal(stm.Cheque_Return_Items__c));
            dataMap.get(CHEQUE_RETURN).add(stm.Cheque_Return_Items__c == null ? '' : GlobalUtility.toValue(stm.Cheque_Return_Items__c));

            summaryMap.put(CHEQUE_RETURN_AMOUNT, summaryMap.get(CHEQUE_RETURN_AMOUNT) + GlobalUtility.toDecimal(stm.Cheque_Return_Amount__c));
            dataMap.get(CHEQUE_RETURN_AMOUNT).add(stm.Cheque_Return_Amount__c == null ? '' : GlobalUtility.toCurrency(stm.Cheque_Return_Amount__c));

            summaryMap.put(TXN_INFLOW, summaryMap.get(TXN_INFLOW) + GlobalUtility.toDecimal(stm.TXN_Inflow__c));
            dataMap.get(TXN_INFLOW).add(stm.TXN_Inflow__c == null ? '' : stm.TXN_Inflow__c);

            summaryMap.put(TXN_OUTFLOW, summaryMap.get(TXN_OUTFLOW) + GlobalUtility.toDecimal(stm.TXN_Outflow__c));
            dataMap.get(TXN_OUTFLOW).add(stm.TXN_Outflow__c == null ? '' : stm.TXN_Outflow__c);
        }

        for(String statement : summaryMap.keySet()) {
            if(dataMap.get(statement).size() > 1) {
                dataMap.get(statement).add(1, GlobalUtility.toCurrency(summaryMap.get(statement)));
            }
        }

        kbankSTMData = new List<List<String>>();
        for(String statement : statementList) {
            kbankSTMData.add(dataMap.get(statement));
        }
    }


    public String toValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }

    private String getFirstIndex(String type){
      if(type == null || type == '') return '';
      String key;
      key = type.substring(0,1);
      return key;   
    }

    private String changeDateformat(String oldDateFormat){
      if( oldDateFormat == null || oldDateFormat == '') return '';
      String[] splitDate = oldDateFormat.split('-');
      Integer year = integer.valueOf(splitDate[0]);
      year = (year < 2500) ? year + 543 : year;
      String newDateFormat = splitDate[2]+'/'+splitDate[1]+'/'+year;
      return newDateFormat;
    }

    private String getCardExpireDateFormat(String oldDateFormat){
      if( oldDateFormat == null || oldDateFormat == '') return '';
        String month = oldDateFormat.substring(0,2);
        String year  = oldDateFormat.substring(2);
        String newExpireDateFormat = monthThaiStrMap.get(integer.valueOf(month))+'-'+year;
        return newExpireDateFormat;
    }

    private String changeStatementDateFormat(String statementDate){
      String statementDateFormate;
      Integer stmtday = Integer.valueOf(statementDate);
      Datetime dateCardLine = Datetime.newInstance(currentDate.year(), currentDate.month(), stmtday);
        if(stmtday < this.currentDate.day()){
          dateCardLine = dateCardLine.addMonths(1);
        }
     // Integer year = (dateCardLine.year() < 2500) ? dateCardLine.year() + 543 : dateCardLine.year();
        Integer year = GlobalUtility.getYearInBuddhistCalendar(dateCardLine);
      statementDateFormate = dateCardLine.format('dd/MM/yyyy').left(6)+year;
      return statementDateFormate;
    }

    private Boolean checkValidDateFormat(String dateFormat){
      return dateFormat.isNumeric();
    }



}