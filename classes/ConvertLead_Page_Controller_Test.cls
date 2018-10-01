@isTest 
private class ConvertLead_Page_Controller_Test {
    public static String accountNameRM = 'rmCreatedAccountName';
    
    @testSetup static void setupAccount(){
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
            
            List<Account> listCust = new List<Account>();
            Account temp = new Account();
            temp.LastName = 'temp';
            temp.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
            temp.Temporary_Customer__c = true;
            listCust.add(temp);
            
            temp = new Account();
            temp.Name = 'temp';
            temp.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
            temp.Temporary_Customer__c = true;
            listCust.add(temp);
            
            temp = new Account();
            temp.Name = 'temp';
            temp.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
            temp.Temporary_Customer__c = true;
            listCust.add(temp);
            
            insert listCust;
        }
	}
    
    @isTest static void convertNewProspectAndNoTemp() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Assigned';
        insert lead;
        
        Id prospectId = ConvertLead_Page_Controller.convert(lead, true, true);
        System.assertNotEquals(null, prospectId);
        
        Lead lead2 = new Lead();
        lead2.FirstName = 'Test';
        lead2.LastName = 'Test';
        lead2.Company = 'Test Test';
        lead2.Status = 'Assigned';
        insert lead2;
        try {
            prospectId = ConvertLead_Page_Controller.convert(lead2, true, true);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
    }
    
    @isTest static void convertNewProspectOrganization() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Assigned';
        insert lead;
        
        lead.Document_Type__c = 'บัตรประชาชน';
        lead.Identification_No__c = '111111111111111';
        
        Id prospectId;
        try {
            prospectId = ConvertLead_Page_Controller.convert(lead, true, false);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
        
        lead.Document_Type__c = 'บัตรประชาชน';
        lead.Identification_No__c = '1111111111111';
        
        prospectId = ConvertLead_Page_Controller.convert(lead, true, false);
        System.assertNotEquals(null, prospectId);
        
        try {
            prospectId = ConvertLead_Page_Controller.convert(lead, true, false);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
    }
    
    @isTest static void convertExistingCustomer() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(
            FirstName = 'Testconvert',
            LastName = 'Existingcust',
            IsActive = true,
            Username = 'testconvert@mail.com',
            Email = 'testconvert@mail.com',
            Alias = 'tconv',
            TimeZoneSidKey = 'Asia/Bangkok',
            LocaleSidKey = 'th_TH',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id,
            Employee_ID__c = '1234567'
        );
        insert user;
        
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        Account temp = new Account();
        temp.LastName = 'temp';
        temp.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
        temp.Temporary_Customer__c = true;
        temp.Port_Pool__c = 'Port';
        insert temp;
        
        temp.Temporary_Customer__c = false;
        update temp;
        
        Lead lead;
        System.runAs(user) {
            lead = new Lead();
            lead.FirstName = 'Test';
            lead.LastName = 'Test';
            lead.Company = 'Test Test';
            lead.Customer__c = temp.Id;
            lead.Status = 'Assigned';
            insert lead;
            
            lead.LastName = '';
        }
        
        Id custId = ConvertLead_Page_Controller.convert(lead, false, true);
        System.assertEquals(temp.Id, custId);
        
        try {
            custId = ConvertLead_Page_Controller.convert(lead, false, true);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
    }
    
    @isTest static void loadPicklistData() {
        List<String> picklistDocumentType =  ConvertLead_Page_Controller.getDocumentType();
        List<String> picklistSalutation =  ConvertLead_Page_Controller.getSalutation();
        List<String> picklistCustomerType =  ConvertLead_Page_Controller.getCustomerType();
        System.assertEquals(true, picklistDocumentType.size() > 0);
        System.assertEquals(true, picklistSalutation.size() > 0);
        System.assertEquals(true, picklistCustomerType.size() > 0);
    }
    
    @isTest static void loadFieldLabel() {
        List<String> fieldLabel =  ConvertLead_Page_Controller.getFieldLabel();
        System.assertEquals(10, fieldLabel.size());
    }
    
    @isTest static void loadUserId() {
        Id userId = ConvertLead_Page_Controller.getCurrentUsedrId();
        System.assertEquals(UserInfo.getUserId(), userId);
    }
    
    @isTest static void loadLeadAndCheckExisting() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Open';
        insert lead;
        
        Lead resultLead = ConvertLead_Page_Controller.getLead(lead.Id);
        Boolean resultExisting = ConvertLead_Page_Controller.haveExistingCustomer(lead);
        System.assertEquals(lead.Id, resultLead.Id);
        System.assertEquals(false, resultExisting);
    }
}