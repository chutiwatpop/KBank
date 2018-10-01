global class SME_ClearMonthlyPerformance_Batch implements Database.Batchable<sObject>,Database.Stateful {
	
	private String query;
   	private List<Monthly_Performance__c>  monthlyPerfListToDelete;
   	private Integer rowEffect = 0;
	
	global SME_ClearMonthlyPerformance_Batch() {

		Date today;
		Integer currentMonth;
		Integer currentYear;
		Integer previosTwoYear;
		today = System.today();
		currentYear = GlobalUtility.getYearInBuddhistCalendar(today);
      	previosTwoYear = currentYear-2;
      	currentMonth = today.month();
      	String condition = '\''+'%'+currentMonth+' '+previosTwoYear+'\'';
		this.query = 'SELECT Id,External_ID__c FROM Monthly_Performance__c WHERE External_ID__c LIKE '+condition;
		monthlyPerfListToDelete = new List<Monthly_Performance__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Monthly_Performance__c> monthlyPerfList) {
   		for(Monthly_Performance__c monthlyPerfObj : monthlyPerfList ){
   			monthlyPerfListToDelete.add(monthlyPerfObj);
   		}
	}
	
	global void finish(Database.BatchableContext BC) {
		if(monthlyPerfListToDelete.size() > 0){
			delete monthlyPerfListToDelete;
			rowEffect = monthlyPerfListToDelete.size();
		}
	}
	
}