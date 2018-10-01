({
	doInit: function(component, event, helper) {
        helper.toggleLoading(component);
        component.set('v.disableSaveButton', true);
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")){
            var height = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
            var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
            var pageStyle = "";
            height = height - 60;
            pageStyle = "height:" + height + "px;width:" + width + "px;max-width: none;margin-bottom:60px;";
            component.set('v.pageStyle', pageStyle);
            component.set('v.containerStyle', "overflow-y: auto;");
        }
        
        var recordId = component.get('v.recordId');
        var getFormAction = component.get('c.getForm');
        getFormAction.setParams({
            "recordId": recordId
        });
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            var form = response.getReturnValue();
            if(state === "SUCCESS" && !form.isError) {
                /*if((form.Fields.section1 == null || form.Fields.section1 == undefined) && 
                   (form.Fields.section2 == null || form.Fields.section2 == undefined) &&
                   (form.Fields.section3 == null || form.Fields.section3 == undefined)) {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "mode": "dismissible",
                        "message": "Can't open edit page.",
                        "type": "error",
                        "duration": "5000"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    
                    helper.closeTabWithoutRefresh(component);
                }*/
                
                if(form.Fields.section1 != null && form.Fields.section1 != undefined) {
                    component.set('v.fieldSection1', form.Fields.section1);
                }
                if(form.Fields.section2 != null && form.Fields.section2 != undefined) {
                    component.set('v.fieldSection2', form.Fields.section2);
                }
                if(form.Fields.section3 != null && form.Fields.section3 != undefined) {
                    component.set('v.fieldSection3', form.Fields.section3);
                }
                component.set('v.opportunityProduct', form.Record);
                if(form.Application != null && form.Application != undefined) {
                    component.set('v.applicationHistory', form.Application);
                }
                if(form.Job != null && form.Job != undefined) {
                    component.set('v.job', form.Job);
                }
                if(form.Product != null && form.Product != undefined) {
                    component.set('v.product', form.Product);
                }
                if(form.CreatedBy != null && form.CreatedBy != undefined) {
                    component.set('v.createBy', form.CreatedBy);
                }
                if(form.LastModifiedBy != null && form.LastModifiedBy != undefined) {
                    component.set('v.lastModifiedBy', form.LastModifiedBy);
                }
                component.set('v.productResultList', helper.subNumberSort(form.ProductResultList,'Label',false));
                component.set('v.reasonList', helper.sortReasonList(form.ReasonList,true));
                //console.log('fieldList: %O', form.Fields);
                //console.log('applicationHistory: %O', form.Application);
                helper.getConfigForm(component, 'fieldSection1', 'componentSection1');
                helper.getConfigForm(component, 'fieldSection2', 'componentSection2');
                helper.getConfigForm(component, 'fieldSection3', 'componentSection3');
                component.set('v.disableSaveButton', false);
            } else {
                helper.showErrorPanel(component);
                if(state === "SUCCESS") {
                    component.set('v.errorMessage', form.ErrorText);
                } else {
                    var errors = response.getError();
                    if(errors) {
                        var errorList = [];
                        for(var i = 0; i < errors.length; i++) {
                            errorList.push(errors[i].message);
                        }
                        component.set('v.errorList', errorList);
                    } else {
                        component.set('v.errorMessage', "Unknown error");
                    }
                }
            }
            helper.toggleLoading(component);
            
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                component.set('v.tabId', response.tabId);
            })
            .catch(function(error) {
                console.log('Problem doInit > getFocusedTabInfo, Message:' + error);
            });
            
            var compList =document.getElementsByClassName("cEditOpportunityProduct");
            var comp = compList.item(compList.length-1);
            if(comp != undefined){
                comp.ontouchmove =  function(e) {
                    e.stopPropagation();
                }
            }
        });
        $A.enqueueAction(getFormAction);
	},
    doRender: function(component, event, helper) {
        var childCmp = component.find('Application__c');
        var isNotSetCustomLookup = component.get('v.isNotSetCustomLookup');
        if(isNotSetCustomLookup && childCmp) {
            component.set('v.isNotSetCustomLookup', false);
            childCmp.oSelectedRecordMethod('Application_History__c', component.get('v.applicationHistory'));
        }
        //waiting for migrate
        var childCmpCBS = component.find('Application_CBS__c');
        var isNotSetCustomLookupCBS = component.get('v.isNotSetCustomLookupCBS');
        if(isNotSetCustomLookupCBS && childCmpCBS) {
            component.set('v.isNotSetCustomLookupCBS', false);
            childCmpCBS.oSelectedRecordMethod('Application_History__c', component.get('v.applicationHistory'));
        }
        //end
    },
    handleTabClosed: function(component, event, helper) {
        var closedTabId = event.getParam('tabId');
        var tabId = component.get('v.tabId');
        if(tabId == closedTabId) {
            //console.log("tabId:" + tabId + ", closedTabId:" + closedTabId);
            var newAppHistIdList = component.get('v.newAppHistIdList');
            if(newAppHistIdList.length > 0) {
                var clearNewAppAction = component.get('c.clearNewApplicationHistory');
                clearNewAppAction.setParams({
                    "newIdList": newAppHistIdList
                });
                clearNewAppAction.setCallback(this, function(response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if(state === "SUCCESS" && result.isSuccess) {
                        console.log("clear new application history success.");
                    } else {
                        var errorMessage = "";
                        if(state === "SUCCESS") {
                            errorMessage = result.message;
                        } else {
                            var errors = response.getError();
                            if(errors) {
                                for(var i = 0; i < errors.length; i++) {
                                    errorMessage = errorMessage + "\n" + errors[i].message;
                                }
                            }
                        }
                        console.log("Problem handleCancel, Message:" + errorMessage);
                    }
                });
                $A.enqueueAction(clearNewAppAction);
            }
        }
    },
    handleSave : function(component, event, helper) {
        helper.toggleLoading(component);
        helper.hideErrorPanel(component);
        component.set('v.disableSaveButton', true);
        var opportunityProduct = component.get("v.opportunityProduct");
        var applicationHistory = component.get('v.applicationHistory');
        var saveAction = component.get('c.save');
        saveAction.setParams({
            "opportunityProduct": opportunityProduct,
            "applicationHistory": applicationHistory
        });
        saveAction.setCallback(this, function(response) {
            component.set('v.isError', false);
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS" && result.isSuccess) {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "mode": "dismissible",
                    "message": "Save Opportunity Product Success.",
                    "type": "success",
                    "duration": "5000"
                });
                resultsToast.fire();
                component.set('v.newAppHistIdList', []);
                helper.closeTabWithRefresh(component);
            } else {
                helper.showErrorPanel(component);
                if(state === "SUCCESS") {
                    component.set('v.errorMessage', result.message);
                } else {
                    var errors = response.getError();
                    if(errors) {
                        var errorList = [];
                        for(var i = 0; i < errors.length; i++) {
                            errorList.push(errors[i].message);
                        }
                        component.set('v.errorList', errorList);
                    }
                }
            }
            helper.toggleLoading(component);
            component.set('v.disableSaveButton', false);
        });
        if(helper.validateInput(component, helper)) {
            $A.enqueueAction(saveAction);
        } else {
            helper.toggleLoading(component);
            component.set('v.disableSaveButton', false);
        }
    },
    handleCancel : function(component, event, helper) {
        var newAppHistIdList = component.get('v.newAppHistIdList');
        if(newAppHistIdList.length > 0) {
            helper.toggleLoading(component);
            helper.hideErrorPanel(component);
            component.set('v.disableSaveButton', true);            
            var clearNewAppAction = component.get('c.clearNewApplicationHistory');
            clearNewAppAction.setParams({
                "newIdList": newAppHistIdList
            });
            clearNewAppAction.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if(state === "SUCCESS" && result.isSuccess) {
                    console.log("clear new application history success.");
                } else {
                    var errorMessage = "";
                    if(state === "SUCCESS") {
                        errorMessage = result.message;
                    } else {
                        var errors = response.getError();
                        if(errors) {
                            for(var i = 0; i < errors.length; i++) {
                                errorMessage = errorMessage + "\n" + errors[i].message;
                            }
                        }
                    }
                    console.log("Problem handleCancel, Message:" + errorMessage);
                }
                component.set('v.newAppHistIdList', []);
                helper.toggleLoading(component);
                helper.closeTabWithoutRefresh(component);
            });
            $A.enqueueAction(clearNewAppAction);
        } else {
            helper.closeTabWithoutRefresh(component);
        }
	},
    handleNewApplication : function(component, event, helper) {
        //console.log('handleNewApplication');
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")) {
            var compList =document.getElementsByClassName("cEditOpportunityProduct");
            var comp = compList.item(compList.length-1);
            comp.style.overflowY = "";
            if(comp.parentElement && comp.parentElement.innerHTML) {
                comp.parentElement.ontouchmove =  function(e) { }
                comp.ontouchmove =  function(e) {
                    e.stopPropagation();
                }
            }
            /*if($A.get("$Browser.isIOS")) {
                comp.ontouchmove =  function(e) { }
            } else {
                comp.parentElement.ontouchmove =  function(e) { }
            }*/
        } else {
            document.body.style.overflow = "";
        }
        component.set('v.isOpenNewAppModal', false);
        
        var params = event.getParam("params");
        //console.log('params:' + params.data.isNewApplication);
        if(params.data.isNewApplication) {
            var newId = component.get('v.applicationHistory.Id');
            var newAppHistIdList = component.get('v.newAppHistIdList');
            newAppHistIdList.push(newId);
            component.set('v.newAppHistIdList', newAppHistIdList);
            //helper.setAppHistQueryCondition(component);
            helper.setApplication(component, helper);
        }
    },
    handleSelectedApplication : function(component, event, helper) {
        //console.log('handleSelectedApplication');
        //var selectedObjectFromEvent = event.getParam("recordByEvent");
        //console.log('selectedObjectFromEvent:' + selectedObjectFromEvent.Id);
    },
    handleNewRecord : function(component, event, helper) {
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")) {
            var compList =document.getElementsByClassName("cEditOpportunityProduct");
            var comp = compList.item(compList.length-1);
            comp.style.overflowY = "hidden";
            if(comp.parentElement && comp.parentElement.innerHTML) {
                comp.ontouchmove =  function(e) { }
                comp.parentElement.style.transform = "translate3d(0px, 0px, 0px)";
                comp.parentElement.ontouchmove =  function(e) {
                    var compList =document.getElementsByClassName("cEditOpportunityProduct");
                    var comp = compList.item(compList.length-1);
                    comp.parentElement.style.transform = "translate3d(0px, 0px, 0px)";
                    e.stopPropagation();
                }
            }
            /*if($A.get("$Browser.isIOS")) {
                comp.style.transform = "translate3d(0px, 0px, 0px)";
                comp.ontouchmove =  function(e) {
                    e.stopPropagation();
                }
            } else {
                comp.parentElement.style.transform = "translate3d(0px, 0px, 0px)";
                comp.parentElement.ontouchmove =  function(e) {
                    var compList =document.getElementsByClassName("cEditOpportunityProduct");
                    var comp = compList.item(compList.length-1);
                    comp.parentElement.style.transform = "translate3d(0px, 0px, 0px)";
                    e.stopPropagation();
                }
            }*/
        } else {
            document.body.style.overflow = "hidden";
        }
        var jobId = component.get('v.opportunityProduct.OpportunityId');
        component.set('v.applicationHistory.OppName__c', jobId);
        component.set('v.isOpenNewAppModal', true);
    },
    onProductResultChange: function(component, event, helper) {
        component.set('v.opportunityProduct.Reasons__c', '');
        component.set('v.requiredReason', '');
        component.set('v.requiredRemark', '');
        var reasonComponent = component.find('Reasons__c');
        var remarkComponent = component.find('Remark__c');
        reasonComponent.set("v.errors", []);
        remarkComponent.set("v.errors", []);
        
        var productResult = component.get('v.opportunityProduct.Product_Results__c');
        var productResultList = component.get('v.productResultList');
        for (var j = 0; j < productResultList.length; j++) {
            if(productResult == productResultList[j].Label) {
                component.set('v.requiredReason', productResultList[j].requiredReason);
                component.set('v.requiredRemark', productResultList[j].requiredRemark);
                break;
            }
        }
        
        var opts = helper.getReasonsPicklistItem(component, helper);
        if(opts.length > 1) {
            component.set('v.disableReasonsPicklist', false);
            component.set('v.optionsReasonsPicklist', opts);
        } else {
            component.set('v.disableReasonsPicklist', true);
        }
    },
    onReasonChange: function(component, event, helper) {
        component.set('v.requiredRemark', '');
        var remarkComponent = component.find('Remark__c');
        remarkComponent.set("v.errors", []);
        
        var productResult = component.get('v.opportunityProduct.Product_Results__c');
        var reason = component.get('v.opportunityProduct.Reasons__c');
        var reasonListMap = component.get('v.reasonList');
        
        if(reason) {
            var reasonList = [];
            if(reasonListMap.hasOwnProperty(productResult)) {
                reasonList = reasonListMap[productResult];
            }
            for (var j = 0; j < reasonList.length; j++) {
                if(reason == reasonList[j].Label) {
                    component.set('v.requiredRemark', reasonList[j].requiredRemark);
                    break;
                }
            }
            
            if(reasonList.length < 1) {
                component.set('v.disableReasonsPicklist', true);
            }
        } else {
            var productResultList = component.get('v.productResultList');
            for (var j = 0; j < productResultList.length; j++) {
                if(productResult == productResultList[j].Label) {
                    component.set('v.requiredRemark', productResultList[j].requiredRemark);
                    break;
                }
            }
        }
    }
})