({
	doInit:function(component,event,helper) {
		// helper.validateFraud(component);
		helper.validateRequest(component);
	},
	closeModal:function(component,event,helper){   
        $A.get("e.force:closeQuickAction").fire();
    },
    onClickYes: function(component,event,helper) {
    	console.log('onClickYes');
        helper.createRequest(component);
    },
})