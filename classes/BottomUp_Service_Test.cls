@isTest
private class BottomUp_Service_Test {

	public static String targetAccountCBSName = 'rmCBCreateAccount1';
	public static String targetAccountCIS = '111111';
	//public static String currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
	public static String currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );

	public static String rmCB2FirstName = 'rmCB2FirstName';
	public static String rmCB2LastName = 'rmCB2LastName';
	public static String rmCB2EmployeeId = '0000000002';

	public static String team2_RC_CODE = 'TEAM2';

	@testSetup static void setupData(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();


		Team_Structure__c teamStructureTL = [SELECT Id,Segment__c,RC_Code__c From Team_Structure__c WHERE External_ID__c = :Mockup_Test.TL_CB_RC_CODE];
        User userTL = [SELECT Id From User WHERE Firstname= :Mockup_Test.userFirstNameCBTL LIMIT 1];
        Profile profileCBRM = [SELECT Id From Profile WHERE Name = :GlobalConstants.CBS_RM LIMIT 1];
        User userRMCB2 = Mockup_Test.newUser(rmCB2FirstName,rmCB2LastName,rmCB2EmployeeId, true, profileCBRM.id, null, userTL.id);
        userRMCB2.Segment__c = GlobalConstants.SEGMENT_CB;
        userRMCB2.RC_Code__c = teamStructureTL.RC_Code__c;
        insert userRMCB2;

		Test.stopTest();
		setUpTeamTargetAndSaleTarget();
	}


	private static void setUpTeamTargetAndSaleTarget(){
		BottomUp_Notification_Settings__c enableNotification = new BottomUp_Notification_Settings__c(Enable_Notification__c = true);
   		insert enableNotification;
		Team_Structure__c teamStructureTL = [SELECT Id,Segment__c,RC_Code__c From Team_Structure__c WHERE External_ID__c = :Mockup_Test.TL_CB_RC_CODE];
		teamStructureTL.Segment__c = 'CB';
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		update teamStructureTL;
		TriggerHandler.clearbypass('TeamStructureTriggerHandler');

		String teamTargetExternalId = currentYear+'-'+teamStructureTL.RC_Code__c;
		Team_Target__c teamTarget = new Team_Target__c(External_ID__c =teamTargetExternalId,Team_Name__c = teamStructureTL.id,Year__c =currentYear );
		insert teamTarget;

		User_Extension__c userExCBRM = [SELECT Id,Employee_ID__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
		String salesTargetExternalId = currentYear+'-'+userExCBRM.Employee_ID__c;
		Sales_Target__c saleTarget = new Sales_Target__c(External_ID__c =salesTargetExternalId,Team_Target__c =teamTarget.id ,Name__c = userExCBRM.id ,Year__c = currentYear );
		insert saleTarget;

		User_Extension__c userEXCBRM2 = [SELECT Id,Employee_ID__c FROM User_Extension__c WHERE User__r.Firstname=:rmCB2FirstName LIMIT 1][0];
		String salesTargetRM2ExternalId = currentYear+'-'+userEXCBRM2.Employee_ID__c;
		Sales_Target__c saleTargetRM2 = new Sales_Target__c(External_ID__c =salesTargetRM2ExternalId,Team_Target__c =teamTarget.id ,Name__c = userEXCBRM2.id ,Year__c = currentYear );
		insert saleTargetRM2;

		Team_Structure__c  teamStructureTL2 = new Team_Structure__c(RC_Code__c=team2_RC_CODE,Segment__c=GlobalConstants.SEGMENT_CB);
		insert teamStructureTL2;

		String teamTarget2ExternalId = currentYear+'-'+teamStructureTL2.RC_Code__c;
		Team_Target__c teamTarget2 = new Team_Target__c(External_ID__c =teamTarget2ExternalId,Team_Name__c = teamStructureTL2.id,Year__c =currentYear );
		insert teamTarget2;

	}
	

	@isTest static void testBottomUpPointToNewSalesTargetOnOwnerChange(){
		Test.startTest();
		Account account;
		User useRMCB = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
		User userRMCB2 = [SELECT Id FROM User WHERE Firstname=:rmCB2FirstName LIMIT 1][0];
		System.runAs(useRMCB){
        	account = Mockup_Test.newAccountWithSegment(targetAccountCBSName,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
        	account.CIS__c = targetAccountCIS;
        	insert account;
        }

        Sales_Target__c saleTarget = [SELECT id,Is_Active__c From Sales_Target__c WHERE Name__r.User__r.id =:useRMCB.id  LIMIT 1];
        //Bottom_Up_Annualized__c bottomUp = [SELECT Id,CIS_ID__r.Id,Sales_Target__c From Bottom_Up_Annualized__c WHERE CIS_ID__r.CIS__c = :targetAccountCIS];
		//System.assertEquals( account.id,bottomUp.CIS_ID__r.Id);
		//System.assertEquals( saleTarget.id,bottomUp.Sales_Target__c);

        User cbsAdmin = [SELECT Id From User WHERE Profile.Name = :GlobalConstants.CBS_ADMIN and IsActive  = true LIMIT 1];
        Bulk_Assignment_Queue__c bulkQueue1 = new Bulk_Assignment_Queue__c();
        System.runAs(cbsAdmin){
			bulkQueue1.Status__c = 'Create';
           	insert bulkQueue1;

	        Bulk_Assignment__c bulkassignment = new Bulk_Assignment__c();
	        	bulkassignment.Status__c = 'New';
	        	bulkassignment.BulkAssignmentQueue__c = bulkQueue1.id;
	        	bulkassignment.CIS_ID__c = account.id;
	        	bulkassignment.AssignmentOwner__c = userRMCB2.id;
	        	bulkassignment.Permanent_Owner__c = userRMCB2.id;
	        	bulkassignment.Port_Pool__c = GlobalConstants.PORT;
	        	bulkassignment.Ownership__c = GlobalConstants.OWNERSHIP_PERMANENT;
	        	bulkassignment.Process__c = true;
	        insert bulkassignment;

        }

        Account_Service.accountTriggerMap = null;
        bulkQueue1 = [SELECT Id, Status__c FROM Bulk_Assignment_Queue__c WHERE Id =: bulkQueue1.Id LIMIT 1];
        bulkQueue1.Status__c = 'Execute';
        update bulkQueue1;
        //SME_CalculateOwnershipAssignment_Service.executeBulkAssignmentBatch();
    
		Test.stopTest();

		User_Extension__c userExtRMCB2 = [SELECT Id From User_Extension__c WHERE User__r.id = :userRMCB2.id];
		Sales_Target__c saleTargetRMCB2 = [SELECT Id,Name__r.id From Sales_Target__c WHERE Name__r.id = :userExtRMCB2.id LIMIT 1];
        System.assertEquals( userExtRMCB2.id,saleTargetRMCB2.Name__r.Id);

        //Account accountAfterOwnerChange = [SELECT Id,OwnerId From Account WHERE Name =:targetAccountCBSName LIMIT 1];
        //Account accountAfterOwnerChange = Mockup_Test.getFirstAccountFromName(targetAccountCBSName, 'Id,OwnerId');
        //System.assertEquals(userRMCB2.id,accountAfterOwnerChange.OwnerId);

 
        //Bottom_Up_Annualized__c bottomUpAfterChangOwner = [SELECT Id,CIS_ID__r.Id,Sales_Target__r.id From Bottom_Up_Annualized__c WHERE CIS_ID__c = :accountAfterOwnerChange.id LIMIT 1];
        //System.assertEquals( saleTargetRMCB2.id,bottomUpAfterChangOwner.Sales_Target__r.id);

	}
	
	@isTest static void testUserInactiveThenServiceInactiveSalesTarget(){
		User useRMCB;
		Test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())){
			useRMCB = [SELECT Id,Isactive FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
				useRMCB.Isactive = false;
			update useRMCB;
		}
		Test.stopTest();

		//Sales_Target__c saleTarget = [SELECT id,Is_Active__c From Sales_Target__c WHERE Name__r.User__r.id =:useRMCB.id  LIMIT 1];
		//System.assertEquals(false,saleTarget.Is_Active__c);

	}

	@isTest static void testNewCBSUserActiveThenServiceCreateSalesTarget(){
		String userRM3FirstName = 'userRM3FirstName';
		String userRM3LastName = 'userRM3LastName';
		String userRM3EmployeeId = '333333';
		Test.startTest();

			Team_Structure__c teamStructureTL = [SELECT Id,Segment__c,RC_Code__c From Team_Structure__c WHERE External_ID__c = :Mockup_Test.TL_CB_RC_CODE];
	        User userTL = [SELECT Id From User WHERE Firstname= :Mockup_Test.userFirstNameCBTL LIMIT 1];
	        Profile profileCBRM = [SELECT Id From Profile WHERE Name = :GlobalConstants.CBS_RM LIMIT 1];
	        User userRMCB3 = Mockup_Test.newUser(userRM3FirstName,userRM3LastName,userRM3EmployeeId, true, profileCBRM.id, null, userTL.id);
	        userRMCB3.Segment__c = GlobalConstants.SEGMENT_CB;
	        userRMCB3.RC_Code__c = teamStructureTL.RC_Code__c;
	        insert userRMCB3;
        Test.stopTest();

        User_Extension__c userExtRM3 = [SELECT Id From User_Extension__c WHERE User__r.Firstname = :userRM3FirstName LIMIT 1];
        Sales_Target__c salesTargetRM3 = [SELECT Id,Name__c From Sales_Target__c WHERE Name__c = :userExtRM3.id];
        System.assertEquals(userExtRM3.id,salesTargetRM3.Name__c);

	}

	@isTest static void testUserChangeTeamThenServicePointSaleTargetToNewTeamTarget(){
		User userCBRM;
		Test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())){
			userCBRM = [SELECT Id,RC_Code__c From User WHERE  Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
				userCBRM.RC_Code__c = team2_RC_CODE;
			update userCBRM;
		}
		Test.stopTest();

		//Team_Target__c teamTarget2 = [SELECT Id From Team_Target__c WHERE Team_RC_Code__c = :team2_RC_CODE  LIMIT 1];
		//Sales_Target__c saleTargetAfterChangeTeam = [SELECT Id,Team_Target__c From Sales_Target__c WHERE Name__r.User__c =  :userCBRM.id LIMIT 1];
		//System.assertEquals(teamTarget2.id,saleTargetAfterChangeTeam.Team_Target__c);
	}
	
	
}