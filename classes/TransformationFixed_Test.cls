@isTest
private class TransformationFixed_Test {
	@isTest
	static void test_TransformationFixed() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', fixedResponse(), null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '3003851';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation productUsageTransformer = new TransformationFixed(cisId, 'FIX', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('FIX_0');
		ProductUsageController.ProductUsageTable productUsageTableSub1 = productUsages.productUsageTables.get('FIX_xxxxx0140x_2_0');
		ProductUsageController.ProductUsageTable productUsageTableSub2 = productUsages.productUsageTables.get('FIX_xxxxx5145x_2_4');
		Test.stopTest();

		system.assertEquals(4, productUsages.productUsageTables.size());
		system.assertEquals(6, productUsageTable.body.size());
		system.assertEquals('บัญชีเดี่ยว', productUsageTable.body.get(0).get(5));
		system.assertEquals('xxx-x-x8213-x', productUsageTable.body.get(1).get(0));
		system.assertEquals(2, productUsageTableSub1.body.size());
		system.assertEquals('001', productUsageTableSub1.body.get(0).get(0));
		system.assertEquals('002', productUsageTableSub1.body.get(1).get(0));
		system.assertEquals('6M', productUsageTableSub1.body.get(1).get(1));
		system.assertEquals(null, productUsageTableSub2);			
	}

	@isTest
	static void test_TransformationFixed_WithSubEmptyAccountData() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', fixedWithoutSubResponse(), null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '3003851';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation productUsageTransformer = new TransformationFixed(cisId, 'FIX', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('FIX_0');
		Test.stopTest();

		system.assertEquals(1, productUsages.productUsageTables.size());
		system.assertEquals(1, productUsageTable.body.size());
		system.assertEquals('0001', productUsageTable.body.get(0).get(1));
		system.assertEquals('บัญชีเดี่ยว', productUsageTable.body.get(0).get(5));	
	}
	
	private static String fixedResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-16T13:34:54+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180816_abb7437cad3e4054a03527eb5a9b477a","RSP_TMS":"2018-08-16T13:34:55.73","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"6"},"Detail":{"IP_ID":"3003851","CIS_SRC_STM_CD":"74","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-08-15","AR_ID":"xxxxx0140x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"437859.12","SUM_HOLD_BAL_AMT":"200000.00","OD_LMT_AMT":"","DOMC_BR_NO":"0070","DOMC_BR_NM":"สาขาบางเขน","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"000","CRN_BAL":"218929.56","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":""},{"SUB_AR":"001","CRN_BAL":"130734.42","HOLD_BAL_AMT":"120000.00","SUB_AR_TERM":"3","SUB_AR_TERM_UOM_TP_CD":"M","SUB_EFF_RATE_PCT":"0.90000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"2018-07-15","SUB_INT_END_DT":"2018-10-15","SUB_EFF_SPRD_RATE_PCT":"5.00000","SUB_EFF_INT_RATE_TP_CD":"10.00000"},{"SUB_AR":"002","CRN_BAL":"88195.14","HOLD_BAL_AMT":"80000.00","SUB_AR_TERM":"6","SUB_AR_TERM_UOM_TP_CD":"M","SUB_EFF_RATE_PCT":"1.15000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"2018-02-18","SUB_INT_END_DT":"2018-08-18","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null,"AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":""},{"POS_DT":"2018-08-15","AR_ID":"xxxxx8213x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"2000.00","SUM_HOLD_BAL_AMT":"1000.00","OD_LMT_AMT":"","DOMC_BR_NO":"0391","DOMC_BR_NM":"สาขาเซ็นทรัล รัตนาธิเบศร์","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_INT_RATE_TP_CD":"","EFF_SPRD_RATE_PCT":"","EFF_RATE_PCT":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"000","CRN_BAL":"1000.00","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"001","CRN_BAL":"1000.00","HOLD_BAL_AMT":"1000.00","SUB_AR_TERM":"3","SUB_AR_TERM_UOM_TP_CD":"M","SUB_EFF_RATE_PCT":"0.90000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"2018-06-21","SUB_INT_END_DT":"2018-09-21","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null,"AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":""},{"POS_DT":"2018-08-15","AR_ID":"xxxxx9665x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"0.00","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"","DOMC_BR_NO":"0001","DOMC_BR_NM":"สาขาสำนักสีลม","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"000","CRN_BAL":"0.00","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null,"AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":""},{"POS_DT":"2018-08-15","AR_ID":"xxxxx6465x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"2044628.80","SUM_HOLD_BAL_AMT":"1000000.00","OD_LMT_AMT":"","DOMC_BR_NO":"0001","DOMC_BR_NM":"สาขาสำนักสีลม","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"001","CRN_BAL":"204536.72","HOLD_BAL_AMT":"200000.00","SUB_AR_TERM":"12","SUB_AR_TERM_UOM_TP_CD":"M","SUB_EFF_RATE_PCT":"1.30000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"2017-10-27","SUB_INT_END_DT":"2018-10-27","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"002","CRN_BAL":"817777.68","HOLD_BAL_AMT":"800000.00","SUB_AR_TERM":"12","SUB_AR_TERM_UOM_TP_CD":"M","SUB_EFF_RATE_PCT":"1.30000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"2018-03-29","SUB_INT_END_DT":"2019-03-29","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"000","CRN_BAL":"1022314.40","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null},{"POS_DT":"2018-08-15","AR_ID":"xxxxx5145x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"0.00","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"","DOMC_BR_NO":"0001","DOMC_BR_NM":"สาขาสำนักสีลม","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"000","CRN_BAL":"0.00","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null},{"POS_DT":"2018-08-15","AR_ID":"xxxxx5442x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"0.00","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"","DOMC_BR_NO":"0001","DOMC_BR_NM":"สาขาสำนักสีลม","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"000","CRN_BAL":"0.00","HOLD_BAL_AMT":"0.00","SUB_AR_TERM":"0","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"0.00000","UNIT_BAL":"","FND_CD":"","FND_DSC_EN":"","FND_DSC_TH":"","NAV":"","NAV_DT":"","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"0.00000","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null}]}}}}';
		return response;
	}

	private static String fixedWithoutSubResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-16T15:11:31+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180816_16f68d6b70044cedb05e3a8d94cb158a","RSP_TMS":"2018-08-16T15:11:33.336","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"6"},"Detail":{"IP_ID":"3003851","CIS_SRC_STM_CD":"74","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-08-15","AR_ID":"xxxxx6465x","AR_NM_EN":"CHAMCHOOSRI PANJASILA","AR_NM_TH":"แช่มชูศรี ปัญจะศิลา","AR_OWN_TP_CD":"2","PD_DSC_EN":"Fixed Deposit (KB)","SUM_CRN_BAL":"2044628.80","SUM_HOLD_BAL_AMT":"1000000.00","OD_LMT_AMT":"","DOMC_BR_NO":"0001","DOMC_BR_NM":"สาขาสำนักสีลม","AR_LCS_TP_CD":"4","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null}]}}}}';
		return response;
	}
}