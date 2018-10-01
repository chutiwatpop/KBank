@isTest
private class SME_BatchInitialGroupChatter_Batch_Test {
	
	@testSetup static void setupUser(){
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
    }

	@isTest static void testCreate1Nh1Ah1Tm1RmTeamAnd4UsersThenInitial1NhGroupAnd1AllSeNhGroup() {
		Test.startTest();
			Database.executeBatch(new SME_BatchInitialGroupChatter_Batch());
		Test.stopTest();
		String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
		CollaborationGroup nhGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :groupName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(2,allGroup.size());
		System.assertEquals(5,nhGroup.MemberCount);
		System.assertEquals(5,allNhSeGroup.MemberCount);
	}
	
	@isTest static void testCreate2Nh1Ah1Tm1RmTeamAnd5UsersThenInitial2NhGroupAnd2AllNhGroup() {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
		String NH_RC_CODE = '1234';
		String userFirstNameNH = '2nhUser';
		String userLastNameNH = 'nh team';
		String userEmpIdNH = '99999999991';
		String secondNhTeamName = 'เครือข่ายลูกค้าผู้ประกอบการ 2 2nhTeam';
		Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
		UserRole nhRole = [SELECT Id FROM UserRole WHERE Name = :Mockup_Test.NH_RC_CODE LIMIT 1];

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NH_RC_CODE,
            RC_Code__c = NH_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = secondNhTeamName,
            Segment__c = Mockup_Test.teamSegment2,
            Type__c = 'Network'
        );
        insert tsNh;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User nhUser = Mockup_Test.newUser(
	                userFirstNameNH,
	                userLastNameNH,
	                true,
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH.substring(0, 4),
	                nhProfile.Id,
	                nhRole.Id,
	                null,
	                userEmpIdNH
	        );
	        nhUser.RC_Code__c = NH_RC_CODE;
	        nhUser.NH_RC_Code__c = NH_RC_CODE;
	        nhUser.Job_Code__c = 'ME1A';
	        nhUser.Status__c = 'A';
	        nhUser.Segment__c = Mockup_Test.teamSegment2;
	        insert nhUser;
	    }

        Test.startTest();
			Database.executeBatch(new SME_BatchInitialGroupChatter_Batch());
		Test.stopTest();

		String nhFirstGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
		String nhSecondGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(secondNhTeamName, Mockup_Test.teamSegment2);
		CollaborationGroup nhFirstGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhFirstGroupName];
		CollaborationGroup nhSecondGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhSecondGroupName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
	    CollaborationGroup allNhMeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment2];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(4,allGroup.size());
		System.assertEquals(5,nhFirstGroup.MemberCount);
		System.assertEquals(2,nhSecondGroup.MemberCount);
		System.assertEquals(5,allNhSeGroup.MemberCount);
		System.assertEquals(2,allNhMeGroup.MemberCount);
	}

	@isTest static void testCreate2Nh1Ah1Tm1RmTeamAnd4UsersBut1TeamNameToLongThenInitial1NhGroupAnd1AllNhSeGroup() {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
		String NH_RC_CODE = '1234';
		String userFirstNameNH = '2nhUser';
		String userLastNameNH = 'nh team';
		String userEmpIdNH = '99999999991';
		String secondNhTeamName = 'เครือข่ายลูกค้าผู้ประกอบการ 2 2nhTeam 1234567890_1234567890_1234567890_';
		Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
		UserRole nhRole = [SELECT Id FROM UserRole WHERE Name = :Mockup_Test.NH_RC_CODE LIMIT 1];

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NH_RC_CODE,
            RC_Code__c = NH_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = secondNhTeamName,
            Segment__c = Mockup_Test.teamSegment2,
            Type__c = 'Network'
        );
        insert tsNh;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User nhUser = Mockup_Test.newUser(
	                userFirstNameNH,
	                userLastNameNH,
	                true,
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH.substring(0, 4),
	                nhProfile.Id,
	                nhRole.Id,
	                null,
	                userEmpIdNH
	        );
	        nhUser.RC_Code__c = NH_RC_CODE;
	        nhUser.NH_RC_Code__c = NH_RC_CODE;
	        nhUser.Job_Code__c = 'ME1A';
	        nhUser.Status__c = 'A';
	        nhUser.Segment__c = Mockup_Test.teamSegment2;
	        insert nhUser;
	    }

        Test.startTest();
			Database.executeBatch(new SME_BatchInitialGroupChatter_Batch());
		Test.stopTest();

		String nhFirstGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
		CollaborationGroup nhFirstGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhFirstGroupName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		//System.assertEquals(2,allGroup.size());
		//System.assertEquals(5,nhFirstGroup.MemberCount);
		//System.assertEquals(5,allNhSeGroup.MemberCount);
	}

	@isTest static void testCreate2Nh1Ah1Tm1RmTeamAnd4UsersButDupTeamNameThenInitial1NhGroupBut2TeamSturctureMembersAreInThisGroupAnd1AllNhGroup() {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
		String NH_RC_CODE = '1234';
		String userFirstNameNH = '2nhUser';
		String userLastNameNH = 'nh team';
		String userEmpIdNH = '99999999991';
		String secondNhTeamName = Mockup_Test.nhTeamName;
		Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
		UserRole nhRole = [SELECT Id FROM UserRole WHERE Name = :Mockup_Test.NH_RC_CODE LIMIT 1];

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NH_RC_CODE,
            RC_Code__c = NH_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = secondNhTeamName,
            Segment__c = Mockup_Test.teamSegment2,
            Type__c = 'Network'
        );
        insert tsNh;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User nhUser = Mockup_Test.newUser(
	                userFirstNameNH,
	                userLastNameNH,
	                true,
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH.substring(0, 4),
	                nhProfile.Id,
	                nhRole.Id,
	                null,
	                userEmpIdNH
	        );
	        nhUser.RC_Code__c = NH_RC_CODE;
	        nhUser.NH_RC_Code__c = NH_RC_CODE;
	        nhUser.Job_Code__c = 'ME1A';
	        nhUser.Status__c = 'A';
	        nhUser.Segment__c = Mockup_Test.teamSegment2;
	        insert nhUser;
	    }

        Test.startTest();
			Database.executeBatch(new SME_BatchInitialGroupChatter_Batch());
		Test.stopTest();

		String nhFirstGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
		String nhSecondGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(secondNhTeamName, Mockup_Test.teamSegment2);
		CollaborationGroup nhFirstGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhFirstGroupName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
	    CollaborationGroup allNhMeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment2];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(3,allGroup.size());
		System.assertEquals(6,nhFirstGroup.MemberCount);
		System.assertEquals(5,allNhSeGroup.MemberCount);
		System.assertEquals(2,allNhMeGroup.MemberCount);
	}

	@isTest static void testInitial2NhGroup2AllNhGroupThenMoveToWrongGroupAndReInitialAgainSystemWillMoveUserToTheRightGroupWithoutRemoveFromOldGroup() {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
		String NH_RC_CODE = '1234';
		String userFirstNameNH = '2nhUser';
		String userLastNameNH = 'nh team';
		String userEmpIdNH = '99999999991';
		String secondNhTeamName = '2nh team name';
		Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
		UserRole nhRole = [SELECT Id FROM UserRole WHERE Name = :Mockup_Test.NH_RC_CODE LIMIT 1];

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NH_RC_CODE,
            RC_Code__c = NH_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = secondNhTeamName,
            Segment__c = Mockup_Test.teamSegment2,
            Type__c = 'Network'
        );
        insert tsNh;


        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User nhUser = Mockup_Test.newUser(
	                userFirstNameNH,
	                userLastNameNH,
	                true,
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH+'@mail.com',
	                userFirstNameNH.substring(0, 4),
	                nhProfile.Id,
	                nhRole.Id,
	                null,
	                userEmpIdNH
	        );
	        nhUser.RC_Code__c = NH_RC_CODE;
	        nhUser.NH_RC_Code__c = NH_RC_CODE;
	        nhUser.Job_Code__c = 'ME1A';
	        nhUser.Status__c = 'A';
	        nhUser.Segment__c = Mockup_Test.teamSegment2;
	        insert nhUser;
	    }

		String nhFirstGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, Mockup_Test.teamSegment1);
		String nhSecondGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(secondNhTeamName, Mockup_Test.teamSegment2);

		User ownerGroup = [SELECT Id FROM User WHERE Name = :System.Label.Chatter_Group_Owner LIMIT 1];
        CollaborationGroup newNhFirstGroup = new CollaborationGroup(Name = nhFirstGroupName,CollaborationType = 'Private', OwnerId = ownerGroup.Id);
        CollaborationGroup newNhSecondGroup = new CollaborationGroup(Name = nhSecondGroupName,CollaborationType = 'Private', OwnerId = ownerGroup.Id);
        CollaborationGroup newAllNhMeGroup = new CollaborationGroup(Name = Mockup_Test.teamSegment2,CollaborationType = 'Private', OwnerId = ownerGroup.Id);
        CollaborationGroup newAllNhSeGroup = new CollaborationGroup(Name = Mockup_Test.teamSegment1,CollaborationType = 'Private', OwnerId = ownerGroup.Id);
        List<CollaborationGroup> listNewGroup = new List<CollaborationGroup>();
		listNewGroup.add(newNhFirstGroup);
		listNewGroup.add(newNhSecondGroup);
		listNewGroup.add(newAllNhMeGroup);
		listNewGroup.add(newAllNhSeGroup);
		insert listNewGroup;

		List<String> listUserFirstName = new List<String>();
		listUserFirstName.add(Mockup_Test.userFirstNameRM);
		listUserFirstName.add(Mockup_Test.userFirstNameTM);
		listUserFirstName.add(Mockup_Test.userFirstNameAH);
		listUserFirstName.add(Mockup_Test.userFirstNameNH);
		listUserFirstName.add(userFirstNameNH);
		
		List<User> listUser = [SELECT Id,FirstName FROM User WHERE FirstName IN :listUserFirstName];
		Map<String, User> mapUserMapByFirstName = new Map<String, User>();
		for(User eachUser : listUser){
			mapUserMapByFirstName.put(eachUser.FirstName, eachUser);
		}

		List<CollaborationGroupMember> listNewCollaborationGroupMember = new List<CollaborationGroupMember>();
		//member first group
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newNhFirstGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(Mockup_Test.userFirstNameTM).Id));
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newNhFirstGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(Mockup_Test.userFirstNameAH).Id));
		//member second group
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newNhSecondGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(Mockup_Test.userFirstNameRM).Id));
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newNhSecondGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(Mockup_Test.userFirstNameNH).Id));
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newNhSecondGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(userFirstNameNH).Id));
		//member SE group
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newAllNhSeGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(Mockup_Test.userFirstNameNH).Id));
		listNewCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = newAllNhSeGroup.Id,CollaborationRole = 'Standard',MemberId = mapUserMapByFirstName.get(userFirstNameNH).Id));

		insert listNewCollaborationGroupMember;

		CollaborationGroup nhFirstGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhFirstGroupName];
		CollaborationGroup nhSecondGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :secondNhTeamName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
	    CollaborationGroup allNhMeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment2];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(3,nhFirstGroup.MemberCount);
		System.assertEquals(4,nhSecondGroup.MemberCount);
		System.assertEquals(3,allNhSeGroup.MemberCount);
		System.assertEquals(1,allNhMeGroup.MemberCount);
		System.assertEquals(4,allGroup.size());

		Test.startTest();
			Database.executeBatch(new SME_BatchInitialGroupChatter_Batch());
		Test.stopTest();

		CollaborationGroup nhFirstGroupAfterReInitial = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :nhFirstGroupName];
		CollaborationGroup nhSecondGroupAfterReInitial = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :secondNhTeamName];
	    CollaborationGroup allNhSeGroupAfterReInitial = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
	    CollaborationGroup allNhMeGroupAfterReInitial = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment2];
		List<CollaborationGroup> allGroupAfterReInitial = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(4,allGroupAfterReInitial.size());
		System.assertEquals(5,nhFirstGroupAfterReInitial.MemberCount);
		System.assertEquals(4,nhSecondGroupAfterReInitial.MemberCount);
		System.assertEquals(6,allNhSeGroupAfterReInitial.MemberCount);
		System.assertEquals(2,allNhMeGroupAfterReInitial.MemberCount);
	}
	
}