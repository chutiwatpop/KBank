@isTest
public class ApplicationHistory_Test {
	private static final String accountNameRM = 'accountNameRM';
	private static String applicationNo ;//= 'ME1/41404/0001/2017';
	private static String applicationNoR1;// = 'ME1/41404/0001/17R1';
	private static String applicationNoR2;// = 'ME1/1234/0001/17R2';
	private static String initialDateBd = '1010'+String.valueOf(System.today().year());
	private static String day = initialDateBd.substring(0,2);
	private static String month = initialDateBd.substring(2,4);
	private static String year = initialDateBd.substring(4);
	private static String uwDatePost = '1110'+String.valueOf(System.today().year());
	private static String dayUwDatePost = uwDatePost.substring(0,2);
	private static String monthUwDatePost = uwDatePost.substring(2,4);
	private static String yearUwDatePost = uwDatePost.substring(4);
	private static String priorityGroup1 = 'K-Buyer Financing Group 1';
	private static String priorityGroup2 = 'K-Buyer Financing Group 2';
	private static String priorityGroup3 = 'K-Buyer Financing Group 3';
	private static String priorityGroup4 = 'K-Buyer Financing Group 4';
	private static String priorityGroup5 = 'K-Buyer Financing Group 5';
	private static String priorityNameMain1_1 = 'K-Buyer Financing Main1 1';
	private static String priorityNameMain1_2 = 'K-Buyer Financing Main1 2';
	private static String priorityNameMain1_3 = 'K-Buyer Financing Main1 3';
	private static String priorityNameMain1_4 = 'K-Buyer Financing Main1 4';
	private static String priorityNameMain1_5 = 'K-Buyer Financing Main1 5';
	private static String priorityNameMain2_1 = 'K-Buyer Financing Main2 1';
	private static String priorityNameMain2_2 = 'K-Buyer Financing Main2 2';
	private static String priorityNameMain2_3 = 'K-Buyer Financing Main2 3';
	private static String priorityNameMain2_4 = 'K-Buyer Financing Main2 4';
	private static String priorityNameMain2_5 = 'K-Buyer Financing Main2 5';
	private static String priorityNameSub1 = 'K-Buyer Financing Sub 1';
	private static String priorityNameSub2 = 'K-Buyer Financing Sub 2';
	private static String priorityNameSub3 = 'K-Buyer Financing Sub 3';
	private static String priorityNameSub4 = 'K-Buyer Financing Sub 4';
	private static String priorityNameSub5 = 'K-Buyer Financing Sub 5';
	private static String priorityNameType1 = 'K-Buyer Financing Type 1';
	private static String priorityNameType2 = 'K-Buyer Financing Type 2';
	private static String priorityNameType3 = 'K-Buyer Financing Type 3';
	private static String priorityNameType4 = 'K-Buyer Financing Type 4';
	private static String priorityNameType5 = 'K-Buyer Financing Type 5';

	private static TransactBP__c newTransact(String inputApplicationNo){
		String busCode = '12345';
		String cusOptionA,cusOptionB,cusOptionC = 'N', cusOptionD = 'Y';
		String uwFinalDecision = 'FA';
		String cr1AmountRequested = '1',cr2AmountRequested = '2',cr3AmountRequested = '3',cr4AmountRequested = '4',cr5AmountRequested = '5';
		String uwRecommendAmount1 = '10',uwRecommendAmount2 = '20',uwRecommendAmount3 = '30',uwRecommendAmount4 = '40',uwRecommendAmount5 = '50';
		String uwSmOfferAmountB1 = '100',uwSmOfferAmountB2 = '200',uwSmOfferAmountB3 = '300',uwSmOfferAmountB4 = '400',uwSmOfferAmountB5 = '500';
		String uwSmOfferAmountC1 = '1000',uwSmOfferAmountC2 = '2000',uwSmOfferAmountC3 = '3000',uwSmOfferAmountC4 = '4000',uwSmOfferAmountC5 = '5000';
		System.debug('inputApplicationNo : '+inputApplicationNo);
		TransactBP__c newTransact = Mockup_Test.newTransact(inputApplicationNo,cusOptionA,cusOptionB,cusOptionC,cusOptionD,uwFinalDecision);
		System.debug('newTransact Application_No_From_BP_SF__c : '+newTransact.Application_No_From_BP_SF__c);
		newTransact.Business_Code__c = busCode;
		newTransact.CR_1_Amount_Requested__c = cr1AmountRequested;
		newTransact.CR_2_Amount_Requested__c = cr2AmountRequested;
		newTransact.CR_3_Amount_Requested__c = cr3AmountRequested;
		newTransact.CR_4_Amount_Requested__c = cr4AmountRequested;
		newTransact.CR_5_Amount_Requested__c = cr5AmountRequested;
		newTransact.UW_Recommend_Amount_Credit_Request_1__c = uwRecommendAmount1;
		newTransact.UW_Recommend_Amount_Credit_Request_2__c = uwRecommendAmount2;
		newTransact.UW_Recommend_Amount_Credit_Request_3__c = uwRecommendAmount3;
		newTransact.UW_Recommend_Amount_Credit_Request_4__c = uwRecommendAmount4;
		newTransact.UW_Recommend_Amount_Credit_Request_5__c = uwRecommendAmount5;
		newTransact.SM_P1_Offer_Amount_B__c = uwSmOfferAmountB1;
		newTransact.SM_P2_Offer_Amount_B__c = uwSmOfferAmountB2;
		newTransact.SM_P3_Offer_Amount_B__c = uwSmOfferAmountB3;
		newTransact.SM_P4_Offer_Amount_B__c = uwSmOfferAmountB4;
		newTransact.SM_P5_Offer_Amount_B__c = uwSmOfferAmountB5;
		newTransact.SM_P1_Offer_Amount_C__c = uwSmOfferAmountC1;
		newTransact.SM_P2_Offer_Amount_C__c = uwSmOfferAmountC2;
		newTransact.SM_P3_Offer_Amount_C__c = uwSmOfferAmountC3;
		newTransact.SM_P4_Offer_Amount_C__c = uwSmOfferAmountC4;
		newTransact.SM_P5_Offer_Amount_C__c = uwSmOfferAmountC5;
		newTransact.Application_Initial_Date_Buddhist_era__c = initialDateBd;
		newTransact.UW_Date_Send_to_Cust_Verification_Post__c = uwDatePost;
		newTransact.UW_Code__c = 'UW_Code__c';
		newTransact.UWA_Code__c = 'UWA_Code__c';
		return newTransact;
	}

