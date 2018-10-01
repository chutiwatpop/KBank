({
    closeBtn : function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
    doInit : function(component, event, helper) {
        // Get a reference to the getWeather() function defined in the Apex controller
        var action = component.get("c.sendToCMAS");
        action.setParams({
            "applicationHistoryId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(response) {
            var data = JSON.parse(response.getReturnValue());
            console.log(data);
            if (typeof(data) !== "undefined" && data !== null ) {
                if(data.status =='9'){
                    if(data.reasonDesc == 'User is inactive'){
                        component.set("v.hasError",true);
                        component.set("v.responseMsg", 'Not found CIS in DIH System');
                    }else{
                        component.set("v.hasError",true);
                        component.set("v.responseMsg", data.reasonDesc);
                    }
                }else{
                    component.set("v.hasError",false);
                    component.set("v.responseMsg", 'Success !!!');
                }
            }else{
                component.set("v.hasError",true);
                component.set("v.responseMsg", 'This application data cannot send to CMAS');
            }
            component.set('v.isLoading', false);
            var resultMsgSection    = component.find("resultMsgSection");
            $A.util.removeClass(resultMsgSection, 'slds-hide');
            $A.util.addClass(resultMsgSection, 'slds-show');
        });
        // Invoke the service
        $A.enqueueAction(action);
    }
    
})