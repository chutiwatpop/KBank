public without sharing class CampaignTriggerHandler extends TriggerHandler {
    private static final String START_NEW_EVENT = 'Start New Event';
    private static final String END_NEW_EVENT = 'End New Event';

    private Map<String,List<Event>> eventInsertMapCampaign;
    private Map<String,List<Event>> eventUpdateMapCampaign;
    private Map<Id, String> teamEmailMapCampaign;
    private Set<String> teamNameSet;

    private Map<String,Set<Id>> userIdMapByCampaign;
    private Map<String,Id> eventRelationMapEventAndRelation;
    private Map<Id,User> userMap;
    private Set<Id> eventDeleteSet;
    private enum EventContext{E_CREATE, E_UPDATE, E_DELETE}

    public override void beforeInsert() {
        for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
            CampaignLead_Service.checkCampaignToActive(eachCampaign);
            CampaignLead_Service.stampCDBField(eachCampaign);
        }
    }

    public override void beforeUpdate() {
        Campaign oldRecord;
        for (Campaign eachCampaign : (List<Campaign>)Trigger.new) {
            oldRecord = (Campaign) Trigger.oldMap.get(eachCampaign.Id);
            CampaignLead_Service.setEventFieldSet(eachCampaign ,oldRecord);
            CampaignLead_Service.setHistoryTracking(eachCampaign ,oldRecord);
            CampaignLead_Service.checkCampaignToActive(eachCampaign, oldRecord);

            if(changeFieldInDihCondition(eachCampaign ,oldRecord)){
                eachCampaign.IsSyncToCDB__c = false;
            }  
        }
    }

    public override void afterInsert() {
        Set<Id> newExpiredCampList = new Set<Id>();
        for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
            if(CampaignLead_Service.isCampaignExpiring(eachCampaign)) {
                newExpiredCampList.add(eachCampaign.Id);
            }
        }
        upsertLeadMST(true);
        if(!newExpiredCampList.isEmpty()){
            setExpiredTargetList(newExpiredCampList);
        }
    }

    public override void afterUpdate() {
        Set<Id> updateCampaignExpiredSet = new Set<Id>();
        Campaign oldRecord;
        for(Campaign eachCampaign : (List<Campaign>) Trigger.new){
            oldRecord = (Campaign) Trigger.oldMap.get(eachCampaign.Id);
            if(CampaignLead_Service.isCampaignExpiring(eachCampaign)) {
                if(eachCampaign.Status != oldRecord.Status) {
                    updateCampaignExpiredSet.add(eachCampaign.Id);
                }
            }
        }
        if(!updateCampaignExpiredSet.isEmpty()){
            setExpiredTargetList(updateCampaignExpiredSet);
        }

        upsertLeadMST(false);
        if(!GlobalUtility.runOnce) {
            String smeEventRecordTypeId     = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign').get(GlobalConstants.SME_EVENT_DEVNAME);
            String smeNonTargetRecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign').get(GlobalConstants.SME_EVENT_NON_TARGET_DEVNAME);
            String rbsEventRecordTypeId     = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign').get(GlobalConstants.RBS_EVENT_DEVNAME);
            String rbsNonTargetRecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign').get(GlobalConstants.RBS_EVENT_NON_TARGETED_DEVNAME);
            Set<String> eventRecordTypeIds = new Set<String>{smeEventRecordTypeId, smeNonTargetRecordTypeId, rbsEventRecordTypeId, rbsNonTargetRecordTypeId};
            Set<Id> campaignEventIds = new Set<Id>();
            for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
                if(eventRecordTypeIds.contains(eachCampaign.RecordTypeId)) {
                    campaignEventIds.add(eachCampaign.Id);
                }
            }

            //event here
            eventInsertMapCampaign = new Map<String,List<Event>>();
            eventUpdateMapCampaign = new Map<String,List<Event>>();
            eventRelationMapEventAndRelation = new Map<String,Id>();
            eventDeleteSet = new Set<Id>();
            teamEmailMapCampaign = new Map<Id, String>();
            teamNameSet = new Set<String>();

            List<Event> eventExistingList = new List<Event>();
            //List<EventRelation> eventRelationExistingList = new List<EventRelation>();
            List<CampaignShare> campaignShareList = new List<CampaignShare>();

            userIdMapByCampaign = new Map<String,Set<Id>>();

            //eventRelationExistingList = [SELECT Id,RelationId,EventId,Event.WhatID FROM EventRelation WHERE Event.WhatID IN:campaignEventIds];
            eventExistingList = [SELECT Id,WhatID,Subject,(SELECT Id,RelationId,EventId FROM EventRelations) FROM Event WHERE WhatID IN:campaignEventIds AND ischild = false];
            campaignShareList = [SELECT Id,UserOrGroupId,CampaignId FROM CampaignShare WHERE CampaignId IN:campaignEventIds AND (RowCause='Manual' OR RowCause='Rule')];

            Set<Id> tmpUserSet = new Set<Id>();
            Set<Id> userSet = new Set<Id>();
            for(CampaignShare eachCampaignShare : campaignShareList){
                if(!userIdMapByCampaign.containsKey(eachCampaignShare.CampaignId)){
                    userIdMapByCampaign.put(eachCampaignShare.CampaignId,new Set<Id>());
                }

                tmpUserSet = UserRoleUtils.GetUserIdsFromGroup(new Set<Id>{eachCampaignShare.UserOrGroupId});
                if(tmpUserSet!=null && tmpUserSet.size() > 0){
                    userIdMapByCampaign.get(eachCampaignShare.CampaignId).addAll(tmpUserSet);
                    userSet.addAll(tmpUserSet);
                }
            }
            if(userSet.size() > 0){
                userMap = new Map<Id,User>([SELECT Id,FirstName,LastName FROM User WHERE Id in:userSet]);
            } else{
                userMap = new Map<Id,User>();
            }

            for(Event eachEvent : eventExistingList){
                if(!eventUpdateMapCampaign.containsKey(eachEvent.WhatID))
                    eventUpdateMapCampaign.put(eachEvent.WhatID,new List<Event>());
                eventUpdateMapCampaign.get(eachEvent.WhatID).add(eachEvent);
                for(EventRelation eachEventRelation : eachEvent.EventRelations){
                    if(!eventRelationMapEventAndRelation.containsKey(eachEventRelation.EventId+''+eachEventRelation.RelationId)) {
                        eventRelationMapEventAndRelation.put(eachEventRelation.EventId+''+eachEventRelation.RelationId,eachEventRelation.Id);
                    }
                }
            }

            //Set<Id> activeLeadIds = new Set<Id>();
            for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
                oldRecord = (Campaign) Trigger.oldMap.get(eachCampaign.Id);
                if(eventRecordTypeIds.contains(eachCampaign.RecordTypeId)) {
                    if(eachCampaign.Status==GlobalConstants.ACTIVE && (oldRecord.Status!=GlobalConstants.ACTIVE || (oldRecord.Venue__c != eachCampaign.Venue__c || oldRecord.End_Date_Time__c != eachCampaign.End_Date_Time__c || oldRecord.Start_Date_Time__c != eachCampaign.Start_Date_Time__c))){
                        if(!eventUpdateMapCampaign.containsKey(eachCampaign.Id)){//INSERT CASE
                            this.handlerEvent(eachCampaign, null, EventContext.E_CREATE);
                            if(eachCampaign.Sent_Email_to_Team__c != null) {
                                teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_CREATE));
                            }
                        }else {
                            this.handlerEvent(eachCampaign, eventUpdateMapCampaign.get(eachCampaign.Id), EventContext.E_UPDATE);
                            if(eachCampaign.Sent_Email_to_Team__c != null) {
                                teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_UPDATE));
                            }
                        }
                    }else if (eachCampaign.Status == GlobalConstants.CANCEL) {
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)){
                            for(Event eachEvent : eventUpdateMapCampaign.get(eachCampaign.Id)){
                                eventDeleteSet.add(eachEvent.Id);
                                if(eachCampaign.Sent_Email_to_Team__c != null) {
                                    teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                    teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_DELETE));
                                }
                            }
                        }
                    } else if (eachCampaign.Status == GlobalConstants.ACTIVE && eachCampaign.Sent_Email_to_Team__c != oldRecord.Sent_Email_to_Team__c) {
                        if(eachCampaign.Sent_Email_to_Team__c != null) {
                            teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                            teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_CREATE));
                        }
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)) {
                            eventUpdateMapCampaign.remove(eachCampaign.Id);
                        }
                    } else {
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)) {
                            eventUpdateMapCampaign.remove(eachCampaign.Id);
                        }
                    }
                } 
            }
        }
    }

    public override void afterUpdateFinally(){
        if(!GlobalUtility.runOnce){
            GlobalUtility.runOnce = true;
            // Future starts here
            Map<Id,Campaign> campaignMap = (Map<Id,Campaign>) Trigger.newMap;
            Map<Id,Campaign> oldCampaignMap = (Map<Id,Campaign>) Trigger.oldMap;
            String eventInsertMapCampaignString = JSON.serialize(eventInsertMapCampaign);
            String eventUpdateMapCampaignString = JSON.serialize(eventUpdateMapCampaign);
            String userIdMapByCampaignString = JSON.serialize(userIdMapByCampaign);
            String userMapString = JSON.serialize(userMap);
            String campaignMapString = JSON.serialize(campaignMap);
            String oldCampaignMapString = JSON.serialize(oldCampaignMap);
            boolean activatedOnce = true;
            String eventMapFlag = '';

            if(teamEmailMapCampaign.size() > 0){
                CampaignTriggerHandlerService.emailToTeam(campaignMapString,oldCampaignMapString,teamEmailMapCampaign,teamNameSet);
            }

            if(eventInsertMapCampaign.size() > 0){
                eventMapFlag = 'Insert';
                CampaignTriggerHandlerService.syncRelation(eventInsertMapCampaignString,userIdMapByCampaignString,eventDeleteSet,eventRelationMapEventAndRelation,userMapString,campaignMapString,activatedOnce,eventMapFlag);
                activatedOnce = false;
            }
            if(eventUpdateMapCampaign.size() > 0){
                eventMapFlag = 'Update';
                CampaignTriggerHandlerService.syncRelation(eventUpdateMapCampaignString,userIdMapByCampaignString,eventDeleteSet,eventRelationMapEventAndRelation,userMapString,campaignMapString,activatedOnce,eventMapFlag);
            }
        }
    }

    private void handlerEvent(Campaign campaignEvent, List<Event> eventList,EventContext ec){
        if(ec == EventContext.E_CREATE){
            if(!eventInsertMapCampaign.containsKey(campaignEvent.Id))
                eventInsertMapCampaign.put(campaignEvent.Id,new List<Event>());

            String recordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.EVENT);
            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.Start_Date_Time__c,
                EndDateTime= campaignEvent.Start_Date_Time__c,
                Subject = START_NEW_EVENT,
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId,
                RecordTypeId = recordTypeId
            ));

            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.End_Date_Time__c,
                EndDateTime= campaignEvent.End_Date_Time__c,
                Subject = END_NEW_EVENT,
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId,
                RecordTypeId = recordTypeId
            ));

            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.Attendee_Confirmation_Date__c,
                EndDateTime= campaignEvent.Attendee_Confirmation_Date__c,
                Subject = 'Confirmation Date',
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId,
                RecordTypeId = recordTypeId
            ));
        }
        else if(ec == EventContext.E_UPDATE && eventList!=null && eventList.size() > 0){

            for(Event eachEvent : eventList){
                if(eachEvent.Subject.startsWith(START_NEW_EVENT)){
                    eachEvent.StartDateTime = campaignEvent.Start_Date_Time__c;
                    eachEvent.EndDateTime = campaignEvent.Start_Date_Time__c;
                } else if(eachEvent.Subject.startsWith(END_NEW_EVENT)){
                    eachEvent.StartDateTime = campaignEvent.End_Date_Time__c;
                    eachEvent.EndDateTime = campaignEvent.End_Date_Time__c;
                } else {
                    eachEvent.StartDateTime = campaignEvent.Attendee_Confirmation_Date__c;
                    eachEvent.EndDateTime = campaignEvent.Attendee_Confirmation_Date__c;
                }
            }
        }
        else if(ec == EventContext.E_DELETE){
            eventDeleteSet.add(campaignEvent.Id);
        }
    }

    public Boolean setExpiredTargetList(Set<Id> campaignTriggerIds) {
        Database.executeBatch(new CampaignChangeStatus_Batch(campaignTriggerIds));
        return true;
    }

    private void upsertLeadMST(Boolean isInsert) {
        if(!System.isBatch()){
            String telesalesRecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign').get(GlobalConstants.TELESALES_CAMPAIGN_DEVNAME);
            if(!isInsert){
                if(Trigger.new.size() == 1 && ((Campaign)Trigger.new.get(0)).RecordTypeId != telesalesRecordTypeId && changeFieldInDihCondition((Campaign)Trigger.new.get(0),(Campaign)Trigger.old.get(0))) {
                    CampaignTriggerHandlerService.upsertLeadMST(Trigger.new.get(0).Id,((Campaign)Trigger.oldMap.get(Trigger.new.get(0).Id)).Lead_Campaign_Event_Code__c);
                }
            }else{
                if(Trigger.new.size() == 1 && ((Campaign)Trigger.new.get(0)).RecordTypeId != telesalesRecordTypeId) {
                    CampaignTriggerHandlerService.upsertLeadMST(Trigger.new.get(0).Id,((Campaign)Trigger.new.get(0)).Lead_Campaign_Event_Code__c);
                }
            }
        }
    }

    private Boolean changeFieldInDihCondition(Campaign newCampaign ,Campaign oldCampaign){
        if(newCampaign.Lead_Campaign_Event_Code__c != oldCampaign.Lead_Campaign_Event_Code__c
            || newCampaign.Name != oldCampaign.Name
            || newCampaign.Promotion__c != oldCampaign.Promotion__c
            || newCampaign.Description != oldCampaign.Description
            || newCampaign.StartDate != oldCampaign.StartDate
            || newCampaign.EndDate != oldCampaign.EndDate
            || newCampaign.Type__c != oldCampaign.Type__c
            || newCampaign.Sub_Type_CBS__c != oldCampaign.Sub_Type_CBS__c
            || newCampaign.Sub_Type__c != oldCampaign.Sub_Type__c
            || newCampaign.Campaign_Type__c != oldCampaign.Campaign_Type__c
            || newCampaign.Priority__c != oldCampaign.Priority__c
            || newCampaign.Priority_Group__c != oldCampaign.Priority_Group__c
            || newCampaign.Add_Associated_Lead__c != oldCampaign.Add_Associated_Lead__c
            || newCampaign.Status != oldCampaign.Status
            ){
            return true;
        }
        return false;
    } 
}