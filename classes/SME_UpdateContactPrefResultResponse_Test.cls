/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_UpdateContactPrefResultResponse_Test
{
	static testMethod void testParse() {
        String json = '{'+
        '\"returnResponse\" : {\"STATUS\" : \"True\"}'+
        '}';
        SME_UpdateContactPrefResultResponse obj = new SME_UpdateContactPrefResultResponse();
        obj = SME_UpdateContactPrefResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testUpdateContactPrefResponse_model() {
        SME_UpdateContactPrefResultResponse obj = new SME_UpdateContactPrefResultResponse();
        SME_UpdateContactPrefResultResponse.getUpdateContactPrefResponse_model tempDataReturn = obj.returnResponse;
        tempDataReturn.STATUS = 'True';

        System.assert(tempDataReturn != null);
    }
}