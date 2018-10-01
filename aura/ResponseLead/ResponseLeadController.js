({
	init: function (component, event, helper) { 
		 
		var ios = $A.get("$Browser.isIOS");        
		var android = $A.get("$Browser.isAndroid");

		if(!ios && !android){
			//debugger;
			var recordId = component.get('v.recordId');     
			var evt = $A.get("e.force:navigateToURL");  
			evt.setParams({            
						"url": "/apex/ResponseLead?&Id="+recordId+"&isRedirectPage=true",
						"isredirect": "true"
			});

			$A.get("e.force:closeQuickAction").fire();	
			evt.fire();

		}else{		
			window.addEventListener("message", function(event) {
				if (event.data != 'closeResponsePageModal') {
					this.console.log('Not the expected message');
					// Not the expected message: Reject the message!
					return;
				}
				// Handle the message
				$A.get("e.force:closeQuickAction").fire();
	
			}, false);
		}

	},
	
	closeQuickActionMethod : function(component,event,helper){
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
	},

})