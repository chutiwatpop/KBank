@isTest
private class ProductUsageHelper_Test {
	
	@TestSetup
	static void setupAlldata(){
		mockProductUsageIntRateData();
		mockProductUsageIdnxIntRateData();
		mockProductUsageMktCodeData();
	}
	
	private static void mockProductUsageIntRateData(){
		List<Product_Usage_Interest_Rate_Type__c> intRateList = new List<Product_Usage_Interest_Rate_Type__c>();
		intRateList.add(newInterestRate('name01','001','MOR'));
		intRateList.add(newInterestRate('name02','002','MLR'));
		intRateList.add(newInterestRate('name03','003','FD'));
		intRateList.add(newInterestRate('name04','095','อิงเงินฝากออมทรัพย์กองทุน'));
		intRateList.add(newInterestRate('name05','096','STAFF VEHICLE 01'));

		insert intRateList;		
	}
	
	private static void mockProductUsageIdnxIntRateData(){
		List<Product_Usage_Idnx_Interest_Rate_Type__c> indxIntRateList = new List<Product_Usage_Idnx_Interest_Rate_Type__c>();
		indxIntRateList.add(newIndxInterestRate('name01','096','LT0001','2018-08-21','0.00','700000.00','2015-10-15','2017-02-28','STAFF HOME 01'));
		indxIntRateList.add(newIndxInterestRate('name02','096','LT0001','2018-08-21','1000000.00','1300000.00','2015-10-15','2017-02-28','STAFF HOME 01'));
		indxIntRateList.add(newIndxInterestRate('name03','096','LT0002', String.valueOf(Date.today().addDays(-1)),'0.00','700000.00','2015-10-15','2024-10-15','STAFF VEHICLE 01'));
		indxIntRateList.add(newIndxInterestRate('name04','096','LT0003', String.valueOf(Date.today().addDays(-1)),'0.00','250000.00','2015-10-15','2024-10-15','Test'));
		indxIntRateList.add(newIndxInterestRate('name05','096','LT0006','2018-08-21','0.00','250000.00','2015-10-15','2024-10-15','COURT YEAR 1'));
		insert indxIntRateList;
	}
	
	private static void mockProductUsageMktCodeData(){
		List<Product_Usage_Market_Code__c> mktCodeList = new List<Product_Usage_Market_Code__c>();
		mktCodeList.add(newMktCode('name01','11001','7100','0010','สินเชื่อบ้านกสิกรไทย'));
		mktCodeList.add(newMktCode('name02','11002','7100','1','สินเชื่อตกแต่งบ้านกสิกรไทย'));
		mktCodeList.add(newMktCode('name03','11003','7100','1','สินเชื่อบ้านเพื่อประกันชีวิตพิทักษ์สินกสิกรไทย'));
		mktCodeList.add(newMktCode('name04','11004','7100','1','สินเชื่อบ้านเพื่อประกันอัคคีภัยกสิกรไทย'));
		mktCodeList.add(newMktCode('name05','11001','8500','1','สินเชื่อบ้านกสิกรไทย เพื่อรีไฟแนนซ์(ส่วนเกิน)'));
		mktCodeList.add(newMktCode('name06','11002','8500','1','สินเชื่อบ้านเพื่อที่พักอาศัยเชิงพาณิชย์'));

		insert mktCodeList;
	}

	private static Product_Usage_Market_Code__c newMktCode(String name,String prodTypeCode,String prodSubtypeCode,String mktCode,String mktDesc){
		Product_Usage_Market_Code__c mktCodeObj = new Product_Usage_Market_Code__c();
		mktCodeObj.Name = name;
		mktCodeObj.Product_Type_Code__c = prodTypeCode;
		mktCodeObj.Product_Sub_Type_Code__c = prodSubtypeCode;
		mktCodeObj.Market_Code__c = mktCode;
		mktCodeObj.Market_Description__c = mktDesc;
		return mktCodeObj;
	}

	private static Product_Usage_Interest_Rate_Type__c newInterestRate(String name,String intRateCode,String intRateDesc){
		Product_Usage_Interest_Rate_Type__c intRateObj = new Product_Usage_Interest_Rate_Type__c();
		intRateObj.Name = name;
		intRateObj.Interest_Rate_Code__c = intRateCode;
		intRateObj.Interest_Rate_Description__c = intRateDesc;
		return intRateObj;
	}
	
	private static Product_Usage_Idnx_Interest_Rate_Type__c newIndxInterestRate(String name,String intRateCode,String origIntRate,String posDate,String startRangeAmt,String endRangeAmt,String effDate,String endDate,String intRateDesc){
		Product_Usage_Idnx_Interest_Rate_Type__c intIndxRateCodeObj = new Product_Usage_Idnx_Interest_Rate_Type__c();
		intIndxRateCodeObj.Name = name;
		intIndxRateCodeObj.Interest_Rate_Code__c = intRateCode;
		intIndxRateCodeObj.Post_Date__c = Date.valueOf(posDate);
		intIndxRateCodeObj.Start_Range_Amount__c = Decimal.valueOf(startRangeAmt);
		intIndxRateCodeObj.End_Range_Amount__c = Decimal.valueOf(endRangeAmt);
		intIndxRateCodeObj.Effective_Date__c = Date.valueOf(effDate);
		intIndxRateCodeObj.End_Date__c = Date.valueOf(endDate);
		intIndxRateCodeObj.Interest_Rate_Description__c = intRateDesc;
		intIndxRateCodeObj.Original_Interest_Rate_Code__c = origIntRate;
		return intIndxRateCodeObj;
	}

