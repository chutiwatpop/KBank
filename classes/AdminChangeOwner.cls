public class AdminChangeOwner implements IOwnerExecution {
    AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
    List<Account> possibleChangeDualLists = new List<Account>();
    List<Account> possibleChangeAFTempLists = new List<Account>();
    List<Account> possibleReleaseAFTempLists = new List<Account>();
    List<Id> possibleOpportunityIdLists = new List<Id>();
    List<Id> possibleOpportunityOwnerIdLists = new List<Id>();
    List<Opportunity> possibleUpdateOpportunityLists = new List<Opportunity>();
    Map<Id, Opportunity> possibleCancelApprovalProcessByOpp = new Map<Id, Opportunity>();
    Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();

    public AdminChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser) {
        Account_Service.isAdminChange = true;
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        possibleChangeDualLists = accountService.possibleChangeDual(accountLists, oldAccountMap);
        possibleChangeAFTempLists = accountService.possibleChangeAFTemp(accountLists, oldAccountMap);
        possibleReleaseAFTempLists = accountService.possibleReleaseAFTemp(accountLists, oldAccountMap);
    }

    public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        possibleUserExtensionMapWithUserId = userExtensionMapWithUserId;
        changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId, newAccountMap);
        changeAccountDual(possibleChangeOwnerLists, oldAccountMap, userExtensionMapWithUserId, newAccountMap);
        Account_Service.isAFDual = true;
        changeAccountDual(possibleChangeDualLists, oldAccountMap, userExtensionMapWithUserId, newAccountMap);
        //closeTemporaryOwnWork(possibleReleaseSMETempLists, oldAccountMap);
    }

    public void executeChangeJob(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        changeJobOwner(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = true;
        changeJobOwner(possibleChangeDualLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = false;
        Account_Service.isAFTemp = true;
        changeJobOwner(possibleChangeAFTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        changeProductOwner(possibleOpportunityOwnerIdLists, possibleOpportunityIdLists);
        changeApprovalProcessOwner(possibleCancelApprovalProcessByOpp);
        Account_Service.isAFDual = false;
        Account_Service.isAFTemp = false;
        Account_Service.isReleaseAFTemp = true;
        Account_Service.isReleaseSMETemp = false;
        autoCloseJob(possibleReleaseAFTempLists,newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isReleaseSMETemp = true;
        Account_Service.isReleaseAFTemp = false;
        List<Account> possibleReleaseSMETempLists = accountService.possibleReleaseSMETemp(newAccountMap.values(), oldAccountMap, userExtensionMapWithUserId);
        autoCloseJob(possibleReleaseSMETempLists,newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
    }

    public void executeChangeEvent(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        changeEvent(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = true;
        changeEvent(possibleChangeDualLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = false;
        Account_Service.isAFTemp = true;
        changeEvent(possibleChangeAFTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
    }

    private void changeAccountOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> oldAccountMap, User currentUser, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId,  Map<Id,Account> newAccountMap){
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        if(possibleChangeOwnerLists.size() > 0){
            mapUserWithId = accountService.getMapUserWithId(possibleChangeOwnerLists, oldAccountMap);
            
            for(Account eachAccount : possibleChangeOwnerLists){
                String oldAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String newAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String segmentFromTo = GlobalUtility.isSegmentFromToString(newAccountOwnerProfile, oldAccountOwnerProfile);
                if(segmentFromTo == 'SMEtoSME'){
                    accountService.isSMEToSMESegment(eachAccount, mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId), mapUserWithId.get(eachAccount.OwnerId), oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else if(segmentFromTo == 'RBStoRBS'){
                    accountService.isRBSToRBSSegment(eachAccount, mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId), mapUserWithId.get(eachAccount.OwnerId), oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else if(segmentFromTo == 'RBStoSME'){
                    accountService.isRBSToSMESegment(eachAccount, mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId), mapUserWithId.get(eachAccount.OwnerId), oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else if(segmentFromTo == 'AFtoAF'){
                    accountService.isAFToAFSegment(eachAccount, mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId), mapUserWithId.get(eachAccount.OwnerId), oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else{
                    accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }
            }
        }
    }

    private void changeAccountDual(List<Account> possibleChangeDualLists, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,Account> newAccountMap){
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        if(possibleChangeDualLists.size() > 0){
            mapUserWithId = accountService.getMapUserWithId(possibleChangeDualLists, oldAccountMap);
            for(Account eachAccount : possibleChangeDualLists){
                String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                if(Account_Service.isAFDual) oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                if(Account_Service.isAFDual) {
                    newAccountOwnerProfile = '';
                    if(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c != null){
                        newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                    }
                }
                if(GlobalConstants.PROFILE_AF_SET.contains(oldAccountOwnerProfile) && !GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile)){
                    accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
                }else if(Account_Service.isAFDual){
                    accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
                }
            }
        }
    }

    private void changeJobOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeJob = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Opportunity> opportunityLists = getOpportunityList(possibleChangeJob);
            List<Id> possibleChangeJobSME = getPossibleChangeSME(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Opportunity> opportunityListSME = getOpportunityList(possibleChangeJobSME);
            List<Id> possibleChangeJobCBS = getPossibleChangeCBS(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Opportunity> opportunityListCBS = getOpportunityList(possibleChangeJobCBS);

            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserId(opportunityLists)));
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserId(opportunityListSME)));
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserId(opportunityListCBS)));
            
            ownAllJob(opportunityLists, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            ownAllJob(opportunityListSME, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            ownAllJob(opportunityListCBS, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
        }
    }

    private List<Id> getPossibleUserId(List<Opportunity> opportunityLists){
        List<Id> possibleUserId = new List<Id>();
        for(Opportunity eachOpportunity : opportunityLists){
            possibleUserId.add(eachOpportunity.OwnerId);
        }
        return possibleUserId;
    }

    private List<Id> getPossibleUserIdFromEvent(List<Event> eventLists){
        List<Id> possibleUserId = new List<Id>();
        for(Event eachEvent : eventLists){
            possibleUserId.add(eachEvent.OwnerId);
        }
        return possibleUserId;
    }

    private void changeProductOwner(List<Id> possibleOpportunityOwnerIdLists, List<Id> possibleOpportunityIdLists){
        if(possibleOpportunityOwnerIdLists.size() > 0 && possibleOpportunityIdLists.size() > 0){
            accountService.changeOwnJobProduct(possibleOpportunityOwnerIdLists, possibleOpportunityIdLists);
        }
    }

    private void autoCloseJob(List<Account> possibleReleaseTempLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleReleaseTempLists.size() > 0){
            List<Id> possibleAccountChangeJob = getPossibleChange(possibleReleaseTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Opportunity> opportunityLists = getOpportunityList(possibleAccountChangeJob);
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserId(opportunityLists)));
            Map<Id,Opportunity> mapClosingOppById = finishJob(opportunityLists, oldAccountMap, newAccountMap, userExtensionMapWithUserId);
            autoCloseApplicationHistory(mapClosingOppById);
            autoCloseProduct(mapClosingOppById);
            autoCancelEvent(possibleReleaseTempLists,mapClosingOppById, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
            //this.opportunityFinishByAFTempRelease = mapClosingOppById;
            TriggerHandler.bypass('OpportunityTriggerHandler');
            Database.update(mapClosingOppById.values());
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }

    private void autoCloseApplicationHistory(Map<Id,Opportunity> mapClosingOppById){
        List<Application_History__c> updateAppHisLists = new List<Application_History__c>();
        List<Application_History__c> listAppHisOwnByAfTemp = [SELECT Id,App_Result__c FROM Application_History__c WHERE OppName__c IN :mapClosingOppById.keySet()];
        if(listAppHisOwnByAfTemp != null && listAppHisOwnByAfTemp.size() > 0){
            Set<String> setStatusClosed = new Set<String>{GlobalConstants.AUTO_CLOSED,GlobalConstants.CLOSED_WON,GlobalConstants.CLOSE_LOST};
            for(Application_History__c eachApp : listAppHisOwnByAfTemp){
                if(!setStatusClosed.contains(eachApp.App_Result__c)){
                    eachApp.App_Result__c = GlobalConstants.AUTO_CLOSED;
                    updateAppHisLists.add(eachApp);
                }
            }
            TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
            Database.update(updateAppHisLists);
            TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
        }
    }

    private void autoCloseProduct(Map<Id,Opportunity> mapClosingOppById){
        List<OpportunityLineItem> updateOpportunityLineItemLists = new List<OpportunityLineItem>();
        List<OpportunityLineItem> listOpportunityLineItemOwnByAfTemp = [SELECT Id,Status__c,Status_CBS__c,OpportunityId,Opportunity.AccountId,OwnerExtension__c,Remark__c FROM OpportunityLineItem WHERE OpportunityId IN :mapClosingOppById.keySet()];
        if(listOpportunityLineItemOwnByAfTemp != null && listOpportunityLineItemOwnByAfTemp.size() > 0){
            Set<String> setAFStatusOpenMustChangeToCancel = new Set<String>{GlobalConstants.OPP_PRODUCT_APP_IN,GlobalConstants.OPP_PRODUCT_WORK_IN_PROCESS,GlobalConstants.OPP_PRODUCT_PRE_APPROVED,GlobalConstants.OPP_PRODUCT_FINAL_APPROVED};
            Set<String> setSMEStatusClose = new Set<String>{GlobalConstants.AUTO_CLOSED,GlobalConstants.CLOSED_WON,GlobalConstants.CLOSE_LOST,GlobalConstants.CANCELLED};
            String remark = GlobalConstants.CANCELLED +' By System';
            for(OpportunityLineItem eachOpportunityLineItem : listOpportunityLineItemOwnByAfTemp){
                if(eachOpportunityLineItem.Status_CBS__c != null){
                    if(!setSMEStatusClose.contains(eachOpportunityLineItem.Status_CBS__c)){
                        eachOpportunityLineItem.Status_CBS__c = GlobalConstants.AUTO_CLOSED;
                        updateOpportunityLineItemLists.add(eachOpportunityLineItem);
                    }
                }else{
                    if(setAFStatusOpenMustChangeToCancel.contains(eachOpportunityLineItem.Status__c) || String.isBlank(eachOpportunityLineItem.Status__c)){
                        eachOpportunityLineItem.Status__c = GlobalConstants.CANCELLED;
                        if(String.isBlank(eachOpportunityLineItem.Remark__c)){
                            eachOpportunityLineItem.Remark__c = remark;
                        }else if(eachOpportunityLineItem.Remark__c.length() + remark.length() < 255){
                            eachOpportunityLineItem.Remark__c = eachOpportunityLineItem.Remark__c+' '+remark;
                        }
                        updateOpportunityLineItemLists.add(eachOpportunityLineItem);
                    }
                }
            }
            Account_Service.byPassValidateOpportunityProduct = true;
            TriggerHandler.bypass('OpportunityProductTriggerHandler');
            Database.update(updateOpportunityLineItemLists);
            TriggerHandler.clearbypass('OpportunityProductTriggerHandler');
        }
    }

    private Map<Id,Opportunity> finishJob(List<Opportunity> opportunityLists, Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        Map<Id,Opportunity> updateOpportunityLists = new Map<Id,Opportunity>();
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                if(oldAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c ==  userExtensionMapWithUserId.get(eachOpportunity.OwnerId).Id
                    ||oldAccountMap.get(eachOpportunity.AccountId).SME_Temporary_Customer__c ==  userExtensionMapWithUserId.get(eachOpportunity.OwnerId).Id){
                    if(eachOpportunity.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName != GlobalConstants.FINISHED_DOT && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED){
                        if(GlobalConstants.PROFILE_AF_SET.contains(eachOpportunity.Owner.Profile.Name)){
                            eachOpportunity.StageName = GlobalConstants.FINISHED;
                        }else{
                            eachOpportunity.StageName = GlobalConstants.AUTO_CLOSED;
                        }
                        eachOpportunity.Jobstage__c = GlobalConstants.FINISHED;
                        eachOpportunity.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity',GlobalConstants.CLOSED_JOB_DEVNAME);
                        updateOpportunityLists.put(eachOpportunity.Id,eachOpportunity);
                    }
                }
            }
        }
        return updateOpportunityLists;
    }

    private void changeApprovalProcessOwner(Map<Id, Opportunity> possibleCancelApprovalProcessByOpp){
        if(possibleCancelApprovalProcessByOpp.size() > 0){
            ApprovalProcess_Service approvalService = new ApprovalProcess_Service();
            approvalService.cancelApprovedByOpportunity(possibleCancelApprovalProcessByOpp);
        }
    }

    private void changeEvent(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeEvent = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Event> eventLists = getEventList(possibleChangeEvent);
            List<Id> possibleChangeEventSME = getPossibleChangeSME(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Event> eventListSME = getEventList(possibleChangeEventSME);
            List<Id> possibleChangeEventCBS = getPossibleChangeCBS(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Event> eventListCBS = getEventList(possibleChangeEventCBS);

            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserIdFromEvent(eventLists)));
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserIdFromEvent(eventListSME)));
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserIdFromEvent(eventListCBS)));
            ownAllEvent(eventLists, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            //ownAllEvent(eventListSME, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            closeAllEvent(eventListSME, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            ownAllEvent(eventListCBS, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
        }
    }

    private void autoCancelEvent(List<Account> possibleReleaseTempLists,Map<Id,Opportunity> mapClosingOppById, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleReleaseTempLists.size() > 0){
            List<Id> possibleAccountChangeEvent = getPossibleChange(possibleReleaseTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Event> eventLists = getEventList(possibleAccountChangeEvent);
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserIdFromEvent(eventLists)));
            cancelEvent(eventLists,mapClosingOppById, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
        }
    }

    private void cancelEvent(List<Event> eventLists,Map<Id,Opportunity> mapClosingOppById, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            Set<String> setStatusClose = new Set<String>{GlobalConstants.CONTACTED,GlobalConstants.CANCELLED};
            Set<Id> setRecordTypeRBS = EventService.getRecordTypeRBS();
            for(Event eachEvent : eventLists){
                if(mapClosingOppById.containsKey(eachEvent.WhatId) ){
                    if(setRecordTypeRBS.contains(eachEvent.RecordTypeID)){
                        if(!setStatusClose.contains(eachEvent.Status__c)) {
                            eachEvent.Status__c = GlobalConstants.CANCELLED;
                        }
                    }else{
                        eachEvent.Status__c = GlobalConstants.STATUS_CLOSED;
                    }
                    eachEvent.RecordTypeID = EventService.getCloseEventRecordType(eachEvent.RecordTypeId);
                    updateEventLists.add(eachEvent);
                }
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(updateEventLists);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    private void closeAllEvent(List<Event> eventLists, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            Set<String> setStatusOpenMustChangeToCancel = new Set<String>{GlobalConstants.PLAN,GlobalConstants.CONTACTED};
            for(Event eachEvent : eventLists){
                if(setStatusOpenMustChangeToCancel.contains(eachEvent.Status__c)){
                    eachEvent.Status__c = GlobalConstants.CLOSED;
                    eachEvent.RecordTypeId = EventService.getCloseEventRecordType(eachEvent.RecordTypeId);
                    updateEventLists.add(eachEvent);   
                }   
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(updateEventLists);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    private List<Event> getEventList(List<Id> possibleChangeEvent){
        return [SELECT Id, WhatId,AccountId, OwnerId, Owner.Profile.Name, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :possibleChangeEvent];
    }

    private List<Opportunity> getOpportunityList(List<Id> possibleChangeJob){
        return [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name, RecordTypeId FROM Opportunity WHERE AccountId IN :possibleChangeJob];
    }

    private List<Id> getPossibleChange(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(Account_Service.isAFDual) oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(Account_Service.isAFDual) {
                newAccountOwnerProfile = '';
                if(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c != null){
                    newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                }
            }
            if(Account_Service.isAFTemp && oldAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c != null && newAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c != null) {
                newAccountOwnerProfile = userExtensionMapWithId.get(newAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c).User__r.Profile.Name;
            }

            if(GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile) || Account_Service.isReleaseAFTemp || Account_Service.isReleaseSMETemp){
                if(Account_Service.isReleaseAFTemp || Account_Service.isReleaseSMETemp){
                    possibleChange.add(eachAccount.Id);
                }else if(Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool_Dual_RM__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }else if (!Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }else if (!Account_Service.isAFDual && Account_Service.isAFTemp){
                    possibleChange.add(eachAccount.Id);
                }
            }
        }
        return possibleChange;
    }

    private List<Id> getPossibleChangeSME(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(!GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile) && !GlobalConstants.PROFILE_RBS_SET.contains(newAccountOwnerProfile)){
                //if(GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile) && newAccountMap.get(eachAccount.Id).Port_Pool__c == GlobalConstants.PORT){
                if((GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile) || GlobalConstants.PROFILE_CBS_SET.contains(newAccountOwnerProfile)) && newAccountMap.get(eachAccount.Id).Port_Pool__c == GlobalConstants.PORT){
                    possibleChange.add(eachAccount.Id);
                }
            }
        }
        return possibleChange;
    }

    private List<Id> getPossibleChangeCBS(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(!GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile) && !GlobalConstants.PROFILE_RBS_SET.contains(newAccountOwnerProfile)){
                if(GlobalConstants.PROFILE_CBS_SET.contains(newAccountOwnerProfile) && newAccountMap.get(eachAccount.Id).Port_Pool__c == GlobalConstants.PORT){
                    possibleChange.add(eachAccount.Id);
                }
            }
        }
        return possibleChange;
    }

    private void ownAllJob(List<Opportunity> opportunityLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        List<Id> opportunityIdLists = new List<Id>();
        List<Id> opportunityOwnerIdLists = new List<Id>();
        List<Opportunity> updateOpportunityLists = new List<Opportunity>();
        Map<Id, Opportunity> cancelApprovalProcessByOpp = new Map<Id, Opportunity>();
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                String oppOwnerProfile = eachOpportunity.Owner.Profile.Name;
                if(Account_Service.isAFDual){
                    eachOpportunity.OwnerId = newAccountMap.get(eachOpportunity.AccountId).Dual_RM_Name__c;
                    eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).Dual_RM_Name__c).Id;
                }else if(Account_Service.isAFTemp && newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c != null){
                    eachOpportunity.OwnerId = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c).User__c;
                    eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c).Id;
                }else{
                    // opp SME stage finish shloud not change owner
                    if(!(
                            GlobalConstants.PROFILE_SME_SET.contains(oppOwnerProfile) && 
                            (eachOpportunity.StageName == GlobalConstants.FINISHED_DOT || eachOpportunity.StageName == GlobalConstants.FINISHED)
                        )
                    ){
                        eachOpportunity.OwnerId = newAccountMap.get(eachOpportunity.AccountId).OwnerId;
                        eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).OwnerId).Id;
                    }
                }
                eachOpportunity.By_Pass__c = true;
                eachOpportunity.Resubmit_Approval__c = false;
                    
                if(eachOpportunity.StageName == GlobalConstants.REOPEN){
                    eachOpportunity.StageName = GlobalConstants.FINISHED;
                    eachOpportunity.Jobstage__c = GlobalConstants.FINISHED;
                    eachOpportunity.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity',GlobalConstants.CLOSED_JOB_DEVNAME);
                    cancelApprovalProcessByOpp.put(eachOpportunity.Id, eachOpportunity);
                }
                opportunityIdLists.add(eachOpportunity.Id);
                opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                updateOpportunityLists.add(eachOpportunity);
            }
            possibleOpportunityIdLists = opportunityIdLists;
            possibleOpportunityOwnerIdLists = opportunityOwnerIdLists;
            possibleUpdateOpportunityLists = updateOpportunityLists;
            possibleCancelApprovalProcessByOpp = cancelApprovalProcessByOpp;
            TriggerHandler.bypass('OpportunityTriggerHandler');
            Database.update(updateOpportunityLists);
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }

    private void ownAllEvent(List<Event> eventLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            for(Event eachEvent : eventLists){
                if(GlobalConstants.PROFILE_AF_SET.contains(userExtensionMapWithUserId.get(eachEvent.OwnerId).User__r.Profile.Name)){
                    if(Account_Service.isAFDual){
                        eachEvent.OwnerId = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).Dual_RM_Name__c).User__c;
                        eachEvent.Created_By_User_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).Dual_RM_Name__c).Id;
                    }else if(Account_Service.isAFTemp && newAccountMap.get(eachEvent.AccountId).AF_Temporary_Customer__c != null){
                        eachEvent.OwnerId = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachEvent.AccountId).AF_Temporary_Customer__c).User__c;
                        eachEvent.Created_By_User_Extension__c = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachEvent.AccountId).AF_Temporary_Customer__c).Id;
                    }else{
                        eachEvent.OwnerId = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).User__c;
                        eachEvent.Created_By_User_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).Id;
                    }
                    updateEventLists.add(eachEvent);
                }
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(updateEventLists);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    //private void closeTemporaryOwnWork(List<Account> possibleReleaseSMETempLists, Map<Id,Account> oldAccountMap){
    //    List<Id> accountIdLists = new List<Id>();
    //    List<Id> userExTempIdLists = new List<Id>();
    //    List<Id> ownerIdLists = new List<Id>();
    //    for(Account eachAccount : possibleReleaseSMETempLists){
    //        Account oldAccount = oldAccountMap.get(eachAccount.Id);
    //         if(isReleaseTemporaryOwnership(oldAccount,eachAccount)){
    //            accountIdLists.add(eachAccount.Id);
    //            userExTempIdLists.add(oldAccount.SME_Temporary_Customer__c);
    //        }
    //    }
    //    if(!userExTempIdLists.isEmpty()){
    //        for(User_Extension__c eacUserEx : [SELECT User__c FROM User_Extension__c WHERE Id IN :userExTempIdLists]){
    //            ownerIdLists.add(eacUserEx.User__c);
    //        }
    //    }
    //    if(!accountIdLists.isEmpty()){
    //        //accountService.closeOwnEvent(accountIdLists, ownerIdLists);
    //        accountService.closeOwnJob(accountIdLists, ownerIdLists);
    //    }
    //}

    //private Boolean isReleaseTemporaryOwnership(Account oldAccount,Account newAccount){
    //    if(Account_Service.isApplication){
    //        return false;
    //    }else if(!String.isBlank(oldAccount.SME_Temporary_Customer__c) && String.isBlank(newAccount.SME_Temporary_Customer__c) && oldAccount.OwnerId == newAccount.OwnerId){
    //        return true;
    //    }
    //    return false;
    //}
}