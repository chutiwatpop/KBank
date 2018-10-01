/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
*/
public class UserTriggerHandler extends TriggerHandler{
    @TestVisible
    public static Boolean isByPass = false;
    private Set<Id> profileRMId;
    public override void allBefore(){
        if(User_Service.allOldUserMap == null){
            User_Service.allOldUserMap = new Map<Id, User>([SELECT Id, Name, Current_Opportunity_Approval__c,Status__c, FirstName, LastName, UserRole.Name, Profile.Name, ProfileId, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c,NH_RC_Code__c FROM User]);
        }
        User_Service.inActiveUserManager        = new Set<Id>();
        User_Service.salesUserNotInTriggerMap   = new Map<Id, User>();
        User_Service.salesUserInTriggerMap      = new Map<Id, User>();
    }

    public override void beforeInsert() {
        for(User eachUser : (List<User>) Trigger.new){
            // Setup user default field
            eachUser.LanguageLocaleKey  = 'th';
            eachUser.LocaleSidKey       = 'th_TH';
            eachUser.EmailEncodingKey   = 'UTF-8';
            eachUser.TimeZoneSidKey     = 'Asia/Bangkok';
        }
    }

    public override void afterInsert() {
        List<String> newUserIds = new List<String>();
        for(User eachUser : (List<User>) Trigger.new){
            newUserIds.add(eachUser.Id);
        }
        if(!isByPass) {
            UserService.createUpdateUserReleatedObject(newUserIds);
        }
    }

    public override void beforeUpdate() {
        // Opportunity Approval Logic
        Set<String> profileSaleName     = new Set<String>{GlobalConstants.SME_RM, GlobalConstants.SME_TM, GlobalConstants.AN_RM, GlobalConstants.AN_TM, GlobalConstants.RBS_RM_ABM, GlobalConstants.RBS_RM_BAR};
        Set<String> profileManagerName  = new Set<String>{GlobalConstants.SME_AH, GlobalConstants.SME_NH, GlobalConstants.AN_AH, GlobalConstants.AN_NH, GlobalConstants.RBS_TM, GlobalConstants.RBS_AH, GlobalConstants.RBS_NH};

        Map<Id, Profile> profileMap   = User_Service.getAllProfile();
        Map<Id, UserRole> userRoleMap = User_Service.getAllUserRole();
        Map<Id,User> userNewMap = (Map<Id,User>) Trigger.newMap;

        for(User eachUser : userNewMap.values()){
            User targetUser = User_Service.allOldUserMap.get(eachUser.Id);
            User oldUser = (User) Trigger.oldMap.get(eachUser.Id);
            if(userRoleMap.containsKey(eachUser.UserRoleId)){
                if(userRoleMap.get(eachUser.UserRoleId).Name != GlobalConstants.SME_FRANCHISE){
                    //if(profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_AH || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_NH || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.AN_AH || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.AN_NH){
                    if(profileManagerName.contains(profileMap.get(eachUser.ProfileId).Name)) {
                        if((eachUser.IsActive == false && (eachUser.IsActive != oldUser.IsActive)) || eachUser.RC_Code__c != oldUser.RC_Code__c){
                            eachUser.IsActive = true;
                            User_Service.inActiveUserManager.add(eachUser.Id);
                        }
                    }
                    //if(profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_RM || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_TM || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.AN_RM || profileMap.get(eachUser.ProfileId).Name == GlobalConstants.AN_TM){
                    if(profileSaleName.contains(profileMap.get(eachUser.ProfileId).Name)) {
                        if(targetUser != null){
                            if(targetUser.Current_Opportunity_Approval__c == eachUser.Current_Opportunity_Approval__c){
                           	    User_Service.salesUserInTriggerMap.put(eachUser.Id,eachUser);
                       	    }
                        }
                    }
                    if(eachUser.RC_Code__c != oldUser.RC_Code__c || eachUser.AH_RC_Code__c != oldUser.AH_RC_Code__c || eachUser.NH_RC_Code__c != oldUser.NH_RC_Code__c){
                        eachUser.Current_Opportunity_Approval__c = null;
                    }
                }
            }
        }

        User_Service.salesUserNotInTriggerMap = new Map<Id,User>([SELECT Id, Current_Opportunity_Approval__c FROM User WHERE Current_Opportunity_Approval__c IN: User_Service.inActiveUserManager AND Id NOT IN: Trigger.newMap.keySet()]);
        if(!User_Service.salesUserNotInTriggerMap.isEmpty()){
            clearCurrentOppApproval(User_Service.salesUserNotInTriggerMap.values());
        }

        for(User eachUser : (List<User>)Trigger.new){
            if(User_Service.salesUserInTriggerMap.containsKey(eachUser.Id)){
                if(User_Service.inActiveUserManager.contains(eachUser.Current_Opportunity_Approval__c)){
                    eachUser.Current_Opportunity_Approval__c = null;
                }
           }
        }
    }

