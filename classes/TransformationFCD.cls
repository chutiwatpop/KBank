public class TransformationFCD implements IProductUsageTransformation {
    private String cisId;
	private String productCode;
    private IProductUsageConfig productUsageConfig;
    private Map<String, String> keyMapByIdEncoded = new Map<String, String>();
    private final String LEVEL_ROOT = 'root';
    
    public TransformationFCD(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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
        HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.FCD_ENDPOINT,'CIS_ID=' + cisId);
        FCDResponseModel fcdResponseModel = (FCDResponseModel) JSON.deserialize(resp.getBody(), FCDResponseModel.class);

        FCDTransformedContent fcdTransformedContent = new FCDTransformedContent();
        fcdTransformedContent.fcdTransformeds = groupDataToMap(fcdResponseModel);
        fcdTransformedContent.ipId = fcdResponseModel.dataResponse.Detail.IP_ID;
        setProductUsageDetail(productUsageModel, fcdTransformedContent);
    }

    private List<FCDTransformed> groupDataToMap(FCDResponseModel fcdResponseModel) {
        Map<String, FCDTransformed> listFCDTransformedMap = new Map<String, FCDTransformed>();

        if(fcdResponseModel != null && fcdResponseModel.dataResponse != null && fcdResponseModel.dataResponse.Detail != null 
            && fcdResponseModel.dataResponse.Detail.AR_DTL_LIST != null && fcdResponseModel.dataResponse.Detail.AR_DTL_LIST.FCD_AR_DTL_INF != null) {
            for(FCDResponseModel.FCDDetailInfo itemDetail : fcdResponseModel.dataResponse.Detail.AR_DTL_LIST.FCD_AR_DTL_INF) {
                // Loop data and map output for sub account level
                if(!String.isBlank(itemDetail.SUB_AR) && Integer.valueOf(itemDetail.SUB_AR) > 0) {
                    // If loop found sub account before account exists in the list
                    if(!listFCDTransformedMap.containsKey(itemDetail.AR_ID_ENCODED)) {
                        FCDTransformed itemAccount = new FCDTransformed();
                        itemAccount.subAccount.add(itemDetail);
                        listFCDTransformedMap.put(itemDetail.AR_ID_ENCODED, itemAccount);
                    } else {
                        listFCDTransformedMap.get(itemDetail.AR_ID_ENCODED).subAccount.add(itemDetail);
                    }
                }
                // Loop data and map output for account level
                else {
                    if(!listFCDTransformedMap.containsKey(itemDetail.AR_ID_ENCODED)) {
                        FCDTransformed itemAccount = new FCDTransformed();
                        itemAccount.account = itemDetail;
                        listFCDTransformedMap.put(itemDetail.AR_ID_ENCODED, itemAccount);
                    } else {
                        listFCDTransformedMap.get(itemDetail.AR_ID_ENCODED).account = itemDetail;
                    }
                }
            }
        }

        return listFCDTransformedMap.values();
    }

    private void setProductUsageDetail(ProductUsageController.ProductUsageModel productUsageModel, FCDTransformedContent fcdTransformedContent) {
        String ownerIpId = fcdTransformedContent.ipId;
        List<FCDTransformed> listFCDTransformed = fcdTransformedContent.fcdTransformeds;
        ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
        List<ProductUsageController.ProductUsageField> columnHeadersLevel2 = productUsageConfig.getColumnHeaders(productCode, 2);
        List<List<String>> details = new List<List<String>>();
        List<Integer> indexKey = new List<Integer>{0};//Level 2

        productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);

        for(FCDTransformed fcdTransformed : listFCDTransformed) {
            FCDResponseModel.FCDDetailInfo accountInfo = fcdTransformed.account;
            String nextLevelKey = '';

            if(fcdTransformed.subAccount.size() > 0) {
                nextLevelKey = ProductUsageHelper.generateModelKey(productCode, accountInfo.AR_ID, 2, indexKey);
                setProductUsageDetailSubLevel(productUsageModel, fcdTransformed.subAccount, columnHeadersLevel2, ownerIpId, nextLevelKey);
            }

            details.add(setRowLevel1(accountInfo, ownerIpId, nextLevelKey));
        }

        productUsageTable.body = details;
        productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
    }

    private void setProductUsageDetailSubLevel(ProductUsageController.ProductUsageModel productUsageModel, List<FCDResponseModel.FCDDetailInfo> fcdDetailList, List<ProductUsageController.ProductUsageField> columnHeadersLevel2, String ownerIpId, String nextLevelKey) {
        ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
        List<List<String>> details = new List<List<String>>();

        productUsageTable.columnHeaders = columnHeadersLevel2;

        for(FCDResponseModel.FCDDetailInfo subInfo : sortBySubAccount(fcdDetailList)) {
            details.add(setRowLevel2(subInfo, ownerIpId));
        }

        productUsageTable.body = details;
        productUsageModel.productUsageTables.put(nextLevelKey, productUsageTable);
    }

    private List<String> setRowLevel1(FCDResponseModel.FCDDetailInfo itemDetail, String ownerIpId, String nextLevelKey) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(itemDetail.AR_ID_FORMATTED);//01-เลขที่บัญชี
        detailColumns.add(itemDetail.DOMC_BR_NO);//02-รหัสสาขา
        detailColumns.add(itemDetail.DOMC_BR_NM);//03-ชื่อสาขา
        detailColumns.add(itemDetail.FCD_TP_CD);//04-ประเภทบัญชี FCD
        detailColumns.add(itemDetail.PD_TP_CD_TXT);//05-ประเภทผลิตภัณฑ์
        detailColumns.add(itemDetail.AR_NM);//06-ชื่อบัญชี
        detailColumns.add(itemDetail.CCY_CD);//07-รหัสสกุลเงิน
        detailColumns.add(itemDetail.CCY_OTSND_BAL);//08-ยอดคงเหลือ (CCY Outstanding)
        detailColumns.add(itemDetail.CNVR_OTSND_BAL);//09-ยอดคงเหลือ (THB Outstanding)
        detailColumns.add(itemDetail.MID_RATE);//10-อัตราแลกเปลี่ยนกลับเป็นเงินบาท
        detailColumns.add(itemDetail.CCY_HLD_AMT);//11-CCY Hold Bal Amount
        detailColumns.add(itemDetail.EFF_INT_RATE);//12-อัตราดอกเบี้ยปัจจุบัน
        detailColumns.add(itemDetail.EFF_INT_RATE_TP_ID_TXT);//13-ประเภทอัตราดอกเบี้ย
        detailColumns.add(itemDetail.EFF_DT);//14-วันที่อัตราดอกเบี้ยมีผล
        detailColumns.add(itemDetail.MAT_DT);//15-วันที่อัตราดอกเบี้ยสิ้นสุด
        detailColumns.add(itemDetail.OPN_DT);//16-วันเปิดบัญชี
        detailColumns.add(itemDetail.AR_OWN_TP_CD_TYPE);//17-ประเภทบัญชี
        detailColumns.add(ownerIpId);//18-CIS_ID
        detailColumns.add(nextLevelKey);//19-Next Model Key
        return detailColumns;
    }

    private List<String> setRowLevel2(FCDResponseModel.FCDDetailInfo itemDetail, String ownerIpId) {
        List<String> detailColumns = new List<String>();
        detailColumns.add(itemDetail.SUB_AR);//01-เลขที่บัญชีระดับ SUB
        detailColumns.add(itemDetail.DOMC_BR_NO);//02-รหัสสาขา
        detailColumns.add(itemDetail.DOMC_BR_NM);//03-ชื่อสาขา
        detailColumns.add(itemDetail.FCD_TP_CD);//04-ประเภทบัญชี FCD
        detailColumns.add(itemDetail.PD_TP_CD_TXT);//05-ประเภทผลิตภัณฑ์
        detailColumns.add(itemDetail.AR_NM);//06-ชื่อบัญชี
        detailColumns.add(itemDetail.CCY_CD);//07-รหัสสกุลเงิน
        detailColumns.add(itemDetail.CCY_OTSND_BAL);//08-ยอดคงเหลือ (CCY Outstanding)
        detailColumns.add(itemDetail.CNVR_OTSND_BAL);//09-ยอดคงเหลือ (THB Outstanding)
        detailColumns.add(itemDetail.MID_RATE);//10-อัตราแลกเปลี่ยนกลับเป็นเงินบาท
        detailColumns.add(itemDetail.CCY_HLD_AMT);//11-CCY Hold Bal Amount
        detailColumns.add(itemDetail.EFF_INT_RATE);//12-อัตราดอกเบี้ยปัจจุบัน
        detailColumns.add(itemDetail.EFF_INT_RATE_TP_ID_TXT);//13-ประเภทอัตราดอกเบี้ย
        detailColumns.add(itemDetail.EFF_DT);//14-วันที่อัตราดอกเบี้ยมีผล
        detailColumns.add(itemDetail.MAT_DT);//15-วันที่อัตราดอกเบี้ยสิ้นสุด
        detailColumns.add(itemDetail.OPN_DT);//16-วันเปิดบัญชี
        detailColumns.add(itemDetail.AR_OWN_TP_CD_TYPE);//17-ประเภทบัญชี
        detailColumns.add(ownerIpId);//18-CIS_ID
        return detailColumns;
    }

    private List<FCDResponseModel.FCDDetailInfo> sortBySubAccount(List<FCDResponseModel.FCDDetailInfo> fcdDetailList) {
        Map<String, FCDResponseModel.FCDDetailInfo> fcdDetailMapBySub = new Map<String, FCDResponseModel.FCDDetailInfo>();
        List<String> subAccountList = new List<String>();
        List<FCDResponseModel.FCDDetailInfo> fcdDetailSortedList = new List<FCDResponseModel.FCDDetailInfo>();
        for(FCDResponseModel.FCDDetailInfo fcdDetail : fcdDetailList) {
            fcdDetailMapBySub.put(fcdDetail.SUB_AR, fcdDetail);
        }
        subAccountList.addAll(fcdDetailMapBySub.keyset());
        subAccountList.sort();
        for(Integer i = 0;i < subAccountList.size();i++) {
            fcdDetailSortedList.add(fcdDetailMapBySub.get(subAccountList.get(i)));
        }
        return fcdDetailSortedList;
    }

    public class FCDTransformedContent {
        String ipId;
        List<FCDTransformed> fcdTransformeds;

        FCDTransformedContent() {
            fcdTransformeds = new List<FCDTransformed>();
        }
    }

    public class FCDTransformed {
        FCDResponseModel.FCDDetailInfo account;
        List<FCDResponseModel.FCDDetailInfo> subAccount;

        FCDTransformed() {
            account = new FCDResponseModel.FCDDetailInfo();
            subAccount = new List<FCDResponseModel.FCDDetailInfo>();
        }
    }
}