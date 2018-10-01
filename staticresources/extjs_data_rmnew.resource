function init(config) {
    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelRefOutColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelConfirmColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Final_Port_Pool__c","Final_Assigned_RM__c","Final_Service_RM__c","Final_Team__c","Final_Refer_Out__c","Final_Refer_Out_Reason__c","Final_Refer_Out_Reason_Detail__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");

    createModel(yearEndModelName, 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment__c',
            fields: config.fieldlist.join(',')
        }
    );
    createModel(yearEndSelModelName, 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldsellist.join(',')
        }
    );
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        filters: [{
            property: 'RM_Employee_ID__c',
            value: '#'+config.user_empid
        }],
        sorters: [{
            property: 'Team__c',
            direction: 'ASC'
        }]
    });
    var yearEndRefOutStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Selected_By__c',
            value: config.user_id
        },{
            property: 'Refer_Out__c',
            value: 'true'
         }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelSelectedStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Selected_By__c',
            value: config.user_id
        },{
            property: 'Refer_Out__c',
            value: 'false'
         }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    var yearEndSelConfirmStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Selected_By__c',
            value: config.user_id
        },{
            property: 'Year_End_Assignment__r.Final_Assigned_RM__c !',
            value: 'null'
         },{
            property: 'Selected_Count__c',
            value: '1'
         }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    var yearEndCheckbox = function(record) {
        return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='') && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c==null || typeof record.Final_Refer_Out__c === "undefined" || record.Final_Refer_Out__c=='') && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r==null || typeof record.Year_End_Assignment_Selections__r === "undefined" || record.Year_End_Assignment_Selections__r.length == 0));
    };
    var yearEndSelCheckbox = function(record) {
        return record.Year_End_Assignment__r.Status__c=='New' && (record.Selected_By__c == config.user_id) && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='');
    };

    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Reason__c'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Segment__c'},true);

    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Province'},true);
    var aumpurStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'District'},false);
    var tumbonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Sub District'},false);

    var segmentCombobox = createComboxbox(config.map_label.YearEnd_ReferOutSegment+'', 'referoutSegment', true, segmentStore, config.map_label.YearEnd_Select_a_Segment, 'pname', 'pvalue', false, true);
    var reasonCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Reason, 'referoutReason', false, reasonStore, config.map_label.YearEnd_Select_a_Reason, 'pname', 'pvalue', false, false);
    var provinceCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Province, 'referoutProvince', true, provinceStore, config.map_label.YearEnd_SelectaProvince, 'pname', 'pvalue', false, true);
    var aumpurCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Aumpur, 'referoutAumpur', true, aumpurStore, config.map_label.YearEnd_SelectaAumpur, 'pname', 'pvalue', false, true);
    var tumbonCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Tumbon, 'referoutTumbon', true, tumbonStore, config.map_label.YearEnd_SelectaTumbon, 'pname', 'pvalue', false, true);

    var referOutTeamText = new Ext.form.TextField({
        fieldLabel: config.map_label.YearEnd_ReferOutTeam,
        name: 'referoutTeam',
        hidden: true
    });
    var cisText = new Ext.form.TextField({
        fieldLabel: config.yearEndForMap["CIS_ID_Unique__c"],
        name: 'search_box'
    });

    reasonCombobox.on('select', function(cmb, record, index) {

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

        provinceCombobox.labelEl.update(config.map_label.YearEnd_SelectaProvince+':');
        aumpurCombobox.labelEl.update(config.map_label.YearEnd_SelectaAumpur+':');
        tumbonCombobox.labelEl.update(config.map_label.YearEnd_SelectaTumbon+':');
        referOutTeamText.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');
        segmentCombobox.labelEl.update(config.map_label.YearEnd_ReferOutSegment+':');

        provinceCombobox.allowBlank = true;
        aumpurCombobox.allowBlank = true;
        tumbonCombobox.allowBlank = true;
        referOutTeamText.allowBlank = true;
        segmentCombobox.allowBlank = true;
        if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Wrong Area') {
            provinceCombobox.labelEl.update(config.map_label.YearEnd_SelectaProvince+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            aumpurCombobox.labelEl.update(config.map_label.YearEnd_SelectaAumpur+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            tumbonCombobox.labelEl.update(config.map_label.YearEnd_SelectaTumbon+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');

            provinceCombobox.allowBlank = false;
            aumpurCombobox.allowBlank = false;
            tumbonCombobox.allowBlank = false;

            provinceCombobox.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Team') {
            referOutTeamText.allowBlank = false;
            referOutTeamText.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            referOutTeamText.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Segment') {
            segmentCombobox.allowBlank = false;
            segmentCombobox.labelEl.update(config.map_label.YearEnd_ReferOutSegment+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
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
    });

    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: config.map_label.YearEnd_Refer_Out,
        items: [reasonCombobox, provinceCombobox, aumpurCombobox, tumbonCombobox, segmentCombobox, referOutTeamText],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: config.map_label.YearEnd_Save,
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('yearEndGrid');
                              var selections = grid.getView().getSelectionModel().getSelection();
                              var final_selections = _.filter(selections, function(record){
                                 return yearEndCheckbox(record.data);
                              });
                              if(final_selections.length > 0){
                                grid.setLoading(true);
                                referout_popup.hide();
                                Ext.Deferred
                                .all([sendRequest('saveYearEnd',{
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
                                             config.map_label.YearEnd_PleaseConfirmtoRefreshList,
                                             results[0].errorMessage,
                                             function(btn, text) {
                                                if (btn=='yes') {
                                                    grid.getView().getSelectionModel().deselectAll();

                                                    reloadAllStore();
                                                }
                                             grid.setLoading(false);
                                          });
                                       }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                    }
                                    grid.setLoading(false);
                                },function (errors) {
                                    Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                });
                            }else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection,config.map_label.YearEnd_NoYearendhavebeenselected);

                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert(config.map_label.YearEnd_Invalid_Fields, config.map_label.YearEnd_Thefollowingfieldsareinvalid+': ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }]
    });
    function reloadAllStore(){
        yearEndStore.reload();
        yearEndRefOutStore.reload();
        yearEndSelSelectedStore.reload();
        yearEndSelConfirmStore.reload();
    };
    var usable_element = {
        remove_selection :function(){
            return {
                text: config.map_label.YearEnd_RemoveSelection,
                handler: function(){
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var final_selections = _.filter(selections, function(record){
                        return yearEndSelCheckbox(record.data);
                    });
                    if(final_selections.length > 0){

                        Ext.MessageBox.confirm(
                            config.map_label.YearEnd_PleaseConfirm,
                            config.map_label.YearEnd_AreYouConfirmtoRemoveselected,
                            function(btn, text) {
                                if (btn=='yes') {
                                    var savingObj = sendRequest('deleteYearEndSel',{
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
                                                 config.map_label.YearEnd_PleaseConfirmtoRefreshList,
                                                 results[0].errorMessage,
                                                 function(btn, text) {
                                                    if (btn=='yes') {
                                                       grid.getView().getSelectionModel().deselectAll();
                                                       reloadAllStore();
                                                    }
                                                 grid.setLoading(false);
                                              });
                                           }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    },function (errors) {
                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                        grid.setLoading(false);
                                    });

                                }
                        });


                    }else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);

                }
            };
        },
        select_by_me :function(){
            return {
                xtype: 'checkbox',
                boxLabel: config.map_label.YearEnd_SelectedByMe,
                checked: true,
                handler: function(model,selected){
                    var grid = this.up('grid');
                    if(selected){
                        grid.store.filter("Selected_By__c", config.user_id);
                        grid.store.sort("CIS_ID__c", 'ASC');
                    }else {
                       grid.store.removeFilter("Selected_By__c");
                    }
                    grid.getView().getSelectionModel().deselectAll();
                }
            };
        }
    };
    config.panel_items = [
        createGridObject('<span style="color:red;">1.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, { //extra here

            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.YearEnd_SelectCheckedCustomer,
                    handler: function(){
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record){
                            return yearEndCheckbox(record.data);
                        });
                        if(final_selections.length > 0){
                            Ext.MessageBox.confirm(
                                config.map_label.YearEnd_PleaseConfirm,
                                config.map_label.YearEnd_AreYouConfirmtoSelect,
                                function(btn, text) {
                                    if (btn=='yes') {
                                        var savingObj = sendRequest('saveYearEnd',{
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
                                                     config.map_label.YearEnd_PleaseConfirmtoRefreshList,
                                                     results[0].errorMessage,
                                                     function(btn, text) {
                                                        if (btn=='yes') {
                                                           grid.getView().getSelectionModel().deselectAll();
                                                           reloadAllStore();
                                                        }
                                                     grid.setLoading(false);
                                                  });
                                               }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                            }
                                            grid.setLoading(false);
                                        },function (errors) {
                                            Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0].errorMessage);
                                            grid.setLoading(false);
                                        });
                                    }
                                });
                        }else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection,config.map_label.YearEnd_NoYearendhavebeenselected);
                    }
                }, {
                    xtype: 'tbspacer'
                }, {
                    text: config.map_label.YearEnd_ReferOutCheckedCustomer,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            reasonCombobox.clearValue();
                            provinceCombobox.clearValue();
                            aumpurCombobox.clearValue();
                            tumbonCombobox.clearValue();
                            segmentCombobox.clearValue();
                            referOutTeamText.setValue('');

                            reasonCombobox.clearInvalid();
                            provinceCombobox.clearInvalid();
                            aumpurCombobox.clearInvalid();
                            tumbonCombobox.clearInvalid();
                            segmentCombobox.clearInvalid();
                            referOutTeamText.clearInvalid();

                            provinceCombobox.hide();
                            aumpurCombobox.hide();
                            tumbonCombobox.hide();
                            referOutTeamText.hide();
                            segmentCombobox.hide();
                            referout_popup.show();
                        } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                    }
                }]
            },
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    xtype: 'checkbox',
                    name: 'previous_me',
                    boxLabel: config.map_label.YearEnd_Previouslyownedbyme,
                    checked: true,
                    handler: function(model,selected){
                        var grid = this.up('grid');
                        if(selected && config.user_empid && config.user_empid!=''){
                            grid.store.filter("RM_Employee_ID__c", '#'+config.user_empid);
                        }else {
                           grid.store.removeFilter("RM_Employee_ID__c");
                        }
                        grid.getView().getSelectionModel().deselectAll();
                    }
                }]
            }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndStore.sync();
                    yearEndStore.reload();
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_SelectedList, 'yearEndSelSelectedGrid', yearEndSelSelectedStore, yearSelColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.remove_selection()]
                },{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{xtype:'tbspacer'},usable_element.select_by_me()]
                }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndSelSelectedStore.sync();
                    yearEndSelSelectedStore.reload();
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndSelCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('<span style="color:red;">3.</span> '+config.map_label.YearEnd_ReferOutList, 'yearEndRefOutGrid', yearEndRefOutStore, yearSelRefOutColumn,{
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.remove_selection()]
                },{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{xtype:'tbspacer'},usable_element.select_by_me()]
                }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndRefOutStore.sync();
                    yearEndRefOutStore.reload();
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndSelCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject(config.map_label.YearEnd_ConfirmList, 'yearEndSelConfirmGrid', yearEndSelConfirmStore, yearSelConfirmColumn, {
            listeners:{
                'afterrender': function(grid) {
                    yearEndSelConfirmStore.sync();
                    yearEndSelConfirmStore.reload();
                }
            }
        })
    ];
    config.container_items = [referout_popup];
};
