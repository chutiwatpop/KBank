@isTest
private class SME_PurgeProspect_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';

	@testSetup static void setupAccount(){
		TriggerHandler.bypass('UserTriggerHandler');
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
		
		Test.startTest();
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		userTM.Segment__c = GlobalConstants.SEGMENT_ME;
        update userTM;
        Account targetAccount;
        System.runAs(userTM){
            targetAccount = new Account(
	            Name = accountNameTM,
	            Port_Pool__c = GlobalConstants.POOL,
	            Birthdate_Registration_Date__c = System.today(),
	            Encrypt_Identification_No__c = '3333332222222',
	            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT),
	            Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY,
	            Primary_Segment_Code__c = 'SE',
                Is_createby_Integration__c = true
	        );
	        insert targetAccount;

            Contact mockContact = new Contact(
            	LastName = 'lastname',
				Contact_Firstname__c = 'Firstname',
				AccountId = targetAccount.Id,
				Phone_Numbers__c = '0123456789'
            );
			insert mockContact;

	        Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c=GlobalConstants.SEGMENT_ME,External_ID__c='123456:'+GlobalConstants.SEGMENT_ME);
	        insert buCodeTest;

			Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c(Name=Customer_BusinessCode_Service.getDefaultValue(),CIS__c=targetAccount.id,Business_Code__c=buCodeTest.id,External__c=targetAccount.CIS__c+':'+buCodeTest.External_ID__c,Account_Owner_Segment__c=GlobalConstants.SEGMENT_ME);
            insert customerBusinessCode;

			Call_Report__c callReport = new Call_Report__c(
                Contact__c = mockContact.Id,
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 6000,
                Customer_Business_Code__c = customerBusinessCode.id,
                Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
            );
            
			insert callReport;
            
            Opportunity opp = new Opportunity(
                Name = 'opp_'+accountNameTM,
                StageName = 'Open',
                AccountId = targetAccount.Id,
                CloseDate = Date.today().addDays(7)
            );
            insert opp;

            TriggerHandler.bypass('CustomerOwnershipRequestTriggerHandler');
            Customer_Ownership_Request__c customerRequest = new Customer_Ownership_Request__c();
            customerRequest.Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP;
            customerRequest.CIS_ID__c = targetAccount.Id;
            customerRequest.Request_Ownership_Type__c = GlobalConstants.POOL;
            insert customerRequest;
            TriggerHandler.clearBypass('CustomerOwnershipRequestTriggerHandler');
        }

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            Campaign mockCampaign = new Campaign();
			mockCampaign.Lead_Campaign_Event_Code__c = 'Test';
			mockCampaign.Type__c = GlobalConstants.LEAD_FOR_SALES;
			mockCampaign.Name = 'Test';
			mockCampaign.Status = GlobalConstants.ACTIVE;
        	mockCampaign.IsActive = true;
        	mockCampaign.StartDate = System.today() - 1;
			mockCampaign.EndDate = System.Today() + 1;
			mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
			insert mockCampaign;

            Target_List__c eachTargetList = new Target_List__c();
			eachTargetList.CIS_ID_Prospect_Name__c = targetAccount.Id;
			eachTargetList.Lead_Campaign__c = mockCampaign.Id;
			eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
			insert eachTargetList;
        }


        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
	}

	@isTest static void testPurgeProspect() {
		System.assertEquals(1, [SELECT Count() FROM Account]);
		System.assertEquals(1, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(1, [SELECT Count() FROM Customer_Ownership_Request__c]);
		System.assertEquals(1, [SELECT Count() FROM Contact]);
		System.assertEquals(1, [SELECT Count() FROM Call_Report__c]);
		System.assertEquals(1, [SELECT Count() FROM Opportunity]);
		
		Test.startTest();
		Database.executeBatch(new SME_PurgeProspect_Batch(-1));
		Test.stopTest();

		System.assertEquals(0, [SELECT Count() FROM Account]);
		System.assertEquals(0, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(0, [SELECT Count() FROM Contact]);
		System.assertEquals(0, [SELECT Count() FROM Customer_Ownership_Request__c]);
		System.assertEquals(0, [SELECT Count() FROM Call_Report__c]);
		System.assertEquals(0, [SELECT Count() FROM Opportunity]);
	}
	
	@isTest static void testNegativePurgeProspect() {
		System.assertEquals(1, [SELECT Count() FROM Account]);
		System.assertEquals(1, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(1, [SELECT Count() FROM Customer_Ownership_Request__c]);
		System.assertEquals(1, [SELECT Count() FROM Contact]);
		
		Test.startTest();
		Database.executeBatch(new SME_PurgeProspect_Batch());
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Account]);
		System.assertEquals(1, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(1, [SELECT Count() FROM Contact]);
		System.assertEquals(1, [SELECT Count() FROM Customer_Ownership_Request__c]);
	}
}