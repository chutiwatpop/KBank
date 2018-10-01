/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_TransactBPResultResponse_Test
{
	/*
	{
        "returnResponse" : {
			"transactBP" : [{
				"IP_ID" : "001",
				"BSN_CD" : "",
				"BSN_NM" : "",
				"BSN_TP_CD" : "",
				"APL_CRT_DT" : "",
				"VLD_FM_DT" : "",
				"BS_SALE_APL" : "",
				"BS_SALE_VERF" : "",
				"PCT_BS_SALE_CR" : "",
				"PCT_BS_SALE_CASH" : "",
				"BS_SALE_TERM_DAY" : "",
				"PCT_BS_PRCH_CR" : "",
				"PCT_BS_PRCH_CASH" : "",
				"BS_PRCH_TERM_DAY" : "",
				"BS_PRCH_APL" : "",
				"BS_PRCH_VERF" : ""
			}]
		}
	}
	 */
	
	static testMethod void testParse() {
        String json = '{'+
        '\"returnResponse\" : {\"transactBP\" : [{'+
        '\"IP_ID\" : \"001\",'+
        '\"BSN_CD\" : \"002\",'+
        '\"BSN_NM\" : \"003\",'+
        '\"BSN_TP_CD\" : \"004\",'+
        '\"APL_CRT_DT\" : \"005\",'+
        '\"VLD_FM_DT\" : \"006\",'+
        '\"BS_SALE_APL\" : \"007\",'+
        '\"BS_SALE_VERF\" : \"008\",'+
        '\"PCT_BS_SALE_CR\" : \"009\",'+
        '\"PCT_BS_SALE_CASH\" : \"010\",'+
        '\"BS_SALE_TERM_DAY\" : \"011\",'+
        '\"PCT_BS_PRCH_CR\" : \"012\",'+
        '\"PCT_BS_PRCH_CASH\" : \"013\",'+
        '\"BS_PRCH_TERM_DAY\" : \"014\",'+
        '\"BS_PRCH_APL\" : \"015\",'+
        '\"BS_PRCH_VERF\" : \"016\"'+
        '}]}'+
        '}';
        SME_TransactBPResultResponse obj = new SME_TransactBPResultResponse();
        obj = SME_TransactBPResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testSetgetTransactBPResponse_model() {
        SME_TransactBPResultResponse obj = new SME_TransactBPResultResponse();
        SME_TransactBPResultResponse.getTransactBPResponse_model tempDataReturn = obj.returnResponse;
        List<SME_TransactBPResultResponse.transactBP_model> transactBPList = new List<SME_TransactBPResultResponse.transactBP_model>();
        SME_TransactBPResultResponse.transactBP_model TempTransactBP = new SME_TransactBPResultResponse.transactBP_model();
        TempTransactBP.LPM_ID = '';
        TempTransactBP.BSN_CD = '';
        TempTransactBP.BSN_NM = '';
        TempTransactBP.BSN_TP_CD = '';
        TempTransactBP.APL_CRT_DT = '';
        TempTransactBP.APL_NO = '';
        TempTransactBP.VLD_FM_DT = '';
        TempTransactBP.BS_SALE_APL = '';
        TempTransactBP.BS_SALE_VERF = '';
        TempTransactBP.PCT_BS_SALE_CR = '';
        TempTransactBP.PCT_BS_SALE_CASH = '';
        TempTransactBP.BS_SALE_TERM_DAY = '';
        TempTransactBP.PCT_BS_PRCH_CR = '';
        TempTransactBP.PCT_BS_PRCH_CASH = '';
        TempTransactBP.BS_PRCH_TERM_DAY = '';
        TempTransactBP.BS_PRCH_APL = '';
        TempTransactBP.BS_PRCH_VERF = '';
        TempTransactBP.TOT_NO_CHK_TXN = '';
        TempTransactBP.TOT_NO_RET_CHK = '';
        TempTransactBP.TOT_AMT_CHK_TXN = '';
        TempTransactBP.TOT_AMT_RET_CHK = '';
        TempTransactBP.BSN_CODE = '';

        tempDataReturn.transactBP = null;
        transactBPList = tempDataReturn.transactBP;

        System.assert(tempDataReturn != null);
    }
}