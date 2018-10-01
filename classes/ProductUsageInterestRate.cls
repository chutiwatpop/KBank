public class ProductUsageInterestRate {

public static List<Product_Usage_Interest_Rate_Type__c> ProductUsageInterestAll = Product_Usage_Interest_Rate_Type__c.getAll().values();
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
		Decimal rateVal = decimal.valueOf(interestRate);
		if(rateVal >= 0){
			return '+' + rateVal;	
		}else{
			return '' + rateVal;	
		}

	}	
}