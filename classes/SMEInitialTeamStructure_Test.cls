@isTest
private class SMEInitialTeamStructure_Test {
    private static Map<String, Team_Structure__c> mapTeamByRCCode;
    private static Map<String, UserRole> mapRoleByDevName;
    private static Map<String, Profile> mapProfileByName;
    private static final String segment = GlobalConstants.SEGMENT_SE;
    private static final String networkRCCode = '10000', areaRCCode = '10100', teamRCCode = '10101';

    @testSetup
    static void setupMockData() {
        setMapProfileByName();
        setupTeam();
        setupRole();
    }

    private static void setMapProfileByName() {
        mapProfileByName = new Map<String, Profile>();
        List<Profile> listProfile = new List<Profile>();
        listProfile = [SELECT Id,Name FROM Profile];
        for(Profile eachProfile : listProfile) {
            mapProfileByName.put(eachProfile.Name, eachProfile);
        }
    }

    private static User createUser(String firstN, String lastN, Id manager, String empId, String profileN, String roleP, String rcCode) {
        return new User(
            FirstName           = firstN,
            LastName            = lastN,
            ManagerId           = manager,
            Employee_ID__c      = empId,
            IsActive            = true,
            Status__c           = 'A',
            TimeZoneSidKey      = 'Asia/Bangkok',
            LocaleSidKey        = 'th_TH',
            EmailEncodingKey    = 'ISO-8859-1',
            LanguageLocaleKey   = 'en_US',
            Username            = firstN + '@kbankmockup.co.th',
            Email               = firstN + '@kbankmockup.co.th',
            Alias               = firstN.substring(0, 4),
            ProfileId           = mapProfileByName.get(profileN).Id,
            UserRoleId          = mapRoleByDevName.get(roleP + rcCode).Id,
            Segment__c          = mapTeamByRCCode.get(rcCode).Segment__c,
            RC_Code__c          = rcCode,
            AH_RC_Code__c       = mapTeamByRCCode.get(rcCode).AH_RC_Code__c,
            NH_RC_Code__c       = mapTeamByRCCode.get(rcCode).NH_RC_Code__c
        );
    }

    private static void setupTeam() {
        Team_Structure__c network = new Team_Structure__c(
            External_ID__c  = networkRCCode,
            RC_Code__c      = networkRCCode,
            AH_RC_Code__c   = null,
            NH_RC_Code__c   = null,
            Name            = 'Network_' + segment,
            AH_Name__c      = null,
            NH_Name__c      = null,
            Type__c         = 'Network',
            Segment__c      = segment,
            Province__c     = 'กรุงเทพมหานคร'
        );
        insert network;
        mapTeamByRCCode.put(network.RC_Code__c, network);

        Team_Structure__c area = new Team_Structure__c(
            External_ID__c  = areaRCCode,
            RC_Code__c      = areaRCCode,
            AH_RC_Code__c   = null,
            NH_RC_Code__c   = networkRCCode,
            Name            = 'Area' + segment,
            AH_Name__c      = null,
            NH_Name__c      = network.Id,
            Type__c         = 'Area',
            Segment__c      = segment,
            Province__c     = 'กรุงเทพมหานคร'
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
            Province__c     = 'กรุงเทพมหานคร'
        );
        insert team;
        mapTeamByRCCode.put(team.RC_Code__c, team);
    }

    private static void setupRole() {
        UserRole nhRole = new UserRole(
            Name = networkRCCode,
            DeveloperName = 'RC' + networkRCCode
        );
        insert nhRole;
        mapRoleByDevName.put(nhRole.DeveloperName, nhRole);

        UserRole ahRole = new UserRole(
            Name = areaRCCode,
            DeveloperName = 'RC' + areaRCCode,
            ParentRoleId = nhRole.Id
        );
        insert ahRole;
        mapRoleByDevName.put(ahRole.DeveloperName, ahRole);

        UserRole tmRole = new UserRole(
            Name = teamRCCode,
            DeveloperName = 'RC' + teamRCCode,
            ParentRoleId = ahRole.Id
        );
        insert tmRole;
        mapRoleByDevName.put(tmRole.DeveloperName, tmRole);

        UserRole rmRole = new UserRole(
            Name = teamRCCode,
            DeveloperName = 'RCRM' + teamRCCode,
            ParentRoleId = tmRole.Id
        );
        insert rmRole;
        mapRoleByDevName.put(rmRole.DeveloperName, rmRole);
    }

    private static void setupUser() {
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        userAdmin.SME_User_ID__c = UserInfo.getUserId();
        update userAdmin;

        User nhUser = createUser('FirstNameNH', 'LastNameNH', null, '1000000001', GlobalConstants.SME_NH, 'RC', networkRCCode);
        insert nhUser;

        User ahUser = createUser('FirstNameAH', 'LastNameAH', nhUser.Id, '1000000002', GlobalConstants.SME_AH, 'RC', areaRCCode);
        insert ahUser;

        User tmUser = createUser('FirstNameTM', 'LastNameTM', ahUser.Id, '1000000003', GlobalConstants.SME_TM, 'RC', teamRCCode);
        insert tmUser;

        User rmUser = createUser('FirstNameRM', 'LastNameRM', tmUser.Id, '1000000004', GlobalConstants.SME_RM, 'RCRM', teamRCCode);
        insert rmUser;
    }
}