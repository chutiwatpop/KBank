public with sharing class CBS_customLookupContact_Controller {
	public String accountId{get;set;}
	public List<Contact> contacts{get;set;}
	public String searchString{get;set;}
	public String index{get;set;}
	public Boolean noResultRecord{get;set;}
	public CBS_customLookupContact_Controller() {
		this.accountId = Apexpages.currentPage().getParameters().get('searchString');
		this.index = Apexpages.currentPage().getParameters().get('index');
		this.noResultRecord = false;
		contacts = getAvailableContacts();
	}
	private List<Contact> getAvailableContacts(){
		System.debug(this.accountId);
		if(String.isBlank(this.accountId)){
			this.noResultRecord = true;
			return new List<Contact>();
		}
		String query = 'SELECT Id,Name,Customer_Name__c,Contact_Position__c,title,CIS_ID__c,Phone_Number__c,Business_Email__c'
			+ ' FROM Contact'
			+ ' WHERE AccountId =: accountId ORDER BY Name ASC NULLS FIRST LIMIT 200';
		this.contacts = database.query(query);
		if(this.contacts.isEmpty()){
			this.noResultRecord = true;
		}
		System.debug(contacts);
		return contacts;
	}
	public void performSearch(){
		String query = 'SELECT Id,Name,Customer_Name__c,Contact_Position__c,title,CIS_ID__c,Phone_Number__c,Business_Email__c'  
            + ' FROM Contact'
            + ' WHERE AccountId =: accountId'; 
        if(this.searchString != null && this.searchString != ''){  
            query += ' AND (Name LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR Contact_Position__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR title LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\')';
            //+' OR CIS_ID__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\')';  
        }       
        query += ' ORDER BY Name ASC';
        System.debug('performSearch query >> ' + query);
      	this.contacts = database.query(query);
      	this.noResultRecord = false;
      	if(this.contacts.isEmpty()){
      		this.noResultRecord = true;
      	}
      	System.debug('performSearch this.accounts >> ' + this.contacts);
	}
}