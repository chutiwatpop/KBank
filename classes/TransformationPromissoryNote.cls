public class TransformationPromissoryNote implements IProductUsageTransformation  {
	private String cisId;
	private String productCode;
    private IProductUsageConfig productUsageConfig;
    private final String typeId = '8002,8020,8200';
	private List<Integer> indexKey = new List<Integer>{0, 0};//Level 2 to 3
	private Map<String, String> keyMapByAccount = new Map<String, String>();

	public TransformationPromissoryNote(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
        String level1Key = productCode + '_0';
        Map<String, List<FNCModel.FNCDetailInfo>> fncDetailListMapByAccount = new Map<String, List<FNCModel.FNCDetailInfo>>();
        Map<String, Integer> subLevelMapByAccount = new Map<String, Integer>();
		Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap = new Map<String, ProductUsageController.CalculatedAccount>();

        HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FNC_ENDPOINT,'CIS_ID=' + cisId + '&PD_TP_CD=' +typeId);
		FNCModel fnc = (FNCModel) JSON.deserialize(resp.getBody(), FNCModel.class);
		HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
		LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);

		groupDataToMap(fncDetailListMapByAccount, subLevelMapByAccount, calculatedAccountMap, fnc);

		List<List<ProductUsageController.ProductUsageField>> columnHeaderList = new List<List<ProductUsageController.ProductUsageField>>();
        for(Integer i = 1;i <= 3;i++) {
            columnHeaderList.add(productUsageConfig.getColumnHeaders(productCode, i));
        }

		for(String key : fncDetailListMapByAccount.keySet()) {
			System.debug('keyAllTest : ' +key);
            List<FNCModel.FNCDetailInfo> fncDetailList = fncDetailListMapByAccount.get(key);
            ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
            
            Integer level = subLevelMapByAccount.get(key);
			String ownerIpId = fnc.dataResponse.Detail.IP_ID;

            productUsageTable.columnHeaders = columnHeaderList.get(level-1);
            System.debug('fncDetailListTest : ' +fncDetailList);
            setProductUsageDetail(productUsageTable, fncDetailList, lpmDetailMap, calculatedAccountMap, level, ownerIpId, subLevelMapByAccount, fncDetailListMapByAccount.keySet());

            if(key == 'root-level1') {
                productUsageModel.productUsageTables.put(level1Key, productUsageTable);
            } else {
                if(!keyMapByAccount.containsKey(key)) {
					keyMapByAccount.put(key, ProductUsageHelper.generateModelKey(productCode, key, level, indexKey));
                }
                productUsageModel.productUsageTables.put(keyMapByAccount.get(key), productUsageTable);
            }
        }
    }

	private void groupDataToMap(Map<String, List<FNCModel.FNCDetailInfo>> fncDetailListMapByAccount, Map<String, Integer> subLevelMapByAccount, Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap, FNCModel fncModel) {
        if(fncModel != null && fncModel.dataResponse != null && fncModel.dataResponse.Detail != null && fncModel.dataResponse.Detail.PCB_LMT_AR_LIST != null) {
            fncDetailListMapByAccount.put('root-level1', new List<FNCModel.FNCDetailInfo>());
            subLevelMapByAccount.put('root-level1', 1);
            for(FNCModel.FNCDetailInfo fncDetail : fncModel.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF) {
                Integer level = Integer.valueOf(fncDetail.LMT_LVL_IND);
                if(fncDetail.LMT_AR_ID == fncDetail.ROOT_LMT_AR_ID) {
                    if(level == 1) {
                        fncDetailListMapByAccount.get('root-level1').add(fncDetail);
                    } else {
                        //root node but not level 1
                        FNCModel.FNCDetailInfo fncDetailTemp = new FNCModel.FNCDetailInfo();
                        fncDetailTemp.LMT_AR_ID = fncDetail.LMT_AR_ID + 'Temp';
                        fncDetailTemp.ORIG_AR_ID = fncDetail.ORIG_AR_ID;
                        fncDetailListMapByAccount.get('root-level1').add(fncDetailTemp);
                        
                        fncDetailListMapByAccount.put(fncDetailTemp.LMT_AR_ID, new List<FNCModel.FNCDetailInfo>{fncDetail});
                        subLevelMapByAccount.put(fncDetailTemp.LMT_AR_ID, level);

                    }
                } else if(fncDetail.LMT_LVL_IND == '2'){
                	String upperCommitment = fncDetail.UPR_LMT_AR_ID;
                    if(fncDetailListMapByAccount.containsKey(upperCommitment)) {
                        fncDetailListMapByAccount.get(upperCommitment).add(fncDetail);
                    } else {
                        fncDetailListMapByAccount.put(upperCommitment, new List<FNCModel.FNCDetailInfo>{fncDetail});
						subLevelMapByAccount.put(upperCommitment, 2);
                    }

                    if(fncDetail.PCB_AR_LIST != null && fncDetail.PCB_AR_LIST.PCB_AR_INF.size() > 0){
		                fncDetailListMapByAccount.put(fncDetail.LMT_AR_ID, new List<FNCModel.FNCDetailInfo>{fncDetail});
						subLevelMapByAccount.put(fncDetail.LMT_AR_ID, 3);
						calculateAccountData(calculatedAccountMap, fncDetail.PCB_AR_LIST.PCB_AR_INF, fncDetail.ROOT_LMT_AR_ID);
                    }
                } 
            }
        }
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

	private void setProductUsageDetail(ProductUsageController.ProductUsageTable productUsageTable, List<FNCModel.FNCDetailInfo> fncDetailList, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, 
	    Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap, Integer level, String ownerIpId, Map<String, Integer> subLevelMapByAccount, Set<String> accountIdSet) {
		
        List<List<String>> details = new List<List<String>>();
        for(FNCModel.FNCDetailInfo fncDetail : fncDetailList) {
			String limitId = fncDetail.LMT_AR_ID;
			String nextLevelKey = '';
			LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
			if(lpmDetailMap != null && lpmDetailMap.containsKey(fncDetail.LMT_AR_ID_ENCODED)) {
				lpmDetailInfo = lpmDetailMap.get(fncDetail.LMT_AR_ID_ENCODED);
			}

            switch on level {
                when 1 {
					FNCModel.FNCDetailIP fncDetailIPFiltered = filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
					ProductUsageController.CalculatedAccount calculatedResult = new ProductUsageController.CalculatedAccount();
					
					if(calculatedAccountMap.containsKey(limitId)) {
                        calculatedResult = calculatedAccountMap.get(limitId);
                    }

					if(accountIdSet.contains(limitId)) {
						if(!keyMapByAccount.containsKey(limitId)) {
							keyMapByAccount.put(limitId, ProductUsageHelper.generateModelKey(productCode, limitId, subLevelMapByAccount.get(limitId), indexKey));
						}
						nextLevelKey = keyMapByAccount.get(limitId);
					}
					if(limitId.right(4) == 'Temp'){
						fncDetail.LMT_AR_ID = '';
					}
					
					addPromissoryNoteToList(details, fncDetail, null, fncDetailIPFiltered, null, lpmDetailInfo, calculatedResult, level, nextLevelKey);
                }
                when 2 {
					FNCModel.FNCDetailIP fncDetailIPFiltered = filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
					FNCModel.FNCDetailInfoAR fncDetailARFiltered = filteredDetailAR(fncDetail.PCB_AR_LIST);
					System.debug('limitId : '+limitId);
					if(accountIdSet.contains(limitId)) {
						if(!keyMapByAccount.containsKey(limitId)) {
							keyMapByAccount.put(limitId, ProductUsageHelper.generateModelKey(productCode, limitId, subLevelMapByAccount.get(limitId), indexKey));
						}
						nextLevelKey = keyMapByAccount.get(limitId);
					}

					addPromissoryNoteToList(details, fncDetail, fncDetailARFiltered, fncDetailIPFiltered, null, lpmDetailInfo, null, level, nextLevelKey);
                }
                when 3 {
                    if(fncDetail.PCB_AR_LIST != null) {
                        for(FNCModel.FNCDetailInfoAR fncDetailInfo : fncDetail.PCB_AR_LIST.PCB_AR_INF) {
							FNCModel.FNCDetailInfoARIP fncDetailInfoArIpFiltered = filteredDetailInfoARIP(fncDetailInfo.PCB_AR_IP_LIST);
							if(lpmDetailMap != null && lpmDetailMap.containsKey(fncDetailInfo.AR_ID_ENCODED)) {
								lpmDetailInfo = lpmDetailMap.get(fncDetailInfo.AR_ID_ENCODED);
							}
							addPromissoryNoteToList(details, fncDetail, fncDetailInfo, null, fncDetailInfoArIpFiltered, lpmDetailInfo, null, level, nextLevelKey);
                        }
                    }
                }
            }
        }
        productUsageTable.body = details;
    }

	private void addPromissoryNoteToList(List<List<String>> levelDetails, FNCModel.FNCDetailInfo fncDetail, FNCModel.FNCDetailInfoAR fncDetailInfo, FNCModel.FNCDetailIP fncDetailIP, 
    	FNCModel.FNCDetailInfoARIP fncDetailInfoARIP, LPMModel.LPMDetailInfo lpmDetailInfo, ProductUsageController.CalculatedAccount calculatedResult, Integer level, String nextLevelKey){

		List<String> detailColumns = new List<String>();
		if(level != 3){
			detailColumns.add(fncDetail.ORIG_AR_ID);//01-เลขที่บัญชี
			detailColumns.add(fncDetail.LMT_AR_ID);//02-เลขที่บัญชีเดิม (Converted Account)
			detailColumns.add(fncDetailIP.AR_OWN_TP_CD_TYPE);//03-ประเภทวงเงิน
			detailColumns.add(fncDetail.LMT_AR_NM_TH);//04-ชื่อบัญชี
			detailColumns.add(fncDetail.PD_DSC);//05-ผลิตภัณฑ์
		}
		switch on level {
			when 1 {
				detailColumns.add(calculatedResult.itemCountText);//06-จำนวนฉบับ
				detailColumns.add(fncDetail.SETUP_LMT_AMT);//07-วงเงิน(Limit)
				detailColumns.add(calculatedResult.outstandingBalanceText);//08-ยอดคงเหลือ(Outstanding)
				detailColumns.add(fncDetail.EFF_DT);//09-วันที่วงเงินมีผล
				detailColumns.add(fncDetail.MAT_DT);//10-วันที่ครบกำหนด
				detailColumns.add(fncDetail.CTR_DT);//11-วันที่ลงนามสัญญา
				detailColumns.add(fncDetail.LMT_TP_CD_TYPE);//12-ประเภทของการทบทวนวงเงิน
				detailColumns.add(lpmDetailInfo.LPM_CST_ID);//13-LPM_NO
				detailColumns.add(fncDetailIP.IP_ID);//14-CIS_ID
				detailColumns.add(nextLevelKey);//15-Next Model Key
			}
			when 2 {
				detailColumns.add(fncDetailInfo.ITEM_COUNT);//06-จำนวนฉบับ
				detailColumns.add(fncDetail.SETUP_LMT_AMT);//07-วงเงิน(Limit)
				detailColumns.add(fncDetailInfo.OTSND_BAL);//08-ยอดคงเหลือ(Outstanding)
				detailColumns.add('');//09-จำนวนวันที่ออกตั๋วสูงสุด (Max Day)
				detailColumns.add(fncDetailInfo.EFF_RATE_PCT);//10-อัตราดอกเบี้ย
				detailColumns.add(fncDetailInfo.EFF_INT_RATE_TP_TEXT);//11-ประเภทอัตราดอกเบี้ย
				detailColumns.add(fncDetail.EFF_DT);//12-วันที่วงเงินมีผล
				detailColumns.add(fncDetail.MAT_DT);//13-วันที่ครบกำหนด
				detailColumns.add(fncDetailInfo.DDC_INT_TP_CD_TYPE);//14-ประเภทของการเก็บดอกเบี้ย
				detailColumns.add(fncDetailInfo.DDC_AR_ID_FORMATTED);//15-เลขที่บัญชีสำหรับหักเงินอัตโนมัติ
				detailColumns.add(fncDetail.LMT_TP_CD_TYPE);//16-ประเภทของการทบทวนวงเงิน
				detailColumns.add(lpmDetailInfo.LPM_CST_ID);//17-LPM_NO
				detailColumns.add(fncDetailIP.IP_ID);//18-CIS_ID
				detailColumns.add(nextLevelKey);//19-Next Model Key
			}
			when 3 {
				detailColumns.add(fncDetailInfo.ORIG_AR_ID);//01-เลขที่บัญชี
				detailColumns.add(fncDetailInfo.AR_ID);//02-เลขที่บัญชีเดิม (Converted Account)
				detailColumns.add(fncDetailInfo.AR_NM_TH_TEXT);//03-ชื่อบัญชี
				detailColumns.add(fncDetailInfo.PD_DSC);//04-ผลิตภัณฑ์
				detailColumns.add(fncDetailInfo.OTSND_BAL);//05-ยอดคงเหลือ(Outstanding)
				detailColumns.add(fncDetailInfo.CTR_AR_TERM);//06-จำนวนวันของตั๋ว
				detailColumns.add(fncDetailInfo.EFF_RATE_PCT);//07-อัตราดอกเบี้ย
				detailColumns.add(fncDetailInfo.EFF_INT_RATE_TP_TEXT);//08-ประเภทอัตราดอกเบี้ย
				detailColumns.add(fncDetailInfo.EFF_DT);//09-วันที่เปิดตั๋ว
				detailColumns.add(fncDetailInfo.MAT_DT);//10-วันครบกำหนด
				detailColumns.add(fncDetailInfo.DDC_INT_TP_CD_TYPE);//11-ประเภทของการเก็บดอกเบี้ย
				detailColumns.add(fncDetailInfo.DDC_AR_ID_FORMATTED);//12-เลขที่บัญชีสำหรับหักเงินอัติโนมัติ
				detailColumns.add(lpmDetailInfo.TDR_F_TEXT);//13-ปรับโครงสร้างหนี้ / สอบทาน
				detailColumns.add(lpmDetailInfo.DLQ_DYS);//14-จำนวนวันค้างชำระ
				detailColumns.add(lpmDetailInfo.LPM_CST_ID);//15-LPM_NO
				detailColumns.add(fncDetailInfoARIP.IP_ID);//16-CIS_ID			
			}
		}
		
		levelDetails.add(detailColumns);
	}

	private void calculateAccountData(Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap, List<FNCModel.FNCDetailInfoAR> dataList, String accountId) {
        Decimal result = 0;
        ProductUsageController.CalculatedAccount calculatedResult = new ProductUsageController.CalculatedAccount();

        if(calculatedAccountMap.containsKey(accountId)) {
            calculatedResult = calculatedAccountMap.get(accountId);
        } else {
            calculatedAccountMap.put(accountId, calculatedResult);
        }

        for(FNCModel.FNCDetailInfoAR fncDetailAR : dataList) {
			if(String.isNotBlank(fncDetailAR.OTSND_BAL)) {
				try {
					result += Decimal.valueOf(fncDetailAR.OTSND_BAL);
				} catch (Exception e) {
					System.debug(e.getStackTraceString());
				}
			}
		}

        calculatedResult.itemCount = calculatedResult.itemCount + dataList.size();
		calculatedResult.outstandingBalance = calculatedResult.outstandingBalance + result;
    }

	private FNCModel.FNCDetailIP filteredDetailIP(FNCModel.FNCDetailIPList ipList, String ownerIpId) {
		FNCModel.FNCDetailIP fncDetailIPFiltered = new FNCModel.FNCDetailIP();
		List<String> ipIdList = new List<String>();
		if(ipList != null){
			for(FNCModel.FNCDetailIP fncDetailIP : ipList.PCB_LMT_IP_INF){
				// Check ip_id same as owner of account
				if (fncDetailIP.IP_ID == ownerIpId) {
					fncDetailIPFiltered = fncDetailIP;
				}
				ipIdList.add(fncDetailIP.IP_ID);
			}
			fncDetailIPFiltered.IP_ID = String.join(ipIdList, ',');
		}
		return fncDetailIPFiltered;
	}

	private FNCModel.FNCDetailInfoAR filteredDetailAR(FNCModel.FNCDetailSub detailList) {
        FNCModel.FNCDetailInfoAR fncDetailARFiltered = new FNCModel.FNCDetailInfoAR();
		Decimal result = 0;
        if(detailList != null) {
			if(detailList.PCB_AR_INF.size() > 0) {
				FNCModel.FNCDetailInfoAR source = detailList.PCB_AR_INF.get(0);
                fncDetailARFiltered.EFF_RATE_PCT = source.EFF_RATE_PCT;
                fncDetailARFiltered.EFF_INT_RATE_TP_CD = source.EFF_INT_RATE_TP_CD;
                fncDetailARFiltered.ORIG_INT_RATE_TP_CD = source.ORIG_INT_RATE_TP_CD;
				fncDetailARFiltered.POS_DT = source.POS_DT;
				fncDetailARFiltered.PNP_AMT = source.PNP_AMT;
				fncDetailARFiltered.EFF_SPRD_RATE_PCT = source.EFF_SPRD_RATE_PCT;
				fncDetailARFiltered.DDC_INT_TP_CD = source.DDC_INT_TP_CD;
				fncDetailARFiltered.DDC_AR_ID = source.DDC_AR_ID;
			}
            
			for(FNCModel.FNCDetailInfoAR fncDetailAR : detailList.PCB_AR_INF) {
				if(String.isNotBlank(fncDetailAR.OTSND_BAL)) {
					try {
						result += Decimal.valueOf(fncDetailAR.OTSND_BAL);
					} catch (Exception e) {
						System.debug(e.getStackTraceString());
					}
				}
			}
			fncDetailARFiltered.ITEM_COUNT = String.valueOf(detailList.PCB_AR_INF.size());
			fncDetailARFiltered.OTSND_BAL = result.setscale(2).toPlainString();
        }
        return fncDetailARFiltered;
    }

	private FNCModel.FNCDetailInfoARIP filteredDetailInfoARIP(FNCModel.FNCDetailInfoARIPList arIpList) {
		FNCModel.FNCDetailInfoARIP fncDetailInfoFiltered = new FNCModel.FNCDetailInfoARIP();
		List<String> ipIdList = new List<String>();
		if(arIpList != null){
			for(FNCModel.FNCDetailInfoARIP fncDetailInfoARIP : arIpList.PCB_AR_IP_INF){
				ipIdList.add(fncDetailInfoARIP.IP_ID);
			}
			fncDetailInfoFiltered.IP_ID = String.join(ipIdList, ',');
		}
		return fncDetailInfoFiltered;
	}

	public class LendingTransformed {
        String ipId;
        //List<FCDTransformed> fcdTransformeds;

        LendingTransformed() {
           //fcdTransformeds = new List<FCDTransformed>();
        }
    }
}