/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:    Customer Search Controller

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
07/06/2015  Komsan.wi           Renovated
27/04/2016  Natthanan.K         Update by add Primary_Segment_Desc__c field for show Segment Information
01/11/2016  Charnun.T           INC000000454462 Change customer serach criteria
24/01/2017  Charnun.T           INC000000505799 Change create button criteria
22/03/2017  Anan.B              INC000000543218 Change request entry criteria
29/03/2017  Anan.B              CBS-CR005 add condition for CBS user to request account from CBS-Admin
26/04/2018  Wongsakorn.S        Delete unused field Name_EN_Prospect__c,Surname_TH_Prospect__c,Surname_EN_Prospect__c
------------------------------------------------------------*/
public without sharing class CustomerSearch_Controller extends CustomerSearch_Management{
    transient Boolean hasError;
    transient Boolean hasInfo;
    public String errorMessage{get;set;}
    
    public String requestLabel;

    public String id {get;set;}
    public String cis {get;set;}
    public String firstname {get;set;}
    public String lastname {get;set;}

    public String prospect_id;
    public String prospect_cis;
    public String prospect_firstname;
    public String prospect_lastname;

    public String sortDirection = 'ASC';
    public String sortExp = 'name';
    public Boolean isEnglishInput_FN = null;
    public Boolean isEnglishInput_LN = null;

    public List<Customer> customerList {get;set;}
    public List<Customer> finalCustomerList {get;set;}
    public List<String> displayedCisList {get;set;}
    public String requestOwnershipValue {get;set;}
    public String lang {get;set;}
    public static final String FIRSTNAME_TH = 'TH_FRST_NM';
    public static final String FIRSTNAME_EN = 'EN_FRST_NM';
    public static final String SURNAME_TH = 'TH_SURNM';
    public static final String SURNAME_EN = 'EN_SURNM';
    public static final String FULL_NAME = 'FULL_NAME';
    public static final String IDENT_NO = 'IDENT_NO';
    public static final String CIS_ID = 'IP_ID';
    public static final String LIMIT_VAR = 'LIMIT';
    public static final String CIS_LIST = 'IP_ID';
    public static final String SORT_TYPE = 'SORT_TYPE';
    public static final String SORT_COLUMN = 'SORT_COLUMN';
    
    private static final String PROS_IDENT_NO = 'Encrypt_Identification_No__c';
    
    private static final Integer PAGE_SIZE = CustomSettingUtil.getSearchResults();
    private static final String TIME_OUT_CASE = 'Read timed out';
    private static final String SERVICE_UNAVAILABLE_CASE = '503';
    private static final String DATABASE_UNAVAILABLE_CASE = '504';//1906503
    private static final String INCORRECT_USER_PASS_CASE = '401';
    private static final String URI_UNAVAILABLE_CASE = '404';
    private static final String EN_LANGUAGE = 'en_US';
    private static final String TH_LANGUAGE = 'th';
    //Add For (CBS-Ongoing) CBS-CR005
    private static final Id CBSADMIN_SFID = CBS_Admin_Ownership__c.getOrgDefaults().User_Record_ID__c;
 
    public String ownerShipId{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}

    /* CR023 */
    public Boolean userIsAN {get;set;}
    /*-------*/

    public Boolean showProspectButton{get;set;}

    public static Map<String, Id> RecordTypeAccount = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
    
    private Map<String,String> errorMap = new Map<String,String>();
    private Set<String> setCISId = new Set<String>();
    private Id existingId;
    private String identNo;
    private String birthdate;

    // Fraud
    public Boolean isShowFraud {get;set;}
    public Boolean isShowFraudColor {get;set;}
    public String colorCode {get;set;}
    public String fraudStatus;
    public String fraudMessage {get;set;}

    private User ownerUser;
    public class Customer{
        public User currentUser{get;set;}
        public Account accountObj{get;set;}
        public String firstNameTH{get;set;}
        public String firstNameEN{get;set;}
        public String surNameTH{get;set;}
        public String surNameEN{get;set;}
        public String fullName{get;set;}
        public String province{get;set;}
        public String district{get;set;}
        public String identificationNo{get;set;}
        public String documentType{get;set;}
        public String birthdateRegistrationDate{get;set;}
        public Boolean isMashup{get;set;}
        public Boolean showRequestOwnershipButton{get;set;}
        public String mashupEndPoint;
        public String teamStructure{get;set;}
        public String getURLStringFromCISAndFieldName(String cis,String fieldName,Boolean isEnglishInput_FN,Boolean isEnglishInput_LN){
            String imgURL = '';
            String functionName = 'getURLStringFromCISAndFieldName';
            if (mashupEndpoint == null){
                // read mashup endpoint from customsetting
                mashupEndPoint = CustomSettingUtil.getEndpointByName('MashupEndpoint');
                //writeDebugMessage(functionName,'Mashup Endpoint:'+mashupEndPoint);
            }
            if(isEnglishInput_FN == true || isEnglishInput_LN == true){
                if(isEnglishInput_FN == false || isEnglishInput_LN == false){
                    imgURL = 'customer/th/'+cis+'/'+fieldName+'.gif';
                }else{
                    imgURL = 'customer/en/'+cis+'/'+fieldName+'.gif';
                }
            }else{
                imgURL = 'customer/th/'+cis+'/'+fieldName+'.gif'; 
            }

            String encryptImgURL = GlobalUtility.getEncryptedDataWithTransform('Test1234 Exameod',imgURL);
            String fullPathEncryptImgURL = mashupEndPoint+'encrypt/'+encryptImgURL;
            String fullPatheImgURL = mashupEndPoint+imgURL;
            return fullPathEncryptImgURL;
        }

        public Customer(User ownerUser, Account accountObj, Map<String,sObject> mapAddress, Boolean isEnglishInput_FN, Boolean isEnglishInput_LN){
            this.accountObj = accountObj;
            this.currentUser = ownerUser;
            this.isMashup = false;        
            if(accountObj.RecordTypeId == RecordTypeAccount.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) || accountObj.RecordTypeId == RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME)){
                this.firstNameTH =  accountObj.Name;
                //this.identificationNo = accountObj.Encrypt_Identification_No__c;
                this.identificationNo = accountObj.Identification_No_Mask__c;
                this.documentType = accountObj.Document_Type_Prospect__c;
                this.showRequestOwnershipButton = false; // Phase 2 Change requirement
                this.district = '-';
                this.province = '-';
            }else{
                sObject tempObj = null;
                if(mapAddress != null){
                    tempObj = mapAddress.get(accountObj.CIS__c);
                }
                this.fullName = accountObj.Name;
                //this.identificationNo = accountObj.Encrypt_Identification_No__c;
                this.identificationNo = accountObj.Identification_No_Mask__c;
                if(tempObj != null){
                    this.district = String.valueOf(tempObj.get('District__c'));
                    this.province = String.valueOf(tempObj.get('Province__c'));
                }else{
                    this.district = '-';
                    this.province = '-';
                }

                // Add for (CBS-Ongoing 25/01/17) CBS User cannot see cbs customer request botton except OwnerIsCBSADMIN
                if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(ownerUser.Segment__c) &&  GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)){
                    //CBS-CR005
                    if(CBSADMIN_SFID != null && accountObj.OwnerId != CBSADMIN_SFID ){
                     this.showRequestOwnershipButton = false;
                    }else{
                     this.showRequestOwnershipButton = false;
                    }
                }else if(accountObj.Owner.Profile.Name == GlobalConstants.SME_ADMIN && !accountObj.Is_SME_Customer__c && !accountObj.Is_CBS_Customer__c){
                    this.showRequestOwnershipButton = false;
                }else{
                    this.showRequestOwnershipButton = false;
                }
             //   this.showRequestOwnershipButton = True; // Phase 2 Change requirement
            }
            if(accountObj.Birthdate_Registration_Date__c != null){
                Datetime tempDate = accountObj.Birthdate_Registration_Date__c;
                this.birthdateRegistrationDate = String.valueOf('0'+String.valueOf(tempDate.day())).right(2)+'/'+String.valueOf('0'+String.valueOf(tempDate.month())).right(2)+'/'+String.valueOf(tempDate.year());
            }
            // 26/09/2016
            if(String.valueOf(accountObj.OwnerId) == String.valueOf(UserInfo.getUserId())){
                this.showRequestOwnershipButton = false;
            }
        }

        public Customer(User ownerUser, Account accountObj, Boolean isEnglishInput_FN, Boolean isEnglishInput_LN){
            this.accountObj = accountObj;
            this.currentUser = ownerUser;

                this.firstNameTH =  accountObj.Name;
                //this.identificationNo = accountObj.Encrypt_Identification_No__c;
                this.identificationNo = accountObj.Identification_No_Mask__c;
                this.documentType = accountObj.Document_Type_Prospect__c;
                this.showRequestOwnershipButton = false; // Phase 2 Change requirement
                this.district = '-';
                this.province = '-';
                this.teamStructure = accountObj.Max_Wealth_Branch__r.Name;
                this.isMashup = false;

                if(isEnglishInput_FN == true || isEnglishInput_LN == true){
                    this.fullName = accountObj.Name;
                }else{
                    this.fullName = accountObj.Name;
                }
                             
                this.district = '-';
                this.province = '-';

                // Add for (CBS-Ongoing 25/01/17) CBS User cannot see cbs customer request botton except OwnerIsCBSADMIN
                if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(ownerUser.Segment__c) &&  GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)){
                    //CBS-CR005
                    if(CBSADMIN_SFID != null && accountObj.OwnerId != CBSADMIN_SFID ){
                     this.showRequestOwnershipButton = false;
                    }else{
                     this.showRequestOwnershipButton = false;
                    }
                }else if(accountObj.Owner.Profile.Name == GlobalConstants.SME_ADMIN && !accountObj.Is_SME_Customer__c && !accountObj.Is_CBS_Customer__c){
                    this.showRequestOwnershipButton = false;
                }else{
                    this.showRequestOwnershipButton = false;
                }
                if(GlobalConstants.PROFILE_RBS_SET.contains(ownerUser.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(ownerUser.Profile.Name)){
                    this.showRequestOwnershipButton = false;
                }

             //   this.showRequestOwnershipButton = True; // Phase 2 Change requirement
            
            if(accountObj.Birthdate_Registration_Date__c != null){
                Datetime tempDate = accountObj.Birthdate_Registration_Date__c;
                this.birthdateRegistrationDate = String.valueOf('0'+String.valueOf(tempDate.day())).right(2)+'/'+String.valueOf('0'+String.valueOf(tempDate.month())).right(2)+'/'+String.valueOf(tempDate.year());
            }
            // 26/09/2016
            if(String.valueOf(accountObj.OwnerId) == String.valueOf(UserInfo.getUserId())){
                this.showRequestOwnershipButton = false;
            }
        }

        public Customer(String cisNumber, Boolean isEnglishInput_FN, Boolean isEnglishInput_LN){
            this.fullName =  getURLStringFromCISAndFieldName(cisNumber,FULL_NAME,isEnglishInput_FN,isEnglishInput_LN);
            this.identificationNo =  getURLStringFromCISAndFieldName(cisNumber,IDENT_NO,isEnglishInput_FN,isEnglishInput_LN);
            //this.documentType = accountObj.Document_Type__c;
            this.showRequestOwnershipButton = false;
            this.isMashup = true;
        }
    }

    public CustomerSearch_Controller(){
        isShowFraud = false;
        isShowFraudColor = false;
        hasError = false;
        hasInfo = false;
        customerList = new List<Customer>();
        finalCustomerList = new List<Customer>();
        showProspectButton = false;
        this.sortDirection = 'ASC';
        this.page = 1;
        ownerUser = getUserFromId(UserInfo.getUserId());

        if(GlobalConstants.PROFILE_AN_SET.contains(ownerUser.Profile.Name)){
            userIsAN = true;
        }else{
            userIsAN = false;
        }

        // Test POP 06/09/2016
        this.existingId = ApexPages.currentPage().getParameters().get('existingId');
        this.birthdate = ApexPages.currentPage().getParameters().get('birthdate');
        this.identNo = ApexPages.currentPage().getParameters().get('identNo');
        if(this.existingId != null || (this.birthdate != null && this.identNo != null)) {
            getExistingCustomer();
        }
    }

    public void doNext(){
        if(getHasNext()){
            this.page++;
            getCustomersFinal();
        }
    }

    public void doPrevious(){
        if(getHasPrevious()){
            this.page--;
            getCustomersFinal();
        }      
    }

    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }

    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }

    public void getExistingCustomer() {
        String functionName = 'getExistingCustomer';
        this.totalRecords = 0;
        this.finalCustomerList.clear();

        List<Account> existingAccount = new List<Account>();
        List<List<sObject>> existingAccountSOSL = new List<List<sObject>>();
        if(this.existingId != null) {
            existingAccountSOSL = [FIND :this.existingId IN ALL Fields
                   RETURNING Account(Id, Name, Encrypt_Identification_No__c, Identification_No_Mask__c, Document_Type_Prospect__c, CIS__c, Birthdate_Registration_Date__c, RecordTypeId, RecordType.DeveloperName, Customer_360__c, Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,OwnerId,Owner.Name,Document_Type__c,Port_Pool__c,Is_SME_Customer__c,Is_CBS_Customer__c,Owner.Profile.Name) LIMIT 1];
                   existingAccount = (List<Account>)existingAccountSOSL[0];
        } else if(this.birthdate != null && this.identNo != null) {
            Date birthdateDate = Date.valueOf(this.birthdate);    
            existingAccountSOSL = [FIND :this.identNo IN All Fields
                   RETURNING Account(Id, Name, Encrypt_Identification_No__c, Identification_No_Mask__c, Document_Type_Prospect__c, CIS__c, Birthdate_Registration_Date__c, RecordTypeId, RecordType.DeveloperName, Customer_360__c, Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,OwnerId,Owner.Name,Document_Type__c,Port_Pool__c,Is_SME_Customer__c,Is_CBS_Customer__c,Owner.Profile.Name )];
                   
                   for(Account eachAcc :(List<Account>)existingAccountSOSL[0]){
                        if(eachAcc.Birthdate_Registration_Date__c == birthdateDate){
                            existingAccount.add(eachAcc);
                        }
                   }
        }
        
        if(existingAccount == null || existingAccount.size() == 0) return;

        Customer customerModel;
        for(Account eachAccount : existingAccount) {
            customerModel = new Customer(ownerUser, eachAccount, null, true, true);
            this.finalCustomerList.add(customerModel);
        }
        this.finalCustomerList.add(customerModel);
        this.totalRecords = existingAccount.size();
    }

    public void getCustomersFinal(){
        String functionName = 'getCustomersFinal';
        finalCustomerList.clear();
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;

        for(Customer each : customerList){
            if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
                this.finalCustomerList.add(each);
            } else{
                System.debug('==>totalRecords'+totalRecords+'this.startIdx:'+this.startIdx+'this.endIdx:'+this.endIdx);
            }
            this.totalRecords++;
        }
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        this.startIdx++;
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
        if(this.firstname != '' || this.lastname != '' || finalCustomerList.size() == 0){
            showProspectButton = true;
        }

        if (this.id.trim() != '' && finalCustomerList.size() > 0) {
            // INC000000505799 Change create button criteria
            showProspectButton = true;
        }
        if(this.totalRecords >= 100){
            showInfoMessageOnPage(System.Label.Search_More100Records);
        }
        writeDebugMessage(functionName,'finalCustomerList.size = '+finalCustomerList.size());
    }

    public String sortExpression{
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }else{
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == ''){
            return 'ASC';
        }else{
            return sortDirection;
        }
    }

    public void setSortDirection(String value){  
        sortDirection = value;
    }
    /*
    public Boolean getRequestOwnerShipId() {
        System.debug(requestOwnershipValue);
        String functionName = 'canRequestOwnerShip';    
        try{        
            Account requestAccount = getAccountFromId(requestOwnershipValue);        
            ownerShipId = '';
            if(requestAccount != null && ownerUser != null){
                if(GlobalConstants.PROFILE_AN_SET.contains(ownerUser.Profile.Name)){
                    showErrorMessageOnPage(Label.Request_Ownership_Error_User);
                    return false;
                }else if(GlobalConstants.PROFILE_AN_SET.contains(requestAccount.Owner.Profile.Name)){
                    showErrorMessageOnPage(Label.Request_Ownership_Error_Customer);
                    return false;
                }

                List<Customer_Ownership_Request__c> currentRecord = new List<Customer_Ownership_Request__c>();
                currentRecord = [SELECT Id,Approval_Status__c FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:requestAccount.Id AND OwnerID=:ownerUser.Id AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC LIMIT 1];
                
                //Add For INC000000543218
                if( !Ownership_Service.isOwnerSegmentOrProfileAllowToRequestOwnership(requestAccount)){
                    showErrorMessageOnPage(System.label.Request_Ownership_Error_Segment);
                    return false;
                }

                if(ownerUser.Profile.Name != GlobalConstants.SME_RM  && ownerUser.Profile.Name != GlobalConstants.CBS_RM && ownerUser.Profile.Name != GlobalConstants.CBS_TM && ownerUser.Profile.Name != GlobalConstants.CBS_TL){
                    if(ownerUser.Profile.Name == GlobalConstants.SME_TM ){
                        if(requestAccount.Owner.SME_User__c || requestAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN ){
                            // Edit For (CBS-Ongoing) 18/01/17 if account is not in CBS segment code , can guarautee that this customer belonges to SME
                            if(!GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(requestAccount.Primary_Segment_Code__c) ){
                                showErrorMessageOnPage(System.Label.TM_can_request_from_CBS_only);
                                return false;
                            }
                        }
                    }else{
                        showErrorMessageOnPage(System.Label.Search_Not_SME_RM);
                        return false;
                    }
                }

                if(GlobalConstants.PROFILE_SME_SET.contains(ownerUser.Profile.Name) || GlobalConstants.PROFILE_CBS_SET.contains(ownerUser.Profile.Name)){
                    if(GlobalConstants.PROFILE_RBS_SET.contains(requestAccount.Owner.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(requestAccount.Owner.Profile.Name)){

                      showErrorMessageOnPage(System.Label.SMECBS_cannot_request_Prospect_from_RBSAF);
                      return false;  
                    }                   
                }

                if(requestAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || requestAccount.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME){ // Prospect
                    if(ownerUser.SME_User__c || ownerUser.RBS_User__c){
                        if(requestAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN){
                            showErrorMessageOnPage(System.Label.SME_cannot_request_Prospect_from_SME_Admin);
                            return false;
                        }else if(!requestAccount.Owner.SME_User__c && !requestAccount.Owner.RBS_User__c && requestAccount.Owner.Profile.Name != GlobalConstants.SME_ADMIN){
                            if(requestAccount.Owner.CBS_User__c){
                                showErrorMessageOnPage(System.Label.SME_cannot_request_Prospect_from_CBS); // sme-cannot request cbs prospect
                                return false;
                            }else{
                                showErrorMessageOnPage(System.Label.Customer_Owner_must_be_SME_CBS_or_RBS_segment_only); // sme-cannot request non-sme,non-rbs prospect
                                return false;
                            }
                        }
                    }else{
                        showErrorMessageOnPage(System.Label.CBS_cannot_request_prospect);
                        return false;
                    }
                }else if(requestAccount.Owner.Profile.Name != GlobalConstants.CBS_ADMIN && requestAccount.Owner.Profile.Name != GlobalConstants.SME_ADMIN){
                    if(ownerUser.CBS_User__c && requestAccount.OwnerId != CBSADMIN_SFID){
                        //Add For (CBS-Ongoing) CBS-CR005
                        if((requestAccount.Owner.RBS_User__c || requestAccount.Owner.SME_User__c) && requestAccount.Is_RBS__c && requestAccount.Port_Pool__c == null){
                            showErrorMessageOnPage(System.Label.Customer_must_be_in_Port_or_Pool);
                            return false;
                        }else if(requestAccount.Owner.CBS_User__c){
                            showErrorMessageOnPage(System.Label.Not_allow_to_request_ownership);
                            return false;
                        }else if(!requestAccount.Owner.SME_User__c && !requestAccount.Owner.CBS_User__c && !requestAccount.Owner.RBS_User__c){
                            showErrorMessageOnPage(System.Label.Customer_Owner_must_be_SME_CBS_or_RBS_segment_only);
                            return false;
                        }
                    }else if(ownerUser.SME_User__c){
                        if(requestAccount.Owner.CBS_User__c && requestAccount.Is_RBS__c){
                            showErrorMessageOnPage(System.Label.SME_cannot_request_RBS_Customer_from_CBS);
                            return false;
                        }else if(!requestAccount.Owner.SME_User__c && !requestAccount.Owner.CBS_User__c && !requestAccount.Owner.RBS_User__c){
                            showErrorMessageOnPage(System.Label.Customer_Owner_must_be_SME_CBS_or_RBS_segment_only);
                            return false;
                        }
                    }else if(ownerUser.RBS_User__c){
                        if(requestAccount.Owner.CBS_User__c && requestAccount.Is_RBS__c){
                            showErrorMessageOnPage(System.Label.RBS_cannot_request_RBS_Customer_from_CBS);
                            return false;
                        }else if(!requestAccount.Owner.SME_User__c && !requestAccount.Owner.CBS_User__c && !requestAccount.Owner.RBS_User__c){
                            showErrorMessageOnPage(System.Label.Customer_Owner_must_be_SME_CBS_or_RBS_segment_only);
                            return false;
                        }
                    }
                }

                if(currentRecord!=null && currentRecord.size() > 0){
                    showErrorMessageOnPage(ExceptionMessage.ALREADY_SUBMMITTED);
                    return false;
                } else {
                    //Customer_Ownership_Request__c ownerObj;
                    //ownerObj = Ownership_Service.createOwnerShip(requestAccount,ownerUser);

                    //if (ownerObj != null && ownerObj.Id != null) {
                    //    ownerShipId = ownerObj.Id;
                    //}
                } 
            } else {
                showErrorMessageOnPage('Request customerfgetRequestOwnerShipId or owner user is null!!');
                return false;
            }

            return true;
        } catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            return true;
        }
    }

    public PageReference requestOwnership(){
        return getFraudStatus();
    }

    // CR Fraud
    public PageReference getFraudStatus() {
        this.isShowFraud = true;
        this.isShowFraudColor = false;
        Account requestAccount = getAccountFromId(requestOwnershipValue);
        if(requestAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || requestAccount.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            return yesFraud();
        }
        try{
            calloutFraudWebservice(requestAccount);
            fraudMessage = Label.FRAUD_ALERT;
            colorCode = Account_Service.calculateFraud(requestAccount.Exit__c, fraudStatus);
            if(colorCode == GlobalConstants.FRAUD_COLOR_BLUE) {
                return yesFraud();
            } else {
                this.isShowFraudColor = (colorCode != 'Other');    
            }
        }catch(CIWebserviceException e){
            fraudMessage = GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage());
        }catch(Exception e){
            fraudMessage = e.getMessage();
        }
        return null;
    }

    public void calloutFraudWebservice(Account accountObj) {
        GetFraud_Webservice webserviceInstance = GetFraud_Webservice.getInstance();
        webserviceInstance.cisId = accountObj.CIS__c;
        GetFraud_Webservice.ResponseModel responseModel = webserviceInstance.calloutWebservice();
        handlerWebserviceResponse(responseModel);
    }

    public void handlerWebserviceResponse(GetFraud_Webservice.ResponseModel responseModel) {
        List<GetFraud_Webservice.CustomerFraud> respCustomers = responseModel.customerModel;
        if(respCustomers != null && respCustomers.size() > 0) {
            fraudStatus = respCustomers[0].BLIST_TP_CD;
        }
    }

    public PageReference yesFraud() {
        isShowFraud = false;
        PageReference redirectPage;
        // Do old request ownership
        Boolean isNotError = false;
        isNotError = getRequestOwnerShipId();
        
        if(isNotError && ownerShipId != null && ownerShipId.length() > 0) {
            redirectPage = new PageReference('/'+ownerShipId+'/e?retURL=%2F'+ownerShipId+'&saveURL=%2F'+ownerShipId);
            redirectPage.setRedirect(true);
        }
        
        return redirectPage;
    }

    public PageReference noFraud() {
        isShowFraud = false;
        return null;
    }

    public void requestOwnershipAsync(){
        getRequestOwnerShipId();
    }*/

    public void searchDataSyncronous(){
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'searchDataSyncronous';
        this.showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();
        ownerUser = getUserFromId(UserInfo.getUserId());
        try {
            if(queryProspectFromSFDC()){
               getCustomersFinal();
               return; 
            }    
            CustomerSearchRequestModel requestModel = getCustomerSearchRequestModel();
            // check if map is null or empty before calling ws
            clearOldResult();

            if(!requestModel.requestMap.isEmpty()){
                CustomerResponseModel responseModel;
                responseModel = getResponseFromWebservice(requestModel);   

                // query prospect and add to customer list
                if(responseModel != null){
                    if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                        showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
                    }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                        backendCustomerList = getCustomerListByCISList(responseModel.cisList);
                        customerList.addAll(backendCustomerList);
                    }else{
                        writeDebugMessage(functionName,'No data from backend');
                    }
                }
                getCustomersFinal();
                if(this.finalCustomerList == null || this.finalCustomerList.isEmpty()){
                    showErrorMessageOnPage(System.Label.Search_NoMatch);
                    if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(ownerUser.Segment__c) && ownerUser.Id !=CBSADMIN_SFID){
                        this.showProspectButton = false;
                    }else{
                        this.showProspectButton = true;
                    }
                }
            } else {
                showInfoMessageOnPage(System.Label.Search_MinField);
            }
            
        }catch(CIWebserviceException e){
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.DATABASE_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }
            if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(ownerUser.Segment__c) && ownerUser.Id !=CBSADMIN_SFID){
                this.showProspectButton = false;
            }else{
                this.showProspectButton = true;
            }
            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }
        

        // set default direction
        sortDirection = 'ASC';
    }

    public Object searchData(){
        System.debug('Debug -- searchData');
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'searchData';
        String requestStr = null;
        showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();

        if(queryProspectFromSFDC()){
           getCustomersFinal();
           return null; 
        }       
        CustomerSearchRequestModel requestModel = getCustomerSearchRequestModel();
        // check if map is null or empty before calling ws
        clearOldResult();

        Continuation con = new Continuation(120);
        String requestNumber;
        String endpoint = SME_CIRestWebservice.SEARCH_ENDPOINT;

        try {
            if(!requestModel.requestMap.isEmpty()){
                requestStr = SME_CIRestWebservice.getRequestStringFromMap(requestModel.requestMap);

                // Set callback method
                con.continuationMethod='handleResponseCustomerSearch';

                // Create callout request
                HttpRequest req = new HttpRequest();

                req.setHeader('Authorization', SME_HTTPCallUtil.getAuthorizationHeader());
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setbody(requestStr);

                // Add callout request to continuation
                this.requestLabel = con.addHttpRequest(req);
            } else {
                showInfoMessageOnPage(System.Label.Search_MinField);
            }
            
        }catch(CIWebserviceException e){
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.DATABASE_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else if(e.getMessage().containsIgnoreCase(URI_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }

        // set default direction
        this.sortDirection = 'ASC';

        // Return the continuation
        return con;
    }

    public Object handleResponseCustomerSearch() {
        System.debug('Debug -- handleResponseCustomerSearch');
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'handleResponseCustomerSearch';
        HttpResponse response;
        showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();
        
        try {
            CustomerResponseModel responseModel;

            if(this.requestLabel != null){
                HttpResponse continuationResponse = Continuation.getResponse(this.requestLabel);
                response = SME_CIRestWebservice.handleReturnException(continuationResponse);
                responseModel = SME_CIRestWebservice.getResponseModelFromSearchResultStr(response.getBody());
            }

            // query prospect and add to customer list
            if(responseModel != null){
                if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                    showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
                }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                    backendCustomerList = getCustomerListByCISList(responseModel.cisList);
                    customerList.addAll(backendCustomerList);
                }else{
                    writeDebugMessage(functionName,'No data from backend');
                }
            }
            getCustomersFinal();
            if(this.finalCustomerList == null || this.finalCustomerList.isEmpty()){
                showErrorMessageOnPage(System.Label.Search_NoMatch);
            }
        }catch(CIWebserviceException e){
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.DATABASE_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else if(e.getMessage().containsIgnoreCase(URI_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }

        // set default direction
        this.sortDirection = 'ASC';
        return null;
    }

    public void clearOldResult(){
        this.finalCustomerList  = new List<Customer>();
        this.displayedCisList = new List<String>();
        this.requestLabel = null;
        ApexPages.getMessages().clear();
        this.page = 1;
    }

    public Boolean queryProspectFromSFDC(){
        List<List<sObject>> soslResultSet = null;
        Boolean result = false;
         setCISId.clear();
         customerList.clear();          
            if(this.cis != null && this.cis.trim() != ''){
              soslResultSet = searchCISValue(this.cis);
              result = soslToAccount(soslResultSet);
            }
            if(result){
                return true;
            }

            soslResultSet = searchAllValue(this.id, this.cis, this.firstname, this.lastname);     
            soslToAccount(soslResultSet);
            
        return false;      
    }

    private Boolean soslToAccount(List<List<sObject>> soslResultSet){

        if(soslResultSet!= null && soslResultSet.size() != 0){
                List<Account> accountLists = ((List<Account>)soslResultSet[0]);

                if(accountLists!= null && accountLists.size() != 0){                       
                    for(Account tempAccount:customAccountSort(accountLists,'ASC')){      
                            showProspectButton = false;
                            customerList.add(new Customer(ownerUser, tempAccount,this.isEnglishInput_FN,this.isEnglishInput_LN));
                            setCISId.add(tempAccount.CIS__c);
                    }
                    return true;
                }              
            }
            return false;
    }

    private Boolean isCISOrIDfieldHasValue(){

        if((this.id != null && this.id.trim() != '') || this.cis != null && this.cis.trim() != ''){

            return true;
        }
        return false;
    }

    private List<Account> customAccountSort(List<Account> accountLists, string sortVal){

        List<String> orderingList = new List<String>();
        Map<String,Account> returnResultMapSorted = new Map<String,Account>();
        Map<String,Account> returnResultMap = new Map<String,Account>(); 
        for(Account val : accountLists){
                /* dont show BOL Account*/
                if(val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.INDIVIDUAL_BOL_DEVNAME) || val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.ORGANIZATION_BOL_DEVNAME)){
                    continue;
                }
                if(val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.INDUSTRIESHOUSEHOLD_DEVNAME)){
                    continue;
                }
                if(val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.PERSONACCOUNT_DEVNAME) || 
                    val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME)|| 
                    val.RecordTypeId == RecordTypeAccount.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME)){
                        if(!isCISOrIDfieldHasValue() && this.firstname != null && this.firstname.trim() != '' && val.FirstName != this.firstname.trim()){
                            continue;
                        }
                        if(!isCISOrIDfieldHasValue() && this.lastname != null && this.lastname.trim() != '' && val.LastName != this.lastname.trim()){
                            continue;
                        }                     
                }
                returnResultMap.put(val.Id,val);             
            }
         
        orderingList.addAll(returnResultMap.keyset());
        //Sort the List
        orderingList.sort();
        if(sortVal == 'ASC'){
           for(Integer i= 0;i < orderingList.size(); i++){
                returnResultMapSorted.put(orderingList[i],returnResultMap.get(orderingList[i]));
            }   
        }else{
            for(Integer i=orderingList.size()-1; i>=0;i--){
                    returnResultMapSorted.put(orderingList[i],returnResultMap.get(orderingList[i]));
                }
        }  
        
            return returnResultMapSorted.values();
    }

    public void sortData(){
        String functionName = 'sortData';
        try{
            showProspectButton = false;
            List<Customer> backendCustomerList = sortBackendData(this.sortDirection);
            List<Customer> prospectCustomerList = sortProspectData(this.sortDirection);
            this.customerList.clear();
            this.customerList.addAll(backendCustomerList);
            this.customerList.addAll(prospectCustomerList);
            this.page = 1;
            this.getCustomersFinal();
        }catch(CIWebserviceException e){
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.DATABASE_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SORT_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        }catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SORT_FAILED);
        }
    }


    public List<Customer> sortBackendData(String direction){
        List<Customer> backendCustomerList = new List<Customer>();
        String functionName = 'sortBackendData';
        showProspectButton = false;
        // if no displayed list , do nothing
        if(this.displayedCisList != null && !this.displayedCisList.isEmpty()){
            CustomerSearchRequestModel requestModel = getCustomerRequestForSorting();
            // the result must not be null before sorting
            CustomerResponseModel responseModel = getResponseFromWebservice(requestModel);
            writeDebugMessage(functionName,'responseSortCISList:='+responseModel.cisList);
            
            if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
            }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                backendCustomerList = getCustomerListByCISList(responseModel.cisList);
            }else{
                writeDebugMessage(functionName,'No data from backend');
            }
        }
        return backendCustomerList;
    }

    public List<Customer> sortProspectData(String direction){
        List<Customer> prospectCustomerList = new List<Customer>();
        List<List<sObject>> soslResultSet = null;
            soslResultSet = sortAllValue(this.id, this.cis, this.firstname, this.lastname,direction);
            if(soslResultSet!= null && soslResultSet.size() != 0){
                Account[] accountLists = ((List<Account>)soslResultSet[0]);
                for(Account tempAccount:customAccountSort(accountLists,direction)){
                        showProspectButton = false;
                        prospectCustomerList.add(new Customer(ownerUser, tempAccount,this.isEnglishInput_FN,this.isEnglishInput_LN));
                }
            }

        return prospectCustomerList;         
    }

    public CustomerResponseModel getResponseFromWebservice(CustomerSearchRequestModel requestModel){
        CustomerResponseModel responseModel;
        String functionName = 'getResponseFromWebservice';

        if(requestModel.requestMap.containsKey(SORT_TYPE)){
            responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(requestModel);
        } else {
            responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(requestModel);
        }
        return responseModel;
    }

    public CustomerSearchRequestModel getCustomerSearchRequestModel(){       
        Map<String,String> requestCISMap = new Map<String,String>();
        CustomerSearchRequestModel reqModel = new CustomerSearchRequestModel();
        Boolean checkLastNameResult = True;
        Boolean checkFirstNameResult = True;
        Boolean hasFirstName = False;
        Boolean hasLastName = False;
        clearProspectParam();

        if(this.cis != null && this.cis.trim() != ''){
            this.cis = this.cis.trim();
            if(isValidParam(this.cis)){
                requestCISMap.put(CIS_ID, this.cis);
                this.prospect_id = this.cis;
            }
        } else if(this.id != null && this.id.trim() != ''){
            this.id = this.id.trim();
            if(isValidParam(this.id)){
                requestCISMap.put(IDENT_NO, this.id);
                this.prospect_id = this.id;
            }
        // check if it TH or EN
        } else if (this.firstname != null && this.firstname.trim() != '' || this.lastname != null && this.lastname.trim() != ''){
            if (this.firstname != null && this.firstname.trim() != ''){
                this.firstname = this.firstname.trim();
                this.prospect_firstname = this.firstname;
                if(isEnglishAlphabet(this.firstname)){
                    requestCISMap.put(FIRSTNAME_EN,this.firstname);
                    this.isEnglishInput_FN = true;
                }else{
                    requestCISMap.put(FIRSTNAME_TH,this.firstname);
                    this.isEnglishInput_FN = false;
                }
                hasFirstName = True;
            } 

            if (this.lastname != null && this.lastname.trim() != ''){
                this.lastname = this.lastname.trim();
                this.prospect_lastname = this.lastname;
                if(isEnglishAlphabet(this.lastname)){
                    requestCISMap.put(SURNAME_EN,this.lastname);
                    this.isEnglishInput_LN = true;
                }else{
                    requestCISMap.put(SURNAME_TH,this.lastname);
                    this.isEnglishInput_LN = false;
                }
                hasLastName = True;
            }

            if(hasFirstName == True && hasLastName == False){
                if(!isValidParam(this.firstname)){
                    reqModel = new CustomerSearchRequestModel();
                    requestCISMap.clear();
                    clearProspectParam();
                }
            } else if (hasFirstName == False && hasLastName == True){
                if(!isValidParam(this.lastname)){
                    reqModel = new CustomerSearchRequestModel();
                    requestCISMap.clear();
                    clearProspectParam();
                }
            }

        }

        reqModel.requestMap = requestCISMap;
        return reqModel;
    }

    public void clearProspectParam(){
        this.prospect_id = '';
        this.prospect_cis = '';
        this.prospect_lastname = '';
        this.prospect_firstname = '';

    }

    public Boolean isValidParam(String param){
        Boolean result = false;
        if(param != ''){
            // check length
            if (param.length()==1){
                showInfoMessageOnPage(System.Label.Search_MinChar);
            }else{
                result = true;
            }
        }
        return result;
    }

    public CustomerSearchRequestModel getCustomerRequestForSorting(){       
        Map<String,String> requestCISMap = new Map<String,String>();
        CustomerSearchRequestModel reqModel = new CustomerSearchRequestModel();

        // check if it TH or EN
        if(this.firstname != null && this.firstname.trim() != ''){
            if(isEnglishAlphabet(this.firstname.trim())){
                requestCISMap.put(SORT_COLUMN,FIRSTNAME_EN);
            }else{
                requestCISMap.put(SORT_COLUMN,FIRSTNAME_TH);
            }
        }else{
            requestCISMap.put(SORT_COLUMN,FIRSTNAME_TH);
        }

        requestCISMap.put(SORT_TYPE,this.sortDirection);
        requestCISMap.put(CIS_ID,convertListToCommaString(displayedCisList));
        reqModel.requestMap = requestCISMap;
        return reqModel;
    }

    public String convertListToCommaString(List<String> idList){
        String outputString = String.join(idList, ',');
        return outputString;
    }

    public Boolean isEnglishAlphabet(String name){
        Boolean isEnglishAlphabet = false;
        String nameRegEx = '[a-zA-Z0-9\\-]+';
        Pattern myPattern = Pattern.compile(nameRegEx);
        Matcher myMatcher = myPattern.matcher(name);
        myMatcher.region(0, myMatcher.regionEnd());
        isEnglishAlphabet = MyMatcher.matches();
        return isEnglishAlphabet;
    }

    public List<Customer> getCustomerListByCISList(List<String> cisIdList){
        List<Customer> backendCustomerList = new List<Customer>();
        String functionName = 'setCustomerListByCISList';
        // Query when match CIS with backend
        // Natthanan add Primary_Segment_Desc__c field for show Segment Information   
        Map<String,sObject> accountMap = GlobalUtility.toMap('CIS__c', [SELECT Id,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,
                                    Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,Document_Type__c,
                                    Birthdate_Registration_Date__c,Port_Pool__c,
                                    Encrypt_Identification_No__c, Identification_No_Mask__c,Document_Type_Prospect__c,Is_SME_Customer__c,Is_CBS_Customer__c,Owner.Profile.Name
                                    FROM Account WHERE CIS__c IN :cisIdList AND isActive__c = true]);
        
        Map<String,sObject> mapAddress = queryMapAddress(cisIdList);

        for (String cis:cisIdList){
            try {
                if (accountMap.get(cis) != null){
                    Account acc = (Account)accountMap.get(cis);
                    if (acc != null){
                        showProspectButton = false;
                        if(!setCISId.contains(acc.CIS__c)){

                            backendCustomerList.add(new Customer(ownerUser, acc,mapAddress,this.isEnglishInput_FN,this.isEnglishInput_LN));   
                        }                 
                    }
                } else {
                    showProspectButton = true;
                    backendCustomerList.add(new Customer(cis,this.isEnglishInput_FN,this.isEnglishInput_LN));   
                }

            }catch(Exception ex){
                writeExceptionMessage(functionName,ex.getMessage(),ex);
            }
        }
        writeDebugMessage(functionName,'backend customerList size:'+backendCustomerList.size());
        displayedCisList = cisIdList;
        return backendCustomerList;
    }

    public Boolean getHasError(){
        return hasError;
    }

    public Boolean getHasInfo(){
        return hasInfo;
    }
    
    public void showInfoMessageOnPage(String errorMsg){
        if (!ApexPages.hasMessages(ApexPages.Severity.ERROR) && !ApexPages.hasMessages(ApexPages.Severity.INFO)){
            apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,errorMsg));
            errorMessage = errorMsg;
            hasInfo = true;
        }       
    }

    public void showErrorMessageOnPage(String errorMsg){
        if (errorMsg != null && !ApexPages.hasMessages(ApexPages.Severity.ERROR) && !ApexPages.hasMessages(ApexPages.Severity.INFO)){
            apexpages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMsg));
            errorMessage = errorMsg;
            hasError = true;
        }
    }

    public static void writeDebugMessage(String sourceFunction,String logMessage){
        String sourceClass = 'CustomerSearch_Controller';
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;

        Exception ex = null;
        Long timeTaken = null;
        String severity = 'DEBUG';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }

    public static void writeExceptionMessage(String sourceFunction,String logMessage,Exception ex){
        String sourceClass = 'CustomerSearch_Controller';
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;

        Long timeTaken = null;
        String severity = 'ERROR';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }
}