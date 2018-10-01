function init(config) {
    var reAssignPermanenceColumn = mappingColumn(config.reAssignPermanenceForMap,["CIS__c","Name_Report__c","Primary_Segment_Code__c","High_Value__c","Credit_Flag__c","Port_Pool__c","District__c","Province__c","Customer_Status__c","Ownership__c","Current_Owner__c","Current_Team_Name__c","Permanent_Owner_Extension__c","Permanent_Team_Name__c","Previous_Owner_Extension__c","Previous_Team_Name__c","Service_RM__c","Customer_s_Business_Code__c","Business_Code_Name_TH__c","Status__c","Income_to_SME__c","Income_to_Bank_This_Year__c","Income_to_Bank_Last_Year__c","Total_SME_Limit__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_Exposure__c","Wallet_Size_Exposure__c","SME_Bscore_1M","SME_Bscore_2M","SME_Bscore_3M","Last_Visited_Date__c","Last_Visited_By__c","Number_of_Visited__c","Last_Setup_Date__c","Last_Setup_By__c","Current_Activity__c","Current_Activity_By__c"]);

    var reAssignTemporaryColumn = reAssignPermanenceColumn;//mappingColumn(config.reAssignTemporaryForMap,["CIS_ID_Unique__c","Customer_Name__c","Customer/Prospect","Port/Pool","Ownership","Service RM","Permanent RC Team","Previous Owner","Previous Owner Team","Current Owner","High Value","Credit Status (G/B)","Income to Bank (Last Year)","Income to Bank (This Year)","Number of Visited","Lead for Sales ","Lead to Do","Campaign/Event","Credit/Non-Credit*"]);

    var reAssignOwnedByOtherColumn = reAssignPermanenceColumn;//mappingColumn(config.reAssignOwnedByOtherForMap,["CIS_ID_Unique__c","Customer_Name__c","Customer/Prospect","Port/Pool","Ownership","Service RM","Permanent RC Team","Previous Owner","Previous Owner Team","Current Owner","High Value","Credit Status (G/B)","Income to Bank (Last Year)","Income to Bank (This Year)","Number of Visited","Lead for Sales ","Lead to Do","Campaign/Event","Credit/Non-Credit*"]);


    var reAssignPermanenceModelName = Ext.String.capitalize("Account1");
    var reAssignTemporaryModelName = Ext.String.capitalize("Account2");
    var reAssignOwnedByOtherModelName = Ext.String.capitalize("Account3");

    // Create Model
    createModel(reAssignPermanenceModelName, 'records', 'Id',
         [{name:'Addresses__r',mapping:'Addresses__r'}], 
			RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignPermanencefieldlist.join(',')
        }
    );
    createModel(reAssignTemporaryModelName, 'records', 'Id',
        [{name:'Addresses__r',mapping:'Addresses__r'}],
            RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignTemporaryfieldlist.join(',')
        }
    );
    createModel(reAssignOwnedByOtherModelName, 'records', 'Id',
        [{name:'Addresses__r',mapping:'Addresses__r'}],
            RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignOwnedByOtherfieldlist.join(',')
        }
    );

    // Create Store Model
    var reAssignPermanenceStore = createStoreModel(reAssignPermanenceModelName, config.pagesize, {
        /*filters: [{
            property: 'RM_Employee_ID__c',
            value: '#'+config.user_empid
        }]*/
    });

    var reAssignTemporaryStore = createStoreModel(reAssignTemporaryModelName, config.pagesize, {
        /*filters: [{
            property: 'RM_Employee_ID__c',
            value: '#'+config.user_empid
        }]*/
    });

    var reAssignOwnedByOtherStore = createStoreModel(reAssignOwnedByOtherModelName, config.pagesize, {
        /*filters: [{
            property: 'RM_Employee_ID__c',
            value: '#'+config.user_empid
        }]*/
    });

    var reAssignPermanenceCheckbox = function(record) {
        /*return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='') && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c==null || typeof record.Final_Refer_Out__c === "undefined" || record.Final_Refer_Out__c=='') && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r==null || typeof record.Year_End_Assignment_Selections__r === "undefined" || record.Year_End_Assignment_Selections__r.length == 0));*/
        return record;
    };

    var reAssignTemporaryCheckbox = function(record) {
        /*return record.Year_End_Assignment__r.Status__c=='New' && (record.Selected_By__c == config.user_id) && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='');*/
        return record.Status__c=='New';
    };

    var reAssignOwnedByOtherCheckbox = function(record) {
        /*return record.Year_End_Assignment__r.Status__c=='New' && (record.Selected_By__c == config.user_id) && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='');*/
        return record.Status__c=='New';
    };

    var reasonStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Reason__c'},true);
    var segmentStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Segment__c'},true);

    var provinceStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryLocation,{scope:'Province'},true);
    var aumpurStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryLocation,{scope:'District'},false);
    var tumbonStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryLocation,{scope:'Sub District'},false);

    var segmentCombobox = createComboxbox(config.map_label.reAssign_ReferOutSegment+'', 'referoutSegment', true, segmentStore, config.map_label.reAssign_Select_a_Segment, 'pname', 'pvalue', false, true);
    var reasonCombobox = createComboxbox(config.map_label.reAssign_Refer_Out_Reason, 'referoutReason', false, reasonStore, config.map_label.reAssign_Select_a_Reason, 'pname', 'pvalue', false, false);

    var provinceCombobox = createComboxbox(config.map_label.reAssign_Refer_Out_Province, 'referoutProvince', true, provinceStore, config.map_label.reAssign_SelectaProvince, 'pname', 'pvalue', false, true);
    var aumpurCombobox = createComboxbox(config.map_label.reAssign_Refer_Out_Aumpur, 'referoutAumpur', true, aumpurStore, config.map_label.reAssign_SelectaAumpur, 'pname', 'pvalue', false, true);
    var tumbonCombobox = createComboxbox(config.map_label.reAssign_Refer_Out_Tumbon, 'referoutTumbon', true, tumbonStore, config.map_label.reAssign_SelectaTumbon, 'pname', 'pvalue', false, true);

    var viewTMLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},false);
    var viewAHLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},false);
    var viewNHLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},false);

    var TMCombobox = createComboxbox(config.map_label.BulkAssign_TM_Level, 'bulkTMLevel', true, viewTMLevel, config.map_label.BulkAssign_TM_Level, 'pname', 'pvalue', false, true);
    var AHCombobox = createComboxbox(config.map_label.BulkAssign_AH_Level, 'bulkAHLevel', true, viewAHLevel, config.map_label.BulkAssign_AH_Level, 'pname', 'pvalue', false, true);
    var NHCombobox = createComboxbox(config.map_label.BulkAssign_NH_Level, 'bulkNHLevel', true, viewNHLevel, config.map_label.BulkAssign_NH_Level, 'pname', 'pvalue', false, true);

    var referOutTeamText = new Ext.form.TextField({
        fieldLabel: config.map_label.reAssign_ReferOutTeam,
        name: 'referoutTeam',
        hidden: true
    });

    var cisText = new Ext.form.TextField({
        fieldLabel: config.reAssignPermanenceForMap["CIS__c"],
        name: 'search_box'
    });

    /*reasonCombobox.on('select', function(cmb, record, index) {

        provinceCombobox.hide();
        aumpurCombobox.hide();
        tumbonCombobox.hide();
        referOutTeamText.hide();
        segmentCombobox.hide();

        provinceCombobox.clearValue();
        aumpurCombobox.clearValue();
        tumbonCombobox.clearValue();
        referOutTeamText.setValue('');
        segmentCombobox.clearValue();

        provinceCombobox.labelEl.update(config.map_label.reAssign_SelectaProvince+':');
        aumpurCombobox.labelEl.update(config.map_label.reAssign_SelectaAumpur+':');
        tumbonCombobox.labelEl.update(config.map_label.reAssign_SelectaTumbon+':');
        referOutTeamText.labelEl.update(config.map_label.reAssign_ReferOutTeam+':');
        segmentCombobox.labelEl.update(config.map_label.reAssign_ReferOutSegment+':');

        provinceCombobox.allowBlank = true;
        aumpurCombobox.allowBlank = true;
        tumbonCombobox.allowBlank = true;
        referOutTeamText.allowBlank = true;
        segmentCombobox.allowBlank = true;
        if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Wrong Area') {
            provinceCombobox.labelEl.update(config.map_label.reAssign_SelectaProvince+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            aumpurCombobox.labelEl.update(config.map_label.reAssign_SelectaAumpur+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            tumbonCombobox.labelEl.update(config.map_label.reAssign_SelectaTumbon+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');

            provinceCombobox.allowBlank = false;
            aumpurCombobox.allowBlank = false;
            tumbonCombobox.allowBlank = false;

            provinceCombobox.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Team') {
            referOutTeamText.allowBlank = false;
            referOutTeamText.labelEl.update(config.map_label.reAssign_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            referOutTeamText.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Segment') {
            segmentCombobox.allowBlank = false;
            segmentCombobox.labelEl.update(config.map_label.reAssign_ReferOutSegment+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            segmentCombobox.show();
        }

        provinceCombobox.clearInvalid();
        aumpurCombobox.clearInvalid();
        tumbonCombobox.clearInvalid();
        referOutTeamText.clearInvalid();
        segmentCombobox.clearInvalid();
    });

    provinceCombobox.on('select', function(cmb, record, index) {
        aumpurCombobox.hide();
        aumpurCombobox.clearValue();

        tumbonCombobox.hide();
        tumbonCombobox.clearValue();

        if (record.get('pvalue') && record.get('pvalue') != '') {
            aumpurCombobox.show();
            aumpurStore.proxy.extraParams.extra = record.get('pvalue');
            aumpurStore.load();
        }
    });

    aumpurCombobox.on('select', function(cmb, record, index) {
        tumbonCombobox.hide();
        tumbonCombobox.clearValue();

        if (record.get('pvalue') && record.get('pvalue') != '') {
            tumbonCombobox.show();
            tumbonStore.proxy.extraParams.extra = record.get('pvalue');
            tumbonStore.load();
        }
    });*/

    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: config.map_label.reAssign_Refer_Out,
        //items: [reasonCombobox, provinceCombobox, aumpurCombobox, tumbonCombobox, segmentCombobox, referOutTeamText],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: config.map_label.reAssign_Save/*,
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('reAssignGrid');
                              var selections = grid.getView().getSelectionModel().getSelection();
                              var final_selections = _.filter(selections, function(record){
                                 return reAssignCheckbox(record.data);
                              });
                              if(final_selections.length > 0){
                                grid.setLoading(true);
                                referout_popup.hide();
                                Ext.Deferred
                                .all([sendRequest('saveBulk',{
                                          contx:'REFER_OUT',
                                          referOut:form.getFieldValues(),
                                          yearlist:_.pluck(final_selections,'id')
                                  })])
                                .then(function (results) {

                                    if (results[0].success) {
                                        grid.getView().getSelectionModel().deselectAll();

                                        reloadAllStore();

                                    } else{
                                        if(results[0].duplicate){
                                          Ext.MessageBox.confirm(
                                             config.map_label.reAssign_PleaseConfirmtoRefreshList,
                                             results[0].errorMessage,
                                             function(btn, text) {
                                                if (btn=='yes') {
                                                    grid.getView().getSelectionModel().deselectAll();

                                                    reloadAllStore();
                                                }
                                             grid.setLoading(false);
                                          });
                                       }else Ext.Msg.alert(config.map_label.reAssign_Servererror, results[0].errorMessage);
                                    }
                                    grid.setLoading(false);
                                },function (errors) {
                                    Ext.Msg.alert(config.map_label.reAssign_Servererror, errors[0]);
                                });
                            }else Ext.Msg.alert(config.map_label.reAssign_InvalidSelection,config.map_label.reAssign_NoreAssignhavebeenselected);

                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.reAssign_Invalid_Fields, config.map_label.reAssign_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }*/
                }
            ]
        }]
    });
    function reloadAllStore(){
        reAssignPermanenceStore.reload();
        reAssignTemporaryStore.reload();
        reAssignOwnedByOtherStore.reload();
    };
    var usable_element = {
        remove_selection :function(){
            return {
                text: config.map_label.BulkAssign_Submitted/*,
                handler: function(){
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var final_selections = _.filter(selections, function(record){
                        return reAssignSelCheckbox(record.data);
                    });
                    if(final_selections.length > 0){

                        Ext.MessageBox.confirm(
                            config.map_label.reAssign_PleaseConfirm,
                            config.map_label.reAssign_AreYouConfirmtoRemoveselected,
                            function(btn, text) {
                                if (btn=='yes') {
                                    var savingObj = sendRequest('deletereAssignSel',{
                                        yearlist:_.pluck(final_selections,'id')
                                    });
                                    grid.setLoading(true);
                                    Ext.Deferred
                                    .all([savingObj])
                                    .then(function (results) {

                                        if(results[0].success){
                                           grid.getView().getSelectionModel().deselectAll();
                                           reloadAllStore();

                                        }else{
                                           if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                 config.map_label.reAssign_PleaseConfirmtoRefreshList,
                                                 results[0].errorMessage,
                                                 function(btn, text) {
                                                    if (btn=='yes') {
                                                       grid.getView().getSelectionModel().deselectAll();
                                                       reloadAllStore();
                                                    }
                                                 grid.setLoading(false);
                                              });
                                           }else Ext.Msg.alert(config.map_label.reAssign_Servererror, results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    },function (errors) {
                                        Ext.Msg.alert(config.map_label.reAssign_Servererror, errors[0]);
                                        grid.setLoading(false);
                                    });

                                }
                        });


                    }else Ext.Msg.alert(config.map_label.reAssign_InvalidSelection, config.map_label.reAssign_NoreAssignhavebeenselected);

                }*/
            };
        },
        select_by_me :function(){
            return {
                xtype: 'checkbox',
                boxLabel: config.map_label.reAssign_SelectedByMe,
                checked: true,
                handler: function(model,selected){
                    var grid = this.up('grid');
                    if(selected){
                        grid.store.filter("Selected_By__c", config.user_id);
                        grid.store.sort("CIS__c", 'ASC');
                    }else {
                       grid.store.removeFilter("Selected_By__c");
                    }
                    grid.getView().getSelectionModel().deselectAll();
                }
            };
        }
    };
    config.panel_items = [
        createGridObject(config.map_label.BulkAssign_CustomerList, 'reAssignPermanenceGrid', reAssignPermanenceStore, reAssignPermanenceColumn, { //extra here

            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function(){
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record){
                            return reAssignCheckbox(record.data);
                        });
                        console.log(record.data);
                    }
                    /*    
                        if(final_selections.length > 0){
                            Ext.MessageBox.confirm(
                                config.map_label.reAssign_PleaseConfirm,
                                config.map_label.reAssign_AreYouConfirmtoSelect,
                                function(btn, text) {
                                    if (btn=='yes') {
                                        var savingObj = sendRequest('saveBulk',{
                                            contx:'SELECTED',
                                            yearlist:_.pluck(final_selections,'id')
                                        });
                                        grid.setLoading(true);
                                        Ext.Deferred
                                        .all([savingObj])
                                        .then(function (results) {
                                            //console.log(results);
                                            if(results[0].success){
                                                grid.getView().getSelectionModel().deselectAll();
                                                reloadAllStore();
                                            }else {
                                               if(results[0].duplicate){
                                                  Ext.MessageBox.confirm(
                                                     config.map_label.reAssign_PleaseConfirmtoRefreshList,
                                                     results[0].errorMessage,
                                                     function(btn, text) {
                                                        if (btn=='yes') {
                                                           grid.getView().getSelectionModel().deselectAll();
                                                           reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                  });
                                               }else Ext.Msg.alert(config.map_label.reAssign_Servererror, results[0].errorMessage);
                                            }
                                            grid.setLoading(false);
                                        },function (errors) {
                                            Ext.Msg.alert(config.map_label.reAssign_Servererror, errors[0].errorMessage);
                                            grid.setLoading(false);
                                        });
                                    }
                                });
                        }else Ext.Msg.alert(config.map_label.reAssign_InvalidSelection,config.map_label.reAssign_NoreAssignhavebeenselected);
                    }*/
                }, {
                    xtype: 'tbspacer'
                }]
            },
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    /*xtype: 'checkbox',
                    name: 'previous_me',
                    boxLabel: config.map_label.reAssign_Previouslyownedbyme,
                    checked: true,
                    handler: function(model,selected){

                    }*/
                    xtype:'combo',
                    fieldLabel:'NH Name',
                    name:'nhlist',
                    queryMode:'local',
                    store:viewNHLevel,
                    displayField:'nhlist',
                    autoSelect:true,
                    forceSelection:true,
                    value: 'RM Name'
                },{
                    xtype:'combo',
                    fieldLabel:'AH List',
                    name:'ahlist',
                    queryMode:'local',
                    store:viewAHLevel,
                    displayField:'ahlist',
                    autoSelect:true,
                    forceSelection:true,
                    value: 'All'
                },{
                    xtype:'combo',
                    fieldLabel:'TM List',
                    name:'tmlist',
                    queryMode:'local',
                    store:viewTMLevel,
                    displayField:'tmlist',
                    autoSelect:true,
                    forceSelection:true,
                    value: 'All'
                }]
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignPermanenceStore.sync();
                    reAssignPermanenceStore.reload();
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
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.remove_selection()]
                },{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{
                        xtype:'combo',
                        fieldLabel:'Current Owner',
                        name:'division',
                        queryMode:'local',
                        store:['All','TM Name','RM1','RM2'],
                        displayField:'division',
                        autoSelect:true,
                        forceSelection:true,
                        value: 'All'
                    }]
                }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignTemporaryStore.sync();
                    reAssignTemporaryStore.reload();
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
                }
            }
        })
    ];
    config.container_items = [referout_popup];
};
