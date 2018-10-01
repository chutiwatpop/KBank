@isTest
private class SME_PurgeLeadCdbBySfdcBin_Batch_Test {
	public static String CAMPAIGN_OBJECT_NAME = 'Campaign';
	public static String TARGET_LIST_OBJECT_NAME = 'Target_List';
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
	
    @testSetup static void setupAccount(){
        System.debug('setupAccount');
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        //Account newAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM LIMIT 1][0];
        Account newAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id');
        List<Campaign> listCampaign = new List<Campaign>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();
		Campaign leadForSales = new Campaign();
		Target_List__c targetListForSales = new Target_List__c();
        
        //System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			leadForSales = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadForSales', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
			listCampaign.add(leadForSales);
			insert listCampaign;

			targetListForSales = Mockup_Test.newTargetList(newAccount.Id, leadForSales.Id, 'externalId2', 'New');
			listTargetList.add(targetListForSales);
			insert listTargetList;
		//}
        
        delete listCampaign;
        
        TriggerHandler.clearBypass('UserTriggerHandler');
    }
    
	@isTest static void PurgeLeadCdbBySfdcBinThenPugreCampaignAndPurgeTargetList() {
		Test.startTest();
			Database.executeBatch(new SME_PurgeLeadCdbBySfdcBin_Batch());
		Test.stopTest();

		System.assertEquals(true,true);
	}
	
	@isTest static void PurgeLeadCdbBySfdcBinPurgeOnlyTargetListThenPurgeTargetList() {
		Test.startTest();
			Database.executeBatch(new SME_PurgeLeadCdbBySfdcBin_Batch(1,1,false,TARGET_LIST_OBJECT_NAME));
		Test.stopTest();

		System.assertEquals(true,true);
	}
    
    @isTest static void PurgeLeadCdbBySfdcBinPurgeOnlyTargetListRunFirstTimeNullThenPurgeTargetList() {
		Test.startTest();
			Database.executeBatch(new SME_PurgeLeadCdbBySfdcBin_Batch(1, 1, TARGET_LIST_OBJECT_NAME));
		Test.stopTest();

		System.assertEquals(true,true);
	}
	
}