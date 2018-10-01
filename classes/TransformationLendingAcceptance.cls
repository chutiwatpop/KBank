public class TransformationLendingAcceptance implements IProductUsageTransformation {
    private String cisId;
    private String productCode;
    private IProductUsageConfig productUsageConfig;
    
    private Map<Integer, List<ProductUsageController.ProductUsageField>> columnHeaderMap;
    private Map<String, String> modelKeyMapByAccount = new Map<String, String>();
    
    private final String TYPE_ID = '8006,8060,8600';
    private final Integer COMMITMENT_LEVEL = 1;
    private final Integer SUBCOMMITMENT_LEVEL = 2;
    private final Integer ACCOUNT_LEVEL = 3;
    private final Integer LIMIT_ID_INDEX = 1;
    private final Integer COMMITMENT_NEXT_LEVEL_KEY_INDEX = 14;
    private final Integer SUBCOMMITMENT_NEXT_LEVEL_KEY_INDEX = 14;

    public TransformationLendingAcceptance(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
        this.cisId = cisId;
        this.productCode = productCode;
        this.productUsageConfig = productUsageConfig;
    }

    public ProductUsageController.ProductUsageModel transform() {
        ProductUsageController.ProductUsageModel productUsageModel = new ProductUsageController.ProductUsageModel();
        FNCModel fncModel = getFNCModel();
        LPMModel lpmModel = getLPMModel();
        productUsageModel.siteMap = productUsageConfig.getSiteMaps(productCode);
        productUsageModel.productUsageTables = setProductUsageTable(fncModel, lpmModel);
        return productUsageModel;
    }

    private Map<String, ProductUsageController.ProductUsageTable> setProductUsageTable(FNCModel fncModel, LPMModel lpmModel) {
        String level1Key = productCode + '_0';
        Map<String, ProductUsageController.ProductUsageTable> productUsageTables = new Map<String, ProductUsageController.ProductUsageTable>();
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = ProductUsageHelper.getLPMDetailMap(lpmModel);
        
        if(fncModel != null && fncModel.dataResponse != null && fncModel.dataResponse.Detail != null && fncModel.dataResponse.Detail.PCB_LMT_AR_LIST != null) {
            String ownerIpId = fncModel.dataResponse.Detail.IP_ID;
            Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap = ProductUsageHelper.calculateAccountData(fncModel.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF);

            for(FNCModel.FNCDetailInfo fncDetail : fncModel.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF) {
                Integer level = Integer.valueOf(fncDetail.LMT_LVL_IND);
                LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
                if(lpmDetailMap.containsKey(fncDetail.LMT_AR_ID_ENCODED)) {
                    lpmDetailInfo = lpmDetailMap.get(fncDetail.LMT_AR_ID_ENCODED);
                }

                if(fncDetail.LMT_AR_ID == fncDetail.ROOT_LMT_AR_ID) {
                    if(level == ProductUsageHelper.COMMITMENT_DATA) {
                        ProductUsageController.CalculatedAccount calculatedResult = new ProductUsageController.CalculatedAccount();
                        if(calculatedAccountMap.containsKey(fncDetail.LMT_AR_ID)) {
                            calculatedResult = calculatedAccountMap.get(fncDetail.LMT_AR_ID);
                        }

                        setCommitmentLevel(productUsageTables, fncDetail, lpmDetailInfo, calculatedResult, ownerIpId, level1Key);
                    } else if(level == ProductUsageHelper.SUBCOMMITMENT_DATA) {
                        setSubCommitmentLevel(productUsageTables, fncDetail, lpmDetailInfo, '', ownerIpId, level1Key);
                        setAccountLevel(productUsageTables, fncDetail.PCB_AR_LIST, lpmDetailMap, fncDetail.LMT_AR_ID);
                    } else {
                        //Create temp commitment
                        FNCModel.FNCDetailInfo fncDetailTemp = new FNCModel.FNCDetailInfo();
                        fncDetailTemp.LMT_AR_ID = fncDetail.LMT_AR_ID + 'COM';
                        fncDetailTemp.ORIG_AR_ID = fncDetail.ORIG_AR_ID;
                        ProductUsageController.CalculatedAccount calculatedResult = new ProductUsageController.CalculatedAccount();
                        calculatedResult.hideItemCount = true;
                        
                        setCommitmentLevel(productUsageTables, fncDetailTemp,  new LPMModel.LPMDetailInfo(), calculatedResult, '', level1Key);
                        setAccountLevel(productUsageTables, fncDetail.PCB_AR_LIST, lpmDetailMap, fncDetailTemp.LMT_AR_ID);
                    }
                } else {
                    setSubCommitmentLevel(productUsageTables, fncDetail, lpmDetailInfo, fncDetail.UPR_LMT_AR_ID, ownerIpId, '');
                    setAccountLevel(productUsageTables, fncDetail.PCB_AR_LIST, lpmDetailMap, fncDetail.LMT_AR_ID);
                }
            }
        }

        setNextLevelKey(productUsageTables);

        return productUsageTables;
    }

    private void setCommitmentLevel(Map<String, ProductUsageController.ProductUsageTable> productUsageTables, FNCModel.FNCDetailInfo fncDetail, LPMModel.LPMDetailInfo lpmDetailInfo, ProductUsageController.CalculatedAccount calculatedResult, String ownerIpId, String keyModel) {
        FNCModel.FNCDetailIP fncDetailIPFiltered = String.isBlank(ownerIpId) ? new FNCModel.FNCDetailIP() : ProductUsageHelper.filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);

        if(!productUsageTables.containsKey(keyModel)) {
            ProductUsageController.ProductUsageTable tableCommitment = new ProductUsageController.ProductUsageTable();
            tableCommitment.columnHeaders = getColumnHeader(COMMITMENT_LEVEL);
            productUsageTables.put(keyModel, tableCommitment);
        }
                        
        productUsageTables.get(keyModel).body.add(setRowCommitmentLevel(fncDetail, fncDetailIPFiltered, lpmDetailInfo, calculatedResult));
    }

    private void setSubCommitmentLevel(Map<String, ProductUsageController.ProductUsageTable> productUsageTables, FNCModel.FNCDetailInfo fncDetail, LPMModel.LPMDetailInfo lpmDetailInfo, String limitId, String ownerIpId, String rootKeyModel) {
        FNCModel.FNCDetailIP fncDetailIPFiltered = ProductUsageHelper.filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
        FNCModel.FNCDetailInfoAR fncDetailARFiltered = ProductUsageHelper.filteredDetailAR(fncDetail.PCB_AR_LIST);

        String keyModel = String.isBlank(limitId) ? rootKeyModel : ProductUsageHelper.generateModelKey(productCode, limitId, SUBCOMMITMENT_LEVEL);
        if(!productUsageTables.containsKey(keyModel)) {
            ProductUsageController.ProductUsageTable tableLevelSub = new ProductUsageController.ProductUsageTable();
            tableLevelSub.columnHeaders = getColumnHeader(SUBCOMMITMENT_LEVEL);
            productUsageTables.put(keyModel, tableLevelSub);
            if(String.isNotBlank(limitId)) {
                modelKeyMapByAccount.put(limitId, keyModel);
            }
        }
        productUsageTables.get(keyModel).body.add(setRowSubCommitmentLevel(fncDetail, fncDetailIPFiltered, fncDetailARFiltered, lpmDetailInfo));
    }

    private void setAccountLevel(Map<String, ProductUsageController.ProductUsageTable> productUsageTables, FNCModel.FNCDetailSub PCB_AR_LIST, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, String limitId) {
        if(PCB_AR_LIST != null) {
            String keyModel = ProductUsageHelper.generateModelKey(productCode, limitId, ACCOUNT_LEVEL);
            for(FNCModel.FNCDetailInfoAR fncDetailAR : PCB_AR_LIST.PCB_AR_INF) {
                FNCModel.FNCDetailInfoARIP fncDetailInfoArIpFiltered = ProductUsageHelper.filteredDetailInfoARIP(fncDetailAR.PCB_AR_IP_LIST);
                LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
                if(lpmDetailMap.containsKey(fncDetailAR.AR_ID_ENCODED)) {
                    lpmDetailInfo = lpmDetailMap.get(fncDetailAR.AR_ID_ENCODED);
                }

                if(!productUsageTables.containsKey(keyModel)) {
                    ProductUsageController.ProductUsageTable tableLevelAccount = new ProductUsageController.ProductUsageTable();
                    tableLevelAccount.columnHeaders = getColumnHeader(ACCOUNT_LEVEL);
                    productUsageTables.put(keyModel, tableLevelAccount);
                    modelKeyMapByAccount.put(limitId, keyModel);
                }
                productUsageTables.get(keyModel).body.add(setRowAccountLevel(fncDetailAR, lpmDetailInfo, fncDetailInfoArIpFiltered));
            }
        }
    }

    private List<String> setRowCommitmentLevel(FNCModel.FNCDetailInfo fncDetail, FNCModel.FNCDetailIP fncDetailIP, LPMModel.LPMDetailInfo lpmDetailInfo, ProductUsageController.CalculatedAccount calculatedResult) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetail.ORIG_AR_ID); // 1 เลขที่บัญชี
        detailColumns.add(fncDetail.LMT_AR_ID);// 2 เลขที่บัญชีเดิม 
        detailColumns.add(fncDetailIP.AR_OWN_TP_CD_TYPE);// 3 ประเภทวงเงิน
        detailColumns.add(fncDetail.LMT_AR_NM_TH);// 4 ชื่อบัญชี
        detailColumns.add(fncDetail.PD_DSC);// 5 ผลิตภัณฑ์
        detailColumns.add(calculatedResult.itemCountText);// 6 จำนวนตั๋ว(ฉบับ)
        detailColumns.add(fncDetail.SETUP_LMT_AMT);// 7 วงเงิน(Limit)
        detailColumns.add(calculatedResult.outstandingBalanceText);// 8 มูลค่าหนีงสือค้ำประกัน
        detailColumns.add(fncDetail.EFF_DT);// 9 วันที่วงเงินมีผล
        detailColumns.add(fncDetail.MAT_DT);// 10 วันที่ครบกำหนด
        detailColumns.add(fncDetail.CTR_DT);// 11  วันที่ลงนามสัญญา
        detailColumns.add(fncDetail.LMT_TP_CD_TYPE);// 12 ประเภทของการทบทวนวงเงิน
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//13 LPM_NO
        detailColumns.add(fncDetailIP.IP_ID);//14 CIS_ID
        detailColumns.add('');// 15 Next Model Key
        return detailColumns;
    }

    private List<String> setRowSubCommitmentLevel(FNCModel.FNCDetailInfo fncDetail, FNCModel.FNCDetailIP fncDetailIP, FNCModel.FNCDetailInfoAR fncDetailAR, LPMModel.LPMDetailInfo lpmDetailInfo) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetail.ORIG_AR_ID); // 1 เลขที่บัญชี
        detailColumns.add(fncDetail.LMT_AR_ID);// 2 เลขที่บัญชีเดิม 
        detailColumns.add(fncDetailIP.AR_OWN_TP_CD_TYPE);// 3 ประเภทวงเงิน
        detailColumns.add(fncDetail.LMT_AR_NM_TH);// 4 ชื่อบัญชี
        detailColumns.add(fncDetail.PD_DSC);// 5 ผลิตภัณฑ์
        detailColumns.add(fncDetailAR.ITEM_COUNT);// 6 จำนวนตั๋ว(ฉบับ)
        detailColumns.add(fncDetail.SETUP_LMT_AMT);// 7 วงเงิน(Limit)
        detailColumns.add(fncDetailAR.OTSND_BAL);// 8 มูลค่าหนีงสือค้ำประกัน
        detailColumns.add(fncDetail.EFF_DT);// 9 วันที่วงเงินมีผล
        detailColumns.add(fncDetail.MAT_DT);// 10 วันที่ครบกำหนด
        detailColumns.add(fncDetail.CTR_DT);// 11  วันที่ลงนามสัญญา
        detailColumns.add(fncDetail.LMT_TP_CD_TYPE);// 12 ประเภทของการทบทวนวงเงิน
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//13 LPM_NO
        detailColumns.add(fncDetailIP.IP_ID);//14 CIS_ID
        detailColumns.add('');// 15 Next Model Key
        return detailColumns;
    }

    private List<String> setRowAccountLevel(FNCModel.FNCDetailInfoAR fncDetailAR, LPMModel.LPMDetailInfo lpmDetailInfo, FNCModel.FNCDetailInfoARIP fncDetailInfoARIP) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(fncDetailAR.ORIG_AR_ID);//1 เลขที่บัญชี
        detailColumns.add(fncDetailAR.AR_ID);//2 เลขที่บัญชีเดิม (Converted Account)
        detailColumns.add(fncDetailAR.AR_NM_TH);//3 ชื่อบัญชี
        detailColumns.add(fncDetailAR.PD_DSC);//4 ผลิตภัณฑ์
        detailColumns.add(fncDetailAR.OTSND_BAL);//5 มูลค่าหนังสือค้ำประกัน
        detailColumns.add(fncDetailAR.FEE_RATE_PCT);//6 อัตราค่าธรรมเนียม  (Fee Rate)
        detailColumns.add(fncDetailAR.PYMT_TP_CD_TYPE);//7 รหัสการคำนวณค่าธรรมเนียม (Cal Code)
        detailColumns.add(fncDetailAR.UPD_FEE_AMT);//8 ค่าธรรมเนียมค้างชำระ
        detailColumns.add(fncDetailAR.EFF_DT);//9 วันที่เปิดตั๋ว
        detailColumns.add(fncDetailAR.MAT_DT);//10 วันครบกำหนด
        detailColumns.add(fncDetailAR.DDC_AR_ID_FORMATTED);//11เลขที่บัญชีสำหรับหักเงินอัติโนมัติ
        detailColumns.add(lpmDetailInfo.TDR_F_TEXT);//12 ปรับโครงสร้างหนี้ / สอบทาน
        detailColumns.add(lpmDetailInfo.DLQ_DYS);//13 จำนวนวันค้างชำระ
        detailColumns.add(lpmDetailInfo.LPM_CST_ID);//14 LPM_NO
        detailColumns.add(fncDetailInfoARIP.IP_ID);//15 CIS_ID
        return detailColumns;
    }

    private FNCModel getFNCModel(){
        HTTPResponse fncResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FNC_ENDPOINT,'CIS_ID=' + cisId + '&PD_TP_CD=' + TYPE_ID);
        FNCModel fncModel = (FNCModel) JSON.deserialize(fncResp.getBody(), FNCModel.class);
        return fncModel;
    }

    private LPMModel getLPMModel(){
        HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
        LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        return lpmModel;
    }

    private List<ProductUsageController.ProductUsageField> getColumnHeader(Integer modelLevel) {
        if(columnHeaderMap == null) {
            columnHeaderMap = new Map<Integer, List<ProductUsageController.ProductUsageField>>();
            for(Integer i = 1;i <= 3;i++) {
                columnHeaderMap.put(i, productUsageConfig.getColumnHeaders(productCode, i));
            }
        }

        return columnHeaderMap.get(modelLevel);
    }

    private void setNextLevelKey(Map<String, ProductUsageController.ProductUsageTable> productUsageTables) {
        for(String key : productUsageTables.keySet()) {
            List<String> keySplit = key.split('_');
            List<List<String>> rows = productUsageTables.get(key).body;
            //For commitment level or sub-commitment level  : [product code]_0
            Boolean isCommitmentLevel = keySplit.get(1) == '0';
            //For sub-commitment level : [product code]_[LIMIT_ID]_[level]
            Boolean isSubCommitmentLevel = keySplit.size() == 3 && keySplit.get(2) == '2';

            if(isCommitmentLevel) {
                for(List<String> row : rows) {
                    if(modelKeyMapByAccount.containsKey(row.get(LIMIT_ID_INDEX))) {
                        row.set(COMMITMENT_NEXT_LEVEL_KEY_INDEX, modelKeyMapByAccount.get(row.get(LIMIT_ID_INDEX)));
                        if(String.isBlank(row.get(5))) {//temporary logic : column จำนวนตั๋ว(ฉบับ) is blank when this row is temp
                            row.set(LIMIT_ID_INDEX, '');//clear เลขที่บัญชีเดิม when not use
                        }
                    }
                }
            } else if(isSubCommitmentLevel) {
                for(List<String> row : rows) {
                    if(modelKeyMapByAccount.containsKey(row.get(LIMIT_ID_INDEX))) {
                        row.set(SUBCOMMITMENT_NEXT_LEVEL_KEY_INDEX, modelKeyMapByAccount.get(row.get(LIMIT_ID_INDEX)));
                    }
                }
            }
        }
    }
}