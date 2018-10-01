({
    searchCustomer : function(component,event, helper){
        helper.clearSearchResult(component);
        let birthDate = component.get("v.inputDOBValue");
        let identification = component.get("v.inputIdentificationValue");
        let cisNumber = component.get("v.inputCISValue");
        var validIdent = (typeof(birthDate) !== 'undefined' && birthDate != null && birthDate != '' && typeof(identification) !== 'undefined' && identification != null && identification != '');
        var isInt = /^\+?\d+$/.test(cisNumber);
        if(isInt){
            helper.searchCustomer(component,helper,'validByCISNumber');
        }else if(validIdent){
            helper.searchCustomer(component,helper,'validByIdent');
        }else{
            if(!validIdent){
                var msgError = 'invalid Form!';
                helper.resetValue(component);
            }else if(!isInt){
                var msgError = 'invalid CIS Number!';
                helper.resetValue(component);
            }
            helper.showErrorMessage(component, msgError);
        }
    },

    convertCustomer : function(component,event,helper){
        let isCustomerExist = component.get("v.isCustomerExist");
        if(isCustomerExist){
            helper.convertCustomer(component, helper);
        } else {
            helper.showErrorMessage(component, 'Cannot convert : No data to convert');
        }
    }
})