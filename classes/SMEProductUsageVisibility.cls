public class SMEProductUsageVisibility implements IProductUsageVisibility {
    private Account currentAccount;
    private User currentUser;
    private Boolean result;

    public SMEProductUsageVisibility(Id currentAccountId) {
        currentAccount = [SELECT Id, Is_SME_Customer__c, Is_CBS_Customer__c, is_RBS__c, Is_AF_Customer__c, Port_Pool__c, Primary_Segment_Code__c, Dual_RM_Name__c, Secondary_Segment_Code__c, Service_RM__c, OwnerId, Owner.Profile.Name, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Owner.RC_Code__c, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId, Owner.Manager.Manager.Manager.ManagerId FROM Account WHERE Id = :currentAccountId];
        currentUser = [SELECT Id, RC_Code__c, Profile.Name, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
        result = false;
    }

    public Boolean allowShowComponent() {
        Boolean isSameSegment = Account_Service.isSameSegment(currentAccount, currentUser);
        if(isSameSegment && Account_Service.isOwnerWithManager(currentAccount)) {
            result = true;
        } else if(currentAccount.Dual_RM_Name__c != null && isDualSegment(currentAccount)) {
            result = true;
        } else if(currentAccount.Port_Pool__c == GlobalConstants.POOL && currentAccount.Service_RM__c != null && isServiceRMWithManager(currentAccount.Service_RM__c)) {
            result = true;
        } else if(isAccountTeamMemberWithManager(currentAccount)) {
            result = true;
        } else if(isOpportunityTeamMemberWithManager(currentAccount)) {
            result = true;
        } else if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name)) {
            result = true;
        } else if(!GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(currentAccount.Secondary_Segment_Code__c)) {
            if(currentAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN && isUserSegment(currentUser.Profile.Name)) {
                result = true;
            } else if(currentAccount.Port_Pool__c == GlobalConstants.POOL && isSameSegment && (currentAccount.Owner.RC_Code__c == currentUser.RC_Code__c || Account_Service.isSamePoolVisibility(currentAccount, currentUser))) {
                result = true;
            }
        }
        return result;
    }

    private Boolean isDualSegment(Account currentAccount) {
        IProductUsageVisibility productUsageComponent;
        if(GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET.contains(currentAccount.Secondary_Segment_Code__c)) {
            productUsageComponent = new RBSProductUsageVisibility(currentAccount.Id, true);
            return productUsageComponent.allowShowComponent();
        } else if(GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(currentAccount.Secondary_Segment_Code__c)) {
            productUsageComponent = new AFProductUsageVisibility(currentAccount.Id, true);
            return productUsageComponent.allowShowComponent();
        }
        return false;
    }

    private Boolean isServiceRMWithManager(Id serviceRMId) {
        User serviceRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE Id =:serviceRMId];
        if(serviceRM.Id == UserInfo.getUserId() || (!String.isBlank(serviceRM.ManagerId) && serviceRM.ManagerId == UserInfo.getUserId()) || (!String.isBlank(serviceRM.Manager.ManagerId) && serviceRM.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(serviceRM.Manager.Manager.ManagerId) && serviceRM.Manager.Manager.ManagerId == UserInfo.getUserId())) {
            return true;
        }
        return false;
    }

    private Boolean isAccountTeamMemberWithManager(Account currentAccount) {
        List<AccountTeamMember> listAccountTeamMember = [SELECT Id, CreatedById, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM AccountTeamMember WHERE AccountAccessLevel != 'None' AND AccountId = :currentAccount.Id AND CreatedBy.Profile.Name LIKE 'SME-%'];
        Set<Id> userIdSet = new Set<Id>();
        for(AccountTeamMember eachAccountTeamMember : listAccountTeamMember) {
            userIdSet.add(eachAccountTeamMember.CreatedById);
        }
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id, RC_Code__c, Profile.Name, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE Id IN :userIdSet]);
        for(AccountTeamMember eachAccountTeamMember : listAccountTeamMember) {
            Boolean isAddByAllowUser = false;
            User userCreated = mapUser.get(eachAccountTeamMember.CreatedById);
            Boolean isSameSegment = Account_Service.isSameSegment(currentAccount, userCreated);
            if(isSameSegment && currentAccount.OwnerId == userCreated.Id) {
                isAddByAllowUser = true;
            } else if(!GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(currentAccount.Secondary_Segment_Code__c)) {
                if(currentAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN) {
                    isAddByAllowUser = true;
                } else if(currentAccount.Port_Pool__c == GlobalConstants.POOL && isSameSegment && (currentAccount.Owner.RC_Code__c == userCreated.RC_Code__c || Account_Service.isSamePoolVisibility(currentAccount, userCreated))) {
                    isAddByAllowUser = true;
                }
            }
            if(isAddByAllowUser && (eachAccountTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachAccountTeamMember.User.ManagerId) && eachAccountTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.ManagerId) && eachAccountTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.Manager.ManagerId) && eachAccountTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId()))) {
                return true;
            }
        }
        return false;
    }

    private Boolean isOpportunityTeamMemberWithManager(Account currentAccount) {
        List<OpportunityTeamMember> listOpportunityTeamMember = [SELECT Id, Opportunity.OwnerId, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM OpportunityTeamMember WHERE OpportunityAccessLevel != 'None' AND Opportunity.AccountId = :currentAccount.Id AND Opportunity.StageName != :GlobalConstants.FINISHED AND Opportunity.Owner.Profile.Name LIKE 'SME-%'];
        Set<Id> userIdSet = new Set<Id>();
        for(OpportunityTeamMember eachOpportunityTeamMember : listOpportunityTeamMember) {
            userIdSet.add(eachOpportunityTeamMember.Opportunity.OwnerId);
        }
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id, RC_Code__c, Profile.Name, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE Id IN :userIdSet]);
        for(OpportunityTeamMember eachOpportunityTeamMember : listOpportunityTeamMember) {
            Boolean isAddByAllowUser = false;
            User userCreated = mapUser.get(eachOpportunityTeamMember.Opportunity.OwnerId);
            Boolean isSameSegment = Account_Service.isSameSegment(currentAccount, userCreated);
            if(isSameSegment && currentAccount.OwnerId == userCreated.Id) {
                isAddByAllowUser = true;
            } else if(!GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(currentAccount.Secondary_Segment_Code__c)) {
                if(currentAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN) {
                    isAddByAllowUser = true;
                } else if(currentAccount.Port_Pool__c == GlobalConstants.POOL && isSameSegment && (currentAccount.Owner.RC_Code__c == userCreated.RC_Code__c || Account_Service.isSamePoolVisibility(currentAccount, userCreated))) {
                    isAddByAllowUser = true;
                }
            }
            if(isAddByAllowUser && (eachOpportunityTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachOpportunityTeamMember.User.ManagerId) && eachOpportunityTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId()))) {
                return true;
            }
        }
        return false;
    }

    /*private Boolean isOpportunityOwnerWithManager(Account currentAccount) {
        List<Opportunity> listOpportunity = [SELECT Id, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Opportunity WHERE AccountId = :currentAccount.Id AND StageName != :GlobalConstants.FINISHED AND Owner.Profile.Name LIKE 'SME-%'];
        Set<Id> userIdSet = new Set<Id>();
        for(Opportunity eachOpportunity : listOpportunity) {
            userIdSet.add(eachOpportunity.OwnerId);
        }
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id, RC_Code__c, Profile.Name, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE Id IN :userIdSet]);
        for(Opportunity eachOpportunity : listOpportunity) {
            Boolean isAddByAllowUser = false;
            User userCreated = mapUser.get(eachOpportunity.OwnerId);
            Boolean isSameSegment = Account_Service.isSameSegment(currentAccount, userCreated);
            if(currentAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN) {
                isAddByAllowUser = true;
            } else if(isSameSegment && currentAccount.OwnerId == userCreated.Id) {
                isAddByAllowUser = true;
            } else if(currentAccount.Port_Pool__c == GlobalConstants.POOL && isSameSegment && (currentAccount.Owner.RC_Code__c == userCreated.RC_Code__c || Account_Service.isSamePoolVisibility(currentAccount, userCreated))) {
                isAddByAllowUser = true;
            }
            if(isAddByAllowUser && (eachOpportunity.OwnerId == UserInfo.getUserId() || (!String.isBlank(eachOpportunity.Owner.ManagerId) && eachOpportunity.Owner.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.ManagerId) && eachOpportunity.Owner.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.Manager.ManagerId) && eachOpportunity.Owner.Manager.Manager.ManagerId == UserInfo.getUserId()))) {
                return true;
            }
        }
        return false;
    }*/

    private Boolean isUserSegment(String profileName) {
        if(GlobalConstants.PROFILE_CBS_SET.contains(profileName) || GlobalConstants.PROFILE_SME_SET.contains(profileName) || GlobalConstants.PROFILE_RBS_SET.contains(profileName) || GlobalConstants.PROFILE_AF_SET.contains(profileName) || GlobalConstants.PROFILE_AN_SET.contains(profileName)) {
            return true;
        }
        return false;
    }
}