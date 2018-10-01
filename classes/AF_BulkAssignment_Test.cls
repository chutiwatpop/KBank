@isTest
private class AF_BulkAssignment_Test
{
	@testSetup 
	static void setup(){
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_AF);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_AF_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_AF_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_AF_TM).Id;
		insert userTM;


		List<User> userRMList = new List<User>();
		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_AF_RM_1).Id;
		userRMList.add(userRM);

		User userRM2 = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM2, Mockup_Test.userFirstNameRM2, Mockup_Test.userLastNameRM2, true, userTM.Id);
		userRM2.RC_Code__c = Mockup_Test.RC_CODE;
		userRM2.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_AF_RM_1).Id;
		userRMList.add(userRM2);
		insert userRMList;
	}

	@isTest static void tmTestPickList(){
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Profile.Name =:GlobalConstants.AF_TM and IsActive = true LIMIT 1][0]){
			
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			ModelExtensions.QueryPickListObj qobj = new ModelExtensions.QueryPickListObj();
			ModelExtensions.PicklistByFilterKeyResponse objResponse = new ModelExtensions.PicklistByFilterKeyResponse();

			qobj.extra = 'All';
			qobj.subScope = 'TMLevel';
			objResponse = SME_BulkAssignment_ListView_Controller.querySelectedBy(qobj);
			System.assertEquals(true,objResponse.success);
			System.assertNotEquals(0,objResponse.records.size());
		}

		Test.stopTest();
	}

	@isTest static void ahTestPickList(){
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Profile.Name =:GlobalConstants.AF_AH and IsActive = true LIMIT 1][0]){
			
			SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();

			ModelExtensions.QueryPickListObj qobj = new ModelExtensions.QueryPickListObj();
			ModelExtensions.PicklistByFilterKeyResponse objResponse = new ModelExtensions.PicklistByFilterKeyResponse();

			qobj.blankInclude = true;
			objResponse = SME_BulkAssignment_ListView_Controller.queryRMNameByTeam(qobj);
			System.assertEquals(true,objResponse.success);
			System.assertNotEquals(0,objResponse.records.size());
		}	
	}


	//@isTest static void searchCISFound(){

	//}

	//@isTest static void searchCISNotFound(){
		
	//}

	//System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){}
}