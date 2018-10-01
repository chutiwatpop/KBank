global class PrepareDateMigrateOppPlaning_Batch implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	
	
	global PrepareDateMigrateOppPlaning_Batch() {
		query ='SELECT  Id FROM Opportunity WHERE CreatedBy.Name=\'UserManage Key\'';
      //query ='SELECT CIS_ID__c,CIS_ID__r.Name, Call_Report_CBS__c, Opportunity__c,Opportunity__r.StageName FROM Opportunity_Planning__c ORDER BY CIS_ID__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   global void execute(Database.BatchableContext BC, List<Opportunity> opplist) {
         Set<ID> oppIdSet = new Set<Id>();
         for(Opportunity eachOpp: opplist){
            oppIdSet.add(eachOpp.Id);
         }

         List<Application_History__c> appList = [select Id,OppName__c,Migrate_Reference_Id__c from Application_History__c  WHERE OppName__c=:oppIdSet];
         if(appList != NULL && appList.size() >0){
            for(Application_History__c eachApp : appList){
               Id migrateOppId = Id.valueOf(eachApp.Migrate_Reference_Id__c);
               eachApp.OppName__c = migrateOppId;
               eachApp.Migrate_Reference_Id__c = '';
            }
            List<Application_History__c> updatelist = new List<Application_History__c>();
            if(updatelist.size() >0){
               TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
                  update updatelist;
               TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
            }
         }
         
         

         if(!oppIdSet.isEmpty()){
            delete [select id from event WHERE WhatId =:oppIdSet];
         }

         if(!oppIdSet.isEmpty()){
            delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:oppIdSet];
         }

         if(!oppIdSet.isEmpty()){
            delete [SELECT Id FROM Opportunity WHERE Id =:oppIdSet];
         }

   		//List<String> appIdList = new List<String>();
   		//for(Application_History__c eachApp : scope){
   		//	appIdList.add(String.valueOf(eachApp.Id));
   		//}

   		//Map<Id,String> tempMap = new Map<Id,String>();
   		//List<temp_opp_app__c> tempList = [SELECT AppID__c,OppName__c FROM temp_opp_app__c WHERE AppID__c =:appIdList];
   		//for(temp_opp_app__c eachtemp : tempList){
   		//	tempMap.put(Id.valueOf(eachtemp.AppID__c),eachtemp.OppName__c);
   		//}
   		
   		//for(Application_History__c eachApp : scope){
   		//	String oppStr =  tempMap.get(eachApp.Id);
   		//	System.debug('oppStr :'+oppStr);
   		//	if(oppStr !=null){
   		//		eachApp.OppName__c = Id.valueOf(oppStr);
   		//		updatelist.add(eachApp);
   		//	}
   			
   		//}
	}

   //global void execute(Database.BatchableContext BC, List<Opportunity_Planning__c> oppPlanlist) {
   //      Set<String> oppIdSet = new Set<String>(); 
   //      for(Opportunity_Planning__c eachOppPlan : oppPlanlist){
   //            oppIdSet.add(String.valueOf(eachOppPlan.Opportunity__c));
   //      }

   //      List<temp_opp_app__c> listTempData = [SELECT OppName__c, AppID__c from temp_opp_app__c  WHERE OppName__c=:oppIdSet];
   //      System.debug('listTempData size'+listTempData.size());
   //      Map<Id,Id> teampMapping = new Map<Id,Id>();
   //      for(temp_opp_app__c eachtemp : listTempData){
   //         //appSetID.add(eachtemp.AppID__c);
   //         teampMapping.put(Id.valueOf(eachtemp.AppID__c), Id.valueOf(eachtemp.OppName__c));
   //      }

   //      List<Application_History__c> appList = [SELECT ID,OppName__c FROM Application_History__c WHERE Id=:teampMapping.Keyset()];
   //      System.debug('appList size'+appList.size());
   //      for(Application_History__c  eachApp : appList){
   //         if(teampMapping.containsKey(eachApp.Id)){
   //            eachApp.OppName__c = teampMapping.get(eachApp.Id);
   //         }
   //      }

   //         TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
   //            update appList;
   //         TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
   //}
	
	global void finish(Database.BatchableContext BC) {

	}
	
}