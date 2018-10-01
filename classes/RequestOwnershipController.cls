global with sharing class RequestOwnershipController {
	global static User_Admin__c userAdmin;

	global class Response{
		global Response () {
            this.UITheme = UserInfo.getUiThemeDisplayed();
			this.success = true;
		}
        @AuraEnabled
        public String UITheme;
        @AuraEnabled
		public Customer_Ownership_Request__c customerRequest;
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public String msg{get;set;}
    }

    public static User getCurrentUserInfo() {
        return [SELECT Id, ProfileId, Profile.Name, Name, Segment__c, IsActive, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Email, Manager.Manager.Manager.Email, Manager.Manager.Manager.Profile.Name, Email, AH_Employee_ID__c, NH_Employee_ID__c, SME_User__c, CBS_User__c, RBS_User__c FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Account_Service.Response getFraudStatus(String accountIdString) {
        Account accountObj = Account_Service.getAccountInformation(accountIdString);
        Account_Service.Response fraudResp = new Account_Service.Response();
        if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME ||
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            fraudResp.success = true;
            fraudResp.colorCode = GlobalConstants.FRAUD_COLOR_BLUE;
        } else {
            fraudResp = Account_Service.getFraudStatus(accountObj);
        }
        return fraudResp;
    }

    @AuraEnabled
    public static Response validateRequestOwnership(String accountIdString) {
        Response resp = new Response();
        try {
            Account accountObj = Account_Service.getAccountInformation(accountIdString);
            User currentUser = getCurrentUserInfo();
            String userSegment = RequestOwnershipService.validateUserPermission(accountObj, currentUser);
            IRequestOwnership requestOwnership;
            switch on userSegment {
                when 'SME' {
                    requestOwnership = new SMERequestOwnership();
                } 
                when 'CBS' {
                    requestOwnership = new CBSRequestOwnership();
                } 
                when 'RBS' {
                    requestOwnership = new RBSRequestOwnership();
                }
            }
            requestOwnership.validateCustomer(accountObj, currentUser);
            requestOwnership.validateExistingRequest(accountObj, currentUser);
            resp.msg                = userSegment;
        } catch(Exception ex) {
            resp.msg = ex.getMessage();
            resp.success = false;
        }
        return resp;
    }

    @AuraEnabled
    public static Response createRequestOwnership(String accountIdString, String userSegment) {
        Response resp = new Response();
        try {
            Account accountObj = Account_Service.getAccountInformation(accountIdString);
            User currentUser = getCurrentUserInfo();
            IRequestOwnership requestOwnership;
            switch on userSegment {
                when 'SME' {
                    requestOwnership = new SMERequestOwnership();
                } 
                when 'CBS' {
                    requestOwnership = new CBSRequestOwnership();
                } 
                when 'RBS' {
                    requestOwnership = new RBSRequestOwnership();
                }
            }
            resp.customerRequest    = requestOwnership.createCustomerOwnershipRequest(accountObj, currentUser);
        } catch(Exception ex) {
            resp.msg = ex.getMessage();
            resp.success = false;
        }
        return resp;
    }
}