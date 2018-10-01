({
	doInit : function(component, event, helper) {
        console.log('doInit');
        var tempRecordId = component.get("v.recordId");
        console.log('tempRecordId',tempRecordId);
        tempRecordId = '0015D00000MOBxoQAH';
		var urlEvent = $A.get("e.force:navigateToURL");
        console.log('urlEvent',urlEvent);
        urlEvent.setParams({
            "url": '/apex/test_page?id='+tempRecordId
        });
        urlEvent.fire();
	}
})