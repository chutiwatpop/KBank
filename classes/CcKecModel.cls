public class CcKecModel {
	public DataResponseModel dataResponse;

	public class DataResponseModel {
		public CcHeader Header;
		public DetailModel Detail;
	}

	public class CcHeader {
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
		public CcDetail CC_DTL_LIST;
	}	

	public class CcDetail {
		public List<CcDetailInfo> CC_DTL_LIST_INF;
	}

	public class CcDetailInfo {
		public String CARD_ORG_NO;
		public String CARD_TP;
		public String CARD_NM;
		public String CARD_NO_MASK;
		public String CARD_NO_MASK_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingCardNumber(CARD_NO_MASK);
            }
		}
		public String PRIM_CARD_F;
		public String PRIM_CARD_DESC {
			set;
            get {
				String primaryCardText = '';
				if (PRIM_CARD_F.toUpperCase() == 'Y') primaryCardText = 'บัตรหลัก';
				else if (PRIM_CARD_F.toUpperCase() == 'N') primaryCardText = 'บัตรเสริม';
                return primaryCardText;
            }
		}
		public String CC_CST_ORG_NO;
		public String CC_CST_NO;
		public String MAIN_CC_CST_ORG_NO;
		public String MAIN_CC_CST_NO;
		public String ALT_CC_CST_ORG_NO;
		public String ALT_CC_CST_NO;
		public String MAIN_NM_TH;
		public String NM_TH;
		public String CARD_TP1;
		public String ST_CD;
		public String ST_CD_DESC {
			set;
			get {
				Map<String, String> statusCode = new Map<String, String>{'0' => 'NEW-ACCOUNT', '1' => 'ACTIVE-ACCOUNT', '2' => 'INACTIVE-ACCOUNT', '3' => 'CONVERSION-ACCOUNT',
				'4' => 'TRANSFERED', '5' => 'CHARGED-OFF-ACCOUNT', '6' => 'TRANSFER-OUT-TODAY', '7' => 'TRANSFER-IN-TODAY', '8' => 'CLOSED-ACCOUNT', '9' => 'ACCOUNT-TO-BE-PURGED'};

				return statusCode.get(ST_CD);
			}
		}
		public String OPN_DT;
		public String EXP_DT;
		public String EXP_DT_FORMATTED {
			set;
			get {
				return '20' + EXP_DT.subString(2,4) + '-' + EXP_DT.subString(0,2) + '-01';
			}
		}
		public String BLC_CD;
		public String BLC_DT;
		public String EMB_NM1;
		public String CR_LMT_AMT;
		public String CR_LMT_DT;
		public String CRN_BAL;
		public String BILL_CYC;
		public String LAST_PYMT_DT;
		public String CARD_TP4;
		public String MN_PYMT_AMT {
			get {
				return GlobalUtility.toValue(MN_PYMT_AMT);
			}
			set;
		}
		public String BAL;
		public String DUE_DT;
	}
}