@isTest
private class CustomItemtoApproveSection_Test {
	public static String accountFirstName1 = 'accountFirstName1';
	@testSetup static void setupData(){
		Test.startTest();
			Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
         		mt.newAccount(accountFirstName1,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        	}
		Test.stopTest();
	}

	@isTest static void testCBSAdminItemToApproveSection() {
		Test.startTest();
			User userTL = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0];
			//Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :CustomItemtoApproveSection_Test.accountFirstName1 LIMIT 1][0];
			Account targetAccount = Mockup_Test.getFirstAccountFromName(CustomItemtoApproveSection_Test.accountFirstName1, 'Id,OwnerId');
			System.runAs(userTL){
				Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
					CIS_ID__c = targetAccount.Id,
					Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
					Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
					Reason__c = 'reason',
					Current_Owner__c = targetAccount.OwnerId
				);
				insert customerRequestNew;

				Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
				app.setObjectId(customerRequestNew.id);
				Approval.ProcessResult result = Approval.process(app);
			}
			Profile adminProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.CBS_ADMIN LIMIT 1][0];
			User userAdmin = Mockup_Test.newUser('admin12345','admin54321','9876543345',true,adminProfile.id,null,null);
			insert userAdmin;
			System.runAs(userAdmin){
				//Test.setCurrentPageReference(new PageReference('CustomItemtoApproveSection.page') );
				CustomItemtoApproveSection_Controller itemToApproveController = new CustomItemtoApproveSection_Controller();
				System.assertEquals(true,itemToApproveController.isCBSAdminUser);
				System.assertEquals(1,itemToApproveController.processInstanceWorkItemWrapperList.size());
				System.assertEquals(false,itemToApproveController.isSelectBulkAssignment);

				itemToApproveController.processInstanceWorkItemWrapperList.get(0).isChecked = true;
				itemToApproveController.approvalType = itemToApproveController.APPROVE;
				itemToApproveController.submitForApproval();

				itemToApproveController.filterType = itemToApproveController.BULK_ASSIGNMENT;
				itemToApproveController.setFilter();
				System.assertEquals(0,itemToApproveController.processInstanceWorkItemWrapperList.size());
				System.assertEquals(true,itemToApproveController.isSelectBulkAssignment);

				Customer_Ownership_Request__c customerRequest = [SELECT Id,Approval_Status__c From Customer_Ownership_Request__c WHERE CIS_ID__c = :targetAccount.id LIMIT 1][0];
				System.assertEquals('Approved',customerRequest.Approval_Status__c);
			}
		Test.stopTest();
	}

	@isTest static void testCoverageConstantVariable(){
		CustomItemtoApproveSection_Controller itemToApproveController = new CustomItemtoApproveSection_Controller();
			System.assertEquals('Items to Approve',itemToApproveController.SECTION_TITLE);
			System.assertEquals('Approve',itemToApproveController.APPROVE);
			System.assertEquals('Reject',itemToApproveController.REJECT);
			System.assertEquals('Related To',itemToApproveController.RELATED_TO);
			System.assertEquals('Type',itemToApproveController.TYPE);
			System.assertEquals('Most Recent Approver',itemToApproveController.MOST_RECENT_APPROVER);
			System.assertEquals('Date Submitted',itemToApproveController.DATE_SUBMITTED);
			System.assertEquals('Go to Bulk Assignment Page',itemToApproveController.GOTO_BULKASSIGNMENT_PAGE);
			System.assertEquals('Please Select At least one row',itemToApproveController.PLEASE_SELECT_AT_LEASE_ONE_ROW);

	}
	
	
}