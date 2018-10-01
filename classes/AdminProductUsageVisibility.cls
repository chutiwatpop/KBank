public class AdminProductUsageVisibility implements IProductUsageVisibility {
    private Account currentAccount;
    private Boolean result;

    public AdminProductUsageVisibility(Id currentAccountId) {
        currentAccount = [SELECT Id, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Account WHERE Id =:currentAccountId];
        result = false;
    }

    public Boolean allowShowComponent() {
        if(Opportunity_Service.isAccountTeamMemberWithManager(currentAccount.Id)) {
            result = true;
        } else if(Opportunity_Service.isOpportunityTeamMemberWithManager(currentAccount.Id)) {
            result = true;
        } else if(Opportunity_Service.isOpportunityOwnerWithManager(currentAccount.Id)) {
            result = true;
        }
        return result;
    }
}