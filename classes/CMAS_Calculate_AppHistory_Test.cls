@isTest
private class CMAS_Calculate_AppHistory_Test {
	private static final String accountNameRM = 'accountNameRM';
	private static final String cmasRefNo = 'CB/0103/12822/2560/0005';
	private static final String cmasAppID = '1010101010';
	private static final String oppName = 'Test Opp 1';
	private static final String appTypeCode = '01';
	private static final String cwuStatus ='01';
	private static final String businessCode ='002020201';
	private static final String creditType='01';
	private static final String facCode1 ='105023001';
	private static final String facCode2 ='105023002';

	@testSetup static void setupAccount(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCodeOnlySme();
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
		mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		}
		User updateUserJobcode = new User(Id=UserInfo.getUserId(),Job_Code__c='ME4A',RC_Code__c='54321',Employee_ID__c = '3333333333');
		TriggerHandler.bypass('UserTriggerHandler');
		update updateUserJobcode;
		TriggerHandler.clearbypass('UserTriggerHandler');
		Test.stopTest();

		String applicationNo = '';
		Application_History__c newAppHis;
		Opportunity newOpp;
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		System.runAs(rmUser){
			newOpp = Mockup_Test.newOpportunity(account.Id, oppName, GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert newOpp;
			newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, applicationNo, GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA, 'ส่งครั้งแรก', GlobalConstants.CMAS, System.today(), 100000);
			insert newAppHis;
			newAppHis.CWU_Number__c = String.valueOf(newAppHis.Id).substring(0, 15);
			newAppHis.IS_Create_By_Integration__c = false; 
			update newAppHis;
		}


		//Mock PIM Code
		PIM__c pimObj1 = new PIM__c();
		PIM__c pimObj2 = new PIM__c();
		pimObj1.PIM_code__c = facCode1;
		pimObj1.Product_Name_English__c = 'K-Cash Connect Plus';
		pimObj1.Product_Group_English__c = 'K-Cash Management Solutions';
		pimObj1.Product_subGroup_English__c = 'K-Business Electronic Service Solutions';
		pimObj2.PIM_code__c = facCode2;
		pimObj2.Product_Name_English__c = 'K-Cash Connect Plus2';
		pimObj2.Product_Group_English__c = 'K-Cash Management Solutions2';
		pimObj2.Product_subGroup_English__c = 'K-Business Electronic Service Solutions2';


		List<PIM__c> pimList = new List<PIM__c>();
		pimList.add(pimObj1);
		pimList.add(pimObj2);

