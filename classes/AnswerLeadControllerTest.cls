@isTest
private class AnswerLeadControllerTest {
	private static final String campaignCodeToDo = 'Test Answer Lead To Do';
	private static final String campaignCodeDpd = 'Test Answer Lead DPD';
	private static final String campaignCodeForSales = 'Test Answer Lead For Sales';
	private static final String campaignTypeToDo = GlobalConstants.LEAD_TO_DO;
	private static final String campaignSubTypeToDo = GlobalConstants.LEAD_SUB_TYPE_DPD;
	private static final String answerLeadAccountNameRM = 'answerLeadAccountNameRM';

	@testSetup static void setUpTest(){
        SME_GroupChatterService.isByPassGroupChatterService = true;
        TriggerHandler.bypass('UserTriggerHandler');
        TriggerHandler.bypass('CampaignTriggerHandler');
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
        Account newAccount1;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            newAccount1 = Mockup_Test.newAccountWithSegment(answerLeadAccountNameRM,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT),'MI');
            insert newAccount1;
        }
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');

        setupLeadMaster();
        setupNewTargetList(newAccount1);
        setupLeadResponse();
    }

    private static void setupLeadMaster(){
        List<Campaign> campaignList = new List<Campaign>();
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeToDo, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_TO_INFORM));
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeForSales, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_FOR_SALES,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA));
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeDpd, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_DPD));
        
        insert campaignList;
    }
    
    private static void setupNewTargetList(Account newAccount){
        List<Target_List__c> targetLists = new List<Target_List__c>();
        Campaign campaignCodeToDo = [SELECT Id FROM Campaign WHERE Name =:campaignCodeToDo];
        Target_List__c targetListToDo = Mockup_Test.newTargetList(newAccount.Id,campaignCodeToDo.Id,campaignCodeToDo.Id,GlobalConstants.STATUS_NEW);
        targetLists.add(targetListToDo);

        Campaign campaignCodeForSales = [SELECT id From Campaign WHERE Name =:campaignCodeForSales];
        Target_List__c targetListForSales = Mockup_Test.newTargetList(newAccount.Id,campaignCodeForSales.Id,campaignCodeForSales.Id,GlobalConstants.STATUS_NEW);
        targetLists.add(targetListForSales);

        Campaign campaignCodeDpd = [SELECT id From Campaign WHERE Name =:campaignCodeDpd];
        Target_List__c targetListDpd = Mockup_Test.newTargetList(newAccount.Id,campaignCodeDpd.Id,campaignCodeDpd.Id,GlobalConstants.STATUS_NEW);
        targetLists.add(targetListDpd);
        insert targetLists;
    }

    private static Global_Master_Data__c newResponse(String name,String campaignCode,Boolean isRequireApp
    	,Boolean isRequireLv2,Boolean isRequireMemo,Boolean isRequireDate,String response1,String response2,String team){
    	Id locationRecType = GlobalUtility.getRecordTypeId('Global_Master_Data__c', 'LeadResponse');
    	Global_Master_Data__c response = new Global_Master_Data__c();
    	response.RecordTypeId = locationRecType;
    	response.LeadResponse_Campaign_Code__c = campaignCode;
    	response.LeadResponse_Required_App_ID__c = isRequireApp;
    	response.LeadResponse_Required_Level2__c = isRequireLv2;
    	response.LeadResponse_Required_Memo__c = isRequireMemo;
    	response.LeadResponse_Required_Date__c = isRequireDate;
    	response.LeadResponse_Response_Level1__c = response1;
    	response.LeadResponse_Response_Level2__c = response2;
    	response.LeadResponse_Team__c = team;
    	return response;
    }

    private static void setupLeadResponse(){
    	List<Global_Master_Data__c> listResponse = new List<Global_Master_Data__c>();
    	//lead to do
    	listResponse.add(newResponse('responseToDo1',campaignCodeToDo,true,true,true,true,'responseToDo1','','SME'));
    	listResponse.add(newResponse('responseToDo1.1',campaignCodeToDo,true,true,true,true,'responseToDo1','responseToDo1.1','SME'));
    	listResponse.add(newResponse('responseToDo1.2',campaignCodeToDo,true,true,true,true,'responseToDo1','responseToDo1.2','SME'));

    	//lead for sales
    	listResponse.add(newResponse('responseForSales1',campaignCodeForSales,true,true,true,true,'responseForSales1','','SME'));
    	listResponse.add(newResponse('responseForSales1.1',campaignCodeForSales,true,false,true,false,'responseForSales1','responseForSales1.1','SME'));
    	listResponse.add(newResponse('responseForSales1.2',campaignCodeForSales,false,true,false,true,'responseForSales1','responseForSales1.2','SME'));
    	listResponse.add(newResponse('responseForSales2',campaignCodeForSales,true,true,true,true,'responseForSales2','','SME'));
    	listResponse.add(newResponse('responseForSales2.1',campaignCodeForSales,true,true,true,true,'responseForSales2','responseForSales2.2','SME'));
    	listResponse.add(newResponse('responseForSales2.2',campaignCodeForSales,true,true,true,true,'responseForSales2','responseForSales2.2','SME'));
   		
   		//lead dpd
    	listResponse.add(newResponse('responseToDpd1',campaignCodeDpd,true,true,true,true,'responseToDpd1','','SME'));
    	listResponse.add(newResponse('responseToDpd1.1',campaignCodeDpd,true,true,true,true,'responseToDpd1','responseToDpd1.1','SME'));
    	listResponse.add(newResponse('responseToDpd1.2',campaignCodeDpd,true,true,true,true,'responseToDpd1','responseToDpd1.2','SME'));
    	listResponse.add(newResponse('responseToDpd2',campaignCodeDpd,true,true,true,true,'responseToDpd2','','SME'));
    	listResponse.add(newResponse('responseToDpd2.1',campaignCodeDpd,true,true,true,true,'responseToDpd2','responseToDpd2.2','SME'));
    	listResponse.add(newResponse('responseToDpd2.2',campaignCodeDpd,true,true,true,true,'responseToDpd2','responseToDpd2.2','SME'));

    	insert listResponse;
    }

	@isTest static void testGetFormReturnLead_DPD_ResponseFieldSet() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeDpd];
		AnswerLeadController.FieldSetForm result = AnswerLeadController.getForm(currentTgl.Id,'Target_List__c');
		System.assertEquals(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c,result.LeadCode);
		System.assertEquals(currentTgl.Lead_Subtype__c,result.LeadSubType);
		System.assertEquals(Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Subtype__c)).getFields().size(),result.Fields.size());
	}
	
	@isTest static void testGetFormReturnLead_For_Sale_ResponseFieldSet() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		AnswerLeadController.FieldSetForm result = AnswerLeadController.getForm(currentTgl.Id,'Target_List__c');
		System.assertEquals(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c,result.LeadCode);
		System.assertEquals(currentTgl.Lead_Subtype__c,result.LeadSubType);
		System.assertEquals(Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields().size(),result.Fields.size());
	}

	@isTest static void testGetFormReturnLead_To_Do_ResponseFieldSet() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeToDo];
		AnswerLeadController.FieldSetForm result = AnswerLeadController.getForm(currentTgl.Id,'Target_List__c');
		System.assertEquals(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c,result.LeadCode);
		System.assertEquals(currentTgl.Lead_Subtype__c,result.LeadSubType);
		System.assertEquals(Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields().size(),result.Fields.size());
	}

	@isTest static void testGetReponseLevel1() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeToDo];
		List<AnswerLeadController.AnswerObject> listAnswer = AnswerLeadController.getResponseLevel1(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c,currentTgl.Lead_Subtype__c);
		System.assertEquals(1,listAnswer.size());
		System.assertEquals('responseToDo1',listAnswer[0].answer);
		System.assertEquals(false,listAnswer[0].isRequireLv2);
		System.assertEquals(true,listAnswer[0].isRequireMemo);
		System.assertEquals(true,listAnswer[0].isRequiredDate);
		System.assertEquals(true,listAnswer[0].isRequiredAppId);
	}

	@isTest static void testGetReponseLevel2() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		List<AnswerLeadController.AnswerObject> listAnswer = AnswerLeadController.getResponseLevel2(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c,'responseForSales1',currentTgl.Lead_Subtype__c);
		System.assertEquals(2,listAnswer.size());
		System.assertEquals('responseForSales1.1',listAnswer[0].answer);
		System.assertEquals(false,listAnswer[0].isRequireLv2);
		System.assertEquals(true,listAnswer[0].isRequireMemo);
		System.assertEquals(false,listAnswer[0].isRequiredDate);
		System.assertEquals(true,listAnswer[0].isRequiredAppId);
		System.assertEquals('responseForSales1.2',listAnswer[1].answer);
		System.assertEquals(true,listAnswer[1].isRequireLv2);
		System.assertEquals(false,listAnswer[1].isRequireMemo);
		System.assertEquals(true,listAnswer[1].isRequiredDate);
		System.assertEquals(false,listAnswer[1].isRequiredAppId);
	}

	@isTest static void testSaveError() {
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		Map<String,String> mapReponseByFieldApi = new Map<String,String>{'invalid field'=>'value'};
		AnswerLeadController.ResultResponse result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		System.assertEquals(false,result.isSuccess);
	}

	@isTest static void testSaveSuccess() {
		String expectedResponseLv1 = 'response 1';
		String expectedResponseLv2 = 'response 2';
		String expectedMemo = 'test memo';
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		Map<String,String> mapReponseByFieldApi = new Map<String,String>();
		List<Schema.FieldSetMember> listField = Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields();
		for(Schema.FieldSetMember eachField : listField){
			if(eachField.fieldPath == 'Response_Level_1__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv1);
			if(eachField.fieldPath == 'Response_Level_2__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv2);
			if(eachField.fieldPath == 'Memo__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedMemo);
		}
		AnswerLeadController.ResultResponse result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		System.assertEquals(true,result.isSuccess);
		Target_List__c resultTgl = [SELECT Id,Response_Level_1__c,Response_Level_2__c,Memo__c FROM Target_List__c WHERE Id = :currentTgl.Id];
		System.assertEquals(expectedResponseLv1,resultTgl.Response_Level_1__c);
		System.assertEquals(expectedResponseLv2,resultTgl.Response_Level_2__c);
		System.assertEquals(expectedMemo,resultTgl.Memo__c);
	}

	@isTest static void Given_TargetListHasReAssignTo_When_OtherAnswerLead_Then_ErrorNotAllowToUpdateRecord() {
		String expectedResponseLv1 = 'response 1';
		String expectedResponseLv2 = 'response 2';
		String expectedMemo = 'test memo';
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User_Extension__c rmUserEx = [SELECT Id FROM User_Extension__c WHERE User__c = :rmUser.Id];
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		currentTgl.Re_Assigned_To_UserEx__c = rmUserEx.Id;
		currentTgl.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard');
		update currentTgl;

		Map<String,String> mapReponseByFieldApi = new Map<String,String>();
		List<Schema.FieldSetMember> listField = Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields();
		for(Schema.FieldSetMember eachField : listField){
			if(eachField.fieldPath == 'Response_Level_1__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv1);
			if(eachField.fieldPath == 'Response_Level_2__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv2);
			if(eachField.fieldPath == 'Memo__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedMemo);
		}
		AnswerLeadController.ResultResponse result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		System.assertEquals(false,result.isSuccess);
		System.assertEquals(Label.Not_Allow_to_update_record,result.message);
	}

	@isTest static void Given_TargetListHasReAssignTo_When_ReAssignUserAnswer_Then_Success() {
		String expectedResponseLv1 = 'response 1';
		String expectedResponseLv2 = 'response 2';
		String expectedMemo = 'test memo';
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		User_Extension__c rmUserEx = [SELECT Id FROM User_Extension__c WHERE User__c = :rmUser.Id];
		Target_List__c currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		currentTgl.Re_Assigned_To_UserEx__c = rmUserEx.Id;
		update currentTgl;

		Map<String,String> mapReponseByFieldApi = new Map<String,String>();
		List<Schema.FieldSetMember> listField = Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields();
		for(Schema.FieldSetMember eachField : listField){
			if(eachField.fieldPath == 'Response_Level_1__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv1);
			if(eachField.fieldPath == 'Response_Level_2__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv2);
			if(eachField.fieldPath == 'Memo__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedMemo);
		}
		AnswerLeadController.ResultResponse result;
		System.runAs(rmUser){
			result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		}
		System.assertEquals(true,result.isSuccess);
	}

	@isTest static void Given_TargetListAndAccountHasSmeTemp_When_TempUserAnswer_Then_Success() {
		String expectedResponseLv1 = 'response 1';
		String expectedResponseLv2 = 'response 2';
		String expectedMemo = 'test memo';
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		User_Extension__c rmUserEx = [SELECT Id FROM User_Extension__c WHERE User__c = :rmUser.Id];
		Target_List__c currentTgl = [SELECT Id,CIS_ID_Prospect_Name__c,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		Account accountRm = new Account(Id = currentTgl.CIS_ID_Prospect_Name__c,SME_Temporary_Customer__c = rmUserEx.Id);
		update accountRm;

		Map<String,String> mapReponseByFieldApi = new Map<String,String>();
		List<Schema.FieldSetMember> listField = Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields();
		for(Schema.FieldSetMember eachField : listField){
			if(eachField.fieldPath == 'Response_Level_1__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv1);
			if(eachField.fieldPath == 'Response_Level_2__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv2);
			if(eachField.fieldPath == 'Memo__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedMemo);
		}
		AnswerLeadController.ResultResponse result;
		System.runAs(rmUser){
			result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		}
		System.assertEquals(true,result.isSuccess);
	}

	@isTest static void Given_TargetListAndAccountHasServiceRm_When_ServiceRmUserAnswer_Then_Success() {
		String expectedResponseLv1 = 'response 1';
		String expectedResponseLv2 = 'response 2';
		String expectedMemo = 'test memo';
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		Target_List__c currentTgl = [SELECT Id,CIS_ID_Prospect_Name__c,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
		Account accountRm = new Account(Id = currentTgl.CIS_ID_Prospect_Name__c,Service_Rm__c = rmUser.Id);
		update accountRm;

		Map<String,String> mapReponseByFieldApi = new Map<String,String>();
		List<Schema.FieldSetMember> listField = Schema.SObjectType.Target_List__c.fieldSets.getMap().get(AnswerLeadController.fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c)).getFields();
		for(Schema.FieldSetMember eachField : listField){
			if(eachField.fieldPath == 'Response_Level_1__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv1);
			if(eachField.fieldPath == 'Response_Level_2__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedResponseLv2);
			if(eachField.fieldPath == 'Memo__c') mapReponseByFieldApi.put(eachField.fieldPath,expectedMemo);
		}
		AnswerLeadController.ResultResponse result;
		System.runAs(rmUser){
			result = AnswerLeadController.saveResponse(currentTgl.Id,mapReponseByFieldApi,null);
		}
		System.assertEquals(true,result.isSuccess);
	}

}