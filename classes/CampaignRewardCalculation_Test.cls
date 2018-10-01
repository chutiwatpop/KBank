/*
 * Created by: chumphon.k@kbtg.tech
 * Created date: 21-Mar-2016
 * Description: CR-006 Auto assign targer list and calculate campaign reward
 * @30/06/2016 Chumphon K., ISCR030 Change condition for NewBooking Campaign
 * @08/09/2016 Chumphon K., ISCR035 Change reward for Thankyou Campaign
 * @18/01/2017 Chumphon K., ISCR055 Campaign Thankyou Change Condition
 * remove campaign thankyou
*/
@isTest
private class CampaignRewardCalculation_Test {
    //public static String strNewBooking='NEWBOOKING';
    //public static String accountNameTM = 'tmCreatedAccountName';
    //public static String accountNameRM = 'rmCreatedAccountName';

    //@testSetup static void setUpTest(){
    //    SME_GroupChatterService.isByPassGroupChatterService = true;
    //    setupCampaign();
    //    setupUser();
    //}

    //public static void setupUser(){
    //    Test.startTest();
    //    Mockup_Test mt;
    //    System.runAs(new User(Id=UserInfo.getUserId())){
    //        mt = new Mockup_Test().setUpTestWithRCCode();
    //        Mockup_Test.setupANTeam();
    //    }

    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
    //        mt.newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }
    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
    //        mt.newAccount(accountNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }
    //    Test.stopTest();
    //}
    
    //public static void setupCampaign(){
    //        Campaign_Setting__c cSetting = new Campaign_Setting__c();
    //        cSetting.NewBooking_Code__c = strNewBooking;
    //        cSetting.Register_Period__c = 30;
    //        cSetting.New_Booking_Condition_SE__c = '';
    //        cSetting.New_Booking_Condition_ME__c = '1 AND (2 AND 3)';
    //        insert cSetting;

    //        List<Campaign> campaignList = new List<Campaign>();
    //        Campaign CampaignNewBooking = new Campaign();
    //        CampaignNewBooking.Name=strNewBooking;
    //        CampaignNewBooking.Type__c=GlobalConstants.CAMPAIGN;
    //        CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
    //        CampaignNewBooking.StartDate=system.today();
    //        CampaignNewBooking.Status=GlobalConstants.ACTIVE;
    //        CampaignNewBooking.IsActive=true;
    //        CampaignNewBooking.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
    //        campaignList.add(CampaignNewBooking);

    //        insert campaignList;

    //        List<Campaign_Expression__c> campaignExpressionList = new List<Campaign_Expression__c>();

    //        Campaign_Expression__c me1 = new Campaign_Expression__c();
    //        me1.Name = 'ME_1';
    //        me1.Object__c = 'Opportunity__c';
    //        me1.Field__c = 'Type';
    //        me1.Operator__c = '=';
    //        me1.Value__c = 'Credit';
    //        me1.Field_Type__c = 'Text';

    //        Campaign_Expression__c me2 = new Campaign_Expression__c();
    //        me2.Name = 'ME_2';
    //        me2.Object__c = 'Opportunity__c';
    //        me2.Field__c = 'Approved_Amount__c';
    //        me2.Operator__c = '>=';
    //        me2.Value__c = '500000';
    //        me2.Field_Type__c = 'Currency';

    //        Campaign_Expression__c me3 = new Campaign_Expression__c();
    //        me3.Name = 'ME_3';
    //        me3.Object__c = 'Opportunity__c';
    //        me3.Field__c = 'StageName';
    //        me3.Operator__c = '=';
    //        me3.Value__c = 'All Loan Setup';
    //        me3.Field_Type__c = 'Text';
    //        campaignExpressionList.add(me1);
    //        campaignExpressionList.add(me2);
    //        campaignExpressionList.add(me3);

    //        insert campaignExpressionList;
    //}

    //@isTest static void testGetConditionQueryString(){
    //    String formulaCondition = '1 AND (2 AND 3)';
    //    String expectedQueryString = 'Type=\'Credit\' AND (Approved_Amount__c>=500000 AND StageName=\'All Loan Setup\')';
    //    List<Campaign_Expression__c> campaignExpressionList = new List<Campaign_Expression__c>();

    //    Campaign_Expression__c me1 = new Campaign_Expression__c();
    //    me1.Name = 'ME_1';
    //    me1.Object__c = 'Opportunity__c';
    //    me1.Field__c = 'Type';
    //    me1.Operator__c = '=';
    //    me1.Value__c = 'Credit';
    //    me1.Field_Type__c = 'Text';

    //    Campaign_Expression__c me2 = new Campaign_Expression__c();
    //    me2.Name = 'ME_2';
    //    me2.Object__c = 'Opportunity__c';
    //    me2.Field__c = 'Approved_Amount__c';
    //    me2.Operator__c = '>=';
    //    me2.Value__c = '500000';
    //    me2.Field_Type__c = 'Currency';

