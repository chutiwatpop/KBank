public with sharing class ApprovalWrapper {
	
	private ProcessInstanceWorkItem workItem;
	private Approval.ProcessWorkitemRequest workItemRequest;

	public Boolean isSetWorkItem;
	public Boolean isSetworkItemRequest;

	public ApprovalWrapper(ProcessInstanceWorkItem workItem) {
		this.workItem = workItem;
		this.isSetWorkItem = true;
		this.isSetworkItemRequest = false;
	}

	public ApprovalWrapper(Approval.ProcessWorkitemRequest workItemRequest) {
		this.workItemRequest = workItemRequest;
		this.isSetworkItemRequest = true;
		this.isSetWorkItem = false;
	}

	public ProcessInstanceWorkItem getWorkItem(){
		return this.workItem;
	}

	public Approval.ProcessWorkitemRequest getWorkItemRequest(){
		return this.workItemRequest;
	}
}