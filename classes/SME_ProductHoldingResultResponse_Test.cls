/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_ProductHoldingResultResponse_Test
{
	/*
	{
        "returnResponse" : {
			"saving" : [{
				"AR_ID" : "001",
				"SUB_AR" : "",
				"AR_NM_TH" : "",
				"CRN_BAL" : "",
				"OPN_DT" : "",
				"EFF_RATE_PCT" : "",
				"AR_TERM" : "",
				"HOLD_BAL_AMT" : ""
			}]
		}
	}
	 */

	static testMethod void testParse() {
        String json = '{'+
        '\"returnResponse\" : {\"deposit\" : [{'+
        '\"AR_ID\" : \"001\",'+
        '\"SUB_AR\" : \"002\",'+
        '\"AR_NM_TH\" : \"003\",'+
        '\"CRN_BAL\" : \"004\",'+
        '\"OPN_DT\" : \"005\",'+
        '\"EFF_RATE_PCT\" : \"006\",'+
        '\"AR_TERM\" : \"007\",'+
        '\"HOLD_BAL_AMT\" : \"008\",'+
        '\"AR_TYPE\" : \"009\"'+
        '}]}'+
        '}';
        SME_ProductHoldingResultResponse obj = new SME_ProductHoldingResultResponse();
        obj = SME_ProductHoldingResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testSetgetSavingResponse_model() {
        SME_ProductHoldingResultResponse obj = new SME_ProductHoldingResultResponse();
        SME_ProductHoldingResultResponse.getDepositResponse_model tempDataReturn = obj.returnResponse;
        List<SME_ProductHoldingResultResponse.deposit_model> depositList = new List<SME_ProductHoldingResultResponse.deposit_model>();
        SME_ProductHoldingResultResponse.deposit_model TempDeposit = new SME_ProductHoldingResultResponse.deposit_model();
        TempDeposit.AR_ID = '';
        TempDeposit.SUB_AR = '';
        TempDeposit.AR_NM_TH = '';
        TempDeposit.CRN_BAL = '';
        TempDeposit.OPN_DT = '';
        TempDeposit.EFF_RATE_PCT = '';
        TempDeposit.AR_TERM = '';
        TempDeposit.HOLD_BAL_AMT = '';
        TempDeposit.AR_TYPE = '';

        tempDataReturn.deposit = null;
        depositList = tempDataReturn.deposit;

        System.assert(tempDataReturn != null);
    }
}