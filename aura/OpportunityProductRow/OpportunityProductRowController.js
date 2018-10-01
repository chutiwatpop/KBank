({
	init : function(component, event, helper) {
        var oppProductWrapper = component.get('v.oppProductWrapper');
        console.log('init oppProductWrapper:', oppProductWrapper.oppLineItem);
        var actionInitProductRow = component.get('c.initialProductResultRow');
        actionInitProductRow.setParams({opportunityProduct:JSON.stringify(oppProductWrapper.oppLineItem)});
        actionInitProductRow.setCallback(this, 
            function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS" && !resp.isError) {
                    helper.createInputForm(component, helper, resp);
                    helper.getProductSettings(component, helper);
                }else{
                    console.log('fail state', state);
                }
                helper.handleInit(component);
            }
        );
        $A.enqueueAction(actionInitProductRow);
	},
	onChangeProductResult : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.setOppLineItemField(component, event);
		helper.getProductReasons(component, helper);
	},
    onChangeReason : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.setOppLineItemField(component, event);
        helper.getRequiredField(component, helper);
    },
    onChangeField: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.setOppLineItemField(component, event);
    },
    handleNewApplication : function(component, event, helper) {
        console.log('handleNewApplication');
        component.set('v.isOpenAppModal', false);
        var params = event.getParam("params");
        console.log('params:' + params.data.isNewApplication);
        if(params.data.isNewApplication) {
            helper.setApplication(component, helper);
        }
        helper.handleNewApplicationModal(component, true);
    },
    handleSelectedApplication : function(component, event, helper) {
        console.log('handleSelectedApplication');
        var objectAPIName = event.getParam("objectAPIName");
        console.log('objectAPIName:' + objectAPIName);
        if(objectAPIName && objectAPIName == 'Application_History__c') {
            var selectedAppFromEvent = event.getParam("recordByEvent");
            console.log('selectedAppFromEvent:' + selectedAppFromEvent.Id);
            var oppProductWrapper = component.get('v.oppProductWrapper');
            oppProductWrapper.oppLineItem.Application__c      = selectedAppFromEvent.Id;
            oppProductWrapper.oppLineItem.Application_CBS__c  = selectedAppFromEvent.Id;
            component.set('v.oppProductWrapper', oppProductWrapper);
        }
    },
    handleNewRecord : function(component, event, helper) {
        var jobId = component.get('v.jobId');
        console.log('handleNewRecord');
        var oppProductWrapper = component.get('v.oppProductWrapper');
        if(!oppProductWrapper.application) oppProductWrapper.application = {};
        oppProductWrapper.application['OppName__c'] = jobId;
        component.set('v.isOpenAppModal', true);
        component.set('v.oppProductWrapper', oppProductWrapper);
        helper.handleNewApplicationModal(component, false);
    },
    handleRemoveRecord : function(component, event, helper) {
        console.log('handleRemoveRecord');
        var oppProductWrapper = component.get('v.oppProductWrapper');
        oppProductWrapper.application                    = null;
        oppProductWrapper.oppLineItem.Application__c     = null;
        oppProductWrapper.oppLineItem.Application_CBS__c = null;
        component.set('v.oppProductWrapper', oppProductWrapper);
    }
})