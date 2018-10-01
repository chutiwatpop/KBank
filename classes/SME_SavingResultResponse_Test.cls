/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_SavingResultResponse_Test
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
        '\"returnResponse\" : {\"saving\" : [{'+
        '\"AR_ID\" : \"001\",'+
        '\"SUB_AR\" : \"002\",'+
        '\"AR_NM_TH\" : \"003\",'+
        '\"CRN_BAL\" : \"004\",'+
        '\"OPN_DT\" : \"005\",'+
        '\"EFF_RATE_PCT\" : \"006\",'+
        '\"AR_TERM\" : \"007\",'+
        '\"HOLD_BAL_AMT\" : \"008\"'+
        '}]}'+
        '}';
        SME_SavingResultResponse obj = new SME_SavingResultResponse();
        obj = SME_SavingResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testSetgetSavingResponse_model() {
        SME_SavingResultResponse obj = new SME_SavingResultResponse();
        SME_SavingResultResponse.getSavingResponse_model tempDataReturn = obj.returnResponse;
        List<SME_SavingResultResponse.saving_model> savingList = new List<SME_SavingResultResponse.saving_model>();
        SME_SavingResultResponse.saving_model TempSaving = new SME_SavingResultResponse.saving_model();
        TempSaving.AR_ID = '';
        TempSaving.SUB_AR = '';
        TempSaving.AR_NM_TH = '';
        TempSaving.CRN_BAL = '';
        TempSaving.OPN_DT = '';
        TempSaving.EFF_RATE_PCT = '';
        TempSaving.AR_TERM = '';
        TempSaving.HOLD_BAL_AMT = '';

        tempDataReturn.saving = null;
        savingList = tempDataReturn.saving;

        System.assert(tempDataReturn != null);
    }
}