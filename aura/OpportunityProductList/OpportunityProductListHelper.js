({
	handleInit : function(component) {
        var compEvent = component.getEvent('handleInitialized');
        compEvent.setParams({
            "dmltype": "success_initial",
            "params": {
                data: {initial: true}
            }
        });
        compEvent.fire();
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
    initTable : function(component, helper, initialComponent) {
        console.log('initTable');
        var mColumns = [];
        var tableColumn = initialComponent.lightningTables;
        for (var mIndex = 0; mIndex < tableColumn.length; mIndex++) {
            var lightningTable = tableColumn[mIndex];
            mColumns.push({label: lightningTable.lnLabel, fieldName: lightningTable.lnFieldName, type: lightningTable.lnType, sortable: 'true'});
        }
        component.set("v.queryCondition", initialComponent.queryCondition);
        component.set('v.data', initialComponent.products);
        component.set('v.allData', initialComponent.products);
        component.set('v.isMobile', initialComponent.isMobile);
        component.set('v.tableColumn', initialComponent.lightningTables);
        component.set('v.columns', mColumns);
        component.set('v.isLoading', false);
        // Set selected product
        helper.clearFilter(component, helper);
        helper.handleInit(component);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.data", data);
    },
    sortBy: function (fieldName, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[fieldName]) }
            : function(x) { return x[fieldName] };
        return function (a, b) {
        	console.log('a:', a);
            var A = key(a);
            var B = key(b);
            return (A === undefined)-(B === undefined) || reverse * ((A > B) - (B > A));
        };
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
        var selectedRowsIds = [];
        for (var mIndex = 0; mIndex < selectedRows.length; mIndex++) {
            var newSelectedRow = selectedRows[mIndex];
            selectedRowsIds.push(newSelectedRow.Id);
        }
        var tableComponent = component.find("productTable");
        tableComponent.set("v.selectedRows", selectedRowsIds);
        component.set('v.selectedRowsCount', selectedRowsIds.length);
        helper.handleSelectedProduct(component, selectedRows);
    },
    handleRowSelect: function(component, helper, selectedRows) {
        var isFiltering = component.get('v.isFiltering');
        var selectedDisplay = component.get('v.selectedDisplay');
        var previousSelected = component.get('v.previousSelected');
        if(isFiltering) {
            component.set('v.isFiltering', false);
            helper.setTableSelectedRow(component, selectedDisplay, helper);
        } else {
            if(selectedRows.length > previousSelected.length) {
                // Add
                for (var mIndex = 0; mIndex < selectedRows.length; mIndex++) {
                    var newSelected = selectedRows[mIndex];
                    var isContain = false;
                    for (var cIndex = 0; cIndex < selectedDisplay.length; cIndex++) {
                        var eachSelected = selectedDisplay[cIndex];
                        if(eachSelected.Name === newSelected.Name) {
                            isContain = true;
                        }
                    }
                    if(!isContain) {
                         selectedDisplay.push(newSelected);
                    }
                }
            } else if(selectedRows.length < previousSelected.length) {
                //Remove
                var removeProducts = [];
                for (var prevIndex = 0; prevIndex < previousSelected.length; prevIndex++) {
                    var eachPrevious = previousSelected[prevIndex];
                    var isPreviousExist = false;
                    for (var currentIndex = 0; currentIndex < selectedRows.length; currentIndex++) {
                        var eachCurrent = selectedRows[currentIndex];
                        if(eachCurrent.Name == eachPrevious.Name) {
                            isPreviousExist = true;
                            break;
                        }
                    }
                    if(!isPreviousExist) {
                        removeProducts.push(eachPrevious.Name);
                    }
                }

                for (var sIndex = 0; sIndex < selectedDisplay.length; sIndex++) {
                    var eachSelected = selectedDisplay[sIndex];
                    if(removeProducts.indexOf(eachSelected.Name) != -1) {
                        selectedDisplay.splice(sIndex, 1);
                    }
                }
            }
            helper.handleSelectedProduct(component, selectedDisplay);
            component.set('v.selectedDisplay', selectedDisplay);
            component.set('v.selectedRowsCount', selectedDisplay.length);
        }
    }

})