({
    doInit : function(component, event, helper) {
        component.set("v.lead", {
            Salutation: "", 
            Document_Type__c: ""
        });
        component.set("v.fieldLabel", {
            CIS_ID__c: "CIS ID", 
            Salutation: "Salutation.", 
            FirstName: "First Name", 
            LastName: "Surname", 
            Title: "Title", 
            Company: "Company Name", 
            Document_Type__c: "Document Type", 
            Identification_No__c: "Identification Number", 
            Birthdate_Registration_Date__c: "Birthdate / Registration Date", 
            Customer__c: "Customer"
        });

        helper.loadFieldLabel(component);
        helper.loadSelectComponent(component, "c.getCustomerType", "inputCustomerType", false);
        helper.loadSelectComponent(component, "c.getDocumentType", "inputDocumentType", true);
        helper.loadSelectComponent(component, "c.getSalutation", "inputSalutation", true);
        
        var action = component.get("c.getCurrentUsedrId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.userId", response.getReturnValue());
                helper.loadLead(component);
            } else {
                var errors = response.getError();
                var errorText = "Unknown error";
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        errorText = errors[0].message;
                    }
                }
                alert("Problem getting current user, Status: " + state + ", Message: " + errorText);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleBeforeConvert : function(component, event, helper) {
        event.getSource().set("v.disabled",true);
        component.set("v.messageError", "");
        component.set("v.showError", false);
        if(component.get("v.isNewCustomer")) {
            if(helper.validateConvertForm(component, component.get("v.isPersonAccount"),component.get("v.isMlpRequireField"))) {
                var action = component.get("c.haveExistingCustomer");
                action.setParams({"lead": component.get("v.lead")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        if(response.getReturnValue()) {
                            if(confirm("Found existing customer. Do you want to merge?")) {
                                helper.handleConvert(component, event);
                            } else {
                                event.getSource().set("v.disabled",false);
                            }
                        } else {
                            helper.handleConvert(component, event);
                        }
                    } else {
                        var errors = response.getError();
                        var errorText = "Unknown error";
                        if(errors) {
                            if(errors[0] && errors[0].message) {
                                errorText = errors[0].message;
                            }
                        }
                        event.getSource().set("v.disabled",false);
                        alert("Problem check existing customer, Status: " + state + ", Message: " + errorText);
                    }
                });
                $A.enqueueAction(action);
            } else {
                event.getSource().set("v.disabled",false);
                component.set("v.messageError", "Required field is missing");
                component.set("v.showError", true);
            }
        } else {
            debugger;
            if(component.get("v.createNewJob") == true && component.get("v.selectedJob").Id != null){
                debugger;
                event.getSource().set("v.disabled",false);
                component.set("v.showError",true);
                component.set("v.messageError",'Please create new job or choose existing job.');
            }else{
                debugger;
                helper.handleConvert(component, event);
            }
        }
    },
	handleCancel : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    onCustomerTypeChange : function(component, event, helper) {
        helper.onCustomerTypeChange(component);
    }
})