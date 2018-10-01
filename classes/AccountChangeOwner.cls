public class AccountChangeOwner {
    public Boolean isProspectAccount(Account accountObj, Map<Id,String> prospectRecordTypeId){
        if(prospectRecordTypeId.containsKey(accountObj.RecordTypeId)){
            return true;
        }
        return false;
    }

    private void ownJob(List<Id> accountIdLists, List<Id> ownerIdLists, Boolean isAutoClose){
        List<Id> opportunityIdLists = new List<Id>();
        List<Id> opportunityOwnerIdLists = new List<Id>();
        AccountChangeOwner accountService = new AccountChangeOwner();
        List<Account> accountLists = [SELECT Id,OwnerId FROM Account WHERE Id IN :accountIdLists];
        Map<Id,Account> mapAccountWithId = accountService.createMapAccountWithId(accountLists);
        List<Opportunity> updateOpportunityLists = new List<Opportunity>();
        List<Event> updateEventLists = new List<Event>();
        List<Opportunity> opportunityLists = [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c, Owner.Profile.Name, (SELECT Id, Status__c, RecordTypeId FROM Events) FROM Opportunity WHERE AccountId IN :accountIdLists AND OwnerId IN: ownerIdLists];
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                if(!GlobalConstants.PROFILE_AF_SET.contains(eachOpportunity.Owner.Profile.Name) && !GlobalConstants.PROFILE_RBS_SET.contains(eachOpportunity.Owner.Profile.Name)){
                    if(isAutoClose){
                        if(eachOpportunity.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName != GlobalConstants.FINISHED_DOT && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED){
                            eachOpportunity.StageName = GlobalConstants.AUTO_CLOSED;
                            eachOpportunity.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity',GlobalConstants.CLOSED_JOB_DEVNAME);
                            updateOpportunityLists.add(eachOpportunity);
                            opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                            opportunityIdLists.add(eachOpportunity.Id);
                        }
                        // Add Close Own Event 07/09/2018
                        if(eachOpportunity.Events != null && eachOpportunity.Events.size() > 0) {
                            updateEventLists.addAll(eachOpportunity.Events);
                        }
                    }else if(eachOpportunity.StageName == GlobalConstants.ON_PROCESS || eachOpportunity.StageName == GlobalConstants.STATUS_OPEN || eachOpportunity.StageName == GlobalConstants.CONTACTED){
                        eachOpportunity.OwnerId = mapAccountWithId.get(eachOpportunity.AccountId).OwnerId;
                        updateOpportunityLists.add(eachOpportunity);
                        opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                        opportunityIdLists.add(eachOpportunity.Id);
                    }
                }
            }
            // Add Close Own Event 07/09/2018
            if(!updateEventLists.isEmpty()) {
                accountService.updateOwnEvent(updateEventLists, true);
            }

            TriggerHandler.bypass('OpportunityTriggerHandler');
            Database.update(updateOpportunityLists);
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
            if(isAutoClose){
                accountService.closeOwnJobProduct(opportunityOwnerIdLists, opportunityIdLists);
            }else{
                accountService.changeOwnJobProduct(opportunityOwnerIdLists, opportunityIdLists);
            }
        }
    }

    private void ownAllJob(Map<Id,Account> changeAccountOwnerIdMap, Boolean isAutoClose, Boolean isOpenJob, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        // TODO : refactor by segment
        List<Id> opportunityIdLists = new List<Id>();
        List<Id> opportunityOwnerIdLists = new List<Id>();
        AccountChangeOwner accountService = new AccountChangeOwner();
        List<Opportunity> updateOpportunityLists = new List<Opportunity>();
        List<Opportunity> opportunityLists = new List<Opportunity>();
        Map<Id, Opportunity> cancelApprovalProcessByOpp = new Map<Id, Opportunity>();
        if(isOpenJob){
            opportunityLists = [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name FROM Opportunity WHERE AccountId IN :changeAccountOwnerIdMap.keySet() AND StageName != 'Finished' AND StageName != 'Finished.'];
        }else{
            opportunityLists = [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name FROM Opportunity WHERE AccountId IN :changeAccountOwnerIdMap.keySet()];
        }
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                if(!GlobalConstants.PROFILE_RBS_SET.contains(eachOpportunity.Owner.Profile.Name)){
                    if(GlobalConstants.PROFILE_AF_SET.contains(eachOpportunity.Owner.Profile.Name)){
                        if(Account_Service.isAFDual){
                            eachOpportunity.OwnerId = changeAccountOwnerIdMap.get(eachOpportunity.AccountId).Dual_RM_Name__c;
                            eachOpportunity.Current_Owner_Extension__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).Dual_RM_Name__c).Id;
                        }else{
                            eachOpportunity.OwnerId = changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId;
                            eachOpportunity.Current_Owner_Extension__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Id;
                        }
                        eachOpportunity.By_Pass__c = true;
                        eachOpportunity.Resubmit_Approval__c = false;
                        
                        if(eachOpportunity.StageName == GlobalConstants.REOPEN){
                            eachOpportunity.StageName = GlobalConstants.FINISHED;
                            cancelApprovalProcessByOpp.put(eachOpportunity.Id, eachOpportunity);
                        }
                        updateOpportunityLists.add(eachOpportunity);
                        opportunityIdLists.add(eachOpportunity.Id);
                        opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                    }else if(!isOpenJob && !isAutoClose){
                        eachOpportunity.OwnerId = changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId;
                        eachOpportunity.By_Pass__c = true;
                        eachOpportunity.Current_Owner_Extension__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Id;
                        eachOpportunity.Current_Team_Name__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Team_Structure__c;
                        updateOpportunityLists.add(eachOpportunity);
                        opportunityIdLists.add(eachOpportunity.Id);
                        opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                    }else if(isAutoClose){
                        if(eachOpportunity.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName != GlobalConstants.FINISHED_DOT && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED){
                            eachOpportunity.StageName = GlobalConstants.AUTO_CLOSED;
                            eachOpportunity.By_Pass__c = true;
                            eachOpportunity.Current_Owner_Extension__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Id;
                            eachOpportunity.Current_Team_Name__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Team_Structure__c;
                            updateOpportunityLists.add(eachOpportunity);
                            opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                            opportunityIdLists.add(eachOpportunity.Id);
                        }
                    }else if(eachOpportunity.StageName == GlobalConstants.ON_PROCESS || eachOpportunity.StageName == GlobalConstants.STATUS_OPEN || eachOpportunity.StageName == GlobalConstants.CONTACTED){
                        eachOpportunity.OwnerId = changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId;
                        eachOpportunity.Current_Owner_Extension__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Id;
                        eachOpportunity.Current_Team_Name__c = possibleUserExtensionMapWithUserId.size() == 0 ? null : possibleUserExtensionMapWithUserId.get(changeAccountOwnerIdMap.get(eachOpportunity.AccountId).OwnerId).Team_Structure__c;
                        eachOpportunity.By_Pass__c = true;
                        updateOpportunityLists.add(eachOpportunity);
                        opportunityIdLists.add(eachOpportunity.Id);
                        opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                    }
                }
            }
            TriggerHandler.bypass('OpportunityTriggerHandler');
            Database.update(updateOpportunityLists);
            TriggerHandler.clearBypass('OpportunityTriggerHandler');

            if(cancelApprovalProcessByOpp.size() > 0){
                ApprovalProcess_Service approvalService = new ApprovalProcess_Service();
                approvalService.cancelApprovedByOpportunity(cancelApprovalProcessByOpp);
            }
            
            if(isAutoClose){
                accountService.closeOwnJobProduct(opportunityOwnerIdLists, opportunityIdLists);
            }else{
                accountService.changeOwnJobProduct(opportunityOwnerIdLists, opportunityIdLists);
            }
        }
    }

    private void ownApplicationHistory(Map<Id,User_Extension__c> mapUserExtensionWithId, List<Id> opportunityIdLists, Boolean isAutoClose){
        List<Application_History__c> updateApplicationHistoryLists = new List<Application_History__c>();
        List<Application_History__c> applicationHistoryLists = [SELECT Id, OppName__c, OppName__r.OwnerId, App_Result__c, Current_AH_Team__c, Current_NH_Team__c, Current_Owner_Extension__c, Current_Team_Name__c, RecordType.Name, RecordTypeId FROM Application_History__c WHERE OppName__c IN :opportunityIdLists AND App_Result__c =:GlobalConstants.WORK_IN_PROGRESS];
        //List<User_Extension__c> userExtensionLists = mapUserExtensionWithId.values();
        if(applicationHistoryLists != null && applicationHistoryLists.size() > 0){
            for(Application_History__c eachApplicationHistory : applicationHistoryLists){
                if(isAutoClose) {
                    if(eachApplicationHistory.App_Result__c == GlobalConstants.WORK_IN_PROGRESS) {
                        eachApplicationHistory.App_Result__c = GlobalConstants.AUTO_CLOSED;
                        updateApplicationHistoryLists.add(eachApplicationHistory);
                    }
                } else {
                    //if(userExtensionLists != null && userExtensionLists.size() > 0) {
                    if(mapUserExtensionWithId.containskey(eachApplicationHistory.OppName__r.OwnerId)) {
                        User_Extension__c assignUserExtension = mapUserExtensionWithId.get(eachApplicationHistory.OppName__r.OwnerId);
                        eachApplicationHistory.Current_AH_Team__c           = assignUserExtension.Team_Structure__r.AH_Name__c;
                        eachApplicationHistory.Current_NH_Team__c           = assignUserExtension.Team_Structure__r.NH_Name__c;
                        eachApplicationHistory.Current_Team_Name__c         = assignUserExtension.Team_Structure__c;
                        eachApplicationHistory.Current_Owner_Extension__c   = assignUserExtension.Id;
                    
                        if(GlobalConstants.PROFILE_SME_SET.contains(assignUserExtension.User__r.Profile.Name)){
                            eachApplicationHistory.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c', 'SME_Application_History');
                        }else if(GlobalConstants.PROFILE_CBS_SET.contains(assignUserExtension.User__r.Profile.Name)){
                            eachApplicationHistory.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c', 'CBS_Application_History');
                        }
                        updateApplicationHistoryLists.add(eachApplicationHistory);
                    }
                }
            }
            if(updateApplicationHistoryLists.size() > 0){
                try{
                    TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
                    Database.update(updateApplicationHistoryLists);
                    TriggerHandler.clearBypass('ApplicationHistoryTriggerHandler');
                }catch(Exception e){
                }
            }
        }
    }

    private void ownJobProduct(Map<Id,User_Extension__c> mapUserExtensionWithId, List<Id> opportunityIdLists, Boolean isAutoClose){
        List<OpportunityLineItem> updateOpportunityLineItemLists = new List<OpportunityLineItem>();
        List<OpportunityLineItem> opportunityLineItemLists = [SELECT Id, OpportunityId, Opportunity.OwnerId, AHName__c, NHName__c, OwnerExtension__c, TeamName__c, Status_CBS__c FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIdLists ];
        if(opportunityLineItemLists != null && opportunityLineItemLists.size() > 0){
            for(OpportunityLineItem eachOpportunityLineItem : opportunityLineItemLists){
                if(isAutoClose){
                    eachOpportunityLineItem.Status_CBS__c = GlobalConstants.AUTO_CLOSED;
                    updateOpportunityLineItemLists.add(eachOpportunityLineItem);
                }else{
                    if(mapUserExtensionWithId.containskey(eachOpportunityLineItem.Opportunity.OwnerId)){
                        eachOpportunityLineItem.OwnerExtension__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Id;
                        if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.AH_Name__c != null){
                             eachOpportunityLineItem.AHName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.AH_Name__c;
                        }
                        if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.NH_Name__c != null){
                            eachOpportunityLineItem.NHName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.NH_Name__c;
                        }
                        if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__c != null){
                            eachOpportunityLineItem.TeamName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__c;
                        }
                    }

                    //if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId) != null && mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.AH_Name__c != null) eachOpportunityLineItem.AHName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.AH_Name__c;
                    //if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId) != null && mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.NH_Name__c != null) eachOpportunityLineItem.NHName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__r.NH_Name__c;
                    //if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId) != null && mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__c != null) eachOpportunityLineItem.TeamName__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Team_Structure__c;
                    //if(mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId) != null) eachOpportunityLineItem.OwnerExtension__c = mapUserExtensionWithId.get(eachOpportunityLineItem.Opportunity.OwnerId).Id;
                    updateOpportunityLineItemLists.add(eachOpportunityLineItem);
                }
            }
            try{
                Account_Service.byPassValidateOpportunityProduct = true;
                TriggerHandler.bypass('OpportunityProductTriggerHandler');
                    Database.update(updateOpportunityLineItemLists,false);
                TriggerHandler.clearbypass('OpportunityProductTriggerHandler');
            }catch(Exception e){
            }
        }
    }
    
    private void ownEvent(List<Id> accountIdLists, List<Id> ownerIdLists, Boolean isAutoClose){
        List<Event> eventLists = [SELECT Id, AccountId, OwnerId, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :accountIdLists AND OwnerId IN: ownerIdLists AND Status__c !=:GlobalConstants.CANCELLED AND Status__c !=:GlobalConstants.CLOSED];
        updateOwnEvent(eventLists, isAutoClose);
    }

    private void ownAllEvent(Map<Id,Account> changeAccountOwnerIdMap){
        List<Event> eventLists = [SELECT Id, AccountId, OwnerId, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :changeAccountOwnerIdMap.keySet()];
        updateOwnerEvent(eventLists, changeAccountOwnerIdMap);
    }

    private void ownTempEvent(Set<Id> accountIdLists, Boolean isAutoClose){
        List<Event> eventLists = [SELECT Id, AccountId, OwnerId, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :accountIdLists AND Status__c !=:GlobalConstants.CANCELLED AND Status__c !=:GlobalConstants.CLOSED];
        updateOwnEvent(eventLists, isAutoClose);
    }
    @TestVisible
    private void updateOwnEvent(List<Event> eventLists, Boolean isAutoClose){
        List<Event> updateEventLists = new List<Event>();
        if(eventLists != null && eventLists.size() > 0){
            for(Event eachEvent : eventLists){
                if((eachEvent.Status__c == GlobalConstants.PLAN || eachEvent.Status__c == GlobalConstants.WAITING_FOR_APPROVAL || eachEvent.Status__c == GlobalConstants.CONTACTED) && isAutoClose){
                    eachEvent.Status__c = GlobalConstants.CLOSED;
                    eachEvent.RecordTypeId = EventService.getCloseEventRecordType(eachEvent.RecordTypeId);
                    /*if(eachEvent.Actual_Visit_Date__c != null && eachEvent.Plan_Date__c != null){
                        eachEvent.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.SME_CALL_REPORT_READ_ONLY_DEVNAME);
                    }else if(eachEvent.Actual_Visit_Date__c == null && eachEvent.Plan_Date__c != null){
                        eachEvent.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.SME_CALL_PLAN_READ_ONLY_DEVNAME);
                    }else if(eachEvent.Actual_Visit_Date__c != null && eachEvent.Plan_Date__c == null){
                        eachEvent.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME);
                    }*/
                    updateEventLists.add(eachEvent);
                }
            }
            try{
                TriggerHandler.bypass('EventTriggerHandler');
                Database.update(updateEventLists);
                TriggerHandler.clearBypass('EventTriggerHandler');
            }catch(Exception e){
            }
        }
    }

    private void updateOwnerEvent(List<Event> eventLists, Map<Id,Account> changeAccountOwnerIdMap){
        List<Event> updateEventLists = new List<Event>();
        if(eventLists != null && eventLists.size() > 0){
            for(Event eachEvent : eventLists){
                eachEvent.OwnerId = changeAccountOwnerIdMap.get(eachEvent.AccountId).OwnerId;
                updateEventLists.add(eachEvent);
            }
            try{
                TriggerHandler.bypass('EventTriggerHandler');
                Database.update(updateEventLists);
                TriggerHandler.clearBypass('EventTriggerHandler');
            }catch(Exception e){
            }
        }
    }

    private void ownApprovalProcess(List<Id> accountIdLists){
    }

    private void ownLead(List<Id> accountIdLists){
    }

    public Map<Id,String> getProspectRecordTypeId(){
        Map<Id,String> prospectRecordTypeId = new Map<Id,String>();
        prospectRecordTypeId.put(GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME),GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
        prospectRecordTypeId.put(GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME),GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        return prospectRecordTypeId;
    }

    public void changeOwnJob(List<Id> accountIdLists, List<Id> ownerIdLists){
        ownJob(accountIdLists, ownerIdLists, false);
    }

    public void closeOwnJob(List<Id> accountIdLists, List<Id> ownerIdLists){
        ownJob(accountIdLists, ownerIdLists, true);
    }

    // For CBS Change All Job
    public void changeAllJob(Map<Id,Account> changeAccountOwnerIdMap, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        ownAllJob(changeAccountOwnerIdMap, false, false, possibleUserExtensionMapWithUserId);
    }

    //public void closeAllJob(Map<Id,Account> changeAccountOwnerIdMap, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
    //    ownAllJob(changeAccountOwnerIdMap, true, false, possibleUserExtensionMapWithUserId);
    //}

    // For SME Change All Job
    public void changeAllOpenJob(Map<Id,Account> changeAccountOwnerIdMap, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        ownAllJob(changeAccountOwnerIdMap, false, true, possibleUserExtensionMapWithUserId);
    }

    //public void closeAllOpenJob(Map<Id,Account> changeAccountOwnerIdMap, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
    //    ownAllJob(changeAccountOwnerIdMap, true, true, possibleUserExtensionMapWithUserId);
    //}

    // For AF Change All Event
    public void changeAllEvent(Map<Id,Account> changeAccountOwnerIdMap){
        ownAllEvent(changeAccountOwnerIdMap);
    }

    // For CBS Change Own Event
    public void changeOwnEvent(List<Id> accountIdLists, List<Id> ownerIdLists){
        ownEvent(accountIdLists, ownerIdLists, false);
    }

    // For SME Close Own Event
    //public void closeOwnEvent(List<Id> accountIdLists, List<Id> ownerIdLists){
    //    ownEvent(accountIdLists, ownerIdLists, true);
    //}

    public void closeAllEvent(List<Id> accountIdLists){
        List<Event> eventLists = [SELECT Id, AccountId, OwnerId, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :accountIdLists AND Status__c !=:GlobalConstants.CANCELLED AND Status__c !=:GlobalConstants.CLOSED];
        updateOwnEvent(eventLists, true);
    }
    
    public void closeTempOwnerEvent(Map<Id,Account> changeAccountOwnerIdMap){
        ownTempEvent(changeAccountOwnerIdMap.keySet(), true);
    }

    /*public void ownAllApplicationHistory(List<Id> opportunityOwnerIdLists, List<Id> opportunityIdLists){
        AccountChangeOwner accountService = new AccountChangeOwner();
        List<User_Extension__c> userExtensionLists = [SELECT Id, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, User__c, User__r.Profile.Name FROM User_Extension__c WHERE User__c IN :opportunityOwnerIdLists];
        Map<Id,User_Extension__c> mapUserExtensionWithId = accountService.createMapUserExtensionWithId(userExtensionLists);
        accountService.ownApplicationHistory(mapUserExtensionWithId, opportunityIdLists, false);
    }*/

    public void changeOwnJobProduct(List<Id> opportunityOwnerIdLists, List<Id> opportunityIdLists){
        AccountChangeOwner accountService = new AccountChangeOwner();
        List<User_Extension__c> userExtensionLists = [SELECT Id, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, User__c, User__r.Profile.Name FROM User_Extension__c WHERE User__c IN :opportunityOwnerIdLists];
        Map<Id,User_Extension__c> mapUserExtensionWithId = accountService.createMapUserExtensionWithUserId(userExtensionLists);
        accountService.ownJobProduct(mapUserExtensionWithId, opportunityIdLists, false);
        accountService.ownApplicationHistory(mapUserExtensionWithId, opportunityIdLists, false);
    }

    public void closeOwnJobProduct(List<Id> opportunityOwnerIdLists, List<Id> opportunityIdLists){
        AccountChangeOwner accountService = new AccountChangeOwner();
        List<User_Extension__c> userExtensionLists = [SELECT Id, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, User__c, User__r.Profile.Name FROM User_Extension__c WHERE User__c IN :opportunityOwnerIdLists];
        Map<Id,User_Extension__c> mapUserExtensionWithId = accountService.createMapUserExtensionWithUserId(userExtensionLists);
        accountService.ownJobProduct(mapUserExtensionWithId, opportunityIdLists, true);
        accountService.ownApplicationHistory(mapUserExtensionWithId, opportunityIdLists, true);
    }

    public User checkCurrentAssignUserFromPermanentOwnerExt(Account accountObj, Map<Id,User> userMappingList, Map<Id,User_Extension__c> userExtensionMappingList){
        User assignUser = new User();
        if(userExtensionMappingList.containsKey(accountObj.Permanent_Owner_Extension__c)) {
            assignUser = userMappingList.get(userExtensionMappingList.get(accountObj.Permanent_Owner_Extension__c).User__c);
        }
        return assignUser;
    }

    public List<Account> possibleChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap){
        List<Account> possibleAccountLists = new List<Account>();
        for(Account eachAccount : accountLists){
            if(!isSameOwnerId(oldAccountMap.get(eachAccount.Id),eachAccount)){
                possibleAccountLists.add(eachAccount);
            }
        }
        return possibleAccountLists;
    }

    public List<Account> possibleChangeDual(List<Account> accountLists, Map<Id,Account> oldAccountMap){
        List<Account> possibleDualLists = new List<Account>();
        for(Account eachAccount : accountLists){
            if(!isSameDualId(oldAccountMap.get(eachAccount.Id),eachAccount)){
                possibleDualLists.add(eachAccount);
            }
        }
        return possibleDualLists;
    }

    public List<Account> possibleChangeAFTemp(List<Account> accountLists, Map<Id,Account> oldAccountMap){
        List<Account> possibleAFTempLists = new List<Account>();
        for(Account eachAccount : accountLists){
            if(eachAccount.AF_Temporary_Customer__c != null && !isSameAFTempId(oldAccountMap.get(eachAccount.Id),eachAccount)){
                possibleAFTempLists.add(eachAccount);
            }
        }
        return possibleAFTempLists;
    }

    public List<Account> possibleReleaseAFTemp(List<Account> accountLists, Map<Id,Account> oldAccountMap){
        List<Account> possibleReleaseAFTempLists = new List<Account>();
        for(Account eachAccount : accountLists){
            if(eachAccount.Customer_Owner_Release_Flag__c && eachAccount.AF_Temporary_Customer__c == null && oldAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c != null){
                eachAccount.Customer_Owner_Release_Flag__c = false;
                possibleReleaseAFTempLists.add(eachAccount);
            }
        }
        return possibleReleaseAFTempLists;
    }

    public List<Account> possibleReleaseSMETemp(List<Account> accountLists, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        List<Account> possibleReleaseSMETempLists = new List<Account>();
        for(Account eachAccount : accountLists){
            User_Extension__c ownerUserExtension = userExtensionMapWithUserId.get(eachAccount.OwnerId);
            if(eachAccount.SME_Temporary_Customer__c == null && oldAccountMap.get(eachAccount.Id).SME_Temporary_Customer__c != null
                && (ownerUserExtension == null || (ownerUserExtension != null && oldAccountMap.get(eachAccount.Id).SME_Temporary_Customer__c != ownerUserExtension.Id))){
                possibleReleaseSMETempLists.add(eachAccount);
            }
        }
        return possibleReleaseSMETempLists;
    }
    
    public List<Account> getSameOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap){
        List<Account> sameOwnerAccountLists = new List<Account>();
        for(Account eachAccount : accountLists){
            if(isSameOwnerId(oldAccountMap.get(eachAccount.Id),eachAccount)){
                sameOwnerAccountLists.add(eachAccount);
            }
        }
        return sameOwnerAccountLists;
    }

    private Boolean isSameOwnerId(Account oldAccount, Account newAccount){
        if(oldAccount.OwnerId == newAccount.OwnerId){
            return true;
        }
        return false;
    }

    private Boolean isSameDualId(Account oldAccount, Account newAccount){
        if(oldAccount.Dual_RM_Name__c == newAccount.Dual_RM_Name__c){
            return true;
        }
        return false;
    }

    private Boolean isSameAFTempId(Account oldAccount, Account newAccount){
        if(oldAccount.AF_Temporary_Customer__c == newAccount.AF_Temporary_Customer__c){
            return true;
        }
        return false;
    }

    public Boolean isRBSToRBSSegment(Account accountObj, User oldOwner, User newOwner, Account oldAccountObj, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        accountObj.Port_Pool__c = GlobalConstants.POOL;
        accountObj.Trash_Pool_Flag__c = false;
        accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
        updateOwnerFieldsSet(accountObj, oldAccountObj, teamMapByRc, possibleUserExtensionMapWithUserId);
        return true;
    }

    public Boolean isRBSToSMESegment(Account accountObj, User oldOwner, User newOwner, Account oldAccountObj, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        if(Account_Service.isAdminChange){
            accountObj.SME_Temporary_Customer__c = null;
        }else if(GlobalUtility.isNotNull((String)accountObj.SME_Temporary_Customer__c) && accountObj.SME_Temporary_Customer__c != newOwner.Id){
            accountObj.addError(ExceptionMessage.CANNOT_UPDATE_TRANSACTION);
            return false;
        }else if(GlobalUtility.isNotNull((String)accountObj.SME_Temporary_Customer__c) && accountObj.SME_Temporary_Customer__c == newOwner.Id){
            accountObj.SME_Temporary_Customer__c = null;
        }
        accountObj.OwnerId = newOwner.Id;
        accountObj.Port_Pool__c = GlobalConstants.PORT;
        accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
        if(Account_Service.isTMPool != null && !Account_Service.isTMPool) accountObj.Trash_Pool_Flag__c = false;
        updateOwnerFieldsSet(accountObj, oldAccountObj, teamMapByRc, possibleUserExtensionMapWithUserId);
        return true;
    }

    public Boolean isSMEToSMESegment(Account accountObj, User oldOwner, User newOwner, Account oldAccountObj, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        if(Account_Service.isApplication){
            accountObj.OwnerId = newOwner.Id;
            accountObj.SME_Temporary_Customer__c = null;
            accountObj.Port_Pool__c = GlobalConstants.PORT;
            accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
            if(Account_Service.isTMPool != null && !Account_Service.isTMPool) accountObj.Trash_Pool_Flag__c = false;
        }else if(Account_Service.isAdminChange){
            accountObj.SME_Temporary_Customer__c = null;
        }else if(!GlobalUtility.isNotNull(accountObj.Port_Pool__c) || accountObj.Port_Pool__c == GlobalConstants.POOL){
            // if(Account_Service.isTMPool != null && !Account_Service.isTMPool) accountObj.Port_Pool__c = GlobalConstants.PORT;
            if(!GlobalUtility.isNotNull(accountObj.Port_Pool__c)) accountObj.Port_Pool__c = GlobalConstants.POOL;
            accountObj.SME_Temporary_Customer__c = null;
            if(Account_Service.isTMPool != null && !Account_Service.isTMPool) accountObj.Trash_Pool_Flag__c = false;
            accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
        }
        updateOwnerFieldsSet(accountObj, oldAccountObj, teamMapByRc, possibleUserExtensionMapWithUserId);
        return true;
    }

    public Boolean isAFToAFSegment(Account accountObj, User oldOwner, User newOwner, Account oldAccountObj, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        if(accountObj.Port_Pool__c == GlobalConstants.POOL){
            updateOwnerFieldsSet(accountObj, oldAccountObj, teamMapByRc, possibleUserExtensionMapWithUserId);
            return true;
        }
        updateOwnerFieldsSet(accountObj, oldAccountObj, teamMapByRc, possibleUserExtensionMapWithUserId);
        return false;
    }

    private Map<Id,User_Extension__c> createMapUserExtensionWithId(List<User_Extension__c> userExtensionLists){
        Map<Id,User_Extension__c> mapUserExtensionWithId = new Map<Id,User_Extension__c>();
        for(User_Extension__c eachUserExtension : userExtensionLists){
            mapUserExtensionWithId.put(eachUserExtension.Id, eachUserExtension);
        }
        return mapUserExtensionWithId;
    }

    private Map<Id,User_Extension__c> createMapUserExtensionWithUserId(List<User_Extension__c> userExtensionLists){
        Map<Id,User_Extension__c> mapUserExtensionWithUserId = new Map<Id,User_Extension__c>();
        for(User_Extension__c eachUserExtension : userExtensionLists){
            mapUserExtensionWithUserId.put(eachUserExtension.User__c, eachUserExtension);
        }
        return mapUserExtensionWithUserId;
    }

    private Map<Id,Account> createMapAccountWithId(List<Account> accountLists){
        Map<Id,Account> mapAccountWithId = new Map<Id,Account>();
        for(Account eachAccount : accountLists){
            mapAccountWithId.put(eachAccount.Id, eachAccount);
        }
        return mapAccountWithId;
    }

    public void updateOwnerFieldsSet(Account accountObj, Account oldAccountObj, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        // Add  Current Team
        setCurrentOwnerFieldsSet(accountObj, teamMapByRc, possibleUserExtensionMapWithUserId.get(accountObj.OwnerId));
        // Add Previous Team
        accountObj.Previous_Owner_Segment_Code__c   = oldAccountObj.Primary_Segment_Code__c;
        accountObj.Port_Pool_Flag_Previous_Owner__c = oldAccountObj.Port_Pool__c;
        accountObj.Previous_Owner_Extension__c      = oldAccountObj.Current_Owner_Extension__c;
        accountObj.Previous_AH_Name__c              = oldAccountObj.Current_AH_Name__c;
        accountObj.Previous_NH_Name__c              = oldAccountObj.Current_NH_Name__c;
        accountObj.Previous_Team_Name__c            = oldAccountObj.Current_Team_Name__c;
        accountObj.Previous_Owner__c                = oldAccountObj.OwnerId;
        accountObj.Previous_Owner_Emp_ID__c         = oldAccountObj.Owner_Emp_ID__c;
        // Add Permanent Team
        setPermanentOwnerFieldsSet(accountObj, teamMapByRc, possibleUserExtensionMapWithUserId.get(accountObj.OwnerId));
        // Calculate Primary Segment

        if(Account_Service.isBulk || Account_Service.isRequest || Account_Service.isRelease || Account_Service.isApplication
        ){
            accountObj.Primary_Segment_Code__c = calculatePrimarySegment(possibleUserExtensionMapWithUserId.get(accountObj.OwnerId).User__r, accountObj, String.valueOf(accountObj.Sales_Size__c));
        }
    }

    public void setCurrentOwnerFieldsSet(Account accountObj, Map<String,Id> teamMapByRc, User_Extension__c userExtension) {
        accountObj.Current_Owner_Extension__c = userExtension == null ? null : userExtension.Id;
        accountObj.Current_AH_Name__c         = teamMapByRc.get(accountObj.AH_RC_Code__c);
        accountObj.Current_NH_Name__c         = teamMapByRc.get(accountObj.NH_RC_Code__c);
        accountObj.Current_Team_Name__c       = teamMapByRc.get(accountObj.RC_Code__c);
    }

    public void setPermanentOwnerFieldsSet(Account accountObj, Map<String,Id> teamMapByRc, User_Extension__c userExtension) {
        accountObj.Permanent_Owner__c           = userExtension == null ? null : userExtension.User__c;
        accountObj.Permanent_Owner_Extension__c = userExtension == null ? null : userExtension.Id;
        accountObj.Permanent_AH_Name__c         = teamMapByRc.get(accountObj.AH_RC_Code__c);
        accountObj.Permanent_NH_Name__c         = teamMapByRc.get(accountObj.NH_RC_Code__c);
        accountObj.Permanent_Team_Name__c       = teamMapByRc.get(accountObj.RC_Code__c);
    }

    public void clearPermanentOwnerFieldsSet(Account accountObj) {
        accountObj.Permanent_Owner__c           = null;
        accountObj.Permanent_Owner_Extension__c = null;
        accountObj.Permanent_AH_Name__c         = null;
        accountObj.Permanent_NH_Name__c         = null;
        accountObj.Permanent_Team_Name__c       = null;
    }

    public String calculatePrimarySegment(User ownerUser, Account accountRecord, String salesSize){
        String primarySegmentCode = '';
        if(accountRecord.RecordTypeId != null && (accountRecord.RecordTypeId == GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT) || accountRecord.RecordTypeId == GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.INDIVIDUAL_PROSPECT))){
            return primarySegmentCode;
        }
        primarySegmentCode = accountRecord.Primary_Segment_Code__c;
        if(ownerUser.Segment__c == GlobalConstants.SEGMENT_SE){
            primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_SM;
        }else if(ownerUser.Segment__c  == GlobalConstants.SEGMENT_ME){
            if(salesSize != null && Double.valueOf(salesSize) > 100000000){
                primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_UM;
            }else{
                primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
            }
        }else if(ownerUser.Segment__c  == GlobalConstants.SEGMENT_CB){
            primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_CB;
        }else if(ownerUser.Segment__c  == GlobalConstants.SEGMENT_MB){
            primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_MB;
        }else if(ownerUser.RBS_User__c){
            primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
        }else if(ownerUser.Segment__c  == GlobalConstants.SEGMENT_PC){
            if(accountRecord.Port_Pool__c == GlobalConstants.PORT){
                primarySegmentCode = GlobalConstants.PRIMARY_SEGMENT_CODE_PC;     
            }else if(accountRecord.Port_Pool__c == GlobalConstants.POOL){
                primarySegmentCode = accountRecord.Customer_Segment_Code__c;
            }else{
                primarySegmentCode = '';
            }
        }
        return primarySegmentCode;
    }

    public void updateIndividualContactOwner(Map<Id, Account> changeAccountOwnerIdMap){
        List<Contact> possibleIndividualContactList =  [SELECT CIS__c, OwnerId
                                                        FROM Contact 
                                                        WHERE CIS__c IN :changeAccountOwnerIdMap.keySet() AND recordTypeId = :GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact')];
        List<Contact> changedIndividualContactList = new List<Contact>();
        for(Contact eachContact : possibleIndividualContactList){
            eachContact.OwnerId = changeAccountOwnerIdMap.get(eachContact.CIS__c).OwnerId;
            changedIndividualContactList.add(eachContact);
        }
        TriggerHandler.bypass('ContactTriggerHandler');
        if(!changedIndividualContactList.isEmpty()) update changedIndividualContactList;
        TriggerHandler.clearBypass('ContactTriggerHandler');
    }

    public void updateDualSegment(Account eachAccount, Map<Id,Account> oldAccountMap, Map<Id,User> mapUserWithId){
        if(!Account_Service.isBulk && !Account_Service.isHRIS && (Account_Service.isAdminChange && !Account_Service.isAFDual)){
            eachAccount.Dual_RM_Name__c = oldAccountMap.get(eachAccount.Id).OwnerId;
            eachAccount.Port_Pool_Dual_RM__c = oldAccountMap.get(eachAccount.Id).Port_Pool__c;
            eachAccount.Dual_RM_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC;
        }
        if(eachAccount.Dual_RM_Name__c != NULL){
            if(eachAccount.Port_Pool_Dual_RM__c == GlobalConstants.PORT){
                eachAccount.Dual_RM_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC;
            }else{
                eachAccount.Dual_RM_Segment_Code__c = eachAccount.Secondary_Segment_Code__c;
            }
        }

        eachAccount.AF_RM_Phone__c = mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId).Phone;
    }

    public void updateAsRMPort(Account eachAccount){
        eachAccount.Port_Pool__c        = GlobalConstants.PORT;
        eachAccount.Trash_Pool_Flag__c  = false;
        eachAccount.Ownership_Text__c   = GlobalConstants.OWNERSHIP_PERMANENT; 
    }

    public Map<Id,User_Extension__c> getUserExtensionMapWithId(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        return UserExtension_Service.getUserExtensionMapById(getPossibleUserExtensionListId(newAccountMap, oldAccountMap));
    }

    public Map<Id,User_Extension__c> getUserExtensionMapWithUserId(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        Map<Id,User_Extension__c> userExtensionMapById = new Map<Id,User_Extension__c>();
        userExtensionMapById =  UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserListId(newAccountMap, oldAccountMap));
        userExtensionMapById.putAll(UserExtension_Service.getUserExtensionMapById(getPossibleUserExtensionListId(newAccountMap, oldAccountMap)));
        return userExtensionMapById;
    }

    private List<Id> getPossibleUserListId(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        List<Id> userIdList = new List<Id>();
        User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
        
        userIdList.add(currentUser.Id);
        if(newAccountMap!=null && newAccountMap.size() > 0){
            for(Account eachNewAccount : newAccountMap.values()){
                userIdList.add(eachNewAccount.OwnerId);
                userIdList.add(eachNewAccount.Dual_RM_Name__c);
            }
        }
        if(oldAccountMap!=null && oldAccountMap.size() > 0){
            for(Account eachOldAccount : oldAccountMap.values()){
                userIdList.add(eachOldAccount.OwnerId);
                userIdList.add(eachOldAccount.Dual_RM_Name__c);
            }
        }
        return userIdList;
    }

    private List<Id> getPossibleUserExtensionListId(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        List<Id> userIdList = new List<Id>();
        if(newAccountMap!=null && newAccountMap.size() > 0){
            for(Account eachNewAccount : newAccountMap.values()){
                userIdList.add(eachNewAccount.AF_Temporary_Customer__c);
            }
        }
        if(oldAccountMap!=null && oldAccountMap.size() > 0){
            for(Account eachOldAccount : oldAccountMap.values()){
                userIdList.add(eachOldAccount.AF_Temporary_Customer__c);
            }
        }
        return userIdList;
    }

    public Map<Id,User> getMapUserWithId(List<Account> possibleAccountLists, Map<Id,Account> oldAccountMap){
        Map<Id,Account> mapAccountWithId = new Map<Id,Account>();
        List<Id> userOwnerIdLists = new List<Id>();
        for(Account eachAccount : possibleAccountLists){
            userOwnerIdLists.add(eachAccount.OwnerId);
            userOwnerIdLists.add(oldAccountMap.get(eachAccount.Id).OwnerId);
            userOwnerIdLists.add(eachAccount.Dual_RM_Name__c);
            userOwnerIdLists.add(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c);
            mapAccountWithId.put(eachAccount.Id, eachAccount);
        }
        return User_Service.getUserMapWithId(userOwnerIdLists);
    }
}