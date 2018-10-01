global class SME_DistinctAccountIDForEnlite_Batch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    private Integer maxYear;
    private String objectName;
    private Set<String> accountIdSet;
    private Integer maximumSizeHashMap;

    global SME_DistinctAccountIDForEnlite_Batch(String objectName,Integer maxYear){
        String condition = ' ORDER BY CIS_ID__c ASC';
        this.query = 'SELECT CIS_ID__c FROM '+objectName + condition;
        this.objectName = objectName;
        this.maxYear = maxYear;
        this.accountIdSet = new Set<String>();
        this.maximumSizeHashMap = !Test.isRunningTest() ? 10000 : 1;
    }
    global SME_DistinctAccountIDForEnlite_Batch(){
       this.objectName = 'Corp_Link_Enlite__c';
        String condition = ' ORDER BY CIS_ID__c ASC';
        this.query = 'SELECT CIS_ID__c FROM '+objectName + condition;
        this.maxYear = 5;
        this.accountIdSet = new Set<String>();
        this.maximumSizeHashMap = !Test.isRunningTest() ? 10000 : 1;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> sObjectList) {
        for(sObject eachObject : sObjectList){
            String eachAccountID = String.valueOf(eachObject.get('CIS_ID__c') != NULL ? eachObject.get('CIS_ID__c') : NULL);
            if(eachAccountID != null){
                if(!accountIdSet.contains(eachAccountID))
                    accountIdSet.add(eachAccountID);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        Set<String> partialAccountId = new Set<String>();
        for(String accoundId : accountIdSet){
            if(partialAccountId.size() < maximumSizeHashMap){
                partialAccountId.add(accoundId);
            }else{
                if(objectName.equals('Corp_Link_Enlite__c')){
                    Database.executeBatch(new SME_UpdateAccountNationality_Batch(partialAccountId));
                }else{
                     Database.executeBatch(new SME_EnlitePurge_Batch(this.objectName,this.maxYear,partialAccountId));
                }
                partialAccountId.clear();
                partialAccountId.add(accoundId);

            }
   
        }
            if( partialAccountId.size() > 0){
                 if(objectName.equals('Corp_Link_Enlite__c')){
                    Database.executeBatch(new SME_UpdateAccountNationality_Batch(partialAccountId));
                }else{
                     Database.executeBatch(new SME_EnlitePurge_Batch(this.objectName,this.maxYear,partialAccountId));
                }
            }


    }
}