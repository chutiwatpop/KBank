public class CMASTriggerHandler extends TriggerHandler{

    public Map<String,Id> applicationHistoryMap;
    public override void beforeInsert() {
        List<String> cwuRefNoList  = new List<String>();
        for(CMAS__c eachCMAS : (List<CMAS__c>) Trigger.new){
            cwuRefNoList.add(eachCMAS.CWU_REF_No__c);
        }

        List<Application_History__c> appList = [SELECT ID,OppName__c,CWU_Number__c FROM Application_History__c  WHERE Id=:cwuRefNoList or CWU_Number__c=:cwuRefNoList];
        applicationHistoryMap = new Map<String,Id>();
        if(!appList.isEmpty()){
            for(Application_History__c eachApp : appList){
                if(eachApp.CWU_Number__c !='' && eachApp.CWU_Number__c !=null){
                    applicationHistoryMap.put(eachApp.CWU_Number__c,eachApp.Id);
                }else{
                    String appId = String.valueOf(eachApp.Id).substring(0, 15);
                    applicationHistoryMap.put(appId,eachApp.Id);
                }
            }
        }

        for(CMAS__c eachCMAS : (List<CMAS__c>) Trigger.new){
            if(applicationHistoryMap.containsKey(eachCMAS.CWU_REF_No__c)){
                eachCMAS.Application_History__c = applicationHistoryMap.get(eachCMAS.CWU_REF_No__c); 
            }
        }
    }
 }