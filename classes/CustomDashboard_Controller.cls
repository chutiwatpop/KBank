public with sharing class CustomDashboard_Controller {
	public List<Account> accountList;
	public List<Call_Report__c> callReportList;
	//public String accountName {get;set;}

	public CustomDashboard_Controller() {
		accountList = new List<Account>();
		callReportList = new List<Call_Report__c>();
	}

	public List<Account> getAllAccount() {
		accountList = [SELECT Id, Name FROM Account WHERE CreatedDate > LAST_WEEK];
		return accountList;
	}

	public List<Call_Report__c> getAllCallReport() {
		callReportList = [SELECT Id, CIS_ID__c, Customer_Name__c FROM Call_Report__c WHERE CreatedDate > LAST_WEEK];
		return callReportList;
	}
}