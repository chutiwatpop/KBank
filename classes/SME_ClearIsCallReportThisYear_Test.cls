@isTest
private class SME_ClearIsCallReportThisYear_Test {

	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';


    @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        
        Test.stopTest();
        
    }
	
	@isTest static void testIsCallReportThisYear() {

		Account account = [SELECT Id FROM Account WHERE Name =: accountNameRM];

		Date lastYearVisitDate = Date.newInstance(System.today().year()-1, System.today().month(), System.today().day());
		Date thisYearVisitDate = System.today();

        List<Call_Report__c> callreportList = new List<Call_Report__c>();
        Call_Report__c callReport = new Call_Report__c();
        Call_Report__c callReport2 = new Call_Report__c();
        Call_Report__c callReport3 = new Call_Report__c();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){


		callReport = new Call_Report__c();
		callReport.Actual_Visit_Date__c = lastYearVisitDate;
        callReport.Plan_Amount__c = 6000;
        callReport.Is_Call_Report_This_Year__c = true;
        callReport.CIS_ID__c = account.Id;
        callReport.Offer_Credit_Product__c = true;
        callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
        callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
        callReport.Expected_Credit_Amount__c = 5000;
        callReport.Contact_Firstname__c = 'abc';
        callReport.Contact_Lastname__c = 'def';
        callReport.Contact_Phone__c = '123456789';

        callReport2 = new Call_Report__c();
		callReport2.Actual_Visit_Date__c = thisYearVisitDate;
        callReport2.Is_Call_Report_This_Year__c = true;
        callReport2.Plan_Amount__c = 6000;
        callReport2.CIS_ID__c = account.Id;
        callReport2.Offer_Credit_Product__c = true;
        callReport2.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
        callReport2.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
        callReport2.Expected_Credit_Amount__c = 5000;
        callReport2.Contact_Firstname__c = 'abc';
        callReport2.Contact_Lastname__c = 'def';
        callReport2.Contact_Phone__c = '123456789';

        callReport3 = new Call_Report__c();
        callReport3.Actual_Visit_Date__c = null;
        callReport3.Is_Call_Report_This_Year__c = true;
        callReport3.Plan_Amount__c = 6000;
        callReport3.CIS_ID__c = account.Id;
        callReport3.Offer_Credit_Product__c = true;
        callReport3.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
        callReport3.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
        callReport3.Expected_Credit_Amount__c = 5000;
        callReport3.Contact_Firstname__c = 'abc';
        callReport3.Contact_Lastname__c = 'def';
        callReport3.Contact_Phone__c = '123456789';

        callreportList.add(callReport);
        callreportList.add(callReport2);
        callreportList.add(callReport3);

            insert callreportList;
        }

        

        callReport = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport.Id];
        System.assertEquals(true, callReport.Is_Call_Report_This_Year__c);

        callReport2 = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport2.Id];
        System.assertEquals(true, callReport2.Is_Call_Report_This_Year__c);

        callReport3 = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport3.Id];
        System.assertEquals(true, callReport3.Is_Call_Report_This_Year__c);

        Test.startTest();
            Database.executeBatch(new SME_ClearIsCallReportThisYear_Batch());
		Test.stopTest();

		callReport = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport.Id];
        System.assertEquals(false, callReport.Is_Call_Report_This_Year__c);

        callReport2 = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport2.Id];
        System.assertEquals(true, callReport2.Is_Call_Report_This_Year__c);

        callReport3 = [SELECT Id, Actual_Visit_Date__c, Is_Call_Report_This_Year__c FROM Call_Report__c WHERE Id =: callReport3.Id];
        System.assertEquals(true, callReport3.Is_Call_Report_This_Year__c);
		
	}
	
	
	
}