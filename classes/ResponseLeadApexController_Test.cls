@isTest
private class ResponseLeadApexController_Test {
	private static final String campaignCodeToDo = 'Test Answer Lead To Do';
	private static final String campaignCodeDpd = 'Test Answer Lead DPD';
	private static final String campaignCodeForSales = 'Test Answer Lead For Sales';
	private static final String campaignTypeToDo = GlobalConstants.LEAD_TO_DO;
	private static final String campaignSubTypeToDo = GlobalConstants.LEAD_SUB_TYPE_DPD;
	private static final String answerLeadAccountNameRM = 'answerLeadAccountNameRM';

    private static final String CAMPAIGN_NAME = 'CampaignName';
	private static final String CBS_LEAD_SUBTYPE = 'SUBTYPE01';

	private static final String USER_EMPOYEEID = '9000000000'; 
	private static final String CIS_ACCOUNT1 = '000001'; 


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
        TriggerHandler.clearBypass('UserTriggerHandler');
        setupCampaign();
        setupLeadMaster();
        setupRelations();
        setupResponses();
        setupNewTargetList(newAccount1);
        setupQuestionAndAnswerListViewPageWithLeadForFeedback(newAccount1);
        Test.stopTest();
    }

    public static void createUserAndAccount(){
		Profile cbsRM_Profile = [SELECT Id From Profile  WHERE Name = :GlobalConstants.CBS_RM LIMIT 1];
		User userCBS_RM = Mockup_Test.newUser('fistname','lastname', USER_EMPOYEEID, true, cbsRM_Profile.id, null, null);
		insert userCBS_RM;
		System.runAs(userCBS_RM){
			Account newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			newAccount1.CIS__c = CIS_ACCOUNT1;
            newAccount1.OwnerId = userCBS_RM.Id;
			insert newAccount1;
		}

	}

    
    private static void setupCampaign(){
        List<Campaign> campaignList = new List<Campaign>();
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeToDo, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_TO_INFORM));
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeForSales, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_FOR_SALES,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA));
        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),campaignCodeDpd, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_DPD));
        
        insert campaignList;
    }

    private static void setupLeadMaster(){
        List<Lead_Master__c> leadMasterLists = new List<Lead_Master__c>();
        leadMasterLists.add(newLeadMaster('Master1','Master1',true,campaignCodeForSales,'1'));
        leadMasterLists.add(newLeadMaster('Master2','Master2',false,campaignCodeForSales,'2'));
        leadMasterLists.add(newLeadMaster('Master3','Master3',false,campaignCodeForSales,'3'));
        leadMasterLists.add(newLeadMaster('Master4','Master4',true,'SUBTYPE01','1'));
        leadMasterLists.add(newLeadMaster('Master5','Master5',false,'SUBTYPE01','2'));
        leadMasterLists.add(newLeadMaster('Master6','Master6',false,'SUBTYPE01','3'));
       
        insert leadMasterLists;
    }

    private static void setupRelations(){
        List<Lead_Relations_Master__c> relationLists = new List<Lead_Relations_Master__c>();
        relationLists.add(newLeadRelationMaster('RelationName1',campaignCodeForSales,'Master1','Response1'));
        relationLists.add(newLeadRelationMaster('RelationName2',campaignCodeForSales,'Master1','Response2'));
        relationLists.add(newLeadRelationMaster('RelationName3',campaignCodeForSales,'Master1','Response3'));
        relationLists.add(newLeadRelationMaster('RelationName4',campaignCodeForSales,'Response1','Response4'));
        relationLists.add(newLeadRelationMaster('RelationName5',campaignCodeForSales,'Response1','Response5'));
        relationLists.add(newLeadRelationMaster('RelationName6',campaignCodeForSales,'Response2','Response6'));
        relationLists.add(newLeadRelationMaster('RelationName7',campaignCodeForSales,'Response2','Response7'));
        relationLists.add(newLeadRelationMaster('RelationName8',campaignCodeForSales,'Response3','Response8'));
        relationLists.add(newLeadRelationMaster('RelationName9',campaignCodeForSales,'Response3','Response9'));
        relationLists.add(newLeadRelationMaster('RelationName10',campaignCodeForSales,'Response3','Response10'));

        relationLists.add(newLeadRelationMaster('RelationName16','SUBTYPE01','Master4','Response16'));
        relationLists.add(newLeadRelationMaster('RelationName11','SUBTYPE01','Master4','Response11'));
        relationLists.add(newLeadRelationMaster('RelationName12','SUBTYPE01','Response10','Response12'));
        relationLists.add(newLeadRelationMaster('RelationName13','SUBTYPE01','Response10','Response13'));
        relationLists.add(newLeadRelationMaster('RelationName14','SUBTYPE01','Response11','Response14'));
        relationLists.add(newLeadRelationMaster('RelationName15','SUBTYPE01','Response13','Relation15'));
        
        insert relationLists;
    }

    private static void setupResponses(){
        List<Lead_Response_Master__c> responseLists = new List<Lead_Response_Master__c>();
        responseLists.add(newLeadResponseMaster('ResponseName1','Question1','Master1',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName2','Question2','Master2',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName3','Question3','Master3',false,false));

        responseLists.add(newLeadResponseMaster('ResponseName4','1. Message1','Response1',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName5','2. Message2','Response2',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName6','3. Message3','Response3',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName7','1.1 Message4','Response4',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName8','1.2 Message5','Response5',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName9','2.1 Message6','Response6',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName10','2.2 Message7','Response7',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName11','Message8','Response8',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName12','Message9','Response9',true,true));
        
        responseLists.add(newLeadResponseMaster('ResponseName14',null,'Master4',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName15',null,'Master5',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName16',null,'Master6',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName13','Message10','Response10',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName18','2. Message11','Response11',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName19','1.1 Message12','Response12',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName20','1.2 Message13','Response13',false,false));
        responseLists.add(newLeadResponseMaster('ResponseName21','2.1 Message14','Response14',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName22','1.2.1 Message15','Response15',true,true));
        responseLists.add(newLeadResponseMaster('ResponseName23','1. Message16','Response16',true,true));

        insert responseLists;
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

    private static void setupExistTargetListWithOldResponses(){
        List<Target_List__c> targetLists = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeToDo];
        for(Integer i=1;i<=5;i++){
            targetLists[0].put('Response_Level_' + i + '__c', 'Response '+i);
			targetLists[0].put('Note_' + i+ '__c',  'Note '+i);
            if(i == 1){
			    targetLists[0].put('Memo__c', 'Memo '+i);
            }else{
			    targetLists[0].put('Memo_' + i + '__c', 'Memo '+i);
            }
        }
		targetLists[0].Status__c =  'Response 5';
        targetLists[0].Response_Date__c = System.today();

        update targetLists;
    }

    private static Lead_Master__c newLeadMaster(String name,String startResponse,Boolean isMain,String leadType,String level){

    	Lead_Master__c master = new Lead_Master__c();
        master.Name = name;
        master.Starting_Response_ID__c = startResponse;
        master.Is_Main_Level__c = isMain;
        master.Lead_Type__c = leadType;
        master.No_of_Level__c = level;
    	return master;
    }

    private static Lead_Relations_Master__c newLeadRelationMaster(String name,String leadType,String responseId,String relatedResponse){

    	Lead_Relations_Master__c relation = new Lead_Relations_Master__c ();
        relation.Name = name;
        relation.Lead_Type__c = leadType;
        relation.Related_Response_ID__c = relatedResponse;
        relation.Response_ID__c = responseId;
    	return relation;
    }

    private static Lead_Response_Master__c newLeadResponseMaster(String name,String message,String responseId,Boolean isShowMemo,Boolean isRequiredMemo){

    	Lead_Response_Master__c response = new Lead_Response_Master__c();
        response.Name = name;
        response.Message__c = message;
        response.Required_Memo__c = isRequiredMemo;
        response.Response_ID__c = responseId;
        response.Show_Memo__c = isShowMemo;
    	return response;
    }

    public static void setupQuestionAndAnswerListViewPageWithLeadForFeedback(Account newAccount){
		Campaign leadForFeedBack = Mockup_Test.newCampaignSubTypeCBS(UserInfo.getUserId(),CAMPAIGN_NAME, System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_CBS_REC, 'Advertisement',CBS_LEAD_SUBTYPE);
		insert leadForFeedBack;

		List<Target_List__c> targetLists = new List<Target_List__c>();
		Target_List__c targetListForFeedBack = Mockup_Test.newTargetList(newAccount.Id, leadForFeedBack.Id, 'externalId1', 'New');
		targetLists.add(targetListForFeedBack);

		insert targetLists;

        ResponseLeadApexController responseLeadCtrl;
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
        stdSetController.setSelected(targetLists);
        responseLeadCtrl = new ResponseLeadApexController(stdSetController);
        responseLeadCtrl.setupQuestionAndChoices();

    }

    @isTest static void setupQuestionAndAnswerListViewPageWithLeadForSale(){
		List<Target_List__c> currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];

        ResponseLeadApexController responseLeadCtrl;
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(currentTgl);
        stdSetController.setSelected(currentTgl);
        responseLeadCtrl = new ResponseLeadApexController(stdSetController);
        responseLeadCtrl.setupQuestionAndChoices();
    }

    @isTest static void setupQuestionAndAnswerOldResponseListViewPageWithLeadToDo(){
		
        setupExistTargetListWithOldResponses();
        List<Target_List__c> currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeToDo];

        ResponseLeadApexController responseLeadCtrl;
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(currentTgl);
        stdSetController.setSelected(currentTgl);
        responseLeadCtrl = new ResponseLeadApexController(stdSetController);
        responseLeadCtrl.setupQuestionAndChoices();

    }

    @isTest static void setupQuestionAndAnswerRecordPage(){
    	List<Lead_Master__c> listResponse = new List<Lead_Master__c>();
		List<Target_List__c> currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeToDo];
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(currentTgl);
        ResponseLeadApexController ctrl = new ResponseLeadApexController(stdController);
        ctrl.recordId = currentTgl[0].Id;
        ctrl.setupQuestionAndChoices();

    }

	@isTest static void testSaveMethodWithNewJobSuccess() {
		List<Target_List__c> currentTgl = [SELECT Id,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignCodeForSales];
        ResponseLeadApexController responseLeadCtrl;
        Test.setCurrentPage(Page.ResponseLead);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(currentTgl);
        stdSetController.setSelected(currentTgl);
        responseLeadCtrl = new ResponseLeadApexController(stdSetController);
        Map<String,Map<String,Object>> questionMapMock = new Map<String,Map<String,Object>>();
        List<Object> objList = new List<Object>();
        for(Integer level=1;level<=3;level++){
            ResponseLeadApexController.AnswerSelectedObject answerObj = new ResponseLeadApexController.AnswerSelectedObject();
            Map<String,Object> attr = new Map<String,Object>();
            answerObj.answerId = 'Response' +level;
            answerObj.answerText = 'Response ' +level;
            answerObj.memoText = 'Memo '+level;
            answerObj.noteText = 'Note '+level;
            answerObj.level = String.valueOf(level);
            answerObj.questionId = 'Question'+level;
            attr.put('Answered',answerObj);
            objList.add(answerObj);
            questionMapMock.put(answerObj.questionId,attr);
        }
        responseLeadCtrl.isCheckedNewJob = 'true';
        responseLeadCtrl.questionMap = questionMapMock;
        responseLeadCtrl.mapAnswerObjStr = JSON.serialize(objList);
        responseLeadCtrl.save();

        Target_List__c targetResult = [SELECT Id,Response_Level_1__c,Response_Level_2__c,Response_Level_3__c,Memo__c,Memo_2__c,Memo_3__c,Note_1__c,Note_2__c,Note_3__c FROM Target_List__c WHERE Id = :currentTgl[0].Id];
        System.assertEquals(true,responseLeadCtrl.resultresponse.isSuccess);
        System.assertEquals('Response 1',targetResult.Response_Level_1__c);
        System.assertEquals('Memo 2',targetResult.Memo_2__c);
        System.assertEquals('Note 3',targetResult.Note_3__c);
	}

    @isTest static void testOnchangeMothod(){
		List<Target_List__c> targetLists = new List<Target_List__c>();
		Target_List__c targetListForFeedBack = [SELECT Id FROM Target_List__c WHERE External_ID__c = 'externalId1' AND Status__c = 'New' LIMIT 1];
		targetLists.add(targetListForFeedBack);

        ResponseLeadApexController responseLeadCtrl;
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
        stdSetController.setSelected(targetLists);
        responseLeadCtrl = new ResponseLeadApexController(stdSetController);
        responseLeadCtrl.selectedAnswer = 'Response2';
        Map<String,Map<String,Object>> questionMapMock = new Map<String,Map<String,Object>>();
        ResponseLeadApexController.AnswerSelectedObject answerObj = new ResponseLeadApexController.AnswerSelectedObject();
        Map<String,Object> attr = new Map<String,Object>();
        answerObj.answerId = 'Response11';
        answerObj.answerText = 'Response 11';
        answerObj.memoText = 'Memo 2';
        answerObj.level = '2';
        answerObj.questionId = 'Master4';
        attr.put('Answered',answerObj);
        questionMapMock.put(answerObj.questionId,attr);
        Map<String,Object> attrNextLv = new Map<String,Object>();
        attrNextLv.put('Answered',answerObj);
        questionMapMock.put('Master5',attrNextLv);
        questionMapMock.put('Master6',attrNextLv);
        responseLeadCtrl.questionMap = questionMapMock;       
        responseLeadCtrl.nextLv = '2';
        responseLeadCtrl.onChangeResponse();
        
        Map<String,Map<String,Object>> mp = responseLeadCtrl.questionMap;
        List<Lead_Response_Master__c> listChoices = (List<Lead_Response_Master__c>) mp.get('Master5').get('Choices');
        System.assertNotEquals(null,mp); 
        System.assertNotEquals(1,listChoices.size()); 

    }

    @isTest static void testSortChoiceLv1(){
        Lead_Response_Master__c newLeadResponseMaster1 = new Lead_Response_Master__c(Message__c = '1. a');
        Lead_Response_Master__c newLeadResponseMaster2 = new Lead_Response_Master__c(Message__c = '2. a');
        Lead_Response_Master__c newLeadResponseMaster3 = new Lead_Response_Master__c(Message__c = '3. a');
        Lead_Response_Master__c newLeadResponseMaster10 = new Lead_Response_Master__c(Message__c = '10. a');
        Lead_Response_Master__c newLeadResponseMaster12 = new Lead_Response_Master__c(Message__c = '12. a');

        List<Lead_Response_Master__c> listLeadResponse = new List<Lead_Response_Master__c>{newLeadResponseMaster10,newLeadResponseMaster2,newLeadResponseMaster12,newLeadResponseMaster3,newLeadResponseMaster1};
        
        List<Target_List__c> targetLists = [SELECT Id FROM Target_List__c WHERE External_ID__c = 'externalId1' AND Status__c = 'New'];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
        ResponseLeadApexController controller = new ResponseLeadApexController(stdSetController);
        List<Lead_Response_Master__c> listLeadResponseSorted = controller.manualSortChoices(listLeadResponse);

        System.assertEquals(newLeadResponseMaster1.Message__c,listLeadResponseSorted[0].Message__c);
        System.assertEquals(newLeadResponseMaster2.Message__c,listLeadResponseSorted[1].Message__c);
        System.assertEquals(newLeadResponseMaster3.Message__c,listLeadResponseSorted[2].Message__c);
        System.assertEquals(newLeadResponseMaster10.Message__c,listLeadResponseSorted[3].Message__c);
        System.assertEquals(newLeadResponseMaster12.Message__c,listLeadResponseSorted[4].Message__c);
    }

    @isTest static void testSortChoiceLv2(){
        Lead_Response_Master__c newLeadResponseMaster1 = new Lead_Response_Master__c(Message__c = '2.1. a');
        Lead_Response_Master__c newLeadResponseMaster2 = new Lead_Response_Master__c(Message__c = '2.2. a');
        Lead_Response_Master__c newLeadResponseMaster3 = new Lead_Response_Master__c(Message__c = '2.3. a');
        Lead_Response_Master__c newLeadResponseMaster10 = new Lead_Response_Master__c(Message__c = '2.10. a');
        Lead_Response_Master__c newLeadResponseMaster12 = new Lead_Response_Master__c(Message__c = '2.12. a');

        List<Lead_Response_Master__c> listLeadResponse = new List<Lead_Response_Master__c>{newLeadResponseMaster10,newLeadResponseMaster2,newLeadResponseMaster12,newLeadResponseMaster3,newLeadResponseMaster1};
        
        List<Target_List__c> targetLists = [SELECT Id FROM Target_List__c WHERE External_ID__c = 'externalId1' AND Status__c = 'New'];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
        ResponseLeadApexController controller = new ResponseLeadApexController(stdSetController);
        List<Lead_Response_Master__c> listLeadResponseSorted = controller.manualSortChoices(listLeadResponse);

        System.assertEquals(newLeadResponseMaster1.Message__c,listLeadResponseSorted[0].Message__c);
        System.assertEquals(newLeadResponseMaster2.Message__c,listLeadResponseSorted[1].Message__c);
        System.assertEquals(newLeadResponseMaster3.Message__c,listLeadResponseSorted[2].Message__c);
        System.assertEquals(newLeadResponseMaster10.Message__c,listLeadResponseSorted[3].Message__c);
        System.assertEquals(newLeadResponseMaster12.Message__c,listLeadResponseSorted[4].Message__c);
    }
	
}