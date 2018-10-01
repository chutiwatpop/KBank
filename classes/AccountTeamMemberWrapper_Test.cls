@isTest
private class AccountTeamMemberWrapper_Test
{
	public static String USER_SMERM_EMPID = '9999999990' ;

	public static String ACCOUNTOWNER_RM = 'ACCOUNTOWNER_RM';
	public static String ACCOUNTOWNER_RM_CIS = '000000001';
	
	public static String USER_AFRM_EMPID = '99999999993';

	@TestSetup
	public static void setupInfo(){
		List<User> users = new List<User>();
		Profile profile = Mockup_Test.getMapProfileByName(GlobalConstants.SME_RM);
		User userSMERm = Mockup_Test.newUser(USER_SMERM_EMPID,USER_SMERM_EMPID, USER_SMERM_EMPID,true, profile.id, null, null);
    	users.add(userSMERm);

    	profile = Mockup_Test.getMapProfileByName(GlobalConstants.AF_RM);
    	User userAFRm = Mockup_Test.newUser(USER_AFRM_EMPID,USER_AFRM_EMPID, USER_AFRM_EMPID,true, profile.id, null, null);
   		users.add(userAFRm);

   		insert users;

   		Id recordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		Account eachAccount = Mockup_Test.newAccountWithSegment(ACCOUNTOWNER_RM,GlobalConstants.PORT,null,recordTypeId,GlobalConstants.SEGMENT_SE); 
		eachAccount.CIS__c = ACCOUNTOWNER_RM_CIS;
		// When
		System.runAs(userSMERm){
			eachAccount.Dual_RM_Name__c = userAFRm.id;
			insert eachAccount;
		}

	}

	@isTest
	static void creatAccountTeamMemberForDualAF()
	{
		// Given
		User useraf = [SELECT id From User where Employee_Id__c = :USER_AFRM_EMPID Limit 1];
		Account eachAccount = [SELECT Id From Account WHERE CIS__C =:ACCOUNTOWNER_RM_CIS Limit 1];
		// When
			//Account is insert with Dual RM
		// Then
		List<AccountTeamMember> accountTeams = [SELECT Id,TeamMemberRole From AccountTeamMember WHERE UserId = :useraf.id AND AccountId = :eachAccount.id Limit 1];
		System.assertEquals(1,accountTeams.size());
		System.assertEquals(GlobalConstants.NONE,accountTeams[0].TeamMemberRole);
	}

	@isTest  
	static void clearAccountTeamWhenDualRmClear(){
		// Given
		Account eachAccount = [SELECT Id,Dual_RM_Name__c From Account WHERE CIS__C =:ACCOUNTOWNER_RM_CIS Limit 1];
		User useraf = [SELECT id From User where Employee_Id__c = :USER_AFRM_EMPID Limit 1];
		//When
		Test.startTest();
			System.runAs(new User(Id=UserInfo.getUserId())){
				eachAccount.Dual_RM_Name__c = null;
				update eachAccount;
			}
		Test.stopTest();
		//Then
		Integer count = [SELECT count() From AccountTeamMember WHERE UserId = :useraf.id AND AccountId = :eachAccount.id Limit 1];
		System.assertEquals(0,count);
	}
}