({
	doInit : function(component, event, helper) {
		helper.canRegister(component,helper);
		helper.loadProvince(component,helper);
	},

	loadDistrict : function(component, event, helper) {
		helper.loadDistrict(component,helper);
	},

	loadSubDistrict : function(component, event, helper) {
		helper.loadSubDistrict(component,helper);
	},

	loadPostCode : function(component, event, helper) {
		helper.loadPostCode(component,helper);
	},

	checkButton : function(component, event, helper) {
		helper.checkButtonHelper(component,helper);
	},

	validatePickRewardController : function(component, event, helper) {
		helper.validatePickRewardHelper(component,event,helper);
	},

	onchangeAccountNumber : function(component, event, helper) {
		helper.onchangeAccountNumber(component,helper);
	},

	validateAccountNumber : function(component, event, helper) {
		var inputValue = component.find('accountNumber').get('v.value');
		if(inputValue && inputValue.length == 10){
			helper.validateAccountNumber(component,helper);
		}
	},

	onchangeMobileNumber : function(component, event, helper) {
		helper.onchangeMobileNumber(component,helper);
	},

	checkMobileNumber : function(component, event, helper) {
		var inputValue = component.find('mobileNo').get('v.value');
		if(inputValue && inputValue.length == 10){
			helper.checkMobileNumber(component,helper);
		}
	},

	actionRegisterImmediately : function(component, event, helper) {
		helper.actionRegisterImmediately(component,helper);
	},

	actionSaveController : function(component, event, helper) {
		helper.actionSaveHelper(component,helper);
	},

	actionCancel : function(component, event, helper) {
		helper.clearValueOnCanCelHelper(component,helper);
		$A.get("e.force:closeQuickAction").fire();
		$A.get('e.force:refreshView').fire();
	},

	actionCancelMobile : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	actionNotRegisterImmediately : function(component, event, helper){
		helper.actionNotRegisterImmediatelyHelper(component,helper)
	}

})