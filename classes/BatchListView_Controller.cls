public without sharing class BatchListView_Controller {
	public static final Integer BATCH_MAX_SIZE = 2000;

	private Map<Id, ApexClass> apexClassMap;
	private Map<String, ScheduleJob> scheduleMapByBatchName = new Map<String, ScheduleJob>();

	public List<BatchJob> batchJobs {get; set;}
	public List<ScheduleJob> scheduleJobs {get;set;}
	public List<SelectOption> selectOptionList;
	public List<SelectOption> selectTypeList;
	public List<SelectOption> hourList = new List<SelectOption>();
	public List<SelectOption> minuteList = new List<SelectOption>();

	public Integer batchSize {get; set;}

	public String oneTimeValue {get; set;}
	public String batchName {get; set;}
	public String runType {get; set;}
	public String scheduleType {get; set;}
	public String dailyType {get; set;}
	public List<String> weeklyType {get; set;}
	public String monthlyType {get; set;}

	public String hoursInput {get;set;}
	public String minInput {get;set;}

	public Id deleteJobId {get; set;}

	public BatchListView_Controller() {
		apexClassMap = new Map<Id, ApexClass>([SELECT Id, Name FROM ApexClass WHERE ApexClass.Name LIKE '%_Batch' order by Name ASC]);
		weeklyType = new List<String>();

		batchSize = Integer.valueOf(Label.MANUAL_BATCH_SIZE);

		batchJobs = new List<BatchJob>();
		refreshBatchJob();

		scheduleJobs = new List<ScheduleJob>();
		refreshScheduleJob();

		selectOptionList = new List<SelectOption>();

		getScheduleTypeValue();
		getTypeValue();
		// Set default
		scheduleType = 'Daily';
		runType = 'Manual';

	   	for(ApexClass eachBatch : apexClassMap.values()) {
	   		selectOptionList.add(new SelectOption(eachBatch.Name, eachBatch.Name));
	   	}
	}

	public void refreshBatchJob() {
		Map<String, BatchJob> jobMapByBatchName = new Map<String, BatchJob>();

		List<AsyncApexJob> listApexJob = [SELECT ApexClassId, ApexClass.Name, TotalJobItems, Status, NumberOfErrors, JobItemsProcessed, CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClassId IN :apexClassMap.keySet() AND JobType = 'BatchApex' ORDER BY CreatedDate DESC];
		BatchJob batchJob;
		for(AsyncApexJob eachsApexJob : listApexJob) {
			if (!jobMapByBatchName.containsKey(eachsApexJob.ApexClass.Name)) {
				batchJob = new BatchJob();

				batchJob.batchId = eachsApexJob.ApexClassId;
	        	batchJob.batchName = eachsApexJob.ApexClass.Name;
	        	batchJob.jobStatus = eachsApexJob.Status;
	        	batchJob.jobTotal = eachsApexJob.TotalJobItems;
        		batchJob.jobItemsProcessed = eachsApexJob.JobItemsProcessed;
	        	batchJob.jobErrors = eachsApexJob.NumberOfErrors;
	        	batchJob.createdDate = getTimeZoneValue(eachsApexJob.CreatedDate);
	        	batchJob.completedDate = getTimeZoneValue(eachsApexJob.CompletedDate);

	        	jobMapByBatchName.put(eachsApexJob.ApexClass.Name, batchJob);
			}
	    }
	    batchJobs = jobMapByBatchName.values();
	}

	public void refreshScheduleJob() {
		scheduleJobs.clear();

		List<CronTrigger> listScheduleJob = [SELECT Id, CronJobDetail.Name, State, CreatedDate, NextFireTime, PreviousFireTime, EndTime FROM CronTrigger ORDER BY CreatedDate DESC];
		for(CronTrigger eachsSchedule : listScheduleJob) {

			ScheduleJob scheduleJob = new ScheduleJob();
		 	scheduleJob.jobId = eachsSchedule.Id;
	        scheduleJob.jobName = eachsSchedule.CronJobDetail.Name;
	        scheduleJob.jobStatus = eachsSchedule.State;
	        scheduleJob.createdTime = getTimeZoneValue(eachsSchedule.CreatedDate);
	        scheduleJob.nextFireTime = getTimeZoneValue(eachsSchedule.NextFireTime);
	        scheduleJob.previousFireTime = getTimeZoneValue(eachsSchedule.PreviousFireTime);
	        scheduleJob.endTime = getTimeZoneValue(eachsSchedule.EndTime);
	        
	        scheduleJobs.add(scheduleJob);
	    }

	}

	public List<SelectOption> getHourList() {
		hourList.clear();
		for (Integer i = 0 ; i < 24 ; i++) {
			hourList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
        return hourList;
    }

    public List<SelectOption> getMinuteList() {
    	minuteList.clear();
    	String min;
    	for (Integer i = 0 ; i < 60 ; i = i + 5) {
    		min = (String.valueOf(i).length() < 2) ? '0' + String.valueOf(i) : String.valueOf(i);
			minuteList.add(new SelectOption(min, min));
		}
        return minuteList;
    }

	public List<SelectOption> getFieldValue() {
        return selectOptionList;
    }

    public List<SelectOption> getTypeValue() {
    	selectTypeList = new List<SelectOption>();
		
		selectTypeList.add(new SelectOption('Manual', 'Manual'));
		selectTypeList.add(new SelectOption('Schedule', 'Schedule'));

        return selectTypeList;
    }

    public List<SelectOption> getScheduleTypeValue() {
    	selectTypeList = new List<SelectOption>();
		
		selectTypeList.add(new SelectOption('Daily', 'Daily'));
		selectTypeList.add(new SelectOption('Weekly', 'Weekly'));
		selectTypeList.add(new SelectOption('Monthly', 'Monthly'));
    	selectTypeList.add(new SelectOption('One Time', 'One Time'));

        return selectTypeList;
    }

    public List<SelectOption> getDailyTypeValue() {
    	List<SelectOption> listOptions = new List<SelectOption>();
		listOptions.add(new SelectOption('EVERY_WEEKDAY', 'Every weekday'));
		listOptions.add(new SelectOption('EVERY_DAY', 'Every day'));
    	
        return listOptions;
    }

    public List<SelectOption> getDayList() {
    	List<SelectOption> listOptions = new List<SelectOption>();
    	for (Integer i = 1; i < 32 ; i++) {
			listOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
		listOptions.add(new SelectOption('Last','Last'));

        return listOptions;
    }

    public List<SelectOption> getWeeklyValue() {
    	List<SelectOption> listOptions = new List<SelectOption>();
		listOptions.add(new SelectOption('SUN', 'Sunday'));
    	listOptions.add(new SelectOption('MON', 'Monday'));
    	listOptions.add(new SelectOption('TUE', 'Tuesday'));
    	listOptions.add(new SelectOption('WED', 'Wednesday'));
    	listOptions.add(new SelectOption('THU', 'Thursday'));
    	listOptions.add(new SelectOption('FRI', 'Friday'));
    	listOptions.add(new SelectOption('SAT', 'Saturday'));
        return listOptions;
    }

	public PageReference runBatch() {
		if (batchSize == null || batchSize <= 0 || batchSize > BATCH_MAX_SIZE) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Batch Size is invalid');
        	ApexPages.addMessage(msg);
        	return null;
		}
        try{
        	Type t = Type.forName(batchName);
        	Database.executeBatch((Database.Batchable<SObject>) t.newInstance(), batchSize);
        } catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Exception : ' + e.getMessage());
            system.debug('Error Message :' + e);
            ApexPages.addMessage(msg);
            return null;
        }
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm,'Run Batch ' + batchName);
        ApexPages.addMessage(msg);
        refreshBatchJob();

        return null;
    }

    public PageReference runSchedule() {

		if (batchSize == null || batchSize <= 0 || batchSize > BATCH_MAX_SIZE) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm,'Batch Size is invalid');
        	ApexPages.addMessage(msg);
        	return null;
		}

		String todayYear = System.now().format('y');

		String scheduleTime;
		if (scheduleType == 'Daily') {
			if (dailyType == 'EVERY_DAY') {
				scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' * * ? ' + todayYear;	
			} else if (dailyType == 'EVERY_WEEKDAY') {
				scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' ? * MON-FRI ' + todayYear;
			} else {
				showError('Exception : Please select daily type.');
				return null;
			}
		} else if (scheduleType == 'Weekly')  {
			if (weeklyType == null || weeklyType.size() == 0) {
				showError('Exception : Please select day of week.');
				return null;
			}
			scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' ? * ' + String.join(weeklyType, ',') + ' ' + todayYear;
		} else if (scheduleType == 'Monthly' && monthlyType != null) {
			if (monthlyType == 'Last') {
				scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' L * ? ' + todayYear;
			} else {
				scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' ' + monthlyType + ' * ? ' + todayYear;		
			}
			
		} else if (scheduleType == 'One Time') {

			Date dateFromInput;
	      	try {
				dateFromInput = Date.parse(oneTimeValue);
			} catch(Exception e) {
				try {
					dateFromInput = Date.valueOf(oneTimeValue);
				} catch (Exception ex) {
					showError('Exception : Invalid date.');
					return null;
				}
			}

			Time inputTime = Time.newInstance(Integer.valueOf(hoursInput), Integer.valueOf(minInput) + 10, 0, 0);
			if (dateFromInput != null && dateFromInput < System.today() || 
					( dateFromInput == System.today() && inputTime < System.now().time())) {
				showError('Exception : Date and time must be current time +10 min.');
				return null;
			}

			DateTime dateTimeInput = DateTime.newInstance(dateFromInput.year(), dateFromInput.month(),dateFromInput.day());
			String[] splitDate = dateTimeInput.format('d/MM/yyyy').split('/');

			scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput) + ' ' + splitDate[0] + ' ' + splitDate[1] + ' ? ' + splitDate[2];
		} else {
			showError('Exception : Something went wrong!');
			return null;
		}
		//showInfo('scheduleTime : ' + scheduleTime);

		try {
			System.schedule(batchName + ', ' + scheduleType , scheduleTime, new ScheduledBatchable(batchName, batchSize));
		} catch ( Exception e) {
			showError('Exception : ' + e.getMessage());
			return null;
		}
		
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm,'Complete Run Schedule Job ' + batchName + ', ' + scheduleType);
        ApexPages.addMessage(msg);
		refreshScheduleJob();

		return null;
	}

	public PageReference deleteSchedule() {
		System.abortJob(deleteJobId);
		refreshScheduleJob();
		return null;
	}
	
	//returns the properly formatted datetime value
	public String getTimeZoneValue(DateTime dateTimeInput) {
		if (dateTimeInput == null) return '';
		Map<String, String> mappedValues = GlobalUtility.getLocaleDateMap(); //populate the map with all the locale specific datetime formats
		String userLocale = UserInfo.getLocale(); //grab the locale of the user
		String dateTimeWithFormat = 'M/d/yyyy h:mm a'; //variable for the datetime format defaulted to the US format
		if (mappedValues.containsKey(userLocale)) { //if the map contains the correct datetime format
			dateTimeWithFormat = mappedValues.get(userLocale); //grab the datetime format for the locale
		}
		return dateTimeInput.format(dateTimeWithFormat);
	}

	public void showError (String errorMsg) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
	    ApexPages.addMessage(msg);
	}

	public void showInfo (String msgLog) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, msgLog);
	    ApexPages.addMessage(msg);
	}
}