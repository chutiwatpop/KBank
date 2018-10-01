@isTest
private class GroupSubGroupTransaction_Service_Test {
	public static final String accountname = 'Account1';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		System.runAs(userTM){
        	Group__c group1 = new Group__c(
		        Group_Name__c = 'group1',
		        External_ID__c = 'g1',
		        Number_of_Group__c = 1
		    );
		    insert group1;
		    Sub_Group__c subGroup1 = new Sub_Group__c(
		        Sub_Group_Name__c = 'subGroup1',
		        External_ID__c = 'sg1',
		        Number_of_Sub_Group__c = 1
		    );
		    insert subGroup1;
		    Group_Sub_Group__c groupSubGroup = new Group_Sub_Group__c(
		        Group_Lookup__c = group1.Id,
		        Sub_Group_Lookup__c = subGroup1.Id,
		        Group__c = 'g1',
		        Sub_Group__c = 'sb1'
		    );
		    insert groupSubGroup;

		    Account accountCBS = new Account(
	            Name = GroupSubGroupTransaction_Service_Test.accountName,
	            Port_Pool__c = GlobalConstants.PORT,
	            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
	            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
	            OwnerId = userTM.Id,
	            Primary_Segment_Code__c = 'CB',
	            Customer_Segment_Code__c = 'CB',
	            Is_createby_Integration__c = true,
	            OwnerChangeExecutedByTrigger__c = true,
	            Group_Sub_Group__c = groupSubGroup.Id
	        );
	        insert accountCBS;

	        List<Customer_Group_Sub_Group__c> customerGSubGList = [SELECT Id FROM Customer_Group_Sub_Group__c WHERE Customer__c	= :accountCBS.Id LIMIT 1];

	        Group_Sub_Group_Transaction__c gSubGTran = new Group_Sub_Group_Transaction__c();
	        gSubGTran.CIS_ID__c = accountCBS.Id;
	        gSubGTran.Group_Lookup__c = group1.Id;
	        gSubGTran.Sub_Group_Lookup__c = subGroup1.Id;
	        gSubGTran.Group_Sub_Group_Lookup__c = groupSubGroup.Id;
	        gSubGTran.Customer_Group_Sub_Group__c = customerGSubGList[0].Id;
	        insert gSubGTran;
        }
	}
	@isTest static void accountChangeGroupSubGroup() {
		Test.startTest();
	        //List<Account> finalAccount = [SELECT Id,Group_Sub_Group__c,Primary_Segment_Code__c FROM Account WHERE Name=:GroupSubGroupTransaction_Service_Test.accountName LIMIT 1];
	        List<Account> finalAccount = new List<Account>();
		    finalAccount.add(Mockup_Test.getFirstAccountFromName(GroupSubGroupTransaction_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c'));
		    Group__c group2 = new Group__c(
		        Group_Name__c = 'group2',
		        External_ID__c = 'g1',
		        Number_of_Group__c = 1
		    );
		    insert group2;
		    Sub_Group__c subGroup2 = new Sub_Group__c(
		        Sub_Group_Name__c = 'subGroup2',
		        External_ID__c = 'sg1',
		        Number_of_Sub_Group__c = 1
		    );
		    insert subGroup2;
		    Group_Sub_Group__c groupSubGroup2 = new Group_Sub_Group__c(
		        Group_Lookup__c = group2.Id,
		        Sub_Group_Lookup__c = subGroup2.Id,
		        Group__c = 'g1',
		        Sub_Group__c = 'sb1'
		    );
		    insert groupSubGroup2;
		    for(Account account:finalAccount){
		    	account.Group_Sub_Group__c = groupSubGroup2.Id;
		    }
		    update finalAccount;

		    GroupSubGroupTransaction_Service.updateGroupSubgroupTransactionAccordingToGroupSubgroupInAccounts(finalAccount);
		    List<Group_Sub_Group_Transaction__c> checkGSubGTran = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Group_Sub_Group_Lookup__c = :finalAccount[0].Group_Sub_Group__c];
		    System.assertEquals(1,checkGSubGTran.size());
        Test.stopTest();
	}
	@isTest static void accountClearGroupSubGroup() {
		Test.startTest();
	        //List<Account> finalAccount = [SELECT Id,Group_Sub_Group__c,Primary_Segment_Code__c FROM Account WHERE Name=:GroupSubGroupTransaction_Service_Test.accountName LIMIT 1];
	        List<Account> finalAccount = new List<Account>();
		    finalAccount.add(Mockup_Test.getFirstAccountFromName(GroupSubGroupTransaction_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c'));
		    for(Account account:finalAccount){
		    	account.Group_Sub_Group__c = null;
		    }
		    update finalAccount;

		    GroupSubGroupTransaction_Service.updateGroupSubgroupTransactionAccordingToGroupSubgroupInAccounts(finalAccount);
		    List<Group_Sub_Group_Transaction__c> checkGSubGTran = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Group_Sub_Group_Lookup__c = null AND CIS_ID__c = :finalAccount[0].Id];
		    System.assertEquals(1,checkGSubGTran.size());
        Test.stopTest();
	}
}