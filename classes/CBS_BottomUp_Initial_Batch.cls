global class CBS_BottomUp_Initial_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;
    private Map<String,Sales_Target__c> saleTargetMapByUserExt;
    private String currentYear;

    global CBS_BottomUp_Initial_Batch() {
        String cbsSegment =  '\''+String.join(new List<String>(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET),'\',\'' )+ '\'';
        this.query = 'SELECT Id,CIS__c,Current_Owner_Extension__c From Account WHERE Primary_Segment_Code__c IN ('+cbsSegment+') AND Current_Owner_Extension__c != null';
        saleTargetMapByUserExt =  BottomUp_Service.getuserExtensionIdSalesTargetMap();
      //  currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
        currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> accountList) {
        List<Bottom_Up_Annualized__c> bottomUpToUpsertList = new List<Bottom_Up_Annualized__c>();
        for(Account eachAccount : accountList){
            if(eachAccount.CIS__c != null){
                String externalId = currentYear+'-'+eachAccount.CIS__c;
                if(saleTargetMapByUserExt.containsKey(eachAccount.Current_Owner_Extension__c)){
                    Sales_Target__c saleTarget = saleTargetMapByUserExt.get(eachAccount.Current_Owner_Extension__c);
                    Bottom_Up_Annualized__c bottomUp = new Bottom_Up_Annualized__c( Sales_Target__c = saleTarget.id ,Year__c = currentYear,
                                                                                    External_ID__c = externalId, CIS_ID__c = eachAccount.id);
                    bottomUpToUpsertList.add(bottomUp);
                }
            }

        }
        if(saleTargetMapByUserExt != null && saleTargetMapByUserExt.size() > 0 ){
            upsert bottomUpToUpsertList External_ID__c;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}