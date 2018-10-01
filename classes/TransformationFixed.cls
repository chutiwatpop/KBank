public class TransformationFixed implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '74';
	private Map<String, List<String>> columnHeaderLabelConfig;
	Map<String, String> keyMapByAccount = new Map<String, String>();
	Integer level2Index = 0;

	public TransformationFixed(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT,'CIS_ID=' + cisId + '&SCR_STM_CD=' +typeId);
		CustomerWealthModel customerWealth = (CustomerWealthModel) JSON.deserialize(resp.getBody(), CustomerWealthModel.class);
		
		setProductUsageDetail(customerWealth, productUsageModel);
	}

	private void setProductUsageDetail(CustomerWealthModel custWealth, ProductUsageController.ProductUsageModel productUsageModel) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		List<ProductUsageController.ProductUsageField> columnHeadersLevel2 = productUsageConfig.getColumnHeaders(productCode, 2);
		List<List<String>> details = new List<List<String>>();

		if(custWealth.dataResponse.Detail.AR_DTL_LIST != null){
			for (CustomerWealthModel.CustWealthDetailInfo CustWealthDetail : custWealth.dataResponse.Detail.AR_DTL_LIST.AR_DTL_INF) {
				details.add(setFirstLevel(CustWealthDetail, custWealth.dataResponse.Detail.IP_ID));	
				if(CustWealthDetail.SUB_AR_DTL_LIST != null){
					ProductUsageController.ProductUsageTable productUsageTableSub = new ProductUsageController.ProductUsageTable();
					List<List<String>> detailsSub = new List<List<String>>();
					productUsageTableSub.columnHeaders = columnHeadersLevel2;
					for(CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount : customSubAccountSort(CustWealthDetail.SUB_AR_DTL_LIST.SUB_AR_DTL_INF)){
						detailsSub.add(setSecondLevel(subAccount, custWealth.dataResponse.Detail.IP_ID));				
					}
					productUsageTableSub.body = detailsSub;
					if(keyMapByAccount.containsKey(CustWealthDetail.AR_ID_ENCODED)) {
                        productUsageModel.productUsageTables.put(keyMapByAccount.get(CustWealthDetail.AR_ID_ENCODED), productUsageTableSub);
                    }
				}
			}
		}
		productUsageTable.body = details;
		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private List<String> setFirstLevel(CustomerWealthModel.CustWealthDetailInfo CustWealthDetail, String cisID){
		List<String> detailColumns = new List<String>();
		detailColumns.add(CustWealthDetail.AR_ID_FORMATTED); // เลขที่บัญชี
		detailColumns.add(CustWealthDetail.DOMC_BR_NO); // รหัสสาขา
		detailColumns.add(CustWealthDetail.DOMC_BR_NM); // ชื่อสาขา
		detailColumns.add(CustWealthDetail.PD_DSC_EN); // ผลิตภัณฑ์
		//detailColumns.add(''); // ระยะเวลาฝาก
		detailColumns.add(CustWealthDetail.AR_NM_TH); // ชื่อบัญชี
		detailColumns.add(CustWealthDetail.AR_OWN_TP_CD_TYPE); // ประเภทบัญชี
		detailColumns.add(cisID);
		if(CustWealthDetail.SUB_AR_DTL_LIST != null && CustWealthDetail.SUB_AR_DTL_LIST.SUB_AR_DTL_INF.size() > 1){
			String level2Key = productCode + '_' + custWealthDetail.AR_ID + '_2_' + level2Index;
			keyMapByAccount.put(custWealthDetail.AR_ID_ENCODED, level2Key);
			detailColumns.add(level2Key); // nextLevelKey
			level2Index++;
		}else{
			detailColumns.add('');
		}

		return detailColumns;
	}

	private List<String> setSecondLevel(CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount, String cisID){
		List<String> detailColumns = new List<String>();
		detailColumns.add(subAccount.SUB_AR); // เลขที่บัญชีระดับ Sub
		detailColumns.add(subAccount.SUB_AR_TERM_TEXT); // ระยะเวลาฝาก
		detailColumns.add(subAccount.CRN_BAL); // ยอดคงเหลือ (Outstanding)
		detailColumns.add(subAccount.HOLD_BAL_AMT); // Hold Balance Amount
		//detailColumns.add(subAccount.SUB_EFF_RATE_PCT); // อัตราดอกเบี้ยปัจจุบัน
		//detailColumns.add(subAccount.SUB_EFF_INT_RATE_TP_TEXT); // ประเภทอัตราดอกเบี้ย
		detailColumns.add(subAccount.SUB_INT_EFF_DT); // วันที่อัตราดอกเบี้ยมีผล
		detailColumns.add(subAccount.SUB_INT_END_DT); // วันที่อัตราดอกเบี้ยสิ้นสุด
		detailColumns.add(subAccount.SUB_AR_OPN_DT); // วันเปิดบัญชี
		//detailColumns.add(cisID); // CIS_ID

		return detailColumns;
	}

	private List<CustomerWealthModel.CustWealthDetailInfoSubAccount> customSubAccountSort(List<CustomerWealthModel.CustWealthDetailInfoSubAccount> subAccountList){
		Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount> SubAccountMap = new Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount>();
		Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount> SubAccountMapSorted = new Map<String,CustomerWealthModel.CustWealthDetailInfoSubAccount>();
		List<String> orderingList = new List<String>();

			for(CustomerWealthModel.CustWealthDetailInfoSubAccount subAccount: subAccountList){
				if(!String.isBlank(subAccount.SUB_AR) && Integer.valueOf(subAccount.SUB_AR) > 0) {
					SubAccountMap.put(subAccount.SUB_AR,subAccount);
				}
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