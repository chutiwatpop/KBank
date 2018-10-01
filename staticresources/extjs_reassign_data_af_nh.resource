function init(config) {
    var selectedOwnerId = '';

    var reAssignAFPortColumn = mappingColumn(config.reAssignAFPortMap,["CIS__c","NameSurnameTHCompanyName_Formula__c","Primary_Segment_Code__c","Secondary_Segment_Code__c","AF_Port_Pool_Formula__c","AF_Port2__c","AF_Owner_Formula__c","AF_Team_Formula__c","Max_Wealth_Branch","RBS_Branch_Closeness"]);
    var reAssignAFPoolColumn = mappingColumn(config.reAssignAFPortMap,["CIS__c","NameSurnameTHCompanyName_Formula__c","Primary_Segment_Code__c","Secondary_Segment_Code__c","AF_Port_Pool_Formula__c","AF_Port2__c","AF_Owner_Formula__c","AF_Team_Formula__c","AF_Temporary_Customer","Max_Wealth_Branch","RBS_Branch_Closeness"]);
    var reAssignAFPort2Column = reAssignAFPortColumn;
    var extendModelColumn = [
        {
            "name": "Max_Wealth_Branch__r.Name",
            "mapping": 'Max_Wealth_Branch__r.Name',
        },{
            "name": "RBS_Branch_Closeness__r.Name",
            "mapping": 'RBS_Branch_Closeness__r.Name',
        },{
            "name": "AF_Temporary_Customer__r.Name",
            "mapping": 'AF_Temporary_Customer__r.Name',
        },{
            "name": "Owner.Name",
            "mapping": 'Owner.Name',
        }
    ];
    var cisText = new Ext.form.TextField({
        fieldLabel: 'CIS Number  ',
        name: 'search_box',
        labelWidth: 170,
    });

    var customerColumns = [
        {
            "xtype": 'widgetcolumn',
            "locked": false,
            "width": 100,
            "widget": {
                "height": 18,
                "padding": 0,
                "xtype": 'button',
                "text": 'Assign Port',
                "handler": function(button,wid){
                    var wrecord = this.getWidgetRecord();
                    console.log(wrecord.data);
                    search_assign_popup.selection_data = wrecord.data;
                    if(wrecord.data.RecordType.DeveloperName =='Organization_Customer'){
                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, 'เป็นลูกค้านิติบุคคล');
                    }else if(wrecord.data.Primary_Segment_Code__c =='HN'){
                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, 'เป็นลูกค้า HN');
                    }else if(wrecord.data.Owner.Profile.Name.includes('AF') ||(wrecord.data.Dual_RM_Name__c !=null && wrecord.data.Dual_RM_Name__r.Profile.Name.includes('AF')) ){
                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, 'มี RM AF ดูแลลูกค้าอยู่แล้ว');
                    }else{
                        search_assign_popup.show();
                    }    
                }
            },
            sortable: false
        },{
            "dataIndex": "CIS__c",
            "text": 'CIS ID',
            "align": "left",
            "locked": false,
            "sortable": false
        },{
            "dataIndex": "NameSurnameTHCompanyName_Formula__c",
            "text": 'Name',
            "align": "left",
            "locked": false,
            "sortable": false
        },{
            "dataIndex": "Primary_Segment_Code__c",
            "text": 'Primary Segment',
            "align": "left",
            "locked": false,
            "sortable": false
        },{
            "dataIndex": "Secondary_Segment_Code__c",
            "text": 'Secondary Segment',
            "align": "left",
            "locked": false,
            "sortable": false
        },{
            "dataIndex": "AF_Port_Pool_Formula__c",
            "text": 'Port/Pool',
            "align": "left",
            "locked": false,
            "sortable": false
        },{
            "dataIndex": "AF_Port2__c",
            "text": 'Port2',
            "align": "left",
            "width": 80,
            "locked": false,
            "sortable": false,
            "renderer": function(recordData){
                if(Ext.isDefined(recordData) && recordData == true){
                    return "<input class='gridCheckbox'  type='checkbox' checked='checked'  disabled='disabled'";
                }else{
                    return "<input class='gridCheckbox'  type='checkbox' disabled='disabled'";
                }
            }
        } ,{
            "dataIndex": "Owner",
            "text": 'Owner',
            "width": 140,
            "locked": false,
            "sortable": false,
            "renderer" : function(recordData) {
                if(Ext.isDefined(recordData) && Ext.isDefined(recordData.Name)){
                    return recordData.Name;
                }else{
                    return '';
                }
            }
        },{
            "dataIndex": "Dual_RM_Name__r",
            "text": 'AF RM Name',
            "width": 120,
            "locked": false,
            "sortable": false,
            "renderer" : function(recordData) {
                if(Ext.isDefined(recordData) && Ext.isDefined(recordData.Name)){
                    return recordData.Name;
                }else{
                    return '';
                }
            }
        } ,{
            "dataIndex": "AF_Temporary_Customer__r",
            "text": 'AF Temporary Ownership',
            "width": 120,
            "locked": false,
            "sortable": false,
            "renderer" : function(recordData) {
                if(Ext.isDefined(recordData) && Ext.isDefined(recordData.Name)){
                    return recordData.Name;
                }else{
                    return '';
                }
            }
        } ,{
            "dataIndex": "Max_Wealth_Branch__r",
            "text": 'Max Wealth Branch',
            "width": 120,
            "locked": false,
            "sortable": false,
            "renderer" : function(recordData) {
                if(Ext.isDefined(recordData) && Ext.isDefined(recordData.Name)){
                    return recordData.Name;
                }else{
                    return '';
                }
            }
        } ,{
            "dataIndex": "RBS_Branch_Closeness__r",
            "text": 'สาขาคนสนิท',
            "width": 120,
            "locked": false,
            "sortable": false,
            "renderer" : function(recordData) {
                if(Ext.isDefined(recordData) && Ext.isDefined(recordData.Name)){
                    return recordData.Name;
                }else{
                    return '';
                }
            }
        }  
    ];

    Ext.define('customerModel', {
        extend: 'Ext.data.Model',
        fields: [{
            name: 'Id',
            type: 'string',
            sortable: false
        },{
            name: 'CIS__c',
            type: 'string',
            sortable: false
        },{
            name: 'Identification_No__c',
            type: 'string',
            sortable: false
        }, {
            name: 'Name',
            type: 'string',
            sortable: false
        }, {
            name: 'NameSurnameTHCompanyName_Formula__c',
            type: 'string',
            sortable: false
        }, {
            name: 'Primary_Segment_Code__c',
            type: 'string',
            sortable: false
        }, {
            name: 'Secondary_Segment_Code__c',
            type: 'string',
            sortable: false
        }, {
            name: 'AF_Port_Pool_Formula__c',
            type: 'string',
            sortable: false
        }, {
            name: 'AF_Port2__c',
            type: 'boolean',
            sortable: false
        }, {
            name: 'AF_Owner_Formula__c',
            type: 'string',
            sortable: false
        }, {
            name: 'AF_Team_Formula__c',
            type: 'string',
            sortable: false
        }, {
            name: 'RecordType.DeveloperName',
            type: 'string',
            sortable: false
        }, {
            name: 'Owner.Name',
            type: 'string',
            sortable: false
        }, {
            name: 'Dual_RM_Name__r.Name',
            type: 'string',
            sortable: false
        }, {
            name: 'AF_Temporary_Customer__r.Name',
            type: 'string',
            sortable: false
        }, {
            name: 'Max_Wealth_Branch__r.Name',
            type: 'string',
            sortable: false
        }, {
            name: 'RBS_Branch_Closeness__r.Name',
            type: 'string',
            sortable: false
        }],//
        idProperty: 'Id'
    });

    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200,
        sorters: []
    });

    var reAssignAFPortModelName = Ext.String.capitalize("RBSAccountPort");
    var reAssignAFPoolModelName = Ext.String.capitalize("RBSAccountPort2");
    var reAssignAFPort2ModelName = Ext.String.capitalize("RBSAccountPool");

    // Create Model
    createModel(reAssignAFPortModelName, 'records', 'Id',extendModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignAFPortfieldlist.join(',')
        }
    );
    createModel(reAssignAFPoolModelName, 'records', 'Id',extendModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignAFPoolfieldlist.join(',')
        }
    );
    createModel(reAssignAFPort2ModelName, 'records', 'Id',extendModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignAFPort2fieldlist.join(',')
        }
    );

    // Create Store Model
    var reAssignAFPortStore = createStoreModel(reAssignAFPortModelName, config.pagesize, {
        filters: [{
            property: 'IsMyTeamPortAF__c ',
            value: '1'
        },{ 
            property: 'AF_Port_Pool_Formula__c ',
            value: 'Port'
        },{
            property: 'AF_Port2__c ',
            value: false
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var reAssignAFPoolStore = createStoreModel(reAssignAFPoolModelName, config.pagesize, {
        filters: [{
            property: 'IsMyTeamPortAF__c ',
            value: '1'
        },{ 
            property: 'AF_Port_Pool_Formula__c ',
            value: 'Pool'
        },{
            property: 'AF_Port2__c ',
            value: false
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var reAssignAFPort2Store = createStoreModel(reAssignAFPort2ModelName, config.pagesize, {
        filters: [{
            property: 'IsMyTeamPortAF__c ',
            value: '1'
        },{ 
            property: 'AF_Port_Pool_Formula__c ',
            value: 'Port'
        },{
            property: 'AF_Port2__c ',
            value: true
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200,
        sorters: []
    });

    var reAssignPortCheckbox = function(record) {
        return record;
    };

    var reAssignPoolCheckbox = function(record) {
        return record;
    };

    var reAssignPort2Checkbox = function(record) {
        return record;
    };

    var rmNamePortTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryRMNameByTeam,{blankInclude:true},true);
    var rmNamePort2TabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryRMNameByTeam,{blankInclude:true},true);
    var rmNamePoolTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryRMNameByTeam,{blankInclude:true},true);
    var rmNamePopupModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryRMNameByTeam,{blankInclude:false},true);

    var teamPortTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true},true);
    var teamPort2TabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true},true);
    var teamPoolTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true},true);
    var teamPopupModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true},true);

    var areaPortTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true,ahLevel:true},true);
    var areaPort2TabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true,ahLevel:true},true);
    var areaPoolTabModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true,ahLevel:true},true);
    var areaPopupModel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryTeamNameByRC,{rccodes:config.user_rc_code,isNH:true,ahLevel:true},true);

    // Popup 
    var selectAreaCombobox = createComboxbox('Area Name', 'selectedAreaName', false, areaPopupModel, '== Select Area ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                if (selected.data.pvalue == '') {
                    delete teamPopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    teamPopupModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePopupModel.proxy.extraParams.ahRCcode = selected.data.scope;
                }
                selectTeamCombobox.clearValue();
                selectPortRMCombobox.clearValue();
                teamPopupModel.reload();
                rmNamePopupModel.reload();
            }
        }
    });
    var selectAreaPoolCombobox = createComboxbox('Area Name', 'selectedAreaName', false, areaPopupModel, '== Select Area ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                if (selected.data.pvalue == '') {
                    delete teamPopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    teamPopupModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePopupModel.proxy.extraParams.ahRCcode = selected.data.scope;
                }
                selectTeamPoolCombobox.clearValue();
                selectPoolRMCombobox.clearValue();
                teamPopupModel.reload();
                rmNamePopupModel.reload();
            }
        }
    });
    var selectAreaPort2Combobox = createComboxbox('Area Name', 'selectedAreaName', false, areaPopupModel, '== Select Area ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                if (selected.data.pvalue == '') {
                    delete teamPopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    teamPopupModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePopupModel.proxy.extraParams.ahRCcode = selected.data.scope;
                }
                selectTeamPort2Combobox.clearValue();
                selectPort2RMCombobox.clearValue();
                teamPopupModel.reload();
                rmNamePopupModel.reload();
            }
        }
    });
    var searchAssignAreaCombobox = createComboxbox('Area Name', 'selectedAreaName', false, areaPopupModel, '== Select Area ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                if (selected.data.pvalue == '') {
                    delete teamPopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    teamPopupModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePopupModel.proxy.extraParams.ahRCcode = selected.data.scope;
                }
                searchAssignTeamCombobox.clearValue();
                searchAssignRmCombobox.clearValue();
                teamPopupModel.reload();
                rmNamePopupModel.reload();
            }
        }
    });
       
    var selectTeamCombobox = createComboxbox('Team Name', 'selectedTeamName', false, teamPopupModel, '== Select Team ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                console.log('selected :'+selected.data.pvalue);
                if (selected.data.pvalue == '') {
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    
                }else {
                    rmNamePopupModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                selectPortRMCombobox.clearValue();
                rmNamePopupModel.reload();
            }
        }
    });
    var selectTeamPoolCombobox = createComboxbox('Team Name', 'selectedTeamName', false, teamPopupModel, '== Select Team ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                console.log('selected :'+selected.data.pvalue);
                if (selected.data.pvalue == '') {
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    rmNamePopupModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                selectPoolRMCombobox.clearValue();
                rmNamePopupModel.reload();
            }
        }
    });
    var selectTeamPort2Combobox = createComboxbox('Team Name', 'selectedTeamName', false, teamPopupModel, '== Select Team ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                console.log('selected :'+selected.data.pvalue);
                if (selected.data.pvalue == '') {
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    rmNamePopupModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                selectPort2RMCombobox.clearValue();
                rmNamePopupModel.reload();
            }
        }
    });
    var searchAssignTeamCombobox = createComboxbox('Team Name', 'selectedTeamName', false, teamPopupModel, '== Select Team ==', 'pname', 'pvalue', false, true, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                console.log('selected :'+selected.data.pvalue);
                if (selected.data.pvalue == '') {
                    delete rmNamePopupModel.proxy.extraParams.scope;
                }else {
                    rmNamePopupModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                searchAssignRmCombobox.clearValue();
                rmNamePopupModel.reload();
            }
        }
    });


    var selectPortRMCombobox = createComboxbox('AF RM Name', 'selectedByRMName', false, rmNamePopupModel, '== Select RM ==', 'pname', 'pvalue', false, false, {
        labelWidth: 100,
        listeners: {
            select: function(combox, selected, index) {
                
            }
        }
    });
    var selectPoolRMCombobox = selectPortRMCombobox.cloneConfig();
    var selectPort2RMCombobox = selectPortRMCombobox.cloneConfig();
    var searchAssignRmCombobox = selectPortRMCombobox.cloneConfig();

    var portPoolAllPortPopupCombobox = createComboxbox('Port/Pool', 'portPoolpanel', false,
        new Ext.data.ArrayStore({
            id: 0,
            fields: [
                'property',
                'value'
            ],
            data: [
                ['Port','Port'],
                ['Port2','Port2'],
                ['Pool','Pool']
            ]
        }), 'Port/Port2/Pool', 'pname', 'pvalue', false, false, {
            value: '',
            valueField: 'value',
            displayField: 'property',
            listeners: {
            }
    }); 
    var portPoolAllPoolPopupCombobox = portPoolAllPortPopupCombobox.cloneConfig();
    var portPoolAllPort2PopupCombobox = portPoolAllPortPopupCombobox.cloneConfig();
    var portPoolAllSearchPopupCombobox = portPoolAllPortPopupCombobox.cloneConfig();
   
    var filterAreaPortTabCombobox = createComboxbox('Area Name ', 'filterAreaName', false, areaPortTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        value: config.map_label.BulkAssign_ShowAll,
        width: 350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_AH_RC_Code__c");
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pkey == '') {
                    delete teamPortTabModel.proxy.extraParams.scope;
                    delete rmNamePortTabModel.proxy.extraParams.ahRCcode;
                    delete rmNamePortTabModel.proxy.extraParams.scope;
                }else{
                    grid.store.filter("AF_AH_RC_Code__c", '#'+selected.data.pkey);
                    teamPortTabModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePortTabModel.proxy.extraParams.ahRCcode = selected.data.pkey;
                }
                filterTeamPortTabCombobox.clearValue();
                filterRMPortTabCombobox.clearValue();
                teamPortTabModel.reload();
                rmNamePortTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterTeamPortTabCombobox = createComboxbox('Team Name ', 'filterTeamName', false, teamPortTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pvalue == '') {
                    delete teamPortTabModel.proxy.extraParams.scope;
                    delete rmNamePortTabModel.proxy.extraParams.scope;
                }else{
                    grid.store.filter("AF_Team_Formula__c", '#'+selected.data.pvalue);
                    rmNamePortTabModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                filterRMPortTabCombobox.clearValue();
                teamPortTabModel.reload();
                rmNamePortTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterRMPortTabCombobox = createComboxbox('RM Name ', 'selectedByRMName', false, rmNamePortTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pvalue == '') {
                    grid.store.removeFilter("AF_Owner_ID_Formula__c");
                }else {
                    grid.store.filter("AF_Owner_ID_Formula__c", '#'+selected.data.pvalue);
                }
                rmNamePortTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });

    var filterAreaPort2TabCombobox = createComboxbox('Area Name ', 'filterAreaName', false, areaPort2TabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        value: config.map_label.BulkAssign_ShowAll,
        width: 350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_AH_RC_Code__c");
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pkey == '') {
                    delete teamPort2TabModel.proxy.extraParams.scope;
                    delete rmNamePort2TabModel.proxy.extraParams.ahRCcode;
                    delete rmNamePort2TabModel.proxy.extraParams.scope;
                }else{
                    grid.store.filter("AF_AH_RC_Code__c", '#'+selected.data.pkey);
                    teamPort2TabModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePort2TabModel.proxy.extraParams.ahRCcode = selected.data.pkey;
                }
                teamPort2TabModel.reload();
                rmNamePort2TabModel.reload();
                filterTeamPort2TabCombobox.clearValue();
                filterRMPort2TabCombobox.clearValue();
                grid.store.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterTeamPort2TabCombobox = createComboxbox('Team Name ', 'filterTeamName', false, teamPort2TabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pvalue == '') {
                    delete teamPort2TabModel.proxy.extraParams.scope;
                    delete rmNamePort2TabModel.proxy.extraParams.scope;
                    
                }else{
                    grid.store.filter("AF_Team_Formula__c", '#'+selected.data.pvalue);
                    rmNamePort2TabModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                filterRMPort2TabCombobox.clearValue();
                rmNamePort2TabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterRMPort2TabCombobox = createComboxbox('RM Name ', 'selectedByRMName', false, rmNamePort2TabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pvalue == '') {
                    grid.store.removeFilter("AF_Owner_ID_Formula__c");
                }else {
                    grid.store.filter("AF_Owner_ID_Formula__c", '#'+selected.data.pvalue);
                }
                rmNamePortTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });

    var filterAreaPoolTabCombobox = createComboxbox('Area Name ', 'filterAreaName', false, areaPoolTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        value: config.map_label.BulkAssign_ShowAll,
        width: 350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_AH_RC_Code__c");
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pkey == '') {
                    delete teamPoolTabModel.proxy.extraParams.scope;
                    delete rmNamePoolTabModel.proxy.extraParams.ahRCcode;
                    delete rmNamePoolTabModel.proxy.extraParams.scope;    
                }else{
                    grid.store.filter("AF_AH_RC_Code__c", '#'+selected.data.pkey);
                    teamPoolTabModel.proxy.extraParams.scope = selected.data.pkey;
                    rmNamePoolTabModel.proxy.extraParams.ahRCcode = selected.data.pkey;
                }
                filterTeamPoolTabCombobox.clearValue();
                filterRMPoolTabCombobox.clearValue();
                teamPoolTabModel.reload();
                rmNamePoolTabModel.reload();
                grid.store.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterTeamPoolTabCombobox = createComboxbox('Team Name ', 'filterTeamName', false, teamPoolTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Team_Formula__c");
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                selectedOwnerId = '';
                if (selected.data.pvalue == '') {
                    delete teamPoolTabModel.proxy.extraParams.scope;
                    delete rmNamePoolTabModel.proxy.extraParams.scope;
                }else{
                    grid.store.filter("AF_Team_Formula__c", '#'+selected.data.pvalue);
                    rmNamePoolTabModel.proxy.extraParams.scope = selected.data.pvalue;
                }
                filterRMPoolTabCombobox.clearValue();
                rmNamePoolTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    var filterRMPoolTabCombobox = createComboxbox('RM Name ', 'selectedByRMName', false, rmNamePoolTabModel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 75,
        width:350,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("AF_Owner_ID_Formula__c");
                if (selected.data.pvalue == '') {
                }else {
                    grid.store.filter("AF_Owner_ID_Formula__c", '#'+selected.data.pvalue);
                }
                rmNamePortTabModel.reload();
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });

    var selectconfirmport_popup = createPanel({
        id: 'selectedPanel',
        title: 'Assign To',
        items: [selectAreaCombobox,selectTeamCombobox,selectPortRMCombobox,portPoolAllPortPopupCombobox],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'SAVE',
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('reAssignAFPortGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPortCheckbox(record.data);
                            });
                            if (final_selections.length > 0 && form.getFieldValues().selectedByRMName != null) {
                                grid.setLoading(true);
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignAFPortGrid',
                                        fromAF : true
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
                                            Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                        } else{
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                config.map_label.BulkAssign_PleaseConfirmtoRefreshList,
                                                results[0].errorMessage,
                                                function(btn, text) {
                                                        if (btn=='yes') {
                                                            grid.getView().getSelectionModel().deselectAll();
                                                            reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                });
                                            }else {
                                                Ext.Msg.alert(config.map_label.BulkAssign_Servererror, results[0].errorMessage);
                                            }
                                        }
                                        grid.setLoading(false);
                                        
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, errors[0]);
                                    });
                                    selectconfirmport_popup.close();
                            } else Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoRM_TM_UserAssignment);
                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }],
        listeners: {
            'close':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaCombobox.clearValue();
                    selectTeamCombobox.clearValue();
                    selectPortRMCombobox.clearValue();
                    portPoolAllPortPopupCombobox.clearValue();
              },
             'hide':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaCombobox.clearValue();
                    selectTeamCombobox.clearValue();
                    selectPortRMCombobox.clearValue();
                    portPoolAllPortPopupCombobox.clearValue();
              }
        }
    });
    var selectconfirmpool_popup = createPanel({
        id: 'poolPanel',
        title: 'Pool Assign To',
        items: [selectAreaPoolCombobox,selectTeamPoolCombobox,selectPoolRMCombobox,portPoolAllPoolPopupCombobox],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'SAVE',
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('reAssignAFPoolGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPortCheckbox(record.data);
                            });
                            if (final_selections.length > 0 && form.getFieldValues().selectedByRMName != null) {
                                grid.setLoading(true);
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignAFPoolGrid',
                                        fromAF : true
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
                                            Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                        } else{
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                config.map_label.BulkAssign_PleaseConfirmtoRefreshList,
                                                results[0].errorMessage,
                                                function(btn, text) {
                                                        if (btn=='yes') {
                                                            grid.getView().getSelectionModel().deselectAll();
                                                            reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                     
                                                });
                                            }else {
                                                Ext.Msg.alert(config.map_label.BulkAssign_Servererror, results[0].errorMessage);
                                            }
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, errors[0]);
                                    });
                                    selectconfirmpool_popup.close();
                            } else Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoRM_TM_UserAssignment);
                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }],
        listeners: {
            'close':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaPoolCombobox.clearValue();
                    selectTeamPoolCombobox.clearValue();
                    selectPoolRMCombobox.clearValue();
                    portPoolAllPoolPopupCombobox.clearValue();
              },
             'hide':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaPoolCombobox.clearValue();
                    selectTeamPoolCombobox.clearValue();
                    selectPoolRMCombobox.clearValue();
                    portPoolAllPoolPopupCombobox.clearValue();
              }
        }
    });
    var selectconfirmport2_popup = createPanel({
        id: 'selectedPort2Panel',
        title: 'Port2 Assign To',
        items: [selectAreaPort2Combobox,selectTeamPort2Combobox,selectPort2RMCombobox,portPoolAllPort2PopupCombobox],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'SAVE',
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('reAssignAFPort2Grid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPortCheckbox(record.data);
                            });
                            if (final_selections.length > 0 && form.getFieldValues().selectedByRMName != null) {
                                grid.setLoading(true);
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignAFPort2Grid',
                                        fromAF : true
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
                                            Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                        } else{
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                config.map_label.BulkAssign_PleaseConfirmtoRefreshList,
                                                results[0].errorMessage,
                                                function(btn, text) {
                                                        if (btn=='yes') {
                                                            grid.getView().getSelectionModel().deselectAll();
                                                            reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                     Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                                });
                                            }else {
                                                Ext.Msg.alert(config.map_label.BulkAssign_Servererror, results[0].errorMessage);
                                            }
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, errors[0]);
                                    });
                                    selectconfirmport2_popup.close();
                            } else Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoRM_TM_UserAssignment);
                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }],
        listeners: {
            'close':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaPort2Combobox.clearValue();
                    selectTeamPort2Combobox.clearValue();
                    selectPort2RMCombobox.clearValue();
                    portPoolAllPort2PopupCombobox.clearValue();
              },
             'hide':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    selectAreaPort2Combobox.clearValue();
                    selectTeamPort2Combobox.clearValue();
                    selectPort2RMCombobox.clearValue();
                    portPoolAllPort2PopupCombobox.clearValue();
              }
        }
    });
    var search_assign_popup = createPanel({
        id: 'search_assign_Panel',
        title: 'Search Assign To',
        items: [searchAssignAreaCombobox,searchAssignTeamCombobox,searchAssignRmCombobox,portPoolAllSearchPopupCombobox],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'SAVE',
                    handler: function() {
                        
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('customerGrid');
                            if (search_assign_popup.selection_data != null) {
                                var cislist = [search_assign_popup.selection_data.Id];
                                grid.setLoading(true);
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: cislist,
                                        gridName: 'customerGrid',
                                        fromAF : true
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
                                            Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                        } else{
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                config.map_label.BulkAssign_PleaseConfirmtoRefreshList,
                                                results[0].errorMessage,
                                                function(btn, text) {
                                                        if (btn=='yes') {
                                                            grid.getView().getSelectionModel().deselectAll();
                                                            reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                     Ext.Msg.alert('Update Completed', 'ทำการมอบหมายลูกค้าให้พนักงานสำเร็จ');
                                                });
                                            }else {
                                                Ext.Msg.alert('Port Assigment Error', results[0].errorMessage);
                                            }
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert('Port Assigment Error', errors[0]);
                                    });
                                    search_assign_popup.close();
                            } else Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoRM_TM_UserAssignment);
                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }],
        listeners: {
            'close':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    searchAssignAreaCombobox.clearValue();
                    searchAssignTeamCombobox.clearValue();
                    searchAssignRmCombobox.clearValue();
                    portPoolAllSearchPopupCombobox.clearValue();
              },
             'hide':function(win){
                    delete rmNamePopupModel.proxy.extraParams.scope;
                    delete rmNamePopupModel.proxy.extraParams.ahRCcode;
                    delete teamPopupModel.proxy.extraParams.scope;
                    
                    rmNamePopupModel.reload();
                    teamPopupModel.reload();
                    searchAssignAreaCombobox.clearValue();
                    searchAssignTeamCombobox.clearValue();
                    searchAssignRmCombobox.clearValue();
                    portPoolAllSearchPopupCombobox.clearValue();
              }
        }
    });
    function reloadAllStore(){
        reAssignAFPortStore.reload();
        reAssignAFPoolStore.reload();
        reAssignAFPort2Store.reload();
    };
    console.log('00102312');
    config.panel_items = [
        createGridObject(config.map_label.BulkAssignment_AFPort, 'reAssignAFPortGrid', reAssignAFPortStore, reAssignAFPortColumn, {
            clearAll: function(){
            },
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignPortCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            rmNamePortTabModel.reload();
                            selectconfirmport_popup.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }, {
                    xtype: 'tbspacer'
                }]
            },
            {
                xtype: 'toolbar',
                dock: 'top',

                items: [//area_selected_by_nhrccode
                    {
                        xtype: 'tbspacer'
                    },filterAreaPortTabCombobox,,filterTeamPortTabCombobox,filterRMPortTabCombobox,
                    {
                        xtype: 'tbspacer'
                    }
                ]
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignAFPortStore.sync();
                    reAssignAFPortStore.reload();
                    console.log('afterrender port');
                    console.log(reAssignAFPortStore);
                },
                'headerclick': function(g, index, ev) {
                },
                'activate': function(tab, eOpts) {
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignPortCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject(config.map_label.BulkAssignment_AFPort2, 'reAssignAFPort2Grid', reAssignAFPort2Store, reAssignAFPort2Column, {
            clearAll: function(){
            },
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignPoolCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            rmNamePortTabModel.reload();
                            selectconfirmport2_popup.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }, {
                    xtype: 'tbspacer'
                }]
            },
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    {
                        xtype: 'tbspacer'
                    },filterAreaPort2TabCombobox,filterTeamPort2TabCombobox,filterRMPort2TabCombobox,
                    {
                        xtype: 'tbspacer'
                    }
                ] 
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignAFPort2Store.sync();
                    reAssignAFPort2Store.reload();
                },
                'headerclick': function(g, index, ev) {
                },
                'activate': function(tab, eOpts) {
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignPoolCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject(config.map_label.BulkAssignment_AFPool, 'reAssignAFPoolGrid', reAssignAFPoolStore, reAssignAFPoolColumn, {
            clearAll: function(){
            },
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignPoolCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            selectconfirmpool_popup.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }, {
                    xtype: 'tbspacer'
                }]
            },
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    {
                        xtype: 'tbspacer'
                    },filterAreaPoolTabCombobox,filterTeamPoolTabCombobox,filterRMPoolTabCombobox,
                    {
                        xtype: 'tbspacer'
                    }
                ]
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignAFPoolStore.sync();
                    reAssignAFPoolStore.reload();
                },
                'headerclick': function(g, index, ev) {
                },
                'activate': function(tab, eOpts) {
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignPoolCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('Search Customer', 'customerGrid', customerStore, customerColumns, {
            dockedItems: [{
                    xtype: 'tbspacer'
                },{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                            cisText, {
                                xtype: 'tbspacer'
                            }, {
                                id: 'search_customer',
                                text: 'Search',
                                handler: function() {
                                    if (cisText.value != "") {
                                        Ext.Deferred
                                            .all([requestApexWithClassName('BulkAssignment_Webservice','getCustomers',{cisNo:cisText.value})])
                                            .then(function(results) {
                                                customerStore.loadData([], false);
                                                console.log('customerStore');
                                                console.log(customerStore);
                                                if (results[0].success!="false") {
                                                    customerStore.loadData([results[0].records]);
                                                }else {
                                                    Ext.Msg.alert('Bulk Error', results[0].errorMessage);   
                                                }
                                            }, function(errors) {
                                                Ext.Msg.alert('Bulk Error', errors[0]);
                                            });
                                    }
                                }
                            }
                        ]
                }],
                listeners:{
                'afterrender': function(grid) {
                    customerStore.sync();
                    customerStore.reload();
                },
                'headerclick': function(g, index, ev) {
                    
                }
            }
        },true)
    ];

    // config.panel_items.on('tabchange', function(tabPanel, tab) {
    //     console.log(tabPanel.id + ' ' + tab.id);
    // });
};
