global class SME_CallReportPerformance_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	public  String CLOSE_CONTACTE_MAIN_BORROWER = 'Closed / Contacted Secondary Call Report Main Borrower (No plan)';
	private String query;
	private Integer rowEffect = 0;
	private Map<String,User_Extension__c> userExMap;
    private Map<String,Team_Structure__c> teamMap;
    private Set<String> secondaryReportToCountType = new Set<String>{CLOSE_CONTACTE_MAIN_BORROWER,GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN};
    private Boolean isManualRun = false;
    private Date thisDay;
    private Integer thisMonth;
    private Integer thisYear;

	global SME_CallReportPerformance_Batch() {
		this.query = 'SELECT ID,Status__c,CreatedById,CreatedDate,Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Date_Report__c,LastModifiedDate,Primary_Call_Report__c,Secondary_Call_Report__c,Contact_Channel__c,Call_Result_Activity__c,Actual_Visit_Date__c,Offer_Credit_Product__c,Collect_Documents__c,Negotiation__c,Offer_Interest__c,RecordType.Name FROM Call_Report__c where Actual_Visit_Date__c = This_Year';
		userExMap = new Map<String,User_Extension__c>([SELECT Employee_ID__c,CRCall_Report_Relationship_Face_to_Face__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_Sales_Phone_Call__c,CRCall_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c FROM User_Extension__c]);
        teamMap = new Map<String,Team_Structure__c>([SELECT RC_Code__c,CRCall_Report_Relationship_Face_to_Face__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_Sales_Phone_Call__c,CRCall_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c  FROM Team_Structure__c]);
		clearOldPerformance();
		this.thisDay = System.today();
		this.thisMonth = thisDay.month();
		this.thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);
	}
	// Add For INC000000570851
	// Example format to execute SME_CallReportPerformance_Batch(0,1,31) means calculating callreperformance for this year at the end of First Month
	global SME_CallReportPerformance_Batch(Integer yearN,Integer monthN,Integer dayN){
		this.thisDay = date.newInstance(System.today().addyears(yearN).year(),monthN, dayN);
		this.thisMonth = thisDay.month();
		this.thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);
		Datetime dt = Datetime.newInstance(thisDay, Time.newInstance(23, 59, 59, 0));
		this.query = 'SELECT ID,Status__c,CreatedById,CreatedDate,Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Date_Report__c,LastModifiedDate,Primary_Call_Report__c,Secondary_Call_Report__c,Contact_Channel__c,Call_Result_Activity__c,Actual_Visit_Date__c,Offer_Credit_Product__c,Collect_Documents__c,Negotiation__c,Offer_Interest__c,RecordType.Name FROM Call_Report__c';
		String condition =  ' WHERE CALENDAR_YEAR(Actual_Visit_Date__c) = '+(thisYear-543)+' AND Actual_Visit_Date__c <='+dt.format('yyyy-MM-dd') +' AND CreatedDate <='+dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		this.query = this.query + condition;
		userExMap = new Map<String,User_Extension__c>([SELECT Employee_ID__c,CRCall_Report_Relationship_Face_to_Face__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_Sales_Phone_Call__c,CRCall_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c FROM User_Extension__c]);
        teamMap = new Map<String,Team_Structure__c>([SELECT RC_Code__c,CRCall_Report_Relationship_Face_to_Face__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_Sales_Phone_Call__c,CRCall_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c  FROM Team_Structure__c]);
		clearOldPerformance();
		isManualRun = true;
	}

	private void clearOldPerformance(){
		for(User_Extension__c userExtObj : userExMap.values()){
         userExtObj.CRTotal_Call_Report__c = 0;
         userExtObj.CRCall_Report_for_Sales__c = 0;
         userExtObj.CRCall_Report_for_Relationship__c = 0;
         userExtObj.CRCall_Report_Sales_Face_to_Face__c = 0;
         userExtObj.CRCall_Report_Sales_Phone_Call__c = 0;
         userExtObj.CRCall_Report_Relationship_Face_to_Face__c = 0;
         userExtObj.CRCall_Report_Relationship_Phone_Call__c = 0;
      }

      	for(Team_Structure__c teamStrucObj : teamMap.values()){
         teamStrucObj.CRTotal_Call_Report__c = 0;
         teamStrucObj.CRCall_Report_for_Sales__c = 0;
         teamStrucObj.CRCall_Report_for_Relationship__c = 0;
         teamStrucObj.CRCall_Report_Sales_Face_to_Face__c = 0;
         teamStrucObj.CRCall_Report_Sales_Phone_Call__c = 0;
         teamStrucObj.CRCall_Report_Relationship_Face_to_Face__c = 0;
         teamStrucObj.CRCall_Report_Relationship_Phone_Call__c = 0;
      }
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Call_Report__c> call_report_list) {

		User_Extension__c userExtObj;
        Team_Structure__c teamStrucTMLevel;
        Team_Structure__c teamStrucAHLevel;
        Team_Structure__c teamStrucNHLevel;
        Boolean isSaleReport = false;
        Boolean isSecondaryAndCount = false;
		for(Call_Report__c callReportObj : call_report_list){

			isSecondaryAndCount = (callReportObj.Secondary_Call_Report__c && callReportObj.Offer_Interest__c == GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY && secondaryReportToCountType.contains(callReportObj.RecordType.Name) ) ? TRUE : FALSE;
			if( !isSecondaryAndCount && !callReportObj.Primary_Call_Report__c) {continue;}
			if(callReportObj.Current_Owner_Extension__c!=null ){

				if(userExMap.containsKey(callReportObj.Current_Owner_Extension__c) ){
					userExtObj = userExMap.get(callReportObj.Current_Owner_Extension__c);
					if( teamMap.containsKey(callReportObj.Current_Team_Name__c) ){
						teamStrucTMLevel =	teamMap.get(callReportObj.Current_Team_Name__c);}
					if(teamMap.containsKey(callReportObj.Current_AH_Name__c) ){
						teamStrucAHLevel =	teamMap.get(callReportObj.Current_AH_Name__c);}
					if( teamMap.containsKey(callReportObj.Current_NH_Name__c) ){
						teamStrucNHLevel =	teamMap.get(callReportObj.Current_NH_Name__c);
					}

					//Calculate Field 1 number of total call_report
					userExtObj.CRTotal_Call_Report__c++;
					if( teamStrucTMLevel != null ){ teamStrucTMLevel.CRTotal_Call_Report__c++;}
					if( teamStrucAHLevel != null ){ teamStrucAHLevel.CRTotal_Call_Report__c++;}
					if( teamStrucNHLevel != null ){ teamStrucNHLevel.CRTotal_Call_Report__c++;}
					
					//Calculate Field 2 For Sale
					//if(saleActivityList.contains(callReportObj.Call_Result_Activity__c)){

					isSaleReport = callReportObj.Offer_Credit_Product__c || callReportObj.Collect_Documents__c || callReportObj.Negotiation__c;
					if( isSaleReport ){
						userExtObj.CRCall_Report_for_Sales__c++;
						if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_for_Sales__c++;}
						if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_for_Sales__c++;}
						if( teamStrucNHLevel != null){ teamStrucNHLevel.CRCall_Report_for_Sales__c++;}
	
						if(callReportObj.Contact_Channel__c =='Face to Face'){ //Calculate Field 4
							userExtObj.CRCall_Report_Sales_Face_to_Face__c++;
							if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_Sales_Face_to_Face__c++;}
							if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_Sales_Face_to_Face__c++;}
							if( teamStrucNHLevel != null) { teamStrucNHLevel.CRCall_Report_Sales_Face_to_Face__c++;}
	
						}
						else if(callReportObj.Contact_Channel__c =='Phone Call'){ //Calculate Field 5
							userExtObj.CRCall_Report_Sales_Phone_Call__c++;
							if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_Sales_Phone_Call__c++;}
							if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_Sales_Phone_Call__c++;}
							if( teamStrucNHLevel != null){ teamStrucNHLevel.CRCall_Report_Sales_Phone_Call__c++;}
					
						}
						else{
							System.debug('This Callreport For Sales has no Contact_Channel : '+ callReportObj.Contact_Channel__c);
						}

					}else{ //Calculate Field 3 For Relationship
						userExtObj.CRCall_Report_for_Relationship__c++;
						if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_for_Relationship__c++;}
						if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_for_Relationship__c++;}
						if( teamStrucNHLevel != null){ teamStrucNHLevel.CRCall_Report_for_Relationship__c++;}
					
						if(callReportObj.Contact_Channel__c =='Face to Face'){ //Calculate Field 6
							userExtObj.CRCall_Report_Relationship_Face_to_Face__c++;
							if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_Relationship_Face_to_Face__c++;}
							if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_Relationship_Face_to_Face__c++;}
							if( teamStrucNHLevel != null){ teamStrucNHLevel.CRCall_Report_Relationship_Face_to_Face__c++;}
						
						}
						else if(callReportObj.Contact_Channel__c =='Phone Call'){ //Calculate Field 7
							userExtObj.CRCall_Report_Relationship_Phone_Call__c++;
							if( teamStrucTMLevel != null){ teamStrucTMLevel.CRCall_Report_Relationship_Phone_Call__c++;}
							if( teamStrucAHLevel != null){ teamStrucAHLevel.CRCall_Report_Relationship_Phone_Call__c++;}
							if( teamStrucNHLevel != null){ teamStrucNHLevel.CRCall_Report_Relationship_Phone_Call__c++;}
					
						}
						else{
							System.debug('This Callreport for Relationship has no Contact_Channel : '+ callReportObj.Contact_Channel__c);
						}
					}

				}
			}else{
				System.debug('Call Report ID :'+callReportObj.ID + 'Has Null Value');
			}
		
			isSaleReport = false;
			isSecondaryAndCount = false;
			teamStrucTMLevel = null;
         	teamStrucAHLevel = null;
         	teamStrucNHLevel = null;
         	//System.debug(' teamMap : ' +teamMap);
         	//System.debug('teamStrucTMLevel : '+teamStrucTMLevel);
		
		}
		//if(call_report_list.size() > 0 ){
		//	rowEffect = call_report_list.size();
		//}
		
	}

	private Boolean isDayToStampMonthlyPerf(){ 

		Performance_Config__c perfConfigObj = Performance_Config__c.getOrgDefaults();
		Date dateField = system.today();
		Date lastDayOfMonth;
		Integer numberOfDays;
		Integer thisYear;
		Boolean isTest = Test.isRunningTest();

		thisYear = GlobalUtility.getYearInBuddhistCalendar(dateField);
		numberOfDays    = Date.daysInMonth(thisYear, dateField.month());
		lastDayOfMonth  = Date.newInstance(dateField.year() , dateField.month(), numberOfDays);

		if( perfConfigObj.Date__c == null  ){
			return (Date.today().isSameDay(lastdayOfMonth) || isTest );
		}else{
			Date dayToStamp = Date.newInstance(dateField.year() , dateField.month(), Integer.valueof(perfConfigObj.Date__c) );
			return (Date.today().isSameDay(dayToStamp) || isTest );
		}
	    
	}
	
	global void finish(Database.BatchableContext BC) {
		//if(rowEffect > 0){
		if(!isManualRun){
			update userExMap.values();
			update teamMap.values();
		}
		//}

		if( isDayToStampMonthlyPerf() || isManualRun){ // Check last day of month
			Map<Id,User_Extension__c> activeUserExtMapReportOwner = CallReport_Service.getMapActiveUserExtForCreateMonthly(thisDay);
		    List<Monthly_Performance__c> monthlyPerfList = [SELECT External_ID__c,CRCall_Report_Relationship_Face_to_Face__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_Sales_Phone_Call__c,CRCall_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c FROM Monthly_Performance__c WHERE CALENDAR_MONTH(Date__c) = :thisDay.month() AND CALENDAR_YEAR(Date__c) = :(thisYear-543)] ;
		    Map<String,Monthly_Performance__c> monthlyMapExId = new Map<String,Monthly_Performance__c>();
		    List<Monthly_Performance__c> monthlyToUpdate = new List<Monthly_Performance__c>();

		   // Date thisDay = System.today();
		    //Integer thisMonth = thisDay.month();
		    //Integer thisYear;
		    String userExtId;
		    String teamExtId;

		    for(Monthly_Performance__c monthlyObj : monthlyPerfList){
		    	monthlyMapExId.put(monthlyObj.External_ID__c, monthlyObj);
		    }

		    for(User_Extension__c userExtObj : userExMap.values() ){
		    	if(userExtobj.Employee_ID__c != null && activeUserExtMapReportOwner.containsKey(userExtObj.Id) ){
		    	userExtId = userExtobj.Employee_ID__c + ' ' + thisMonth + ' ' +thisYear;

			    	if( monthlyMapExId.containsKey(userExtId) ){
			    		Monthly_Performance__c monthlyObj = monthlyMapExId.get(userExtId);
			    		monthlyObj.CRCall_Report_Relationship_Face_to_Face__c = userExtobj.CRCall_Report_Relationship_Face_to_Face__c;
			    		monthlyObj.CRCall_Report_Relationship_Phone_Call__c   = userExtobj.CRCall_Report_Relationship_Phone_Call__c;
			    		monthlyObj.CRCall_Report_Sales_Face_to_Face__c		  =	userExtobj.CRCall_Report_Sales_Face_to_Face__c;
			    		monthlyObj.CRCall_Report_Sales_Phone_Call__c		  = userExtobj.CRCall_Report_Sales_Phone_Call__c;
			    		monthlyObj.CRCall_Report_for_Relationship__c 		  = userExtobj.CRCall_Report_for_Relationship__c;
			    		monthlyObj.CRCall_Report_for_Sales__c 		          = userExtobj.CRCall_Report_for_Sales__c;
			    		monthlyObj.CRTotal_Call_Report__c		              = userExtobj.CRTotal_Call_Report__c;
			    		monthlyToUpdate.add(monthlyObj);
			    	}
			    	else{  // this externalId not found in monthly_p object
			    		
				    		monthlyToUpdate.add( new Monthly_Performance__c(
				    		External_ID__c = userExtId,
				    		Name = GlobalConstants.monthThaiNameList.get(thisMonth-1) + ' ' + thisYear,
				    		CRCall_Report_Relationship_Face_to_Face__c= userExtobj.CRCall_Report_Relationship_Face_to_Face__c,
				    		CRCall_Report_Relationship_Phone_Call__c  = userExtobj.CRCall_Report_Relationship_Phone_Call__c,
				    		CRCall_Report_Sales_Face_to_Face__c		  =	userExtobj.CRCall_Report_Sales_Face_to_Face__c,
				    		CRCall_Report_Sales_Phone_Call__c		  = userExtobj.CRCall_Report_Sales_Phone_Call__c,
				    		CRCall_Report_for_Relationship__c 		  = userExtobj.CRCall_Report_for_Relationship__c,
				    		CRCall_Report_for_Sales__c 		          = userExtobj.CRCall_Report_for_Sales__c,
				    		CRTotal_Call_Report__c 		              = userExtobj.CRTotal_Call_Report__c,
				    		User__c                                   = userExtObj.Id,
				    		Date__c = Date.newInstance(thisDay.year(), thisMonth, thisDay.day() )
				    		));
			    		}
			    	
		
				}
		    }
		    for(Team_Structure__c teamStrucObj : teamMap.values() ){
		    	if(teamStrucObj.RC_Code__c != null ) {
			    	teamExtId = teamStrucObj.RC_Code__c + ' ' + thisMonth + ' ' + thisYear;
			    
			    	if( monthlyMapExId.containsKey(teamExtId)){
			    		Monthly_Performance__c monthlyObj = monthlyMapExId.get(teamExtId);
			    		monthlyObj.CRCall_Report_Relationship_Face_to_Face__c = teamStrucObj.CRCall_Report_Relationship_Face_to_Face__c;
			    		monthlyObj.CRCall_Report_Relationship_Phone_Call__c   = teamStrucObj.CRCall_Report_Relationship_Phone_Call__c;
			    		monthlyObj.CRCall_Report_Sales_Face_to_Face__c		  =	teamStrucObj.CRCall_Report_Sales_Face_to_Face__c;
			    		monthlyObj.CRCall_Report_Sales_Phone_Call__c		  = teamStrucObj.CRCall_Report_Sales_Phone_Call__c;
			    		monthlyObj.CRCall_Report_for_Relationship__c 		  = teamStrucObj.CRCall_Report_for_Relationship__c;
			    		monthlyObj.CRCall_Report_for_Sales__c 		          = teamStrucObj.CRCall_Report_for_Sales__c;
			    		monthlyObj.CRTotal_Call_Report__c		              = teamStrucObj.CRTotal_Call_Report__c;
			    		monthlyToUpdate.add(monthlyObj);
			    	}
			    	else{
			    		monthlyToUpdate.add(new Monthly_Performance__c(
			    		External_ID__c = teamExtId,
			    		Name = GlobalConstants.monthThaiNameList.get(thisMonth-1) + ' ' + thisYear,
			    		CRCall_Report_Relationship_Face_to_Face__c= teamStrucObj.CRCall_Report_Relationship_Face_to_Face__c,
			    		CRCall_Report_Relationship_Phone_Call__c  = teamStrucObj.CRCall_Report_Relationship_Phone_Call__c,
			    		CRCall_Report_Sales_Face_to_Face__c		  =	teamStrucObj.CRCall_Report_Sales_Face_to_Face__c,
			    		CRCall_Report_Sales_Phone_Call__c		  = teamStrucObj.CRCall_Report_Sales_Phone_Call__c,
			    		CRCall_Report_for_Relationship__c 		  = teamStrucObj.CRCall_Report_for_Relationship__c,
			    		CRCall_Report_for_Sales__c 		          = teamStrucObj.CRCall_Report_for_Sales__c,
			    		CRTotal_Call_Report__c 		              = teamStrucObj.CRTotal_Call_Report__c,
			    		Team__c 								  = teamStrucObj.Id,
			    		Date__c = Date.newInstance(thisDay.year(), thisMonth, thisDay.day() )
			    		));

			    	}
			    }
		    }
		    
		   	upsert monthlyToUpdate External_ID__c;
		}

	}
	
}