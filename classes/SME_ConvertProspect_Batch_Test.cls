@isTest
private class SME_ConvertProspect_Batch_Test {

	@testSetup static void setupTestClass(){
		Mockup_Test mt = new Mockup_Test().setUpTestOnlyAdmin();
	}	

    @isTest static void testBatch(){
        String prospectRecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]) {
            Account accProspect = new Account();
            accProspect.Name = 'testBatch';
            accProspect.CIS__c = '123456';
            accProspect.RecordTypeId = prospectRecordTypeId;
            accProspect.Is_createby_Integration__c = true;
            insert accProspect;

            Account accProspect2 = new Account();
            accProspect2.Name = 'testBatch2';
            accProspect2.CIS__c = 'String';
            accProspect2.RecordTypeId = prospectRecordTypeId;
            accProspect2.Birthdate_Registration_Date__c = System.today() - 600;
            accProspect2.Encrypt_Identification_No__c = '2312312425553';
            accProspect2.Is_createby_Integration__c = true;
            insert accProspect2;
        }
        Test.startTest();        
            Id executeBatchJobId = Database.executeBatch(new SME_ConvertProspect_Batch());
            System.assertNotEquals(null, executeBatchJobId);
        Test.stopTest();
        Account targetAccount = Mockup_Test.getFirstAccountFromName('testBatch2', 'Convert_Prospect_Date__c');
        System.assertNotEquals(System.today(), targetAccount.Convert_Prospect_Date__c);
    }
}