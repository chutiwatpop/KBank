/**
* @author charnun.t@beryl8.com
* @23/02/2017 createddate
*/
@isTest
private class SME_ReCalSMEAdminOwnership_Batch_Test {
	public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String accountNameNH = 'nhCreatedAccountName';
    public static String accountNameAdminRM = 'rmCreatedAccountAdminName';
    public static String accountNameSharedRM = 'rmCreatedAccountSharedName';
	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,null,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,null,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBSAdmin LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,null,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            mt.newAccount(accountNameAdminRM,null,null,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void reCalculateAll(){
		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
		userAdmin.Firstname = '';
		userAdmin.LastName = 'SME-Admin';

		TriggerHandler.bypass('UserTriggerHandler');
		update userAdmin;
		TriggerHandler.clearBypass('UserTriggerHandler');

		List<User_Extension__c> userExtensionUpdateList = new List<User_Extension__c>();
		List<User_Extension__c> userExtensionList = [SELECT Id,Name FROM User_Extension__c];
		System.debug(userExtensionList);
		for(User_Extension__c eachUserExtension : userExtensionList){
			if(eachUserExtension.Name.contains(Mockup_Test.userFirstNameAdmin)){
				eachUserExtension.Name = 'SME-Admin';
				userExtensionUpdateList.add(eachUserExtension);
			}else if(eachUserExtension.Name.contains(Mockup_Test.userFirstNameCBSAdmin)){
				eachUserExtension.Name = 'CBS Admin';
				userExtensionUpdateList.add(eachUserExtension);
			}
		}
		System.debug(userExtensionUpdateList);
		if(userExtensionUpdateList.size()>0){
            UserExtension_Service.updateUserExtension(JSON.serialize((List<User_Extension__c>) userExtensionUpdateList));
		}

		System.runAs(userAdmin){
			Test.startTest();
				Set<Id> accountIdSet = new Set<Id>();
				List<Account> rmAccountList = [SELECT Id,Ownership_Text__c,Owner.Name,Port_Pool__c FROM Account];
				for(Account rmAccount : rmAccountList){
					rmAccount.Ownership_Text__c = null;
					accountIdSet.add(rmAccount.Id);
				}
				TriggerHandler.bypass('AccountTriggerHandler');
				update rmAccountList;
				TriggerHandler.clearBypass('AccountTriggerHandler');

				SME_ReCalculateOwnership_Service.reCalculateSMEAdmin();
				SME_ReCalculateOwnership_Service.reCalculateSMEAdmin(accountIdSet,'All');
				Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
				Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch('All'));
				Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch(accountIdSet,'All'));
			Test.stopTest();
		}
	}
}