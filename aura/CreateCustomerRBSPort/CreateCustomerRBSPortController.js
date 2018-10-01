({
	doInit : function(component, event, helper) {
         var mRecordId = component.get('v.recordId');
        //console.log('mRecordId:' + mRecordId);
        var getAccountInfo = component.get('c.createCustomerRBSPort');
        getAccountInfo.setParams({
            "CustomerId" :  mRecordId
        });
         getAccountInfo.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                if(resp == 'true') {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast('ทำรายการสำเร็จ', 'success');
                } else if(resp == 'not authorized'){
                     $A.get("e.force:closeQuickAction").fire();
                    helper.showToast('ปุ่มสำหรับ RBS-BM,  RBS-ABM และ RBS-BAR', 'warning');       
                }else {
                    //console.log('error:' + resp);
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast('ทำรายการไม่สำเร็จ ' + resp, 'error');
                }
            }
        });
        if(mRecordId != null){
            $A.enqueueAction(getAccountInfo);
        }
	}
})