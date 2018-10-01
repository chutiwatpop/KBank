@isTest
private class SME_FixAccountPermanentOwner_Batch_Test {
    public static String customerPoolNameTM = 'customerPoolNameTM';
    public static String customerPortNameTM = 'customerPortNameTM';
    public static String customerPoolNameRM = 'customerPoolNameRM';
    public static String customerPortNameRM = 'customerPortNameRM';
    public static String prospectNameRM     = 'prospectNameRM';
    public static String customerPoolNameAH = 'customerPoolNameAH';
    public static String customerPoolNameAdmin = 'customerPoolNameAdmin';

    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithExtension().setUpTestAdmin();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(customerPoolNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(customerPortNameTM,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(customerPoolNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(customerPortNameRM,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(prospectNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(customerPoolNameAH,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            mt.newAccount(customerPoolNameAdmin,null,null,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

    @isTest static void testFixBatch(){
        Test.startTest();
            Database.executeBatch(new SME_FixAccountPermanentOwner_Batch());
        Test.stopTest();
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :userRM.Id LIMIT 1];
        User_Extension__c userTMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :userTM.Id LIMIT 1];
        User_Extension__c userAHExt = [SELECT Id FROM User_Extension__c WHERE User__c = :userAH.Id LIMIT 1];
    
        //Account acccustomerPoolNameRM = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameRM LIMIT 1];
        //Account acccustomerPortNameRM = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPortNameRM LIMIT 1];
        //Account accprospectNameRM     = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.prospectNameRM LIMIT 1];

        //Account acccustomerPoolNameTM = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameTM LIMIT 1];
        //Account acccustomerPortNameTM = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPortNameTM LIMIT 1];
        
        //Account acccustomerPoolNameAH = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameAH LIMIT 1];
        
        //Account acccustomerPoolNameAdmin = [SELECT Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameAdmin LIMIT 1];
        
        Account acccustomerPoolNameRM = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameRM, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account acccustomerPortNameRM = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPortNameRM, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account accprospectNameRM = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.prospectNameRM, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account acccustomerPoolNameTM = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameTM, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account acccustomerPortNameTM = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPortNameTM, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account acccustomerPoolNameAH = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameAH, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');
        Account acccustomerPoolNameAdmin = Mockup_Test.getFirstAccountFromName(SME_FixAccountPermanentOwner_Batch_Test.customerPoolNameAdmin, 'Id,Permanent_Owner_Extension__c,Port_Pool__c, Ownership_Text__c');

        System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY, accprospectNameRM.Ownership_Text__c);
        System.assertEquals(null, accprospectNameRM.Port_Pool__c);
        System.assertEquals(null, accprospectNameRM.Permanent_Owner_Extension__c);

        System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT,    acccustomerPortNameRM.Ownership_Text__c);
        System.assertEquals(GlobalConstants.PORT,                   acccustomerPortNameRM.Port_Pool__c);
        System.assertEquals(userRMExt.Id,                           acccustomerPortNameRM.Permanent_Owner_Extension__c);

        System.assertEquals(GlobalConstants.OWNERSHIP_TEMPORARY,    acccustomerPoolNameRM.Ownership_Text__c);
        System.assertEquals(GlobalConstants.POOL,                   acccustomerPoolNameRM.Port_Pool__c);
        System.assertEquals(userTMExt.Id,                           acccustomerPoolNameRM.Permanent_Owner_Extension__c);

        System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT,    acccustomerPortNameTM.Ownership_Text__c);
        System.assertEquals(GlobalConstants.PORT,                   acccustomerPortNameTM.Port_Pool__c);
        System.assertEquals(userTMExt.Id,                           acccustomerPortNameTM.Permanent_Owner_Extension__c);

        System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT,    acccustomerPoolNameTM.Ownership_Text__c);
        System.assertEquals(GlobalConstants.POOL,                   acccustomerPoolNameTM.Port_Pool__c);
        System.assertEquals(userTMExt.Id,                           acccustomerPoolNameTM.Permanent_Owner_Extension__c);

        System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT,    acccustomerPoolNameAH.Ownership_Text__c);
        System.assertEquals(GlobalConstants.POOL,                   acccustomerPoolNameAH.Port_Pool__c);
        System.assertEquals(userAHExt.Id,                           acccustomerPoolNameAH.Permanent_Owner_Extension__c);

        System.assertEquals(null, acccustomerPoolNameAdmin.Ownership_Text__c);
        System.assertEquals(null, acccustomerPoolNameAdmin.Port_Pool__c);
        System.assertEquals(null, acccustomerPoolNameAdmin.Permanent_Owner_Extension__c);
    }
    
}