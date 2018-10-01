public class TransformationHomeLoan implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '7100';
	private Map<String, List<String>> columnHeaderLabelConfig;

	public TransformationHomeLoan(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
		FNCModel fnc = (FNCModel) JSON.deserialize(resp.getBody(), FNCModel.class);
		
		HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
		LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);

		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		setProductUsageDetail(fnc, lpmDetailMap, productUsageTable);

		System.debug('productUsageHomeLoanTable.body :' + productUsageTable.body);
		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private Map<String, LPMModel.LPMDetailInfo> getLPMDetailMap(LPMModel lpmModel) {
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = new Map<String, LPMModel.LPMDetailInfo>();
        if(lpmModel != null && lpmModel.dataResponse  != null && lpmModel.dataResponse.Detail  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF  != null) {
            for(LPMModel.LPMDetailInfo lpmDetailInfo : lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF) {
                lpmDetailMap.put(lpmDetailInfo.AR_ID_ENCODED, lpmDetailInfo);
            }
        }
        return lpmDetailMap;
    }

    private void addHomeLoanItemsToList(List<List<String>> details, FNCModel.FNCDetailInfoAR fncDetailInfo, FNCModel.FNCDetailInfo fncDetail,
    	FNCModel.FNCDetailInfoSHD fncDetailInfoSHD, LPMModel.LPMDetailInfo lpmDetailInfo, FNCModel.FNCDetailInfoARIP fncDetailInfoARIP){

    	List<String> detailColumns = new List<String>();
		detailColumns.add(fncDetailInfo.ORIG_AR_ID);
		detailColumns.add(fncDetailInfo.AR_ID);
		detailColumns.add(fncDetailInfoARIP.AR_OWN_TP_CD_TYPE);
		detailColumns.add(fncDetailInfo.AR_NM_TH);
		detailColumns.add(fncDetailInfo.PD_DSC);
		detailColumns.add(fncDetail.SETUP_LMT_AMT);
		detailColumns.add(fncDetailInfo.OTSND_BAL);
		detailColumns.add(fncDetailInfo.EFF_RATE_PCT);
		detailColumns.add(fncDetailInfo.EFF_INT_RATE_TP_TEXT); //INT_RATE_TP_DSC+PCB_AR_LIST.EFF_SPRD_RATE_PCT
		detailColumns.add(fncDetailInfo.TOT_NO_INSTL);
		detailColumns.add(fncDetailInfoSHD.PNP_AMT);
		detailColumns.add(fncDetailInfo.OPN_DT);
		detailColumns.add(fncDetailInfo.MAT_DT);
		detailColumns.add(fncDetailInfo.CTR_DT);
		detailColumns.add(fncDetailInfo.DDC_AR_ID_FORMATTED);
		detailColumns.add(fncDetailInfo.LAST_PYMT_DT);
		if(lpmDetailInfo != null){
			detailColumns.add(lpmDetailInfo.TDR_F_TEXT);
			detailColumns.add(lpmDetailInfo.DLQ_DYS); 
			detailColumns.add(lpmDetailInfo.LPM_CST_ID);
		}else{
			detailColumns.add('');
			detailColumns.add(''); 
			detailColumns.add('');
		}	 
		detailColumns.add(fncDetailInfoARIP.IP_ID);

		details.add(detailColumns);
    }

	private void setProductUsageDetail(FNCModel fnc, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
		if(fnc.dataResponse.Detail.PCB_LMT_AR_LIST != null){
			String ownerIpId = fnc.dataResponse.Detail.IP_ID;
			for (FNCModel.FNCDetailInfo fncDetail : fnc.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF) {
                if(fncDetail.PCB_AR_LIST != null){
					FNCModel.FNCDetailInfoARIP fncDetailInfoFiltered = new FNCModel.FNCDetailInfoARIP();
					FNCModel.FNCDetailInfoSHD fncDetailInfoSHDFiltered = new FNCModel.FNCDetailInfoSHD();
                	for(FNCModel.FNCDetailInfoAR fncDetailInfo : fncDetail.PCB_AR_LIST.PCB_AR_INF){
                		fncDetailInfo.POS_DT = fnc.dataResponse.Detail.POS_DT;
						LPMModel.LPMDetailInfo lpmDetailInfo;
		                if(lpmDetailMap.containsKey(fncDetailInfo.AR_ID_ENCODED)) {
		                    lpmDetailInfo = new LPMModel.LPMDetailInfo();
							lpmDetailInfo = lpmDetailMap.get(fncDetailInfo.AR_ID_ENCODED);
		                }
                		fncDetailInfoFiltered = filteredDetailInfoARIP(fncDetailInfo.PCB_AR_IP_LIST, ownerIpId);
						fncDetailInfoSHDFiltered = filteredDetailInfoSHD(fncDetailInfo.PYMT_SHD_LIST);
						
						addHomeLoanItemsToList(details,fncDetailInfo,fncDetail,fncDetailInfoSHDFiltered,lpmDetailInfo,fncDetailInfoFiltered);
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
}