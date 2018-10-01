({
	showSuccessToast : function(component) {
		var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": "Release Temporary Ownership Request Success.",
            "type": "success",
            "duration": "5000"
        });
        resultsToast.fire();
	},
    showErrorToast : function(component, errorMsg) {
		var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": errorMsg,
            "type": "error",
            "duration": "5000"
        });
        resultsToast.fire();
	}
})