public with sharing class OpportunityApprovalReassigner  implements IObjectApprovalReassigner{
	private Map<Id,Opportunity> opportunityMap;
	private Map<Id,Opportunity> opportunityMapToUpdate;
	private Map<id,User_MaskModel> userMaskMapByUserId;
	private Map<String, User> userMapByNewRoleRC;
	private Map<Id, User> assignedUserMap;
	private Map<String,Team_Structure__c> teamStructureMapByRc;
	private User_Admin__c userAdmin;

	public OpportunityApprovalReassigner(Map<Id,Opportunity> opportunityMap,
		Map<Id,User> assignedUserMap,Map<String, User> userMapByNewRoleRC, Map<String,Team_Structure__c> teamStructureMapByRc,
		User_Admin__c userAdmin,Map<id,User_MaskModel> userMaskMapByUserId ) {
		this.opportunityMap = opportunityMap;
		this.assignedUserMap = assignedUserMap;
		this.userMapByNewRoleRC = userMapByNewRoleRC;
		this.teamStructureMapByRc = teamStructureMapByRc;
		this.userAdmin = userAdmin;
		this.userMaskMapByUserId = userMaskMapByUserId;
		this.opportunityMapToUpdate = new Map<Id,Opportunity>();
	}

	public ApprovalWrapper getReAssign(ProcessInstanceWorkitem workItem){
		ApprovalWrapper approvalWrapper;
		User_MaskModel userMask;
		Approval.ProcessWorkitemRequest workItemRequest;
		Opportunity opp;
		if(userMaskMapByUserId.containsKey(workItem.ProcessInstance.CreatedById)){
			userMask = userMaskMapByUserId.get(workItem.ProcessInstance.CreatedById);
			if(userMask.isChangeToInactive || userMask.isChangeRCCode){
				if(userMask.isOldRBSProfile || userMask.isOldAFProfile){
					if(opportunityMap.containsKey(workItem.ProcessInstance.TargetObjectId)){
						opp = opportunityMap.get(workItem.ProcessInstance.TargetObjectId);
						setJobInfoAndAddtoUpdateList(opp);
						workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,Label.ReopenJobRequestorIsInactive,ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
		                approvalWrapper = new ApprovalWrapper(workItemRequest);
					}
				}
			}
		}else if(userMaskMapByUserId.containsKey(workItem.ActorId)){
			userMask = userMaskMapByUserId.get(workItem.ActorId);
			if(userMask.isChangeToInactive || userMask.isChangeRCCode){
				if(userMask.isOldSMEProfile){
					if(workItem.ProcessInstance.CreatedBy.Current_Opportunity_Approval__c != null){
						workItem.ActorId = workItem.ProcessInstance.CreatedBy.Current_Opportunity_Approval__c;
						approvalWrapper = new ApprovalWrapper(workItem);
					}else{
						workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,null,ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
						approvalWrapper = new ApprovalWrapper(workItemRequest);
					}
				}else if(userMask.isOldRBSProfile || userMask.isOldAFProfile){
					if(opportunityMap.containsKey(workItem.ProcessInstance.TargetObjectId)){
						opp = opportunityMap.get(workItem.ProcessInstance.TargetObjectId);
						setJobInfoAndAddtoUpdateList(opp);
						workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,Label.ReopenJobApproverIsInactive,ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
		                approvalWrapper = new ApprovalWrapper(workItemRequest);
					}
				}
			}
		}
		return approvalWrapper;
	}

	private void setJobInfoAndAddtoUpdateList(Opportunity opp){
		setOpportunityStage(opp,GlobalConstants.FINISHED);
		setFlagResubmitApproval(opp,false);
		setApproverChangedTeamInactiveFlag(opp,true);
		addToUpdateList(opp);
	}

	private void addToUpdateList(Opportunity opp){
		this.opportunityMapToUpdate.put(opp.id,opp);
	}

	public List<sObject> getAllObjectToUpdate(){
		return (List<sObject>)this.opportunityMapToUpdate.values();
	}

	private void setOpportunityStage(Opportunity opp,String stage){
		opp.StageName = stage;
	}

	private void setFlagResubmitApproval(Opportunity opp,Boolean flag){
		opp.Resubmit_Approval__c = flag;
	}

	private void setApproverChangedTeamInactiveFlag(Opportunity opp,Boolean flag){
		opp.Approver_Changed_Team_Inactive__c = flag;
	}
}