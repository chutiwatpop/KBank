public with sharing class EventSelector {
	Schema.SObjectType sObjectType;

	public EventSelector() {
		this.sObjectType = Event.sObjectType;
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return GlobalUtility.getAllCreatableSchemaSObjectFields(sObjectType);
	}

	public List<Event> selectByIds(Set<Id> idSet) {
		List<Event> eventList = (List<Event>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id IN :idSet').toSOQL());
		return eventList;
	}

	public List<Event> selectByCustomerIds(Set<Id> idSet) {
		List<Event> eventList = (List<Event>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('CIS_ID__c IN :idSet').toSOQL());
		return eventList;
	}
}