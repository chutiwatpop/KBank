function init(config) {
    var selectedCountColumn = mappingColumn(config.yearEndSelForMap,["RM_Name__c","Team__c","TM_Name__c","Selected_By_Name__c","Selected_By_Team__c"]);

    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Additional_or_Refer_out__c","Refer_Out_By_Team__c","Refer_Out_Reason_fr_other__c","Refer_To_Team__c","Refer_Sub_District__c","Refer_District__c","Refer_Province__c"]);

    var yearSelMoreOneColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Additional_or_Refer_out__c","Refer_Out_By_Team__c","Refer_Out_Reason_fr_other__c","Refer_To_Team__c","Refer_Sub_District__c","Refer_District__c","Refer_Province__c"]);

    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Additional_or_Refer_out__c","Refer_Out_By_Team__c","Refer_Out_Reason_fr_other__c","Refer_To_Team__c","Refer_Sub_District__c","Refer_District__c","Refer_Province__c"]);

    var yearSelConfirmColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Final_Port_Pool__c","Final_Assigned_RM__c","Final_Service_RM__c","Final_Team__c","Final_Refer_Out__c","Final_Refer_Out_Reason__c","Final_Refer_Out_Reason_Detail__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_Service_RM_Name_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_2M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Additional_or_Refer_out__c","Refer_Out_By_Team__c","Refer_Out_Reason_fr_other__c","Refer_To_Team__c","Refer_Sub_District__c","Refer_District__c","Refer_Province__c"]);

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
    createModel('selectedCount', 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldselcountlist.join(',')
        }
    );
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        autoLoad:false,
        sorters: [{
            property: 'Selected_Count__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelMoreOneStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_RM__c',
            value: 'null'
         },{
            property: 'Selected_Count__c',
            value: '@'
         }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndRefOutStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_RM__c',
            value: 'null'
         },{
            property: 'Selected_Count__c',
            value: '1'
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
            property: 'Year_End_Assignment__r.Final_Assigned_RM__c',
            value: 'null'
         },{
            property: 'Selected_Count__c',
            value: '1'
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
        autoLoad:false,
        filters: [{
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

    var selectedCountStore = createStoreModel('selectedCount', 200, {
        autoLoad: false
    });

    var yearEndCheckbox = function(record) {
        return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c == null || typeof record.Final_Assigned_RM__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined") && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined") && record.Selected_Count__c==0);
    };
    var yearEndSelCheckbox = function(record) {
        return record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c == null || typeof record.Final_Assigned_RM__c === "undefined");
    };
    var yearEndSelConfirmCheckbox = function(record) {
        return record.Year_End_Assignment__r.Status__c=='New' && record.Final_Assigned_RM__c && record.Final_Assigned_RM__c != null && typeof record.Final_Assigned_RM__c !== "undefined";
    };

    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByAH,{extra:'All',isAH:true,selfInclude:false},true);
    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByAH,{scope:config.user_rc_code,isAH:true,selfInclude:false},true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM,{scope:config.user_rc_code,isAH:true},true);
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Reason__c'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Segment__c'},true);

    var selectByTeamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},true);

    var selectByTeamPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{},true);

    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Province'},true);
    var aumpurStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'District'},false);
    var tumbonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Sub District'},false);

    var selectByRefOutCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyName, 'selectedbyname', false, selectByStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 210,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    grid.store.filter("Selected_By__c", selected.get('pvalue'));
                } else grid.store.removeFilter("Selected_By__c");
            }
        }
    });
    var selectByMoreOneCombobox = selectByRefOutCombobox.cloneConfig();
    selectByMoreOneCombobox.disable();
    var selectBySelectedCombobox = selectByRefOutCombobox.cloneConfig();
    var selectByConfirmCombobox = selectByRefOutCombobox.cloneConfig();

    var selectByTeamPanelCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyTeam, 'selectedbyTeampanel', false, selectByTeamPanelStore, config.map_label.YearEnd_CustomerSelectedbyTeam, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                //var grid = this.up('grid');
                selectByPanelCombobox.clearValue();
                portPoolPanelCombobox.clearValue();
                servicePanelCombobox.clearValue();
                
                servicePanelCombobox.hide();
                portPoolPanelCombobox.disable();

                selectByPanelCombobox.clearInvalid();
                portPoolPanelCombobox.clearInvalid();
                servicePanelCombobox.clearInvalid();

                if (selected.data.pvalue == '') {
                    selectByPanelCombobox.clearValue();
                    selectByPanelCombobox.disable();
                    //grid.store.removeFilter("Selected_By__r.RC_Code__c");
                    delete selectByPanelStore.proxy.extraParams.subScope;
                }else {
                    selectByPanelCombobox.clearValue();
                    selectByPanelCombobox.enable();
                    //grid.store.filter("Selected_By__r.RC_Code__c", '#'+selected.data.pvalue);
                    selectByPanelStore.proxy.extraParams.subScope = selected.data.pvalue;
                }
                selectByPanelStore.load();
                //grid.getView().getSelectionModel().deselectAll();
            }
        }
    });

    var selectByPanelCombobox = createComboxbox(config.map_label.YearEnd_SelectRM_TM, 'selectedbyNamepanel', false, selectByPanelStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                servicePanelCombobox.hide();
                servicePanelCombobox.clearValue();
                portPoolPanelCombobox.enable();
                if(selected.get('pvalue') && config.lowerLevelSet.indexOf(selected.get('pvalue'))!=-1 && portPoolPanelCombobox.getValue()=='Pool'){
                   servicePanelStore.proxy.extraParams.extra = selected.get('pvalue');
                   servicePanelStore.load();
                   servicePanelCombobox.show();
                }
                if(selected.get('pvalue') && config.lowerLevelSet.indexOf(selected.get('pvalue'))==-1){
                    portPoolPanelCombobox.setValue('Port');
                    portPoolPanelCombobox.setReadOnly(true);
                }else portPoolPanelCombobox.setReadOnly(false);
            }
        }
    });
    
    selectByPanelCombobox.disable();
    
    var portPoolPanelCombobox = createComboxbox(config.map_label.YearEnd_SelectPort_Pool, 'portPoolpanel', false,
        new Ext.data.ArrayStore({
            id: 0,
            fields: [
                'property',
                'value'
            ],
            data: [
                [config.map_label.YearEnd_Port,'Port'],
                [config.map_label.YearEnd_Pool,'Pool']
            ]
        }), config.map_label.YearEnd_Port + ' ' + config.map_label.YearEnd_Port, 'pname', 'pvalue', false, false, {
            value: '',
            valueField: 'value',
            displayField: 'property',
            listeners: {
                select: function(combox, selected, index) {
                    var grid = this.up('grid');
                    servicePanelCombobox.hide();
                    servicePanelCombobox.clearValue();
                    if(selected.data && selected.data.value=='Pool' && config.lowerLevelSet.indexOf(selectByPanelCombobox.getValue())!=-1){
                        servicePanelStore.proxy.extraParams.extra = selectByPanelCombobox.getValue();
                        servicePanelStore.load();
                        servicePanelCombobox.show();
                    }
                }
            }
        });
    portPoolPanelCombobox.disable();
    var servicePanelCombobox = createComboxbox(config.map_label.YearEnd_SelectServicingRM, 'serviceRMpanel', true, servicePanelStore, config.map_label.YearEnd_Servicing_RM, 'pname', 'pvalue', false, true, {
        value: ''
    });

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
    var selectedcount_popup = createPanel({
        id: 'selectedcountPanel',
        title: config.map_label.YearEnd_SelectedUserinthisRecords,
        width: 550,
        items: [{
            xtype: 'grid',
            id: 'selectedcountgrid',
            loadMask: true,
            store: selectedCountStore,
            columns: selectedCountColumn,
            enableLocking: false,
            collapsed: false,
            collapsible: false,
            //width: 1,
            height: 200,
            width: '100%'
        }]
    });
    var selectconfirm_popup = createPanel({
        id: 'selectedPanel',
        title: config.map_label.YearEnd_SelectRM_TM,
        items: [selectByTeamPanelCombobox,selectByPanelCombobox, portPoolPanelCombobox, servicePanelCombobox],
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
                            var final_selections = _.filter(selections, function(record) {
                                return yearEndCheckbox(record.data);
                            });
                            if (final_selections.length > 0) {
                                grid.setLoading(true);
                                selectconfirm_popup.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveYearEnd', {
                                        contx: 'SELECTEDCONFIRM',
                                        selectName: form.getFieldValues(),
                                        yearlist: _.pluck(final_selections, 'id')
                                    })])
                                    .then(function(results) {

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
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                    });
                            } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);

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
                                          contx:'REFER_OUTCONFIRM',
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
        yearEndSelMoreOneStore.reload();
        yearEndRefOutStore.reload();
        yearEndSelSelectedStore.reload();
        yearEndSelConfirmStore.reload();
    };
    var usable_element = {
        customer_selected_by_team :function(flisteners){
            return {
                xtype: 'combobox',
                labelWidth: 155,
                fieldLabel: config.map_label.YearEnd_CustomerSelectedbyTeam,
                triggerAction: 'all',
                editable: false,
                mode: 'remote',
                //forceSelection: true,
                //loading: true,
                //value: '',
                emptyText: config.map_label.YearEnd_CustomerSelectedbyTeam,
                store: selectByTeamStore,
                valueField: 'pvalue',
                displayField: 'pname',
                listeners: flisteners
            };
        },
        confirm_final :function(){
            return {
                text: config.map_label.YearEnd_ConfirmFinalRM_TM_ReferOut,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var before_final_selections = _.filter(selections, function(record) {
                        return yearEndSelCheckbox(record.data);
                    });
                    if (before_final_selections.length > 0) {
                        Ext.MessageBox.confirm(
                            config.map_label.YearEnd_PleaseConfirm,
                            config.map_label.YearEnd_AreYouConfirmtoConfirmation,
                            function(btn, text) {
                                if (btn == 'yes') {
                                    grid.setLoading(true);
                                    Ext.Deferred.all([sendRequest('saveYearEnd', {
                                            contx: 'CONFIRM',
                                            yearlist: _.pluck(before_final_selections, 'id')
                                        })])
                                        .then(function(results) {
                                            if (results[0].success) {
                                                grid.getView().getSelectionModel().deselectAll();

                                                reloadAllStore();
                                            } else {
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
                                        }, function(errors) {
                                            Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                        });
                                }
                            });
                    } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                }
            };
        },
        remove_selection :function(){
            return {
                text: config.map_label.YearEnd_Remove_RM_Selection,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    if (selections.length > 0) {

                        Ext.MessageBox.confirm(
                            config.map_label.YearEnd_PleaseConfirm,
                            config.map_label.YearEnd_AreYouConfirmtoRemoveselected,
                            function(btn, text) {
                                if (btn == 'yes') {
                                    var savingObj = sendRequest('deleteYearEndSel', {
                                        yearlist: _.pluck(selections, 'id')
                                    });
                                    grid.setLoading(true);
                                    Ext.Deferred
                                        .all([savingObj])
                                        .then(function(results) {
                                            if (results[0].success) {
                                                grid.getView().getSelectionModel().deselectAll();

                                                reloadAllStore();

                                            } else {
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
                                        }, function(errors) {
                                            Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                        });

                                }
                            });


                    } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);

                }
            };
        },
        remove_confirmation :function(){
            return {
                text: config.map_label.YearEnd_RemoveConfirmation,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var final_selections = _.filter(selections, function(record) {
                        return yearEndSelConfirmCheckbox(record.data);
                    });
                    if (final_selections.length > 0) {

                        Ext.MessageBox.confirm(
                            config.map_label.YearEnd_PleaseConfirm,
                            config.map_label.YearEnd_AreYouConfirmtoRemoveConfirmation,
                            function(btn, text) {
                                if (btn == 'yes') {
                                    var savingObj = sendRequest('deleteYearEndSel', {
                                        deleteFinalAssign: true,
                                        yearlist: _.pluck(final_selections, 'id')
                                    });
                                    grid.setLoading(true);
                                    Ext.Deferred.all([savingObj])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            reloadAllStore();

                                        } else {
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                 config.map_label.YearEnd_PleaseConfirmtoRefreshList,
                                                 results[0].errorMessage,
                                                 function(btn, text) {
                                                    if (btn=='yes') {
                                                        grid.getView().getSelectionModel().deselectAll();

                                                        yreloadAllStore();
                                                    }
                                                 grid.setLoading(false);
                                              });
                                           }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                    });
                                }
                            });
                    } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                }
            };
        }
    };

    config.panel_items = [
        createGridObject('<span style="color:red;">1.</span> '+config.map_label.YearEnd_SelectedCountMoreThanOne, 'yearEndSelMoreOneGrid', yearEndSelMoreOneStore, yearSelMoreOneColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            load: function(a,b,c) {
                                console.log(a,b,c);
                            },
                            select: function(combox, selected, index) {
                                //console.log(combox, selected, index);
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By__c");
                                if (selected.data.pvalue == '') {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    delete selectByStore.proxy.extraParams.subScope;
                                }else {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.enable();
                                    //grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#'+selected.data.pvalue);
                                    selectByStore.proxy.extraParams.subScope = selected.data.pvalue;
                                }
                                selectByStore.load();
                                grid.getView().getSelectionModel().deselectAll();
                            }
                        }),
                        {
                            xtype: 'tbspacer'
                        },
                        selectByMoreOneCombobox
                    ]
                }],
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
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_SelectedList, 'yearEndSelSelectedGrid', yearEndSelSelectedStore, yearSelColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.confirm_final(), usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            load: function(a,b,c) {
                                console.log(a,b,c);
                            },
                            select: function(combox, selected, index) {
                                //console.log(combox, selected, index);
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By__c");
                                if (selected.data.pvalue == '') {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    delete selectByStore.proxy.extraParams.subScope;
                                }else {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.enable();
                                    //grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#'+selected.data.pvalue);
                                    selectByStore.proxy.extraParams.subScope = selected.data.pvalue;
                                }
                                selectByStore.load();
                                grid.getView().getSelectionModel().deselectAll();
                            }
                        }),
                        {
                            xtype: 'tbspacer'
                        },
                        selectBySelectedCombobox
                    ]
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
        createGridObject('<span style="color:red;">3.</span> '+config.map_label.YearEnd_ReferOutList, 'yearEndRefOutGrid', yearEndRefOutStore, yearSelColumn,{
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.confirm_final(), usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            load: function(a,b,c) {
                                console.log(a,b,c);
                            },
                            select: function(combox, selected, index) {
                                //console.log(combox, selected, index);
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By__c");
                                if (selected.data.pvalue == '') {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    delete selectByStore.proxy.extraParams.subScope;
                                }else {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.enable();
                                    //grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#'+selected.data.pvalue);
                                    selectByStore.proxy.extraParams.subScope = selected.data.pvalue;
                                }
                                selectByStore.load();
                                grid.getView().getSelectionModel().deselectAll();
                            }
                        }),
                        {
                            xtype: 'tbspacer'
                        },
                        selectByRefOutCombobox
                    ]
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
        createGridObject('<span style="color:red;">4.</span> '+config.map_label.YearEnd_ConfirmList, 'yearEndSelConfirmGrid', yearEndSelConfirmStore, yearSelConfirmColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [usable_element.remove_confirmation()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            load: function(a,b,c) {
                                console.log(a,b,c);
                            },
                            select: function(combox, selected, index) {
                                //console.log(combox, selected, index);
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By__c");
                                if (selected.data.pvalue == '') {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    delete selectByStore.proxy.extraParams.subScope;
                                }else {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.enable();
                                    //grid.store.removeFilter("Selected_By__r.RC_Code__c");
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#'+selected.data.pvalue);
                                    selectByStore.proxy.extraParams.subScope = selected.data.pvalue;
                                }
                                selectByStore.load();
                                grid.getView().getSelectionModel().deselectAll();
                            }
                        }),
                        {
                            xtype: 'tbspacer'
                        },
                        selectByConfirmCombobox
                    ]
                }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndSelConfirmStore.sync();
                    yearEndSelConfirmStore.reload();
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndSelConfirmCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('<span style="color:red;">5.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, { //extra here

            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.YearEnd_Select_Confirm,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();

                        var before_final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        var final_selections = _.filter(before_final_selections, function(record) {
                            return record.data.Selected_Count__c == 0;
                        });
                        if (final_selections.length > 0) {
                            selectByTeamPanelCombobox.clearValue();
                            selectByPanelCombobox.clearValue();
                            portPoolPanelCombobox.clearValue();
                            servicePanelCombobox.clearValue();
                            
                            selectByTeamPanelCombobox.clearInvalid();
                            selectByPanelCombobox.clearInvalid();
                            portPoolPanelCombobox.clearInvalid();
                            servicePanelCombobox.clearInvalid();

                            servicePanelCombobox.hide();
                            portPoolPanelCombobox.disable();
                            selectconfirm_popup.show();
                        } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                    }
                }, {
                    xtype: 'tbspacer'
                }, {
                    text: config.map_label.YearEnd_ReferOut_Confirm,
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
        {
            xtype : 'panel',
            title: '<span style="color:red;">6.</span> '+config.map_label.YearEnd_Submitted,
            height: 500,
            layout: {
                type: 'vbox',
                align: 'center',
                pack: 'center',

            },
            //frame : true,
            items: [
            {
                xtype: 'tbspacer'
            },
            Ext.create('Ext.Component', {
                html: config.map_label.YearEnd_Submit_All_Selection,
                padding: 20,
                componentCls: 'biggertext'
            })
            ,{
                xtype: 'button',
                scale: 'large',
                text: config.map_label.YearEnd_SubmittedAllSelection,
                handler: function() {
                    Ext.MessageBox.confirm(
                            config.map_label.YearEnd_PleaseConfirm,
                            '<span style="color:red;">Warning!</span> '+config.map_label.SubmittedAlert+'<br /><br />'+config.map_label.YearEnd_Areyousuretoconfirm,
                        function(btn, text) {
                            if (btn == 'yes') {
                                Ext.Deferred
                                    .all([sendRequest('saveYearEnd', {
                                        contx: 'SUBMITTED'
                                    })])
                                    .then(function(results) {
                                        if (results[0].success) {
                                            reloadAllStore();
                                        } else {
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                 config.map_label.YearEnd_PleaseConfirmtoRefreshList,
                                                 results[0].errorMessage,
                                                 function(btn, text) {
                                                    if (btn=='yes') {

                                                       reloadAllStore();
                                                    }
                                              });
                                           }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                        }
                                    }, function(errors) {
                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                    });
                            }
                        });
                    }
                }
            ]
        }

    ];
    config.container_items = [referout_popup, selectconfirm_popup,selectedcount_popup];
};