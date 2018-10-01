/**
*@author Pasakorn Promsuban
*@27/6/2016 Created Class for future call on event relation
**/
public class CampaignTriggerHandlerService{
    
    public static Map<String, Id> recordTypeMapByDevName;
    private static final String START_NEW_EVENT = 'Start New Event';
    private static final String END_NEW_EVENT = 'End New Event';
    private enum EventContext{E_CREATE, E_UPDATE, E_DELETE}
    
    @future
    public static void emailToTeam(String campaignMapString, String oldCampaignMapString,Map<Id,String> teamEmailMapCampaign, Set<String> teamNameSet){
            Set<String> template = new Set<String>{
                GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL, GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL,GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL
            };

            Map<String,EmailTemplate> emailTemplate = new Map<String,EmailTemplate>();
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName IN: template]);
            Map<Id,Campaign> campaignMap = (Map<Id,Campaign>) JSON.deserialize(campaignMapString, Map<Id,Campaign>.class);
            Map<Id,Campaign> oldCampaignMap = (Map<Id,Campaign>) JSON.deserialize(oldCampaignMapString, Map<Id,Campaign>.class);
            Map<String,List<Event_External_User__c>> teamMemberAddressMap = new Map<String, List<Event_External_User__c>>();
            List<Event_External_User__c> teamMemberAddressList = [SELECT Id, Name__c, Team__c, Email__c FROM Event_External_User__c WHERE Team__c IN :teamNameSet];
            Set<String> oldTeamNameSet = new Set<String>();
            List<Messaging.SingleEmailMessage> emailToSendTeam = new List<Messaging.SingleEmailMessage>();
            Campaign tempCampaign = new Campaign();
            Campaign oldRecord = new Campaign();
            Set<String> teamsSet = new Set<String>();
            List<Event_External_User__c> membersToSentList = new List<Event_External_User__c>();

            String emailSubject = '';
            String emailBody = '';

            for(EmailTemplate eTemp : emailTemplateList){
                emailTemplate.put(eTemp.DeveloperName,eTemp);
            }
            
            for(Event_External_User__c eachTeamMember : teamMemberAddressList) {
                if(teamMemberAddressMap.containsKey(eachTeamMember.Team__c)) {
                    teamMemberAddressMap.get(eachTeamMember.Team__c).add(eachTeamMember);    
                } else {
                    teamMemberAddressMap.put(eachTeamMember.Team__c, new List<Event_External_User__c>{eachTeamMember});
                }
            }
            if(teamEmailMapCampaign.size() > 0){
                for(Id campaignId : teamEmailMapCampaign.keySet()) {
                    if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_UPDATE)) {
                        emailSubject = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL).Subject.replace('{!Campaign.Name}', (campaignMap.get(campaignId)).Name);
                        emailBody = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL).Body;
                    } else if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_CREATE)) {
                        emailSubject = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL).Subject.replace('{!Campaign.Name}', (campaignMap.get(campaignId)).Name);
                        emailBody = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL).Body;
                    }else if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_DELETE)) {
                        emailSubject = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL).Subject.replace('{!Campaign.Name}', (campaignMap.get(campaignId)).Name);
                        emailBody = emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL).Body;
                    }
                    tempCampaign = campaignMap.get(campaignId);
                    oldRecord = oldCampaignMap.get(campaignId);
                    teamsSet = new Set<String>(((String)tempCampaign.Sent_Email_to_Team__c).split(';'));
                    if(tempCampaign.Sent_Email_to_Team__c != oldRecord.Sent_Email_to_Team__c && oldRecord.Sent_Email_to_Team__c != null) {
                        oldTeamNameSet.addAll(new Set<String>(oldRecord.Sent_Email_to_Team__c.split(';')));
                    }
                    teamsSet.removeAll(oldTeamNameSet);
                    membersToSentList = new List<Event_External_User__c>();
                    for(String eachTeam : teamsSet) {
                        if(teamMemberAddressMap.containsKey(eachTeam))
                            membersToSentList.addAll(teamMemberAddressMap.get(eachTeam));
                    }
                    emailToSendTeam.addAll(sentEmailToTeam(emailSubject, emailBody, tempCampaign, membersToSentList));
                }
            }
        CampaignTriggerHandlerService.sendEmails(emailToSendTeam);
    }

    @future
    public static void syncRelation(String eventByCampaignMapString,String userIdMapByCampaignString, Set<Id> eventDeleteSet, Map<String,Id> eventRelationMapEventAndRelation, String userMapString, String campaignListString, boolean activatedOnce,String flag){
        Set<String> template = new Set<String>{
                GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT, GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT,GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT
            };
        Map<String,EmailTemplate> emailTemplate = new Map<String,EmailTemplate>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName IN: template]);
        Map<Id,Campaign> campaignMap = (Map<Id,Campaign>) JSON.deserialize(campaignListString, Map<Id,Campaign>.class);
        Map<Id,User> userMap = (Map<Id,User>) JSON.deserialize(userMapString, Map<Id,User>.class);
        Map<String,Set<Id>> userIdMapByCampaign = (Map<String,Set<Id>>) JSON.deserialize(userIdMapByCampaignString, Map<String,Set<Id>>.class);
        Map<String,Set<Id>> userIdMapByEventId = new Map<String,Set<Id>>();
        Map<String,String> campaignIdMapByEventId = new Map<String,String>();
        Map<String,List<Event>> eventByCampaignMap = (Map<String,List<Event>>) JSON.deSerialize(eventByCampaignMapString, Map<String,List<Event>>.class);
        List<EventRelation> eventRelationList = new List<EventRelation>();
        List<Event> eventListToUpsert = new List<Event>();
        List<Messaging.SingleEmailMessage> emailToSendSyncRelation = new List<Messaging.SingleEmailMessage>();


        for(EmailTemplate emailTemp : emailTemplateList){
            emailTemplate.put(emailTemp.DeveloperName,emailTemp);
        }
        
        System.debug('CampIds:' + eventByCampaignMap.keySet());
        System.debug('Events[]:' + eventByCampaignMap);

        for(String campaignId : eventByCampaignMap.keySet()){
            eventListToUpsert.addAll(eventByCampaignMap.get(campaignId));
        }
        upsert eventListToUpsert;   
        
        for(String campaignId : eventByCampaignMap.keySet()){
            
            if(userIdMapByCampaign.containsKey(campaignId)){//have member

                for(Event eachEventInCampaign : eventByCampaignMap.get(campaignId)){

                    if(!eventDeleteSet.contains(eachEventInCampaign.Id)){

                        for(Id eachUserToShare : userIdMapByCampaign.get(campaignId)){

                            if(eachUserToShare!=campaignMap.get(campaignId).get('OwnerId')){

                                if(!eventRelationMapEventAndRelation.containsKey(eachEventInCampaign.Id+''+eachUserToShare)){
                                    eventRelationList.add(new EventRelation(
                                        EventId = eachEventInCampaign.Id,
                                        RelationId = eachUserToShare
                                    ));
                                }else eventRelationMapEventAndRelation.remove(eachEventInCampaign.Id+''+eachUserToShare);// have event relation 
                                
                                if(eachEventInCampaign.Subject.startsWith(START_NEW_EVENT)){
                                    if(flag == 'insert'){
                                        emailToSendSyncRelation.add(addEmail(emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT).Subject.replace('{!Campaign.Name}',(campaignMap.get(campaignId)).Name),emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT).Body, eachUserToShare, campaignMap.get(campaignId),userMap));
                                    }
                                    else{
                                        emailToSendSyncRelation.add(addEmail(emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT).Subject.replace('{!Campaign.Name}',(campaignMap.get(campaignId)).Name),emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT).Body, eachUserToShare, campaignMap.get(campaignId),userMap));
                                    }
                                    
                                }  
                            }
                        }
                    }
                }
            }
        }


        if(activatedOnce == true){
            List<EventRelation> eventRelationDeleteList = new List<EventRelation>();
            if(eventDeleteSet.size() > 0) {
                eventRelationDeleteList = [SELECT Id,RelationId,Event.WhatID FROM EventRelation WHERE EventId in : eventDeleteSet AND Event.Subject LIKE 'Start New Event%' AND Relation.Type = 'User'];
                for(EventRelation eachRelation : eventRelationDeleteList){
                    emailToSendSyncRelation.add(addEmail(emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT).Subject.replace('{!Campaign.Name}',(campaignMap.get(eachRelation.Event.WhatID)).Name),emailTemplate.get(GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT).Body, eachRelation.RelationId, campaignMap.get(eachRelation.Event.WhatID),userMap));
                }
            }

            if(eventRelationMapEventAndRelation.size() > 0){
                //delete remain unused relation
                delete [SELECT Id FROM EventRelation WHERE Id in:eventRelationMapEventAndRelation.values()];
            }
            System.debug('Delete Set FutureSync'+eventDeleteSet);
            if(eventDeleteSet.size() > 0) {

                delete [SELECT Id FROM Event WHERE Id in:eventDeleteSet];
            }
        }
        
        
        System.debug('User Size:' + userIdMapByCampaign);
        if(eventRelationList.size() > 0){
            upsert eventRelationList;
        } 
        CampaignTriggerHandlerService.sendEmails(emailToSendSyncRelation);
    }
    

    
    public static void sendEmails(List<Messaging.SingleEmailMessage> emailToSend){
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailToSend);
        for(Messaging.SendEmailResult eachResult : emailResults){
            if(!eachResult.IsSuccess()){
                    System.debug(eachResult.getErrors()+'');
            }
        }
    }
    
    
    private static List<Messaging.SingleEmailMessage> sentEmailToTeam(String emailSubjectSent, String emailBodySent, Campaign campaignObj, List<Event_External_User__c> membersToSent) {
        Messaging.SingleEmailMessage emailObj;
        String campaignEmailBody = setAllCampaignTemplateBody(campaignObj , emailBodySent);
        List<Messaging.SingleEmailMessage> emailToSendTeam = new List<Messaging.SingleEmailMessage>();
        for (Event_External_User__c eachExternal : membersToSent) {
            emailObj = new Messaging.SingleEmailMessage();

            string fullTemplateBody = setAllUserTemplateBody(eachExternal, campaignEmailBody);

            emailObj.setPlainTextBody(fullTemplateBody);
            emailObj.setToAddresses(new List<String>{eachExternal.Email__c});
            emailObj.setSubject(emailSubjectSent);
            emailObj.setUseSignature(false);
            emailObj.setBccSender(false);
            emailObj.setSaveAsActivity(false);

            emailToSendTeam.add(emailObj);
        }
        return emailToSendTeam;
    }
    

    private static Messaging.SingleEmailMessage addEmail(String emailSubjectAdd,String emailBodyAdd,String userId,Campaign campaignObj, Map<Id,User> userMap){
        Messaging.SingleEmailMessage emailObj;
        emailObj = new Messaging.SingleEmailMessage();
        //emailObj.setTemplateId(templateId);
        string fullTemplateBody = setAllUserTemplateBody(userMap.get(userId),setAllCampaignTemplateBody(campaignObj , emailBodyAdd));
        emailObj.setPlainTextBody(fullTemplateBody);
        emailObj.setTargetObjectId(userId);
        emailObj.setSubject(emailSubjectAdd);
        //emailObj.setWhatId(whatId);
        emailObj.setUseSignature(false);
        emailObj.setBccSender(false);
        emailObj.setSaveAsActivity(false);
        return emailObj;
    }

    public static string setAllUserTemplateBody(Event_External_User__c externalUser, String templateBody){
        
        String fullTemplateBody = templateBody;
        String target = '{!User.FirstName} {!User.LastName} ';
        if(fullTemplateBody.contains(target)){
            fullTemplateBody = fullTemplateBody.replace(target, externalUser.Name__c);
        }

        target = '{!User.LastName}';
        if(fullTemplateBody.contains(target)){
            fullTemplateBody = fullTemplateBody.replace(target, '');
        }
        
        return fullTemplateBody;
    }

    public static String setAllUserTemplateBody(User eachUser, String templateBody){
        String fullTemplateBody = templateBody;
        Map<String, Schema.SObjectField> userFields = Schema.SObjectType.User.fields.getMap();
        
        for(Schema.SObjectField fieldName : userFields.values()) {
            String fieldString = '{!User.'+String.valueOf(fieldName)+'}';
            if(fullTemplateBody.contains(fieldString)){
                Integer index = fullTemplateBody.indexOf(fieldString);
                String target = fullTemplateBody.substring(index, (index+fieldString.length()));
                if(fieldString == '{!User.Id}' && eachUser != null && String.valueOf(eachUser.get('Id')) != null){
                    String link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachUser.Id;
                    fullTemplateBody = fullTemplateBody.replace(target,link);
                }else if(eachUser != null && String.valueOf(eachUser.get(fieldName)) != null){
                    fullTemplateBody = fullTemplateBody.replace(target, String.valueOf(eachUser.get(fieldName)));
                }else{
                    fullTemplateBody = fullTemplateBody.replace(target, '');
                }
            }
        }
        
        return fullTemplateBody;
    }

    public static String setAllCampaignTemplateBody(Campaign eachCampaign, String templateBody){
        String fullTemplateBody = templateBody;
        Map<String, Schema.SObjectField> campaignFields = Schema.SObjectType.Campaign.fields.getMap();
        
        Integer index;
        String fieldString;
        String target;
        String eventTime;
        Datetime eventDateTime;
        for(Schema.SObjectField fieldName : campaignFields.values()) {
            fieldString = '{!Campaign.'+String.valueOf(fieldName)+'}';
            if(fullTemplateBody.contains(fieldString)){
                index = fullTemplateBody.indexOf(fieldString);
                target = fullTemplateBody.substring(index, (index+fieldString.length()));
                if(String.valueOf(eachCampaign.get(String.valueOf(fieldName))) != null) {
                    if(fieldString == '{!Campaign.Start_Date_Time__c}'){
                        eventDateTime = eachCampaign.Start_Date_Time__c;
                        eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = eventTime.split(' ');
                        fullTemplateBody = fullTemplateBody.replace(target,splitedTime[0]+' '+splitedTime[1]);
                    }else if(fieldString == '{!Campaign.End_Date_Time__c}'){
                        eventDateTime = eachCampaign.End_Date_Time__c;
                        eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = eventTime.split(' ');
                        fullTemplateBody = fullTemplateBody.replace(target,splitedTime[0]+' '+splitedTime[1]);
                    }else if(fieldString == '{!Campaign.Previous_Start_Date_Time__c}'){
                        eventDateTime = eachCampaign.Previous_Start_Date_Time__c;
                        eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = eventTime.split(' ');
                        fullTemplateBody = fullTemplateBody.replace(target,splitedTime[0]+' '+splitedTime[1]);
                    }else if(fieldString == '{!Campaign.Previous_End_Date_Time__c}'){
                        eventDateTime = eachCampaign.Previous_End_Date_Time__c;
                        eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = eventTime.split(' ');
                        fullTemplateBody = fullTemplateBody.replace(target,splitedTime[0]+' '+splitedTime[1]);
                    }else if(fieldString == '{!Campaign.Attendee_Confirmation_Date__c}'){
                        eventDateTime = eachCampaign.Attendee_Confirmation_Date__c;
                        eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = eventTime.split(' ');
                        fullTemplateBody = fullTemplateBody.replace(target,splitedTime[0]+' '+splitedTime[1]);
                    }else if(fieldString == '{!Campaign.Id}'){
                        String link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachCampaign.Id;
                        fullTemplateBody = fullTemplateBody.replace(target,link);
                    }else if(String.valueOf(eachCampaign.get(fieldName)) != null){
                        fullTemplateBody = fullTemplateBody.replace(target,String.valueOf(eachCampaign.get(fieldName)));
                    }
                } else {
                    fullTemplateBody = fullTemplateBody.replace(target,'');
                }
            }
        }
        fullTemplateBody = fullTemplateBody.replace('{!Campaign.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachCampaign.Id);
        
        return fullTemplateBody;
    }

    @future(callout=true)
    public static void upsertLeadMST(String targetCampaignId,String oldCode) {
        List<Campaign> targetCamps = new List<Campaign>();
        targetCamps = [SELECT Id, Lead_Campaign_Event_Code__c, Name, Promotion__c, Description, StartDate, EndDate, Type__c, Sub_Type__c,Sub_Type_CBS__c, Campaign_Type__c, CreatedDate, LastModifiedDate, Priority__c, Priority_Group__c, Add_Associated_Lead__c, Status, Created_By_CDB__c, Last_Modified_By_CDB__c, Created_Date_CDB__c, Last_Modified_Date_CDB__c, CreatedBy.Employee_Id__c, LastModifiedBy.Employee_Id__c FROM Campaign WHERE Id = :targetCampaignId LIMIT 1];

        Campaign targetCamp;
        if(targetCamps.isEmpty()) {
            return;
        } else {
            targetCamp = targetCamps.get(0);
        }

        try {
            // Call Webservice
            CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
            CIBaseResponseModel responseModel = webServiceInstance.upsertMSTWebservice(targetCamp,oldCode);
            if(responseModel != null && responseModel.success) {
                TriggerHandler.bypass('CampaignTriggerHandler');
                update new Campaign(Id = targetCamp.Id,IsSyncToCDB__c = true);
            }
        } catch (Exception e) {
            System.debug('Exception:' + e);
            GlobalUtility.logMessage('ERROR','CampaignTriggerHandlerService','upsertLeadMST',null,null,e.getMessage(),null,e,null);
        }
    }
}