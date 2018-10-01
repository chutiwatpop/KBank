@isTest
private class TransformationCcKec_Test
{
	@isTest
	static void itShouldReturnOnlyCreditCardWhenWebServiceReturnBothCCAndKEC()
	{
		// Given
		HttpCalloutMock ccKecResponse = new SingleRequestMock(200, 'Complete', creditCardResponse(), null);
		Test.setMock(HttpCalloutMock.class, ccKecResponse);
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation ccKecTransformer = new TransformationCcKec('11', 'CRCARD', productUsageConfig);

		// When
		Test.startTest();
		ProductUsageController.ProductUsageModel productUsageInfo = ccKecTransformer.transform();
		Test.stopTest();

		// Then
		system.assertEquals(2, productUsageInfo.productUsageTables.get('CRCARD_0').body.size());
		system.assertEquals('บัตรหลัก', productUsageInfo.productUsageTables.get('CRCARD_0').body.get(0).get(8));
		system.assertEquals('บัตรเสริม', productUsageInfo.productUsageTables.get('CRCARD_0').body.get(1).get(8));
	}

	@isTest
	static void itShouldReturnOnlyKECWhenWebServiceReturnBothCCAndKEC()
	{
		// Given
		HttpCalloutMock ccKecResponse = new SingleRequestMock(200, 'Complete', creditCardResponse(), null);
		Test.setMock(HttpCalloutMock.class, ccKecResponse);
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation ccKecTransformer = new TransformationCcKec('11', 'KXCARD', productUsageConfig);

		// When
		ProductUsageController.ProductUsageModel productUsageInfo = ccKecTransformer.transform();

		// Then
		system.assertEquals(1, productUsageInfo.productUsageTables.get('KXCARD_0').body.size());
		system.assertEquals('บัตรหลัก', productUsageInfo.productUsageTables.get('KXCARD_0').body.get(0).get(8));
	}

	private static String creditCardResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CC_CARD","RQS_UNQ_ID":"2018-08-02T16:21:33+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180802_5841434a4cb644939afcbc96ea466d2f","RSP_TMS":"2018-08-02T16:21:34.986","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"CC_DTL_LIST":{"CC_DTL_LIST_INF":[{"CARD_ORG_NO":"001","CARD_TP":"992","CARD_NM":"","CARD_NO_MASK":"406230*****0000","PRIM_CARD_F":"Y","CC_CST_ORG_NO":"001","CC_CST_NO":"1000000014905317","MAIN_CC_CST_ORG_NO":"001","MAIN_CC_CST_NO":"1000000014905317","ALT_CC_CST_ORG_NO":"000","ALT_CC_CST_NO":"0000000000000000","MAIN_NM_TH":"Mrs.maincard creditcard","NM_TH":"นาย อาชวิณ หมื่นอาจ","CARD_TP1":"90","ST_CD":"2","OPN_DT":"2009-11-17","EXP_DT":"1118","BLC_CD":"C","BLC_DT":"2018-03-20","EMB_NM1":"ARCHAWIN MUEN-ART","CR_LMT_AMT":"100000.00","CR_LMT_DT":"2013-12-21","CRN_BAL":"2250.50","BILL_CYC":"5","LAST_PYMT_DT":"2017-09-22","CARD_TP4":"85","MN_PYMT_AMT":"1000.00","BAL":"2000.00","DUE_DT":"2017-10-20"},{"CARD_ORG_NO":"001","CARD_TP":"992","CARD_NM":"","CARD_NO_MASK":"406230*****0000","PRIM_CARD_F":"N","CC_CST_ORG_NO":"001","CC_CST_NO":"1000000014905317","MAIN_CC_CST_ORG_NO":"001","MAIN_CC_CST_NO":"1000000014905317","ALT_CC_CST_ORG_NO":"000","ALT_CC_CST_NO":"0000000000000000","MAIN_NM_TH":"Mrs.subcard creditcard","NM_TH":"นาย อาชวิณ หมื่นอาจ","CARD_TP1":"90","ST_CD":"2","OPN_DT":"2009-11-17","EXP_DT":"1118","BLC_CD":"C","BLC_DT":"2018-03-20","EMB_NM1":"ARCHAWIN MUEN-ART","CR_LMT_AMT":"100000.00","CR_LMT_DT":"2013-12-21","CRN_BAL":"2250.50","BILL_CYC":"5","LAST_PYMT_DT":"2017-09-22","CARD_TP4":"85","MN_PYMT_AMT":"1000.00","BAL":"2000.00","DUE_DT":"2017-10-20"},{"CARD_ORG_NO":"200","CARD_TP":"992","CARD_NM":"","CARD_NO_MASK":"Mrs.subcard creditcard","PRIM_CARD_F":"Y","CC_CST_ORG_NO":"001","CC_CST_NO":"1000000014905317","MAIN_CC_CST_ORG_NO":"001","MAIN_CC_CST_NO":"1000000014905317","ALT_CC_CST_ORG_NO":"000","ALT_CC_CST_NO":"0000000000000000","MAIN_NM_TH":"Mrs.Card K-Expresscashcard","NM_TH":"นาย อาชวิณ หมื่นอาจ","CARD_TP1":"90","ST_CD":"2","OPN_DT":"2009-11-17","EXP_DT":"1118","BLC_CD":"C","BLC_DT":"2018-03-20","EMB_NM1":"ARCHAWIN MUEN-ART","CR_LMT_AMT":"100000.00","CR_LMT_DT":"2013-12-21","CRN_BAL":"2250.50","BILL_CYC":"5","LAST_PYMT_DT":"2017-09-22","CARD_TP4":"85","MN_PYMT_AMT":"1000.00","BAL":"2000.00","DUE_DT":"2017-10-20"}]}}}}';
		return response;
	}
}