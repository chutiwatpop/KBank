/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
global class SME_TransactBPResultResponse {
	public getTransactBPResponse_model returnResponse
	{
		get
		{
			if(returnResponse==null)
				returnResponse=new getTransactBPResponse_model();
				return returnResponse;
		}
		set;	
	}

	public class getTransactBPResponse_model
	{
		public List<transactBP_model> transactBP
		{
			get
			{
				if(transactBP==null)
					transactBP=new List<transactBP_model>();
					return transactBP;
			}
			set;
		}
	}

	public class transactBP_model {
		public String LPM_ID {get;set;}
		public String BSN_CD {get;set;}
		public String BSN_NM {get;set;}
		public String BSN_TP_CD {get;set;}
		public String APL_CRT_DT {get;set;}
		public String APL_NO {get;set;}
		public String VLD_FM_DT {get;set;}
		public String BS_SALE_APL {get;set;}
		public String BS_SALE_VERF {get;set;}
		public String PCT_BS_SALE_CR {get;set;}
		public String PCT_BS_SALE_CASH {get;set;}
		public String BS_SALE_TERM_DAY {get;set;}
		public String PCT_BS_PRCH_CR {get;set;}
		public String PCT_BS_PRCH_CASH {get;set;}
		public String BS_PRCH_TERM_DAY {get;set;}
		public String BS_PRCH_APL {get;set;}
		public String BS_PRCH_VERF {get;set;}
		public String TOT_NO_CHK_TXN {get;set;}
		public String TOT_NO_RET_CHK {get;set;}
		public String TOT_AMT_CHK_TXN {get;set;}
		public String TOT_AMT_RET_CHK {get;set;}
		public String BSN_CODE {get; set;}
	}

	public static SME_TransactBPResultResponse parse(String json) {
		return (SME_TransactBPResultResponse) System.JSON.deserialize(json, SME_TransactBPResultResponse.class);
	}

}