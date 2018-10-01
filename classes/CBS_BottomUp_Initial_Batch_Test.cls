@isTest
private class CBS_BottomUp_Initial_Batch_Test {
	public static String accountFirstName1 = 'accountFirstName1';
	//public static String currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
	public static String currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );
	@testSetup static void setupData(){
		Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
         	mt.newAccount(accountFirstName1,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        //updateTeamStructureAndAccountDataForTest();
        Test.stopTest();
        updateTeamStructureAndAccountDataForTest();
   		BottomUp_Notification_Settings__c enableNotification = new BottomUp_Notification_Settings__c(Enable_Notification__c = true);
   		insert enableNotification;

   		Team_Structure__c teamStructure = [SELECT Id,Name,RC_Code__c From Team_Structure__c WHERE Name = :Mockup_Test.tlTeamName Limit 1][0];
   		User nhTL = [SELECT Id,Name,Employee_ID__c,RC_Code__c From User WHERE Firstname = :Mockup_Test.userFirstNameNH Limit 1][0];
		User_Mirror_Management__c userMirrorCustomSetting = new User_Mirror_Management__c(User_Value__c =  nhTL.RC_Code__c,Mirror_Value__c = teamStructure.RC_Code__c, Employee_ID__c = nhTL.Employee_ID__c,Employee_Name__c = nhTL.Name ,Name ='NHTL001',Mirror_Type__c = GlobalConstants.USER_MIRROR_TYPE_RC_CODE);
		insert userMirrorCustomSetting;
	}
	
	@isTest static void testInitialTeamTarget_SaleTarget_BottomUp() {
		Test.startTest();
			Database.executeBatch(new CBS_TeamTarget_Initial_Batch(),200);
		Test.stopTest();

		Team_Structure__c teamStructure = [SELECT Id,Name,RC_Code__c From Team_Structure__c WHERE Name = :Mockup_Test.tlTeamName Limit 1][0];
		User_Extension__c userExtensionRM = [SELECT Id,Employee_ID__c,Segment__c From User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameCBRM Limit 1][0];
		User_Extension__c userExtensionNHTL = [SELECT Id,Employee_ID__c,Segment__c From User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameNH Limit 1][0];
		//Account accountOwnerIsRm = [SELECT Id,CIS__c,Current_Owner_Extension__c From Account WHERE Name = :CBS_BottomUp_Initial_Batch_Test.accountFirstName1 Limit 1][0];
		Account accountOwnerIsRm = Mockup_Test.getFirstAccountFromName(CBS_BottomUp_Initial_Batch_Test.accountFirstName1, 'Id,CIS__c,Current_Owner_Extension__c');
		String teamTargetExternalId = CBS_BottomUp_Initial_Batch_Test.currentYear+'-'+teamStructure.RC_Code__c;
		String saleTargetExternalId = CBS_BottomUp_Initial_Batch_Test.currentYear+'-'+userExtensionRM.Employee_ID__c;
		String bottomupExternalId = CBS_BottomUp_Initial_Batch_Test.currentYear+'-'+accountOwnerIsRm.CIS__c;
		String saleTargetNHTLExternalId = CBS_BottomUp_Initial_Batch_Test.currentYear+'-'+userExtensionNHTL.Employee_ID__c;

		Team_Target__c teamTarget = [SELECT Id,Team_Name__r.Id,Team_Name__r.Name,Year__c,External_ID__c From Team_Target__c WHERE External_ID__c = :teamTargetExternalId Limit 1][0];
		Sales_Target__c saleTarget = [SELECT Id,Name__r.Name,Year__c,Team_Target__r.id,Name__r.id,External_ID__c From Sales_Target__c WHERE External_ID__c = :saleTargetExternalId Limit 1][0];
		Sales_Target__c saleTargetNHTL = [SELECT Id,Name__r.Name,Year__c,Team_Target__r.id,Name__r.id,External_ID__c From Sales_Target__c WHERE External_ID__c = :saleTargetNHTLExternalId Limit 1][0];


		Bottom_Up_Annualized__c bottomUp = [SELECT Id,Sales_Target__c,Year__c,CIS_ID__r.id,External_ID__c From Bottom_Up_Annualized__c WHERE External_ID__c = :bottomupExternalId Limit 1][0];

		System.assertEquals(teamTargetExternalId,teamTarget.External_ID__c);
		System.assertEquals(teamStructure.id,teamTarget.Team_Name__r.Id);

		System.assertEquals(saleTargetExternalId,saleTarget.External_ID__c);
		System.assertEquals(teamTarget.id,saleTarget.Team_Target__r.id);
		System.assertEquals(userExtensionRM.id,saleTarget.Name__r.id);

		System.assertEquals(saleTargetNHTLExternalId,saleTargetNHTL.External_ID__c);
		System.assertEquals(teamTarget.id,saleTarget.Team_Target__r.id);
		System.assertEquals(userExtensionNHTL.id,saleTargetNHTL.Name__r.id);

		System.assertEquals(bottomupExternalId,bottomUp.External_ID__c);
		System.assertEquals(saleTarget.id,bottomUp.Sales_Target__c);
		System.assertEquals(accountOwnerIsRm.id,bottomUp.CIS_ID__r.id);

	}

	private static void updateTeamStructureAndAccountDataForTest(){
		Team_Structure__c teamStructure = [SELECT  Id,Name,Segment__c From Team_Structure__c WHERE Name = :Mockup_Test.tlTeamName Limit 1][0];
		teamStructure.Segment__c = GlobalConstants.SEGMENT_CB;
		update teamStructure;

		User_Extension__c userExtensionRM = [SELECT Id From User_Extension__c WHERE User__r.Firstname = :Mockup_Test.userFirstNameCBRM Limit 1][0];

		//Account account = [SELECT Id,CIS__c,Current_Owner_Extension__c From Account WHERE Name = :CBS_BottomUp_Initial_Batch_Test.accountFirstName1 Limit 1][0];
		Account account = Mockup_Test.getFirstAccountFromName(CBS_BottomUp_Initial_Batch_Test.accountFirstName1, 'Id,CIS__c,Current_Owner_Extension__c');
		account.CIS__c = '000001';
		account.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB;
		account.Current_Owner_Extension__c = userExtensionRM.id;
		update account;

	}
	
	
}