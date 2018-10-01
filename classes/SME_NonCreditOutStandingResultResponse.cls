/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_NonCreditOutStandingResultResponse {
    

    public getNonCreditOutStandingResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getnonCreditOutStandingResponse_model();
                return returnResponse;
        }
        set; 
    }

    public class getnonCreditOutStandingResponse_model
    {
        public List<nonCreditOutStandingResponse_model> outstanding
        {
            get
            {
                if(outstanding==null)
                    outstanding=new List<nonCreditOutStandingResponse_model>();
                    return outstanding;
            }
            set;
        }
    }

    public class nonCreditOutStandingResponse_model{
        public String OST {get;set;}
        public String AR_TYPE {get;set;}
    }

    public static SME_NonCreditOutStandingResultResponse parse(String json) {
        return (SME_NonCreditOutStandingResultResponse) System.JSON.deserialize(json, SME_NonCreditOutStandingResultResponse.class);
    }

}