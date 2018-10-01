@isTest
private class BusinessCode_Test
{
	@isTest static void testSyncOnoging()
	{
		Test.startTest();
			Upsert_BusinessCode_Schedule businessCodeSchedule = new Upsert_BusinessCode_Schedule();
			MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
			Test.setMock(HttpCalloutMock.class, mockrequest);
			businessCodeSchedule.execute(null);
		Test.stopTest();
	}

	@isTest static void testSyncInitial()
	{
		Test.startTest();
			Upsert_BusinessCode_Schedule businessCodeSchedule = new Upsert_BusinessCode_Schedule('True');
			MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
			Test.setMock(HttpCalloutMock.class, mockrequest);
			businessCodeSchedule.run();
		Test.stopTest();
	}

	@isTest static void testSyncFixBatch()
	{
		Test.startTest();
			Upsert_BusinessCode_Schedule businessCodeSchedule = new Upsert_BusinessCode_Schedule('2017-01-1 00:00:00','2017-01-2 00:00:00');
			MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
			Test.setMock(HttpCalloutMock.class, mockrequest);
			businessCodeSchedule.run();
		Test.stopTest();
	}


}