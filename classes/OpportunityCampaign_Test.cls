/***********************************************************************
*  Created By       : Chumphon Kaewpraphan
*  Date Created     : 04 July 2016
*
*  Description      : Test class for batch Account_UpdateFirstVisitedDate_Batch
*
*  Modification List:
*  Name             Date            Modification Description
*  ----------       -----------     ------------------------------
*  Chumphon K.      04-Jul-2016     Initial Code Creation
*  Chumphon K.      23-Jan-2017    ISCR055 Campaign Thankyou Change Condition
*  
***********************************************************************/
@isTest
public class OpportunityCampaign_Test {
    //public static String accountNameRM = 'rmCreatedAccountName';
    //public static string strNewBooking='NEWBOOKING';
    //public static string strThankyou='THANKYOU';
    
    //@testSetup static void setupUser(){
    //    TriggerHandler.bypass('UserTriggerHandler');
    //    TriggerHandler.bypass('CampaignTriggerHandler');
    //    Test.startTest();
    //    Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
    //        mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
    //        setupCampaign();
    //    }
    //    Test.stopTest();
    //    TriggerHandler.clearBypass('UserTriggerHandler');
    //}
    
    //public static void setupCampaign(){
    //    /*
    //     * Created by: Nareerat W.
    //     * Created date: 28-Mar-2016
    //     * Description: Prepare Data for CR-006 Test class OpportunityTriggerHandler
    //    */
    //        Campaign_Setting__c cSetting = new Campaign_Setting__c();
    //        cSetting.NewBooking_Code__c= strNewBooking;
    //        cSetting.ThankYou_Code__c= strThankyou;
    //        cSetting.Register_Period__c=30;
    //        //[Start] Change by Chumphon K., 23/01/2017 ISCR055
    //        cSetting.Thankyou_Setup_Amount__c = 1000000;
    //        cSetting.Thankyou_Max_Reward__c = 50000;
    //        cSetting.Thankyou_Divisor__c = 1000000;
    //        cSetting.Thankyou_ME_Prize__c = 1000;
    //        cSetting.Thankyou_SE_Prize__c = 2000;
    //        //[End] Change by Chumphon K., 23/01/2017 ISCR055
    //        insert cSetting;
    //        List<Campaign> campaignList = new List<Campaign>();
    //        Campaign CampaignNewBooking = new Campaign();
    //        CampaignNewBooking.name=strNewBooking;
    //        CampaignNewBooking.type__c='Campaign';
    //        CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
    //        CampaignNewBooking.StartDate=system.today();
    //        CampaignNewBooking.status='Active';
    //        CampaignNewBooking.IsActive=true;           
    //        campaignList.add(CampaignNewBooking);
        
    //        Campaign CampaignThankyou = new Campaign();
    //        CampaignThankyou.name=strThankyou;
    //        CampaignThankyou.type__c='Campaign';
    //        CampaignThankyou.Lead_Campaign_Event_Code__c=strThankyou;
    //        CampaignThankyou.StartDate=system.today();
    //        CampaignThankyou.status='Active';
    //        CampaignThankyou.IsActive=true;         
    //        campaignList.add(CampaignThankyou);
    //        insert campaignList;
    //}
    
    //static testMethod void testInsertOpp_CheckNewBookingTargetList(){
    //    /*
    //     * Created by: Nareerat W.
    //     * Created date: 22-Mar-2016
    //     * Description: CR-006 Test class OpportunityTriggerHandler, afterinsert
    //    */
        
    //    User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //    userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
    //    userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
    //    userRM.Segment__c = GlobalConstants.SEGMENT_ME;
    //    update userRM;

    //    Test.startTest();
    //    System.runAs(userRM){
    //        Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
    //        targetAccount.Customer_s_Business_Code__c = '111111';
    //        update targetAccount;          

    //        Business_Code__c newBusinessCode = new Business_Code__c();
    //        newBusinessCode.Name = 'test class';
    //        newBusinessCode.Segment__c = GlobalConstants.SEGMENT_ME;
    //        newBusinessCode.External_ID__c = 'testRegisterTgl';
    //        insert newBusinessCode;

    //        //Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
    //        Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.CMAS);
    //        opp1.Credit_Model__c = 'PL';
    //        opp1.Application_Number__c = 'TEST/0001/2559/00000001';
    //        opp1.Owner = userRM;
    //        opp1.Owner_Segment_Business_Code__c = GlobalConstants.SEGMENT_ME;
    //        opp1.Business_Code__c = newBusinessCode.Id;
    //        insert opp1;
    //    }

    //    Opportunity finalOpp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestNewOpp_1'];
    //    List<Target_List__c> listNewBooking =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and Opportunity__r.name = 'TestNewOpp_1'];
    //    Test.stopTest();
    //    System.assertEquals('TestNewOpp_1', finalOpp.Name);
    //    system.assertEquals(listNewBooking.size(),1);
    //}
    
    //static testMethod void testUpdateOpp_CloseWon(){
    //    /*
    //     * Created by: Nareerat W.
    //     * Created date: 22-Mar-2016
    //     * Description: CR-006 Test class OpportunityTriggerHandler, AfterUpdate
    //    */
        
