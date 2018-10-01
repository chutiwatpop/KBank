/**
 * @author komsan.wi@beryl8.com
 * @07/04/2016 create new
 */
global class SME_Performance_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new SME_Performance_Batch());
    }
}