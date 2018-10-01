public interface ICustomerRelation {
	void addRelationToList(SLL_Relation__c sllItem);
	void insertRelation(Map<String, Account> customerSllInfo);
	Map<String, SLL_Relation__c> getSllRelationMapAfterAddRelation();
}