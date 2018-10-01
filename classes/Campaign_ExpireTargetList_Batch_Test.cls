/***********************************************************************
*  Created By       : Chumphon Kaewpraphan
*  Date Created     : 13 October 2016
*
*  Description      : Batch to test expire not registered campaign within registration period
*
*  Global Variables Used :  None
*
*  Modification List:
*  Name             Date            Modification Description
*  ----------       -----------     ------------------------------
*  Chumphon K.      13-Oct-2016     Initial Code Creation
*  
***********************************************************************/
@isTest
public class Campaign_ExpireTargetList_Batch_Test {
    //public static string strNewBooking='NEWBOOKING';
    //public static string strThankyou='THANKYOU';
    //public static string strLead='LEADTODO';
    
    //@testSetup static void setupUser() {
    //    Test.startTest();
    //        setupCampaign();
    //    Test.stopTest();
    //}
    //public static void setupCampaign(){
    //        Campaign_Setting__c cSetting = new Campaign_Setting__c();
    //        cSetting.NewBooking_Code__c= strNewBooking;
    //        cSetting.ThankYou_Code__c= strThankyou;
    //        cSetting.Register_Period__c=0;
    //        cSetting.Thankyou_Reward_1__c = 'Cash Back 3,000';
    //        cSetting.Thankyou_Reward_2__c = 'PTT 5,000';
    //        cSetting.Thankyou_Reward_3__c = 'iPad mini 2 Wi-Fi 16GB';
    //        cSetting.Thankyou_Reward_4__c = 'Apple watch Sport 42mm';
    //        cSetting.Thankyou_Reward_5__c = 'iPad Air 2 Wi-Fi 64GB';
    //        cSetting.Thankyou_Reward_6__c = 'iPhone 6s';
    //        cSetting.Thankyou_Reward_7__c = 'iPad Pro รุ่น 12.9 Inch 128GB';
    //        cSetting.Thankyou_Reward_8__c = 'Mac Book 12 Inch';
    //        insert cSetting;
    //        List<Campaign> campaignList = new List<Campaign>();
        
    //        Campaign CampaignNewBooking = new Campaign();
    //        CampaignNewBooking.Name=strNewBooking;
    //        CampaignNewBooking.Type__c=GlobalConstants.CAMPAIGN;
    //        CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
    //        CampaignNewBooking.StartDate=system.today() - 100;
    //        CampaignNewBooking.Status=GlobalConstants.ACTIVE;
    //        CampaignNewBooking.IsActive=true;
    //        CampaignNewBooking.RecordTypeId=GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
    //        campaignList.add(CampaignNewBooking);
        
    //        Campaign CampaignThankyou = new Campaign();
    //        CampaignThankyou.Name=strThankyou;
    //        CampaignThankyou.Type__c=GlobalConstants.CAMPAIGN;
    //        CampaignThankyou.Lead_Campaign_Event_Code__c=strThankyou;
    //        CampaignThankyou.StartDate=system.today() - 100;
    //        CampaignThankyou.Status=GlobalConstants.ACTIVE;
    //        CampaignThankyou.IsActive=true;
    //        CampaignThankyou.RecordTypeId=GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
    //        campaignList.add(CampaignThankyou);
        
    //        Campaign leadTest = new Campaign();
    //        leadTest.Name=strThankyou;
    //        leadTest.Type__c=GlobalConstants.LEAD_TO_DO;
    //        leadTest.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
    //        leadTest.Lead_Campaign_Event_Code__c=strLead;
    //        leadTest.StartDate=system.today() - 100;
    //        leadTest.Status=GlobalConstants.ACTIVE;
    //        leadTest.IsActive=true;
    //        leadTest.RecordTypeId=GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
    //        campaignList.add(leadTest);
        
    //        insert campaignList;
    //}
    
    //static testMethod void testExpireNotRegisteredCampaign(){
    //    Integer i;
    //    Id NewBookingID, ThankyouID, TestLeadId;
    //    List<Target_List__c > listTarget = new List<Target_List__c >();
         
    //    List<Campaign> campaignList = [SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign];
    //    for(Campaign eachCamp : campaignList) {
    //        if(eachCamp.Lead_Campaign_Event_Code__c == strNewBooking)
    //            NewBookingID = eachCamp.Id;
    //        if(eachCamp.Lead_Campaign_Event_Code__c == strThankyou)
    //            ThankyouID = eachCamp.Id;
    //        if(eachCamp.Lead_Campaign_Event_Code__c == strLead)
    //            TestLeadId = eachCamp.Id;
    //    }
         
    //    Account testAccount = new Account();
    //    testAccount.Name = 'Test Account';
    //    insert testAccount;
        
    //    Target_List__c  newTarget1 = new Target_List__c ();
    //    newTarget1.Lead_Campaign__c = NewBookingID;
    //    newTarget1.CIS_ID_Prospect_Name__c = testAccount.Id;
    //    newTarget1.Status__c = GlobalConstants.STATUS_NEW;
    //    insert newTarget1;
         
    //    Target_List__c  newTarget2 = new Target_List__c ();
    //    newTarget2.Lead_Campaign__c = ThankyouID;
    //    newTarget2.CIS_ID_Prospect_Name__c = testAccount.Id;
    //    newTarget2.Status__c = GlobalConstants.STATUS_NEW;
    //    insert newTarget2;
        
    //    Target_List__c  newTarget3 = new Target_List__c ();
    //    newTarget3.Lead_Campaign__c = TestLeadId;
    //    newTarget3.CIS_ID_Prospect_Name__c = testAccount.Id;
    //    newTarget3.Status__c = GlobalConstants.STATUS_NEW;
    //    insert newTarget3;

    //    Test.startTest();
    //        Database.executeBatch(new Campaign_ExpireTargetList_Batch());
    //    Test.stopTest();
         
    //    Target_List__c resultTarget1 = [select Id, Status__c from Target_List__c where Id =:newTarget1.Id];
    //    System.assertEquals(resultTarget1.Status__c, GlobalConstants.LEAD_EXPIRED);
         
    //    Target_List__c resultTarget2 = [select Id, Status__c from Target_List__c where Id =:newTarget2.Id];
    //    System.assertEquals(resultTarget2.Status__c, GlobalConstants.LEAD_EXPIRED);
        
    //    Target_List__c resultTarget3 = [select Id, Status__c from Target_List__c where Id =:newTarget3.Id];
    //    System.assertEquals(resultTarget3.Status__c, GlobalConstants.STATUS_NEW);
    // }
}