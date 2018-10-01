public class TransformationLetterOfGuarantee2 implements IProductUsageTransformation {
    private String cisId;
	private String productCode;
    private IProductUsageConfig productUsageConfig;
    private final String typeId = '8003,8030,8300,8301';

    public TransformationLetterOfGuarantee2(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
        Map<String, String> keyMapByAccount = new Map<String, String>();
        List<Integer> indexKey = new List<Integer>{0, 0, 0};//Level 2 to 4
        
        HTTPResponse fncResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FNC_ENDPOINT,'CIS_ID=' + cisId + '&PD_TP_CD=' + typeId);
		FNCModel fncModel = (FNCModel) JSON.deserialize(fncResp.getBody(), FNCModel.class);
        
        HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
		LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);

        groupDataToMap(fncModel, fncDetailListMapByAccount, subLevelMapByAccount);

        List<List<ProductUsageController.ProductUsageField>> columnHeaderList = new List<List<ProductUsageController.ProductUsageField>>();
        for(Integer i = 1;i <= 4;i++) {
            columnHeaderList.add(productUsageConfig.getColumnHeaders(productCode, i));
        }

        for(String key : fncDetailListMapByAccount.keySet()) {
            List<FNCModel.FNCDetailInfo> fncDetailList = fncDetailListMapByAccount.get(key);
            ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
            
            Integer level = subLevelMapByAccount.get(key);
            String ownerIpId = fncModel.dataResponse.Detail.IP_ID;

            productUsageTable.columnHeaders = columnHeaderList.get(level-1);
            setProductUsageDetail(fncDetailList, lpmDetailMap, productUsageTable, level, ownerIpId, subLevelMapByAccount, fncDetailListMapByAccount.keySet(), keyMapByAccount, indexKey);

            if(key == 'root-level1') {
                productUsageModel.productUsageTables.put(level1Key, productUsageTable);
            } else {
                if(!keyMapByAccount.containsKey(key)) {
                    generateModelKey(key, level, keyMapByAccount, indexKey);
                }
                productUsageModel.productUsageTables.put(keyMapByAccount.get(key), productUsageTable);
            }
        }
    }

    private void groupDataToMap(FNCModel fncModel, Map<String, List<FNCModel.FNCDetailInfo>> fncDetailListMapByAccount, Map<String, Integer> subLevelMapByAccount) {
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
                        String teampLMT = '';
                        FNCModel.FNCDetailInfo fncDetailTemp = new FNCModel.FNCDetailInfo();
                        teampLMT = fncDetail.LMT_AR_ID + 'L1';
                        fncDetailTemp.LMT_AR_ID = '555';
                        //fncDetailTemp.LMT_AR_ID = fncDetail.LMT_AR_ID + 'L1';
                        fncDetailTemp.ORIG_AR_ID = fncDetail.ORIG_AR_ID + 'L1';
                        fncDetailListMapByAccount.get('root-level1').add(fncDetailTemp);

                        fncDetailListMapByAccount.put(teampLMT, new List<FNCModel.FNCDetailInfo>{fncDetail});
                        subLevelMapByAccount.put(teampLMT, level + 1);

                        if(level == 2 && fncDetail.PCB_AR_LIST != null && fncDetail.PCB_AR_LIST.PCB_AR_INF.size() > 0) {
                            fncDetailListMapByAccount.put(fncDetail.LMT_AR_ID, new List<FNCModel.FNCDetailInfo>{fncDetail});
                            subLevelMapByAccount.put(fncDetail.LMT_AR_ID, 4);
                        }
                    }
                } else {
                    String upperAccount = fncDetail.UPR_LMT_AR_ID;
                    if(fncDetailListMapByAccount.containsKey(upperAccount)) {
                        fncDetailListMapByAccount.get(upperAccount).add(fncDetail);
                    } else {
                        fncDetailListMapByAccount.put(upperAccount, new List<FNCModel.FNCDetailInfo>{fncDetail});
                        subLevelMapByAccount.put(upperAccount, level + 1);//Change level 1 => 2, level 2 => 3
                    }

                    //Add this object to level 4 when it is sub-commitment level
                    if(fncDetail.LMT_LVL_IND == '2' && fncDetail.PCB_AR_LIST != null && fncDetail.PCB_AR_LIST.PCB_AR_INF.size() > 0) {
                        fncDetailListMapByAccount.put(fncDetail.LMT_AR_ID, new List<FNCModel.FNCDetailInfo>{fncDetail});
                        subLevelMapByAccount.put(fncDetail.LMT_AR_ID, 4);
                    }
                }
            }
        }
    }

    private void setProductUsageDetail(List<FNCModel.FNCDetailInfo> fncDetailList, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, ProductUsageController.ProductUsageTable productUsageTable, Integer level, String ownerIpId, Map<String, Integer> subLevelMapByAccount, Set<String> accountIdSet, Map<String, String> keyMapByAccount, List<Integer> indexKey) {
        List<List<String>> details = new List<List<String>>();
        for(FNCModel.FNCDetailInfo fncDetail : fncDetailList) {
            LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
            if(lpmDetailMap.containsKey(fncDetail.LMT_AR_ID_ENCODED)) {
                lpmDetailInfo = lpmDetailMap.get(fncDetail.LMT_AR_ID_ENCODED);
            }

            switch on level {
                when 1, 2 {
                    FNCModel.FNCDetailIP fncDetailIPFiltered = filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
                    FNCModel.FNCDetailInfoAR fncDetailARFiltered = filteredDetailARLevelCommitment(fncDetail.PCB_AR_LIST);
                    details.add(setRowCommitmentLevel(fncDetail, fncDetailIPFiltered, fncDetailARFiltered, lpmDetailInfo, level, subLevelMapByAccount, accountIdSet, keyMapByAccount, indexKey));
                }
                when 3 {
                    FNCModel.FNCDetailIP fncDetailIPFiltered = filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
                    FNCModel.FNCDetailInfoAR fncDetailARFiltered = filteredDetailAR(fncDetail.PCB_AR_LIST);
                    details.add(setRowSubCommitmentLevel(fncDetail, fncDetailIPFiltered, fncDetailARFiltered, lpmDetailInfo, accountIdSet, keyMapByAccount, indexKey));
                }
                when 4 {
                    if(fncDetail.PCB_AR_LIST != null) {
                        for(FNCModel.FNCDetailInfoAR fncDetailAR : fncDetail.PCB_AR_LIST.PCB_AR_INF) {
                            FNCModel.FNCDetailInfoARIP fncDetailInfoArIpFiltered = filteredDetailInfoARIP(fncDetailAR.PCB_AR_IP_LIST);
                            if(lpmDetailMap.containsKey(fncDetailAR.AR_ID_ENCODED)) {
                                lpmDetailInfo = lpmDetailMap.get(fncDetailAR.AR_ID_ENCODED);
                            }
                            details.add(setRowAccountLevel(fncDetailAR, lpmDetailInfo, fncDetailInfoArIpFiltered));
                        }
                    }
                }
            }
        }
        productUsageTable.body = details;
    }

    private List<String> setRowCommitmentLevel(FNCModel.FNCDetailInfo fncDetail, FNCModel.FNCDetailIP fncDetailIP, FNCModel.FNCDetailInfoAR fncDetailAR, LPMModel.LPMDetailInfo lpmDetailInfo, Integer level, Map<String, Integer> subLevelMapByAccount, Set<String> accountIdSet, Map<String, String> keyMapByAccount, List<Integer> indexKey) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetail.ORIG_AR_ID);//01-เลขที่บัญชี
        detailColumns.add(fncDetail.LMT_AR_ID);//02-เลขที่บัญชีเดิม (Converted Account)
        detailColumns.add(fncDetailIP.AR_OWN_TP_CD_TYPE);//03-ประเภทวงเงิน
        detailColumns.add(fncDetailAR.AR_NM_TH);//04-ชื่อบัญชี
        detailColumns.add(fncDetail.PD_DSC);//05-ประเภทหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.ITEM_COUNT);//06-จำนวนตั๋ว(ฉบับ)
        detailColumns.add(fncDetail.SETUP_LMT_AMT);//07-วงเงิน(Limit)
        detailColumns.add(fncDetailAR.OTSND_BAL);//08-มูลค่าหนังสือค้ำประกัน
        detailColumns.add(fncDetail.EFF_DT);//09-วันที่วงเงินมีผล
        detailColumns.add(fncDetail.MAT_DT);//10-วันที่ครบกำหนด
        detailColumns.add(fncDetail.CTR_DT);//11-วันที่ลงนามสัญญา
        detailColumns.add(fncDetail.LMT_TP_CD_TYPE);//12-ประเภทของการทบทวนวงเงิน
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//13-LPM_NO
        detailColumns.add(fncDetailIP.IP_ID);//14-CIS_ID
        if(accountIdSet.contains(fncDetail.LMT_AR_ID)) {//15-Next Model Key
            if(!keyMapByAccount.containsKey(fncDetail.LMT_AR_ID)) {
                generateModelKey(fncDetail.LMT_AR_ID, subLevelMapByAccount.get(fncDetail.LMT_AR_ID), keyMapByAccount, indexKey);
            }
            detailColumns.add(keyMapByAccount.get(fncDetail.LMT_AR_ID));
        } else {
            detailColumns.add('');
        }
        return detailColumns;
    }

    private List<String> setRowSubCommitmentLevel(FNCModel.FNCDetailInfo fncDetail, FNCModel.FNCDetailIP fncDetailIP, FNCModel.FNCDetailInfoAR fncDetailAR, LPMModel.LPMDetailInfo lpmDetailInfo, Set<String> accountIdSet, Map<String, String> keyMapByAccount, List<Integer> indexKey) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetail.ORIG_AR_ID);//01-เลขที่บัญชี
        detailColumns.add(fncDetail.LMT_AR_ID);//02-เลขที่บัญชีเดิม (Converted Account)
        detailColumns.add(fncDetailIP.AR_OWN_TP_CD_TYPE);//03-ประเภทวงเงิน
        detailColumns.add(fncDetailAR.AR_NM_TH);//04-ชื่อบัญชี
        detailColumns.add(fncDetail.PD_DSC);//05-ประเภทหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.ITEM_COUNT);//06-จำนวนตั๋ว(ฉบับ)
        detailColumns.add(fncDetail.SETUP_LMT_AMT);//07-วงเงิน(Limit)
        detailColumns.add(fncDetailAR.OTSND_BAL);//08-มูลค่าหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.FEE_RATE_PCT);//09-อัตราค่าธรรมเนียม  (Fee Rate)
        detailColumns.add(fncDetailAR.CMSN_TP_CD_TYPE);//10-รหัสการคำนวณค่าธรรมเนียม (Cal Code)
        detailColumns.add(fncDetailAR.DDC_AR_ID_FORMATTED);//11-เลขที่บัญชีสำหรับหักเงินอัตโนมัติ
        detailColumns.add(fncDetail.EFF_DT);//12-วันที่วงเงินมีผล
        detailColumns.add(fncDetail.MAT_DT);//13-วันที่ครบกำหนด
        detailColumns.add(fncDetail.LMT_TP_CD_TYPE);//14-ประเภทของการทบทวนวงเงิน
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//15-LPM_NO
        detailColumns.add(fncDetailIP.IP_ID);//16-CIS_ID
        if(accountIdSet.contains(fncDetail.LMT_AR_ID)) {//17-Next Model Key
            if(!keyMapByAccount.containsKey(fncDetail.LMT_AR_ID)) {
                generateModelKey(fncDetail.LMT_AR_ID, 4, keyMapByAccount, indexKey);
            }
            detailColumns.add(keyMapByAccount.get(fncDetail.LMT_AR_ID));
        } else {
            detailColumns.add('');
        }
        return detailColumns;
    }

    private List<String> setRowAccountLevel(FNCModel.FNCDetailInfoAR fncDetailAR, LPMModel.LPMDetailInfo lpmDetailInfo, FNCModel.FNCDetailInfoARIP fncDetailInfoARIP) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetailAR.ORIG_AR_ID);//01-เลขที่บัญชี
        detailColumns.add(fncDetailAR.AR_ID);//02-เลขที่บัญชีเดิม (Converted Account)
        detailColumns.add(fncDetailAR.AR_NM_TH);//03-ชื่อบัญชี
        detailColumns.add(fncDetailAR.PD_DSC);//04-ประเภทหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.OTSND_BAL);//05-มูลค่าหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.FEE_RATE_PCT);//06-อัตราค่าธรรมเนียม  (Fee Rate)
        detailColumns.add(fncDetailAR.CMSN_TP_CD_TYPE);//07-รหัสการคำนวณค่าธรรมเนียม (Cal Code)
        detailColumns.add(fncDetailAR.UPD_FEE_AMT);//08-ค่าธรรมเนียมค้างชำระ
        detailColumns.add(fncDetailAR.EFF_DT);//09-วันที่เปิดตั๋ว
        detailColumns.add(fncDetailAR.MAT_DT);//10-วันครบกำหนด
        detailColumns.add(fncDetailAR.DDC_AR_ID_FORMATTED);//11-เลขที่บัญชีสำหรับหักเงินอัตโนมัติ
        detailColumns.add(lpmDetailInfo.TDR_F_TEXT);//12-ปรับโครงสร้างหนี้ / สอบทาน
        detailColumns.add(lpmDetailInfo.DLQ_DYS);//13-จำนวนวันค้างชำระ
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//14-LPM_NO
        detailColumns.add(fncDetailInfoARIP.IP_ID);//15-CIS_ID
        return detailColumns;
    }

    private void generateModelKey(String id, Integer level, Map<String, String> keyMapByAccount, List<Integer> indexKey) {
        Integer index = indexKey.get(level-2);
        String levelKey = productCode + '_' + id + '_'  + level + '_' + index;
        keyMapByAccount.put(id, levelKey);
        indexKey.set(level-2, index + 1);
    }

    private Map<String, LPMModel.LPMDetailInfo> getLPMDetailMap(LPMModel lpmModel) {
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = new Map<String, LPMModel.LPMDetailInfo>();
        if(lpmModel != null && lpmModel.dataResponse  != null && lpmModel.dataResponse.Detail  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST  != null) {
            for(LPMModel.LPMDetailInfo lpmDetailInfo : lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF) {
                lpmDetailMap.put(lpmDetailInfo.AR_ID_ENCODED, lpmDetailInfo);
            }
        }
        return lpmDetailMap;
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
				fncDetailARFiltered.AR_NM_TH = source.AR_NM_TH;
                fncDetailARFiltered.FEE_RATE_PCT = source.FEE_RATE_PCT;
                fncDetailARFiltered.CMSN_TP_CD = source.CMSN_TP_CD;
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

    private FNCModel.FNCDetailInfoAR filteredDetailARLevelCommitment(FNCModel.FNCDetailSub detailList) {
        FNCModel.FNCDetailInfoAR fncDetailARFiltered = new FNCModel.FNCDetailInfoAR();
		Decimal result = 0;
		Set<String> accountNameSet = new Set<String>();
        if(detailList != null) {
			for(FNCModel.FNCDetailInfoAR fncDetailAR : detailList.PCB_AR_INF) {
				if(String.isNotBlank(fncDetailAR.OTSND_BAL)) {
					try {
						result += Decimal.valueOf(fncDetailAR.OTSND_BAL);
					} catch (Exception e) {
						System.debug(e.getStackTraceString());
					}
				}
				if(String.isNotBlank(fncDetailAR.AR_NM_TH)) {
					accountNameSet.add(fncDetailAR.AR_NM_TH);
				}
			}
			fncDetailARFiltered.AR_NM_TH = String.join(new List<String>(accountNameSet), ',');
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
}