public without sharing class RequestOwnershipService {
    public static String validateUserPermission(Account accountObj, User currentUser) {
        String userSegment;
        if(GlobalConstants.PROFILE_RBS_SALE_SET.contains(currentUser.Profile.Name)) {
            userSegment = 'RBS';
        } else if(GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)) {
            userSegment = 'CBS';
            if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(accountObj.OwnerId != UserManager.getUserAdmin().CBS_User_ID__c) {
                    throw new OwnershipException(Label.CBS_Can_Request_Customer_from_CBS_Admin);
                }
            }
        } else if(currentUser.Profile.Name == GlobalConstants.SME_RM) {
            userSegment = 'SME';
            if (accountObj.SME_Temporary_Customer__c == currentUser.Id) {
                throw new OwnershipException('This customer already in your temporary.');
            } else if(accountObj.OwnerId == currentUser.Id) {
                throw new OwnershipException('This customer already in your port.');
            }
        } else if(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)) {
            throw new OwnershipException(Label.AF_CantReleaseRequestOwnership);
        } else {
            throw new OwnershipException(Label.Request_Ownership_Error_User);
        }
        return userSegment;
    }

    public static void updateRequesterFields(Customer_Ownership_Request__c requestObj, User requester) {
        UserApproverModel requesterWrapper = UserApproverModel.getUserApproverHierachy(requester);
        requestObj.Requestor_TM__c = requesterWrapper.getApproverIdFromProfile(new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM});
        requestObj.Requestor_AH__c = requesterWrapper.getApproverIdFromProfile(new Set<String>{GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL});
        requestObj.Requestor_NH__c = requesterWrapper.getApproverIdFromProfile(new Set<String>{GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
    }

    public static void updateApproverFields(Customer_Ownership_Request__c requestObj, User currentAccountOwner) {
        UserApproverModel approverUserWrapper = UserApproverModel.getUserApproverHierachy(currentAccountOwner);
        requestObj.Current_Owner_TM__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM});
        requestObj.Current_Owner_AH__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL});
        requestObj.Current_Owner_NH__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
    }

    public class OwnershipException extends Exception{}
}