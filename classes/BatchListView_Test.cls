@isTest
private class BatchListView_Test {
	
	@isTest static void testCreateSchedule() {
		Test.startTest();
		System.schedule('UserStructure_Batch', '1 1 1 1 1 ? 2050', new ScheduledBatchable('UserStructure_Batch'));
		Test.stopTest();
		System.assertNotEquals(null, [SELECT Id FROM CronTrigger]);
	}

	@isTest static void testRunNegativeBatchJob() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.getHourList();
		bCon.getMinuteList();
		bCon.getDayList();
		bCon.getWeeklyValue();
		bCon.getDailyTypeValue();
		bCon.getFieldValue();
		bCon.getScheduleTypeValue();
		bCon.batchName = 'UserStructure_Batch';
		bCon.batchSize = 2;
		bCon.scheduleType = 'One Time';
		bCon.oneTimeValue = '1022/1022/2560';

		Test.startTest();
			bCon.runBatch();
		Test.stopTest();
	}

	@isTest static void testRunNegativeBatchSize() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.batchSize = 201;
		bCon.scheduleType = 'Daily';
		bCon.dailyType = 'EVERY_WEEKDAY';

		Test.startTest();
			bCon.runBatch();
		Test.stopTest();
	}

	@isTest static void testRunBatchJob() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.batchSize = 5;
		Datetime beforeRunbatch = System.now();

		Test.startTest();
			bCon.runBatch();
		Test.stopTest();

		//AsyncApexJob asyncJob = [SELECT CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = :bCon.batchName];
	}
	
	@isTest static void testRunScheduleJobOneTime() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.hoursInput = '0';
		bCon.minInput = '0';
		bCon.scheduleType = 'One Time';
		bCon.oneTimeValue = '10/10/2560';

		Test.startTest();
			bCon.runSchedule();
		Test.stopTest();

		String jobName = bCon.batchName + ', ' + bCon.scheduleType;

		System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
	}

	@isTest static void testRunScheduleJobDaily() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.hoursInput = '0';
		bCon.minInput = '0';
		bCon.scheduleType = 'Daily';
		bCon.dailyType = 'EVERY_DAY';

		Test.startTest();
			bCon.runSchedule();
		Test.stopTest();

		String jobName = bCon.batchName + ', ' + bCon.scheduleType;

		System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
	}

	@isTest static void testRunScheduleJobWeekly() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.hoursInput = '0';
		bCon.minInput = '0';
		bCon.scheduleType = 'Weekly';
		bCon.weeklyType.add('SUN');
		bCon.weeklyType.add('MON');

		Test.startTest();
			bCon.runSchedule();
		Test.stopTest();

		String jobName = bCon.batchName + ', ' + bCon.scheduleType;

		System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
	}
	
	@isTest static void testRunScheduleJobMonthly() {
		BatchListView_Controller bCon = new BatchListView_Controller();
		bCon.batchName = 'UserStructure_Batch';
		bCon.hoursInput = '10';
		bCon.minInput = '0';
		bCon.scheduleType = 'Monthly';
		bCon.monthlyType = '28';

		Test.startTest();
			bCon.runSchedule();
		Test.stopTest();

		String jobName = bCon.batchName + ', ' + bCon.scheduleType;

		System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
	}

}