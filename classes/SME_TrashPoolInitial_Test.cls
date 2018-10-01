@isTest
private class SME_TrashPoolInitial_Test {
	private static Map<Id,User> userMap;
	private static Map<String,Id> userExtMap;
	private static Map<Id,User> userMapByExt;
	private static Map<String,Team_Structure__c> teamStructureMap;

	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String accountNameNH = 'nhCreatedAccountName';

	@testSetup static void setUpSME_TrashPoolInitial_Test(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test();
		mt.setUpTestWithRCCode();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,null,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,null,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,null,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1][0]){
            mt.newAccount(accountNameNH,null,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        List<User> userToUpdateList = new List<User>();
        System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
        	TriggerHandler.bypass('UserTriggerHandler');
        	User userRM = [SELECT Id, Current_Opportunity_Approval__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        	userRM.Current_Opportunity_Approval__c = null;
        	userToUpdateList.add(userRM);
        	User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        	userTM.Current_Opportunity_Approval__c = null;
        	userToUpdateList.add(userTM);
        	update userToUpdateList;
        	TriggerHandler.clearBypass('UserTriggerHandler');
        }
        
		Test.stopTest();
		
	}

	@isTest static void testOwnerOfAccountIsRMAndTMIsActive(){
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.RC_Code__c];
		Team_Structure__c teamAHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.AH_RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.NH_RC_Code__c];
		System.debug('userTM : '+userTM);
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userTM.Id];
		System.debug('userExtTM : '+userExt);
		Account accountRm = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameRM];
		System.assertEquals(GlobalConstants.POOL, accountRm.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY, accountRm.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountRm.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountRm.Permanent_Team_Name__c);
		System.assertEquals(teamAHRCCode.Id, accountRm.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountRm.Permanent_NH_Name__c);
	}
	
	@isTest static void testOwnerOfAccountIsRMAndTMIsInactiveAndAHIsActive() {
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.IsActive = false;
			update userTM;
		}
		
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();
		
		User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAH.Id];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.RC_Code__c];
		Team_Structure__c teamAHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.AH_RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.NH_RC_Code__c];
		Account accountRm = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameRM];
		
		System.assertEquals(GlobalConstants.POOL, accountRm.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY, accountRm.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountRm.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountRm.Permanent_Team_Name__c);
		System.assertEquals(teamAHRCCode.Id, accountRm.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountRm.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsRMAndTMIsInactiveAndAHIsInactiveAndNHIsActive(){
		List<User> userToUpdateList = new List<User>();
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.byPass('UserTriggerHandler');

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.IsActive = false;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}

		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();
		
		
		User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userNH.Id];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.RC_Code__c];
		
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.NH_RC_Code__c];
		Account accountRm = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameRM];
		
		System.assertEquals(GlobalConstants.POOL, accountRm.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY, accountRm.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountRm.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountRm.Permanent_Team_Name__c);
		System.assertEquals(null, accountRm.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountRm.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsRMAndTMIsInactiveAndAHIsInactiveAndNHIsInactive(){
		
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.byPass('UserTriggerHandler');

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.IsActive = false;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;

			User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
			userNH.IsActive = false;
			update userNH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TrashPoolInitial_Batch());
			Test.stopTest();
		}
		
		User userAdmin = [SELECT Id FROM User WHERE Firstname =: Mockup_Test.userFirstNameAdmin];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAdmin.Id];
		Account accountRm = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameRM];
		
		System.assertEquals(GlobalConstants.POOL, accountRm.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY, accountRm.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountRm.Permanent_Owner_Extension__c);
		System.assertEquals(null, accountRm.Permanent_Team_Name__c);
		System.assertEquals(null, accountRm.Permanent_AH_Name__c);
		System.assertEquals(null, accountRm.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsTMAndTMIsActive(){
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userTM.Id];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.RC_Code__c];
		Team_Structure__c teamAHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.AH_RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userTM.NH_RC_Code__c];
		Account accountTM = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameTM];
		System.assertEquals(GlobalConstants.POOL, accountTM.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountTM.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountTM.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountTM.Permanent_Team_Name__c);
		System.assertEquals(teamAHRCCode.Id, accountTM.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountTM.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsTMAndTMIsInactiveAndAHIsActive(){
		
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.bypass('UserTriggerHandler');
			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.IsActive = false;
			update userTM;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}
		
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAH.Id];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.RC_Code__c];
		Team_Structure__c teamAHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.AH_RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.NH_RC_Code__c];
		Account accountTM = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameTM];
		System.assertEquals(GlobalConstants.POOL, accountTM.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountTM.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountTM.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountTM.Permanent_Team_Name__c);
		System.assertEquals(teamAHRCCode.Id, accountTM.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountTM.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsTMAndTMIsInactiveAndAHIsInactiveAndNHIsActive(){
		
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.byPass('UserTriggerHandler');
			User userRM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
			userRM.Current_Opportunity_Approval__c = null;
			update userRM;

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.IsActive = false;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		
		}
		

		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userNH.Id];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.NH_RC_Code__c];
		Account accountTM = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameTM];
		System.assertEquals(GlobalConstants.POOL, accountTM.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountTM.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountTM.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountTM.Permanent_Team_Name__c);
		System.assertEquals(null, accountTM.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountTM.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsTMAndTMIsInactiveAndAHIsInactiveAndNHIsInactive(){
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.bypass('UserTriggerHandler');
			User userRM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userRM.Current_Opportunity_Approval__c = null;
			update userRM;

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.Current_Opportunity_Approval__c =null;
			userTM.IsActive = false;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;

			User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
			userNH.IsActive = false;
			update userNH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			Test.startTest();
			Database.executeBatch(new SME_TrashPoolInitial_Batch());
			Test.stopTest();
		}


		
		User userAdmin = [SELECT Id FROM User WHERE Firstname =: Mockup_Test.userFirstNameAdmin];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAdmin.Id];
		Account accountTM = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameTM];
		
		System.assertEquals(GlobalConstants.POOL, accountTM.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountTM.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountTM.Permanent_Owner_Extension__c);
		System.assertEquals(null, accountTM.Permanent_Team_Name__c);
		System.assertEquals(null, accountTM.Permanent_AH_Name__c);
		System.assertEquals(null, accountTM.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsAHAndAHIsActive(){
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.RC_Code__c];
		Team_Structure__c teamAHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.AH_RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userAH.NH_RC_Code__c];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAH.Id];

		Account accountAH = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameAH];
		System.assertEquals(GlobalConstants.POOL, accountAH.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountAH.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountAH.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountAH.Permanent_Team_Name__c);
		System.assertEquals(teamAHRCCode.Id, accountAH.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountAH.Permanent_NH_Name__c);
	}
	
	@isTest static void testOwnerOfAccountIsAHAndAHIsInactiveAndNHIsActive(){
		
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.bypass('UserTriggerHandler');
			User userRM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userRM.Current_Opportunity_Approval__c = null;
			update userRM;

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.Current_Opportunity_Approval__c =null;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}
		
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.NH_RC_Code__c];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userNH.Id];

		Account accountAH = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameAH];
		System.assertEquals(GlobalConstants.POOL, accountAH.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountAH.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountAH.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountAH.Permanent_Team_Name__c);
		System.assertEquals(null, accountAH.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountAH.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsAHAndAHIsInactiveAndNHIsInactive(){
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.bypass('UserTriggerHandler');
			User userRM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userRM.Current_Opportunity_Approval__c = null;
			update userRM;

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.Current_Opportunity_Approval__c =null;
			update userTM;

			User userAH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
			userAH.IsActive = false;
			update userAH;

			User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
			userNH.IsActive = false;
			update userNH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}
		
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();
		User userAdmin = [SELECT Id FROM User WHERE Firstname =: Mockup_Test.userFirstNameAdmin];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAdmin.Id];
		Account accountAH = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameAH];
		
		System.assertEquals(GlobalConstants.POOL, accountAH.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountAH.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountAH.Permanent_Owner_Extension__c);
		System.assertEquals(null, accountAH.Permanent_Team_Name__c);
		System.assertEquals(null, accountAH.Permanent_AH_Name__c);
		System.assertEquals(null, accountAH.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsNHAndNHIsActive(){
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();

		User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
		Team_Structure__c teamRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.RC_Code__c];
		Team_Structure__c teamNHRCCode = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c =: userNH.NH_RC_Code__c];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userNH.Id];

		Account accountNH = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameNH];
		System.assertEquals(GlobalConstants.POOL, accountNH.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountNH.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountNH.Permanent_Owner_Extension__c);
		System.assertEquals(teamRCCode.Id, accountNH.Permanent_Team_Name__c);
		System.assertEquals(null, accountNH.Permanent_AH_Name__c);
		System.assertEquals(teamNHRCCode.Id, accountNH.Permanent_NH_Name__c);
	}

	@isTest static void testOwnerOfAccountIsNHAndNHIsInactive(){
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
			TriggerHandler.bypass('UserTriggerHandler');
			User userRM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userRM.Current_Opportunity_Approval__c = null;
			update userRM;

			User userTM = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
			userTM.Current_Opportunity_Approval__c =null;
			update userTM;

			User userNH = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
			userNH.IsActive = false;
			update userNH;
			TriggerHandler.clearBypass('UserTriggerHandler');
		}
		
		Test.startTest();
		Database.executeBatch(new SME_TrashPoolInitial_Batch());
		Test.stopTest();
		User userAdmin = [SELECT Id FROM User WHERE Firstname =: Mockup_Test.userFirstNameAdmin];
		User_Extension__c userExt = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: userAdmin.Id];
		Account accountNH = [SELECT Id, Port_Pool__c, Ownership_Text__c , Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Name =: accountNameNH];
		
		System.assertEquals(GlobalConstants.POOL, accountNH.Port_Pool__c);
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, accountNH.Ownership_Text__c);
		System.assertEquals(userExt.Id, accountNH.Permanent_Owner_Extension__c);
		System.assertEquals(null, accountNH.Permanent_Team_Name__c);
		System.assertEquals(null, accountNH.Permanent_AH_Name__c);
		System.assertEquals(null, accountNH.Permanent_NH_Name__c);
	}
}