@isTest
private class SME_GroupChatterService_Test {
	@testSetup static void setupUser(){
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;
		//Mockup_Test.RUN_TEST_GROUP_CHATTER = true;
        Mockup_Test.setUpCustomSetting();
        
        System.runAs(new User(Id=UserInfo.getUserId())){

            List<Profile> listProfile = new List<Profile>();
            listProfile = [SELECT Id, Name FROM Profile];

            Map<String,Profile> mapProfileByName = new Map<String,Profile>();
            for(Profile eachProfile : listProfile){
                mapProfileByName.put(eachProfile.Name, eachProfile);
            }

            List<Job_Code__c> listJobCode = new List<Job_Code__c>();
            Profile nhProfile = mapProfileByName.get(GlobalConstants.SME_NH);
            listJobCode.add(new Job_Code__c(Name = 'ME1A', Profile_Name__c = nhProfile.Name));
            
            Profile ahProfile = mapProfileByName.get(GlobalConstants.SME_AH);
            listJobCode.add(new Job_Code__c(Name = 'ME2A', Profile_Name__c = ahProfile.Name));
        
            Profile tmProfile = mapProfileByName.get(GlobalConstants.SME_TM);
            listJobCode.add(new Job_Code__c(Name = 'ME3A', Profile_Name__c = tmProfile.Name));
          
            Profile rmProfile = mapProfileByName.get(GlobalConstants.SME_RM);
            listJobCode.add(new Job_Code__c(Name = 'ME4A', Profile_Name__c = rmProfile.Name));
            insert listJobCode;

            UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
            UserRole nhRole = Mockup_Test.newRole(Mockup_Test.NH_RC_CODE, 'RC' + Mockup_Test.NH_RC_CODE, adminRole.Id);
            insert nhRole;
            UserRole ahRole = Mockup_Test.newRole(Mockup_Test.AH_RC_CODE, 'RC' + Mockup_Test.AH_RC_CODE, nhRole.Id);
            insert ahRole;
            UserRole tmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RC' + Mockup_Test.RC_CODE, ahRole.Id);
            insert tmRole;
            UserRole rmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RCRM' + Mockup_Test.RC_CODE, tmRole.Id);
            insert rmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = Mockup_Test.NH_RC_CODE,
                RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                External_ID__c = Mockup_Test.AH_RC_CODE,
                RC_Code__c = Mockup_Test.AH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_Name__c = null,
                NH_Name__c = tsNh.Id,
                Name = Mockup_Test.ahTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Area'
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                External_ID__c = Mockup_Test.RC_CODE,
                RC_Code__c = Mockup_Test.RC_CODE,
                AH_RC_Code__c = Mockup_Test.AH_RC_CODE,
                NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_Name__c = tsAh.Id,
                NH_Name__c = tsNh.Id,
                Name = Mockup_Test.tmTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Team'
            );
            insert tsTm;

            List<User> listInsertUser = new List<User>();
            User nhUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameNH,
                    Mockup_Test.userLastNameNH,
                    true,
                    Mockup_Test.userFirstNameNH+'@mail.com',
                    Mockup_Test.userFirstNameNH+'@mail.com',
                    Mockup_Test.userFirstNameNH.substring(0, 4),
                    nhProfile.Id,
                    nhRole.Id,
                    null,
                    Mockup_Test.userEmpIdNH
            );
            nhUser.RC_Code__c = Mockup_Test.NH_RC_CODE;
            nhUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            nhUser.Job_Code__c = 'ME1A';
            nhUser.Status__c = 'A';
            nhUser.Segment__c = Mockup_Test.teamSegment1;
            //insert nhUser;
            listInsertUser.add(nhUser);
            

            User ahUser = Mockup_Test.newUser(
	                Mockup_Test.userFirstNameAH,
	                Mockup_Test.userLastNameAH,
	                true,
	                Mockup_Test.userFirstNameAH+'@mail.com',
	                Mockup_Test.userFirstNameAH+'@mail.com',
	                Mockup_Test.userFirstNameAH.substring(0, 4),
	                ahProfile.Id,
	                ahRole.Id,
	                nhUser.Id,
	                Mockup_Test.userEmpIdAH
	        );
	        ahUser.RC_Code__c = Mockup_Test.AH_RC_CODE;
	        ahUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
	        ahUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
	        ahUser.Job_Code__c = 'ME2A';
	        ahUser.Status__c = 'A';
	        ahUser.Segment__c = Mockup_Test.teamSegment1;
	        //insert ahUser;
	        listInsertUser.add(ahUser);

