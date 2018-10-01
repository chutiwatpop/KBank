public class RBSProductUsageVisibility implements IProductUsageVisibility {
    private Account currentAccount;
    private User currentUser;
    private Boolean result;
    private Boolean isDual;

    public RBSProductUsageVisibility(Id currentAccountId) {
        this(currentAccountId, false);
    }
    
    public RBSProductUsageVisibility(Id currentAccountId, Boolean isDual) {
        if(isDual) {
            currentAccount = [SELECT Id, Dual_RM_Name__c, Dual_RM_Name__r.RC_Code__c, Dual_RM_Name__r.ManagerId, Dual_RM_Name__r.Manager.ManagerId, Dual_RM_Name__r.Manager.Manager.ManagerId FROM Account WHERE Id = :currentAccountId];
        } else {
            currentAccount = [SELECT Id, Is_SME_Customer__c, Is_CBS_Customer__c, is_RBS__c, Is_AF_Customer__c, Primary_Segment_Code__c, OwnerId, Owner.RC_Code__c, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Account WHERE Id = :currentAccountId];
        }
        this.isDual = isDual;
        currentUser = [SELECT Id, RC_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        result = false;
    }

    public Boolean allowShowComponent() {
        if(isDual) {
            /*if(Account_Service.isDualOwnerWithManager(currentAccount)) {
                result = true;
            } else if(currentAccount.Dual_RM_Name__r.RC_Code__c == currentUser.RC_Code__c) {
                result = true;
            } else*/ if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name)) {
                result = true;
            }
        } else {
            Boolean isSameSegment = Account_Service.isSameSegment(currentAccount, currentUser);
            if(isSameSegment && Account_Service.isOwnerWithManager(currentAccount)) {
                result = true;
            } else if(isAccountTeamMemberWithManager(currentAccount.Id)) {
                result = true;
            } else if(isOpportunityTeamMemberWithManager(currentAccount.Id)) {
                result = true;
            } else if(isSameSegment && currentAccount.Owner.RC_Code__c == currentUser.RC_Code__c) {
                result = true;
            } else if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name)) {
                result = true;
            }
        }
        return result;
    }

    private Boolean isAccountTeamMemberWithManager(Id accountId) {
        List<AccountTeamMember> listAccountTeamMember = [SELECT Id, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM AccountTeamMember WHERE AccountAccessLevel != 'None' AND AccountId = :accountId AND CreatedBy.Profile.Name LIKE 'RBS-%'];
        for(AccountTeamMember eachAccountTeamMember : listAccountTeamMember) {
            if(eachAccountTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachAccountTeamMember.User.ManagerId) && eachAccountTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.ManagerId) && eachAccountTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.Manager.ManagerId) && eachAccountTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }

    private Boolean isOpportunityTeamMemberWithManager(Id accountId) {
        List<OpportunityTeamMember> listOpportunityTeamMember = [SELECT Id, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM OpportunityTeamMember WHERE OpportunityAccessLevel != 'None' AND Opportunity.AccountId = :accountId AND Opportunity.StageName != :GlobalConstants.FINISHED AND Opportunity.Owner.Profile.Name LIKE 'RBS-%'];
        for(OpportunityTeamMember eachOpportunityTeamMember : listOpportunityTeamMember) {
            if(eachOpportunityTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachOpportunityTeamMember.User.ManagerId) && eachOpportunityTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }

    /*private Boolean isOpportunityOwnerWithManager(Id accountId) {
        List<Opportunity> listOpportunity = [SELECT Id, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Opportunity WHERE AccountId = :accountId AND StageName != :GlobalConstants.FINISHED AND Owner.Profile.Name LIKE 'RBS-%'];
        for(Opportunity eachOpportunity : listOpportunity) {
            if(eachOpportunity.OwnerId == UserInfo.getUserId() || (!String.isBlank(eachOpportunity.Owner.ManagerId) && eachOpportunity.Owner.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.ManagerId) && eachOpportunity.Owner.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.Manager.ManagerId) && eachOpportunity.Owner.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }*/
}