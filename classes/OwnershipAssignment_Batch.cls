global class OwnershipAssignment_Batch implements Database.Batchable<sObject> {
    
    String query;
    
    global OwnershipAssignment_Batch () {
        this.query = 'SELECT Id, Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, IsActive__c, Previous_RC_Code__c, Previous_AH_RC_Code__c, Previous_NH_RC_Code__c, Previous_Job_Code__c, Previous_IsActive__c FROM User_Structure__c';
    }

    global OwnershipAssignment_Batch (String queryCondition) {
        this.query = 'SELECT Id, Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, IsActive__c, Previous_RC_Code__c, Previous_AH_RC_Code__c, Previous_NH_RC_Code__c, Previous_Job_Code__c, Previous_IsActive__c FROM User_Structure__c' + queryCondition;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User_Structure__c> userStructures) {
        Set<String> employeeIds = new Set<String>();
        for(User_Structure__c eachUserStructure : userStructures) {
            String employeeId = UserManagementService.formatEmployeeId(eachUserStructure.Name);
            employeeIds.add(employeeId);
        }

        Map<String, Id> userIdMapByEmpId = new Map<String, Id>();
        List<User> userList = [SELECT Id, Employee_Id__c FROM User WHERE Employee_ID__c IN :employeeIds];
        for(User eachUser : userList) {
            userIdMapByEmpId.put(eachUser.Employee_Id__c, eachUser.Id);
        }

        Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
        for(User_Structure__c eachUserStructure : userStructures) {
            String employeeId = UserManagementService.formatEmployeeId(eachUserStructure.Name);
            User_MaskModel eachUserMask = new User_MaskModel();
            eachUserMask.setNewUserField(eachUserStructure);
            eachUserMask.setOldUserField(eachUserStructure);
            if((eachUserMask.isChangeTeamHierachy || 
                eachUserMask.isChangeToActive || 
                eachUserMask.isChangeToInactive) 
                    && userIdMapByEmpId.containsKey(employeeId)) {
                Id userId = userIdMapByEmpId.get(employeeId);
                eachUserMask.userId = userId;
                userMaskMapByUserId.put(userId, eachUserMask);
            }
        }
        if(!userMaskMapByUserId.isEmpty()) {
            System.enqueueJob(new OwnershipAssignment_Queue(userMaskMapByUserId));
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}