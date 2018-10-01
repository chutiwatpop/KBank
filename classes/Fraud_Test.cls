@isTest
private class Fraud_Test {
	public static Id CUSTOMER_REC_ID = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);

	@isTest static void callOutFromAccountService() {
		Account existAccount = Mockup_Test.newAccountObj('1991',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.CIS__c = '1993';
		existAccount.Exit__c = null;
		insert existAccount;

		Account_Service.Response res = Account_Service.getFraudStatus(JSON.serialize(existAccount));
        System.assertEquals(true, res.success);
        System.assertEquals(GlobalConstants.FRAUD_COLOR_BLUE, res.colorCode);
	}

	@isTest static void callOutFromAccountServiceNegative() {
		Account existAccount = Mockup_Test.newAccountObj('1995',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.CIS__c = '1995';
		existAccount.Exit__c = null;
		insert existAccount;

		Account_Service.Response res = Account_Service.getFraudStatus(JSON.serialize(existAccount));
        System.assertEquals(false, res.success);
        System.assertEquals('Customer fraud status cannot found', res.msg);
	}

	@isTest static void callOutFromFraudSection() {
		Account existAccount = Mockup_Test.newAccountObj('1991',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.CIS__c = '1991';
		existAccount.Exit__c = 'Y';
		insert existAccount;

		ApexPages.StandardController stdController = new ApexPages.StandardController(existAccount);
		SME_FraudSection_Controller fraudController = new SME_FraudSection_Controller(stdController);
		fraudController.init();
		System.assertEquals(GlobalConstants.FRAUD_COLOR_BROWN, fraudController.colorCode);
	}
	
	@isTest static void callOutFromFraudSectionNegative() {
		Account existAccount = Mockup_Test.newAccountObj('1991',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.Exit__c = null;
		insert existAccount;

		ApexPages.StandardController stdController = new ApexPages.StandardController(existAccount);
		SME_FraudSection_Controller fraudController = new SME_FraudSection_Controller(stdController);
		fraudController.init();
		System.assertEquals('Invalid request parameter', fraudController.fraudMessage);
	}

	@isTest static void callOutFromFraudWarning() {
		Account existAccount = Mockup_Test.newAccountObj('1992',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.CIS__c = '1992';
		existAccount.Exit__c = 'N';
		insert existAccount;

		Test.setCurrentPageReference(new PageReference('/apex/SME_FraudWarning_Page')); 
		System.currentPageReference().getParameters().put('existingId', existAccount.Id);
		System.currentPageReference().getParameters().put('redirectNewPage', '/');

		SME_FraudWarning_Controller fraudController = new SME_FraudWarning_Controller();
		fraudController.init();

		System.assertEquals(GlobalConstants.FRAUD_COLOR_PINK, fraudController.colorCode);

		fraudController.redirectNewPage();
	}

	@isTest static void callOutFromFraudWarningNegative() {
		Account existAccount = Mockup_Test.newAccountObj('1991',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.Exit__c = null;
		insert existAccount;

		Test.setCurrentPageReference(new PageReference('/apex/SME_FraudWarning_Page')); 
		System.currentPageReference().getParameters().put('existingId', existAccount.Id);
		System.currentPageReference().getParameters().put('redirectNewPage', null);

		SME_FraudWarning_Controller fraudController = new SME_FraudWarning_Controller();
		fraudController.init();

		System.assertEquals('Invalid request parameter', fraudController.fraudMessage);
	}

	@isTest static void callOutFromFraudWarningNegativeOther() {
		Account existAccount = Mockup_Test.newAccountObj('1990',GlobalConstants.PORT,CUSTOMER_REC_ID);
		existAccount.CIS__c = '1990';
		existAccount.Exit__c = 'WrongExit';
		insert existAccount;

		Test.setCurrentPageReference(new PageReference('/apex/SME_FraudWarning_Page')); 
		System.currentPageReference().getParameters().put('existingId', existAccount.Id);
		System.currentPageReference().getParameters().put('redirectNewPage', null);

		SME_FraudWarning_Controller fraudController = new SME_FraudWarning_Controller();
		fraudController.init();

		System.assertEquals(Label.FRAUD_ALERT, fraudController.fraudMessage);
	}
	
}