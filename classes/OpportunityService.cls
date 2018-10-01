public with sharing class OpportunityService {
	private static IOpportunityServiceSegment serviceSegmentManager;

	public static void validateCreatePermission(Opportunity eachOpportunity, Map<Id, Account> accountMap) {
		//getServiceSegmentManager().validateCreatePermission(eachOpportunity, accountMap);
	}

	public static void takeTemporaryOwnership(Opportunity eachOpportunity, Map<Id, Account> accountMap) {
		//getServiceSegmentManager().takeTemporaryOwnership(eachOpportunity, accountMap);
	}

	//private static IOpportunityService getUserManager(){
	//	return UserManager.getInstance();
	//}

	private static IOpportunityServiceSegment getServiceSegmentManager(){
		//if(serviceSegmentManager == null) {
		//	User currentUser = UserService.getCurrentUserInfo();
		//	if(GlobalConstants.PROFILE_SME_SET.contains(currentUser.Profile.Name)) {
		//        return new SMEUserManager();
		//    } else if(GlobalConstants.PROFILE_CBS_SET.contains(currentUser.Profile.Name)) {
		//        return new CBSUserManager();
		//    } else if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name)) {
		//    	return new RBSUserManager();
		//    } else if(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)) {
		//    	return new AFUserManager();
		//    }
		//}
		return serviceSegmentManager;
	}
}