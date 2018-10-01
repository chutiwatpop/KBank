public without sharing class Account_OverrideNew_Controller {
    private List<CreateProspect_Webservice.CustomerAddress> responseAddressList;
    private Account newAccount {get; set;}
    public Integer columnWidth {get;set;}
    public String recordTypeDevName {get;set;}
    public String customerType {get;set;}
    public String inputFirstName {get;set;}
    public String inputLastName {get;set;}
    public String inputSalutation {get;set;}
    public String reference {get;set;}
    public String referenceJSONString {get {return  JSON.serialize(reference);} }

    public Boolean isSF1() {
        String UItheme = UserInfo.getUiThemeDisplayed();
        if (UItheme == 'Theme4t') {
            return true;
        }else{
            return false;
        }
    }
    
    public Account_OverrideNew_Controller(ApexPages.StandardController stdController) {
        this.newAccount = (Account) stdController.getRecord();
        this.newAccount.OwnerId = UserInfo.getUserId();
        customerType = GlobalConstants.INDIVIDUAL;
        if(isSF1()) {
            columnWidth = 1;
        } else {
            columnWidth = 2;
        }

        /* 20180626 - Add customer detail to converted page */
        if(null != newAccount){
            if(null != newAccount.RecordTypeId){
                Account acc = [SELECT Id,Convertedrecord__c,RecordType.DeveloperName FROM Account WHERE Id = :newAccount.Id];
                if(null != acc.Convertedrecord__c){
                    this.reference = acc.Convertedrecord__c;  
                }
                this.recordTypeDevName = acc.RecordType.DeveloperName;                
                if(recordTypeDevName == GlobalConstants.ORGANIZATION_BOL_DEVNAME){
                    this.customerType = GlobalConstants.ORGANIZATION;
                }else if(recordTypeDevName == GlobalConstants.INDIVIDUAL_BOL_DEVNAME){
                    this.inputFirstName = newAccount.FirstName;
                    this.inputLastName = newAccount.LastName;
                    this.inputSalutation = newAccount.Salutation;
                    this.customerType = GlobalConstants.INDIVIDUAL;
                }

            }
        }

    }

    public List<SelectOption> getCustomerTypeItems() {
        List<SelectOption> customerTypeList = new List<SelectOption>();
        customerTypeList.add(new SelectOption(GlobalConstants.INDIVIDUAL, GlobalConstants.INDIVIDUAL));
        customerTypeList.add(new SelectOption(GlobalConstants.ORGANIZATION, GlobalConstants.ORGANIZATION));

        return customerTypeList;
    }

    public List<SelectOption> getSalutations() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachVal : picklistVal) {
            options.add(new SelectOption(eachVal.getLabel(), eachVal.getValue()));
        }       
        return options;
    }

    public PageReference save() {
        PageReference pageRef;
        this.newAccount.FirstName = inputFirstName;
        this.newAccount.LastName = inputLastName;
        this.newAccount.Salutation = inputSalutation;    
        
        if(GlobalUtility.isNumberAlphabet(this.newAccount.LastName)) {
            this.newAccount.CIS__c = this.newAccount.LastName;
        } else if(GlobalUtility.isNumberAlphabet(this.newAccount.Name)) {
            this.newAccount.CIS__c = this.newAccount.Name;
        } else {
            this.newAccount.CIS__c = null;
        }

        Account existingAccount = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(this.newAccount.CIS__c, this.newAccount.Encrypt_Identification_No__c, this.newAccount.Birthdate_Registration_Date__c);
        if(existingAccount != null) {
            pageRef = new PageReference('/' + existingAccount.Id);
            return pageRef;
        }

        try {
            Account responseAccount = Prospect_Service.startConvertProspect(this.newAccount, customerType);
            /* update reference after converted for BOL account */
            if(recordTypeDevName == GlobalConstants.ORGANIZATION_BOL_DEVNAME || recordTypeDevName == GlobalConstants.INDIVIDUAL_BOL_DEVNAME){
                Account oldAccount = new Account(Id = newAccount.Id,Convertedrecord__c = responseAccount.Id);
                update oldAccount;
            }
            pageRef = new PageReference('/' + responseAccount.Id);
        } catch(CIWebserviceException e){
            showError(GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage()));
        } catch (System.QueryException e) {
            if(e.getMessage().contains('List has no rows')) {
                showError(Label.Temporary_Customer_Empty);
            } else {
                showError(e.getMessage());
            }
        } catch (DmlException dmlEx) {
            showError(dmlEx.getDmlMessage(0));
        } catch(Exception e){
            showError(e.getMessage());
        }
        
        return pageRef;
    }

    public void showError(String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public PageReference gotoReference(){
        PageReference pageRef;
        try{
            pageRef = new PageReference('/' + reference);
        } catch(Exception e){
            showError(e.getMessage());
        }
        return pageRef;
    }
    
}