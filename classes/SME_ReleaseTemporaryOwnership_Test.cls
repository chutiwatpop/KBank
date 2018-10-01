@isTest
private class SME_ReleaseTemporaryOwnership_Test{
    /* Mock Up */
    public static final String RC_CODE    = '888881';
    public static final String AH_RC_CODE = '888882';
    public static final String NH_RC_CODE = '888883';
    public static final String RC_CODE_2    = '881404';
    public static final String AH_RC_CODE_2 = '881400';
    public static final String NH_RC_CODE_2 = '881201';

    public static final String SME_TM_EMP        = '7000000002';
    public static final String SME_TM_FIRST_NAME = 'SMEFirstName1';
    public static final String SME_TM_LAST_NAME  = 'SMELastName1';

    public static final String SME_RM_EMP        = '7000000001';
    public static final String SME_RM_FIRST_NAME = 'SMEFirstName';
    public static final String SME_RM_LAST_NAME  = 'SMELastName';

    public static final String SME_TM_EMP_2        = '7000000012';
    public static final String SME_TM_FIRST_NAME_2 = 'SMEFirstName2';
    public static final String SME_TM_LAST_NAME_2  = 'SMELastName2';
    
    @testSetup static void setUpTest(){
        Mockup_Test mt = new Mockup_Test().setUpTestOnlyAdmin();
    }
    
    private static Map<String, User> setUpUser() {
        UserTriggerHandler.isByPass = true;
        Map<String, User> userMapByEmpId = new Map<String, User>();
        // Given
        UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
        User SME_TM = UserManagementMockupTest.createNewUser(SME_TM_EMP, SME_TM_FIRST_NAME, SME_TM_LAST_NAME, true, null);
        UserManagementMockupTest.setUserAdditionalInfo(SME_TM, UserManagementMockupTest.JOB_CODE_SME_TM_1, 'RC', RC_CODE);
        SME_TM.Segment__c = 'SE';
        insert SME_TM;

        User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
        UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
        SME_RM.Segment__c = 'SE';
        insert SME_RM;

        UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'SME');
        User SME_TM_2 = UserManagementMockupTest.createNewUser(SME_TM_EMP_2, SME_TM_FIRST_NAME_2, SME_TM_LAST_NAME_2, true, null);
        UserManagementMockupTest.setUserAdditionalInfo(SME_TM_2, UserManagementMockupTest.JOB_CODE_SME_TM_1, 'RC', RC_CODE_2);
        SME_TM_2.Segment__c = 'SE';
        insert SME_TM_2;

        Team_Structure__c branchTeam1 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
        branchTeam1.OwnerId = SME_TM.Id;

        Team_Structure__c branchTeam2 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
        branchTeam2.OwnerId = SME_TM_2.Id;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            update branchTeam1;
            update branchTeam2;

            List<User_Extension__c> userExtensionList = new List<User_Extension__c>();
            User_Extension__c SME_RM_EXT = UserService.createUserExtension(SME_RM, UserManagementMockupTest.mapTeamByRCCode);
            User_Extension__c SME_TM_EXT = UserService.createUserExtension(SME_TM, UserManagementMockupTest.mapTeamByRCCode);
            User_Extension__c SME_TM_2_EXT = UserService.createUserExtension(SME_TM_2, UserManagementMockupTest.mapTeamByRCCode);
            userExtensionList.add(SME_RM_EXT);
            userExtensionList.add(SME_TM_EXT);
            userExtensionList.add(SME_TM_2_EXT);

