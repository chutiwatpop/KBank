({
	init : function(component, event, helper) {
		component.set('v.isLoading', true);
		var action = component.get("c.checkIsMobile");
        action.setCallback(this, function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS") {
                    if(resp) {
                        console.log(' Mobile! :' + resp);
                        component.set('v.isMobile', resp);
                    } else {
                    	console.log('Not Mobile! :' + resp);
                    }
                } else {
                    console.log('Error!');                
                }
            }
        );   
        $A.enqueueAction(action); 
		console.log('recordId:' + component.get('v.recordId'));
	},
	doSave : function(component, event, helper) {
		console.log('doSave');
		component.set('v.isLoading', true);
		component.set('v.isSaving', true);
		helper.clearError(component);
		helper.saveOpportunityProduct(component, helper);
	},
	doNext : function(component, event, helper) {
		console.log('doNext');
		component.set('v.isLoading', true);
		helper.parseSelectedProductsToWrapper(component, component.get('v.selectedProduct'));
		component.set('v.isShowResult', true);
	},
	doBack : function(component, event, helper) {
		console.log('doBack');
		helper.clearError(component);
		component.set('v.isShowResult', false);
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
	handleSelectedProduct : function(component, event, helper) {
		var params = event.getParam("params");
		if(params && params.data.selectedRows) {
			component.set('v.selectedProduct', params.data.selectedRows);
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