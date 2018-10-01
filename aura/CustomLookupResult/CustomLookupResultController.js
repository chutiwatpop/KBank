({
	doInit: function(component, event, helper) {
		console.log('doInit');
        var oRecord 				= component.get("v.oRecord");
        var primaryFieldAPIName 	= component.get("v.primaryFieldAPIName");
        var secondaryFieldAPIName 	= component.get("v.secondaryFieldAPIName");
        if(primaryFieldAPIName) {helper.getValue(primaryFieldAPIName, oRecord)
        	component.set("v.primaryFieldValue", helper.getValue(primaryFieldAPIName, oRecord));
        }
        if(secondaryFieldAPIName) {
        	component.set("v.secondaryFieldValue", helper.getValue(secondaryFieldAPIName, oRecord));
        }
    },
    selectRecord : function(component, event, helper){      
        var getSelectRecord = component.get("v.oRecord");
        var objectAPIName = component.get("v.objectAPIName");
        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({"recordByEvent" : getSelectRecord,"objectAPIName":objectAPIName}); 
        compEvent.fire();
    }
})