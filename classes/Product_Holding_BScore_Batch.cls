global class Product_Holding_BScore_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{
	
	String query = 'SELECT Name FROM LPM__c';
	String batchType = 'IS_ONGOING';
	String calloutURL = SME_CIRestWebservice.CALLOUT_URL;
	Set<String> lpmIndexs;
	String firstLPM = '0';
	String lastLPM = '0';
	//String calloutURL = 'http://58.137.161.149/';
	global Product_Holding_BScore_Batch() {
		//this.query = 'SELECT Name FROM LPM__c ORDER BY Name ASC NULLS FIRST';
		this.query += ' ORDER BY LPM_Number__c';
		Map<String,String>maxMinLPMNumbers = Product_Holding_Batch_Utils.getMaxMinLPMNumber();
		this.firstLPM = maxMinLPMNumbers.get('minLPM');
		this.lastLPM =  maxMinLPMNumbers.get('maxLPM');
		//this.batchType = 'IS_INITIAL';
	}

	global Product_Holding_BScore_Batch(String batchType) {
		//this.query = 'SELECT Name FROM LPM__c ORDER BY Name ASC NULLS FIRST';
		this.query += ' ORDER BY LPM_Number__c';
		this.batchType = batchType;
		Map<String,String>maxMinLPMNumbers = Product_Holding_Batch_Utils.getMaxMinLPMNumber();
		this.firstLPM = maxMinLPMNumbers.get('minLPM');
		this.lastLPM =  maxMinLPMNumbers.get('maxLPM');
	}

	global Product_Holding_BScore_Batch(String batchType,Integer minLPM,Integer maxLPM) {
		//this.query = 'SELECT Name FROM LPM__c ORDER BY Name ASC NULLS FIRST';
		this.query += ' WHERE LPM_Number__c > '+minLPM+' and LPM_Number__c < '+maxLPM+' ORDER BY LPM_Number__c ASC';
		this.batchType = batchType;
		System.debug(this.query);
		//Map<String,String>maxMinLPMNumbers = Product_Holding_Batch_Utils.getMaxMinLPMNumber();
		this.firstLPM =  String.valueOf(minLPM);
		this.lastLPM =  String.valueOf(maxLPM);
	}

	//global Product_Holding_BScore_Batch(String batchType,String startLPM,String endLPM) {
	//	this.query += ' WHERE Name >= ' + startLPM + ' AND Name <= ' + endLPM + ' ORDER BY Name ASC NULLS FIRST';
	//	this.batchType = batchType;
	//}

	global Product_Holding_BScore_Batch(String batchType,Set<String>lpms){
		this.lpmIndexs = lpms;
		this.query += ' WHERE Name IN: lpmIndexs ORDER BY LPM_Number__c ';
		this.batchType = batchType;
		Map<String,String>maxMinLPMNumbers = Product_Holding_Batch_Utils.getMaxMinLPMNumber();
		this.firstLPM = maxMinLPMNumbers.get('minLPM');
		this.lastLPM =  maxMinLPMNumbers.get('maxLPM');
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<LPM__c> lpms){
		Integer lpmSize = lpms.size();
		boolean isInitial = (this.batchType == 'IS_INITIAL');
		boolean isOngoing = (this.batchType == 'IS_ONGOING');
		if(isOngoing){
			runLPMFixedOngoing(lpms);
		}else if(isInitial){
			runLPMFixedInitital(lpms);
		} 
	}
	
	global void finish(Database.BatchableContext BC) {
	}

	private void runLPMFixedInitital(List<LPM__C>lpms){
		List<String> requests = Product_Holding_Batch_Utils.getRequests(lpms);
		Integer requestsLength = requests.size();
		for(Integer i=0;i<requestsLength;i++){
			String request = 'IS_LPMFIXED_INITIAL=True&todayTimeStamp='+Product_Holding_Batch_Utils.getTodayTimeStamp()+'&last12MonthsTimeStamp='+Product_Holding_Batch_Utils.getLast12MonthTimeStamp();
			boolean isThisRequestContainsFirstLPMNumber = Product_Holding_Batch_Utils.isRequestContainsLPMNumber(this.firstLPM,requests[i]);
			boolean isThisRequestContainsLastLPMNumber = Product_Holding_Batch_Utils.isRequestContainsLPMNumber(this.lastLPM,requests[i]);
			System.debug('Batch Initial isThisRequestContainsFirstLPMNumber >> ' + isThisRequestContainsFirstLPMNumber + ' isThisRequestContainsLastLPMNumber >> ' + isThisRequestContainsLastLPMNumber);
			if(isThisRequestContainsFirstLPMNumber){
				request += '&Is_Sending_Email_Start=True'+requests[i];	
			}
			else if(isThisRequestContainsLastLPMNumber){
				request += '&Is_Sending_Email_Finish=True'+requests[i];	
			}else{
				request += requests[i];	
			}
			try{
				System.debug('Batch Initital request >> '  + request);
				HTTPResponse resp;
				resp = SME_HTTPCallUtil.sendHttpCallout(this.calloutURL+'BSCORE_NEW',request);
			}catch(Exception e){
	           	GlobalUtility.logMessage('ERROR','Product_Holding_BScore_Batch','runLPMFixedInitital',null,null,e.getMessage(),null,e,null);
			}
		}
	}

	private void runLPMFixedOngoing(List<LPM__C>lpms){
		List<String> requests = Product_Holding_Batch_Utils.getRequests(lpms);
		Integer requestsLength = requests.size();
		for(Integer i=0;i<requestsLength;i++){
			String request = 'IS_LPMFIXED_ONGOING=True&todayTimeStamp='+Product_Holding_Batch_Utils.getTodayTimeStamp()+'&last12MonthsTimeStamp='+Product_Holding_Batch_Utils.getLast12MonthTimeStamp()+'&lastMonthTimeStamp='+Product_Holding_Batch_Utils.getLastMonth();
			boolean isThisRequestContainsFirstLPMNumber = Product_Holding_Batch_Utils.isRequestContainsLPMNumber(this.firstLPM,requests[i]);
			boolean isThisRequestContainsLastLPMNumber = Product_Holding_Batch_Utils.isRequestContainsLPMNumber(this.lastLPM,requests[i]);
			System.debug('Batch Ongoing isThisRequestContainsFirstLPMNumber >> ' + isThisRequestContainsFirstLPMNumber + ' isThisRequestContainsLastLPMNumber >> ' + isThisRequestContainsLastLPMNumber);
			if(isThisRequestContainsFirstLPMNumber){
				request += '&Is_Sending_Email_Start=True'+requests[i];	
			}
			else if(isThisRequestContainsLastLPMNumber){
				request += '&Is_Sending_Email_Finish=True'+requests[i];	
			}else{
				request += requests[i];	
			}
			try{
				System.debug('Batch Ongoing request >> '  + request);
				HTTPResponse resp;
				resp = SME_HTTPCallUtil.sendHttpCallout(this.calloutURL+'BSCORE_NEW',request);
			}catch(Exception e){
	           	GlobalUtility.logMessage('ERROR','Product_Holding_BScore_Batch','runLPMFixedOngoing',null,null,e.getMessage(),null,e,null);
			}
		}
	}

}