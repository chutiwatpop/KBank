/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_TaweesupResultResponse_Test
{
	/*
	{
        "returnResponse" : {
			"taweesup" : [{
				"AR_ID" : "001",
				"CRN_BAL" : "",
				"HLD_BAL_AMT" : "",
				"OPN_DT" : "",
				"EFF_RATE_PCT" : ""
			}]
		}
	}
	 */

	static testMethod void testParse() {
        String json = '{'+
        '\"returnResponse\" : {\"taweesup\" : [{'+
        '\"AR_ID\" : \"001\",'+
        '\"CRN_BAL\" : \"002\",'+
        '\"HLD_BAL_AMT\" : \"003\",'+
        '\"OPN_DT\" : \"004\",'+
        '\"EFF_RATE_PCT\" : \"005\"'+
        '}]}'+
        '}';
        SME_TaweesupResultResponse obj = new SME_TaweesupResultResponse();
        obj = SME_TaweesupResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testSetgetTaweesupResponse_model() {
        SME_TaweesupResultResponse obj = new SME_TaweesupResultResponse();
        SME_TaweesupResultResponse.getTaweesupResponse_model tempDataReturn = obj.returnResponse;
        List<SME_TaweesupResultResponse.taweesup_model> taweesupList = new List<SME_TaweesupResultResponse.taweesup_model>();
        SME_TaweesupResultResponse.taweesup_model TempTaweesup = new SME_TaweesupResultResponse.taweesup_model();
        TempTaweesup.AR_ID = '';
        TempTaweesup.CRN_BAL = '';
        TempTaweesup.HLD_BAL_AMT = '';
        TempTaweesup.OPN_DT = '';
        TempTaweesup.EFF_RATE_PCT = '';

        tempDataReturn.taweesup = null;
        taweesupList = tempDataReturn.taweesup;

        System.assert(tempDataReturn != null);
    }
}