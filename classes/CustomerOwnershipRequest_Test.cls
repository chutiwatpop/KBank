/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
* @29/03/2017 CBS-CR005 add test method testCBSRMRequestOwnershipFromCBSAdmin
*/
@isTest
private class CustomerOwnershipRequest_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
	public static String accountNameTMPer = 'tmCreatedAccountPer';
	public static String accountNameRMPer = 'accountNameRMPer0';
	public static String accountNameRMPer1 = 'accountNameRMPer1';
	public static String accountNameRMPer2 = 'accountNameRMPer2';

	public static String userRcCode1 = '52215';
	public static String userRcCode2 = '52216';
	public static String targetFirstName1 = 'manualNhUserFirstName1';
	public static String targetLastName1 = 'manualNhUserLastName1';
	public static String targetFirstName2 = 'manualNhUserFirstName2';
	public static String targetLastName2 = 'manualNhUserLastName2';

	public static String targetAccountCBSName = 'rmCBCreateAccount1';
	public static String cbsAdminFirstName = 'CBSadminFristName';
	public static String cbsAdminLastName = 'CBSadminLastName';

	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMPer,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMPer1,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMPer2,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
        	mt.newAccount(accountNameTMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    		//Mockup_Test.newAccountShare(
    		//	[SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Id,
			//	[SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1][0].Id,
			//	'edit',
			//	'edit'
    		//);

    		Mockup_Test.newAccountShare(
            	[SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Id,
				Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameTM, 'Id').Id,
				'edit',
				'edit'
            );
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
        	Account account = Mockup_Test.newAccountWithSegment(targetAccountCBSName,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
        	account.CIS__c = '111111';
        	insert account;

        }
        Test.startTest();
        setupDataForTestReleaseOtherSegment();
        Test.stopTest();
	}

	private static void monkUserExt(){

		Account targetAccount1 = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id,OwnerId,SME_Temporary_Customer__c');
		Account targetAccount2 = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer1, 'Id,OwnerId,SME_Temporary_Customer__c');
		Account targetAccount3 = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer2, 'Id,OwnerId,SME_Temporary_Customer__c');
	
		List<User_Extension__c> userList = new List<User_Extension__c>();

		User_Extension__c userExt = new User_Extension__c();
		userExt.User__c = targetAccount1.OwnerId;
		userList.add(userExt);

		User_Extension__c userExt2 = new User_Extension__c();
		userExt2.User__c = targetAccount2.OwnerId;
		userList.add(userExt2);

		User_Extension__c userExt3 = new User_Extension__c();
		userExt3.User__c = targetAccount3.OwnerId;
		userList.add(userExt3);

		insert userList;
	}

	private static void setupDataForTestReleaseOtherSegment(){
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		//Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer1 LIMIT 1];
		monkUserExt();

		System.runAs(userRM){
		Account targetAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer1, 'Id,OwnerId,SME_Temporary_Customer__c');
		targetAccount.SME_Temporary_Customer__c = null;
		update targetAccount;

			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = targetAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_NOT_SME,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'MB',
				Reason__c = 'reason',
				Current_Owner__c = targetAccount.OwnerId
			);
			insert customerRequestNew;

			Customer_Ownership_Request__c customerRequest = [SELECT Id,Approval_Status__c FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			customerRequest.Current_Owner__c = UserInfo.getUserId();
			update customerRequest;
		}
		
	}
	/*@isTest static void sendRequestApprovalFromAction(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userRM){
			//insert new Customer_Ownership_Request__c(
			//		CIS_ID__c = targetAccount.Id,
			//		Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
			//		Want_to_request_for_ownership__c = true
			//	);
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
        Account finalAccount = [SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
        System.assertEquals(GlobalConstants.PORT,finalAccount.Port_Pool__c);
        System.assertEquals(userRM.Id,finalAccount.OwnerId);
        System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	}

	@isTest static void sendReleaseApprovalFromAction(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userTM){
			insert new Customer_Ownership_Request__c(
					CIS_ID__c = targetAccount.Id,
					Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
					Want_to_request_for_ownership__c = true
				);
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.RELEASE_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
	}
	@isTest static void changeOwnerWhenApproved(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userRM){
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
        System.assertEquals(GlobalConstants.PORT,finalAccount.Port_Pool__c);
        System.assertEquals(userRM.Id,finalAccount.OwnerId);
        System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	}*/

	@isTest static void releaseOtherSegment(){
		//Account accountPer = [SELECT Id,Primary_Segment_Code__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer1 LIMIT 1];
		Account accountPer = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer1, 'Id,Primary_Segment_Code__c');
        accountPer.Primary_Segment_Code__c = 'SM';
        Test.startTest();
        update accountPer;
        Test.stopTest();

        Account finalAccount = [SELECT Id, Owner.ProfileId, Owner.Profile.Name FROM Account WHERE Id = :accountPer.Id LIMIT 1];
        //System.assertEquals(String.valueOf(UserInfo.getProfileId()),String.valueOf(finalAccount.Owner.ProfileId));
	}

	@isTest static void releaseWrongAreaWithNH(){
		String expectedOwnerNameResult = targetFirstName1 + ' ' + targetLastName1;
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		//Account releaseAccount = [SELECT Id ,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c, OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		Account releaseAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id ,Name,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c, OwnerId');
		System.assertEquals(null,releaseAccount.Current_Owner_Extension__r.Name);
		System.assertNotEquals(userRcCode1,releaseAccount.Current_Team_Name__r.External_ID__c);

		Test.startTest();
			Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];

			Team_Structure__c tsNh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = userRcCode1,
				External_ID__c = userRcCode1
			);
			insert tsNh;

			User manualNhUser = Mockup_Test.newUser(
		            targetFirstName1,
			    	targetLastName1,
		            true,
		            targetFirstName1 +'@mail.com',
		            targetFirstName1 +'@mail.com',
		            targetFirstName1.substring(0, 4),
		            nhProfile.Id,
		            null,
		            null,
		            '9999999991'
		    );
		    manualNhUser.RC_Code__c = userRcCode1;
		    manualNhUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		    manualNhUser.Job_Code__c = 'ME1A';
		    manualNhUser.Status__c = 'A';
		    insert manualNhUser;
		Test.stopTest();

		Team_Structure__c tempTs = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c =:userRcCode1];
		Master_Map__c mapObject = new Master_Map__c(
			Code__c = '77667',
			Type__c = 'test type'
		);
		insert mapObject;
		
		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'ME',
				Reason__c = 'reason',
				Refer_Out_Team__c = tempTs.Name,
				Refer_Out_Area__c = mapObject.Id,
				Current_Owner__c = releaseAccount.OwnerId
			);
			System.debug('Insert in test method');
			System.debug('Customer request new : '+customerRequestNew);
			insert customerRequestNew;
		}
			Customer_Ownership_Request__c customerRequest;
			customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			customerRequest.Current_Owner__c = releaseAccount.OwnerId;
			update customerRequest;		
		
		

        Account finalAccount = [SELECT Id, Name, Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c,Owner.Name FROM Account WHERE Id = :releaseAccount.Id LIMIT 1];
        
        //System.assertEquals(expectedOwnerNameResult,finalAccount.Current_Owner_Extension__r.Name);
        //System.assertEquals(userRcCode1,finalAccount.Current_Team_Name__r.External_ID__c);
	}

	@isTest static void releaseTmPool(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account releaseAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id , OwnerId, Customer_s_Business_Code__c, Owner.Segment__c');
		System.assertEquals(userRM.Id,releaseAccount.OwnerId);
		Test.startTest();
		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = 'TM Pool',
				Not_SME_Segment_Flag__c = false,
				Reason__c = 'reason'
			);
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			ReleaseOwnershipService.setRequestorApprover(customerRequestNew, releaseAccount, currentUser);
			insert customerRequestNew;
		}
		
		Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
		update customerRequest;

		Test.stopTest();
        Account finalAccount = [SELECT Id, Name, OwnerId FROM Account WHERE Id = :releaseAccount.Id LIMIT 1];
        
        System.assertEquals(userTM.Id,finalAccount.OwnerId);
	}

	@isTest static void releaseWrongAreaStatusApprovalInProgress(){
		//TriggerHandler.bypass('TeamStructureTriggerHandler');
		String expectedOwnerNameResult = targetFirstName1 + ' ' + targetLastName1;

		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		//Account releaseAccount = [SELECT Id ,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		Account releaseAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id ,Name,OwnerId,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c');
		System.assertEquals(null,releaseAccount.Current_Owner_Extension__r.Name);
		System.assertNotEquals(userRcCode1,releaseAccount.Current_Team_Name__r.External_ID__c);

		Test.startTest();
			Profile ahProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
			Profile rmProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

			Team_Structure__c tsAh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = userRcCode1,
				External_ID__c = userRcCode1,
				Name = 'Ah Team 1',
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Area'
			);
			insert tsAh;

			Team_Structure__c tsNh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = userRcCode2,
				External_ID__c = userRcCode2,
				Name = 'เครือข่ายลูกค้าผู้ประกอบการ 2 Team 1',
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Network'
			);
			insert tsNh;

			User manualAhUser = Mockup_Test.newUser(
		            targetFirstName1,
			    	targetLastName1,
		            true,
		            targetFirstName1 +'@mail.com',
		            targetFirstName1 +'@mail.com',
		            targetFirstName1.substring(0, 4),
		            ahProfile.Id,
		            null,
		            null,
		            '9999999991'
		    );
		    manualAhUser.RC_Code__c = userRcCode1;
		    manualAhUser.AH_RC_Code__c = userRcCode1;
		    manualAhUser.Job_Code__c = 'ME2A';
		    manualAhUser.Status__c = 'A';
		    insert manualAhUser;

		    User manualRmUser2 = Mockup_Test.newUser(
		            targetFirstName2,
			    	targetLastName2,
		            true,
		            targetFirstName2 +'@mail.com',
		            targetFirstName2 +'@mail.com',
		            targetFirstName2.substring(0, 4),
		            rmProfile.Id,
		            null,
		            manualAhUser.Id,
		            '9999999992'
		    );
		    manualRmUser2.RC_Code__c = userRcCode2;
		    manualRmUser2.AH_RC_Code__c = userRcCode1;
		    manualRmUser2.Job_Code__c = 'ME4A';
		    manualRmUser2.Status__c = 'A';
		    insert manualRmUser2;

		Test.stopTest();

		Team_Structure__c tempTs = [SELECT Id,Name FROM Team_Structure__c WHERE External_ID__c =:userRcCode1];

		System.runAs(userRM){	
			Master_Map__c mapObject = new Master_Map__c(
				Code__c = '77667',
				Type__c = 'test type'
			);
			insert mapObject;
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'ME',
				Reason__c = 'reason',
				Refer_Out_Team__c = tempTs.Name,
				Refer_Out_Area__c = mapObject.Id
			);
			insert customerRequestNew;
		}
		Team_Structure__c defaultTs = [SELECT Id,Name FROM Team_Structure__c WHERE External_ID__c =:userRcCode2];
				
		Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		
		customerRequest.Approval_Status__c = 'Approval In Progress';
		customerRequest.Refer_Out_Team__c = defaultTs.Name;
		update customerRequest;		

        Customer_Ownership_Request__c customerRequestResult = [SELECT Id,Current_Owner__r.Name,Current_Owner_TM__r.Name,Current_Owner_AH__r.Name,Current_Owner_NH__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		
        System.assertEquals(expectedOwnerNameResult,customerRequestResult.Current_Owner__r.Name);
        System.assertEquals(expectedOwnerNameResult,customerRequestResult.Current_Owner_TM__r.Name);
        System.assertEquals(null,customerRequestResult.Current_Owner_AH__r.Name);
        System.assertEquals(null,customerRequestResult.Current_Owner_NH__r.Name);
	}

	/*@isTest static void changeOwnerWhenApproved2(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
		//Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameTM, 'Id,Name,Delete_Flag__c');
		System.runAs(userAH){
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Year_End_Assignment__c yearEnd = new Year_End_Assignment__c();
			yearEnd.CIS_ID_Unique__c = targetAccount.Id;
    		yearEnd.CIS_ID__c = targetAccount.Id;
    		yearEnd.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
			insert yearEnd;

			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				customerRequest.Year_End_Assignment__c = yearEnd.Id;
				customerRequest.Requestor_AH__c = userAH.Id;
				update customerRequest;
			Test.stopTest();
		
			Customer_Ownership_Request__c customerOwnerReq = [SELECT Requestor_AH__c FROM Customer_Ownership_Request__c WHERE Year_End_Assignment__c = :yearEnd.Id LIMIT 1];
			Year_End_Assignment__c finalYE = [SELECT Id, OwnerId FROM Year_End_Assignment__c LIMIT 1][0];
	        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
	        //System.assertEquals(userRM.Id,finalAccount.OwnerId);
	        //System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	        System.assertEquals(finalYE.OwnerId, customerOwnerReq.Requestor_AH__c);
		}
	}*/

	@isTest static void testReleaseReasonClosedBusiness(){
		Test.startTest();
		CBS_Admin_Ownership__c cbsADMIN = CBS_Admin_Ownership__c.getOrgDefaults();
		//User cbsADMIN = [SELECT id From User WHERE Profile.Name = :GlobalConstants.CBS_ADMIN LIMIT 1][0];
		User cbsRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
		//User cbsTL = [SELECT Id From User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0];
		//Account releaseAccount = [SELECT Id,OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.targetAccountCBSName LIMIT 1];
		Account releaseAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.targetAccountCBSName, 'Id,OwnerId');
		System.runAs(cbsRM){
				Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
				Reason__c = 'Reason'
			);
			insert customerRequestNew;

			Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			update customerRequest;
		}
		Account accountFinal = [SELECT Id,OwnerId FROM Account WHERE Id = :releaseAccount.Id LIMIT 1];

		System.assertEquals(cbsADMIN.User_Record_ID__c,accountFinal.OwnerId);
		Test.stopTest();
	}

	/*@isTest static void testSMEReleaseToCBSReasonCompanyRelatedWithNHTLisApprover(){
		Test.startTest();
			String userNHTLFirstName = 'userNHTLFirstName';
			String userNHTLLastName = 'userNHTLFirstName';
			List<User> userToUpdateList = new List<User>();

			Profile profileNH = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
			User userNHTL = Mockup_Test.newUser(userNHTLFirstName, userNHTLLastName,'111112', true, profileNH.id, null, null);
			userNHTL.RC_Code__c = 'NHTLRCCODE';
			System.runAs(new User(Id=UserInfo.getUserId())){
				insert userNHTL;
			}
			
			
			Team_Structure__c teamStrcutureTL = [SELECT Id,Name,Segment__c From Team_Structure__c WHERE Name = :Mockup_Test.tlTeamName LIMIT 1];
			teamStrcutureTL.Segment__c = GlobalConstants.SEGMENT_CB;
			update teamStrcutureTL;

			User userTL = [SELECT Id,RC_Code__c,Team_Name__c,ManagerId  From User WHERE Firstname = :Mockup_Test.userFirstNameCBTL LIMIT 1];
				userTL.ManagerId = userNHTL.Id;
				userTL.Team_Name__c = teamStrcutureTL.Name;
			userToUpdateList.add(userTL);

			User userCBRM = [SELECT Id,RC_Code__c,Team_Name__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
				userCBRM.Team_Name__c = teamStrcutureTL.Name;
			userToUpdateList.add(userCBRM);

			User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
				userRM.Segment__c = GlobalConstants.SEGMENT_SE;
			userToUpdateList.add(userRM);

			TriggerHandler.bypass('UserTriggerHandler');
			System.runAs(new User(Id=UserInfo.getUserId())){
				update userToUpdateList;
			}
			TriggerHandler.clearbypass('UserTriggerHandler');



			System.runAs(new User(Id=UserInfo.getUserId())){
				User_Mirror_Management__c userMirrorCustomSetting = new User_Mirror_Management__c(User_Value__c = userNHTL.RC_Code__c, Mirror_Value__c = userTL.RC_Code__c,Employee_ID__c = userNHTL.Employee_ID__c,Employee_Name__c = userNHTL.Firstname +' '+userNHTL.LastName ,Name ='NHTL001',Mirror_Type__c = GlobalConstants.USER_MIRROR_TYPE_RC_CODE);
				insert userMirrorCustomSetting;
			}

			Account relatedAccount = [SELECT Id,CIS__c,OwnerId,Owner.Name From account WHERE CIS__c = '111111' LIMIT 1];
			Account targetAccount = [SELECT Id,CIS__C,OwnerId,Owner.Name FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
			
			Customer_Ownership_Request__c customerRequestNew;
			System.runAs(userRM){
				customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = targetAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_COMPANY_RELATED,
				Company_Related_Text__c = relatedAccount.CIS__c,
				Refer_Out_Team__c = userTL.Team_Name__c,
				Reason__c = 'Reason',
				Is_Current_Owner_NHTL__c = true
			);
			insert customerRequestNew;

			
			Customer_Ownership_Request__c temp =[SELECT Id,RecordTypeId,Refer_Out_Reason__c,Refer_Out_Team__c,CIS_ID__c,Request_Type__c,Requestor_TM__c,Requestor_AH__c,Requestor_NH__c,Current_Owner__c,Current_Owner_TM__c,Current_Owner_AH__c,Current_Owner_NH__c From Customer_Ownership_Request__c WHERE Id =:customerRequestNew.id LIMIT 1];

        	Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
       		req1.setObjectId(customerRequestNew.id);
        	Approval.ProcessResult result = Approval.process(req1);
        	// Verify the result
        	System.assert(result.isSuccess());

			}

			User userTM = [SELECT Id From User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0];
			System.runAs(userTM){
				ProcessInstanceWorkitem processInstantItem = [SELECT Id,ProcessInstance.TargetObject.Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.Id =:customerRequestNew.id AND ActorId = :userTM.Id LIMIT 1];
				Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
				req.setAction('Approve');
				req.setWorkitemId(processInstantItem.id);
				Approval.process(req);
			}

			System.runAs(userNHTL){
				ProcessInstanceWorkitem processInstantItem = [SELECT Id,ProcessInstance.TargetObject.Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.Id =:customerRequestNew.id AND ActorId = :userNHTL.Id LIMIT 1];
				Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
				req.setAction('Approve');
				req.setWorkitemId(processInstantItem.id);
				Approval.process(req);
			}

			Account finalAccount = [SELECT Id,OwnerId,Primary_Segment_Code__c,Current_Team_Name__r.Name From Account WHERE Id = :targetAccount.Id];

			System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_CB,finalAccount.Primary_Segment_Code__c);
			System.assertEquals(userTL.id,finalAccount.OwnerId);
			System.assertEquals(userTL.Team_Name__c,finalAccount.Current_Team_Name__r.Name);

		Test.stopTest();

	}*/

	//@isTest static void testCBSTLRequestCustomerFromSMERM(){
	//	Test.startTest();

	//		Team_Structure__c teamStrcutureTL = [SELECT Id,Name,Segment__c From Team_Structure__c WHERE Name = :Mockup_Test.tlTeamName LIMIT 1];
	//		teamStrcutureTL.Segment__c = GlobalConstants.SEGMENT_CB;
	//		update teamStrcutureTL;

	//		List<User> userToUpdateList = new List<User>();
	//		User userTL = [SELECT Id,RC_Code__c,Team_Name__c  From User WHERE Firstname = :Mockup_Test.userFirstNameCBTL LIMIT 1];
	//			userTL.Team_Name__c = teamStrcutureTL.Name;
	//		userToUpdateList.add(userTL);


	//		User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
	//		userRM.Segment__c = GlobalConstants.SEGMENT_SE;
	//		userToUpdateList.add(userRM);
	//		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
	//			update userToUpdateList;
	//		}
			

	//		Account targetAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id,Name,CIS__C,OwnerId,Owner.Name,Primary_Segment_Code__c');
	//		targetAccount.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM;
	//		targetAccount.CIS__c = '222222';
	//		System.runAs(new User(Id=UserInfo.getUserId())){
				
	//			update targetAccount;
	//		}

	//		Customer_Ownership_Request__c customerRequestNew;
	//		customerRequestNew = new Customer_Ownership_Request__c(
	//				CIS_ID__c = targetAccount.Id,
	//				Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
	//				Request_Ownership_Type__c = GlobalConstants.PORT,
	//				Reason__c = 'Reason',
	//				Approval_Status__c = 'Open',
	//				Current_Owner__c = userTL.Id
	//			);
	//			//insert customerRequestNew;
	//			insert customerRequestNew;
	//		System.runAs(userTL){
	//			Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name,OwnerId FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
	//			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
	//			update customerRequest;
	//		}
	//		Test.stopTest();
	
	//		//Account targetAccountAfrerChangeOwner = [SELECT Id,OwnerId From Account WHERE Id = :targetAccount.id LIMIT 1]; 
	//		//System.assertEquals(UserInfo.getUserId(),targetAccountAfrerChangeOwner.OwnerId);
	//}

	//Add For (CBS-Ongoing) CBS-CR005
	/*@isTest static void testCBSRMRequestOwnershipFromCBSAdmin(){
		Test.startTest();
		User cbsAdmin = [SELECT Id From User WHERE Firstname = :Mockup_Test.userFirstNameCBSAdmin LIMIT 1];
		//Account targetAccount = [SELECT Id,CIS__C,OwnerId,Owner.Name,Primary_Segment_Code__c,OwnerChangeExecutedByTrigger__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(CustomerOwnershipRequest_Test.accountNameRMPer, 'Id,Name,CIS__C,OwnerId,Owner.Name,Primary_Segment_Code__c,OwnerChangeExecutedByTrigger__c');
		targetAccount.OwnerChangeExecutedByTrigger__c = true;
		targetAccount.Owner = cbsAdmin;
		update targetAccount;

		User cbsRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];

		AccountShare accShare =  new AccountShare( CaseAccessLevel = 'none',
                                    OpportunityAccessLevel = 'none',
                                    AccountAccessLevel = 'read',
                                    AccountId = targetAccount.id,
                                    UserOrGroupId = cbsRM.Id);
		insert accShare;

		System.runAs(cbsRM){
				Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
					CIS_ID__c = targetAccount.Id,
					Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
					Request_Ownership_Type__c = GlobalConstants.PORT,
					Reason__c = 'Reason',
					Approval_Status__c = 'Open'
				);
				insert customerRequestNew;
		}

		System.runAs(new User(Id=UserInfo.getUserId())){
			Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name,OwnerId FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			update customerRequest;
		}
		Test.stopTest();
		Account targetAccountAfrerChangeOwner = [SELECT Id,OwnerId From Account WHERE Id = :targetAccount.id LIMIT 1]; 
		System.assertEquals(cbsRM.id,targetAccountAfrerChangeOwner.OwnerId);

	}*/


}