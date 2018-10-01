public with sharing class SMEOwnershipAssignment implements IOwnershipAssignment {

  private Map<String, User> userMapByNewRoleRC;
  private Map<Id,User_MaskModel> userMaskMapByUserId;
  private Map<Id,User> userMap;
  private User_Admin__c userAdmin;
  private Map<String,Team_Structure__c> teamStructureMapByRc;
  private Boolean isSetAccount;

  public SMEOwnershipAssignment(Map<Id,User_MaskModel> userMaskMapByUserId, Map<String,Team_Structure__c> teamStructureMapByRc, Map<Id, User> userMap,Map<String,User> userMapByNewRoleRC, User_Admin__c userAdmin) {
      this.userMaskMapByUserId = userMaskMapByUserId;
      this.teamStructureMapByRc = teamStructureMapByRc;
      this.userMapByNewRoleRC = userMapByNewRoleRC;
      this.userMap = userMap;
      this.userAdmin = userAdmin;
      this.isSetAccount = false;
      init();
  }

  private void init(){
    setUserMapByNewRoleRC();
  }

  private void setUserMapByNewRoleRC(){
    this.userMapByNewRoleRC = new Map<String, User>();
    for(User_MaskModel userMask : this.userMaskMapByUserId.values()){
      if(userMask.isChangeRCCode || userMask.isChangeJobCode){
        User eachUser = userMask.newUserObj;
        userMapByNewRoleRC.put(eachUser.Job_Code__c + '-' + eachUser.RC_Code__c, eachUser);
      }
    }
  }

  private Boolean shouldAssignAccountOwner(User_MaskModel userMask){
      Boolean shouldAssignNewOwner = false;
      if(userMask.isChangeRCCode || userMask.isChangeToInactive){
        shouldAssignNewOwner = true;
      }
      return shouldAssignNewOwner;
  }
    

  private void setCurrentAndAssignedAccountOwner(Bulk_Assignment__c bulkAssignment,Account account){
      User_MaskModel userMask;
      if(userMaskMapByUserId.containsKey(account.OwnerId)){
          userMask = userMaskMapByUserId.get(account.OwnerId);
        if(shouldAssignAccountOwner(userMask)){
            bulkAssignment.CurrentOwner__c = account.OwnerId;
            User assignedUser = OwnershipAssignmentManager.getUserForReplacement(userMask,userMapByNewRoleRC);
            if(assignedUser == null){ 
              assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
            }
            if(assignedUser == null){
              assignedUser = OwnershipAssignmentManager.getAdminFromUserMask(userMask,userAdmin, userMap);
            }
            bulkAssignment.AssignmentOwner__c = assignedUser.id;
            isSetAccount = true;
        }
      }
  }

  private void setAssignedServiceRM(Bulk_Assignment__c bulkAssignment, Account account){
      User_MaskModel userMask;
      if(account.Service_RM__c != null){
        if(userMaskMapByUserId.containsKey(account.Service_RM__c)){
          userMask = userMaskMapByUserId.get(account.Service_RM__c);
          if(userMask.isChangeToInactive || userMask.isChangeRCCode){
              bulkAssignment.Service_RM__c = null;
              isSetAccount = true;
          }
        }else{
          bulkAssignment.Service_RM__c = account.Service_RM__c;
        }
    }
  }

  public void setBulkAssignmentInfo(BulkAssignmentWrapper bulkWrapper,Account account){
    setCurrentAndAssignedAccountOwner(bulkWrapper.bulkAssignment,account);
    setAssignedServiceRM(bulkWrapper.bulkAssignment,account);
  }
  public Boolean isAccountSetted(){
      return this.isSetAccount;
  }
}