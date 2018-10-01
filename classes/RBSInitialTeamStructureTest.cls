@isTest
private class RBSInitialTeamStructureTest {
    private static Map<String, Team_Structure__c> mapTeamByRCCode = new Map<String, Team_Structure__c>();
    private static final String segment = GlobalConstants.RBS;
    private static final String networkRCCode = '20000T', areaRCCode = '20100T', teamRCCode = '20101T';

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
        userAdmin.RBS_User_ID__c = adminUser.Id;
        insert userAdmin;
    }

    private static void setupTeam() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        Team_Structure__c network = new Team_Structure__c(
            External_ID__c  = networkRCCode,
            RC_Code__c      = networkRCCode,
            Name            = 'Network' + segment,
            Type__c         = 'Network',
            Segment__c      = segment,
            Province__c     = 'ชลบุรี'
        );
        insert network;
        mapTeamByRCCode.put(network.RC_Code__c, network);

        Team_Structure__c area = new Team_Structure__c(
            External_ID__c  = areaRCCode,
            RC_Code__c      = areaRCCode,
            NH_RC_Code__c   = networkRCCode,
            Name            = 'Area' + segment,
            NH_Name__c      = network.Id,
            Type__c         = 'Area',
            Segment__c      = segment,
            Province__c     = 'ชลบุรี'
        );
        insert area;
        mapTeamByRCCode.put(area.RC_Code__c, area);

        Team_Structure__c team = new Team_Structure__c(
            External_ID__c  = teamRCCode,
            RC_Code__c      = teamRCCode,
            AH_RC_Code__c   = areaRCCode,
            NH_RC_Code__c   = networkRCCode,
            Name            = 'Team' + segment,
            AH_Name__c      = area.Id,
            NH_Name__c      = network.Id,
            Type__c         = 'Team',
            Segment__c      = segment,
            Province__c     = 'ชลบุรี'
        );
        insert team;
        mapTeamByRCCode.put(team.RC_Code__c, team);
        TriggerHandler.clearBypass('TeamStructureTriggerHandler');
    }

    private static void setupRole() {
        UserRole adminRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'RBS_Admin'];
        InitialTeamStructureMockupTest.putUserRole(adminRole);
        UserRole nhRole = InitialTeamStructureMockupTest.createUserRole('RC', networkRCCode, null);
        UserRole ahRole = InitialTeamStructureMockupTest.createUserRole('RC', areaRCCode, nhRole.Id);
        UserRole tmRole = InitialTeamStructureMockupTest.createUserRole('RC', teamRCCode, ahRole.Id);
        UserRole rmRole = InitialTeamStructureMockupTest.createUserRole('RCRM', teamRCCode, tmRole.Id);
    }

    private static void setupUser() {
        List<User> userList = new List<User>();
        TriggerHandler.bypass('UserTriggerHandler');
        User admin = InitialTeamStructureMockupTest.createUser('FirstNameAdmin', 'LastNameAdmin', null, '2000000', '021111111', GlobalConstants.RBS_ADMIN, 'RBS_Admin', null);
        insert admin;

        User nhUser = InitialTeamStructureMockupTest.createUser('FirstNameNH', 'LastNameNH', null, '2000001', '022222222', GlobalConstants.RBS_NH, 'RC' + networkRCCode, mapTeamByRCCode.get(networkRCCode));
        insert nhUser;

        User ahUser = InitialTeamStructureMockupTest.createUser('FirstNameAH', 'LastNameAH', nhUser.Id, '2000002', '023333333', GlobalConstants.RBS_AH, 'RC' + areaRCCode, mapTeamByRCCode.get(areaRCCode));
        insert ahUser;

        User tmUser = InitialTeamStructureMockupTest.createUser('FirstNameTM', 'LastNameTM', ahUser.Id, '2000003', '024444444', GlobalConstants.RBS_TM, 'RC' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert tmUser;

        User rmUser = InitialTeamStructureMockupTest.createUser('FirstNameRM', 'LastNameRM', tmUser.Id, '2000004', '025555555', GlobalConstants.RBS_RM_BAR, 'RCRM' + teamRCCode, mapTeamByRCCode.get(teamRCCode));
        insert rmUser;
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    @isTest
    static void calculateInitialTeamStructure() {
        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure();
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        List<Team_Structure__c> teamList = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c, Province__c, RC_Code__c FROM Team_Structure__c];
        List<User> userList = [SELECT Id, FirstName, Name, Phone, Province__c, RC_Code__c FROM User WHERE FirstName IN ('FirstNameNH', 'FirstNameAH', 'FirstNameTM', 'FirstNameRM')];
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
        User tmUser = [SELECT Id, IsActive, Status__c, RC_Code__c, ManagerId FROM User WHERE FirstName = 'FirstNameTM' LIMIT 1];
        tmUser.IsActive = false;
        tmUser.Status__c = 'I';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update tmUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure(tmUser.RC_Code__c);
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();

        Team_Structure__c team = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c FROM Team_Structure__c WHERE RC_Code__c = :tmUser.RC_Code__c LIMIT 1];
        User user = [SELECT ManagerId, Manager.Name, Manager.Phone FROM User WHERE FirstName = 'FirstNameTM' LIMIT 1];
        System.assertEquals(user.ManagerId, team.OwnerId);
        System.assertEquals(user.Manager.Name, team.Owner_Name__c);
        System.assertEquals(user.Manager.Phone, team.Owner_Phone__c);
    }

    @isTest
    static void calcualteWhenUserAndManagerInactive() {
        User tmUser = [SELECT Id, IsActive, Status__c, RC_Code__c, ManagerId FROM User WHERE FirstName = 'FirstNameTM' LIMIT 1];
        tmUser.IsActive = false;
        tmUser.Status__c = 'I';

        User ahUser = [SELECT Id, IsActive, Status__c, RC_Code__c, ManagerId, Manager.Name, Manager.Phone FROM User WHERE Id = :tmUser.ManagerId];
        ahUser.IsActive = false;
        ahUser.Status__c = 'I';

        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update tmUser;
            update ahUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure(tmUser.RC_Code__c);
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();

        Team_Structure__c team = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c FROM Team_Structure__c WHERE RC_Code__c = :tmUser.RC_Code__c];
        System.assertEquals(ahUser.ManagerId, team.OwnerId);
        System.assertEquals(ahUser.Manager.Name, team.Owner_Name__c);
        System.assertEquals(ahUser.Manager.Phone, team.Owner_Phone__c);
    }

    @isTest
    static void calcualteWhenTeamNoManager() {
        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure(areaRCCode);
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);

        User ahUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameAH' LIMIT 1];
        Team_Structure__c area = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = :areaRCCode LIMIT 1];
        User areaOwner = [SELECT Name, Phone FROM User WHERE Id = :area.OwnerId];
        System.assertEquals(ahUser.Id, area.OwnerId);

        User tmUser = [SELECT Id, RC_Code__c FROM User WHERE FirstName = 'FirstNameTM' LIMIT 1];
        tmUser.RC_Code__c = '';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update tmUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        listTeamStructure.clear();
        initialTeamStructure = new RBSInitialTeamStructure(teamRCCode);
        Test.startTest();
        listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        
        Team_Structure__c team = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c FROM Team_Structure__c WHERE RC_Code__c = :teamRCCode LIMIT 1];
        System.assertEquals(area.OwnerId, team.OwnerId);
        System.assertEquals(areaOwner.Name, team.Owner_Name__c);
        System.assertEquals(areaOwner.Phone, team.Owner_Phone__c);
    }

    @isTest
    static void calcualteWhenAreaNoManager() {
        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure(networkRCCode);
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);

        User nhUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameNH' LIMIT 1];
        Team_Structure__c network = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = :networkRCCode LIMIT 1];
        User networkOwner = [SELECT Name, Phone FROM User WHERE Id = :network.OwnerId];
        System.assertEquals(nhUser.Id, network.OwnerId);

        User ahUser = [SELECT Id, RC_Code__c FROM User WHERE FirstName = 'FirstNameAH' LIMIT 1];
        ahUser.RC_Code__c = '';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update ahUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        listTeamStructure.clear();
        initialTeamStructure = new RBSInitialTeamStructure(areaRCCode);
        Test.startTest();
        listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        
        Team_Structure__c area = [SELECT OwnerId, Owner_Name__c, Owner_Phone__c FROM Team_Structure__c WHERE RC_Code__c = :areaRCCode LIMIT 1];
        System.assertEquals(network.OwnerId, area.OwnerId);
        System.assertEquals(networkOwner.Name, area.Owner_Name__c);
        System.assertEquals(networkOwner.Phone, area.Owner_Phone__c);
    }

    @isTest
    static void calcualteWhenNetworkNoManager() {
        User nhUser = [SELECT Id, RC_Code__c FROM User WHERE FirstName = 'FirstNameNH' LIMIT 1];
        nhUser.RC_Code__c = '';
        System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('UserTriggerHandler');
            update nhUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }

        IInitialTeamStructure initialTeamStructure = new RBSInitialTeamStructure(networkRCCode);
        Test.startTest();
        List<Team_Structure__c> listTeamStructure = Database.query(initialTeamStructure.getQuery());
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
        Test.stopTest();
        
        Team_Structure__c network = [SELECT OwnerId FROM Team_Structure__c WHERE RC_Code__c = :networkRCCode LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE FirstName = 'FirstNameAdmin' LIMIT 1];
        System.assertEquals(adminUser.Id, network.OwnerId);
    }
}