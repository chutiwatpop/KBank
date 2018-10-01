public class FNCModel {
	public DataResponseModel dataResponse;

	public class DataResponseModel {
		public FNCHeader Header;
		public DetailModel Detail;
	}

	public class FNCHeader {
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
		public FNCDetail PCB_LMT_AR_LIST;
	}

	public class FNCDetail {
		public List<FNCDetailInfo> PCB_LMT_AR_INF;
	}

	public class FNCDetailInfo {
		public String LMT_AR_ID = '';
		public String LMT_AR_ID_ENCODED = '';
		public String ORIG_AR_ID = '';
		public String UPR_LMT_AR_ID = '';
		public String ROOT_LMT_AR_ID = '';
		public String LMT_LVL_IND = '';
		public String LMT_AR_PPS_TP_CD = '';
		public String LMT_KBNK_IDY_CL_CD = '';
		public String CTR_DT = '';
		public String EFF_DT = '';
		public String MAT_DT = '';
		//public String CLS_DT = '';
		public String DCN_TP_CD = '';
		public String LMT_TP_CD = '';
		public String LMT_TP_CD_TYPE {
			set;
			get {
				String resultText = '';
				switch on LMT_TP_CD {
					when '1' {
						resultText = 'ทบทวนปีต่อปี';
					}
					when '2' {
						resultText = 'ชั่วคราว';
					}
					when '3' {
						resultText = 'เฉพาะราย';
					}
				}
				return resultText;
			}
		}
		public String LMT_AR_NM_TH = '';
		public String LMT_AR_NM_EN = '';
		public String PD_GRP = '';
		public String PD_TP_CD = '';
		public String PD_SUB_TP_CD = '';
		public String MKT_CD = '';
		public String PD_DSC {
			set;
            get {
            	return ProductUsageHelper.getMarketDescription(PD_TP_CD,PD_SUB_TP_CD,MKT_CD);
            }
		}
		public String COA_PD_FTR_CD = '';
		public String SETUP_LMT_AMT = '';
		public String CTR_LMT_AMT = '';
		public String UNUSED_LMT_AMT = '';
		public String HOLD_AMT = '';
		public String AVL_LMT_AMT = '';
		public String TOT_LI_AMT = '';

		public FNCDetailIPList PCB_LMT_IP_LIST;
		public FNCDetailSub PCB_AR_LIST;
	}

	public class FNCDetailIPList {
		public List<FNCDetailIP> PCB_LMT_IP_INF;
	}

	public class FNCDetailIP {
		public String IP_ID = '';
		public String AR_OWN_TP_CD = '';
		public String AR_OWN_TP_CD_TYPE {
			set;
            get {
            	String accountTypeText = '';
				switch on AR_OWN_TP_CD {
		            when '0' {
		                accountTypeText = 'กู้ร่วม(รอง)';
		            }
		            when '1' {
		                accountTypeText = 'กู้ร่วม(หลัก)';
		            }
		            when '2' {
		                accountTypeText = 'กู้เดี่ยว';
		            }
		        }
		        return accountTypeText;
            }
		}
	}

	public class FNCDetailSub {
		public List<FNCDetailInfoAR> PCB_AR_INF;
	}

	public class FNCDetailInfoAR {
		public String AR_ID = '';
		public String AR_ID_ENCODED = '';
		public String ORIG_AR_ID = '';
		public String LMT_AR_ID = '';
		public String ROOT_LMT_AR_ID = '';
		public String AR_PBS_TP_CD = '';
		public String KBNK_IDY_CL_CD = '';
		public String OPN_DT = '';
		public String EFF_DT = '';
		public String CTR_DT = '';
		public String MAT_DT = '';
		public String CLS_DT = '';
		public String POS_DT = '';
		public String CTR_AR_TEAM = '';
		public String CTR_AR_TERM_UOM_TP_CD = '';
		public String PD_GRP = '';
		public String PD_TP_CD = '';
		public String PD_SUB_TP_CD = '';
		public String MKT_CD = '';
		public String PD_DSC {
			set;
            get {
            	return ProductUsageHelper.getMarketDescription(PD_TP_CD,PD_SUB_TP_CD,MKT_CD);
            }
		}
		public String COA_PD_FTR_CD = '';
		public String LPM_CLSS = '';
		public String LMT_AMT = '';
		public String PNP_AMT = '';
		public String ACR_INT_AMT = '';
		public String RVRS_INT_AMT = '';
		public String RVRS_F = '';
		public String RVRS_DT = '';
		public String MEMO_ACR_INT_AMT = '';
		public String CTR_AR_TERM = '';
		public String OTSND_BAL = '';
		public String TOT_NO_INSTL = '';
		public String EFF_RATE_PCT = '';
		public String EFF_INT_RATE_TP_CD = '';
		public String EFF_SPRD_RATE_PCT = '';
		public String EFF_INT_RATE_TP_TEXT {
			set;
            get {
            	return String.isBlank(EFF_INT_RATE_TP_CD) ? '' : ProductUsageHelper.getInterestRateCodeFNC(EFF_INT_RATE_TP_CD, ORIG_INT_RATE_TP_CD,POS_DT,PNP_AMT) + 
				ProductUsageHelper.getSpreadInterestRate(EFF_SPRD_RATE_PCT);
            }
		}
		public String ORIG_ADV_AR_ID = '';
		public String AR_NM_TH = '';
		public String AR_NM_TH_TEXT{
			set;
            get {
            	return String.isBlank(AR_NM_TH) ? '' : AR_NM_TH;
            }
		}
		public String AR_NM_EN = '';
		public String PYMT_TP_CD = '';
		public String PYMT_TP_CD_TYPE {
			set;
			get {
				String resultText = '';
				switch on PYMT_TP_CD {
					when '0' {
						resultText = 'ชำระด้วยตัวเอง';
					}
					when '2' {
						resultText = 'หักบัญชีเงินฝากอัตโนมัติ';
					}
				}
				return resultText;
			}
		}
		public String PYMT_DUE_DT = '';
		public String LAST_PYMT_DT = '';
		public String DDC_AR_ID = '';
		public String DDC_AR_ID_FORMATTED {
			set;
            get {
				return ProductUsageHelper.formattingAccountNumber(DDC_AR_ID);
            }
		}
		public String DDC_INT_TP_CD = '';
		public String DDC_INT_TP_CD_TYPE {
			set;
			get {
				String resultText = '';
				switch on DDC_INT_TP_CD {
					when '1' {
						resultText = 'เก็บดอกเบี้ยล่วงหน้า'; 
					}
					when '2' {
						resultText = 'เก็บดอกเบี้ย Monthly';
					}
					when '3' {
						resultText = 'เก็บดอกเบี้ย ณ วันที่ครบกำหนด';
					}
				}
				return resultText;
			}
		}
		public String FEE_RATE_PCT = '';
		public String CMSN_TP_CD = '';
		public String CMSN_TP_CD_TYPE {
			set;
			get {
				String resultText = '';
				switch on CMSN_TP_CD {
					when '1' {
						resultText = 'คิดตามเกณฑ์';
					}
					when '2' {
						resultText = 'คิดตามจริง มีค่าธรรมเนียมขั้นต่ำ';
					}
					when '3' {
						resultText = 'คิดตามจริง มีระยะเวลาขั้นต่ำ';
					}
					when '7' {
						resultText = 'คิดครั้งแรก 1 เดือน';
					}
				}
				return resultText;
			}
		}
		public String UPD_FEE_AMT = '';
		public String ORIG_INT_RATE_TP_CD = '';

		public FNCDetailInfoARIPList PCB_AR_IP_LIST;
		public FNCDetailInfoSHDList PYMT_SHD_LIST;

		//Use only salesforce
		public String ITEM_COUNT = '0';
	}

	public class FNCDetailInfoARIPList {
		public List<FNCDetailInfoARIP> PCB_AR_IP_INF;
	}

	public class FNCDetailInfoARIP {
		public String IP_ID = '';
		public String AR_OWN_TP_CD = '';
		public String AR_OWN_TP_CD_TYPE {
			set;
            get {
            	String accountTypeText = '';
				switch on AR_OWN_TP_CD {
		            when '0' {
		                accountTypeText = 'กู้ร่วม(รอง)';
		            }
		            when '1' {
		                accountTypeText = 'กู้ร่วม(หลัก)';
		            }
		            when '2' {
		                accountTypeText = 'กู้เดี่ยว';
		            }
		        }
		        return accountTypeText;
            }
		}
	}

	public class FNCDetailInfoSHDList {
		public List<FNCDetailInfoSHD> PYMT_SHD_INF;
	}

	public class FNCDetailInfoSHD {
		public String CNDT_STRT_DT = '';
		public String PYMT_MTH_CD = '';
		public String PYMT_MTH_DSC = '';
		public String PNP_PYMT_FRQ_CYC_CD = '';
		public String PNP_PYMT_FRQ_UNIT_CD = '';
		public String PNP_PYMT_FRQ_TP_CD = '';
		public String PNP_PYMT_FRQ_DAY_CD = '';
		public String PNP_AMT = '';
		public String INT_PYMT_FRQ_CYC_CD = '';
		public String INT_PYMT_FRQ_UNIT_CD = '';
		public String INT_PYMT_FRQ_TP_CD = '';
		public String INT_PYMT_FRQ_DAY_CD = '';
		public String INT_AMT = '';
	}	

}