@isTest
private class SME_UserExtensionInitial_Batch_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String newRMEmpId = 'TEST01';
    public static String newTMEmpId = 'TEST02';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';

    public static String newRCCode = '84044';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            SME_UserExtensionInitial_Batch_Test.setUpTeam();
        }
	}
	
	public static void setUpTeam() {
		Team_Structure__c tsNh = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			External_ID__c = Mockup_Test.NH_RC_CODE
		);
		insert tsNh;

		Team_Structure__c tsAh = new Team_Structure__c(
			NH_Name__c = tsNh.Id,
			NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
			RC_Code__c = Mockup_Test.AH_RC_CODE,
			AH_Name__c = null,
			External_ID__c = Mockup_Test.AH_RC_CODE
		);
		insert tsAh;

		Team_Structure__c tsTm = new Team_Structure__c(
			NH_Name__c = tsNh.Id,
			NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
			AH_Name__c = tsAh.Id,
			AH_RC_Code__c = Mockup_Test.AH_RC_CODE,
			RC_Code__c = Mockup_Test.RC_CODE,
			External_ID__c = Mockup_Test.RC_CODE
		);
		insert tsTm;
	}

	@isTest	static void testInitial(){
		System.assertNotEquals(0, [SELECT Count() FROM User]);
		Integer beforerunBatch = [SELECT Count() FROM User_Extension__c];

		Test.startTest();
			Database.executeBatch(new SME_UserExtensionInitial_Batch());
		Test.stopTest();

		System.assert(beforerunBatch < [SELECT Count() FROM User_Extension__c]);
	}
}