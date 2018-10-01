public class TransformationLendingAcceptance implements IProductUsageTransformation {
    private String cisId;
    private String productCode;
    private IProductUsageConfig productUsageConfig;
    private final String typeId = '8006,8060,8600';
    private Map<String, List<FNCModel.FNCDetailInfo>> fncDetailListMapByAccount = new Map<String, List<FNCModel.FNCDetailInfo>>();
    private Map<String, String> keyMapByAccount = new Map<String, String>();
    private List<Integer> indexKey = new List<Integer>{0};//Level 2 account detail
    private final Integer MAX_LEVEL = 2; // sub-commitment , account detail
    private final String ROOT_LEVEL_2 = 'root-level2';

    public TransformationLendingAcceptance(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
        FNCModel fncModel = getFNCModel();
        LPMModel lpmModel = getLPMModel();

        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = getLPMDetailMap(lpmModel);
        
        groupDataToMap(fncModel, fncDetailListMapByAccount);
        List<List<ProductUsageController.ProductUsageField>> columnHeaderList = new List<List<ProductUsageController.ProductUsageField>>();
        
        for(Integer i = 1;i <= MAX_LEVEL;i++) {
            columnHeaderList.add(productUsageConfig.getColumnHeaders(productCode, i));
        }

        for(String key : fncDetailListMapByAccount.keySet()) {
            List<FNCModel.FNCDetailInfo> fncDetailList = fncDetailListMapByAccount.get(key);
            ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
            Integer level = (key == ROOT_LEVEL_2 ) ? 1 : 2;
            String ownerIpId = fncModel.dataResponse.Detail.IP_ID;
            productUsageTable.columnHeaders = columnHeaderList.get(level-1);
            setProductUsageDetail(fncDetailList, lpmDetailMap, productUsageTable, level, fncDetailListMapByAccount.keySet(), ownerIpId);
       
            if(key == ROOT_LEVEL_2 ){
                productUsageModel.productUsageTables.put(level1Key, productUsageTable);
            }else {
                if(!keyMapByAccount.containsKey(key)) {
                    keyMapByAccount.put(key, ProductUsageHelper.generateModelKey(productCode, key, level, indexKey));
                }
                productUsageModel.productUsageTables.put(keyMapByAccount.get(key), productUsageTable);
            }
        }
    }

    private void groupDataToMap(FNCModel fncModel, Map<String, List<FNCModel.FNCDetailInfo>> fncDetailListMapByAccount) {
        if(fncModel != null && fncModel.dataResponse != null && fncModel.dataResponse.Detail != null && fncModel.dataResponse.Detail.PCB_LMT_AR_LIST != null) {
            for(FNCModel.FNCDetailInfo fncDetail : fncModel.dataResponse.Detail.PCB_LMT_AR_LIST.PCB_LMT_AR_INF) {
                if(fncDetail.LMT_AR_ID == fncDetail.ROOT_LMT_AR_ID) {
                    if(fncDetail.LMT_LVL_IND == '2'){
                        if(!fncDetailListMapByAccount.containsKey(ROOT_LEVEL_2)) {
                            fncDetailListMapByAccount.put(ROOT_LEVEL_2, new List<FNCModel.FNCDetailInfo>());
                        }
                        fncDetailListMapByAccount.get(ROOT_LEVEL_2).add(fncDetail);
                        if(fncDetail.PCB_AR_LIST != null && fncDetail.PCB_AR_LIST.PCB_AR_INF.size() > 0) {
                            fncDetailListMapByAccount.put(fncDetail.LMT_AR_ID, new List<FNCModel.FNCDetailInfo>{fncDetail});
                        }
                    }
                }
            }
        }
    }

    private void setProductUsageDetail(List<FNCModel.FNCDetailInfo> fncDetailList, Map<String, LPMModel.LPMDetailInfo> lpmDetailMap, ProductUsageController.ProductUsageTable productUsageTable, Integer level, Set<String> accountIdSet, String ownerIpId) {
        List<List<String>> details = new List<List<String>>();
        for(FNCModel.FNCDetailInfo fncDetail : fncDetailList) {
            LPMModel.LPMDetailInfo lpmDetailInfo = new LPMModel.LPMDetailInfo();
            switch on level {
                when 1 {
                    FNCModel.FNCDetailIP fncDetailIPFiltered = filteredDetailIP(fncDetail.PCB_LMT_IP_LIST, ownerIpId);
                    FNCModel.FNCDetailInfoAR fncDetailARFiltered = filteredDetailAR(fncDetail.PCB_AR_LIST);
                    String nextLevelKey = '';
                    String limitId = fncDetail.LMT_AR_ID;
                    if(lpmDetailMap.containsKey(fncDetail.LMT_AR_ID_ENCODED)) {
                        lpmDetailInfo = lpmDetailMap.get(fncDetail.LMT_AR_ID_ENCODED);
                    }
                    if(accountIdSet.contains(limitId)) {
                        if(!keyMapByAccount.containsKey(limitId)) {
                            keyMapByAccount.put(limitId, ProductUsageHelper.generateModelKey(productCode, limitId, level+1, indexKey));
                        }
                        nextLevelKey = keyMapByAccount.get(limitId);
                    }
                    details.add(setRowSubCommitmentLevel(fncDetail, lpmDetailInfo, level, fncDetailIPFiltered, fncDetailARFiltered, nextLevelKey));
                }
                when 2 {
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

    private List<String> setRowSubCommitmentLevel(FNCModel.FNCDetailInfo fncDetail, LPMModel.LPMDetailInfo lpmDetailInfo, Integer level, FNCModel.FNCDetailIP fncDetailIP, FNCModel.FNCDetailInfoAR fncDetailAR, String nextLevelKey) {
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
        detailColumns.add(nextLevelKey);// 15
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

    private Map<String, LPMModel.LPMDetailInfo> getLPMDetailMap(LPMModel lpmModel) {
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = new Map<String, LPMModel.LPMDetailInfo>();
        if(lpmModel != null && lpmModel.dataResponse  != null && lpmModel.dataResponse.Detail  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST  != null) {
            for(LPMModel.LPMDetailInfo lpmDetailInfo : lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF) {
                lpmDetailMap.put(lpmDetailInfo.AR_ID_ENCODED, lpmDetailInfo);
            }
        }
        return lpmDetailMap;
    }

    private FNCModel getFNCModel(){
        HTTPResponse fncResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FNC_ENDPOINT,'CIS_ID=' + cisId + '&PD_TP_CD=' + typeId);
        FNCModel fncModel = (FNCModel) JSON.deserialize(fncResp.getBody(), FNCModel.class);
        return fncModel;
    }

    private LPMModel getLPMModel(){
        HTTPResponse lpmResp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.LPM_TDR_ENDPOINT,'CIS_ID=' + cisId);
        LPMModel lpmModel = (LPMModel) JSON.deserialize(lpmResp.getBody(), LPMModel.class);
        return lpmModel;
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
}