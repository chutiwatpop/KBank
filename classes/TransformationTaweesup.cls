public class TransformationTaweesup implements IProductUsageTransformation {
    private String cisId;
	private String productCode;
    private IProductUsageConfig productUsageConfig;
    private final String typeId = '75';

    public TransformationTaweesup(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
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

        HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT,'CIS_ID=' + cisId + '&SCR_STM_CD=' + typeId);
		CustomerWealthModel customerWealth = (CustomerWealthModel) JSON.deserialize(resp.getBody(), CustomerWealthModel.class);

        productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
        setProductUsageDetail(customerWealth, productUsageTable);

		productUsageModel.productUsageTables.put(level1Key, productUsageTable);
    }

    private void setProductUsageDetail(CustomerWealthModel custWealth, ProductUsageController.ProductUsageTable productUsageTable) {
		List<List<String>> details = new List<List<String>>();
        if(custWealth != null && custWealth.dataResponse != null && custWealth.dataResponse.Detail != null && custWealth.dataResponse.Detail.AR_DTL_LIST != null) {
            for(CustomerWealthModel.CustWealthDetailInfo custWealthDetail : custWealth.dataResponse.Detail.AR_DTL_LIST.AR_DTL_INF) {
                List<String> detailColumns = new List<String>();
                detailColumns.add(custWealthDetail.AR_ID_FORMATTED);//01-เลขที่บัญชี
                detailColumns.add(custWealthDetail.DOMC_BR_NO);//02-รหัสสาขา
                detailColumns.add(custWealthDetail.DOMC_BR_NM);//03-ชื่อสาขา
                detailColumns.add(custWealthDetail.PD_DSC_EN);//04-ผลิตภัณฑ์
                detailColumns.add(custWealthDetail.AR_TERM_TEXT);//05-ระยะเวลาฝาก
                detailColumns.add(custWealthDetail.AR_NM_TH);//06-ชื่อบัญชี
                detailColumns.add(custWealthDetail.SUM_CRN_BAL);//07-ยอดคงเหลือ (Outstanding)
                detailColumns.add(custWealthDetail.SUM_HOLD_BAL_AMT);//08-Hold Balance Amount
                detailColumns.add(custWealthDetail.EFF_RATE_PCT);//09-อัตราดอกเบี้ยปัจจุบัน
                detailColumns.add(custWealthDetail.INT_EFF_DT);//10-วันที่อัตราดอกเบี้ยมีผล
                detailColumns.add(custWealthDetail.INT_END_DT);//11-วันที่อัตราดอกเบี้ยสิ้นสุด
                detailColumns.add(custWealthDetail.OPN_DT);//12-วันเปิดบัญชี
                detailColumns.add(custWealthDetail.AR_OWN_TP_CD_TYPE);//13-ประเภทบัญชี
                detailColumns.add(custWealth.dataResponse.Detail.IP_ID);//14-CIS_ID
                details.add(detailColumns);
            }
        }

		productUsageTable.body = details;
	}

    /*private String formatTermUnit(String termUnit) {
        String termUnitText = '';
        switch on termUnit.toUpperCase() {
            when 'M' {
                termUnitText = 'เดือน';
            }
            when else {
                termUnitText = termUnit;
            }
        }
        return termUnitText;
    }*/
}