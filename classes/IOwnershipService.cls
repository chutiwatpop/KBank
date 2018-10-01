public interface IOwnershipService {
	List<Account> checkTemporary(List<Account> accountLists, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId);
}