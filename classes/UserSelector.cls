public with sharing class UserSelector {
	Schema.SObjectType sObjectType;

	public UserSelector() {
		this.sObjectType = User.sObjectType;
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return GlobalUtility.getAllCreatableSchemaSObjectFields(sObjectType);
	}

	public List<User> selectByIds(Set<Id> idSet) {
		List<User> userList = (List<User>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id IN :idSet').toSOQL());
		return userList;
	}

	public User selectById(Id queryId) {
		List<User> userList = (List<User>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id = :queryId').toSOQL());
		return userList[0];
	}

	public User selectById(Id queryId, Set<String> fields) {
		List<User> userList = (List<User>) Database.query(new QueryBuilder(sObjectType).selectFields(fields).setCondition('Id = :queryId').toSOQL());
		return userList[0];
	}
}