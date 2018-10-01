({  
    canRegister :function(component,helper){
        var action = component.get("c.canRegister");
        var recordId = component.get("v.recordId");
        action.setParams({tglIdString : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'SUCCESS'){
                    component.set("v.canRegister",true);
                    helper.getRecordInfo(component,helper);
                }else{
                    component.set('v.extendHeight',100);
                    component.set('v.errorMessage',returnVal.message);
                    component.set("v.canRegister",false);
                    component.set("v.isError",true);
                }
                component.set("v.isMobile",returnVal.isMobile);
                component.set("v.loadingCanRegisterComplete", true);
            }else{
                console.log('getRecordInfo error');
            }
        });
        $A.enqueueAction(action);
    },

	getRecordInfo : function(component,helper) {
        var action = component.get("c.getRecordInfo");
        var recordId = component.get("v.recordId");
        action.setParams({tglIdString : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.wrapperTargetListRecord", returnVal);
                component.set("v.extendHeight", 0);

                var optionsList = [];
                for (var key in returnVal.mapReward) {
                    if (returnVal.mapReward.hasOwnProperty(key)) {
                        optionsList.push({value: key, label: returnVal.mapReward[key]});
                    }
                };
                component.set('v.rewardList', optionsList);
                component.set("v.loadingDataComplete", true);
            }else{
                console.log('getRecordInfo error');
            }
        });
        $A.enqueueAction(action);
    },
    loadProvince : function(component,helper) {
        var action = component.get("c.getProvincePickListValues");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.listProvince", returnVal);
                helper.disableButton(component);
            }else{
                console.log('loadProvince error');
            }
        });
        $A.enqueueAction(action);
    },
    loadDistrict : function(component,helper) {
        var action = component.get("c.getDistrictPickListValues");
        var province = component.find("province").get("v.value");
        action.setParams({selectedProvince : province});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.listDistrict", returnVal);
                helper.disableButton(component);
            }else{
                console.log('loadDistrict error');
            }
        });
        $A.enqueueAction(action);
    },
    loadSubDistrict : function(component,helper) {
        var action = component.get("c.getSubDistrictPickListValues");
        var province = component.find("province").get("v.value");
        var district = component.find("district").get("v.value");
        action.setParams({selectedProvince : province,selectedDistrict:district});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                component.set("v.listSubDistrict", returnVal);
            }else{
                console.log('loadSubDistrict error');
            }
        });
        $A.enqueueAction(action);
    },
    loadPostCode : function(component,helper) {
        var action = component.get("c.getPostCode");
        var province = component.find("province").get("v.value");
        var district = component.find("district").get("v.value");
        var subDistrict = component.find("subDistrict").get("v.value");
        action.setParams({selectedProvince : province,
                          selectedDistrict : district,
                          selectedSubDistrict : subDistrict});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                component.find("postCode").set("v.value",returnVal);
                helper.checkButtonHelper(component,helper);
            }else{
                console.log('loadPostCode error');
            }
        });
        $A.enqueueAction(action);
    },

	checkButtonHelper : function(component,helper) {
        if(helper.validateInput(component,helper)) {
            helper.enableButton(component); 
        }
        else 
            helper.disableButton(component);
	},

	disableButton : function(component) {
        if(component.find("saveButton")){
            component.find("saveButton").set("v.disabled",true);
        }
    },

    enableButton : function(component) {
        if(component.find("saveButton")){
            component.find("saveButton").set("v.disabled",false);
        }
    },

    onchangeMobileNumber : function(component,helper) {
        var inputValue = component.find('mobileNo').get('v.value');
        helper.checkMobileNumber(component,helper);
    },

    checkMobileNumber : function(component,helper) {
        var inputValue = component.find('mobileNo').get('v.value');
        var regex = new RegExp('^[0-9]+$'); 
        if (!regex.test(inputValue) || inputValue.length != 10) {
            helper.disableButton(component);
            helper.showErrorMessage(component,'เบอร์โทรศัพท์มือถือต้องเป็นตัวเลข 10 หลัก');
            return false;
        }
        helper.hideErrorMessage(component);
        helper.checkButtonHelper(component,helper);
    },

    onchangeAccountNumber : function(component,helper) {
        var inputValue = component.find('accountNumber').get('v.value');
        helper.validateAccountNumber(component,helper);
    },

    validateAccountNumber : function(component,helper) {
        var inputValue = component.find('accountNumber').get('v.value');
        var regex = new RegExp('^[0-9]+$'); 
        if (!regex.test(inputValue) || inputValue.length != 10) {
            helper.disableButton(component);
            helper.showErrorMessage(component,"เลขบัญชีไม่ถูกต้อง ต้องเป็นตัวเลข 10 หลัก");
            return false;
        }
        helper.hideErrorMessage(component);
        helper.checkButtonHelper(component,helper);
    },

    validateInput : function(component,helper) {
        var result = false;
        var isShowAddressSection = component.get('v.wrapperTargetListRecord').isShowAddressSection;
        var mustSelectReward = component.get('v.wrapperTargetListRecord').mustSelectReward;
        if(isShowAddressSection){
            var valContactName = component.find('contactPerson').get('v.value');
            var valMobileNo = component.find('mobileNo').get('v.value');
            var valHouseNo = component.find('houseNo').get('v.value');
            var valPostCode = component.find('postCode').get('v.value');
            var valSubDistrict = component.find('subDistrict').get('v.value');
        }else{
            var valAccountNumber = component.find('accountNumber').get('v.value');
        }

        if(mustSelectReward){
            var valRewardAmount = component.find('inputRewardAmount').get('v.value');
            if((typeof valRewardAmount == 'undefined' || valRewardAmount == '')) return false;
        }
        
        if(((valContactName && valHouseNo && valSubDistrict && valSubDistrict != '' && valPostCode && valPostCode.length == 5 && valMobileNo && valMobileNo.length == 10) || (valAccountNumber && valAccountNumber.length == 10))) {
            result = true;
        }
        return result;
    },

    validatePickRewardHelper : function(component,event,helper) {
        var action = component.get("c.validatePickReward");
        var inputRewardAmount = component.find("inputRewardAmount").get("v.value");
        action.setParams({campaignReward : inputRewardAmount});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                var wrapperTargetListRecord = component.get('v.wrapperTargetListRecord');
                wrapperTargetListRecord.isShowAddressSection = returnVal;
                component.set('v.wrapperTargetListRecord',wrapperTargetListRecord);
            }else{
                console.log('validatePickRewardHelper error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(type,msg) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": msg,
            "type": type,
            "duration": "4000"
        });
        resultsToast.fire();
    },

    showErrorMessage : function(component,errorMsg) {
        component.set('v.extendHeight',50);
        component.set('v.isError',true);
        component.set('v.errorMessage',errorMsg);
    },

    hideErrorMessage : function(component) {
        component.set('v.extendHeight',0);
        component.set('v.isError',false);
        component.set('v.errorMessage','');
    },

    actionSaveHelper : function(component,helper) {
        var action = component.get("c.savingTargetList");
        var mustSelectReward = component.get('v.wrapperTargetListRecord').mustSelectReward;
        if(mustSelectReward){
            var inputRewardAmount = component.find("inputRewardAmount").get("v.value");
        }
        var wrapperTargetListRecord = component.get("v.wrapperTargetListRecord");
        action.setParams({inputWrapTargetListString : JSON.stringify(wrapperTargetListRecord), inputRewardAmount : inputRewardAmount});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('actionSaveHelper success');
                var isMobile = component.get("v.isMobile");
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    if(!isMobile){
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
                helper.showToast(returnVal.result,returnVal.message);
            }else{
                helper.showErrorMessage(component,returnVal.message);
            }
        });
        $A.enqueueAction(action);
    },

    actionRegisterImmediately : function(component,helper) {
        var action = component.get("c.savingTargetListImmediately");
        var wrapperTargetListRecord = component.get("v.wrapperTargetListRecord");
        action.setParams({inputWrapTargetListString : JSON.stringify(wrapperTargetListRecord)});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'SUCCESS'){
                    $A.get('e.force:refreshView').fire();
                    helper.showToast(returnVal.result,returnVal.message);
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    helper.showErrorMessage(component,returnVal.message);
                }
            }else{
                console.log('actionRegisterImmediately error');
            }
        });
        $A.enqueueAction(action);
    },
    actionNotRegisterImmediatelyHelper : function(component,helper) {
        var action = component.get("c.saveNotRegisterImmediately");
        var wrapperTargetListRecord = component.get("v.wrapperTargetListRecord");
        action.setParams({inputWrapTargetListString : JSON.stringify(wrapperTargetListRecord)});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal =  response.getReturnValue();
                returnVal = JSON.parse(returnVal);
                if(returnVal.result == 'SUCCESS'){
                    $A.get('e.force:refreshView').fire();
                    helper.showToast(returnVal.result,returnVal.message);
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    helper.showErrorMessage(component,returnVal.message);
                }
            }else{
                console.log('actionNotRegisterImmediatelyHelper error');
            }
        });
        $A.enqueueAction(action);
    },

    clearValueOnCanCelHelper : function(component,helper){
        component.set('v.wrapperTargetListRecord',{'objectType' :'WrapperTargetList'});
        component.find('accountNumber').set('v.value','');
        component.set('v.isError',false);
    },
})