({
	doInit: function(component,event,helper) {
        helper.validateReleaseOwnership(component);
    },
    closeModal:function(component,event,helper){   
        $A.get("e.force:closeQuickAction").fire();
    },
    onClickYes: function(component,event,helper) {
    	component.set('v.isLoading', true);
        var releaseSegment = component.get("v.releaseSegment");
        helper.handleUserSegment(component, releaseSegment);
    },
})