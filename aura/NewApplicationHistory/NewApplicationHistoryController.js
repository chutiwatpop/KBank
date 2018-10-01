({
    doInit: function(component, event, helper) {
        console.log('Version 8');
        helper.toggleLoading(component);
        if($A.get("$Browser.isPhone") || $A.get("$Browser.isTablet")){
            component.set('v.pageHeight', (screen.availHeight - 160)+'px');
        }
        
        var applicationRecord = component.get('v.applicationRecord');
        var getFormAction = component.get('c.getForm');
        //console.log(applicationRecord);
        //console.log(applicationRecord['OppName__c']);
        getFormAction.setParams({
            "appRecord": applicationRecord
        });
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('response: %O', response.getReturnValue());
            var form = response.getReturnValue();
            if(state === "SUCCESS" && !form.isError) {
                component.set('v.sectionLabel', form.SectionLabel);
                if(form.HelpTextList != null && form.HelpTextList != undefined) {
                    component.set('v.helpTextMap', form.HelpTextList);
                }
                if(form.Fields.section1 != null && form.Fields.section1 != undefined) {
                    component.set('v.fieldSection1', form.Fields.section1);
                }
                if(form.Fields.section2 != null && form.Fields.section2 != undefined) {
                    component.set('v.fieldSection2', form.Fields.section2);
                }
                if(form.Fields.section3 != null && form.Fields.section3 != undefined) {
                    component.set('v.fieldSection3', form.Fields.section3);
                }
                if(form.Fields.section4 != null && form.Fields.section4 != undefined) {
                    component.set('v.fieldSection4', form.Fields.section4);
                }
                if(form.Fields.section5 != null && form.Fields.section5 != undefined) {
                    component.set('v.fieldSection5', form.Fields.section5);
                }
                if(form.Fields.section6 != null && form.Fields.section6 != undefined) {
                    component.set('v.fieldSection6', form.Fields.section6);
                }
                if(form.Fields.section7 != null && form.Fields.section7 != undefined) {
                    component.set('v.fieldSection7', form.Fields.section7);
                }
                if(form.Fields.section8 != null && form.Fields.section8 != undefined) {
                    component.set('v.fieldSection8', form.Fields.section8);
                }
                if(form.FieldsList != null && form.FieldsList != undefined) {
                    component.set('v.fields', form.FieldsList);
                }

                if(form.Job != null && form.Job != undefined) {
                    component.set('v.selectedJob', form.Job);
                }
                if(form.BusinessCode != null && form.BusinessCode != undefined) {
                    component.set('v.selectedBusiness', form.BusinessCode);
                }
                if(form.LpmCustomer != null && form.LpmCustomer != undefined) {
                    component.set('v.selectedLPM', form.LpmCustomer);
                }
                if(form.ApplicationHistory != null && form.ApplicationHistory != undefined) {
                    component.set('v.applicationRecord', form.ApplicationHistory);
                }
                
                helper.getConfigForm(component, 'fieldSection1', 'componentSection1');
                helper.getConfigForm(component, 'fieldSection2', 'componentSection2');
                helper.getConfigForm(component, 'fieldSection3', 'componentSection3');
                helper.getConfigForm(component, 'fieldSection4', 'componentSection4');
                helper.getConfigForm(component, 'fieldSection5', 'componentSection5');
                helper.getConfigForm(component, 'fieldSection6', 'componentSection6');
                helper.getConfigForm(component, 'fieldSection7', 'componentSection7');
                helper.getConfigForm(component, 'fieldSection8', 'componentSection8');
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
        });
        $A.enqueueAction(getFormAction);
    },
    handleSave : function(cmp, event, helper) {
        helper.toggleLoading(cmp);
        helper.hideErrorPanel(cmp);
        cmp.set('v.disableSaveButton', true);
        console.log('handleSave');
        var applicationRecord = cmp.get('v.applicationRecord');
        var selectedBusiness = cmp.get('v.selectedBusiness');
        var selectedLPM = cmp.get('v.selectedLPM');
        if(helper.validateInput(cmp, helper)) {
            if(selectedBusiness != undefined) {
                applicationRecord['Business_Code__c'] = selectedBusiness.Id;
            }
            if(selectedLPM != undefined) {
                applicationRecord['LPM_Customer__c'] = selectedLPM.Id;
            }
            
            var saveAction = cmp.get('c.save');
            saveAction.setParams({
                "applicationHistory": applicationRecord
            });
            saveAction.setCallback(this, function(response){
                cmp.set('v.isError', false);
                var state = response.getState();
                var result = response.getReturnValue();
                if(state === "SUCCESS" && result.isSuccess) {
                    cmp.set('v.applicationRecord', result.applicationHistory);
                    helper.handleNewApplication(cmp, true);
                } else {
                    helper.showErrorPanel(cmp);
                    if(state === "SUCCESS") {
                        cmp.set('v.errorMessage', result.message);
                    } else {
                        var errors = response.getError();
                        if(errors) {
                            var errorList = [];
                            for(var i = 0; i < errors.length; i++) {
                                errorList.push(errors[i].message);
                            }
                            cmp.set('v.errorList', errorList);
                        }
                    }
                }
                helper.toggleLoading(cmp);
                cmp.set('v.disableSaveButton', false);
            });
            $A.enqueueAction(saveAction);
        } else {
            helper.toggleLoading(cmp);
            cmp.set('v.disableSaveButton', false);
        }
    },
    handleCancel : function(component, event, helper) {
        console.log('handleCancel');
        helper.handleNewApplication(component, false);
    },
    doRender: function(component, event, helper) {
        var childCmp = component.find('Business_Code__c');
        
        var isNotSetCustomLookup = component.get('v.isNotSetCustomLookup');
        if(isNotSetCustomLookup && childCmp) {
            component.set('v.isNotSetCustomLookup', false);
            if(component.get('v.selectedBusiness') !=null){
                childCmp.oSelectedRecordMethod('Business_Code__c', component.get('v.selectedBusiness'));
            }
        }
        
        var childLPMCmp = component.find('LPM_Customer__c');
        
        var isNotSetLPMCustomLookup = component.get('v.isNotSetLPMCustomLookup');
        if(isNotSetLPMCustomLookup && childLPMCmp) {
            component.set('v.isNotSetLPMCustomLookup', false);
            if(component.get('v.selectedLPM') !=null){
                childLPMCmp.oSelectedRecordMethod('LPM_Customer__c', component.get('v.selectedLPM'));
            }
        }
    }
})