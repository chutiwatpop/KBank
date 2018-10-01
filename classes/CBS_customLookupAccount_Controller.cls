public with sharing class CBS_customLookupAccount_Controller {
	public String accountId{get;set;}
	public List<Account> accounts{get;set;}
	public String searchString{get;set;}
	public Boolean noResultRecord{get;set;}
	private String currentUserRoleId;
	private Set<String> acceptableAccountIds;
	private String currentUserId;
	public CBS_customLookupAccount_Controller() {
		accountId = Apexpages.currentPage().getParameters().get('searchString');
		this.noResultRecord = false;
		this.currentUserRoleId = UserInfo.getUserRoleId();
		//this.acceptableAccountIds = getAcceptableAccounts(currentUserRoleId);
		this.currentUserId = UserInfo.getUserId();
		this.accounts = getAvailableAccounts();
		//System.debug('acceptableAccountIds >> ' + acceptableAccountIds);
	}
	private List<Account> getAvailableAccounts(){
		String query = 'SELECT Id,Name,Name_TH__c,Name_Surname_TH__c,CIS__c,Identification_No__c,Port_Pool__c,OwnerId,Owner.FirstName,Owner.LastName'
			+ ' FROM Account';
			//query += ' WHERE Id IN: acceptableAccountIds';
			query += ' WHERE OwnerId =: currentUserId ORDER BY Name ASC NULLS FIRST LIMIT 200';
		this.accounts = database.query(query);
		System.debug('this.accounts >> ' + this.accounts);
		if(this.accounts.isEmpty()){
			this.noResultRecord = true;
		}
		return accounts;
	}
	public void performSearch(){
		String query = 'SELECT Id,Name,Name_TH__c,Name_Surname_TH__c,CIS__c,Identification_No__c,Port_Pool__c,OwnerId,Owner.FirstName,Owner.LastName'  
            + ' FROM Account';
            //query += ' WHERE Id IN: acceptableAccountIds'; 
        if(this.searchString != null && this.searchString != ''){  
            query += ' WHERE CIS__c LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\''
            +' OR Name LIKE \'' + String.escapeSingleQuotes(this.searchString) + '%\'';  
        }       
        query += ' ORDER BY Name ASC';  
        System.debug('performSearch query >> ' + query);
      	this.accounts = database.query(query);
      	this.noResultRecord = false;
      	if(this.accounts.isEmpty()){
      		this.noResultRecord = true;
      	}
      	System.debug('performSearch this.accounts >> ' + this.accounts);
	}
	//private Set<String> getAcceptableUserRoleIds(String userRoleID){
	//	Map<String,List<String>> rolesMap = new Map<String,List<String>>();
	//	List<UserRole>roles = [SELECT Id,Name,ParentRoleId FROM UserRole];
	//	Map<String,String> roleNameMap = new Map<String,String>();
	//	for(UserRole role:roles){
	//		roleNameMap.put(role.Id,role.Name);
	//	}
	//	for(UserRole role:roles){
	//		if(!rolesMap.keySet().contains(role.ParentRoleId)){
	//			rolesMap.put(role.ParentRoleId,new List<String>());
	//		}
	//		rolesMap.get(role.ParentRoleId).add(role.Id);
	//	}
	//	for(String key:rolesMap.keySet()){
	//	//System.debug(key + ' >> ' + rolesMap.get(key));
	//	}
	//	List<String>subOrdinates;
	//	if(rolesMap.get(userRoleID)!=null && !rolesMap.get(userRoleID).isEmpty()){
	//		subOrdinates = rolesMap.get(userRoleID);
	//	}else{
	//		subOrdinates = new List<String>();
	//	}
	//	Set<String> acceptableUserRoleIds = new Set<String>();
	//	acceptableUserRoleIds.add(userRoleID);
	//	if(!subOrdinates.isEmpty()){
	//	for(String subordinate:subOrdinates){
	//		acceptableUserRoleIds.add(subordinate);
	//	}
	//	}
	//	for(String roleId:acceptableUserRoleIds){
	//		System.debug(roleNameMap.get(roleId));
	//	}
	//	return acceptableUserRoleIds;
	//}
	//private Set<String> getAcceptableAccounts(String userRoleID){
	//	Set<String> acceptableAcc = new Set<String>();
	//	Set<String> acceptableUserRoleIds = getAcceptableUserRoleIds(userRoleID);
	//	List<User> acceptableUsers = [SELECT Id FROM User WHERE UserRoleId IN: acceptableUserRoleIds];
	//	Set<String> acceptableUserIds = new Set<String>();
	//	for(User acceptableUser:acceptableUsers){
	//		acceptableUserIds.add(acceptableUser.Id);
	//	}
	//	List<Account> acceptableAccounts = [SELECT Id FROM Account WHERE OwnerId IN: acceptableUserIds];
	//	if(!acceptableAccounts.isEmpty()){
	//		for(Account acceptableAccount:acceptableAccounts){
	//			acceptableAcc.add(acceptableAccount.Id);
	//		}	
	//	}
	//	return acceptableAcc;
	//}
}