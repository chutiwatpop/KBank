({
	init : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        console.log('device:' + device);
        if(device == 'DESKTOP') {
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
        }
	},
    handleRowSelect: function (component, event, helper) {
        console.log('handleRowSelect');
        var selectedRows = event.getParam('selectedRows');
        console.log(selectedRows);
        helper.handleRowSelect(component, helper, selectedRows);
        component.set('v.previousSelected', selectedRows);
    },
    handleSort: function (component, event, helper) {
        console.log('handleSort')
        component.set('v.isLoading', true);
        setTimeout(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            if(fieldName && sortDirection) {
                component.set("v.sortedBy", fieldName);
                component.set("v.sortedDirection", sortDirection);
                helper.sortData(component, fieldName, sortDirection);
            } else {
                console.log('Error sorted!!')
            }
            component.set('v.isLoading', false);
        }, 0);
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
    removeSelectRow: function (component, event, helper) {
        event.preventDefault();
        var newSelectedRows = component.get('v.selectedDisplay');
        var currentPill = event.getSource().get("v.name");
        for (var mIndex = 0; mIndex < newSelectedRows.length; mIndex++) {
            var newSelectedRow = newSelectedRows[mIndex];
            if(newSelectedRow.Id === currentPill) {
                newSelectedRows.splice(mIndex, 1);
            }
        }
        component.set('v.selectedDisplay', newSelectedRows);
        helper.setTableSelectedRow(component, newSelectedRows, helper);
    },
})