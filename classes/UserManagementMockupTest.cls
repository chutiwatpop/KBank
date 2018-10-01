@isTest
public class UserManagementMockupTest{
    public static final String JOB_CODE_SME_NH_1 = 'ME1A';
    public static final String JOB_CODE_SME_NH_2 = 'SE1A';
    public static final String JOB_CODE_SME_AH_1 = 'ME2A';
    public static final String JOB_CODE_SME_AH_2 = 'SE2A';
    public static final String JOB_CODE_SME_TM_1 = 'ME3A';
    public static final String JOB_CODE_SME_TM_2 = 'SE3A';
    public static final String JOB_CODE_SME_RM_1 = 'ME4A';
    public static final String JOB_CODE_SME_RM_2 = 'ME4B';
    public static final String JOB_CODE_SME_RM_3 = 'SE4A';

    public static final String JOB_CODE_CBS_TL = 'CB1A';
    public static final String JOB_CODE_CBS_TM = 'CB2A';
    public static final String JOB_CODE_CBS_RM = 'CB3A';

    public static final String JOB_CODE_AF_NH = 'AF1A';
    public static final String JOB_CODE_AF_AH = 'AF2B';
    public static final String JOB_CODE_AF_TM = 'AF3B';
    public static final String JOB_CODE_AF_RM_1 = 'AF3C';
    public static final String JOB_CODE_AF_RM_2 = 'AF4A';

    public static final String JOB_CODE_AN_NH = 'AN1A';
    public static final String JOB_CODE_AN_AH = 'AN2A';
    public static final String JOB_CODE_AN_TM = 'AN3A';
    public static final String JOB_CODE_AN_RM = 'AN4A';

    public static final String JOB_CODE_RBS_NH = 'BN1A';
    public static final String JOB_CODE_RBS_AH = 'BN2A';
    public static final String JOB_CODE_RBS_BM = 'BN3A';
    public static final String JOB_CODE_RBS_RM_ABM_1 = 'BN4C';
    public static final String JOB_CODE_RBS_RM_ABM_2 = 'BN4N';
    public static final String JOB_CODE_RBS_RM_BAR_1 = 'BN5I';
    public static final String JOB_CODE_RBS_RM_BAR_2 = 'BN5G';
    public static final String JOB_CODE_RBS_RM_BAR_3 = 'BN5B';
    public static final String JOB_CODE_RBS_RM_BAR_4 = 'BN5A';

    public static Map<String, Team_Structure__c> mapTeamByRCCode;
    public static Map<String, UserRole> mapRoleByDevName;
    public static Map<String, Profile> mapProfileByName;
    public static Map<String, Profile> mapProfileByJobCode;

    public static void init(String networkRCCode, String areaRCCode, String teamRCCode, String segment) {
        createRoleHierachy(networkRCCode, areaRCCode, teamRCCode);
        // Run as to avoid MIXED_DML_OPERATION setup object is not permitted after you have updated a non-setup object (or vice versa)
        System.runAs(new User(Id=UserInfo.getUserId())){
            createTeamHierachy(networkRCCode, areaRCCode, teamRCCode, segment);
            if(mapProfileByJobCode == null) {
                createJobCode();
            }
        }
    }

    public static Profile getMapProfileByName(String profileName) {
        if(mapProfileByName == null) {
            mapProfileByName = new Map<String, Profile>();
            List<Profile> listProfile = new List<Profile>();
            listProfile = [SELECT Id,Name FROM Profile];
            for(Profile eachProfile : listProfile){
                mapProfileByName.put(eachProfile.Name, eachProfile);
            }
        }
        return mapProfileByName.get(profileName);
    }

    public static Profile getProfileByJobCode(String jobCode) {
        if(mapProfileByJobCode == null) {
            createJobCode();
        }
        return mapProfileByJobCode.get(jobCode);
     }

