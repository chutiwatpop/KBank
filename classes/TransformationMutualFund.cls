public class TransformationMutualFund  implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '16';
	private Map<String, List<String>> columnHeaderLabelConfig;

	public TransformationMutualFund(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
					subAccount.FND_CD = '';
					subAccount.FND_DSC_TH = '';
					subAccount.UNIT_BAL = '';
					subAccount.NAV_DT = '';
					subAccount.NAV = '';
					subAccount.CRN_BAL = '';
					addFixedItemsToList(details, custWealth, CustWealthDetail, subAccount);
	            }
				if(CustWealthDetail.AR_ST_LIST != null){
					List<String> listsubOthers = new List<String>();
					for(CustomerWealthModel.CustWealthDetailInfoSubOther subOther : CustWealthDetail.AR_ST_LIST.AR_ST_INF){
						listsubOthers.add(subOther.MISC_CD);
					}
					String separator = ',';
					String miscCd = String.join(listsubOthers, separator);
					addSubOtherToList(details,miscCd);

				}else{
					String miscCd = '';
					addSubOtherToList(details,miscCd);
				}
			}
		}

		productUsageTable.body = details;
	}

	private void addFixedItemsToList(List<List<String>> details, CustomerWealthModel custWealth, CustomerWealthModel.CustWealthDetailInfo CustWealthDetail, 
	CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount) {
		List<String> detailColumns = new List<String>();

		detailColumns.add(CustWealthDetail.AR_ID_FUND_FORMATTED);
		detailColumns.add(subAccount.SUB_AR);
		detailColumns.add(CustWealthDetail.AR_NM_TH);

		detailColumns.add(subAccount.FND_CD);
		detailColumns.add(subAccount.FND_DSC_TH);
		detailColumns.add(subAccount.UNIT_BAL);

		detailColumns.add(subAccount.NAV_DT);
		detailColumns.add(subAccount.NAV);
		detailColumns.add(subAccount.CRN_BAL);

		details.add(detailColumns);
	}

	private void addSubOtherToList(List<List<String>> details,String miscCd){
		for(Integer i=0;i<details.size();i++){
			details[i].add(miscCd);
		}
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