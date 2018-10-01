({
	onInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
		var action = component.get("c.releaseTemporaryOwnership");
        action.setParams({accountId : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            $A.get("e.force:closeQuickAction").fire();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.success == true) {
                    helper.showSuccessToast(component);
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.showErrorToast(component, result.msg);
                }
            } else {
                var errors = response.getError();
                var errorText = "Failed to Release Temporary Ownership Request.";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                helper.showErrorToast(component, errorText);
            }
        });
        $A.enqueueAction(action);
	}
})