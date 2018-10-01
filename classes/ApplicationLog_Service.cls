/**
* @author komsan.wi@beryl8.com
* @17/07/2015 createddate
*/
public virtual class ApplicationLog_Service {
	public static final String LOG_NAME_PREFIX = 'ALOG-';
	private List<Application_Log__c> logList;
	private ERROR_LEVEL currentLevel;
	private enum ERROR_LEVEL {
		DEBUG,ERROR,INFO,WARN
	}
	public ApplicationLog_Service(){
		logList = new List<Application_Log__c>();
		resetErrorLevel();
	}
	private void resetErrorLevel(){
		currentLevel = ERROR_LEVEL.ERROR;
	}
	/*private ApplicationLog_Service resetErrorLevel(){
		this.resetErrorLevel();
		return this;
	}*/
	@TestVisible
	protected ApplicationLog_Service setErrorLevel(ERROR_LEVEL elvl){
		currentLevel = elvl;
		return this;
	}
	@TestVisible
	protected void addLog(String sourceClass,Exception ex){
		addLog(sourceClass,'',ex.getMessage(),ex.getStackTraceString(),ex.getTypeName(),System.now());
	}
	@TestVisible
	protected void addLog(String sourceClass,Exception ex, String sourceFunction){
		addLog(sourceClass,sourceFunction,ex.getMessage(),ex.getStackTraceString(),ex.getTypeName(),System.now());
	}
	@TestVisible
	protected void addLog(String sourceClass,String logMessage){
		addLog(sourceClass,'--None--',logMessage,null,'',System.now());
	}
	@TestVisible
	protected void addLog(String sourceClass,String logMessage, String sourceFunction){
		addLog(sourceClass,sourceFunction,logMessage,null,'',System.now());
	}
	private void addLog(String sourceClass, String sourceFunction, String logMessage, String trace,String exceptionType, DateTime timeTaken){
		Application_Log__c al = new Application_Log__c();

		Datetime dt = Datetime.now();
        String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
        al.Name = LOG_NAME_PREFIX+formattedDt;
		al.Debug_Level__c = this.currentLevel.name();
		al.Message__c = logMessage;
		al.Source__c = sourceClass;
		al.Source_Function__c = sourceFunction;
		al.Stack_Trace__c = trace;
		al.Exception_Type__c = exceptionType;
		//al.Timer__c = timeTaken;
		logList.add(al);
		resetErrorLevel();
	}
	@TestVisible
    protected virtual void clearance(){
    	if(logList.size() > 0){
            System.enqueueJob(new ApplicationLog_Queue(logList));
    		//ApplicationLog_Service.futureInsertLog(JSON.serialize(logList));
	    	//insert logList;
	    	logList.clear();
	    }
    }

    //@future
    //public static void futureInsertLog(String logJson){
    //    List<Application_Log__c> logList = (List<Application_Log__c>)JSON.deserialize(logJson, List<Application_Log__c>.class);
    //    insert logList;
    //}


    public class SalesStructureException extends Exception {}
    public class UserException extends Exception {}
    public class LicenseException extends Exception {}
}