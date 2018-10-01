/**
* @author Panachai Reinthavorn
*/
function forceLoadOwnerFilterStoreWithCurrentRCCode(ownerFilterComboBox){
	ownerFilterComboBox.store.reload({
	        params:{
	            teamRCCode:currentUserRCCode,
	            isTL:true
	        }
	   	});
}
function init(config){
	//Filter
	var filterItems = [];
	var ownerFilterComboBox = createSalesMemberFilterComboBox({});
	ownerFilterComboBox.setDisabled(false);
	filterItems.push(ownerFilterComboBox);
    var redFlagFilterComboBox = createRedFlagFilterPicklists({});
    redFlagFilterComboBox.show();
    redFlagFilterComboBox.setDisabled(false);
    filterItems.push(redFlagFilterComboBox);
	//Grid
	var tableItems = [];
	var salesTargetTeamGrid = createSalesTargetTable('teamLevel');
	var salesTargetsTeamStore = salesTargetTeamGrid.getStore();
    salesTargetsTeamStore.model.proxy.extraParams.filter = [{teamRCCode:currentUserRCCode,salesEmployeeId:'none'}];
    salesTargetsTeamStore.reload();
	salesTargetTeamGrid.show();
	tableItems.push(salesTargetTeamGrid);
	var salesTargetRMGrid = createSalesTargetTable('individualLevel');
	tableItems.push(salesTargetRMGrid);
	var bottomUpAnnualizedGrid = createBottomUpTable();
	bottomUpAnnualizedGrid.getStore().filter([
                {
                    property: 'Sales_Target__r.Name__r.User__r.RC_Code__c = \'' + currentUserRCCode + '\'',
                    operator: 'AND',
                    value: 'Sales_Target__c IN (SELECT ID FROM Sales_Target__c WHERE (Name__r.User__r.Profile.Name IN (\'CBS-RM\',\'CBS-TM\',\'CBS-TL\')))',
                }
            ]);
	bottomUpAnnualizedGrid.show();
	tableItems.push(bottomUpAnnualizedGrid);
    //Events
	ownerFilterComboBox.on('afterRender', function(thisCombo,record) {
		forceLoadOwnerFilterStoreWithCurrentRCCode(this)
	});
	ownerFilterComboBox.on('select', function(thisCombo,record) {
        var selectedSalesEmployeeID = thisCombo.getValue();
        if(selectedSalesEmployeeID !== 'ALL'){
            //show sales target table of selected team
            var salesTargetRMStore = salesTargetRMGrid.getStore();
            salesTargetRMStore.model.proxy.extraParams.filter = [{teamRCCode:'none',salesEmployeeId:selectedSalesEmployeeID}];
            salesTargetRMStore.reload();
            salesTargetRMGrid.show();
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.filter([
                {
                    id : 'userEmployeeIDFilter',
                    property : 'Sales_Target__r.Name__r.User__r.Employee_ID__c',
                    value    : '#'+selectedSalesEmployeeID
                },
                {
                    property : 'Year__c',
                    value    : '#'+currentYear
                }
            ]);
            redFlagFilterComboBox.show();
            redFlagFilterComboBox.setDisabled(false);
            salesTargetRMGrid.show();
            bottomUpAnnualizedGrid.show();
            salesTargetTeamGrid.hide();
        }else{
            //show only team target table
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.removeFilter('userEmployeeIDFilter');
            bottomUpAnnualizedStore.filter([
                {
                    property : 'Sales_Target__r.Name__r.User__r.RC_Code__c',
                    value    : '#'+currentUserRCCode
                }
            ]);            
            var salesTargetsTeamStore = salesTargetTeamGrid.getStore();
            salesTargetsTeamStore.model.proxy.extraParams.filter = [{teamRCCode:currentUserRCCode,salesEmployeeId:'none'}];
            salesTargetsTeamStore.reload();
            redFlagFilterComboBox.show();
            redFlagFilterComboBox.setDisabled(false);
            redFlagFilterComboBox.setValue('ALL');
            salesTargetTeamGrid.show();
            salesTargetRMGrid.hide();
            bottomUpAnnualizedGrid.show();
        }
    });
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