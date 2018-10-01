({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('record:' + recordId);
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSave : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
    },
    onChangeCustomerType : function(component, event, helper) {
        helper.onChangeCustomerType(component);
    }
})