	@isTest
	static void testGetMarketDesc(){
		String expectedMktCode = 'สินเชื่อบ้านกสิกรไทย';
		String mktCode = ProductUsageHelper.getMarketDescription('11001', '7100', '0010');
		String mktCodeEmpty = ProductUsageHelper.getMarketDescription('', '', null);
		System.AssertEquals(expectedMktCode,mktCode);
		System.AssertEquals('',mktCodeEmpty);
	}

	@isTest
	static void testGetInterestRateCodeFNC(){
		String intCodeEmpty = ProductUsageHelper.getInterestRateCodeFNC('','','','');
		String intCodeForStaffVehicle = ProductUsageHelper.getInterestRateCodeFNC('096','LT0002','2018-03-23','500000.00');
		String intCodeForStaffVehicleOutOfCondition = ProductUsageHelper.getInterestRateCodeFNC('096','LT0001','2018-03-23','1200000.00');
		String intCodeTest = ProductUsageHelper.getInterestRateCodeFNC('096','LT0003','2018-03-23','70000.00');
		String intCodeForMOR = ProductUsageHelper.getInterestRateCodeFNC('001','LT0001','2018-03-23','0.00');
		String intCodeFor095 = ProductUsageHelper.getInterestRateCodeFNC('095','LT0001','2018-03-23','0.00');

		System.AssertEquals('MOR',intCodeForMOR);
		System.AssertEquals('',intCodeEmpty);
		System.AssertEquals('อิงเงิน',intCodeFor095);
		System.AssertEquals('',intCodeForStaffVehicleOutOfCondition);
		System.AssertEquals('STAFF V',intCodeForStaffVehicle);
		System.AssertEquals('Test',intCodeTest);

	}

	@isTest
	static void testGetSpreadInterestRate(){
		String spIntRateNull = ProductUsageHelper.getSpreadInterestRate(null);
		String spIntRate0 = ProductUsageHelper.getSpreadInterestRate('0.000000');
		String spIntRateMinus = ProductUsageHelper.getSpreadInterestRate('-10.000000');
		String spIntRateEmpty = ProductUsageHelper.getSpreadInterestRate('');

		System.AssertEquals('',spIntRateNull);
		System.AssertEquals('',spIntRateEmpty);
		System.AssertEquals('',spIntRate0);
		System.AssertEquals('-10.000000%',spIntRateMinus);

	}

	@isTest
	static void testGetInterestRateCode(){
		String intRateNull = ProductUsageHelper.getInterestRateCode(null);
		String intRateMLR = ProductUsageHelper.getInterestRateCode('002');
		String intRateEmpty = ProductUsageHelper.getInterestRateCode('');

		System.AssertEquals('',intRateNull);
		System.AssertEquals('',intRateEmpty);
		System.AssertEquals('MLR',intRateMLR);

	}

	@isTest
	static void itShouldFormatAccountNumberAfterCallFormatting(){
		String formattedAccountNumber = ProductUsageHelper.formattingAccountNumber('1234567890');

		System.AssertEquals('123-4-56789-0', formattedAccountNumber);
	}

	@isTest
	static void itShouldReturnSameNumberIfLengthIsNotAccountNumber(){
		String formattedAccountNumber = ProductUsageHelper.formattingAccountNumber('');
		System.AssertEquals('', formattedAccountNumber);
		formattedAccountNumber = ProductUsageHelper.formattingAccountNumber('1234');
		System.AssertEquals('1234', formattedAccountNumber);
	}

	@isTest
	static void itShouldFormatCardNumberAfterCallFormatting(){
		String formattedCardNumber = ProductUsageHelper.formattingCardNumber('1234567890123456');

		System.AssertEquals('1234 5678 9012 3456', formattedCardNumber);
	}

	@isTest
	static void itShouldReturnSameNumberIfLengthIsNotCardNumber(){
		String formattedCardNumber = ProductUsageHelper.formattingCardNumber('');
		System.AssertEquals('', formattedCardNumber);
		formattedCardNumber = ProductUsageHelper.formattingCardNumber('1234');
		System.AssertEquals('1234', formattedCardNumber);
	}

	@isTest
	static void itShouldFormatFundAccountNumberAfterCallFormatting(){
		String formattedFundAccountNumber = ProductUsageHelper.formattingFundAccountNumber('12345678901234');

		System.AssertEquals('1234-567-8-90123-4', formattedFundAccountNumber);
	}

	@isTest
	static void itShouldReturnSameNumberIfLengthIsNotFundAccountNumber(){
		String formattedFundAccountNumber = ProductUsageHelper.formattingFundAccountNumber('');
		System.AssertEquals('', formattedFundAccountNumber);
		formattedFundAccountNumber = ProductUsageHelper.formattingFundAccountNumber('1234');
		System.AssertEquals('1234', formattedFundAccountNumber);
	}
}