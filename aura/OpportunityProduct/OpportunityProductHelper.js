({
	saveOpportunityProduct : function(component, helper) {
		var oppProductWrapperList = component.get('v.oppProductWrapperList');
        var requiredColumn = component.get('v.requiredColumn');
        
        // Validate
        var errorList = [];
        for (var mIndex = 0; mIndex < oppProductWrapperList.length; mIndex++) {
            var eachWrapper = oppProductWrapperList[mIndex];
            var eachOppLineItem = eachWrapper.oppLineItem;
            var isMissingRequiredField = false;
            for(var key in requiredColumn) {
                if(requiredColumn[key] && 
                    (!eachOppLineItem[key] || (eachOppLineItem[key] && (eachOppLineItem[key] + '').trim() == ''))) {
                    isMissingRequiredField = true;
                    break;
                }
            }
            if(eachOppLineItem.requiredReason && (!eachOppLineItem.Reasons__c || (eachOppLineItem.Reasons__c && eachOppLineItem.Reasons__c.trim() == ''))) {
                isMissingRequiredField = true;
            } else if(eachOppLineItem.requiredRemark && (!eachOppLineItem.Remark__c || (eachOppLineItem.Remark__c && eachOppLineItem.Remark__c.trim() == ''))) {
                isMissingRequiredField = true;
            }

            if(isMissingRequiredField) {
                errorList.push(eachWrapper.Product2.Name + ' ');
            }
        }

        if(errorList.length > 0) {
            // helper.showErrorList(component, errorList, 'Missing required field!');
            helper.showError(component, 'Product:' + errorList.toString(), 'Missing required field!');
            component.set('v.isLoading', false);
            component.set('v.isSaving', false);
        } else {
            var action = component.get("c.saveOpportunityProduct");
            action.setParams({oppProductWrapper : JSON.stringify(oppProductWrapperList)});
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    var resp = response.getReturnValue();
                    if (state === "SUCCESS") {
                        if(resp.success) {
                            helper.showToast($A.get("$Label.c.Record_Created_Successfully"),'success');
                            $A.get('e.force:refreshView').fire();
                            $A.get("e.force:closeQuickAction").fire();
                        } else {
                            helper.showError(component, resp.msg);
                        }
                    } else {
                        console.log('Error!');                
                    }
                    component.set('v.isLoading', false);
                    component.set('v.isSaving', false);
                }
            );   
            $A.enqueueAction(action); 
        }
	},
    parseSelectedProductsToWrapper : function(component, selectedProducts) {
        var oppWrapperList = component.get('v.oppProductWrapperList');
        var recordId = component.get("v.recordId");
        var wrapperMapByProductId = {};
        if(!oppWrapperList) {
            oppWrapperList = [];
        } else {
            for (var oIndex = 0; oIndex < oppWrapperList.length; oIndex++) {
                var eachWrapper = oppWrapperList[oIndex];
                wrapperMapByProductId[eachWrapper.oppLineItem.Product2Id] = eachWrapper;
            }
        }

        // Clear old list
        oppWrapperList = [];
        for (var mIndex = 0; mIndex < selectedProducts.length; mIndex++) {
            var eachProduct = selectedProducts[mIndex];
            var eachWrapper;
            if(wrapperMapByProductId[eachProduct.Id]) {
                eachWrapper = wrapperMapByProductId[eachProduct.Id];
            } else {
                eachWrapper = {};
                eachProduct.PricebookEntries = null;
                eachWrapper.Product2    = eachProduct;
                eachWrapper.oppLineItem = {};
                eachWrapper.oppLineItem.Product2Id      = eachProduct.Id;
                eachWrapper.oppLineItem.OpportunityId   = recordId;
            }
            oppWrapperList.push(eachWrapper);
        }
        console.log('parseSelectedProductsToWrapper:' + oppWrapperList.length);
        component.set('v.oppProductWrapperList', oppWrapperList);
    },
    showError : function(component, errorMessage, errorHeader) {
        if(!errorHeader) errorHeader = 'Review the errors on this page.';
        component.set("v.contentHeight", 120);
        component.set("v.errorHeader", errorHeader);
        component.set("v.errorMessage", errorMessage);
        component.set('v.isError',true);
    },
    showErrorList : function(component, errorList, errorHeader) {
        // Review the errors on this page.
        component.set("v.contentHeight", 120);
        if(!errorHeader) errorHeader = 'Review the errors on this page.';
        component.set("v.errorHeader", errorHeader);
        component.set("v.errorList", errorList);
        component.set('v.isError',true);
    },
    showToast: function(message, type) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": message,
            "type": type,
            "duration": "5000"
        });
        resultsToast.fire();
    },
    clearError: function(component) {
        component.set("v.contentHeight", 0);
        component.set("v.errorHeader", '');
        component.set("v.errorMessage", '');
        component.set("v.errorList", []);
        component.set('v.isError', false);
    },
})