    public static void createJobCode() {
        List<Job_Code__c> newJobCodeList = new List<Job_Code__c>();
        // SME
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_NH_1, Profile_Name__c = GlobalConstants.SME_NH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_NH_2, Profile_Name__c = GlobalConstants.SME_NH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_AH_1, Profile_Name__c = GlobalConstants.SME_AH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_AH_2, Profile_Name__c = GlobalConstants.SME_AH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_TM_1, Profile_Name__c = GlobalConstants.SME_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_TM_2, Profile_Name__c = GlobalConstants.SME_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_RM_1, Profile_Name__c = GlobalConstants.SME_RM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_RM_2, Profile_Name__c = GlobalConstants.SME_RM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_SME_RM_3, Profile_Name__c = GlobalConstants.SME_RM));
        // CBS
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_CBS_TL, Profile_Name__c = GlobalConstants.CBS_TL));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_CBS_TM, Profile_Name__c = GlobalConstants.CBS_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_CBS_RM, Profile_Name__c = GlobalConstants.CBS_RM));
        // AF
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AF_NH, Profile_Name__c = GlobalConstants.AF_NH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AF_AH, Profile_Name__c = GlobalConstants.AF_AH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AF_TM, Profile_Name__c = GlobalConstants.AF_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AF_RM_1, Profile_Name__c = GlobalConstants.AF_RM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AF_RM_2, Profile_Name__c = GlobalConstants.AF_RM));
        // AN
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AN_NH, Profile_Name__c = GlobalConstants.AN_NH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AN_AH, Profile_Name__c = GlobalConstants.AN_AH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AN_TM, Profile_Name__c = GlobalConstants.AN_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_AN_RM, Profile_Name__c = GlobalConstants.AN_RM));
        // RBS
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_NH, Profile_Name__c = GlobalConstants.RBS_NH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_AH, Profile_Name__c = GlobalConstants.RBS_AH));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_BM, Profile_Name__c = GlobalConstants.RBS_TM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_ABM_1, Profile_Name__c = GlobalConstants.RBS_RM_ABM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_ABM_2, Profile_Name__c = GlobalConstants.RBS_RM_ABM));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_BAR_1, Profile_Name__c = GlobalConstants.RBS_RM_BAR));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_BAR_2, Profile_Name__c = GlobalConstants.RBS_RM_BAR));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_BAR_3, Profile_Name__c = GlobalConstants.RBS_RM_BAR));
        newJobCodeList.add(new Job_Code__c(Name = JOB_CODE_RBS_RM_BAR_4, Profile_Name__c = GlobalConstants.RBS_RM_BAR));
        
        insert newJobCodeList;

        mapProfileByJobCode = new Map<String, Profile>();
        for(Job_Code__c eachJobCode : newJobCodeList) {
            if(getMapProfileByName(eachJobCode.Profile_Name__c) != null) {
                mapProfileByJobCode.put(eachJobCode.Name, getMapProfileByName(eachJobCode.Profile_Name__c));
            }
        }
    }

    private static UserRole createNewRole(String name, String devName, String parentId) {
        UserRole newRole = new UserRole(
            Name = name,
            DeveloperName = devName,
            ParentRoleId = parentId
        );
        System.debug('Debug -- newRole'+newRole);
        insert newRole;
        if(mapRoleByDevName == null) {
            mapRoleByDevName = new Map<String, UserRole>();
        }
        mapRoleByDevName.put(newRole.DeveloperName, newRole);
        return newRole;
    }

    private static void createTeamHierachy(String networkRCCode, String areaRCCode, String teamRCCode, String segment) {
        if(mapTeamByRCCode == null) mapTeamByRCCode = new Map<String, Team_Structure__c>();
        Team_Structure__c network = new Team_Structure__c(
            External_ID__c  = networkRCCode,
            RC_Code__c      = networkRCCode,
            AH_RC_Code__c   = null,
            NH_RC_Code__c   = null,
            Name            = networkRCCode + segment,
            AH_Name__c      = null,
            NH_Name__c      = null,
            Type__c         = 'Network',
            Segment__c      = segment
        );
        insert network;
        mapTeamByRCCode.put(network.RC_Code__c, network);

        Team_Structure__c area = new Team_Structure__c(
            External_ID__c  = areaRCCode,
            RC_Code__c      = areaRCCode,
            AH_RC_Code__c   = null,
            NH_RC_Code__c   = networkRCCode,
            Name            = areaRCCode + segment,
            AH_Name__c      = null,
            NH_Name__c      = network.Id,
            Type__c         = 'Area',
            Segment__c      = segment
        );
        insert area;
        mapTeamByRCCode.put(area.RC_Code__c, area);

        Team_Structure__c team = new Team_Structure__c(
            External_ID__c  = teamRCCode,
            RC_Code__c      = teamRCCode,
            AH_RC_Code__c   = areaRCCode,
            NH_RC_Code__c   = networkRCCode,
            Name            = teamRCCode + segment,
            AH_Name__c      = area.Id,
            NH_Name__c      = network.Id,
            Type__c         = 'Team',
            Segment__c      = segment
        );
        insert team;
        mapTeamByRCCode.put(team.RC_Code__c, team);
    }

    public static void createRoleHierachy(String networkRCCode, String areaRCCode, String teamRCCode) {
        UserRole nhRole = createNewRole(networkRCCode, 'RC' + networkRCCode, null);
        UserRole ahRole = createNewRole(areaRCCode, 'RC' + areaRCCode, nhRole.Id);
        UserRole tmRole = createNewRole(teamRCCode, 'RC' + teamRCCode, ahRole.Id);
        UserRole rmRole = createNewRole(teamRCCode, 'RCRM' + teamRCCode, tmRole.Id);
    }
    
    public static User createNewUser(String empId, String first, String last, Boolean active, Id manager) {
        return new User(
            FirstName           = first,
            LastName            = last,
            ManagerId           = manager,
            Employee_ID__c      = empId,
            IsActive            = active,
            Status__c           = (active ? 'A' : 'I'),
            TimeZoneSidKey      = 'Asia/Bangkok',
            LocaleSidKey        = 'th_TH',
            EmailEncodingKey    = 'ISO-8859-1',
            LanguageLocaleKey   = 'en_US',
            Username            = first + '@kbankmockup.co.th',
            Email               = first + '@kbankmockup.co.th',
            Alias               = first.substring(0, 4)
        );
    }

    public static void setUserAdditionalInfo(User newUser, String jobCode, String rolePrefix, String rcCode) {
        Team_Structure__c teamStructure = mapTeamByRCCode.get(rcCode);
        UserRole userRole = mapRoleByDevName.get(rolePrefix + rcCode);
        Profile profile = getProfileByJobCode(jobCode);

        newUser.ProfileId           = profile.Id;
        newUser.UserRoleId          = userRole.Id;
        newUser.Current_Opportunity_Approval__c = newUser.ManagerId;
        newUser.Job_Code__c         = jobCode;
        if(teamStructure != null) {
            newUser.Segment__c          = teamStructure.Segment__c;
            newUser.RC_Code__c          = teamStructure.RC_Code__c;
            newUser.AH_RC_Code__c       = teamStructure.AH_RC_Code__c;
            newUser.NH_RC_Code__c       = teamStructure.NH_RC_Code__c;
        }
    }
}