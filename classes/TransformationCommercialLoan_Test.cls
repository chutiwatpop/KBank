@isTest
private class TransformationCommercialLoan_Test {
	@isTest
	static void testTransformCommercialloan() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', commercialLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '21027657';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation comTransformer = new TransformationCommercialLoan(cisId, 'COM', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = comTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('COM_0');
		Test.stopTest();

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('000055107499', productUsageTable.body[0][1]);
		System.AssertEquals('100006756500', productUsageTable.body[0][0]);
		System.AssertEquals('กู้ร่วม(รอง)', productUsageTable.body[0][2]);
		System.AssertEquals('1300.00', productUsageTable.body[0][10]);
		System.AssertEquals('21027657,20816572', productUsageTable.body[0][19]);
		System.AssertEquals('', productUsageTable.body[1][2]);
    	System.AssertEquals('15300.00', productUsageTable.body[1][10]);
		System.AssertEquals('', productUsageTable.body[1][19]);
		System.AssertEquals('กู้ร่วม(รอง)', productUsageTable.body[2][2]);
    	System.AssertEquals('', productUsageTable.body[2][10]);
		System.AssertEquals('21027657,20816572', productUsageTable.body[2][19]);
		System.AssertEquals('', productUsageTable.body[3][2]);
    	System.AssertEquals('', productUsageTable.body[3][10]);
		System.AssertEquals('', productUsageTable.body[3][19]);
	}

	@isTest
	static void testTransformCommercialloanWithoutLPMResponse() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', commercialLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', emptyLPMResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '21027657';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation comTransformer = new TransformationCommercialLoan(cisId, 'COM', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = comTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('COM_0');
		Test.stopTest();

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('', productUsageTable.body[1][16]);
		System.AssertEquals('', productUsageTable.body[1][17]);
		System.AssertEquals('', productUsageTable.body[1][18]);
	}

	private static String commercialLoanResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_FNC_SVC_AR_DTL","RQS_UNQ_ID":"2018-08-28T14:36:18+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180828_db6a806e00a84b4d967d061ec85ccf1c","RSP_TMS":"2018-08-28T14:36:22.599","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"4"},"Detail":{"IP_ID":"21027657","POS_DT":"2018-08-27","PCB_LMT_AR_LIST":{"PCB_LMT_AR_INF":[{"LMT_AR_ID":"000055107499","ORIG_AR_ID":"100006756500","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"000055107499","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"027","LMT_KBNK_IDY_CL_CD":"005022903","CTR_DT":"2014-05-08","EFF_DT":"2014-05-08","MAT_DT":"2019-05-08","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"0006","COA_PD_FTR_CD":"110581001","SETUP_LMT_AMT":"57908.00","CTR_LMT_AMT":"57908.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"000055107499","AR_ID_ENCODED":"XHKKEZ6oyW463YnO9ovzMw==","ORIG_AR_ID":"100006756500","LMT_AR_ID":"000055107499","ROOT_LMT_AR_ID":"000055107499","AR_PPS_TP_CD":"027","KBNK_IDY_CL_CD":"005022903","OPN_DT":"2014-05-08","EFF_DT":"2014-05-08","CTR_DT":"2014-05-08","MAT_DT":"2019-05-08","CLS_DT":"","CTR_AR_TERM":"60","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"0006","COA_PD_FTR_CD":"110581001","LPM_CLSS":"2","LMT_AMT":"57908.00","PNP_AMT":"23599.21","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"2","RVRS_DT":"2017-08-19","MEMO_ACR_INT_AMT":"2372.97","OTSND_BAL":"27270.16","TOT_NO_INSTL":"60","EFF_RATE_PCT":"10.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"3.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"อินฝน สายจุม","AR_NM_EN":"INFHON SAIJUM","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"2017-09-26","DDC_AR_ID":"4732089387","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-05-31","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"31","PNP_AMT":"1300.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"31","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"47360000460101","ORIG_AR_ID":"100004567212","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"47360000460101","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"052","LMT_KBNK_IDY_CL_CD":"005022903","CTR_DT":"2016-08-15","EFF_DT":"2016-09-06","MAT_DT":"2020-06-15","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"9001","COA_PD_FTR_CD":"110581001","SETUP_LMT_AMT":"450055.20","CTR_LMT_AMT":"450055.20","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"47360000460101","AR_ID_ENCODED":"gHlqXjy6Rpx66xEoHxKI+g==","ORIG_AR_ID":"100004567212","LMT_AR_ID":"47360000460101","ROOT_LMT_AR_ID":"47360000460101","AR_PPS_TP_CD":"052","KBNK_IDY_CL_CD":"005022903","OPN_DT":"2016-09-06","EFF_DT":"2016-09-06","CTR_DT":"2016-08-15","MAT_DT":"2020-06-15","CLS_DT":"","CTR_AR_TERM":"47","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"9001","COA_PD_FTR_CD":"110581001","LPM_CLSS":"2","LMT_AMT":"450055.20","PNP_AMT":"450055.20","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"2","RVRS_DT":"2017-01-30","MEMO_ACR_INT_AMT":"65233.61","OTSND_BAL":"515288.81","TOT_NO_INSTL":"47","EFF_RATE_PCT":"10.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"3.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"อินฝน สายจุม","AR_NM_EN":"INFHON SAIJUM","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"2017-08-25","DDC_AR_ID":"4732089387","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-05-31","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"E","PNP_AMT":"15300.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"E","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"47360000460301","ORIG_AR_ID":"100004567220","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"47360000460301","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"052","LMT_KBNK_IDY_CL_CD":"005022903","CTR_DT":"2016-08-15","EFF_DT":"2016-09-06","MAT_DT":"2022-03-15","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"9001","COA_PD_FTR_CD":"110581001","SETUP_LMT_AMT":"284506.13","CTR_LMT_AMT":"284506.13","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"47360000460301","AR_ID_ENCODED":"N8XntQbqynbGEkjO0evDkQ==","ORIG_AR_ID":"100004567220","LMT_AR_ID":"47360000460301","ROOT_LMT_AR_ID":"47360000460301","AR_PPS_TP_CD":"052","KBNK_IDY_CL_CD":"005022903","OPN_DT":"2016-09-06","EFF_DT":"2016-09-06","CTR_DT":"2016-08-15","MAT_DT":"2022-03-15","CLS_DT":"","CTR_AR_TERM":"68","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"9001","COA_PD_FTR_CD":"110581001","LPM_CLSS":"2","LMT_AMT":"284506.13","PNP_AMT":"284506.13","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"2","RVRS_DT":"2017-01-30","MEMO_ACR_INT_AMT":"39411.53","OTSND_BAL":"323917.66","TOT_NO_INSTL":"68","EFF_RATE_PCT":"10.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"3.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"อินฝน สายจุม","AR_NM_EN":"INFHON SAIJUM","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"2017-08-25","DDC_AR_ID":"0083297131","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PYMT_SHD_LIST":null}]}},{"LMT_AR_ID":"004054797599","ORIG_AR_ID":"100008020668","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"004054797599","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"027","LMT_KBNK_IDY_CL_CD":"005022903","CTR_DT":"2016-02-02","EFF_DT":"2016-02-02","MAT_DT":"2021-02-02","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"0006","COA_PD_FTR_CD":"110581001","SETUP_LMT_AMT":"26355.00","CTR_LMT_AMT":"26355.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"21027657","AR_OWN_TP_CD":"0"},{"IP_ID":"20816572","AR_OWN_TP_CD":"1"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"004054797599","AR_ID_ENCODED":"OddsrTc3gSY7VUSWd+JDJw==","ORIG_AR_ID":"100008020668","LMT_AR_ID":"004054797599","ROOT_LMT_AR_ID":"004054797599","AR_PPS_TP_CD":"027","KBNK_IDY_CL_CD":"005022903","OPN_DT":"2016-02-02","EFF_DT":"2016-02-02","CTR_DT":"2016-02-02","MAT_DT":"2021-02-02","CLS_DT":"","CTR_AR_TERM":"60","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"COM","PD_TP_CD":"8100","PD_SUB_TP_CD":"41001","MKT_CD":"0006","COA_PD_FTR_CD":"110581001","LPM_CLSS":"2","LMT_AMT":"26355.00","PNP_AMT":"20249.74","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"2","RVRS_DT":"2017-08-19","MEMO_ACR_INT_AMT":"2032.30","OTSND_BAL":"23382.78","TOT_NO_INSTL":"60","EFF_RATE_PCT":"10.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"3.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"อินฝน สายจุม","AR_NM_EN":"INFHON SAIJUM","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"2017-09-26","DDC_AR_ID":"0083297131","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":null}]}}]}}}}';
		return response;
	}

	private static String lpmResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180828_33ac738cd0d143498fbafc7b8652a96d","RSP_TMS":"2018-08-28T17:40:52.302","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"10"},"Detail":{"IP_ID":"21027657","LPM_DTL_LIST":{"LPM_DTL_INF":[{"POS_DT":"","LPM_CST_ID":"","AR_ID_ENCODED":"1B2M2Y8AsgTpgAmY7PhCfg==","DLQ_DYS":"","TDR_F":""},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"iYNDsojZzwEG0venNU3h4Q==","DLQ_DYS":"0","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"XHKKEZ6oyW463YnO9ovzMw==","DLQ_DYS":"31","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"tGHJnKePgFnRNqF6erpcjw==","DLQ_DYS":"0","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"OddsrTc3gSY7VUSWd+JDJw==","DLQ_DYS":"31","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"gHlqXjy6Rpx66xEoHxKI+g==","DLQ_DYS":"31","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"Hvx8r0IkytFx09tUTx/8jQ==","DLQ_DYS":"0","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"N8XntQbqynbGEkjO0evDkQ==","DLQ_DYS":"31","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"hi+IpAwgGZyErwAYmVCJrg==","DLQ_DYS":"0","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"4874198","AR_ID_ENCODED":"mo/oJ5yokZePSurR1nUV0A==","DLQ_DYS":"","TDR_F":""}]}}}}';
		return response;
	}

	private static String emptyLPMResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_5fcc580ea843477e8ed9d2678b1b6938","RSP_TMS":"2018-08-23T10:46:24.841","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"21027657","LPM_DTL_LIST":null}}}';
		return response;
	}
}