/**
* @author Panachai Reinthavorn
*/
function forceLoadTeamFilterStore(teamFilterComboBox){
	teamFilterComboBox.store.reload({
	        params:{
	            fsvpID:'ALL'
	        }
	   	});
}
function init(config){
	//Filter
	var filterItems = [];
	var teamFilterComboBox = createTeamFilterComboBox({});
	teamFilterComboBox.setDisabled(false);
	filterItems.push(teamFilterComboBox);
	var ownerFilterComboBox = createSalesMemberFilterComboBox({});
	filterItems.push(ownerFilterComboBox);
    var redFlagFilterComboBox = createRedFlagFilterPicklists({});
    filterItems.push(redFlagFilterComboBox);
	//Grid
	var tableItems = [];
	var teamTargetGrid = createTeamTargetTable();
	teamTargetGrid.getStore().model.proxy.extraParams.filter = [{FSVPEmployeeID:'ALL'}];
	teamTargetGrid.getStore().reload();
    teamTargetGrid.show();
	tableItems.push(teamTargetGrid);
	var salesTargetTeamGrid = createSalesTargetTable('teamLevel');
	tableItems.push(salesTargetTeamGrid);
	var salesTargetRMGrid = createSalesTargetTable('individualLevel');
	tableItems.push(salesTargetRMGrid);
	var bottomUpAnnualizedGrid = createBottomUpTable();
	tableItems.push(bottomUpAnnualizedGrid);
    //Events
	teamFilterComboBox.on('afterRender', function(thisCombo,record) {
	    forceLoadTeamFilterStore(this);
	});
	teamFilterComboBox.on('select', function(thisCombo,record) {
	    var selectedTeamRCCode = thisCombo.getValue();
        ownerFilterComboBox.setValue('');
        bottomUpAnnualizedGrid.getStore().removeFilter('UserEmployeeIDFilter');
        if(selectedTeamRCCode !== 'ALL'){
            //show sales target table of selected team
            ownerFilterComboBox.store.removeAll();
            ownerFilterComboBox.store.reload({
                params:{
                    teamRCCode:selectedTeamRCCode
                }
            });
            ownerFilterComboBox.setDisabled(false);
            var salesTargetsTeamStore = salesTargetTeamGrid.getStore();
            salesTargetsTeamStore.model.proxy.extraParams.filter = [{teamRCCode:selectedTeamRCCode,salesEmployeeId:'none'}];
            salesTargetsTeamStore.reload();
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.filter([
                {
                    id : 'userRCCodeFilter',
                    property : 'Sales_Target__r.Name__r.User__r.RC_Code__c',
                    value    : '#'+selectedTeamRCCode
                },
                {
                    property : 'Year__c',
                    value    : '#'+currentYear
                }
            ]);
            redFlagFilterComboBox.show();
            redFlagFilterComboBox.setDisabled(false);
            salesTargetTeamGrid.show();
            teamTargetGrid.hide();
            salesTargetRMGrid.hide();
            bottomUpAnnualizedGrid.show();
        }else{
            ownerFilterComboBox.setDisabled(true);
            redFlagFilterComboBox.hide();
            redFlagFilterComboBox.setValue('ALL');
            redFlagFilterComboBox.setDisabled(true);
            //show only team target table
            teamTargetGrid.show();
            salesTargetTeamGrid.hide();
            salesTargetRMGrid.hide();
            bottomUpAnnualizedGrid.hide();
        }
	});
	ownerFilterComboBox.on('select', function(thisCombo,record) {
        var selectedSalesEmployeeID = thisCombo.getValue();
        if(selectedSalesEmployeeID !== 'ALL'){
            //show sales target table of selected team
            var salesTargetRMStore = salesTargetRMGrid.getStore();
            salesTargetRMStore.model.proxy.extraParams.filter = [{teamRCCode:'none',salesEmployeeId:selectedSalesEmployeeID}];
            salesTargetRMStore.reload();
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.filter([
                {
                    id : 'UserEmployeeIDFilter',
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
            teamTargetGrid.hide();
            bottomUpAnnualizedGrid.show();
            salesTargetTeamGrid.hide();
        }else{
            //show only team target table
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.removeFilter('UserEmployeeIDFilter');
            var selectedTeamRCCode = teamFilterComboBox.getValue();
            bottomUpAnnualizedStore.filter([
                {
                    property : 'Sales_Target__r.Name__r.User__r.RC_Code__c',
                    value    : '#'+selectedTeamRCCode
                }
            ]);            
            redFlagFilterComboBox.show();
            redFlagFilterComboBox.setValue('ALL');
            redFlagFilterComboBox.setDisabled(false);
            teamTargetGrid.hide();
            bottomUpAnnualizedGrid.show();
            salesTargetTeamGrid.show();
            salesTargetRMGrid.hide();
        }
    });
	//display
	var filterDropDownPanel = createFilterPanel(filterItems);
	filterDropDownPanel.show();
	config.filter_items = [filterDropDownPanel];
	for(let index=0;index<tableItems.length;index++){
		config.table_items.push(tableItems[index]);
	}
}