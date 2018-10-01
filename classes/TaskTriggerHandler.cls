/**
* @author pasakorn.p@beryl8.com
* @14/09/2016 createddate
*/
public class TaskTriggerHandler extends TriggerHandler{
    
    public override void allBefore(){
        if(Task_Service.normalTaskRecordType == null){
            Task_Service.normalTaskRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: GlobalConstants.NORMAL_TASK];
        }

        if(Task_Service.completedTaskRecordType == null){
            Task_Service.completedTaskRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: GlobalConstants.COMPLETED_TASK];
        }

        if(Task_Service.leadTask == null){
            Task_Service.leadTask = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: GlobalConstants.LEAD_TASK];
        }
    }

    public override void beforeInsert(){
        List<Task> listOfTask = Trigger.new;
        Set<Id> whatIds = new Set<Id>();
        for(Task eachTask : listOfTask){
            if(!whatIds.contains(eachTask.WhatId)){
                whatIds.add(eachTask.WhatId);
            }
        }
        Map<Id,Target_List__c> targetListMapById = new Map<Id,Target_List__c>([SELECT Id FROM Target_List__c WHERE Id IN :whatIds]);
        for(Task eachTask : (List<Task>) Trigger.new){
            if(eachTask.RecordTypeId == null){
                eachTask.RecordTypeId = Task_Service.normalTaskRecordType.Id;
            }
        }
    }

    public override void afterUpdate(){
        List<Task> listTaskToUpdate = new List<Task>();
        Map<Id,Task> oldMapTask = (Map<Id,Task>) Trigger.oldMap;
        Map<Id,Task> mapTaskById = new Map<Id,Task>([SELECT Id, IsClosed, Status, Answered_Date__c, Complete_Date__c, RecordTypeId, WhatId, What.Type,Response_Level_1__c, Response_Level_2__c, Memo__c FROM Task WHERE Id IN: Trigger.new]);
        Set<Id> targetListSetId = new Set<Id>();

        for(Task eachTask : mapTaskById.values()){
            if(eachTask.What.Type == GlobalConstants.TARGET_LIST_TYPE){
                targetListSetId.add(eachTask.WhatId);
            }
        }

        Map<Id,Target_List__c> mapTargetListById = new Map<Id,Target_List__c>([SELECT Id, Status__c, Response_Level_1__c, Response_Level_2__c, Memo__c ,Lead_Campaign__r.RecordType.DeveloperName,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE ID IN :targetListSetId]);
        System.debug('mapTargetListById : '+mapTargetListById);

        Map<Id,Target_List__c> mapTargetListToUpdate = new Map<Id,Target_List__c>();

        List<Target_List__c> targetListToUpdate = new List<Target_List__c>();
        for(Task eachTask : mapTaskById.values()){
            Task oldRecord = oldMapTask.get(eachTask.Id);
            if(eachTask.RecordTypeId == Task_Service.leadTask.Id){

                Target_List__c eachTargetList = mapTargetListById.get(eachTask.WhatId);

                if(eachTargetList.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME){
                    updateSmeTargetList(mapTargetListToUpdate,eachTask,oldRecord,eachTargetList);
                }else if(eachTargetList.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME){
                    updateCbsTargetList(mapTargetListToUpdate,eachTask,eachTargetList);
                }

                if(eachTask.IsClosed){
                    eachTask.RecordTypeId = Task_Service.completedTaskRecordType.Id;
                    
                    eachTask.Complete_Date__c = System.today();
                    listTaskToUpdate.add(eachTask);
                }
            }
        }
        for(Target_List__c eachTargetList : mapTargetListToUpdate.values()){
            System.debug('Target List Update ID : '+eachTargetList.Id);
            System.debug('CIS ID : '+eachTargetList.CIS_ID_Prospect_Name__c);
        }
    
        if(Task_Service.fromTaskTrigger == null){
            Task_Service.fromTaskTrigger = true;
        }

        if(Task_Service.fromTaskTrigger){
            if(!mapTargetListToUpdate.isEmpty()){
                update mapTargetListToUpdate.values();    
            }
            
        }
        Task_Service.fromTaskTrigger = null;

        
        TriggerHandler.bypass('TaskTriggerHandler');
        update listTaskToUpdate;
        TriggerHandler.clearBypass('TaskTriggerHandler');
        

    }

    private void updateSmeTargetList(Map<Id,Target_List__c> mapTargetListToUpdate,Task newTask,Task oldTask,Target_List__c eachTargetList){
        //if(newTask.Status != oldTask.Status){
            eachTargetList.Status__c = newTask.Status;
            eachTargetList.Response_Level_1__c = newTask.Status;
            eachTargetList.Memo__c = newTask.Memo__c;
            if(newTask.Answered_Date__c != oldTask.Answered_Date__c){
                if(newTask.Answered_Date__c != null){
                    eachTargetList.Response_Level_2__c = newTask.Answered_Date__c.format();
                }else{
                    eachTargetList.Response_Level_2__c = null;
                }
            }
            mapTargetListToUpdate.put(eachTargetList.Id,eachTargetList);
            //targetListToUpdate.add(eachTargetList);
        //}
    }

    private void updateCbsTargetList(Map<Id,Target_List__c> mapTargetListToUpdate,Task newTask,Target_List__c eachTargetList){
        eachTargetList.Status__c = newTask.Status;
        eachTargetList.Response_Level_1__c = newTask.Response_Level_1__c;
        eachTargetList.Response_Level_2__c = newTask.Response_Level_2__c;
        eachTargetList.Memo__c = newTask.Memo__c;
        mapTargetListToUpdate.put(eachTargetList.Id,eachTargetList);
        //targetListToUpdate.add(eachTargetList);
    }
}