({
    init: function(cmp, event, helper) {
        var sobjectName = cmp.get('v.sObjectName');
        var recordId = cmp.get('v.recordId');
        
        var getFormAction = cmp.get('c.getForm');

        getFormAction.setParams({
            objectName: sobjectName,
            recordId: recordId,
        });

        getFormAction.setCallback(this, 
            function(response) {

                var state = response.getState();
                var form = response.getReturnValue();
                if (cmp.isValid() && state === "SUCCESS" && !form.isError) {
                    cmp.set('v.fields', form.Fields);
                    cmp.set('v.record', form.Record);
                    cmp.set('v.campaignCode', form.LeadCode);
                    cmp.set('v.leadSubType', form.LeadSubType);
                    cmp.set('v.existingJobQueryCondition',"AccountId = '"+ form.ParentId +"' AND (StageName NOT IN ('Finished','Finished.','Reopen')  OR (StageName IN ('Finished','Finished.') AND CloseDate >= LAST_N_DAYS:"+$A.get("$Label.c.Lead_Response_Limit_Job_xx_Days_Backward")+"))");
                    cmp.set('v.selectedJob',form.Job);
                    cmp.set('v.hasJobReadAccess',form.HasJobReadAccess);
                    helper.createForm(cmp);
                    helper.getResponseLv1(cmp, helper);

                    var childCmp = cmp.find('customLookupJob');
                    childCmp.oSelectedRecordMethod('Opportunity', cmp.get('v.selectedJob'));
                }else{
                    console.log('fail state',state);
                }
                cmp.set('v.isLoadComplete', true);
                cmp.set('v.isMobile',form.isMobile);
            }
        );
 
        $A.enqueueAction(getFormAction);
    },

    save: function(cmp, event, helper) {
    	var listField = cmp.get('v.fields');
    	var recordId = cmp.get("v.recordId");
    	var selectedJob = cmp.get("v.selectedJob");
    	var mapReponseByFieldApi = {};

    	for(var eachApi in listField){
            if(listField[eachApi] != undefined && listField[eachApi].APIName != undefined){
                mapReponseByFieldApi[listField[eachApi].APIName] = cmp.find(listField[eachApi].APIName).get('v.value');
            }
    	}
    	if(helper.isMissingRequiredFieldForSave(cmp,helper)){
    		helper.showToast(cmp,'warning','Warning!','Please input all required fields.');
    		return;
    	}
    	var saveAction = cmp.get('c.saveResponse');
        saveAction.setParams({
            recordId : recordId,
            mapReponseByFieldApi : mapReponseByFieldApi,
            jobId : selectedJob.Id,
        });

        saveAction.setCallback(this, 
            function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (cmp.isValid() && state === "SUCCESS" && result.isSuccess) {
                    $A.get('e.force:refreshView').fire();
                    cmp.set('v.selectedJob',result.relatedOpp);
                    var childCmp = cmp.find('customLookupJob');
                    childCmp.oSelectedRecordMethod('Opportunity', cmp.get('v.selectedJob'));
                    cmp.find('Create_New_Job__c').set('v.value',false);
                    helper.showToast(cmp,'success','Success!',$A.get("$Label.c.Record_Update_Successfully"));

                    $A.get("e.force:closeQuickAction").fire();
                }else{
                	helper.showToast(cmp,'error','Error!',result.message);
                }
            }
        );
        $A.enqueueAction(saveAction);
    },

    getResponseLv2 : function(cmp, event, helper){
    	helper.getResponseLv2(cmp, helper);
    	helper.checkRequiredFieldLv1(cmp,helper);
    },

    checkRequiredFieldLv2 : function(cmp, event, helper){
        helper.checkRequiredFieldLv2(cmp, helper);
    },

    cancel : function(cmp, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    updateRecord : function(cmp, event, helper){
        if(!cmp.get('v.isMobile')){

            cmp.set('v.isLoadComplete',false);
            var sobjectName = cmp.get('v.sObjectName');
            var recordId = cmp.get('v.recordId');
            
            var getFormAction = cmp.get('c.getForm');

            getFormAction.setParams({
                objectName: sobjectName,
                recordId: recordId,
            });

            getFormAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (cmp.isValid() && state === "SUCCESS") {        
                        var form = response.getReturnValue();
                        cmp.set('v.record',form.Record);
                        cmp.set('v.selectedJob',form.Job);
                        cmp.set('v.hasJobReadAccess',form.HasJobReadAccess);
                        cmp.set('v.isMobile',form.isMobile);
                        cmp.find('Response_Level_1__c').set('v.value',form.Record.Response_Level_1__c);
                        cmp.find('Response_Level_2__c').set('v.value',form.Record.Response_Level_2__c);
                        helper.getResponseLv1(cmp, helper);

                        var childCmp = cmp.find('customLookupJob');
                        childCmp.oSelectedRecordMethod('Opportunity', cmp.get('v.selectedJob'));
                    }else{
                        console.log('state',state);
                    }
                }
            );
     
            $A.enqueueAction(getFormAction);
        }
    },
})