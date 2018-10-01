@isTest
public class InitialTeamStructureMockupTest {
    private static Map<String, Profile> mapProfileByName = new Map<String, Profile>();
    private static Map<String, UserRole> mapRoleByDevName = new Map<String, UserRole>();

    public static void clearData() {
        mapProfileByName.clear();
        mapRoleByDevName.clear();
    }

    public static Id getProfileIdByName(String profileName) {
        if(mapProfileByName.isEmpty()) {
            List<Profile> listProfile = new List<Profile>();
            listProfile = [SELECT Id,Name FROM Profile];
            for(Profile eachProfile : listProfile) {
                mapProfileByName.put(eachProfile.Name, eachProfile);
            }
        }
        
        Id profileId;
        if(mapProfileByName.containsKey(profileName)) {
            profileId = mapProfileByName.get(profileName).Id;
        }
        return profileId;
    }

    public static User createUser(String first, String last, Id manager, String empId, String phone, String profile, String roleDevName, Team_Structure__c team) {
        User user = new User(
            FirstName           = first,
            LastName            = last,
            ManagerId           = manager,
            Employee_ID__c      = empId,
            Phone               = phone,
            IsActive            = true,
            Status__c           = 'A',
            TimeZoneSidKey      = 'Asia/Bangkok',
            LocaleSidKey        = 'th_TH',
            EmailEncodingKey    = 'ISO-8859-1',
            LanguageLocaleKey   = 'en_US',
            Username            = first + '@kbankmockup.co.th',
            Email               = first + '@kbankmockup.co.th',
            Alias               = first.substring(0, 4),
            ProfileId           = getProfileIdByName(profile),
            UserRoleId          = mapRoleByDevName.get(roleDevName).Id
        );
        if(team != null) {
            user.Segment__c = team.Segment__c;
            user.RC_Code__c = team.RC_Code__c;
            user.AH_RC_Code__c = team.AH_RC_Code__c;
            user.NH_RC_Code__c = team.NH_RC_Code__c;
        }
        return user;
    }

    public static void putUserRole(UserRole userRole) {
        mapRoleByDevName.put(userRole.DeveloperName, userRole);
    }

    public static UserRole createUserRole(String pefix, String rcCode, Id parentRoleId) {
        UserRole userRole = new UserRole(
            Name = rcCode,
            DeveloperName = pefix + rcCode,
            ParentRoleId = parentRoleId
        );
        insert userRole;
        mapRoleByDevName.put(userRole.DeveloperName, userRole);
        return userRole;
    }
}