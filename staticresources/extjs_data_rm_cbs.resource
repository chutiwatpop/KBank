function init(config) {
    
    fields_base["Sales_Size__c"] = {
        "dataIndex": "Sales_Size__c",
        "align": "right",
        "format": "0,000",
        "sortable":true,
        "header": 'Sales Size',
        "xtype": "numbercolumn"
    };

    var selectionModelColumn = [
        {
            "name": "CreatedBy.Name",
            "mapping": 'CreatedBy.Name'
        }
    ];
    //var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Segment_Original__c","Refer_Out_Selection__c","Refer_Out_Team__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Refer_Province__c"]);
    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Segment_Original__c","RM_TM_Name__c","TL_Name__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Total_Income__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Refer_Out_Selection__c"]);
    
    //var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID__c","Customer_Name__c","Segment_Original__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c"]);
    
    var yearSelRefOutColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Segment_Original__c","RM_TM_Name__c","TL_Name__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Total_Income__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Created_Name","Selected_By_Name__c","Refer_Out_Team__c","Refer_Out_Reason__c"]);
    var yearStrucColumn = mappingColumn(config.customerOwnerForMap,["CIS_ID__c","Customer_Name__c","Type__c","Approval_Status__c","Segment_Original__c","Credit_Status__c","RM_Name__c","Team__c","TM_Name__c","Requester_Name_Text__c","Requester_Team__c","Requester_AH_Name__c","Approver_Name__c"]);
    var customerColumns = [
        {
            "xtype": 'widgetcolumn',
            "locked": true,
            "width": 130,
            "widget": {
                "height": 18,
                "padding": 0,
                "xtype": 'button',
                "text": 'Request Ownership',
                "handler": function(button,wid){
                    request_id = button.getWidgetRecord().getId();
                    selectByPanelRequestCombobox.clearValue();
                    portPoolPanelRequestCombobox.clearValue();
                    servicePanelRequestCombobox.clearValue();

                    selectByPanelRequestCombobox.clearInvalid();
                    portPoolPanelRequestCombobox.clearInvalid();
                    servicePanelRequestCombobox.clearInvalid();

                    servicePanelRequestCombobox.hide();

                    request_popup.show();
                }
            },
            sortable: false
        },{
            "dataIndex": "cis_id",
            "text": config.customerOwnerForMap["CIS_ID__c"].label,
            "align": "right",
            "width": 70,
            "locked": true,
            sortable: false
        }, {
            "dataIndex": "name",
            "text": config.customerOwnerForMap["Customer_Name__c"].label,
            "width": 150,
            "locked": true,
            sortable: false
        },  {
            "dataIndex": "segment",
            "text": config.customerOwnerForMap["Segment_Original__c"].label,
            "width": 150,
            sortable: false
        },  {
            "dataIndex": "flag_port",
            "text": config.customerOwnerForMap["Assigned_Port_Pool__c"].label,
            "width": 150,
            sortable: false
        }, {
            "dataIndex": "credit_status",
            "text": config.customerOwnerForMap["Credit_Status__c"].label,
            "width": 150,
            sortable: false
        }, {
            "dataIndex": "existing_rm_name",
            "text": config.customerOwnerForMap["RM_Name__c"].label,
            "width": 150,
            sortable: false
        }, {
            "dataIndex": "team",
            "text": config.customerOwnerForMap["Team__c"].label,
            "width": 150,
            sortable: false
        }, {
            "dataIndex": "tm_name",
            "text": config.customerOwnerForMap["TM_Name__c"].label,
            "width": 150,
            sortable: false
        }
    ];

    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");
    var customerOwnerModelName = Ext.String.capitalize("Year_End_Ownership_Request__c");

    // Create Model
    createModel(yearEndModelName, 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Assignment__c',
            fields: config.fieldlist.join(',')
        }
    );
    createModel(yearEndSelModelName, 'records', 'Id',
        selectionModelColumn, RemoterExtensions.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldsellist.join(',')
        }
    );
    createModel(customerOwnerModelName, 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Ownership_Request__c',
            fields: config.fieldrequestlist.join(',')
        }
    );

    // Create Store Model
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        filters: [{ 
            property: 'AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
        },{
            property: 'RM_Employee_ID__c',
            value: '#'+config.user_empid
        }],
        sorters:[{
            property: 'CIS_ID_Unique__c',
            direction: 'ASC'
        }]
    });
    var yearEndRefOutStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Year_End_Assignment__r.RM_Employee_ID__c',
            value: '#'+config.user_empid
        },{
            property: 'Refer_Out__c',
            value: 'true'
        },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    
    Ext.define('customerModel', {
        extend: 'Ext.data.Model',
        fields: [{
            name: 'year_id',
            type: 'string',
            sortable: false
        },{
            name: 'customer_id',
            type: 'string',
            sortable: false
        }, {
            name: 'cis_id',
            type: 'string',
            sortable: false
        }, {
            name: 'name',
            type: 'string',
            sortable: false
        }, {
            name: 'segment',
            type: 'string',
            sortable: false
        }, {
            name: 'high_value',
            type: 'string',
            sortable: false
        }, {
            name: 'flag_port',
            type: 'string',
            sortable: false
        }, {
            name: 'credit_status',
            type: 'string',
            sortable: false
        }, {
            name: 'existing_rm_name',
            type: 'string',
            sortable: false
        }, {
            name: 'team',
            type: 'string',
            sortable: false
        }, {
            name: 'tm_name',
            type: 'string',
            sortable: false
        }, {
            name: 'ah_name',
            type: 'string',
            sortable: false
        }, {
            name: 'nh_name',
            type: 'string',
            sortable: false
        }, {
            name: 'approval_status',
            type: 'string',
            sortable: false
        }],
        idProperty: 'year_id'
    });

    //Picklist Store
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryReason,{scope:'CBS'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Segment'},true);
    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Province'},false);
    var teamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Team'},false);
    var percentShareStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Percent_Shareholder__c'},true);
    var languageStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Language__c'},true);
    var segmentProsStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'CBS'},true);
    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM, {
        scope: config.user_rc_code,
        selfInclude:true
    }, true);

    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedBy, {
        scope: config.user_rc_code
    }, true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM, {
        scope: config.user_rc_code
    }, true);
    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200,
        sorters: []
    });
    var customerOwnerStore = createStoreModel(customerOwnerModelName, 200, {
        autoLoad: false,
        filters: [{
            property: 'Requester__c',
            value: '#'+config.user_id
        },{
            property: 'Type__c',
            value: 'Request Ownership'
        }],
        sorters: [{
            property: 'Approval_Status__c',
            direction: 'ASC'
        },{
            property: 'CIS_ID__c',
            direction: 'DESC'
        }]
    });

    var cisText = new Ext.form.TextField({
        fieldLabel: config.yearEndForMap["CIS_ID_Unique__c"].label,//,
        name: 'search_box',
        
    });


    //fieldLabel, fieldName, hidden, store, emptyText, displayField, valueField, editable, allowBlank, addition
    var reasonCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Reason, 'referoutReason', false, reasonStore, config.map_label.YearEnd_Select_a_Reason, 'pname', 'pvalue', false, false);
    //var reasonCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Reason, 'referoutReason', false, reasonStore, config.map_label.YearEnd_Select_a_Reason, 'pname', 'pvalue', false, false);
    var languageCombobox = createComboxbox(config.map_label.YearEnd_Refer_Language, 'referoutLanguage', false, languageStore, config.map_label.YearEnd_Select_a_Reason, 'pname', 'pvalue', false, false);
    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.yearEndSelForMap['Segment_Proposed__c'].label, 'pname', 'pvalue', false, false);

    var provinceCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Province, 'referoutProvince', true, provinceStore, config.map_label.YearEnd_SelectaProvince, 'pname', 'pvalue', false, true,{
        listConfig: {
            tpl: ['<li class="my-boundlist-item-menu">--Clear Value--</li>',
                  '<tpl for=".">',
                  '<li class="x-boundlist-item">{pname}</li>',
                  '</tpl>'],
            listeners: {
                el: {
                    delegate: '.my-boundlist-item-menu',
                    click: function() {
                        provinceCombobox.clearValue();
                        provinceCombobox.clearInvalid();
                        provinceCombobox.collapse();
                        delete teamStore.proxy.extraParams.province;
                        teamStore.load();
                    }
                }
            }
        }
    });
    var teamCombobox = createComboxbox(config.map_label.YearEnd_ReferOutTeam+'', 'referoutTeam', true, teamStore, config.map_label.YearEnd_ReferOutTeam, 'pname', 'pvalue', false, false,{
        matchFieldWidth: false,
        listConfig: {
            listeners: {
                beforeshow: function(picker) {
                    picker.minWidth = picker.up('combobox').getSize().width;
                }
            }
        }
    });

    var cisRelatedText = new Ext.form.TextField({
        fieldLabel: 'Related CIS',//,
        name: 'referoutrelateCIS',
        labelStyle: 'width:120px'
    });

    cisRelatedText.on('blur', function(cmb, record, index) {
       delete teamStore.proxy.extraParams.reason;
       delete teamStore.proxy.extraParams.cisRelated;
       delete teamStore.proxy.extraParams.province;

        if (record != '' && reasonCombobox.value != '') {
            teamStore.proxy.extraParams.cisRelated = cisRelatedText.value;
            teamStore.proxy.extraParams.reason = reasonCombobox.value;
            teamStore.reload();
        }
       if(teamStore.getCount() > 0){
            teamCombobox.show();
       }
    });

    reasonCombobox.on('select', function(cmb, record, index) {
        delete teamStore.proxy.extraParams.cisRelated;
        delete teamStore.proxy.extraParams.reason;
        
        languageCombobox.hide();
        segmentProsCombobox.hide();
        provinceCombobox.hide();
        teamCombobox.hide();
        cisRelatedText.setValue('');
        cisRelatedText.hide();

        segmentProsCombobox.clearValue();
        languageCombobox.clearValue();
        provinceCombobox.clearValue();
        teamCombobox.clearValue();
        

        languageCombobox.labelEl.update(config.map_label.YearEnd_Refer_Language+':');
        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');

        languageCombobox.allowBlank = true;
        provinceCombobox.allowBlank = true;
        teamCombobox.allowBlank = true;
        cisRelatedText.allowBlank=true;
        segmentProsCombobox.allowBlank = true;


        if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Segment') {
            teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            teamCombobox.allowBlank = false;
            delete provinceStore.proxy.extraParams.reason;
            delete provinceStore.proxy.extraParams.cisRelated;
            provinceStore.proxy.extraParams.reason = reasonCombobox.value;
            teamStore.proxy.extraParams.reason = reasonCombobox.value;
            provinceStore.reload();
            teamStore.reload();
            segmentProsCombobox.show();
            languageCombobox.show();
            
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Company Related') {
            teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            teamCombobox.allowBlank = false;

            delete teamStore.proxy.extraParams.reason;
            delete teamStore.proxy.extraParams.cisRelated;
            delete teamStore.proxy.extraParams.province;

            teamStore.proxy.extraParams.reason = reasonCombobox.value;
            teamStore.proxy.extraParams.cisRelated = cisRelatedText.value;

            teamStore.reload();
            cisRelatedText.show();
            teamCombobox.show();
        }
        provinceCombobox.clearValue();
        teamCombobox.clearValue();
    });

    segmentProsCombobox.on('select', function(cmb, record, index) {

        provinceCombobox.hide();
        teamCombobox.hide();
        cisRelatedText.hide();

        provinceCombobox.clearValue();
        teamCombobox.clearValue();
        cisRelatedText.setValue('');

        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');

        languageCombobox.allowBlank = true;
        provinceCombobox.allowBlank = true;
        teamCombobox.allowBlank = true;
        cisRelatedText.allowBlank=true;



        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
        provinceCombobox.allowBlank = false;
        teamCombobox.allowBlank = false;

        delete provinceStore.proxy.extraParams.reason;
        delete provinceStore.proxy.extraParams.segment;

       // provinceStore.proxy.extraParams.cisRelated = record;
        provinceStore.proxy.extraParams.reason = reasonCombobox.value;
        provinceStore.proxy.extraParams.segment = segmentProsCombobox.value;

        provinceStore.reload();
        provinceCombobox.show();

        provinceCombobox.clearValue();
        teamCombobox.clearValue();
    });
    provinceCombobox.on('select', function(cmb, record, index) {
        
        teamCombobox.clearValue();
        teamCombobox.clearInvalid();
        
        delete teamStore.proxy.extraParams.province;
        delete teamStore.proxy.extraParams.segment;
        teamCombobox.allowBlank = true;

        if (record.get('pvalue') && record.get('pvalue') != '') {
            teamStore.proxy.extraParams.province = record.get('pvalue');
            teamStore.proxy.extraParams.segment = segmentProsCombobox.value;
            teamStore.reload();
        }
        teamCombobox.show();
    });

    var servicePanelRequestCombobox = createComboxbox(config.map_label.YearEnd_SelectServicingRM, 'serviceRMRequestpanel', true, servicePanelStore, config.map_label.YearEnd_Servicing_RM, 'pname', 'pvalue', false, true, {
        value: '',
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {

                }
            }
        }
    });

    var selectByPanelRequestCombobox = createComboxbox(config.map_label.YearEnd_SelectRM_TM, 'selectedbyNameRequestpanel', false, selectByPanelStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                servicePanelRequestCombobox.hide();
                servicePanelRequestCombobox.clearValue();
                if (selected.get('pvalue') && selected.get('pvalue') == config.user_id && portPoolPanelRequestCombobox.getValue() == 'Pool') {
                    servicePanelRequestCombobox.show();
                }
                if(selected.get('pvalue') != config.user_id){
                    portPoolPanelRequestCombobox.setValue('Port');
                    portPoolPanelRequestCombobox.setReadOnly(true);
                }else portPoolPanelRequestCombobox.setReadOnly(false);
            }
        }
    });

    var portPoolPanelRequestCombobox = createComboxbox(config.map_label.YearEnd_SelectPort_Pool, 'portPoolRequestpanel', false,
        new Ext.data.ArrayStore({
            id: 0,
            fields: [
                'property',
                'value'
            ],
            data: [
                [config.map_label.YearEnd_Port,'Port']
            ]
        }), config.map_label.YearEnd_Port + ' ' + config.map_label.YearEnd_Pool, 'pname', 'pvalue', false, false, {
            value: '',
            valueField: 'value',
            displayField: 'property',
            listeners: {
                select: function(combox, selected, index) {
                    var grid = this.up('grid');
                    servicePanelRequestCombobox.hide();
                    servicePanelRequestCombobox.clearValue();
                    if (selected.data && selected.data.value == 'Pool' && selectByPanelRequestCombobox.getValue() == config.user_id) {
                        servicePanelRequestCombobox.show();
                    }
                }
            }
        });

    var yearEndCheckbox = function(record) {
    	//console.log('record.Refer_Out_Selection__c '+record.Year_End_Assignment_Selections__r[0].Refer_Out__c);
       var valid = false;;
       if(record.Year_End_Assignment_Selections__r != null){
	       	if(!config.submit_flag && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c==null || typeof record.Final_Assigned_Next_Year__c === "undefined" || record.Final_Assigned_Next_Year__c=='') && record.Year_End_Assignment_Selections__r[0].Refer_Out__c != null && record.Year_End_Assignment_Selections__r[0].Refer_Out__c != true){
	             valid = true;
	        }else{
	             valid = false;
	        }
    	}else{
    		valid = true;
    	}
        return valid;
    };
    
    var yearEndSelCheckbox = function(record) {
        return !config.submit_flag;
    };



    var ownershipCheckbox = function(record) {
        return !config.submit_flag && record.Requester__r.Id==config.user_id && (record.Approval_Status__c=='Open' || record.Approval_Status__c=='Approval In Progress');
    };

    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: config.map_label.YearEnd_Refer_Out,
        items: [reasonCombobox,languageCombobox,segmentProsCombobox,cisRelatedText,provinceCombobox,teamCombobox],
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
                            var before_final_selections = _.filter(selections, function(record){
                                return yearEndCheckbox(record.data);
                            });
                            var blacklist_records = [];
                            var final_selections = [];
                            
                            final_selections = before_final_selections;
                            if(final_selections.length){
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
                                },function (errors) {console.log(errors);
                                    if(errors[0].errorMessage)
                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0].errorMessage);
                                    else Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors);
                                });
                            }else {
                                if(!blacklist_records.length)
                                    Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection,config.map_label.YearEnd_NoYearendhavebeenselected);
                            }

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
	var request_popup = createPanel({
        id: 'requestPanel',
        title: config.map_label.YearEnd_RequestInformation,
        items: [selectByPanelRequestCombobox, portPoolPanelRequestCombobox, servicePanelRequestCombobox],
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
                            request_popup.hide();
                            Ext.Deferred
                                .all([requestApex('createRequestYearEnd',{
                                        selectNameString: JSON.stringify(form.getFieldValues()),
                                        yearlist: [request_id]
                                    })])
                                .then(function(results) {
                                   if (results[0].success=="true") {
                                        //customerOwnerStore.sync();
                                        customerStore.reload();
                                        customerOwnerStore.reload();
                                    
                                        Ext.Msg.alert('', 'Create Request Done');
                                    } else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                }, function(errors) {
                                    Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                });

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
        customerOwnerStore.reload();
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
        }
    }; 

    //tab Panel
    config.panel_items = [
        createGridObject('<span style="color:red;">1.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                hidden:config.submit_flag,
                items: [{
                    text: config.map_label.YearEnd_ReferOutCheckedCustomer,
                    handler: function() {
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            reasonCombobox.clearValue();
                            languageCombobox.clearValue();
                            provinceCombobox.clearValue();
                            teamCombobox.clearValue();
                            segmentProsCombobox.clearValue();
                            cisRelatedText.setValue('');

                            reasonCombobox.clearInvalid();
                            segmentProsCombobox.clearInvalid();
                            languageCombobox.clearInvalid();
                            provinceCombobox.clearInvalid();
                            teamCombobox.clearInvalid();

                            segmentProsCombobox.hide();
                            cisRelatedText.hide();
                            languageCombobox.hide();
                            provinceCombobox.hide();
                            teamCombobox.hide();
                            referout_popup.show();
                        } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                    }
                }]
            }],
            listeners:{
                'headerclick': function(g, index, ev) {
                    //console.log(index.dataIndex);
                    if(index.dataIndex === 'Year_End_Assignment_Selections__r'){
                        return false;
                    }
                }
            },
            selModel: {
                selType: 'checkboxmodel',
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
            }
        }),
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_ReferOutList, 'yearEndRefOutGrid', yearEndRefOutStore, yearSelRefOutColumn,{
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    hidden:config.submit_flag,
                    items: [usable_element.remove_selection()]
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
        {
            title: '<span style="color:red;">3.</span> '+config.map_label.YearEnd_OwnershipRequest,
            id: 'ownerrequest-tab',
            xtype: 'container',
            width: 1, //dummy
            minHeight: 500,
            height: 500,
            autoScroll: true,
            layout: {
                type: 'vbox',
                align: 'center'
            },
            items: [
                createGridObject(config.map_label.YearEnd_SearchResult, 'customerGrid', customerStore, customerColumns, {
                    width: '100%',
                    height: 150,
                    dockedItems: [{
                        xtype: 'tbspacer'
                    }, {
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [
                            cisText, {
                                xtype: 'tbspacer'
                            }, {
                                id: 'search_customer',
                                text: config.map_label.YearEnd_Search,
                                handler: function() {
                                    if (cisText.value != "") {
                                        Ext.Deferred
                                            .all([requestApex('getCustomers',{cis:cisText.value})])
                                            .then(function(results) {
                                            	console.log(results);
                                                customerStore.loadData([], false);
                                                if (results[0].success!="false") {
                                                    customerStore.loadData([results[0].records]);
                                                }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                                            }, function(errors) {
                                                Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                                            });
                                    }
                                }
                            }
                        ]
                    }]
                }, true),
                createGridObject(config.map_label.YearEnd_ListofRequest, 'customerRequestGrid', customerOwnerStore, yearStrucColumn, {
                    width: '100%',
                    height: 350,
                    dockedItems: [{
                            xtype: 'tbspacer'
                        }, {
                            xtype: 'toolbar',
                            dock: 'bottom',
                            hidden:config.submit_flag,
                            items: [
                                {
                                    xtype: 'button',
                                    text: config.map_label.YearEnd_Recall,
                                    handler: function() {
                                        var grid = this.up('grid');
                                        var selections = grid.getView().getSelectionModel().getSelection();
                                        var final_selections = _.filter(selections, function(record) {
                                            return ownershipCheckbox(record.data);
                                        });
                                        console.log(final_selections.length);
                                        if (final_selections.length > 0) {
                                            Ext.MessageBox.confirm(
                                                config.map_label.YearEnd_ConfirmRecall,
                                                config.map_label.YearEnd_AreYouSureToRecall,
                                                function(btn, text) {
                                                    if (btn == 'yes') {
                                                        var savingObj = sendRequest('changeStatusYearStruc', {
                                                            yearlist: _.pluck(final_selections, 'id'),
                                                            approveStatus: 'Recalled'
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
                                                                      Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
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
                                },
                            ]
                        }
                    ],
                    selModel: new Ext.selection.CheckboxModel({
                        checkOnly: true,
                        mode: 'SIMPLE',
                        renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                            if (ownershipCheckbox(record.data)) {
                                meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                                return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                            } else {
                                return '';
                            }
                        }
                    }),
                    listeners:{
                        'afterrender': function(grid) {
                            customerOwnerStore.sync();
                            customerOwnerStore.reload();
                        }
                    }
                })
            ]
        },
        {
            xtype : 'panel',
            title: '<span style="color:red;">4.</span> '+config.map_label.YearEnd_Submitted,
            height: 500,
            //hidden:config.submit_flag,
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
                html: (!config.submit_flag)?config.map_label.YearEnd_Submit_All_Selection:config.map_label.YearEnd_AlreadySubmitted,
                padding: 20,
                componentCls: 'biggertext'
            })
            ,{
                xtype: 'button',
                scale: 'large',
                disabled: config.submit_flag,
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
                                            //reloadAllStore();
                                            Ext.Msg.alert('Success',config.map_label.YearEnd_SuccessSubmit,function(){
                                                document.location.reload();
                                            });
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
    config.container_items = [referout_popup];
};

