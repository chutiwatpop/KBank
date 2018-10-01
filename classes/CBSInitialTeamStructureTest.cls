@isTest
private class CBSInitialTeamStructureTest {
    private static Map<String, Team_Structure__c> mapTeamByRCCode = new Map<String, Team_Structure__c>();
    private static final String segment = GlobalConstants.SEGMENT_CB;
    private static final String teamRCCode = '40101T';

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
        userAdmin.CBS_User_ID__c = adminUser.Id;
        insert userAdmin;
    }

    private static void setupTeam() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        Team_Structure__c team = new Team_Structure__c(
            External_ID__c  = teamRCCode,
            RC_Code__c      = teamRCCode,
            AH_RC_Code__c   = teamRCCode,
            Name            = 'Team' + segment,
            Type__c         = 'Team',
            Segment__c      = segment,
            Province__c     = 'กรุงเทพมหานคร'
        );
        insert team;
        mapTeamByRCCode.put(team.RC_Code__c, team);
        TriggerHandler.clearBypass('TeamStructureTriggerHandler');
    }

    private static void setupRole() {
        UserRole adminRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CBS_Admin'];
        InitialTeamStructureMockupTest.putUserRole(adminRole);
        UserRole tlRole = InitialTeamStructureMockupTest.createUserRole('RC', teamRCCode, null);
        UserRole tmRole = InitialTeamStructureMockupTest.createUserRole('RCTM', teamRCCode, tlRole.Id);
        UserRole rmRole = InitialTeamStructureMockupTest.createUserRole('RCRM', teamRCCode, tmRole.Id);
    }

    private static void setupUser() {
        List<User> userList = new List<User>();
        TriggerHandler.bypass('UserTriggerHandler');
        User admin = InitialTeamStructureMockupTest.createUser('FirstNameAdmin', 'LastNameAdmin', null, '4000000', '021111111', GlobalConstants.CBS_ADMIN, 'CBS_Admin', null);
        insert admin;

        User tlUser = InitialTeamStructureMockupTest.createUser('FirstNameTL', 'LastNameTL', null, '4000001', '022222222', GlobalConstants.CBS_TL, 'RC' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert tlUser;

        User rmUser = InitialTeamStructureMockupTest.createUser('FirstNameRM', 'LastNameRM', tlUser.Id, '4000002', '023333333', GlobalConstants.CBS_RM, 'RCRM' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert rmUser;
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    @isTest
    static void calculateInitialTeamStructure() {
        IInitialTeamStructure initialTeamStructure = new CBSInitialTeamStructure();
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        List<Team_Structure__c> teamList = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c, Province__c, RC_Code__c FROM Team_Structure__c];
        List<User> userList = [SELECT Id, FirstName, Name, Phone, Province__c, RC_Code__c FROM User WHERE FirstName IN ('FirstNameTL', 'FirstNameRM')];
        mapTeamByRCCode.clear();

        for(Team_Structure__c eachTeam : teamList) {
            mapTeamByRCCode.put(eachTeam.RC_Code__c, eachTeam);
        }

        for(User eachUser : userList) {
            if(eachUser.FirstName != 'FirstNameRM') {
                System.assertEquals(eachUser.Id, mapTeamByRCCode.get(eachUser.RC_Code__c).OwnerId);
                System.assertEquals(eachUser.Name, mapTeamByRCCode.get(eachUser.RC_Code__c).Owner_Name__c);
                System.assertEquals(eachUser.Phone, mapTeamByRCCode.get(eachUser.RC_Code__c).Owner_Phone__c);
            }
            System.assertEquals(mapTeamByRCCode.get(eachUser.RC_Code__c).Province__c, eachUser.Province__c);
        }
    }

    @isTest
    static void calcualteWhenUserInactive() {
        User tlUser = [SELECT Id, IsActive, Status__c, RC_Code__c, ManagerId FROM User WHERE FirstName = 'FirstNameTL' LIMIT 1];
        tlUser.IsActive = false;
        tlUser.Status__c = 'I';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update tlUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        IInitialTeamStructure initialTeamStructure = new CBSInitialTeamStructure(tlUser.RC_Code__c);
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();

        Team_Structure__c team = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = :tlUser.RC_Code__c LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameAdmin' LIMIT 1];
        System.assertEquals(adminUser.Id, team.OwnerId);
    }

    @isTest
    static void calcualteWhenTeamNoManager() {
        User tlUser = [SELECT Id, RC_Code__c FROM User WHERE FirstName = 'FirstNameTL' LIMIT 1];
        tlUser.RC_Code__c = '';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update tlUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        IInitialTeamStructure initialTeamStructure = new CBSInitialTeamStructure(teamRCCode);
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        
        Team_Structure__c network = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = :teamRCCode LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameAdmin' LIMIT 1];
        System.assertEquals(adminUser.Id, network.OwnerId);
    }
}