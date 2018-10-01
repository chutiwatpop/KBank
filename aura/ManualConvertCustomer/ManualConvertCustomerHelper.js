({
    convertCustomer : function(component, helper) {
        console.log('callWebservice');
        helper.toggleLoading(component);
        var customerObj = component.get("v.customerObj");
        var action = component.get("c.repairCustomerWithAccount");
        action.setParams({accountObj:JSON.stringify(customerObj)});
        action.setCallback(this,function(response){
            console.log('callBack');
            helper.toggleLoading(component);
            var state = response.getState();
            var returnVal =  response.getReturnValue();
            if(state === "SUCCESS"){
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'ERROR') {
                    helper.showErrorMessage(component, returnVal.message);
                } else {
                    // $A.get("e.force:closeQuickAction").fire();
                    if(returnVal.convertedCustomer != undefined && returnVal.convertedCustomer != null) {
                        helper.showToast('Success', 'success');
                    } 
                }
            }else{
                console.log('state not SUCCESS!!');
            }
        });
        $A.enqueueAction(action);
    },
    toggleLoading: function(component) {
        var loadingOverlay = component.find('loadingOverlay');
        var hasHidden = $A.util.hasClass(loadingOverlay, 'hideEle');
        if(hasHidden){
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
    showErrorMessage : function(component,errorMsg) {
        component.set('v.isError',true);
        component.set('v.errorMessage',errorMsg);
    },
    hideErrorMessage : function(component) {
        component.set('v.isError',false);
        component.set('v.errorMessage','');
    },
    resetValue : function(component){
        component.set("v.checkExistCustomer",false);
        component.set("v.isCustomerExist",false);
    },
    searchCustomer : function(component,helper,msg){
        console.log(msg);
        helper.toggleLoading(component);
        var searchCustomerAction = component.get("c.searchCustomerByCriteria");
        let birthDate = component.get("v.inputDOBValue");
        let identification = component.get("v.inputIdentificationValue");
        let cisNumber = component.get("v.inputCISValue");
        helper.hideErrorMessage(component);
        if(msg == 'validByCISNumber'){
            searchCustomerAction.setParams({
                cisNumber:cisNumber
            });
        }else if(msg == 'validByIdent'){
            searchCustomerAction.setParams({
                identification:identification,
                birthDateStr:birthDate
            });            
        }
        searchCustomerAction.setCallback(this, function(response){
            helper.toggleLoading(component);
            console.log('searchCustomer');
                var result = response.getReturnValue();
                if(result != null){
                    result = JSON.parse(result);
                    component.set("v.checkExistCustomer",true);
                    if(result.convertedCustomer != null){
                        component.set("v.isCustomerExist",true);
                        component.set("v.customerObj",result.convertedCustomer);
                        if(component.get("v.customerObj.Customer_Type_Code__c") == 'I'){
                            component.set("v.customerTypeShow","Individual");
                        }else if(component.get("v.customerObj.Customer_Type_Code__c") == 'O'){
                            component.set("v.customerTypeShow","Organization");
                        }
                        if(result.convertedCustomer.CIS__c == null || result.convertedCustomer.CIS__c == ''){
                            helper.showErrorMessage(component,'Warning : CIS is null');
                        }else if(result.message !== 'undefined' && result.message != '' && result.message != null){
                            helper.showErrorMessage(component,'Warning : '+result.message);
                        }                        
                    }else{
                        component.set("v.isCustomerExist",false);
                    }
                }else{
                    component.set("v.checkExistCustomer",true);
                    component.set("v.isCustomerExist",false);
                }
        });
        $A.enqueueAction(searchCustomerAction);
    },
    clearSearchResult : function(component){
        component.set('v.customerObj',{
            'sobjectType':'Account',
            'CIS__c':'',
            'Birthdate_Registration_Date__c':'',
            'Salutation':'',
            'Encrypt_Title_TH__c':'',
            'Encrypt_Title_EN__c':'',
            'Customer_Type_Code__c':'',
            'Encrypt_Identification_No__c':'',
            'Customer_Status__c':'',
            'Status__c':'',
            'Customer_Segment_Code__c':'',
            'Primary_Segment_Code__c':'',
            'Customer_s_Business_Code__c':'',
            'Industry_Classification_Code__c':''
        });
    }
})