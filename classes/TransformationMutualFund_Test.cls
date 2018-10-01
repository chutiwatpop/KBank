@isTest
private class TransformationMutualFund_Test {
	@isTest
	static void testTransformMutualFund() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', mutualFundResponse(), null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '3003851';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation mutualFundTransformer = new TransformationMutualFund(cisId, 'FND', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = mutualFundTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('FND_0');
		Test.stopTest();

		System.AssertEquals(10, productUsageTable.body[0].size());
		System.AssertEquals(6, productUsageTable.body.size());
		System.AssertEquals('0000-001-5-03557-9', productUsageTable.body[0][0]);
		System.AssertEquals('009', productUsageTable.body[1][1]);
	}

	@isTest
	static void testTransformMutualFundWithoutSubAccount() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', mutualFundWithoutSubResponse(), null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '26495254';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation mutualFundTransformer = new TransformationMutualFund(cisId, 'FND', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = mutualFundTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('FND_0');
		Test.stopTest();

		System.AssertEquals(10, productUsageTable.body[0].size());
		System.AssertEquals(1, productUsageTable.body.size());
		System.AssertEquals('0000-001-5-03557-9', productUsageTable.body[0][0]);
		System.AssertEquals('', productUsageTable.body[0][1]);
	}

	@isTest
	static void testTransformMutualFundWithMiscellaneousCodeList() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200, 'Complete', mutualFundWithMiscellaneousResponse(), null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '3003852';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation mutualFundTransformer = new TransformationMutualFund(cisId, 'MF', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = mutualFundTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('MF_0');
		Test.stopTest();

		System.AssertEquals(10, productUsageTable.body[0].size());
		System.AssertEquals(6, productUsageTable.body.size());
		System.AssertEquals('0000-001-5-03557-9', productUsageTable.body[0][0]);
		System.AssertEquals('28,30,33', productUsageTable.body[0][9]);
	}

	private static String mutualFundResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-20T11:43:21+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180820_bbeada36cd72434c8f76f0a17f66d4b0","RSP_TMS":"2018-08-20T11:43:21.48","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"3003851","CIS_SRC_STM_CD":"16","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-06-07","AR_ID":"00000015035579","AR_NM_EN":"","AR_NM_TH":"","AR_OWN_TP_CD":"P1","PD_DSC_EN":"Fund","SUM_CRN_BAL":"2045626.87","SUM_HOLD_BAL_AMT":"","OD_LMT_AMT":"","DOMC_BR_NO":"","DOMC_BR_NM":"","AR_LCS_TP_CD":"","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"007","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-PLAN1","FND_DSC_EN":"K PLAN 1 FUND","FND_DSC_TH":"กองทุนเปิดเค แพลน 1","NAV":"12.5513","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"037","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-FIXED","FND_DSC_EN":"K Fixed Income Fund","FND_DSC_TH":"กองทุนเปิดเค ตราสารหนี้","NAV":"12.2148","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"024","CRN_BAL":"690860.42","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"73650.9262","FND_CD":"K-GOLD","FND_DSC_EN":"K Gold Fund","FND_DSC_TH":"กองทุนเปิดเค โกลด์","NAV":"9.3802","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"021","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-SET50","FND_DSC_EN":"K SET 50 Index Fund","FND_DSC_TH":"กองทุนเปิดเค เซ็ท 50","NAV":"35.3079","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"017","CRN_BAL":"1043274.77","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"218706.7143","FND_CD":"K-OIL","FND_DSC_EN":"K Oil Fund","FND_DSC_TH":"กองทุนเปิดเค ออยล์","NAV":"4.7702","NAV_DT":"2018-06-13","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"009","CRN_BAL":"311491.68","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"18316.3601","FND_CD":"K70LTF","FND_DSC_EN":"K Equity 70:30 LTF","FND_DSC_TH":"กองทุนเปิดเค 70:30 หุ้นระยะยาวปันผล","NAV":"17.0062","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":null}]}}}}';
		return response;
	}

	private static String mutualFundWithoutSubResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-20T11:43:21+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180820_bbeada36cd72434c8f76f0a17f66d4b0","RSP_TMS":"2018-08-20T11:43:21.48","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"26495254","CIS_SRC_STM_CD":"16","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-06-07","AR_ID":"00000015035579","AR_NM_EN":"","AR_NM_TH":"","AR_OWN_TP_CD":"P1","PD_DSC_EN":"Fund","SUM_CRN_BAL":"2045626.87","SUM_HOLD_BAL_AMT":"","OD_LMT_AMT":"","DOMC_BR_NO":"","DOMC_BR_NM":"","AR_LCS_TP_CD":"","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":null}]}}}}';
		return response;
	}

	private static String mutualFundWithMiscellaneousResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-20T11:43:21+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180820_bbeada36cd72434c8f76f0a17f66d4b0","RSP_TMS":"2018-08-20T11:43:21.48","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"3003852","CIS_SRC_STM_CD":"16","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-06-07","AR_ID":"00000015035579","AR_NM_EN":"","AR_NM_TH":"","AR_OWN_TP_CD":"P1","PD_DSC_EN":"Fund","SUM_CRN_BAL":"2045626.87","SUM_HOLD_BAL_AMT":"","OD_LMT_AMT":"","DOMC_BR_NO":"","DOMC_BR_NM":"","AR_LCS_TP_CD":"","OPN_DT":"","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":{"SUB_AR_DTL_INF":[{"SUB_AR":"007","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-PLAN1","FND_DSC_EN":"K PLAN 1 FUND","FND_DSC_TH":"กองทุนเปิดเค แพลน 1","NAV":"12.5513","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"037","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-FIXED","FND_DSC_EN":"K Fixed Income Fund","FND_DSC_TH":"กองทุนเปิดเค ตราสารหนี้","NAV":"12.2148","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"024","CRN_BAL":"690860.42","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"73650.9262","FND_CD":"K-GOLD","FND_DSC_EN":"K Gold Fund","FND_DSC_TH":"กองทุนเปิดเค โกลด์","NAV":"9.3802","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"021","CRN_BAL":"0.00","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"0.0000","FND_CD":"K-SET50","FND_DSC_EN":"K SET 50 Index Fund","FND_DSC_TH":"กองทุนเปิดเค เซ็ท 50","NAV":"35.3079","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"017","CRN_BAL":"1043274.77","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"218706.7143","FND_CD":"K-OIL","FND_DSC_EN":"K Oil Fund","FND_DSC_TH":"กองทุนเปิดเค ออยล์","NAV":"4.7702","NAV_DT":"2018-06-13","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""},{"SUB_AR":"009","CRN_BAL":"311491.68","HOLD_BAL_AMT":"","SUB_AR_TERM":"","SUB_AR_TERM_UOM_TP_CD":"","SUB_EFF_RATE_PCT":"","UNIT_BAL":"18316.3601","FND_CD":"K70LTF","FND_DSC_EN":"K Equity 70:30 LTF","FND_DSC_TH":"กองทุนเปิดเค 70:30 หุ้นระยะยาวปันผล","NAV":"17.0062","NAV_DT":"2018-06-14","SUB_INT_EFF_DT":"","SUB_INT_END_DT":"","SUB_EFF_SPRD_RATE_PCT":"","SUB_EFF_INT_RATE_TP_CD":""}]},"AR_ST_LIST":{"AR_ST_INF":[{"STRT_DT":"","MISC_CD":"28"},{"STRT_DT":"","MISC_CD":"30"},{"STRT_DT":"","MISC_CD":"33"}]}}]}}}}';
		return response;
	}
}