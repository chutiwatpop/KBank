/**
* @author Panachai Reinthavorn
*/

//Set up variable
var picklistFields = [{"type": "string", "name": "Label"},{"type": "string", "name": "Value"}];
var gridWidth = 1300;
var allowBlank = true;
var gridMargin = '20 0 20 0';
var defaultEmptyTextInComboBox = 'All';
var cellEditingPlugin = {
    ptype: 'cellediting',
    clicksToEdit: 1,
    editing:true
};
Ext.util.Format.currencySign = ' ';
Ext.util.Format.currencyPrecision = 0;
var redFlagPicklistData = [
        {"Label":"All","Value":"ALL"},
        {"Label":"Bottom Up < Annualized","Value":"RED"}
    ];
var filterMargin = '10 10 10 10';
var targetPageSize = 1000;
//Methods
function createFSVPFilterComboBox(config){
    var fsvpStore = createStorePicklistModel(CBS_BottomUp_Controller.getAllFSVPs,{},false);
    var fsvpComboBox = createComboxbox(fsvpFilter_Label,fsvpFilter_Label, false, fsvpStore, defaultEmptyTextInComboBox, 'pname', 'pvalue', false, allowBlank,{id:'fsvpComboBoxId',margin:filterMargin});
    fsvpComboBox.matchFieldWidth = false;
    return fsvpComboBox;
}
function createTeamFilterComboBox(config){
    var teamStore = createStorePicklistModel(CBS_BottomUp_Controller.getTeamsThatRelatedToSelectedFSVP,{},false);
    var teamComboBox = createComboxbox(teamFilter_Label,teamFilter_Label, false, teamStore,defaultEmptyTextInComboBox, 'pname', 'pvalue', false, allowBlank,{id:'teamComboBoxId',lastQuery:'',
        margin:filterMargin});
    teamComboBox.setDisabled(true);
    teamComboBox.matchFieldWidth = false;
    teamComboBox.setWidth(320);
    return teamComboBox;
}
function createSalesMemberFilterComboBox(config){
    var salesMemberStore = createStorePicklistModel(CBS_BottomUp_Controller.getOwnerMemberThatRelatedToSelectedTeam,{},false);      
    var salesMemberComboBox = createComboxbox(ownerFilter_Label,ownerFilter_Label, false, salesMemberStore,defaultEmptyTextInComboBox, 'pname', 'pvalue', false, allowBlank,{id:'ownerComboBoxId',lastQuery:'',
        margin:filterMargin});
    salesMemberComboBox.setDisabled(true);
    salesMemberComboBox.matchFieldWidth = false;
    return salesMemberComboBox;
}
function createSalesMemberFilterComboBoxForTM(config){
    var salesMemberStore = createStorePicklistModel(CBS_BottomUp_Controller.getOwnerMemberThatRelatedToSelectedTeamForTM,{},false);
    var salesMemberComboBox = createComboxbox(ownerFilter_Label,ownerFilter_Label, false, salesMemberStore,defaultEmptyTextInComboBox, 'pname', 'pvalue', false, allowBlank,{id:'ownerComboBoxId',lastQuery:'',
        margin:filterMargin});
    salesMemberComboBox.setDisabled(true);
    return salesMemberComboBox;
}
function createRedFlagFilterPicklists(config){
    //data
    var redFlagData = redFlagPicklistData;
    //model
    var redFlagModel = createLocalModel('redFlagModel',picklistFields);
    //store
    var redFlagStore = createLocalStore(redFlagModel,redFlagData);
    //combo box
    var redFlagFilterComboBox = createLocalComboBox(recordFilter_Label,'Label','Value',redFlagStore,mergeConfig(config,{margin:filterMargin}));
    redFlagFilterComboBox.setValue('All');
    redFlagFilterComboBox.setDisabled(true);
    //event
    redFlagFilterComboBox.on('select',function(thisCombo,record){
        var bottomUpAnnualizedGrid = Ext.getCmp('bottomUpAnnualizedGridId');
        var haveBottomUpAnnualizedGrid = (typeof bottomUpAnnualizedGrid != 'undefined');
        if(haveBottomUpAnnualizedGrid){
            var bottomUpAnnualizedGridStore = bottomUpAnnualizedGrid.getStore();
            var selectedSalesEmployeeID = thisCombo.getValue();
            if(selectedSalesEmployeeID == 'RED'){
                bottomUpAnnualizedGridStore.addFilter([{
                    id: 'bottomUpAnnualizedFlagFilter',
                    property : 'Bottom_Up_Less_Than_Annaulized_Flag__c ',
                    value    : true
                }]);
            }else if(selectedSalesEmployeeID == 'ALL'){
                bottomUpAnnualizedGridStore.removeFilter('bottomUpAnnualizedFlagFilter');
            }
        }
    });
    redFlagFilterComboBox.matchFieldWidth = false;
    return redFlagFilterComboBox;
}
function createFilterPanel(filterItems,config){
    var panel = createPanel(mergeConfig({
        id: 'filterPanel',
        title: filterPanel_Label,
        layout: 'column',
        items: filterItems,
        floating:false,
        width: gridWidth,    
        closable: false
    },config));
    return panel;
}
function createEVPTargetTable(){
    //store
    var queryObj = {};
    createModel('fsvpsTargetModel', 'records', 'Id',
        '', CBS_BottomUp_Controller.queryFSVPTargetTable, queryObj
    );
    var evpTargetStore = createStoreModel('fsvpsTargetModel', targetPageSize, {
        autoLoad:true,
        sorters:[{property:'targetName',direction:'ASC'}]
    });
    //Columns
    var columnWidthSize = 150;
    var fsvpNameColumn = createColumn({
            text     : fsvpFilter_Label,
            flex     : 1,
            sortable : true,
            dataIndex: 'targetName',
            summaryType:'count',
            summaryRenderer: function(value, summaryData, dataIndex) {
                                return Ext.String.format(Summary_Label);
                            }
            });
    var totalMiracleTargetSubColumn = createColumn({
                text     : totalMiracleTarget_ColumnHeaderLabel,
                flex     : 1,
                sortable : true,
                dataIndex: 'totalMiracle',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalMiracle;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                align    : 'right'
    });
    var totalBottomUpSubColumn = createColumn({
                text     : totalBottomUp_ColumnHeaderLabel,
                flex     : 1,
                sortable : true,
                dataIndex: 'totalBottomUp',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                align    : 'right'
    });
    var totalMiracleColumn = createColumn({
            text: totalMiracleIncome_ColumnHeaderLabel,
            width:200,
            columns: [
                totalMiracleTargetSubColumn,
                totalBottomUpSubColumn
                ]
        });
    var transactionFeeTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var transactionFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var transactionFeeColumn = createColumn({
                text: TransactionFee_Label,
                columns: [
                        transactionFeeTeamTargetSubColumn,
                        transactionFeeBottomUpSummarySubColumn
                    ]
                });
    var mainOperatingBankTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var mainOperatingBankBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var mainOperatingBankColumn = createColumn({
                text: MainOperatingBank_Label,
                columns: [
                    mainOperatingBankTeamTargetSubColumn,
                    mainOperatingBankBottomUpSummarySubColumn
                    ]
                });
    var dealBaseFeeTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var dealBaseFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var dealBaseFeeColumn = createColumn({
                text: DealBaseFee_Label,
                columns: [
                    dealBaseFeeTeamTargetSubColumn,
                    dealBaseFeeBottomUpSummarySubColumn
                ]
            });
    var evpTargetColumns = [
            fsvpNameColumn,
            totalMiracleColumn,
            transactionFeeColumn,
            mainOperatingBankColumn,
            dealBaseFeeColumn
        ];
    var exportToCSVButton = createButton(exportToCSVButton_Label,
        {
            handler:function(){
                var exportedCSV = exportToCSV('evpTargetGridId',CBSBottomUp_Exported_File_Label_All_FSVP_Table_Label+getTodayInDDMMYYYYFormat(),',', true);
            }
        });
    var toolbarSpacer = createToolbarSpacer({});
    //Grid
    var config = {
        id:'evpTargetGridId',
        features: [
            {
                ftype: 'summary'
            }
        ],
        width:gridWidth,
        dockedItems: [
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    toolbarSpacer,
                    exportToCSVButton
                ]
            }
        ],
        margin:gridMargin
    };
    var evpTargetGrid = createSimpleGrid(fsvpTargetTableName_Label,evpTargetStore,evpTargetColumns,config);
    evpTargetGrid.hide();
    return evpTargetGrid;
}
function createTeamTargetTable(){
    //store
    var queryObj = {filter:[{FSVPEmployeeID:'none'}]};
    createModel('teamsTargetModel', 'records', 'Id',
        '', CBS_BottomUp_Controller.queryTeamTargetTable, queryObj
    );
    var teamTargetStore = createStoreModel('teamsTargetModel', targetPageSize, {
        id:'teamTargetStoreId',
        autoLoad:true,
        sorters:[{property:'targetName',direction:'ASC'}]
    });
    //Columns
    var columnWidthSize = 140;
    var teamNameColumn = createColumn({
                    text : teamFilter_Label,
                    flex     : 1,
                    sortable : true,
                    width    : 200,
                    dataIndex: 'targetName',
                    summaryType:'count',
                    summaryRenderer: function(value, summaryData, dataIndex) {
                                        return Ext.String.format(Summary_Label);
                                    }
                });
    var totalMiracleTargetSubColumn = createColumn({
                text     : totalMiracleTarget_ColumnHeaderLabel,
                width    : columnWidthSize,
                sortable : true,
                dataIndex: 'totalMiracle',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalMiracle;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                align    : 'right'
    });
    var totalBottomUpSubColumn = createColumn({
                text     : totalBottomUp_ColumnHeaderLabel,
                width    : columnWidthSize,
                sortable : true,
                dataIndex: 'totalBottomUp',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                align    : 'right'
    });
    var totalMiracleColumn = createColumn({
            text: totalMiracleIncome_ColumnHeaderLabel,
            columns: [
                totalMiracleTargetSubColumn,
                totalBottomUpSubColumn
                ]
        });
    var transactionFeeTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var transactionFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var transactionFeeColumn = createColumn({
                text: TransactionFee_Label,
                columns: [
                    transactionFeeTeamTargetSubColumn,
                    transactionFeeBottomUpSummarySubColumn
                    ]
                });
    var mainOperatingBankTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var mainOperatingBankBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var mainOperatingBankColumn = createColumn({
                    text: MainOperatingBank_Label,
                    columns: [
                        mainOperatingBankTeamTargetSubColumn,
                        mainOperatingBankBottomUpSummarySubColumn]
                });
    var dealBaseFeeTeamTargetSubColumn = createColumn({
                    text     : TeamTarget_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeTarget',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var dealBaseFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeBottomUp',
                    renderer: function(value,record){
                        var valueInCurrencyFormat = Ext.util.Format.currency(value);
                        return valueInCurrencyFormat;
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var dealBaseFeeColumn = createColumn({
                    text: DealBaseFee_Label,
                    columns: [
                        dealBaseFeeTeamTargetSubColumn,
                        dealBaseFeeBottomUpSummarySubColumn
                        ]
                });
    var teamTargetColumns = [
            teamNameColumn,
            totalMiracleColumn,
            transactionFeeColumn,
            mainOperatingBankColumn,
            dealBaseFeeColumn
        ];
    var exportToCSVButton = createButton(exportToCSVButton_Label,{
        handler:function(){
            var exportedCSV = exportToCSV('teamTargetGridId',CBSBottomUp_Exported_File_Label_All_Team_Table+getTodayInDDMMYYYYFormat(),',', true);
        }
    });
    var toolbarSpacer = createToolbarSpacer({});
    //Grid
    var config = {
        id:'teamTargetGridId',
        features: [
            {
                ftype: 'summary'
            }
        ],
        width:gridWidth,
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'top',
            items: [
                toolbarSpacer,
                exportToCSVButton
            ]
        }],
        margin:gridMargin
    };
    var teamTargetGrid = createSimpleGrid(teamTargetTableName_Label,teamTargetStore,teamTargetColumns,config);
    teamTargetGrid.hide();
    return teamTargetGrid;
}
function createSalesTargetTable(tableLevel){
    var isTeamLevelTM = (tableLevel == 'teamLevelTM');
    var isTeamLevel = (tableLevel == 'teamLevel' || isTeamLevelTM);
    var queryObj = {filter:[{teamRCCode:'none',salesEmployeeId:'none'}]};
    createModel('salesTargetModel', 'records', 'Id','', CBS_BottomUp_Controller.querySalesTargetTable, queryObj);
    var salesTargetStore = createStoreModel('salesTargetModel', targetPageSize, {
        autoLoad:true,
        sorters:[{property:'targetName',direction:'ASC'}],
        autosort:false,
        remoteSort:false,
    });
    var TransactionFeeTeamTarget;
    var MainOperatingBankTeamTarget;
    var DealBaseFeeTeamTarget;
    //change header if it's sales target for team
    salesTargetStore.on('load',function(store,records,opts){
        if(isTeamLevel && records.length > 0 && !isTeamLevelTM){
            TransactionFeeTeamTarget = Ext.util.Format.currency(records[0].data.transactionFeeTeamTarget);
            MainOperatingBankTeamTarget = Ext.util.Format.currency(records[0].data.mainOperatingBankTeamTarget);
            DealBaseFeeTeamTarget = Ext.util.Format.currency(records[0].data.dealBaseFeeTeamTarget);
            document.getElementById('printTransactionFee').innerHTML = (isTeamLevelTM)?'':'<p><table style="border: 1px;"><tr><td style="border: 1px;width:165px;">'+TeamTarget_Label+'</td><td style="border: 1px;width:165px;">'+TransactionFeeTeamTarget+'</td></tr></table>';
            document.getElementById('printMainOperatingBank').innerHTML = (isTeamLevelTM)?'':'<p><table style="border: 1px;"><tr><td style="border: 1px;width:165px;">'+TeamTarget_Label+'</td><td style="border: 1px;width:165px;">'+MainOperatingBankTeamTarget+'</td></tr></table></p>';
            document.getElementById('printDealBaseFee').innerHTML = (isTeamLevelTM)?'':'<p><table style="border: 1px;"><tr><td style="border: 1px;width:165px;">'+TeamTarget_Label+'</td><td style="border: 1px;width:165px;">'+DealBaseFeeTeamTarget+'</td></tr></table></p>';
            var totalTeamTarget = Ext.util.Format.currency(+records[0].data.transactionFeeTeamTarget + +records[0].data.mainOperatingBankTeamTarget + +records[0].data.dealBaseFeeTeamTarget);
            document.getElementById('printTotalTeamTarget').innerHTML = (isTeamLevelTM)?'':'<p><table style="border: 1px;"><tr><td style="border: 1px;width:165px;">'+TeamTarget_Label+'</td><td style="border: 1px;width:165px;">'+ totalTeamTarget +'</td></tr></table></p>';
            setSummaryCellClass();
        }
    });
    //Columns
    var columnWidthSize = 140;
    var salesTransactionFeeDisplayInColumneHeader = '<p>'+TransactionFee_Label+'</p><p id="printTransactionFee"></p>';
    var salesMainOperatingBankDisplayInColumnHeader = '<p>'+MainOperatingBank_Label+'</p><p id="printMainOperatingBank"/p>';
    var salesDealBaseFeeDisplayInColumnHeader = '<p>'+DealBaseFee_Label+'</p><p id="printDealBaseFee"/p>';
    var nameColumn = createColumn({
                text     : 'Name',
                flex     : 1,
                sortable : true,
                width    : 200,
                dataIndex: 'targetName',
                summaryType:'count',
                summaryRenderer: function(value, summaryData, dataIndex) {
                                    return Ext.String.format(Summary_Label);
                                }
                });
    var totalMiracleTargetSubColumn = createColumn({
                text     : totalMiracleTarget_ColumnHeaderLabel,
                // flex     : 1,
                width    : columnWidthSize,
                sortable : true,
                dataIndex: 'totalMiracle',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalMiracle;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return '<div id="miracleIncomeTargetSummaryCellId">'+Ext.util.Format.currency(summary)+'</div>';
                    },
                align    : 'right'
    });
    var totalBottomUpSubColumn = createColumn({
                text     : totalBottomUp_ColumnHeaderLabel,
                // flex     : 1,
                width    : columnWidthSize,
                sortable : true,
                dataIndex: 'totalBottomUp',
                renderer: function(data){
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.totalBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                align    : 'right'
    });
    var totalMiracleDisplayInColumneHeader = '<p>'+totalMiracleIncome_ColumnHeaderLabel+'</p><p id="printTotalTeamTarget"></p>';
    var totalMiracleColumn = createColumn({
            text: totalMiracleDisplayInColumneHeader,
            columns: [
                totalMiracleTargetSubColumn,
                totalBottomUpSubColumn
                ]
        });
    var salesTransactionFeeTargetSubColumn = createColumn({
                    text     : Target_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeTarget',
                    editor: 'numberfield',
                    editable:true,
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return '<div id="salesTransactionFeeTargetSummaryCellId">'+Ext.util.Format.currency(summary)+'</div>';
                    },
                    align    : 'right'
                });
    var salesTransactionFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label, 
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'transactionFeeBottomUp',
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.transactionFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var salesTransactionFeeColumn = createColumn({
                text: salesTransactionFeeDisplayInColumneHeader,
                columns: [
                    salesTransactionFeeTargetSubColumn,
                    salesTransactionFeeBottomUpSummarySubColumn
                    ]
            });
    var salesMainOperatingBankTargetSubColumn = createColumn({
                    text     : Target_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankTarget',
                    editor: 'numberfield',
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return '<div id="salesMainOperatingBankTargetSummaryCellId">'+Ext.util.Format.currency(summary)+'</div>';
                    },
                    align    : 'right'
                });
    var salesMainOperatingBankBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'mainOperatingBankBottomUp',
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.mainOperatingBankBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var salesMainOperatingBankColumn = createColumn({
                text: salesMainOperatingBankDisplayInColumnHeader,
                columns: [
                    salesMainOperatingBankTargetSubColumn,
                    salesMainOperatingBankBottomUpSummarySubColumn
                    ]
            });
    var salesDealBaseFeeTeamTargetSubColumn = createColumn({
                    text     : Target_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeTarget',
                    editor: 'numberfield',
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeTarget;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return '<div id="salesDealBaseFeeTargetSummaryCellId">'+Ext.util.Format.currency(summary)+'</div>';
                    },
                    align    : 'right'
                });
    var salesDealBaseFeeBottomUpSummarySubColumn = createColumn({
                    text     : BottomUpSummary_Label,
                    width    : columnWidthSize,
                    sortable : true,
                    dataIndex: 'dealBaseFeeBottomUp',
                    renderer: function(data){
                        if(data == null || typeof data == 'undefined'){
                            return 0;
                        }else{
                            return Ext.util.Format.currency(data);
                        }
                    },
                    summaryType:function(records){
                        var summary = 0;
                        Ext.Array.forEach(records, function (record){
                            var recordData = record.data.dealBaseFeeBottomUp;
                            if(typeof recordData != 'undefined'){
                                summary += recordData;
                            }
                        });
                        return Ext.util.Format.currency(summary);
                    },
                    align    : 'right'
                });
    var salesDealBaseFeeColumn = createColumn({
                text: salesDealBaseFeeDisplayInColumnHeader ,
                columns: [
                    salesDealBaseFeeTeamTargetSubColumn,
                    salesDealBaseFeeBottomUpSummarySubColumn
                    ]
            });
    var columns = [nameColumn,
            totalMiracleColumn,
            salesTransactionFeeColumn,
            salesMainOperatingBankColumn,
            salesDealBaseFeeColumn
        ];
    var saveButton = createButton(saveButton_Label,{
        handler: function() {
                var isSave = confirm('Edited data will be saved. Are you sure you want to proceed saving the records?');
                var salesTargetGrid;
                    if(isTeamLevel){
                        salesTargetGrid = Ext.getCmp('salesTargetTeamLevelGridId');
                    }else{
                        salesTargetGrid = Ext.getCmp('salesTargetRMLevelGridId');
                    }
                if(isSave){
                    var targetMeet = isTargetMeet(salesTargetGrid);
                    if(targetMeet){
                        var salesTargetGridData = salesTargetGrid.getStore().getData();
                        var requestSaveRecords = [];
                        for (var i = 0; i <salesTargetGridData.items.length;i++) {
                            var record = salesTargetGridData.items[i];
                            var data = record.data;
                            var isRecordChanged = record.dirty;
                            if(isRecordChanged){
                                var requestSaveRecord = {
                                    salesTargetId : data.Id,
                                    transactionFeeTarget : (typeof data.transactionFeeTarget != 'undefined' && data.transactionFeeTarget != null)?data.transactionFeeTarget:0,
                                    mainOperatingBankTarget : (typeof data.mainOperatingBankTarget != 'undefined' && data.mainOperatingBankTarget != null)?data.mainOperatingBankTarget:0,
                                    dealBaseFeeTarget : (typeof data.dealBaseFeeTarget != 'undefined' && data.dealBaseFeeTarget != null)?data.dealBaseFeeTarget:0,
                                };
                                requestSaveRecords.push(requestSaveRecord);    
                            }
                        }
                        Ext.Deferred
                            .all([sendRequest('saveSalesTargetTable', {
                                salesTargetRequests : requestSaveRecords
                            })])
                            .then(function(results) {
                                //commitChanges will remove dirty
                                salesTargetGrid.getStore().commitChanges();
                                salesTargetGrid.getStore().reload();
                                // alert('Save complete');
                            }, function(errors) {
                            });
                    }else{
                        alert(targetDoesntMeetErrorMessage_Label);
                    }
                }else{
                    salesTargetGrid.getStore().reload();
                }
            }
    });
    var cancelButton = createButton(cancelButton_Label,{
        handler: function() {
            var isCancel = confirm('Edited data will be discarded. Are you sure you want to cancel?');
            if(isCancel){
                salesTargetGrid.getStore().reload();
            }
        }
    });
    var toolbarSpacer = createToolbarSpacer({});
    //Grid
    var config = {
            width:gridWidth,
            margin:gridMargin
        };
    var IsSalesTransactionFeeTargetSummaryEqualsSalesTransactionFeeTeamTarget = function(salesTargetGridData){
                    var isEquals;
                    var SalesTransactionFeeTeamTarget = salesTargetGridData[0].get('transactionFeeTeamTarget');
                    var salesTransactionFeeTargetSummary = 0;
                    Ext.Array.forEach(salesTargetGridData, function (record){
                        var transactionFeeTarget = record.get('transactionFeeTarget');
                        transactionFeeTarget = (typeof transactionFeeTarget != 'undefined')?transactionFeeTarget:0;
                        salesTransactionFeeTargetSummary += transactionFeeTarget;
                    });
                    if(salesTransactionFeeTargetSummary == SalesTransactionFeeTeamTarget){
                        return true;
                    }else{
                        return false;
                    }
                };
    var IsMainOperatingBankTargetSummaryEqualsMainOperatingBankTeamTarget = function(salesTargetGridData){
                    var isEquals;
                    var MainOperatingBankTeamTarget = salesTargetGridData[0].get('mainOperatingBankTeamTarget');
                    var MainOperatingBankTargetSummary = 0;
                    Ext.Array.forEach(salesTargetGridData, function (record){
                        var mainOperatingBankTarget = record.get('mainOperatingBankTarget');
                        mainOperatingBankTarget = (typeof mainOperatingBankTarget != 'undefined')?mainOperatingBankTarget:0;
                        MainOperatingBankTargetSummary += mainOperatingBankTarget;
                    });
                    if(MainOperatingBankTargetSummary == MainOperatingBankTeamTarget){
                        return true;
                    }else{
                        return false;
                    }
                };
    var IsDealBaseFeeTargetSummaryEqualsDealBaseFeeTeamTarget = function(salesTargetGridData){
                    var isEquals;
                    var DealBaseFeeTeamTarget = salesTargetGridData[0].get('dealBaseFeeTeamTarget');
                    var DealBaseFeeTeamTargetSummary = 0;
                    Ext.Array.forEach(salesTargetGridData, function (record){
                        var dealBaseFeeTarget = record.get('dealBaseFeeTarget');
                        dealBaseFeeTarget = (typeof dealBaseFeeTarget != 'undefined')?dealBaseFeeTarget:0;
                        DealBaseFeeTeamTargetSummary += dealBaseFeeTarget;
                    });
                    if(DealBaseFeeTeamTargetSummary == DealBaseFeeTeamTarget){
                        return true;
                    }else{
                        return false;
                    }
                };
    var IsMiracleIncomeTargetSummaryEqualsMiracleIncomeTeamTarget = function(salesTargetGridData){
        var isEquals;
        var transactionFeeTeamTarget = (typeof salesTargetGridData[0].get('transactionFeeTeamTarget') != 'undefined')?salesTargetGridData[0].get('transactionFeeTeamTarget'):0;
        var mainOperatingBankTeamTarget = (typeof salesTargetGridData[0].get('mainOperatingBankTeamTarget') != 'undefined')?salesTargetGridData[0].get('mainOperatingBankTeamTarget'):0;
        var dealBaseFeeTeamTarget = (typeof salesTargetGridData[0].get('dealBaseFeeTeamTarget') != 'undefined')?salesTargetGridData[0].get('dealBaseFeeTeamTarget'):0;
        var miracleIncomeTeamTarget =  transactionFeeTeamTarget + mainOperatingBankTeamTarget + dealBaseFeeTeamTarget;
        var miracleIncomeTargetSummary = 0;
        Ext.Array.forEach(salesTargetGridData, function (record){
            var totalMiracleTarget = record.get('totalMiracle');
            totalMiracleTarget = (typeof totalMiracleTarget != 'undefined')?totalMiracleTarget:0;
            miracleIncomeTargetSummary += totalMiracleTarget;
        });
        if(miracleIncomeTargetSummary == miracleIncomeTeamTarget){
            return true;
        }else{
            return false;
        }
    };
    var setSummaryCellClass = function(){
        var salesTargetGridData = salesTargetGrid.getStore().getData().items;
        var salesTransactionFeeTargetSummaryIsEqualsSalesTransactionFeeTeamTarget = IsSalesTransactionFeeTargetSummaryEqualsSalesTransactionFeeTeamTarget(salesTargetGridData);
        if(salesTransactionFeeTargetSummaryIsEqualsSalesTransactionFeeTeamTarget){
            document.getElementById("salesTransactionFeeTargetSummaryCellId").className = "";
        }else{
            document.getElementById("salesTransactionFeeTargetSummaryCellId").className = "redSummaryCell";
        }
        var mainOperatingBankTargetTargetSummaryIsEqualsmainOperatingBankTargetTeamTarget = IsMainOperatingBankTargetSummaryEqualsMainOperatingBankTeamTarget(salesTargetGridData);
        if(mainOperatingBankTargetTargetSummaryIsEqualsmainOperatingBankTargetTeamTarget){
            document.getElementById("salesMainOperatingBankTargetSummaryCellId").className = "";
        }else{
            document.getElementById("salesMainOperatingBankTargetSummaryCellId").className = "redSummaryCell";
        }
        var dealBaseFeeTargetTargetSummaryIsEqualsdealBaseFeeTargetTeamTarget = IsDealBaseFeeTargetSummaryEqualsDealBaseFeeTeamTarget(salesTargetGridData);
        if(dealBaseFeeTargetTargetSummaryIsEqualsdealBaseFeeTargetTeamTarget){
            document.getElementById("salesDealBaseFeeTargetSummaryCellId").className = "";
        }else{
            document.getElementById("salesDealBaseFeeTargetSummaryCellId").className = "redSummaryCell";
        }
        var miracleIncomeTargetSummaryIsEqualsMiracleIncomeTeamTarget = IsMiracleIncomeTargetSummaryEqualsMiracleIncomeTeamTarget(salesTargetGridData);
        if(miracleIncomeTargetSummaryIsEqualsMiracleIncomeTeamTarget){
            document.getElementById("miracleIncomeTargetSummaryCellId").className = "";
        }else{
            document.getElementById("miracleIncomeTargetSummaryCellId").className = "redSummaryCell";
        }
    };
    //If it's Sales Target Grid in Team Level,this grid must have summary row and ability to edit cell
    if(isTeamLevel){
        var summaryFeatures = {
            ftype: 'summary',
            showSummaryRow:true
        };
        config.features = [summaryFeatures];
        config.listeners = {
            edit:function(){
                setSummaryCellClass();
                var e = arguments[1];
                var newValue = e.value;
                if(newValue === null){
                    var theCell = Ext.get(e.cell);
                    theCell.removeCls('x-grid-dirty-cell');
                }
            },
            sortchange:function(){
                setSummaryCellClass();
            }
        }
    }
    config.id = (isTeamLevel)?'salesTargetTeamLevelGridId':'salesTargetRMLevelGridId';
    if(isTeamLevel){
        var exportToCSVButton = createButton(exportToCSVButton_Label,{
            handler:function(){
                var exportedCSV = exportToCSV('salesTargetTeamLevelGridId',CBSBottomUp_Exported_File_Label_Sales_Target_Label+getTodayInDDMMYYYYFormat(),',', true);
            }
        });
    }else{
        var exportToCSVButton = createButton(exportToCSVButton_Label,{
            handler:function(){
                var exportedCSV = exportToCSV('salesTargetRMLevelGridId',CBSBottomUp_Exported_File_Label_Sales_Target_Label+getTodayInDDMMYYYYFormat(),',', true);
            }
        });
    }
    var salesTargetGrid = createSimpleGrid(salesTargetTableName_Label,salesTargetStore,columns,config);
    //canEditTargetTable is a custom setting,used to enable sales user to edit in chosen period
    if(canEditTargetTable){
        salesTargetGrid.addPlugin(cellEditingPlugin);
        var salesTargetGridColumns = salesTargetGrid.getColumns();
        //Set css class
        console.log('salesTargetGridColumns>>',salesTargetGridColumns);
        salesTargetGridColumns[3].tdCls = 'editableTD';
        salesTargetGridColumns[5].tdCls = 'editableTD';
        salesTargetGridColumns[7].tdCls = 'editableTD';
        //Add buttons
        salesTargetGrid.addDocked([{
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    toolbarSpacer,
                    saveButton,
                    cancelButton,
                    exportToCSVButton
                ]
            }]);
    }else{
        salesTargetGrid.addDocked([{
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    toolbarSpacer,
                    exportToCSVButton
                ]
            }]);
    }
    salesTargetGrid.hide(); 
    return salesTargetGrid; 
}
function isTargetMeet(salesTargetGrid){
    var salesTargetGridDataItems = salesTargetGrid.getStore().getData().items;
    var summaryTransactionFeeTarget = 0;
    var summaryMainOperatingBankTarget = 0;
    var summaryDealBaseFeeTarget = 0;
    var targetMeet;
    var transactionFeeTeamTarget;
    var mainOperatingBankTeamTarget;
    var dealBaseFeeTeamTarget;
    Ext.Array.forEach(salesTargetGridDataItems, function (record){
            if(typeof transactionFeeTeamTarget == 'undefined'){
                transactionFeeTeamTarget = (typeof salesTargetGridDataItems[0].data.transactionFeeTeamTarget != 'undefined' && salesTargetGridDataItems[0].data.transactionFeeTeamTarget != null)?salesTargetGridDataItems[0].data.transactionFeeTeamTarget:0;
            }
            if(typeof mainOperatingBankTeamTarget == 'undefined'){
                mainOperatingBankTeamTarget = (typeof salesTargetGridDataItems[0].data.mainOperatingBankTeamTarget != 'undefined' && salesTargetGridDataItems[0].data.mainOperatingBankTeamTarget != null)?salesTargetGridDataItems[0].data.mainOperatingBankTeamTarget:0;
            }
            if(typeof dealBaseFeeTeamTarget == 'undefined'){
                dealBaseFeeTeamTarget = (typeof salesTargetGridDataItems[0].data.dealBaseFeeTeamTarget != 'undefined' && salesTargetGridDataItems[0].data.dealBaseFeeTeamTarget != null)?salesTargetGridDataItems[0].data.dealBaseFeeTeamTarget:0;
            }
            if(typeof record.data.transactionFeeTarget != 'undefined'){
                summaryTransactionFeeTarget += record.data.transactionFeeTarget;
            }
            if(typeof record.data.mainOperatingBankTarget != 'undefined'){
                summaryMainOperatingBankTarget += record.data.mainOperatingBankTarget;
            }
            if(typeof record.data.dealBaseFeeTarget != 'undefined'){
                summaryDealBaseFeeTarget += record.data.dealBaseFeeTarget;
            }
        });
    targetMeet = (summaryTransactionFeeTarget==transactionFeeTeamTarget)&&
                        (summaryMainOperatingBankTarget==mainOperatingBankTeamTarget)&&
                        (summaryDealBaseFeeTarget==dealBaseFeeTeamTarget);
    return targetMeet;
}
function createBottomUpTable(){
    var fieldsNameForBottomUpAnnualizedQuery = 'Id,Name,CIS_ID__c,CIS_ID__r.Sub_Group__c,CIS_ID__r.Group__c,'+
    'CIS_ID__r.CIS__c,CIS_ID__r.Name,CIS_ID__r.RM_Name__c,CIS_ID__r.Owner.ManagerId,CIS_ID__r.Owner.Manager.Name,CIS_ID__r.Owner.Manager.Profile.Name,'+
    'CIS_ID__r.Owner.Manager.ManagerId,CIS_ID__r.Owner.Manager.Manager.Name,CIS_ID__r.Owner.Manager.Manager.Profile.Name,'+
    'Asset_Bad_Flag__c,Sales_Target__r.Name__r.User__r.ManagerId,Is_Active__c,Customer_Name__c,'+
    'BottomUp_TF__c,BottomUp_FX__c,BottomUp_LI__c,BottomUp_SS__c,Total_Transaction_Fee_Bottom_Up__c,BottomUp_Float__c,'+
    'BottomUp_Cash__c,BottomUp_KA__c,Total_Main_Operating_Bank_Bottom_Up__c,BottomUp_Front_End__c,BottomUp_Derivative__c,'+
    'BottomUp_IBB__c,BottomUp_Investment_Fee__c,BottomUp_BA__c,Total_Deal_Base_Fee_Bottom_Up__c,Credit_Wallet_Size_Out__c,'+
    'Credit_Wallet_Size_NII__c,Credit_SOW_NII__c,Annualized_TF__c,Annaulized_FX__c,Annualized_LI__c,Annualized_SS__c,Bottom_Up_Total__c,Annualized_Total__c,'+
    'Total_Annualized_Transaction_Fee__c,Annaulized_Float__c,Annualized_Cash__c,Annualized_KA__c,Total_Annualized_Main_Operating_Bank__c,Sales_Target__r.Is_Active__c,'+
    'Business_Closed__c,Sales_Target__r.Name__r.User__r.Employee_ID__c,Sales_Target__r.Name__r.User__r.RC_Code__c,Bottom_Up_Less_Than_Annaulized_Flag__c';
    var bottomUpAnnualizedFieldsMappingForLookUpFields = [
        {
            name: 'CIS_ID__r.Sub_Group__c',
            mapping: 'CIS_ID__r.Sub_Group__c'
        },{
            name: 'CIS_ID__r.Group__c',
            mapping: 'CIS_ID__r.Group__c'
        },{
            name: 'CIS_ID__r.CIS__c',
            mapping: 'CIS_ID__r.CIS__c'
        },
        // {
        //     name: 'CIS_ID__r.Name',
        //     mapping: 'CIS_ID__r.Name'
        // },
        {
            name: 'CIS_ID__r.RM_Name__c',
            mapping: 'CIS_ID__r.RM_Name__c'
        },{
            name: 'CIS_ID__r.Owner.Manager.Name',
            mapping: function(data){
                var isTL = typeof data.CIS_ID__r.Owner.ManagerId != 'undefined' && typeof data.CIS_ID__r.Owner.Manager.Profile.Name != 'undefined' && data.CIS_ID__r.Owner.Manager.Profile.Name === 'CBS-TL';
                var isTM = typeof data.CIS_ID__r.Owner.ManagerId != 'undefined' && typeof data.CIS_ID__r.Owner.Manager.Profile.Name != 'undefined' && data.CIS_ID__r.Owner.Manager.Profile.Name === 'CBS-TM';
                if(isTM){
                    //assumed only 2 level (get TL over this TM)
                    var TLName = (typeof data.CIS_ID__r.Owner.Manager.ManagerId !=='undefined' && typeof data.CIS_ID__r.Owner.Manager.Manager.Name !== 'undefined')?data.CIS_ID__r.Owner.Manager.Manager.Name:'';
                    return TLName;
                }
                if(isTL){
                    var TLName = (typeof data.CIS_ID__r.Owner.Manager.Name !== 'undefined')?data.CIS_ID__r.Owner.Manager.Name:'';
                    return TLName;
                }
            }
        }
    ];
    createModel('bottomUpAnnualizedModel', 'records', 'Id',
        bottomUpAnnualizedFieldsMappingForLookUpFields, RemoterExtensions.query, {
            sobjname: 'Bottom_Up_Annualized__c',
            fields: fieldsNameForBottomUpAnnualizedQuery
        }
    );
    var bottomUpAnnualizedStore = createStoreModel('bottomUpAnnualizedModel', targetPageSize, {
        autoLoad:true
        ,sorters:[{property:'CIS_ID__r.RM_Name__c',direction:'ASC'}]
        ,groupField:'CIS_ID__r.RM_Name__c',
        autosort:false,
        remoteSort:false,
        remoteFilter:true
    });
    //Columns
    var lockHeadColumn = false;
    var subGroupColumn = createColumn({
                text:SubGroup_Label,
                sortable : true,
                dataIndex: 'CIS_ID__r.Sub_Group__c',
                locked:lockHeadColumn,
                filter:{
                    type: "string",
                    typeahead: false,
                    updateBuffer: 1000,
                    itemDefaults: {
                        emptyText: searchCustomerSubGroup
                    }
                },
                width:100
            });
    var groupColumn = createColumn({
                text:Group_Label,
                sortable : true,
                locked:lockHeadColumn,
                dataIndex: 'CIS_ID__r.Group__c',
                filter:{
                    type: "string",
                    typeahead: false,
                    updateBuffer: 1000,
                    itemDefaults: {
                        emptyText: searchCustomerGroup
                    }
                },
                width:75
            });
    var customerIDColumn = createColumn({
                text:CustomerID_Label,
                sortable : true,
                locked:lockHeadColumn,
                dataIndex: 'CIS_ID__r.CIS__c',
                renderer: function(CISNumber,meta,record){
                    var cisID = record.data.CIS_ID__c;
                    var linkToRelatedCIS = '<a target="_blank" href=\''+(salesForcebaseUrl+'/'+cisID)+'\'>'+CISNumber+'</a>';
                    return linkToRelatedCIS;
                },
                filter:{
                    type: "string",
                    typeahead: false,
                    updateBuffer: 1000,
                    itemDefaults: {
                        emptyText: searchCustomerID
                    }
                },
                width:75
            });
    var customerNameColumn = createColumn({
                text:CustomerName_Label,
                sortable : false,
                dataIndex: 'Customer_Name__c',
                locked:lockHeadColumn,
                renderer:function(data){
                    var imgTag = Ext.util.Format.htmlDecode(data);
                    return imgTag;
                },
                width:125
            });
    var rmColumn = createColumn({
                text:RM_Label,
                sortable : true,
                dataIndex: 'CIS_ID__r.RM_Name__c',
                locked:lockHeadColumn,
                filter:{
                    type: "string",
                    typeahead: false,
                    updateBuffer: 1000,
                    itemDefaults: {
                        emptyText: searchCustomerRM
                    }
                },
                width:75,
                summaryType: function(records){
                    return Summary_Label;
                }
            });
    var tlColumn = createColumn({
                text:TL_Label,
                sortable : true,
                dataIndex: 'CIS_ID__r.Owner.Manager.Name',
                locked:lockHeadColumn,
                filter:{
                    type: "string",
                    typeahead: false,
                    updateBuffer: 1000,
                    itemDefaults: {
                        emptyText: searchCustomerTL
                    }
                },
                width:75
            });
    // var assetBadFlagColumn = createColumn({
    //             text:AssetBadFlag_Label,
    //             sortable : true,
    //             dataIndex: 'Asset_Bad_Flag__c',
    //             summaryType: function(records){
    //                 return Summary_Label;
    //             },
    //             locked:lockHeadColumn,
    //             filter:{
    //                 type: "boolean",
    //                 typeahead: false,
    //                 updateBuffer: 1000,
    //                 yesText:"True",
    //                 noText:"False"
    //             },
    //             width:75
    //         });
    var bottomUpTransactionFeeTFSubColumn = createColumn({
                text:TransactionFee_TF_Label,
                sortable:true,
                dataIndex:'BottomUp_TF__c',
                renderer:function(data,metadata,record){

                    var annualizedVal = (typeof record.get('Annualized_TF__c') != 'undefined')?record.get('Annualized_TF__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_TF__c') != 'undefined')?record.get('BottomUp_TF__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    //title is quick tip on mouse over (qtip has technical problem when using on chrome or ff)
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized TF : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_TF__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var bottomUpTransactionFeeFXSubColumn = createColumn({
                text:TransactionFee_FX_Label,
                sortable:true,
                dataIndex:'BottomUp_FX__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annaulized_FX__c') != 'undefined')?record.get('Annaulized_FX__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_FX__c') != 'undefined')?record.get('BottomUp_FX__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized FX : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_FX__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var bottomUpTransactionFeeLISubColumn = createColumn({
                text:TransactionFee_LI_Label,
                sortable:true,
                dataIndex:'BottomUp_LI__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annualized_LI__c') != 'undefined')?record.get('Annualized_LI__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_LI__c') != 'undefined')?record.get('BottomUp_LI__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized LI : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_LI__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var bottomUpTransactionFeeSSSubColumn = createColumn({
                text:TransactionFee_SS_Label,
                sortable:true,
                dataIndex:'BottomUp_SS__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annualized_SS__c') != 'undefined')?record.get('Annualized_SS__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_SS__c') != 'undefined')?record.get('BottomUp_SS__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized SS : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_SS__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
                });
    var bottomUpTransactionFeeTotalSubColumn = createColumn({
                text:TransactionFee_Total_Label,
                sortable:true,
                dataIndex:'Total_Transaction_Fee_Bottom_Up__c',
                renderer:function(data,metadata,record){
                    var annualizedTF = (typeof record.get('Annualized_TF__c') != 'undefined' && record.get('Annualized_TF__c') != null)?record.get('Annualized_TF__c'):0;
                    var annualizedFX = (typeof record.get('Annaulized_FX__c') != 'undefined' && record.get('Annaulized_FX__c') != null)?record.get('Annaulized_FX__c'):0;
                    var annualizedSS = (typeof record.get('Annualized_LI__c') != 'undefined' && record.get('Annualized_LI__c') != null)?record.get('Annualized_LI__c'):0;
                    var annualizedLI = (typeof record.get('Annualized_SS__c') != 'undefined' && record.get('Annualized_SS__c') != null)?record.get('Annualized_SS__c'):0;
                    var val =  annualizedTF + annualizedFX + annualizedSS + annualizedLI;
                    var customerInfo = record.get('CIS_ID__r.CIS_annualizedSS_c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized Transaction Fee Total : ' + val + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Total_Transaction_Fee_Bottom_Up__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var bottomUpTransactionFeeColumn = createColumn({
                        text: TransactionFee_Label,
                        columns:
                        [
                            bottomUpTransactionFeeTFSubColumn,
                            bottomUpTransactionFeeFXSubColumn,
                            bottomUpTransactionFeeLISubColumn,
                            bottomUpTransactionFeeSSSubColumn,
                            bottomUpTransactionFeeTotalSubColumn
                        ]
                    });
    var mainOperatingBankFloatSubColumn = createColumn({
                text:MainOperatingBank_Float_Label,
                sortable:true,
                dataIndex:'BottomUp_Float__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annaulized_Float__c') != 'undefined')?record.get('Annaulized_Float__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_Float__c') != 'undefined')?record.get('BottomUp_Float__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized Float : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_Float__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var mainOperatingBankCashSubColumn = createColumn({
                text:MainOperatingBank_Cash_Label,
                sortable:true,
                dataIndex:'BottomUp_Cash__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annualized_Cash__c') != 'undefined')?record.get('Annualized_Cash__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_Cash__c') != 'undefined')?record.get('BottomUp_Cash__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized Cash : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_Cash__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var mainOperatingBankKASubColumn = createColumn({
                text:MainOperatingBank_KA_Label,
                sortable:true,
                dataIndex:'BottomUp_KA__c',
                renderer:function(data,metadata,record){
                    var annualizedVal = (typeof record.get('Annualized_KA__c') != 'undefined')?record.get('Annualized_KA__c'):0;
                    var bottomUpVal = (typeof record.get('BottomUp_KA__c') != 'undefined')?record.get('BottomUp_KA__c'):0;
                    if(annualizedVal > bottomUpVal){
                        metadata.tdCls += ' redSummaryCell';
                    }
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\nAnnualized KA : ' + annualizedVal + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_KA__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var mainOperatingBankTotalSubColumn = createColumn({
                text:MainOperatingBank_Total_Label,
                sortable:true,
                dataIndex:'Total_Main_Operating_Bank_Bottom_Up__c',
                renderer:function(data,metadata,record){
                    var annualizedFloat = (typeof record.get('Annaulized_Float__c') != 'undefined' && record.get('Annaulized_Float__c') != null)?record.get('Annaulized_Float__c'):0;
                    var annualizedCash = (typeof record.get('Annualized_Cash__c') != 'undefined' && record.get('Annualized_Cash__c') != null)?record.get('Annualized_Cash__c'):0;
                    var annualizedKA = (typeof record.get('Annualized_KA__c') != 'undefined' && record.get('Annualized_KA__c') != null)?record.get('Annualized_KA__c'):0;
                    var val = annualizedFloat + annualizedCash + annualizedKA;
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo + '\Annualized Main Operating Bank Total : ' + val + '"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Total_Main_Operating_Bank_Bottom_Up__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var mainOperatingBankColumn = createColumn({
                text: MainOperatingBank_Label,
                columns: [
                    mainOperatingBankFloatSubColumn,
                    mainOperatingBankCashSubColumn,
                    mainOperatingBankKASubColumn,
                    mainOperatingBankTotalSubColumn
                ]
            });
    var dealBaseFeeFrontEndSubColumn = createColumn({
                text:DealBaseFee_FrontEnd_Label,
                sortable:true,
                dataIndex:'BottomUp_Front_End__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_Front_End__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var dealBaseFeeDeriverativeSubColumn = createColumn({
                text:DealBaseFee_Derivative_Label,
                sortable:true,
                dataIndex:'BottomUp_Derivative__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_Derivative__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var dealBaseFeeIBBSubColumn = createColumn({
                text:DealBaseFee_IBB_Label,
                sortable:true,
                dataIndex:'BottomUp_IBB__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_IBB__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var dealBaseFeeInvestMentFeeSubColumn = createColumn({
                text:DealBaseFee_InvestmentFee_Label,
                sortable:true,
                dataIndex:'BottomUp_Investment_Fee__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_Investment_Fee__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var dealBaseFeeBASubColumn = createColumn({
                text:DealBaseFee_BA_Label,
                sortable:true,
                dataIndex:'BottomUp_BA__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.BottomUp_BA__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                editor: 'numberfield',
                align:'right'
            });
    var dealBaseFeeTotalSubColumn = createColumn({
                text:DealBaseFee_Total_Label,
                sortable:true,
                dataIndex:'Total_Deal_Base_Fee_Bottom_Up__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Total_Deal_Base_Fee_Bottom_Up__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var dealBaseFeeColumn = createColumn({
                        text     : DealBaseFee_Label,
                        columns: [
                            dealBaseFeeFrontEndSubColumn,
                            dealBaseFeeDeriverativeSubColumn,
                            dealBaseFeeIBBSubColumn,
                            dealBaseFeeInvestMentFeeSubColumn,
                            dealBaseFeeBASubColumn,
                            dealBaseFeeTotalSubColumn
                        ]
                    });
    var totalBottomUpColumn = createColumn({
                text     : totalBottomUp_Label,
                sortable : true,
                dataIndex: 'Bottom_Up_Total__c',
                width:150,
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Bottom_Up_Total__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var bottomUpHeaderColumn = createColumn({
                text: bottomUpTableLabel_Label,
                columns: [
                    totalBottomUpColumn,
                    bottomUpTransactionFeeColumn,
                    mainOperatingBankColumn,
                    dealBaseFeeColumn
                ]
            });
    var creditWalletSizeOutSubColumn = createColumn({
                text     : Credit_WalletSizeOut_Label,
                sortable : true,
                dataIndex: 'Credit_Wallet_Size_Out__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Credit_Wallet_Size_Out__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var creditWalletSizeNIISubColumn = createColumn({
                text     : Credit_WalletSizeNII_Label,
                sortable : true,
                dataIndex: 'Credit_Wallet_Size_NII__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Credit_Wallet_Size_NII__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var creditPercentSOWSubColumn = createColumn({
                text     : Credit_SOWNII_Label,
                sortable : true,
                dataIndex: 'Credit_SOW_NII__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Credit_SOW_NII__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var creditColumn = createColumn({
                text: Credit_Label,
                columns: [
                    creditWalletSizeOutSubColumn,
                    creditWalletSizeNIISubColumn,
                    creditPercentSOWSubColumn
                    ]
            });
    var annualizedTransactionFeeTFSubColumn = createColumn({
                text:TransactionFee_TF_Label,
                sortable:true,
                dataIndex:'Annualized_TF__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annualized_TF__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedTransactionFeeFXSubColumn = createColumn({
                text:TransactionFee_FX_Label,
                sortable:true,
                dataIndex:'Annaulized_FX__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annaulized_FX__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedTransactionFeeLISubColumn = createColumn({
                text:TransactionFee_LI_Label,
                sortable:true,
                dataIndex:'Annualized_LI__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annualized_LI__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedTransactionFeeSSSubColumn = createColumn({
                text:TransactionFee_SS_Label,
                sortable:true,
                dataIndex:'Annualized_SS__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annualized_SS__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedTransactionFeeTotalSubColumn = createColumn({
                text:TransactionFee_Total_Label,
                sortable:true,
                dataIndex:'Total_Annualized_Transaction_Fee__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Total_Annualized_Transaction_Fee__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedTransactionFeeColumn = createColumn({
                        text: TransactionFee_Label,
                        columns:[
                            annualizedTransactionFeeTFSubColumn,
                            annualizedTransactionFeeFXSubColumn,
                            annualizedTransactionFeeLISubColumn,
                            annualizedTransactionFeeSSSubColumn,
                            annualizedTransactionFeeTotalSubColumn
                        ]
                    });
    var annualizedMainOperatingBankFloatSubColumn = createColumn({
                text:MainOperatingBank_Float_Label,
                sortable:true,
                dataIndex:'Annaulized_Float__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annaulized_Float__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedMainOperatingBankCashSubColumn = createColumn({
                text:MainOperatingBank_Cash_Label,
                sortable:true,
                dataIndex:'Annualized_Cash__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annualized_Cash__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedMainOperatingBankKASubColumn = createColumn({
                text:MainOperatingBank_KA_Label,
                sortable:true,
                dataIndex:'Annualized_KA__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Annualized_KA__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedMainOperatingBankTotalSubColumn = createColumn({
                text:MainOperatingBank_Total_Label,
                sortable:true,
                dataIndex:'Total_Annualized_Main_Operating_Bank__c',
                renderer:function(data,metadata,record){
                    var customerInfo = record.get('CIS_ID__r.CIS__c');
                    metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
                    if(data == null || typeof data == 'undefined'){
                        return 0;
                    }else{
                        return Ext.util.Format.currency(data);
                    }
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Total_Annualized_Main_Operating_Bank__c;
                        if(typeof recordData != 'undefined'){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                align:'right'
            });
    var annualizedMainOperatingBankColumn = createColumn({
                        text: MainOperatingBank_Label,
                        columns: [
                            annualizedMainOperatingBankFloatSubColumn,
                            annualizedMainOperatingBankCashSubColumn,
                            annualizedMainOperatingBankKASubColumn,
                            annualizedMainOperatingBankTotalSubColumn
                        ]
                    });
    var totalAnnualizedColumn = createColumn({
        text:totalAnnualized_Label,
        sortable:true,
        dataIndex:'Annualized_Total__c',
        width:150,
        renderer:function(data,metadata,record){
            var customerInfo = record.get('CIS_ID__r.CIS__c');
            metadata.tdAttr = 'title="CIS ID : ' + customerInfo +'"';
            if(data == null || typeof data == 'undefined'){
                return 0;
            }else{
                return Ext.util.Format.currency(data);
            }
        },
        summaryType:function(records){
            var summary = 0;
            Ext.Array.forEach(records, function (record){
                var recordData = record.data.Annualized_Total__c;
                if(typeof recordData != 'undefined'){
                    summary += recordData;
                }
            });
            return Ext.util.Format.currency(summary);
        },
        align:'right'
    });
    var annualizedHeaderColumn = createColumn({
                text: annualizedTableLabel_Label,
                columns: [
                    annualizedTransactionFeeColumn,
                    annualizedMainOperatingBankColumn,
                    totalAnnualizedColumn
                ]
            });
    var closeDownEditor = {
                    xtype: 'combo',
                    store: ['Yes', 'No'],
                    editable:false
                };
    var closeDownColumn = createColumn({
                text: CloseBusiness_Label,
                sortable:true,
                dataIndex:'Business_Closed__c',
                editor: closeDownEditor,
                align:'center'
            });
    var columnsConfig = [
            subGroupColumn,
            groupColumn,
            customerIDColumn,
            customerNameColumn,
            rmColumn,
            tlColumn,
            // assetBadFlagColumn,
            bottomUpHeaderColumn,
            creditColumn,
            annualizedHeaderColumn,
            closeDownColumn
        ];
    var saveButton = createButton(saveButton_Label,
        {
            handler: function() {
                    var isSave = confirm('Edited data will be saved. Are you sure you want to proceed saving the records?');
                    var bottomUpAnnualizedGrid = Ext.getCmp('bottomUpAnnualizedGridId');
                    if(isSave){
                        var bottomUpAnnualizedGridData = bottomUpAnnualizedGrid.getStore().getData();
                        var requestSaveRecords = [];
                        for (var i = 0; i <bottomUpAnnualizedGridData.items.length;i++) {
                            var record = bottomUpAnnualizedGridData.items[i];
                            var data = record.data;
                            var isRecordChanged = record.dirty;
                            if(isRecordChanged){
                                var requestSaveRecord = {
                                    bottomUpAnnualizedId : data.Id,
                                    transactionFeeTF : (typeof data.BottomUp_TF__c != 'undefined' && data.BottomUp_TF__c != null)?data.BottomUp_TF__c:0,
                                    transactionFeeFX : (typeof data.BottomUp_FX__c != 'undefined' && data.BottomUp_FX__c != null)?data.BottomUp_FX__c:0,
                                    transactionFeeLI : (typeof data.BottomUp_LI__c != 'undefined' && data.BottomUp_LI__c != null)?data.BottomUp_LI__c:0,
                                    transactionFeeSS : (typeof data.BottomUp_SS__c != 'undefined' && data.BottomUp_SS__c != null)?data.BottomUp_SS__c:0,
                                    mainOperatingBankFloat : (typeof data.BottomUp_Float__c != 'undefined' && data.BottomUp_Float__c != null)?data.BottomUp_Float__c:0,
                                    mainOperatingBankCash : (typeof data.BottomUp_Cash__c != 'undefined' && data.BottomUp_Cash__c != null)?data.BottomUp_Cash__c:0,
                                    mainOperatingBankKA : (typeof data.BottomUp_KA__c != 'undefined' && data.BottomUp_KA__c != null)?data.BottomUp_KA__c:0,
                                    dealBaseFeeFrontEnd : (typeof data.BottomUp_Front_End__c != 'undefined' && data.BottomUp_Front_End__c != null)?data.BottomUp_Front_End__c:0,
                                    dealBaseFeeDeriverative : (typeof data.BottomUp_Derivative__c != 'undefined' && data.BottomUp_Derivative__c != null)?data.BottomUp_Derivative__c:0,
                                    dealBaseFeeIBB : (typeof data.BottomUp_IBB__c != 'undefined' && data.BottomUp_IBB__c != null)?data.BottomUp_IBB__c:0,
                                    dealBaseFeeInvestmentFee : (typeof data.BottomUp_Investment_Fee__c != 'undefined' && data.BottomUp_Investment_Fee__c != null)?data.BottomUp_Investment_Fee__c:0,
                                    dealBaseFeeBA : (typeof data.BottomUp_BA__c != 'undefined' && data.BottomUp_BA__c != null)?data.BottomUp_BA__c:0,
                                    businessClosed : data.Business_Closed__c
                                };
                                requestSaveRecords.push(requestSaveRecord);    
                            }
                        }
                        Ext.Deferred
                            .all([sendRequest('saveBottomUpAnnualizedTable', {
                                bottomUpAnnualizedRequests : requestSaveRecords
                            })])
                            .then(function(results) {
                                bottomUpAnnualizedGrid.getStore().commitChanges();
                                bottomUpAnnualizedGrid.getStore().reload();
                                var salesTargetTeamLevelGrid = Ext.getCmp('salesTargetTeamLevelGridId');
                                if(typeof salesTargetTeamLevelGrid != 'undefined'){
                                    var salesTargetTeamLevelStore = Ext.getCmp('salesTargetTeamLevelGridId').getStore();
                                    salesTargetTeamLevelStore.reload();
                                }
                                var salesTargetRmLevelGrid = Ext.getCmp('salesTargetRMLevelGridId');
                                if(typeof salesTargetRmLevelGrid != 'undefined'){
                                    var salesTargetRmLevelStore = salesTargetRmLevelGrid.getStore();
                                    salesTargetRmLevelStore.reload();
                                }        
                                // alert('Save complete');                    
                            }, function(errors) {
                            });
                    }else{
                        bottomUpAnnualizedGrid.getStore().reload();
                    }
                }
        });
    var cancelButton = createButton(cancelButton_Label,
        {
            handler: function() {
                var isCancel = confirm('Edited data will be discarded. Are you sure you want to cancel?');
                if(isCancel){
                    bottomUpAnnualizedGrid.getStore().reload();
                }
            }
        });
    var toolbarSpacer = createToolbarSpacer({});
    //Grid
    var config = {
            id:'bottomUpAnnualizedGridId',
            cls:'bottomUpAnnualizedGridClass',
            plugins: [
                {
                ptype: 'gridfilters'
                }
            ],
            features: [
                {
                    id: Group_Label,
                    ftype: 'groupingsummary',
                    hideGroupedHeader: false,
                    enableNoGroups: true,
                    enableGroupingMenu: false
                },
                {
                    ftype: 'summary',
                    dock: 'bottom'
                }
            ],
            width:gridWidth,
            height:500,
            // viewConfig:{
            //     getRowClass: function(record, rowIndex, rowParams, store){
            //         var bottomUpTF = (typeof record.data.BottomUp_TF__c != 'undefined' && record.data.BottomUp_TF__c != null)?record.data.BottomUp_TF__c:0;
            //         var bottomUpFX = (typeof record.data.BottomUp_FX__c != 'undefined' && record.data.BottomUp_FX__c != null)?record.data.BottomUp_FX__c:0;
            //         var bottomUpLI = (typeof record.data.BottomUp_LI__c != 'undefined' && record.data.BottomUp_LI__c != null)?record.data.BottomUp_LI__c:0;
            //         var bottomUpSS = (typeof record.data.BottomUp_SS__c != 'undefined' && record.data.BottomUp_SS__c != null)?record.data.BottomUp_SS__c:0;
            //         var bottomUpFloat = (typeof record.data.BottomUp_Float__c != 'undefined' && record.data.BottomUp_Float__c != null)?record.data.BottomUp_Float__c:0;
            //         var bottomUpCash = (typeof record.data.BottomUp_Cash__c != 'undefined' && record.data.BottomUp_Cash__c != null)?record.data.BottomUp_Cash__c:0;
            //         var bottomUpKA = (typeof record.data.BottomUp_KA__c != 'undefined' && record.data.BottomUp_KA__c != null)?record.data.BottomUp_KA__c:0;
            //         var annualizedTF = (typeof record.data.Annualized_TF__c != 'undefined' && record.data.Annualized_TF__c != null)?record.data.Annualized_TF__c:0;
            //         var annualizedFX = (typeof record.data.Annaulized_FX__c != 'undefined' && record.data.Annaulized_FX__c != null)?record.data.Annaulized_FX__c:0;
            //         var annualizedLI = (typeof record.data.Annualized_LI__c != 'undefined' && record.data.Annualized_LI__c != null)?record.data.Annualized_LI__c:0;
            //         var annualizedSS = (typeof record.data.Annualized_SS__c != 'undefined' && record.data.Annualized_SS__c != null)?record.data.Annualized_SS__c:0;
            //         var annualizedFloat = (typeof record.data.Annaulized_Float__c != 'undefined' && record.data.Annaulized_Float__c != null)?record.data.Annaulized_Float__c:0;
            //         var annualizedCash = (typeof record.data.Annualized_Cash__c != 'undefined' && record.data.Annualized_Cash__c != null)?record.data.Annualized_Cash__c:0;
            //         var annualizedKA = (typeof record.data.Annualized_KA__c != 'undefined' && record.data.Annualized_KA__c != null)?record.data.Annualized_KA__c:0;
            //         var changeToRedRowClassName = (bottomUpTF < annualizedTF ||
            //             bottomUpFX < annualizedFX ||
            //             bottomUpLI < annualizedLI ||
            //             bottomUpSS < annualizedSS ||
            //             bottomUpFloat < annualizedFloat ||
            //             bottomUpCash < annualizedCash||
            //             bottomUpKA < annualizedKA);
            //         return (changeToRedRowClassName)?'redBottomUpRowClass':'normalBottomUpRowClass';
            //     }
            // },
            multiColumnSort: false,
            margin:gridMargin
        };
    var bottomUpAnnualizedGrid = createSimpleGrid(bottomUpAnnualizedTableName_Label,bottomUpAnnualizedStore,columnsConfig,config);
    //canEditBottomUpTable is a custom setting,used to enable sales user to edit in chosen period
    if(canEditBottomUpTable){
        var bottomUpAnnualizedGridColumns = bottomUpAnnualizedGrid.getColumns();
        console.log('bottomUpAnnualizedGridColumns>>',bottomUpAnnualizedGridColumns);
        bottomUpAnnualizedGrid.addPlugin(cellEditingPlugin);
        bottomUpAnnualizedGridColumns[7].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[8].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[9].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[10].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[12].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[13].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[14].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[16].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[17].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[18].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[19].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[20].tdCls = 'editableTD';
        bottomUpAnnualizedGridColumns[35].tdCls = 'editableTD';
        bottomUpAnnualizedGrid.addDocked([{
                xtype: 'toolbar',
                dock: 'top',
                items: [
                     toolbarSpacer,
                     saveButton,
                     cancelButton
                ]
            }]);
    }
    //Events
    bottomUpAnnualizedGrid.on('edit',function(editor,e){
        var changedFieldName = e.field;
        var originalValue = e.originalValue;
        var newValue = e.value;
        var toChangeRecord = e.record;
        if(originalValue !== newValue){
            var totalBottomup = (typeof toChangeRecord.data.Bottom_Up_Total__c != 'undefined')?toChangeRecord.data.Bottom_Up_Total__c:0;
            if(changedFieldName === 'BottomUp_TF__c' || 
                changedFieldName === 'BottomUp_FX__c' || 
                changedFieldName === 'BottomUp_LI__c' || 
                changedFieldName === 'BottomUp_SS__c'){
                var TF = (typeof toChangeRecord.data.BottomUp_TF__c != 'undefined')?toChangeRecord.data.BottomUp_TF__c:0;
                var FX = (typeof toChangeRecord.data.BottomUp_FX__c != 'undefined')?toChangeRecord.data.BottomUp_FX__c:0;
                var LI = (typeof toChangeRecord.data.BottomUp_LI__c != 'undefined')?toChangeRecord.data.BottomUp_LI__c:0;
                var SS = (typeof toChangeRecord.data.BottomUp_SS__c != 'undefined')?toChangeRecord.data.BottomUp_SS__c:0;
                var totalTransactionFee = TF + FX + LI + SS;
                toChangeRecord.set('Total_Transaction_Fee_Bottom_Up__c',totalTransactionFee);
                toChangeRecord.set('Bottom_Up_Total__c',totalBottomup+totalTransactionFee);
            }else if(changedFieldName === 'BottomUp_Float__c' ||
                     changedFieldName === 'BottomUp_Cash__c' || 
                     changedFieldName === 'BottomUp_KA__c'){
                var FLOAT = (toChangeRecord.data.BottomUp_Float__c != 'undefined')?toChangeRecord.data.BottomUp_Float__c:0;
                var CASH = (toChangeRecord.data.BottomUp_Cash__c != 'undefined')?toChangeRecord.data.BottomUp_Cash__c:0;
                var KA = (toChangeRecord.data.BottomUp_KA__c != 'undefined')?toChangeRecord.data.BottomUp_KA__c:0;
                var totalMainOperatingBank =  FLOAT + CASH + KA;
                toChangeRecord.set('Total_Main_Operating_Bank_Bottom_Up__c',totalMainOperatingBank);
                toChangeRecord.set('Bottom_Up_Total__c',totalBottomup+totalMainOperatingBank);
            }else if(changedFieldName === 'BottomUp_Front_End__c' ||
                     changedFieldName === 'BottomUp_Derivative__c' ||
                      changedFieldName === 'BottomUp_Investment_Fee__c' ||
                       changedFieldName === 'BottomUp_IBB__c' ||
                        changedFieldName === 'BottomUp_BA__c'){
                var FRONTEND = (toChangeRecord.data.BottomUp_Front_End__c != 'undefined')?toChangeRecord.data.BottomUp_Front_End__c:0;
                var DERIVERATIVE = (toChangeRecord.data.BottomUp_Derivative__c != 'undefined')?toChangeRecord.data.BottomUp_Derivative__c:0;
                var INVESTMENTFEE = (toChangeRecord.data.BottomUp_Investment_Fee__c != 'undefined')?toChangeRecord.data.BottomUp_Investment_Fee__c:0;
                var IBB = (toChangeRecord.data.BottomUp_IBB__c != 'undefined')?toChangeRecord.data.BottomUp_IBB__c:0;
                var BA = (toChangeRecord.data.BottomUp_BA__c != 'undefined')?toChangeRecord.data.BottomUp_BA__c:0;
                var totalDealBaseFee = FRONTEND + DERIVERATIVE + INVESTMENTFEE + IBB + BA;
                toChangeRecord.set('Total_Deal_Base_Fee_Bottom_Up__c',totalDealBaseFee);
                toChangeRecord.set('Bottom_Up_Total__c',totalBottomup+totalDealBaseFee);
            }
        }
        var userEnterBlank = (newValue === null);
        if(userEnterBlank){
            var theCell = Ext.get(e.cell);
            theCell.removeCls('x-grid-dirty-cell');
        }
    });
    bottomUpAnnualizedGrid.hide();
    bottomUpAnnualizedStore.filter([
                {
                    id: 'isActive',
                    property : 'Is_Active__c',
                    value    : true
                },{
                    id: 'salesTargetIsActive',
                    property: 'Sales_Target__r.Is_Active__c',
                    value: true
                }
    ]);
    return bottomUpAnnualizedGrid;
}
function sendRequest(operate, requestObj) {
    var deferred = new Ext.Deferred();
    CBS_BottomUp_Controller[operate](requestObj, function(results, e) {
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
}
function exportToCSV(gridId,fileName,separator,isTargetTableRequest,includeHidden) {
    var text = "";
    //Columns
    var grid = Ext.getCmp(gridId);
    var columns = grid.columnManager.columns;
    var columnsCount = columns.length;
    var targetTableHeader = ['','','','Transaction Fee - ','Transaction Fee - ','Main Operating Bank - ','Main Operating Bank - ','Deal Base Fee - ','Deal Base Fee - '];
    for (var i = 0; i < columnsCount; i++) {
        if (includeHidden || !columns[i].hidden) {
            if(isTargetTableRequest){
                text += targetTableHeader[i]+columns[i].text + separator;
            }else{
                text += columns[i].text + separator;    
            }
        }
    }
    text = text.substring(0, text.length-1);
    text += "\r";
    //Row
    var rows = grid.store.data.items;
    var rowsCount = rows.length;
    for (var i = 0; i < rowsCount; i++) {
        var row = rows[i].data;
        for (var j = 0; j<columnsCount; j++) {
            if (includeHidden || !columns[j].hidden) {
                var value = (typeof row[columns[j].dataIndex] != "undefined")?row[columns[j].dataIndex]:'-';
                text += "\"" + value + "\"" + separator;
            }
        }
        text = text.substring(0, text.length-1);
        text += "\r";
    }
    var hiddenElement = document.createElement('a');
    var encodeText = encodeURI(text);
    //%EF%BB%BF is BOM(byte order marks) for UTF8-encoding
    hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeText;
    hiddenElement.target = '_blank';
    hiddenElement.download = fileName+'.csv';
    hiddenElement.click();
    hiddenElement.remove();
    return encodeURI(text);
}
function getTodayInDDMMYYYYFormat(){
    var today = new Date();
    var dd = today.getDate();
    //month January start at index 0
    var mm = today.getMonth()+1;
    var yyyy = today.getFullYear();
    if(dd<10) {
        dd='0'+dd
    } 
    if(mm<10) {
        mm='0'+mm
    } 
    today = dd+'/'+mm+'/'+yyyy;
    return today;
}
