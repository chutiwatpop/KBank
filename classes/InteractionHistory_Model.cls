public class InteractionHistory_Model {
	public Map<String, String> salesHistoryMap {get; private set;}
	public Map<String, String> purchaseHistoryMap {get; private set;}
	public String lastLoanRequestDate {get; private set;}
	public String appNumber {get; private set;}

	public InteractionHistory_Model(String cis, String transactBPResponseStr) {
		salesHistoryMap = new Map<String,String>();
		purchaseHistoryMap = new Map<String,String>();

		SME_TransactBPResultResponse transactBPResponse;
		try{
            transactBPResponse = SME_TransactBPResultResponse.parse(transactBPResponseStr);
        } catch(Exception e){
            String errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+transactBPResponseStr;
            GlobalUtility.logMessage('ERROR','InteractionHistory_Model','InteractionHistory_Model',null,null,errorMessage,null,e,null);
            throw new CIWebserviceException(errorMessage);
        } 

		if(transactBPResponse == null || transactBPResponse.returnResponse == null) return;
		if(transactBPResponse.returnResponse.transactBP.size() == 1) {
			SME_TransactBPResultResponse.transactBP_model transactBPModel = transactBPResponse.returnResponse.transactBP[0];
			if(transactBPModel.PCT_BS_PRCH_CR == null) transactBPModel.PCT_BS_PRCH_CR = '0';
			if(transactBPModel.PCT_BS_PRCH_CASH == null) transactBPModel.PCT_BS_PRCH_CASH = '0';
			if(transactBPModel.PCT_BS_SALE_CR == null) transactBPModel.PCT_BS_SALE_CR = '0';
			if(transactBPModel.PCT_BS_SALE_CASH == null) transactBPModel.PCT_BS_SALE_CASH = '0';
			parseSMETransactBPResultResponse(transactBPModel);
		}	

	}

	public InteractionHistory_Model(String cis) {
		Boolean isMockData = false;
		salesHistoryMap = new Map<String,String>();
		purchaseHistoryMap = new Map<String,String>();

		if(isMockData) {
			SME_TransactBPResultResponse.transactBP_model transactBPModel = new SME_TransactBPResultResponse.transactBP_model();
			transactBPModel.PCT_BS_PRCH_CR = '10.00';
			transactBPModel.PCT_BS_PRCH_CASH = '20.00';
			transactBPModel.PCT_BS_SALE_CR = '30.00';
			transactBPModel.PCT_BS_SALE_CASH = '40.00';
			parseSMETransactBPResultResponse(transactBPModel);
		} else {
			SME_TransactBPResultResponse transactBPResponse = SME_CIRestWebservice.getTransactBPRequest(cis);
			if(transactBPResponse == null || transactBPResponse.returnResponse == null) return;
			if(transactBPResponse.returnResponse.transactBP.size() == 1) {
				SME_TransactBPResultResponse.transactBP_model transactBPModel = transactBPResponse.returnResponse.transactBP[0];
				if(transactBPModel.PCT_BS_PRCH_CR == null) transactBPModel.PCT_BS_PRCH_CR = '0';
				if(transactBPModel.PCT_BS_PRCH_CASH == null) transactBPModel.PCT_BS_PRCH_CASH = '0';
				if(transactBPModel.PCT_BS_SALE_CR == null) transactBPModel.PCT_BS_SALE_CR = '0';
				if(transactBPModel.PCT_BS_SALE_CASH == null) transactBPModel.PCT_BS_SALE_CASH = '0';
				parseSMETransactBPResultResponse(transactBPModel);
			}	
		}
	}

	public void parseSMETransactBPResultResponse(SME_TransactBPResultResponse.transactBP_model transactBPModel) {
		lastLoanRequestDate = transactBPModel.APL_CRT_DT;
		if(lastLoanRequestDate != null && lastLoanRequestDate.length() == 8) {
			lastLoanRequestDate = GlobalUtility.toDateFormat(lastLoanRequestDate.substring(4,8), lastLoanRequestDate.substring(2,4), lastLoanRequestDate.substring(0,2));
		}
		appNumber = transactBPModel.APL_NO;
		salesHistoryMap.put('credit', transactBPModel.PCT_BS_SALE_CR != null ? transactBPModel.PCT_BS_SALE_CR : '');
		salesHistoryMap.put('cash', transactBPModel.PCT_BS_SALE_CASH != null ? transactBPModel.PCT_BS_SALE_CASH : '');
		salesHistoryMap.put('term', GlobalUtility.toNumber(transactBPModel.BS_SALE_TERM_DAY));
		salesHistoryMap.put('previousApp', transactBPModel.BS_SALE_APL != null ? transactBPModel.BS_SALE_APL : '');
		salesHistoryMap.put('verifiedApp', transactBPModel.BS_SALE_VERF != null ? transactBPModel.BS_SALE_VERF : '');

		purchaseHistoryMap.put('credit', transactBPModel.PCT_BS_PRCH_CR != null ? transactBPModel.PCT_BS_PRCH_CR : '');
		purchaseHistoryMap.put('cash', transactBPModel.PCT_BS_PRCH_CASH != null ? transactBPModel.PCT_BS_PRCH_CASH : '');
		purchaseHistoryMap.put('term', GlobalUtility.toNumber(transactBPModel.BS_PRCH_TERM_DAY));
		purchaseHistoryMap.put('previousApp', transactBPModel.BS_PRCH_APL != null ? transactBPModel.BS_PRCH_APL : '');
		purchaseHistoryMap.put('verifiedApp', transactBPModel.BS_PRCH_VERF != null ? transactBPModel.BS_PRCH_VERF : '');
	}

	public Map<String, String> getDataMap() {
		Map<String, String> dataMap = new Map<String, String>();
		dataMap.put('lastLoanRequestDate', validateNull(lastLoanRequestDate));
		dataMap.put('appNumber', validateNull(appNumber));
		dataMap.put('salesCredit', validateNull(salesHistoryMap.get('credit')));
		dataMap.put('salesCash', validateNull(salesHistoryMap.get('cash')));
		dataMap.put('salesTerm', validateNull(salesHistoryMap.get('term')));
		dataMap.put('salesPreviousApp', validateNull(salesHistoryMap.get('previousApp')));
		dataMap.put('salesVerifiedApp', validateNull(salesHistoryMap.get('verifiedApp')));
		dataMap.put('purchaseCredit', validateNull(purchaseHistoryMap.get('credit')));
		dataMap.put('purchaseCash', validateNull(purchaseHistoryMap.get('cash')));
		dataMap.put('purchaseTerm', validateNull(purchaseHistoryMap.get('term')));
		dataMap.put('purchasePreviousApp', validateNull(purchaseHistoryMap.get('previousApp')));
		dataMap.put('purchaseVerifiedApp', validateNull(purchaseHistoryMap.get('verifiedApp')));
		return dataMap;
	}

	public String validateNull(String value) {
		return value != null ? value : '';
	}
}