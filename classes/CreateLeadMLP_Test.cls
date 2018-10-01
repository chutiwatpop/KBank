@isTest
private class CreateLeadMLP_Test
{	
	private static final String accountNameRM = 'accountNameRM';
	private static final String productCode1 = 'SME_Loan';
	private static final String productCode2 = 'CC';
	private static final String cisNumber1 = '1234567890';
	private static final String cisNumber2 = '0123456789';
	private static final String lastName1 = 'testLastName';
	private static final String lastName2 = 'testLastName2';
	@testSetup static void setupAccount(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCodeOnlySme();
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c,ProfileId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		}

		System.runAs(new User(Id=UserInfo.getUserId())){
			User tmUser = [SELECT Id,ProfileId FROM User WHERE Firstname = :Mockup_Test.userFirstNameTM];
			User ahUser = [SELECT Id,ProfileId FROM User WHERE Firstname = :Mockup_Test.userFirstNameAH];
			tmUser.ProfileId = Mockup_Test.getMapProfileByName('Telesales - TM').Id;
			ahUser.ProfileId = Mockup_Test.getMapProfileByName('Telesales - TM').Id;
			List<User> listUser = new List<User>{tmUser,ahUser};
			update listUser;
		}
		Test.stopTest();
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		account.CIS__c = cisNumber1;
		update account;
		List<Campaign> teleSaleCampaignList = new List<Campaign>();
		Campaign campaignMobile = Mockup_Test.newCampaign(UserInfo.getUserId(), Label.Lead_MLP_Code, System.now().addDays(1), System.now().addDays(2), System.now(), GlobalConstants.PLANNED, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_TO_INFORM);
        Campaign campaignWebsite = Mockup_Test.newCampaign(UserInfo.getUserId(), Label.Lead_Online_from_Website_Code, System.now().addDays(1), System.now().addDays(2), System.now(), GlobalConstants.PLANNED, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_TO_INFORM);
        
        teleSaleCampaignList.add(campaignMobile);
        teleSaleCampaignList.add(campaignWebsite);
        insert teleSaleCampaignList;


		List<MLP_Owner__c> mlpOwnerList = new List<MLP_Owner__c>();
		MLP_Owner__c owner1 = new MLP_Owner__c();
		MLP_Owner__c owner2 = new MLP_Owner__c();
		owner1.Name = Mockup_Test.userEmpIdAH;
		owner2.Name = Mockup_Test.userEmpIdTM;
		mlpOwnerList.add(owner1);
		mlpOwnerList.add(owner2);
		insert mlpOwnerList;

