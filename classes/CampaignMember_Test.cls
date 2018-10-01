@isTest
private class CampaignMember_Test {
	public static String contactName = 'contactName';
	public static String contactLastName = 'contactLastName';
	public static String accountNameTM = 'accountNameTM';
	public static String accountNameRM = 'accountNameRM';
	public static String campaignName = 'testCampaign';

	 @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]){

            mt.newAccountWithContact(accountNameTM, contactName, contactLastName, GlobalConstants.POOL, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));            
        	Campaign cam = Mockup_Test.newCampaign(UserInfo.getUserId(),campaignName, System.now(), ((Datetime) System.now()).addDays(1), ((Datetime) System.now()).addDays(-1), GlobalConstants.PLANNED,GlobalConstants.SME_EVENT_NON_TARGET,'Campaign');
        	//cam.Address_Registration__c = 'No';
        	insert cam;
            mt.newAccountWithContact(accountNameRM, 'conName2', 'conLastName2', GlobalConstants.POOL, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

	static testMethod void testInsertComplete() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]){

			//Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Name_Surname_TH__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
			Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Name_Surname_TH__c');
	        Contact cont = [SELECT Id, Customer_Name__c FROM Contact WHERE AccountId = :targetAccount.Id LIMIT 1];
	        Campaign cmp = [SELECT Id FROM Campaign WHERE OwnerId = :UserInfo.getUserId() LIMIT 1];

	        Event_Target_List__c ets = new Event_Target_List__c();
	        ets.Event_Name__c = cmp.Id;
	        ets.CIS_ID_Prospect_Name__c = targetAccount.Id;
	        insert ets;

			System.assertEquals(1, [SELECT Id FROM Event_Target_List__c].size());
	        System.assertEquals(0, [SELECT Id FROM CampaignMember].size());

	        CampaignMember cmpMem = new CampaignMember();
	        cmpMem.CampaignId = cmp.Id;
	        cmpMem.ContactId = cont.Id;

	        Test.startTest();
	    		insert cmpMem;
	    	Test.stopTest();

	    	System.assertEquals(1, [SELECT Id FROM CampaignMember].size());
    	}
	}

	static testMethod void testInsertIncomplete() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]){

			//Account accountTM = [SELECT Id FROM Account WHERE Name = :accountNameTM LIMIT 1];
			//Account accountRM = [SELECT Id FROM Account WHERE Name = :accountNameRM LIMIT 1];
			Account accountTM = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id');
			Account accountRM = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id');
	        Contact cont = [SELECT Id, Customer_Name__c FROM Contact WHERE Contact.AccountId = :accountRM.Id LIMIT 1];
	        Campaign cmp = [SELECT Id FROM Campaign WHERE OwnerId = :UserInfo.getUserId() LIMIT 1];

	        Event_Target_List__c ets = new Event_Target_List__c();
	        ets.Event_Name__c = cmp.Id;
	        ets.CIS_ID_Prospect_Name__c = accountTM.Id;
	        insert ets;

	        System.assertEquals(0, [SELECT Id FROM CampaignMember].size());

	        try {
				CampaignMember cmpMem = new CampaignMember();
		        cmpMem.CampaignId = cmp.Id;
		        cmpMem.ContactId = cont.Id;
		        Test.startTest();
		    		insert cmpMem;
		    	Test.stopTest();
	        } catch (DmlException dmex) {
	        	System.assert(dmex.getMessage().contains(GlobalConstants.CANNOT_INSERT_CAMMEM));
	        }
    	}
	}

	static testMethod void testStampContact() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]){

			//Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Name_Surname_TH__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
			Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Name_Surname_TH__c');
	        Contact cont = [SELECT Id, Customer_Name__c, Phone_Numbers__c FROM Contact WHERE AccountId = :targetAccount.Id LIMIT 1];
	        Campaign cmp = [SELECT Id FROM Campaign WHERE OwnerId = :UserInfo.getUserId() LIMIT 1];

	        Event_Target_List__c ets = new Event_Target_List__c();
	        ets.Event_Name__c = cmp.Id;
	        ets.CIS_ID_Prospect_Name__c = targetAccount.Id;
	        insert ets;

			System.assertEquals(1, [SELECT Id FROM Event_Target_List__c].size());
	        System.assertEquals(0, [SELECT Id FROM CampaignMember].size());

	        CampaignMember cmpMem = new CampaignMember();
	        cmpMem.CampaignId = cmp.Id;
	        cmpMem.ContactId = cont.Id;

	        Test.startTest();
	    		insert cmpMem;
	    	Test.stopTest();
	    	CampaignMember finalContact = [SELECT Id, Contact_Phone_Number__c FROM CampaignMember WHERE ContactId = :cont.Id LIMIT 1];
	    	System.assertEquals(cont.Phone_Numbers__c, finalContact.Contact_Phone_Number__c);
    	}
	}
}