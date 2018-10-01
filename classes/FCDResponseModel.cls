public class FCDResponseModel {
	public DataResponseModel dataResponse;

	public class DataResponseModel {
		public FCDHeader Header;
		public DetailModel Detail;
	}

	public class FCDHeader {
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
		public FCDDetail AR_DTL_LIST;
	}	

	public class FCDDetail {
		public List<FCDDetailInfo> FCD_AR_DTL_INF;
	}

	public class FCDDetailInfo {
		public String POS_DT;
		public String AR_ID;
		public String AR_ID_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingAccountNumber(AR_ID);
            }
		}
		public String AR_ID_ENCODED;
		public String SUB_AR;
		public String AR_NM;
		public String OPN_DT;
		public String CLS_DT;
		public String FCD_TP_CD;
		public String PD_TP_CD;
		public String PD_TP_CD_TXT{
            set;
            get{
                AR_TERM = GlobalUtility.toValue(AR_TERM);
                AR_TERM_UOM_TP_CD = GlobalUtility.toValue(AR_TERM_UOM_TP_CD);
                if(PD_TP_CD == '1101'){
                    PD_TP_CD_TXT = 'กระแสรายวัน';
                }else if(PD_TP_CD == '2101' || PD_TP_CD == '2102'){
                    PD_TP_CD_TXT = 'ออมทรัพย์';
                }else if(PD_TP_CD == '3101'){
                    PD_TP_CD_TXT = 'ฝากประจำ ' + AR_TERM + AR_TERM_UOM_TP_CD;
                }else{
                    PD_TP_CD_TXT = GlobalUtility.toValue(PD_TP_CD);
                }
                return PD_TP_CD_TXT;
            }
        } 
		public String AR_TERM;
		public String AR_TERM_UOM_TP_CD;
		public String CCY_CD;
		public String CCY_OTSND_BAL;
		public String MID_RATE;
		public String CNVR_OTSND_BAL;
		public String AR_LCS_TP_CD;
		public String AR_OWN_TP_CD;
		public String AR_OWN_TP_CD_TYPE {
            set;
            get {
                String accountTypeText = '';
                switch on AR_OWN_TP_CD {
                    when '0' {
                        accountTypeText = 'บัญชีร่วมรอง';
                    }
                    when '1' {
                        accountTypeText = 'บัญชีร่วมหลัก';
                    }
                    when '2' {
                        accountTypeText = 'บัญชีเดี่ยว';
                    }
                }
                return accountTypeText;
            }
        }
		public String CCY_HLD_AMT;
		public String EFF_INT_RATE;
		public String EFF_INT_RATE_TP_ID;
		public String EFF_SPRD_INT_RATE;
		public String EFF_INT_RATE_TP_ID_TXT {
			set;
            get {
                return EFF_INT_RATE_TP_ID + ProductUsageHelper.getSpreadInterestRate(EFF_SPRD_INT_RATE);
            }
		}
		public String EFF_DT;
		public String MAT_DT;
		public String DOMC_BR_NO;
		public String DOMC_BR_NM;
		public String SRC_STM_ID;
	}
}