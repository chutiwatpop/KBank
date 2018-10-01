@isTest
private class AF_ReleaseTemporaryOwnershipTest {
	public static String accountLastCallOpptyOverLabelLimit_1 = 'accountLastCallOpptyOverLabelLimit_1';
	public static String accountLastCallOpptyOverLabelLimit_2 = 'accountLastCallOpptyOverLabelLimit_2';
	public static String accountLastCallOpptyEqualLabelLimit_1 = 'accountLastCallOpptyEqualLabelLimit_1';
    public static String accountLastCallOpptyEqualLabelLimit_2 = 'accountLastCallOpptyEqualLabelLimit_2';
    public static String accountLastCallOpptyUnderLabelLimit_1 = 'accountLastCallOpptyUnderLabelLimit_1';
    public static String accountLastCallOpptyUnderLabelLimit_2 = 'accountLastCallOpptyUnderLabelLimit_2';

	@testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountLastCallOpptyOverLabelLimit_1,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
            mt.newAccount(accountLastCallOpptyOverLabelLimit_2,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));

            mt.newAccount(accountLastCallOpptyEqualLabelLimit_1,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
			mt.newAccount(accountLastCallOpptyEqualLabelLimit_2,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
            
            mt.newAccount(accountLastCallOpptyUnderLabelLimit_1,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
            mt.newAccount(accountLastCallOpptyUnderLabelLimit_2,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
        }
        
        User_Extension__c rmUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        List<Account> accountList = [SELECT Id, Name, AF_Last_CallReprt_Opty_Updated_Date__c, CreatedDate FROM Account];
        String limitOfReleaseOwnership = Label.AF_Release_Temporary_Customer;
        for(Account account:accountList){
            
            if(account.Name == accountLastCallOpptyOverLabelLimit_1 || account.Name == accountLastCallOpptyOverLabelLimit_2){
                account.AF_Temporary_Customer__c = rmUserExtension.Id;
                account.AF_Last_CallReprt_Opty_Updated_Date__c = System.today()-(Integer.valueOf(limitOfReleaseOwnership)+1);
            }
            if(account.Name == accountLastCallOpptyEqualLabelLimit_1 || account.Name == accountLastCallOpptyEqualLabelLimit_2){
                account.AF_Temporary_Customer__c = rmUserExtension.Id;
                account.AF_Last_CallReprt_Opty_Updated_Date__c = System.today()-Integer.valueOf(limitOfReleaseOwnership);
            }
            if(account.Name == accountLastCallOpptyUnderLabelLimit_1 || account.Name == accountLastCallOpptyUnderLabelLimit_2){
                account.AF_Temporary_Customer__c = rmUserExtension.Id;
                account.AF_Last_CallReprt_Opty_Updated_Date__c = System.today()-(Integer.valueOf(limitOfReleaseOwnership)-1);
            }

        }
        TriggerHandler.bypass('AccountTriggerHandler');
        update accountList;
    }

	@isTest static void Given_AccountUnderEqualAndOverLimit_When_RunBatch_Then_AccountOverLimitClearAfTemp(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        List<Account> listAccount = [SELECT Id, Name, AF_Last_CallReprt_Opty_Updated_Date__c, CreatedDate FROM Account];
        List<Id> listAccountId = new List<Id>();
        for(Account eachAccount : listAccount){
        	listAccountId.add(eachAccount.Id);
        }
        Database.executeBatch(new AF_ReleaseTemporaryOwnership_Batch(listAccountId));
        Test.stopTest();

        Account resultAccountLastCallOpptyOverLabelLimit_1 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyOverLabelLimit_1, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertEquals(null,resultAccountLastCallOpptyOverLabelLimit_1.AF_Temporary_Customer__c);
        
        Account resultAccountLastCallOpptyOverLabelLimit_2 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyOverLabelLimit_2, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertEquals(null,resultAccountLastCallOpptyOverLabelLimit_2.AF_Temporary_Customer__c);
        
		Account resultAccountLastCallOpptyEqualLabelLimit_1 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyEqualLabelLimit_1, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertEquals(null,resultAccountLastCallOpptyEqualLabelLimit_1.AF_Temporary_Customer__c);
        
        Account resultAccountLastCallOpptyEqualLabelLimit_2 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyEqualLabelLimit_2, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertEquals(null,resultAccountLastCallOpptyEqualLabelLimit_2.AF_Temporary_Customer__c);
        
        Account resultAccountLastCallOpptyUnderLabelLimit_1 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyUnderLabelLimit_1, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertNotEquals(null,resultAccountLastCallOpptyUnderLabelLimit_1.AF_Temporary_Customer__c);
        
        Account resultAccountLastCallOpptyUnderLabelLimit_2 = Mockup_Test.getFirstAccountFromName(accountLastCallOpptyUnderLabelLimit_2, 'Id, Customer_Owner_Release_Flag__c, AF_Temporary_Customer__c');
        System.assertNotEquals(null,resultAccountLastCallOpptyUnderLabelLimit_2.AF_Temporary_Customer__c);
    }
	
}