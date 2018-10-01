({
	myAction : function(component, event, helper) {
		
	},
    
    openRelatedList: function(component, _event){
       var relatedListEvent = $A.get("e.force:navigateToRelatedList");
       relatedListEvent.setParams({
          "relatedListId": "Target_Lists__r",
          "parentRecordId": component.get("v.recordId")
       });
       relatedListEvent.fire();
    }

})