({
    configMap: {
        'anytype': { componentDef: 'ui:inputText', attributes: {} },
        'base64': { componentDef: 'ui:inputText', attributes: {} },
        'boolean': {componentDef: 'ui:inputCheckbox', attributes: {} },
        'combobox': { componentDef: 'ui:inputText', attributes: {} },
        'currency': { componentDef: 'ui:inputText', attributes: {} },
        'datacategorygroupreference': { componentDef: 'ui:inputText', attributes: {} },
        'date': {
            componentDef: 'ui:inputDate',
            attributes: {
                displayDatePicker: true,
                format: 'MM/dd/yyyy'
            }
        },
        'datetime': { componentDef: 'ui:inputDateTime', attributes: {} },
        'double': { componentDef: 'ui:inputNumber', attributes: {} },
        'email': { componentDef: 'ui:inputEmail', attributes: {} },
        'encryptedstring': { componentDef: 'ui:inputText', attributes: {} },
        'id': { componentDef: 'ui:inputText', attributes: {} },
        'integer': { componentDef: 'ui:inputNumber', attributes: {} },
        'multipicklist': { componentDef: 'ui:inputSelect', attributes: {multiple:"true"} },
        'percent': { componentDef: 'ui:inputNumber', attributes: {} },
        'phone': { componentDef: 'ui:inputPhone', attributes: {} },
        'picklist': { componentDef: 'ui:inputSelect', attributes: {} },
        'reference': { componentDef: 'ui:inputText', attributes: {} },
        'string': { componentDef: 'ui:inputText', attributes: {} },
        'textarea': { componentDef: 'ui:inputText', attributes: {} },
        'time': { componentDef: 'ui:inputDateTime', attributes: {} },
        'url': { componentDef: 'ui:inputText', attributes: {} },
        'output': { componentDef: 'ui:outputText', attributes: {} },
        'lookup': { componentDef: 'c:CustomLookup', attributes: {} }
    },
    handleNewApplicationModal : function(component, isClosed) {
        var oppProductWrapper = component.get('v.oppProductWrapper');
        var newApplicationId;
        if(isClosed && oppProductWrapper.application) {
            newApplicationId = oppProductWrapper.application.Id;
        }
        console.log('handleNewApplicationModal');
        var compEvent = component.getEvent('handleNewApplicationModal');
        compEvent.setParams({
            dmltype: "new_application",
            params: {
                newApplicationId : newApplicationId,
                isClosedModal : isClosed
            }
        });
        compEvent.fire();
    },
    setOppLineItemField : function(component, event) {
        var componentId     = event.getSource().getLocalId();
        var newValue        = event.getSource().get('v.value');
        var oppProductWrapper = component.get('v.oppProductWrapper');
        if(newValue == null || newValue == undefined || newValue == ''){
            oppProductWrapper.oppLineItem[componentId] = null;
        }else{
            oppProductWrapper.oppLineItem[componentId] = newValue;
        }
        component.set('v.oppProductWrapper', oppProductWrapper);

        if(componentId == 'Remark__c' && oppProductWrapper.oppLineItem.requiredRemark) {
            var productRemarkComp = component.find('Remark__c');
            if(newValue.trim().length > 0) {
                $A.util.removeClass(productRemarkComp, 'has-required');
            } else {
                $A.util.addClass(productRemarkComp, 'has-required');
            }
        }

        console.log('Set Field:' + componentId);
        console.log('newValue:' + newValue);
    },
    setApplication : function(component, helper) {
        console.log('setApplication');
        var oppProductWrapper   = component.get('v.oppProductWrapper');
        var applicationComp     = component.find('Application__c');
        var applicationCBSComp  = component.find('Application_CBS__c');
        oppProductWrapper.oppLineItem.Application__c = null;
        oppProductWrapper.oppLineItem.Application_CBS__c = null;
        if(applicationComp) {
            applicationComp.oSelectedRecordMethod('Application_History__c', oppProductWrapper.application);
            oppProductWrapper.oppLineItem.Application__c      = oppProductWrapper.application.Id;
        } else if(applicationCBSComp) {
            applicationCBSComp.oSelectedRecordMethod('Application_History__c', oppProductWrapper.application);
            oppProductWrapper.oppLineItem.Application_CBS__c  = oppProductWrapper.application.Id;
        } else {
            console.log('Cannot find application field');
        }
    },
    handleInit : function(component) {
        var compEvent = component.getEvent('handleInitRow');
        compEvent.setParams({
            "dmltype": "success_initial",
            "params": {
                data: {initial: true}
            }
        });
        compEvent.fire();
    },
    createInputForm: function(component, helper, initialComponent) {
        console.log('createInputForm');
        var jobId             = component.get('v.jobId');
        var oppProductWrapper = component.get('v.oppProductWrapper');

        if(!oppProductWrapper.Product2) {
            oppProductWrapper.Product2 = initialComponent.existingProduct;
        }
        if(initialComponent.existingApplication) {
            oppProductWrapper.isExistingApp = true;
            oppProductWrapper.application = initialComponent.existingApplication;
        }

        var selectedProduct = oppProductWrapper.Product2;
        var oppLineItem     = oppProductWrapper.oppLineItem;
        var fields          = initialComponent.fields;
        
        component.set('v.oppProductWrapper', oppProductWrapper);
        component.set('v.fields', fields);
        for (var colIndex = 0; colIndex < fields.length; colIndex++) {
            var inputDesc = [];
            var eachField = fields[colIndex];
            var type = eachField.Type.toLowerCase();
            var configTemplate = this.configMap[type];

            if(eachField.APIName == 'Product2Id') {
                configTemplate = this.configMap['output'];
            } else if(eachField.APIName == 'Application__c' || eachField.APIName == 'Application_CBS__c') {
                configTemplate = this.configMap['lookup'];
            }

            if(eachField.isManualPicklist) configTemplate = this.configMap['picklist'];
            if (!configTemplate) {
                console.log('type ${ type } not supported');
                continue;
            }
            
            var config = JSON.parse(JSON.stringify(configTemplate));
            config.attributes.required = eachField.Required;
            var onChangeField = component.getReference("c.onChangeField");
            config.attributes['change'] = onChangeField;

            if(eachField.isManualPicklist) {
                if(eachField.APIName == 'Product_Results__c') {
                    var onChangeProductResult = component.getReference("c.onChangeProductResult");
                    var opts = [{value:'',label:'-- None --'}];
                    config.attributes['options'] = opts;
                    config.attributes['change'] = onChangeProductResult;
                } else if(eachField.APIName == 'Reasons__c') {
                    config.attributes['disable'] = true;
                    var onChangeReason = component.getReference("c.onChangeReason");
                    config.attributes['change'] = onChangeReason;
                    config.attributes['options'] = [];
                }
            } else if(eachField.isPicklist) {
                var opts = [];
                if(!oppLineItem[eachField.APIName]) {
                    oppLineItem[eachField.APIName] = eachField.DefaultValue;
                }
                console.log('eachField.DefaultValue:' + eachField.DefaultValue);
                for (var key in eachField.picklistValues) {
                    if (eachField.picklistValues.hasOwnProperty(key)) {
                        console.log('eachField.picklistValues:' + eachField.picklistValues[key]);
                        var isSelected = false;
                        if(oppLineItem[eachField.APIName] == eachField.picklistValues[key]){
                            isSelected = true;
                        }
                        opts.push({class: "optionClass",value: key, label: eachField.picklistValues[key], selected : isSelected});
                    }
                };
                config.attributes['options'] = opts;
            } else {
                if(eachField.APIName == 'Application__c' || eachField.APIName == 'Application_CBS__c') {
                    // Custom Lookup
                    config.attributes['objectAPIName']  = 'Application_History__c';
                    config.attributes['IconName']       = 'custom:custom51';
                    config.attributes['canNewRecord']   = true;
                    config.attributes['newRecordLabel'] = 'New Application';
                    config.attributes['selectedRecord'] = initialComponent.existingApplication;
                    config.attributes['queryField']     = "Id, Name, App_Num_Selected__c"
                    config.attributes['queryCondition'] = 'OppName__c = \'' + jobId + '\'';
                    config.attributes['primaryFieldAPIName']    = 'Name';
                    config.attributes['secondaryFieldAPIName']  = 'App_Num_Selected__c';
                }
            }
            // Set Value handle edit mode
            if(eachField.APIName == 'Product2Id'){
                config.attributes.value = selectedProduct.Name;
            } else if(oppLineItem[eachField.APIName]) {
                config.attributes.value = oppLineItem[eachField.APIName];
            } else {
                config.attributes.value = '';
            }
            
            config.attributes.fieldPath     = eachField.APIName;
            config.attributes['aura:id']    = eachField.APIName;
            
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);

            helper.createComponent(component, helper, inputDesc, colIndex);
        }
    },

    createComponent: function(component, helper, inputDesc, index) {
        $A.createComponents(inputDesc, function(cmps, status, errorMessage) {
            if(status === "SUCCESS") {
                var tableBody = component.get("v.tableBody");
                tableBody[index] = cmps;
                component.set('v.tableBody', tableBody);
                helper.setApplication(component, helper);
            } else {
                console.log("Status:" + status + " " + index + " No response from server or client is offline.");
            }
        });
    },

    getProductSettings : function(component, helper) {
        var oppProductWrapper = component.get('v.oppProductWrapper');
        var productCode       = oppProductWrapper.Product2.Product_Code__c;
        console.log('getProductSettings:' + productCode);
        if(productCode && productCode.trim() != '') {
            var action = component.get("c.getProductSettings");
            action.setParams({productCode : productCode});
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    var resp = response.getReturnValue();
                    component.set('v.isLoading', false);
                    if (state === "SUCCESS") {
                        component.set('v.productSettings', resp);
                        helper.getProductResults(component, helper, resp);
                    } else {
                        console.log('Error!');                
                    }
                }
            );   
            $A.enqueueAction(action); 
        }
    },
    getProductResults : function(component, helper, productSettings) {
        var oppProductWrapper = component.get('v.oppProductWrapper');
        var oppLineItem         = oppProductWrapper.oppLineItem;
        var productResultComp   = component.find('Product_Results__c');        
        var optionsList = [{value:'',label:'-- None --'}];
        var productResults = [];
        for (var pIndex = 0; pIndex < productSettings.length; pIndex++) {
            var eachSetting = productSettings[pIndex];
            if(eachSetting.ProductResult_Product_Result__c && eachSetting.ProductResult_Product_Result__c.trim() != '' && productResults.indexOf(eachSetting.ProductResult_Product_Result__c) == -1) {
                productResults.push(eachSetting.ProductResult_Product_Result__c);
            }
        }
        productResults = this.mSort(productResults,false);
        for (var pIndex = 0; pIndex < productResults.length; pIndex++) {
            var eachResult = productResults[pIndex];
            var isSelected = (oppLineItem.Product_Results__c == eachResult);
            optionsList.push({value: eachResult, label: eachResult, selected : isSelected});
        }
        productResultComp.set('v.options', optionsList);
        helper.getProductReasons(component, helper);
    },
    getProductReasons : function(component, helper) {
        var oppProductWrapper   = component.get('v.oppProductWrapper');
        var oppLineItem         = oppProductWrapper.oppLineItem;
        var productCode         = oppProductWrapper.Product2.Product_Code__c;
        var productSettings     = component.get('v.productSettings');
        var productResultComp   = component.find('Product_Results__c');
        var productReasonComp   = component.find('Reasons__c');
        var productRemarkComp   = component.find('Remark__c');
        var productResult       = productResultComp.get('v.value');
        $A.util.removeClass(productRemarkComp, 'has-required');
        $A.util.removeClass(productReasonComp, 'has-required');
        oppLineItem.requiredReason = false;
        oppLineItem.requiredRemark = false;
        var optionsList = [{value:'',label:'-- None --'}];
        if(productResult && productResult.trim() != '') {
            var productReasons = [];
            for(var pIndex = 0; pIndex < productSettings.length; pIndex++) {
                var eachSetting = productSettings[pIndex];
                if(eachSetting.ProductResult_Product_Result__c == productResult) {
                    // Set required reason
                    var isRequired = (eachSetting.ProductResult_Require_Reason__c == true);
                    if(isRequired) {
                        $A.util.addClass(productReasonComp, 'has-required');
                        productReasonComp.set('v.required', isRequired);
                        oppLineItem.requiredReason = isRequired;
                    }
                        
                    if(eachSetting.ProductResult_Reason__c && eachSetting.ProductResult_Reason__c.trim() != '' && productReasons.indexOf(eachSetting.ProductResult_Reason__c) == -1) {
                        productReasons.push(eachSetting.ProductResult_Reason__c);
                    }
                }
            }
            if(productReasons.length > 0) {
                productReasons = this.mSort(productReasons,true);
                for(var pIndex = 0; pIndex < productReasons.length; pIndex++) {
                    var eachReason = productReasons[pIndex];
                    var isSelected = (oppLineItem.Reasons__c == eachReason);
                    optionsList.push({value: eachReason, label: eachReason, selected : isSelected});
                }
            } else {
                oppLineItem.Reasons__c = '';
            }
        }
        productReasonComp.set('v.options', optionsList);
        oppProductWrapper.oppLineItem = oppLineItem;
        component.set('v.oppProductWrapper', oppProductWrapper);
        helper.getRequiredField(component, helper);
    },

    mSort : function(productReasons,hasDeciaml) {
        var mSize = productReasons.length;
        for (var i = mSize-1; i >= 0; i--){
            for(var j = 1; j <= i; j++){
                var varLeft,varRight;
                if(hasDeciaml){
                    varLeft = parseInt(productReasons[j-1].split(" ")[0].split(".")[1]);
                    varRight = parseInt(productReasons[j].split(" ")[0].split(".")[1]);
                }else{
                    varLeft = parseInt(productReasons[j-1].split(".")[0]);
                    varRight = parseInt(productReasons[j].split(".")[0]);
                }
                if(varLeft > varRight){
                    var temp = productReasons[j-1];
                    productReasons[j-1] = productReasons[j];
                    productReasons[j] = temp;
                }
            }
        }
        return productReasons;
    },
    
    getRequiredField : function(component, helper) {
        var oppProductWrapper   = component.get('v.oppProductWrapper');
        var oppLineItem         = oppProductWrapper.oppLineItem;
        var productSettings     = component.get('v.productSettings');
        var productResultComp   = component.find('Product_Results__c');
        var productReasonComp   = component.find('Reasons__c');
        var productRemarkComp   = component.find('Remark__c');
        var productResult       = productResultComp.get('v.value');
        var productReason       = productReasonComp.get('v.value');
        var productRemark       = productRemarkComp.get('v.value');
        $A.util.removeClass(productRemarkComp, 'has-required');
        oppLineItem.requiredRemark = false;
        console.log('oppLineItem.requiredReason:' + oppLineItem.requiredReason);
        if(productReason && productReason.trim() != '') {
            console.log('productReason:' + productReason);
            $A.util.removeClass(productReasonComp, 'has-required');
        } else if(oppLineItem.requiredReason) {
            $A.util.addClass(productReasonComp, 'has-required');
        }
        for(var pIndex = 0; pIndex < productSettings.length; pIndex++) {
            var eachSetting = productSettings[pIndex];
            if(eachSetting.ProductResult_Product_Result__c == productResult && (eachSetting.ProductResult_Reason__c == productReason || (eachSetting.ProductResult_Reason__c == undefined && productReason == ''))) {
                var isRequired = (eachSetting.ProductResult_Require_Remark__c == true);
                if(isRequired && productRemark.trim().length == 0) {
                    $A.util.addClass(productRemarkComp, 'has-required');
                }
                productRemarkComp.set('v.required', isRequired);
                oppLineItem.requiredRemark = isRequired;
                break;
            }
        }
            
        oppProductWrapper.oppLineItem = oppLineItem;
        component.set('v.oppProductWrapper', oppProductWrapper);
    },
})