/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_UpdateContactPrefResultResponse {

    public getUpdateContactPrefResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getUpdateContactPrefResponse_model();
                return returnResponse;
        }
        set; 
    }

    public class getUpdateContactPrefResponse_model
    {
        public String STATUS {get;set;}
    }

    public static SME_UpdateContactPrefResultResponse parse(String json) {
        return (SME_UpdateContactPrefResultResponse) System.JSON.deserialize(json, SME_UpdateContactPrefResultResponse.class);
    }
}