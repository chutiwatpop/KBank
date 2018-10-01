public with sharing class ApprovalAssignmentQueue implements Queueable {

	@TestVisible
	private static Boolean doChainJob = true;
	private Map<Id,User_MaskModel> inActiveOrChangeTeamUserMaskMapByUserId;
	
	public ApprovalAssignmentQueue(Map<Id,User_MaskModel> inActiveOrChangeTeamUserMaskMapByUserId){
		this.inActiveOrChangeTeamUserMaskMapByUserId = inActiveOrChangeTeamUserMaskMapByUserId;
	}
	public void execute(QueueableContext context) {
		ApprovalManager approvalManager = new ApprovalManager(inActiveOrChangeTeamUserMaskMapByUserId);
        approvalManager.initObjectReAssigner();
        approvalManager.reAssignProcessInstance();
        approvalManager.updateAllWork();

        if(doChainJob && GlobalUtility.isApexClassConfigActive('TargetListAssignmentQueue')) {	
        	System.enqueueJob(new TargetListAssignmentQueue(inActiveOrChangeTeamUserMaskMapByUserId));
        }
	}
}