	        User tmUser = Mockup_Test.newUser(
	                Mockup_Test.userFirstNameTM,
	                Mockup_Test.userLastNameTM,
	                true,
	                Mockup_Test.userFirstNameTM+'@mail.com',
	                Mockup_Test.userFirstNameTM+'@mail.com',
	                Mockup_Test.userFirstNameTM.substring(0, 4),
	                tmProfile.Id,
	                tmRole.Id,
	                ahUser.Id,
	                Mockup_Test.userEmpIdTM
	         );
	        tmUser.Job_Code__c = 'ME3A';
	        tmUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
	        tmUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
	        tmUser.RC_Code__c = Mockup_Test.RC_CODE;
	        tmUser.Status__c = 'A';
	        tmUser.Segment__c = Mockup_Test.teamSegment1;
	        //insert tmUser;
	        listInsertUser.add(tmUser);

	        User rmUser = Mockup_Test.newUser(
	                Mockup_Test.userFirstNameRM,
	                Mockup_Test.userLastNameRM,
	                true,
	                Mockup_Test.userFirstNameRM+'@mail.com',
	                Mockup_Test.userFirstNameRM+'@mail.com',
	                Mockup_Test.userFirstNameRM.substring(0, 4),
	                rmProfile.Id,
	                rmRole.Id,
	                tmUser.Id,
	                Mockup_Test.userEmpIdRM
	         );
	        rmUser.Job_Code__c = 'ME4A';
	        rmUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
	        rmUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
	        rmUser.RC_Code__c = Mockup_Test.RC_CODE;
	        rmUser.Status__c = 'A';
	        //insert rmUser;
	        listInsertUser.add(rmUser);
	        insert listInsertUser;

	        Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
	        areaBKK1.Group_Indicate__c = 'Bangkok';
	        areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
	        areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.1)';
	        insert areaBKK1;
        }
        Mockup_Test mt = new Mockup_Test();
        mt.setUpTestAdmin();
    }

	//@isTest static void testCreateUserThenCreateGroupChatter() {
	//	TestUtils.enable_isRunningTest = true;
 //       CollaborationGroup resultGroup;
 //       CollaborationGroup resultNhGroup;
 //       List<CollaborationGroup> allGroup;
 //       List<CollaborationGroupMember> resultGroupMember;
 //       List<CollaborationGroupMember> resultNhGroupMember;

 //       System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
 //           Test.startTest();
	//			//Mockup_Test.RUN_TEST_GROUP_CHATTER = true;
 //               Team_Structure__c teamStructure = [SELECT Name,Segment__c FROM Team_Structure__c WHERE External_ID__c = :Mockup_Test.NH_RC_CODE];
 //               String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);
 //               resultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupName];
 //               resultGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultGroup.Id AND CollaborationRole = 'Standard'];
                
 //               resultNhGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1];
 //               resultNhGroupMember = [SELECT Id,Member.Name FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultNhGroup.Id AND CollaborationRole = 'Standard'];

 //               allGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
 //           Test.stopTest();
 //       }

 //       System.assertEquals(2, allGroup.size());
 //       System.assertEquals(5, resultGroup.MemberCount);
 //       System.assertEquals(4, resultGroupMember.size());
 //       System.assertEquals('Private', resultGroup.CollaborationType);

 //       System.assertEquals(4, resultNhGroup.MemberCount);
 //       System.assertEquals(3, resultNhGroupMember.size());
 //       System.assertEquals('Private', resultNhGroup.CollaborationType);
 //   }

    @isTest static void testUpdateUserProfileFromRmToTmSameTeamThenDoNothing() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;
        //Mockup_Test.RUN_TEST_GROUP_CHATTER = true;
        String rmUser = 'testGroupRmUser1';
        CollaborationGroup resultGroup;
        List<CollaborationGroup> allGroup;
        List<CollaborationGroupMember> resultGroupMember;
        User newUser;
        Id tmProfileId;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole rmRole = [SELECT Id FROM UserRole WHERE DeveloperName= :('RCRM' + Mockup_Test.RC_CODE)];
            User tmUser = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM];
            Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
            tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
            newUser = Mockup_Test.newUser(rmUser,
                                                rmUser,
                                                true,
                                                rmUser+'@mail.com',
                                                rmUser+'@mail.com',
                                                'rmUser',
                                                rmProfileId,
                                                rmRole.Id,
                                                tmUser.Id,
                                                '9999999991'
            );
            insert newUser;
        }

        Test.startTest();
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
                newUser.ProfileId = tmProfileId;
                newUser.Job_Code__c = 'ME3A';
                update newUser;
            }
        Test.stopTest();

        Team_Structure__c teamStructure = [SELECT Name,Segment__c FROM Team_Structure__c WHERE External_ID__c = :Mockup_Test.NH_RC_CODE];
        String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);
        //resultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupName];
        //resultGroupMember = [SELECT Id,Member.Name,CollaborationRole FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultGroup.Id AND CollaborationRole = 'Standard'];
        //allGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];

        //System.assertEquals(2, allGroup.size());
        //System.assertEquals(5, resultGroup.MemberCount);
        //System.assertEquals(4, resultGroupMember.size());
        //System.assertEquals('Private', resultGroup.CollaborationType);

        //for(CollaborationGroupMember member : resultGroupMember){
        //    if(member.Member.Name == Mockup_Test.userFirstNameAdmin){
        //        System.assertEquals('Admin',member.CollaborationRole);
        //    }
        //}
    }

    //@isTest static void testUpdateUserTeamThenRemoveUserFromOldGroupAndAddUserToNewGroup() {
    //    TriggerHandler.bypass('TeamStructureTriggerHandler');
    //    TestUtils.enable_isRunningTest = true;
    //    String ahUser = 'testGroupAhUser1';
    //    String nhUser = 'testGroupNhUser1';
    //    String NH_RC_CODE = '1234';
    //    String AH_RC_CODE = '5678';
    //    CollaborationGroup resultGroup1;
    //    CollaborationGroup resultGroup2;
    //    CollaborationGroup resultGroupAllNH;
    //    List<CollaborationGroup> listResultGroup;
    //    List<CollaborationGroupMember> resultGroupMember1;
    //    List<CollaborationGroupMember> resultGroupMember2;
    //    List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();
    //    User newNhUser;
    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

    //        List<Profile> listProfile = [SELECT Id, Name FROM Profile];
    //        Map<String ,Id> mapProfileIdByName = new Map<String ,Id>();
    //        for(Profile pf : listProfile){
    //            mapProfileIdByName.put(pf.Name, pf.Id);
    //        }

    //        Id nhProfileId = mapProfileIdByName.get(GlobalConstants.SME_NH);
    //        Id ahProfileId = mapProfileIdByName.get(GlobalConstants.SME_AH);

    //        Team_Structure__c tsNh = new Team_Structure__c(
    //            External_ID__c = NH_RC_CODE,
    //            RC_Code__c = NH_RC_CODE,
    //            AH_RC_Code__c = null,
    //            NH_RC_Code__c = null,
    //            Name = Mockup_Test.nhTeamName + '1',
    //            Segment__c = Mockup_Test.teamSegment1,
    //            Type__c = 'Network'
    //        );
    //        listTeamStructure.add(tsNh);

    //        Team_Structure__c tsAh = new Team_Structure__c(
    //            External_ID__c = AH_RC_CODE,
    //            RC_Code__c = AH_RC_CODE,
    //            AH_RC_Code__c = null,
    //            NH_RC_Code__c = NH_RC_CODE,
    //            AH_Name__c = null,
    //            NH_Name__c = tsNh.Id,
    //            Name = Mockup_Test.ahTeamName + '1',
    //            Segment__c = Mockup_Test.teamSegment1,
    //            Type__c = 'Area'
    //        );
    //        listTeamStructure.add(tsAh);

    //        insert listTeamStructure;

    //        newNhUser = Mockup_Test.newUser(nhUser,
    //                                            nhUser,
    //                                            true,
    //                                            nhUser+'@mail.com',
    //                                            nhUser+'@mail.com',
    //                                            'nhUser',
    //                                            nhProfileId,
    //                                            null,
    //                                            null,
    //                                            'MockUserGroup2'
    //        );
    //        newNhUser.RC_Code__c = NH_RC_CODE;
    //        newNhUser.NH_RC_Code__c = NH_RC_CODE;
    //        newNhUser.Job_Code__c = 'ME1A';
    //        newNhUser.Status__c = 'A';
    //        newNhUser.Segment__c = Mockup_Test.teamSegment1;
            
    //        Test.startTest();
    //        	insert newNhUser;
    //        Test.stopTest();

    //        //Test.startTest();
	   //     	User oldNhUser = [SELECT Id,RC_Code__c,NH_RC_Code__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameNH];
	   //         oldNhUser.RC_Code__c = NH_RC_CODE;
	   //         oldNhUser.NH_RC_Code__c = NH_RC_CODE;
	   //         update oldNhUser;
	   //     //Test.stopTest();
    //    }
        

    //    Map<String ,Team_Structure__c> mapTeamByExternalId = new Map<String ,Team_Structure__c>();
    //    listTeamStructure = [SELECT Name,Segment__c,External_ID__c FROM Team_Structure__c];     
    //    for(Team_Structure__c eachTeam : listTeamStructure){
    //        mapTeamByExternalId.put(eachTeam.External_ID__c, eachTeam);
    //    }

    //    Map<String ,CollaborationGroup> mapGroupByName = new Map<String ,CollaborationGroup>();
    //    listResultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
    //    for(CollaborationGroup eachGroup : listResultGroup){
    //    	System.debug('Group Name = '+eachGroup.Name);
    //    	System.debug([SELECT Id,CollaborationGroup.Name,Member.Name From CollaborationGroupMember WHERE CollaborationGroupId = :eachGroup.Id]);
    //        mapGroupByName.put(eachGroup.Name, eachGroup);
    //    }

    //    Team_Structure__c teamStructure1 = mapTeamByExternalId.get(Mockup_Test.NH_RC_CODE);

    //    String groupName1 = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure1.Name,teamStructure1.Segment__c);
    //    resultGroup1 = mapGroupByName.get(groupName1);

    //    Team_Structure__c teamStructure2 = mapTeamByExternalId.get(NH_RC_CODE);
    //    String groupName2 = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure2.Name,teamStructure2.Segment__c);
    //    resultGroup2 = mapGroupByName.get(groupName2);

    //    resultGroupAllNH = mapGroupByName.get(Mockup_Test.teamSegment1);

    //    System.assertEquals(3, listResultGroup.size());

    //    System.assertEquals(3, resultGroup2.MemberCount);
    //    System.assertEquals('Private', resultGroup2.CollaborationType);

    //    System.assertEquals(5, resultGroup1.MemberCount);
    //    System.assertEquals('Private', resultGroup1.CollaborationType);

    //    System.assertNotEquals(null,resultGroupAllNH);
    //    System.assertEquals(3,resultGroupAllNH.MemberCount);
    //}

    @isTest static void testInactiveNhThenDeleteNhFromAllNhGroupAndDeleteNhFromOwnGroup() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
		TestUtils.enable_isRunningTest = true;
        //Mockup_Test.RUN_TEST_GROUP_CHATTER = true;
        CollaborationGroup resultGroupAllNH;
        CollaborationGroup resultGroupNH;
        List<CollaborationGroup> listResultGroup;
        List<CollaborationGroupMember> resultGroupMemberAllNh;
        List<CollaborationGroupMember> resultGroupMemberNh;
        List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();
        
        Map<String ,Team_Structure__c> mapTeamByExternalId = new Map<String ,Team_Structure__c>();
        listTeamStructure = [SELECT Name,Segment__c,External_ID__c FROM Team_Structure__c];

        for(Team_Structure__c eachTeam : listTeamStructure){
            mapTeamByExternalId.put(eachTeam.External_ID__c, eachTeam);
        }

        Team_Structure__c teamStructure = mapTeamByExternalId.get(Mockup_Test.NH_RC_CODE);

        String groupNameNH = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);

        //CollaborationGroup cbgAllNH = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1 LIMIT 1];
        //CollaborationGroup cbgNH = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupNameNH LIMIT 1];

        //System.assertEquals(4, cbgAllNH.MemberCount);
        //System.assertEquals('Private', cbgAllNH.CollaborationType);
        //System.assertEquals(5, cbgNH.MemberCount);
        //System.assertEquals('Private', cbgNH.CollaborationType);

        //System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

        //    Test.startTest();
            
        //        User nhUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        //        System.debug('nhUser = '+nhUser);
        //        nhUser.isActive = false;
        //        update nhUser;

        //    Test.stopTest();
        //}

        //Map<String ,CollaborationGroup> mapGroupByName = new Map<String ,CollaborationGroup>();
        //listResultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
        //for(CollaborationGroup eachGroup : listResultGroup){
        //    mapGroupByName.put(eachGroup.Name, eachGroup);
        //}        
        
        //resultGroupNH = mapGroupByName.get(groupNameNH);
        //resultGroupAllNH = mapGroupByName.get(Mockup_Test.teamSegment1);

        //System.assertEquals(2, listResultGroup.size());

        //System.assertEquals(4, resultGroupNH.MemberCount);
        //System.assertEquals('Private', resultGroupNH.CollaborationType);

        //System.assertNotEquals(null,resultGroupAllNH);
        //System.assertEquals(3, resultGroupAllNH.MemberCount);
        //System.assertEquals('Private', resultGroupAllNH.CollaborationType);

    }
	
}