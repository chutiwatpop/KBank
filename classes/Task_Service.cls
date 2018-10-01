public class Task_Service {
    public static RecordType normalTaskRecordType;
    public static RecordType completedTaskRecordType;
    public static RecordType leadTask;
    public static Boolean fromTaskTrigger;
    public static List<Task> relateTaskList;

    public static void reassignTask(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
        List<Task> taskList = new List<Task>();
        Map<Id, Target_List__c> mapTargetList = new Map<Id, Target_List__c>();
        Set<String> setTaskWhatId = new Set<String>();
        Set<String> statusesNotInclude = new Set<String>{'Not Started','In Progress','Waiting on someone else','Deferred','New'};
        taskList = [SELECT Id, OwnerId, WhoId, WhatId, What.RecordType.SobjectType, Status, RecordType.DeveloperName, IsClosed FROM Task WHERE OwnerId IN:assignMapByCurrentUser.keyset() AND AccountId != null AND IsRecurrence = false];
        for(Task eachTask : taskList) {
            if(eachTask.What.RecordType.SobjectType == 'Target_List__c') {
                setTaskWhatId.add(eachTask.WhatId);
            }
        }
        for(Target_List__c eachTargetList : [SELECT Id, Lead_Campaign__r.Type__c, Lead_Campaign__r.Sub_Type__c FROM Target_List__c WHERE Id IN :setTaskWhatId]) {
            mapTargetList.put(eachTargetList.Id, eachTargetList);
        }
        for(Task eachTask : taskList) {
            if(assignMapByCurrentUser.containsKey(eachTask.OwnerId)) {
                if(mapTargetList.containsKey(eachTask.WhatId) &&
                    ((mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_TO_DO && (mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_TO_INFORM || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM)) || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_FEEDBACK
                    ) && !eachTask.IsClosed
                ) {
                    eachTask.OwnerId = assignMapByCurrentUser.get(eachTask.OwnerId).AssignmentOwner__c;
                } else {
                    if(eachTask.RecordType.DeveloperName.equalsIgnoreCase(GlobalConstants.NORMAL_TASK)){
                        eachTask.Status = GlobalConstants.CLOSED_BY_SYSTEM;
                    }
                }
            }
        }
        if(taskList.size() > 0)
            update taskList;
    }

    public static void reassignTask(List<Account_MaskModel> accountTargetList, Set<Id> relatedUpdateSet) {
        List<Task> taskToUpdateList = new List<Task>();
        Map<Id, Target_List__c> mapTargetList = new Map<Id, Target_List__c>();
        Set<String> setTaskWhatId = new Set<String>();
        taskToUpdateList = [SELECT Id, OwnerId, Owner.Profile.Name, AccountId, WhatId, What.RecordType.SobjectType, IsClosed, RecordType.DeveloperName FROM Task WHERE AccountId IN: relatedUpdateSet];
        if(taskToUpdateList != null && taskToUpdateList.size() > 0) {
            for(Task eachTask : taskToUpdateList) {
                if(eachTask.What.RecordType.SobjectType == 'Target_List__c') {
                    setTaskWhatId.add(eachTask.WhatId);
                }
            }
            for(Target_List__c eachTargetList : [SELECT Id, Lead_Campaign__r.Type__c, Lead_Campaign__r.Sub_Type__c FROM Target_List__c WHERE Id IN :setTaskWhatId]) {
                mapTargetList.put(eachTargetList.Id, eachTargetList);
            }
            for(Task eachTask : taskToUpdateList){
                for(Account_MaskModel eachMask : accountTargetList) {
                    if(eachMask.accObj.Id == eachTask.AccountId) {
                        if(eachMask.ownerUser.Id != eachTask.OwnerId && eachTask.OwnerId != eachMask.accObj.Share_With__c) {
                            if(mapTargetList.containsKey(eachTask.WhatId) &&
                                ((mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_TO_DO && (mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_TO_INFORM || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM)) || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_FEEDBACK
                                ) && !eachTask.IsClosed
                            ) {
                                eachTask.OwnerId = eachMask.ownerUser.Id;
                            } else {
                                if(eachTask.RecordType.DeveloperName.equalsIgnoreCase(GlobalConstants.NORMAL_TASK)){
                                    eachTask.Status = GlobalConstants.CLOSED_BY_SYSTEM;
                                }
                            }
                        }
                    }
                }
            }
        }
        if(!taskToUpdateList.isEmpty()) {
            update taskToUpdateList;
        }
    }
    //INC000000640518  AddNew Method
    public static void reassignTaskList(List<Account_MaskModel> accountTargetList, Set<Id> relatedUpdateSet) {
        if(relateTaskList == null){
            relateTaskList = new List<Task>(); 
        }
        List<Task> taskToUpdateList = new List<Task>();
        Map<Id, Target_List__c> mapTargetList = new Map<Id, Target_List__c>();
        Set<String> setTaskWhatId = new Set<String>();
        taskToUpdateList = [SELECT Id, OwnerId, Owner.Profile.Name, AccountId, WhatId, What.RecordType.SobjectType, IsClosed, RecordType.DeveloperName FROM Task WHERE AccountId IN: relatedUpdateSet];
        if(taskToUpdateList != null && taskToUpdateList.size() > 0){
            for(Task eachTask : taskToUpdateList) {
                if(eachTask.What.RecordType.SobjectType == 'Target_List__c') {
                    setTaskWhatId.add(eachTask.WhatId);
                }
            }
            for(Target_List__c eachTargetList : [SELECT Id, Lead_Campaign__r.Type__c, Lead_Campaign__r.Sub_Type__c FROM Target_List__c WHERE Id IN :setTaskWhatId]) {
                mapTargetList.put(eachTargetList.Id, eachTargetList);
            }
            for(Task eachTask : taskToUpdateList){
                for(Account_MaskModel eachMask : accountTargetList) {
                    if(eachMask.accObj.Id == eachTask.AccountId) {
                        if(eachMask.ownerUser.Id != eachTask.OwnerId && eachTask.OwnerId != eachMask.accObj.Share_With__c) {
                            if(mapTargetList.containsKey(eachTask.WhatId) &&
                                ((mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_TO_DO && (mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_TO_INFORM || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM)) || mapTargetList.get(eachTask.WhatId).Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_FEEDBACK
                                ) && !eachTask.IsClosed
                            ) {
                                eachTask.OwnerId = eachMask.ownerUser.Id;
                            } else {
                                if(eachTask.RecordType.DeveloperName.equalsIgnoreCase(GlobalConstants.NORMAL_TASK)){
                                    eachTask.Status = GlobalConstants.CLOSED_BY_SYSTEM;
                                }
                            }
                        }
                    }
                }
            }
        }
        relateTaskList.addAll(taskToUpdateList);
    }
}