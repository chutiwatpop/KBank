/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
*/
@isTest
private class Account_Test {
    public static String accountNameTM          = 'tmCreatedAccountName';
    public static String accountNameRM          = 'rmCreatedAccountName';
    public static String accountNameSharedRM    = 'rmCreatedAccountSharedName';
    public static String accountNameAH          = 'ahCreatedAccountName';
    public static String accountNameNH          = 'nhCreatedAccountName';
    @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTestWithRCCodeOnlySme();
            //Mockup_Test.setupANTeam();
        }
        System.runAs([SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
            System.runAs([SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameNH LIMIT 1][0]){
            mt.newAccount(accountNameNH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }

        User userAdmin = [SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
        User userCBSAdmin = [SELECT Id From User WHERE FirstName=:Mockup_Test.userFirstNameCBSAdmin LIMIT 1][0];
        User_Admin__c settings = User_Admin__c.getOrgDefaults();
        settings.SME_User_ID__c = userAdmin.Id;
        settings.CBS_User_ID__c = userCBSAdmin.Id;
        settings.Integration_User_ID__c = UserInfo.getUserId();
        update settings;

        //User badRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.rmANUserFirstName];

        //System.runAs([SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
        //    insert new Account(
        //        Name = accountNameSharedRM,
        //        Port_Pool__c = GlobalConstants.PORT,
        //        RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
        //        Primary_Segment_Code__c = 'SM',
        //        Share_With__c = badRM.Id,
        //        Sharing_Status__c = GlobalConstants.SHARING_WITH_AN
        //    );
        //}

        //System.runAs(new User(Id=UserInfo.getUserId())){
        //    Mockup_Test.setupANAccountShare(accountNameSharedRM);
        //}
        Test.stopTest();
        
    }
    //static testMethod void deletedProspect45day(){
    //  //Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Account_Test.accountNameRM LIMIT 1];
 //       Account targetAccount = Mockup_Test.getFirstAccountFromName(Account_Test.accountNameRM, 'Id,Delete_Flag__c');
    //  Test.startTest();
    //      targetAccount.Delete_Flag__c = true;
    //      update targetAccount;
    //  Test.stopTest();
 //       List<Account> listTargetAccount = new List<Account>();
 //       listTargetAccount = Mockup_Test.getAllAccountFromName(Account_Test.accountNameRM, 'Id,Delete_Flag__c');
    //  System.assertEquals(0,listTargetAccount.size());
    //}
    
    @isTest static void accountOfGoodOwnerANotSharedWithBadChangeOwnerToGoodOwnerBCallPlan(){
        //Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c FROM Account WHERE Name = : accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c');
        User accountOwnerRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User newAccountOwnerTM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];

        Test.startTest();
        Call_Report__c callPlanGoodRM;
        System.runAs(accountOwnerRM){
            callPlanGoodRM = new Call_Report__c(
            Contact_FirstName__c = 'abc',
            Contact_LastName__c = 'def',
            Contact_Phone__c = '123456789',
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.PLAN,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
            Plan_Date__c = System.Today().addMonths(1)
            );
            insert callPlanGoodRM;
        }
        targetAccount.OwnerChangeExecutedByTrigger__c = true;
        targetAccount.OwnerId = newAccountOwnerTM.Id;
        update targetAccount;
        Test.stopTest();

        //targetAccount = [SELECT Id,Delete_Flag__c,OwnerId FROM Account WHERE Name = :accountNameRM LIMIT 1];
        targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Delete_Flag__c,OwnerId');
        //callPlanGoodRM = [SELECT Id, Status__c, Current_Owner_Extension__r.User__c FROM Call_Report__c WHERE Id =: callPlanGoodRM.Id];

        System.assertEquals(newAccountOwnerTM.Id,targetAccount.OwnerId);
        //System.assertEquals(GlobalConstants.CLOSED,callPlanGoodRM.Status__c);
        //System.assertEquals(accountOwnerRM.Id,callPlanGoodRM.Current_Owner_Extension__r.User__c);
    }

    

    @isTest static void accountOfGoodOwnerANotSharedWithBadChangeOwnerToGoodOwnerBOpportunity(){
        
        //Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c FROM Account WHERE Name = : accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c');
        User accountOwnerRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User newAccountOwnerTM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        //User badRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.rmANUserFirstName];

        
        Test.startTest();
        String oppNameGoodRM = 'TestOpp1';
        System.runAs(accountOwnerRM){
            Opportunity opportunityTest = Mockup_Test.newOpportunity(targetAccount.Id, oppNameGoodRM, GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.CMAS);
            insert opportunityTest;
        }
        targetAccount.OwnerChangeExecutedByTrigger__c = true;
        targetAccount.OwnerId = newAccountOwnerTM.Id;
        update targetAccount;
        Test.stopTest();

        //targetAccount = [SELECT Id,Delete_Flag__c,OwnerId FROM Account WHERE Name = :Account_Test.accountNameRM LIMIT 1];
        targetAccount = Mockup_Test.getFirstAccountFromName(Account_Test.accountNameRM, 'Id,Delete_Flag__c,OwnerId');
        Opportunity oppGoodRM = [SELECT Id, StageName,Current_Owner_Extension__r.User__c,OwnerId FROM Opportunity WHERE Name =: oppNameGoodRM];

        System.assertEquals(newAccountOwnerTM.Id,targetAccount.OwnerId);
        //System.assertEquals(newAccountOwnerTM.Id,oppGoodRM.Current_Owner_Extension__r.User__c);
        //System.assertEquals(newAccountOwnerTM.Id,oppGoodRM.OwnerId);
        //System.assertEquals(GlobalConstants.STOCK_NEGOTIATION,oppGoodRM.StageName);
    }

    //@isTest static void accountOfGoodOwnerASharedWithBadChangeOwnerToGoodOwnerBCallPlan(){
    //    //Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c FROM Account WHERE Name = : accountNameSharedRM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameSharedRM, 'Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c');
    //    User accountOwnerRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
    //    User newAccountOwnerTM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
    //    User badRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.rmANUserFirstName];

    //    Test.startTest();
    //    Call_Report__c callPlanBadRM;
    //    System.runAs(badRM){
    //        callPlanBadRM = new Call_Report__c(
    //        Contact_FirstName__c = 'abc',
    //        Contact_LastName__c = 'defg',
    //        Contact_Phone__c = '123456789',
    //        CIS_ID__c = targetAccount.Id,
    //        Status__c = GlobalConstants.PLAN,
    //        RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
    //        Plan_Date__c = System.Today().addMonths(1)
    //        );
    //        insert callPlanBadRM;
    //    }

    //    AccountShare accountShare = [SELECT AccountAccessLevel FROM AccountShare WHERE UserOrGroupId =: badRM.Id AND AccountId =: targetAccount.Id];
    //    System.assertEquals('Edit',accountShare.AccountAccessLevel);

    //    targetAccount.OwnerChangeExecutedByTrigger__c = true;
    //    targetAccount.OwnerId = newAccountOwnerTM.Id;
    //    update targetAccount;
    //    Test.stopTest();

    //    accountShare = [SELECT AccountAccessLevel,RowCause FROM AccountShare WHERE UserOrGroupId =: badRM.Id AND AccountId =: targetAccount.Id];
    //    System.assertEquals('Edit',accountShare.AccountAccessLevel);

    //    //targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Sharing_Status__c FROM Account WHERE Name = :accountNameSharedRM LIMIT 1];
    //    targetAccount = Mockup_Test.getFirstAccountFromName(accountNameSharedRM, 'Id,Delete_Flag__c,OwnerId,Sharing_Status__c');
    //    callPlanBadRM = [SELECT Id, Status__c, Current_Owner_Extension__r.User__c FROM Call_Report__c WHERE Id =: callPlanBadRM.Id];
    //    System.assertEquals(newAccountOwnerTM.Id,targetAccount.OwnerId);
    //    System.assertEquals(GlobalConstants.PLAN,callPlanBadRM.Status__c);
    //    System.assertEquals(badRM.Id,callPlanBadRM.Current_Owner_Extension__r.User__c);
    //    System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetAccount.Sharing_Status__c);
    //}

    //@isTest static void accountOfGoodOwnerASharedWithBadChangeOwnerToGoodOwnerBOpportunity(){
    //    //Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c FROM Account WHERE Name = : accountNameSharedRM LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameSharedRM, 'Id,Delete_Flag__c,OwnerChangeExecutedByTrigger__c');
    //    User accountOwnerRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
    //    User newAccountOwnerTM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
    //    User badRM = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.rmANUserFirstName];

    //    AccountShare accountShare = [SELECT AccountAccessLevel,RowCause FROM AccountShare WHERE UserOrGroupId =: badRM.Id AND AccountId =: targetAccount.Id];
    //    System.assertEquals('Edit',accountShare.AccountAccessLevel);

    //    Test.startTest();
    //    String oppNameBadRM = 'TestOpp2';
    //    System.runAs(badRM){
    //        Opportunity opportunityTest = Mockup_Test.newOpportunity(targetAccount.Id, oppNameBadRM, GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.CMAS);
    //        insert opportunityTest;
    //    }
    //    targetAccount.OwnerChangeExecutedByTrigger__c = true;
    //    targetAccount.OwnerId = newAccountOwnerTM.Id;
    //    update targetAccount;
    //    Test.stopTest();

    //    accountShare = [SELECT AccountAccessLevel,RowCause FROM AccountShare WHERE UserOrGroupId =: badRM.Id AND AccountId =: targetAccount.Id];
    //    System.assertEquals('Edit',accountShare.AccountAccessLevel);
        
    //    Opportunity oppBadRM = [SELECT Id, StageName,Current_Owner_Extension__r.User__c,OwnerId,IsClosed FROM Opportunity WHERE Name =: oppNameBadRM];
    //    //targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Sharing_Status__c FROM Account WHERE Name = :Account_Test.accountNameSharedRM LIMIT 1];
    //    targetAccount = Mockup_Test.getFirstAccountFromName(Account_Test.accountNameSharedRM, 'Id,Delete_Flag__c,OwnerId,Sharing_Status__c');
    //    System.assertEquals(newAccountOwnerTM.Id,targetAccount.OwnerId);
    //    System.assertEquals(badRM.Id,oppBadRM.Current_Owner_Extension__r.User__c);
    //    System.assertEquals(badRM.Id,oppBadRM.OwnerId);
    //    System.assertEquals(GlobalConstants.STOCK_NEGOTIATION,oppBadRM.StageName);
    //    System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetAccount.Sharing_Status__c);
    //}

    @isTest static void integratedCustomerCBS(){
        Account newAccount;
        Test.startTest();
        newAccount =  new Account(
            Name = 'accountCBS',
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB,
            Is_createby_Integration__c = true
        );
        insert newAccount;
        Test.stopTest();
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        newAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(userAdmin.CBS_User_ID__c, newAccount.OwnerId);
    }

    @isTest static void integratedCustomerSME(){
        Account newAccount;
        Test.startTest();
        newAccount =  new Account(
            Name = 'accountSME',
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM,
            Is_createby_Integration__c = true
        );
        insert newAccount;
        Test.stopTest();
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        newAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(userAdmin.SME_User_ID__c, newAccount.OwnerId);
    }

    @isTest static void convertOProspectToOCustomer_test() {
        
        Account OtoO = new Account(
            Name = 'Prospect O to O',
            Temporary_Customer__c = true,
            RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME)
        );
        insert OtoO;

        Contact OContact = new Contact(
            FirstName = 'Contact',
            LastName = 'O',
            AccountId = OtoO.Id,
            Phone_Numbers__c = '0810000000',
            RecordTypeId = GlobalUtility.getRecordTypeId('Contact', 'SME_Contact')
        );
        insert OContact;

        Id acctId = OtoO.Id;

        List<Account> changedAccountList = [SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId];
        Map<Id, Account> oldAccountById = new Map<Id, Account>([SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId]);

        for(Account eachAccount : changedAccountList) {
            eachAccount.RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
            eachAccount.Customer_Type_Code__c = 'O';
        }

        Test.startTest();
        new AccountTriggerHandler().updateContactLookupAccount(changedAccountList, oldAccountById);
        Test.stopTest();

        List<Contact> newOContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE AccountId = :acctId];
        
        boolean isO = true;
        for(Contact eachContact : newOContactList){
            if(eachContact.CIS__c == acctId || eachContact.AccountId == null) isO = false;
        }

        System.assertEquals(true, isO);
    }

    @isTest static void convertIProspectToICustomer_test() {
        Account ItoI = new Account(
            LastName = 'Prospect I to I',
            Temporary_Customer__c = true,
            RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME)
        );
        insert ItoI;

        Contact IContact = new Contact(
            FirstName = 'Contact',
            LastName = 'I',
            CIS__c = ItoI.Id,
            Phone_Numbers__c = '0810000000',
            RecordTypeId = GlobalUtility.getRecordTypeId('Contact', 'Individual_Contact')
        );
        insert IContact;

        Id acctId = ItoI.Id;
        List<Account> changedAccountList = [SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId];
        Map<Id, Account> oldAccountById = new Map<Id, Account>([SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId]);

        for(Account eachAccount : changedAccountList) {
            eachAccount.RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
            eachAccount.Customer_Type_Code__c = 'I';
        }

        Test.startTest();
        new AccountTriggerHandler().updateContactLookupAccount(changedAccountList, oldAccountById);
        Test.stopTest();

        List<Contact> newIContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE CIS__c = :acctId];
        boolean isI = true;
        for(Contact eachContact : newIContactList){
            if(eachContact.CIS__c == null || eachContact.AccountId == acctId) isI = false;
        }
        System.assertEquals(true, isI);
    }

    // @isTest static void convertOProspectToICustomer_test() {
    //     System.debug('Convert O to I');
    //     Account OtoI = new Account(
    //         Name = 'Prospect O to I',
    //         RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME)
    //     );
    //     insert OtoI;

    //     Contact OContact = new Contact(
    //         FirstName = 'Contact',
    //         LastName = 'O',
    //         AccountId = OtoI.Id,
    //         Phone_Numbers__c = '0810000000',
    //         RecordTypeId = GlobalUtility.getRecordTypeId('Contact', 'SME_Contact')
    //     );
    //     insert OContact;

    //     Id acctId = OtoI.Id;

    //     List<Account> changedAccountList = [SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId];
    //     Map<Id, Account> oldAccountById = new Map<Id, Account>([SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId]);

    //     for(Account eachAccount : changedAccountList) {
    //         eachAccount.RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
    //         eachAccount.Customer_Type_Code__c = 'I';
    //     }

    //     Test.startTest();
    //     new AccountTriggerHandler().updateContactLookupAccount(changedAccountList, oldAccountById);
    //     Test.stopTest();
        
    //     List<Contact> newIContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE CIS__c = :acctId];
        
    //     boolean isI = true;
    //     for(Contact eachContact : newIContactList){
    //         if(eachContact.CIS__c == null || eachContact.AccountId == acctId) isI = false;
    //     }

    //     System.assertEquals(true, isI);
    // }

    // @isTest static void convertIProspectToOCustomer_test() {
    //     Account ItoO = new Account(
    //         Name = 'Prospect I to O',
    //         Temporary_Customer__c = true,
    //         RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME)
    //     );
    //     insert ItoO;
    //     System.debug(ItoO.Id);
    //     Contact IContact = new Contact(
    //         FirstName = 'Contact',
    //         LastName = 'I',
    //         CIS__c = ItoO.Id,
    //         Phone_Numbers__c = '0810000000',
    //         RecordTypeId = GlobalUtility.getRecordTypeId('Contact', 'Individual_Contact')
    //     );
    //     insert IContact;

    //     Id acctId = ItoO.Id;

    //     List<Account> changedAccountList = [SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId];
    //     Map<Id, Account> oldAccountById = new Map<Id, Account>([SELECT Id, Customer_Type_Code__c, PersonContactId FROM Account WHERE Id = :acctId]);

    //     for(Account eachAccount : changedAccountList) {
    //         eachAccount.RecordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
    //         eachAccount.Customer_Type_Code__c = 'O';
    //     }

    //     Test.startTest();
    //     new AccountTriggerHandler().updateContactLookupAccount(changedAccountList, oldAccountById);
    //     Test.stopTest();

    //     List<Contact> newOContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE AccountId = :acctId];
    //     boolean isO = true;
    //     for(Contact eachContact : newOContactList){
    //         if(eachContact.CIS__c == acctId || eachContact.AccountId == null) isO = false;
    //     }
    //     System.assertEquals(true, isO);
    // }
}