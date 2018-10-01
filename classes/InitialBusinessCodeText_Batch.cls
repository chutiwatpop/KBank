/**
* @author anan.b@beryl8.com
* @15/08/2017 INC000000764605 For TrackError Batch
*/

global class InitialBusinessCodeText_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global InitialBusinessCodeText_Batch() {
		this.query = 'SELECT Id From Account';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC,List<Account> accountList) {
		List<Call_Report__c> callReportList = [SELECT id,Business_Code_Text__c,Business_Code__r.Name From Call_Report__c WHERE CIS_ID__c IN :accountList AND Business_Code__c != null];
		for(Call_Report__c eachCallReport : callReportList){
			eachCallReport.Business_Code_Text__c = eachCallReport.Business_Code__r.Name;
		}

		List<Opportunity> opportunityList = [SELECT Id,Business_Code__r.Name,Business_Code_Text__c,Owner.Segment__c,Owner_Segment_Business_Code__c From Opportunity WHERE AccountId IN :accountList];
		for(Opportunity eachOpportunity : opportunityList){
			if (eachOpportunity.Business_Code__c != null){
				eachOpportunity.Business_Code_Text__c = eachOpportunity.Business_Code__r.Name;
			}
			eachOpportunity.Owner_Segment_Business_Code__c = eachOpportunity.Owner.Segment__c;
		}
		//INC000000764605
		if(!callReportList.isEmpty()){
			DB_Service.updateSObjectWithBypass(callReportList, true);
		}
		if(!opportunityList.isEmpty()){
			DB_Service.updateSObjectWithBypass(opportunityList, true);
		}
	}
	
	global void finish(Database.BatchableContext BC) {}
}