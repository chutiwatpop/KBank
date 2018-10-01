@isTest
private class InitialTeamStructureTest {
    private static Map<String, Team_Structure__c> mapTeamByRCCode = new Map<String, Team_Structure__c>();
    private static final String segment = GlobalConstants.SEGMENT_SE;
    private static final String teamRCCode = '50101T';

    @testSetup
    static void setupMockData() {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            setupTeam();
        }
        setupRole();
        setupUser();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            setupCustomSetting();
        }
    }

    private static void setupCustomSetting() {
        User adminUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameAdmin' LIMIT 1];
        User_Admin__c userAdmin = new User_Admin__c();
        userAdmin.SME_User_ID__c = adminUser.Id;
        insert userAdmin;
    }

    private static void setupTeam() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        Team_Structure__c team = new Team_Structure__c(
            External_ID__c  = teamRCCode,
            RC_Code__c      = teamRCCode,
            Name            = 'Team' + segment,
            Type__c         = 'Team',
            Segment__c      = segment,
            Province__c     = 'สงขลา'
        );
        insert team;
        mapTeamByRCCode.put(team.RC_Code__c, team);
        TriggerHandler.clearBypass('TeamStructureTriggerHandler');
    }

    private static void setupRole() {
        UserRole adminRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'SME_Admin'];
        InitialTeamStructureMockupTest.putUserRole(adminRole);
        UserRole tmRole = InitialTeamStructureMockupTest.createUserRole('RC', teamRCCode, null);
        UserRole rmRole = InitialTeamStructureMockupTest.createUserRole('RCRM', teamRCCode, tmRole.Id);
    }

    private static void setupUser() {
        List<User> userList = new List<User>();
        TriggerHandler.bypass('UserTriggerHandler');
        User admin = InitialTeamStructureMockupTest.createUser('FirstNameAdmin', 'LastNameAdmin', null, '5000000', '', GlobalConstants.SME_ADMIN, 'SME_Admin', null);
        insert admin;

        User tmUser = InitialTeamStructureMockupTest.createUser('FirstNameTM', 'LastNameTM', null, '5000001', '', GlobalConstants.SME_TM, 'RC' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert tmUser;

        User rmUser = InitialTeamStructureMockupTest.createUser('FirstNameRM', 'LastNameRM', tmUser.Id, '5000002', '', GlobalConstants.SME_RM, 'RCRM' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert rmUser;
        TriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    @isTest
    static void executeBatchSuscess() {
        Test.startTest();
        Id batchProcessId = Database.executeBatch(new InitialTeamStructure_Batch(new SMEInitialTeamStructure()));
        Test.stopTest();
        System.assert(batchProcessId != null);
    }
    
    @isTest
    static void executeBatchWithoutArgument() {
        Exception result;
        try {
            Test.startTest();
            Database.executeBatch(new InitialTeamStructure_Batch(null));
            Test.stopTest();
        } catch(Exception e) {
            result = e;
        }
        System.assert(result != null);
    }
}