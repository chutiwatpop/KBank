/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_PurgeApplicationLog_Batch implements Database.Batchable<sObject> {
	
	public static String CLASS_NAME = 'SME_PurgeApplicationLog_Batch';

	public String query(){
        return 	'SELECT Id, CreatedDate ' + 
				'FROM Application_Log__c WHERE CreatedDate < LAST_N_DAYS:'+ CustomSettingUtil.getPurgeTime();
    }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(this.query());
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try{
			// Send list to Delete with SFDC
			Delete scope;
		}catch (Exception ex){
			GlobalUtility.logMessage('ERROR',CLASS_NAME,'Purge Application Log',null,null,ex.getMessage(),null,ex,null);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}