@isTest
private class SME_TeamStructureInitial_Test {
	
	@testsetup static void setupTeamStructure(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
	}

	@isTest static void testProvinceTeamtoUser() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();

			User tm = [SELECT Id, IsActive, RC_Code__c, Province__c FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
			Team_Structure__c teamStructure = [SELECT OwnerId, Province__c FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];

			System.assertEquals(teamStructure.OwnerId, tm.Id);
			System.assertEquals(teamStructure.Province__c, tm.Province__c);
		}
	}
	
	@isTest static void testUserWithRCCodeAndUserActive() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		User tm = [SELECT Id, IsActive, RC_Code__c FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
		Team_Structure__c teamStructure = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];

		System.assertEquals(tm.Id,teamStructure.OwnerId);
	}

	@isTest static void testUserWithRCCodeAndUserInactiveButManagerActiveAndNotNull() {
		User tm = [SELECT Id, IsActive, RC_Code__c, ManagerId FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			tm.IsActive = false;
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update tm;
		}

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		Team_Structure__c teamStructure = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		System.assertEquals(tm.ManagerId,teamStructure.OwnerId);

	}

	@isTest static void testUserWithRCCodeAndUserInactiveButManagerInActiveAndNotNull() {
		User tm = [SELECT Id, IsActive, RC_Code__c, ManagerId, Manager.IsActive, Manager.ManagerId FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
		User ah = [SELECT Id, IsActive, RC_Code__c, ManagerId FROM User WHERE Id =: tm.ManagerId];
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			tm.IsActive = false;
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update tm;
            
            ah.IsActive = false;
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update ah;
		}
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		Team_Structure__c teamStructure = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		System.assertEquals(ah.ManagerId, teamStructure.OwnerId);
	}

	@isTest static void testTeamStructureWithNoUser(){
		User tm = [SELECT Id, IsActive, RC_Code__c, ManagerId, Manager.IsActive, Manager.ManagerId FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			tm.RC_CODE__c = '2398295823523';
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update tm;
		}

		Team_Structure__c teamStructureAH = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.AH_RC_CODE];
		teamStructureAH.OwnerId = tm.ManagerId;
		update teamStructureAH;

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		Team_Structure__c teamStructureTM = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		System.assertEquals(teamStructureAH.OwnerId, teamStructureTM.OwnerId);
	}

	@isTest static void testTeamStructureWithNoUserAndNoAHStructure(){
		User tm = [SELECT Id, IsActive, RC_Code__c, ManagerId, Manager.IsActive, Manager.ManagerId FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			tm.RC_CODE__c = '2398295823523';
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update tm;
		}

		Team_Structure__c teamStructureTM = [SELECT OwnerId, AH_Name__c FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		teamStructureTM.AH_Name__c = null;
		update teamStructureTM;

		Team_Structure__c teamStructureNH = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.NH_RC_CODE];
		teamStructureNH.OwnerId = tm.Manager.ManagerId;
		update teamStructureNH;

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		teamStructureTM = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		System.assertEquals(teamStructureNH.OwnerId, teamStructureTM.OwnerId);
	}

	@isTest static void testTeamStructureWithNoUserAndNoAHAndNHStructure(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User tm = [SELECT Id, IsActive, RC_Code__c, ManagerId, Manager.IsActive, Manager.ManagerId FROM User WHERE RC_Code__c = :Mockup_Test.RC_CODE AND FirstName = :Mockup_Test.userFirstNameTM];
			tm.RC_CODE__c = '2398295823523';
            SME_CalculateOwnershipAssignment_Service.oldUserMap = null;
			update tm;
		}

		Team_Structure__c teamStructureTM = [SELECT OwnerId, AH_Name__c, NH_Name__c FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		teamStructureTM.AH_Name__c = null;
		teamStructureTM.NH_Name__c = null;
		update teamStructureTM;

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TeamStructureInitial_Batch());
			Test.stopTest();
		}

		teamStructureTM = [SELECT OwnerId, AH_Name__c, NH_Name__c FROM Team_Structure__c WHERE RC_Code__c = : Mockup_Test.RC_CODE];
		
		User admin = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin];
		System.assertEquals(admin.Id, teamStructureTM.OwnerId);
	}
}