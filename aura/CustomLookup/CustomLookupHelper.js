({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        var objectAPIName = component.get("v.objectAPIName");
        var queryCondition = component.get("v.queryCondition");
        var queryField = component.get("v.queryField");
        var searchField = component.get("v.searchField");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objectName' : objectAPIName,
            'queryCondition' : queryCondition,
            'queryField' : queryField,
            'searchField' : searchField
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    removeSelectedRecord : function(component, helper) {
        var compEvent = component.getEvent('handleRemoveRecord');
        compEvent.setParams({
            "dmltype": "remove_selected",
            "params": {}
        });
        compEvent.fire();
    },
    getValue : function(fieldAPIName, record) {
		var value;
        var tempRecord = record;
        var fields = fieldAPIName.split(".");
        for(var i = 0;i < fields.length;i++) {
            if(tempRecord != null && tempRecord != undefined) {
                value = tempRecord[fields[i]];
                tempRecord = value;
            } else {
                break;
            }
        }
        
        return value;
	}
})