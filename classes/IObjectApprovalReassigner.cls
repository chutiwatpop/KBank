public interface IObjectApprovalReassigner {
	ApprovalWrapper getReAssign(ProcessInstanceWorkitem workItem);
	List<sObject> getAllObjectToUpdate();
}