global class BatchCreateLeadBackward implements Database.Batchable<sObject>,Database.Stateful {
    
    String query;
    List<Id> campaignId;
    
    global BatchCreateLeadBackward(Set<Id> listCampaignId) {
        campaignId = new List<Id>(listCampaignId);
        query = 'SELECT Id, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Subtype__c, Lead_Campaign__c, Lead_Campaign__r.Status, Lead_Campaign__r.Effective_Date__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Lead_Campaign__r.EndDate, Status__c, Lead_Campaign__r.Add_Associated_Lead__c, '
        +' (SELECT Id, Opportunity__r.StageName, Opportunity__r.Approved_Amount__c, Opportunity__r.Setup_Amount__c,Is_Focusing__c FROM Opportunities_Leads__r WHERE Is_Focusing__c = true ORDER BY CreatedDate DESC LIMIT 1) '
        +' FROM Target_List__c '
        +' WHERE Lead_Campaign__c IN (\'' + String.join(campaignId,'\',\'')
        +'\') AND Lead_Campaign__r.RecordType.DeveloperName = \''+ GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME 
        +'\' AND (Lead_Type__c = \''+ GlobalConstants.LEAD_FOR_SALES +'\' OR Lead_Type__c = \''+ GlobalConstants.LEAD_TO_DO +'\' )'
        +' AND Lead_Campaign__r.Status = \''+ GlobalConstants.ACTIVE
        +'\' AND IsFromTrigger__c = false '
        +' AND Lead_Campaign__r.Effective_Date__c != null ';
    }

    global BatchCreateLeadBackward(Set<Id> listCampaignId,Map<Id,Target_List__c> mapTgl) {
        campaignId = new List<Id>(listCampaignId);
        query = 'SELECT Id, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Subtype__c, Lead_Campaign__c, Lead_Campaign__r.Status, Lead_Campaign__r.Effective_Date__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Lead_Campaign__r.EndDate, Status__c, Lead_Campaign__r.Add_Associated_Lead__c, '
        +' (SELECT Id, Opportunity__r.StageName, Opportunity__r.Approved_Amount__c, Opportunity__r.Setup_Amount__c,Is_Focusing__c FROM Opportunities_Leads__r WHERE Is_Focusing__c = true ORDER BY CreatedDate DESC LIMIT 1) '
        +' FROM Target_List__c '
        +' WHERE Lead_Campaign__c IN (\'' + String.join(campaignId,'\',\'')
        +'\') AND Lead_Campaign__r.RecordType.DeveloperName = \''+ GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME 
        +'\' AND (Lead_Type__c = \''+ GlobalConstants.LEAD_FOR_SALES +'\' OR Lead_Type__c = \''+ GlobalConstants.LEAD_TO_DO +'\' )'
        +' AND Lead_Campaign__r.Status = \''+ GlobalConstants.ACTIVE
        +'\' AND IsFromTrigger__c = false '
        +' AND ID IN (\'' + String.join(new List<Id>(mapTgl.keySet()),'\',\'') +'\')'
        +' AND Lead_Campaign__r.Effective_Date__c != null ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Target_List__c> listTargetList) {
        CampaignLead_Service.createLeadBackward(listTargetList);
    }
    
    global void finish(Database.BatchableContext BC) {
        CampaignLead_Service.createLeadBackwardAssociated();
    }
    
}