/**
* @author chutiwat.s@beryl8.com
* @07/09/2015 createddate
*/
@isTest
private class CampaignSharing_Service_Test {
    
    //@testSetup static void setupAccount(){
    //    Mockup_Test mt = new Mockup_Test().setUpTest();
    //}
    
    //static testMethod void campaignShare(){
    //    User userAh = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
    //    System.assert(userAh != null);
        
    //    System.runAs(userAh){
    //        Campaign camp = Mockup_Test.newCampaign(userAh.Id, 'test', System.now(), ((Datetime) System.now()).addDays(1), ((Datetime) System.now()).addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
    //        insert camp;
    //        List<Campaign> campaigns = [SELECT Id, OwnerID, Name, Start_Date_Time__c, End_Date_Time__c, Attendee_Confirmation_Date__c FROM Campaign];
            
    //        CampaignSharing_Service.Response res = CampaignSharing_Service.shareCampaign(JSON.serialize(campaigns.get(0)));
    //        List<Event> events = [SELECT Id, OwnerID, WhatId FROM Event];

    //        Map<Id, Group> groupMap = new Map<Id, Group>([SELECT Id FROM Group WHERE RelatedId = :UserInfo.getUserRoleId()]);
    //        List<CampaignShare> cmpShareList = [SELECT Id FROM CampaignShare WHERE UserOrGroupId IN :groupMap.keySet()];

    //        // Check Response
    //        System.assertEquals(true, res.success);

    //        // Check Event is Created
    //        System.assert(events.size() > 0);

    //        // Check Share
    //        System.assert(groupMap.size() > 0);
    //        System.assert(cmpShareList.size() > 0);
    //        System.assertEquals(userAh.Id, campaigns[0].OwnerID);
    //    }
    //}
    
}