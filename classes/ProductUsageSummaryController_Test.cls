@isTest
private class ProductUsageSummaryController_Test {
	private static final String CIS_ACCOUNT = '000000099'; 
	private static final String CIS_ACCOUNT_PERSON_KBANK = '0000000199'; 

	@TestSetup
	static void makeData(){
		createAccount();
		createColumnHeader();
		createFinancialAccount();
	}
	
	private static void createAccount(){
		List<Account> accountList = new List<Account>();
		accountList.add(newAccount('name001',CIS_ACCOUNT_PERSON_KBANK,ProductUsageSummaryController.PERSONTYPE_KBANK));
		accountList.add(newAccount('name007',CIS_ACCOUNT,null));
		insert accountList;
	}

	private static Account newAccount(String name,String cisId,String personType){
		Account accountObj = new Account();
		accountObj.Name = name;
		accountObj.CIS__c = cisId;
		accountObj.Person_Type__c = personType;
		return accountObj;
	}

	private static void createFinancialAccount(){
		List<FinServ__FinancialAccount__c> finAccList = new List<FinServ__FinancialAccount__c>();
		Account accountObj = [SELECT Id FROM Account WHERE CIS__c = :CIS_ACCOUNT];
		Account accountPersonKbank = [SELECT Id FROM Account WHERE CIS__c = :CIS_ACCOUNT_PERSON_KBANK];
		finAccList.add(newFinancialAccount('name001',accountObj,'ATM','1','156.17'));
		finAccList.add(newFinancialAccount('name002',accountObj,'SA','2','15000'));
		finAccList.add(newFinancialAccount('name003',accountObj,'FIX','1','163329.2'));
		finAccList.add(newFinancialAccount('name004',accountObj,'OD','2','30000'));
		finAccList.add(newFinancialAccount('name005',accountObj,'CRCARD','1','0'));
		finAccList.add(newFinancialAccount('name006',accountObj,'ADV','2','2000000'));

		finAccList.add(newFinancialAccount('name007',accountPersonKbank,'SA','2','2000000'));
		finAccList.add(newFinancialAccount('name008',accountPersonKbank,'FIX','1','100000'));
		finAccList.add(newFinancialAccount('name009',accountPersonKbank,'HL','1','1500000'));
		insert finAccList;
	}

	private static FinServ__FinancialAccount__c newFinancialAccount(String name,Account accountObj,String productCode,String quantity,String balance){
		FinServ__FinancialAccount__c finAccObj = new FinServ__FinancialAccount__c();
		finAccObj.Name = name;
		finAccObj.Product_Code__c = productCode;
		finAccObj.Quantity_Unit__c = Decimal.valueOf(quantity.trim());
		finAccObj.FinServ__Balance__c = Decimal.valueOf(balance.trim());
		finAccObj.FinServ__PrimaryOwner__c = accountObj.Id;
		finAccObj.IsActive__c = true;
		return finAccObj;
	}

	private static void createColumnHeader() {
		List<Product_Usage_Config__c> configList = new List<Product_Usage_Config__c>();
		configList.add(newColumnHeader('name001', 'Product Name', 'ชื่อผลิตภัณฑ์', 1));
		configList.add(newColumnHeader('name002', 'Unit', 'จำนวน', 2));
		configList.add(newColumnHeader('name003', 'Limit', 'วงเงิน', 3));
		configList.add(newColumnHeader('name004', 'Outstanding', 'ยอดเงินคงเหลือ', 4));
		insert configList;
	}

	private static Product_Usage_Config__c newColumnHeader(String name, String enLabel, String thLabel, Decimal order) {
		Product_Usage_Config__c productConfig = new Product_Usage_Config__c();
		productConfig.Name = name;
		productConfig.EN_Label__c = enLabel;
		productConfig.TH_Label__c = thLabel;
		productConfig.Product_Code__c = 'PRDTSMY';
		productConfig.Level__c = 1; 
		productConfig.Order__c = order;
		productConfig.Data_Type__c = 'string';
		productConfig.Visible__c = true;
		return productConfig;
	}

	@isTest
	static void testGetProductUsageSummary(){
		/* Use this code when check visibility from ProductUsageVisibilityService
		Account accountObj = [SELECT Id, Person_Type__c FROM Account WHERE CIS__c = :CIS_ACCOUNT];
		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController();
		productUsageSummaryCtrl.isVisible = true;
		productUsageSummaryCtrl.accountInfo = accountObj;
		productUsageSummaryCtrl.cisId = CIS_ACCOUNT;

		ProductUsageSummaryController.ProductUsageSummary productUsageSummary =  (ProductUsageSummaryController.ProductUsageSummary) JSON.deserialize(productUsageSummaryCtrl.getProductUsageSummary(), ProductUsageSummaryController.ProductUsageSummary.class);
		System.assertEquals(1, productUsageSummary.domainOperation.size());
		System.assertEquals(2, productUsageSummary.domainSaving.size());
		System.assertEquals(3, productUsageSummary.domainFunding.size());
		System.assertEquals(0, productUsageSummary.domainProtection.size());*/

		Account accountObj = [SELECT Id FROM Account WHERE CIS__c = :CIS_ACCOUNT];
		PageReference pageRef = Page.ProductUsage_Page;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(accountObj);
		ApexPages.currentPage().getParameters().put('id', accountObj.Id);

		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController(stdController);
		System.AssertNotEquals('', productUsageSummaryCtrl.productUsageSummary);
	}

