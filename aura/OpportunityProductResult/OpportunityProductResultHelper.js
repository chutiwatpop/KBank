({  
    initTable: function(component, helper, initialComponent) {
        var requiredFieldMapByAPI = {};
        for (var colIndex = 0; colIndex < initialComponent.lightningTables.length; colIndex++) {
            var eachLightningCol = initialComponent.lightningTables[colIndex];
            requiredFieldMapByAPI[eachLightningCol.lnFieldName] = eachLightningCol.lnIsRequired;
        }
        component.set('v.requiredColumn', requiredFieldMapByAPI);
        component.set('v.columns', initialComponent.lightningTables);
        component.set('v.isMobile', initialComponent.isMobile);
        helper.handleInit(component);
    },
    handleInit : function(component) {
        var requiredFieldMapByAPI = component.get('v.requiredColumn');
        var compEvent = component.getEvent('handleInitialized');
        compEvent.setParams({
            "dmltype": "initial_product_results",
            "params": {
                data: {
                    initial: true,
                    requiredColumn : requiredFieldMapByAPI
                }
            }
        });
        compEvent.fire();
    },
})