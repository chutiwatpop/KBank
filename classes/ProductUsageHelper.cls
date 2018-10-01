public class ProductUsageHelper {

	public static List<Product_Usage_Interest_Rate_Type__c> ProductUsageInterestAll = Product_Usage_Interest_Rate_Type__c.getAll().values();
	public static List<Product_Usage_Market_Code__c> ProductUsageMarketCodeAll = Product_Usage_Market_Code__c.getAll().values();
	public static List<Product_Usage_Idnx_Interest_Rate_Type__c> ProductUsageIdnxInterestRateAll = Product_Usage_Idnx_Interest_Rate_Type__c.getAll().values();
	public static final Integer COMMITMENT_DATA = 1;
    public static final Integer SUBCOMMITMENT_DATA = 2;
    public static final Integer ACCOUNT_DATA = 3;

	public static String getInterestRateCode(String InterestRateCode){
		if(!String.isBlank(InterestRateCode)){
			Integer interestRateCodeVal = integer.valueof(InterestRateCode);
			for(Product_Usage_Interest_Rate_Type__c interestCode : ProductUsageInterestAll){
				if(interestRateCodeVal == integer.valueof(interestCode.Interest_Rate_Code__c)){
					return interestCode.Interest_Rate_Description__c;
				}
			}
		}
		return '';
	}

	public static string getSpreadInterestRate(string interestRate){
		if(!String.isBlank(interestRate)){
			Decimal rateVal = decimal.valueOf(interestRate).setScale(2);
			if(rateVal == 0){
				return '';
			}
			if(rateVal > 0){
				return '+' + rateVal + '%';	
			}else{
				return '' + rateVal + '%';	
			}
		}
		return '';
	}

	public static string getMarketDescription(string ProductTypeCode, string ProductSubTypeCode, string MarketCode){
		if(!String.isBlank(ProductTypeCode) && !String.isBlank(ProductSubTypeCode) && !String.isBlank(MarketCode)){
			for(Product_Usage_Market_Code__c productMarketCode : ProductUsageMarketCodeAll){
				if(productMarketCode.Product_Type_Code__c == ProductTypeCode && productMarketCode.Product_Sub_Type_Code__c == ProductSubTypeCode && productMarketCode.Market_Code__c == MarketCode){
					return productMarketCode.Market_Description__c;
				}
			}
		}
		return '';
	}

	public static String getInterestRateCodeFNC(String InterestRateCode, String OrigInterestRate,String posDate, String InstallmentAmount){
		if(!String.isBlank(InterestRateCode)){
			Integer interestRateCodeVal = integer.valueof(InterestRateCode);
			if(interestRateCodeVal != 96){
				for(Product_Usage_Interest_Rate_Type__c interestCode : ProductUsageInterestAll){
					if(interestRateCodeVal == integer.valueof(interestCode.Interest_Rate_Code__c)){
						if(interestCode.Interest_Rate_Description__c.length() > 7){
							return interestCode.Interest_Rate_Description__c.subString(0,7);
						}else{
							return interestCode.Interest_Rate_Description__c;
						}
					}
				}
			}else{
				for(Product_Usage_Idnx_Interest_Rate_Type__c interestIdnxCode : ProductUsageIdnxInterestRateAll){
					Decimal intAmount = decimal.valueOf(InstallmentAmount);
					if(interestRateCodeVal == integer.valueof(interestIdnxCode.Interest_Rate_Code__c) && interestIdnxCode.Original_Interest_Rate_Code__c == OrigInterestRate &&
						interestIdnxCode.Post_Date__c == Date.today().addDays(-1) &&
						intAmount > interestIdnxCode.Start_Range_Amount__c && intAmount < interestIdnxCode.End_Range_Amount__c &&
						Date.valueOf(posDate) > interestIdnxCode.Effective_Date__c && Date.valueOf(posDate) < interestIdnxCode.End_Date__c){
						if(interestIdnxCode.Interest_Rate_Description__c.length() > 7){
							return interestIdnxCode.Interest_Rate_Description__c.subString(0,7);
						}else{
							return interestIdnxCode.Interest_Rate_Description__c;
						}
					}
				}
			}

			
		}
		return '';      
	}

	public static String formattingAccountNumber(String accountNumber) {
		String accountNumberFormatted = accountNumber;

		if (accountNumberFormatted.length() == 10) {
			accountNumberFormatted = accountNumber.substring(0, 3) + '-' + accountNumber.substring(3, 4) + '-' + accountNumber.substring(4, 9) 
			+ '-' + accountNumber.substring(9, 10);
		}

		return accountNumberFormatted;
	}

	public static String formattingCardNumber(String cardNumber) {
		String cardNumberFormatted = cardNumber;

		if (cardNumberFormatted.length() == 16) {
			cardNumberFormatted = cardNumber.substring(0, 4) + ' ' + cardNumber.substring(4, 8) + ' ' + cardNumber.substring(8, 12) 
			+ ' ' + cardNumber.substring(12, 16);
		}

		return cardNumberFormatted;
	}

	public static String formattingFundAccountNumber(String fundAccountNumber) {
		String fundAccountNumberFormatted = fundAccountNumber;

		if (fundAccountNumberFormatted.length() == 14) {
			fundAccountNumberFormatted = fundAccountNumber.substring(0, 4) + '-' + fundAccountNumber.substring(4, 7) + '-' + fundAccountNumber.substring(7, 8) 
			+ '-' + fundAccountNumber.substring(8, 13) + '-' + fundAccountNumber.substring(13, 14);
		}

		return fundAccountNumberFormatted;
	}
	
	public static Map<String, LPMModel.LPMDetailInfo> getLPMDetailMap(LPMModel lpmModel) {
        Map<String, LPMModel.LPMDetailInfo> lpmDetailMap = new Map<String, LPMModel.LPMDetailInfo>();
        if(lpmModel != null && lpmModel.dataResponse  != null && lpmModel.dataResponse.Detail  != null && lpmModel.dataResponse.Detail.LPM_DTL_LIST  != null) {
            for(LPMModel.LPMDetailInfo lpmDetailInfo : lpmModel.dataResponse.Detail.LPM_DTL_LIST.LPM_DTL_INF) {
                lpmDetailMap.put(lpmDetailInfo.AR_ID_ENCODED, lpmDetailInfo);
            }
        }
        return lpmDetailMap;
    }

	public static String generateModelKey(String productCode, String id, Integer level, List<Integer> indexKey) {
		Integer index = indexKey.get(level-2);
        String levelKey = productCode + '_' + id + '_'  + level + '_' + index;
        indexKey.set(level-2, index + 1);
		return levelKey;
    }

	public static String generateModelKey(String productCode, String id, Integer level) {
        return productCode + '_' + id + '_'  + level;
    }

	public static FNCModel.FNCDetailIP filteredDetailIP(FNCModel.FNCDetailIPList ipList, String ownerIpId) {
		FNCModel.FNCDetailIP fncDetailIPFiltered = new FNCModel.FNCDetailIP();
        List<String> ipIdList = new List<String>();
		if(ipList != null){
			for(FNCModel.FNCDetailIP fncDetailIP : ipList.PCB_LMT_IP_INF){
				// Check ip_id same as owner of account
				if (fncDetailIP.IP_ID == ownerIpId) {
					fncDetailIPFiltered = fncDetailIP;
				}
                ipIdList.add(fncDetailIP.IP_ID);
			}
            fncDetailIPFiltered.IP_ID = String.join(ipIdList, ',');
		}
		return fncDetailIPFiltered;
	}

	public static FNCModel.FNCDetailInfoAR filteredDetailAR(FNCModel.FNCDetailSub detailList) {
        FNCModel.FNCDetailInfoAR fncDetailARFiltered = new FNCModel.FNCDetailInfoAR();
        Decimal result = 0;
        if(detailList != null) {
			for(FNCModel.FNCDetailInfoAR fncDetailAR : detailList.PCB_AR_INF) {
				if(String.isNotBlank(fncDetailAR.OTSND_BAL)) {
					try {
						result += Decimal.valueOf(fncDetailAR.OTSND_BAL);
					} catch (Exception e) {
						System.debug(e.getStackTraceString());
					}
				}
			}
			fncDetailARFiltered.ITEM_COUNT = String.valueOf(detailList.PCB_AR_INF.size());
			fncDetailARFiltered.OTSND_BAL = result.setscale(2).toPlainString();
        }
        return fncDetailARFiltered;
    }

	public static FNCModel.FNCDetailInfoARIP filteredDetailInfoARIP(FNCModel.FNCDetailInfoARIPList arIpList) {
		FNCModel.FNCDetailInfoARIP fncDetailInfoFiltered = new FNCModel.FNCDetailInfoARIP();
		List<String> ipIdList = new List<String>();
		if(arIpList != null){
			for(FNCModel.FNCDetailInfoARIP fncDetailInfoARIP : arIpList.PCB_AR_IP_INF){
				ipIdList.add(fncDetailInfoARIP.IP_ID);
			}
			fncDetailInfoFiltered.IP_ID = String.join(ipIdList, ',');
		}
		return fncDetailInfoFiltered;
	}

	public static Map<String, ProductUsageController.CalculatedAccount> calculateAccountData(List<FNCModel.FNCDetailInfo> fncDetails) {
        Map<String, ProductUsageController.CalculatedAccount> calculatedAccountMap =  new Map<String, ProductUsageController.CalculatedAccount>();
        for(FNCModel.FNCDetailInfo fncDetail : fncDetails) {
            if(Integer.valueOf(fncDetail.LMT_LVL_IND) == SUBCOMMITMENT_DATA && fncDetail.PCB_AR_LIST != null && fncDetail.PCB_AR_LIST.PCB_AR_INF.size() > 0) {
                Decimal result = 0;
                ProductUsageController.CalculatedAccount calculatedForRoot = new ProductUsageController.CalculatedAccount();
                ProductUsageController.CalculatedAccount calculatedForUpper = new ProductUsageController.CalculatedAccount();
                String rootId = fncDetail.ROOT_LMT_AR_ID;
                String upperId = fncDetail.UPR_LMT_AR_ID;
                Boolean isNotSameUpperAndRoot = !upperId.equals(rootId);
                
                if(calculatedAccountMap.containsKey(rootId)) {
                    calculatedForRoot = calculatedAccountMap.get(rootId);
                } else {
                    calculatedAccountMap.put(rootId, calculatedForRoot);
                }
                if(isNotSameUpperAndRoot) {
                    if(calculatedAccountMap.containsKey(upperId)) {
                        calculatedForUpper = calculatedAccountMap.get(upperId);
                    } else {
                        calculatedAccountMap.put(upperId, calculatedForUpper);
                    }
                }
                
                for(FNCModel.FNCDetailInfoAR fncDetailAR : fncDetail.PCB_AR_LIST.PCB_AR_INF) {
                    if(String.isNotBlank(fncDetailAR.OTSND_BAL)) {
                        try {
                            result += Decimal.valueOf(fncDetailAR.OTSND_BAL);
                        } catch (Exception e) {
                            System.debug(e.getStackTraceString());
                        }
                    }
                }

                calculatedForRoot.itemCount = calculatedForRoot.itemCount + fncDetail.PCB_AR_LIST.PCB_AR_INF.size();
                calculatedForRoot.outstandingBalance = calculatedForRoot.outstandingBalance + result;
                if(isNotSameUpperAndRoot) {
                    calculatedForUpper.itemCount = calculatedForUpper.itemCount + fncDetail.PCB_AR_LIST.PCB_AR_INF.size();
                    calculatedForUpper.outstandingBalance = calculatedForUpper.outstandingBalance + result;
                }
            }
        }

        return calculatedAccountMap;
    }
}