    //    TriggerHandler.bypass('UserTriggerHandler');
    //    User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //    userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
    //    userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
    //    userRM.Segment__c = GlobalConstants.SEGMENT_ME;
    //    update userRM;      
    //    TriggerHandler.clearBypass('UserTriggerHandler');

    //    Account targetAccount;
    //    System.runAs(userRM){
    //        TriggerHandler.bypass('AccountTriggerHandler');
    //        targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
    //        targetAccount.Customer_s_Business_Code__c = '111111';
    //        update targetAccount;
    //        TriggerHandler.clearBypass('AccountTriggerHandler');
    //    }

    //    Opportunity opp1;
    //    System.runAs(userRM){
    //        Business_Code__c newBusinessCode = new Business_Code__c();
    //        newBusinessCode.Name = 'test class';
    //        newBusinessCode.Segment__c = GlobalConstants.SEGMENT_ME;
    //        newBusinessCode.External_ID__c = 'testRegisterTgl';
    //        insert newBusinessCode;

    //        opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_2', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
    //        opp1.Owner = userRM;
    //        opp1.Owner_Segment_Business_Code__c = GlobalConstants.SEGMENT_ME;
    //        opp1.Application_Number__c = 'test app no';
    //        opp1.Business_Code__c = newBusinessCode.Id;
    //        opp1.Approval_Status__c = 'Final Approve';

    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        insert opp1;    
    //        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    //    }

    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        opp1.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update opp1;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');

    //        Application_History__c newAppHis = new Application_History__c();
    //        newAppHis.OppName__c = opp1.Id;
    //        newAppHis.AppNum_NonCMAS__c = '23456';
    //        newAppHis.Index__c = 1;
    //        newAppHis.RMActualRequestedAmt__c = 10000;
    //        newAppHis.RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
    //        newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
    //        newAppHis.TentativeSubmitDate__c = System.today();
    //        insert newAppHis;

    //        Opportunity_Product__c newOppPro = new Opportunity_Product__c();
    //        newOppPro.Opportunity__c = opp1.Id;
    //        newOppPro.Approved_Amount__c = 10000000;
    //        insert newOppPro;
    //    }

    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        opp1.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update opp1;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');

    //        Setup_History__c oppProduct1=new Setup_History__c();
    //        oppProduct1.Product__c='ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        oppProduct1.Status__c='Setup';
    //        oppProduct1.Opportunity__c=opp1.Id;
    //        oppProduct1.Setup_Amount__c=1000000;
    //        oppProduct1.Setup_Date__c=system.today();
    //        oppProduct1.Front_End_Fee__c=50000;
    //        oppProduct1.BA_Prosaving__c=50000;
    //        oppProduct1.BA_Protection__c=50000;
    //        oppProduct1.For_Refinance_In__c='TISCO-ธ.ทิสโก้';
    //        insert oppProduct1;
    //    }         
    //    Test.startTest();
    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.ALL_LOAN_SETUP;
    //        opp1.IsCloseWon__c = true;
    //        update opp1;
    //    }

    //    System.runAs(userRM){ 
            
    //        //Opportunity finalOpp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestNewOpp_2' LIMIT 1];
            
    //        List<Target_List__c> listThankyou =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strThankyou and opportunity__c = :opp1.Id];
    //        //System.assertEquals('TestNewOpp_2', finalOpp.Name);
    //        system.assertEquals(listThankyou.size(),1);
    //    }
    //    Test.stopTest();
    //}
    
    // static testMethod void testUpdateOpp_CloseWon_RegisterTargetList(){
    //    /*
    //     * Created by: Nareerat W.
    //     * Created date: 22-Mar-2016
    //     * Description: CR-006 Test class OpportunityTriggerHandler, AfterUpdate
    //    */
        
    //    TriggerHandler.bypass('UserTriggerHandler');
    //    User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //    userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
    //    userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
    //    userRM.Segment__c = 'SE';
    //    update userRM;
    //    TriggerHandler.clearBypass('UserTriggerHandler');

    //    Test.startTest();
    //    Account targetAccount;
    //    System.runAs(userRM){
    //        TriggerHandler.bypass('AccountTriggerHandler');
    //        targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
    //        targetAccount.Customer_s_Business_Code__c = '111111';
    //        update targetAccount;
    //        TriggerHandler.clearBypass('AccountTriggerHandler');
    //    }
        
    //    Opportunity opp1;
    //    System.runAs(userRM){
    //        Business_Code__c newBusinessCode = new Business_Code__c();
    //        newBusinessCode.Name = 'test class';
    //        newBusinessCode.Segment__c = GlobalConstants.SEGMENT_SE;
    //        newBusinessCode.External_ID__c = 'testRegisterTgl';
    //        insert newBusinessCode;

    //        opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_2', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
    //        opp1.Owner = userRM;
    //        opp1.Owner_Segment_Business_Code__c = GlobalConstants.SEGMENT_SE;
    //        opp1.Application_Number__c = 'test app no';
    //        opp1.Business_Code__c = newBusinessCode.Id;

