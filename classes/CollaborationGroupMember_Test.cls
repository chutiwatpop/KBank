@isTest
private class CollaborationGroupMember_Test {
	private static String newFirstName = 'newFirstName';
    private static String newLastName = 'newLastName';
    private static String newUserEmpId = '9900000001';
    private static String salesFirstName = 'salesFirstName';
    private static String salesLastName = 'salesLastName';
    private static String salesUserEmpId = '9900000002';
	private static String NEW_RC_CODE = '2115';

	@testSetup static void setupUser(){
		TriggerHandler.bypass('UserTriggerHandler');
        TestUtils.enable_isRunningTest = true;
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
    }

	@isTest static void testAddCollaborationGroupMemberAndGroupWasNotCreatedBySystemThenInsertMemberNotificationFrequencyEqualNever() {
        UserRole rmRole = [SELECT Id FROM UserRole WHERE DeveloperName= :('RCRM' + Mockup_Test.RC_CODE)];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName= 'SME_Support'];
        User tmUser = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM];
        Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
        Id salesManagementProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'SME-Sales Management' LIMIT 1].Id;
        User newUser;
        User salesUser;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            newUser = Mockup_Test.newUser(newFirstName,
                newLastName,
                true,
                newFirstName+'@mail.com',
                newFirstName+'@mail.com',
                newFirstName.subString(0,4),
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                newUserEmpId
            );
            insert newUser;

            salesUser = Mockup_Test.newUser(
                    salesFirstName,
                    salesLastName,
                    true,
                    salesFirstName+'@mail.com',
                    salesFirstName+'@mail.com',
                    salesFirstName.substring(0, 4),
                    salesManagementProfileId,
                    adminRole.Id,
                    null,
                    salesUserEmpId
            );
            salesUser.RC_Code__c = NEW_RC_CODE;
            salesUser.NH_RC_Code__c = NEW_RC_CODE;
            salesUser.Job_Code__c = 'ME1A';
            salesUser.Status__c = 'A';
            salesUser.Segment__c = Mockup_Test.teamSegment1;
            insert salesUser;
        }

        //User ownerGroup = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
        CollaborationGroup newGroup = new CollaborationGroup();
        newGroup.Name = 'test group';
        newGroup.OwnerId = salesUser.Id;
        newGroup.CollaborationType = 'Private';
        insert newGroup;
        
        CollaborationGroupMember newMember = new CollaborationGroupMember();
        newMember.MemberId = newUser.Id;
        newMember.CollaborationGroupId = newGroup.Id;
        newMember.CollaborationRole = 'Standard';

        Test.startTest();
        	insert newMember;
        Test.stopTest();

        CollaborationGroupMember memberAfterInsert = [SELECT Id,NotificationFrequency FROM CollaborationGroupMember WHERE Id = :newMember.Id];
        System.assertEquals('N',memberAfterInsert.NotificationFrequency);
	}
	
	@isTest static void testAddCollaborationGroupMemberAndGroupWasCreatedBySystemAndGroupNameWasConvertedByConFigThenInsertMemberNotificationFrequencyEqualConfig() {
        UserRole rmRole = [SELECT Id FROM UserRole WHERE DeveloperName= :('RCRM' + Mockup_Test.RC_CODE)];
        User tmUser = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM];
        Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
        User newUser;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            newUser = Mockup_Test.newUser(newFirstName,
                newLastName,
                true,
                newFirstName+'@mail.com',
                newFirstName+'@mail.com',
                newFirstName.subString(0,4),
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                newUserEmpId
            );
            insert newUser;
        }

        String convertedGroupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, GlobalConstants.SEGMENT_SE);
        //CollaborationGroup testGroup = [SELECT Id FROM CollaborationGroup WHERE Name = :convertedGroupName LIMIT 1];

        //CollaborationGroupMember newMember = new CollaborationGroupMember();
        //newMember.MemberId = newUser.Id;
        //newMember.CollaborationGroupId = testGroup.Id;
        //newMember.CollaborationRole = 'Standard';

        //Test.startTest();
        //	insert newMember;
        //Test.stopTest();

        //CollaborationGroupMember memberAfterInsert = [SELECT Id,NotificationFrequency FROM CollaborationGroupMember WHERE Id = :newMember.Id];
        //System.assertEquals('D',memberAfterInsert.NotificationFrequency);
	}
	
	@isTest static void testAddCollaborationGroupMemberAndGroupWasCreatedBySystemAndGroupNameWasNotConvertedByConFigThenInsertMemberNotificationFrequencyEqualNever() {

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NEW_RC_CODE,
            RC_Code__c = NEW_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = 'test group not match config',
            Segment__c = Mockup_Test.teamSegment1,
            Type__c = 'Network'
        );
        insert tsNh;

		UserRole nhRole = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        User newNhUser;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Test.startTest();
            newNhUser = Mockup_Test.newUser(
                    newFirstName,
                    newLastName,
                    true,
                    newFirstName+'@mail.com',
                    newFirstName+'@mail.com',
                    newFirstName.substring(0, 4),
                    nhProfile.Id,
                    nhRole.Id,
                    null,
                    newUserEmpId
            );
            newNhUser.RC_Code__c = NEW_RC_CODE;
            newNhUser.NH_RC_Code__c = NEW_RC_CODE;
            newNhUser.Job_Code__c = 'ME1A';
            newNhUser.Status__c = 'A';
            newNhUser.Segment__c = Mockup_Test.teamSegment1;
            insert newNhUser;
        }
		//CollaborationGroup newGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'test group not match config'];
        Test.stopTest();
		
        //CollaborationGroupMember memberAfterInsert = [SELECT Id,NotificationFrequency FROM CollaborationGroupMember WHERE MemberId = :newNhUser.Id AND CollaborationGroupId = :newGroup.Id LIMIT 1];
        //System.assertEquals('D',memberAfterInsert.NotificationFrequency);
	}
}