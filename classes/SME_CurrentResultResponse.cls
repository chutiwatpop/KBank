/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_CurrentResultResponse {
    public getCurrentResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getCurrentResponse_model();
                return returnResponse;
        }
        set;    
    }

    public class getCurrentResponse_model
    {
        public List<current_model> current
        {
            get
            {
                if(current==null)
                    current=new List<current_model>();
                    return current;
            }
            set;
        }
    }

    public class current_model {
        public String AR_ID {get;set;}
        public String SUB_AR {get;set;}
        public String AR_NM_TH {get;set;}
        public String CRN_BAL {get;set;}
        public String OPN_DT {get;set;}
        public String EFF_RATE_PCT {get;set;}
        public String AR_TERM {get;set;}
        public String HOLD_BAL_AMT {get;set;}
        public String OWN_TP_CD {get;set;}
    }

    public static SME_CurrentResultResponse parse(String json) {
        return (SME_CurrentResultResponse) System.JSON.deserialize(json, SME_CurrentResultResponse.class);
    }

}