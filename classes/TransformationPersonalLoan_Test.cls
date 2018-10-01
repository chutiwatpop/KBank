@isTest
private class TransformationPersonalLoan_Test {
	@isTest
	static void testTransformPersonalLoan() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', personalLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String, HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '17835994';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation plTransformer = new TransformationPersonalLoan(cisId, 'KPL', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = plTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('KPL_0');
		Test.stopTest();

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('100008477099', productUsageTable.body[0][0]);
		System.AssertEquals('005077288899', productUsageTable.body[0][1]);
		System.AssertEquals('17835994', productUsageTable.body[0][19]);
		System.AssertEquals('', productUsageTable.body[1][19]);
    	System.AssertEquals('', productUsageTable.body[1][10]);
		System.AssertEquals('', productUsageTable.body[2][19]);
    	System.AssertEquals('500.00', productUsageTable.body[2][10]);
		System.AssertEquals('17835994', productUsageTable.body[3][19]);
    	System.AssertEquals('', productUsageTable.body[3][10]);

	}

	@isTest
	static void testTransformPersonalLoanWithoutLPMResponse() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', personalLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', emptyLPMResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String, HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '17835994';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation plTransformer = new TransformationPersonalLoan(cisId, 'KPL', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = plTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('KPL_0');
		Test.stopTest();

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('', productUsageTable.body[1][16]);
		System.AssertEquals('', productUsageTable.body[1][17]);
		System.AssertEquals('', productUsageTable.body[1][18]);
	}

	private static String personalLoanResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_FNC_SVC_AR_DTL","RQS_UNQ_ID":"2018-08-23T16:47:04+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_7de51343971d49e99edc8b8dfa097ee8","RSP_TMS":"2018-08-23T16:47:06.067","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"17835994","POS_DT":"2018-08-22","PCB_LMT_AR_LIST":{"PCB_LMT_AR_INF":[{"LMT_AR_ID":"005077288899","ORIG_AR_ID":"100008477099","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"005077288899","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"028","LMT_KBNK_IDY_CL_CD":"010050000","CTR_DT":"2016-08-26","EFF_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","SETUP_LMT_AMT":"70000.00","CTR_LMT_AMT":"70000.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"005077288899","AR_ID_ENCODED":"qA9Qphllg5GI1cUjdSutuQ==","ORIG_AR_ID":"100008477099","LMT_AR_ID":"005077288899","ROOT_LMT_AR_ID":"005077288899","AR_PPS_TP_CD":"028","KBNK_IDY_CL_CD":"010050000","OPN_DT":"2016-08-26","EFF_DT":"2016-08-26","CTR_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":"","CTR_AR_TERM":"12","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","LPM_CLSS":"2","LMT_AMT":"70000.00","PNP_AMT":"10099.96","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"45.23","RVRS_F":"2","RVRS_DT":"2017-10-03","MEMO_ACR_INT_AMT":"2376.25","OTSND_BAL":"12476.21","TOT_NO_INSTL":"12","EFF_RATE_PCT":"26.00000","EFF_INT_RATE_TP_CD":"011","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"ทีปประชัย สยมพล","AR_NM_EN":"TEEPPRACHAI SAYOMPOL","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-27","LAST_PYMT_DT":"2017-12-16","DDC_AR_ID":"7382744211","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-05-31","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"27","PNP_AMT":"500.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"27","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"005077288899","ORIG_AR_ID":"100008477099","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"005077288899","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"028","LMT_KBNK_IDY_CL_CD":"010050000","CTR_DT":"2016-08-26","EFF_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","SETUP_LMT_AMT":"70000.00","CTR_LMT_AMT":"70000.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"005077288899","AR_ID_ENCODED":"qA9Qphllg5GI1cUjdSutuQ==","ORIG_AR_ID":"100008477099","LMT_AR_ID":"005077288899","ROOT_LMT_AR_ID":"005077288899","AR_PPS_TP_CD":"028","KBNK_IDY_CL_CD":"010050000","OPN_DT":"2016-08-26","EFF_DT":"2016-08-26","CTR_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":"","CTR_AR_TERM":"12","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","LPM_CLSS":"2","LMT_AMT":"70000.00","PNP_AMT":"10099.96","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"45.23","RVRS_F":"2","RVRS_DT":"2017-10-03","MEMO_ACR_INT_AMT":"2376.25","OTSND_BAL":"12476.21","TOT_NO_INSTL":"12","EFF_RATE_PCT":"26.00000","EFF_INT_RATE_TP_CD":"011","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"ทีปประชัย สยมพล","AR_NM_EN":"TEEPPRACHAI SAYOMPOL","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-27","LAST_PYMT_DT":"2017-12-16","DDC_AR_ID":"7382744211","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":null}]}},{"LMT_AR_ID":"005077288899","ORIG_AR_ID":"100008477099","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"005077288899","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"028","LMT_KBNK_IDY_CL_CD":"010050000","CTR_DT":"2016-08-26","EFF_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","SETUP_LMT_AMT":"70000.00","CTR_LMT_AMT":"70000.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"005077288899","AR_ID_ENCODED":"qA9Qphllg5GI1cUjdSutuQ==","ORIG_AR_ID":"100008477099","LMT_AR_ID":"005077288899","ROOT_LMT_AR_ID":"005077288899","AR_PPS_TP_CD":"028","KBNK_IDY_CL_CD":"010050000","OPN_DT":"2016-08-26","EFF_DT":"2016-08-26","CTR_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":"","CTR_AR_TERM":"12","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","LPM_CLSS":"2","LMT_AMT":"70000.00","PNP_AMT":"10099.96","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"45.23","RVRS_F":"2","RVRS_DT":"2017-10-03","MEMO_ACR_INT_AMT":"2376.25","OTSND_BAL":"12476.21","TOT_NO_INSTL":"12","EFF_RATE_PCT":"26.00000","EFF_INT_RATE_TP_CD":"011","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"ทีปประชัย สยมพล","AR_NM_EN":"TEEPPRACHAI SAYOMPOL","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-27","LAST_PYMT_DT":"2017-12-16","DDC_AR_ID":"7382744211","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-05-31","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"27","PNP_AMT":"500.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"27","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"005077288899","ORIG_AR_ID":"100008477099","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"005077288899","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"028","LMT_KBNK_IDY_CL_CD":"010050000","CTR_DT":"2016-08-26","EFF_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","SETUP_LMT_AMT":"70000.00","CTR_LMT_AMT":"70000.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"005077288899","AR_ID_ENCODED":"qA9Qphllg5GI1cUjdSutuQ==","ORIG_AR_ID":"100008477099","LMT_AR_ID":"005077288899","ROOT_LMT_AR_ID":"005077288899","AR_PPS_TP_CD":"028","KBNK_IDY_CL_CD":"010050000","OPN_DT":"2016-08-26","EFF_DT":"2016-08-26","CTR_DT":"2016-08-26","MAT_DT":"2017-08-26","CLS_DT":"","CTR_AR_TERM":"12","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7200","PD_SUB_TP_CD":"12001","MKT_CD":"0002","COA_PD_FTR_CD":"110570003","LPM_CLSS":"2","LMT_AMT":"70000.00","PNP_AMT":"10099.96","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"45.23","RVRS_F":"2","RVRS_DT":"2017-10-03","MEMO_ACR_INT_AMT":"2376.25","OTSND_BAL":"12476.21","TOT_NO_INSTL":"12","EFF_RATE_PCT":"26.00000","EFF_INT_RATE_TP_CD":"011","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"ทีปประชัย สยมพล","AR_NM_EN":"TEEPPRACHAI SAYOMPOL","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-27","LAST_PYMT_DT":"2017-12-16","DDC_AR_ID":"7382744211","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"17835994","AR_OWN_TP_CD":"2"}]},"PYMT_SHD_LIST":null}]}}]}}}}';
		return response;
	}

	private static String lpmResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180824_133d841fceb8484ebd6d597460c0e467","RSP_TMS":"2018-08-24T10:47:04.719","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"3"},"Detail":{"IP_ID":"17835994","LPM_DTL_LIST":{"LPM_DTL_INF":[{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"qA9Qphllg5GI1cUjdSutuQ==","DLQ_DYS":"182","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"JmMnMdV4EM1YHQhPmhg5sA==","DLQ_DYS":"182","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"s8k2WZS2c778ohPpqbiK7w==","DLQ_DYS":"182","TDR_F":"Y"}]}}}}';
        return response;
    }

	private static String emptyLPMResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_5fcc580ea843477e8ed9d2678b1b6938","RSP_TMS":"2018-08-23T10:46:24.841","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"17835994","LPM_DTL_LIST":null}}}';
        return response;
    }
}