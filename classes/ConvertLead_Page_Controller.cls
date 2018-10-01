public without sharing class ConvertLead_Page_Controller {
    @AuraEnabled
    public static Id getCurrentUsedrId() {
        return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static List<String> getCustomerType() {
        List<String> options = new List<String>();
        options.add(GlobalConstants.INDIVIDUAL + ',Individual');
        options.add(GlobalConstants.ORGANIZATION + ',Business');
        return options;
    }
    
    @AuraEnabled
    public static List<String> getDocumentType() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry eachVal: picklistVal) {
            options.add(eachVal.getLabel() + ',' + eachVal.getValue());
        }
        return options;
    }

    @AuraEnabled
    public static List<String> getSalutation() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry eachVal: picklistVal) {
            options.add(eachVal.getLabel() + ',' + eachVal.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getFieldLabel() {
        List<String> fieldLabel = new List<String>();
        fieldLabel.add(Schema.SObjectType.Lead.fields.CIS_ID__c.Name + '|,|' + Schema.SObjectType.Lead.fields.CIS_ID__c.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Salutation.Name + '|,|' + Schema.SObjectType.Lead.fields.Salutation.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.FirstName.Name + '|,|' + Schema.SObjectType.Lead.fields.FirstName.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.LastName.Name + '|,|' + Schema.SObjectType.Lead.fields.LastName.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Title.Name + '|,|' + Schema.SObjectType.Lead.fields.Title.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Company.Name + '|,|' + Schema.SObjectType.Lead.fields.Company.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Document_Type__c.Name + '|,|' + Schema.SObjectType.Lead.fields.Document_Type__c.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Identification_No__c.Name + '|,|' + Schema.SObjectType.Lead.fields.Identification_No__c.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Birthdate_Registration_Date__c.Name + '|,|' + Schema.SObjectType.Lead.fields.Birthdate_Registration_Date__c.Label);
        fieldLabel.add(Schema.SObjectType.Lead.fields.Customer__c.Name + '|,|' + Schema.SObjectType.Lead.fields.Customer__c.Label);
        return fieldLabel;
    }
    
    @AuraEnabled
    public static Boolean haveExistingCustomer(Lead lead) {
        Account existingAccount = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(lead.CIS_ID__c, lead.Identification_No__c, lead.Birthdate_Registration_Date__c);
        if(existingAccount != null) { return true; }
        return false;
    }
    
    @AuraEnabled
    public static Lead getLead(Id leadId) {
        return [SELECT Id,Title, CIS_ID__c, Salutation, FirstName, LastName, Company, Document_Type__c, Identification_No__c, Birthdate_Registration_Date__c, Customer__c, Customer__r.Name, Status, OwnerId FROM Lead WHERE Id = :leadId];
    }
    
    @AuraEnabled
    public static Id convert(Lead lead, Boolean isNewCustomer, Boolean isPersonAccount) {
        Id resultId;
        String customerType;
        String convertErrorText = '';
        
        if(isNewCustomer) {
            Account target = new Account();
            if(isPersonAccount) {
                customerType = GlobalConstants.INDIVIDUAL;
                target.Salutation = lead.Salutation;
                target.FirstName = lead.FirstName;
                target.LastName = lead.LastName;
            } else {
                customerType = GlobalConstants.ORGANIZATION;
                target.Title__c = lead.Title;
                target.Name = lead.Company;
            }
            target.CIS__c = lead.CIS_ID__c;
            target.Document_Type_Prospect__c = lead.Document_Type__c;
            target.Encrypt_Identification_No__c = lead.Identification_No__c;
            target.Birthdate_Registration_Date__c = lead.Birthdate_Registration_Date__c;
            
            Savepoint sp = Database.setSavepoint();
            try {
                update lead;
                Account resultAccount = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(target.CIS__c, target.Encrypt_Identification_No__c, target.Birthdate_Registration_Date__c);
                if(resultAccount == null) {
                    //resultAccount = Prospect_Service.startConvertProspect(target, customerType);
                    resultAccount = Prospect_Service.getTemporaryAndCloneProspectField(target, customerType);
                    update resultAccount;
                }
                
                Database.LeadConvertResult convertResult = convertLead(lead.Id, resultAccount.Id);
                if(convertResult.isSuccess()) {
                    resultId = convertResult.getAccountId();
                } else {
                    convertErrorText = convertResult.getErrors()[0].getMessage();
                }
            } catch(System.DmlException e) {
                convertErrorText = e.getDmlMessage(0) + getErrorFieldName(e);
            } catch(System.QueryException e) {
                if(e.getMessage().contains('List has no rows')) {
                    convertErrorText = Label.Temporary_Customer_Empty;
                } else {
                    convertErrorText = e.getMessage();
                }
            } catch(Exception e) {
                convertErrorText = e.getMessage();
            }
            if(convertErrorText != '') {
                Database.rollback(sp);
                throw new AuraHandledException(convertErrorText);
            }
        } else {
            Savepoint sp = Database.setSavepoint();
            try {
                Database.LeadConvertResult convertResult = convertLead(lead.Id, lead.Customer__c);
                if(convertResult.isSuccess()) {
                    resultId = convertResult.getAccountId();
                } else {
                    convertErrorText = convertResult.getErrors()[0].getMessage();
                }
            } catch(System.DmlException e) {
                if(e.getMessage().contains('insufficient access rights')) {
                    convertErrorText = Label.Unable_to_merge_Referral_to_this_Customer;
                } else {
                    convertErrorText = e.getDmlMessage(0) + getErrorFieldName(e);
                }
            } catch(Exception e) {
                convertErrorText = e.getMessage();
            }
            if(convertErrorText != '') {
                Database.rollback(sp);
                throw new AuraHandledException(convertErrorText);
            }
        }
        
        return resultId;
    }

    private static Database.LeadConvertResult convertLead(Id leadId, Id accountId) {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setAccountId(accountId);
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel=:Label.Referral_Converted_Status];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus(Label.Referral_Converted_Status);
        lc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        return lcr;
    }
    
    private static String getErrorFieldName(System.DmlException e) {
        String fieldName = '';
        if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
            try {
                for(Schema.sObjectField fields : e.getDmlFields(0)) {
                    if(fieldName != '') {
                        fieldName += ', ';
                    } else {
                        fieldName = ': (';
                    }
                    fieldName += fields.getDescribe().getLabel();
                }
                fieldName += ')';
            } catch(Exception ex) {
                fieldName += '';
            }
        }
        return fieldName;
    }
}