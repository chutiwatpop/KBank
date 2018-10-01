({
    validateMainEvent : function(component,helper) {
        var mainEventId = component.get("v.recordId");
        var action = component.get("c.validateMainEvent");
        action.setParams({mainEventId:mainEventId});
        action.setCallback(this,function(response){
            var state = response.getState();
            helper.toggleLoading(component);
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                if(returnVal.Secondary_Call_Report__c == true) {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast($A.get("$Label.c.Cant_Create_Call_Asso"),'error');
                } else if (returnVal.Secondary_Call_Report_ID1__c != undefined && returnVal.Secondary_Call_Report_ID2__c != undefined) {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast($A.get("$Label.c.Call_ReachMaxAsso"),'error');
                }
            }else{
                console.log('validateMainEvent error');
            }
        });
        $A.enqueueAction(action);
    },
    getBorrowerList : function(component,helper) {
        var action = component.get("c.getBorrowerTypes");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.borrowerList", returnVal);
                component.set("v.selectedBorrower", returnVal[0]);
            }else{
                console.log('getBorrowerList error');
            }
        });
        $A.enqueueAction(action);
    },
    getAssociateList : function(component,helper) {
        var action = component.get("c.getAssociateTypes");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.associateList", returnVal);
                component.set("v.selectedAssociate", returnVal[0]);
            }else{
                console.log('getAssociateList error');
            }
        });
        $A.enqueueAction(action);
    },
    actionSave : function(component,helper) {
        helper.validateInput(component,helper);
        helper.toggleLoading(component);
        var selectedAccount = component.get("v.selectedAccount");
        var isInterested = component.get("v.isInterested"); 
        var inputAssociateType = component.find("inputAssociateType").get("v.value");
        var inputBorrowerType;
        if(isInterested) {
            inputBorrowerType = component.find("inputBorrowerType").get("v.value");
        }
        var mainEventId = component.get("v.recordId");
        var errorList = component.get("v.errorList");
        if(errorList.length == 0){
            console.log('account:' + JSON.stringify(selectedAccount));
            var action = component.get("c.saveRecord");
            action.setParams({accountString : JSON.stringify(selectedAccount), mainEventId:mainEventId, associateType:inputAssociateType, borrowerType:inputBorrowerType});
            action.setCallback(this,function(response){
                helper.toggleLoading(component);
                var state = response.getState();
                var returnVal =  response.getReturnValue();
                if(state === "SUCCESS"){
                    returnVal = JSON.parse(returnVal);
                    console.log('Save Resp:' + returnVal);
                    if(returnVal.result == 'ERROR') {
                        if(returnVal.errors != '' || returnVal.errors.length >0) {
                            component.set("v.errorList", returnVal.errors);
                            helper.showErrorList(component);
                        } else {
                            helper.showErrorMessage(component, returnVal.message);
                        }
                    } else {
                        if(isInterested && inputBorrowerType == 'Main Borrower') {
                            $A.get("e.force:closeQuickAction").fire();
                            helper.createEvent(returnVal.newEvent);
                        } else {
                            helper.navigateTo(returnVal.newEvent);
                            helper.showToast($A.get("$Label.c.Record_Created_Successfully"),'success');
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                }else {
                    console.log('state:' + state)   
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.toggleLoading(component);
            helper.showErrorList(component);
        }
    },
    validateInput : function(component,helper) {
        var errorList = [];
        var isErrorRequired = false;
        var requiredField = 'These required fields must be completed: ';
        var selectedAccount = component.get("v.selectedAccount");
        if(selectedAccount.Id == undefined) {
            requiredField += "Customer Name";
            isErrorRequired = true;
        }
        var mainEventId = component.get("v.recordId");
        if(mainEventId == undefined) errorList.push("Cannot read Page recordId");
        if(isErrorRequired) errorList.push(requiredField);
        console.log('selectedAccount:' + selectedAccount.Id);
        console.log('mainEventId:' + mainEventId);
        console.log('errorList:' + errorList);
        component.set("v.errorList", errorList);
    },
    showErrorList : function(component) {
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
    showErrorMessage : function(component,errorMsg) {
        component.set('v.isError',true);
        component.set('v.errorMessage',errorMsg);
    },
    hideErrorMessage : function(component) {
        component.set('v.isError',false);
        component.set('v.errorMessage','');
        component.set("v.errorList", {});
    },
    createEvent : function(newEvent) {
        console.log('newEvent:' + newEvent);
        var createEvent = $A.get("e.force:createRecord");
        createEvent.setParams({
            "entityApiName": "Event",
            "defaultFieldValues": {
                'Offer_Interest__c' : newEvent.Offer_Interest__c,
                'OwnerId' : newEvent.OwnerId,
                'Secondary_Call_Report__c' : newEvent.Secondary_Call_Report__c,
                'Offer_Credit_Product__c' : newEvent.Offer_Credit_Product__c,
                'Primary_Call_Report_Id__c' : newEvent.Primary_Call_Report_Id__c,
                'Visit_Objective__c' : newEvent.Visit_Objective__c,
                'StartDateTime' : newEvent.StartDateTime,
                'EndDateTime' : newEvent.EndDateTime,
                'WhatId' : newEvent.WhatId,
                'Borrower_Type__c' : newEvent.Borrower_Type__c,
                'RecordTypeId' : newEvent.RecordTypeId,
                'Status__c' : newEvent.Status__c,
                'Contact_Channel__c' : newEvent.Contact_Channel__c
            }
        });
        createEvent.fire();
    },
    navigateTo : function(newEvent) {
        console.log('newEvent:' + newEvent.Id);
        var navigateToSObject = $A.get("e.force:navigateToSObject");
        navigateToSObject.setParams({
            "recordId": newEvent.Id
        });
        navigateToSObject.fire();
    },
    toggleLoading: function(component) {
        var loadingOverlay = component.find('loadingOverlay');
        var hasHidden = $A.util.hasClass(loadingOverlay, 'hideEle');
        if(hasHidden){;
            $A.util.removeClass(loadingOverlay, 'hideEle')
        } else {
            $A.util.addClass(loadingOverlay, 'hideEle')
        }
    },
})