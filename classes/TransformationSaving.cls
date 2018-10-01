public class TransformationSaving implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '72';
	private Map<String, List<String>> columnHeaderLabelConfig;
	private Account accountInfo;

	public TransformationSaving(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
		this.cisId = cisId;
		this.productCode = productCode;
		this.productUsageConfig = productUsageConfig;
		this.accountInfo = [SELECT Id,Person_Type__c From Account WHERE CIS__C = :cisId Limit 1];
	}

	public ProductUsageController.ProductUsageModel transform() {
		ProductUsageController.ProductUsageModel productUsageModel = new ProductUsageController.ProductUsageModel();
		if(shouldDisplayPageInfo()){
			setProductUsageSiteMap(productUsageModel);
	        setProductUsageTable(productUsageModel);
	    }

		return productUsageModel;
	}

	private void setProductUsageSiteMap(ProductUsageController.ProductUsageModel productUsageModel) {
        productUsageModel.siteMap = productUsageConfig.getSiteMaps(productCode);
    }

	private void setProductUsageTable(ProductUsageController.ProductUsageModel productUsageModel) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();

		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT,'CIS_ID=' + cisId + '&SCR_STM_CD=' +typeId);
		CustomerWealthModel customerWealth = (CustomerWealthModel) JSON.deserialize(resp.getBody(), CustomerWealthModel.class);

		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		setProductUsageDetail(customerWealth, productUsageTable);
		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private void setProductUsageDetail(CustomerWealthModel custWealth, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
		if(custWealth.dataResponse.Detail.AR_DTL_LIST != null){
			for (CustomerWealthModel.CustWealthDetailInfo custWealthDetail : custWealth.dataResponse.Detail.AR_DTL_LIST.AR_DTL_INF) {
			List<String> detailColumns = new List<String>();
				detailColumns.add(custWealthDetail.AR_ID_FORMATTED);
				detailColumns.add(custWealthDetail.DOMC_BR_NO);
				detailColumns.add(custWealthDetail.DOMC_BR_NM);
				detailColumns.add(custWealthDetail.AR_NM_TH);
				detailColumns.add(custWealthDetail.SUM_CRN_BAL);
				detailColumns.add(custWealthDetail.SUM_HOLD_BAL_AMT);
				detailColumns.add(custWealthDetail.OPN_DT);
				detailColumns.add(custWealthDetail.PD_DSC_EN);
				detailColumns.add(custWealthDetail.AR_OWN_TP_CD_TYPE);
				detailColumns.add(custWealth.dataResponse.Detail.IP_ID);
				details.add(detailColumns);
			}
		}

		productUsageTable.body = details;
	}

	private Boolean shouldDisplayPageInfo(){
		return !ProductUsageSummaryController.PERSONTYPE_KBANK.equalsIgnoreCase(this.accountInfo.Person_Type__c);
	}
}