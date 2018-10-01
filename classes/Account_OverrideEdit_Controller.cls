/**
* @05/06/2017 Re-factor CIWebserviceException
*/
public without sharing class Account_OverrideEdit_Controller {

    private ApexPages.StandardController stdController;
    private Boolean isShowConvert;
    private String oldAccountName;
    private String oldIdent;
    private Date oldBirthDate;
    private String PROSPECT_REC_ID;

    public Boolean isSF1() {
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
            ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
            (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone'))){
            return true;
        }else{
            return false;
        }
    }
    public Account editAccount {get; set;}
    public Integer columnWidth {get;set;}

    public Account_OverrideEdit_Controller(ApexPages.StandardController stdController) {
        this.isShowConvert = false;
        this.stdController = stdController;
        this.editAccount = (Account) stdController.getRecord();
        PROSPECT_REC_ID = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT);

        if(this.editAccount.RecordTypeId == PROSPECT_REC_ID) {
            this.oldAccountName = this.editAccount.Name;
            this.oldBirthDate = this.editAccount.Birthdate_Registration_Date__c;
            this.oldIdent = this.editAccount.Identification_No_Prospect__c;
        }

        if(isSF1()){
            columnWidth = 1;
        } else {
            columnWidth = 2;
        }
    }

    public PageReference redirectPage() {
        if(this.editAccount.RecordTypeId == PROSPECT_REC_ID) {
            return null;
        }
        PageReference pageRef = new PageReference('/' + this.editAccount.Id + '/e');
        pageRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        pageRef.getParameters().put('nooverride', '1');
        return pageRef;
    }

    public PageReference save(){
        String functionName = 'saveProspect';
        // Check is update CIS or Ident + BirthDate
        if(this.editAccount.Name != this.oldAccountName || this.editAccount.Birthdate_Registration_Date__c != this.oldBirthDate || this.editAccount.Identification_No_Prospect__c != this.oldIdent){
            // Check Existing in SFDC
            try{
                checkExistingAccount(this.editAccount.Name, this.editAccount);
            }catch (Exception e){
                showError(e.getMessage());
                return null;
            }

            if(GlobalUtility.isNumberAlphabet(this.editAccount.Name) || (this.editAccount.Birthdate_Registration_Date__c != null && this.editAccount.Identification_No_Prospect__c != null)){
                try{
                    callWebservice(this.editAccount);
                }catch(CIWebserviceException e){
                    showError(GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage()));
                    GlobalUtility.logMessage(GlobalConstants.ERROR_LOG,'Account_OverrideEdit_Controller',functionName,null,null,e.getMessage(),null,e,null);
                    return null;
                }catch(Exception e){
                    GlobalUtility.logMessage(GlobalConstants.ERROR_LOG,'Account_OverrideEdit_Controller',functionName,null,null,e.getMessage(),null,e,null);
                    showError(e.getMessage());
                    return null;
                }
            }
        }

        PageReference pageRef = this.stdController.save();
        if(this.isShowConvert) {
            pageRef = new PageReference('/apex/NewAccount_Warning_Page');
            pageRef.getParameters().put('existingId', ApexPages.currentPage().getParameters().get('id'));
            pageRef.getParameters().put('warningMessage', Label.Prospect_Warning_Update_Prospect);
            return pageRef;
        }
        return pageRef;
    }

    public void checkExistingAccount(String cisId, Account checkAccount){
        List<Account> queryAccount = new List<Account>();
        if(GlobalUtility.isNumberAlphabet(cisId) && cisId != this.oldAccountName){
            queryAccount = [SELECT Id, Name FROM Account WHERE Name = :cisId OR CIS__c = :cisId LIMIT 1];
            if(queryAccount.size() > 0) {
                throw new CIWebserviceException(Label.Prospect_Warning_Duplicate_Prospect);
            }
        }
        if(checkAccount != null && (checkAccount.Birthdate_Registration_Date__c != this.oldBirthDate || checkAccount.Identification_No_Prospect__c != this.oldIdent) && checkAccount.Birthdate_Registration_Date__c != null && checkAccount.Identification_No_Prospect__c != null) {
            queryAccount = [SELECT Id, Name FROM Account WHERE Birthdate_Registration_Date__c = :checkAccount.Birthdate_Registration_Date__c AND Identification_No_Prospect__c = :checkAccount.Identification_No_Prospect__c LIMIT 1];
            if(queryAccount.size() > 0) {
                throw new CIWebserviceException(Label.Prospect_Warning_Duplicate_Prospect);
            }
        }
    }

    public void callWebservice(Account beforeSaveAccount) {
        CreateProspect_Webservice webServiceInstance = CreateProspect_Webservice.getInstance();
        if(GlobalUtility.isNumberAlphabet(beforeSaveAccount.Name)) {
            webServiceInstance.cisId = beforeSaveAccount.Name;
        }
        if(beforeSaveAccount.Birthdate_Registration_Date__c != null){
            webServiceInstance.birthDate = SME_JSONGenerator.toValue(beforeSaveAccount.Birthdate_Registration_Date__c);
        }
        if(beforeSaveAccount.Identification_No_Prospect__c != null){
            webServiceInstance.identNo = beforeSaveAccount.Identification_No_Prospect__c;
        }
        CreateProspect_Webservice.ResponseModel responseModel = webServiceInstance.calloutWebservice();

        handlerWebserviceResponse(beforeSaveAccount, responseModel);
    }

    public void handlerWebserviceResponse(Account beforeSaveAccount, CreateProspect_Webservice.ResponseModel responseModel) {
        if(responseModel.error != null && responseModel.error.message != null) {
            throw new CIWebserviceException(responseModel.error.message);
        }
        CreateProspect_Webservice.CustomerInfo respCustomerInfo = responseModel.customerModel;
        //Convert Response CustomerInfo to Customer
        if(respCustomerInfo != null && respCustomerInfo.IP_ID != null) {
            checkExistingAccount(respCustomerInfo.IP_ID, null);
            this.isShowConvert = true;
        }
    }

    public void showError(String errorMsg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
    }
}