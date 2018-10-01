public class ProductUsageVisibilityService {
    private Account accountObj;

    public ProductUsageVisibilityService(Id accountId) {
        try {
            accountObj = [SELECT Id, Owner.Profile.Name, Primary_Segment_Code__c, Is_CBS_Customer__c, is_RBS__c, Is_AF_Customer__c FROM Account WHERE Id=:accountId];
        } catch(QueryException e) {
            accountObj = null;
        }
    }

    public Boolean isVisible() {
        if(accountObj == null) {
            return false;
        }
        String primarySegment = accountObj.Primary_Segment_Code__c;
        String profileName = accountObj.Owner.Profile.Name;
        IProductUsageVisibility productUsageVisibility;
        
        if(primarySegment == 'HN') {
            return false;
        } else if(!GlobalConstants.PROFILE_CBS_SET.contains(profileName)
               && !GlobalConstants.PROFILE_SME_SET.contains(profileName)
               && !GlobalConstants.PROFILE_RBS_SET.contains(profileName)
               && !GlobalConstants.PROFILE_AF_SET.contains(profileName)
               && !GlobalConstants.PROFILE_AN_SET.contains(profileName)) {
            productUsageVisibility = new AdminProductUsageVisibility(accountObj.Id);
        } else if(accountObj.Is_CBS_Customer__c) {
            productUsageVisibility = new CBSProductUsageVisibility(accountObj.Id);
        } else if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(primarySegment)) {
            productUsageVisibility = new SMEProductUsageVisibility(accountObj.Id);
        } else if(accountObj.is_RBS__c || (accountObj.Is_AF_Customer__c && profileName == 'RBS-Admin')) {
            productUsageVisibility = new RBSProductUsageVisibility(accountObj.Id);
        } else if(accountObj.Is_AF_Customer__c) {
            productUsageVisibility = new AFProductUsageVisibility(accountObj.Id);
        } else {
            productUsageVisibility = new AdminProductUsageVisibility(accountObj.Id);
        }
        
        return productUsageVisibility.allowShowComponent();
    }
}