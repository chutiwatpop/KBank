public class LPMModel {
    public DataResponseModel dataResponse;
    
    public class DataResponseModel {
		public LPMHeader Header;
		public DetailModel Detail;
	}
    
    public class LPMHeader {
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
        public LPMDetail LPM_DTL_LIST;
    }
    
    public class LPMDetail {
        public List<LPMDetailInfo> LPM_DTL_INF;
    }
    
    public class LPMDetailInfo {
        public String POS_DT;
        public String LPM_CST_ID;
        public String AR_ID_ENCODED;
        public String DLQ_DYS;
        public String TDR_F;
        public String TDR_F_TEXT {
			set;
            get {
            	return TDR_F.equalsIgnoreCase('Y') ? 'Yes' : (TDR_F.equalsIgnoreCase('N') ? 'No' : '');
            }
		}

        public LPMDetailInfo() {
            POS_DT = '';
            LPM_CST_ID = '';
            AR_ID_ENCODED = '';
            DLQ_DYS = '';
            TDR_F = '';
        }
    }
}