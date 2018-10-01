@isTest
private class TransformationTaweesup_Test {
    @isTest 
	static void test_TaweesupTransform_Positive() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', taweesupResponse(), null);
        Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '17272004';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation productUsageTransformer = new TransformationTaweesup(cisId, 'TWD', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable =  productUsages.productUsageTables.get('TWD_0');
		Test.stopTest();

		system.assertEquals(1, productUsages.productUsageTables.size());
		system.assertEquals(0, productUsageTable.columnHeaders.size());
		system.assertEquals(3, productUsageTable.body.size());
        system.assertEquals(14, productUsageTable.body[0].size());
		system.assertEquals(14, productUsageTable.body[1].size());
		system.assertEquals(14, productUsageTable.body[2].size());
    }

	private static String taweesupResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-01T15:42:27+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180801_f7423371d50645f08d96d21db6a76d48","RSP_TMS":"2018-08-01T15:42:28.088","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"17272004","CIS_SRC_STM_CD":"75","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-02-15","AR_ID":"0011564186","AR_NM_EN":"NATTHAYAPORN YATOON","AR_NM_TH":"ณัฐิญาภรณ์ ยะตุ่น","AR_OWN_TP_CD":"2","PD_DSC_EN":"Special Fixed Deposit (KB)","SUM_CRN_BAL":"24597.05","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"0.00","DOMC_BR_NO":"0481","DOMC_BR_NM":"สาขาถนนสุขุมวิท นาเกลือ","AR_LCS_TP_CD":"4","OPN_DT":"2015-07-21","CLS_DT":"","EFF_RATE_PCT":"0.00000","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_EFF_INT_RATE_TP_CD":"2.00000","SUB_EFF_SPRD_RATE_PCT":"3.00000"}]},"AR_ST_LIST":null},{"POS_DT":"2018-02-15","AR_ID":"4974305711","AR_NM_EN":"NATTHAYAPORN YATOON","AR_NM_TH":"ณัฐิญาภรณ์ ยะตุ่น","AR_OWN_TP_CD":"1","PD_DSC_EN":"Special Fixed Deposit (KB)","SUM_CRN_BAL":"24597.05","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"0.00","DOMC_BR_NO":"0481","DOMC_BR_NM":"สาขาถนนสุขุมวิท นาเกลือ","AR_LCS_TP_CD":"4","OPN_DT":"2015-07-21","CLS_DT":"","EFF_INT_RATE_TP_CD":"10.00000","EFF_SPRD_RATE_PCT":"5.00000","EFF_RATE_PCT":"0.00000","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null},{"POS_DT":"2018-02-15","AR_ID":"3840023490","AR_NM_EN":"NATTHAYAPORN YATOON","AR_NM_TH":"ณัฐิญาภรณ์ ยะตุ่น","AR_OWN_TP_CD":"0","PD_DSC_EN":"Special Fixed Deposit (KB)","SUM_CRN_BAL":"24597.05","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"0.00","DOMC_BR_NO":"0481","DOMC_BR_NM":"สาขาถนนสุขุมวิท นาเกลือ","AR_LCS_TP_CD":"4","OPN_DT":"2015-07-21","CLS_DT":"","EFF_RATE_PCT":"0.00000","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null}]}}}}';
		return response;
	}
}