({
	init : function(component, event, helper) {
		var initialComponent = component.get('c.initialProductList');
        component.set('v.isLoading', true);
		initialComponent.setCallback(this, 
            function(response) {
                console.log('init response');
                var state = response.getState();
                var initialComponent = response.getReturnValue();
                if (component.isValid() && state === "SUCCESS" && !initialComponent.isError) {
                    helper.initTable(component, helper, initialComponent);
                }else{
                    console.log('fail state', state);
                }
            }
        );
        $A.enqueueAction(initialComponent);
    },
    doneRendering: function(component, helper) {
        var allCheckBoxElements = document.getElementsByName('products');
        if(allCheckBoxElements.length > 0){
            var selectedPreviousRows = component.get('v.selectedDisplay');
            if(selectedPreviousRows.length > 0){
                for(var i=0;i<selectedPreviousRows.length;i++){
                    if(document.getElementById(selectedPreviousRows[i].Id) != null){
                        document.getElementById(selectedPreviousRows[i].Id).checked = true;
                    }
                }
            }
        }
    },
    handleKeypress: function (component, event, helper) {
        if(event.getParams().keyCode == 13){
            component.set('v.isLoading', true);
            helper.filterSearch(component, helper);
        }
    },
    handleSearchClick: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.filterSearch(component, helper);
    },
    selectedRow: function (component, event, helper) {
        var selectedRows = []; 
        var inputElements = document.getElementsByName('products');
        for(var i=0; inputElements[i]; ++i){
            if(inputElements[i].checked){
                selectedRows.push(component.get('v.data')[i]);
            }
        }

        helper.handleRowSelect(component, helper, selectedRows);
        component.set('v.previousSelected', selectedRows);
    },
    removeSelectRow: function (component, event, helper) {
        event.preventDefault();
        var newSelectedRows = component.get('v.selectedDisplay');
        var currentPill = event.getSource().get("v.name");
        for (var mIndex = 0; mIndex < newSelectedRows.length; mIndex++) {
            var newSelectedRow = newSelectedRows[mIndex];
            if(newSelectedRow.Id === currentPill) {
                newSelectedRows.splice(mIndex, 1);
            }
            if(document.getElementById(currentPill) != null){
                document.getElementById(currentPill).checked = false;
            }
        }
        component.set('v.selectedDisplay', newSelectedRows);
        helper.setTableSelectedRow(component, newSelectedRows, helper);
    },
    
})