({
    onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord == undefined || getInputkeyWord.length == 0){
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            // Get Default 5 Records order by createdDate DESC
            helper.searchHelper(component,event,getInputkeyWord);
        }
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if(getInputkeyWord.length > 1 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        } else {  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selection 
    clear :function(component,event,helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        var searchIcon = component.find("searchIcon");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        $A.util.addClass(searchIcon, 'slds-show');
        $A.util.removeClass(searchIcon, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});
        component.set("v.selectedLabel", "");
        helper.removeSelectedRecord(component, helper);

        var isCalledFromVFPage = component.get("v.isCalledFromVFPage");
        if(isCalledFromVFPage){
            var getExternalValue = component.get('c.callExternalFunction');
            $A.enqueueAction(getExternalValue);
        }
    },

    handleComponentMethod : function(component, event, helper) {
        var primaryFieldAPIName = component.get("v.primaryFieldAPIName");
        component.set("v.selectedRecord" , event.getParam('arguments').selectedRecord);
        
        if(!event.getParam('arguments').selectedRecord.Id) {
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField"); 

            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');

            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');

            component.set("v.SearchKeyWord",null);
            component.set("v.listOfSearchRecords", null);
            component.set("v.selectedRecord", {});
            component.set("v.selectedLabel", "");

            return;
        }
        
        component.set("v.selectedLabel", helper.getValue(primaryFieldAPIName, event.getParam('arguments').selectedRecord));
        var forclose = component.find("searchIcon");
        $A.util.removeClass(forclose, 'slds-show');
        $A.util.addClass(forclose, 'slds-hide');

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONENT event 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var primaryFieldAPIName = component.get("v.primaryFieldAPIName");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        component.set("v.selectedLabel", helper.getValue(primaryFieldAPIName, selectedAccountGetFromEvent));
       
        var forclose = component.find("searchIcon");
        $A.util.removeClass(forclose, 'slds-show');
        $A.util.addClass(forclose, 'slds-hide');
       
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

        var isCalledFromVFPage = component.get("v.isCalledFromVFPage");
        if(isCalledFromVFPage){
            var getExternalValue = component.get('c.callExternalFunction');
            $A.enqueueAction(getExternalValue);
        }
    },

    newRecord : function(component, event, helper) {
        var compEvent = component.getEvent('handleNewRecord');
        compEvent.setParams({
            "dmltype": "new_record",
            "params": {}
        });
        compEvent.fire();
    },
    
    callExternalFunction : function(component, event, helper){
        console.log('callExternalFunction');
        var lightningAppExternalEvent = $A.get("e.c:selectedsObjectRecordEventForVFPage");
        lightningAppExternalEvent.setParams({
            "recordByEvent": component.get("v.selectedRecord"),
            "objectAPIName": component.get("v.objectAPIName")
        });
        lightningAppExternalEvent.fire();
    },

})