		List<Telesales_Product_Name_to_Field_Mapping__c> listCustomSetting = new List<Telesales_Product_Name_to_Field_Mapping__c>();
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KEC',Field_API_Name__c= 'KEC__c',Display_Product_Name_As__c = 'KEC'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KPL',Field_API_Name__c= 'KPL__c',Display_Product_Name_As__c = 'KPL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL',Field_API_Name__c= 'HL__c',Display_Product_Name_As__c = 'HL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Refinance',Field_API_Name__c= 'HL_Refinance__c',Display_Product_Name_As__c = 'HL_Refinance'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Equity',Field_API_Name__c= 'HL_Help__c',Display_Product_Name_As__c = 'HL_ช่วยได้'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KCar',Field_API_Name__c= 'KCar__c',Display_Product_Name_As__c = 'KCar'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KL',Field_API_Name__c= 'KL__c',Display_Product_Name_As__c = 'KL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'SME_Loan',Field_API_Name__c= 'SME_Loan__c',Display_Product_Name_As__c = 'SME Loan'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'CC',Field_API_Name__c= 'CC__c',Display_Product_Name_As__c = 'CC'));
		insert listCustomSetting;
	}


	@isTest
	static void createNewLeadToExistLeadOwner()
	{	
		User tmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		Date yesterday = Date.today().addDays(-1);
        String prefixDate =  yesterday.day()+''+ yesterday.month()+''+yesterday.year();
        Id recordTypeLeadMLP = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Lead',GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
        Lead existLead = new Lead();
        existLead.RecordTypeId = recordTypeLeadMLP;
        existLead.Salutation = 'คุณ';
        existLead.Status = 'Opened';
        existLead.LastName = lastName1;
        existLead.Group_Name_Telesales__c = 'MLP'; 
        existLead.Lead_MLP_Reference_Mapping__c = '{"KPL":"SLAS1600111576039_20180629"}';
        existLead.MLP_ExternalKey__c = cisNumber1+'_'+prefixDate;
        existLead.OwnerId = tmUser.Id;
        existLead.Customer__c = account.Id;
        existLead.Latest_Lead__c = true;
        insert existLead;

		List<Lead_MLP__c> mlpList = new List<Lead_MLP__c>();
		Lead_MLP__c recordMLP = new Lead_MLP__c();
		recordMLP.PERSZ_MSG__c = productCode1;
		recordMLP.IP_ID__c = cisNumber1;
		recordMLP.REL_ST__c = 'New';
		recordMLP.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP.REFR_ID__c = 'SLAS1600712824072_20180629';
		recordMLP.IDENT_NO__c = '12301234567890';

		Lead_MLP__c recordMLP2 = new Lead_MLP__c();
		recordMLP2.PERSZ_MSG__c = productCode2;
		recordMLP2.IP_ID__c = cisNumber1;
		recordMLP2.REL_ST__c = 'New';
		recordMLP2.IDENT_NO__c = '01234567890123';
		recordMLP2.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP2.REFR_ID__c = 'SLAS1600712824071_20180629';
		mlpList.add(recordMLP);
		mlpList.add(recordMLP2);

		insert(mlpList);

		Test.startTest();
		Database.executeBatch(new CreateLeadMLP_Batch());
		Test.stopTest();
		List<CampaignMember> campaignMemberList = [SELECT Id FROM CampaignMember ];
		List<Lead> leadList = [SELECT Id FROM Lead ];
		System.assertEquals(2,leadList.size());
		System.assertEquals(1,campaignMemberList.size());
		
	}

	@isTest
	static void createNewLeadToExistingAccount(){
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		Date yesterday = Date.today().addDays(-1);
        String prefixDate =  yesterday.day()+''+ yesterday.month()+''+yesterday.year();
        Id recordTypeLeadMLP = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Lead',GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
    
		List<Lead_MLP__c> mlpList = new List<Lead_MLP__c>();
		Lead_MLP__c recordMLP = new Lead_MLP__c();
		recordMLP.PERSZ_MSG__c = productCode1;
		recordMLP.IP_ID__c = cisNumber1;
		recordMLP.REL_ST__c = 'New';
		recordMLP.IDENT_NO__c = '12301234567890';
		recordMLP.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP.REFR_ID__c = 'SLAS1600712824072_20180629';

		Lead_MLP__c recordMLP2 = new Lead_MLP__c();
		recordMLP2.PERSZ_MSG__c = productCode2;
		recordMLP2.IP_ID__c = cisNumber1;
		recordMLP2.REL_ST__c = 'New';
		recordMLP2.IDENT_NO__c = '01234567890123';
		recordMLP2.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP2.REFR_ID__c = 'SLAS1600712824071_20180629';
		mlpList.add(recordMLP);
		mlpList.add(recordMLP2);

		insert(mlpList);

		Test.startTest();
		CreateLeadMLP_Batch batchCreateLeadMLP = new CreateLeadMLP_Batch();
		batchCreateLeadMLP.isManual = true;
		Database.executeBatch(batchCreateLeadMLP);
		Test.stopTest();
		List<CampaignMember> campaignMemberList = [SELECT Id FROM CampaignMember ];
		List<Lead> leadList = [SELECT Id FROM Lead ];
		System.assertEquals(1,leadList.size());
		System.assertEquals(1,campaignMemberList.size());
		
	}

	@isTest
	static void createNewLeadToProspect(){
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		Date yesterday = Date.today().addDays(-1);
        String prefixDate =  yesterday.day()+''+ yesterday.month()+''+yesterday.year();
        Id recordTypeLeadMLP = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Lead',GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
    
		List<Lead_MLP__c> mlpList = new List<Lead_MLP__c>();
		Lead_MLP__c recordMLP = new Lead_MLP__c();
		recordMLP.PERSZ_MSG__c = productCode1;
		recordMLP.IP_ID__c = cisNumber2;
		recordMLP.REL_ST__c = 'New';
		recordMLP.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP.REFR_ID__c = 'SLAS1600712824072_20180629';
		recordMLP.IDENT_NO__c = '12301234567890';

		Lead_MLP__c recordMLP2 = new Lead_MLP__c();
		recordMLP2.PERSZ_MSG__c = productCode2;
		recordMLP2.IP_ID__c = cisNumber2;
		recordMLP2.REL_ST__c = 'New';
		recordMLP2.IDENT_NO__c = '01234567890123';
		recordMLP2.PROSP_NM__c = 'fix|'+lastName1+'|0818188216';
		recordMLP2.REFR_ID__c = 'SLAS1600712824071_20180629';
		mlpList.add(recordMLP);
		mlpList.add(recordMLP2);

		insert(mlpList);

		Test.startTest();
		CreateLeadMLP_Batch batchCreateLeadMLP = new CreateLeadMLP_Batch();
		batchCreateLeadMLP.isManual = true;
		Database.executeBatch(batchCreateLeadMLP);
		Test.stopTest();
		List<CampaignMember> campaignMemberList = [SELECT Id FROM CampaignMember ];
		List<Lead> leadList = [SELECT Id FROM Lead ];
		System.assertEquals(1,leadList.size());
		System.assertEquals(1,campaignMemberList.size());
		
	}


	@isTest
	static void createNewLeadWithRoundRobinQueue(){	
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		Date yesterday = Date.today().addDays(-1);
        String prefixDate =  yesterday.day()+''+ yesterday.month()+''+yesterday.year();
        Id recordTypeLeadMLP = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Lead',GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);

		List<Lead_MLP__c> mlpList = new List<Lead_MLP__c>();
		Lead_MLP__c recordMLP = createNewMLP(cisNumber1,lastName1,productCode1);
		Lead_MLP__c recordMLP2 = createNewMLP(cisNumber2,lastName2,productCode2);
		mlpList.add(recordMLP);
		mlpList.add(recordMLP2);

		insert(mlpList);

		Test.startTest();
		CreateLeadMLP_Batch batchCreateLeadMLP = new CreateLeadMLP_Batch();
		batchCreateLeadMLP.isManual = true;
		Database.executeBatch(batchCreateLeadMLP);
		Test.stopTest();
		Set<String> recordTypeTelesales = new Set<String>{GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME,GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME};
		List<AggregateResult> leadList = [SELECT COUNT(Id) CountLead,Assigned_Owner__r.Employee_ID__c EmpId FROM Lead WHERE RecordType.DeveloperName=:recordTypeTelesales GROUP BY Assigned_Owner__r.Employee_ID__c ];
		List<Lead> leadList2 = [SELECT Id FROM LEAD];
		Map<String,Integer> leadResultMap = new Map<String,Integer>();
		for(AggregateResult result : leadList){
			String tmpEmpId =  String.valueOf(result.get('EmpId'));
			Integer countLead = Integer.valueOf(result.get('CountLead'));
			leadResultMap.put(tmpEmpId,countLead);
		}
		System.assertEquals(1,leadResultMap.get(Mockup_Test.userEmpIdAH));
		System.assertEquals(1,leadResultMap.get(Mockup_Test.userEmpIdTM));
	}


	private static Lead_MLP__c createNewMLP(String cisNum,String lastName,String productCode){
		Lead_MLP__c recordMLP = new Lead_MLP__c();
		recordMLP.PERSZ_MSG__c = productCode;
		recordMLP.IP_ID__c = cisNum;
		recordMLP.REL_ST__c = 'New';
		recordMLP.PROSP_NM__c = 'fix|'+lastName+'|0818188216';
		recordMLP.IDENT_NO__c = '01234567890123';
		recordMLP.REFR_ID__c = 'SLAS1600712824071_20180629';
		return recordMLP;
	}

}