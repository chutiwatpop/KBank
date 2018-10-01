({
    showMessage: function(component,displayMsg){
        component.set('v.isLoading', false);
        component.set('v.displayMsg', displayMsg);
    },
    showToast: function(component, displayMsg, type) {
        let toastParams = {
            "mode"      : "dismissible",
            "duration"  : "5000",
            "message"   : displayMsg,
            "type"      : type
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    handleErrors : function(component, displayMsg) {
        var self = this;
        component.set('v.isLoading', false);
        component.set('v.isError', true);
        var UITheme = component.get("v.cmpTheme");
        if(UITheme == 'Theme4d'){
            self.showToast(component, displayMsg, "error");
        } else {
            self.showMessage(component, displayMsg);
        }
    },
    validateFraud : function(component) {
        var self = this;
        var action = component.get("c.getFraudStatus");
        var recordId = component.get("v.recordId");
        action.setParams({accountIdString : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal =  response.getReturnValue();
                var colorCode = returnVal.colorCode;
                if (colorCode == undefined || colorCode == '#0501ea') {
                    self.createRequest(component);
                } else if (colorCode == 'Other') {
                    self.showMessage(component, $A.get('$Label.c.FRAUD_ALERT'));
                } else {
                    component.set('v.colorGroup', colorCode);
                    component.set('v.isShowColor', true);
                    self.showMessage(component, 'ลูกค้าอยู่ใน Color Group ');
                }
            }else{
                self.handleErrors(component, returnVal.msg);
            }
        });
        $A.enqueueAction(action);
    },
    validateRequest : function(component) {
        console.log('validateRequest');
        component.set('v.isLoading', true);
        var self = this;
        var recordId = component.get("v.recordId");
        var actionValidate = component.get("c.validateRequestOwnership");
        actionValidate.setParams({accountIdString : recordId});
        actionValidate.setCallback(this,function(response){
            var state = response.getState();
            var returnVal =  response.getReturnValue();
            component.set('v.cmpTheme', returnVal.UITheme);
            if(state === "SUCCESS"){
                if(returnVal.success == true) {
                    component.set('v.mSegment', returnVal.msg);
                    if(returnVal.msg == 'RBS') {
                        self.showMessage(component, $A.get('$Label.c.RBS_Confirm_Request_Branch_Closeness'));
                    } else {
                        self.validateFraud(component);
                    }
                } else {
                    self.handleErrors(component, returnVal.msg);
                }
            }else{
                self.handleErrors(component, 'Failed to Create Ownership Request ' + returnVal.msg);
            }
        });
        $A.enqueueAction(actionValidate);
    },
    createRequest: function(component) {
        var self = this;
        var actionCreate = component.get("c.createRequestOwnership");
        var mSegment = component.get('v.mSegment');
        var recordId = component.get("v.recordId");
        var UITheme  = component.get("v.cmpTheme");
        actionCreate.setParams({accountIdString : recordId, userSegment:mSegment});
        actionCreate.setCallback(this,function(response){
            component.set('v.isLoading', false);
            var state = response.getState();
            var returnVal =  response.getReturnValue();
            if(state === "SUCCESS"){
                if(returnVal.success == true) {
                    if(returnVal.customerRequest == undefined) {
                        if(UITheme == 'Theme4d'){
                            var displayMsg = $A.get('$Label.c.RBS_Branch_Closeness_Updated');
                            self.showToast(component, displayMsg, "success");
                        } else {
                            self.showMessage(component, displayMsg);
                        }
                        $A.get('e.force:refreshView').fire();
                    } else {
                        self.navigateToCreateRecord(returnVal.customerRequest);
                    }
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    self.handleErrors(component, returnVal.msg);
                }
            } else {
                self.handleErrors(component, returnVal.msg);
            }
        });
        $A.enqueueAction(actionCreate);
    },
    navigateToCreateRecord : function(mRecord) {
        var mCreateRecord = $A.get("e.force:createRecord");
        mCreateRecord.setParams({
            "entityApiName": "Customer_Ownership_Request__c",
            "defaultFieldValues": {
                'Request_Type__c'   	: mRecord.Request_Type__c,
                'CIS_ID__c'         	: mRecord.CIS_ID__c,
                'OwnerID'           	: mRecord.OwnerID,
                'Requestor_TM__c'   	: mRecord.Requestor_TM__c,
                'Requestor_AH__c'   	: mRecord.Requestor_AH__c,
                'Requestor_NH__c'   	: mRecord.Requestor_NH__c,
                'Current_Owner__c'  	: mRecord.Current_Owner__c,
                'User_Admin__c'     	: mRecord.User_Admin__c,
                'RecordTypeId'      	: mRecord.RecordTypeId,
                'Request_Ownership_Type__c' : mRecord.Request_Ownership_Type__c,
                'Requestor__c'     :    mRecord.Requestor__c,
                'Approver__c'      :    mRecord.Approver__c,
                'Approver_Branch__c' :  mRecord.Approver_Branch__c
            }
        });
        mCreateRecord.fire();
    },
})