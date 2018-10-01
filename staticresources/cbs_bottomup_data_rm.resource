/**
* @author Panachai Reinthavorn
*/
function init(config){
	//Filter
	var filterItems = [];
	var redFlagFilterComboBox = createRedFlagFilterPicklists({});
	redFlagFilterComboBox.show();
	redFlagFilterComboBox.setDisabled(false);
    filterItems.push(redFlagFilterComboBox);
    //Grid
	var tableItems = [];
	var salesTargetRMGrid = createSalesTargetTable('individualLevel');
	var salesTargetRMStore = salesTargetRMGrid.getStore();
    salesTargetRMStore.model.proxy.extraParams.filter = [{teamRCCode:'none',salesEmployeeId:currentUserEmployeeID}];
    salesTargetRMStore.reload();
	salesTargetRMGrid.show();
	tableItems.push(salesTargetRMGrid);
	var bottomUpAnnualizedGrid = createBottomUpTable();
	var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.filter([
                {
                    property : 'Sales_Target__r.Name__r.User__r.Employee_ID__c',
                    value    : '#'+currentUserEmployeeID
                },
                {
                    property : 'Year__c',
                    value    : '#'+currentYear
                }
            ]);
	bottomUpAnnualizedGrid.show();
	tableItems.push(bottomUpAnnualizedGrid);
	//Display
	var filterDropDownPanel = createFilterPanel(filterItems);
	filterDropDownPanel.show();
	config.filter_items = [filterDropDownPanel];
	for(let index=0;index<tableItems.length;index++){
		config.table_items.push(tableItems[index]);
	}
	//hide TL Column
    var gridColumns = bottomUpAnnualizedGrid.getColumns();
    console.log('gridColumns >> ',gridColumns);
    gridColumns[5].setHidden(true);
}