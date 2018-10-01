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
        'reference': { componentDef: 'ui:outputText', attributes: {} },
        'string': { componentDef: 'ui:inputText', attributes: {} },
        'textarea': { componentDef: 'ui:inputTextArea', attributes: {} },
        'time': { componentDef: 'ui:inputDateTime', attributes: {} },
        'url': { componentDef: 'ui:inputText', attributes: {} },
        'lookup': { componentDef: 'c:CustomLookup', attributes: {} },
        'formula': { componentDef: 'ui:outputText', attributes: {} }
    },
    handleNewApplication : function(component, isNewApplication) {
        console.log('sendEvent');
        var compEvent = component.getEvent('handleNewApplication');
        compEvent.setParams({
            dmltype: "selected_app",
            params: {
                data: {isNewApplication: isNewApplication}
            }
        });
        compEvent.fire();
    },
    getConfigForm: function(component, fieldSection, componentSection) {
        var fieldList = component.get('v.'+fieldSection);
        var record = component.get('v.applicationRecord');
        var helpTextMap = component.get('v.helpTextMap');
        var componentDetail = {};
        for(var i = 0; i < fieldList.length; i++) {
            var inputDesc = [];
            var eachField = fieldList[i];
            
            var type = eachField.Type.toLowerCase();
            
            var configTemplate = this.configMap[type];
            if(eachField.APIName == 'Business_Code__c' || eachField.APIName == 'LPM_Customer__c') {
            	configTemplate = this.configMap['lookup'];
            }

            if (!configTemplate) {
                console.log(`type ${ type } not supported`);
            	continue;
            }
            
            var config = JSON.parse(JSON.stringify(configTemplate));
            config.attributes.fieldPath = eachField.APIName;
            config.attributes['aura:id'] = eachField.APIName;
            
            if(eachField.isPicklist) {
                var opts = [];
                for (var key in eachField.picklistValues) {
                    if (eachField.picklistValues.hasOwnProperty(key)) {
                        var isSelected = false;
                        if(record[eachField.APIName] == eachField.picklistValues[key]){
                            isSelected = true;
                        }
                        opts.push({class: "optionClass",value: key, label: eachField.picklistValues[key], selected : isSelected});
                    }
                };
                config.attributes.options = opts;
                config.attributes.required = eachField.Required;
                config.attributes.value = component.getReference('v.applicationRecord.' + eachField.APIName);
            } else {
                if(eachField.APIName == 'OppName__c') {
                    config.attributes.value = component.getReference('v.selectedJob.Name');
                } else if(eachField.APIName == 'Business_Code__c') {
                    config.attributes.label = eachField.Label;
                    config.attributes['objectAPIName']  = eachField.APIName;
                    config.attributes['IconName']       = 'custom:custom53';
                    config.attributes['queryField'] = 'Id, Name, Business_Code_Description__c';
                    config.attributes['canNewRecord']   = false;
                    config.attributes['isRequired'] = eachField.Required;
                    config.attributes['selectedRecord'] = component.getReference('v.selectedBusiness');
                    config.attributes['primaryFieldAPIName']    = 'Name';
                    config.attributes['secondaryFieldAPIName']  = 'Business_Code_Description__c';
                    if(helpTextMap[eachField.APIName]) {
                        config.attributes['helpText']  = helpTextMap[eachField.APIName];
                    }
                } else if(eachField.APIName == 'LPM_Customer__c') {
                    config.attributes.label = eachField.Label;
                    config.attributes['objectAPIName']  = eachField.APIName;
                    config.attributes['IconName']       = 'custom:custom42';
                    config.attributes['queryField'] = 'Id, Name, LPM__r.Name, CIS__r.CIS__c';
                    config.attributes['searchField'] = 'LPM__r.Name,CIS__r.CIS__c';
                    config.attributes['canNewRecord']   = false;
                    config.attributes['isRequired'] = eachField.Required;
                    config.attributes['selectedRecord'] = component.getReference('v.selectedLPM');
                    config.attributes['primaryFieldAPIName']    = 'LPM__r.Name';
                    config.attributes['secondaryFieldAPIName']  = 'CIS__r.CIS__c';
                    if(helpTextMap[eachField.APIName]) {
                        config.attributes['helpText']  = helpTextMap[eachField.APIName];
                    }
                } else {
                    config.attributes.value = component.getReference('v.applicationRecord.' + eachField.APIName);
                    if(type != 'reference' && type != 'formula') {
                        config.attributes.required = eachField.Required;
                    }
                }
            }
            var renderType = 0;
            inputDesc.push([
                'lightning:layoutItem', {
                    'size': '12',
                    'mediumDeviceSize': '6',
                    'padding': 'around-small',
                    'class': 'slds-form-element__control'
                }
            ]);
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);
            if(type == 'formula' || (type == 'reference' && eachField.APIName != 'Business_Code__c' && eachField.APIName != 'LPM_Customer__c')) {
                inputDesc.push([
                    'aura:html', {
                        'tag': 'div'
                    }
                ]);
                inputDesc.push([
                    'aura:html', {
                        'tag': 'span',
                        'body': eachField.Label,
                        'HTMLAttributes': {
                            'class': 'slds-form-element__label'
                        }
                    }
                ]);
                renderType = 1;
            } else if(eachField.APIName != 'Business_Code__c' && eachField.APIName != 'LPM_Customer__c') {
                inputDesc.push([
                    'aura:html', {
                        'tag': 'div',
                        'HTMLAttributes': {
                            'class': 'uiInput--default uiInput--input'
                        }
                    }
                ]);
                inputDesc.push([
                    'aura:html', {
                        'tag': 'label',
                        'HTMLAttributes': {
                            'class': 'uiLabel-left form-element__label'
                        }
                    }
                ]);
                inputDesc.push([
                    'aura:html', {
                        'tag': 'span',
                        'body': eachField.Label,
                        'HTMLAttributes': {
                            'class': 'slds-form-element__label'
                        }
                    }
                ]);
                
                if(eachField.Required) {
                    inputDesc.push([
                        'aura:html', {
                            'tag': 'span',
                            'body': '*',
                            'HTMLAttributes': {
                                'class': 'required'
                            }
                        }
                    ]);
                }
                
                if(helpTextMap[eachField.APIName]) {
                    inputDesc.push([
                        'lightning:helptext', {
                            'content': helpTextMap[eachField.APIName],
                            'class': 'help-text'
                        }
                    ]);
                }
                renderType = 2;
            }

            this.createComponent(component, inputDesc, componentSection, renderType, i);
        }
    },
    createComponent: function(component, inputDesc, componentSection, type, index) {
        $A.createComponents(inputDesc, function(cmps, status, errorMessage) {
            if(status === "SUCCESS") {
                var componentList = component.get("v."+componentSection);
                var layoutItem = cmps[0];
                if(type == 1) {
                    var labelDiv = cmps[2];
                    var labelText = cmps[3];
                    var outputValue = cmps[1];
                    labelDiv.set("v.body", labelText);
                    var layoutItemList = [];
                    layoutItemList.push(labelDiv);
                    layoutItemList.push(outputValue);
                    layoutItem.set("v.body", layoutItemList);
                } else if(type == 2) {
                    var outputValue = cmps[1];
                    var compDiv = cmps[2];
                    var compLabel = cmps[3];
                    var labelText = cmps[4];
                    var compLabelList = [];
                    compLabelList.push(labelText);
                    if(cmps.length > 5) {
                        for(var j = 5;j < cmps.length;j++) {
                            var optionComp = cmps[j];
                            compLabelList.push(optionComp);
                        }
                    }
                    compLabel.set("v.body", compLabelList);
                    var htmlAttr = compLabel.get("v.HTMLAttributes");
                    htmlAttr.for = outputValue.getGlobalId();
                    compLabel.set("v.HTMLAttributes", htmlAttr);
                    var compDivList = [];
                    compDivList.push(compLabel);
                    compDivList.push(outputValue);
                    compDiv.set("v.body", compDivList);
                    layoutItem.set("v.body", compDiv);
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
    validateInput: function(component, helper) {
        var isValid = true;
        var listField = helper.getAllField(component);
        var errorList = [], errorField = [];
        
        for(var i = 0; i < listField.length; i++) {
            var eachField = listField[i];
            var type = eachField.Type.toLowerCase();
            if(type != 'formula' && (type != 'reference') && eachField.Required) {
                var inputValue = component.find(eachField.APIName).get('v.value');
                var inputComponent = component.find(eachField.APIName);
                if(!inputValue) {
                    inputComponent.set("v.errors", [{message:"Complete this field"}]);
                    errorField.push(eachField.Label);
                    isValid = false;
                } else {
                    inputComponent.set("v.errors", []);
                }
            } else if(type == 'reference' && eachField.APIName == 'Business_Code__c' && eachField.Required) {
                var inputValue = component.find('Business_Code__c').get('v.selectedRecord.Id');
                var inputComponent = component.find(eachField.APIName);
                if(!inputValue) {
                    inputComponent.set("v.errors", [{message:"Complete this field"}]);
                    errorField.push(eachField.Label);
                    isValid = false;
                } else {
                    inputComponent.set("v.errors", []);
                }
            } else if(type == 'reference' && eachField.APIName == 'LPM_Customer__c' && eachField.Required) {
                var inputValue = component.find('LPM_Customer__c').get('v.selectedRecord.Id');
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
        var fieldList = [];
        for(var fieldIndex = 1; fieldIndex <= 8; fieldIndex++) {
            var fieldSection = component.get('v.fieldSection' + fieldIndex);
            for(var i = 0; i < fieldSection.length; i++) {
                fieldList.push(fieldSection[i]);
            }
        }
        return fieldList;
    },
    toggleLoading: function(component) {
        var loadingOverlay = component.find('loadingOverlayNewApp');
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
        component.set('v.errorList', '');
        component.set('v.hasError', false);
        /*var errorPanel = component.find('errorPanel');
        var hasHidden = $A.util.hasClass(errorPanel, 'hideEle');
        if(!hasHidden){;
            $A.util.addClass(errorPanel, 'hideEle')
        }*/
    }
})