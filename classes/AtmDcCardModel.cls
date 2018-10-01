public class AtmDcCardModel {
	public DataResponseModel dataResponse;

	public class DataResponseModel {
		public AtmDcHeader Header;
		public DetailModel Detail;
	}

	public class AtmDcHeader {
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
		public AtmDcDetail DC_DTL_LIST;
	}	

	public class AtmDcDetail {
		public List<AtmDcDetailInfo> DC_DTL_INF;
	}

	public class AtmDcDetailInfo {
		public String CARD_NO;
		public String CARD_NO_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingCardNumber(CARD_NO);
            }
		}
		public String ST_CD;
		public String ST_CD_DESC {
			set;
            get {
				String cardStatusDescription = '';
				if (ST_CD.equalsIgnoreCase('00')) cardStatusDescription = 'Active';
				else if (ST_CD.equalsIgnoreCase('02')) cardStatusDescription = 'Inactive';
				else if (ST_CD.equalsIgnoreCase('04')) cardStatusDescription = 'Need PIN change';
				else if (ST_CD.equalsIgnoreCase('20')) cardStatusDescription = 'Hot card';
				else if (ST_CD.equalsIgnoreCase('40')) cardStatusDescription = 'Lost card';
				else if (ST_CD.equalsIgnoreCase('80')) cardStatusDescription = 'Delete card';
				else cardStatusDescription = 'Other Status';
                return cardStatusDescription;
            }
		}
		public String TOT_USED_CNT;
		public String CA_AR_ID;
		public String CA_AR_ID_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingAccountNumber(CA_AR_ID);
            }
		}
		public String CA_DOMC_BR_NO;
		public String CA_DOMC_BR_NO_FILTERED {
			set;
            get {
				String branchNo = '';
				if (!String.isEmpty(CA_DOMC_BR_NO) && Integer.valueof(CA_DOMC_BR_NO) != 0) {
					branchNo = CA_DOMC_BR_NO;
				}
				return branchNo;
            }
		}
		public String CA_DOMC_BR_NM;
		public String SA_AR_ID;
		public String SA_AR_ID_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingAccountNumber(SA_AR_ID);
            }
		}
		public String SA_DOMC_BR_NO;
		public String SA_DOMC_BR_NO_FILTERED {
			set;
            get {
				String branchNo = '';
				if (!String.isEmpty(SA_DOMC_BR_NO) && Integer.valueof(SA_DOMC_BR_NO) != 0) {
					branchNo = SA_DOMC_BR_NO;
				}
				return branchNo;
            }
		}
		public String SA_DOMC_BR_NM;
		public String EXP_YR_MO;
		public String EXP_YR_MO_FORMATTED {
			set;
			get {
				return '20' + EXP_YR_MO.subString(0,2) + '-' + EXP_YR_MO.subString(2,4) + '-01';
			}
		}
		public String CARD_HLDR_NM;
		public String IVR_BAD_PIN_CNT;
		public String ISSU_DT;
		public String RSET_PIN_CNT;
		public String CARD_BR_NO;
		public String CRT_DT;
		public String LAST_MNT_DT;
		public String EDC_LAST_USED_DT;
		public String EDC_TOT_AMT;
		public String TO_BR_NO;
		public String CNCL_DT;
		public String CNCL_TM;
		public String ST_UDT_TM;
		public String INTR_BNK_CNT;
		public String INTR_BNK_LAST_USED_DT;
		public String UDT_F_DT;
		public String ANUL_FEE_F;
		public String ANUL_FEE_DESC {
			set;
            get {
				String annaulFeeDescription = '';
				if (ANUL_FEE_F.toUpperCase() == '0') annaulFeeDescription = 'ไม่ค้าง';
				else if (ANUL_FEE_F.toUpperCase() == '1') annaulFeeDescription = 'ค้าง';
                return annaulFeeDescription;
            }
		}
		public String ANUL_FEE_CNT;
		public String ANUL_FEE_AMT;
		public String ANUL_FEE_PAID_DT;
		public String INN_PRCH_RGST_F;
		public String EDC_BAD_PIN_CNT;
		public String INN_PRCH_AMT;
		public String INN_PRCH_LMT_AMT;
		public String WD_LMT_AMT;
		public String WD_LMT_UDT_DT;
		public String WD_LMT_UDT_TM;
		public String TFR_LMT_AMT;
		public String TFR_LMT_UDT_DT;
		public String TFR_LMT_UDT_TM;
		public String CARD_TP_CD;
		public String CARD_TP_DSC;
		public String DUE_YR_MO;
		public String OLD_CARD_NO;
		public String INTR_BNK_CALC_FEE_DT;
		public String INTR_BNK_CALC_FEE_CNT;
		public String CHIP_CARD_F;
		public String CHIP_CARD_CNT;

	}
}