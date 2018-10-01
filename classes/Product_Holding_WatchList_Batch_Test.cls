@isTest
private class Product_Holding_WatchList_Batch_Test {
	
	@isTest static void testDefault() {
		Mockup_Test.newLPM();
		Test.startTest();
		Database.executeBatch(new Product_Holding_WatchList_Batch());
		Test.stopTest();
	}

	@isTest static void testInitial() {
		Mockup_Test.newLPM();
		Test.startTest();
		Database.executeBatch(new Product_Holding_WatchList_Batch('IS_INITIAL'));
		Test.stopTest();
	}	
	
	@isTest static void testOngoing() {
		Mockup_Test.newLPM();
		Test.startTest();
		Database.executeBatch(new Product_Holding_WatchList_Batch('IS_ONGOING'));
		Test.stopTest();
	}

	//@isTest static void testInitialWithStartLPMandEndLPM() {
	//	Mockup_Test.newLPM();
	//	Test.startTest();
	//	Database.executeBatch(new Product_Holding_WatchList_Batch('IS_INITIAL','1','5'));
	//	Test.stopTest();
	//}

	//@isTest static void testOngoingWithStartLPMandEndLPM() {
	//	Mockup_Test.newLPM();
	//	Test.startTest();
	//	Database.executeBatch(new Product_Holding_WatchList_Batch('IS_ONGOING','1','5'));
	//	Test.stopTest();
	//}

	@isTest static void testInitialWithLPMIds() {
		Mockup_Test.newLPM();
		Test.startTest();
		Database.executeBatch(new Product_Holding_WatchList_Batch('IS_INITIAL',new Set<String>{'1','2','3','4','5'}));
		Test.stopTest();
	}

	@isTest static void testOngoingWithLPMIds() {
		Mockup_Test.newLPM();
		Test.startTest();
		Database.executeBatch(new Product_Holding_WatchList_Batch('IS_ONGOING',new Set<String>{'1','2','3','4','5'}));
		Test.stopTest();
	}
	
}