	public static String getMockapplicationNo(String jobCode,String rcCode,Integer submitNo){
		String applicationNo = '';
		String prefixApp = jobCode.substring(0,2) + '1/' + rcCode +'/0001/';
		Integer currentYear = System.Today().year();
		if(currentYear < 2500){
			currentYear = currentYear + 543;
		}
		String yearPrefix = String.valueOf(currentYear);
		if(submitNo > 0){
			applicationNo = prefixApp + yearPrefix.substring(2)+'R'+submitNo;
		}else{
			applicationNo = prefixApp + yearPrefix;
		}
		return applicationNo;
	}

	public static String getMockNewapplicationNo(String jobCode,String rcCode,Integer submitNo){
		String applicationNo = '';
		String prefixApp = jobCode.substring(0,2) + '1/' + rcCode +'/0001/';
		Integer currentYear = System.Today().year();
		if(currentYear < 2500){
			currentYear = currentYear + 543;
		}
		String yearPrefix = String.valueOf(currentYear);
		if(submitNo > 0){
			applicationNo = prefixApp + yearPrefix.substring(2)+'S'+submitNo;
		}else{
			applicationNo = prefixApp + yearPrefix.substring(2) + 'SR';
		}
		return applicationNo;
	}

	private static void insertPrioriyMaster(){
		List<Priority_Master_Table__c> listPriority = new List<Priority_Master_Table__c>();
		listPriority.add(Mockup_Test.newPriorityMaster('1','1','001','001','1',priorityGroup1,priorityNameMain1_1,priorityNameMain2_1,priorityNameSub1,priorityNameType1));
		listPriority.add(Mockup_Test.newPriorityMaster('2','2','001','002','2',priorityGroup2,priorityNameMain1_2,priorityNameMain2_2,priorityNameSub2,priorityNameType2));
		listPriority.add(Mockup_Test.newPriorityMaster('3','3','002','003','3',priorityGroup3,priorityNameMain1_3,priorityNameMain2_3,priorityNameSub3,priorityNameType3));
		listPriority.add(Mockup_Test.newPriorityMaster('4','4','003','003','4',priorityGroup4,priorityNameMain1_4,priorityNameMain2_4,priorityNameSub4,priorityNameType4));
		listPriority.add(Mockup_Test.newPriorityMaster('5','5','001','004','5',priorityGroup5,priorityNameMain1_5,priorityNameMain2_5,priorityNameSub5,priorityNameType5));
		insert listPriority;
	}

	@testSetup static void setupAccount(){
		Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCodeOnlySme();
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        System.runAs(rmUser){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }

        User updateUserJobcode = new User(Id=UserInfo.getUserId(),Job_Code__c='ME4A',RC_Code__c='54321',Employee_Id__c = '4000000002');
        TriggerHandler.bypass('UserTriggerHandler');
        	update updateUserJobcode;
        TriggerHandler.clearbypass('UserTriggerHandler');
        Test.stopTest();
    }

