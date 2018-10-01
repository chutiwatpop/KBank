global class RestResponseModel {

	global class sensitive_model {
		public String IP_ID {get;set;}
		public String IP_TAX_ID {get;set;}
		public String IDENT_NO {get;set;}
		public String TH_TTL {get;set;}
		public String TH_FRST_NM {get;set;}
		public String TH_MDL_NM {get;set;}
		public String TH_SURNM {get;set;}
		public String EN_TTL {get;set;}
		public String EN_FRST_NM {get;set;}
		public String EN_MDL_NM {get;set;}
		public String EN_SURNM {get;set;}
	}

	global class enlite_model {
		public String FNC_ID {get;set;}
		public String ORG_ID {get;set;}
		public String FNC_POS_DT {get;set;}
		public String POS_DT {get;set;}
		public String CASH_EQVC_AMT {get;set;}
		public String AC_RCVB_AMT {get;set;}
		public String ACR_INT_AMT {get;set;}
		public String SHRT_TERM_LOAN_AMT {get;set;}
		public String TOT_SHRT_TERM_LOAN_AMT {get;set;}
		public String IVNT_AMT {get;set;}
		public String NET_IVNT_AMT {get;set;}
		public String TOT_CRN_AST_AMT {get;set;}
		public String NET_PTY_PLNT_EQMT_AMT {get;set;}
		public String OTHR_NON_CRN_AST_AMT {get;set;}
		public String TOT_NON_CRN_AST_AMT {get;set;}
		public String TOT_AST_AMT {get;set;}
		public String LBY_SHRHLR_EQTY_AMT {get;set;}
		public String OD_SHRT_TERM_LOAN_AMT {get;set;}
		public String TRD_AC_NOTE_PBL_AMT {get;set;}
		public String AC_PBL_AMT {get;set;}
		public String OTHR_AC_PBL_AMT {get;set;}
		public String OTHR_SHRT_TERM_LOAN_AMT {get;set;}
		public String TOT_CRN_LBY_AMT {get;set;}
		public String LT_LOAN_AMT {get;set;}
		public String TOT_LT_LOAN_AMT {get;set;}
		public String OTHR_LBY_AMT {get;set;}
		public String TOT_LBY_AMT {get;set;}
		public String OTH_LIST_AMT {get;set;}
		public String SHRHLR_EQTY_AMT {get;set;}
		public String LIST_SAMT_AMT {get;set;}
		public String VAL_AMT {get;set;}
		public String PAID_SAMT_AMT {get;set;}
	}

	global class customerInformation_model {
		public String IP_ID {get;set;}
		public String PRVN_F {get;set;}
		public String IP_PERF_ST_CD {get;set;}
		public String PRIM_SEG_CD {get;set;}
		public String PRIM_SUB_SEG_CD {get;set;}
		public String DUAL_SEG_CD {get;set;}
		public String DUAL_SUB_SEG_CD {get;set;}
		public String IP_TP_CD {get;set;}
		public String IP_LGL_STC_TP_CD {get;set;}
		public String BRTH_ESTB_DT {get;set;}
		public String DOC_ITM_CD {get;set;}
		public String DOMC_BR_NO {get;set;}
		public String DEATH_DT {get;set;}
		public String DEATH_F {get;set;}
		public String GND_CD {get;set;}
		public String RLG_CD {get;set;}
		public String NAT_CD {get;set;}
		public String RACE_CD {get;set;}
		public String MAR_ST_CD {get;set;}
		public String ORG_LGLTY_END_DT {get;set;}
		public String KBNK_IDY_CL_CD {get;set;}
		public String CO_IDY_CL_CD {get;set;}
		public String ISSU_DT {get;set;}
		public String EXP_DT {get;set;}
		public String GOVT_ISSUR {get;set;}
	}

	/*{"jsonResponse":{
        "returnResults" : [{
                        "SFDC_ID" : "xxxxxx",
                        "CIS_ID" : "xxxxxx",
                        "SUCCESS" : "FALSE",
                        "ERRORS" : [{
                                        "ERR_MSG" : "003",
                                        "ERR_STATUSCODE" : "004"
                                }
                        ]
                }
        ],
        "CI_JOB_ID" : "<CI_JobID>",
        "API_NAME" : "CI02_JDBC_Batch_ConvertProspect",
        "OBJECT_NAME" : "Account",
        "START_DT" : "yyyy-MM-dd HH:mm:ss.SSS",
        "FINISH_DT" : "yyyy-MM-dd HH:mm:ss.SSS",
        "RETRY_NUM" : "1"
        }
	}*/

	global class convertProspectResponse_model {
		public List<accountInformation_model> returnResults
		{
            get
            {
                if(returnResults==null)
                    returnResults=new List<accountInformation_model>();
                return returnResults;
            }
            set;
        }
		public String ci_job_id {get;set;}
		public String api_name {get;set;}
		public String object_name {get;set;}
		public String start_dt {get;set;}
		public String finish_dt {get;set;}
		public String retry_num {get;set;}
	}

	global class accountInformation_model {
		public String sfdc_id {get;set;}
		public String cis_id {get;set;}
		public String success {get;set;}
		public List<error_model> errors 
		{
            get
            {
                if(errors==null)
                    errors=new List<error_model>();
                return errors;
            }
            set;
        }
	}

	global class error_model {
		public String err_msg {get;set;}
		public String err_statuscode {get;set;}
	}

	global class batchTrigger_model {
		public String batch_Name {get;set;}
	}

	global class CMASrequestModel {
		public String batch_Name {get;set;}
		public String cwu_ref_no {get;set;}
		public String cust_id {get;set;}
		public String opportunity_id {get;set;}
		public String cwu_status {get;set;}
	}

}