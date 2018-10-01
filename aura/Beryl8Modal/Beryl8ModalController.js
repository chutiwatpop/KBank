({
    doInit:function(component,event,helper){    
    },
    closeModal:function(component,event,helper){    
        component.set('v.isDisplayOnLoad',false);
        console.log('closeModal');
    },
    openmodal: function(component,event,helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    gotoURL : function (component, event, helper) {
        console.log(component.get('v.objectId'));        
        var navEvt  = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get('v.objectId'),
          "slideDevName": "Detail"
        });
        navEvt.fire();
        console.log('after fired');
    }
})