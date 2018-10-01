@isTest
private class CBS_OpptPlanningCallReport_Test {
	public static String accName = 'testAccount';

	public static String pruductGruop_Transaction = 'Transaction';
	public static String productName_SBLC = 'SBLC';

	@testSetup static void setUpCallReport(){
		setUpProductMasterData();
		Test.startTest();
		Mockup_Test mt = new Mockup_Test();
		mt.setUpTest();

		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = new Account(
				Name = accName,
				CIS__c = '22222',
				Primary_Segment_Code__c = 'CB',
				Port_Pool__c = GlobalConstants.PORT,
				Birthdate_Registration_Date__c = System.today().addYears(-10),
				Identification_No_Prospect__c = '222222222222222');

			insert account;
			
			Call_Report__c callReport = new Call_Report__c();
				callReport.Actual_Visit_Date__c = System.today() - 3;
	            callReport.Plan_Amount__c = 6000;
	            callReport.CIS_ID__c = account.Id;
	            callReport.Offer_Credit_Product__c = true;
	            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
	            callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	            callReport.Expected_Credit_Amount__c = 5000;
	            callReport.Contact_Firstname__c = 'abc';
	            callReport.Contact_Lastname__c = 'def';
	            callReport.Contact_Phone__c = '123456789';
            insert callReport;

			Map<String,Product_List_Master__c> cbsProductConfigMapByCode = CBS_Utility.getCBSProductConfigMapByProductCode();

			Opportunity_Planning__c oppPlanning = new Opportunity_Planning__c(
				CIS_ID__c = account.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				New_Limit__c = 10000,
				Volume_Outstanding__c = 10000,
				Front_End_Fee__c = 10000,
				Fee__c = 10000,
				Remark__c = 'remark'
			);
			insert oppPlanning;

			List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();

			Opportunity_Planning_Line_Item__c productLineItem = new Opportunity_Planning_Line_Item__c(
				Product_Name__c  = cbsProductConfigMapByCode.values().get(0).Product_Name__c,
	        	Opportunity_Planning__c = oppPlanning.Id,
	        	Call_Report_Product_List_Master__c = cbsProductConfigMapByCode.values().get(0).id
			);

			newLineItems.add(productLineItem);
	        insert newLineItems;
		}
	}

	public static void setUpProductMasterData(){
		RecordType rt = [SELECT id From RecordType WHERE SObjectType ='Product_List_Master__c' AND DeveloperName =:GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_CBS LIMIT 1];
		List<Product_List_Master__c> callReportProductListMaster = new List<Product_List_Master__c>();
		Product_List_Master__c productMaster = Mockup_Test.newProductMasterCBS(CBS_OpptPlanningCallReport_Test.pruductGruop_Transaction,1,CBS_OpptPlanningCallReport_Test.productName_SBLC,1,rt.id);
		callReportProductListMaster.add(productMaster);
		insert callReportProductListMaster;
	}

	
	@isTest static void testController() {
		System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userCBSFirstNameRM][0]){
			Account account = [SELECT Id FROM Account WHERE Name =: accName];
			Call_Report__c callReport = [SELECT Id FROM Call_Report__c WHERE CIS_ID__C =: account.Id];

			Test.setCurrentPageReference(new PageReference('Page.CBS_OpptPlanningCallReport'));
			System.currentPageReference().getParameters().put('Id', callreport.id);

			ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
			CBS_OpptPlanningCallReport_Controller callReportOppt = new CBS_OpptPlanningCallReport_Controller(stdController);
			
			System.assertEquals(1,callReportOppt.oppPlanningMapByproductGroup.get(CBS_OpptPlanningCallReport_Test.pruductGruop_Transaction).size());
		}
		
	}
}