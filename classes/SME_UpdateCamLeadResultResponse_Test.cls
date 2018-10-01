/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_UpdateCamLeadResultResponse_Test
{

	static testMethod void testParse() {
        String json = '{'+
        '\"returnResponse\" : {\"STATUS\" : \"True\"}'+
        '}';
        SME_UpdateCampaignLeadResultResponse obj = new SME_UpdateCampaignLeadResultResponse();
        obj = SME_UpdateCampaignLeadResultResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testUpdateCampaignLeadResponse_model() {
        SME_UpdateCampaignLeadResultResponse obj = new SME_UpdateCampaignLeadResultResponse();
        SME_UpdateCampaignLeadResultResponse.getUpdateCampaignLeadResponse_model tempDataReturn = obj.returnResponse;
        tempDataReturn.STATUS = 'True';

        System.assert(tempDataReturn != null);
    }
}