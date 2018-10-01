({
	init : function(component, event, helper) {
        var oppProductWrapperList = component.get('v.oppProductWrapperList');
        console.log('Init Product Result:' + oppProductWrapperList.length);
        component.set('v.isLoading', true);
        var ios = $A.get("$Browser.isIOS");        
		var android = $A.get("$Browser.isAndroid");
		
		if(ios || android){
            if(document.documentElement.clientWidth <= 1024){
                var cmpTarget = component.find('divC');
        		$A.util.addClass(cmpTarget, 'content-mobile'); 
           }
        }
		var initialComponent = component.get('c.initialProductResult');
		initialComponent.setCallback(this, 
            function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS" && !resp.isError) {
                    helper.initTable(component, helper, resp)
                }else{
                    console.log('fail state', state);
                }
                component.set('v.isLoading', false);
            }
        );
        $A.enqueueAction(initialComponent);
	},
    handleInitRow : function(component, event, helper) {
        var dmltype = event.getParam("dmltype");
        if(dmltype === 'success_initial') {
            // helper.handleInit(component);
        }
    },
})