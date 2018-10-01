public with sharing class ScheduledBatchable implements Schedulable {
	private String batchName;
	private Integer batchSize;

	public ScheduledBatchable(String batchName) {
		this.batchName = batchName;
	}

	public ScheduledBatchable(String batchName, Integer batchSize) {
		this.batchName = batchName;
		this.batchSize = batchSize;
	}

	public void execute(SchedulableContext sc) {
        Type t = Type.forName(batchName);

        if (batchSize == null || batchSize < 1) {
        	Database.executeBatch((Database.Batchable<SObject>) t.newInstance());
        } else {
        	Database.executeBatch((Database.Batchable<SObject>) t.newInstance(), batchSize);
        }
    	
    }
}