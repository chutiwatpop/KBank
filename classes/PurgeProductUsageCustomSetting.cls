global class PurgeProductUsageCustomSetting implements Database.Batchable<sObject> {
	
	String query;
	private Integer currentSetting;
	private List<String> customSettingToPurges = new List<String>{'Product_Usage_Market_Code__c','Product_Usage_Idnx_Interest_Rate_Type__c','Product_Usage_Interest_Rate_Type__c'};
	
	global PurgeProductUsageCustomSetting() {
		this.currentSetting = 0;
	}

	global PurgeProductUsageCustomSetting(Integer currentSetting){
		this.currentSetting = currentSetting;
	}

	private void init(){
		this.query = 'SELECT id From '+customSettingToPurges.get(currentSetting);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		init();
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		if(hasNext()){
			Database.executeBatch(new PurgeProductUsageCustomSetting(getNext()));
		}
	}

	private Boolean hasNext(){
		return (currentSetting < customSettingToPurges.size()-1) ? true : false;
	}

	private Integer getNext(){
		return currentSetting+1;
	}
}