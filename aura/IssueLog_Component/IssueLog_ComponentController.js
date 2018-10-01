({
	doInit : function(component, event, helper) {
        var currentUser = $A.get("$SObjectType.CurrentUser.Id");
        var recordId = component.get('v.recordId');        
        var actionLogs = component.get("c.getIssueLogs");
        actionLogs.setParams({
            "logId" :  recordId
        });
        actionLogs.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var issueLogs = response.getReturnValue();
                var issueId = issueLogs.Id;
                var ownerId = issueLogs.OwnerId.substring(0, 15);
                var isSaveDraft = issueLogs.IsSaveDraft__c;
                var currentStatus = issueLogs.Status__c;
                var assingedUser = issueLogs.Assigned_Internal_Lookup__c;
                currentUser = currentUser.substring(0, 15); // Add fixed Winter
                if(currentUser == ownerId){
            		if((isSaveDraft && isSaveDraft == true) || currentStatus == "Recalled") {
                        // Go to edit
                        var url = "/apex/CBS_EditOwnerIssueLog_Page?"
                        +"&id="+recordId
                        +"&nooverride=1";
                        helper.urlFire(url);
                    } else {
                        // Go to view
                        var url = "/apex/CBS_ViewIssueLog_Page?"
                        +"&id="+recordId
                        +"&nooverride=1";

                        helper.urlFire(url);
                    }
        		}else {                  
                    var action = component.get("c.getProfileUser");
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var currentProfile = response.getReturnValue();
                            if((assingedUser !=null && assingedUser.substring(0, 15) == currentUser) || currentProfile == "CBS-SC" || currentProfile == "CBS-Admin"){
                                if(currentStatus == "Recalled"){
                                    window.alert("This issue has been recalled");	
                                }else{
                                    var url = "/apex/CBS_EditAssignedIssueLog_Page?"+"&id=" + recordId + "&nooverride=1";
                                    helper.urlFire(url);	
                                }  
                            }else {
                                $A.get("e.force:closeQuickAction").fire();
                                window.alert("Only Issue Log owner and assigned user can manage Issue Log");
                            }
                        }
                    });
                    $A.enqueueAction(action);            	
                }  
            }
        });
        $A.enqueueAction(actionLogs);
	}
})