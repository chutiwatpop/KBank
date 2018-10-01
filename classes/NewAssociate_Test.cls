@isTest
private class NewAssociate_Test {
    public static String accountNameRMPort = 'accountNameRMPort';
    public static String accountNameRMPool = 'accountNameRMPool';
	@testSetup static void setupAccount(){
		System.runAs(new User(Id=UserInfo.getUserId())){
            SME_Associate_Conditions__c associateDefault = SME_Associate_Conditions__c.getInstance(UserInfo.getOrganizationId());
            associateDefault.Interest__c = 'Interest_and_can_apply';
            associateDefault.Not_Interest__c = 'Not interest';
			associateDefault.Not_Interest_Memo__c = 'Associated Customer ลูกค้าไม่สนใจ';
			associateDefault.Not_Interest_Reason__c = '4_11_Others';
			insert associateDefault;
        }

        Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        System.runAs(rmUser){
            mt.newAccount(accountNameRMPort,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMPool,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        Test.stopTest();
	}

	@isTest static void testNewAssoComponentGetPicklist() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			NewAssociateController.getAssociateTypes();
			NewAssociateController.getBorrowerTypes();
		}
	}

	@isTest static void NewAssoFromComponentInterestMain() {
		Account targetAccount = Mockup_Test.getFirstAccountFromName(NewAssociate_Test.accountNameRMPort, 'Id,Name,RecordType.DeveloperName,CIS__c');
		String accountString = JSON.serialize(targetAccount);
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert targetOpp;
			Event mainEvent = new Event(
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now(),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
				WhatId = targetOpp.Id
			);
			insert mainEvent;
			String respString = NewAssociateController.saveRecord(accountString, mainEvent.Id, 'สนใจ', 'Main Borrower');
			NewAssociateController.ResultResponse resultResponse = (NewAssociateController.ResultResponse) JSON.deserialize(respString, NewAssociateController.ResultResponse.class);
			System.assertEquals('SUCCESS', resultResponse.result);

			Date currentDate = System.today();
            Integer year 	= currentDate.year();
            Integer month 	= currentDate.month();
            Integer day 	= currentDate.day();
            String stringMonth;
            if(month < 10){
                stringMonth = '0'+month;
            }
            String expectedJobName = year + '/' + stringMonth + '/' + day + '_' + targetAccount.Name + '_Asso';

			Opportunity newJobFromAsso = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE AccountId = :targetAccount.Id AND Name =: expectedJobName ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals(expectedJobName, newJobFromAsso.Name);
			System.assertEquals(GlobalConstants.CONTACTED, newJobFromAsso.StageName);
		}
	}

	@isTest static void NewAssoFromComponentInterestCo() {
		Account targetAccount = Mockup_Test.getFirstAccountFromName(NewAssociate_Test.accountNameRMPort, 'Id,Name,RecordType.DeveloperName,CIS__c');
		String accountString = JSON.serialize(targetAccount);
		User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		Event mainEvent;
		System.runAs(userRm){
			Test.startTest();
			Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert targetOpp;
			mainEvent = new Event(
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
				WhatId = targetOpp.Id
				//Visit_Objective__c
			);
			insert mainEvent;
			Test.stopTest();
		}

		System.runAs(userRm){
			
			String respString = NewAssociateController.saveRecord(accountString, mainEvent.Id, 'สนใจ', 'Co-Borrower');
			NewAssociateController.ResultResponse resultResponse = (NewAssociateController.ResultResponse) JSON.deserialize(respString, NewAssociateController.ResultResponse.class);
			System.assertEquals('SUCCESS', resultResponse.result);
			
			Date currentDate = System.today();
            Integer year 	= currentDate.year();
            Integer month 	= currentDate.month();
            Integer day 	= currentDate.day();
            String stringMonth;
            if(month < 10){
                stringMonth = '0'+month;
            }
            String expectedJobName = year + '/' + stringMonth + '/' + day + '_' + targetAccount.Name + '_Asso';

			Opportunity newJobFromAsso = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE AccountId = :targetAccount.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals(expectedJobName, newJobFromAsso.Name);
			System.assertEquals(GlobalConstants.FINISHED, newJobFromAsso.StageName);

			Event newEvent = [SELECT Id, OwnerId, Secondary_Call_Report__c, Offer_Credit_Product__c, Primary_Call_Report_Id__c, Visit_Objective__c, StartDateTime, EndDateTime, RecordTypeId, Offer_Interest__c, Borrower_Type__c FROM Event WHERE WhatId = :newJobFromAsso.Id];
			System.assertEquals(userRm.Id, newEvent.OwnerId);
			System.assertEquals(true, newEvent.Secondary_Call_Report__c);
			System.assertEquals(true, newEvent.Offer_Credit_Product__c);
			System.assertEquals(mainEvent.Id, newEvent.Primary_Call_Report_Id__c);
			System.assertEquals(mainEvent.Visit_Objective__c, newEvent.Visit_Objective__c);
			System.assertEquals(mainEvent.StartDateTime, newEvent.StartDateTime);
			System.assertEquals(mainEvent.EndDateTime, newEvent.EndDateTime);
			//System.assertEquals('Co-Borrower', newEvent.Borrower_Type__c);
			System.assertEquals(GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME), newEvent.RecordTypeId);
		}
	}

	@isTest static void NewAssoFromComponentNotInterest() {
		SME_Associate_Conditions__c associateDefault = SME_Associate_Conditions__c.getOrgDefaults();
		Account targetAccount = Mockup_Test.getFirstAccountFromName(NewAssociate_Test.accountNameRMPort, 'Id,Name,RecordType.DeveloperName,CIS__c');
		String accountString = JSON.serialize(targetAccount);
		User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(userRm){
			Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert targetOpp;
			Event mainEvent = new Event(
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
				WhatId = targetOpp.Id
				//Visit_Objective__c
			);
			insert mainEvent;
			String respString = NewAssociateController.saveRecord(accountString, mainEvent.Id, 'ไม่สนใจ', null);
			NewAssociateController.ResultResponse resultResponse =  (NewAssociateController.ResultResponse) JSON.deserialize(respString, NewAssociateController.ResultResponse.class);
			System.assertEquals('SUCCESS', resultResponse.result);

			Date currentDate = System.today();
            Integer year 	= currentDate.year();
            Integer month 	= currentDate.month();
            Integer day 	= currentDate.day();
            String stringMonth;
            if(month < 10){
                stringMonth = '0'+month;
            }
            String expectedJobName = year + '/' + stringMonth + '/' + day + '_' + targetAccount.Name + '_Asso';

			Opportunity newJobFromAsso = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE AccountId = :targetAccount.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals(expectedJobName, newJobFromAsso.Name);
			System.assertEquals(GlobalConstants.FINISHED, newJobFromAsso.StageName);

			Event newEvent = [SELECT Id, OwnerId, Secondary_Call_Report__c, Offer_Credit_Product__c, Primary_Call_Report_Id__c, Visit_Objective__c, StartDateTime, EndDateTime, RecordTypeId, Offer_Interest__c, Memo__c, Reason__c FROM Event WHERE WhatId = :newJobFromAsso.Id];
			System.assertEquals(userRm.Id, newEvent.OwnerId);
			System.assertEquals(true, newEvent.Secondary_Call_Report__c);
			System.assertEquals(true, newEvent.Offer_Credit_Product__c);
			System.assertEquals(mainEvent.Id, newEvent.Primary_Call_Report_Id__c);
			System.assertEquals(mainEvent.Visit_Objective__c, newEvent.Visit_Objective__c);
			System.assertEquals(mainEvent.StartDateTime, newEvent.StartDateTime);
			System.assertEquals(mainEvent.EndDateTime, newEvent.EndDateTime);
			System.assertEquals(associateDefault.Not_Interest__c, newEvent.Offer_Interest__c);
			System.assertEquals(associateDefault.Not_Interest_Memo__c, newEvent.Memo__c);
			System.assertEquals(associateDefault.Not_Interest_Reason__c, newEvent.Reason__c);
			System.assertEquals(GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME), newEvent.RecordTypeId);
		}
	}

	@isTest static void NewAssoNegativeCase() {
		SME_Associate_Conditions__c associateDefault = SME_Associate_Conditions__c.getOrgDefaults();
		Account targetAccount = Mockup_Test.getFirstAccountFromName(NewAssociate_Test.accountNameRMPort, 'Id,Name,RecordType.DeveloperName,CIS__c');
		String accountString = JSON.serialize(targetAccount);
		User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(userRm){
			String respString = NewAssociateController.saveRecord(accountString, null, 'ไม่สนใจ', null);
			NewAssociateController.ResultResponse resultResponse =  (NewAssociateController.ResultResponse) JSON.deserialize(respString, NewAssociateController.ResultResponse.class);
			System.assertEquals('ERROR', resultResponse.result);
			System.assertEquals('List has no rows for assignment to SObject', resultResponse.message);
		}
	}
}