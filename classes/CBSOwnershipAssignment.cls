public with sharing class CBSOwnershipAssignment {
//implements IOwnershipAssignment {
	
//    private Map<Id,User_MaskModel> userMaskMapByUserId;
//    private Map<String,Team_Structure__c> teamStructureMapByRc;
//    private Map<Id,User> userMap;
//    private User_Admin__c userAdmin;
//    private Boolean isSetAccount;

//    public CBSOwnershipAssignment(Map<Id,User_MaskModel> userMaskMapByUserId, Map<String,Team_Structure__c> teamStructureMapByRc, Map<Id,User> userMap,User_Admin__c userAdmin) {
//        this.userMaskMapByUserId = userMaskMapByUserId;
//        this.teamStructureMapByRc = teamStructureMapByRc;
//        this.userAdmin = userAdmin;
//        this.userMap = userMap;
//        this.isSetAccount = false;
//    }

//	private Boolean shouldAssignAccountOwner(User_MaskModel userMask){
//        Boolean shouldAssignNewOwner = false;
//        if(userMask.isChangeRCCode){
//            shouldAssignNewOwner = true;
//        }
//        return shouldAssignNewOwner;
//    }

//    private void setCurrentAndAssignedAccountOwner(Bulk_Assignment__c bulkAssignment,Account account){
//        User_MaskModel userMask;
//            if(userMaskMapByUserId.containsKey(account.OwnerId)){
//                userMask = userMaskMapByUserId.get(account.OwnerId);
//            if(shouldAssignAccountOwner(userMask)){
//                User assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
//                if(assignedUser == null){
//                    assignedUser = OwnershipAssignmentManager.getAdminFromUserMask(userMask,userAdmin, userMap);
//                }
//                bulkAssignment.CurrentOwner__c = account.OwnerId;
//                bulkAssignment.AssignmentOwner__c = assignedUser.id;
//                isSetAccount = true;
//            }
//        }
//    }


//	public void setBulkAssignmentInfo(BulkAssignmentWrapper bulkWrapper,Account account){
//        setCurrentAndAssignedAccountOwner(bulkWrapper.bulkAssignment, account);
// 	}
//    public Boolean isAccountSetted(){
//        return this.isSetAccount;
//    }
}