		insert pimList;
	}
	@isTest static void updateAppNoExistingAppOnly() {
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		CMAS_Workflow_History__c  cmasWFObj = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_CREATED);

		List<CMAS_Fac_Info__c> facList = new List<CMAS_Fac_Info__c>();

		CMAS_Fac_Info__c cmasFac1 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, 0, 0, 10);
		CMAS_Fac_Info__c cmasFac2 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, 10, 0, 5);
		CMAS_Fac_Info__c cmasFac3 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, 0, 5, 20);
		
		facList.add(cmasFac1);
		facList.add(cmasFac2);
		facList.add(cmasFac3);

		insert cmasObj;
		insert cmasWFObj;
		insert facList;

		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Requested_Amt__c,SP_Cancel_Requested_Amt__c,SP_Approved_Amt__c,SP_Cancel_Approved_Amt__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		Application_History__c appObj = appList.get(0);
		System.assertEquals(cmasRefNo,appObj.App_Num_CMAS__c);
		System.assertEquals(30,appObj.SP_Requested_Amt__c);
		System.assertEquals(5,appObj.SP_Cancel_Requested_Amt__c);
		System.assertEquals(5,appObj.SP_Approved_Amt__c);
		System.assertEquals(10,appObj.SP_Cancel_Approved_Amt__c);
	}
	
	@isTest static void createNewAppWhenReSubmit() {
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		CMAS_Fac_Info__c cmasFacObj = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, existing, approved, propose);
		
		List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
		CMAS_Workflow_History__c  cmasWFObj1 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_CREATED);
		CMAS_Workflow_History__c  cmasWFObj2 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_APPROVED);
		CMAS_Workflow_History__c  cmasWFObj3 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_APPROVED,GlobalConstants.CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL);
		CMAS_Workflow_History__c  cmasWFObj4 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL,GlobalConstants.CMAS_WF_ST_PENDING_RESUBMIT);
		
		wfList.add(cmasWFObj1);
		wfList.add(cmasWFObj2);
		wfList.add(cmasWFObj3);
		wfList.add(cmasWFObj4);

		insert cmasObj;
		insert cmasFacObj;
		insert wfList;
		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		Application_History__c app1 = appList.get(0);
		Application_History__c app2 = appList.get(1);
		System.assertEquals(2,appList.size());
		System.assertEquals(cmasRefNo,app1.App_Num_CMAS__c);
		System.assertEquals('A',app1.SP_Approve_Option__c);
		System.assertEquals(GlobalConstants.FINAL_APPROVE,app1.SP_Approval_Result__c);
		System.assertEquals('CB/0103/12822/60R1/0005',app2.App_Num_CMAS__c);
	}

	@isTest static void createOppProductWhenFinalApprove() {
		// Implement test code
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		
		List<CMAS_Fac_Info__c> cmasFacList = new List<CMAS_Fac_Info__c>();
		CMAS_Fac_Info__c cmasFacObj = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, existing, approved, propose);
		CMAS_Fac_Info__c cmasFacObj2 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, existing, approved, propose);
		cmasFacList.add(cmasFacObj);
		cmasFacList.add(cmasFacObj2);


		List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
		CMAS_Workflow_History__c  cmasWFObj1 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_CREATED);
		CMAS_Workflow_History__c  cmasWFObj2 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_APPROVED);
		CMAS_Workflow_History__c  cmasWFObj3 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_APPROVED,GlobalConstants.CMAS_WF_ST_CUSTOMER_ACCEPTED);
		CMAS_Workflow_History__c  cmasWFObj4 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CUSTOMER_ACCEPTED,GlobalConstants.CMAS_WF_ST_COMPLETE);
		
		wfList.add(cmasWFObj1);
		wfList.add(cmasWFObj2);
		wfList.add(cmasWFObj3);
		wfList.add(cmasWFObj4);

		insert cmasObj;
		insert cmasFacList;
		insert wfList;
		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName AND SP_Approval_Result__c=:GlobalConstants.FINAL_APPROVE ORDER BY Index__c DESC];
		Application_History__c lastFinalAppApprove = appList.get(0);
		List<Credit_Info__c> creditInfoList = [SELECT ID,Application_Number__c,Requested_Amount__c,Approved_Amount__c,Cancel_Approve__c,Cancel_Request__c FROM Credit_Info__c WHERE Application_History__c =:lastFinalAppApprove.ID ];
		System.assertEquals(2,creditInfoList.size());
	}

	//update Lead Status  new-> servicing
	@isTest static void createOppNewCreditCMASReturnServicing() {
		// Implement test code
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		


		List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
		CMAS_Workflow_History__c  cmasWFObj1 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_APPROVED);
		CMAS_Fac_Info__c cmasFacObj1 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, existing, approved, propose);
		CMAS_Fac_Info__c cmasFacObj2 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, existing, approved, propose);
		wfList.add(cmasWFObj1);
		insert cmasObj;
		insert wfList;
		insert cmasFacObj1;
		insert cmasFacObj2;
		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName AND SP_Approval_Result__c=:GlobalConstants.FINAL_APPROVE ORDER BY Index__c DESC];
		Application_History__c lastFinalAppApprove = appList.get(0);
		List<Credit_Info__c> creditInfoList = [SELECT ID,Application_Number__c,Requested_Amount__c,Approved_Amount__c,Cancel_Approve__c,Cancel_Request__c FROM Credit_Info__c WHERE Application_History__c =:lastFinalAppApprove.ID ];
		System.assertEquals(2,creditInfoList.size());
	}

	@isTest static void createOppNewServicingCMASReturnNewCredit() {
		// Implement test code
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		
		List<CMAS_Fac_Info__c> cmasFacList = new List<CMAS_Fac_Info__c>();
		CMAS_Fac_Info__c cmasFacObj = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, existing, approved, propose);
		CMAS_Fac_Info__c cmasFacObj2 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, existing, approved, propose);
		cmasFacList.add(cmasFacObj);
		cmasFacList.add(cmasFacObj2);


		List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
		CMAS_Workflow_History__c  cmasWFObj1 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_CREATED);
		CMAS_Workflow_History__c  cmasWFObj2 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_APPROVED);
		CMAS_Workflow_History__c  cmasWFObj3 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_APPROVED,GlobalConstants.CMAS_WF_ST_CUSTOMER_ACCEPTED);
		CMAS_Workflow_History__c  cmasWFObj4 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CUSTOMER_ACCEPTED,GlobalConstants.CMAS_WF_ST_COMPLETE);
		
		wfList.add(cmasWFObj1);
		wfList.add(cmasWFObj2);
		wfList.add(cmasWFObj3);
		wfList.add(cmasWFObj4);

		List<CMAS_Fac_Info__c> facList = new List<CMAS_Fac_Info__c>();

		CMAS_Fac_Info__c cmasFac1 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, 0, 0, 10);
		CMAS_Fac_Info__c cmasFac2 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, 10, 0, 5);
		CMAS_Fac_Info__c cmasFac3 = Mockup_Test.newCMAS_FAC(cmasAppID,facCode2, 0, 5, 20);
		
		facList.add(cmasFac1);
		facList.add(cmasFac2);
		facList.add(cmasFac3);
		
		insert cmasObj;
		insert cmasFacList;
		insert wfList;
		insert facList;
		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName AND SP_Approval_Result__c=:GlobalConstants.FINAL_APPROVE ORDER BY Index__c DESC];
		Application_History__c lastFinalAppApprove = appList.get(0);
		List<Credit_Info__c> creditInfoList = [SELECT ID,Application_Number__c,Requested_Amount__c,Approved_Amount__c,Cancel_Approve__c,Cancel_Request__c FROM Credit_Info__c WHERE Application_History__c =:lastFinalAppApprove.ID ];
		System.assertEquals(2,creditInfoList.size());
	}
	//update  Lead Status  servicing-> new

	@isTest static void createNewAppHaveOppVisitFromProductWhenReSubmit() {
		Date actualVisitDate = Date.newinstance(System.today().year(),System.today().month(),System.today().day());
		Application_History__c  firstApp = [SELECT ID,CWU_Number__c FROM Application_History__c WHERE RMSubmitChannel__c=:GlobalConstants.CMAS AND IS_Create_By_Integration__c = false LIMIT 1];
		firstApp.Report_Actual_Visit_Date__c = actualVisitDate;
		update firstApp; 
		String cwuRefNo = firstApp.CWU_Number__c;
		Decimal existing = 10;
		Decimal approved = 10;
		Decimal propose = 0;
		CMAS__c cmasObj = Mockup_Test.newCMAS(cwuRefNo,cmasRefNo,appTypeCode,cwuStatus,businessCode,cmasAppID,creditType);
		CMAS_Fac_Info__c cmasFacObj = Mockup_Test.newCMAS_FAC(cmasAppID,facCode1, existing, approved, propose);
		
		List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
		CMAS_Workflow_History__c  cmasWFObj1 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_CREATED);
		CMAS_Workflow_History__c  cmasWFObj2 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_CREATED,GlobalConstants.CMAS_WF_ST_APPROVED);
		CMAS_Workflow_History__c  cmasWFObj3 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_APPROVED,GlobalConstants.CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL);
		CMAS_Workflow_History__c  cmasWFObj4 = Mockup_Test.newCMAS_Workflow(cmasAppID,GlobalConstants.CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL,GlobalConstants.CMAS_WF_ST_PENDING_RESUBMIT);
		
		wfList.add(cmasWFObj1);
		wfList.add(cmasWFObj2);
		wfList.add(cmasWFObj3);
		wfList.add(cmasWFObj4);

		insert cmasObj;
		insert cmasFacObj;
		insert wfList;
		Test.startTest();
		Database.executeBatch(new CMAS_Calculate_AppHistory_Batch());
		Test.stopTest();
		List<Application_History__c> appList = [SELECT ID,Report_Actual_Visit_Date__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		Application_History__c app1 = appList.get(0);
		Application_History__c app2 = appList.get(1);
		System.assertEquals(2,appList.size());
		System.assertEquals(app1.Report_Actual_Visit_Date__c,app2.Report_Actual_Visit_Date__c);
	}

	

}