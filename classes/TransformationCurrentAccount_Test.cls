@isTest
private class TransformationCurrentAccount_Test {
    @isTest
    static void testCurrentAccountTransform_Positive() {
        SingleRequestMock custWealthResponse = new SingleRequestMock(200, 'Complete', currentResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
        SingleRequestMock odResponse = new SingleRequestMock(200, 'Complete', odResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT, custWealthResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        endpointRespMap.put(SME_CIRestWebservice.OD_LIMIT_ENDPOINT, odResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        String cisId = '454059';
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        IProductUsageTransformation productUsageTransformer = new TransformationCurrentAccount(cisId, 'CRN', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('CRN_0');
        Test.stopTest();

		system.assertEquals(2, productUsages.productUsageTables.size());
		system.assertEquals(0, productUsageTable.columnHeaders.size());
		system.assertEquals(2, productUsageTable.body.size());
        system.assertEquals(15, productUsageTable.body[0].size());
		system.assertEquals(15, productUsageTable.body[1].size());
    }

    @isTest
    static void testCurrentWithODTransform_Positive() {
        SingleRequestMock custWealthResponse = new SingleRequestMock(200, 'Complete', currentResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
        SingleRequestMock odResponse = new SingleRequestMock(200, 'Complete', odResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT, custWealthResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        endpointRespMap.put(SME_CIRestWebservice.OD_LIMIT_ENDPOINT, odResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        String cisId = '454059';
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        IProductUsageTransformation productUsageTransformer = new TransformationCurrentAccount(cisId, 'OD', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable level1Table = productUsages.productUsageTables.get('OD_0');
        ProductUsageController.ProductUsageTable level2Table = productUsages.productUsageTables.get('OD_xxxxx1930x_2_0');
        Test.stopTest();

		system.assertEquals(2, productUsages.productUsageTables.size());
		system.assertEquals(0, level1Table.columnHeaders.size());
		system.assertEquals(2, level1Table.body.size());
        system.assertEquals(15, level1Table.body[0].size());
		system.assertEquals(15, level1Table.body[1].size());
        system.assertEquals(0, level2Table.columnHeaders.size());
		system.assertEquals(5, level2Table.body.size());
        system.assertEquals(9, level2Table.body[0].size());
        system.assertEquals(9, level2Table.body[2].size());
        system.assertEquals(9, level2Table.body[4].size());
    }

    @isTest
    static void testCurrentAccountWithoutRecordNumber(){
        SingleRequestMock custWealthResponse = new SingleRequestMock(200, 'Complete', currentResponse(), null);
		SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', lpmResponse(), null);
        SingleRequestMock odResponse = new SingleRequestMock(200, 'Complete', odWithoutRecordNumberResponse(), null);
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
        endpointRespMap.put(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT, custWealthResponse);
        endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
        endpointRespMap.put(SME_CIRestWebservice.OD_LIMIT_ENDPOINT, odResponse);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        String cisId = '454059';
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        IProductUsageTransformation productUsageTransformer = new TransformationCurrentAccount(cisId, 'OD', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('OD_0');
        Test.stopTest();
        
        system.assertEquals(1, productUsages.productUsageTables.size());
		system.assertEquals(2, productUsageTable.body.size());
    }

    private static String currentResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-08-21T18:08:29+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180821_72fdaec4c4084009b03cc98bd185ae10","RSP_TMS":"2018-08-21T18:08:30.213","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"2"},"Detail":{"IP_ID":"454059","CIS_SRC_STM_CD":"73","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-08-20","AR_ID":"xxxxx1930x","AR_ID_ENCODED":"R9/uBl+ZOKJaJp096ga9Sw==","AR_NM_EN":"CHITSUK HANVIRIYAROJ","AR_NM_TH":"ชิตสุข หาญวิริยะโรจน์","AR_OWN_TP_CD":"2","PD_DSC_EN":"Current (KB)","SUM_CRN_BAL":"30000.00","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"20000000.00","DOMC_BR_NO":"0038","DOMC_BR_NM":"สาขาถนนสาทร","AR_LCS_TP_CD":"4","OPN_DT":"2000-05-22","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null},{"POS_DT":"2018-08-20","AR_ID":"xxxxx0517x","AR_ID_ENCODED":"5oSSPvCsR8BWMLRdB2DLdA==","AR_NM_EN":"CHITSUK HANVIRIYAROJ","AR_NM_TH":"ชิตสุข หาญวิริยะโรจน์","AR_OWN_TP_CD":"2","PD_DSC_EN":"Current (KB)","SUM_CRN_BAL":"24081.50","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"0.00","DOMC_BR_NO":"0410","DOMC_BR_NM":"สาขาท่าแซะ","AR_LCS_TP_CD":"4","OPN_DT":"2008-04-01","CLS_DT":"","EFF_RATE_PCT":"","AR_TERM":"","AR_TERM_UOM_TP_CD":"","INT_EFF_DT":"","INT_END_DT":"","EFF_SPRD_RATE_PCT":"","EFF_INT_RATE_TP_CD":"","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null}]}}}}';
        return response;
    }

    private static String lpmResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180821_e80c393cdf544c1b9857091c76c595e5","RSP_TMS":"2018-08-21T18:08:55.692","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"175"},"Detail":{"IP_ID":"454059","LPM_DTL_LIST":{"LPM_DTL_INF":[{"POS_DT":"2018-05-31","LPM_CST_ID":"810306","AR_ID_ENCODED":"KQOTaUINjw6GyVSaP9N+kg==","DLQ_DYS":"","TDR_F":""},{"POS_DT":"2018-05-31","LPM_CST_ID":"810306","AR_ID_ENCODED":"Jka1MWJfrMy8YCdEbtpwQQ==","DLQ_DYS":"","TDR_F":""},{"POS_DT":"2018-05-31","LPM_CST_ID":"810306","AR_ID_ENCODED":"R9/uBl+ZOKJaJp096ga9Sw==","DLQ_DYS":"","TDR_F":""},{"POS_DT":"2018-05-31","LPM_CST_ID":"810306","AR_ID_ENCODED":"5oSSPvCsR8BWMLRdB2DLdA==","DLQ_DYS":"","TDR_F":""},{"POS_DT":"2018-05-31","LPM_CST_ID":"810306","AR_ID_ENCODED":"5yOPma3xPpN7uGRFK0JGoA==","DLQ_DYS":"","TDR_F":""}]}}}}';
        return response;
    }

    private static String odResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_OD_LMT_DTL","RQS_UNQ_ID":"2018-08-21T16:35:08+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180821_c8b4cf34faee4b9b8e801b91b8851fad","RSP_TMS":"2018-08-21T16:35:08.767","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"454059","POS_DT":"2018-08-20","OD_AR_LIST":{"OD_AR_INF":[{"AR_ID":"xxxxx1930x","AR_ID_ENCODED":"R9/uBl+ZOKJaJp096ga9Sw==","EFF_INT_RATE_TP_CD":"","EFF_SPRD_RATE_PCT":"0.00000","INT_RATE_IND":"N","COA_PD":"210101","CRN_BAL":"30000.00","TOT_LMT_AMT":"20000000.00","OD_AR_IP_LIST":{"OD_AR_IP_INF":[{"IP_ID":"454059","AR_OWN_TP_CD":"2"}]},"OD_LMT_LIST":{"OD_LMT_INF":[{"CA_LMT_AR_ID":"0000000009","DOMC_BR_NO":"0038","CRN_AMT_LMT":"300000.00","DRVD_LMT_AMT":"0.00","UTLZ_LMT_AMT":"0.00","OTSND_BAL":"0.00","FRZ_LMT_AMT":"0.00","AVL_LMT_AMT":"0.00","LMT_TP_CD":"1","AR_LCS_TP_ID":"4","OPN_DT":"2017-05-03","CLS_DT":""},{"CA_LMT_AR_ID":"0000000007","DOMC_BR_NO":"0038","CRN_AMT_LMT":"300000.00","DRVD_LMT_AMT":"0.00","UTLZ_LMT_AMT":"0.00","OTSND_BAL":"0.00","FRZ_LMT_AMT":"0.00","AVL_LMT_AMT":"0.00","LMT_TP_CD":"1","AR_LCS_TP_ID":"4","OPN_DT":"2017-05-03","CLS_DT":""},{"CA_LMT_AR_ID":"0000000008","DOMC_BR_NO":"0038","CRN_AMT_LMT":"300000.00","DRVD_LMT_AMT":"0.00","UTLZ_LMT_AMT":"0.00","OTSND_BAL":"0.00","FRZ_LMT_AMT":"0.00","AVL_LMT_AMT":"0.00","LMT_TP_CD":"1","AR_LCS_TP_ID":"4","OPN_DT":"2017-05-03","CLS_DT":""},{"CA_LMT_AR_ID":"0000000006","DOMC_BR_NO":"0038","CRN_AMT_LMT":"null","DRVD_LMT_AMT":"0.00","UTLZ_LMT_AMT":"0.00","OTSND_BAL":"0.00","FRZ_LMT_AMT":"0.00","AVL_LMT_AMT":"0.00","LMT_TP_CD":"1","AR_LCS_TP_ID":"4","OPN_DT":"2017-05-03","CLS_DT":""},{"CA_LMT_AR_ID":"0000000005","DOMC_BR_NO":"0038","CRN_AMT_LMT":"300000.00","DRVD_LMT_AMT":"0.00","UTLZ_LMT_AMT":"0.00","OTSND_BAL":"0.00","FRZ_LMT_AMT":"0.00","AVL_LMT_AMT":"0.00","LMT_TP_CD":"1","AR_LCS_TP_ID":"4","OPN_DT":"2017-05-03","CLS_DT":""}]}}]}}}}';
        return response;
    }

    private static String odWithoutRecordNumberResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_OD_LMT_DTL","RQS_UNQ_ID":"2018-08-21T16:35:08+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180821_c8b4cf34faee4b9b8e801b91b8851fad","RSP_TMS":"2018-08-21T16:35:08.767","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":""},"Detail":{"IP_ID":"454059","POS_DT":"2018-08-20","OD_AR_LIST":{"OD_AR_INF":[{"AR_ID":"","AR_ID_ENCODED":"","EFF_INT_RATE_TP_CD":"","EFF_SPRD_RATE_PCT":"","INT_RATE_IND":"","COA_PD":"","CRN_BAL":"","TOT_LMT_AMT":"","OD_AR_IP_LIST":null,"OD_LMT_LIST":null}]}}}}';
        return response;
    }
}