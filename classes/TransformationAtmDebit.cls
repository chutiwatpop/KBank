public class TransformationAtmDebit implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;

	public TransformationAtmDebit(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
		this.cisId = cisId;
		this.productCode = productCode;
		this.productUsageConfig = productUsageConfig;
	}

	public ProductUsageController.ProductUsageModel transform() {
		ProductUsageController.ProductUsageModel productUsageInfo = new ProductUsageController.ProductUsageModel();

		setProductUsageSiteMap(productUsageInfo);
		setProductUsageTable(productUsageInfo);

		return productUsageInfo;
	} 

	private void setProductUsageSiteMap(ProductUsageController.ProductUsageModel productUsageInfo) {
		productUsageInfo.siteMap = productUsageConfig.getSiteMaps(productCode);
	}

	private void setProductUsageTable(ProductUsageController.ProductUsageModel productUsageInfo) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();

		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.ATM_DEBIT_CARD_INFO_ENDPOINT, 'CIS_ID=' + cisId);
		AtmDcCardModel atmDcCard = (AtmDcCardModel) JSON.deserialize(resp.getBody(), AtmDcCardModel.class);

		setColumnHeader(productUsageTable);
		setProductUsageDetail(atmDcCard, productUsageTable);

		productUsageInfo.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private void setColumnHeader(ProductUsageController.ProductUsageTable productUsageTable) {
		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
	}

	private void setProductUsageDetail(AtmDcCardModel atmDcCard, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
		if(atmDcCard != null && atmDcCard.dataResponse != null && atmDcCard.dataResponse.Detail != null 
		&& atmDcCard.dataResponse.Detail.DC_DTL_LIST != null && atmDcCard.dataResponse.Detail.DC_DTL_LIST.DC_DTL_INF != null) {
			for (AtmDcCardModel.AtmDcDetailInfo atmDcCardDetail : atmDcCard.dataResponse.Detail.DC_DTL_LIST.DC_DTL_INF) {
				List<String> detailColumns = new List<String>();

				detailColumns.add(atmDcCardDetail.CARD_NO_FORMATTED);
				detailColumns.add(atmDcCardDetail.CARD_TP_DSC);
				detailColumns.add(atmDcCardDetail.ST_CD_DESC);
				detailColumns.add(atmDcCardDetail.SA_AR_ID_FORMATTED);
				detailColumns.add(atmDcCardDetail.SA_DOMC_BR_NO_FILTERED);
				detailColumns.add(atmDcCardDetail.SA_DOMC_BR_NM);
				detailColumns.add(atmDcCardDetail.CA_AR_ID_FORMATTED);
				detailColumns.add(atmDcCardDetail.CA_DOMC_BR_NO_FILTERED);
				detailColumns.add(atmDcCardDetail.CA_DOMC_BR_NM);
				detailColumns.add(atmDcCardDetail.ANUL_FEE_DESC);
				detailColumns.add(atmDcCardDetail.ISSU_DT);
				detailColumns.add(atmDcCardDetail.EXP_YR_MO_FORMATTED);
				detailColumns.add(atmDcCardDetail.CARD_HLDR_NM);

				details.add(detailColumns);
			}
		}

		productUsageTable.body = details;
	}
}