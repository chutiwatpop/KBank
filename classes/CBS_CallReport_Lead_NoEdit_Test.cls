@isTest
private class CBS_CallReport_Lead_NoEdit_Test {

	public static String accName = 'testAccount';
	public static String accName2 = 'testAccount2';
	
	@testSetup static void testSetup(){
		Test.startTest();
		User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

		Mockup_Test mt = new Mockup_Test();
		System.runAs(user){
			mt.setUpTest();
		}

		
		

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = new Account(
			Name = accName,
			CIS__c = '22222',
			Primary_Segment_Code__c = 'CB',
			Port_Pool__c = GlobalConstants.PORT,
			Birthdate_Registration_Date__c = System.today().addYears(-10),
			Identification_No_Prospect__c = '222222222222222');

			insert account;
		}

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName];
			Campaign cm = new Campaign();
			cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
			cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
			cm.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_EDC;
			cm.Name = 'TestCampaign';
			cm.IsActive = true;
			cm.Status = 'Active';
			cm.StartDate = System.Today() - 1;
			cm.EndDate = System.Today() + 1;
			cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('CBS - Lead');
			insert cm;

			Target_List__c tl = new Target_List__c();
			tl.CIS_ID_Prospect_Name__c = account.Id;
			tl.Lead_Campaign__c = cm.Id;
			tl.Status__c = GlobalConstants.STATUS_NEW;
			insert tl;
		}

			

		Test.stopTest();
	}

	@isTest static void testController() {
		Test.startTest();

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName];
			Campaign cm2 = new Campaign();
			cm2.Lead_Campaign_Event_Code__c = 'TestCampaign2';
			cm2.Type__c = GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER;
			cm2.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_EDC;
			cm2.Name = 'TestCampaign2';
			cm2.IsActive = true;
			cm2.Status = 'Active';
			cm2.StartDate = System.Today() - 1;
			cm2.EndDate = System.Today() + 1;
			cm2.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('CBS - Lead');
			insert cm2;

			

			Target_List__c tl2 = new Target_List__c();
			tl2.CIS_ID_Prospect_Name__c = account.Id;
			tl2.Lead_Campaign__c = cm2.Id;
			tl2.Status__c = GlobalConstants.STATUS_NEW;
			insert tl2;
		}

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName];
			Call_Report__c callreportObj;
			callreportObj = new Call_Report__c(
				RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
				CIS_ID__c = account.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today()
			);

			insert callreportObj;
		} 

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName];
			Call_Report__c callReport = [SELECT Id FROM Call_Report__c WHERE CIS_ID__C =: account.Id];

			Test.setCurrentPageReference(new PageReference('Page.CBS_CallReport_Lead_NoEdit_Controller'));
			System.currentPageReference().getParameters().put('Id', callReport.id);

			ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
			CBS_CallReport_Lead_NoEdit_Controller callReportOppt = new CBS_CallReport_Lead_NoEdit_Controller(stdController);
		}
		Test.stopTest();
	}

	@isTest static void testControllerNoLeads() {
		Test.startTest();

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
		
			Account account = new Account(
			Name = accName2,
			CIS__c = '22223',
			Primary_Segment_Code__c = 'CB',
			Port_Pool__c = GlobalConstants.PORT,
			Birthdate_Registration_Date__c = System.today().addYears(-10),
			Identification_No_Prospect__c = '222222222322222');

			insert account;
			

			Call_Report__c callreportObj;
			callreportObj = new Call_Report__c(
				RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
				CIS_ID__c = account.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today()
			);

			insert callreportObj;
		} 
		
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName2];
			Call_Report__c callReport = [SELECT Id FROM Call_Report__c WHERE CIS_ID__C =: account.Id];

			Test.setCurrentPageReference(new PageReference('Page.CBS_CallReport_Lead_NoEdit_Controller'));
			System.currentPageReference().getParameters().put('Id', callReport.id);

			ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
			CBS_CallReport_Lead_NoEdit_Controller callReportOppt = new CBS_CallReport_Lead_NoEdit_Controller(stdController);
		}
		Test.stopTest();
	}
}