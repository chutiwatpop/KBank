/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_CreditOutStandingResultResponse {
    

    public getCreditOutStandingResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getCreditOutStandingResponse_model();
                return returnResponse;
        }
        set; 
    }

    public class getCreditOutStandingResponse_model
    {
        public List<creditOutStandingResponse_model> outstanding
        {
            get
            {
                if(outstanding==null)
                    outstanding=new List<creditOutStandingResponse_model>();
                    return outstanding;
            }
            set;
        }
    }

    public class creditOutStandingResponse_model{
        public String OST {get;set;}
        public String AR_TYPE {get;set;}
    }

    public static SME_CreditOutStandingResultResponse parse(String json) {
        return (SME_CreditOutStandingResultResponse) System.JSON.deserialize(json, SME_CreditOutStandingResultResponse.class);
    }

}