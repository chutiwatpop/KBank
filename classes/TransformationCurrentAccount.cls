public class TransformationCurrentAccount implements IProductUsageTransformation {
    private String cisId;
	private String productCode;
    private IProductUsageConfig productUsageConfig;
    private final String typeId = '73';

    public TransformationCurrentAccount(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
        ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
        Map<String, String> keyMapByAccount = new Map<String, String>();

        HTTPResponse customerWealthResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT,'CIS_ID=' + cisId + '&SCR_STM_CD=' + typeId);
		CustomerWealthModel customerWealth = (CustomerWealthModel) JSON.deserialize(customerWealthResp.getBody(), CustomerWealthModel.class);
        
        HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
		LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);

        Map<String, ODLimitModel.ODLimitAccountInfo> odAccountMap;
        HTTPResponse odResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.OD_LIMIT_ENDPOINT,'CIS_ID=' + cisId);
        ODLimitModel odLimit = (ODLimitModel) JSON.deserialize(odResp.getBody(), ODLimitModel.class);
        odAccountMap = getODAccountMap(odLimit);
        System.debug('odAccountMap : ' + odAccountMap);

        productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
        setProductUsageDetailLevel1(customerWealth, lpmDetailMap, odAccountMap, productUsageTable, keyMapByAccount);

		productUsageModel.productUsageTables.put(level1Key, productUsageTable);

        if(odAccountMap != null && !odAccountMap.isEmpty()) {
            for(ODLimitModel.ODLimitAccountInfo eachODAccount : odAccountMap.values()) {
                ProductUsageController.ProductUsageTable level2Table = new ProductUsageController.ProductUsageTable();
                level2Table.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 2);
                setProductUsageDetailLevel2(eachODAccount, level2Table);

                if(keyMapByAccount.containsKey(eachODAccount.AR_ID_ENCODED)) {
                    productUsageModel.productUsageTables.put(keyMapByAccount.get(eachODAccount.AR_ID_ENCODED), level2Table);
                }
            }
        }
    }

    private void setProductUsageDetailLevel1(CustomerWealthModel custWealth, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, Map<String, ODLimitModel.ODLimitAccountInfo> odAccountMap, ProductUsageController.ProductUsageTable productUsageTable, Map<String, String> keyMapByAccount) {
        List<List<String>> details = new List<List<String>>();
        if(custWealth != null && custWealth.dataResponse != null && custWealth.dataResponse.Detail != null && custWealth.dataResponse.Detail.AR_DTL_LIST != null) {
            Integer level2Index = 0;
            for(CustomerWealthModel.CustWealthDetailInfo custWealthDetail : custWealth.dataResponse.Detail.AR_DTL_LIST.AR_DTL_INF) {
                LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
                if(lpmDetailMap.containsKey(custWealthDetail.AR_ID_ENCODED)) {
                    lpmDetailInfo = lpmDetailMap.get(custWealthDetail.AR_ID_ENCODED);
                }
                List<String> detailColumns = new List<String>();
                detailColumns.add(custWealthDetail.AR_ID_FORMATTED);//01-เลขที่บัญชี
                detailColumns.add(custWealthDetail.DOMC_BR_NO);//02-รหัสสาขา
                detailColumns.add(custWealthDetail.DOMC_BR_NM);//03-ชื่อสาขา
                detailColumns.add(custWealthDetail.AR_NM_TH);//04-ชื่อบัญชี
                detailColumns.add(sumLimitAmount(odAccountMap, custWealthDetail.AR_ID_ENCODED));//05-วงเงิน (Limit) //custWealthDetail.OD_LMT_AMT
                detailColumns.add(custWealthDetail.SUM_CRN_BAL);//06-ยอดคงเหลือ (Outstanding)
                detailColumns.add(custWealthDetail.SUM_HOLD_BAL_AMT);//07-Hold Balance Amount
                detailColumns.add(custWealthDetail.OPN_DT);//08-วันเปิดบัญชี
                detailColumns.add(lpmDetailInfo.TDR_F_TEXT);//09-ปรับโครงสร้าง / สอบทาน
                detailColumns.add(lpmDetailInfo.DLQ_DYS);//10-จำนวนวันค้างชำระ
                detailColumns.add(custWealthDetail.PD_DSC_EN);//11-ชื่อผลิตภัณฑ์
                detailColumns.add(custWealthDetail.AR_OWN_TP_CD_TYPE);//12-ประเภทบัญชี
                detailColumns.add(lpmDetailInfo.LPM_CST_ID);//13-LPM_NO
                detailColumns.add(custWealth.dataResponse.Detail.IP_ID);//14-CIS_ID
                if(odAccountMap != null && odAccountMap.containsKey(custWealthDetail.AR_ID_ENCODED)) {//15-Next Model Key
                    String level2Key = productCode + '_' + custWealthDetail.AR_ID + '_2_' + level2Index;
                    keyMapByAccount.put(custWealthDetail.AR_ID_ENCODED, level2Key);
                    detailColumns.add(level2Key);
                    level2Index++;
                } else {
                    detailColumns.add('');
                }
                details.add(detailColumns);
            }
        }

        productUsageTable.body = details;
    }

    private void setProductUsageDetailLevel2(ODLimitModel.ODLimitAccountInfo accountInfo, ProductUsageController.ProductUsageTable productUsageTable) {
        List<List<String>> details = new List<List<String>>();
        if(accountInfo != null && accountInfo.OD_LMT_LIST != null) {
            for(ODLimitModel.ODLimitDetailInfo odDetail : accountInfo.OD_LMT_LIST.OD_LMT_INF) {
                List<String> detailColumns = new List<String>();
                detailColumns.add(accountInfo.AR_ID_FORMATTED);//01-เลขที่บัญชี
                detailColumns.add(odDetail.CA_LMT_AR_ID);//02-ลำดับที่ของวงเงิน
                detailColumns.add(odDetail.LMT_EFF_DT);//03-วันที่วงเงินมีผล
                detailColumns.add(odDetail.LMT_END_DT);//04-วันที่ครบกำหนด
                detailColumns.add(odDetail.LMT_CTR_DT);//05-วันที่ลงนามสัญญา
                detailColumns.add(odDetail.CRN_AMT_LMT);//06-วงเงิน (Limit)
                detailColumns.add(odDetail.LMT_INT_RATE);//07-อัตราดอกเบี้ยปัจจุบัน
                detailColumns.add(odDetail.LMT_INT_RATE_TP_TEXT);//08-ประเภทอัตราดอกเบี้ย
                detailColumns.add(odDetail.LMT_INT_EFF_DT);//09-วันที่อัตราดอกเบี้ยมีผล
                details.add(detailColumns);
            }
        }
        System.debug('details : ' + details);
        productUsageTable.body = details;
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

    private Map<String, ODLimitModel.ODLimitAccountInfo> getODAccountMap(ODLimitModel odLimit) {
        Map<String, ODLimitModel.ODLimitAccountInfo> odAccountMap = new Map<String, ODLimitModel.ODLimitAccountInfo>();
        if(odLimit != null && odLimit.dataResponse != null && odLimit.dataResponse.Header != null) {
            Integer totalRecord;
            try {
                totalRecord = Integer.valueOf(odLimit.dataResponse.Header.TOT_RCRD);
            } catch (Exception e) {
                totalRecord = 0;
            }

            if(totalRecord > 0 && odLimit.dataResponse.Detail != null && odLimit.dataResponse.Detail.OD_AR_LIST != null) {
                for(ODLimitModel.ODLimitAccountInfo odAccountInfo : odLimit.dataResponse.Detail.OD_AR_LIST.OD_AR_INF) {
                    odAccountMap.put(odAccountInfo.AR_ID_ENCODED, odAccountInfo);
                }
            }
        }
        return odAccountMap;
    }

    private String sumLimitAmount(Map<String, ODLimitModel.ODLimitAccountInfo> odAccountMap, String accountIdEncoded) {
        String resultText = '0';
        Decimal result = 0;
        if(odAccountMap != null && odAccountMap.containsKey(accountIdEncoded)) {
            ODLimitModel.ODLimitAccountInfo odAccount = odAccountMap.get(accountIdEncoded);
            if(odAccount != null && odAccount.OD_LMT_LIST != null) {
                for(ODLimitModel.ODLimitDetailInfo odDetail : odAccount.OD_LMT_LIST.OD_LMT_INF) {
                    if(String.isNotBlank(odDetail.CRN_AMT_LMT)) {
                        try {
							result += Decimal.valueOf(odDetail.CRN_AMT_LMT);
						} catch (Exception e) {
							System.debug(e.getStackTraceString());
						}
                    }
                }
                resultText = result.setscale(2).toPlainString();
            }
        }
        return resultText;
    }
}