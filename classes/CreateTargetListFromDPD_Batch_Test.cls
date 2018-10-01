@isTest
private class CreateTargetListFromDPD_Batch_Test {
	public static String userRMSE_FirstName = 'userSE_FirstName';
	public static String userRMSE_LastName = 'userSE_LastName';
	public static String userRMSE_EmpId = '9999999991';

	public static String userRMME_FirstName = 'userME_FirstName';
	public static String userRMME_LastName = 'userME_LastName';
	public static String userRMME_EmpId = '9999999992';

	public static String userRMCB_FirstName = 'userCB_FirstName';
	public static String userRMCB_LastName = 'userCB_LastName';
	public static String userRMCB_EmpId = '9999999993';

	public static String userRMMB_FirstName = 'userMB_FirstName';
	public static String userRMMB_LastName = 'userMB_LastName';
	public static String userRMMB_EmpId = '9999999994';

	public static String accountNameRMSE = 'accountNameRMSE';
	public static String accountNameRMME = 'accountNameRMME';
	public static String accountNameRMCB = 'accountNameRMCB';
	public static String accountNameRMMB = 'accountNameRMMB';

	public static String campaignName = 'campaignName';
	
	@testSetup static void setupCampaign_CustomSetting_User_Account(){
        Mockup_Test.setUpCustomSetting();
		Test.startTest();
			List<User> userList = new List<User>();

			Profile rmProfile = [SELECT Id From Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
			User useRMSE = Mockup_Test.newUser(userRMSE_FirstName,userRMSE_LastName,userRMSE_EmpId,true,rmProfile.id,null,null);
			useRMSE.Segment__c = GlobalConstants.SEGMENT_SE;
			userList.add(useRMSE);

			User useRMME = Mockup_Test.newUser(userRMME_FirstName,userRMME_LastName,userRMME_EmpId,true,rmProfile.id,null,null);
			useRMME.Segment__c = GlobalConstants.SEGMENT_ME;
			userList.add(useRMME);

			User useRMCB = Mockup_Test.newUser(userRMCB_FirstName,userRMCB_LastName,userRMCB_EmpId,true,rmProfile.id,null,null);
			useRMCB.Segment__c = GlobalConstants.SEGMENT_CB;
			userList.add(useRMCB);

			User useRMMB = Mockup_Test.newUser(userRMMB_FirstName,userRMMB_LastName,userRMMB_EmpId,true,rmProfile.id,null,null);
			useRMMB.Segment__c = GlobalConstants.SEGMENT_MB;
			userList.add(useRMMB);

			insert userList;

			String recoedTypeIdAccountCustomer = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
			System.runAs(useRMSE){
				Account accountOwnerRMSE = Mockup_Test.newAccountWithSegment(accountNameRMSE,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
				accountOwnerRMSE.Credit_Flag__c  = 'Credit';
				accountOwnerRMSE.CIS__c = '555555555';
				insert accountOwnerRMSE;
			}
			System.runAs(useRMME){
				Account accountOwnerRMME = Mockup_Test.newAccountWithSegment(accountNameRMME,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
				accountOwnerRMME.Credit_Flag__c  = 'Credit';
				accountOwnerRMME.CIS__c = '555555556';
				insert accountOwnerRMME;
			}
			System.runAs(useRMCB){
				Account accountOwnerRMCB = Mockup_Test.newAccountWithSegment(accountNameRMCB,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
				accountOwnerRMCB.Credit_Flag__c  = 'Credit';
				accountOwnerRMCB.CIS__c = '555555557';
				insert accountOwnerRMCB;
			}
			System.runAs(useRMMB){
				Account accountOwnerRMMB = Mockup_Test.newAccountWithSegment(accountNameRMMB,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
				accountOwnerRMMB.Credit_Flag__c  = 'Credit';
				accountOwnerRMMB.CIS__c = '555555558';
				insert accountOwnerRMMB;
			}


			Generate_Lead_DPD__c genLeadDPDCustomSetting = new Generate_Lead_DPD__c(Name='Generate Lead DPD Criteria',Lead_Code__c='DPD',CLS_Reason__c='915;902',CLS_Reason_OD__c='602;501;401;404',Credit__c=true,NonCredit__c=false,SE__c = '15', ME__c = '1' ,CB__c='1',MB__c='1',Cut_Off_Date__c=5);
				insert genLeadDPDCustomSetting;
			Campaign campaign = new Campaign(Lead_Campaign_Event_Code__c = genLeadDPDCustomSetting.Lead_Code__c,Sub_Type__c= GlobalConstants.LEAD_SUB_TYPE_DPD,Type__c = GlobalConstants.LEAD_SUB_TYPE_DPD,Name=campaignName);
				insert campaign;

		Test.stopTest();
	}

	@isTest static void testgenerateTargetList_CalculateMaxDPDAndTotalOutstading() {

			List<LPM_Customer__c> LPMCustomerList = new List<LPM_Customer__c>();
			//Account accountOwnerRMSE = [SELECT Id From Account WHERE Name = :accountNameRMSE LIMIT 1];
			//Account accountOwnerRMME = [SELECT Id From Account WHERE Name = :accountNameRMME LIMIT 1];
			//Account accountOwnerRMCB = [SELECT Id From Account WHERE Name = :accountNameRMCB LIMIT 1];
			//Account accountOwnerRMMB = [SELECT Id From Account WHERE Name = :accountNameRMMB LIMIT 1];
			Account accountOwnerRMSE = Mockup_Test.getFirstAccountFromName(accountNameRMSE, 'Id');
			Account accountOwnerRMME = Mockup_Test.getFirstAccountFromName(accountNameRMME, 'Id');
			Account accountOwnerRMCB = Mockup_Test.getFirstAccountFromName(accountNameRMCB, 'Id');
			Account accountOwnerRMMB = Mockup_Test.getFirstAccountFromName(accountNameRMMB, 'Id');

			LPM__c rmSE_LPM = new LPM__c(Name='LPM-000001',Upload_DPD__c = 16,CLS_Reason__c ='915',Count_Display_DPD__c='No');
				insert rmSE_LPM;
			LPM_Customer__c rmSE_LPMCustomer = new LPM_Customer__c(LPM__c=rmSE_LPM.id,CIS__c=accountOwnerRMSE.id,Primary__c=true);
			LPMCustomerList.add(rmSE_LPMCustomer);

			LPM__c rmME_LPM = new LPM__c(Name='LPM-000002',Upload_DPD__c = 2,CLS_Reason__c ='915',Count_Display_DPD__c='No');
				insert rmME_LPM;
			LPM_Customer__c rmME_LPMCustomer = new LPM_Customer__c(LPM__c=rmME_LPM.id,CIS__c=accountOwnerRMME.id,Primary__c=true);
			LPMCustomerList.add(rmME_LPMCustomer);

			LPM__c rmCB_LPM = new LPM__c(Name='LPM-000003',Upload_DPD__c = 2,CLS_Reason__c ='915',Count_Display_DPD__c='No');
				insert rmCB_LPM;
			LPM_Customer__c rmCB_LPMCustomer = new LPM_Customer__c(LPM__c=rmCB_LPM.id,CIS__c=accountOwnerRMCB.id,Primary__c=true);
			LPMCustomerList.add(rmCB_LPMCustomer);

			LPM__c rmMB_LPM = new LPM__c(Name='LPM-000004',Upload_DPD__c = 2,CLS_Reason__c ='915',Total_Outstanding__c=100,Count_Display_DPD__c='No');
				insert rmMB_LPM;
			LPM_Customer__c rmMB_LPMCustomer = new LPM_Customer__c(LPM__c=rmMB_LPM.id,CIS__c=accountOwnerRMMB.id,Primary__c=true);
			LPMCustomerList.add(rmMB_LPMCustomer);

			LPM__c rmMB_LPM2 = new LPM__c(Name='LPM-000005',Upload_DPD__c = 0,CLS_Reason__c ='100',Total_Outstanding__c=150,TDR_Date__c = System.today(),Count_Display_DPD__c='No');
				insert rmMB_LPM2;
			LPM_Customer__c rmMB_LPMCustomer2 = new LPM_Customer__c(LPM__c=rmMB_LPM2.id,CIS__c=accountOwnerRMMB.id,Primary__c=true);
			LPMCustomerList.add(rmMB_LPMCustomer2);

			insert LPMCustomerList;

		Test.startTest();
			//Database.executeBatch(new LPM_ChunkManagement_Batch(),200);
			Database.executeBatch(new CreateTargetListFromDPD_Batch(),200);
			Database.executeBatch(new AccountLeadInitial_Batch(),200);
		Test.stopTest();
		List<Target_List__c> targetLists = [SELECT Id From Target_List__c];
		System.assertEquals(5,targetLists.size());

		accountOwnerRMMB = [SELECT Id,Max_DPD__c,Total_Outstanding__c From Account WHERE Id = :accountOwnerRMMB.Id LIMIT 1];
		System.assertEquals('2',accountOwnerRMMB.Max_DPD__c);
		System.assertEquals(250,accountOwnerRMMB.Total_Outstanding__c);
	}

	@isTest static void testReactiveExistingTargetListFromLPM(){

		Campaign leadDPD = [SELECT id,Lead_Campaign_Event_Code__c,Sub_Type__c,Type__c From Campaign WHERE Name =:campaignName LIMIT 1];
		//Account accountOwnerRMSE = [SELECT Id From Account WHERE Name = :accountNameRMSE LIMIT 1];
		Account accountOwnerRMSE = Mockup_Test.getFirstAccountFromName(accountNameRMSE, 'Id');
		LPM__c rmSE_LPM = new LPM__c(Name='LPM-000001',Upload_DPD__c = 16,CLS_Reason__c ='915',Count_Display_DPD__c='No');
			insert rmSE_LPM;
		LPM_Customer__c rmSE_LPMCustomer = new LPM_Customer__c(LPM__c=rmSE_LPM.id,CIS__c=accountOwnerRMSE.id,Primary__c=true);
			insert rmSE_LPMCustomer;

		rmSE_LPMCustomer = [SELECT Id,LPM__c,LPM__r.LPM__c,CIS__c From LPM_Customer__c WHERE id = :rmSE_LPMCustomer.id LIMIT 1];
		Target_List__c inactiveTargetList = new Target_List__c(CIS_ID_Prospect_Name__c = accountOwnerRMSE.id,Lead_Campaign__c = leadDPD.id,LPM__c = rmSE_LPM.id);
		Map<Id,Account> accountMapById = new Map<Id,Account>{rmSE_LPMCustomer.CIS__c => new Account(Id = rmSE_LPMCustomer.CIS__c)};
        Map<Id,Campaign> campaignMapById = new Map<Id,Campaign>{leadDPD.id => leadDPD};
        TargetList_Service.generateExternalId(inactiveTargetList,null,campaignMapById,accountMapById, true, rmSE_LPMCustomer);
       
        TriggerHandler.bypass('TargetListTriggerHandler');
			insert inactiveTargetList;
		TriggerHandler.clearbypass('TargetListTriggerHandler');

		Test.startTest();
			Database.executeBatch(new CreateTargetListFromDPD_Batch(),200);
			//Database.executeBatch(new LPM_ChunkManagement_Batch(),200);
		Test.stopTest();

		rmSE_LPM.Upload_DPD__c = 15;
		rmSE_LPM.Note__c = 'testNote';
		update rmSE_LPM;

		rmSE_LPM = [SELECT id,Previous_DPD__c,Upload_DPD__c From LPM__c WHERE LPM__c = 'LPM-000001'];
		System.assertEquals(16,rmSE_LPM.Previous_DPD__c);

		inactiveTargetList = [SELECT Id,Active_Target_List__c From Target_List__c WHERE Id = :inactiveTargetList.id LIMIT 1];
		System.assertNotEquals(null,inactiveTargetList.Active_Target_List__c);
	}

	@isTest static void testNotCreateTargetListFromLPMAndInactiveTargetList(){

		Campaign leadDPD = [SELECT id,Lead_Campaign_Event_Code__c,Sub_Type__c,Type__c From Campaign WHERE Name =:campaignName LIMIT 1];
		//Account accountOwnerRMSE = [SELECT Id From Account WHERE Name = :accountNameRMSE LIMIT 1];
		//Account accountOwnerRMME = [SELECT Id From Account WHERE Name = :accountNameRMME LIMIT 1];
		Account accountOwnerRMSE = Mockup_Test.getFirstAccountFromName(accountNameRMSE, 'Id');
		Account accountOwnerRMME = Mockup_Test.getFirstAccountFromName(accountNameRMME, 'Id');
		
		LPM__c rmSE_LPM = new LPM__c(Name='LPM-000001',Upload_DPD__c = 16,CLS_Reason__c ='915',Count_Display_DPD__c='No');
			insert rmSE_LPM;
		LPM_Customer__c rmSE_LPMCustomer = new LPM_Customer__c(LPM__c=rmSE_LPM.id,CIS__c=accountOwnerRMSE.id,Primary__c=false);
			insert rmSE_LPMCustomer;

		rmSE_LPMCustomer = [SELECT Id,LPM__c,LPM__r.LPM__c,CIS__c From LPM_Customer__c WHERE id = :rmSE_LPMCustomer.id LIMIT 1];
		Target_List__c inactiveTargetList = new Target_List__c(CIS_ID_Prospect_Name__c = accountOwnerRMSE.id,Active_Target_List__c = accountOwnerRMSE.id,Lead_Campaign__c = leadDPD.id,LPM__c = rmSE_LPM.id);
		Map<Id,Account> accountMapById = new Map<Id,Account>{rmSE_LPMCustomer.CIS__c => new Account(Id = rmSE_LPMCustomer.CIS__c)};
        Map<Id,Campaign> campaignMapById = new Map<Id,Campaign>{leadDPD.id => leadDPD};
        TargetList_Service.generateExternalId(inactiveTargetList,null,campaignMapById,accountMapById, true, rmSE_LPMCustomer);
       
        TriggerHandler.bypass('TargetListTriggerHandler');
			insert inactiveTargetList;
		TriggerHandler.clearbypass('TargetListTriggerHandler');

		LPM__c rmME_LPM = new LPM__c(Name='LPM-000002',Upload_DPD__c = 2,CLS_Reason__c ='915',Count_Display_DPD__c='No');
			insert rmME_LPM;
		LPM_Customer__c rmME_LPMCustomer = new LPM_Customer__c(LPM__c=rmME_LPM.id,CIS__c=accountOwnerRMME.id,Primary__c=false);
			insert rmME_LPMCustomer;

		Test.startTest();
			Database.executeBatch(new CreateTargetListFromDPD_Batch(),200);
			//Database.executeBatch(new LPM_ChunkManagement_Batch(),200);
		Test.stopTest();

		List<Target_List__c> targetListOf_accountOwnerRMME = [SELECT Id From Target_List__c WHERE LPM__r.LPM__c = 'LPM-000002'];
		System.assertEquals(true,targetListOf_accountOwnerRMME.isEmpty());
		inactiveTargetList = [SELECT Id,Active_Target_List__c From Target_List__c WHERE id = :inactiveTargetList.id LIMIT 1];
		System.assertEquals(null,inactiveTargetList.Active_Target_List__c);
	}


	
}