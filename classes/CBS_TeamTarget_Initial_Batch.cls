global class CBS_TeamTarget_Initial_Batch implements Database.Batchable<sObject>, Database.Stateful{
	private String query;
	private List<Team_Target__c> teamTargetToUpsert;
	private String currentYear;

    global CBS_TeamTarget_Initial_Batch() {
    	String cbsSegment =  '\''+String.join(new List<String>(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET),'\',\'' )+ '\'';
        this.query = 'SELECT Id,RC_Code__c From Team_Structure__c WHERE Segment__c IN ('+cbsSegment+')'; 
    	teamTargetToUpsert = new List<Team_Target__c>();
    	//currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
        currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Team_Structure__c> teamStructureList) {
       for(Team_Structure__c eachTeam : teamStructureList){
	       	if(eachTeam.RC_Code__c != null){
		       	String externalId = currentYear+'-'+eachTeam.RC_Code__c;
		       	Team_Target__c teamTarget = new Team_Target__c(Team_Name__c = eachTeam.id, External_ID__c = externalId ,Year__c = currentYear);
		       	teamTargetToUpsert.add(teamTarget);
		    }
       }
       
    }

    global void finish(Database.BatchableContext BC) {
    	if(teamTargetToUpsert != null && teamTargetToUpsert.size() > 0){
    		upsert teamTargetToUpsert External_ID__c;
        }
        Database.executeBatch(new CBS_SalesTarget_Initial_Batch(),200);
    }

}