public with sharing class IssueLogTriggerHandler extends TriggerHandler {
    private Map<Id, User> ownerUserMap;
    private List<Assignment_History_CBS__c> assignmentHistoryList;
    private Map<String,Assignment_History_CBS__c> assignmentHistoryMapById;
    private List<Issue_Log__c> parentIssueUpdateList;

    private Map<Id, String> recordTypeDevNameMapById;
    private Map<String, Id> recordTypeIdMapByDevName;
    private Map<String, String> closedRecordTypeMapByOpen;
    private Set<String> closeStatusSet;

    public override void init() {
        if(recordTypeIdMapByDevName == null) {
            recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
        }
        if(recordTypeDevNameMapById == null) {
            recordTypeDevNameMapById = GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Issue_Log__c');
        }
    }

    public override void allAfter() {
        this.assignmentHistoryList = new List<Assignment_History_CBS__c>();
        this.assignmentHistoryMapById = new Map<String,Assignment_History_CBS__c>();
        this.parentIssueUpdateList = new List<Issue_Log__c>();
    }

    private Boolean isCloseStatus(String eachStatus) {
        if(closeStatusSet == null)
            closeStatusSet = new Set<String>{GlobalConstants.REJECTED, GlobalConstants.STATUS_DONE, GlobalConstants.CLOSED, GlobalConstants.CLOSED_WON, GlobalConstants.CLOSE_LOST, GlobalConstants.CBS_ISSUELOG_CANCELLED};
        
        return closeStatusSet.contains(eachStatus);
    }

    public override void beforeInsert() {
        
        Set<Id> userIds = new Set<Id>();
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            if(eachIssue.Issue_Log_Owner__c == null) {
                eachIssue.Issue_Log_Owner__c = eachIssue.OwnerId;
            }

            if(isCloseStatus(eachIssue.Status__c)) {
                changeToCloseRecordType(eachIssue);
            }
            
            userIds.add(eachIssue.Issue_Log_Owner__c);
        }

        ownerUserMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive FROM User WHERE Id IN :userIds]);

        User ownerUser;
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            ownerUser = ownerUserMap.get(eachIssue.Issue_Log_Owner__c);
            IssueLog_Service.setIssueCreator(eachIssue, ownerUser);
        }
    }

    public override void beforeUpdate() {
        Set<Id> userIds = new Set<Id>();
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            if(eachIssue.Issue_Log_Owner__c != null) {
                userIds.add(eachIssue.Issue_Log_Owner__c);
            }
        }

        ownerUserMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive FROM User WHERE Id IN :userIds]);

        User ownerUser;
        Issue_Log__c oldIssue;
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            oldIssue = (Issue_Log__c) Trigger.oldMap.get(eachIssue.Id);
            // Change Owner
            if(eachIssue.Issue_Log_Owner__c != oldIssue.Issue_Log_Owner__c) {
                ownerUser = ownerUserMap.get(eachIssue.Issue_Log_Owner__c);
                IssueLog_Service.setIssueCreator(eachIssue, ownerUser);
            }

            // Change Assignee
            if(eachIssue.Assigned_Internal_Lookup__c != oldIssue.Assigned_Internal_Lookup__c) {
                eachIssue.Previous_Assigned_Team_Person__c = oldIssue.Assigned_Internal_Lookup__c;
            }

            // Change Status
            if(eachIssue.Status__c != oldIssue.Status__c) {
                if(eachIssue.Date_Time_Closed__c == null && isCloseStatus(eachIssue.Status__c)) {
                    eachIssue.Date_Time_Closed__c = System.now();
                }

                if(eachIssue.Status__c == GlobalConstants.RECALLED ){
                    eachIssue.IsSaveDraft__c = true;
                }

                if(isCloseStatus(eachIssue.Status__c)) {
                    changeToCloseRecordType(eachIssue);
                }
            }
        }
    }

    private void changeToCloseRecordType(Issue_Log__c eachIssue) {
        if(recordTypeDevNameMapById.containsKey(eachIssue.RecordTypeId)) {
            if(recordTypeDevNameMapById.get(eachIssue.RecordTypeId) == GlobalConstants.CBS_OPEN_ISSUE_NORMAL_REC) {
                if(eachIssue.Rating_Enabled__c) {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_NORMAL_REC);
                } else {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_NORMAL_NO_RATING_REC);
                }
            } else if(recordTypeDevNameMapById.get(eachIssue.RecordTypeId) == GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC) {
                if(eachIssue.Rating_Enabled__c) {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_PARENT_REC);
                } else {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_PARENT_NO_RATING_REC);
                }
            } else if(recordTypeDevNameMapById.get(eachIssue.RecordTypeId) == GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC) {
                if(eachIssue.Rating_Enabled__c) {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_SECOND_REC);
                } else {
                    eachIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_SECOND_NO_RATING_REC);
                }
            }
        }
    }

    public override void afterInsert() {
        // Prepare Data for update Parent Issue
        Set<Id> parentIds = new Set<Id>();
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            if(eachIssue.Parent_Issue__c != null) {
                parentIds.add(eachIssue.Parent_Issue__c);
            }
        }
        Map<Id, Issue_Log__c> parentIssueMap = new Map<Id, Issue_Log__c>([SELECT Id, Current_Child_Issue_Log__c, Previous_Closed_Issue_Log_Group__c, Rating_Enabled__c, RecordTypeId FROM Issue_Log__c WHERE Id IN :parentIds]);
        Issue_Log__c parentIssue;

        Set<Id> userIds = new Set<Id>();
        Map<Id, Issue_Log__c> issueLogMap = new Map<Id, Issue_Log__c>();
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            // Prepare for send Email
            if(eachIssue.Status__c != GlobalConstants.STATUS_DONE && eachIssue.Assigned_Team_Person__c != null) {
                issueLogMap.put(eachIssue.Id, eachIssue);
                if(eachIssue.Assigned_Internal_Lookup__c != null) {
                    userIds.add(eachIssue.Assigned_Internal_Lookup__c);
                }
            }

            // Create New Assignment History
            this.assignmentHistoryList.add(IssueLog_Service.createAssignmentHistory(eachIssue));
            //assignmentHistoryMapById

            // Check/Update Parent Issue Status / Date Open (Group)
            if(eachIssue.Parent_Issue__c != null && parentIssueMap.containsKey(eachIssue.Parent_Issue__c)) {
                parentIssue = parentIssueMap.get(eachIssue.Parent_Issue__c);

                // 27/02/2017
                if(parentIssue.Current_Child_Issue_Log__c != null) {
                    parentIssue.Previous_Closed_Issue_Log_Group__c = parentIssue.Current_Child_Issue_Log__c;
                }

                parentIssue.Current_Child_Issue_Log__c = eachIssue.Id;

                if(eachIssue.Rating_Enabled__c) {
                    parentIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_PARENT_REC);
                } else {
                    parentIssue.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_PARENT_NO_RATING_REC);
                }

                this.parentIssueUpdateList.add(parentIssue);
            }
        }
        

        // Future Send Email to assignee Status != Done
        IssueLog_Service.sendEmails(JSON.serialize(issueLogMap), '', JSON.serialize(userIds));
    }

    public override void afterUpdate() {
        // Prepare Data for update Parent Issue
        Set<Id> parentIds = new Set<Id>();
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            if(eachIssue.Parent_Issue__c != null) {
                parentIds.add(eachIssue.Parent_Issue__c);
            }
        }
        Map<Id, Issue_Log__c> parentIssueMap = new Map<Id, Issue_Log__c>([SELECT Id, Current_Child_Issue_Log__c, Previous_Closed_Issue_Log_Group__c FROM Issue_Log__c WHERE Id IN :parentIds]);
        Issue_Log__c parentIssue;

        // Prepare to update Assignment History
        List<Assignment_History_CBS__c> existAssignmentHistoryList = new List<Assignment_History_CBS__c>();
        existAssignmentHistoryList = [SELECT Id, Name__c, Issue_Log_Number__c, Released_Date__c FROM Assignment_History_CBS__c WHERE Issue_Log_Number__c IN :Trigger.newMap.keySet() AND Released_Date__c = null ORDER BY CreatedDate DESC];
        
        Map<Id, Map<String, Assignment_History_CBS__c>> existHistoryMapByIssueId = new Map<Id, Map<String, Assignment_History_CBS__c>>();
        for(Assignment_History_CBS__c eachExistHistory : existAssignmentHistoryList) {
            if(!existHistoryMapByIssueId.containsKey(eachExistHistory.Issue_Log_Number__c)) 
                existHistoryMapByIssueId.put(eachExistHistory.Issue_Log_Number__c, new Map<String, Assignment_History_CBS__c>());

            existHistoryMapByIssueId.get(eachExistHistory.Issue_Log_Number__c).put(eachExistHistory.Name__c, eachExistHistory);
        }

        // Prepare data for send Email
        Set<Id> userIds = new Set<Id>();
        Map<Id, Issue_Log__c> issueLogMap = new Map<Id, Issue_Log__c>();
        Map<Id, Issue_Log__c> oldIssueLogMap = new Map<Id, Issue_Log__c>();

        Issue_Log__c oldIssue;
        for(Issue_Log__c eachIssue : (List<Issue_Log__c>) Trigger.new) {
            oldIssue = (Issue_Log__c) Trigger.oldMap.get(eachIssue.Id);
            //Assignment_History_CBS__c eachAssignmentHistory = existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c);
            Assignment_History_CBS__c eachAssignmentHistory;
            if(existHistoryMapByIssueId.containsKey(eachIssue.Id) && existHistoryMapByIssueId.get(eachIssue.Id).containsKey(oldIssue.Assigned_Team_Person__c) ){
                eachAssignmentHistory = existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c);
            }

            userIds.add(eachIssue.Issue_Log_Owner__c);
            userIds.add(oldIssue.Issue_Log_Owner__c);

            if(eachIssue.Assigned_Internal_Lookup__c != null) {
                userIds.add(eachIssue.Assigned_Internal_Lookup__c);
                userIds.add(oldIssue.Assigned_Internal_Lookup__c);
            }

            // Status Change
            if(eachIssue.Status__c != oldIssue.Status__c) {
                issueLogMap.put(eachIssue.Id, eachIssue);
                oldIssueLogMap.put(eachIssue.Id, oldIssue);

                // Status = Re-called or Closed Status Update Assignment History field release date
                if(eachIssue.Status__c == GlobalConstants.RECALLED || isCloseStatus(eachIssue.Status__c)) {

                    if(eachAssignmentHistory != null) {
                      //  this.assignmentHistoryList.add(IssueLog_Service.updateAssignmentHistory(eachIssue, eachIssue.Status__c, existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c)));
                       
                        //Assignment_History_CBS__c eachAssignmentHistory = IssueLog_Service.updateAssignmentHistory(eachIssue, eachIssue.Status__c, existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c));
                        IssueLog_Service.updateAssignmentHistory(eachIssue, eachIssue.Status__c, eachAssignmentHistory);
                        if(eachAssignmentHistory != null){
                            if(!this.assignmentHistoryMapById.containsKey(eachAssignmentHistory.id)){
                                this.assignmentHistoryMapById.put(eachAssignmentHistory.id,null);
                            }
                            this.assignmentHistoryMapById.put(eachAssignmentHistory.id,eachAssignmentHistory);
                        }
                    }
                } 
            }

            //Assigned Change 
            if((eachIssue.Assigned_Team_Person__c != oldIssue.Assigned_Team_Person__c && eachIssue.IsSaveDraft__c == false) || (eachIssue.IsSaveDraft__c != oldIssue.IsSaveDraft__c && eachIssue.IsSaveDraft__c == false)) {
                issueLogMap.put(eachIssue.Id, eachIssue);
                oldIssueLogMap.put(eachIssue.Id, oldIssue);

                // From Save Draft and change Status = DONE
                if((oldIssue.Status__c != GlobalConstants.STATUS_DONE && eachIssue.Status__c == GlobalConstants.STATUS_DONE ) &&
                    (oldIssue.Status__c != GlobalConstants.CBS_ISSUELOG_CLOSE && eachIssue.Status__c == GlobalConstants.CBS_ISSUELOG_CLOSE) &&
                    eachIssue.Issue_Log_Owner__c == UserInfo.getUserId()) {
                    Assignment_History_CBS__c doneAssignment = IssueLog_Service.createAssignmentHistory(eachIssue);
                    doneAssignment = IssueLog_Service.updateAssignmentHistory(eachIssue, GlobalConstants.STATUS_DONE, doneAssignment);
                    this.assignmentHistoryList.add(doneAssignment);
                } else {
                    // Assigned Change Create Assignment History update old Assigned
                    this.assignmentHistoryList.add(IssueLog_Service.createAssignmentHistory(eachIssue));
                    if(eachAssignmentHistory != null) {
                      //  this.assignmentHistoryList.add(IssueLog_Service.updateAssignmentHistory(eachIssue, GlobalConstants.ESCALATE_REASSIGNED, existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c)));
                    

                        //Assignment_History_CBS__c eachAssignmentHistory = IssueLog_Service.updateAssignmentHistory(eachIssue, GlobalConstants.ESCALATE_REASSIGNED, existHistoryMapByIssueId.get(eachIssue.Id).get(oldIssue.Assigned_Team_Person__c));
                        IssueLog_Service.updateAssignmentHistory(eachIssue, GlobalConstants.ESCALATE_REASSIGNED,eachAssignmentHistory);
                        if(eachAssignmentHistory != null){
                            if(!this.assignmentHistoryMapById.containsKey(eachAssignmentHistory.id)){
                                this.assignmentHistoryMapById.put(eachAssignmentHistory.id,null);
                            }
                            this.assignmentHistoryMapById.put(eachAssignmentHistory.id,eachAssignmentHistory);
                        }
                    }
                }
            }

            if(oldIssue.Status__c != GlobalConstants.STATUS_DONE && eachIssue.Status__c == GlobalConstants.STATUS_DONE && eachIssue.Issue_Log_Owner__c == UserInfo.getUserId()) {
                // Do not send Email
                issueLogMap.remove(eachIssue.Id);
                oldIssueLogMap.remove(eachIssue.Id);
            } else if (eachIssue.IsSaveDraft__c) {
                issueLogMap.remove(eachIssue.Id);
                oldIssueLogMap.remove(eachIssue.Id);
            }
        }

        // Future Send Email
        IssueLog_Service.sendEmails(JSON.serialize(issueLogMap), JSON.serialize(oldIssueLogMap), JSON.serialize(userIds));
    }

    public override void afterFinally() {
        if(!this.assignmentHistoryMapById.isEmpty()){
            this.assignmentHistoryList.addAll(this.assignmentHistoryMapById.values());
        }

        if(!this.assignmentHistoryList.isEmpty()) upsert this.assignmentHistoryList;
        // Update Parent Issue Status / Date Open (Group)
        if(!this.parentIssueUpdateList.isEmpty()) update this.parentIssueUpdateList;
    }
    
}