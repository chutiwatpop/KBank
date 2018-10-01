({
	doInit : function(component, event, helper) {
        //get Rating Value
        var action = component.get("c.getRatingValue");
        var inputsel = component.find("rateSelect");
    	var opts=[];
        action.setCallback(this, function(a) {
            var allValues = a.getReturnValue();
            console.log('DataList : '+allValues);
            for(var i=0;i< allValues.length;i++){
                opts.push({"class": "optionClass", 
                           label: allValues[i],
                           value: allValues[i]
                          });
            }
        	inputsel.set("v.options", opts);
    	});     
    	$A.enqueueAction(action);
        
        //get initial Value
        var recordId = component.get('v.recordId');
        var actionInt = component.get("c.getIssueLogs");
        actionInt.setParams({
            "logId" :  recordId
        });
        actionInt.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var issueLogs = response.getReturnValue();
                component.find("rateSelect").set("v.value", issueLogs.Rating__c);
                component.find("commentArea").set("v.value", issueLogs.Comment__c);
            }
        })
                              
        $A.enqueueAction(actionInt);
    
	},
    cancelRating: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();   
    },
    saveRating: function (component, event, helper) {
        //var rateVal = component.find("rateSelect").get("v.value");
        //var commentVal = component.find("commentArea").get("v.value");
		var recordId = component.get('v.recordId'); 
		var dataLog = component.get("v.issueLog");
        dataLog.Id = recordId;
        var action1 = component.get("c.updateIssueLog");
        action1.setParams({
        "log": dataLog
       });
        
        action1.setCallback(this, function(response) {
            var state = response.getState();           
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                alert('Rating Completed!');
            }else { 
				alert('An error occurred updating this Issue Log'); 
            }
        });
        $A.enqueueAction(action1); 
    }
    
})