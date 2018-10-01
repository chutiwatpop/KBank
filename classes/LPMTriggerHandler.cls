/**
* @author anan.b@beryl8.com
* @07/02/2017 created new
*/

public without sharing class LPMTriggerHandler extends TriggerHandler{
	private static Map<Id,LPM__c> LPMNoteChangedMapById;

	public override void beforeInsert(){
		for(LPM__c eachLPM : (List<LPM__c>)Trigger.new){
			eachLPM.LPM__c = eachLPM.Name;
		}
	}

	public override void beforeUpdate(){
		LPMNoteChangedMapById = new Map<Id,LPM__c>();
		LPM__c LPMOldReccord;
		for(LPM__c eachLPM : (List<LPM__c>)Trigger.new){
		 	LPMOldReccord = (LPM__c)Trigger.oldMap.get(eachLPM.Id);
		 	if(eachLPM.Name != LPMOldReccord.Name){
		 		eachLPM.LPM__c = eachLPM.Name;
		 	}
		 	if(eachLPM.Upload_DPD__c != LPMOldReccord.Upload_DPD__c){
		 		eachLPM.Previous_DPD__c = LPMOldReccord.Upload_DPD__c;
		 	}
		 	if(eachLPM.DPD_As_of_date__c != LPMOldReccord.DPD_As_of_date__c){
		 		eachLPM.Previous_DPD_As_of_Date__c = LPMOldReccord.DPD_As_of_date__c;
		 	}
		 	if(eachLPM.Note__c != LPMOldReccord.Note__c){
		 		LPMNoteChangedMapById.put(eachLPM.id,eachLPM);
		 	}
		}
	}
	public override void afterUpdate(){
		List<Target_List__c> targetListUpdateNote = [SELECT Id,Personalised_Message__c,LPM__c From Target_List__c WHERE LPM__c IN :LPMNoteChangedMapById.keySet()];
		for(Target_List__c targetList : targetListUpdateNote){
			if(LPMNoteChangedMapById.containsKey(targetList.LPM__c)){
				targetList.Personalised_Message__c = LPMNoteChangedMapById.get(targetList.LPM__c).Note__c;
			}
		}

		if(!targetListUpdateNote.isEmpty()){
			TriggerHandler.bypass('TargetListTriggerHandler');
				if(targetListUpdateNote.size() < 10000){
					update targetListUpdateNote;
				}else{
					Database.executeBatch(new SME_DML_Batch(targetListUpdateNote),2000);
				}
			TriggerHandler.clearbypass('TargetListTriggerHandler');
		}
	}

	public override void beforeDelete(){
		TargetList_Service.inActiveTargetListFromLPMId(Trigger.oldMap.keySet() );
	}
}