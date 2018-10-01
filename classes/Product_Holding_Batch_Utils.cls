public without sharing class Product_Holding_Batch_Utils {

	private static String notExistingLPM = '-999999999';

	public static List<String> getRequests(List<LPM__C>lpms){
		List<String>requests = new List<String>();
		Integer lpmSize = lpms.size();
		for(Integer i=0;i<lpmSize;i+=20){
			String lpm1 = checkIfNull(lpms,i);
			String lpm2 = checkIfNull(lpms,i+1);
			String lpm3 = checkIfNull(lpms,i+2);
			String lpm4 = checkIfNull(lpms,i+3);
			String lpm5 = checkIfNull(lpms,i+4);
			String lpm6 = checkIfNull(lpms,i+5);
			String lpm7 = checkIfNull(lpms,i+6);
			String lpm8 = checkIfNull(lpms,i+7);
			String lpm9 = checkIfNull(lpms,i+8);
			String lpm10 = checkIfNull(lpms,i+9);
			String lpm11 = checkIfNull(lpms,i+10);
			String lpm12 = checkIfNull(lpms,i+11);
			String lpm13 = checkIfNull(lpms,i+12);
			String lpm14 = checkIfNull(lpms,i+13);
			String lpm15 = checkIfNull(lpms,i+14);
			String lpm16 = checkIfNull(lpms,i+15);
			String lpm17 = checkIfNull(lpms,i+16);
			String lpm18 = checkIfNull(lpms,i+17);
			String lpm19 = checkIfNull(lpms,i+18);
			String lpm20 = checkIfNull(lpms,i+19);
			String request = '&LPM1='+lpm1+'&LPM2='+lpm2+'&LPM3='+lpm3+'&LPM4='+lpm4+'&LPM5='+lpm5+'&LPM6='+lpm6+'&LPM7='+lpm7+'&LPM8='+lpm8+'&LPM9='+lpm9+'&LPM10='+lpm10+'&LPM11='+lpm11+'&LPM12='+lpm12+'&LPM13='+lpm13+'&LPM14='+lpm14+'&LPM15='+lpm15+'&LPM16='+lpm16+'&LPM17='+lpm17+'&LPM18='+lpm18+'&LPM19='+lpm19+'&LPM20='+lpm20;
			requests.add(request);
		}
		return requests;
	}

	private static String checkIfNull(List<LPM__C>lpms,Integer Index){
		Integer lpmsSize = lpms.size();
		if(Index > lpmsSize-1 || String.isBlank(lpms[Index].Name)){
			return notExistingLPM;
		}else{
			return lpms[Index].Name;
		}
	}

	public static String getTodayTimeStamp(){
		return String.valueOf(Date.today());
	}

	public static String getLast12MonthTimeStamp(){
		return String.valueOf(Date.today().addMonths(-11));
	}

	public static String getLastMonth(){
		return String.valueOf(Date.today().addMonths(-1));
	}

	public static boolean isRequestContainsLPMNumber(String lpmNumber,String request){	
		Pattern containFirstLPM = Pattern.compile('.*LPM\\d{1,2}='+lpmNumber+'(\\Z|&.*)');
		Matcher containFirstLPMMatcher = containFirstLPM.matcher(request);
		boolean isMatchPattern = containFirstLPMMatcher.matches();
		return isMatchPattern;
	}

	public static Map<String,String> getMaxMinLPMNumber(){
		LPM__c maxLPMObj =  [SELECT Name FROM LPM__c  WHERE Name !='' Order by Name desc LIMIT 1];
		LPM__c minLPMObj =  [SELECT Name FROM LPM__c  WHERE Name !='' Order by Name asc LIMIT 1];
		Map<String,String> resultsMap = new Map<String,String>();
		resultsMap.put('minLPM',minLPMObj.Name);
		resultsMap.put('maxLPM',maxLPMObj.Name);
		return resultsMap;
	}

}