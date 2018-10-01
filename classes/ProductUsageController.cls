public class ProductUsageController {

	public String productUsageData {get;set;}
	public Boolean isMobile { get; set; }
	public String productCode {get;set;}
	public String accountId { get; set; }
	public String cisId {get;set;}
	public Boolean isVisible {get;set;}
	private IProductUsageTransformation productUsageTransformer;

	public ProductUsageController() {
		
	}

	public ProductUsageController(ApexPages.StandardController stdController) {
		isMobile = UserInfo.getUiTheme() == 'Theme4t';
		productCode = apexpages.currentpage().getparameters().get('productcode');
		cisId = apexpages.currentpage().getparameters().get('cisId');
		getAccountIdFromtCIS();
		ProductUsageVisibilityService visibilityService = new ProductUsageVisibilityService(accountId);
		isVisible =  true; // Mock and wait to release at PPE deployment 25/09 | visibilityService.isVisible();
	}

	private void getAccountIdFromtCIS() {
		Account accountInfo = [SELECT Id FROM Account WHERE CIS__c = :cisId LIMIT 1];
		accountId = accountInfo.Id;
	}

	public PageReference loadProductUsageData() {
		try {
			productUsageData = getProductUsageData(productCode);
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			String errorText = e.getMessage();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText));
		}
		return null;
	}

	public String getProductUsageData(String productCode) {
		ProductUsageModel productUsage;
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		String productUsageString;

		if (cisId == '8001') {
			if (productCode.equalsIgnoreCase('CRCARD') || productCode.equalsIgnoreCase('KXCARD')) {
				cisId = productCode.equalsIgnoreCase('CRCARD') ? '6552814' : '114';
				productUsageTransformer = new TransformationCcKec(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('ATM')){
				//cisId = '6992582';
				cisId = '37502';
				productUsageTransformer = new TransformationAtmDebit(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('SA')){
				cisId = '11';
				productUsageTransformer = new TransformationSaving(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('FIX')){
				cisId = '3003851';
				productUsageTransformer = new TransformationFixed(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('TWD')){
				cisId = '7387391';
				productUsageTransformer = new TransformationTaweesup(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('FCD')){
				cisId = '17680848';
				productUsageTransformer = new TransformationFCD(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('FND')){
				cisId = '26495254';
				productUsageTransformer = new TransformationMutualFund(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('CRN')){
				cisId = '72733';
				productUsageTransformer = new TransformationCurrentAccount(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('OD')){
				//cisId = '4041187';
				cisId = '21387982';
				productUsageTransformer = new TransformationCurrentAccount(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('HL')){
				cisId = '11';
				productUsageTransformer = new TransformationHomeLoan(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('ADV')){
				cisId = '3661252';
				productUsageTransformer = new TransformationAdvancement(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('KPL')){
				cisId = '17835994';
				productUsageTransformer = new TransformationPersonalLoan(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('COM')){
				cisId = '21027657';
				productUsageTransformer = new TransformationCommercialLoan(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('PN')){
				cisId = '12792873';
				//cisId = '14502653'; //No commitmentLV 
				productUsageTransformer = new TransformationPromissoryNote(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('AV')){
				cisId = '4133681';
				//cisId = '132016'; only account level
				//cisId = '1768508'; only account level
				productUsageTransformer = new TransformationLendingAval(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('ACCEPT')){
				cisId = '4133681';
				productUsageTransformer = new TransformationLendingAcceptance(cisId, productCode, productUsageConfig);
			}else if(productCode.equalsIgnoreCase('LG')){
				cisId = '3281732';//22212
				productUsageTransformer = new TransformationLetterOfGuarantee(cisId, productCode, productUsageConfig);
			}
		} else {
			if(isVisible) {
				if (productCode.equalsIgnoreCase('CRCARD') || productCode.equalsIgnoreCase('KXCARD')) {
					productUsageTransformer = new TransformationCcKec(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('ATM')){
					productUsageTransformer = new TransformationAtmDebit(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('SA')){
					productUsageTransformer = new TransformationSaving(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('FIX')){
					productUsageTransformer = new TransformationFixed(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('TWD')){
					productUsageTransformer = new TransformationTaweesup(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('FCD')){
					productUsageTransformer = new TransformationFCD(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('FND')){
					productUsageTransformer = new TransformationMutualFund(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('CRN') || productCode.equalsIgnoreCase('OD')){
					productUsageTransformer = new TransformationCurrentAccount(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('HL')){
					productUsageTransformer = new TransformationHomeLoan(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('ADV')){
					productUsageTransformer = new TransformationAdvancement(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('KPL')){
					productUsageTransformer = new TransformationPersonalLoan(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('COM')){
					productUsageTransformer = new TransformationCommercialLoan(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('PN')){
					productUsageTransformer = new TransformationPromissoryNote(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('AV')){
					productUsageTransformer = new TransformationLendingAval(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('ACPT')){
					productUsageTransformer = new TransformationLendingAcceptance(cisId, productCode, productUsageConfig);
				}else if(productCode.equalsIgnoreCase('LG')){
					productUsageTransformer = new TransformationLetterOfGuarantee(cisId, productCode, productUsageConfig);
				}
			}
		}

		
		if(productUsageTransformer == null){
			productUsage = new ProductUsageModel();
		} else {
			productUsage = productUsageTransformer.transform();
		}
		
		productUsageString = JSON.serialize(productUsage);
		productUsageString = productUsageString.replace('\'', '\\\'');

		return productUsageString;
	}

	public class ProductUsageModel {
		public SiteMapModel siteMap;
		public Map<String, ProductUsageTable> productUsageTables;

		public ProductUsageModel() {
			siteMap = new SiteMapModel();
			productUsageTables = new Map<String, ProductUsageTable>();
		}
	}

	public class ProductUsageTable {
		public List<ProductUsageField> columnHeaders;
		public List<List<String>> body;

		public ProductUsageTable() {
			columnHeaders = new List<ProductUsageField>();
			body = new List<List<String>>();
		}
	}

	public class ProductUsageField {
		public String text;
		public String type;
		public String nextLevelId;
		public Boolean visible;

		public ProductUsageField(String text, String type, String nextLevelId, Boolean visible) {
			this.text = text;
			this.type = type;
			this.nextLevelId = nextLevelId;
			this.visible = visible;
		}	
	}

	public class SiteMapModel {
		public Map<String, SiteMapDetail> siteMaps;

		public SiteMapModel() {
			siteMaps = new Map<String, SiteMapDetail>();
		}
	}

	public class SiteMapDetail {
		public String level;
		public String label;
		public String fieldIndex;

		public SiteMapDetail(String level, String label, String fieldIndex) {
			this.level = level;
			this.label = label;
			this.fieldIndex = fieldIndex;
		}
	}

	public class CalculatedAccount {
        public Set<String> accountNameSet = new Set<String>();
        public String accountNameText {
            set;
            get {
                return String.join(new List<String>(accountNameSet), ',');
            }
        }
        public Decimal outstandingBalance = 0;
        public String outstandingBalanceText {
            set;
            get {
                return itemCount == 0 ? '' : outstandingBalance.setscale(2).toPlainString();
            }
        }
		public Boolean hideItemCount = false;
        public Integer itemCount = 0;
        public String itemCountText {
            set;
            get {
                return hideItemCount ? '' : String.valueOf(itemCount);
            }
        }
    }
}