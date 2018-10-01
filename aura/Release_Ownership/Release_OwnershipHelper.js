({
    showMessage: function(component, displayMsg) {
        component.set('v.displayMsg', displayMsg);
    },
    showToast: function(component, displayMsg) {
        let toastParams = {
            "mode"      : "dismissible",
            "duration"  : "5000",
            "title"     : "Error",
            "message"   : displayMsg,
            "type"      : "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    handleErrors : function(component, displayMsg) {
        var self = this;
        component.set('v.isError', true);
        var UITheme = component.get("v.cmpTheme");
        if(UITheme == 'Theme4d'){
            self.showToast(component, displayMsg);
        } else {
            self.showMessage(component, displayMsg);
        }
    },
    validateReleaseOwnership: function(component){
        var self = this;
        var recordId = component.get("v.recordId");
        var actionValidateReleaseOwnership = component.get("c.validateReleaseOwnership");
        actionValidateReleaseOwnership.setParams({accountId : recordId});
        actionValidateReleaseOwnership.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.UITheme) {
                    component.set('v.cmpTheme', result.UITheme);
                }
                if(result.success == true) {
                    component.set('v.releaseSegment', result.msg);
                    if(result.msg == 'RBS') {
                        component.set('v.showConfirm', true);
                        self.showMessage(component, $A.get('$Label.c.RBS_Confirm_Release_Branch_Closeness'));
                    } else {
                        self.showMessage(component, 'Loading');
                        self.gotoURL(component, result.msg);
                    }
                } else {
                    component.set('v.showConfirm', true);
                    self.handleErrors(component,result.msg);
                }
            }else{
                component.set('v.showConfirm', true);
                self.handleErrors(component,state);
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(actionValidateReleaseOwnership);
    },
    handleUserSegment: function(component, releaseSegment) {
        var self = this;
        if(releaseSegment == 'RBS') {
            self.createRequest(component);
        } else {
            self.gotoURL(component, releaseSegment);
        }
    },
    createRequest: function(component) {
        var self = this;
        var recordId = component.get("v.recordId");
        var actionCreateRequest = component.get("c.createCustomerOwnershipRequest");
        actionCreateRequest.setParams({accountId : recordId});
        actionCreateRequest.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.success == true) {
                    self.createNewRequest(result.customerRequest);
                } else {
                    self.handleErrors(component,result.msg);
                }
            }else{
                self.handleErrors(component,state);
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(actionCreateRequest);
    },
    gotoURL: function (component, releaseSegment) {
    	var recordId = component.get("v.recordId");
    	// var releaseSegment = component.get("v.releaseSegment");
	    var urlEvent = $A.get("e.force:navigateToURL");
	    if(releaseSegment == 'SME') {
	    	urlEvent.setParams({
		      "url": "/apex/Account_ReferOutInformation_Page?cisID="+recordId
		    });
	    } else if(releaseSegment == 'CBS') {
	    	urlEvent.setParams({
		      "url": "/apex/Account_ReferOutInformation_CBS_Page?cisID="+recordId
		    });
	    }
	    var recordId = component.get("v.recordId");
	    urlEvent.fire();
	},
    createNewRequest : function(newRequest) {
        var createNewOwnershipRequest = $A.get("e.force:createRecord");
        createNewOwnershipRequest.setParams({
            "entityApiName": "Customer_Ownership_Request__c",
            "defaultFieldValues": { 
                'User_Admin__c'    :  newRequest.User_Admin__c,
                'Request_Type__c'  :  newRequest.Request_Type__c,
                'CIS_ID__c'        :  newRequest.CIS_ID__c,
                'OwnerID'          :  newRequest.OwnerID,
                'RecordTypeId'     :  newRequest.RecordTypeId,
                'Requestor__c'     :  newRequest.Requestor__c,
                'Requestor_TM__c'  :  newRequest.Requestor_TM__c,
                'Approver__c'      :  newRequest.Approver__c,
                'Approver_Branch__c'  :  newRequest.Approver_Branch__c
            }
        });
        createNewOwnershipRequest.fire();
    },
})