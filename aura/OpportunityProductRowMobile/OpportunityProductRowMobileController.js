({
	init : function(component, event, helper) {
        helper.initTable(component, event, helper);
	},
	selectedRow: function (component, event, helper) {
        var compEvent = component.getEvent('selectedRow');
        compEvent.fire();
    },
})