@isTest
private class EventTargetList_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountProspect = 'rmCreatedAccountProspect';
    public static String accountNameAH = 'ahCreatedAccountName';

    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountProspect,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }
	
	static testMethod void testDeleteEventByRM() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {

			Account testAcc = [SELECT Id FROM Account WHERE Name = :EventTargetList_Test.accountNameRM LIMIT 1];
			testAcc.OwnerId = UserInfo.getUserId();
			update testAcc;
        	
			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT_NON_TARGET, GlobalConstants.LEAD_FOR_SALES);
			camp.IsActive = true;
          	insert camp;

			Event_Target_List__c target = new Event_Target_List__c();
			target.Event_Name__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target;

			Test.startTest();
				Event_Target_List__c finalTarget = [SELECT Id, Name FROM Event_Target_List__c WHERE Id = :target.Id];
				try {
					delete finalTarget;	
				} catch (Exception ex) {
					System.assert(((String)ex.getMessage()).contains('cannot delete'));
				}
				
			Test.stopTest();
			
		}
	}

	static testMethod void testInsertEventProspect() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {

			Account testAcc = [SELECT Id FROM Account WHERE Name = :EventTargetList_Test.accountProspect LIMIT 1];
			testAcc.OwnerId = UserInfo.getUserId();
			update testAcc;
        	
			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT_NON_TARGET, GlobalConstants.LEAD_FOR_SALES);
			camp.IsActive = true;
          	insert camp;

			Event_Target_List__c target = new Event_Target_List__c();
			target.Event_Name__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			
			Test.startTest();
				insert target;
			Test.stopTest();
			
			Event_Target_List__c finalTarget = [SELECT Id, External_ID__c FROM Event_Target_List__c WHERE Event_Name__c = :camp.Id LIMIT 1];
			System.assertEquals(camp.Lead_Campaign_Event_Code__c + '' + testAcc.Id, finalTarget.External_ID__c);
		}
	}

	static testMethod void testInsertEventCustomer() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {

			Account testAcc = [SELECT Id FROM Account WHERE Name = :EventTargetList_Test.accountNameRM LIMIT 1];
			testAcc.OwnerId = UserInfo.getUserId();
			update testAcc;
        	
			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT_NON_TARGET, GlobalConstants.LEAD_FOR_SALES);
			camp.IsActive = true;
          	insert camp;

			Event_Target_List__c target = new Event_Target_List__c();
			target.Event_Name__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			
			Test.startTest();
				insert target;
			Test.stopTest();
			
			Event_Target_List__c finalTarget = [SELECT Id, External_ID__c FROM Event_Target_List__c WHERE Event_Name__c = :camp.Id LIMIT 1];
			System.assertEquals(camp.Lead_Campaign_Event_Code__c + '' + testAcc.CIS__c, finalTarget.External_ID__c);
		}
	}
	
}