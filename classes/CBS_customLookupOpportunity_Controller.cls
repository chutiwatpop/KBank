public with sharing class CBS_customLookupOpportunity_Controller {
	public String accountId{get;set;}
	public List<Opportunity> opportunities{get;set;}
	public String searchString{get;set;}
	private Set<String> allowOpportunityStageNames = new Set<String>{'Stock Negotiation','Create Write Up'};
	public String index{get;set;}
	public Boolean noResultRecord{get;set;}
	public Boolean isGroupOppPlanning {get;set;}
	public CBS_customLookupOpportunity_Controller() {
		this.accountId = Apexpages.currentPage().getParameters().get('searchString');
		this.index = Apexpages.currentPage().getParameters().get('index');
		this.isGroupOppPlanning = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isGroupOppPlanning'));
		this.noResultRecord = false;
		opportunities = getAvailableOpportunities();
	}
	private List<Opportunity> getAvailableOpportunities(){
		String query = 'SELECT Id,Name,CIS_ID__c,StageName,CloseDate,Amount,Credit_Model__c,Submission_Channel__c,Submit_Issue__c,Number_of_Day_Created__c'
			+ ' FROM Opportunity'
			+ ' WHERE AccountId =: accountId AND StageName IN: allowOpportunityStageNames AND CMAS_Status__c = null ORDER BY Name ASC NULLS FIRST LIMIT 200';
		this.opportunities = database.query(query);
		if(this.opportunities.isEmpty()){
			this.noResultRecord = true;
		}
		return opportunities;
	}
	public void performSearch(){
		String query = 'SELECT Id,Name,CIS_ID__c,StageName,CloseDate,Amount,Credit_Model__c,Submission_Channel__c,Submit_Issue__c,Number_of_Day_Created__c'  
            + ' FROM Opportunity'
            + ' WHERE AccountId =: accountId AND StageName IN: allowOpportunityStageNames AND CMAS_Status__c = null'; 
        if(this.searchString != null && this.searchString != ''){  
            query += ' AND (Name LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR CIS_ID__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR Credit_Model__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR Submission_Channel__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR Submit_Issue__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\')';
        }       
        query += ' ORDER BY Name ASC';

      	this.opportunities = database.query(query);
      	this.noResultRecord = false;
      	if(this.opportunities.isEmpty()){
      		this.noResultRecord = true;
      	}
	}
}