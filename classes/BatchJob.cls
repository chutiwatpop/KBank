public with sharing class BatchJob {
    public Id batchId {get; set;}
    public String batchName {get; set;}
    public String jobStatus {get; set;}
    public Integer jobTotal {get; set;}
    public Integer jobErrors {get; set;}
    public String createdDate {get; set;}
    public String completedDate {get; set;}
    public Integer jobItemsProcessed {get; set;}

    public BatchJob(){
        this.batchId = null;
        this.batchName = '';
        this.jobStatus = '';
        this.jobTotal = 0;
        this.jobErrors = 0;
        this.createdDate = null;
        this.completedDate = null;
        this.jobItemsProcessed = null;
    }
}