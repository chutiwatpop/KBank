public class TransformationCcKec implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;

	public TransformationCcKec(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
		this.cisId = cisId;
		this.productCode = productCode;
		this.productUsageConfig = productUsageConfig;
	}

	public ProductUsageController.ProductUsageModel transform() {
		ProductUsageController.ProductUsageModel productUsageInfo = new ProductUsageController.ProductUsageModel();

		setProductUsageSiteMap(productUsageInfo);
		setProductUsageTable(productUsageInfo);

		String productUsageString = JSON.serialize(productUsageInfo);
		productUsageString.replace('\'', '\\\'');

		return productUsageInfo;
	} 

	private void setProductUsageSiteMap(ProductUsageController.ProductUsageModel productUsageInfo) {
		productUsageInfo.siteMap = productUsageConfig.getSiteMaps(productCode);
	}

	private void setProductUsageTable(ProductUsageController.ProductUsageModel productUsageInfo) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();

		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CREDIT_CARD_INFO_ENDPOINT, 'CIS_ID=' + cisId);
		CcKecModel ccKec = (CcKecModel) JSON.deserialize(resp.getBody(), CcKecModel.class);

		setColumnHeader(productUsageTable);
		setProductUsageDetail(ccKec, productUsageTable);

		productUsageInfo.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private void setColumnHeader(ProductUsageController.ProductUsageTable productUsageTable) {
		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
	}

	private void setProductUsageDetail(CcKecModel ccKec, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();

		if(ccKec != null && ccKec.dataResponse != null && ccKec.dataResponse.Detail != null 
		&& ccKec.dataResponse.Detail.CC_DTL_LIST != null && ccKec.dataResponse.Detail.CC_DTL_LIST.CC_DTL_LIST_INF != null) {
			for (CcKecModel.CcDetailInfo ccDetail : ccKec.dataResponse.Detail.CC_DTL_LIST.CC_DTL_LIST_INF) {
				List<String> detailColumns = new List<String>();

				// Filter CC or KEC data by CARD_ORG_NO, 001 = Credit Card, 200 = Personal O/D or K-Express cash card
				if ((ccDetail.CARD_ORG_NO == '001' && productCode == 'CRCARD') || (ccDetail.CARD_ORG_NO == '200' && productCode == 'KXCARD')) {
					detailColumns.add(ccDetail.CARD_NO_MASK_FORMATTED);
					detailColumns.add(ccDetail.CARD_NM);
					detailColumns.add(ccDetail.OPN_DT);
					detailColumns.add(ccDetail.CR_LMT_AMT);
					detailColumns.add(ccDetail.CRN_BAL);
					detailColumns.add(ccDetail.MN_PYMT_AMT);
					detailColumns.add(ccDetail.BAL);
					detailColumns.add(ccDetail.DUE_DT);
					detailColumns.add(ccDetail.PRIM_CARD_DESC);
					detailColumns.add(ccDetail.EXP_DT_FORMATTED);
					detailColumns.add(ccDetail.ST_CD_DESC);
					detailColumns.add(ccDetail.MAIN_NM_TH);
					detailColumns.add(ccDetail.NM_TH);
					detailColumns.add(ccDetail.BILL_CYC);
					details.add(detailColumns);
				}
			}
		}

		productUsageTable.body = details;
	}
}