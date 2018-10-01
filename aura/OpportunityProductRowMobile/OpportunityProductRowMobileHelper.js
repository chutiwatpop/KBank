({
	initTable : function(component, event, helper) {
		var eachProduct = component.get('v.eachProduct');
		var mColumns = component.get('v.columns');
		console.log('mColumns:' + mColumns.length);

		var fields = [];
		for (var mIndex = 0; mIndex < mColumns.length; mIndex++) {
			var lightningTable = mColumns[mIndex];
			var key = lightningTable.lnFieldName;
			console.log('key:' + key);
			console.log('lightningTable:' + lightningTable.lnLabel);
			var fieldMap = {};
			fieldMap.Label = lightningTable.lnLabel;
			fieldMap.Value = eachProduct[key];
			fields.push(fieldMap);
		}
        component.set('v.productFields', fields);
	},
	handleRowSelect: function(component, helper, selectedRows) {
        helper.handleSelectedProduct(component, selectedRows);
        component.set('v.selectedDisplay', selectedRows);
        component.set('v.selectedRowsCount', selectedRows.length);
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
})