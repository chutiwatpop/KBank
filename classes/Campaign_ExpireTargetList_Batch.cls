/***********************************************************************
*  Created By       : Chumphon Kaewpraphan
*  Date Created     : 13 October 2016
*
*  Description      : Batch to expire not registered campaign within registration period
*
*  Global Variables Used :  None
*
*  Modification List:
*  Name             Date            Modification Description
*  ----------       -----------     ------------------------------
*  Chumphon K.      13-Oct-2016     Initial Code Creation
*  
***********************************************************************/
global class Campaign_ExpireTargetList_Batch implements Database.Batchable<sObject> {
    global final String query;
    
    global Campaign_ExpireTargetList_Batch(){
        Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
        String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        String campaignThankyouCode = campaignSetting.ThankYou_Code__c;
        String newStatus = 'New';
        Integer registerPeriod = (Integer)campaignSetting.Register_Period__c;
        datetime expireDate = system.today() - registerPeriod;
        //string strExpireDate = expireDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        string strExpireDate = expireDate.format('yyyy-MM-dd') + 'T17:00:00Z';
        
        this.query = 'SELECT Id, Name, CreatedDate, Lead_Campaign__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, CIS_ID_Prospect_Name__c, Status__c FROM Target_List__c WHERE Status__c = \'' + newStatus + '\' And (Lead_Campaign__r.Lead_Campaign_Event_Code__c = \'' + campaignNewBookingCode + '\' OR Lead_Campaign__r.Lead_Campaign_Event_Code__c = \'' + campaignThankyouCode + '\') And (CreatedDate <= '+ strExpireDate +')';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Target_List__c> listTargets) {
        List<Target_List__c> updateTargets = new List<Target_List__c>();
        for(Target_List__c eachTarget : listTargets) {
            eachTarget.Status__c = GlobalConstants.LEAD_EXPIRED;
            updateTargets.add(eachTarget);
        }
        if(updateTargets.size() > 0) update updateTargets;
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Campaign_ExpireTargetList_Batch');
    }
}