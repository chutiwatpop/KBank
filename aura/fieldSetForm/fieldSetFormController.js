({
    doInit : function(component, event, helper) {
        var mode = component.get('v.mode');
        if(mode=='Input')component.set('v.inputModeBool', true);
        var action = component.get("c.getFields");
        var objectApiName = component.get("v.objectApiName");
        var fsName = component.get("v.fieldSetName");
        action.setParams({typeName: objectApiName, fsName: fsName});
        action.setCallback(this, function(a) {
            var fields = a.getReturnValue();
            component.set("v.fields", fields);
        });
        $A.enqueueAction(action);        
    },
    fireRefreshView : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    handleToggle : function(component, event, helper) {        
        var inputModeBool = component.get("v.inputModeBool");
        component.set("v.inputModeBool", !inputModeBool);
    }
})