@isTest
private class SME_CallReportOwnerInitial_Batch_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void callReportInitial(){
		Account targetAccount = [SELECT Id, Owner_Emp_ID__c, RC_Code__c FROM Account WHERE Name = :SME_CallReportOwnerInitial_Batch_Test.accountNameRM LIMIT 1];
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
				Collect_Documents__c = true,
				RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
				Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION
			);

			insert callreportObj;

			Test.startTest();
				Database.executeBatch(new SME_CallReportOwnerInitial_Batch());
			Test.stopTest();

		}

		Team_Structure__c teamStr = [SELECT Id FROM Team_Structure__c WHERE External_ID__c = :targetAccount.RC_Code__c LIMIT 1];
		User_Extension__c userExt = [SELECT Id FROM User_Extension__c WHERE External_ID__c = :targetAccount.Owner_Emp_ID__c LIMIT 1];
		Call_Report__c targetCallRep = [SELECT Id, Current_Owner_Extension__c, Current_Team_Name__c FROM Call_Report__c WHERE CIS_ID__c = :targetAccount.Id];
        System.assertEquals(userExt.Id, targetCallRep.Current_Owner_Extension__c);
        System.assertEquals(teamStr.Id, targetCallRep.Current_Team_Name__c);
	}
	
}