    public override void afterUpdate() {
        // Opportunity Approval Reassign
        if(!User_Service.inActiveUserManager.isEmpty()){
            setUserManagerToInactive(User_Service.inActiveUserManager);
        }
        
        if(!User_Service.salesUserNotInTriggerMap.isEmpty()){
            setCurrentOpportunityApprover(User_Service.salesUserNotInTriggerMap);
        }
        
        if(!User_Service.salesUserInTriggerMap.isEmpty()){
            setCurrentOpportunityApprover(User_Service.salesUserInTriggerMap);
        }

        // Calculate ownership assignment effected by user change
        Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
        for(User eachUser : (List<User>) Trigger.new){
            User oldUser = (User) Trigger.oldMap.get(eachUser.Id);
            User_MaskModel userMask = new User_MaskModel();
            userMask.isReCalculateOwnership = (eachUser.Pending_for_Ownership_Calculation__c == true) ? true : false;
            userMask.userId = eachUser.Id;
            userMask.setNewUser(eachUser);
            userMask.setOldUser(oldUser);
            if(userMask.isChangeTeamHierachy || userMask.isChangeToInactive || userMask.isChangeToActive || userMask.isChangeSegment || userMask.isChangeName) {
                userMaskMapByUserId.put(eachUser.Id, userMask);
            }
        }
        
        System.debug('userMaskMapByUserId.isEmpty() = '+userMaskMapByUserId.isEmpty());
        if(!userMaskMapByUserId.isEmpty()) {
            //if(!Test.isRunningTest()) {
                System.enqueueJob(new UserServiceQueue(userMaskMapByUserId));
            //}
        }
    }

    public override void afterfinally(){
        if(BottomUp_Service.globalSalesTargetForUpsert != null && BottomUp_Service.globalSalesTargetForUpsert.size() > 0){
            BottomUp_Service.upsertGlobalSalesTargetForUpsert(JSON.serialize(BottomUp_Service.globalSalesTargetForUpsert) );
            BottomUp_Service.globalSalesTargetForUpsert = null;
        }
    }

    private void setUserManagerToInactive(Set<Id> inActiveUserManager){
        List<User> listToUpdateAHNHInactiveToActive = new List<User>();
        listToUpdateAHNHInactiveToActive = [SELECT Id, FirstName, LastName, Segment__c, ProfileId, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, IsActive FROM User WHERE Id IN: inActiveUserManager];
        Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
        for(User eachUser : listToUpdateAHNHInactiveToActive){
            User_MaskModel userMask = new User_MaskModel();
            userMask.userId = eachUser.Id;
            userMask.setOldUser(eachUser);
            eachUser.IsActive = false;
            userMask.setNewUser(eachUser);
            if(userMask.isChangeTeamHierachy || userMask.isChangeToInactive || userMask.isChangeToActive || userMask.isChangeSegment || userMask.isChangeName) {
                userMaskMapByUserId.put(eachUser.Id, userMask);
            }
        }

        TriggerHandler.bypass('UserTriggerHandler');
        update listToUpdateAHNHInactiveToActive;
        TriggerHandler.clearBypass('UserTriggerHandler');
        if(!userMaskMapByUserId.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new UserServiceQueue(userMaskMapByUserId));
        }
    }

    private void setCurrentOpportunityApprover(Map<Id, User> saleUserMap){
        Map<Id, Profile> profileMap = User_Service.getAllProfile();
        saleUserMap = new Map<Id,User>([SELECT Id, Current_Opportunity_Approval__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c, ProfileId, ManagerId, Manager.IsActive, Manager.ProfileId, Manager.ManagerId, Manager.Manager.IsActive, Manager.Manager.ProfileId, Manager.Manager.ManagerId, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.ProfileId FROM User WHERE Id IN: saleUserMap.keySet()]);

        for(User eachUser : saleUserMap.values()){
            User oldUser = (User) Trigger.oldMap.get(eachUser.Id);
            if(profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_RM || 
                profileMap.get(eachUser.ProfileId).Name == GlobalConstants.RBS_RM_BAR ||
                profileMap.get(eachUser.ProfileId).Name == GlobalConstants.RBS_RM_ABM) {
                if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive){
                    eachUser.Current_Opportunity_Approval__c = eachUser.Manager.ManagerId;
                }else if(eachUser.Manager.Manager.Manager != null && eachUser.Manager.Manager.Manager.IsActive){
                    eachUser.Current_Opportunity_Approval__c = eachUser.Manager.Manager.ManagerId;
                }else{
                    eachUser.Current_Opportunity_Approval__c = null;
                }
            }else if(profileMap.get(eachUser.ProfileId).Name == GlobalConstants.SME_TM ||
                profileMap.get(eachUser.ProfileId).Name == GlobalConstants.RBS_TM){
                if(eachUser.Manager != null && eachUser.Manager.IsActive){
                    eachUser.Current_Opportunity_Approval__c = eachUser.ManagerId;
                }else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive){
                    eachUser.Current_Opportunity_Approval__c = eachUser.Manager.ManagerId;
                }else{
                    eachUser.Current_Opportunity_Approval__c = null;
                }
            }
        }

        TriggerHandler.bypass('UserTriggerHandler');
        update saleUserMap.values();
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    private void clearCurrentOppApproval(List<User> userList){
        for(User eachUser : userList){
            eachUser.Current_Opportunity_Approval__c = null;
        }

        TriggerHandler.bypass('UserTriggerHandler');
        update userList;
        TriggerHandler.clearBypass('UserTriggerHandler');
    }
}