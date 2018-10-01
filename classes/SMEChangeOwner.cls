public class SMEChangeOwner implements IOwnerExecution {
    AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
    List<Account> possibleChangeDualLists = new List<Account>();
    //List<Account> possibleReleaseSMETempLists = new List<Account>();
    //List<Account> sameOwnerAccountLists = new List<Account>();
    //List<Account> listCurrentAccount = new List<Account>();
    List<Id> possibleOpportunityIdLists = new List<Id>();
    List<Id> possibleOpportunityOwnerIdLists = new List<Id>();
    List<Opportunity> possibleUpdateOpportunityLists = new List<Opportunity>();
    Map<Id, Opportunity> possibleCancelApprovalProcessByOpp = new Map<Id, Opportunity>();
    Map<Id, User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
    
    public SMEChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser){
        //listCurrentAccount = accountLists;
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        possibleChangeDualLists = accountService.possibleChangeDual(accountLists, oldAccountMap);
        //possibleReleaseSMETempLists = accountService.possibleReleaseSMETemp(accountLists, oldAccountMap);
        //possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        //possibleChangeDualLists = accountService.possibleChangeDual(accountLists, oldAccountMap);
        //sameOwnerAccountLists = accountService.getSameOwner(accountLists, oldAccountMap);
        //listCurrentAccount = accountLists;
        //if(!possibleChangeOwnerLists.isEmpty() || !sameOwnerAccountLists.isEmpty()) {
        //    List<Id> userIdList = new List<Id>();
        //    for(Account eachAccount : accountLists){
        //        userIdList.add(eachAccount.OwnerId);
        //        userIdList.add(oldAccountMap.get(eachAccount.Id).OwnerId);
        //    }
        //    userIdList.add(currentUser.Id);
        //    possibleUserMap = User_Service.getUserMapWithId(userIdList);
        //    possibleUserExtensionMapWithUserId = UserExtension_Service.getUserExtensionMapByUserId(userIdList);
        //}
    }

    public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        //changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId, sameOwnerAccountLists);
        possibleUserExtensionMapWithUserId = userExtensionMapWithUserId;
        changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId, newAccountMap);
        changeAccountDual(possibleChangeDualLists, oldAccountMap, userExtensionMapWithUserId, newAccountMap);
        //closeTemporaryOwnWork(oldAccountMap);
    }

    public void executeChangeJob(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        changeJobOwner(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        changeProductOwner(possibleOpportunityOwnerIdLists, possibleOpportunityIdLists);
        changeApprovalProcessOwner(possibleCancelApprovalProcessByOpp);
        
        List<Account> possibleReleaseSMETempLists = accountService.possibleReleaseSMETemp(newAccountMap.values(), oldAccountMap, userExtensionMapWithUserId);
        autoCloseJob(possibleReleaseSMETempLists,newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
    }

    private void autoCloseJob(List<Account> possibleReleaseTempLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleReleaseTempLists.size() > 0){
            List<Id> possibleAccountChangeJob = getPossibleChange(possibleReleaseTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
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
                //if(oldAccountMap.get(eachApp.Opportunity.AccountId).AF_Temporary_Customer__c ==  eachApp.OwnerExtension__c
                //|| mapClosingOppById.containsKey(eachApp.OpportunityId)){
                    if(!setStatusClosed.contains(eachApp.App_Result__c)){
                        eachApp.App_Result__c = GlobalConstants.AUTO_CLOSED;
                        updateAppHisLists.add(eachApp);
                    }
                //}
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
                } else {
                    if(setAFStatusOpenMustChangeToCancel.contains(eachOpportunityLineItem.Status__c) || String.isBlank(eachOpportunityLineItem.Status__c)){
                        eachOpportunityLineItem.Status__c = GlobalConstants.CANCELLED;
                        if(String.isBlank(eachOpportunityLineItem.Remark__c)){
                            eachOpportunityLineItem.Remark__c = remark;
                        } else if (eachOpportunityLineItem.Remark__c.length() + remark.length() < 255){
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

    private void autoCancelEvent(List<Account> possibleReleaseTempLists,Map<Id,Opportunity> mapClosingOppById, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(possibleReleaseTempLists.size() > 0){
            List<Id> possibleAccountChangeEvent = getPossibleChange(possibleReleaseTempLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
            List<Event> eventLists = getEventList(possibleAccountChangeEvent);
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(getPossibleUserIdFromEvent(eventLists)));
            cancelEvent(eventLists,mapClosingOppById, newAccountMap ,oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
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

    private void cancelEvent(List<Event> eventLists,Map<Id,Opportunity> mapClosingOppById, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            Set<String> setStatusClose = new Set<String>{GlobalConstants.CONTACTED,GlobalConstants.CANCELLED};
            Set<Id> setRecordTypeRBS = EventService.getRecordTypeRBS();
            for(Event eachEvent : eventLists){
                if(mapClosingOppById.containsKey(eachEvent.WhatId) && mapClosingOppById.get(eachEvent.WhatId).AccountId != NULL &&  newAccountMap.containsKey(mapClosingOppById.get(eachEvent.WhatId).AccountId) && newAccountMap.get(mapClosingOppById.get(eachEvent.WhatId).AccountId).OwnerId != eachEvent.OwnerId ) {
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

    private Map<Id,Opportunity> finishJob(List<Opportunity> opportunityLists, Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        Map<Id,Opportunity> updateOpportunityLists = new Map<Id,Opportunity>();
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                if(oldAccountMap.get(eachOpportunity.AccountId).SME_Temporary_Customer__c ==  userExtensionMapWithUserId.get(eachOpportunity.OwnerId).Id){
                    if(eachOpportunity.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && !Account_Service.isApplication){
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

    public void executeChangeEvent(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc) {
        changeEvent(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
    }

    //private Boolean isReleaseTemporaryOwnership(Account oldAccount,Account newAccount){
    //    if(Account_Service.isApplication){
    //        return false;
    //    }else if(!String.isBlank(oldAccount.SME_Temporary_Customer__c) && String.isBlank(newAccount.SME_Temporary_Customer__c) && oldAccount.OwnerId == newAccount.OwnerId){
    //        return true;
    //    }
    //    return false;
    //}

    //private void closeTemporaryOwnWork(Map<Id,Account> oldAccountMap){
    //    List<Id> accountIdLists = new List<Id>();
    //    List<Id> userExTempIdLists = new List<Id>();
    //    List<Id> ownerIdLists = new List<Id>();
    //    for(Account eachAccount : listCurrentAccount){
    //        Account oldAccount = oldAccountMap.get(eachAccount.Id);
    //        if(isReleaseTemporaryOwnership(oldAccount,eachAccount)){
    //            accountIdLists.add(eachAccount.Id);
    //            userExTempIdLists.add(oldAccount.SME_Temporary_Customer__c);
    //        }
    //    }

    //    if(!userExTempIdLists.isEmpty()){
    //        for(User_Extension__c eacUserEx : [SELECT User__c FROM User_Extension__c WHERE Id IN :userExTempIdLists]){
    //            ownerIdLists.add(eacUserEx.User__c);
    //        }
    //    }
    //    //accountService.closeOwnEvent(accountIdLists, ownerIdLists);
    //    accountService.closeOwnJob(accountIdLists, ownerIdLists);
    //}

    private void changeAccountOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> oldAccountMap, User currentUser, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId, Map<Id,Account> newAccountMap){
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        if(possibleChangeOwnerLists.size() > 0){
            mapUserWithId = accountService.getMapUserWithId(possibleChangeOwnerLists, oldAccountMap);
            for(Account eachAccount : possibleChangeOwnerLists){
                String oldAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String newAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String segmentFromTo = GlobalUtility.isSegmentFromToString(newAccountOwnerProfile, oldAccountOwnerProfile);
                if(segmentFromTo == 'SMEtoSME'){
                    if(!Account_Service.isBulk) {
                        accountService.isSMEToSMESegment(eachAccount, mapUserWithId.get(eachAccount.OwnerId), currentUser, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                    } else {
                        accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                    }
                } else if(segmentFromTo == 'RBStoSME') {
                    accountService.isRBSToSMESegment(eachAccount, mapUserWithId.get(eachAccount.OwnerId), currentUser, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                } else {
                    accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }
                /*if(GlobalConstants.PROFILE_SME_SET.contains(oldAccountOwnerProfile) && GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile) && !Account_Service.isBulk){
                    accountService.isSMEToSMESegment(eachAccount, mapUserWithId.get(eachAccount.OwnerId), currentUser, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else if(GlobalConstants.PROFILE_SME_SET.contains(oldAccountOwnerProfile) && GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile) && Account_Service.isBulk){
                    accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else if(GlobalConstants.PROFILE_RBS_SET.contains(oldAccountOwnerProfile) && GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile)){
                    accountService.isRBSToSMESegment(eachAccount, mapUserWithId.get(eachAccount.OwnerId), currentUser, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else{
                    accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }*/
            }
        }
    }

    private void changeAccountDual(List<Account> possibleChangeDualLists, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,Account> newAccountMap){
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        if(possibleChangeDualLists.size() > 0){
            mapUserWithId = accountService.getMapUserWithId(possibleChangeDualLists, oldAccountMap);
            for(Account eachAccount : possibleChangeDualLists){
                String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                //if(Account_Service.isAFDual) oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                //if(Account_Service.isAFDual) newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                if(GlobalConstants.PROFILE_AF_SET.contains(oldAccountOwnerProfile) && 
                    !GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile)){
                    accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
                }
            }
        }
    }

    private void changeJobOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if((Account_Service.isBulk || Account_Service.isHRIS || Account_Service.isApplication || Account_Service.isRelease || Account_Service.isRequest) && possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeJob = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
            List<Opportunity> opportunityLists = getOpportunityList(possibleChangeJob);
            List<Id> possibleUserId = new List<Id>();
            for(Opportunity eachOpportunity : opportunityLists){
                possibleUserId.add(eachOpportunity.OwnerId);
            }
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(possibleUserId));
            ownAllJob(opportunityLists, newAccountMap, userExtensionMapWithUserId);
        }
    }

    private void changeProductOwner(List<Id> possibleOpportunityOwnerIdLists, List<Id> possibleOpportunityIdLists){
        if(possibleOpportunityOwnerIdLists.size() > 0 && possibleOpportunityIdLists.size() > 0){
            accountService.changeOwnJobProduct(possibleOpportunityOwnerIdLists, possibleOpportunityIdLists);
        }
    }

    private void changeApprovalProcessOwner(Map<Id, Opportunity> possibleCancelApprovalProcessByOpp){
        if(possibleCancelApprovalProcessByOpp.size() > 0){
            ApprovalProcess_Service approvalService = new ApprovalProcess_Service();
            approvalService.cancelApprovedByOpportunity(possibleCancelApprovalProcessByOpp);
        }
    }

    private void changeEvent(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if((Account_Service.isBulk || Account_Service.isHRIS || Account_Service.isApplication || Account_Service.isRelease) && possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeEvent = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
            List<Event> eventLists = getEventList(possibleChangeEvent);
            List<Id> possibleUserId = new List<Id>();
            for(Event eachEvent : eventLists){
                possibleUserId.add(eachEvent.OwnerId);
            }
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(possibleUserId));
            ownAllEvent(eventLists, newAccountMap, userExtensionMapWithUserId);
        } else if(Account_Service.isRequest && possibleChangeOwnerLists.size() > 0) {
            List<Id> possibleChangeEvent = getPossibleChangeRequest(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
            List<Event> eventLists = getEventList(possibleChangeEvent);
            closeEvent(eventLists);
        }
    }

    private List<Event> getEventList(List<Id> possibleChangeEvent){
        return [SELECT Id, WhatId,AccountId, OwnerId, Owner.Profile.Name, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :possibleChangeEvent];
    }

    private List<Opportunity> getOpportunityList(List<Id> possibleChangeJob){
        return [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name FROM Opportunity WHERE AccountId IN :possibleChangeJob];
    }

    private List<Id> getPossibleChange(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(!GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile) && 
                !GlobalConstants.PROFILE_RBS_SET.contains(newAccountOwnerProfile)){
                //if(newAccountMap.get(eachAccount.Id).Port_Pool__c != GlobalConstants.POOL){ 
                // should assign jon even POOL ex. TM Assign account to TM POOL
                    possibleChange.add(eachAccount.Id);
                //}
            }else if(oldAccountMap.get(eachAccount.Id).SME_Temporary_Customer__c != null && newAccountMap.get(eachAccount.Id).SME_Temporary_Customer__c == null){
                possibleChange.add(eachAccount.Id);
            }
        }
        return possibleChange;
    }

    private List<Id> getPossibleChangeRequest(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(GlobalConstants.PROFILE_SME_SET.contains(newAccountOwnerProfile) 
            || GlobalConstants.PROFILE_CBS_SET.contains(newAccountOwnerProfile)){
                possibleChange.add(eachAccount.Id);
            }
        }
        return possibleChange;
    }

    private void ownAllJob(List<Opportunity> opportunityLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        List<Id> opportunityIdLists = new List<Id>();
        List<Id> opportunityOwnerIdLists = new List<Id>();
        List<Opportunity> updateOpportunityLists = new List<Opportunity>();
        if(opportunityLists != null && opportunityLists.size() > 0){
            for(Opportunity eachOpportunity : opportunityLists){
                if(!GlobalConstants.PROFILE_AF_SET.contains(userExtensionMapWithUserId.get(eachOpportunity.OwnerId).User__r.Profile.Name) && 
                    !GlobalConstants.PROFILE_RBS_SET.contains(userExtensionMapWithUserId.get(eachOpportunity.OwnerId).User__r.Profile.Name)){
                    
                    if(Account_Service.isRelease || (eachOpportunity.StageName != GlobalConstants.FINISHED_DOT && eachOpportunity.StageName != GlobalConstants.FINISHED)){
                        eachOpportunity.OwnerId = newAccountMap.get(eachOpportunity.AccountId).OwnerId;
                        eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).OwnerId).Id;
                        eachOpportunity.By_Pass__c = true;
                        eachOpportunity.Resubmit_Approval__c = false;
                        eachOpportunity.Current_Team_Name__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).OwnerId).Team_Structure__c;
                        updateOpportunityLists.add(eachOpportunity);
                    }

                    opportunityIdLists.add(eachOpportunity.Id);
                    opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                    // Opp stage finish shloud not be updated
                    //updateOpportunityLists.add(eachOpportunity);
                }
            }
            possibleOpportunityIdLists = opportunityIdLists;
            possibleOpportunityOwnerIdLists = opportunityOwnerIdLists;
            possibleUpdateOpportunityLists = updateOpportunityLists;
            TriggerHandler.bypass('OpportunityTriggerHandler');
            if(!updateOpportunityLists.isEmpty()) {
                Database.update(updateOpportunityLists);
            }
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }

    private void ownAllEvent(List<Event> eventLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            Set<String> eventStatusToClosed = new Set<String>();
            for(Event eachEvent : eventLists){
                if(GlobalConstants.PROFILE_SME_SET.contains(userExtensionMapWithUserId.get(eachEvent.OwnerId).User__r.Profile.Name) && 
                    (eachEvent.Status__c != GlobalConstants.CLOSED && 
                    eachEvent.Status__c != GlobalConstants.CANCELLED && 
                    eachEvent.Status__c != GlobalConstants.REJECTED) &&
                    userExtensionMapWithUserId.containsKey(newAccountMap.get(eachEvent.AccountId).OwnerId) && 
                    userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).User__c !=NULL && 
                    userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).User__c != eachEvent.OwnerId
                ){
                    if(shouldClosedEventStatus(eachEvent)){
                        eachEvent.Status__c     = GlobalConstants.STATUS_CLOSED;
                        eachEvent.RecordTypeID  = EventService.getCloseEventRecordType(eachEvent.RecordTypeId);
                    }else{
                        eachEvent.OwnerId       = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).User__c;
                    }
                    
                    updateEventLists.add(eachEvent);
                }
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(updateEventLists);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    private void closeEvent(List<Event> eventLists) {
        if(eventLists != null && eventLists.size() > 0) {
            List<Event> closedEventList = new List<Event>();
            for(Event eachEvent : eventLists) {
                if(eachEvent.Status__c != GlobalConstants.CLOSED
                && eachEvent.Status__c != GlobalConstants.CANCELLED
                && eachEvent.Status__c != GlobalConstants.REJECTED) {
                    eachEvent.Status__c = GlobalConstants.STATUS_CLOSED;
                    eachEvent.RecordTypeId = EventService.getCloseEventRecordType(eachEvent.RecordTypeId);
                    closedEventList.add(eachEvent);
                }
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(closedEventList);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    private Boolean shouldClosedEventStatus(Event event){
        Set<String> eventStatusToClosed = new Set<String>{GlobalConstants.PLAN, GlobalConstants.CONTACTED};
        return eventStatusToClosed.contains(event.Status__c);
    }
}