    @isTest static void createTransactAndHasOpportunityButNoAppHisThenNotCreateApplicationHistory() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            insert Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
        }

        applicationNo = 'ME1/9999/0000/17R1';
		String cusOptionA,cusOptionB,cusOptionC = 'N';
		String cusOptionD = 'Y';
		String uwFinalDecision = 'FA';
		TransactBP__c newTransact = Mockup_Test.newTransact(applicationNo,cusOptionA,cusOptionB,cusOptionC,cusOptionD,uwFinalDecision);
		insert newTransact;
		TransactBP__c resultTransact = [SELECT Id,Application_History__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		List<Application_History__c> resultAppHis = [SELECT Id FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c];
		System.assertEquals(null,resultTransact.Application_History__c);
		System.assertEquals(0,resultAppHis.size());
	}

	@isTest static void createTransactWithoutOpportunityThenNotCreateApplicationHistory() {
		applicationNo = 'ME1/9999/0000/17R1';
		String cusOptionA,cusOptionB,cusOptionC = 'N';
		String cusOptionD = 'Y';
		String uwFinalDecision = 'FA';
		TransactBP__c newTransact = Mockup_Test.newTransact(applicationNo,cusOptionA,cusOptionB,cusOptionC,cusOptionD,uwFinalDecision);
		insert newTransact;
		TransactBP__c resultTransact = [SELECT Id,Application_History__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		List<Application_History__c> resultAppHis = [SELECT Id FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c];
		System.assertEquals(null,resultTransact.Application_History__c);
		System.assertEquals(0,resultAppHis.size());
	}

	@isTest static void createTransactWithoutOpportunityThenNotCreateApplicationHistoryWithNewAppNoFormat() {
		applicationNo = 'SE1/22519/0023/61S1';
		String cusOptionA,cusOptionB,cusOptionC = 'N';
		String cusOptionD = 'Y';
		String uwFinalDecision = 'FA';
		TransactBP__c newTransact = Mockup_Test.newTransact(applicationNo,cusOptionA,cusOptionB,cusOptionC,cusOptionD,uwFinalDecision);
		insert newTransact;
		TransactBP__c resultTransact = [SELECT Id,Application_History__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		List<Application_History__c> resultAppHis = [SELECT Id FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c];
		System.assertEquals(null,resultTransact.Application_History__c);
		System.assertEquals(0,resultAppHis.size());
	}

	
	
	@isTest static void resubmitTransactOptionDCreateNewApp() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
		applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
   		applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);

   		System.debug('applicationNo :'+applicationNo);
   		System.debug('applicationNoR1 :'+applicationNoR1);
		Application_History__c newAppHis;
		Opportunity newOpp;
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            newAppHis.IS_Create_By_Integration__c = false;
            insert newAppHis;
        }
        List<Application_History__c> allAPPList = [SELECT ID,AppNum_NonCMAS__c FROM Application_History__c];
        System.debug('allAPPList size :'+allAPPList.size());
        System.debug('AppNum_NonCMAS__c'+ allAPPList.get(0).AppNum_NonCMAS__c);

		TransactBP__c newTransact = newTransact(applicationNoR1);
		insert newTransact;
		List<Application_History__c> allAPPList2 = [SELECT ID,AppNum_NonCMAS__c FROM Application_History__c];
        System.debug('allAPPList2 size :'+allAPPList2.size());
        for(Application_History__c eachApp : allAPPList2){
        	System.debug('eachApp.AppNum_NonCMAS__c :'+eachApp.AppNum_NonCMAS__c);
        }

		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		System.assertEquals(resultAppHis.IsActive__c,true);
		System.assertEquals(resultAppHis.AppNum_NonCMAS__c,newTransact.Application_No_From_BP_SF__c);
		//System.assertEquals(resultAppHis.SP_Submit_Issue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.RMSubmitIssue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.SPBusinessCode__c,resultTransact.Business_Code__c);
		System.assertEquals(resultAppHis.SP_Requested_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMActualRequestedAmt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMSubmitChannel__c,GlobalConstants.NON_CMAS);
		System.assertEquals(resultAppHis.RMCreditModel__c,'FL');
		System.assertEquals(resultAppHis.SP_Approve_Option__c,'D');
		System.assertEquals(resultAppHis.SP_Approved_Amt__c,(GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_1__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_2__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_3__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_4__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_5__c)));
		System.assertEquals(resultAppHis.SP_CAPF_Received_DT__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.TentativeSubmitDate__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.SP_CAPB_Workout_DT__c,Date.newinstance(Integer.valueOf(yearUwDatePost),Integer.valueOf(monthUwDatePost),Integer.valueOf(dayUwDatePost)));
		System.assertEquals(resultAppHis.SP_Approval_Result__c,GlobalConstants.FINAL_APPROVE);
		System.assertEquals(resultAppHis.SP_UW_Name__c,newTransact.UW_Code__c);
		System.assertEquals(resultAppHis.SP_UWA_Name__c,newTransact.UWA_Code__c);
	}

	@isTest static void createTransactAndHasOpportunityAndHasFirstAppHisAndHasManyPriorityThenCreateApplicationHistoryWithMaxPriorityInfo() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
        applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
        applicationNoR2 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,2);
		System.debug('applicationNoR1 :'+ applicationNoR1);
		Application_History__c newAppHis;
		Opportunity newOpp;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, null);
            insert newOpp;
        }
        System.runAs(rmUser){
        	newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
        }
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

        insertPrioriyMaster();
        System.debug('applicationNoR1 :'+ applicationNoR1);
		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.Product_Program__c = '001';
		newTransact.CR1_Campaign_Code__c = '001';
		newTransact.CR2_Campaign_Code__c = '002';
		newTransact.CR3_Campaign_Code__c = '004';
		insert newTransact;
		System.debug('retest :'+newTransact.Application_No_From_BP_SF__c);
		List<Application_History__c> testlist =  [SELECT Id,ProductNameMain__c,ProductGroupPP__c,ProductNameMain2__c,ProductNameSub__c,Campcode__c,Pcode__c,PID__c,Ptype__c,PriorityRank__c,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c];
		
		System.debug('testlist size :'+testlist.size());
		System.debug('testlist '+testlist);
		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,ProductNameMain__c,ProductGroupPP__c,ProductNameMain2__c,ProductNameSub__c,Campcode__c,Pcode__c,PID__c,Ptype__c,PriorityRank__c,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		System.assertEquals(resultAppHis.IsActive__c,true);
		System.assertEquals(resultAppHis.AppNum_NonCMAS__c,newTransact.Application_No_From_BP_SF__c);
		//System.assertEquals(resultAppHis.SP_Submit_Issue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.RMSubmitIssue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.SPBusinessCode__c,resultTransact.Business_Code__c);
		System.assertEquals(resultAppHis.SP_Requested_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMActualRequestedAmt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMSubmitChannel__c,GlobalConstants.NON_CMAS);
		System.assertEquals(resultAppHis.RMCreditModel__c,'FL');
		System.assertEquals(resultAppHis.SP_Approve_Option__c,'D');
		System.assertEquals(resultAppHis.SP_Approved_Amt__c,(GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_1__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_2__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_3__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_4__c)+GlobalUtility.toDecimal(resultTransact.UW_Recommend_Amount_Credit_Request_5__c)));
		System.assertEquals(resultAppHis.SP_CAPF_Received_DT__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.TentativeSubmitDate__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.SP_CAPB_Workout_DT__c,Date.newinstance(Integer.valueOf(yearUwDatePost),Integer.valueOf(monthUwDatePost),Integer.valueOf(dayUwDatePost)));
		System.assertEquals(resultAppHis.SP_Approval_Result__c,GlobalConstants.FINAL_APPROVE);
		System.assertEquals(resultAppHis.SP_UW_Name__c,newTransact.UW_Code__c);
		System.assertEquals(resultAppHis.SP_UWA_Name__c,newTransact.UWA_Code__c);

		System.assertEquals(resultAppHis.PID__c,'5');
		System.assertEquals(resultAppHis.Ptype__c,priorityNameType5);
		System.assertEquals(resultAppHis.PriorityRank__c,'5');
		System.assertEquals(resultAppHis.Pcode__c,'001');
		System.assertEquals(resultAppHis.Campcode__c,'004');
		System.assertEquals(resultAppHis.ProductNameSub__c,priorityNameSub5);
		System.assertEquals(resultAppHis.ProductNameMain__c,priorityNameMain1_5);
		System.assertEquals(resultAppHis.ProductNameMain2__c,priorityNameMain2_5);
		System.assertEquals(resultAppHis.ProductGroupPP__c,priorityGroup5);
	}


	@isTest static void createTransactCustomerOptionAAndHasOpportunityAndHasFirstAppHisThenCreateApplicationHistoryCustomerOptionA() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		//applicationNo = rmUser.Job_Code__c.substring(0,2) + '1/' + rmUser.Rc_Code__c +'/0001/'+String.valueOf(System.today().year());
		//      applicationNoR1 = rmUser.Job_Code__c.substring(0,2) + '1/' + rmUser.Rc_Code__c +'/0001/'+String.valueOf(System.today().year()).substring(2)+'R1';
		//      applicationNoR2 = runningUser.Job_Code__c.substring(0,2) + '1/' + runningUser.Rc_Code__c + '/0001/'+String.valueOf(System.today().year()).substring(2)+'R2';

		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
		applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
		applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);
		Application_History__c newAppHis;
		Opportunity newOpp;
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
		newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
		insert newOpp;
		newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insert newAppHis;
		}
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.Customer_Option_A__c = 'Y';
		newTransact.Customer_Option_D__c = 'N';
		insert newTransact;
		
		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		System.assertEquals(resultAppHis.IsActive__c,true);
		System.assertEquals(resultAppHis.AppNum_NonCMAS__c,newTransact.Application_No_From_BP_SF__c);
		//System.assertEquals(resultAppHis.SP_Submit_Issue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.RMSubmitIssue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.SPBusinessCode__c,resultTransact.Business_Code__c);
		System.assertEquals(resultAppHis.SP_Requested_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMActualRequestedAmt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMSubmitChannel__c,GlobalConstants.NON_CMAS);
		System.assertEquals(resultAppHis.RMCreditModel__c,'FL');
		System.assertEquals(resultAppHis.SP_Approve_Option__c,'A');
		System.assertEquals(resultAppHis.SP_Approved_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.SP_CAPF_Received_DT__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.TentativeSubmitDate__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.SP_CAPB_Workout_DT__c,Date.newinstance(Integer.valueOf(yearUwDatePost),Integer.valueOf(monthUwDatePost),Integer.valueOf(dayUwDatePost)));
		System.assertEquals(resultAppHis.SP_Approval_Result__c,GlobalConstants.FINAL_APPROVE);
		System.assertEquals(resultAppHis.SP_UW_Name__c,newTransact.UW_Code__c);
		System.assertEquals(resultAppHis.SP_UWA_Name__c,newTransact.UWA_Code__c);
	}

	@isTest static void createTransactCustomerOptionBAndHasOpportunityAndHasFirstAppHisThenCreateApplicationHistoryCustomerOptionB() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];

		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
		applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
		applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);
		Application_History__c newAppHis;
		Opportunity newOpp;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
			newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
			insert newOpp;
			newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insert newAppHis;
		}

		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.Customer_Option_A__c = 'N';
		newTransact.Customer_Option_B__c = 'Y';
		newTransact.Customer_Option_C__c = 'N';
		newTransact.Customer_Option_D__c = 'N';
		insert newTransact;

		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c,SM_P1_Offer_Amount_B__c,SM_P2_Offer_Amount_B__c,SM_P3_Offer_Amount_B__c,SM_P4_Offer_Amount_B__c,SM_P5_Offer_Amount_B__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		System.assertEquals(resultAppHis.IsActive__c,true);
		System.assertEquals(resultAppHis.AppNum_NonCMAS__c,newTransact.Application_No_From_BP_SF__c);
		//System.assertEquals(resultAppHis.SP_Submit_Issue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.RMSubmitIssue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.SPBusinessCode__c,resultTransact.Business_Code__c);
		System.assertEquals(resultAppHis.SP_Requested_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMActualRequestedAmt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMSubmitChannel__c,GlobalConstants.NON_CMAS);
		System.assertEquals(resultAppHis.RMCreditModel__c,'FL');
		System.assertEquals(resultAppHis.SP_Approve_Option__c,'D');
		System.assertEquals(resultAppHis.SP_Approved_Amt__c,(GlobalUtility.toDecimal(resultTransact.SM_P1_Offer_Amount_B__c)+GlobalUtility.toDecimal(resultTransact.SM_P2_Offer_Amount_B__c)+GlobalUtility.toDecimal(resultTransact.SM_P3_Offer_Amount_B__c)+GlobalUtility.toDecimal(resultTransact.SM_P4_Offer_Amount_B__c)+GlobalUtility.toDecimal(resultTransact.SM_P5_Offer_Amount_B__c)));
		System.assertEquals(resultAppHis.SP_CAPF_Received_DT__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.TentativeSubmitDate__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.SP_CAPB_Workout_DT__c,Date.newinstance(Integer.valueOf(yearUwDatePost),Integer.valueOf(monthUwDatePost),Integer.valueOf(dayUwDatePost)));
		System.assertEquals(resultAppHis.SP_Approval_Result__c,GlobalConstants.FINAL_APPROVE);
		System.assertEquals(resultAppHis.SP_UW_Name__c,newTransact.UW_Code__c);
		System.assertEquals(resultAppHis.SP_UWA_Name__c,newTransact.UWA_Code__c);
	}

	@isTest static void createTransactCustomerOptionCAndHasOpportunityAndHasFirstAppHisThenCreateApplicationHistoryCustomerOptionC() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
        applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
       	applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);
		Application_History__c newAppHis;
		Opportunity newOpp;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS); insert newOpp;
            newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
        }

		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.Customer_Option_A__c = 'N';
		newTransact.Customer_Option_B__c = 'N';
		newTransact.Customer_Option_C__c = 'Y';
		newTransact.Customer_Option_D__c = 'N';
		insert newTransact;
		
		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c,SM_P1_Offer_Amount_C__c,SM_P2_Offer_Amount_C__c,SM_P3_Offer_Amount_C__c,SM_P4_Offer_Amount_C__c,SM_P5_Offer_Amount_C__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		System.assertEquals(resultAppHis.IsActive__c,true);
		System.assertEquals(resultAppHis.AppNum_NonCMAS__c,newTransact.Application_No_From_BP_SF__c);
		//System.assertEquals(resultAppHis.SP_Submit_Issue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.RMSubmitIssue__c,GlobalConstants.NEW_CREDIT);
		System.assertEquals(resultAppHis.SPBusinessCode__c,resultTransact.Business_Code__c);
		System.assertEquals(resultAppHis.SP_Requested_Amt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMActualRequestedAmt__c,(GlobalUtility.toDecimal(resultTransact.CR_1_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_2_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_3_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_4_Amount_Requested__c)+GlobalUtility.toDecimal(resultTransact.CR_5_Amount_Requested__c)));
		System.assertEquals(resultAppHis.RMSubmitChannel__c,GlobalConstants.NON_CMAS);
		System.assertEquals(resultAppHis.RMCreditModel__c,'FL');
		System.assertEquals(resultAppHis.SP_Approve_Option__c,'D');
		System.assertEquals(resultAppHis.SP_Approved_Amt__c,(GlobalUtility.toDecimal(resultTransact.SM_P1_Offer_Amount_C__c)+GlobalUtility.toDecimal(resultTransact.SM_P2_Offer_Amount_C__c)+GlobalUtility.toDecimal(resultTransact.SM_P3_Offer_Amount_C__c)+GlobalUtility.toDecimal(resultTransact.SM_P4_Offer_Amount_C__c)+GlobalUtility.toDecimal(resultTransact.SM_P5_Offer_Amount_C__c)));
		System.assertEquals(resultAppHis.SP_CAPF_Received_DT__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.TentativeSubmitDate__c,Date.newinstance(Integer.valueOf(year),Integer.valueOf(month),Integer.valueOf(day)));
		System.assertEquals(resultAppHis.SP_CAPB_Workout_DT__c,Date.newinstance(Integer.valueOf(yearUwDatePost),Integer.valueOf(monthUwDatePost),Integer.valueOf(dayUwDatePost)));
		System.assertEquals(resultAppHis.SP_Approval_Result__c,GlobalConstants.FINAL_APPROVE);
		System.assertEquals(resultAppHis.SP_UW_Name__c,newTransact.UW_Code__c);
		System.assertEquals(resultAppHis.SP_UWA_Name__c,newTransact.UWA_Code__c);
	}

	

	@isTest static void createTransactApproveOptionFinalApproveThenCreateApplicationHistoryAndCreateOppProduct() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
        applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
       	applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);

		Application_History__c newAppHis;
		Opportunity newOpp;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
        }
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

        insertPrioriyMaster();
		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.CR_1_Category__c = 'Product 1';
		newTransact.CR_2_Category__c = 'Product 2';
		newTransact.CR_3_Category__c = 'Product 3';
		newTransact.CR_4_Category__c = 'Product 4';
		newTransact.CR_5_Category__c = 'Product 5';
		insert newTransact;
		
		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,ProductNameMain__c,ProductGroupPP__c,ProductNameMain2__c,ProductNameSub__c,Campcode__c,Pcode__c,PID__c,Ptype__c,PriorityRank__c,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);

		List<Credit_Info__c> listCreditInfo = [SELECT Id,Product_Name__c,Requested_Amount__c FROM Credit_Info__c WHERE Application_History__c = :resultAppHis.Id];
		System.assertEquals(5,listCreditInfo.size());
		System.assertEquals('Product 1',listCreditInfo[0].Product_Name__c);
		System.assertEquals('Product 2',listCreditInfo[1].Product_Name__c);
		System.assertEquals('Product 3',listCreditInfo[2].Product_Name__c);
		System.assertEquals('Product 4',listCreditInfo[3].Product_Name__c);
		System.assertEquals('Product 5',listCreditInfo[4].Product_Name__c);
		System.assertEquals(1,listCreditInfo[0].Requested_Amount__c);
		System.assertEquals(2,listCreditInfo[1].Requested_Amount__c);
		System.assertEquals(3,listCreditInfo[2].Requested_Amount__c);
		System.assertEquals(4,listCreditInfo[3].Requested_Amount__c);
		System.assertEquals(5,listCreditInfo[4].Requested_Amount__c);
	}

	//passs

	@isTest static void updateTransactApproveOptionFinalApproveThenRemoveOldAppProductAndRemoveOldOppProductAndCreateNewAppProductOppProduct() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
        User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
        applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
       	applicationNoR2 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,2);
		Application_History__c newAppHis;
		Opportunity newOpp;
		TransactBP__c newTransact1;
		TransactBP__c newTransact2;
		TransactBP__c updateTransact2;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
        }

        TriggerHandler.bypass('OpportunityTriggerHandler');
        update newOpp;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');
        insertPrioriyMaster();

        Test.startTest();
        newTransact1 = newTransact(applicationNoR1);
		newTransact1.CR_1_Category__c = 'Product 1';
		newTransact1.CR_2_Category__c = 'Product 2';
		newTransact1.CR_3_Category__c = 'Product 3';
		newTransact1.CR_4_Category__c = 'Product 4';
		newTransact1.CR_5_Category__c = 'Product 5';
		insert newTransact1;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update newOpp;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');

		newTransact2 = newTransact(applicationNoR2);
		newTransact2.CR_1_Category__c = 'Product transact 21';
		newTransact2.CR_2_Category__c = 'Product transact 22';
		newTransact2.CR_3_Category__c = 'Product transact 23';
		newTransact2.CR_4_Category__c = 'Product transact 24';
		newTransact2.CR_5_Category__c = 'Product transact 25';
		insert newTransact2;

        TriggerHandler.bypass('OpportunityTriggerHandler');
        update newOpp;
        TriggerHandler.clearbypass('OpportunityTriggerHandler');

		updateTransact2 = new TransactBP__c();
		updateTransact2.Id = newTransact2.Id;
		updateTransact2.Application_No_From_BP_SF__c = applicationNoR2;
		updateTransact2.CR_1_Category__c = 'Product transact 21 updated';
		updateTransact2.CR_2_Category__c = 'Product transact 22 updated';
		updateTransact2.CR_3_Category__c = 'Product transact 23 updated';
		updateTransact2.CR_4_Category__c = 'Product transact 24 updated';
		updateTransact2.CR_5_Category__c = 'Product transact 25 updated';
		update updateTransact2;
		Test.stopTest();
		List<Application_History__c> allAppHis = [SELECT ID FROM Application_History__c];
		System.debug('allAppHis size1 :'+allAppHis.size());

		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact2.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,ProductNameMain__c,ProductGroupPP__c,ProductNameMain2__c,ProductNameSub__c,Campcode__c,Pcode__c,PID__c,Ptype__c,PriorityRank__c,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :updateTransact2.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);
		List<Credit_Info__c> listCreditInfo = [SELECT Id,Product_Name__c,Requested_Amount__c FROM Credit_Info__c WHERE Application_History__c = :resultAppHis.Id];
		System.assertEquals(5,listCreditInfo.size());
		System.assertEquals('Product transact 21 updated',listCreditInfo[0].Product_Name__c);
		System.assertEquals('Product transact 22 updated',listCreditInfo[1].Product_Name__c);
		System.assertEquals('Product transact 23 updated',listCreditInfo[2].Product_Name__c);
		System.assertEquals('Product transact 24 updated',listCreditInfo[3].Product_Name__c);
		System.assertEquals('Product transact 25 updated',listCreditInfo[4].Product_Name__c);

	}

	@isTest static void createTransactApproveOptionFinalApproveAndDuplicateProductNameThenSumRequestAmountAndSumApproveAmount() {
		User runningUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];
    	User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		applicationNo = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,0);
		applicationNoR1 = getMockapplicationNo(rmUser.Job_Code__c,rmUser.Rc_Code__c,1);
   		applicationNoR2 = getMockapplicationNo(runningUser.Job_Code__c,runningUser.Rc_Code__c,2);
		Application_History__c newAppHis;
		Opportunity newOpp;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		System.runAs(rmUser){
            newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
        }
        
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');

        insertPrioriyMaster();
		
		Test.startTest();
		TransactBP__c newTransact = newTransact(applicationNoR1);
		newTransact.CR_1_Category__c = 'Product 1';
		newTransact.CR_2_Category__c = 'Product 2';
		newTransact.CR_3_Category__c = 'Product 2';
		newTransact.CR_4_Category__c = 'Product 3';
		newTransact.CR_5_Category__c = 'Product 3';
		insert newTransact;
		Test.stopTest();

		TransactBP__c resultTransact = [SELECT Id,Application_History__c,Business_Code__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c FROM TransactBP__c WHERE Id = :newTransact.Id LIMIT 1];
		Application_History__c resultAppHis = [SELECT Id,ProductNameMain__c,ProductGroupPP__c,ProductNameMain2__c,ProductNameSub__c,Campcode__c,Pcode__c,PID__c,Ptype__c,PriorityRank__c,IsActive__c,SP_UW_Name__c,SP_CAPB_Workout_DT__c,SP_UWA_Name__c,SP_Approval_Result__c,SP_CAPF_Received_DT__c,TentativeSubmitDate__c,SP_Approved_Amt__c,SP_Approve_Option__c,RMCreditModel__c,AppNum_NonCMAS__c,RMSubmitChannel__c,SP_Submit_Issue__c,RMSubmitIssue__c,SPBusinessCode__c,SP_Requested_Amt__c,RMActualRequestedAmt__c FROM Application_History__c WHERE AppNum_NonCMAS__c = :newTransact.Application_No_From_BP_SF__c LIMIT 1];
		System.assertEquals(resultAppHis.Id,resultTransact.Application_History__c);

		List<Credit_Info__c> listCreditInfo = [SELECT Id,Product_Name__c,Requested_Amount__c,Approved_Amount__c FROM Credit_Info__c WHERE Application_History__c = :resultAppHis.Id];
		System.assertEquals(3,listCreditInfo.size());
		System.assertEquals('Product 1',listCreditInfo[0].Product_Name__c);
		System.assertEquals('Product 2',listCreditInfo[1].Product_Name__c);
		System.assertEquals('Product 3',listCreditInfo[2].Product_Name__c);
		System.assertEquals(1,listCreditInfo[0].Requested_Amount__c);
		System.assertEquals(5,listCreditInfo[1].Requested_Amount__c);
		System.assertEquals(9,listCreditInfo[2].Requested_Amount__c);
		System.assertEquals(10,listCreditInfo[0].Approved_Amount__c);
		System.assertEquals(50,listCreditInfo[1].Approved_Amount__c);
		System.assertEquals(90,listCreditInfo[2].Approved_Amount__c);
	}

	@isTest static void closeApplicationWhenRelatedToOpportunityProduct() {
		User rmUser = [SELECT Id,ProfileId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
        Product2 product = new Product2(Name = 'Deposit', Product_Code__c = 'P001', IsActive = true);
        insert product;
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 1,
            IsActive = product.IsActive
        );
        insert pricebookEntry;

		System.runAs(rmUser) {
			Opportunity newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            Application_History__c newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
			insert new OpportunityLineItem(
                OpportunityId = newOpp.Id,
                PricebookEntryId = pricebookEntry.Id,
                Application__c = newAppHis.Id
            );
			
			Test.startTest();
			Application_History__c editAppHis = [SELECT Id, App_Result__c, Request_Process_Name__c FROM Application_History__c WHERE Id = :newAppHis.Id];
			editAppHis.Request_Process_Name__c = 'Closed Lost';
			editAppHis.App_Result__c = GlobalConstants.CLOSED_WON;
			update editAppHis;
			Test.stopTest();

			System.assertEquals(newAppHis.Id, editAppHis.Id);
			System.assertEquals(GlobalConstants.CLOSED_WON, editAppHis.App_Result__c);
		}
	}

	@isTest static void errorUpdateApplicationWhenApplicationClosed() {
		User rmUser = [SELECT Id,ProfileId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		User tmUser = [SELECT Id,ProfileId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		String errorMessage = '';
		User_Management__c userManagement = new User_Management__c(
			SetupOwnerId = tmUser.ProfileId,
			Allow_Change_Opportunity__c = false
		);
		insert userManagement;

		System.runAs(rmUser) {
            Opportunity newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            Application_History__c newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;

			Application_History__c editAppHis = [SELECT Id, App_Result__c, Report_Actual_Visit_Date__c, Request_Process_Name__c FROM Application_History__c WHERE Id = :newAppHis.Id];
			editAppHis.Report_Actual_Visit_Date__c = System.today();
			editAppHis.App_Result__c = GlobalConstants.CLOSE_LOST;
			update editAppHis;

			try {
				System.runAs(tmUser) {
					editAppHis.App_Result__c = GlobalConstants.WORK_IN_PROGRESS;
					update editAppHis;
				}
			} catch(Exception e) {
				errorMessage = e.getMessage();
			}

			System.assert(errorMessage.contains(Label.App_Not_Allow_Edit_Closed));
        }
	}

	@isTest static void errorCloseApplicationWhenNotRelatedToOpportunityProduct() {
		User rmUser = [SELECT Id,ProfileId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
		String errorMessage = '';

		System.runAs(rmUser) {
			Opportunity newOpp = Mockup_Test.newOpportunity(account.Id, 'Test Opp 1', GlobalConstants.JOB_DEVNAME, GlobalConstants.NON_CMAS);
            insert newOpp;
            Application_History__c newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, '', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
            insert newAppHis;
			
			Application_History__c editAppHis = [SELECT Id, App_Result__c, Request_Process_Name__c FROM Application_History__c WHERE Id = :newAppHis.Id];
			editAppHis.App_Result__c = GlobalConstants.CLOSED_WON;
			try {
				update editAppHis;
			} catch(Exception e) {
				errorMessage = e.getMessage();
			}

			System.assert(errorMessage.contains(Label.Not_Allow_Close_Won_App));
		}
	}
}