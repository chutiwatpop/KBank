/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_TaweesupResultResponse {
    public getTaweesupResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getTaweesupResponse_model();
                return returnResponse;
        }
        set;    
    }

    public class getTaweesupResponse_model
    {
        public List<taweesup_model> taweesup
        {
            get
            {
                if(taweesup==null)
                    taweesup=new List<taweesup_model>();
                    return taweesup;
            }
            set;
        }
    }

    public class taweesup_model {
        public String AR_ID {get;set;}
        public String CRN_BAL {get;set;}
        public String HLD_BAL_AMT {get;set;}
        public String OPN_DT {get;set;}
        public String EFF_RATE_PCT {get;set;}
        public String OWN_TP_CD {get;set;}
    }

    public static SME_TaweesupResultResponse parse(String json) {
        return (SME_TaweesupResultResponse) System.JSON.deserialize(json, SME_TaweesupResultResponse.class);
    }

}