    //        insert opp1;
    //    }

    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        opp1.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update opp1;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');

    //        Application_History__c newAppHis = new Application_History__c();
    //        newAppHis.OppName__c = opp1.Id;
    //        newAppHis.AppNum_NonCMAS__c = '23456';
    //        newAppHis.Index__c = 1;
    //        newAppHis.RMActualRequestedAmt__c = 10000;
    //        newAppHis.RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
    //        newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
    //        newAppHis.TentativeSubmitDate__c = System.today();
    //        insert newAppHis;

    //        Opportunity_Product__c newOppPro = new Opportunity_Product__c();
    //        newOppPro.Opportunity__c = opp1.Id;
    //        newOppPro.Approved_Amount__c = 10000000;
    //        insert newOppPro;
    //    }
        
    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
    //        opp1.Approval_Status__c = 'Final Approve';
    //        TriggerHandler.bypass('OpportunityTriggerHandler');
    //        update opp1;
    //        TriggerHandler.clearbypass('OpportunityTriggerHandler');
    //    }
    //    Test.stopTest();

    //    System.runAs(userRM){
    //        Setup_History__c oppProduct1=new Setup_History__c();
    //        oppProduct1.Product__c='ตั้งวงเงินทั้งหมดในครั้งแรก';
    //        oppProduct1.Status__c='Setup';
    //        oppProduct1.Opportunity__c=opp1.Id;
    //        oppProduct1.Setup_Amount__c=1000001;
    //        oppProduct1.Setup_Date__c=system.today();
    //        oppProduct1.Front_End_Fee__c=50000;
    //        oppProduct1.BA_Prosaving__c=50000;
    //        oppProduct1.BA_Protection__c=50000;
    //        oppProduct1.For_Refinance_In__c='TISCO-ธ.ทิสโก้';
    //        insert oppProduct1;  
    //    }

    //    Target_List__c target;
    //    System.runAs(userRM){
    //        //[Start] Chumphon K., 25-Mar-2016 Add step to register campaign NewBooking
    //        target = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and opportunity__c = :opp1.Id LIMIT 1];
    //        target.Status__c = 'Registered';
    //        update target;
    //        //[End] Chumphon K., 25-Mar-2016 Add step to register campaign NewBooking
    //    }

    //    System.runAs(userRM){
    //        opp1.StageName = GlobalConstants.ALL_LOAN_SETUP;
    //        opp1.IsCloseWon__c = true;
    //        update opp1;
    //    }

    //    System.debug('test =============== '+[select stagename from opportunity where id = :opp1.Id]);
    //    System.runAs(userRM){    
    //        Opportunity finalOpp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestNewOpp_2' LIMIT 1];
            
    //        List<Target_List__c> listThankyou =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strThankyou and opportunity__c = :opp1.Id];
    //        System.assertEquals('TestNewOpp_2', finalOpp.Name);
    //        system.assertEquals(listThankyou.size(),1);

    //        //[Start] Chumphon K., 25-Mar-2016 Add step to register campaign NewBooking
    //        Target_List__c targetNewBooking = [SELECT Id, Status__c, Campaign_Reward_Calc__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and opportunity__c = :opp1.Id LIMIT 1];
    //        System.assertEquals('Registered', targetNewBooking.Status__c);
    //        System.assertNotEquals('-', targetNewBooking.Campaign_Reward_Calc__c);
    //        //[End] Chumphon K., 25-Mar-2016 Add step to register campaign NewBooking
    //    }
    //}

    //static testMethod void testUpdateOpp_ClosedLost(){
    //    /*
    //     * Created by: Chumphon K.
    //     * Created date: 25-Mar-2016
    //     * Description: CR-006 Test class OpportunityTriggerHandler, afterUpdate
    //    */

        
    //    User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //    userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
    //    userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
    //    userRM.Segment__c = GlobalConstants.SEGMENT_SE;
    //    update userRM;
    //    Test.startTest(); 
    //    System.runAs(userRM){
    //        Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
    //        targetAccount.Customer_s_Business_Code__c = '111111';
    //        update targetAccount;          
            
    //        Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_SE);
    //        insert newBusCode;

    //        Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
    //        opp1.Owner = userRM;
    //        opp1.Business_Code__c = newBusCode.Id;
    //        opp1.Owner_Segment_Business_Code__c = GlobalConstants.SEGMENT_SE;
    //        opp1.StageName = GlobalConstants.STOCK_NEGOTIATION;
    //        opp1.Application_Number__c = 'test app no';
    //        insert opp1;
            
    //        opp1.StageName = 'Closed Lost';
    //        opp1.Lost_reason__c = 'Test';
    //        update opp1;
    //    }
    //    Test.stopTest();

    //    Opportunity finalOpp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestNewOpp_1' LIMIT 1];
    //    List<Target_List__c> listNewBooking =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and Opportunity__r.name = 'TestNewOpp_1'];
    //    System.assertEquals('TestNewOpp_1', finalOpp.Name);
    //    system.assertEquals(listNewBooking.size(),1);
    //    system.assertEquals(listNewBooking[0].Status__c,GlobalConstants.LEAD_EXPIRED);
    //}
}