({
	doInit : function(component) {
        window.addEventListener("message", function(event) {
            if (event.data != 'refreshPage') {
                // Not the expected message: Reject the message!
                return;
            }
			$A.get('e.force:refreshView').fire();
        }, false);
	},
})