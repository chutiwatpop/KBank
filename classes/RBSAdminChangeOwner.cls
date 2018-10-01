public class RBSAdminChangeOwner implements IOwnerExecution {
    AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
    List<Account> possibleChangeDualLists = new List<Account>();
    List<Account> possibleChangeAFTempLists = new List<Account>();
    List<Id> possibleOpportunityIdLists = new List<Id>();
    List<Id> possibleOpportunityOwnerIdLists = new List<Id>();
    List<Opportunity> possibleUpdateOpportunityLists = new List<Opportunity>();
    Map<Id, Opportunity> possibleCancelApprovalProcessByOpp = new Map<Id, Opportunity>();
    Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();

    public RBSAdminChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser){
        Account_Service.isAdminChange = true;
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        possibleChangeDualLists = accountService.possibleChangeDual(accountLists, oldAccountMap);
        possibleChangeAFTempLists = accountService.possibleChangeAFTemp(accountLists, oldAccountMap);
    }

    public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        possibleUserExtensionMapWithUserId = userExtensionMapWithUserId;
        changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId, newAccountMap);
        changeAccountDual(possibleChangeOwnerLists, oldAccountMap, userExtensionMapWithUserId, newAccountMap);
        Account_Service.isAFDual = true;
        changeAccountDual(possibleChangeDualLists, oldAccountMap, userExtensionMapWithUserId, newAccountMap);
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

    private void changeAccountOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> oldAccountMap, User currentUser, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId, Map<Id,Account> newAccountMap){
        String fromTo = '';
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        if(possibleChangeOwnerLists.size() > 0){
            mapUserWithId = accountService.getMapUserWithId(possibleChangeOwnerLists, oldAccountMap);
            
            for(Account eachAccount : possibleChangeOwnerLists){
                String oldAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String newAccountOwnerProfile = possibleUserExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
                String segmentFromTo = GlobalUtility.isSegmentFromToString(newAccountOwnerProfile, oldAccountOwnerProfile);
                fromTo = segmentFromTo;
                if(segmentFromTo == 'RBStoRBS'){
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
                if(Account_Service.isAFDual) newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
                if(GlobalConstants.PROFILE_AF_SET.contains(oldAccountOwnerProfile) && !GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile)){
                    accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
                }else if(Account_Service.isAFDual){
                    accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
                }
            }
        }
    }

    private void changeJobOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if((Account_Service.isBulk || Account_Service.isHRIS) && possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeJob = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Opportunity> opportunityLists = getOpportunityList(possibleChangeJob);
            List<Id> possibleUserId = new List<Id>();
            for(Opportunity eachOpportunity : opportunityLists){
                possibleUserId.add(eachOpportunity.OwnerId);
            }
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(possibleUserId));
            ownAllJob(opportunityLists, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
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
        if((Account_Service.isBulk || Account_Service.isHRIS) && possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeEvent = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
            List<Event> eventLists = getEventList(possibleChangeEvent);
            List<Id> possibleUserId = new List<Id>();
            for(Event eachEvent : eventLists){
                possibleUserId.add(eachEvent.OwnerId);
            }
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(possibleUserId));
            ownAllEvent(eventLists, newAccountMap, userExtensionMapWithUserId, userExtensionMapWithId);
        }
    }

    private List<Event> getEventList(List<Id> possibleChangeEvent){
        return [SELECT Id, AccountId, OwnerId, Owner.Profile.Name, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :possibleChangeEvent];
    }

    private List<Opportunity> getOpportunityList(List<Id> possibleChangeJob){
        return [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name FROM Opportunity WHERE AccountId IN :possibleChangeJob];
    }

    private List<Id> getPossibleChange(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(Account_Service.isAFDual) oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(Account_Service.isAFDual) newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
            if(Account_Service.isAFTemp && oldAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c != null && newAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c != null) {
                newAccountOwnerProfile = userExtensionMapWithId.get(newAccountMap.get(eachAccount.Id).AF_Temporary_Customer__c).User__r.Profile.Name;
            }

            if(GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile)){
                if(Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool_Dual_RM__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }else if (!Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }else if (!Account_Service.isAFDual && Account_Service.isAFTemp){
                    possibleChange.add(eachAccount.Id);
                }else if( userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.IsActive != true){
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
                if(GlobalConstants.PROFILE_AF_SET.contains(userExtensionMapWithUserId.get(eachOpportunity.OwnerId).User__r.Profile.Name)){
                    if(Account_Service.isAFDual){
                        eachOpportunity.OwnerId = newAccountMap.get(eachOpportunity.AccountId).Dual_RM_Name__c;
                        eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).Dual_RM_Name__c).Id;
                    }else if(Account_Service.isAFTemp && newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c != null){
                        eachOpportunity.OwnerId = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c).User__c;
                        eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithId.size() == 0 ? null : userExtensionMapWithId.get(newAccountMap.get(eachOpportunity.AccountId).AF_Temporary_Customer__c).Id;
                    }else{
                        eachOpportunity.OwnerId = newAccountMap.get(eachOpportunity.AccountId).OwnerId;
                        eachOpportunity.Current_Owner_Extension__c = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachOpportunity.AccountId).OwnerId).Id;
                    }
                    eachOpportunity.By_Pass__c = true;
                    eachOpportunity.Resubmit_Approval__c = false;
                        
                    if(eachOpportunity.StageName == GlobalConstants.REOPEN){
                        eachOpportunity.StageName = GlobalConstants.FINISHED;
                        cancelApprovalProcessByOpp.put(eachOpportunity.Id, eachOpportunity);
                    }
                    opportunityIdLists.add(eachOpportunity.Id);
                    opportunityOwnerIdLists.add(eachOpportunity.OwnerId);
                    updateOpportunityLists.add(eachOpportunity);
                }
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
}