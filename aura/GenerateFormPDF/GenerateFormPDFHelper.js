({  
    toggleLoading: function(component) {
        var loadingOverlay = component.find('loadingOverlay');
        var hasHidden = $A.util.hasClass(loadingOverlay, 'hideEle');
        if(hasHidden){;
            $A.util.removeClass(loadingOverlay, 'hideEle')
        } else {
            $A.util.addClass(loadingOverlay, 'hideEle')
        }
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
    validatePermission : function(component, helper) {
        helper.toggleLoading(component);
        var selectedForm = component.find("inputFormName").get("v.value");
        var recordId = component.get("v.recordId");
        var action = component.get("c.validatePermission");
        console.log('recordId:' + recordId);
        action.setParams({accountId:recordId, formName:selectedForm});
        action.setCallback(this,function(response){
            helper.toggleLoading(component);
            var state = response.getState();
            var returnVal =  response.getReturnValue();
            if(state === "SUCCESS"){
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'ERROR') {
                    helper.showToast(returnVal.message,'error');
                } else {
                    helper.createHistory(component,helper);
                }
            }else{
                console.log('Error!! validatePermission');
            }
        });
        $A.enqueueAction(action);
    },
    actionNext : function(component, helper) {
        helper.validatePermission(component, helper);
    },
    getFormList : function(component, helper) {
        helper.toggleLoading(component);
        var action = component.get("c.getFormNameList");
        action.setCallback(this,function(response){
            helper.toggleLoading(component);
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                console.log('getFormList:' + returnVal);
                if(returnVal && returnVal.length > 0) {
                    component.set("v.formList", returnVal);
                    component.set("v.selectedForm", returnVal[0]);
                    console.log('returnVal[0]:' + returnVal[0]);
                }
            }else{
                console.log('Error!! getFormList');
            }
        });
        $A.enqueueAction(action);
    },
    createHistory: function(component, helper) {
        helper.toggleLoading(component);
        var selectedForm = component.find("inputFormName").get("v.value");
        var recordId = component.get("v.recordId");
        var action = component.get("c.createHistory");
        action.setParams({accountId:recordId, formName:selectedForm});
        action.setCallback(this,function(response){
            helper.toggleLoading(component);
            var state = response.getState();
            var returnVal =  response.getReturnValue();
            if(state === "SUCCESS"){
                returnVal = JSON.parse(returnVal);
                console.log('createHistory:' + returnVal);
                if(returnVal.result == 'ERROR') {
                    helper.showToast(returnVal.message,'error');
                } else {
                    helper.gotoURL(component, helper);
                }
            }else{
                console.log('Error!! createHistory');
            }
        });
        $A.enqueueAction(action);
    },
    gotoURL: function(component, helper) {
        var inputFormName = component.find("inputFormName").get("v.value");
        var recordId = component.get("v.recordId");
        var urlString ="/apex/" + inputFormName + "?id=" + recordId;
        window.open(urlString,'_blank');
    },
})