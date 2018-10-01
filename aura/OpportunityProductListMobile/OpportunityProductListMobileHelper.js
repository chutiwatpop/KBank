({
	handleInit : function(component) {
        console.log('try handleInit');
        var compEvent = component.getEvent('handleInitialized');
        var selectedDisplay = component.get('v.selectedDisplay');
        compEvent.setParams({
            "dmltype": "success_initial",
            "params": {
                data: {initial: true},
                selectedDisplayParams: selectedDisplay
            }
        });
        compEvent.fire();
    },
	initTable : function(component, helper, initialComponent) {
        console.log('initTable');
        component.set("v.queryCondition", initialComponent.queryCondition);
        component.set('v.data', initialComponent.products);
        component.set('v.columns', initialComponent.lightningTables);
        component.set('v.tableColumn', initialComponent.lightningTables);
        component.set('v.allData', initialComponent.products);
        component.set('v.isLoading', false);
        // Set selected product
        // helper.clearFilter(component, helper);
        helper.handleInit(component);
    },
    filterSearch: function(component, helper, inputSearch) {
    	var inputSearch     = component.find('inputSearch').get('v.value');
    	var queryCondition 	= component.get("v.queryCondition");
    	var tableColumn 	= component.get("v.tableColumn");
    	var action          = component.get("c.getProductFromInput");
        var selectedDisplay = component.get('v.selectedDisplay');
        if(inputSearch && inputSearch.trim() != '') {    
            action.setParams({inputSearch : inputSearch, queryCondition: queryCondition, lightningTables: JSON.stringify(tableColumn)});
            action.setCallback(this, function(response){
                    console.log('ProductList response');
                    var state = response.getState();
                    var resp = response.getReturnValue();
                    component.set('v.isLoading', false);
                    if (state === "SUCCESS") {
                        if(selectedDisplay.length > 0) {
                            component.set('v.isFiltering', true);
                        }
                        component.set('v.data', resp);
                    } else {
                        console.log('Error!');                
                    }
                }
            );   
            $A.enqueueAction(action); 
        } else {
            helper.clearFilter(component, helper);
        }
    },
    clearFilter: function(component, helper) {
        setTimeout(function() {
            var allData = component.get('v.allData');
            var selectedDisplay = component.get('v.selectedDisplay');
            component.set('v.data', allData);
            helper.setTableSelectedRow(component, selectedDisplay, helper);
            component.set('v.isLoading', false);
        }, 0);
    },
    setTableSelectedRow: function(component, selectedRows, helper) {
        console.log('setTableSelectedRow');
        component.set('v.previousSelected', selectedRows);
        
        component.set('v.selectedRowsCount', selectedRows.length);
        helper.handleSelectedProduct(component, selectedRows);
    },
    handleSelectedProduct : function(component, newSelectedRows) {
        var compEvent = component.getEvent('handleSelectedProduct');
        compEvent.setParams({
            dmltype: "selected_products",
            params: {
                data: {selectedRows: newSelectedRows}
            }
        });
        compEvent.fire();

        setTimeout(function() {
            // Dynamic Height
            var pillContainer = component.find("selected-pill");
            if(pillContainer) {
                console.log('pillContainer:' + pillContainer.getElement().offsetHeight);
                var mOffsetHeight = pillContainer.getElement().offsetHeight;
                if(newSelectedRows.length > 0  && mOffsetHeight) {
                    component.set('v.divHeight', mOffsetHeight);
                }
            } else {
                component.set('v.divHeight', '0');
            }
        }, 0);
    },
    handleRowSelect: function(component, helper, selectedRows) {
        var selectedDisplay = selectedRows;
            helper.handleSelectedProduct(component, selectedDisplay);
            component.set('v.selectedDisplay', selectedDisplay);
            component.set('v.selectedRowsCount', selectedDisplay.length);
    },
})