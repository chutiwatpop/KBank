global class SME_ClearIsCallReportThisYear_Schedule implements Schedulable {
	
	global void execute(SchedulableContext sc) {
   		Database.executeBatch(new SME_ClearIsCallReportThisYear_Batch());
	}
}