({
	doInit: function(component, event, helper) {
        helper.getFormList(component,helper);
    },
    actionNext : function(component, event, helper) {
        helper.actionNext(component,helper);
        return false;
    },
})