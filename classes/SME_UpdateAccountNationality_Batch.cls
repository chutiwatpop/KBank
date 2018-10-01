global class SME_UpdateAccountNationality_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    private Map<String,Map<String,Decimal>> cisNationalShareMap;
    
    //global SME_UpdateAccountNationality_Batch() {
    //    this.query = 'SELECT CIS_ID__c,Shareholders_nationality__c,Share__c FROM Corp_Link_Enlite__c';
    //    cisNationalShareMap = new Map<String,Map<String,Decimal>>();
    //}
    global SME_UpdateAccountNationality_Batch(Set<String> accountIdList) {
        List<String> accountListToQuery = new List<String>(accountIdList);
        String condition = ' WHERE CIS_ID__c IN (\'' + String.join(accountListToQuery, '\',\'') +'\') ORDER BY CIS_ID__c DESC';
        this.query = 'SELECT CIS_ID__c,Shareholders_nationality__c,Share__c FROM Corp_Link_Enlite__c'+condition;

        cisNationalShareMap = new Map<String,Map<String,Decimal>>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Corp_Link_Enlite__c> corpLinkList) {
        for(Corp_Link_Enlite__c corpLinkObj : corpLinkList){
            if(!cisNationalShareMap.containsKey(corpLinkObj.CIS_ID__c)){ // no cis in map yet
                if(corpLinkObj.CIS_ID__c != NULL && corpLinkObj.Shareholders_nationality__c != NULL && corpLinkObj.Share__c != NULL){
                cisNationalShareMap.put(corpLinkObj.CIS_ID__c,new Map<String,Decimal>{corpLinkObj.Shareholders_nationality__c => corpLinkObj.Share__c});
                }
            }else{// map already contain cis
                Map<String,Decimal> nationalShareMap = cisNationalShareMap.get(corpLinkObj.CIS_ID__c);
                if(!cisNationalShareMap.get(corpLinkObj.CIS_ID__c).containsKey(corpLinkObj.Shareholders_nationality__c)){
                    if( corpLinkObj.Shareholders_nationality__c != NULL && corpLinkObj.Share__c != NULL){
                    cisNationalShareMap.get(corpLinkObj.CIS_ID__c).put(corpLinkObj.Shareholders_nationality__c,corpLinkObj.Share__c);
                    }
                }else{
                    Decimal oldshare = cisNationalShareMap.get(corpLinkObj.CIS_ID__c).get(corpLinkObj.Shareholders_nationality__c);
                    if(corpLinkObj.Share__c != NULL){
                        cisNationalShareMap.get(corpLinkObj.CIS_ID__c).put(corpLinkObj.Shareholders_nationality__c,oldshare+corpLinkObj.Share__c);
                    }
                }
            }
        }
    }

    private String sortedNationalityShare(Map<String,Decimal> shareNationalityMap){
        List<PairWrapper> sortedList = new List<PairWrapper>();
        for(String key : shareNationalityMap.keySet() ){
            sortedList.add(  new PairWrapper( new NationalityShare(key,shareNationalityMap.get(key) ) )  );
        }
        sortedList.sort();
        String result = NULL;
        //for(PairWrapper pairWrapper : sortedList ){
        //  if( result != NULL)
        //      result += ', '+pairWrapper.pair1.key + '('+pairWrapper.pair1.value +'%)';
        //  else if ( result == NULL)
        //      result =  pairWrapper.pair1.key + '('+pairWrapper.pair1.value +'%)';
        //}
        result = sortedList.get(0).pair1.key+' '+sortedList.get(0).pair1.value +' %';
        return result;
    }
    
    global void finish(Database.BatchableContext BC) {
          List<Account> accountList = new List<Account>();
        for(String cis : cisNationalShareMap.keySet() ){
            String nationalShareStr = sortedNationalityShare(cisNationalShareMap.get(cis) );
            accountList.add(new Account(Id = cis , Major_Shareholder_Nationality__c = nationalShareStr) );
        }

        if(accountList.size() > 0){
            Database.executeBatch(new SME_ByPassMAX_DML_Batch(accountList,'update'));
        }
    }

    public class NationalityShare {
        public Decimal value {get;set;}
        public String key {get;set;}
        public NationalityShare(String key,Decimal value){
            this.key = key;
            this.value = value.setScale(2);
        }    
    }

    public class PairWrapper implements Comparable{
        public NationalityShare pair1;
        public PairWrapper(NationalityShare p1){
            this.pair1 = p1;
        }

        public Integer compareTo(Object compareTo){
            PairWrapper comPaireToPair1 = (PairWrapper)compareTo;
            Integer returnValue = 0;
            if( pair1.value > comPaireToPair1.pair1.value)  
                returnValue = -1;
            else if ( pair1.value <= comPaireToPair1.pair1.value)
                returnValue = 1;
            return returnValue;
        }
    }
    
}