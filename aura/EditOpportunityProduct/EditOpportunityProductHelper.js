({
    configMap: {
        'anytype': { componentDef: 'ui:inputText', attributes: {} },
        'base64': { componentDef: 'ui:inputText', attributes: {} },
        'boolean': {componentDef: 'ui:inputCheckbox', attributes: {} },
        'combobox': { componentDef: 'ui:inputText', attributes: {} },
        'currency': { componentDef: 'ui:inputNumber', attributes: {} },
        'datacategorygroupreference': { componentDef: 'ui:inputText', attributes: {} },
        'date': {
            componentDef: 'ui:inputDate',
            attributes: {
                displayDatePicker: true,
                format: 'd/M/yyyy'
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
        'string': { componentDef: 'ui:inputText', attributes: {} },
        'textarea': { componentDef: 'ui:inputTextArea', attributes: {} },
        'time': { componentDef: 'ui:inputDateTime', attributes: {} },
        'url': { componentDef: 'ui:inputText', attributes: {} },
        'reference': { componentDef: 'ui:outputText', attributes: {} },
        'lookup': { componentDef: 'c:CustomLookup', attributes: {} },
        'formula': { componentDef: 'ui:outputText', attributes: {} }
    },
    getConfigForm: function(component, fieldSection, componentSection) {
        var fieldList = component.get('v.'+fieldSection);
        var record = component.get('v.opportunityProduct');
        var componentDetail = {};
        var isGetReasonsPicklist = false;
        
        for(var i = 0; i < fieldList.length; i++) {
            var inputDesc = [];
            var eachField = fieldList[i];
            var type = eachField.Type.toLowerCase();
            
            var configTemplate = this.configMap[type];
            if(eachField.APIName == 'Application__c' || eachField.APIName == 'Application_CBS__c') {//waiting for migrate
            	configTemplate = this.configMap['lookup'];
            }

            if (!configTemplate) {
                console.log(`type ${ type } not supported`);
            	continue;
            }
            
            var config = JSON.parse(JSON.stringify(configTemplate));
            config.attributes.label = eachField.Label;
            config.attributes.fieldPath = eachField.APIName;
            config.attributes['aura:id'] = eachField.APIName;
            
            if(eachField.isPicklist) {
                var opts = [];
                if(eachField.APIName == 'Product_Results__c') {
                    var productResultList = component.get('v.productResultList');
                    opts.push({class: "optionClass",value: '', label: ''});
                    for (var j = 0; j < productResultList.length; j++) {
                        var isSelected = false;
                        if(record[eachField.APIName] == productResultList[j].Label) {
                            isSelected = true;
                            component.set('v.requiredReason', productResultList[j].requiredReason);
                            if(!isGetReasonsPicklist || (!record['Reasons__c'])) {
                                component.set('v.requiredRemark', productResultList[j].requiredRemark);
                            }
                        }
                        opts.push({class: "optionClass",value: productResultList[j].Value, label: productResultList[j].Label, selected : isSelected});
                    }
                    config.attributes.options = opts;
                    config.attributes.required = eachField.Required;
                    config.attributes.change = component.getReference('c.onProductResultChange');
                } else if(eachField.APIName == 'Reasons__c') {
                    isGetReasonsPicklist = true;
                    var productResult = record['Product_Results__c'];
                    var reasonListMap = component.get('v.reasonList');
                    var reasonList = [];
                    if(reasonListMap.hasOwnProperty(productResult)) {
                        reasonList = reasonListMap[productResult];
                    }
                    opts.push({class: "optionClass",value: '', label: ''});
                    for (var j = 0; j < reasonList.length; j++) {
                        var isSelected = false;
                        if(record[eachField.APIName] == reasonList[j].Label) {
                            isSelected = true;
                            component.set('v.requiredRemark', reasonList[j].requiredRemark);
                        }
                        opts.push({class: "optionClass",value: reasonList[j].Value, label: reasonList[j].Label, selected : isSelected});
                    }
                    component.set('v.optionsReasonsPicklist', opts);
                    config.attributes.options = component.getReference('v.optionsReasonsPicklist');
                    if(opts.length > 1) {
                        component.set('v.disableReasonsPicklist', false);
                    } else {
                        component.set('v.disableReasonsPicklist', true);
                    }
                    config.attributes.disabled = component.getReference('v.disableReasonsPicklist');
                    config.attributes.required = component.getReference('v.requiredReason');
                    config.attributes.change = component.getReference('c.onReasonChange');
                } else {
                    for (var key in eachField.picklistValues) {
                        if (eachField.picklistValues.hasOwnProperty(key)) {
                            var isSelected = false;
                            if(record[eachField.APIName] == eachField.picklistValues[key]){
                                isSelected = true;
                            }
                            opts.push({class: "optionClass",value: key, label: eachField.picklistValues[key], selected : isSelected});
                        }
                    }
                    config.attributes.options = opts;
                    config.attributes.required = eachField.Required;
                }
                config.attributes.value = component.getReference('v.opportunityProduct.' + eachField.APIName);
            } else {
                if(eachField.APIName == 'Product2Id'){
                    config.attributes.label = eachField.Label.replace(' ID', '');
                    config.attributes.value = component.getReference('v.product.Name');
                } else if(eachField.APIName == 'OpportunityId'){
                    config.attributes.value = component.getReference('v.job.Name');
                } else if(eachField.APIName == 'CreatedById'){
                    config.attributes.label = eachField.Label.replace(' ID', '');
                    config.attributes.value = component.getReference('v.createBy.Name');
                } else if(eachField.APIName == 'LastModifiedById'){
                    config.attributes.label = eachField.Label.replace(' ID', '');
                    config.attributes.value = component.getReference('v.lastModifiedBy.Name');
                } else if(eachField.APIName == 'Application__c' || eachField.APIName == 'Application_CBS__c') {//waiting for migrate
                    config.attributes['objectAPIName']  = 'Application_History__c';
                    config.attributes['IconName']       = 'custom:custom51';
                    config.attributes['canNewRecord']   = true;
                    config.attributes['newRecordLabel'] = 'New Application';
                    config.attributes['isRequired'] = eachField.Required;
                    config.attributes['selectedRecord'] = component.getReference('v.applicationHistory');
                    config.attributes['queryField'] = 'Id, Name, App_Num_Selected__c';
                    component.set('v.defaultQueryCondition', "OppName__c = '" + record['OpportunityId'] + "'");
                    config.attributes['queryCondition'] = component.get('v.defaultQueryCondition');
                    config.attributes['primaryFieldAPIName']    = 'Name';
                    config.attributes['secondaryFieldAPIName']  = 'App_Num_Selected__c';
                } else {
                    config.attributes.value = component.getReference('v.opportunityProduct.' + eachField.APIName);
                    if(eachField.APIName == 'Remark__c') {
                        config.attributes.required = component.getReference('v.requiredRemark');
                    } else if(type != 'reference') {
                        config.attributes.required = eachField.Required;
                    }
                }
            }
            
            inputDesc.push([
                'lightning:layoutItem', {
                    'size': '12',
                    'mediumDeviceSize': '6',
                    'padding': 'around-small',
                    'class': 'slds-form-element__control'
                }
            ]);
            if(type == 'formula' || (type == 'reference' && eachField.APIName != 'Application__c' && eachField.APIName != 'Application_CBS__c')) {//waiting for migrate
                inputDesc.push([
                    'aura:html', {
                        'tag': 'div'
                    }
                ]);
                inputDesc.push([
                    'aura:html', {
                        'tag': 'span',
                        'body': config.attributes.label,
                        'HTMLAttributes': {
                            'class': 'slds-form-element__label'
                        }
                    }
                ]);
            }
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);
            if(eachField.APIName == 'CreatedById') {
                inputDesc.push([
                    'ui:outputDateTime', {
                        'format': ', d/M/yyyy, HH:mm น.',
                        'value': component.getReference('v.opportunityProduct.CreatedDate')
                    }
                ]);
            } else if(eachField.APIName == 'LastModifiedById') {
                inputDesc.push([
                    'ui:outputDateTime', {
                        'format': ', d/M/yyyy, HH:mm น.',
                        'value': component.getReference('v.opportunityProduct.LastModifiedDate')
                    }
                ]);
            }
            
            this.createComponent(component, inputDesc, componentSection, i);
        }
    },
    createComponent: function(component, inputDesc, componentSection, index) {
        $A.createComponents(inputDesc, function(cmps, status, errorMessage) {
            if(status === "SUCCESS") {
                var componentList = component.get("v."+componentSection);
                var layoutItem = cmps[0];
                if(cmps.length == 4 || cmps.length == 5) {
                    var labelDiv = cmps[1];
                    var labelText = cmps[2];
                    var outputValue = cmps[3];
                    labelDiv.set("v.body", labelText);
                    var layoutItemList = [];
                    layoutItemList.push(labelDiv);
                    layoutItemList.push(outputValue);
                    if(cmps.length == 5) {
                        var outputValueDate = cmps[4];
                        layoutItemList.push(outputValueDate);
                    }
                    layoutItem.set("v.body", layoutItemList);
                } else {
                    var outputValue = cmps[1];
                    layoutItem.set("v.body", outputValue);
                }
                componentList[index] = layoutItem;
                component.set('v.'+componentSection, componentList);
            } else if(status === "INCOMPLETE") {
                console.log(index + ") No response from server or client is offline.");
            } else if(status === "ERROR") {
                console.log(index + ") Problem createComponents, Message: " + errorMessage);
            }
        });
    },
    setApplication: function(component, helper) {
        //console.log('setApplication');
        var childCmp = component.find('Application__c');
        if(childCmp) {
            childCmp.oSelectedRecordMethod('Application_History__c', component.get('v.applicationHistory'));
        }
        //waiting for migrate
        var childCmpCBS = component.find('Application_CBS__c');
        if(childCmpCBS) {
            component.set('v.isNotSetCustomLookupCBS', false);
            childCmpCBS.oSelectedRecordMethod('Application_History__c', component.get('v.applicationHistory'));
        }
        //end
    },
    setAppHistQueryCondition: function(component) {
        var defaultQuery = component.get('v.defaultQueryCondition');
        var newIdList = component.get('v.newAppHistIdList');
        var newQuery = defaultQuery + " OR Id IN ('";
        for(var i = 0; i < newIdList.length; i++) {
            newQuery = newQuery + newIdList[i];
            if(i < newIdList.length - 1) {
                newQuery = newQuery + "','";
            }
        }
        newQuery = newQuery + "')";
        
        var childCmp = component.find('Application__c');
        if(childCmp) {
            childCmp.set('v.queryCondition', newQuery);
        }
        //waiting for migrate
        var childCmpCBS = component.find('Application_CBS__c');
        if(childCmpCBS) {
            childCmpCBS.set('v.queryCondition', newQuery);
        }
        //end
    },
    getReasonsPicklistItem: function(component, helper) {
        var opts = [];
        var productResult = component.get('v.opportunityProduct.Product_Results__c');
        var reasonListMap = component.get('v.reasonList');
        var reasonList = [];
        if(reasonListMap.hasOwnProperty(productResult)) {
            reasonList = reasonListMap[productResult];
        }
        opts.push({class: "optionClass",value: '', label: ''});
        for (var j = 0; j < reasonList.length; j++) {
            opts.push({class: "optionClass",value: reasonList[j].Value, label: reasonList[j].Label});
        }
        
        return opts;
    },
    validateInput: function(component, helper) {
        var isValid = true;
        var fieldList = helper.getAllField(component);
        var errorList = [], errorField = [];
        
        for(var i = 0; i < fieldList.length; i++) {
            var eachField = fieldList[i];
            var type = eachField.Type.toLowerCase();
            if(eachField.APIName == 'Reasons__c' || eachField.APIName == 'Remark__c') {
                var isRequired = (eachField.APIName == 'Reasons__c') ? component.get('v.requiredReason') : component.get('v.requiredRemark');
                if(isRequired) {
                    var inputValue = component.get('v.opportunityProduct.' + eachField.APIName);
                    var inputComponent = component.find(eachField.APIName);
                    if(!inputValue) {
                        inputComponent.set("v.errors", [{message:"Complete this field"}]);
                        errorField.push(eachField.Label);
                        isValid = false;
                    } else {
                        inputComponent.set("v.errors", []);
                    }
                }
            } else if(type != 'formula' && (type != 'reference') && eachField.Required) {
                var inputValue = component.get('v.opportunityProduct.' + eachField.APIName);
                var inputComponent = component.find(eachField.APIName);
                if(!inputValue) {
                    inputComponent.set("v.errors", [{message:"Complete this field"}]);
                    errorField.push(eachField.Label);
                    isValid = false;
                } else {
                    inputComponent.set("v.errors", []);
                }
            } else if(type == 'reference' && (eachField.APIName == 'Application__c' || eachField.APIName == 'Application_CBS__c') && eachField.Required) {//waiting for migrate
                var inputValue = component.get('v.applicationHistory.Id');
                var inputComponent = component.find(eachField.APIName);
                if(!inputValue) {
                    inputComponent.set("v.errors", [{message:"Complete this field"}]);
                    errorField.push(eachField.Label);
                    isValid = false;
                } else {
                    inputComponent.set("v.errors", []);
                }
            }
        }
        
        if(errorField.length > 0) {
            errorList.push("These required fields must be completed: " + errorField.join(", "));
            helper.showErrorPanel(component);
            component.set('v.errorList', errorList);
        }
        return isValid;
    },
    getAllField: function(component) {
        var fieldSection1 = component.get('v.fieldSection1');
        var fieldSection2 = component.get('v.fieldSection2');
        var fieldSection3 = component.get('v.fieldSection3');
        var fieldList = [];
        for(var i = 0; i < fieldSection1.length; i++) {
            fieldList.push(fieldSection1[i]);
        }
        for(var i = 0; i < fieldSection2.length; i++) {
            fieldList.push(fieldSection2[i]);
        }
        for(var i = 0; i < fieldSection3.length; i++) {
            fieldList.push(fieldSection3[i]);
        }
        return fieldList;
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
    showErrorPanel: function(component) {
        component.set('v.hasError', true);
        /*var errorPanel = component.find('errorPanel');
        var hasHidden = $A.util.hasClass(errorPanel, 'hideEle');
        if(hasHidden){;
            $A.util.removeClass(errorPanel, 'hideEle')
        }*/
    },
    hideErrorPanel: function(component) {
        component.set('v.errorMessage', '');
        component.set('v.errorList', []);
        component.set('v.hasError', false);
        /*var errorPanel = component.find('errorPanel');
        var hasHidden = $A.util.hasClass(errorPanel, 'hideEle');
        if(!hasHidden){;
            $A.util.addClass(errorPanel, 'hideEle')
        }*/
    },
    closeTabWithRefresh: function(component) {
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")) {
            window.history.back();
        } else {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                
                workspaceAPI.getAllTabInfo().then(function(response) {
                    var foundParentTab = false;
                    for(var i = 0; i < response.length; i++) {
                        var subTabs = response[i].subtabs;
                        for(var j = 0; j < subTabs.length; j++) {
                            if(subTabs[j].tabId == focusedTabId) {
                                foundParentTab = true;
                                break;
                            }
                        }
                        if(foundParentTab) {
                            //workspaceAPI.focusTab({tabId : response[i].tabId});
                            workspaceAPI.refreshTab({
                                tabId: response[i].tabId,
                                includeAllSubtabs: true
                            });
                            break;
                        }
                    }
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log('Problem closeTabWithRefresh > getAllTabInfo, Message:' + error);
                });
            })
            .catch(function(error) {
                console.log('Problem closeTabWithRefresh > getFocusedTabInfo, Message:' + error);
            });
        }
    },
    closeTabWithoutRefresh: function(component) {
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")) {
            window.history.back();
        } else {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log('Problem closeTabWithoutRefresh > getFocusedTabInfo, Message:' + error);
            });
        }
	},
    sortReasonList : function(reasonList,hasDecimal) {
        var result = {};
        for(var key in reasonList) {
            if(reasonList.hasOwnProperty(key)) {
                var eachReasonList = reasonList[key];
                result[key] = this.subNumberSort(eachReasonList, "Label",hasDecimal);
            }
        }
        return result;
    },
    subNumberSort : function(itemList, fieldName,hasDecimal) {
        var listSize = itemList.length;
        for (var i = listSize-1; i >= 0; i--){
            for(var j = 1; j <= i; j++){
                var varLeft,varRight;
                if(hasDecimal){
                    varLeft = parseInt(itemList[j-1][fieldName].split(" ")[0].split(".")[1]);
                    varRight = parseInt(itemList[j][fieldName].split(" ")[0].split(".")[1]);
                }else{
                    varLeft = parseInt(itemList[j-1][fieldName].split(".")[0]);
                    varRight = parseInt(itemList[j][fieldName].split(".")[0]);
                }
                if(varLeft > varRight){
                    var temp = itemList[j-1];
                    itemList[j-1] = itemList[j];
                    itemList[j] = temp;
                }
            }
        }
        return itemList;
    }
})