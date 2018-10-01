@isTest
private class EventTrigger_Test {
	@testSetup static void setupTest(){
        Test.startTest();
	        Mockup_Test mt;
	        System.runAs(new User(Id=UserInfo.getUserId())){
	            mt = new Mockup_Test().setUpTestWithRCCode();
	        }
	      	
	      	System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
	      		Account accountRM = Mockup_Test.newAccountObj(Mockup_Test.userFirstNameRM,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
	            insert accountRM;
	      	}
        Test.stopTest();

	        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
				Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
				insert accountRecord;
				Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	        	insert opp;

	        	User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
	            OpportunityTeamMember oppTeam = new OpportunityTeamMember(
	            	TeamMemberRole = 'RM',
	            	UserId = rmUser.Id,
	            	OpportunityId = opp.Id
	            );
	            insert oppTeam;
	            OpportunityShare oppShare = new OpportunityShare(
	            	UserOrGroupId = rmUser.Id,
	            	OpportunityId = opp.Id,
		            OpportunityAccessLevel = 'Edit'
	            );
	            insert oppShare;
	        }
    }

	@isTest static void testCreateNewCallPlan() {
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'OppName'];
			Event newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = UserInfo.getUserId(),
				Status__c = GlobalConstants.PLAN,
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
			);
			insert newEvent;

			User currentUser = UserService.getCurrentUserInfo();
			Team_Structure__c mTeam = [SELECT Id,Branch_Code__c,Branch_Name__c,RC_Code__c,RC_Short_Name__c,AH_RC_Code__c,AH_Short_Name__c,NH_RC_Code__c,NH_Short_Name__c FROM Team_Structure__c WHERE RC_Code__c = :currentUser.RC_Code__c];
			Event actualEvent = [SELECT Id, Job__c, Branch_Code__c,Branch_Name__c,Team_RC_Code__c,Team_Short_Name__c,AH_RC_Code__c,AH_Short_Name__c,NH_RC_Code__c,NH_Short_Name__c,Plan_Date__c,ActivityDateTime FROM Event WHERE Id = :newEvent.Id];
			System.assertEquals(mTeam.Branch_Code__c, actualEvent.Branch_Code__c);
			System.assertEquals(mTeam.Branch_Name__c, actualEvent.Branch_Name__c);
			System.assertEquals(mTeam.RC_Code__c, actualEvent.Team_RC_Code__c);
			System.assertEquals(mTeam.RC_Short_Name__c, actualEvent.Team_Short_Name__c);
			System.assertEquals(mTeam.AH_RC_Code__c, actualEvent.AH_RC_Code__c);
			System.assertEquals(mTeam.AH_Short_Name__c, actualEvent.AH_Short_Name__c);
			System.assertEquals(mTeam.NH_RC_Code__c, actualEvent.NH_RC_Code__c);
			System.assertEquals(mTeam.NH_Short_Name__c, actualEvent.NH_Short_Name__c);
			System.assertEquals(actualEvent.Job__c, opp.Id);
			System.assertEquals(actualEvent.Plan_Date__c, actualEvent.ActivityDateTime);
		}
		Test.stopTest();
	}

	@isTest static void testCreateNewCallReport() {
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'OppName'];
			Event newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Visit_Objective__c = 'เพื่อขาย',
				Status__c = 'Contacted'
			);
			insert newEvent;

			User currentUser = UserService.getCurrentUserInfo();
			Team_Structure__c mTeam = [SELECT Id,Branch_Code__c,Branch_Name__c,RC_Code__c,RC_Short_Name__c,AH_RC_Code__c,AH_Short_Name__c,NH_RC_Code__c,NH_Short_Name__c FROM Team_Structure__c WHERE RC_Code__c = :currentUser.RC_Code__c];
			Event actualEvent = [SELECT Id, Branch_Code__c,Branch_Name__c,Team_RC_Code__c,Team_Short_Name__c,AH_RC_Code__c,AH_Short_Name__c,NH_RC_Code__c,NH_Short_Name__c FROM Event WHERE Id = :newEvent.Id];
			System.assertEquals(mTeam.Branch_Code__c, actualEvent.Branch_Code__c);
			System.assertEquals(mTeam.Branch_Name__c, actualEvent.Branch_Name__c);
			System.assertEquals(mTeam.RC_Code__c, actualEvent.Team_RC_Code__c);
			System.assertEquals(mTeam.RC_Short_Name__c, actualEvent.Team_Short_Name__c);
			System.assertEquals(mTeam.AH_RC_Code__c, actualEvent.AH_RC_Code__c);
			System.assertEquals(mTeam.AH_Short_Name__c, actualEvent.AH_Short_Name__c);
			System.assertEquals(mTeam.NH_RC_Code__c, actualEvent.NH_RC_Code__c);
			System.assertEquals(mTeam.NH_Short_Name__c, actualEvent.NH_Short_Name__c);
		}
		Test.stopTest();
	}

	@isTest static void testNegativeUpdateCallReport() {
		//Given
		User userTm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		Event newEvent;
		System.runAs(userTm){
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'OppName'];
			newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = userTm.Id,
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
				Visit_Objective__c = 'เพื่อขาย',
				Servicing__c = true,
				Offer_Credit_Product__c = false,
				Status__c = 'Contacted'
			);
			insert newEvent;
		}
		//When
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Test.startTest();
			System.runAs(userRM){
				Event updateEvent = [SELECT Id, OwnerId FROM Event WHERE Id = :newEvent.Id];
				updateEvent.Description = 'test';
				try {
					update updateEvent;	
				} catch(Exception ex) {
					// Then
					System.assert(ex.getMessage().contains(Label.Call_No_Access_Right));
				}
			}
		Test.stopTest();
	}


	@isTest static void testCBSSecondarycallReport(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            Account accountRecord = Mockup_Test.newAccountObj('AccountName2',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            insert accountRecord;
            Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName2', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
        	insert opp;

      		Event newEvent = new Event(
				WhatId = opp.Id,
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Visit_Objective__c = 'เพื่อขาย',
				Servicing__c = true,
				Offer_Credit_Product__c = false,
				Status__c = 'Contacted'
			);
	    	insert newEvent;
	    	
	    	Test.startTest();
	      	Event newEvent2 = new Event(
				WhatId = opp.Id,
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Visit_Objective__c = 'เพื่อขาย',
				Servicing__c = true,
				Offer_Credit_Product__c = false,
				Status__c = 'Contacted',
				Subject = 'SecordCall'
			);
      		insert newEvent2;
			Test.stopTest();
			System.assertNotEquals(0, [SELECT Count() FROM Event WHERE Secondary_Call_Report__c = true]);

        }
	}

	private static void initialCustomSettingForLeadMLP(){
		List<Telesales_Product_Name_to_Field_Mapping__c> listCustomSetting = new List<Telesales_Product_Name_to_Field_Mapping__c>();
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KEC',Field_API_Name__c= 'KEC__c',Display_Product_Name_As__c = 'KEC'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KPL',Field_API_Name__c= 'KPL__c',Display_Product_Name_As__c = 'KPL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL',Field_API_Name__c= 'HL__c',Display_Product_Name_As__c = 'HL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Refinance',Field_API_Name__c= 'HL_Refinance__c',Display_Product_Name_As__c = 'HL_Refinance'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Equity',Field_API_Name__c= 'HL_Help__c',Display_Product_Name_As__c = 'HL_ช่วยได้'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KCar',Field_API_Name__c= 'KCar__c',Display_Product_Name_As__c = 'KCar'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KL',Field_API_Name__c= 'KL__c',Display_Product_Name_As__c = 'KL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'SME_Loan',Field_API_Name__c= 'SME_Loan__c',Display_Product_Name_As__c = 'SME Loan'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'CC',Field_API_Name__c= 'CC__c',Display_Product_Name_As__c = 'CC'));
		insert listCustomSetting;
	}

	@isTest static void Given_LeadMLP_When_InsertEventWithInterestProduct_Then_CheckInterestProductInLead(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM = Mockup_Test.getFirstAccountFromName(Mockup_Test.userFirstNameRM, 'Id, RC_Code__c');
		User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		initialCustomSettingForLeadMLP();
		Lead lead = new Lead();
		System.runAs(rmUser){
	       lead.LastName = 'Test';
	       lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
	       insert lead;
	       lead.Customer__c = accountRM.Id;
	       update lead;
		}

		Test.startTest();
		System.runAs(rmUser){
			Event event = new Event();
			event.WhoId = lead.Id;
			event.Product_Interest__c = 'KEC;KPL;HL_ช่วยได้';
			event.StartDateTime = System.now();
			event.EndDateTime = System.now().addDays(7);
			event.Call_Result__c = 'C1 ติดต่อได้_สนใจสมัคร';
			event.Answer_LV2__c = 'C1.1 ส่งแมสเสนเจอร์';
			event.Description = 'Description';
			event.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get('Telesales');
			insert event;
		}
		Test.stopTest();
		Set<String> setInterestProductResult = new Set<String>{'KEC','KPL','HL_Equity'};
		String queryField = 'Id,Description,';
		for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
			queryField = queryField + eachMapping.Field_API_Name__c + ',';
		}
		queryField = queryField +' Name ';
		List<Lead> listLeadResult = (List<Lead>)Database.query('SELECT '+queryField +' FROM LEAD WHERE ID = \''+lead.Id+'\'');
		for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
			System.assertEquals(setInterestProductResult.contains(eachMapping.Name), listLeadResult[0].get(eachMapping.Field_API_Name__c));
		}

		System.assertEquals('Description',listLeadResult[0].Description);

	}

	@isTest static void Given_LeadMLP_When_InsertEventWithInterestProduct_Then_NotInterestProductInLead(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM = Mockup_Test.getFirstAccountFromName(Mockup_Test.userFirstNameRM, 'Id, RC_Code__c');
		User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		initialCustomSettingForLeadMLP();

		List<Telesales_Call_Results_Mapping__mdt> telesalesCallResultsList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Call_Result__c, Answer_LV2__c, Answer_LV3__c, Lead_Status__c, Update_First_Contacted_Date__c FROM Telesales_Call_Results_Mapping__mdt];
		Map<String,Telesales_Call_Results_Mapping__mdt> telesalesCallResultsByAnswerLV2Map = new Map<String,Telesales_Call_Results_Mapping__mdt>();
		for(Telesales_Call_Results_Mapping__mdt eachCallResultMapping : telesalesCallResultsList){
       		if(eachCallResultMapping.Answer_LV2__c !=null){
   				telesalesCallResultsByAnswerLV2Map.put(eachCallResultMapping.Answer_LV2__c,eachCallResultMapping);
   			}
	    }
	    String answerLv2Text;
	    String callResultText;
	    for(String keytext : telesalesCallResultsByAnswerLV2Map.keySet()){
	    	answerLv2Text = keytext;
	    	callResultText = telesalesCallResultsByAnswerLV2Map.get(keytext).Call_Result__c;
	    	continue;
	    }

		Lead lead = new Lead();
		System.runAs(rmUser){
	       lead.LastName = 'Test';
	       lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
	       insert lead;
	       lead.Customer__c = accountRM.Id;
	       update lead;
		}

		Test.startTest();
		System.runAs(rmUser){
			Event event = new Event();
			event.WhoId = lead.Id;
			event.StartDateTime = System.now();
			event.EndDateTime = System.now().addDays(7);
			event.Call_Result__c = callResultText;
			event.Answer_LV2__c = answerLv2Text;
			event.Description = 'Description';
			event.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get('Telesales');
			insert event;
		}
		Test.stopTest();
		Set<String> setInterestProductResult = new Set<String>{'KEC','KPL','HL_Equity'};
		List<Lead> listLeadResult = (List<Lead>)Database.query('SELECT Id,Answer_LV2__c,Call_Result__c,Description FROM LEAD WHERE ID = \''+lead.Id+'\'');
		System.assertEquals(answerLv2Text,listLeadResult[0].get('Answer_LV2__c'));
		System.assertEquals(callResultText,listLeadResult[0].get('Call_Result__c'));
		System.assertEquals('Description',listLeadResult[0].Description);

	}

	// [Start] Created by Worrapol A. for, testing to create relationship between the inserted contact and input contact.
	@isTest static void test_createCallReportWithPositiveRelatedContact() {
		//Create mocked data of Personal account, FinServ__ReciprocalRole__c, contacts, and job to test this class
		Account acctFirst = new Account (
			FirstName = 'Firstname',
			LastName = 'Lastname',
            Temporary_Customer__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		insert acctFirst;

		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c (
			Name = 'ผู้ติดต่อ',
			Role_Code__c = 'MGT',
			FinServ__InverseRole__c = 'ผู้ติดต่อ',
			Inverse_Role_Code__c = 'MGT',
			FinServ__RelationshipType__c = 'Contact Contact Reltion',
			FinServ__CreateInverseRole__c = false,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole')
		);
		insert reciprocalRole;

		List<Contact> listContact = new List<Contact>();
		Contact contPos1 = new Contact (
			FirstName = 'Positive',
			LastName = 'First',
			Phone_Numbers__c = '081111111',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		Contact contPos2 = new Contact (
			FirstName = 'Positive',
			LastName = 'Second',
			Phone_Numbers__c = '082222222',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		listContact.add(contPos1);
		listContact.add(contPos2);
		insert listContact;

		List<FinServ__ContactContactRelation__c> relateList = new List<FinServ__ContactContactRelation__c>();
		for(Integer i = 0; i < 2; i++){
			FinServ__ContactContactRelation__c relate = new FinServ__ContactContactRelation__c(
				FinServ__Contact__c = acctFirst.PersonContactId,
				FinServ__RelatedContact__c = listContact[i].Id,
				Finserv__Role__c = reciprocalRole.Id,
				Is_Createby_Integration__c = false
			);
			relateList.add(relate);
		}
		insert relateList;

		Opportunity eachOpp = new Opportunity(
			StageName = GlobalConstants.STATUS_OPEN,
			Name = '' + System.Today() + '_' + acctFirst.Name,
			CloseDate = System.Today().addDays(7),
			AccountId = acctFirst.Id
		);
		insert eachOpp;

		Test.startTest();
		Event eachEvent = new Event(
			Subject = 'Test_callReport_non_callPlan',
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Contact_Channel__c = 'Face to Face',
			WhatId = eachOpp.Id,
			WhoId = listContact[0].Id,
			Negotiation__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Report_without_Plan')
		);
		insert eachEvent;
		Test.stopTest();
	}

	@isTest static void test_updateCallPlanToCallReportWithPositiveRelatedContact() {
		//Create mocked data of Personal account, FinServ__ReciprocalRole__c, contacts, and job to test this class
		Account acctFirst = new Account (
			FirstName = 'Firstname',
			LastName = 'Lastname',
            Temporary_Customer__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		insert acctFirst;

		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c (
			Name = 'ผู้ติดต่อ',
			Role_Code__c = 'MGT',
			FinServ__InverseRole__c = 'ผู้ติดต่อ',
			Inverse_Role_Code__c = 'MGT',
			FinServ__RelationshipType__c = 'Contact Contact Reltion',
			FinServ__CreateInverseRole__c = false,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole')
		);
		insert reciprocalRole;

		List<Contact> listContact = new List<Contact>();
		Contact contPos1 = new Contact (
			FirstName = 'Positive',
			LastName = 'First',
			Phone_Numbers__c = '081111111',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		Contact contPos2 = new Contact (
			FirstName = 'Positive',
			LastName = 'Second',
			Phone_Numbers__c = '082222222',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		listContact.add(contPos1);
		listContact.add(contPos2);
		insert listContact;

		Opportunity eachOpp = new Opportunity(
			StageName = GlobalConstants.STATUS_OPEN,
			Name = '' + System.Today() + '_' + acctFirst.Name,
			CloseDate = System.Today().addDays(7),
			AccountId = acctFirst.Id
		);
		insert eachOpp;

		List<FinServ__ContactContactRelation__c> relateList = new List<FinServ__ContactContactRelation__c>();
		for(Integer i = 0; i < 2; i++){
			FinServ__ContactContactRelation__c relate = new FinServ__ContactContactRelation__c(
				FinServ__Contact__c = acctFirst.PersonContactId,
				FinServ__RelatedContact__c = listContact[i].Id,
				Finserv__Role__c = reciprocalRole.Id,
				Is_Createby_Integration__c = false
			);
			relateList.add(relate);
		}
		insert relateList;

		Test.startTest();
		Event eachEvent = new Event(
			Subject = 'Test_callPlan_to callReport',
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			WhatId = eachOpp.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Plan')
		);
		insert eachEvent;
		
		eachEvent.Contact_Channel__c = 'Face to Face';
		eachEvent.WhoId = listContact[0].Id;
		eachEvent.Negotiation__c = true;
		eachEvent.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Plan_Call_Report_Editable');
		update eachEvent;
		Test.stopTest();
	}

	@isTest static void test_createCallReportWithNegativeRelatedContact() {
		//Create mocked data of Personal account, FinServ__ReciprocalRole__c, contacts, and job to test this class
		List<Account> listAcct = new List<Account>();
		Account acctFirst = new Account (
			FirstName = 'First',
			LastName = 'Account',
            Temporary_Customer__c = true,
			Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		Account acctSecond = new Account (
			FirstName = 'Second',
			LastName = 'Account',
            Temporary_Customer__c = true,
			Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		listAcct.add(acctFirst);
		listAcct.add(acctSecond);
		insert listAcct;

		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c (
			Name = 'ผู้ติดต่อ',
			Role_Code__c = 'MGT',
			FinServ__InverseRole__c = 'ผู้ติดต่อ',
			Inverse_Role_Code__c = 'MGT',
			FinServ__RelationshipType__c = 'Contact Contact Reltion',
			FinServ__CreateInverseRole__c = false,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole')
		);
		insert reciprocalRole;

		List<Contact> listContact = new List<Contact>();
		Contact contPos1 = new Contact (
			FirstName = 'Negative',
			LastName = 'First',
			Phone_Numbers__c = '081111111',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		Contact contPos2 = new Contact (
			FirstName = 'Positive',
			LastName = 'Second',
			Phone_Numbers__c = '082222222',
			CIS__c = acctSecond.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		listContact.add(contPos1);
		listContact.add(contPos2);
		insert listContact;

		List<FinServ__ContactContactRelation__c> relateList = new List<FinServ__ContactContactRelation__c>();
		for(Integer i = 0; i < 2; i++){
			FinServ__ContactContactRelation__c relate = new FinServ__ContactContactRelation__c(
				FinServ__Contact__c = listAcct[i].PersonContactId,
				FinServ__RelatedContact__c = listContact[i].Id,
				Finserv__Role__c = reciprocalRole.Id,
				Is_Createby_Integration__c = false
			);
			relateList.add(relate);
		}
		insert relateList;

		Opportunity eachOpp = new Opportunity(
			StageName = GlobalConstants.STATUS_OPEN,
			Name = '' + System.Today() + '_' + acctFirst.Name,
			CloseDate = System.Today().addDays(7),
			AccountId = acctFirst.Id
		);
		insert eachOpp;

		Test.startTest();
		Event eachEvent = new Event(
			Subject = 'Test_callReport_non_callPlan',
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Contact_Channel__c = 'Face to Face',
			WhatId = eachOpp.Id,
			WhoId = listContact[0].Id,
			Negotiation__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Report_without_Plan')
		);
		try{
			insert eachEvent;
		}
		catch(Exception e) {
			String errorMsg = e.getMessage();
			System.AssertEquals(errorMsg.contains(Label.Event_Validate_Contact), true);
		}
		Test.stopTest();
	}

	@isTest static void test_updateCallPlanToCallReportWithNegativeRelatedContact() {
		//Create mocked data of Personal account, FinServ__ReciprocalRole__c, contacts, and job to test this class
		List<Account> listAcct = new List<Account>();
		Account acctFirst = new Account (
			FirstName = 'First',
			LastName = 'Account',
            Temporary_Customer__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		Account acctSecond = new Account (
			FirstName = 'Second',
			LastName = 'Account',
            Temporary_Customer__c = true,
			RecordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer')
		);
		listAcct.add(acctFirst);
		listAcct.add(acctSecond);
		insert listAcct;

		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c (
			Name = 'ผู้ติดต่อ',
			Role_Code__c = 'MGT',
			FinServ__InverseRole__c = 'ผู้ติดต่อ',
			Inverse_Role_Code__c = 'MGT',
			FinServ__RelationshipType__c = 'Contact Contact Reltion',
			FinServ__CreateInverseRole__c = false,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole')
		);
		insert reciprocalRole;


		List<Contact> listContact = new List<Contact>();
		Contact contPos1 = new Contact (
			FirstName = 'Negative',
			LastName = 'First',
			Phone_Numbers__c = '081111111',
			CIS__c = acctFirst.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		Contact contPos2 = new Contact (
			FirstName = 'Positive',
			LastName = 'Second',
			Phone_Numbers__c = '082222222',
			CIS__c = acctSecond.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')
		);
		listContact.add(contPos1);
		listContact.add(contPos2);
		insert listContact;

		List<FinServ__ContactContactRelation__c> relateList = new List<FinServ__ContactContactRelation__c>();
		for(Integer i = 0; i < 2; i++){
			FinServ__ContactContactRelation__c relate = new FinServ__ContactContactRelation__c(
				FinServ__Contact__c = listAcct[i].PersonContactId,
				FinServ__RelatedContact__c = listContact[i].Id,
				Finserv__Role__c = reciprocalRole.Id,
				Is_Createby_Integration__c = false
			);
			relateList.add(relate);
		}
		insert relateList;

		Opportunity eachOpp = new Opportunity(
			StageName = GlobalConstants.STATUS_OPEN,
			Name = '' + System.Today() + '_' + acctFirst.Name,
			CloseDate = System.Today().addDays(7),
			AccountId = acctFirst.Id
		);
		insert eachOpp;

		Test.startTest();
		Event eachEvent = new Event(
			Subject = 'Test_callPlan_to callReport',
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			WhatId = eachOpp.Id,
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Plan')
		);
		insert eachEvent;
		
		eachEvent.Contact_Channel__c = 'Face to Face';
		eachEvent.WhoId = listContact[0].Id;
		eachEvent.Negotiation__c = true;
		eachEvent.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Event', 'SME_Call_Plan_Call_Report_Editable');
		try{
			update eachEvent;
		}
		catch(Exception e) {
			String errorMsg = e.getMessage();
			System.AssertEquals(errorMsg.contains(Label.Event_Validate_Contact), true);
		}
		Test.stopTest();
	}
	// [End] Created by Worrapol A. for, testing to create relationship between the inserted contact and input contact.

	@isTest static void test_updateAllContactedPlan() {
		Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		insert accountRecord;
		Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
		insert opp;
		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = UserInfo.getUserId(),
			Status__c = GlobalConstants.CONTACTED,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Negotiation__c = True,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
		);
		insert newEvent;

		Test.startTest();
			update newEvent;
			Event changedEvent = [SELECT Id, RecordTypeId, Converted_Date__c FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVName));
			System.assertEquals(changedEvent.Converted_Date__c, System.TODAY());

			newEvent.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_PLAN_DEVNAME);

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId, Converted_Date__c FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVName));
			System.assertEquals(changedEvent.Converted_Date__c, System.TODAY());

			newEvent.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.RBS_CALL_PLAN_DEVNAME);

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId, Converted_Date__c FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVName));
			System.assertEquals(changedEvent.Converted_Date__c, System.TODAY());
		Test.stopTest();
	}

	@isTest static void test_updateAllCancelContactedPlan() {
		Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		insert accountRecord;
		Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
		insert opp;
		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = UserInfo.getUserId(),
			Status__c = GlobalConstants.APPROVED,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Negotiation__c = True,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
		);
		insert newEvent;

		Test.startTest();
			update newEvent;

			newEvent.StartDateTime = System.now().addDays(2);
	
			update newEvent;

			Event changedEvent = [SELECT Id, RecordTypeId, Status__c FROM Event WHERE Id = :newEvent.Id LIMIT 1];

			newEvent.Status__c = GlobalConstants.CANCELLED;

			update newEvent;

			update newEvent;

			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_READ_ONLY_DEVName));

			newEvent.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_PLAN_DEVNAME);

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_READ_ONLY_DEVName));

			newEvent.RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.RBS_CALL_PLAN_DEVNAME);

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(changedEvent.RecordTypeId, GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_READ_ONLY_DEVName));
		Test.stopTest();
	}

	@isTest static void test_updateRBSCallPlanToApprove() {
		Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		insert accountRecord;
		Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
		insert opp;
		User rmCBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
		User tlUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = rmCBSUser.Id,
			Status__c = GlobalConstants.PLAN,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Negotiation__c = True,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.RBS_CALL_PLAN_DEVNAME)
		);
		insert newEvent;

		Test.startTest();
		Event changedEvent;
		System.runAs(rmCBSUser){
			newEvent.Status__c = GlobalConstants.WAITING_FOR_APPROVAL;

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_FOR_APPROVE_DEVNAME), changedEvent.RecordTypeId);
		}
		System.runAs(tlUser){
			newEvent.Status__c = GlobalConstants.PLAN;

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_DEVNAME), changedEvent.RecordTypeId);

			newEvent.Status__c = GlobalConstants.APPROVED;

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_DEVNAME), changedEvent.RecordTypeId);

			newEvent.Status__c = GlobalConstants.REJECTED;

			update newEvent;
			changedEvent = [SELECT Id, RecordTypeId FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_READ_ONLY_DEVNAME), changedEvent.RecordTypeId);
		}
		Test.stopTest();
	}

	@isTest static void test_insertSecondaryCallReport() {
		Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		insert accountRecord;
		Opportunity opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
		insert opp;
		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = UserInfo.getUserId(),
			Status__c = GlobalConstants.CONTACTED,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Negotiation__c = True,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_SECONDARY_DEVNAME)
		);

		Test.startTest();
			insert newEvent;
			Event changedEvent = [SELECT Id, RecordTypeId, Converted_Date__c FROM Event WHERE Id = :newEvent.Id LIMIT 1];
			System.assertEquals(GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME), changedEvent.RecordTypeId);
			System.assertEquals(System.TODAY(), changedEvent.Converted_Date__c);
		Test.stopTest();
	}

	@isTest static void test_createCallReportWithNegativeUser() {
		Profile rmProfile = Mockup_Test.getMapProfileByName(GlobalConstants.SME_RM);
		String devName = 'RCRM' + Mockup_Test.RC_CODE;
		UserRole rmRole = [SELECT Id FROM UserRole WHERE DeveloperName = :devName LIMIT 1];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User tmUser = [SELECT Id FROM User WHERE FirstName = :Mockup_Test.userFirstNameTM LIMIT 1];
		User rmUser2 = Mockup_Test.newUser(
			'FirstNameRM2',
			'LastNameRM2',
			true,
			'FirstNameRM2'+'@mail.com',
			'FirstNameRM2'+'@mail.com',
			'FirstNameRM2'.substring(0, 4),
			rmProfile.Id,
			null,
			tmUser.Id,
			Mockup_Test.userEmpIdRM2
		);
		Account accountRecord;
		Opportunity opp;

		System.runAs(rmUser){
			accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			insert accountRecord;
			opp = Mockup_Test.newOpportunity(accountRecord.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert opp;
		}
		try{
			System.runAs(rmUser2){
				Event newEvent = new Event(
					WhatId = opp.Id,
					OwnerId = UserInfo.getUserId(),
					Status__c = GlobalConstants.PLAN,
					StartDateTime = System.now(),
					EndDateTime = System.now().addDays(7),
					RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
				);
				insert newEvent;
			}
		}
		catch(Exception e){
			System.assert(e.getMessage().contains(Label.SMERBS_NotAllowCreateJobOnOthersEvent));
		}
		
	}
}