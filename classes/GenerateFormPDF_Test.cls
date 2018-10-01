@isTest
private class GenerateFormPDF_Test {
	private static String PDF_NAME1 = 'Demo_Form';
	private static String PDF_NAME2 = 'Doc_KPLUS_SME_O_TH';

	//@testSetup static void mockupTest(){
	//	List<GenerateFormPDFSetting__c> generateFormPDFSettingList = new List<GenerateFormPDFSetting__c>();
 //       generateFormPDFSettingList = [SELECT Name, Form_Name__c, Page_Name__c FROM GenerateFormPDFSetting__c];
	//	System.runAs(new User(Id=UserInfo.getUserId())){
 //           GenerateFormPDFSetting__c mSetting = new GenerateFormPDFSetting__c();
 //           mSetting.Name = PDF_NAME1;
 //           mSetting.Page_Name__c = 'Demo_Form';
	//		mSetting.Form_Name__c = 'แบบฟอร์มสำหรับทดสอบ';
	//		insert mSetting;

	//		GenerateFormPDFSetting__c mSetting2 = new GenerateFormPDFSetting__c();
	//		mSetting2.Name = PDF_NAME2;
 //           mSetting2.Page_Name__c = 'Doc_KPLUS_SME_O_TH';
	//		mSetting2.Form_Name__c = 'ใบคำขอสมัครบริการ K PLUS SME (บัญชีนิติบุคคล)_TH';
	//		insert mSetting2;

	//		insert new Allow_Generate_PromptPay_Form__c(Name='O');
 //       }
	//}
	
	//@isTest static void testGetFormNameList() {
	//	String respString = GenerateFormPDFApexController.getFormNameList();
	//	List<GenerateFormPDFSetting__c> formPDFSettingList = (List<GenerateFormPDFSetting__c>) JSON.deserialize(respString, List<GenerateFormPDFSetting__c>.class);
		
	//	Integer countName = 0;
	//	for(GenerateFormPDFSetting__c eachSetting : formPDFSettingList) {
	//		if(eachSetting.Name == PDF_NAME1 || eachSetting.Name == PDF_NAME2) {
	//			countName++;
	//			continue;
	//		}
	//	}
	//	System.assertEquals(formPDFSettingList.size(), countName);
	//}
	
	//@isTest static void testNegativeValidate() {
	//	String respString = GenerateFormPDFApexController.validatePermission('InvalidId');
	//	GenerateFormPDFApexController.ResultResponse resultResp = (GenerateFormPDFApexController.ResultResponse) JSON.deserialize(respString, GenerateFormPDFApexController.ResultResponse.class);
	//	System.assertEquals(GenerateFormPDFApexController.ERROR, resultResp.result);
	//}

	//@isTest static void testNegativeCreateHistory() {
	//	String respString = GenerateFormPDFApexController.createHistory('InvalidId', 'Demo_Form');
	//	GenerateFormPDFApexController.ResultResponse resultResp = (GenerateFormPDFApexController.ResultResponse) JSON.deserialize(respString, GenerateFormPDFApexController.ResultResponse.class);
	//	System.assertEquals(GenerateFormPDFApexController.ERROR, resultResp.result);
	//}
}