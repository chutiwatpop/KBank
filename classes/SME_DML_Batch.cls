global class SME_DML_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    private List<sObject> dmlList;
    global SME_DML_Batch(List<sObject> dmlList) {
    	this.dmlList = dmlList;
    }
    global List<sObject> start(Database.BatchableContext bc) {
    	return dmlList;
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> partialList) {
    	update partialList;
    }

    global void finish(Database.BatchableContext BC) {}
}