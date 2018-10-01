public with sharing class ScheduleJob {
	public Id jobId {get; set;}
    public String jobName {get; set;}
    public String jobStatus {get; set;}
    public String createdTime {get; set;}
    public String nextFireTime {get; set;}
    public String previousFireTime {get; set;}
    public String endTime {get; set;}

    public ScheduleJob(){
        this.jobId = null;
        this.jobName = '';
        this.jobStatus = '';
        this.createdTime = null;
        this.nextFireTime = null;
        this.previousFireTime = null;
        this.endTime = null;
    }
}