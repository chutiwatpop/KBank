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
        'url': { componentDef: 'ui:inputText', attributes: {} }
    },

    createForm: function(cmp) {
        var fields = cmp.get('v.fields');
        var record = cmp.get('v.record');
        
        for (var i = 0; i < fields.length; i++) {
        	var inputDesc = [];
            var field = fields[i];
            var type = field.Type.toLowerCase();

            var configTemplate = this.configMap[type];
            if(field.isManualPicklist) configTemplate = this.configMap['picklist'];

            if (!configTemplate) {
                console.log(`type ${ type } not supported`);
            	continue;
            }
            
            var config = JSON.parse(JSON.stringify(configTemplate));
            
            config.attributes.label = field.Label;
            if(field.APIName == 'Response_Level_1__c'){
				config.attributes.required = true;            	
            }else{
            	config.attributes.required = field.Required;
            }

            if(field.isPicklist){
				var opts = [];
            	for (var key in field.picklistValues) {
                    if (field.picklistValues.hasOwnProperty(key)) {
                    	var isSelected = false;
                    	if(record[field.APIName] == field.picklistValues[key]){
                    		isSelected = true;
                    	}
                        opts.push({class: "optionClass",value: key, label: field.picklistValues[key], selected : isSelected});
                    }
                };
            	config.attributes['options'] = opts;
            }else if(field.isManualPicklist){
            	if(field.APIName == 'Response_Level_1__c'){
	            	var getResponseLv2 = cmp.getReference("c.getResponseLv2");
	            	config.attributes['change'] = getResponseLv2;
	            }else if(field.APIName == 'Response_Level_2__c'){
	            	var checkRequiredFieldLv2 = cmp.getReference("c.checkRequiredFieldLv2");
	            	config.attributes['change'] = checkRequiredFieldLv2;
	            }
            }else {
            	config.attributes.value = cmp.getReference(' v.record.' + field.APIName);
            }
            config.attributes.fieldPath = field.APIName;
            config.attributes['aura:id'] = field.APIName;
            
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);

            $A.createComponents(inputDesc, function(cmps) {
	            var listField = cmp.get("v.listField");
	            listField.push(cmps);
	            cmp.set('v.listField', listField);
	        });
        }
    },

    getResponseLv1 : function(cmp, helper){
    	var campaignCode = cmp.get('v.campaignCode');
    	var leadSubType = cmp.get('v.leadSubType');
        var getReponseLv1Action = cmp.get('c.getResponseLevel1');
        getReponseLv1Action.setParams({
            campaignCode: campaignCode,
            subType:leadSubType,
        });

        getReponseLv1Action.setCallback(this, 
            function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var responseLv1 = response.getReturnValue();
                    var record = cmp.get('v.record');
                    var optionsList = [{value:'',label:'-- None --'}];
                    var optionsMap = cmp.get('v.mapReponseLevel1');
                    for (var eachRes in responseLv1) {
                    	var isSelected = false;
                    	optionsMap[responseLv1[eachRes].answer]=responseLv1[eachRes];
                    	if(record['Response_Level_1__c'] == responseLv1[eachRes].answer){
                    		isSelected = true;
                    		if(!record['Response_Level_2__c']){
                    			helper.checkRequiredFieldLv1(cmp,helper,responseLv1[eachRes]);
                    		}else{
	                    		if(cmp.find('Response_Level_2__c') && responseLv1[eachRes].isRequireLv2){
									cmp.find('Response_Level_2__c').set('v.required',true);
                                    cmp.find('Response_Level_2__c').set('v.disabled',false);
                                    cmp.find('Response_Level_2__c').set('v.value',record['Response_Level_2__c']);
								}
							}
                            helper.getResponseLv2(cmp,helper);
                    	}else if(eachRes == 0){
                            helper.checkRequiredFieldLv1(cmp,helper,{isRequireLv2:false,isRequiredDate:false,isRequireMemo:false});
                        }
	                    optionsList.push({value: responseLv1[eachRes].answer, label: responseLv1[eachRes].answer, selected : isSelected});
	                };
	                cmp.set('v.mapReponseLevel1',optionsMap);
                    cmp.find('Response_Level_1__c').set('v.options',optionsList);
                }else{
                    console.log('Error getResponseLv1',state);
                }
            }
        );
        $A.enqueueAction(getReponseLv1Action);
    },

    getResponseLv2 : function(cmp, helper,inputResponseLv1){
    	var campaignCode = cmp.get('v.campaignCode');
    	var leadSubType = cmp.get('v.leadSubType');
    	var record = cmp.get('v.record');
        var optionsMapResLv1 = cmp.get('v.mapReponseLevel1');
    	var responseLv1 = cmp.find('Response_Level_1__c').get('v.value')?cmp.find('Response_Level_1__c').get('v.value'):record['Response_Level_1__c'];
        if(!inputResponseLv1) inputResponseLv1=responseLv1;
        if(!optionsMapResLv1.hasOwnProperty(inputResponseLv1)) return;
        var getReponseLv2Action = cmp.get('c.getResponseLevel2');

        getReponseLv2Action.setParams({
            campaignCode: campaignCode,
            responseLv1:inputResponseLv1,
            subType:leadSubType
        });

        getReponseLv2Action.setCallback(this, 
            function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var responseLv2 = response.getReturnValue();
                    var record = cmp.get('v.record');
                    var isLoadComplete = cmp.get('v.isLoadComplete');
                    var optionsList = [{value:'',label:'-- None --'}];
                    var optionsMap = cmp.get('v.mapReponseLevel2');
                    for (var eachRes in responseLv2) {
                    	var isSelected = false;
                    	optionsMap[responseLv2[eachRes].answer]=responseLv2[eachRes];
                    	if(!isLoadComplete && record['Response_Level_2__c'] == responseLv2[eachRes].answer){
                    		isSelected = true;
                    	}
	                    optionsList.push({value: responseLv2[eachRes].answer, label: responseLv2[eachRes].answer, selected : isSelected});
	                };
	                cmp.set('v.mapReponseLevel2',optionsMap);
                    cmp.find('Response_Level_2__c').set('v.options',optionsList);
                    
                    if(record['Response_Level_2__c'] || cmp.find('Response_Level_2__c').get('v.value')){
                		var tmpResponse;
                		if(!isLoadComplete) {
                			tmpResponse = record['Response_Level_2__c'];
                			helper.checkRequiredFieldLv2(cmp,helper,tmpResponse);
                		}else{
                			helper.checkRequiredFieldLv1(cmp,helper);
                		}
                	}else{
                        helper.checkRequiredFieldLv1(cmp,helper);
                    }
                	cmp.set('v.isLoadComplete',true);
                }
            }
        );
        $A.enqueueAction(getReponseLv2Action);
    },

    checkRequiredFieldLv1 : function(cmp, helper, responseObject){
    	responseObject = helper.getReponseIfNotExistGetFromMap(cmp, responseObject,'Response_Level_1__c','v.mapReponseLevel1');
        if(cmp.find('Response_Level_2__c')){
            if(!responseObject){
                cmp.find('Response_Level_2__c').set('v.required',false);
                cmp.find('Response_Level_2__c').set('v.value','');
                cmp.find('Response_Level_2__c').set('v.disabled',true);
                cmp.set('v.mapReponseLevel2',{});
                cmp.find('Response_Level_2__c').set('v.options',[]);
            }else{
    			if(responseObject.isRequireLv2){
    				cmp.find('Response_Level_2__c').set('v.required',true);
    			}else{
    				cmp.find('Response_Level_2__c').set('v.required',false);
    				cmp.find('Response_Level_2__c').set('v.value','');
    			}
                if(cmp.find('Response_Level_2__c').get('v.options').length > 1){
                    cmp.find('Response_Level_2__c').set('v.disabled',false);
                }else{
                    cmp.find('Response_Level_2__c').set('v.disabled',true);
                }
            }
		}
		helper.checkRequiredFieldMemo(cmp,responseObject);
		helper.checkRequiredFieldApplicationId(cmp,responseObject);
		helper.checkRequiredFieldDate(cmp,responseObject);
    },

    checkRequiredFieldLv2 : function(cmp, helper, responseObject){
        responseObject = helper.getReponseIfNotExistGetFromMap(cmp, '','Response_Level_2__c','v.mapReponseLevel2');
		helper.checkRequiredFieldMemo(cmp,responseObject);
		helper.checkRequiredFieldApplicationId(cmp,responseObject);
		helper.checkRequiredFieldDate(cmp,responseObject);
    },

    checkRequiredFieldApplicationId : function(cmp,responseObject){
		if(cmp.find('Application_ID__c')){
			if(responseObject && responseObject.isRequiredAppId){
				cmp.find('Application_ID__c').set('v.required',true);
				cmp.find('Application_ID__c').set('v.disabled',false);
			}else{
				cmp.find('Application_ID__c').set('v.required',false);
				cmp.find('Application_ID__c').set('v.disabled',true);
				cmp.find('Application_ID__c').set('v.value','');
			}
		}
    },

    checkRequiredFieldMemo : function(cmp,responseObject){
		if(cmp.find('Memo__c')){
			if(responseObject && responseObject.isRequireMemo){
				cmp.find('Memo__c').set('v.required',true);
			}else{
				cmp.find('Memo__c').set('v.required',false);
			}
		}
    },

    checkRequiredFieldDate : function(cmp,responseObject){
		if(cmp.find('Proceeding_Date__c')){
			if(responseObject && responseObject.isRequiredDate){
				cmp.find('Proceeding_Date__c').set('v.required',true);
				cmp.find('Proceeding_Date__c').set('v.disabled',false);
			}else{
				cmp.find('Proceeding_Date__c').set('v.required',false);
				cmp.find('Proceeding_Date__c').set('v.disabled',true);
				cmp.find('Proceeding_Date__c').set('v.value','');
			}
		}
    },

    getReponseIfNotExistGetFromMap : function(cmp,responseObject,fieldName,mapName){
		var responseLvFromField = cmp.find(fieldName).get('v.value');
    	if(!responseObject) responseObject = cmp.get(mapName)[responseLvFromField];
    	return responseObject;
    },

    showToast : function(component,type,title,msg) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "type":type,
	        "title": title,
	        "message": msg
	    });
	    toastEvent.fire();
	},

	isMissingRequiredFieldForSave : function(cmp,helper){
		var listField = cmp.get('v.fields');
		for(var eachApi in listField){
            if(listField[eachApi] != undefined && listField[eachApi].APIName != undefined){
                if(cmp.find(listField[eachApi].APIName).get('v.required') && !cmp.find(listField[eachApi].APIName).get('v.value')) return true;
            }
		}
	},
})