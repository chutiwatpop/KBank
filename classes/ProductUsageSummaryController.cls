public with sharing class ProductUsageSummaryController {
	public String productUsageSummary {get;set;}
	public Boolean isMobile { get; set; }
	public String accountId { get; set; }
	public String cisId { get; set; }
	public Boolean isVisible { get; set; }
	private List<String> productCodeOdDomainOperation;
	private List<String> productCodeOfDomainSaving;
	private List<String> productCodeOfDomainFunding;
	private List<String> productCodeOfDomainProtection;
	private IProductUsageConfig productUsageConfig;
	@TestVisible
	private Account accountInfo;
	public static final String PERSONTYPE_KBANK = '0707';

	public ProductUsageSummaryController() {
		this.productUsageConfig = new ProductUsageConfig();
		setProductCodeOfEachDomain();
	}

	public ProductUsageSummaryController(ApexPages.StandardController stdController) {
		isMobile = UserInfo.getUiTheme() == 'Theme4t';
		accountId = ApexPages.currentPage().getParameters().get('id');
		this.productUsageConfig = new ProductUsageConfig();
		getCisIdFromAccountId();
		setProductCodeOfEachDomain();
		ProductUsageVisibilityService visibilityService = new ProductUsageVisibilityService(accountId);
		isVisible = true; // Mock and wait to release at PPE deployment 25/09 | visibilityService.isVisible();
		productUsageSummary = getProductUsageSummary();
	}

	private void getCisIdFromAccountId() {
		this.accountInfo = [SELECT CIS__c,Person_Type__c FROM Account WHERE Id = :accountId LIMIT 1];
		cisId = accountInfo.CIS__c;
	}

	private void setProductCodeOfEachDomain() {
		productCodeOdDomainOperation = new List<String>{'ATM'};
		productCodeOfDomainSaving = new List<String>{'SA', 'FIX', 'TWD', 'CRN', 'FCD', 'FND', 'FIXMOCK'};
		productCodeOfDomainFunding = new List<String>{'OD', 'CRCARD', 'KXCARD', 'COM', 'PN', 'LG', 'AV', 'ACPT', 'HL', 'KPL', 'ADV'};
		productCodeOfDomainProtection = new List<String>(); 
	}

	private void setColumnHeaderInfo(ProductUsageSummary productUsageSummary) {
		productUsageSummary.columnHeaderLabels = new List<String>();
		List<ProductUsageController.ProductUsageField> columns = productUsageConfig.getColumnHeaders('PRDTSMY', 1);
		for (ProductUsageController.ProductUsageField columnItem : columns) {
			productUsageSummary.columnHeaderLabels.add(columnItem.text);
		}
	}

	public String getProductUsageSummary() {
		ProductUsageSummary productUsageSummary;
		if(cisId == '8001'){
			productUsageSummary = getProductUsageMock();
			return JSON.serialize(productUsageSummary);
		}
		if(isVisible) {
			productUsageSummary = getProductUsage();
		} else {//Send empty object when user can not view data
			productUsageSummary = new ProductUsageSummary();
			setColumnHeaderInfo(productUsageSummary);
		}
		
		return JSON.serialize(productUsageSummary);
	}

	private ProductUsageSummary getProductUsageMock() {
		ProductUsageSummary productUsageSummary = new ProductUsageSummary();

		// Column Header
		setColumnHeaderInfo(productUsageSummary);
		// Domain 1
		productUsageSummary.domainOperation.add(getNewFinancialAccount('K-ATM/K-Debit (KB)', 'ATM', 10000.00, 10000.00, 1.00));
		// Domain 2
		productUsageSummary.domainSaving.add(getNewFinancialAccount('Savings (KB)', 'SA', 0, 1000.00, 2.00));
		productUsageSummary.domainSaving.add(getNewFinancialAccount('Fixed Deposit (KB)', 'FIX', 0, 50000.00, 1.00));
		productUsageSummary.domainSaving.add(getNewFinancialAccount('Fixed Deposit (KB) (Mock)', 'FIXMOCK', 0, 50000.00, 1.00));
		productUsageSummary.domainSaving.add(getNewFinancialAccount('Taweesup (KB)', 'TWD', 0, 20000.00, 1.00));
		productUsageSummary.domainSaving.add(getNewFinancialAccount('FCD (KB)', 'FCD', 0, 9000.00, 1.00));
		productUsageSummary.domainSaving.add(getNewFinancialAccount('Current (KB)', 'CRN', 1000000.00, 9123.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('K-Mutual Fund (KA)', 'FND', 240000.00, 1222.00, 1.00));
		// Domain 3
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Current with Limit-OD (KB)', 'OD', 1000000.00, 9123.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-PN (KB)', 'PN', 100000.00, 9876.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('K-KEC (KB)', 'KXCARD', 400000.00, 1234.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('K-Credit Card (KB)', 'CRCARD', 500000.00, 1222.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-HomeLoan (KB)', 'HL', 10000.00, 1522.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-PersonalLoan (KB)', 'KPL', 12300.00, 1222.00, 3.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-Commercial Loan (KB)', 'COM', 300000.00, 2500000.00, 3.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-Advancement (KB)', 'ADV', 700000.00, 1122.00, 1.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-PromissoryNote (KB)', 'PN', 500000.00, 3122.00, 6.00));
		productUsageSummary.domainFunding.add(getNewFinancialAccount('Lending-LG (KB)', 'LG', 517000.00, 3122.00, 19.00));

		return productUsageSummary;
	}

	private FinancialAccountModel getNewFinancialAccount(String name, String productCode, decimal totalCreditLimit, decimal balance, decimal quantityUnit) {
		FinancialAccountModel financialAccountRet = new FinancialAccountModel();
		FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();

		financialAccount.Name = name;
		financialAccount.Product_Code__c = productCode;
		financialAccount.Quantity_Unit__c = quantityUnit;
		financialAccount.FinServ__TotalCreditLimit__c = totalCreditLimit;
		financialAccount.FinServ__Balance__c = balance;

		financialAccountRet = transformFinancialAccount(financialAccount);

		return financialAccountRet;
	}

	private FinancialAccountModel transformFinancialAccount(FinServ__FinancialAccount__c financialAccount) {
		FinancialAccountModel financialAccountRet = new FinancialAccountModel();
		financialAccountRet.Name = financialAccount.Name;
		financialAccountRet.ProductCode = financialAccount.Product_Code__c;
		financialAccountRet.QuantityUnit = financialAccount.Quantity_Unit__c == null ? '' : String.valueOf(financialAccount.Quantity_Unit__c);
		financialAccountRet.TotalCreditLimit = financialAccount.FinServ__TotalCreditLimit__c == null ? '' : String.valueOf(financialAccount.FinServ__TotalCreditLimit__c);
		financialAccountRet.Balance = financialAccount.FinServ__Balance__c == null ? '' : String.valueOf(financialAccount.FinServ__Balance__c);

		return financialAccountRet;
	}

	private ProductUsageSummary getProductUsage() {
		ProductUsageSummary productUsageSummary = new ProductUsageSummary();
		List<FinServ__FinancialAccount__c> productUsageSummarysFromDB = queryFinancialAccounts();

		// Column Header
		setColumnHeaderInfo(productUsageSummary);

		for (FinServ__FinancialAccount__c productUsageSummaryItem : productUsageSummarysFromDB) {
			if (productCodeOdDomainOperation.contains(productUsageSummaryItem.Product_Code__c.toUpperCase())) {
				productUsageSummary.domainOperation.add(transformFinancialAccount(productUsageSummaryItem));
			} else if (productCodeOfDomainSaving.contains(productUsageSummaryItem.Product_Code__c.toUpperCase())) {
				productUsageSummary.domainSaving.add(transformFinancialAccount(productUsageSummaryItem));
			} else if (productCodeOfDomainFunding.contains(productUsageSummaryItem.Product_Code__c.toUpperCase())) {
				productUsageSummary.domainFunding.add(transformFinancialAccount(productUsageSummaryItem));
			} else if (productCodeOfDomainProtection.contains(productUsageSummaryItem.Product_Code__c.toUpperCase())) {
				productUsageSummary.domainProtection.add(transformFinancialAccount(productUsageSummaryItem));
			}
		}

		return productUsageSummary;
	}

	private List<FinServ__FinancialAccount__c> queryFinancialAccounts(){
		List<FinServ__FinancialAccount__c> productUsageSummarysFromDB;
		if(PERSONTYPE_KBANK.equalsIgnoreCase(this.accountInfo.Person_Type__c)){
			productUsageSummarysFromDB = [SELECT Name, Product_Code__c, Quantity_Unit__c, FinServ__TotalCreditLimit__c, FinServ__Balance__c FROM FinServ__FinancialAccount__c WHERE Product_Code__c != 'SA' AND FinServ__PrimaryOwner__r.CIS__c = :cisId AND IsActive__c = TRUE ORDER BY Order__c];
		}else{
			productUsageSummarysFromDB = [SELECT Name, Product_Code__c, Quantity_Unit__c, FinServ__TotalCreditLimit__c, FinServ__Balance__c FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__r.CIS__c = :cisId AND IsActive__c = TRUE ORDER BY Order__c];
		}
		return productUsageSummarysFromDB;
	}

	public class ProductUsageSummary {
		public List<String> columnHeaderLabels;
		public List<FinancialAccountModel> domainOperation; // 1
		public List<FinancialAccountModel> domainSaving; // 2
		public List<FinancialAccountModel> domainFunding; // 3 
		public List<FinancialAccountModel> domainProtection; // 4

		public ProductUsageSummary() {
			columnHeaderLabels = new List<String>();
			domainOperation = new List<FinancialAccountModel>();
			domainSaving = new List<FinancialAccountModel>();
			domainFunding = new List<FinancialAccountModel>();
			domainProtection = new List<FinancialAccountModel>();
		}
	}

	public class FinancialAccountModel {
		public String Name;
		public String ProductCode;
		public String QuantityUnit;
		public String TotalCreditLimit;
		public String Balance;
	}
}