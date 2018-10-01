@isTest
private class ReCalculateOwnership_Batch_Test {
	public static String O_CUSTOMER_RM_TEMP_POOL 	= 'A';
	public static String O_PROSPECT_RM 				= 'B';
	public static String I_PROSPECT_RM_TEMP 		= 'C';
    public static String O_CUSTOMER_TM_POOL_PER 	= 'D';
    public static String O_CUSTOMER_ADMIN_PER  		= 'E';
	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            insert Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_TEMP_POOL, GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            insert Mockup_Test.newAccountWithSegment(O_PROSPECT_RM, '', '', Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            insert Mockup_Test.newAccountWithSegment(I_PROSPECT_RM_TEMP, '', GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.INDIVIDUAL_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_UM);
        }
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            insert Mockup_Test.newAccountWithSegment(O_CUSTOMER_TM_POOL_PER, GlobalConstants.POOL, 'Permanent', Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_UM);
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            insert Mockup_Test.newAccountWithSegment(O_CUSTOMER_ADMIN_PER, null, 'Permanent', Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
        }
	}
	
	@isTest static void currentOwnerRM() {
		//Given
		User rmUser = [SELECT Id, Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Set<String> rcCodes = new Set<String>{rmUser.RC_Code__c, rmUser.AH_RC_Code__c, rmUser.NH_RC_Code__c};
		User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :rmUser.Id LIMIT 1];
		List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
		Map<String, Id> teamMapByRCCode = new Map<String, Id>();
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRCCode.put(eachTeam.RC_Code__c, eachTeam.Id);
		}

		//When
		Test.startTest();
			Database.executeBatch(new RecalculateOwnership_Batch());
		Test.stopTest();

		//Then
		Account targetProspect = Mockup_Test.getFirstAccountFromName(O_PROSPECT_RM, 'OwnerId, Owner.Name, Ownership_Text__c, Permanent_Owner_Extension__c,Permanent_Team_Name__c,Permanent_AH_Name__c,Permanent_NH_Name__c, Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Port_Pool__c,Port_Pool_Flag_Previous_Owner__c,Trash_Pool_Flag__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Previous_AH_Name__c,Previous_NH_Name__c,Previous_Owner_Segment_Code__c,Service_RM__c,Primary_Segment_Code__c,SME_Temporary_Customer__c,AF_Temporary_Customer__c');
		System.assertEquals(rmUser.Id, targetProspect.OwnerId);
		System.assertEquals(teamMapByRCCode.get(rmUser.RC_Code__c), targetProspect.Current_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.AH_RC_Code__c), targetProspect.Current_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.NH_RC_Code__c), targetProspect.Current_NH_Name__c);
		System.assertEquals(userRMExt.Id, targetProspect.Current_Owner_Extension__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.RC_Code__c), targetProspect.Permanent_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.AH_RC_Code__c), targetProspect.Permanent_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.NH_RC_Code__c), targetProspect.Permanent_NH_Name__c);
		System.assertEquals(userRMExt.Id, targetProspect.Permanent_Owner_Extension__c);
		System.assertEquals(null, targetProspect.Port_Pool__c);
		System.assertEquals(null, targetProspect.Ownership_Text__c);
		System.assertEquals(null, targetProspect.Port_Pool_Flag_Previous_Owner__c);
		System.assertEquals(false, targetProspect.Trash_Pool_Flag__c);
		System.assertEquals(null, targetProspect.Previous_Owner__c);
		System.assertEquals(null, targetProspect.Previous_Owner_Extension__c);
		System.assertEquals(null, targetProspect.Previous_Team_Name__c);
		System.assertEquals(null, targetProspect.Previous_AH_Name__c);
		System.assertEquals(null, targetProspect.Previous_NH_Name__c);
		System.assertEquals(null, targetProspect.Previous_Owner_Segment_Code__c);
		System.assertEquals(null, targetProspect.Service_RM__c);
		System.assertEquals(null, targetProspect.SME_Temporary_Customer__c);
		System.assertEquals(null, targetProspect.AF_Temporary_Customer__c);
	}

	@isTest static void currentOwnerTM() {
		//Given

		//When
		Test.startTest();
			Database.executeBatch(new RecalculateOwnership_Batch());
		Test.stopTest();

		//Then
		User tmUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		Set<String> rcCodes = new Set<String>{tmUser.RC_Code__c, tmUser.AH_RC_Code__c, tmUser.NH_RC_Code__c};
		User_Extension__c userTMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :tmUser.Id LIMIT 1];
		List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
		Map<String, Id> teamMapByRCCode = new Map<String, Id>();
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRCCode.put(eachTeam.RC_Code__c, eachTeam.Id);
		}

		Account targetCustomer = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_TM_POOL_PER, 'OwnerId, Owner.Name, Ownership_Text__c, Permanent_Owner_Extension__c,Permanent_Team_Name__c,Permanent_AH_Name__c,Permanent_NH_Name__c, Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Port_Pool__c,Port_Pool_Flag_Previous_Owner__c,Trash_Pool_Flag__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Previous_AH_Name__c,Previous_NH_Name__c,Previous_Owner_Segment_Code__c,Service_RM__c,Primary_Segment_Code__c,SME_Temporary_Customer__c,AF_Temporary_Customer__c');
		System.assertEquals(tmUser.Id, targetCustomer.OwnerId);
		System.assertEquals(teamMapByRCCode.get(tmUser.RC_Code__c), targetCustomer.Current_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.AH_RC_Code__c), targetCustomer.Current_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.NH_RC_Code__c), targetCustomer.Current_NH_Name__c);
		System.assertEquals(userTMExt.Id, targetCustomer.Current_Owner_Extension__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.RC_Code__c), targetCustomer.Permanent_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.AH_RC_Code__c), targetCustomer.Permanent_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.NH_RC_Code__c), targetCustomer.Permanent_NH_Name__c);
		System.assertEquals(userTMExt.Id, targetCustomer.Permanent_Owner_Extension__c);
		System.assertEquals(GlobalConstants.POOL, targetCustomer.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, targetCustomer.Ownership_Text__c);
		System.assertEquals(null, targetCustomer.Port_Pool_Flag_Previous_Owner__c);
		System.assertEquals(false, targetCustomer.Trash_Pool_Flag__c);
		System.assertEquals(null, targetCustomer.Previous_Owner__c);
		System.assertEquals(null, targetCustomer.Previous_Owner_Extension__c);
		System.assertEquals(null, targetCustomer.Previous_Team_Name__c);
		System.assertEquals(null, targetCustomer.Previous_AH_Name__c);
		System.assertEquals(null, targetCustomer.Previous_NH_Name__c);
		System.assertEquals(null, targetCustomer.Previous_Owner_Segment_Code__c);
		System.assertEquals(null, targetCustomer.Service_RM__c);
		System.assertEquals(null, targetCustomer.SME_Temporary_Customer__c);
		System.assertEquals(null, targetCustomer.AF_Temporary_Customer__c);
	}

	@isTest static void currentOwnerAdmin() {
		//Given

		//When
		Test.startTest();
			Database.executeBatch(new RecalculateOwnership_Batch());
		Test.stopTest();

		//Then
		User adminUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		Set<String> rcCodes = new Set<String>{adminUser.RC_Code__c, adminUser.AH_RC_Code__c, adminUser.NH_RC_Code__c};
		User_Extension__c userTMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :adminUser.Id LIMIT 1];
		List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
		Map<String, Id> teamMapByRCCode = new Map<String, Id>();
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRCCode.put(eachTeam.RC_Code__c, eachTeam.Id);
		}

		Account targetCustomer = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_ADMIN_PER, 'OwnerId, Owner.Name, Ownership_Text__c, Permanent_Owner_Extension__c,Permanent_Team_Name__c,Permanent_AH_Name__c,Permanent_NH_Name__c, Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Port_Pool__c,Port_Pool_Flag_Previous_Owner__c,Trash_Pool_Flag__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Previous_AH_Name__c,Previous_NH_Name__c,Previous_Owner_Segment_Code__c,Service_RM__c,Primary_Segment_Code__c,SME_Temporary_Customer__c,AF_Temporary_Customer__c');
		System.assertEquals(adminUser.Id, targetCustomer.OwnerId);
		System.assertEquals(null, targetCustomer.Current_Team_Name__c);
		System.assertEquals(null, targetCustomer.Current_AH_Name__c);
		System.assertEquals(null, targetCustomer.Current_NH_Name__c);
		System.assertEquals(userTMExt.Id, targetCustomer.Current_Owner_Extension__c);
		System.assertEquals(null, targetCustomer.Permanent_Team_Name__c);
		System.assertEquals(null, targetCustomer.Permanent_AH_Name__c);
		System.assertEquals(null, targetCustomer.Permanent_NH_Name__c);
		System.assertEquals(null, targetCustomer.Permanent_Owner_Extension__c);
		System.assertEquals(null, targetCustomer.Port_Pool__c);
		System.assertEquals(null, targetCustomer.Ownership_Text__c);
		System.assertEquals(null, targetCustomer.Port_Pool_Flag_Previous_Owner__c);
		System.assertEquals(false, targetCustomer.Trash_Pool_Flag__c);
		System.assertEquals(null, targetCustomer.Previous_Owner__c);
		System.assertEquals(null, targetCustomer.Previous_Owner_Extension__c);
		System.assertEquals(null, targetCustomer.Previous_Team_Name__c);
		System.assertEquals(null, targetCustomer.Previous_AH_Name__c);
		System.assertEquals(null, targetCustomer.Previous_NH_Name__c);
		System.assertEquals(null, targetCustomer.Previous_Owner_Segment_Code__c);
		System.assertEquals(null, targetCustomer.Service_RM__c);
		System.assertEquals(null, targetCustomer.SME_Temporary_Customer__c);
		System.assertEquals(null, targetCustomer.AF_Temporary_Customer__c);
	}

	@isTest static void currentOwnerTMPreviousOwnerRM() {
		// Given
		User tmUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		System.runAs(tmUser){
            Account targetCustomer = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_RM_TEMP_POOL, 'Id, Name');
            targetCustomer.OwnerId = UserInfo.getUserId();
            update targetCustomer;
        }

        //When
		Test.startTest();
			Database.executeBatch(new RecalculateOwnership_Batch());
		Test.stopTest();

		//Then
		User rmUser = [SELECT Id, Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :rmUser.Id LIMIT 1];
		User_Extension__c userTMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :tmUser.Id LIMIT 1];
		Set<String> rcCodes = new Set<String>{tmUser.RC_Code__c, tmUser.AH_RC_Code__c, tmUser.NH_RC_Code__c, rmUser.RC_Code__c, rmUser.AH_RC_Code__c, rmUser.NH_RC_Code__c};
		List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
		Map<String, Id> teamMapByRCCode = new Map<String, Id>();
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRCCode.put(eachTeam.RC_Code__c, eachTeam.Id);
		}

		Account targetCustomer = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_RM_TEMP_POOL, 'OwnerId, Owner.Name, Ownership_Text__c, Permanent_Owner_Extension__c,Permanent_Team_Name__c,Permanent_AH_Name__c,Permanent_NH_Name__c, Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Port_Pool__c,Port_Pool_Flag_Previous_Owner__c,Trash_Pool_Flag__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Previous_AH_Name__c,Previous_NH_Name__c,Previous_Owner_Segment_Code__c,Service_RM__c,Primary_Segment_Code__c,SME_Temporary_Customer__c,AF_Temporary_Customer__c');
		System.assertEquals(tmUser.Id, targetCustomer.OwnerId);
		System.assertEquals(teamMapByRCCode.get(tmUser.RC_Code__c), targetCustomer.Current_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.AH_RC_Code__c), targetCustomer.Current_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.NH_RC_Code__c), targetCustomer.Current_NH_Name__c);
		System.assertEquals(userTMExt.Id, targetCustomer.Current_Owner_Extension__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.RC_Code__c), targetCustomer.Permanent_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.AH_RC_Code__c), targetCustomer.Permanent_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(tmUser.NH_RC_Code__c), targetCustomer.Permanent_NH_Name__c);
		System.assertEquals(userTMExt.Id, targetCustomer.Permanent_Owner_Extension__c);
		System.assertEquals(rmUser.Id, targetCustomer.Previous_Owner__c);
		System.assertEquals(userRMExt.Id, targetCustomer.Previous_Owner_Extension__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.RC_Code__c), targetCustomer.Previous_Team_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.AH_RC_Code__c), targetCustomer.Previous_AH_Name__c);
		System.assertEquals(teamMapByRCCode.get(rmUser.NH_RC_Code__c), targetCustomer.Previous_NH_Name__c);
	}
	
}