	@isTest
	static void testGetProductUsageSummaryPersonTypeKBANKEmployee(){
		/* Use this code when check visibility from ProductUsageVisibilityService
		//Given Set up info above
		//When
		Account accountObj = [SELECT Id, Person_Type__c FROM Account WHERE CIS__c = :CIS_ACCOUNT_PERSON_KBANK];
		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController();
		productUsageSummaryCtrl.isVisible = true;
		productUsageSummaryCtrl.accountInfo = accountObj;
		productUsageSummaryCtrl.cisId = CIS_ACCOUNT_PERSON_KBANK;

		//Then
		ProductUsageSummaryController.ProductUsageSummary productUsageSummary =  (ProductUsageSummaryController.ProductUsageSummary) JSON.deserialize(productUsageSummaryCtrl.getProductUsageSummary(), ProductUsageSummaryController.ProductUsageSummary.class);
		System.assertEquals(0, productUsageSummary.domainOperation.size());
		System.assertEquals(1, productUsageSummary.domainSaving.size());
		System.assertEquals(1, productUsageSummary.domainFunding.size());
		System.assertEquals(0, productUsageSummary.domainProtection.size());*/

		//Given Set up info above
		//When
		Account accountObj = [SELECT Id,Person_Type__c FROM Account WHERE CIS__c = :CIS_ACCOUNT_PERSON_KBANK];
		PageReference pageRef = Page.ProductUsage_Page;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(accountObj);
		ApexPages.currentPage().getParameters().put('id', accountObj.Id);

		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController(stdController);
		//Then
		ProductUsageSummaryController.ProductUsageSummary productUsageSummary =  (ProductUsageSummaryController.ProductUsageSummary) JSON.deserialize(productUsageSummaryCtrl.productUsageSummary, ProductUsageSummaryController.ProductUsageSummary.class);
		System.assertEquals(0, productUsageSummary.domainOperation.size());
		System.assertEquals(1, productUsageSummary.domainSaving.size());
		System.assertEquals(1, productUsageSummary.domainFunding.size());
		System.assertEquals(0, productUsageSummary.domainProtection.size());
	}

	@isTest
	static void testGetProductUsageSummaryWhenNotVisible(){
		/* Use this code when check visibility from ProductUsageVisibilityService
		Account accountObj = [SELECT Id FROM Account WHERE CIS__c = :CIS_ACCOUNT];
		PageReference pageRef = Page.ProductUsage_Page;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(accountObj);
		ApexPages.currentPage().getParameters().put('id', accountObj.Id);

		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController(stdController);
		ProductUsageSummaryController.ProductUsageSummary productUsageSummary =  (ProductUsageSummaryController.ProductUsageSummary) JSON.deserialize(productUsageSummaryCtrl.productUsageSummary, ProductUsageSummaryController.ProductUsageSummary.class);
		System.assertEquals(0, productUsageSummary.domainOperation.size());
		System.assertEquals(0, productUsageSummary.domainSaving.size());
		System.assertEquals(0, productUsageSummary.domainFunding.size());
		System.assertEquals(0, productUsageSummary.domainProtection.size());*/

		Account accountObj = [SELECT Id, Person_Type__c FROM Account WHERE CIS__c = :CIS_ACCOUNT];
		ProductUsageSummaryController productUsageSummaryCtrl = new ProductUsageSummaryController();
		productUsageSummaryCtrl.isVisible = false;
		productUsageSummaryCtrl.accountInfo = accountObj;
		productUsageSummaryCtrl.cisId = CIS_ACCOUNT;

		ProductUsageSummaryController.ProductUsageSummary productUsageSummary =  (ProductUsageSummaryController.ProductUsageSummary) JSON.deserialize(productUsageSummaryCtrl.getProductUsageSummary(), ProductUsageSummaryController.ProductUsageSummary.class);
		System.assertEquals(0, productUsageSummary.domainOperation.size());
		System.assertEquals(0, productUsageSummary.domainSaving.size());
		System.assertEquals(0, productUsageSummary.domainFunding.size());
		System.assertEquals(0, productUsageSummary.domainProtection.size());
	}
}