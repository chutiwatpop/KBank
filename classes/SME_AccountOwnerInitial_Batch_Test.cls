@isTest
private class SME_AccountOwnerInitial_Batch_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

	@testSetup static void setupAccount(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        Test.stopTest();
	}

	@isTest static void initialWithPreviousOwner(){
		//Account targetAccount = [SELECT Id, Owner_Emp_ID__c, RC_Code__c FROM Account WHERE Name = :SME_AccountOwnerInitial_Batch_Test.accountNameTM LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(SME_AccountOwnerInitial_Batch_Test.accountNameTM, 'Id, Owner_Emp_ID__c, RC_Code__c');
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

		Call_Report__c callreportObj;
		//System.runAs(userRM){
			callreportObj = new Call_Report__c(
				Contact_Firstname__c = 'abc',
				Contact_Lastname__c = 'def',
				Contact_Phone__c = '123456789',
				CIS_ID__c = targetAccount.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today(),
				Collect_Documents__c = true,
				RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
				Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION
			);
			insert callreportObj;
		//}
		
		Account expectAccount = [SELECT Id,RC_Code__c, Owner_Emp_ID__c, Previous_Owner__c, Previous_Owner__r.Employee_ID__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
		//System.assertEquals(userTM.Id, expectAccount.Previous_Owner__c);

		Test.startTest();
			Database.executeBatch(new SME_AccountOwnerInitial_Batch());
		Test.stopTest();

		Team_Structure__c teamStr = [SELECT Id FROM Team_Structure__c WHERE External_ID__c = :expectAccount.RC_Code__c LIMIT 1];
		User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE External_ID__c = :expectAccount.Owner_Emp_ID__c LIMIT 1];
		//User_Extension__c userTMExt = [SELECT Id FROM User_Extension__c WHERE External_ID__c = :expectAccount.Previous_Owner__r.Employee_ID__c LIMIT 1];
	
		Account finalAccount = [SELECT Id,Current_Owner_Extension__c,Previous_Owner_Extension__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
		System.assertEquals(userRMExt.Id, finalAccount.Current_Owner_Extension__c);
		//System.assertEquals(userTMExt.Id, finalAccount.Previous_Owner_Extension__c); 
	}
	
}