@isTest
private class SME_YearEndContactChangeOwner_Batch_Test
{
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String contactNameTM = 'tmCreatedContactName';
    public static String contactNameRM = 'rmCreatedContactName';
    public static String contactNameAH = 'ahCreatedContactName';

    public static String lastNameTM = 'tmCreatedLastName';
    public static String lastNameRM = 'rmCreatedLastName';
    public static String lastNameAH = 'ahCreatedLastName';
    @testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameAH,contactNameAH,lastNameAH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

    static testMethod void itShould()
    {
        Test.startTest();
            Database.executeBatch(new SME_YearEndContactChangeOwner_Batch());
        Test.stopTest();
    }
}