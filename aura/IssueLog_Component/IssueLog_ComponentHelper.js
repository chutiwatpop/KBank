({
	urlFire : function(url) {
		
         var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": url,
              "isredirect": "true"
            });
            urlEvent.fire();
	}
})