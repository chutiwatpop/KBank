public class CBSProductUsageVisibility implements IProductUsageVisibility {
    private Account currentAccount;
    private User currentUser;
    private Boolean result;

    public CBSProductUsageVisibility(Id currentAccountId) {
        currentAccount = [SELECT Id, Is_SME_Customer__c, Is_CBS_Customer__c, is_RBS__c, Is_AF_Customer__c, Port_Pool__c, Primary_Segment_Code__c, Dual_RM_Name__c, Secondary_Segment_Code__c, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId, Owner.Manager.Manager.Manager.ManagerId FROM Account WHERE Id =:currentAccountId];
        currentUser = [SELECT Id, RC_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        result = false;
    }

    public Boolean allowShowComponent() {
        if(currentAccount.Port_Pool__c == GlobalConstants.PORT) {
            if(Account_Service.isSameSegment(currentAccount, currentUser) && Account_Service.isOwnerWithManager(currentAccount)) {
                result = true;
            } else if(currentAccount.Dual_RM_Name__c != null && isDualSegment(currentAccount)) {
                result = true;
            } else if(Opportunity_Service.isAccountTeamMemberWithManager(currentAccount.Id)) {
                result = true;
            } else if(isOpportunityOwnerWithManager(currentAccount.Id)) {
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

    private Boolean isOpportunityOwnerWithManager(Id accountId) {
        List<Opportunity> listOpportunity = [SELECT Id, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Opportunity WHERE AccountId = :accountId AND Owner.Profile.Name LIKE 'CBS-%'];
        for(Opportunity eachOpportunity : listOpportunity) {
            if(eachOpportunity.OwnerId == UserInfo.getUserId() || (!String.isBlank(eachOpportunity.Owner.ManagerId) && eachOpportunity.Owner.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.ManagerId) && eachOpportunity.Owner.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.Manager.ManagerId) && eachOpportunity.Owner.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }
}