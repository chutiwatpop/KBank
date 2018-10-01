public class CustomerWealthModel {
	public DataResponseModel dataResponse;

	public class DataResponseModel {
		public CustWealthHeader Header;
		public DetailModel Detail;
	}

	public class CustWealthHeader {
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
		public String CIS_SRC_STM_CD;
		public CustWealthDetail AR_DTL_LIST;
	}

	public class CustWealthDetail {
		public List<CustWealthDetailInfo> AR_DTL_INF;
	}

	public class CustWealthDetailInfo {
		public String POS_DT;
		public String AR_ID;
		public String AR_ID_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingAccountNumber(AR_ID);
            }
		}
		public String AR_ID_FUND_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingFundAccountNumber(AR_ID);
            }
		}
		public String AR_ID_ENCODED;
		public String AR_NM_EN;
		public String AR_NM_TH;
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
		public String PD_DSC_EN;
		public String SUM_CRN_BAL;
		public String SUM_HOLD_BAL_AMT;
		public String OD_LMT_AMT;
		public String DOMC_BR_NO;
		public String DOMC_BR_NM;
		public String AR_LCS_TP_CD;
		public String OPN_DT;
		public String CLS_DT;
		public String EFF_RATE_PCT;
		public String AR_TERM;
		public String AR_TERM_UOM_TP_CD;
		public String AR_TERM_TEXT {
			set;
            get {
            	return AR_TERM + AR_TERM_UOM_TP_CD;
            }
		}
		public String INT_EFF_DT;
		public String INT_END_DT;
		public String EFF_SPRD_RATE_PCT;
		public String EFF_INT_RATE_TP_CD;
		public String EFF_INT_RATE_TP_TEXT {
			set;
            get {
            	return String.isBlank(EFF_INT_RATE_TP_CD) ? '' : ProductUsageHelper.getInterestRateCode(EFF_INT_RATE_TP_CD) + 
				ProductUsageHelper.getSpreadInterestRate(EFF_SPRD_RATE_PCT);
            }
		}
		public CustWealthDetailSub SUB_AR_DTL_LIST;
		public CustWealthDetailSubOther AR_ST_LIST;
	}

	public class CustWealthDetailSub {
		public List<CustWealthDetailInfoSubAccount> SUB_AR_DTL_INF;
	}

	public class CustWealthDetailInfoSubAccount {
		public String SUB_AR;
		public String CRN_BAL;
		public String HOLD_BAL_AMT;
		public String SUB_AR_TERM;
		public String SUB_AR_TERM_UOM_TP_CD;
		public String SUB_AR_TERM_TEXT {
			set;
            get {
            	return SUB_AR_TERM + SUB_AR_TERM_UOM_TP_CD;
            }
		}
		public String SUB_EFF_RATE_PCT;
		public String SUB_AR_OPN_DT;
		public String SUB_AR_CLS_DT;
		public String UNIT_BAL;
		public String FND_CD;
		public String FND_DSC_EN;
		public String FND_DSC_TH;
		public String NAV;
		public String NAV_DT;
		public String SUB_INT_EFF_DT;
		public String SUB_INT_END_DT;
		public String SUB_EFF_SPRD_RATE_PCT;
		public String SUB_EFF_INT_RATE_TP_CD;
		public String SUB_EFF_INT_RATE_TP_TEXT {
			set;
            get {
            	return String.isBlank(SUB_EFF_INT_RATE_TP_CD) ? '' : ProductUsageHelper.getInterestRateCode(SUB_EFF_INT_RATE_TP_CD) + 
				ProductUsageHelper.getSpreadInterestRate(SUB_EFF_SPRD_RATE_PCT);
            }
		}
	}

	public class CustWealthDetailSubOther {
		public List<CustWealthDetailInfoSubOther> AR_ST_INF;
	}

	public class CustWealthDetailInfoSubOther {
		public String STRT_DT;
		public String MISC_CD;
	}


}