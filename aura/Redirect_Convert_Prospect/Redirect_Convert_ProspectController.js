({
	init: function (component, event, helper) { 
		
		var ios = $A.get("$Browser.isIOS");        
		var android = $A.get("$Browser.isAndroid");        
		if(!ios && !android){            
			setTimeout(function(){                
				var spin = document.getElementsByClassName("backgroundSpinner");                
				spin[0].style.background = "rgba(0, 0, 0, 0)";            
				var modal = document.getElementsByClassName("modal-body");                
				modal[0].style.background = "rgba(0, 0, 0, 0)";                
				modal[0].style.boxShadow = "0 0px 0px 0 rgba(0, 0, 0, 0)";                
				var header = document.getElementsByClassName("closeIcon");                
				header[0].style.display = "none";        
			}, 1);        
		} else {            
			setTimeout(function(){                
				var mobileModal = document.getElementsByClassName("panel-content");                
				mobileModal[0].style.background = "rgb(246, 246, 246)";            
			}, 1);        
		}        
		var recordId = component.get('v.recordId');     
		var evt = $A.get("e.force:navigateToURL");        
		evt.setParams({            
					"url": "/apex/Override_NewAccount_Page?&Id="+recordId,
					"isredirect": "true"
		});        
		evt.fire();    
	}
})