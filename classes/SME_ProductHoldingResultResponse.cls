/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_ProductHoldingResultResponse {
    public getDepositResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getDepositResponse_model();
                return returnResponse;
        }
        set;    
    }

    public class getDepositResponse_model
    {
        public List<deposit_model> deposit
        {
            get
            {
                if(deposit==null)
                    deposit=new List<deposit_model>();
                    return deposit;
            }
            set;
        }
    }

    public class deposit_model {
        public String AR_ID {get;set;}
        public String SUB_AR {get;set;}
        public String AR_NM_TH {get;set;}
        public String CRN_BAL {get;set;}
        public String OPN_DT {get;set;}
        public String EFF_RATE_PCT {get;set;}
        public String AR_TERM {get;set;}
        public String HOLD_BAL_AMT {get;set;}
        public String AR_TYPE {get;set;}
    }

    public static SME_ProductHoldingResultResponse parse(String json) {
        return (SME_ProductHoldingResultResponse) System.JSON.deserialize(json, SME_ProductHoldingResultResponse.class);
    }

}