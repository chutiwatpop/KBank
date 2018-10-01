public class ODLimitModel {
    public DataResponseModel dataResponse;

    public class DataResponseModel {
		public ODLimitHeader Header;
		public DetailModel Detail;
	}

    public class ODLimitHeader {
        public String FCN_NM;
		public String RQS_UNQ_ID;
		public String RSP_APL_ID;
		public String RSP_UNQ_ID;
		public String RSP_TMS;
		public String RSP_CD;
		public String RSP_ST;
		public String TOT_RCRD;
    }

    public class DetailModel {
        public String IP_ID;
        public String POS_DT;
        public ODLimitAccount OD_AR_LIST;
    }

    public class ODLimitAccount {
        public List<ODLimitAccountInfo> OD_AR_INF;
    }

    public class ODLimitAccountInfo {
        public String AR_ID;
        public String AR_ID_FORMATTED {
            set;
            get {
				return ProductUsageHelper.formattingAccountNumber(AR_ID);
            }
        }
        public String AR_ID_ENCODED;
        public String AR_NM_TH;
        public String EFF_INT_RATE_TP_CD;
        public String EFF_SPRD_RATE_PCT;
        public String INT_RATE_IND;
        public String COA_PD;
        public String CRN_BAL;
        public String HOLD_BAL_AMT;
        public String TOT_LMT_AMT;
        public String NBR_ON_OL;
        public ODLimitCustomer OD_AR_IP_LIST;
        public ODLimitDetail OD_LMT_LIST;
    }

    public class ODLimitCustomer {
        public List<ODLimitCustomerInfo> OD_AR_IP_INF;
    }

    public class ODLimitCustomerInfo {
        public String IP_ID;
        public String AR_OWN_TP_CD;
    }

    public class ODLimitDetail {
        public List<ODLimitDetailInfo> OD_LMT_INF;
    }

    public class ODLimitDetailInfo {
        public String CA_LMT_AR_ID;
        public String DOMC_BR_NO;
        public String DOMC_BR_NM;
        public String LMT_CTR_DT;
        public String LMT_END_DT;
        public String CRN_AMT_LMT;
        public String DRVD_LMT_AMT;
        public String UTLZ_LMT_AMT;
        public String OTSND_BAL;
        public String FRZ_LMT_AMT;
        public String AVL_LMT_AMT;
        public String LMT_TP_CD;
        public String AR_LCS_TP_ID;
        public String OPN_DT;
        public String CLS_DT;
        public String LMT_INT_RATE;
        public String LMT_INT_RATE_TP_ID;
        public String LMT_INT_RATE_TP_DSC;
        public String LMT_SPRD_INT_RATE;
        public String LMT_INT_RATE_TP_TEXT {
			set;
            get {
            	return String.isBlank(LMT_INT_RATE_TP_DSC) ? '' : LMT_INT_RATE_TP_DSC.substring(6) + ProductUsageHelper.getSpreadInterestRate(LMT_SPRD_INT_RATE);
            }
		}
        public String OD_TP;
        public String LMT_EFF_DT;
        public String LMT_INT_EFF_DT;
    }
}