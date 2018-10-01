/**
* @author komsan.wi@beryl8.com
* @16/10/2015 createddate
*/
@isTest
private class UserRoleUtils_Test {
	public static final String USER_EMP_ID_AH = '9999999991';
	public static final String USER_EMP_ID_TM = '9999999992';
	public static final String USER_EMP_ID_RM = '9999999993';

    @isTest static void getRoleUnder(){
    	Map<String, Profile> mapProfileByName = new Map<String, Profile>();
        for(Profile eachProfile : [SELECT Id,Name FROM Profile]){
            mapProfileByName.put(eachProfile.Name, eachProfile);
        }
    	// Given
    	System.runAs(new User(Id=UserInfo.getUserId())){
            UserRole ahRole = new UserRole(Name='AreaAh',DeveloperName=Mockup_Test.ahRoleDeveloperName);
            insert ahRole;

            User ahUser = Mockup_Test.newUser(
                USER_EMP_ID_AH,
                USER_EMP_ID_AH,
                true,
                'FirstNameAh@mail.com',
                'FirstNameAh@mail.com',
                'ahUser',
                mapProfileByName.get(GlobalConstants.SME_AH).Id,
                ahRole.Id,
                null,
                USER_EMP_ID_AH
            );
            insert ahUser;

            UserRole tmRole = new UserRole(Name='AreaTm',DeveloperName=Mockup_Test.tmRoleDeveloperName,ParentRoleId=ahRole.Id);
            insert tmRole;

            User tmUser = Mockup_Test.newUser(
                USER_EMP_ID_TM,
                USER_EMP_ID_TM,
                true,
                'FirstNameTM@mail.com',
                'FirstNameTM@mail.com',
                'tmUser',
                mapProfileByName.get(GlobalConstants.SME_TM).Id,
                tmRole.Id,
                ahUser.Id,
                USER_EMP_ID_TM
            );
            insert tmUser;
            
            UserRole rmRole = new UserRole(Name='AreaRm',DeveloperName=Mockup_Test.rmRoleDeveloperName,ParentRoleId=tmRole.Id);
            insert rmRole;

            User rmUser = Mockup_Test.newUser(
                USER_EMP_ID_RM,
                USER_EMP_ID_RM,
                true,
                'FirstNameRM@mail.com',
                'FirstNameRM@mail.com',
                'rmUser',
                mapProfileByName.get(GlobalConstants.SME_RM).Id,
                rmRole.Id,
                tmUser.Id,
                USER_EMP_ID_RM
            );
            insert rmUser;
        }

        // When
    	User userAH = [SELECT Id FROM User WHERE Firstname=:USER_EMP_ID_AH LIMIT 1];
		System.runAs(userAH){
			// 1
			UserRoleUtils userRole = UserRoleUtils.getInstance();
			// Then
			System.assertEquals(3, userRole.userList.size());

			// 2
			List<Group> groupList = [SELECT Id,RelatedId FROM Group WHERE DeveloperName=:Mockup_Test.ahRoleDeveloperName];
			Set<Id> groupSet = new Set<Id>();
			for(Group eachGroup : groupList){
				groupSet.add(eachGroup.Id);
			}
			// Then
			Set<Id> resultSet = UserRoleUtils.GetUserIdsFromGroup(groupSet);
			System.assertNotEquals(0,resultSet.size());
		}
    }
}