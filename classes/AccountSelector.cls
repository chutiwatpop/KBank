public with sharing class AccountSelector {
	Schema.SObjectType sObjectType;

	public AccountSelector() {
		this.sObjectType = Account.sObjectType;
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return GlobalUtility.getAllCreatableSchemaSObjectFields(sObjectType);
	}

	public List<Account> selectByIds(Set<Id> idSet) {
		List<Account> accountList = (List<Account>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id IN :idSet').toSOQL());
		return accountList;
	}

	public Account selectById(Id queryId) {
		List<Account> accountList = (List<Account>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id = :queryId').toSOQL());
		return accountList[0];
	}

	public Account selectById(Id queryId, Set<String> fields) {
		List<Account> accountList = (List<Account>) Database.query(new QueryBuilder(sObjectType).selectFields(fields).setCondition('Id = :queryId').toSOQL());
		return accountList[0];
	}
}