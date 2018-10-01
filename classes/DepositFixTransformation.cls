public class DepositFixTransformation implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '74';
	private Map<String, List<String>> columnHeaderLabelConfig;

	public DepositFixTransformation(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
		this.cisId = cisId;
		this.productCode = productCode;
		this.productUsageConfig = productUsageConfig;
	}

	public ProductUsageController.ProductUsageModel transform() {
		ProductUsageController.ProductUsageModel productUsageModel = new ProductUsageController.ProductUsageModel();

		setProductUsageSiteMap(productUsageModel);
        setProductUsageTable(productUsageModel);

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

		System.debug('productUsageTable.body :' + productUsageTable.body);
		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private void setProductUsageDetail(CustomerWealthModel custWealth, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
		if(custWealth.dataResponse.Detail.AR_DTL_LIST != null){
			for (CustomerWealthModel.CustWealthDetailInfo CustWealthDetail : custWealth.dataResponse.Detail.AR_DTL_LIST.AR_DTL_INF) {	
				if(CustWealthDetail.SUB_AR_DTL_LIST != null){
					for(CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount : customSubAccountSort(CustWealthDetail.SUB_AR_DTL_LIST.SUB_AR_DTL_INF)){
						addFixedItemsToList(details, custWealth, CustWealthDetail, subAccount);
					}
	            }else{
					CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount = new CustomerWealthModel.CustWealthDetailInfoSubAccount();
					subAccount.SUB_AR = '';
					subAccount.SUB_AR_TERM = '';
					subAccount.SUB_AR_TERM_UOM_TP_CD = '';
					subAccount.SUB_EFF_RATE_PCT = '';
					subAccount.SUB_EFF_INT_RATE_TP_CD = '';
					subAccount.SUB_INT_EFF_DT = '';
					subAccount.SUB_INT_END_DT = '';
					addFixedItemsToList(details, custWealth, CustWealthDetail, subAccount);
	            }
			}
		}

		productUsageTable.body = details;
	}

	private void addFixedItemsToList(List<List<String>> details, CustomerWealthModel custWealth, CustomerWealthModel.CustWealthDetailInfo CustWealthDetail, 
	CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount) {
		List<String> detailColumns = new List<String>();

		detailColumns.add(CustWealthDetail.AR_ID);
		detailColumns.add(subAccount.SUB_AR);
		detailColumns.add(CustWealthDetail.DOMC_BR_NO);
		detailColumns.add(CustWealthDetail.DOMC_BR_NM);
		detailColumns.add(CustWealthDetail.PD_DSC_EN);
		detailColumns.add(subAccount.SUB_AR_TERM_TEXT);
		detailColumns.add(CustWealthDetail.AR_NM_TH);
		detailColumns.add(CustWealthDetail.SUM_CRN_BAL);
		detailColumns.add(CustWealthDetail.SUM_HOLD_BAL_AMT);
		detailColumns.add(subAccount.SUB_EFF_RATE_PCT);
		detailColumns.add(subAccount.SUB_EFF_INT_RATE_TP_TEXT);
		detailColumns.add(subAccount.SUB_INT_EFF_DT);
		detailColumns.add(subAccount.SUB_INT_END_DT);
		detailColumns.add(CustWealthDetail.OPN_DT);
		detailColumns.add(CustWealthDetail.AR_OWN_TP_CD_TYPE);
		detailColumns.add(custWealth.dataResponse.Detail.IP_ID);

		details.add(detailColumns);
	}

	private List<CustomerWealthModel.CustWealthDetailInfoSubAccount> customSubAccountSort(List<CustomerWealthModel.CustWealthDetailInfoSubAccount> subAccountList){
		Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount> SubAccountMap = new Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount>();
		Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount> SubAccountMapSorted = new Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount>();
		List<String> orderingList = new List<String>();

			for(CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount: subAccountList){
			     SubAccountMap.put(subAccount.SUB_AR,subAccount);
			}
		    //Add all elements of Set into a list
		    orderingList.addAll(SubAccountMap.keyset());
		    orderingList.sort();
		 
		    for(Integer i= 0;i < orderingList.size(); i++){
		        SubAccountMapSorted.put(orderingList[i],SubAccountMap.get(orderingList[i]));
		    }

		return SubAccountMapSorted.values();           
	}
}