/**
* @author Panachai Reinthavorn
*/
function init(config){
	//Filter
	var filterItems = [];
	var fsvpFilterComboBox = createFSVPFilterComboBox({});
	filterItems.push(fsvpFilterComboBox);
	var teamFilterComboBox = createTeamFilterComboBox({});
	filterItems.push(teamFilterComboBox);
	var ownerFilterComboBox = createSalesMemberFilterComboBox({});
	filterItems.push(ownerFilterComboBox);
    var redFlagFilterComboBox = createRedFlagFilterPicklists({});
    filterItems.push(redFlagFilterComboBox);

    //Grid
    var tableItems = [];
    var EVPTargetGrid = createEVPTargetTable();
    EVPTargetGrid.show();
    tableItems.push(EVPTargetGrid);
    var teamTargetGrid = createTeamTargetTable();
    tableItems.push(teamTargetGrid);
    var salesTargetTeamGrid = createSalesTargetTable('teamLevel');
    tableItems.push(salesTargetTeamGrid);
    var salesTargetRMGrid = createSalesTargetTable('rmLevel');
    tableItems.push(salesTargetRMGrid);
    var bottomUpAnnualizedGrid = createBottomUpTable();
    tableItems.push(bottomUpAnnualizedGrid);
    //Events
	fsvpFilterComboBox.on('select', function(thisCombo,record) {
        var selectedFSVPEmployeeId = thisCombo.getValue();
        teamFilterComboBox.setValue('');
        ownerFilterComboBox.setValue('');
        ownerFilterComboBox.setDisabled(true);
        if(selectedFSVPEmployeeId !== 'ALL'){
            teamFilterComboBox.store.removeAll();
            teamFilterComboBox.store.reload({
                params:{
                    fsvpID:selectedFSVPEmployeeId
                }
           });
           var teamTargetsStore = teamTargetGrid.getStore();
           teamTargetsStore.model.proxy.extraParams.filter = [{'FSVPEmployeeID':selectedFSVPEmployeeId}];
           teamTargetsStore.reload();
           teamFilterComboBox.setDisabled(false);
           redFlagFilterComboBox.hide();
           redFlagFilterComboBox.setValue('ALL');
           redFlagFilterComboBox.setDisabled(true);
           EVPTargetGrid.hide();
           teamTargetGrid.show();
           salesTargetRMGrid.hide();
           salesTargetTeamGrid.hide();
           bottomUpAnnualizedGrid.hide();
        }else{
            //All FSVPs is selected,Show only FSVP target table.
            teamFilterComboBox.store.removeAll();
            teamFilterComboBox.setValue('');
            teamFilterComboBox.setDisabled(true);
            ownerFilterComboBox.store.removeAll();
            ownerFilterComboBox.setValue('');
            ownerFilterComboBox.setDisabled(true);
            redFlagFilterComboBox.hide();
            redFlagFilterComboBox.setValue('ALL');
            redFlagFilterComboBox.setDisabled(true);
            EVPTargetGrid.show();
            teamTargetGrid.hide();
            salesTargetRMGrid.hide();
            salesTargetTeamGrid.hide();
            bottomUpAnnualizedGrid.hide();
        }
    });
    teamFilterComboBox.on('select', function(thisCombo,record) {
        var selectedTeamRCCode = thisCombo.getValue();
        ownerFilterComboBox.setValue('');
        bottomUpAnnualizedGrid.getStore().removeFilter('userEmployeeIDFilter');
        bottomUpAnnualizedGrid.getStore().removeFilter('userRCCodeFilter');
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
                    id: 'userRCCodeFilter',
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
            EVPTargetGrid.hide();
            teamTargetGrid.hide();
            salesTargetRMGrid.hide();
            salesTargetTeamGrid.show();
            bottomUpAnnualizedGrid.show();
        }else{
            ownerFilterComboBox.setDisabled(true);
            redFlagFilterComboBox.hide();
            redFlagFilterComboBox.setValue('ALL');
            redFlagFilterComboBox.setDisabled(true);
            EVPTargetGrid.hide();
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
                    id: 'userEmployeeIDFilter',
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
            EVPTargetGrid.hide();
            teamTargetGrid.hide();
            bottomUpAnnualizedGrid.show();
            salesTargetTeamGrid.hide();
        }else{
            //show only team target table
            var bottomUpAnnualizedStore = bottomUpAnnualizedGrid.getStore();
            bottomUpAnnualizedStore.reload();
            bottomUpAnnualizedStore.removeFilter('userEmployeeIDFilter');
            var selectedTeamRCCode = teamFilterComboBox.getValue();
            bottomUpAnnualizedStore.filter([
                {
                    id: 'userRCCodeFilter',
                    property : 'Sales_Target__r.Name__r.User__r.RC_Code__c',
                    value    : '#'+selectedTeamRCCode
                }
            ]);            
            redFlagFilterComboBox.show();
            redFlagFilterComboBox.setDisabled(false);
            redFlagFilterComboBox.setValue('ALL');
            salesTargetTeamGrid.show();
            salesTargetRMGrid.hide();
            teamTargetGrid.hide();
            EVPTargetGrid.hide();
            bottomUpAnnualizedGrid.show();
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