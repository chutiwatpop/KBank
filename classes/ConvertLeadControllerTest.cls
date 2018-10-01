@isTest 
private class ConvertLeadControllerTest {
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
    
    @isTest static void convertNewIndividualProspectAndNoTempWithJob() {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
        Lead lead = new Lead();
        lead.Identification_No__c = '1234567891011';
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Status = 'Assigned';
        lead.Company = 'Test Test';
        lead.RecordTypeID = recordTypeMapByDevName.get('Lead_Referral');
        insert lead;
        
        Id prospectId = ConvertLeadController.convert(lead, true, true, null);
        System.assertNotEquals(null, prospectId);
    }

    @isTest static void convertNewIndividualProspectAndNoTempNoJob() {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Status = 'Assigned';
        lead.Company = 'Test Test';
        lead.RecordTypeID = recordTypeMapByDevName.get('Lead_Referral');
        insert lead;
        
        Id prospectId = ConvertLeadController.convert(lead, true, false, null);
        System.assertNotEquals(null, prospectId);        
    }
    
    @isTest static void convertNewProspectOrganizationNegative() {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Assigned';
        lead.RecordTypeID = recordTypeMapByDevName.get('Lead_Referral');
        insert lead;
        
        lead.Document_Type__c = 'บัตรประชาชน';
        lead.Identification_No__c = '111111111111111';
        
        Id prospectId;
        try {
            prospectId = ConvertLeadController.convert(lead, false, false, null);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
    }

    @isTest static void convertNewProspectOrganization() {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Assigned';
        lead.RecordTypeID = recordTypeMapByDevName.get('Lead_Referral');
        insert lead;
        
        Id prospectId;
        
        lead.Document_Type__c = 'บัตรประชาชน';
        lead.Identification_No__c = '1111111111111';
        
        prospectId = ConvertLeadController.convert(lead, false, false, null);
        System.assertNotEquals(null, prospectId);
        
        try {
            prospectId = ConvertLeadController.convert(lead, false, false, null);
        } catch(AuraHandledException e) {
            System.assertNotEquals(null,e.getMessage());
        }
    }
    
    @isTest static void convertExistingCustomer() {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        Account temp = new Account();
        temp.LastName = 'Test';
        temp.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
        temp.Temporary_Customer__c = true;
        temp.Port_Pool__c = 'Port';
        temp.CIS__c = '101011';
        insert temp;
        
        temp.Temporary_Customer__c = false;
        update temp;
        
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Customer__c = temp.Id;
        lead.Status = 'Assigned';
        lead.CIS_ID__c  = '101011';
        insert lead;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Id custId = ConvertLeadController.convert(lead, true, false, null);
            System.assertEquals(temp.Id, custId);
            
            try {
                custId = ConvertLeadController.convert(lead, true, false, null);
            } catch(AuraHandledException e) {
                System.assertNotEquals(null,e.getMessage());
            }
        }
    }
    
    @isTest static void loadPicklistData() {
        List<String> picklistDocumentType =  ConvertLeadController.getDocumentType();
        List<String> picklistSalutation =  ConvertLeadController.getSalutation();
        List<String> picklistCustomerType =  ConvertLeadController.getCustomerType();
        System.assertEquals(true, picklistDocumentType.size() > 0);
        System.assertEquals(true, picklistSalutation.size() > 0);
        System.assertEquals(true, picklistCustomerType.size() > 0);
    }
    
    @isTest static void loadFieldLabel() {
        List<String> fieldLabel =  ConvertLeadController.getFieldLabel();
        System.assertEquals(10, fieldLabel.size());
    }
    
    @isTest static void loadUserId() {
        Id userId = ConvertLeadController.getCurrentUsedrId();
        System.assertEquals(UserInfo.getUserId(), userId);
    }
    
    @isTest static void loadLeadAndCheckExisting() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test Test';
        lead.Status = 'Open';
        insert lead;
        
        ConvertLeadController.ResponseModel resultLead = ConvertLeadController.getLead(lead.Id);
        Boolean resultExisting = ConvertLeadController.haveExistingCustomer(lead);
        System.assertEquals(lead.Id, resultLead.lead.Id);
        System.assertEquals(false, resultExisting);
    }
}