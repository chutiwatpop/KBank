@isTest
private class GenerateFormPDFApexController_Test {
    public static String M_ORGANIZATION_CUSTOMER 	= 'organizetion';
    public static String M_INDIVIDUAL_CUSTOMER 	= 'individual';
	@testSetup static void setupAccount(){
        Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        
        Test.stopTest();
        Allow_Generate_PromptPay_Form__c settings = Allow_Generate_PromptPay_Form__c.getOrgDefaults();
        settings.Customer_Type_Code_Description__c = 'O';
        settings.Name = 'O';
        insert settings;
	}

	@isTest static void validatePermissionPositive() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account accountRecord;
        System.runAs(rmUser){
        	accountRecord = Mockup_Test.newAccountObj(M_ORGANIZATION_CUSTOMER,GlobalConstants.POOL, recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME));
            accountRecord.Customer_Type_Code__c = 'O';
            insert accountRecord;
        }

		GenerateFormPDFApexController.ResultResponse resp = (GenerateFormPDFApexController.ResultResponse) JSON.deserialize(GenerateFormPDFApexController.validatePermission(accountRecord.Id, 'Promptpay_Registration_Juristic_PDF'), GenerateFormPDFApexController.ResultResponse.class);
		System.assertEquals('SUCCESS', resp.result);
	}
	
	@isTest static void validatePermissionNegative() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account accountRecord;
        System.runAs(rmUser){
            accountRecord = Mockup_Test.newAccountObj(M_INDIVIDUAL_CUSTOMER,GlobalConstants.PORT, recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME));
            accountRecord.Customer_Type_Code__c = 'I';
            insert accountRecord;
        }

		GenerateFormPDFApexController.ResultResponse resp = (GenerateFormPDFApexController.ResultResponse) JSON.deserialize(GenerateFormPDFApexController.validatePermission(accountRecord.Id, 'Promptpay_Registration_Juristic_PDF'), GenerateFormPDFApexController.ResultResponse.class);
		System.assertEquals('ERROR', resp.result);
        System.assertEquals(Label.GeneratePromptPayFormErrorMsg, resp.message);
	}
	
}