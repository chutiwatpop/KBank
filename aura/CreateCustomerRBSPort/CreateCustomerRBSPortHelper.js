({
	showToast: function(message, type) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": message,
            "type": type,
            "duration": "5000"
        });
        resultsToast.fire();
    }
})