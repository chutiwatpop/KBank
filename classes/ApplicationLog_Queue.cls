public class ApplicationLog_Queue implements Queueable {
	public List<Application_Log__c> logList;
	public ApplicationLog_Queue(List<Application_Log__c> logList) {
		this.logList = logList;
	}

	public void execute(QueueableContext context) {
		insert logList;
	}
}