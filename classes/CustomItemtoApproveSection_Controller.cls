public with sharing class CustomItemtoApproveSection_Controller {
	public String SECTION_TITLE	{get {return 'Items to Approve';}	private set;}
	public String APPROVE 		{get {return 'Approve';}			private set;}
	public String REJECT 		{get {return 'Reject';}				private set;}
	public String RELATED_TO	{get {return 'Related To';}			private set;}
	public String TYPE			{get {return 'Type';}				private set;}
	public String MOST_RECENT_APPROVER	{get {return 'Most Recent Approver';}private set;}
	public String DATE_SUBMITTED	{get {return 'Date Submitted';}private set;}
	public String GOTO_BULKASSIGNMENT_PAGE	{get {return 'Go to Bulk Assignment Page';}private set;}


	public String PLEASE_SELECT_AT_LEASE_ONE_ROW { get {return 'Please Select At least one row';}private set;}
	//public String PLEASE_GIVE_REJECT_REASON 	 { get {return 'Please Give Reject Reason';}private set;}
	private Set<String> REFEROUT_REASON_SET_TO_REDIRECT = new Set<String>{GlobalConstants.REASON_NATIONALITY,
		GlobalConstants.REASON_NOT_SME,GlobalConstants.REASON_COMPANY_RELATED};

	public String BULK_ASSIGNMENT {get {return 'Bulk Assignment';}	private set;}
	private String BULK_ASSIGNMENT_APINAME = 'Bulk_Assignment__c';
	public String OTHERS {get {return 'Other';}	private set;}
	private User currentUser;
	private Id userGroupId;

	private List<ProcessInstanceWorkitem> processInstanceWorkItemList {get;set;}

	public List<ProcessInstanceWorkItemWrapper> processInstanceWorkItemWrapperList{get;set;}
	public String commentText {get;set;}
	public String approvalType{get;set;}
	public Boolean isRedirectToBulkAssignment {get;set;}
	public Boolean isCBSAdminUser {get;private set;}
	public String filterType{get;set;}
	public Boolean isSelectBulkAssignment {get {return filterType == BULK_ASSIGNMENT;} private set;}

	private static Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

	public class ProcessInstanceWorkItemWrapper{
		public ProcessInstanceWorkitem processInstanceWorkItem{get;set;}
		public Boolean isChecked{get;set;}
		public String objectLabel{get;set;}
		public String summitDate {get;set;}
		public String mostRecentApprover {get;set;}
		public String mostRecentApproverId {get;set;}
		public Bulk_Assignment__c bulkAssignment {get;private set;}

		public processInstanceWorkItemWrapper(ProcessInstanceWorkitem processItem,String mostRecentApprover,String mostRecentApproverId,Bulk_Assignment__c bulkAssignment){
			this.processInstanceWorkItem = processItem;
			this.summitDate = processItem.createdDate.format();
			this.mostRecentApprover = mostRecentApprover;
			this.mostRecentApproverId = mostRecentApproverId;
			this.objectLabel = CustomItemtoApproveSection_Controller.schemaMap.get(processItem.ProcessInstance.TargetObject.Type).getDescribe().getLabel();
			isChecked = false;
			this.bulkAssignment = bulkAssignment;
			
		}
	}


	public CustomItemtoApproveSection_Controller(){
		this.currentUser = [SELECT Id,Profile.Name From User WHERE Id = :UserInfo.getUserId()];
		this.isCBSAdminUser = false;
		this.filterType = OTHERS;
			if(currentUser.Profile.Name == GlobalConstants.CBS_ADMIN){
				this.isCBSAdminUser = true;
				this.userGroupId = [SELECT id From Group WHERE Name = :GlobalConstants.CBS_ADMIN Limit 1].Id;
			}
		this.isRedirectToBulkAssignment = false;
		init();
	}

	public void init(){
		processInstanceWorkItemWrapperList = new List<ProcessInstanceWorkItemWrapper>();
		Map<Id,ProcessInstanceWorkitem> processInstanceWorkitemProcessInstanceMap = new Map<Id,ProcessInstanceWorkitem>();
		Set<Id> bulkAssignmentIdSet = new Set<Id>();
		Map<Id,Bulk_Assignment__c> bulkAssignMentMapById = new Map<Id,Bulk_Assignment__c>();
		String currentUserIdTemp = currentUser.Id;
		String userGroupIdTemp = userGroupId;
		String objectCondition = '';
		String query = 'SELECT Id, ActorId,Actor.Name,ProcessInstance.Id,ProcessInstance.TargetObject.Id,ProcessInstance.TargetObject.Type,ProcessInstance.TargetObject.Name,createdDate FROM ProcessInstanceWorkitem WHERE ActorId IN (:currentUserIdTemp,:userGroupIdTemp)'; 
		if(filterType == BULK_ASSIGNMENT){
			objectCondition = ' AND ProcessInstance.TargetObject.Type = :BULK_ASSIGNMENT_APINAME';
		}else{
			objectCondition = ' AND ProcessInstance.TargetObject.Type != :BULK_ASSIGNMENT_APINAME';
		}
		query = query + objectCondition;

		this.processInstanceWorkItemList = Database.query(query);

		for( ProcessInstanceWorkitem processworkItem : processInstanceWorkItemList){
			processInstanceWorkitemProcessInstanceMap.put(processworkItem.ProcessInstance.id,processworkItem);
			if(processworkItem.ProcessInstance.TargetObject.Type == BULK_ASSIGNMENT_APINAME){
				bulkAssignmentIdSet.add(processworkItem.ProcessInstance.TargetObject.Id);
			}
		
		}

		if(bulkAssignmentIdSet != null && bulkAssignmentIdSet.size() > 0){
			bulkAssignMentMapById = new Map<ID, Bulk_Assignment__c>([SELECT Id,CIS_ID__r.CIS__c,Request_Reason_CBS__c,BulkAssignmentQueue__r.Request_Reason_Picklist__c,AssignmentOwner__r.Name,AssignmentOwner__r.Id From Bulk_Assignment__c WHERE Id IN :bulkAssignmentIdSet]);
		}
		List<ProcessInstance> processInstanceList = [SELECT Id,(SELECT Actor.Id,Actor.Name FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) FROM ProcessInstance  WHERE Id IN :processInstanceWorkitemProcessInstanceMap.keySet() ORDER BY id DESC];	
        for(ProcessInstance processInstance : processInstanceList){            
		if(processInstance.Steps == null || processInstance.Steps.isEmpty() )
            continue;
			ProcessInstanceWorkitem processworkObj = processInstanceWorkitemProcessInstanceMap.get(processInstance.Id);
            String name = processInstance.Steps.get(0).Actor.Name;
			String userid = processInstance.Steps.get(0).Actor.id;
			Bulk_Assignment__c bulkAssignment = bulkAssignMentMapById.get(processworkObj.ProcessInstance.TargetObject.Id);          
			processInstanceWorkItemWrapperList.add(
													new processInstanceWorkItemWrapper(processworkObj,name,userid,bulkAssignment)
												);
		}

	}



	public PageReference submitForApproval(){
		
		Set<Id> customerOwnershipRequestId = new Set<id>();
		Integer result;
		List<Approval.ProcessWorkitemRequest> workItemRequestList = new List<Approval.ProcessWorkItemRequest>();
		for(ProcessInstanceWorkItemWrapper processworkItemWarpper : processInstanceWorkItemWrapperList){
			if(processworkItemWarpper.isChecked){
				Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
				req.setAction(approvalType);
				req.setComments(commentText);
				req.setWorkitemId(processworkItemWarpper.processInstanceWorkItem.id);
				workItemRequestList.add(req);
				//Approval.ProcessResult processResult =  Approval.process(req);
				customerOwnershipRequestId.add(processworkItemWarpper.ProcessInstanceWorkitem.ProcessInstance.TargetObjectId);
			}
		}


		if(!workItemRequestList.isEmpty()) {
        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
        }

		if( approvalType == APPROVE){
			result = [SELECT count() From Customer_Ownership_Request__c 
								WHERE Id IN :customerOwnershipRequestId AND 
								//(Current_Owner_AH__c = :currentUser.Id OR Current_Owner_TL__c = :currentUser.Id) AND 
								Request_Type__c = :GlobalConstants.RELEASE_OWNERSHIP AND
								Refer_Out_Reason__c IN :REFEROUT_REASON_SET_TO_REDIRECT];

		}
		if(result > 0){
			this.isRedirectToBulkAssignment = true;
		}


		return null;
	}


    public PageReference setFilter() {
        init();
        return null;
    }


    



}