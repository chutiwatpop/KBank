/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_FixedResultResponse {
    public getFixedResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getFixedResponse_model();
                return returnResponse;
        }
        set;    
    }

    public class getFixedResponse_model
    {
        public List<fixed_model> fixed
        {
            get
            {
                if(fixed==null)
                    fixed=new List<fixed_model>();
                    return fixed;
            }
            set;
        }
    }

    public class fixed_model {
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

    public static SME_FixedResultResponse parse(String json) {
        return (SME_FixedResultResponse) System.JSON.deserialize(json, SME_FixedResultResponse.class);
    }

}