({
	init : function(component, event, helper) {
        console.log('init Edit Main');
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
		var initialComponent = component.get('c.initialEditProduct');
		initialComponent.setParams({jobId:recordId});
		initialComponent.setCallback(this, 
            function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS" && !resp.isError) {
                    component.set('v.oppProductWrapperList', resp.oppWrapperList);
                }else{
                    console.log('fail state', state);
                }
                component.set('v.isLoading', false);
            }
        );
        $A.enqueueAction(initialComponent);
	},
    handleInitialized : function(component, event, helper) {
        console.log('handleInitialized');
        component.set('v.isLoading', false);
        var dmltype = event.getParam("dmltype");
        var params = event.getParam("params");
        if(dmltype === 'initial_product_results') {
            console.log('initial_product_results:' + params.data.requiredColumn);
            if(params.data.requiredColumn) {
                component.set('v.requiredColumn', params.data.requiredColumn);
            }
        }
    },
    updateRecords : function(component, event, helper) {
        console.log('updateRecords');
        component.set('v.isLoading', true);
        component.set('v.isSaving', true);
        helper.clearError(component);
        helper.updateOpportunityProduct(component, helper);
    },
    closeModal : function(component, event, helper) {
        component.set('v.isLoading', true);
        var newApplicationIds = component.get('v.newApplicationIds');
        if(newApplicationIds.length > 0) {
            var deleteApplication = component.get('c.deleteApplication');
            deleteApplication.setParams({applicationIds:JSON.stringify(newApplicationIds)});
            deleteApplication.setCallback(this, 
                function(response) {
                    component.set('v.isLoading', false);
                    var state = response.getState();
                    var resp = response.getReturnValue();
                    if (state === "SUCCESS") {
                        if(resp.success) {
                            $A.get("e.force:closeQuickAction").fire();
                        } else {
                            helper.showError(component, resp.msg);
                        }
                    } else {
                        console.log('Error!');                
                    }
                }
            );
            $A.enqueueAction(deleteApplication);
        } else {
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    handleNewApplicationModal : function(component,event,helper){
        console.log('handleNewApplicationModal');
        var params = event.getParam("params");

        if(params.newApplicationId) {
            var newApplicationIds = component.get('v.newApplicationIds');
            newApplicationIds.push(params.newApplicationId);
            component.set('v.newApplicationIds', newApplicationIds);
        }

        var btnGroup = component.find('btnGroup');
        if(!params.isClosedModal) {
            $A.util.addClass(btnGroup, 'hide-button');
        } else {
            $A.util.removeClass(btnGroup, 'hide-button');
        }
    }
})