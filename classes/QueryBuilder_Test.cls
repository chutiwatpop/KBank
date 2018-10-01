@isTest
private class QueryBuilder_Test {
	
	@isTest static void buildCommonQuery() {
		QueryBuilder queryBuilder = new QueryBuilder(User.sObjectType);
		List<User> userList = (List<User>) Database.query(queryBuilder.toSOQL());
		System.assertNotEquals(null, userList);
	}
	
	@isTest static void buildWithName() {
		QueryBuilder queryBuilder = new QueryBuilder(User.sObjectType);
		queryBuilder.selectFields(new List<String>{'Id'});
		queryBuilder.selectFields(new Set<String>{'Name'});
		queryBuilder.selectField('RC_Code__c');
		queryBuilder.setSortSelectFields(true);
		List<User> userList = (List<User>) Database.query(queryBuilder.toSOQL());
		for(User eachUser : userList) {
			System.assertNotEquals(null, eachUser.Name);
		}
	}
	
	@isTest static void buildWithSObjectFields() {
		QueryBuilder queryBuilder = new QueryBuilder(User.sObjectType);
		queryBuilder.selectFields(GlobalUtility.getAllCreatableSchemaSObjectFields(User.sObjectType));
		List<User> userList = (List<User>) Database.query(queryBuilder.toSOQL());
		for(User eachUser : userList) {
			System.assertNotEquals(null, eachUser.Name);
		}
	}

	@isTest static void buildWithLimit() {
		QueryBuilder queryBuilder = new QueryBuilder(User.sObjectType);
		queryBuilder.selectFields(new Set<String>{'Id, Name'});
		queryBuilder.setLimit(1);
		List<User> userList = (List<User>) Database.query(queryBuilder.toSOQL());
		System.assertEquals(1, userList.size());
	}

	@isTest static void buildWithCondition() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		QueryBuilder queryBuilder = new QueryBuilder(Account.sObjectType);
		queryBuilder.selectFields(new List<String>{'Id'});
		
		queryBuilder.setCondition('Port_Pool__c = \'Port\'');
		List<Account> accountList = (List<Account>) Database.query(queryBuilder.toSOQL());
		System.assertEquals(1, accountList.size());
	}
}