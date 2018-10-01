function init(config) {
    var selectedRMId = '';
    var selectedOwnerTMId = '';
    var selectedOwnerTMRCCode = '';
    var selectedTempRMId = '';
    var selectedOwnerTempTMId = '';
    var selectedOwnerTempTMRCCode = '';

    var customerRequestModelColumn = [
        {
            "name": "Current_Owner_Extension__r.Name",
            "mapping": 'Current_Owner_Extension__r.Name'
        },{
            "name": "Current_Team_Name__r.Name",
            "mapping": 'Current_Team_Name__r.Name'
        },{
            "name": "Permanent_Owner_Extension__r.Name",
            "mapping": 'Permanent_Owner_Extension__r.Name'
        },{
            "name": "Permanent_Team_Name__r.Name",
            "mapping": 'Permanent_Team_Name__r.Name'
        },{
            "name": "Previous_Owner_Extension__r.Name",
            "mapping": 'Previous_Owner_Extension__r.Name'
        },{
            "name": "Previous_Team_Name__r.Name",
            "mapping": 'Previous_Team_Name__r.Name'
        },{
            "name": "Service_RM__r.Name",
            "mapping": 'Service_RM__r.Name'
        },{
            "name": "SME_Temporary_Customer__r.Name",
            "mapping": 'SME_Temporary_Customer__r.Name'
        }
    ];
    var reAssignPermanenceColumn = mappingColumn(config.reAssignPermanenceForMap,["CIS__c","NameSurnameTHCompanyName_Formula__c","Primary_Segment_Code__c","High_Value__c","Credit_Flag__c","Port_Pool__c","District__c","Province__c","Customer_Status__c","SME_Temporary_Customer__c","Ownership_Text__c","Current_Owner_Extension__c","Current_Team_Name__c","Permanent_Owner_Extension__c","Permanent_Team_Name__c","Previous_Owner_Extension__c","Previous_Team_Name__c","Service_RM__c","Customer_s_Business_Code__c","Business_Code_Name_EN__c","Income_to_Bank_This_Year_Range__c","Income_to_Bank_Last_Year_Range__c","Total_SME_Limit_Range__c","Total_SME_Out_Range__c","Total_SME_Exposure_Range__c","Wallet_Size_Credit_Limit_Range__c","Wallet_Size_Credit_Outstanding_Range__c","Wallet_Size_Credit_Exposure_Range__c","SOW_Exposure__c","Trade_Turn_Range__c","Last_Visited_Date__c","Last_Visited_By__c","Last_Setup_Date__c","Last_Setup_By__c"]);
    var reAssignTemporaryColumn = reAssignPermanenceColumn;
    var reAssignOwnedByOtherColumn = reAssignPermanenceColumn;

    var reAssignPermanenceModelName = Ext.String.capitalize("AccountPermanence");
    var reAssignTemporaryModelName = Ext.String.capitalize("AccountTemporary");
    var reAssignOwnedByOtherModelName = Ext.String.capitalize("AccountOwnedByOther");

    var user_rc_code = config.user_rc_code;
    var targetRM;
    var targetRMOwnerTab;

    // Create Model
    createModel(reAssignPermanenceModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignPermanencefieldlist.join(',')
        }
    );
    createModel(reAssignTemporaryModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignTemporaryfieldlist.join(',')
        }
    );
    createModel(reAssignOwnedByOtherModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignOwnedByOtherfieldlist.join(',')
        }
    );

    // Create Store Model
    //SELECT Id,CIS__c,Owner.Name,(SELECT District__c,Province__c FROM Addresses__r),Owner.RC_Code__c,Owner.AH_RC_Code__c,Owner.NH_RC_Code__c,Permanent_Team_Name__r.RC_Code__c,Permanent_Team_Name__r.AH_RC_Code__c,Permanent_Team_Name__r.NH_RC_Code__c FROM Account where Permanent_Team_Name__c IN(SELECT Id FROM Team_Structure__c WHERE NH_RC_Code__c = '22900') AND Owner.NH_RC_Code__c = '22900' limit 100
    var reAssignPermanenceStore = createStoreModel(reAssignPermanenceModelName, config.pagesize, {
        filters: [{
            property: 'Owner.AH_RC_Code__c',
            value: '#'+config.user_rc_code
        },{ 
            property: 'RecordType.DeveloperName',
            operator: 'NOT IN',
            value: '[Organization_Prospect, Individual_Prospect]'
        },{
            property: 'Permanent_Team_Name__c',
            operator: 'IN',
            value: '(SELECT Id FROM Team_Structure__c WHERE AH_RC_Code__c = \''+config.user_rc_code+'\' OR RC_Code__c = \''+config.user_rc_code+'\')'
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    //SELECT Id,CIS__c,Owner.Name,(SELECT District__c,Province__c FROM Addresses__r),Owner.RC_Code__c,Owner.AH_RC_Code__c,Owner.NH_RC_Code__c,Permanent_Team_Name__r.RC_Code__c,Permanent_Team_Name__r.AH_RC_Code__c,Permanent_Team_Name__r.NH_RC_Code__c FROM Account where Permanent_Team_Name__c NOT IN(SELECT Id FROM Team_Structure__c WHERE NH_RC_Code__c = '22900') AND Owner.NH_RC_Code__c = '22900' limit 100
    var reAssignTemporaryStore = createStoreModel(reAssignTemporaryModelName, config.pagesize, {
        filters: [{
            property: 'Owner.AH_RC_Code__c !',
            value: '#'+config.user_rc_code
        },{
            property: 'SME_Temporary_Customer__r.User__r.AH_RC_Code__c',
            value: '#'+config.user_rc_code
        },{
            property: 'Permanent_Team_Name__c',
            operator: 'NOT IN',
            value: '(SELECT Id FROM Team_Structure__c WHERE AH_RC_Code__c = \''+config.user_rc_code+'\' OR RC_Code__c = \''+config.user_rc_code+'\')'
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var reAssignOwnedByOtherStore = createStoreModel(reAssignOwnedByOtherModelName, config.pagesize, {
        filters: [{
            property: 'Owner.Name !',
            value: 'SME-Admin'
        },{
            property: 'SME_Temporary_Customer__r.User__r.AH_RC_Code__c',
            operator: 'NOT IN',
            value: '['+config.user_rc_code+', ]'
        },{
            property: 'Permanent_Team_Name__c',
            operator: 'IN',
            value: '(SELECT Id FROM Team_Structure__c WHERE AH_RC_Code__c = \''+config.user_rc_code+'\' OR RC_Code__c = \''+config.user_rc_code+'\')'
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var reAssignPermanenceCheckbox = function(record) {
        //console.log(record);
        return (record.Bulk_Assignments__r == null)||(record.Bulk_Assignments__r[0].Status__c == "Complete");//(!record.Owner.RC_Code__c || record.Owner.RC_Code__c == null || typeof record.Owner.RC_Code__c === "undefined") && (!record.Owner.AH_RC_Code__c || record.Owner.AH_RC_Code__c == null || typeof record.Owner.AH_RC_Code__c === "undefined") && (!record.Owner.NH_RC_Code__c || record.Owner.NH_RC_Code__c == null || typeof record.Owner.NH_RC_Code__c === "undefined");
    };

    var reAssignTemporaryCheckbox = function(record) {
        //console.log(record);
        return (record.Bulk_Assignments__r == null)||(record.Bulk_Assignments__r[0].Status__c == "Complete");//record.Status__c=='New';
    };

    var reAssignOwnedByOtherCheckbox = function(record) {
        return record;//record.Status__c=='New';
    };

    var viewTMLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedBy,{},true);
    var viewAHLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedTMByAH,{extra:'All'},true);

    var viewTMLevelOwnerTab = viewTMLevel;
    var viewAHLevelOwnerTab = viewAHLevel;

    var popupTMLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedBy,{},true);
    var popupAHLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedTMByAH,{},true);

    var servicePanelStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedBy,{},true);
    var temporaryPanelStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedBy,{},true);

    var popupTMLevelOwnerTab = popupTMLevel;
    var popupAHLevelOwnerTab = popupAHLevel;

    var servicePanelStoreOwnerTab = servicePanelStore;
    var temporaryPanelStoreOwnerTab = temporaryPanelStore;

    /*
    Popup Permanent Tab
    */
    // Popup AH
    var selectByRefTeamPanelComboboxOne = createComboxbox(config.map_label.BulkAssign_TMLevelName, 'selectedbyname', false, popupAHLevel, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                delete popupTMLevel.proxy.extraParams.scope;
                delete popupTMLevel.proxy.extraParams.subScope;

                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    selectByTeamPanelComboboxTwo.clearValue();
                    selectByTeamPanelComboboxTwo.enable();
                    popupTMLevel.proxy.extraParams.scope = selected.get('pvalue');
                    popupTMLevel.proxy.extraParams.subScope = 'AHLevel';
                    popupTMLevel.reload();
                    targetRM = selected.get('pvalue');
                } else{
                    selectByTeamPanelComboboxTwo.clearValue();
                    selectByTeamPanelComboboxTwo.disable(); 
                }
            }
        }
    });
    // Popup TM
    var selectByRefTeamPanelComboboxTwo = createComboxbox(config.map_label.BulkAssign_RMLevelName, 'selectedByRMName', false, popupTMLevel, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                if(selected.get('pkey') != 'SME-TM'){
                    portPoolPanelCombobox.setValue('Port');

                    servicePanelCombobox.clearValue();
                    temporaryPanelCombobox.clearValue();

                    servicePanelCombobox.disable();
                    temporaryPanelCombobox.disable();
                    portPoolPanelCombobox.disable();

                    servicePanelCombobox.hide();
                    temporaryPanelCombobox.hide();

                    servicePanelStore.reload();
                    temporaryPanelStore.reload();
                }else{
                    portPoolPanelCombobox.enable();
                }
            }
        }
    });
    // Popup Port/Pool
    var portPoolPanelCombobox = createComboxbox('Port/Pool', 'portPoolpanel', false,
        new Ext.data.ArrayStore({
            id: 0,
            fields: [
                'property',
                'value'
            ],
            data: [
                ['Port','Port'],
                ['Pool','Pool']
            ]
        }), config.map_label.BulkAssign_Port + ' ' + config.map_label.BulkAssign_Pool, 'pname', 'pvalue', false, false, {
            value: '',
            valueField: 'value',
            displayField: 'property',
            listeners: {
                select: function(combox, selected, index) {
                    if(selected.data && selected.data.value=='Pool'){
                        servicePanelCombobox.clearValue();
                        temporaryPanelCombobox.clearValue();

                        servicePanelCombobox.enable();
                        temporaryPanelCombobox.disable();
                        //temporaryPanelCombobox.enable();

                        servicePanelCombobox.show();
                        temporaryPanelCombobox.hide();
                        //temporaryPanelCombobox.show();

                        servicePanelStore.proxy.extraParams.scope = targetRM;
                        servicePanelStore.proxy.extraParams.subScope = 'AHLevelServiceRM';
                        //temporaryPanelStore.proxy.extraParams.scope = targetRM;
                        //temporaryPanelStore.proxy.extraParams.subScope = 'AHLevelServiceRM';

                        servicePanelStore.reload();
                        //temporaryPanelStore.reload();
                    }else{
                        servicePanelCombobox.clearValue();
                        temporaryPanelCombobox.clearValue();

                        servicePanelCombobox.disable();
                        temporaryPanelCombobox.disable();

                        servicePanelCombobox.hide();
                        temporaryPanelCombobox.hide();
                    }
                }
            }
        });
    // Popup Service RM
    var servicePanelCombobox = createComboxbox('Service RM', 'serviceRMpanel', false, servicePanelStore, 'ServiceRM', 'pname', 'pvalue', false, true, {
        listeners: {
            select: function(combox, selected, index) {
                if(selected.data && selected.data.value!=''){
                    temporaryPanelCombobox.clearValue();
                    temporaryPanelCombobox.disable();
                }else{
                    temporaryPanelCombobox.clearValue();
                    temporaryPanelCombobox.enable();
                }
            }
        }
    });
    // Popup Temporary
    var temporaryPanelCombobox = createComboxbox('Temporary RM', 'temporaryRMpanel', false, temporaryPanelStore, 'TemporaryRM', 'pname', 'pvalue', false, true, {
        listeners: {
            select: function(combox, selected, index) {
                if(selected.data && selected.data.value!=''){
                    servicePanelCombobox.clearValue();
                    servicePanelCombobox.disable();
                }else{
                    servicePanelCombobox.clearValue();
                    servicePanelCombobox.enable();
                }
            }
        }
    });

    portPoolPanelCombobox.disable();
    servicePanelCombobox.hide();
    temporaryPanelCombobox.hide();

    /*
    Popup Owner Tab
    */
    // Popup AH
    var selectByRefTeamPanelComboboxOneOwnerTab = createComboxbox(config.map_label.BulkAssign_TMLevelName, 'selectedbyname', false, popupAHLevelOwnerTab, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                delete popupTMLevelOwnerTab.proxy.extraParams.scope;
                delete popupTMLevelOwnerTab.proxy.extraParams.subScope;

                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    selectByTeamPanelComboboxTwoOwnerTab.clearValue();
                    selectByTeamPanelComboboxTwoOwnerTab.enable();
                    popupTMLevelOwnerTab.proxy.extraParams.scope = selected.get('pvalue');
                    popupTMLevelOwnerTab.proxy.extraParams.subScope = 'AHLevel';
                    popupTMLevelOwnerTab.reload();
                    targetRMOwnerTab = selected.get('pvalue');
                } else{
                    selectByTeamPanelComboboxTwoOwnerTab.clearValue();
                    selectByTeamPanelComboboxTwoOwnerTab.disable(); 
                }
            }
        }
    });
    // Popup TM
    var selectByRefTeamPanelComboboxTwoOwnerTab = createComboxbox(config.map_label.BulkAssign_RMLevelName, 'selectedByRMName', false, popupTMLevelOwnerTab, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90
    });

    // Header Filter TM
    var selectByRefComboboxTwo = createComboxbox(config.map_label.BulkAssign_RMLevelName, 'filterByRMName', false, viewTMLevel, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    selectedRMId = selected.get('pvalue');
                    grid.store.filter("OwnerId", '#'+selected.get('pvalue'));
                } else grid.store.removeFilter("OwnerId");
            }
        }
    });

    // Header Filter TM Owner Tab
    var selectByRefComboboxTwoOwnerTab = createComboxbox(config.map_label.BulkAssign_RMLevelName, 'filterByRMName', false, viewTMLevelOwnerTab, config.map_label.BulkAssign_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    selectedTempRMId = selected.get('pvalue');
                    grid.store.filter("OwnerId", '#'+selected.get('pvalue'));
                } else grid.store.removeFilter("OwnerId");
            }
        }
    });

    var selectByFilterOnComboboxTwo = selectByRefComboboxTwo.cloneConfig();
    var selectByTeamPanelComboboxOne = selectByRefTeamPanelComboboxOne.cloneConfig();
    var selectByTeamPanelComboboxTwo = selectByRefTeamPanelComboboxTwo.cloneConfig();

    var selectByFilterOnComboboxTwoOwnerTab = selectByRefComboboxTwoOwnerTab.cloneConfig();
    var selectByTeamPanelComboboxOneOwnerTab = selectByRefTeamPanelComboboxOneOwnerTab.cloneConfig();
    var selectByTeamPanelComboboxTwoOwnerTab = selectByRefTeamPanelComboboxTwoOwnerTab.cloneConfig();

    selectByFilterOnComboboxTwo.disable();
    selectByTeamPanelComboboxTwo.disable();
    selectByFilterOnComboboxTwoOwnerTab.disable();
    selectByTeamPanelComboboxTwoOwnerTab.disable();

    function reloadAllStore(){
        reAssignPermanenceStore.reload();
        reAssignTemporaryStore.reload();
        reAssignOwnedByOtherStore.reload();
    };

    var usable_element = {
        customer_selected_by_team :function(flisteners){
            return {
                xtype: 'combobox',
                labelWidth: 60,
                fieldLabel: config.map_label.BulkAssign_TMLevelName,
                triggerAction: 'all',
                editable: false,
                mode: 'remote',
                store: viewAHLevel,
                valueField: 'pvalue',
                displayField: 'pname',
                listeners: flisteners,
                value: config.map_label.BulkAssign_ShowAll
            };
        },customer_selected_by_team_OwnerTab :function(flisteners){
            return {
                xtype: 'combobox',
                labelWidth: 60,
                fieldLabel: config.map_label.BulkAssign_TMLevelName,
                triggerAction: 'all',
                editable: false,
                mode: 'remote',
                store: viewAHLevelOwnerTab,
                valueField: 'pvalue',
                displayField: 'pname',
                listeners: flisteners,
                value: config.map_label.BulkAssign_ShowAll
            };
        }
    };

    var selectconfirm_popup = createPanel({
        id: 'selectedPanel',
        title: 'Assign To',
        items: [selectByTeamPanelComboboxOne,selectByTeamPanelComboboxTwo,portPoolPanelCombobox,servicePanelCombobox,temporaryPanelCombobox],
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
                            var grid = Ext.getCmp('reAssignPermanenceGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPermanenceCheckbox(record.data);
                            });
                            if (final_selections.length > 0 && form.getFieldValues().selectedByRMName != null) {
                                grid.setLoading(true);
                                selectconfirm_popup.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignPermanenceGrid'
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
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
                                           }else Ext.Msg.alert(config.map_label.BulkAssign_Servererror, results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, errors[0]);
                                    });
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
        }]
    });

    var selectconfirm_popupOwnerTab = createPanel({
        id: 'selectedPanelOwnerTab',
        title: 'Assign To',
        items: [selectByTeamPanelComboboxOneOwnerTab,selectByTeamPanelComboboxTwoOwnerTab],
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
                            var grid = Ext.getCmp('reAssignTemporaryGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignTemporaryCheckbox(record.data);
                            });
                            if (final_selections.length > 0 && form.getFieldValues().selectedByRMName != null) {
                                grid.setLoading(true);
                                selectconfirm_popupOwnerTab.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignTemporaryGrid'
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();
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
                                           }else Ext.Msg.alert(config.map_label.BulkAssign_Servererror, results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.BulkAssign_Servererror, errors[0]);
                                    });
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
        }]
    });

    config.panel_items = [
        createGridObject(config.map_label.BulkAssign_CustomerList, 'reAssignPermanenceGrid', reAssignPermanenceStore, reAssignPermanenceColumn, {
            
            clearAll: function(){
                var grid = this;
                if (selectedOwnerTMId != '') {
                    grid.store.filter("Owner.RC_Code__c", '#'+selectedOwnerTMRCCode);
                    viewTMLevel.proxy.extraParams.scope = selectedOwnerTMId;
                    viewTMLevel.proxy.extraParams.subScope = 'AHLevel';
                    if(selectedRMId != ''){
                        grid.store.filter("OwnerId", '#'+selectedRMId);
                    }
                    viewTMLevel.reload();
                }
                viewAHLevel.load();
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
                            return reAssignPermanenceCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            delete popupTMLevel.proxy.extraParams.scope;
                            delete popupTMLevel.proxy.extraParams.subScope;

                            delete popupTMLevelOwnerTab.proxy.extraParams.scope;
                            delete popupTMLevelOwnerTab.proxy.extraParams.subScope;

                            popupAHLevel.reload();
                            popupTMLevel.reload();

                            popupAHLevelOwnerTab.reload();
                            popupTMLevelOwnerTab.reload();

                            selectByTeamPanelComboboxOne.clearValue();
                            selectByTeamPanelComboboxTwo.clearValue();

                            selectByTeamPanelComboboxTwo.disable();

                            servicePanelCombobox.clearValue();
                            temporaryPanelCombobox.clearValue();
                            portPoolPanelCombobox.clearValue();

                            servicePanelCombobox.disable();
                            temporaryPanelCombobox.disable();
                            portPoolPanelCombobox.disable();

                            servicePanelCombobox.hide();
                            temporaryPanelCombobox.hide();

                            selectconfirm_popup.show();
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
                    },
                    usable_element.customer_selected_by_team({
                        load: function(a,b,c) {},
                        select: function(combox, selected, index) {
                            var grid = this.up('grid');
                            grid.store.removeFilter("Owner");
                            selectedRMId = '';
                            selectedOwnerTMId = '';
                            selectedOwnerTMRCCode = '';
                            if (selected.data.pvalue == '') {
                                selectByFilterOnComboboxTwo.clearValue();
                                selectByFilterOnComboboxTwo.disable();
                                grid.store.removeFilter("Owner.RC_Code__c");
                                grid.store.removeFilter("OwnerId");
                                delete viewTMLevel.proxy.extraParams.scope;
                            }else {
                                selectedOwnerTMId = selected.data.pvalue;
                                selectedOwnerTMRCCode = selected.data.pkey;
                                selectByFilterOnComboboxTwo.clearValue();
                                selectByFilterOnComboboxTwo.enable();
                                
                                grid.store.filter("Owner.RC_Code__c", '#'+selected.data.pkey);
                                grid.store.removeFilter("OwnerId");
                                viewTMLevel.proxy.extraParams.scope = selected.data.pvalue;
                                viewTMLevel.proxy.extraParams.subScope = 'AHLevel';
                                viewTMLevel.reload();
                            }
                            viewAHLevel.load();
                            grid.getView().getSelectionModel().deselectAll();
                        }
                    }),
                    {
                        xtype: 'tbspacer'
                    },
                    selectByFilterOnComboboxTwo
                ]
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignPermanenceStore.sync();
                    reAssignPermanenceStore.reload();
                },
                'headerclick': function(g, index, ev) {
                    //console.log(index.dataIndex);
                    if(index.dataIndex === 'Addresses__r' || index.dataIndex === 'Behaviour_Scores__r'){
                        return false;
                    }
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignPermanenceCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject(config.map_label.BulkAssign_TempOwnerList, 'reAssignTemporaryGrid', reAssignTemporaryStore, reAssignTemporaryColumn, {
            
            clearAll: function(){
                var grid = this;
                if (selectedOwnerTempTMId != '') {
                    grid.store.filter("SME_Temporary_Customer__r.User__r.RC_Code__c", '#'+selectedOwnerTempTMRCCode);
                    viewTMLevelOwnerTab.proxy.extraParams.scope = selectedOwnerTempTMId;
                    viewTMLevelOwnerTab.proxy.extraParams.subScope = 'AHLevel';

                    if(selectedTempRMId != ''){
                        grid.store.filter("SME_Temporary_Customer__r.User__c", '#'+selectedTempRMId);
                    }

                    viewTMLevelOwnerTab.reload();
                }
                viewAHLevelOwnerTab.load();
                
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
                            return reAssignTemporaryCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            delete popupTMLevel.proxy.extraParams.scope;
                            delete popupTMLevel.proxy.extraParams.subScope;

                            delete popupTMLevelOwnerTab.proxy.extraParams.scope;
                            delete popupTMLevelOwnerTab.proxy.extraParams.subScope;

                            popupAHLevel.reload();
                            popupTMLevel.reload();

                            popupAHLevelOwnerTab.reload();
                            popupTMLevelOwnerTab.reload();

                            selectByTeamPanelComboboxOneOwnerTab.clearValue();
                            selectByTeamPanelComboboxTwoOwnerTab.clearValue();

                            selectByTeamPanelComboboxTwoOwnerTab.disable();

                            selectconfirm_popupOwnerTab.show();
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
                    },
                    usable_element.customer_selected_by_team_OwnerTab({
                        load: function(a,b,c) {},
                        select: function(combox, selected, index) {
                            var grid = this.up('grid');
                            grid.store.removeFilter("Owner");
                            selectedTempRMId = '';
                            selectedOwnerTempTMId = '';
                            selectedOwnerTempTMRCCode = '';
                            if (selected.data.pvalue == '') {
                                selectByFilterOnComboboxTwoOwnerTab.clearValue();
                                selectByFilterOnComboboxTwoOwnerTab.disable();
                                grid.store.removeFilter("SME_Temporary_Customer__r.User__r.RC_Code__c");
                                grid.store.removeFilter("SME_Temporary_Customer__r.User__c");
                                delete viewAHLevelOwnerTab.proxy.extraParams.scope;
                            }else {
                                selectedOwnerTempTMId = selected.data.pvalue;
                                selectedOwnerTempTMRCCode = selected.data.pkey;
                                selectByFilterOnComboboxTwoOwnerTab.clearValue();
                                selectByFilterOnComboboxTwoOwnerTab.enable();
                                
                                grid.store.filter("SME_Temporary_Customer__r.User__r.RC_Code__c", '#'+selected.data.pkey);
                                grid.store.removeFilter("SME_Temporary_Customer__r.User__c");
                                viewTMLevelOwnerTab.proxy.extraParams.scope = selected.data.pvalue;
                                viewTMLevelOwnerTab.proxy.extraParams.subScope = 'AHLevel';
                                viewTMLevelOwnerTab.reload();
                            }
                            viewAHLevelOwnerTab.load();
                            grid.getView().getSelectionModel().deselectAll();
                        }
                    }),
                    {
                        xtype: 'tbspacer'
                    },
                    selectByFilterOnComboboxTwoOwnerTab
                ] 
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignTemporaryStore.sync();
                    reAssignTemporaryStore.reload();
                },
                'headerclick': function(g, index, ev) {
                    //console.log(index.dataIndex);
                    if(index.dataIndex === 'Addresses__r' || index.dataIndex === 'Behaviour_Scores__r'){
                        return false;
                    }
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignTemporaryCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject(config.map_label.BulkAssign_OwnerByOtherList, 'reAssignOwnedByOtherGrid', reAssignOwnedByOtherStore, reAssignOwnedByOtherColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                },{
                    xtype: 'toolbar',
                    dock: 'top',
                }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignOwnedByOtherStore.sync();
                    reAssignOwnedByOtherStore.reload();
                },
                'headerclick': function(g, index, ev) {
                    //console.log(index.dataIndex);
                    if(index.dataIndex === 'Addresses__r' || index.dataIndex === 'Behaviour_Scores__r'){
                        return false;
                    }
                }
            }
        })
    ];
};