    //    Campaign_Expression__c me3 = new Campaign_Expression__c();
    //    me3.Name = 'ME_3';
    //    me3.Object__c = 'Opportunity__c';
    //    me3.Field__c = 'StageName';
    //    me3.Operator__c = '=';
    //    me3.Value__c = 'All Loan Setup';
    //    me3.Field_Type__c = 'Text';

    //    campaignExpressionList.add(me1);
    //    campaignExpressionList.add(me2);
    //    campaignExpressionList.add(me3);

    //    Test.startTest();
    //        String queryString = CampaignRewardCalculation.getConditionQueryString(formulaCondition, campaignExpressionList, 'ME');
    //    Test.stopTest();
    //    System.assertEquals(expectedQueryString, queryString);
    //}

    //static testMethod void testOwnerSECloseWonNoConfigCondition(){
    //    Business_Code__c buCode;
    //    User userRM;
    //    System.runAs(new User(Id=UserInfo.getUserId())){
    //        userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //        userRM.Segment__c = 'SE';
    //        update userRM;

    //        buCode = new Business_Code__c(Name = '111111',Segment__c = 'SE',External_ID__c='111111:ME');
    //        insert buCode;
    //    }

    //    //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id,RC_Code__c');
    //    Opportunity targetOpp;
    //    System.runAs(userRM){
    //        targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        targetOpp.Business_Code__c = buCode.Id;
    //        insert targetOpp;

    //        Application_History__c newAppHis = new Application_History__c();
    //        newAppHis.OppName__c = targetOpp.Id;
    //        newAppHis.AppNum_NonCMAS__c = '23456';
    //        newAppHis.Index__c = 1;
    //        newAppHis.RMActualRequestedAmt__c = 10000;
    //        newAppHis.RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
    //        newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
    //        newAppHis.TentativeSubmitDate__c = System.today();
    //        insert newAppHis;

    //        Opportunity_Product__c newOppProduct = new Opportunity_Product__c();
    //        newOppProduct.Opportunity__c = targetOpp.Id;
    //        newOppProduct.Product_Name__c = 'test opp product';
    //        newOppProduct.Requested_Amount__c = 100000;
    //        newOppProduct.Approved_Amount__c = 100000;
    //        insert newOppProduct;

    //        targetOpp.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update targetOpp;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');
            
    //        Setup_History__c oppProduct = new Setup_History__c();
    //        oppProduct.Opportunity__c = targetOpp.Id;
    //        oppProduct.Status__c = 'Setup';
    //        oppProduct.Front_End_Fee__c = 0;
    //        oppProduct.BA_Prosaving__c = 100000.0;
    //        oppProduct.BA_Protection__c = 100000.0;
    //        oppProduct.Setup_Amount__c = 100000;
    //        oppProduct.Product__c = 'ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        oppProduct.Setup_Date__c = System.today();
    //        oppProduct.For_Refinance_In__c = 'KTB-ธ.กรุงไทย';
    //        insert oppProduct;

    //        Test.startTest();
    //        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Id = :targetOpp.Id];
    //        oppObj.IsCloseWon__c = true;
    //        oppObj.StageName = GlobalConstants.ALL_LOAN_SETUP;
    //        Account_Service.triggerInitialCall = false;
    //        update oppObj;
    //        Test.stopTest();
    //    }

    //    Target_List__c targetResult = [SELECT Id FROM Target_List__c WHERE Opportunity__c = :targetOpp.Id];
    //    System.assertEquals(1,[SELECT Count() FROM Target_List__c]);
    //}

    //static testMethod void testOwnerMECloseWonWithConfigConditionCreateTGL(){
    //    Business_Code__c buCode;
    //    User userRM;
    //    System.runAs(new User(Id=UserInfo.getUserId())){
    //        userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //        userRM.Segment__c = 'ME';
    //        update userRM;

    //        buCode = new Business_Code__c(Name = '111111',Segment__c = 'ME',External_ID__c='111111:ME');
    //        insert buCode;
    //    }

    //    //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id,RC_Code__c');
    //    Opportunity targetOpp;
    //    System.runAs(userRM){
    //        targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        targetOpp.Type = 'Credit';
    //        targetOpp.Business_Code__c = buCode.Id;
    //        insert targetOpp;

    //        Application_History__c newAppHis = new Application_History__c();
    //        newAppHis.OppName__c = targetOpp.Id;
    //        newAppHis.AppNum_NonCMAS__c = '23456';
    //        newAppHis.Index__c = 1;
    //        newAppHis.RMActualRequestedAmt__c = 10000;
    //        newAppHis.RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
    //        newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
    //        newAppHis.TentativeSubmitDate__c = System.today();
    //        insert newAppHis;

