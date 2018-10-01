@isTest
private class ProductUsageVisibility_Test {
    private static String CISPortSME = '0000001';
    private static String CISPoolSME = '0000002';
    private static String CISAdminSME = '0000003';
    private static String CISPortCBS = '0000004';
    private static String CISPortCBS2 = '0000005';
    private static String CISRBS = '0000006';
    private static String CISPortAF = '0000007';
    private static String CISPoolAF = '0000008';
    private static String CISIntegration = '0000009';
    private static String CISUnknown = '0000010';

    @testSetup static void setupMockData() {
        Mockup_Test mt;
	    System.runAs(new User(Id=UserInfo.getUserId())) {
	        mt = new Mockup_Test().setUpTestWithRCCode();
            mt.setUpTestDifferentArea();
            setupUser();
	    }

        User rmCBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        User rmSMEUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User rmDiffSMEUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAhDiff LIMIT 1];
        USer adminSMEUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        USer adminSMEUser2 = [SELECT Id FROM User WHERE Firstname='FirstNameAdmin2' LIMIT 1];
        User rmRBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1];
        User rmAFUser = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1];
        
        Id accountRecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
        
        Test.startTest();
        System.runAs(rmSMEUser) {
            Account accountSMEPort = new Account(
                Firstname = 'accountNameSME',
                Lastname = 'accountNameSME',
                CIS__c = CISPortSME,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
                Secondary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Dual_RM_Name__c = rmAFUser.Id,
                Port_Pool_Dual_RM__c = GlobalConstants.PORT,
                Is_createby_Integration__c = true
            );
            Account accountSMEPool = new Account(
                Firstname = 'accountNameSME2',
                Lastname = 'accountNameSME2',
                CIS__c = CISPoolSME,
                Port_Pool__c = GlobalConstants.POOL,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM,
                Service_RM__c = rmSMEUser2.Id,
                Secondary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MI,
                Dual_RM_Name__c = rmRBSUser.Id,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountSMEPort;
            insert accountSMEPool;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            AccountTeamMember accTeamPort = new AccountTeamMember(
                AccountId = accountSMEPort.Id,
                UserId = rmDiffSMEUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert accTeamPort;

            Opportunity oppPort = new Opportunity(
                AccountId = accountSMEPort.Id,
                Name = 'oppNameSME',
                StageName = 'Open',
                Amount = 10,
                CloseDate = System.today() + 7
            );
            TriggerHandler.bypass('OpportunityTriggerHandler');
            insert oppPort;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            OpportunityTeamMember oppTeamPort = new OpportunityTeamMember(
                OpportunityId = oppPort.Id,
                UserId = rmSMEUser2.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeamPort;
        }
        System.runAs(adminSMEUser) {
            Account accountSMEAdmin = new Account(
                Firstname = 'accountNameSME3',
                Lastname = 'accountNameSME3',
                CIS__c = CISAdminSME,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_UM,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_UM,
                Dual_RM_Name__c = rmRBSUser.Id,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountSMEAdmin;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            System.runAs(adminSMEUser2) {
                AccountTeamMember accTeam2 = new AccountTeamMember(
                    AccountId = accountSMEAdmin.Id,
                    UserId = rmDiffSMEUser.Id,
                    AccountAccessLevel = 'Edit'
                );
                insert accTeam2;

                Opportunity opp = new Opportunity(
                    AccountId = accountSMEAdmin.Id,
                    Name = 'oppNameSME2',
                    StageName = 'Open',
                    Amount = 10,
                    CloseDate = System.today() + 7
                );
                TriggerHandler.bypass('OpportunityTriggerHandler');
                insert opp;
                TriggerHandler.clearbypass('OpportunityTriggerHandler');
                OpportunityTeamMember oppTeam = new OpportunityTeamMember(
                    OpportunityId = opp.Id,
                    UserId = rmSMEUser2.Id,
                    OpportunityAccessLevel = 'Edit'
                );
                insert oppTeam;
            }
        }

        System.runAs(rmCBSUser) {
            Account accountCBSPort = new Account(
                Firstname = 'accountNameCBS',
                Lastname = 'accountNameCBS',
                CIS__c = CISPortCBS,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB,
                Secondary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Dual_RM_Name__c = rmAFUser.Id,
                Port_Pool_Dual_RM__c = GlobalConstants.POOL,
                Is_createby_Integration__c = true
            );
            Account accountCBSPort2 = new Account(
                Firstname = 'accountNameCBS2',
                Lastname = 'accountNameCBS2',
                CIS__c = CISPortCBS2,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MB,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MB,
                Secondary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MI,
                Dual_RM_Name__c = rmRBSUser.Id,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountCBSPort;
            insert accountCBSPort2;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            AccountTeamMember accTeam = new AccountTeamMember(
                AccountId = accountCBSPort.Id,
                UserId = rmSMEUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert accTeam;
        }

        System.runAs(rmRBSUser) {
            Account accountRBS = new Account(
                Firstname = 'accountNameRBS',
                Lastname = 'accountNameRBS',
                CIS__c = CISRBS,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MI,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_MI,
                Is_createby_Integration__c = true
            );
            Account accountUnknown = new Account(
                Firstname = 'accountNameUnknown',
                Lastname = 'accountNameUnknown',
                CIS__c = CISUnknown,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = 'A1',
                Customer_Segment_Code__c = 'A1',
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountRBS;
            insert accountUnknown;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            AccountTeamMember accTeam = new AccountTeamMember(
                AccountId = accountRBS.Id,
                UserId = rmSMEUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert accTeam;

            Opportunity opp = new Opportunity(
                AccountId = accountRBS.Id,
                Name = 'oppNameRBS',
                StageName = 'Open',
                Amount = 10,
                CloseDate = System.today() + 7
            );
            TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            OpportunityTeamMember oppTeam = new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = rmSMEUser2.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeam;
        }

        System.runAs(rmAFUser) {
            Account accountAFPort = new Account(
                Firstname = 'accountNameAF',
                Lastname = 'accountNameAF',
                CIS__c = CISPortAF,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Is_createby_Integration__c = true
            );
            Account accountAFPool = new Account(
                Firstname = 'accountNameAF2',
                Lastname = 'accountNameAF2',
                CIS__c = CISPoolAF,
                Port_Pool__c = GlobalConstants.POOL,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_PC,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountAFPort;
            insert accountAFPool;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            AccountTeamMember accTeam = new AccountTeamMember(
                AccountId = accountAFPort.Id,
                UserId = rmSMEUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert accTeam;

            Opportunity opp = new Opportunity(
                AccountId = accountAFPort.Id,
                Name = 'oppNameAF',
                StageName = 'Open',
                Amount = 10,
                CloseDate = System.today() + 7
            );
            TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            OpportunityTeamMember oppTeam = new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = rmSMEUser2.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeam;
        }

        System.runAs(new User(Id=UserInfo.getUserId())) {
            Account accountAdmin = new Account(
                Firstname = 'accountNameIntegration',
                Lastname = 'accountNameIntegration',
                CIS__c = CISIntegration,
                RecordTypeId = accountRecordTypeId,
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_RO,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_RO,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountAdmin;
            TriggerHandler.clearbypass('AccountTriggerHandler');

            AccountTeamMember accTeam = new AccountTeamMember(
                AccountId = accountAdmin.Id,
                UserId = rmSMEUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert accTeam;

            Opportunity opp = new Opportunity(
                AccountId = accountAdmin.Id,
                Name = 'oppNameAdmin',
                StageName = 'Open',
                Amount = 10,
                OwnerId = rmSMEUser2.Id,
                CloseDate = System.today() + 7
            );
            TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            OpportunityTeamMember oppTeam = new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = rmRBSUser.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeam;
        }
        Test.stopTest();
    }

    private static void setupUser() {
        List<User> listUser = new List<User>();

        String rmSMERoleDevname = 'RCRM' + Mockup_Test.RC_CODE;
        UserRole rmSMERole = [SELECT Id FROM UserRole WHERE DeveloperName = :rmSMERoleDevname LIMIT 1];
        User rmSMEUser = [SELECT Id, ProfileId, UserRoleId, ManagerId, Job_Code__c, AH_RC_Code__c, NH_RC_Code__c, RC_Code__c, Status__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User rmSMEUser2 = Mockup_Test.newUser(
            Mockup_Test.userFirstNameRM2,
            Mockup_Test.userLastNameRM2,
            true,
            Mockup_Test.userFirstNameRM2+'@mail.com',
            Mockup_Test.userFirstNameRM2+'@mail.com',
            Mockup_Test.userFirstNameRM2.substring(0, 4),
            rmSMEUser.ProfileId,
            rmSMEUser.UserRoleId,
            rmSMEUser.ManagerId,
            Mockup_Test.userEmpIdRM2
        );
        rmSMEUser2.Job_Code__c = rmSMEUser.Job_Code__c;
        rmSMEUser2.AH_RC_Code__c = rmSMEUser.AH_RC_Code__c;
        rmSMEUser2.NH_RC_Code__c = rmSMEUser.NH_RC_Code__c;
        rmSMEUser2.RC_Code__c = rmSMEUser.RC_Code__c;
        rmSMEUser2.Status__c = rmSMEUser.Status__c;
        listUser.add(rmSMEUser2);

        User rmSMEUser3 = Mockup_Test.newUser(
            'FirstNameRM3',
            'LastNameRM3',
            true,
            'FirstNameRM3@mail.com',
            'FirstNameR3@mail.com',
            'rmsme3',
            rmSMEUser.ProfileId,
            rmSMEUser.UserRoleId,
            null,
            '1100000003'
        );
        rmSMEUser3.AH_RC_Code__c = '41410';
        rmSMEUser3.NH_RC_Code__c = rmSMEUser.NH_RC_Code__c;
        rmSMEUser3.RC_Code__c = '41407';
        listUser.add(rmSMEUser3);

        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin' LIMIT 1];
        User adminSMEUser2 = Mockup_Test.newUser(
            'FirstNameAdmin2',
            'LastNameAdmin2',
            true,
            'FirstNameAdmin2@mail.com',
            'FirstNameAdmin2@mail.com',
            'admin2',
            Mockup_Test.getMapProfileByName(GlobalConstants.SME_ADMIN).Id,
            adminRole.Id,
            null,
            '1100000002'
        );
        listUser.add(adminSMEUser2);

        String rmCBRoleDevname = 'RCCBRM' + Mockup_Test.RC_CODE;
        UserRole rmCBRole = [SELECT Id FROM UserRole WHERE DeveloperName = :rmCBRoleDevname LIMIT 1];
        User rmCBSUser2 = Mockup_Test.newUser(
            Mockup_Test.userFirstNameCBRM2,
            Mockup_Test.userLastNameCBRM2,
            true,
            Mockup_Test.userFirstNameCBRM2+'@mail.com',
            Mockup_Test.userFirstNameCBRM2+'@mail.com',
            Mockup_Test.userFirstNameCBRM2.substring(0, 4),
            Mockup_Test.getMapProfileByName(GlobalConstants.CBS_RM).Id,
            rmCBRole.Id,
            null,
            '1100000001'
        );
        listUser.add(rmCBSUser2);
            
        User rmAFUser = Mockup_Test.newUser(
            'FirstAFNameRM',
            'LastAFNameRM',
            true,
            'FirstAFNameRM@mail.com',
            'FirstAFNameRM@mail.com',
            'AFRM',
            Mockup_Test.getMapProfileByName('AF-RM').Id,
            rmSMERole.Id,
            null,
            '1100000004'
        );
        rmAFUser.RC_Code__c = '41501';
        listUser.add(rmAFUser);

        User rmAFUser2 = Mockup_Test.newUser(
            'FirstAFNameRM2',
            'LastAFNameRM2',
            true,
            'FirstAFNameRM2@mail.com',
            'FirstAFNameRM2@mail.com',
            'AFRM2',
            Mockup_Test.getMapProfileByName('AF-RM').Id,
            rmSMERole.Id,
            null,
            '1100000005'
        );
        rmAFUser2.RC_Code__c = '41501';
        listUser.add(rmAFUser2);

        User rmRBSUser = Mockup_Test.newUser(
            Mockup_Test.userRbsFirstNameRM,
            Mockup_Test.userRbsLastNameRM,
            true,
            Mockup_Test.userRbsFirstNameRM +'@mail.com',
            Mockup_Test.userRbsFirstNameRM +'@mail.com',
            Mockup_Test.userRbsFirstNameRM.substring(0, 4),
            Mockup_Test.getMapProfileByName(GlobalConstants.RBS_RM_BAR).Id,
            rmSMERole.Id,
            null,
            '1100000006'
        );
        rmRBSUser.RC_Code__c = '41601';
        listUser.add(rmRBSUser);

        User rmRBSUser2 = Mockup_Test.newUser(
            Mockup_Test.userRbsFirstNameRM2,
            Mockup_Test.userRbsLastNameRM2,
            true,
            Mockup_Test.userRbsFirstNameRM2 +'@mail.com',
            Mockup_Test.userRbsFirstNameRM2 +'@mail.com',
            Mockup_Test.userRbsFirstNameRM2.substring(0, 4),
            Mockup_Test.getMapProfileByName(GlobalConstants.RBS_RM_BAR).Id,
            rmSMERole.Id,
            null,
            '1100000007'
        );
        rmRBSUser2.RC_Code__c = '41601';
        listUser.add(rmRBSUser2);

        User rmRBSUser3 = Mockup_Test.newUser(
            'FirstRbsNameRM3',
            'LastRbsNameRM3',
            true,
            'FirstRbsNameRM3@mail.com',
            'FirstRbsNameRM3@mail.com',
            'RBSRM3',
            Mockup_Test.getMapProfileByName(GlobalConstants.RBS_RM_BAR).Id,
            rmSMERole.Id,
            null,
            '1100000008'
        );
        listUser.add(rmRBSUser3);
        insert listUser;
    }

    private static ProductUsageVisibilityService getService(Account currentAccount) {
        return new ProductUsageVisibilityService(currentAccount.Id);
    }

    static testMethod void testOwnerUserSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testDualAFUserSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        User user = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAhDiff LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }
    
    static testMethod void testRBSUserSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserSMEPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortSME];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin' LIMIT 1];
        User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User rmAFUser = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1];
        rmSMEUser2.UserRoleId = adminRole.Id;
        update rmSMEUser2;
        System.runAs(rmSMEUser2) {
            insert new AccountTeamMember(
                AccountId = account.Id,
                UserId = rmAFUser.Id,
                AccountAccessLevel = 'Edit'
            );
        }
        System.runAs(rmAFUser) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User rmAFUser = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1];
        Opportunity oppPool = new Opportunity(
            AccountId = account.Id,
            Name = 'oppNameSME3',
            StageName = 'Open',
            Amount = 10,
            CloseDate = System.today() + 7,
            OwnerId = rmSMEUser2.Id
        );
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppPool;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');
        System.runAs(rmSMEUser2) {
            OpportunityTeamMember oppTeamPool = new OpportunityTeamMember(
                OpportunityId = oppPool.Id,
                UserId = rmAFUser.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeamPool;
        }
        System.runAs(rmAFUser) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testTeamUserSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        User user = [SELECT Id FROM User WHERE Firstname='FirstNameRM3' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testServiceRMUserSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testDualRBSUserSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserSMEPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolSME];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        System.runAs(user) {
            insert new AccountTeamMember(
                AccountId = account.Id,
                UserId = user.Id,
                AccountAccessLevel = 'Edit'
            );
        }
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testOtherSegmentUserSMEAdminAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISAdminSME];
        User user = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamSMEAdminAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISAdminSME];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAhDiff LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamSMEAdminAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISAdminSME];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserSMEAdminAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISAdminSME];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testOwnerUserCBSPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortCBS];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testDualAFUserCBSPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortCBS];
        User user = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM2' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testDualRBSUserCBSPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortCBS2];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamCBSPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortCBS];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOwnerOpportunityCBSPortAccount() {
        Account account = [SELECT Id, Secondary_Segment_Code__c FROM Account WHERE CIS__c = :CISPortCBS2];
        account.Secondary_Segment_Code__c = '';
        update account;
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM2 LIMIT 1];
        Opportunity opp = new Opportunity(
            AccountId = account.Id,
            Name = 'oppNameCBS',
            StageName = 'Open',
            Amount = 10,
            OwnerId = user.Id,
            CloseDate = System.today() + 7
        );
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserCBSPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortCBS];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testOwnerUserRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testTeamUserRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM2 LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherRBSUserRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        User user = [SELECT Id FROM User WHERE Firstname='FirstRbsNameRM3' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserRBSAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISRBS];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testOwnerUserAFPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortAF];
        System.runAs([SELECT Id FROM User WHERE Firstname='FirstAFNameRM' LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamAFPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortAF];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamAFPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortAF];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserAFPortAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPortAF];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamAFPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolAF];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin' LIMIT 1];
        User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User rmAFUser2 = [SELECT Id, UserRoleId FROM User WHERE Firstname='FirstAFNameRM2' LIMIT 1];
        rmAFUser2.UserRoleId = adminRole.Id;
        update rmAFUser2;
        System.runAs(rmAFUser2) {
            insert new AccountTeamMember(
                AccountId = account.Id,
                UserId = rmSMEUser2.Id,
                AccountAccessLevel = 'Edit'
            );
        }
        System.runAs(rmSMEUser2) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamAFPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolAF];
        User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User rmAFUser2 = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM2' LIMIT 1];
        Opportunity oppPool = new Opportunity(
            AccountId = account.Id,
            Name = 'oppNameAF2',
            StageName = 'Open',
            Amount = 10,
            CloseDate = System.today() + 7,
            OwnerId = rmAFUser2.Id
        );
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppPool;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');
        System.runAs(rmAFUser2) {
            OpportunityTeamMember oppTeamPool = new OpportunityTeamMember(
                OpportunityId = oppPool.Id,
                UserId = rmSMEUser2.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert oppTeamPool;
        }
        System.runAs(rmSMEUser2) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testTeamUserAFPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolAF];
        User user = [SELECT Id FROM User WHERE Firstname='FirstAFNameRM2' LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testRBSUserAFPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolAF];
        User user = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1];
        insert new AccountTeamMember(
            AccountId = account.Id,
            UserId = user.Id,
            AccountAccessLevel = 'Edit'
        );
        System.runAs(user) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserAFPoolAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISPoolAF];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testAccountTeamIntegrationAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISIntegration];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOpportunityTeamIntegrationAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISIntegration];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOwnerOpportunityIntegrationAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISIntegration];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1][0]) {
            System.assert(getService(account).isVisible());
        }
    }

    static testMethod void testOtherUserIntegrationAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISIntegration];
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testHNAccount() {
        Account account = [SELECT Id, CIS__c, Primary_Segment_Code__c FROM Account WHERE CIS__c = :CISPortSME];
        account.Primary_Segment_Code__c = 'HN';
        TriggerHandler.bypass('AccountTriggerHandler');
        update account;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }

    static testMethod void testNotHaveAccount() {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            System.assertEquals(false, new ProductUsageVisibilityService(null).isVisible());
        }
    }

    static testMethod void testUnknownAccount() {
        Account account = [SELECT Id, CIS__c FROM Account WHERE CIS__c = :CISUnknown];
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userRbsFirstNameRM LIMIT 1][0]) {
            System.assertEquals(false, getService(account).isVisible());
        }
    }
}