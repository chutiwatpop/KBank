/**
* @author komsan.wi@beryl8.com
* @05/08/2015 createddate
*/
@isTest
private class AccountShareInitial_Batch_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    @testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        User targetTMUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User targetAHUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithPreviousOwner(accountNameAH,'Pool',targetTMUser.Id,targetAHUser.Id,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }
    static testMethod void initialAccountShare(){
        // Create custom setting
        Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
        areaBKK1.Group_Indicate__c = 'Bangkok';
        areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
        areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.2)';
        insert areaBKK1;

        ////////////////////////
        Account targetAccount = [SELECT Id,Delete_Flag__c,CIS__c,OwnerId,Previous_Owner__c,Permanent_Owner__c,Port_Pool__c,Primary_Segment_Code__c FROM Account WHERE Name = :AccountShareInitial_Batch_Test.accountNameAH LIMIT 1];
        
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        Account_MaskModel accMaskModel = new Account_MaskModel(targetAccount);
        List<Account_MaskModel> accountTargetList = new List<Account_MaskModel>();
        accMaskModel.temporaryPreviousOwnerUserId = targetAccount.Previous_Owner__c;
        accMaskModel.temporaryNewOwnerUserId = targetAccount.Permanent_Owner__c;
        accountTargetList.add(accMaskModel);

        System.runAs(userAdmin){
            Test.startTest();
                Account_Service.ownerChange(accountTargetList);
                Database.executeBatch(new AccountShareInitial_Batch());
            Test.stopTest();
        }
        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :AccountShareInitial_Batch_Test.accountNameAH LIMIT 1];

        List<AccountShare> finalAccountShare = new List<AccountShare>();
        finalAccountShare = [SELECT Id FROM AccountShare WHERE AccountId IN (SELECT Id FROM Account WHERE Name=: AccountShareInitial_Batch_Test.accountNameAH) AND RowCause='Manual'];
        System.assert(finalAccountShare!=null);
        System.assertEquals(1,finalAccountShare.size());
    }
}