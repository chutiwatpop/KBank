@isTest
private class SME_CallReport_Initial_Batch_Test {
	public static String accountNameRM = 'rmCreatedAccountName';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}
    static testMethod void testMethod1() {
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Call_Report__c callreportObj;
		System.runAs(userRM){
			
			callreportObj = new Call_Report__c(
				Contact_Firstname__c = 'abc',
				Contact_Lastname__c = 'def',
				Contact_Phone__c = '123456789',
				CIS_ID__c = targetAccount.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today(),
				Primary_Call_Report__c = false
			);
			insert callreportObj;
		}
		Call_Report__c finalcallreport = [select id,Primary_Call_Report__c from call_report__c where id=:callreportObj.Id limit 1];
		system.assertEquals(false,finalcallreport.Primary_Call_Report__c);
		Test.startTest();
        	Database.executeBatch(new SME_CallReport_Initial_Batch());
        Test.stopTest();
        finalcallreport = [select id,Primary_Call_Report__c from call_report__c where id=:callreportObj.Id limit 1];
		system.assertEquals(true,finalcallreport.Primary_Call_Report__c);
    }
}