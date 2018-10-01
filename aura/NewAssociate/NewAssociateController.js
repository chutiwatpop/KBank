({  
    doInit: function(component, event, helper) {
        helper.toggleLoading(component);
        helper.validateMainEvent(component,helper);
        helper.getBorrowerList(component,helper);
        helper.getAssociateList(component,helper);
    },
    actionSave : function(component, event, helper) {
        console.log('actionSave');
        helper.actionSave(component,helper);
        return false;
    },
    actionCancel : function(component, event, helper) {
        console.log('actionCancel');
        $A.get("e.force:closeQuickAction").fire();
    },
    validateAssociateType : function(component, event, helper) {
        var inputAssociateType = component.find("inputAssociateType").get("v.value");
        component.set("v.isInterested", (inputAssociateType == 'สนใจ'));
    },
})