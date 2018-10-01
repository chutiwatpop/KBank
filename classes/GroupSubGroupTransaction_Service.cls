public with sharing class GroupSubGroupTransaction_Service {
	public static void updateGroupSubgroupTransactionAccordingToGroupSubgroupInAccounts(List<Account>accounts){
		Set<Id>accountIDs = new Set<Id>();
		Set<Id>groupSubgroupIDs = new Set<Id>();
		for(Account account:accounts){
			accountIDs.add(account.Id);
			groupSubgroupIDs.add(account.Group_Sub_Group__c);
		}
		Map<Id,Account>accountsMap = new Map<Id,Account>(accounts);
		List<Group_Sub_Group__c>groupSubgroups = [SELECT Id,Group_Lookup__c,Sub_Group_Lookup__c FROM Group_Sub_Group__c WHERE ID IN: groupSubgroupIDs];
		Map<Id,Group_Sub_Group__c>groupSubgroupsMap = new Map<Id,Group_Sub_Group__c>(groupSubgroups);
		List<Group_Sub_Group_Transaction__c>groupSubgroupTransactions = [SELECT ID,CIS_ID__c,Group_Lookup__c,Sub_Group_Lookup__c,Group_Sub_Group_Lookup__c FROM Group_Sub_Group_Transaction__c WHERE CIS_ID__c IN: accountIDs];
		for(Group_Sub_Group_Transaction__c groupSubgroupTransaction:groupSubgroupTransactions){
			Account updatedAccount = accountsMap.get(groupSubgroupTransaction.CIS_ID__c);
			Id accountCustomerGroupSubgroup = updatedAccount.Group_Sub_Group__c;
			groupSubgroupTransaction.Group_Sub_Group_Lookup__c = accountCustomerGroupSubgroup;
			groupSubgroupTransaction.Group_Lookup__c = (accountCustomerGroupSubgroup != null)?groupSubgroupsMap.get(accountCustomerGroupSubgroup).Group_Lookup__c:null;
			groupSubgroupTransaction.Sub_Group_Lookup__c = (accountCustomerGroupSubgroup != null)?groupSubgroupsMap.get(accountCustomerGroupSubgroup).Sub_Group_Lookup__c:null;
		}
		update groupSubgroupTransactions;
	}
}