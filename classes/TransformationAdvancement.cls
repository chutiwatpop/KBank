public class TransformationAdvancement implements IProductUsageTransformation{
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '8500';
	private Map<String, List<String>> columnHeaderLabelConfig;

	public TransformationAdvancement(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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

		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FNC_ENDPOINT,'CIS_ID=' + cisId + '&PD_TP_CD=' +typeId);
		FNCModel fncModel = (FNCModel) JSON.deserialize(resp.getBody(), FNCModel.class);

		HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
		LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);

		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		setProductUsageDetail(fncModel,lpmDetailMap, productUsageTable);

		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);

	}

	private Map<String, LPMModel.LPMDetailInfo> getLPMDetailMap(LPMModel lpmModel) {
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = new Map<String, LPMModel.LPMDetailInfo>();
        if(lpmModel != null && lpmModel.dataResponse  != null && lpmModel.dataResponse.Detail  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST  != null  && lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF  != null) {
            for(LPMModel.LPMDetailInfo lpmDetailInfo : lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF) {
                lpmDetailMap.put(lpmDetailInfo.AR_ID_ENCODED, lpmDetailInfo);
            }
        }
        return lpmDetailMap;
    }

	private void setProductUsageDetail(FNCModel fncModel,Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
		if(fncModel.dataResponse.Detail.PCB_LMT_AR_LIST != null){
			String ownerIpId = fncModel.dataResponse.Detail.IP_ID;
			for(FNCModel.FNCDetailInfo fncDetailInfo : fncModel.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF){
				if(fncDetailInfo.PCB_AR_LIST != null){					
					for(FNCModel.FNCDetailInfoAR fncDetailInfoAR : fncDetailInfo.PCB_AR_LIST.PCB_AR_INF){
						fncDetailInfoAR.POS_DT = fncModel.dataResponse.Detail.POS_DT;
						LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
						FNCModel.FNCDetailInfoARIP fncDetailInfoArIpFiltered = new FNCModel.FNCDetailInfoARIP();
						FNCModel.FNCDetailInfoSHD fncDetailInfoSHDFiltered = new FNCModel.FNCDetailInfoSHD();
						if(lpmDetailMap.containsKey(fncDetailInfoAR.AR_ID_ENCODED)) {
							lpmDetailInfo = lpmDetailMap.get(fncDetailInfoAR.AR_ID_ENCODED);
		                }

						fncDetailInfoArIpFiltered = filteredDetailInfoARIP(fncDetailInfoAR.PCB_AR_IP_LIST, ownerIpId);
						fncDetailInfoSHDFiltered = filteredDetailInfoSHD(fncDetailInfoAR.PYMT_SHD_LIST);

						addItemsToList(details,lpmDetailInfo,fncDetailInfo,fncDetailInfoAR,fncDetailInfoArIpFiltered,fncDetailInfoSHDFiltered);
					}
				}
			}
		}
		productUsageTable.body = details;
	}

	private FNCModel.FNCDetailInfoARIP filteredDetailInfoARIP(FNCModel.FNCDetailInfoARIPList arIpList, String ownerIpId) {
		FNCModel.FNCDetailInfoARIP fncDetailInfoFiltered = new FNCModel.FNCDetailInfoARIP();
		List<String> ipIdList = new List<String>();
		if(arIpList != null){
			for(FNCModel.FNCDetailInfoARIP fncDetailInfoARIP : arIpList.PCB_AR_IP_INF){
				// Check ip_id same as owner of account
				if (fncDetailInfoARIP.IP_ID == ownerIpId) {
					fncDetailInfoFiltered = fncDetailInfoARIP;
				}
				ipIdList.add(fncDetailInfoARIP.IP_ID);
			}
			fncDetailInfoFiltered.IP_ID = String.join(ipIdList, ',');
		}
		return fncDetailInfoFiltered;
	}

	private FNCModel.FNCDetailInfoSHD filteredDetailInfoSHD(FNCModel.FNCDetailInfoSHDList detailInfoSHDList) {
		FNCModel.FNCDetailInfoSHD fncDetailInfoSHDFiltered = new FNCModel.FNCDetailInfoSHD();
		if(detailInfoSHDList != null){
			for(FNCModel.FNCDetailInfoSHD fncDetailInfoSHD : detailInfoSHDList.PYMT_SHD_INF){
				if (!String.isBlank(fncDetailInfoSHD.PNP_AMT) && !String.isBlank(fncDetailInfoSHD.CNDT_STRT_DT) && Decimal.valueOf(fncDetailInfoSHD.PNP_AMT) > 0 && Date.valueOf(fncDetailInfoSHD.CNDT_STRT_DT) <= System.today().addDays(-1)) {
					fncDetailInfoSHDFiltered = fncDetailInfoSHD;
					break;
				}
			}
		}
		return fncDetailInfoSHDFiltered;
	}

	private void addItemsToList(List<List<String>> details,LPMModel.LPMDetailInfo lpmDetailInfo,FNCModel.FNCDetailInfo fncDetailInfo, 
	FNCModel.FNCDetailInfoAR fncDetailInfoAR,FNCModel.FNCDetailInfoARIP fncDetailInfoARIP,FNCModel.fncDetailInfoSHD fncDetailInfoSHD){ 

		List<String> detailColumns = new List<String>();
			detailColumns.add(fncDetailInfoAR.ORIG_AR_ID);
			detailColumns.add(fncDetailInfoAR.AR_ID);
			detailColumns.add(fncDetailInfoARIP.AR_OWN_TP_CD_TYPE);
			detailColumns.add(fncDetailInfoAR.AR_NM_TH);
			detailColumns.add(fncDetailInfoAR.PD_DSC);
			detailColumns.add(fncDetailInfo.SETUP_LMT_AMT);
			detailColumns.add(fncDetailInfoAR.OTSND_BAL);
			detailColumns.add(fncDetailInfoAR.EFF_RATE_PCT);
			detailColumns.add(fncDetailInfoAR.EFF_INT_RATE_TP_TEXT);
			detailColumns.add(fncDetailInfoAR.TOT_NO_INSTL);
			detailColumns.add(fncDetailInfoSHD.PNP_AMT);
			detailColumns.add(fncDetailInfoAR.OPN_DT);
			detailColumns.add(fncDetailInfoAR.MAT_DT);
			detailColumns.add(fncDetailInfoAR.CTR_DT);
			detailColumns.add(fncDetailInfoAR.DDC_AR_ID_FORMATTED);
			detailColumns.add(fncDetailInfoAR.LAST_PYMT_DT);
			detailColumns.add(lpmDetailInfo.TDR_F_TEXT);
			detailColumns.add(lpmDetailInfo.DLQ_DYS);
			detailColumns.add(lpmDetailInfo.LPM_CST_ID);
			detailColumns.add(fncDetailInfoARIP.IP_ID);
			
			details.add(detailColumns);

	}
}