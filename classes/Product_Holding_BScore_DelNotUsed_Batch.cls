global class Product_Holding_BScore_DelNotUsed_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global Product_Holding_BScore_DelNotUsed_Batch() {
		/*
		This will delete the records that ARENT in latest 12 months
		*/
		this.query = getQuerystatement();
	}
	
	global Product_Holding_BScore_DelNotUsed_Batch(String fromYYYYMM,String toYYYYMM){
		/*
		Format : YYYY-MM
		This will delete the records that ARE in between fromYYYMM and toYYYYMM
		*/
		this.query = getQuerystatement(fromYYYYMM,toYYYYMM);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Behaviour_Score__c> bScores) {
		delete bScores;
	}
	
	global void finish(Database.BatchableContext BC) {
		Product_Holding_BScore_Batch bScoreBatch = new Product_Holding_BScore_Batch('IS_ONGOING');
		ID batchprocessid = Database.executeBatch(bScoreBatch);
	}
	
	private static List<String> getExternalKeysOfLatestNMonth(String startDateString,Integer n){
		List<String>extKeys = new List<String>();
		Date startDate;
		if(String.isNotBlank(startDateString)){
			List<String>dateComp = startDateString.split('-');
			Integer year = Integer.valueOf(dateComp[0]);
			Integer month = Integer.valueOf(dateComp[1]);
			startDate = date.newinstance(year,month,1);
		}else{
			startDate = System.today();
		}
		for(Integer i=n-1;i>=0;i--){
			Date d = startDate.addMonths(-i);
			String year = String.valueOf(d.year());
			String month = String.valueOf(d.month());
			extKeys.add(year+'-'+month);
		}
		return extKeys;
	}

	private static List<String> getExternalKeysBetweenTwoMonths(String fromYYYYMM,String toYYYYMM){
		List<String> fromDateCompo = fromYYYYMM.split('-');
		List<String> toDateCompo = toYYYYMM.split('-');
		Integer fromDateYear = Integer.valueOf(fromDateCompo[0]);
		Integer fromDateMonth = Integer.valueOf(fromDateCompo[1]);
		Integer toDateYear = Integer.valueOf(toDateCompo[0]);
		Integer toDateMonth = Integer.valueOf(toDateCompo[1]);
		Date fromDate = date.newinstance(fromDateYear,fromDateMonth,1);
		Date toDate = date.newinstance(toDateYear,toDateMonth,1);
		Integer monthsBetween = fromDate.monthsBetween(toDate)+1;
		String toDateString = toDateYear+'-'+toDateMonth;
		return getExternalKeysOfLatestNMonth(toDateString,monthsBetween);
	}

	private static String getQuerystatement(){
		String sqlStatement = 'SELECT External_ID__c,Id,LastModifiedDate,LPM__c,Name FROM Behaviour_Score__c';
		List<String>externalKeys = getExternalKeysOfLatestNMonth('',12);
		if(!externalKeys.isEmpty()){
			sqlStatement += ' WHERE NOT(External_ID__c LIKE \'%-' + externalKeys[0] + '\'';
			for(Integer i=1;i<externalKeys.size();i++){
				sqlStatement += ' OR External_ID__c LIKE \'%-' + externalKeys[i] + '\'';
			}
			sqlStatement += ')';
		}
		return sqlStatement;
	}

	private static String getQuerystatement(String fromYYYYMM,String toYYYYMM){
		String sqlStatement = 'SELECT External_ID__c,Id,LastModifiedDate,LPM__c,Name FROM Behaviour_Score__c';
		List<String>externalKeys = getExternalKeysBetweenTwoMonths(fromYYYYMM,toYYYYMM);
		if(!externalKeys.isEmpty()){
			sqlStatement += ' WHERE (External_ID__c LIKE \'%-' + externalKeys[0] + '\'';
			for(Integer i=1;i<externalKeys.size();i++){
				sqlStatement += ' OR External_ID__c LIKE \'%-' + externalKeys[i] + '\'';
			}
			sqlStatement += ')';
		}
		return sqlStatement;
	}
	
}