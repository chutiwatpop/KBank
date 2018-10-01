({
	onCustomerTypeChange : function(component) {
		var selectCmp = component.find("inputCustomerType");
        if(selectCmp.get("v.value") === "Individual") {
            component.set("v.isPersonAccount", true);
            document.getElementById("personField").className = "";
            document.getElementById("organizationField").className = "hide";
        } else {
            component.set("v.isPersonAccount", false);
            document.getElementById("personField").className = "hide";
            document.getElementById("organizationField").className = "";
        }
	},
    loadFieldLabel : function(component) {
        var action = component.get("c.getFieldLabel");
        action.setCallback(this, function(response) {
            var fLabel=[];
            var state = response.getState();
            if(state === "SUCCESS") {
                var fLabels = response.getReturnValue();
                for(var i=0;i< fLabels.length;i++) {
                    var fLabelItem = fLabels[i].split('|,|');
                    component.set("v.fieldLabel."+fLabelItem[0], fLabelItem[1]);
                }
            } else {
                var errors = response.getError();
                var errorText = "Unknown error";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                alert("Problem getting field label, Status: " + state + ", Message: " + errorText);
            }
        });
        $A.enqueueAction(action);
    },
    loadSelectComponent : function(component, functionName, selectId, emptyItem) {
        var action = component.get(functionName);
        var inputSelect = component.find(selectId);
        action.setCallback(this, function(response) {
            var opts=[];
            var state = response.getState();
            if(state === "SUCCESS") {
                var selectValue = response.getReturnValue();
                if(emptyItem) {
                    opts.push({"class": "optionClass", label: "", value: ""});
                }
                for(var i=0;i< selectValue.length;i++) {
                    var selectItem = selectValue[i].split(',');
                    opts.push({"class": "optionClass", label: selectItem[0], value: selectItem[1]});
                }
                inputSelect.set("v.options", opts);
            } else {
                var errors = response.getError();
                var errorText = "Unknown error";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                alert("Problem getting picklist, Status: " + state + ", Message: " + errorText);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    loadLead : function(component) {
        var action = component.get("c.getLead");
        action.setParams({"leadId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.lead", result.lead);
                component.set("v.selectedJob", result.job);
                if(component.get("v.lead.Customer__c")) {
                    component.set("v.isNewCustomer", false);
                    component.set('v.existingJobQueryCondition',"AccountId = '"+ component.get("v.lead.Customer__c") +"' AND (StageName NOT IN ('Finished','Finished.','Reopen')  OR (StageName IN ('Finished','Finished.') AND CloseDate >= LAST_N_DAYS:"+$A.get("$Label.c.Referral_Limit_Job_xx_Days_Backward")+"))");
                }
                if(component.get("v.lead.Status") !== "Assigned" || component.get("v.lead.OwnerId") !== component.get("v.userId")) {
                    $A.get("e.force:closeQuickAction").fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "mode": "dismissible",
                        "message": component.get("v.massageNotAssigned"),
                        "type": "error",
                        "duration": "5000"
                    });
                    resultsToast.fire();
                }

                console.log('recordtype',component.get("v.lead.RecordType.DeveloperName"));
                console.log('cis',component.get("v.lead.CIS_ID__c"));

                if(component.get("v.lead.RecordType.DeveloperName") == 'Telesales_Lead_MLP' || component.get("v.lead.RecordType.DeveloperName") == 'Telesales_Lead_MLP_Read_Only'){
                    console.log('set(v.isMlpRequireField,true)');
                    component.set("v.isMlpRequireField",true);
                    component.find('inputDocumentType').set('v.required',true);
                    component.find('inputIdentificationNumber').set('v.required',true);
                    component.find('inputBirthdate_RegistrationDate').set('v.required',true);
                }
            } else {
                var errors = response.getError();
                var errorText = "Unknown error";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                alert("Problem getting lead, Status: " + state + ", Message: " + errorText);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleConvert : function(component, event) {
        var action = component.get("c.convert");
        action.setParams({
            "lead": component.get("v.lead"), 
            "isPersonAccount": component.get("v.isPersonAccount"),
            "createNewJob":component.get("v.createNewJob"),
            "jobId":component.get("v.selectedJob").Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "mode": "dismissible",
                    "message": component.get("v.messageSuccess"),
                    "type": "success",
                    "duration": "5000"
                });
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue()
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                var errorText = "Unknown error";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                event.getSource().set("v.disabled",false);
                component.set("v.messageError", errorText);
                component.set("v.showError", true);
            }
        });
        $A.enqueueAction(action);
    },
    validateConvertForm : function(component, isPersonAccount, isMlpRequireField) {
        var validContact = true;

        if(isPersonAccount) {
            var inputSurname = component.find("inputLastName");
            if(!inputSurname.get("v.value")) {
                inputSurname.set("v.errors", [{message:"Please complete this field"}]);
                validContact = false;
            } else {
                inputSurname.set("v.errors", null);
            }
        } else {
            var inputCompanyName = component.find("inputCompanyName");
            if(!inputCompanyName.get("v.value")) {
                inputCompanyName.set("v.errors", [{message:"Please complete this field"}]);
                validContact = false;
            } else {
                inputCompanyName.set("v.errors", null);
            }
        }

        if(isMlpRequireField){
            var inputIdentificationNumber = component.find("inputIdentificationNumber");
            if(!inputIdentificationNumber.get("v.value")) {
                inputIdentificationNumber.set("v.errors", [{message:"Please complete this field"}]);
                validContact = false;
            }else{
                inputIdentificationNumber.set("v.errors", []);
            }
            var inputBirthdate_RegistrationDate = component.find("inputBirthdate_RegistrationDate");
            console.log('birth',inputBirthdate_RegistrationDate.get("v.value"));
            if(!inputBirthdate_RegistrationDate.get("v.value")) {
                inputBirthdate_RegistrationDate.set("v.errors", [{message:"Please complete this field"}]);
                validContact = false;
            }else{
                inputBirthdate_RegistrationDate.set("v.errors", []);
            }

            var inputDocumentType = component.find("inputDocumentType");
            if(!inputDocumentType.get("v.value")) {
                inputDocumentType.set("v.errors", [{message:"Please complete this field"}]);
                validContact = false;
            }else{
                inputDocumentType.set("v.errors", []);
            }

            if(validContact){
                inputIdentificationNumber.set("v.errors", null);
            }
        }
        
        return validContact;
    }
})