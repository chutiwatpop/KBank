public without sharing class ConvertLeadController {
    public class ResponseModel{
        @AuraEnabled
        public Lead lead {get;set;}
        @AuraEnabled
        public Opportunity job {get;set;}
    }

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
        if(existingAccount != null) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static ResponseModel getLead(Id leadId) {
        ResponseModel responseModel = new ResponseModel();
        Lead lead = [SELECT Id,Job__r.Id,Job__r.Name,RecordType.DeveloperName,Title, CIS_ID__c, Salutation, FirstName, LastName, Company, Document_Type__c, Identification_No__c, Birthdate_Registration_Date__c, Customer__c, Customer__r.Name, Status, OwnerId FROM Lead WHERE Id = :leadId];
        Opportunity job = new Opportunity();
        if(lead.Job__c != null){
            job.Id = lead.Job__r.Id;
            job.Name = lead.Job__r.Name;
        }
        responseModel.lead = lead;
        responseModel.job = job;
        return responseModel;
    }
    
    @AuraEnabled
    public static Id convert(Lead lead, Boolean isPersonAccount, Boolean createNewJob, String jobId) {
        Id resultId;
        String resultJobId = jobId;
        String customerType;
        String convertErrorText = '';
        Account existingAccount = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(lead.CIS_ID__c, lead.Identification_No__c, lead.Birthdate_Registration_Date__c);
        Account_Service.resetAllFlagOwnership();
        lead.Job__c = resultJobId;
        Savepoint sp = Database.setSavepoint();
        try{
            update lead;
        } catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            convertErrorText = e.getMessage();
            Database.rollback(sp);
            throw new AuraHandledException(convertErrorText);
        }

        if(existingAccount == null) {
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
            
            try {
                Account resultAccount = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(target.CIS__c, target.Encrypt_Identification_No__c, target.Birthdate_Registration_Date__c);
                Account_Service.isConvertLead = true;
                if(resultAccount == null) {
                    resultAccount = Prospect_Service.getTemporaryAndCloneProspectField(target, customerType);
                    User_Extension__c currentUserEx = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
                    if(currentUserEx != null && GlobalConstants.PROFILE_AF_SET.contains(currentUserEx.User__r.Profile.Name)){
                        resultAccount.AF_Temporary_Customer__c = currentUserEx.Id;
                    }
                    update resultAccount;
                }
                TriggerHandler.bypass('AccountTriggerHandler');
                Database.LeadConvertResult convertResult = convertLead(lead.Id, resultAccount.Id, createNewJob);
                TriggerHandler.clearbypass('AccountTriggerHandler');
                if(convertResult.isSuccess()) {
                    resultId = convertResult.getAccountId();
                    if(createNewJob) {
                        updateJob(convertResult.getAccountId(), convertResult.getOpportunityId(), convertResult.getLeadID());
                        resultId = convertResult.getOpportunityId();
                        resultJobId = convertResult.getOpportunityId();
                    }
                    updateLeadRelateToJob(lead.Id,convertResult.getAccountId(),resultJobId);

                    if(lead.RecordType.DeveloperName == GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME || lead.RecordType.DeveloperName == GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME){
                        List<Event> listRelatedEvent = [SELECT Id,WhoId,WhatId FROM Event WHERE AccountId = :convertResult.getAccountId() AND RecordType.DeveloperName = :GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME];
                        for(Event eachEvent : listRelatedEvent){
                            eachEvent.WhatId = null;
                            eachEvent.WhoId = lead.Id;
                        }
                        TriggerHandler.bypass('EventTriggerHandler');
                        update listRelatedEvent;
                        TriggerHandler.clearbypass('EventTriggerHandler');
                    }
                } else {
                    convertErrorText = convertResult.getErrors()[0].getMessage();
                }
            } catch(System.DmlException e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                convertErrorText = e.getDmlMessage(0) + getErrorFieldName(e);
            } catch(System.QueryException e) {
                System.debug(e.getMessage());
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
            Id accountTeamId = autoCreateNewAccountTeam(existingAccount.Id,UserInfo.getUserId());    
            Account_Service.isConvertLead = true;
            try {
                TriggerHandler.bypass('AccountTriggerHandler');
                Database.LeadConvertResult convertResult = convertLead(lead.Id, existingAccount.Id, createNewJob);
                TriggerHandler.clearbypass('AccountTriggerHandler');
                if(convertResult.isSuccess()) {
                    resultId = convertResult.getAccountId();
                    if(createNewJob) {
                        updateJob(convertResult.getAccountId(), convertResult.getOpportunityId(), convertResult.getLeadID());
                        resultId = convertResult.getOpportunityId();
                        resultJobId = convertResult.getOpportunityId();
                    }
                    updateLeadRelateToJob(lead.Id,convertResult.getAccountId(),resultJobId);

                    if(lead.RecordType.DeveloperName == GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME || lead.RecordType.DeveloperName == GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME){
                        List<Event> listRelatedEvent = [SELECT Id,WhoId,WhatId FROM Event WHERE AccountId = :convertResult.getAccountId() AND RecordType.DeveloperName = :GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME];
                        for(Event eachEvent : listRelatedEvent){
                            eachEvent.WhatId = null;
                            eachEvent.WhoId = lead.Id;
                        }
                        TriggerHandler.bypass('EventTriggerHandler');
                        update listRelatedEvent;
                        TriggerHandler.clearbypass('EventTriggerHandler');
                    }
                } else {
                    convertErrorText = convertResult.getErrors()[0].getMessage();
                }
            } catch(System.DmlException e) {
                System.debug(e.getStackTraceString());
                if(e.getMessage().contains('insufficient access rights')) {
                    convertErrorText = Label.Unable_to_merge_Referral_to_this_Customer;
                } else {
                    convertErrorText = e.getDmlMessage(0) + getErrorFieldName(e);
                }
            } catch(Exception e) {
                System.debug(e.getStackTraceString());
                convertErrorText = e.getMessage();
            } finally {
                if(accountTeamId != null){
                    autoDeleteNewAccountTeam(accountTeamId);
                }
            }
            if(convertErrorText != '') {
                Database.rollback(sp);
                System.debug('error:'+convertErrorText);
                throw new AuraHandledException(convertErrorText);
            }
        }
        return resultId;
    }

    private static Id autoCreateNewAccountTeam(Id accountId, Id userId){
        return Account_Service.createNewAccountTeam(accountId, userId, 'Edit', 'None', 'None', 'Read');
    }

    private static void autoDeleteNewAccountTeam(Id accountTeamId){
        Database.delete(accountTeamId);
    }

    private static Database.LeadConvertResult convertLead(Id leadId, Id accountId, Boolean createOpp) {
        Account accountInfo = [SELECT RecordType.DeveloperName,(SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE Id =:accountId];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setAccountId(accountId);
        lc.setConvertedStatus(Label.Referral_Converted_Status);
        lc.setDoNotCreateOpportunity(!createOpp);
        if(accountInfo.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || accountInfo.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME){
            if(accountInfo.Contacts.size()>0) lc.setContactId(accountInfo.Contacts[0].Id);
        }
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        return lcr;
    }

    private static void updateJob(Id accountId, Id jobId, Id leadId) {
        Account customer = [SELECT Id, Name FROM Account WHERE Id=:accountId];
        Opportunity job =  [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE Id=:jobId];
        Datetime now = Datetime.now();
        String dateString = '';
        if(now.year() < 2500) {
            dateString = String.valueOf(Datetime.now().year() + 543);
        } else {
            dateString = String.valueOf(Datetime.now().year());
        }
        dateString += now.format('/MM/dd');

        job.Name = dateString + '_' + customer.Name;
        job.StageName = 'Open';
        Date today = Date.today();
        job.CloseDate = today.addDays(Integer.valueOf(Label.Default_Job_CloseDate));
        job.Referral__c = leadId;

        OpportunityProductField__c opportunityProductField = OpportunityProductField__c.getOrgDefaults();
        if(opportunityProductField != null && opportunityProductField.Pricebook2Id__c != null) {
            job.Pricebook2Id = opportunityProductField.Pricebook2Id__c;
        }
        update job;
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

    private static void updateLeadRelateToJob(Id leadId, Id accountId, Id oppId){
        TriggerHandler.bypass('LeadTriggerHandler');
        Account_Service.isConvertLead = true;
        Lead lead = new Lead();
        lead.Id = leadId;
        lead.RecordTypeId = GlobalUtility.getRecordTypeId('Lead',GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL_CONVERTED);
        lead.Account__c = accountId;
        lead.Customer__c = accountId;
        lead.Job__c = oppId;
        update lead;
        TriggerHandler.clearbypass('LeadTriggerHandler');
    }
}