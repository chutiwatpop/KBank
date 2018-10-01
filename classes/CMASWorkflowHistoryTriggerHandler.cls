/**
* @author chansak.s@beryl8.com
*/
public class CMASWorkflowHistoryTriggerHandler extends TriggerHandler {
    public override void allBefore() {
        List<String> cwuRefNoList  = new List<String>();
        for(CMAS_Workflow_History__c eachCmasWF : (List<CMAS_Workflow_History__c>) Trigger.new){
        	  if(eachCmasWF.To_Date__c  !=null){
        	  	eachCmasWF.To_Date__c = eachCmasWF.To_Date__c.addHours(-7);
        	  }
        	  if(eachCmasWF.From_Date__c !=null){
        	  	eachCmasWF.From_Date__c = eachCmasWF.From_Date__c.addHours(-7);
        	  }
        }
    }
}