public class AFChangeOwner implements IOwnerExecution {
    AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
    List<Account> possibleChangeDualLists = new List<Account>();
    List<Id> possibleOpportunityIdLists = new List<Id>();
    List<Id> possibleOpportunityOwnerIdLists = new List<Id>();
    List<Opportunity> possibleUpdateOpportunityLists = new List<Opportunity>();
    Map<Id,User> possibleUserMap = new Map<Id,User>();
    Map<Id, Opportunity> possibleCancelApprovalProcessByOpp = new Map<Id, Opportunity>();
    Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();

    public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        possibleUserExtensionMapWithUserId = userExtensionMapWithUserId;
        changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId);
        changeAccountDual(possibleChangeDualLists, oldAccountMap);
    }

    public void executeChangeJob(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        changeJobOwner(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = true;
        changeJobOwner(possibleChangeDualLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        changeProductOwner(possibleOpportunityOwnerIdLists, possibleOpportunityIdLists);
        changeApprovalProcessOwner(possibleCancelApprovalProcessByOpp);
    }

    public void executeChangeEvent(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        Account_Service.isAFDual = false;
        changeEvent(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        Account_Service.isAFDual = true;
        changeEvent(possibleChangeDualLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
    }

    public AFChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser){
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        possibleChangeDualLists = accountService.possibleChangeDual(accountLists, oldAccountMap);
    }

    private void changeAccountOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> oldAccountMap, User currentUser, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        String fromTo = '';
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        mapUserWithId = accountService.getMapUserWithId(possibleChangeOwnerLists, oldAccountMap);
        
        for(Account eachAccount : possibleChangeOwnerLists){
            if(isValidatePass(eachAccount, oldAccountMap, possibleUserExtensionMapWithUserId, currentUser)){
                String segmentFromTo = GlobalUtility.isSegmentFromTo(mapUserWithId.get(eachAccount.OwnerId),mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId));
                fromTo = segmentFromTo;
                if(segmentFromTo == 'AFtoAF'){
                    accountService.isAFToAFSegment(eachAccount, mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId), mapUserWithId.get(eachAccount.OwnerId), oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }else{
                    accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
                }
            }
        }
    }

    private void changeAccountDual(List<Account> possibleChangeDualLists, Map<Id,Account> oldAccountMap){
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        mapUserWithId = accountService.getMapUserWithId(possibleChangeDualLists, oldAccountMap);
        for(Account eachAccount : possibleChangeDualLists){
            accountService.updateDualSegment(eachAccount, oldAccountMap, mapUserWithId);
        }
    }

    private void changeJobOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){
        if(Account_Service.isBulk && possibleChangeOwnerLists.size() > 0){
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
        if(Account_Service.isBulk && possibleChangeOwnerLists.size() > 0){
            List<Id> possibleChangeEvent = getPossibleChange(possibleChangeOwnerLists, newAccountMap, oldAccountMap, userExtensionMapWithUserId);
            List<Event> eventLists = getEventList(possibleChangeEvent);
            List<Id> possibleUserId = new List<Id>();
            for(Event eachEvent : eventLists){
                possibleUserId.add(eachEvent.OwnerId);
            }
            userExtensionMapWithUserId.putAll(UserExtension_Service.getUserExtensionMapByUserId(possibleUserId));
            ownAllEvent(eventLists, newAccountMap, userExtensionMapWithUserId);
        }
    }

    private List<Event> getEventList(List<Id> possibleChangeEvent){
        return [SELECT Id, AccountId, OwnerId, Owner.Profile.Name, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :possibleChangeEvent];
    }

    private List<Opportunity> getOpportunityList(List<Id> possibleChangeJob){
        return [SELECT Id, AccountId, OwnerId, StageName, Jobstage__c , By_Pass__c, Owner.Profile.Name FROM Opportunity WHERE AccountId IN :possibleChangeJob];
    }

    private List<Id> getPossibleChange(List<Account> possibleChangeOwnerLists, Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        List<Id> possibleChange = new List<Id>();
        for(Account eachAccount : possibleChangeOwnerLists){
            //String oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            //if(Account_Service.isAFDual) oldAccountOwnerProfile = userExtensionMapWithUserId.get(oldAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
            String newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).OwnerId).User__r.Profile.Name;
            if(Account_Service.isAFDual) newAccountOwnerProfile = userExtensionMapWithUserId.get(newAccountMap.get(eachAccount.Id).Dual_RM_Name__c).User__r.Profile.Name;
            if(GlobalConstants.PROFILE_AF_SET.contains(newAccountOwnerProfile)){
                if(Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool_Dual_RM__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }else if (!Account_Service.isAFDual && newAccountMap.get(eachAccount.Id).Port_Pool__c != GlobalConstants.POOL){
                    possibleChange.add(eachAccount.Id);
                }
            }
        }
        return possibleChange;
    }

    private void ownAllJob(List<Opportunity> opportunityLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
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

    private void ownAllEvent(List<Event> eventLists, Map<Id,Account> newAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId){
        if(eventLists != null && eventLists.size() > 0){
            List<Event> updateEventLists = new List<Event>();
            for(Event eachEvent : eventLists){
                if(GlobalConstants.PROFILE_AF_SET.contains(userExtensionMapWithUserId.get(eachEvent.OwnerId).User__r.Profile.Name)){
                    if(Account_Service.isAFDual){
                        eachEvent.OwnerId = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).Dual_RM_Name__c).User__c;
                    }else{
                        eachEvent.OwnerId = userExtensionMapWithUserId.size() == 0 ? null : userExtensionMapWithUserId.get(newAccountMap.get(eachEvent.AccountId).OwnerId).User__c;
                    }
                    updateEventLists.add(eachEvent);
                }
            }
            TriggerHandler.bypass('EventTriggerHandler');
            Database.update(updateEventLists);
            TriggerHandler.clearBypass('EventTriggerHandler');
        }
    }

    private Boolean isValidatePass(Account accountObj, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId, User currentUser){
        if(Account_Service.isBulk || Account_Service.isConvertLead){
            return true;
        }else if(oldAccountMap.get(accountObj.Id).Temporary_Customer__c == true ){
            return true;
        }else if(isSameAsTemporary(accountObj, possibleUserExtensionMapWithUserId)){
            accountObj.AF_Temporary_Customer__c = null;
            return true;
        }
        accountObj.addError(ExceptionMessage.CANNOT_UPDATE_TRANSACTION);
        return false;
    }

    private Boolean isSameAsTemporary(Account accountObj, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        if(accountObj.AF_Temporary_Customer__c == possibleUserExtensionMapWithUserId.get(accountObj.OwnerId).Id){
            return true;
        }else if(accountObj.AF_Temporary_Customer__c == null){
            return true;
        }
        return false;
    }

    private Boolean isSameRmSegment(Account accountObj, Set<String> rmSegment){
        if(rmSegment.contains(accountObj.Customer_Segment_Code__c)){
            return true;
        }
        return false;
    }
}