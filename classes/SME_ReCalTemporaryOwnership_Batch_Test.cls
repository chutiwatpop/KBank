/**
* @author charnun.t@beryl8.com
* @23/02/2017 createddate
*/
@isTest
private class SME_ReCalTemporaryOwnership_Batch_Test {
	public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String accountNameNH = 'nhCreatedAccountName';
    public static String accountNameAdminRM = 'rmCreatedAccountAdminName';
    public static String accountNameSharedRM = 'rmCreatedAccountSharedName';
	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,'Temporary',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.PORT,'Temporary',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Lastname=:Mockup_Test.userLastNameAdmin LIMIT 1][0]){
            mt.newAccount(accountNameAH,null,'Temporary',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
		System.runAs([SELECT Id FROM User WHERE Lastname=:Mockup_Test.userLastNameCBSAdmin LIMIT 1][0]){
            mt.newAccount(accountNameNH,null,'Temporary',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            mt.newAccount(accountNameAdminRM,null,'Temporary',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void reCalculateAll(){
		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Set<Id> accountIdSet = new Set<Id>();
				List<Account> rmAccountList = [SELECT Id,Ownership_Text__c,Owner.Name,Port_Pool__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameAH OR Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameNH];
				for(Account rmAccount : rmAccountList){
					//rmAccount.Ownership_Text__c = null;
					accountIdSet.add(rmAccount.Id);
				}
				TriggerHandler.bypass('AccountTriggerHandler');
				update rmAccountList;
				TriggerHandler.clearBypass('AccountTriggerHandler');

				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch('All'));
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch(accountIdSet,'All'));
			Test.stopTest();
		}
	}

	@isTest static void reCalculateOwnerExtension(){
		Account rmAccount = [SELECT Id,Current_Owner_Extension__c,Permanent_Owner_Extension__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameRM LIMIT 1];
		if(rmAccount != null){
			User_Extension__c rmUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameTM LIMIT 1];

			if(rmUserExtension != null){
				rmAccount.Current_Owner_Extension__c = rmUserExtension.Id;
				rmAccount.Permanent_Owner_Extension__c = rmUserExtension.Id;
				update rmAccount;
			}
		}

		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
			Test.stopTest();
		}
	}

	@isTest static void reCalculateCurrentOwnerExtension(){
		Account rmAccount = [SELECT Id,Current_Owner_Extension__c,Permanent_Owner_Extension__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameRM LIMIT 1];
		if(rmAccount != null){
			User_Extension__c rmCurrentUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameRM LIMIT 1];

			if(rmCurrentUserExtension != null){
				rmAccount.Current_Owner_Extension__c = rmCurrentUserExtension.Id;
				rmAccount.Permanent_Owner_Extension__c = null;
				update rmAccount;
			}
		}

		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
			Test.stopTest();
		}
	}

	@isTest static void reCalculatePermanentOwnerExtension(){
		Account rmAccount = [SELECT Id,Current_Owner_Extension__c,Permanent_Owner_Extension__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameRM LIMIT 1];
		if(rmAccount != null){
			User_Extension__c rmPermanentUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameTM LIMIT 1];

			if(rmPermanentUserExtension != null){
				rmAccount.Current_Owner_Extension__c = null;
				rmAccount.Permanent_Owner_Extension__c = rmPermanentUserExtension.Id;
				update rmAccount;
			}
		}

		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
			Test.stopTest();
		}
	}

	@isTest static void reCalculateCurrentOwnerExtensionNotSameOwnerId(){
		Account rmAccount = [SELECT Id,Current_Owner_Extension__c,Permanent_Owner_Extension__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameRM LIMIT 1];
		if(rmAccount != null){
			User_Extension__c rmCurrentUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameTM LIMIT 1];

			if(rmCurrentUserExtension != null){
				rmAccount.Current_Owner_Extension__c = rmCurrentUserExtension.Id;
				rmAccount.Permanent_Owner_Extension__c = null;
				update rmAccount;
			}
		}

		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
			Test.stopTest();
		}
	}

	@isTest static void reCalculatePermanentOwnerExtensionSameOwnerId(){
		Account rmAccount = [SELECT Id,Current_Owner_Extension__c,Permanent_Owner_Extension__c FROM Account WHERE Name = :SME_ReCalTemporaryOwnership_Batch_Test.accountNameRM LIMIT 1];
		if(rmAccount != null){
			User_Extension__c rmPermanentUserExtension = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameRM LIMIT 1];

			if(rmPermanentUserExtension != null){
				rmAccount.Current_Owner_Extension__c = null;
				rmAccount.Permanent_Owner_Extension__c = rmPermanentUserExtension.Id;
				update rmAccount;
			}
		}

		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		System.runAs(userAdmin){
			Test.startTest();
				Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
			Test.stopTest();
		}
	}
}