({
	doInit : function(component, event, helper) {
        var currentUser = $A.get("$SObjectType.CurrentUser.Id");
        var recordId = component.get('v.recordId');        
        var actionLogs = component.get("c.getUrlReOpen");
        actionLogs.setParams({
            "logId" :  recordId,
            "userId" : currentUser
        });
        actionLogs.setCallback(this, function(response) {
            var state = response.getState();
            console.log("DataResponse : "+ state);
            if (state === "SUCCESS") {
                
                var issueLogs = response.getReturnValue();
                if(issueLogs.true != null){
                    console.log("DataTrue : "+ issueLogs.true);
                    var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                          "url": issueLogs.true,
                          "isredirect": "true"
                        });
                        urlEvent.fire();
                   
                }else{
                     $A.get("e.force:closeQuickAction").fire();
                     window.alert(issueLogs.false);
                     console.log("DataFalse : "+ issueLogs.false);
                }
                
            }      
        });     
        $A.enqueueAction(actionLogs);   
	}
})