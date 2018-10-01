@isTest
public without sharing class CBS_BulkAssignment_Test {

	public static String accountNameTL1 = 'accountNameTL1';
	public static String accountNameTL2 = 'accountNameTL2';

	public static String accountNameTM1 = 'accountNameTM1';
	public static String accountNameTM2 = 'accountNameTM2';

	public static String accountNameNHTL1 = 'accountNameNHTL1';
	public static String accountNameNHTL2 = 'accountNameNHTL2';

	public static String accountNameCBSAdmin1 = 'accountNameCBSAdmin1';
	public static String accountNameCBSAdmin2 = 'accountNameCBSAdmin2';

	public static String nhTLRCCode = 'nhtlRC';
	public static String nhTLTeamName = 'nhTLName';

	public static String tlUnderNHTLRCCode1 = 'nhtlRC1';
	public static String tlUnderNHTLTeamName1 = 'nhTLName1';

	public static String tlUnderNHTLFirstName = 'nhTL1FirstName';
	public static String tlUnderNHTLLastName = 'nhTL1LastName';
	public static String tlUnderNHTLEmpId = 'nhtl01';

	public static String stlRCCode = 'stlRC';
	public static String stlTeamName = 'stlName';

	public static String stlFirstName = 'stlFirstName';
	public static String stlLastName = 'stlFirstName';
	public static String stlEmpId = '7000000001';

	public static String teamUnderSTL1RCCode = 'team1';
	public static String teamUnderSTL1Name = 'team1';

	public static String tlUnderSTL1FirstName = 'tlUnderNHTL1FirstName';
	public static String tlUnderSTL1LastName = 'tlUnderNHTL1LastName';
	public static String tlUnderSTL1EmpId = '7000000002';
	


	@testSetup static void setup(){
		Test.startTest();
		TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        TriggerHandler.clearBypass('UserTriggerHandler');
        Integer pagesize = 150;
        Test.stopTest();

        Profile tlProfile = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.CBS_TL];
        UserRole tlRole = [SELECT Id, Name FROM UserRole WHERE Name =: Mockup_Test.TL_CB_RC_CODE];

        User nh = [SELECT Id, RC_Code__c, Employee_ID__c, FirstName, LastName FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];

        System.runAs(new User(Id=UserInfo.getUserId())){
        	Team_Structure__c tsNHTL = new Team_Structure__c(
	            External_ID__c = nhTLRCCode,
	            RC_Code__c = nhTLRCCode,
	            Name = nhTLTeamName,
	            Segment__c = 'CB',
	            Type__c = 'Team'
	        );
	        insert tsNHTL;

        	Team_Structure__c tsSTL = new Team_Structure__c(
	            External_ID__c = stlRCCode,
	            RC_Code__c = stlRCCode,
	            Name = stlTeamName,
	            Segment__c = 'CB',
	            Type__c = 'Team'
	        );
	        insert tsSTL;

	        Team_Structure__c tsTeamUnderSTL1 = new Team_Structure__c(
	            External_ID__c = teamUnderSTL1RCCode,
	            RC_Code__c = teamUnderSTL1RCCode,
	            Name = teamUnderSTL1Name,
	            Segment__c = 'CB',
	            Type__c = 'Team'
	        );
	        insert tsTeamUnderSTL1;
        }

        System.runAs(new User(Id=UserInfo.getUserId())){
        	User stl = Mockup_Test.newUser(
                stlFirstName,
                stlLastName,
                true,
                stlFirstName+'@mail.com',
                stlFirstName+'@mail.com',
                stlFirstName.substring(0, 4),
                tlProfile.Id,
                tlRole.Id,
                null,
                stlEmpId
	        );
	        stl.RC_Code__c = stlRCCode;
	        stl.Segment__c = GlobalConstants.SEGMENT_CB;
	        insert stl;

	        User tl1UnderSTL = Mockup_Test.newUser(
	                tlUnderSTL1FirstName,
	                tlUnderSTL1LastName,
	                true,
	                tlUnderSTL1FirstName+'@mail.com',
	                tlUnderSTL1FirstName+'@mail.com',
	                tlUnderSTL1FirstName.substring(0, 4),
	                tlProfile.Id,
	                tlRole.Id,
	                stl.Id,
	                tlUnderSTL1EmpId
	        );
	        tl1UnderSTL.RC_Code__c = teamUnderSTL1RCCode;
	        tl1UnderSTL.Segment__c = GlobalConstants.SEGMENT_CB;
	        insert tl1UnderSTL;
        }

        Team_Structure__c nhTlTeam = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: nhTLRCCode];

        User_Mirror_Management__c nhTLManagement = new User_Mirror_Management__c();
        nhTLManagement.Name = 'NHTL';
        nhTLManagement.Employee_ID__c = nh.Employee_ID__c;
        nhTLManagement.Employee_Name__c = nh.FirstName+' '+nh.LastName;
        nhTLManagement.User_Value__c = nh.RC_Code__c;
        nhTLManagement.Mirror_Value__c = nhTlTeam.RC_Code__c;
        nhTLManagement.Mirror_Type__c = GlobalConstants.USER_MIRROR_TYPE_RC_CODE;
        insert nhTLManagement;
        
  		//List<User_Mirror_Management__c> cbsNHTLManagement = [SELECT Employee_ID__c, Employee_Name__c, User_Value__c,Mirror_Value__c FROM User_Mirror_Management__c];
		

        
		
		System.runAs([SELECT Id FROM User WHERE Profile.Name = 'CBS-Admin' and IsActive = true LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
            mt.newAccount(accountNameCBSAdmin1,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameCBSAdmin2,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_cbs_admin');

            reassignController.getReAssignPermanenceFieldsForCBS();
            reassignController.getReAssignPermanenceFieldsDesForCBS();

            reassignController.getApprovalBulkAssignFieldsForCBS();
            reassignController.getApprovalBulkAssignFieldsDesForCBS();

            reassignController.getSalesTargetFieldsForCBS();
            reassignController.getSalesTargetFieldsDesForCBS();

            reassignController.getBulkSalesTargetFieldsForCBS();
            reassignController.getBulkSalesTargetFieldsDesForCBS();

            reassignController.setNHActAsTLFalse();
            reassignController.getCheckNHTL();

            reassignController.setNHActAsTLTrue();
            reassignController.getCheckNHTL();

        }

        

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
        	SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
            mt.newAccount(accountNameTL1,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameTL2,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            
            reassignController.getCheckNHTL();
            System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_cbs_tl');
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:stlFirstName LIMIT 1][0]){
        	SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        	System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_cbs_nh_tl');
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            mt.newAccount(accountNameTM1,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameTM2,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

	@isTest static void testPickList(){
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Profile.Name = 'CBS-Admin' and IsActive = true LIMIT 1][0]){
			

			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			ModelExtensions.QueryPickListObj qobj = new ModelExtensions.QueryPickListObj();
			ModelExtensions.PicklistByFilterKeyResponse objResponse = new ModelExtensions.PicklistByFilterKeyResponse();

			qobj.extra = 'All';
			qobj.scope = GlobalConstants.CBS_ADMIN;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByTeamName(qobj);

			qobj.extra = 'All';
			qobj.scope = stlRCCode;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByTeamName(qobj);

			qobj.extra = 'All';
			qobj.rccodes = '[1234,4567]';
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByTeamName(qobj);



			qobj= new ModelExtensions.QueryPickListObj();
			qobj.extra = 'All';
			qobj.isActive = true;
			qobj.scope = stlRCCode;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam(qobj);

			qobj= new ModelExtensions.QueryPickListObj();
			qobj.extra = 'All';
			qobj.scope = stlRCCode;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam(qobj);

			qobj= new ModelExtensions.QueryPickListObj();
			qobj.extra = 'All';
			qobj.scope = GlobalConstants.CBS_ADMIN;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam(qobj);

			qobj= new ModelExtensions.QueryPickListObj();
			qobj.extra = 'All';
			qobj.rccodes = '[1234,4567]';
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam(qobj);

			qobj= new ModelExtensions.QueryPickListObj();
			qobj.extra = 'All';
			qobj.rccodes = '[1234,4567]';
			qobj.isActive = true;
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam(qobj);

			qobj= new ModelExtensions.QueryPickListObj();
			qobj.sobjname = 'Bulk_Assignment_Queue__c';
			qobj.field = 'Request_Reason_Picklist__c';
			objResponse = SME_BulkAssignment_ListView_Controller.queryPickListOfObj(qobj);
		}
		Test.stopTest();
	}

	@isTest static void testSaveBulkCBSAdmin(){
		//Account accountTL = [SELECT Id FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];
		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Profile.Name = 'CBS-Admin' and IsActive = true LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        //Account accountTM = [SELECT Id, OwnerId FROM Account WHERE Id =:accountTL.Id LIMIT 1];
        //System.assertEquals(assignedUserTM.Id,accountTM.OwnerId);
	}

	@isTest static void testSaveBulkTL(){
		BottomUp_Notification_Settings__c bottomupNoti = new BottomUp_Notification_Settings__c();
		bottomupNoti.Enable_Notification__c = false;
		insert bottomupNoti;

		//Account accountTL = [SELECT Id FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];

		User userTL = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTL LIMIT 1];

		User_Extension__c userTLExtension = new User_Extension__c(User__c = userTL.Id);
		insert userTLExtension;

		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Team_Target__c teamTarget = new Team_Target__c();
		teamTarget.Deal_Base_Fee_Team_Target__c = 500000;
		teamTarget.Main_Operating_Bank_Team_Target__c = 500000;
		teamTarget.Transaction_Fee_Team_Target__c = 500000;
		teamTarget.External_ID__c = 'testTeamTarget';
		teamTarget.Year__c = String.valueOf(System.today().year());
		teamTarget.Team_Name__c = teamStructTL.Id;

		TriggerHandler.bypass('TeamTriggerHandler');
		insert teamTarget;
		TriggerHandler.clearBypass('TeamTriggerHandler');

		Sales_Target__c salesTarget = new Sales_Target__c();
		salesTarget.Deal_Base_Fee_Target__c = 500000;
		salesTarget.Main_Operating_Bank_Target__c = 500000;
		salesTarget.Transaction_Fee_Target__c = 500000;
		salesTarget.External_ID__c = 'testSalesTarget';
		salesTarget.Name__c = userTLExtension.Id;
		salesTarget.Is_Active__c = true;
		salesTarget.Year__c = String.valueOf(System.today().year());
		salesTarget.Team_Target__c = teamTarget.Id;
		insert salesTarget;

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

            List<SME_BulkAssignment_Model.SalesTarget> salesTargetSaveList = new List<SME_BulkAssignment_Model.SalesTarget>();

            SME_BulkAssignment_Model.SalesTarget salesTargetSave = new SME_BulkAssignment_Model.SalesTarget();
            salesTargetSave.salesTargetId = String.valueOf(salesTarget.Id);
            salesTargetSave.dealBaseFeeNewTarget = String.valueOf(500000);
            salesTargetSave.mainOperatingBankNewTarget = String.valueOf(500000);
            salesTargetSave.transactionFeeNewTarget = String.valueOf(500000);

            salesTargetSaveList.add(salesTargetSave);


			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;
		    svobj.salesTargets = salesTargetSaveList;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        Account accountTM = [SELECT Id, OwnerId FROM Account WHERE Id =: accountTL.Id LIMIT 1];
        System.assertEquals(userTL.Id,accountTM.OwnerId);
	}

	@isTest static void testSaveBulkTLSalesTargetNull(){
		BottomUp_Notification_Settings__c bottomupNoti = new BottomUp_Notification_Settings__c();
		bottomupNoti.Enable_Notification__c = false;
		insert bottomupNoti;

		//Account accountTL = [SELECT Id, OwnerId FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id,OwnerId');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];

		User userTL = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTL LIMIT 1];

		User_Extension__c userTLExtension = new User_Extension__c(User__c = userTL.Id);
		insert userTLExtension;

		System.runAs(userTL){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = accountTL.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
				Request_Ownership_Type__c = GlobalConstants.PORT,
				Reason__c = 'reason',
				Approval_Status__c = GlobalConstants.STATUS_OPEN,
				Current_Owner__c = userTL.Id
			);
			insert customerRequestNew;

			Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
	   		req1.setObjectId(customerRequestNew.id);
	    	Approval.ProcessResult result = Approval.process(req1);
		}



		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Team_Target__c teamTarget = new Team_Target__c();
		teamTarget.Deal_Base_Fee_Team_Target__c = 500000;
		teamTarget.Main_Operating_Bank_Team_Target__c = 500000;
		teamTarget.Transaction_Fee_Team_Target__c = 500000;
		teamTarget.External_ID__c = 'testTeamTarget';
		teamTarget.Year__c = String.valueOf(System.today().year());
		teamTarget.Team_Name__c = teamStructTL.Id;

		TriggerHandler.bypass('TeamTriggerHandler');
		insert teamTarget;
		TriggerHandler.clearBypass('TeamTriggerHandler');

		Sales_Target__c salesTarget = new Sales_Target__c();
		salesTarget.Deal_Base_Fee_Target__c = 500000;
		salesTarget.Main_Operating_Bank_Target__c = 500000;
		salesTarget.Transaction_Fee_Target__c = 500000;
		salesTarget.External_ID__c = 'testSalesTarget';
		salesTarget.Name__c = userTLExtension.Id;
		salesTarget.Is_Active__c = true;
		salesTarget.Year__c = String.valueOf(System.today().year());
		salesTarget.Team_Target__c = teamTarget.Id;
		insert salesTarget;

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

            List<SME_BulkAssignment_Model.SalesTarget> salesTargetSaveList = new List<SME_BulkAssignment_Model.SalesTarget>();

            SME_BulkAssignment_Model.SalesTarget salesTargetSave = new SME_BulkAssignment_Model.SalesTarget();
            salesTargetSave.salesTargetId = String.valueOf(salesTarget.Id);
            salesTargetSave.dealBaseFeeNewTarget = '';
            salesTargetSave.mainOperatingBankNewTarget = '';
            salesTargetSave.transactionFeeNewTarget = '';

            salesTargetSaveList.add(salesTargetSave);


			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;
		    svobj.salesTargets = salesTargetSaveList;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        Account accountTM = [SELECT Id, OwnerId FROM Account WHERE Id =: accountTL.Id LIMIT 1];
        System.assertEquals(userTL.Id,accountTM.OwnerId);
	}

	@isTest static void testHandleApprovalProcessApprove(){
		BottomUp_Notification_Settings__c bottomupNoti = new BottomUp_Notification_Settings__c();
		bottomupNoti.Enable_Notification__c = false;
		insert bottomupNoti;

		//Account accountTL = [SELECT Id, OwnerId FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id,OwnerId');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];

		User userTL = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTL LIMIT 1];

		User_Extension__c userTLExtension = new User_Extension__c(User__c = userTL.Id);
		insert userTLExtension;

		System.runAs(userTL){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = accountTL.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
				Request_Ownership_Type__c = GlobalConstants.PORT,
				Reason__c = 'reason',
				Approval_Status__c = GlobalConstants.STATUS_OPEN,
				Current_Owner__c = userTL.Id
			);
			insert customerRequestNew;

			Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
	   		req1.setObjectId(customerRequestNew.id);
	    	Approval.ProcessResult result = Approval.process(req1);
		}



		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Team_Target__c teamTarget = new Team_Target__c();
		teamTarget.Deal_Base_Fee_Team_Target__c = 500000;
		teamTarget.Main_Operating_Bank_Team_Target__c = 500000;
		teamTarget.Transaction_Fee_Team_Target__c = 500000;
		teamTarget.External_ID__c = 'testTeamTarget';
		teamTarget.Year__c = String.valueOf(System.today().year());
		teamTarget.Team_Name__c = teamStructTL.Id;

		TriggerHandler.bypass('TeamTriggerHandler');
		insert teamTarget;
		TriggerHandler.clearBypass('TeamTriggerHandler');

		Sales_Target__c salesTarget = new Sales_Target__c();
		salesTarget.Deal_Base_Fee_Target__c = 500000;
		salesTarget.Main_Operating_Bank_Target__c = 500000;
		salesTarget.Transaction_Fee_Target__c = 500000;
		salesTarget.External_ID__c = 'testSalesTarget';
		salesTarget.Name__c = userTLExtension.Id;
		salesTarget.Is_Active__c = true;
		salesTarget.Year__c = String.valueOf(System.today().year());
		salesTarget.Team_Target__c = teamTarget.Id;
		insert salesTarget;

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

            List<SME_BulkAssignment_Model.SalesTarget> salesTargetSaveList = new List<SME_BulkAssignment_Model.SalesTarget>();

            SME_BulkAssignment_Model.SalesTarget salesTargetSave = new SME_BulkAssignment_Model.SalesTarget();
            salesTargetSave.salesTargetId = String.valueOf(salesTarget.Id);
            salesTargetSave.dealBaseFeeNewTarget = '';
            salesTargetSave.mainOperatingBankNewTarget = '';
            salesTargetSave.transactionFeeNewTarget = '';

            salesTargetSaveList.add(salesTargetSave);


			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;
		    svobj.salesTargets = salesTargetSaveList;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'CBS-Admin' and IsActive = true LIMIT 1][0]){
        	List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
        	bulkAssignList = [SELECT Id FROM Bulk_Assignment__c];

        	List<String> approvalBulkIdList = new List<String>();
        	approvalBulkIdList.add(String.valueOf(bulkAssignList.get(0).Id));

        	SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'APPROVE';
		    svobj.gridName = 'approvalProcessBulkAssignGrid';
		    svobj.approvalIdList = approvalBulkIdList;
		    
		  	ModelExtensions.SavingResponse handleBulkApprove = SME_BulkAssignment_ListView_Controller.handleBulkApproval(svobj);

        	System.assertEquals(1,bulkAssignList.size());
        }
        

	}

	@isTest static void testHandleApprovalProcessReject(){
		BottomUp_Notification_Settings__c bottomupNoti = new BottomUp_Notification_Settings__c();
		bottomupNoti.Enable_Notification__c = false;
		insert bottomupNoti;

		//Account accountTL = [SELECT Id, OwnerId FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id,OwnerId');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];

		User userTL = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTL LIMIT 1];

		User_Extension__c userTLExtension = new User_Extension__c(User__c = userTL.Id);
		insert userTLExtension;

		System.runAs(userTL){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = accountTL.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
				Request_Ownership_Type__c = GlobalConstants.PORT,
				Reason__c = 'reason',
				Approval_Status__c = GlobalConstants.STATUS_OPEN,
				Current_Owner__c = userTL.Id
			);
			insert customerRequestNew;

			Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
	   		req1.setObjectId(customerRequestNew.id);
	    	Approval.ProcessResult result = Approval.process(req1);
		}



		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Team_Target__c teamTarget = new Team_Target__c();
		teamTarget.Deal_Base_Fee_Team_Target__c = 500000;
		teamTarget.Main_Operating_Bank_Team_Target__c = 500000;
		teamTarget.Transaction_Fee_Team_Target__c = 500000;
		teamTarget.External_ID__c = 'testTeamTarget';
		teamTarget.Year__c = String.valueOf(System.today().year());
		teamTarget.Team_Name__c = teamStructTL.Id;

		TriggerHandler.bypass('TeamTriggerHandler');
		insert teamTarget;
		TriggerHandler.clearBypass('TeamTriggerHandler');

		Sales_Target__c salesTarget = new Sales_Target__c();
		salesTarget.Deal_Base_Fee_Target__c = 500000;
		salesTarget.Main_Operating_Bank_Target__c = 500000;
		salesTarget.Transaction_Fee_Target__c = 500000;
		salesTarget.External_ID__c = 'testSalesTarget';
		salesTarget.Name__c = userTLExtension.Id;
		salesTarget.Is_Active__c = true;
		salesTarget.Year__c = String.valueOf(System.today().year());
		salesTarget.Team_Target__c = teamTarget.Id;
		insert salesTarget;

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

            List<SME_BulkAssignment_Model.SalesTarget> salesTargetSaveList = new List<SME_BulkAssignment_Model.SalesTarget>();

            SME_BulkAssignment_Model.SalesTarget salesTargetSave = new SME_BulkAssignment_Model.SalesTarget();
            salesTargetSave.salesTargetId = String.valueOf(salesTarget.Id);
            salesTargetSave.dealBaseFeeNewTarget = '';
            salesTargetSave.mainOperatingBankNewTarget = '';
            salesTargetSave.transactionFeeNewTarget = '';

            salesTargetSaveList.add(salesTargetSave);


			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;
		    svobj.salesTargets = salesTargetSaveList;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'CBS-Admin' and IsActive = true LIMIT 1][0]){
        	List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
        	bulkAssignList = [SELECT Id FROM Bulk_Assignment__c];

        	List<String> approvalBulkIdList = new List<String>();
        	approvalBulkIdList.add(String.valueOf(bulkAssignList.get(0).Id));

        	SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.rejectReason = 'Good Customer';
            selectName.rejectReasonText = 'Test';

        	SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'REJECT';
		    svobj.selectName = selectName;
		    svobj.gridName = 'approvalProcessBulkAssignGrid';
		    svobj.approvalIdList = approvalBulkIdList;
		    
		  	ModelExtensions.SavingResponse handleBulkApprove = SME_BulkAssignment_ListView_Controller.handleBulkApproval(svobj);

        	System.assertEquals(1,bulkAssignList.size());
        }
	}

	@isTest static void testHandleApprovalProcessRecall(){
		BottomUp_Notification_Settings__c bottomupNoti = new BottomUp_Notification_Settings__c();
		bottomupNoti.Enable_Notification__c = false;
		insert bottomupNoti;

		//Account accountTL = [SELECT Id, OwnerId FROM Account WHERE Name =: accountNameTL1 LIMIT 1];
		Account accountTL = Mockup_Test.getFirstAccountFromName(accountNameTL1, 'Id,OwnerId');
		User assignedUserTM = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTM LIMIT 1];

		User userTL = [SELECT Id, RC_Code__c FROM User WHERE Firstname =: Mockup_Test.userFirstNameCBTL LIMIT 1];

		User_Extension__c userTLExtension = new User_Extension__c(User__c = userTL.Id);
		insert userTLExtension;

		System.runAs(userTL){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = accountTL.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS,
				Request_Ownership_Type__c = GlobalConstants.PORT,
				Reason__c = 'reason',
				Approval_Status__c = GlobalConstants.STATUS_OPEN,
				Current_Owner__c = userTL.Id
			);
			insert customerRequestNew;

			Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
	   		req1.setObjectId(customerRequestNew.id);
	    	Approval.ProcessResult result = Approval.process(req1);
		}



		Team_Structure__c teamStructTL = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c =: assignedUserTM.RC_Code__c];

		String assignedUserString = String.valueOf(assignedUserTM.Id);

		Team_Target__c teamTarget = new Team_Target__c();
		teamTarget.Deal_Base_Fee_Team_Target__c = 500000;
		teamTarget.Main_Operating_Bank_Team_Target__c = 500000;
		teamTarget.Transaction_Fee_Team_Target__c = 500000;
		teamTarget.External_ID__c = 'testTeamTarget';
		teamTarget.Year__c = String.valueOf(System.today().year());
		teamTarget.Team_Name__c = teamStructTL.Id;

		TriggerHandler.bypass('TeamTriggerHandler');
		insert teamTarget;
		TriggerHandler.clearBypass('TeamTriggerHandler');

		Sales_Target__c salesTarget = new Sales_Target__c();
		salesTarget.Deal_Base_Fee_Target__c = 500000;
		salesTarget.Main_Operating_Bank_Target__c = 500000;
		salesTarget.Transaction_Fee_Target__c = 500000;
		salesTarget.External_ID__c = 'testSalesTarget';
		salesTarget.Name__c = userTLExtension.Id;
		salesTarget.Is_Active__c = true;
		salesTarget.Year__c = String.valueOf(System.today().year());
		salesTarget.Team_Target__c = teamTarget.Id;
		insert salesTarget;

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			List<String> cisList = new List<String>();
			cisList.add(String.valueOf(accountTL.Id));

			SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.selectedByTeamRCCode = String.valueOf(teamStructTL.Id);
            selectName.selectedByUserId = String.valueOf(assignedUserTM.Id);

            List<SME_BulkAssignment_Model.SalesTarget> salesTargetSaveList = new List<SME_BulkAssignment_Model.SalesTarget>();

            SME_BulkAssignment_Model.SalesTarget salesTargetSave = new SME_BulkAssignment_Model.SalesTarget();
            salesTargetSave.salesTargetId = String.valueOf(salesTarget.Id);
            salesTargetSave.dealBaseFeeNewTarget = '';
            salesTargetSave.mainOperatingBankNewTarget = '';
            salesTargetSave.transactionFeeNewTarget = '';

            salesTargetSaveList.add(salesTargetSave);


			SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'SAVE_BULK';
		    svobj.gridName = 'reAssignPermanenceGrid';
		    svobj.selectName = selectName;
		    svobj.bulkCISlist = cisList;
		    svobj.fromCBS = true;
		    svobj.salesTargets = salesTargetSaveList;

		    ModelExtensions.SavingResponse saveBulkCBSAdmin = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);
            
        }
        Test.stopTest();

        System.runAs(userTL){
        	List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
        	bulkAssignList = [SELECT Id FROM Bulk_Assignment__c];

        	List<String> approvalBulkIdList = new List<String>();
        	approvalBulkIdList.add(String.valueOf(bulkAssignList.get(0).Id));

        	SME_BulkAssignment_Model.SelectedName selectName = new SME_BulkAssignment_Model.SelectedName();
            selectName.rejectReason = 'Good Customer';
            selectName.rejectReasonText = 'Test';

        	SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
		    svobj.contx = 'RECALL';
		    svobj.gridName = 'approvalProcessBulkAssignGrid';
		    svobj.approvalIdList = approvalBulkIdList;
		    
		  	ModelExtensions.SavingResponse handleBulkApprove = SME_BulkAssignment_ListView_Controller.handleBulkApproval(svobj);

        	System.assertEquals(1,bulkAssignList.size());
        }
	}

	@isTest static void testnhTLAsTLWith1Team(){
		User nh = [SELECT Id, RC_Code__c, Employee_ID__c, FirstName, LastName FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];

		System.runAs(nh){
        	SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        	reassignController.getCheckNHTL();
        	reassignController.setNHActAsTLTrue();
        	System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_cbs_tl');
        }
    }

    @isTest static void testnhTLAsTLWith2Team(){
		User nh = [SELECT Id, RC_Code__c, Employee_ID__c, FirstName, LastName FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
		Profile tlProfile = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.CBS_TL];
        UserRole tlRole = [SELECT Id, Name FROM UserRole WHERE Name =: Mockup_Test.TL_CB_RC_CODE];
        Test.startTest();
		System.runAs(new User(Id=UserInfo.getUserId())){
			Team_Structure__c tsTL1UnderNHTL = new Team_Structure__c(
	            External_ID__c = tlUnderNHTLRCCode1,
	            RC_Code__c = tlUnderNHTLRCCode1,
	            Name = tlUnderNHTLTeamName1,
	            Segment__c = 'CB',
	            Type__c = 'Team'
	        );
	        insert tsTL1UnderNHTL;
		}

		System.runAs(new User(Id=UserInfo.getUserId())){
			User tlUnderNHTL1 = Mockup_Test.newUser(
                tlUnderNHTLFirstName,
                tlUnderNHTLLastName,
                true,
                tlUnderNHTLFirstName+'@mail.com',
                tlUnderNHTLFirstName+'@mail.com',
                tlUnderNHTLFirstName.substring(0, 4),
                tlProfile.Id,
                tlRole.Id,
                nh.Id,
                tlUnderNHTLEmpId
	        );
	        tlUnderNHTL1.RC_Code__c = tlUnderNHTLRCCode1;
	        tlUnderNHTL1.Segment__c = GlobalConstants.SEGMENT_CB;
	        tlUnderNHTL1.Employee_ID__c = '4343434343';
	        insert tlUnderNHTL1;
		}
		Test.stopTest();

		

		System.runAs(nh){
        	SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        	reassignController.getCheckNHTL();
        	reassignController.setNHActAsTLTrue();
        	System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_cbs_nh_tl');
        }
    }
}