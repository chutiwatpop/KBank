@isTest
private class SetupAll_Controller_Test {
    //public static String accountNameTM = 'tmCreatedAccountName';
    //@testSetup static void setupAccount(){
    //    Mockup_Test mt = new Mockup_Test().setUpTest();
    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
    //        mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }
    //}    

    //static testMethod void assertTarget(){
    //    Integer expectedSetupAmount = 100;
    //    Date expectedDate = System.today()-2;
    //    String expectedStatus = 'Setup';

    //    User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
    //    //Account targetAccount = [SELECT Id FROM Account WHERE Name = :SetupAll_Controller_Test.accountNameTM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(SetupAll_Controller_Test.accountNameTM, 'Id');
    //    Opportunity targetOp = new Opportunity();
    //    Opportunity_Product__c targetOpProduct = new Opportunity_Product__c();
    //    Setup_History__c targetSetupHis = new Setup_History__c();
    //    System.runAs(userTM){

    //        targetOp.AccountId = targetAccount.Id;
    //        targetOp.Name = 'TestOp';
    //        targetOp.StageName = 'Waiting for Credit Approval';
    //        targetOp.CloseDate = System.Today() + 1;
    //        targetOp.Submission_Channel__c   = GlobalConstants.CMAS;
    //        targetOp.Credit_Model__c = 'DLA';
    //        targetOp.Submit_Issue__c = 'New Credit';
    //        targetOp.Amount      = 10;
    //        targetOp.CloseDate   = System.today() + 1;
    //        targetOp.Tentative_Application_Submit_Date__c = System.today() + 7;
    //        targetOp.Approval_Status__c = 'Final Approve';
    //        insert targetOp;

    //        Application_History__c appHis = new Application_History__c(
    //            OppName__c = targetOp.Id,
    //            RMCreditModel__c = 'DLA',
    //            RMSubmitChannel__c = 'Non CMAS',
    //            TentativeSubmitDate__c = System.today() + 1
    //        );
    //        insert appHis;

    //        targetOpProduct.Product__c='ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        targetOpProduct.Status__c='Setup';
    //        targetOpProduct.Opportunity__c=targetOp.Id;
    //        targetOpProduct.Setup_Amount__c=1000000;
    //        targetOpProduct.Approved_Amount__c = 1000000;
    //        targetOpProduct.Setup_Date__c=system.today();
    //        targetOpProduct.Front_End_Fee__c=50000;
    //        targetOpProduct.BA_Prosaving__c=50000;
    //        targetOpProduct.BA_Protection__c=50000;
    //        insert targetOpProduct;

    //        targetOp.StageName = 'Waiting for Credit Approval';
    //        targetOp.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update targetOp;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');

    //        targetSetupHis.Opportunity__c = targetOp.Id;
    //        targetSetupHis.Front_End_Fee__c = 0;
    //        targetSetupHis.BA_Prosaving__c = 0;
    //        targetSetupHis.BA_Protection__c = 0;
    //        targetSetupHis.Setup_Amount__c = 10;
    //        targetSetupHis.Setup_Date__c = System.today();
    //        targetSetupHis.For_Refinance_In__c = 'KTB-ธ.กรุงไทย';
    //        insert targetSetupHis;
    //    }

    //    System.runAs(userTM){
    //        Test.startTest();
    //        ApexPages.currentPage().getParameters().put('opid',targetOp.Id);

    //        SetupAll_Controller sc = new SetupAll_Controller();
    //        sc = new SetupAll_Controller(new ApexPages.StandardController(targetSetupHis));

    //        sc.setupall.Setup_Date__c = expectedDate;
    //        sc.setupall.Setup_Amount__c = expectedSetupAmount;
    //        sc.setupall.Status__c = expectedStatus;

    //        sc.savingSetupall();

    //        Setup_History__c resultOpProduct = [SELECT Id,Setup_Date__c,Setup_Amount__c,Status__c FROM Setup_History__c WHERE Opportunity__c = :targetOp.Id LIMIT 1];

    //        System.assertEquals(expectedDate,resultOpProduct.Setup_Date__c);
    //        System.assertEquals(expectedSetupAmount,resultOpProduct.Setup_Amount__c);
    //        System.assertEquals(expectedStatus,resultOpProduct.Status__c);
    //        Test.stopTest();
    //    }
    //}
}