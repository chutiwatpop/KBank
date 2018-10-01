/**
* @author komsan.wi@beryl8.com
* @30/09/2015 created new
*/
@isTest
private class CallReportOpportunity_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	static testMethod void defaultLeadToOpportunity(){
		Account targetAccount = [SELECT Id,CIS__c FROM Account WHERE Name = :CallReportOpportunity_Test.accountNameTM LIMIT 1];
		User tmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		Campaign mockCampaign;
		Target_List__c eachTargetList;
		Contact mockContact;

		System.runAs(new User(Id=UserInfo.getUserId())){
			mockCampaign = new Campaign();
			mockCampaign.Lead_Campaign_Event_Code__c = 'Lead1';
			mockCampaign.Type__c = GlobalConstants.LEAD_FOR_SALES;
			mockCampaign.Name = 'Lead1';
			mockCampaign.Status = GlobalConstants.ACTIVE;
			mockCampaign.StartDate = System.today() - 1;
			mockCampaign.EndDate = System.Today() + 1;
			mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Campaign', GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME);
			insert mockCampaign;

			eachTargetList = new Target_List__c();
			eachTargetList.CIS_ID_Prospect_Name__c = targetAccount.Id;
			eachTargetList.Lead_Campaign__c = mockCampaign.Id;
			eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
			insert eachTargetList;

			mockContact = new Contact(
        	LastName = 'lastname',
			Contact_Firstname__c = 'Firstname',
			AccountId = targetAccount.Id,
			Phone_Number__c = '023456789'
        	);
			insert mockContact;
		}
		System.runAs(tmUser){
			tmUser.Segment__c = GlobalConstants.SEGMENT_ME;
			TriggerHandler.bypass('UserTriggerHandler');
            update tmUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
        Call_Report__c mockCallReport;
        Test.startTest();
        	System.runAs(tmUser){
				Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c=GlobalConstants.SEGMENT_ME,External_ID__c='123456:'+GlobalConstants.SEGMENT_ME);
		        insert buCodeTest;

				Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c(Name=Customer_BusinessCode_Service.getDefaultValue(),CIS__c=targetAccount.id,Business_Code__c=buCodeTest.id,External__c=targetAccount.CIS__c+':'+buCodeTest.External_ID__c,Account_Owner_Segment__c=GlobalConstants.SEGMENT_ME);
	            insert customerBusinessCode;
        		mockCallReport = new Call_Report__c(
			        CIS_ID__c = targetAccount.Id,
			        Status__c = GlobalConstants.CONTACTED,
			        Actual_Visit_Date__c = Date.today()-1,
			        Contact_Channel__c = 'Phone Call',
			        Contact__c = mockContact.Id,
			        Offer_Credit_Product__c = true,
			        Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
			        Expected_Credit_Amount__c = 500000,
			        RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
			        Customer_Business_Code__c = customerBusinessCode.id,
                	Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
		        );

				insert mockCallReport;
			}
        System.debug('mockCallReport '+mockCallReport.Id);	

        Test.stopTest();
        List<Call_Report_Lead__c> callreportLeadList = new List<Call_Report_Lead__c>();
    	callreportLeadList = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.CIS_ID_Prospect_Name__c, Target_List__r.Lead_Type__c, Target_List__r.Lead_Campaign__c FROM Call_Report_Lead__c WHERE Target_List__r.Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES AND Call_Plan_Call_Report__c = :mockCallReport.Id];
    	System.assertEquals(1, callreportLeadList.size());

        Call_Report_Opportunity__c callReportOpp = [SELECT Id, Opportunity_Name__c, Call_Plan_Call_Report__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c = :mockCallReport.Id LIMIT 1];
        System.debug('callReportOpp : '+callReportOpp);
  		Opportunity_Lead__c oppLead = [SELECT Target_List__c, Target_List__r.Status__c, Opportunity_Lead_Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :callReportOpp.Opportunity_Name__c LIMIT 1];
  		System.debug('oppLead : '+oppLead);
		System.assertEquals(GlobalConstants.STOCK_NEGOTIATION, oppLead.Opportunity_Lead_Status__c);
	}
}