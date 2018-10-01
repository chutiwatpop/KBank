global class SME_EnlitePurge_Batch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    private Integer maxYear;
    private String objectName;
    private Map<String,List<sObject>> cisObjectListMap;

    //global SME_EnlitePurge_Batch(String objectName,Integer maxYear) {
    //    this.query = 'SELECT CIS_ID__c,Name,External_ID__c FROM '+objectName;
    //    this.maxYear = maxYear;
    //    cisObjectListMap = new Map<String,List<sObject>>();
    //}

    global SME_EnlitePurge_Batch(String objectName,Integer maxYear,Set<String> accountIdList) {
        List<String> accountListToQuery = new List<String>(accountIdList);
       // System.debug('SME_EnlitePurge_Batch accountIdList::'+accountIdList + '  objectName :: '+objectName);
        this.query = 'SELECT ID,CIS_ID__c,Name,External_ID__c FROM '+objectName;
        String condition = ' WHERE CIS_ID__c IN (\'' + String.join(accountListToQuery, '\',\'') +'\') ORDER BY CIS_ID__c ASC';
        this.query = this.query + condition;
        this.maxYear = maxYear;
        cisObjectListMap = new Map<String,List<sObject>>();
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> sObjectList) {
        for(sObject eachObject : sObjectList){

            String eachCIS = String.valueOf(eachObject.get('CIS_ID__c') != NULL ? eachObject.get('CIS_ID__c') : NULL);
            String newName = String.valueOf(eachObject.get('Name')).split(' ')[0];
            if( newName != null){
                eachObject.put('Name',newName);
            }
            if( eachCIS != null ){
                if(cisObjectListMap.containsKey(eachCIS)){
                    (cisObjectListMap.get(eachCIS)).add(eachObject);
                }else{
                    List<sObject> tempList = new List<sObject>{eachObject};
                    cisObjectListMap.put(eachCIS,tempList);
                }
            }

        }
    }

    global void finish(Database.BatchableContext BC) {

        List<sObject> objectListToPurge = new List<sObject>();
        for(List<sObject> eachCisObjectList : cisObjectListMap.values()){
            objectListToPurge.addall( eachCisListToPurge(eachCisObjectList) );
        }

        if(!objectListToPurge.isEmpty()){
            Database.executeBatch(new SME_ByPassMAX_DML_Batch(objectListToPurge,'delete'));
        }
    }

    private List<sObject> eachCisListToPurge(List<sObject> objList){
        List<sObject> resultList = new List<sObject>();
        //System.debug('Jay : before sorted >>'+objList);
        objList.sort();
        //System.debug('Jay : after sorted >>'+objList);
        for(Integer i = objList.size()-(maxYear+1); i >= 0;i-- ){
            resultList.add(objList.get(i));
        }
        return resultList;
    }

}