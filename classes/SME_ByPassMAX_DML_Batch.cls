global class SME_ByPassMAX_DML_Batch implements Database.Batchable<sObject> ,Database.Stateful {
    private List<sObject> dmlList;
    private String operationType;
    global SME_ByPassMAX_DML_Batch(List<sObject> dmlList,String opType) {
        this.dmlList = dmlList;
        this.operationType = opType;
    }
    global List<sObject> start(Database.BatchableContext bc) {
        return dmlList;
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> partialList) {
        if(operationType == 'update')
            update partialList;
        else if(operationType == 'delete')
            delete partialList;
    }

    global void finish(Database.BatchableContext BC) {}

}