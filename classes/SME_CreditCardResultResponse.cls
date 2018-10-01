global class SME_CreditCardResultResponse {
	public getCreditCardResponse_model returnResponse
    {
        get
        {
            if(returnResponse==null)
                returnResponse=new getCreditCardResponse_model();
                return returnResponse;
        }
        set;    
    }
	public class getCreditCardResponse_model
    {
        public List<creditcard_model> creditcard
        {
            get
            {
                if(creditcard==null)
                    creditcard=new List<creditcard_model>();
                    return creditcard;
            }
            set;
        }
        public List<creditcard_model> kec
        {
            get
            {
                if(kec==null)
                    kec=new List<creditcard_model>();
                    return kec;
            }
            set;
        }
    }
    public class creditcard_model {
        public String CARD_NO_MASK {get;set;}
        public String CARD_TP1 {get;set;}
        public String OPN_DT {get;set;}
        public String CR_LMT_AMT {get;set;}
        public String CRN_BAL {get;set;}
        public String MN_PYMT_AMT {get;set;}
        public String DUE_DT {get;set;}
        public String EXP_DT {get;set;}
        public String ST_CD {get;set;}
        public String ISMAIN {get;set;}
        public String IP_ID_MAINCARD {get;set;}
        public String IP_ID_ALTCARD {get;set;}
    }

    public static SME_CreditCardResultResponse parse(String json) {
        return (SME_CreditCardResultResponse) System.JSON.deserialize(json, SME_CreditCardResultResponse.class);
    }
    
}