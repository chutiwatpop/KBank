/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_MutualFundResultResponse {
    public getMutualFundResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getMutualFundResponse_model();
                return returnResponse;
        }
        set;    
    }

    public class getMutualFundResponse_model
    {
        public List<mutualfund_model> mutualfund
        {
            get
            {
                if(mutualfund==null)
                    mutualfund=new List<mutualfund_model>();
                    return mutualfund;
            }
            set;
        }
    }

    public class mutualfund_model {
        public String AR_ID {get;set;}
        public String SUB_AR {get;set;}
        public String AR_NM_TH {get;set;}
        public String CRN_BAL {get;set;}
        public String OPN_DT {get;set;}
        public String EFF_RATE_PCT {get;set;}
        public String AR_TERM {get;set;}
        public String HOLD_BAL_AMT {get;set;}

        public String FND_CD {get; set;}
        public String FND_DSC_EN {get; set;}
        public String FND_DSC_TH {get; set;}
        public String UNIT_BAL {get; set;}
        public String NAV_DT {get; set;}
        public String NAV {get; set;}
        public String FND_TP_CD {get; set;}
        public String AR_OWN_TP_CD {get ;set;}
    }

    public static SME_MutualFundResultResponse parse(String json) {
        return (SME_MutualFundResultResponse) System.JSON.deserialize(json, SME_MutualFundResultResponse.class);
    }

}