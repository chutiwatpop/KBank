global class CBS_SalesTarget_Initial_Batch implements Database.Batchable<sObject>, Database.Stateful {
	private String query;
	private List<Sales_Target__c> saleTargetToUpsert;
	private String currentYear;
	private Map<String,Team_Target__c> teamTargetMapByRcCode;
    private Map<String,User_Mirror_Management__c> nhtlMirrorSettingMapByUserRcCode;

    global CBS_SalesTarget_Initial_Batch() {
    	String cbsSegment =  '\''+String.join(new List<String>(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET),'\',\'' )+ '\'';

        nhtlMirrorSettingMapByUserRcCode = CustomSettingUtil.getMirrorSettingMapByUserAndMirrorRcCode();
        List<String> nhTLEmployeeIdSet = new List<String>();
        for(User_Mirror_Management__c nhTlList : nhtlMirrorSettingMapByUserRcCode.values() ){
            nhTLEmployeeIdSet.add(nhTlList.Employee_ID__c);
        }
        String nhtlEmployeeIdCondition = '\''+String.join(nhTLEmployeeIdSet,'\',\'' )+ '\'';

        this.query = 'SELECT Id,User__r.RC_Code__c,Employee_ID__c,Segment__c From User_Extension__c WHERE User__r.Isactive = true AND ( Segment__c IN ('+cbsSegment+') OR Employee_ID__c IN ('+nhtlEmployeeIdCondition+') )'; 
    	saleTargetToUpsert = new List<Sales_Target__c>();
    	//currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
    	currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );
        teamTargetMapByRcCode = BottomUp_Service.getRcCodeTeamTargetMap();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<User_Extension__c> userExtList) {
       
       for(User_Extension__c eachuUserExt : userExtList){
	       	if(eachuUserExt.Employee_ID__c != null){
		       	String externalId = currentYear+'-'+eachuUserExt.Employee_ID__c;
                String userRCCode;
                if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(eachuUserExt.Segment__c) ){
                    userRCCode = eachuUserExt.User__r.RC_Code__c;
                }else{
                    if(nhtlMirrorSettingMapByUserRcCode.containsKey(eachuUserExt.User__r.RC_Code__c)){
                        userRCCode = nhtlMirrorSettingMapByUserRcCode.get(eachuUserExt.User__r.RC_Code__c).Mirror_Value__c;
                    }
                }
		       	if(teamTargetMapByRcCode.containsKey(userRCCode)){
		       		Team_Target__c teamTarget = teamTargetMapByRcCode.get(userRCCode);
			       	Sales_Target__c saleTarget = new Sales_Target__c(Team_Target__c = teamTarget.id, Name__c = eachuUserExt.id, 
			       													 External_ID__c = externalId ,Year__c = currentYear);
			       	saleTargetToUpsert.add(saleTarget);
		       	}
		    }
       }
       
    }

    global void finish(Database.BatchableContext BC) {
    	if(saleTargetToUpsert != null && saleTargetToUpsert.size() > 0){
    		upsert saleTargetToUpsert External_ID__c;
        }
        Database.executeBatch(new CBS_BottomUp_Initial_Batch(),200);
    }

}