            upsert userExtensionList External_ID__c;
        }

        userMapByEmpId.put(SME_TM_EMP, SME_TM);
        userMapByEmpId.put(SME_RM_EMP, SME_RM);
        userMapByEmpId.put(SME_TM_EMP_2, SME_TM_2);
        return userMapByEmpId;
    }       

    private static Account createCustomer(String name, String portPool, String recordTypeDevName, String customerSegment) {
        Id recordTypeId = GlobalUtility.getRecordTypeId('Account', recordTypeDevName);
        Account newAccount = new Account(
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId,
            Primary_Segment_Code__c     = customerSegment,
            Customer_Segment_Code__c    = customerSegment,
            Is_createby_Integration__c  = true
        );
        if(recordTypeDevName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME || 
            recordTypeDevName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            newAccount.LastName = name;
        } else if(recordTypeDevName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
            recordTypeDevName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) {
            newAccount.Name = name;
        }

        return newAccount;
    }

    private static Event createEvent(Opportunity targetOpp) {
        return new Event(
            WhatId          = targetOpp.Id,
            OwnerId         = UserInfo.getUserId(),
            Status__c       = GlobalConstants.PLAN,
            StartDateTime   = System.now(),
            EndDateTime     = System.now().addDays(7),
            RecordTypeId    = GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_DEVNAME)
        );
    }

    private static Application_History__c createApplication(Opportunity targetOpp) {
        return new Application_History__c(
            AppNum_NonCMAS__c       = '',
            OppName__c              = targetOpp.Id,
            RMCreditModel__c        = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
            RMSubmitRound__c        = 'ส่งครั้งแรก',
            RMSubmitChannel__c      = GlobalConstants.NON_CMAS,
            TentativeSubmitDate__c  = System.today(),
            RMActualRequestedAmt__c = 100000
        );
    }

    private static OpportunityLineItem createOpportunityProduct(Opportunity targetOpp, Application_History__c application) {
        createProductAndPriceBook();
        PricebookEntry pricebookEntry = [SELECT Id, Name FROM PricebookEntry LIMIT 1];
        return new OpportunityLineItem(
            OpportunityId       = targetOpp.Id,
            PricebookEntryId    = pricebookEntry.Id,
            Application__c      = application.Id,
            Remark__c           = 'before'
        );
    }

    private static void createProductAndPriceBook() {
        List<Product2> productList = new List<Product2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        productList.add(new Product2(Name = 'Deposit', Product_Code__c = 'P001', IsActive = true, Product_Segment__c = 'SME'));
        productList.add(new Product2(Name = 'Account Link', Product_Code__c = 'P002', IsActive = true, Product_Segment__c = 'SME'));
        productList.add(new Product2(Name = 'Inter Account Funds Transfer', Product_Code__c = 'P003', IsActive = true, Product_Segment__c = 'SME'));
        insert productList;
        
        for(Product2 eachProduct : productList) {
            pricebookEntryList.add(new PricebookEntry(
                Product2Id = eachProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1,
                IsActive = true
            ));
        }
        insert pricebookEntryList;
    }

    @isTest static void releaseCustomerNoEvent() {
        //********* GIVEN *********//
        Datetime dateTimeOverLabelLimit = System.today()-300;
        Map<String, User> userMapByEmpId = new Map<String, User>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            userMapByEmpId = setUpUser();
        }
        User SME_RM = userMapByEmpId.get(SME_RM_EMP);
        User SME_TM = userMapByEmpId.get(SME_TM_EMP);
        User_Extension__c SME_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :SME_RM.Id];

        Opportunity targetOpp;
        Account I_CUSTOMER_POOL;
        System.runAs(SME_RM) {
             // New Account
            I_CUSTOMER_POOL = createCustomer('NAME', 'Pool', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            I_CUSTOMER_POOL.SME_Temporary_Customer__c = SME_RM_EXT.Id;
            insert I_CUSTOMER_POOL;
            Test.setCreatedDate(I_CUSTOMER_POOL.Id, dateTimeOverLabelLimit);
        }
        //********* WHEN *********//
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        }
        Test.stopTest();

        //********* THEN *********//
        Account resultAccount = [SELECT Id, SME_Temporary_Customer__c FROM Account WHERE Id = :I_CUSTOMER_POOL.Id];
        System.assertEquals(null, resultAccount.SME_Temporary_Customer__c);
    }

    @isTest static void releaseCustomer() {
        //********* GIVEN *********//
        Datetime dateTimeOverLabelLimit = System.today()-300;
        Map<String, User> userMapByEmpId = new Map<String, User>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            userMapByEmpId = setUpUser();
        }
        User SME_RM = userMapByEmpId.get(SME_RM_EMP);
        User SME_TM = userMapByEmpId.get(SME_TM_EMP);
        User_Extension__c SME_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :SME_RM.Id];

        Opportunity targetOpp;
        Account I_CUSTOMER_POOL;
        System.runAs(SME_RM) {
            // New Account
            I_CUSTOMER_POOL = createCustomer('NAME', 'Pool', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            I_CUSTOMER_POOL.SME_Temporary_Customer__c = SME_RM_EXT.Id;
            insert I_CUSTOMER_POOL;
            Test.setCreatedDate(I_CUSTOMER_POOL.Id, dateTimeOverLabelLimit);
            // New Job
            targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_POOL.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;
            // New Event
            insert createEvent(targetOpp);
        }
        //********* WHEN *********//
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            I_CUSTOMER_POOL.Last_CallReprt_Opty_Updated_Date__c = System.today()-300;
            update I_CUSTOMER_POOL;
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        }
        Test.stopTest();

        //********* THEN *********//
        Account resultAccount = [SELECT Id, SME_Temporary_Customer__c FROM Account WHERE Id = :I_CUSTOMER_POOL.Id];
        System.assertEquals(null, resultAccount.SME_Temporary_Customer__c);
    }

    @isTest static void releaseProspect() {
        //********* GIVEN *********//
        Datetime dateTimeOverLabelLimit = System.today()-300;
        Map<String, User> userMapByEmpId = new Map<String, User>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            userMapByEmpId = setUpUser();
        }
        User SME_RM = userMapByEmpId.get(SME_RM_EMP);
        User SME_TM = userMapByEmpId.get(SME_TM_EMP);
        User_Extension__c SME_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :SME_RM.Id];

        Opportunity targetOpp;
        Account I_CUSTOMER_POOL;
        System.runAs(SME_RM) {
            // New Account
            I_CUSTOMER_POOL = createCustomer('NAME', '', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME, null);
            I_CUSTOMER_POOL.SME_Temporary_Customer__c = SME_RM_EXT.Id;
            insert I_CUSTOMER_POOL;
            Test.setCreatedDate(I_CUSTOMER_POOL.Id, dateTimeOverLabelLimit);
             // New Job
            targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_POOL.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;
            // New Event
            insert createEvent(targetOpp);
        }
        //********* WHEN *********//
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            I_CUSTOMER_POOL.Last_CallReprt_Opty_Updated_Date__c = System.today()-300;
            update I_CUSTOMER_POOL;
        }
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        }
        Test.stopTest();

        //********* THEN *********//
        Account resultAccount = [SELECT Id, SME_Temporary_Customer__c FROM Account WHERE Id = :I_CUSTOMER_POOL.Id];
        System.assertEquals(null, resultAccount.SME_Temporary_Customer__c);
    }

    @isTest static void releaseProspectNoEvent() {
        //********* GIVEN *********//
        Datetime dateTimeOverLabelLimit = System.today()-300;
        Map<String, User> userMapByEmpId = new Map<String, User>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            userMapByEmpId = setUpUser();
        }
        User SME_RM = userMapByEmpId.get(SME_RM_EMP);
        User SME_TM = userMapByEmpId.get(SME_TM_EMP);
        User_Extension__c SME_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :SME_RM.Id];

        Opportunity targetOpp;
        Account I_CUSTOMER_POOL;
        System.runAs(SME_RM) {
            // New Account
            I_CUSTOMER_POOL = createCustomer('NAME', '', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME, null);
            I_CUSTOMER_POOL.SME_Temporary_Customer__c = SME_RM_EXT.Id;
            insert I_CUSTOMER_POOL;
            Test.setCreatedDate(I_CUSTOMER_POOL.Id, dateTimeOverLabelLimit);
        }
        //********* WHEN *********//
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        }
        Test.stopTest();

        //********* THEN *********//
        Account resultAccount = [SELECT Id, SME_Temporary_Customer__c FROM Account WHERE Id = :I_CUSTOMER_POOL.Id];
        System.assertEquals(null, resultAccount.SME_Temporary_Customer__c);
    }

    @isTest static void releaseSpecificOwnerId() {
        //********* GIVEN *********//
        Map<String, User> userMapByEmpId = new Map<String, User>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            userMapByEmpId = setUpUser();
        }
        User SME_RM = userMapByEmpId.get(SME_RM_EMP);
        User SME_TM = userMapByEmpId.get(SME_TM_EMP);
        User_Extension__c SME_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :SME_RM.Id];

        Opportunity targetOpp;
        Account I_CUSTOMER_POOL;
        System.runAs(SME_RM) {
            // New Account
            I_CUSTOMER_POOL = createCustomer('NAME', '', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME, null);
            I_CUSTOMER_POOL.SME_Temporary_Customer__c = SME_RM_EXT.Id;
            insert I_CUSTOMER_POOL;
        }
        //********* WHEN *********//
        Test.startTest();
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch(new Set<Id>{SME_RM.Id}));
        Test.stopTest();
    }
}