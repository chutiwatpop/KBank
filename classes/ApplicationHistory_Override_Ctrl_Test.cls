@isTest
private class ApplicationHistory_Override_Ctrl_Test {
    private static String accountNameRMSME = 'accountNameRMSME';
    private static String accountNameRMCBS = 'accountNameRMCBS';

    @testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMSME,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            mt.newAccount(accountNameRMCBS,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        List<ApplicationHistoryField__c> appHisCustomSettingList = new List<ApplicationHistoryField__c>();

        ApplicationHistoryField__c customsettingSME = new ApplicationHistoryField__c();
        customsettingSME.Credit_Model_Id__c = 'Credit_Model_Id__c';
        customsettingSME.OpportunityLookBackId__c = 'OpportunityLookBackId__c';
        customsettingSME.OpportunityLookBackNameId__c = 'OpportunityLookBackNameId__c';
        customsettingSME.Submit_Issue_Field__c = 'Submit_Issue_Field';
        customsettingSME.Name = 'ApplicationHistorySMEField';
        appHisCustomSettingList.add(customsettingSME);

        ApplicationHistoryField__c customsettingCBS = new ApplicationHistoryField__c();
        customsettingCBS.OppAmountId__c = 'OppAmountId__c';
        customsettingCBS.OpportunityLookBackId__c = 'OpportunityLookBackId__c';
        customsettingCBS.OpportunityLookBackNameId__c = 'OpportunityLookBackNameId__c';
        customsettingCBS.Submit_Issue_Field__c = 'Submit_Issue_Field';
        customsettingCBS.Name = 'ApplicationHistoryCBSField';
        appHisCustomSettingList.add(customsettingCBS);
        insert appHisCustomSettingList;
    }

    @isTest static void testSMEClickNewApplicationHistoryFromOpportunityRecordTypeCreditThenRedirectToAppHisPageCreditRecordType() {
        Id recordTypeCreditOpp = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity','Credit_Opportunity');
        Id recordTypeCreditAppHistory = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Credit_Application_History');
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :accountNameRMSME LIMIT 1];
        User userRM = [SELECT Id,Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        PageReference pageRef;
        Opportunity oppCredit;
        Test.startTest();
            System.runAs(userRM){
                oppCredit = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
                oppCredit.RecordTypeId = recordTypeCreditOpp;
                oppCredit.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
                insert oppCredit;

                Application_History__c applicationHis = Mockup_Test.newApplicationHistory(oppCredit.Id,'appNo','DLA',null,'Non CMAS',System.today() + 1, 1000);
                insert applicationHis;

                ApexPages.StandardController stdController = new ApexPages.StandardController(applicationHis);
                ApplicationHistory_Override_Controller appHisController = new ApplicationHistory_Override_Controller(stdController);
                pageRef = appHisController.redirect();
            }
        Test.stopTest();

        System.assertEquals(pageRef.getParameters().get('OpportunityLookBackId__c'),oppCredit.Id);
        System.assertEquals(pageRef.getParameters().get('OpportunityLookBackNameId__c'),oppCredit.Name);
        System.assertEquals(pageRef.getParameters().get('Credit_Model_Id__c'),oppCredit.Credit_Model__c);
        System.assertEquals(pageRef.getParameters().get('RecordType'),String.valueOf(recordTypeCreditAppHistory));
    }

    @isTest static void testCBSClickNewApplicationHistoryFromOpportunityRecordTypeCreditThenRedirectToAppHisPageCreditRecordType() {
        Id recordTypeCreditOpp = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity','Credit_Opportunity');
        Id recordTypeCreditAppHistory = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Credit_Application_History');
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :accountNameRMCBS LIMIT 1];
        User userRM = [SELECT Id,Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];

        PageReference pageRef;
        Opportunity oppCredit;
        Test.startTest();
            System.runAs(userRM){
                oppCredit = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
                oppCredit.Amount = 100.00;
                oppCredit.RecordTypeId = recordTypeCreditOpp;
                oppCredit.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
                insert oppCredit;

                Application_History__c applicationHis = Mockup_Test.newApplicationHistory(oppCredit.Id,'appNo','DLA',null,'Non CMAS',System.today() + 1, 1000);
                insert applicationHis;

                ApexPages.StandardController stdController = new ApexPages.StandardController(applicationHis);
                ApplicationHistory_Override_Controller appHisController = new ApplicationHistory_Override_Controller(stdController);
                pageRef = appHisController.redirect();
            }
        Test.stopTest();

        System.assertEquals(pageRef.getParameters().get('OpportunityLookBackId__c'),oppCredit.Id);
        System.assertEquals(pageRef.getParameters().get('OpportunityLookBackNameId__c'),oppCredit.Name);
        System.assertEquals(pageRef.getParameters().get('OppAmountId__c'),String.valueOf(oppCredit.Amount));
        System.assertEquals(pageRef.getParameters().get('RecordType'),String.valueOf(recordTypeCreditAppHistory));
    }

}