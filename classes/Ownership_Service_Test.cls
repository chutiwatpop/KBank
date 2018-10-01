/**
 * @author: komsan.wi@beryl8.com.com
 * @komsan.wi: 27/07/2015 create new
 */
@isTest
private class Ownership_Service_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String accountNameRMPort = 'accountNameRMPort';
    public static String accountNameRMPool = 'accountNameRMPool';
    public static String accountNameCBRMPort = 'accountNameCBRMPort';
    @testSetup static void setupAccount(){

        List<Profile> profileList = [SELECT Id,Name FROM Profile];
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User rmCBSUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        User tmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        System.runAs(rmCBSUser){
            mt.newAccount(accountNameCBRMPort,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs(tmUser){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs(rmUser){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMPort,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMPool,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        Test.stopTest();

        System.runAs(new User(Id=UserInfo.getUserId())){
            rmUser.Segment__c = GlobalConstants.SEGMENT_SE;
            tmUser.Segment__c = GlobalConstants.SEGMENT_SE;
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
            update tmUser;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }

    static testMethod void releaseTempOwnership_AN() {
        Mockup_Test.setupANTeam();

        User targetUserAN = [SELECT Id,RC_Code__c,Segment__c FROM User WHERE Firstname=:Mockup_Test.tmANUserFirstName LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Ownership_Service_Test.accountNameTM, 'Id,Name,Port_Pool__c,OwnerId,Owner.Employee_Id__c,RC_Code__c,Temporary_Ownership_Flag__c');
        Test.startTest();
        System.runAs(targetUserAN){
            Ownership_Service.Response res = Ownership_Service.releaseTemporaryOwnership(targetAccount.Id);
            System.assertEquals(false, res.success);
            System.assertEquals(Label.Release_Temporary_Ownership_Error_User, res.msg);
        }
        Test.stopTest();
    }

    static testMethod void releaseTempOwnership_AlreadyRelease() {
        User targetUserRM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Ownership_Service_Test.accountNameRMPool, 'Id,Name,Port_Pool__c,OwnerId,Owner.Employee_Id__c,RC_Code__c,Temporary_Ownership_Flag__c');
        
        System.runAs(targetUserRM){
            Ownership_Service.Response res = Ownership_Service.releaseTemporaryOwnership(targetAccount.Id);
        }
        
        Test.startTest();
        System.runAs(targetUserRM){
            Ownership_Service.Response res = Ownership_Service.releaseTemporaryOwnership(targetAccount.Id);

            System.assertEquals(false, res.success);
        }
        Test.stopTest();
    }
}