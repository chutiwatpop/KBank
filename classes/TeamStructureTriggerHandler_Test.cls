@isTest
private class TeamStructureTriggerHandler_Test {
	@testSetup static void setupUser(){
        TestUtils.enable_isRunningTest = true;
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
    }

	@isTest static void testCreateTeamStructureNhAhTmRmThenCreate1AhGroup1AllAhGroup() {

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
	        Test.startTest();
	            List<CollaborationGroup> allGroup = [SELECT Id FROM CollaborationGroup];
	            String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
	            //CollaborationGroup nhGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :groupName];
	        Test.stopTest();

	        //System.assertEquals(1, allGroup.size());
	        //System.assertEquals(groupName, nhGroup.Name);
	        //System.assertEquals(1, nhGroup.MemberCount);
        }
	}
	
	@isTest static void testNetworkUpdateTeamNameThenUpdateGroupName() {
		Team_Structure__c nhTeam;
		Team_Structure__c nhTeamAfterChangeName;
		CollaborationGroup nhGroup;
		CollaborationGroup nhGroupAfterChangeName;
		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		System.runAs(userAdmin){
			String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
            //nhGroup = [SELECT Id,Name FROM CollaborationGroup WHERE Name = :groupName];
            //System.assertEquals(groupName, nhGroup.Name);
            //nhTeam = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
        }
        
     //   Test.startTest();
	    //	nhTeam.Name = 'เครือข่ายลูกค้าผู้ประกอบการ 2 (after change name)';
	    //    update nhTeam;
	    //Test.stopTest();

     //   nhTeamAfterChangeName = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
    	//System.assertEquals('เครือข่ายลูกค้าผู้ประกอบการ 2 (after change name)', nhTeamAfterChangeName.Name);

    	//nhGroupAfterChangeName = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = 'SE after change name'];
    	//System.assertEquals('SE after change name', nhGroupAfterChangeName.Name);
    	//System.assertEquals(1, nhGroupAfterChangeName.MemberCount);
	}
	
	//@isTest static void testChangeTypeToNetworkThenCreateNewGroup() {
	//	String AH_RC_CODE = '1234';
	//	Team_Structure__c ahTeam;
	//	Team_Structure__c nhTeam;
	//	CollaborationGroup nhNewGroup;
	//	List<CollaborationGroup> allGroup;
	//	System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
 //       	nhTeam = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
 //           ahTeam = new Team_Structure__c(
 //               External_ID__c = AH_RC_CODE,
 //               RC_Code__c = AH_RC_CODE,
 //               AH_RC_Code__c = null,
 //               NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
 //               AH_Name__c = null,
 //               NH_Name__c = nhTeam.Id,
 //               Name = 'เครือข่ายลูกค้าผู้ประกอบการ 1 testToNH',
 //               Segment__c = Mockup_Test.teamSegment2,
 //               Type__c = 'Area'
 //           );
 //           insert ahTeam;
 //       }

 //       Test.startTest();
	//        ahTeam.Type__c = 'Network';
	//        update ahTeam;
	//    Test.stopTest();

        //allGroup = [SELECT Id FROM CollaborationGroup];
        //System.assertEquals(2,allGroup.size());

        //nhNewGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = 'ME testToNH'];
        //System.assertEquals('ME testToNH',nhNewGroup.Name);
        //System.assertEquals(1, nhNewGroup.MemberCount);
	//}

	@isTest static void testDeleteTeamThenDeleteGroup() {
		Test.startTest();
        	Team_Structure__c nhTeam = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
            delete nhTeam;
        Test.stopTest();

        List<CollaborationGroup> allGroup = [SELECT Id FROM CollaborationGroup];
        System.assertEquals(0,allGroup.size());
	}

	@isTest static void testInsertGroupNameWrongFormatAndLengthLessThan41ThenCreateGroupNameSameAsTeamName() {
		String WRONG_NAME_NH_RC_CODE = '12345';
		String WRONG_NAME_FORMAT = 'WRONG_NAME_FORMAT';
		Test.startTest();
        	Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = WRONG_NAME_NH_RC_CODE,
                RC_Code__c = WRONG_NAME_NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = WRONG_NAME_FORMAT,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );
            insert tsNh;
        Test.stopTest();

        //List<CollaborationGroup> allGroup = [SELECT Id FROM CollaborationGroup];
        //CollaborationGroup worngNameGroup = [SELECT Id,Name FROM CollaborationGroup WHERE Name = :WRONG_NAME_FORMAT];
        //System.assertEquals(2,allGroup.size());
        //System.assertEquals(WRONG_NAME_FORMAT,worngNameGroup.Name);
	}

	@isTest static void testInsertGroupNameWrongFormatAndLengthMoreThan40ThenError() {
		String WRONG_NAME_NH_RC_CODE = '12345';
		String NAME_TO_LONG = '123456789_123456789_123456789_123456789_1';
		Test.startTest();
        	Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = WRONG_NAME_NH_RC_CODE,
                RC_Code__c = WRONG_NAME_NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = NAME_TO_LONG,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );

            try{
            	insert tsNh;
            	//System.assertEquals('Error' ,'But Not Error');
            }catch(Exception e){
            	//Boolean errorMsg = e.getMessage().contains(System.Label.TeamStructure_Name_Error);
            	//System.assertEquals(true ,errorMsg);
            }
        Test.stopTest();
	}

	@isTest static void testInsertGroupNameRightFormatAndLengthMoreThan40ThenError() {
		String WRONG_NAME_NH_RC_CODE = '12345';
		String NAME_TO_LONG = 'เครือข่ายลูกค้าผู้ประกอบการ 1 1234567890_1234567890_1234567890_1234567890';
		Test.startTest();
        	Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = WRONG_NAME_NH_RC_CODE,
                RC_Code__c = WRONG_NAME_NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = NAME_TO_LONG,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );

            try{
            	insert tsNh;
            	//System.assertEquals('Error' ,'But Not Error');
            }catch(Exception e){
            	//Boolean errorMsg = e.getMessage().contains(System.Label.TeamStructure_Name_Error);
            	//System.assertEquals(true ,errorMsg);
            }
        Test.stopTest();
	}

	@isTest static void testInsertDuplicateGroupNameThenError() {
		String WRONG_NAME_NH_RC_CODE = '12345';
		String NAME_TO_LONG = Mockup_Test.nhTeamName;
		Test.startTest();
        	Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = WRONG_NAME_NH_RC_CODE,
                RC_Code__c = WRONG_NAME_NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = NAME_TO_LONG,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );

            //try{
            //	insert tsNh;
            //	System.assertEquals('Error' ,'But Not Error');
            //}catch(Exception e){
            //	Boolean errorMsg = e.getMessage().contains(System.Label.TeamStructure_Dup_Name_Error);
            //	System.assertEquals(true ,errorMsg);
            //}
        Test.stopTest();
	}
}