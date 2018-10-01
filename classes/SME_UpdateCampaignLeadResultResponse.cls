/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_UpdateCampaignLeadResultResponse {

    public getUpdateCampaignLeadResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getUpdateCampaignLeadResponse_model();
                return returnResponse;
        }
        set; 
    }

    public class getUpdateCampaignLeadResponse_model
    {
        public String STATUS {get;set;}
    }

    public static SME_UpdateCampaignLeadResultResponse parse(String json) {
        return (SME_UpdateCampaignLeadResultResponse) System.JSON.deserialize(json, SME_UpdateCampaignLeadResultResponse.class);
    }
}