    //        Opportunity_Product__c newOppProduct = new Opportunity_Product__c();
    //        newOppProduct.Opportunity__c = targetOpp.Id;
    //        newOppProduct.Product_Name__c = 'test opp product';
    //        newOppProduct.Requested_Amount__c = 700000;
    //        newOppProduct.Approved_Amount__c = 700000;
    //        insert newOppProduct;

    //        targetOpp.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update targetOpp;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');
            
    //        Setup_History__c oppProduct = new Setup_History__c();
    //        oppProduct.Opportunity__c = targetOpp.Id;
    //        oppProduct.Status__c = 'Setup';
    //        oppProduct.Front_End_Fee__c = 0;
    //        oppProduct.BA_Prosaving__c = 800000.0;
    //        oppProduct.BA_Protection__c = 800000.0;
    //        oppProduct.Setup_Amount__c = 500000;
    //        oppProduct.Product__c = 'ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        oppProduct.Setup_Date__c = System.today();
    //        oppProduct.For_Refinance_In__c = 'KTB-ธ.กรุงไทย';
    //        insert oppProduct;

    //        Test.startTest();
    //        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Id = :targetOpp.Id];
    //        oppObj.IsCloseWon__c = true;
    //        oppObj.StageName = GlobalConstants.ALL_LOAN_SETUP;
    //        Account_Service.triggerInitialCall = false;
    //        update oppObj;
    //        Test.stopTest();
    //    }

    //    Opportunity oppResult = [SELECT Id, Approved_Amount__c, Type FROM Opportunity WHERE Id = :targetOpp.Id];
    //    System.assertEquals(700000,oppResult.Approved_Amount__c);
    //    System.assertEquals('Credit',oppResult.Type);

    //    Target_List__c targetResult = [SELECT Id FROM Target_List__c WHERE Opportunity__c = :targetOpp.Id];
    //    System.assertEquals(1,[SELECT Count() FROM Target_List__c]);
    //}

    //static testMethod void testOwnerMECloseWonWithConfigConditionNotCreateTGL(){
    //    Business_Code__c buCode;
    //    User userRM;
    //    System.runAs(new User(Id=UserInfo.getUserId())){
    //        userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //        userRM.Segment__c = 'ME';
    //        update userRM;

    //        buCode = new Business_Code__c(Name = '111111',Segment__c = 'ME',External_ID__c='111111:ME');
    //        insert buCode;
    //    }

    //    //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id,RC_Code__c');
    //    Opportunity targetOpp;
    //    System.runAs(userRM){
    //        targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        targetOpp.Business_Code__c = buCode.Id;
    //        insert targetOpp;

    //        Application_History__c newAppHis = new Application_History__c();
    //        newAppHis.OppName__c = targetOpp.Id;
    //        newAppHis.AppNum_NonCMAS__c = '23456';
    //        newAppHis.Index__c = 1;
    //        newAppHis.RMActualRequestedAmt__c = 10000;
    //        newAppHis.RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
    //        newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
    //        newAppHis.TentativeSubmitDate__c = System.today();
    //        insert newAppHis;

    //        Opportunity_Product__c newOppProduct = new Opportunity_Product__c();
    //        newOppProduct.Opportunity__c = targetOpp.Id;
    //        newOppProduct.Product_Name__c = 'test opp product';
    //        newOppProduct.Requested_Amount__c = 100000;
    //        newOppProduct.Approved_Amount__c = 100000;
    //        insert newOppProduct;

    //        targetOpp.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        targetOpp.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update targetOpp;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');
            
    //        Setup_History__c oppProduct = new Setup_History__c();
    //        oppProduct.Opportunity__c = targetOpp.Id;
    //        oppProduct.Status__c = 'Setup';
    //        oppProduct.Front_End_Fee__c = 0;
    //        oppProduct.BA_Prosaving__c = 100000.0;
    //        oppProduct.BA_Protection__c = 100000.0;
    //        oppProduct.Setup_Amount__c = 100000;
    //        oppProduct.Product__c = 'ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        oppProduct.Setup_Date__c = System.today();
    //        oppProduct.For_Refinance_In__c = 'KTB-ธ.กรุงไทย';
    //        insert oppProduct;

    //        Test.startTest();
    //        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Id = :targetOpp.Id];
    //        oppObj.IsCloseWon__c = true;
    //        oppObj.StageName = GlobalConstants.ALL_LOAN_SETUP;
    //        Account_Service.triggerInitialCall = false;
    //        update oppObj;
    //        Test.stopTest();
    //    }

    //    System.assertEquals(0,[SELECT Count() FROM Target_List__c WHERE Opportunity__c = :targetOpp.Id]);
    //}
}