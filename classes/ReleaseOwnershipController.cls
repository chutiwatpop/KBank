global with sharing class ReleaseOwnershipController {
	global class Response{
		global Response () {
			this.success = true;
			this.UITheme = UserInfo.getUiThemeDisplayed();
		}
        @AuraEnabled
        public Customer_Ownership_Request__c customerRequest;
		@AuraEnabled
        public String UITheme{get;set;}
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public String msg{get;set;}
    }

	private static User getUserInfo() {
        User user = [SELECT Id, Profile.Name, RC_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
        return user;
    }

    private static Account getAccountInfo(String accountId) {
        return Account_Service.getAccountInformation(accountId);
    }

	@AuraEnabled
    public static Response validateReleaseOwnership(String accountId) {
        Response res = new Response();
        try {
            User currentUser = getUserInfo();
            Account accountObj = getAccountInfo(accountId);
            String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
            IReleaseOwnership releaseOwnership;
            switch on userSegment {
                when 'SME' {
                    releaseOwnership = new SMEReleaseOwnership();
                } 
                when 'CBS' {
                    releaseOwnership = new CBSReleaseOwnership();
                } 
                when 'RBS' {
                    releaseOwnership = new RBSReleaseOwnership();
                }
            }
            releaseOwnership.validateCustomer(accountObj, currentUser);
            res.msg = userSegment;
        } catch (Exception ex) {
            res.msg = ex.getMessage();
            res.success = false;
        }
        System.debug('res:' + res);
        return res;
    }

    @AuraEnabled
    public static Response createCustomerOwnershipRequest(String accountId) {
        Response res = new Response();
        try {
            User currentUser = getUserInfo();
            Account accountObj = getAccountInfo(accountId);
            res.customerRequest = new RBSReleaseOwnership().createCustomerOwnershipRequest(accountObj, currentUser);
        }catch (Exception ex) {
            res.msg = ex.getMessage();
            res.success = false;
        }
        System.debug('res:' + res);
        return res;
    }
}