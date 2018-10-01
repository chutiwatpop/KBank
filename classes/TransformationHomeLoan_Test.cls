@isTest
private class TransformationHomeLoan_Test {
	@isTest
	static void testTransformHomeloan() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', homeLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String, HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '11';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation hlTransformer = new TransformationHomeLoan(cisId, 'HL', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = hlTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('HL_0');
		Test.stopTest();
		System.debug('Test:' + JSON.serialize(productUsageTable));

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('100015474577', productUsageTable.body[0][0]);
		System.AssertEquals('100015474577', productUsageTable.body[0][1]);
		System.AssertEquals('11', productUsageTable.body[0][19]);
		System.AssertEquals('', productUsageTable.body[1][19]);
    	System.AssertEquals('1200.00', productUsageTable.body[1][10]);
    	System.AssertEquals('', productUsageTable.body[2][10]);
	}

	@isTest
	static void testTransformHomeloanWithoutLPMResponse() {
		SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', homeLoanResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', emptyLPMResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String, HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		String cisId = '17835994';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation hlTransformer = new TransformationHomeLoan(cisId, 'HL', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsageInfo = hlTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsageInfo.productUsageTables.get('HL_0');
		Test.stopTest();

		System.AssertEquals(20, productUsageTable.body[0].size());
		System.AssertEquals(4, productUsageTable.body.size());
		System.AssertEquals('', productUsageTable.body[1][16]);
		System.AssertEquals('', productUsageTable.body[1][17]);
		System.AssertEquals('', productUsageTable.body[1][18]);
	}

	private static String homeLoanResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_FNC_SVC_AR_DTL","RQS_UNQ_ID":"2018-08-23T15:09:29+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_1d9043c0df0b460da8c1d1463ff88006","RSP_TMS":"2018-08-23T15:10:11.235","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"16"},"Detail":{"IP_ID":"11","POS_DT":"2018-08-22","PCB_LMT_AR_LIST":{"PCB_LMT_AR_INF":[{"LMT_AR_ID":"100015474577","ORIG_AR_ID":"100015474577","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"100015474577","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"011","LMT_KBNK_IDY_CL_CD":"010020000","CTR_DT":"2018-06-07","EFF_DT":"2018-06-07","MAT_DT":"2048-06-07","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0010","COA_PD_FTR_CD":"110585001","SETUP_LMT_AMT":"4500000.00","CTR_LMT_AMT":"4500000.00","UNUSED_LMT_AMT":"4500000.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"4500000.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"11","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"100015474577","AR_ID_ENCODED":"eaBzIsAHloe+KqNuBVNAMw==","ORIG_AR_ID":"100015474577","LMT_AR_ID":"100015474577","ROOT_LMT_AR_ID":"100015474577","AR_PPS_TP_CD":"011","KBNK_IDY_CL_CD":"010020000","OPN_DT":"2018-06-07","EFF_DT":"2018-06-07","CTR_DT":"2018-06-07","MAT_DT":"2048-06-07","CLS_DT":"","CTR_AR_TERM":"360","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0010","COA_PD_FTR_CD":"110585001","LPM_CLSS":"0","LMT_AMT":"4500000.00","PNP_AMT":"0.00","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"0","RVRS_DT":"","MEMO_ACR_INT_AMT":"0.00","OTSND_BAL":"0.00","TOT_NO_INSTL":"360","EFF_RATE_PCT":"7.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"นายอาชวิณ หมื่นอาจ","AR_NM_EN":"","PYMT_TP_CD":"0","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"","DDC_AR_ID":"0000000000","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"11","AR_OWN_TP_CD":"2"}]},"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-06-07","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"E","PNP_AMT":"0.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"E","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"100015474585","ORIG_AR_ID":"100015474585","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"100015474585","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"024","LMT_KBNK_IDY_CL_CD":"010020000","CTR_DT":"2018-06-07","EFF_DT":"2018-06-07","MAT_DT":"2048-06-07","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0010","COA_PD_FTR_CD":"110585001","SETUP_LMT_AMT":"5200000.00","CTR_LMT_AMT":"5200000.00","UNUSED_LMT_AMT":"5200000.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"5200000.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"11","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"100015474585","AR_ID_ENCODED":"OgUxVXvNePAwzy5D3lZvqw==","ORIG_AR_ID":"100015474585","LMT_AR_ID":"100015474585","ROOT_LMT_AR_ID":"100015474585","AR_PPS_TP_CD":"024","KBNK_IDY_CL_CD":"010020000","OPN_DT":"2018-06-07","EFF_DT":"2018-06-07","CTR_DT":"2018-06-07","MAT_DT":"2048-06-07","CLS_DT":"","CTR_AR_TERM":"360","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0010","COA_PD_FTR_CD":"110585001","LPM_CLSS":"0","LMT_AMT":"5200000.00","PNP_AMT":"0.00","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"0","RVRS_DT":"","MEMO_ACR_INT_AMT":"0.00","OTSND_BAL":"0.00","TOT_NO_INSTL":"360","EFF_RATE_PCT":"7.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"นายอาชวิณ หมื่นอาจ","AR_NM_EN":"","PYMT_TP_CD":"0","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"","DDC_AR_ID":"0000000000","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":{"PYMT_SHD_INF":[{"CNDT_STRT_DT":"2018-06-07","PYMT_MTH_CD":"15","PYMT_MTH_DSC":"P& I","PNP_PYMT_FRQ_CYC_CD":"1","PNP_PYMT_FRQ_UNIT_CD":"M","PNP_PYMT_FRQ_TP_CD":"A","PNP_PYMT_FRQ_DAY_CD":"E","PNP_AMT":"1200.00","INT_PYMT_FRQ_CYC_CD":"1","INT_PYMT_FRQ_UNIT_CD":"M","INT_PYMT_FRQ_TP_CD":"A","INT_PYMT_FRQ_DAY_CD":"E","INT_AMT":"0.00"}]}}]}},{"LMT_AR_ID":"100015473406","ORIG_AR_ID":"100015473406","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"100015473406","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"024","LMT_KBNK_IDY_CL_CD":"010020000","CTR_DT":"2018-06-04","EFF_DT":"2018-06-04","MAT_DT":"2048-06-04","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11005","MKT_CD":"0001","COA_PD_FTR_CD":"110593001","SETUP_LMT_AMT":"5200000.00","CTR_LMT_AMT":"5200000.00","UNUSED_LMT_AMT":"5200000.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"5200000.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"11","AR_OWN_TP_CD":"2"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"100015473406","AR_ID_ENCODED":"weoIDa1NBkMrSAvvuD2rbQ==","ORIG_AR_ID":"100015473406","LMT_AR_ID":"100015473406","ROOT_LMT_AR_ID":"100015473406","AR_PPS_TP_CD":"024","KBNK_IDY_CL_CD":"010020000","OPN_DT":"2018-06-04","EFF_DT":"2018-06-04","CTR_DT":"2018-06-04","MAT_DT":"2048-06-04","CLS_DT":"","CTR_AR_TERM":"360","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11005","MKT_CD":"0001","COA_PD_FTR_CD":"110593001","LPM_CLSS":"0","LMT_AMT":"5200000.00","PNP_AMT":"0.00","ACR_INT_AMT":"0.00","RVRS_INT_AMT":"0.00","RVRS_F":"0","RVRS_DT":"","MEMO_ACR_INT_AMT":"0.00","OTSND_BAL":"0.00","TOT_NO_INSTL":"360","EFF_RATE_PCT":"7.12000","EFF_INT_RATE_TP_CD":"008","EFF_SPRD_RATE_PCT":"0.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"นายอาชวิณ หมื่นอาจ","AR_NM_EN":"","PYMT_TP_CD":"0","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"","DDC_AR_ID":"0000000000","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":{"PCB_AR_IP_INF":[{"IP_ID":"11","AR_OWN_TP_CD":"2"}]},"PYMT_SHD_LIST":null}]}},{"LMT_AR_ID":"93564483070101","ORIG_AR_ID":"100005881654","UPR_LMT_AR_ID":"000000000000","ROOT_LMT_AR_ID":"93564483070101","LMT_LVL_IND":"3","LMT_AR_PPS_TP_CD":"011","LMT_KBNK_IDY_CL_CD":"010020000","CTR_DT":"2009-10-20","EFF_DT":"2009-10-20","MAT_DT":"2039-10-20","CLS_DT":{"@nil":"false"},"DCN_TP_CD":"0","LMT_TP_CD":"0","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0001","COA_PD_FTR_CD":"110585001","SETUP_LMT_AMT":"2263000.00","CTR_LMT_AMT":"2263000.00","UNUSED_LMT_AMT":"0.00","HOLD_AMT":"0.00","AVL_LMT_AMT":"0.00","TOT_LI_AMT":"0.00","PCB_LMT_IP_LIST":{"PCB_LMT_IP_INF":[{"IP_ID":"8866452","AR_OWN_TP_CD":"0"},{"IP_ID":"11","AR_OWN_TP_CD":"1"}]},"PCB_AR_LIST":{"PCB_AR_INF":[{"AR_ID":"93564483070101","AR_ID_ENCODED":"aTQPp4ssf7BW6MANYINalQ==","ORIG_AR_ID":"100005881654","LMT_AR_ID":"93564483070101","ROOT_LMT_AR_ID":"93564483070101","AR_PPS_TP_CD":"011","KBNK_IDY_CL_CD":"010020000","OPN_DT":"2009-10-20","EFF_DT":"2009-10-20","CTR_DT":"2009-10-20","MAT_DT":"2039-10-20","CLS_DT":"","CTR_AR_TERM":"360","CTR_AR_TERM_UOM_TP_CD":"M","PD_GRP":"LN","PD_TP_CD":"7100","PD_SUB_TP_CD":"11001","MKT_CD":"0001","COA_PD_FTR_CD":"110585001","LPM_CLSS":"1","LMT_AMT":"2263000.00","PNP_AMT":"1979208.60","ACR_INT_AMT":"6547.66","RVRS_INT_AMT":"0.00","RVRS_F":"0","RVRS_DT":"","MEMO_ACR_INT_AMT":"0.00","OTSND_BAL":"1985756.26","TOT_NO_INSTL":"360","EFF_RATE_PCT":"5.25000","EFF_INT_RATE_TP_CD":"002","EFF_SPRD_RATE_PCT":"-1.00000","ORIG_ADV_AR_ID":null,"AR_NM_TH":"อาชวิณ หมื่นอาจ","AR_NM_EN":"ARCHAWIN MUEN-ART","PYMT_TP_CD":"2","PYMT_DUE_DT":"2018-07-31","LAST_PYMT_DT":"2018-07-31","DDC_AR_ID":"0052776449","DDC_INT_TP_CD":"0","FEE_RATE_PCT":"0.00000","CMSN_TP_CD":"0","UPD_FEE_AMT":"0.00","PCB_AR_IP_LIST":null,"PYMT_SHD_LIST":null}]}}]}}}}}';
		return response;
	}

	private static String lpmResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180824_133d841fceb8484ebd6d597460c0e467","RSP_TMS":"2018-08-24T10:47:04.719","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"3"},"Detail":{"IP_ID":"11","LPM_DTL_LIST":{"LPM_DTL_INF":[{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"eaBzIsAHloe+KqNuBVNAMw==","DLQ_DYS":"182","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"OgUxVXvNePAwzy5D3lZvqw==","DLQ_DYS":"182","TDR_F":"Y"},{"POS_DT":"2018-05-31","LPM_CST_ID":"5069038","AR_ID_ENCODED":"weoIDa1NBkMrSAvvuD2rbQ==","DLQ_DYS":"182","TDR_F":"Y"}]}}}}';
        return response;
    }

	private static String emptyLPMResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_5fcc580ea843477e8ed9d2678b1b6938","RSP_TMS":"2018-08-23T10:46:24.841","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"17835994","LPM_DTL_LIST":null}}}';
        return response;
    }
}