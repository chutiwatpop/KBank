function init(config) {
    // fields_base["Selected_Count__c"] = {
    //     "dataIndex": "Selected_Count__c",
    //     "align": "right",
    //     "format": "0,000",
    //     "sortable":false,
    //     "xtype": "numbercolumn",
    //     "listeners":{
    //         "click": function(gridtable,gridtable_html,index,col,record){
    //             var record_data = record.record.data;
    //             if(record_data.Selected_Count__c > 0){
    //                 //console.log(record_data);
    //                 var yearEndRecord = (record_data.Year_End_Assignment__c)?record_data.Year_End_Assignment__c:record_data.Id;
    //                 selectedCountStore.filter("Year_End_Assignment__c", yearEndRecord);
    //                 selectedcount_popup.show();
    //             }
    //         }
    //     },
    //     "locked": true
    // };
    fields_base["Selected_Count__c"] = {
        "dataIndex": "Selected_Count__c",
        "align": "right",
        "format": "0,000",
        "sortable":false,
        "xtype": "numbercolumn",
        // renderer: function (val, metadata, record) {
        //     metadata.style = 'cursor: pointer;'; 
        //     return val;
        // },
        "listeners":{
            // "click": function(gridtable,gridtable_html,index,col,record){
            //     var record_data = record.record.data;
            //     if(record_data.Selected_Count__c > 1){
            //         console.log(record_data.Year_End_Assignment__c);
            //         selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
            //         selectedCountStore.reload();
            //         //selectedcount_popup.show();
            //     }
            // }
        },
        "locked": true
    };


    fields_base["Sales_Size__c"] = {
        "dataIndex": "Sales_Size__c",
        "align": "right",
        "format": "0,000",
        "sortable":true,
        "header": 'Sales Size',
        "xtype": "numbercolumn"
    };
    
    var customerRequestModelColumn = [
        {
            "name": "CreatedBy.Name",
            "mapping": 'CreatedBy.Name'
        }
    ];

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
                    var wrecord = button.getWidgetRecord();
                    //console.debug(wrecord.data);
                    request_id = wrecord.getId();
                    selectByPanelRequestCombobox.clearValue();
                    portPoolPanelRequestCombobox.clearValue();
                    servicePanelRequestCombobox.clearValue();

                    selectByPanelRequestCombobox.clearInvalid();
                    portPoolPanelRequestCombobox.clearInvalid();
                    servicePanelRequestCombobox.clearInvalid();

                    servicePanelRequestCombobox.hide();
                    //console.log(record);
                    request_popup.selection_data = wrecord.data;
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
        }, {
            "dataIndex": "selected_count",
            "align": "right",
            "text": config.yearEndForMap["Selected_Count__c"].label,
            "width": 150,
            "locked": true,
            sortable: false
        }, {
            "dataIndex": "segment",
            "text": config.customerOwnerForMap["Segment_Original__c"].label,
            "width": 150,
            sortable: false
        }, {
            "dataIndex": "high_value",
            "text": config.customerOwnerForMap["High_Value_Flag__c"].label,
            "width": 150,
            sortable: false
        }, {
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

    var yearStrucColumn = mappingColumn(config.customerOwnerForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Port_Pool__c","Credit_Status__c","RM_Name__c","Team__c","TM_Name__c","Type__c","Requester_Name_Text__c","Requester_Team__c","Assigned_Port_Pool__c","Service_RM_Name_Text__c","Refer_Out_Reason__c","Refer_Out_From_Name__c","Refer_Out_From_Team__c","Refer_Out_To_Name__c","Refer_Out_To_Team__c","Approver_Name__c","Approval_Status__c"]);

    var selectedCountColumn = mappingColumn(config.yearEndSelForMap,["RM_Name__c","Team__c","TM_Name__c","Created_Name","Selected_By_Name__c","Selected_By_Team__c"]);

    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Sales_Size__c"]);

    var yearSelMoreOneColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Selected_Port_Pool__c","Created_Name","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelConfirmColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Final_Port_Pool__c","Final_Team__c","Final_Refer_Out__c","Final_Refer_Out_Reason__c","Final_Refer_Out_Reason_Detail__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Created_Name","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);
    
    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");
    var customerOwnerModelName = Ext.String.capitalize("Year_End_Ownership_Request__c");
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
        idProperty: 'year_id',
    });

    createModel(yearEndModelName, 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Assignment__c',
            fields: config.fieldlist.join(',')
        }
    );
    createModel(yearEndSelModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
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
    createModel('selectedCount', 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldselcountlist.join(',')
        }
    );
    
    var customerOwnerStore = createStoreModel(customerOwnerModelName, 200, {
        autoLoad: false,
        filters: [{
            property: 'Requester__r.RC_Code__c',
            value: '#'+config.user_rc_code
        }],
        sorters: [{
            property: 'CIS_ID__c',
            direction: 'DESC'
        }]
    });
    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200,
        sorters: []
    });
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        autoLoad:false,
        filters: [{ // move to controller
            property: 'AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code,
            default: true
        }],
        sorters: [{
            property: 'Team__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelMoreOneStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [
        // {
        //     property: 'CreatedBy.RC_Code__c',
        //     default: true,
        //     value: '#' + config.user_rc_code
        // },
        {
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            default: true,
            value: 'null'
         },{
            property: 'Selected_Count__c',
            default: true,
            operator: '>',
            value: 1
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            default: true,
            value: '#'+config.user_ah_rc_code
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndRefOutStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            default: true,
            value: 'null'
         },{
            property: 'Selected_Count__c',
            default: true,
            value: '1'
         },{
            property: 'Refer_Out__c',
            default: true,
            value: 'true'
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            default: true,
            value: '#'+config.user_ah_rc_code
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelSelectedStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Selected_By_Next_Year__r.RC_Code__c',
            default: true,
            value: '#' + config.user_rc_code
        },{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            default: true,
            value: 'null'
         },{
            property: 'Selected_Count__c',
            default: true,
            value: '1'
         },{
            property: 'Refer_Out__c',
            default: true,
            value: 'false'
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            default: true,
            value: '#'+config.user_ah_rc_code
        },{
            property: 'Need_Approval__c',
            default: false,
            value: 'false'
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelConfirmStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Selected_By_Next_Year__r.RC_Code__c',
            default: true,
            value: '#' + config.user_rc_code
        },{
            property: 'Selected_Count__c',
            default: true,
            value: '1'
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            default: true,
            value: '#'+config.user_ah_rc_code
        },{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c !',
            value: 'null'
        },{
            property: 'Need_Approval__c',
            default: false,
            value: 'false'
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    //refer out panel
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryReason,{scope:'SME'},true);

    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Segment'},true);
    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Province'},false);
    var teamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Team'},false);
    var percentShareStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Percent_Shareholder__c'},true);
    var languageStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Language__c'},true);

    var segmentProsStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'SME'},true);

    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM, {
        scope: config.user_rc_code,
        selfInclude:true
    }, true);

    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedBy, {
        scope: config.user_rc_code
    }, true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryAHSelectedByOnlyRM, {
        scope: config.user_rc_code
    }, true);

    //Create Component
    var cisText = new Ext.form.TextField({
        fieldLabel: config.yearEndForMap["CIS_ID_Unique__c"].label,//,
        name: 'search_box'
    });
    var selectByPanelRequestCombobox = createComboxbox(config.map_label.YearEnd_SelectRM_TM, 'selectedbyNameRequestpanel', false, selectByPanelStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                
                console.log(request_popup.selection_data);
                servicePanelRequestCombobox.hide();
                servicePanelRequestCombobox.clearValue();
                if(request_popup.selection_data.segment =='CB' || request_popup.selection_data.segment == 'MB'){
                    portPoolPanelRequestCombobox.setValue('Port');
                    portPoolPanelRequestCombobox.setReadOnly(true);
                }else{
                    if (selected.get('pvalue') && selected.get('pvalue') == config.user_id && portPoolPanelRequestCombobox.getValue() == 'Pool') {
                        servicePanelRequestCombobox.show();
                    }
                    if(selected.get('pvalue') != config.user_id){
                        portPoolPanelRequestCombobox.setValue('Port');
                        portPoolPanelRequestCombobox.setReadOnly(true);
                    }else portPoolPanelRequestCombobox.setReadOnly(false);
                }
                
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
                ,[config.map_label.YearEnd_Pool,'Pool']
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

    var selectByMoreOneCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyName, 'selectedbyname', false, selectByStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 210,
        listeners: {
            select: function(combox, selected, index) {
                console.log(selected.get('pvalue'));
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    grid.store.filter("Createdby.Id", selected.get('pvalue'));
                } else grid.store.removeFilter("Createdby.Id");
            }
        }
    });
    var selectByRefOutCombobox = selectByMoreOneCombobox.cloneConfig();
    var selectBySelectedCombobox = selectByMoreOneCombobox.cloneConfig();
    var selectByConfirmCombobox = selectByMoreOneCombobox.cloneConfig();
    var selectByPanelCombobox = createComboxbox(config.map_label.YearEnd_SelectRM_TM, 'selectedbyNamepanel', false, selectByPanelStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                servicePanelCombobox.hide();
                servicePanelCombobox.clearValue();
                portPoolPanelCombobox.enable();
        
                if (selected.get('pvalue') && selected.get('pvalue') == config.user_id && portPoolPanelCombobox.getValue() == 'Pool') {
                    servicePanelCombobox.show();
                }
                if(selected.get('pvalue') != config.user_id){
                    portPoolPanelCombobox.setValue('Port');
                    portPoolPanelCombobox.setReadOnly(true);
                }else portPoolPanelCombobox.setReadOnly(false);
            }
        }
    });
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
        }), config.map_label.YearEnd_Port + ' ' + config.map_label.YearEnd_Pool, 'pname', 'pvalue', false, false, {
            value: '',
            valueField: 'value',
            displayField: 'property',
            listeners: {
                select: function(combox, selected, index) {
                    var grid = this.up('grid');
                    servicePanelCombobox.hide();
                    servicePanelCombobox.clearValue();
                    if (selected.data && selected.data.value == 'Pool' && selectByPanelCombobox.getValue() == config.user_id) {
                        servicePanelCombobox.show();
                    }
                }
            }
        });

    portPoolPanelCombobox.disable();

    var servicePanelCombobox = createComboxbox(config.map_label.YearEnd_SelectServicingRM, 'serviceRMpanel', true, servicePanelStore, config.map_label.YearEnd_Servicing_RM, 'pname', 'pvalue', false, true, {
        value: ''
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
        items: [selectByPanelCombobox,portPoolPanelCombobox, servicePanelCombobox], 
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
                                        contx: 'SELECTED',
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
    //fieldLabel, fieldName, hidden, store, emptyText, displayField, valueField, editable, allowBlank, addition
    var reasonCombobox = createComboxbox(config.map_label.YearEnd_Refer_Out_Reason, 'referoutReason', false, reasonStore, config.map_label.YearEnd_Select_a_Reason, 'pname', 'pvalue', false, false);
    var segmentCombobox = createComboxbox(config.map_label.YearEnd_ReferOutSegment+'', 'referoutSegment', true, segmentStore, config.map_label.YearEnd_Select_a_Segment, 'pname', 'pvalue', false, true,{
        listConfig: {
            tpl: ['<li class="my-boundlist-item-menu">--Clear Value--</li>',
                  '<tpl for=".">',
                  '<li class="x-boundlist-item">{pname}</li>',
                  '</tpl>'],
            listeners: {
                el: {
                    delegate: '.my-boundlist-item-menu',
                    click: function() {
                        segmentCombobox.clearValue();
                        segmentCombobox.clearInvalid();
                        segmentCombobox.collapse();
                        delete provinceStore.proxy.extraParams.segment;
                        delete teamStore.proxy.extraParams.segment;
                        provinceStore.load();
                        teamStore.load();
                    }
                }
            }
        }
    });
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
    var percentShareCombobox = createCustomComboxbox(config.map_label.YearEnd_Refer_PercentShare, 'referoutPercentShare', false, percentShareStore, '%Shareholder', 'pname', 'pvalue', false, false);
    var languageCombobox = createComboxbox(config.map_label.YearEnd_Refer_Language, 'referoutLanguage', false, languageStore, 'Language', 'pname', 'pvalue', false, false);

    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.yearEndSelForMap['Segment_Proposed__c'].label, 'pname', 'pvalue', false, false);

    var cisRelatedText = new Ext.form.TextField({
        fieldLabel: 'Related CIS',//,
        name: 'referoutrelateCIS',
        labelStyle: 'width:120px'
    });


    // Event Handler
    cisRelatedText.on('blur', function(cmb, record, index) {
        //console.log(record);
       delete teamStore.proxy.extraParams.cisRelated;
        console.log(cisRelatedText.value);
        if (record.target.value != '' && reasonCombobox.value != '') {
            teamStore.proxy.extraParams.cisRelated = cisRelatedText.value;
            teamStore.proxy.extraParams.reason = reasonCombobox.value;
            teamStore.reload();
        }
       if(teamStore.getCount() > 0){
            teamCombobox.show();
       }
    });

    reasonCombobox.on('select', function(cmb, record, index) {
        delete provinceStore.proxy.extraParams.segment;
        delete provinceStore.proxy.extraParams.reason;
        delete provinceStore.proxy.extraParams.province;
        delete provinceStore.proxy.extraParams.percentShare;
        delete provinceStore.proxy.extraParams.language;
        delete provinceStore.proxy.extraParams.businessCode;
        delete provinceStore.proxy.extraParams.saleSize;    

        delete teamStore.proxy.extraParams.cisRelated;
        delete teamStore.proxy.extraParams.reason;
        delete teamStore.proxy.extraParams.province;
        delete teamStore.proxy.extraParams.segment;
        
        segmentCombobox.hide();
        provinceCombobox.hide();
        teamCombobox.hide();
        segmentProsCombobox.hide();
        percentShareCombobox.hide();
        languageCombobox.hide();
        cisRelatedText.hide();

        segmentCombobox.clearValue();
        provinceCombobox.clearValue();
        teamCombobox.clearValue();
        segmentProsCombobox.clearValue();
        percentShareCombobox.clearValue();
        languageCombobox.clearValue();
        cisRelatedText.setValue('');

        segmentCombobox.labelEl.update(config.map_label.YearEnd_ReferOutSegment+':');
        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');
        segmentProsCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');

        segmentCombobox.allowBlank = true;
        provinceCombobox.allowBlank = true;
        teamCombobox.allowBlank = true;
        segmentProsCombobox.allowBlank = true;
        percentShareCombobox.allowBlank = true;
        languageCombobox.allowBlank = true;
        cisRelatedText.allowBlank = true;


        if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Wrong Area') {
            
            segmentProsCombobox.allowBlank = false;
            segmentProsCombobox.labelEl.update('Refer Out Segment'+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            segmentProsCombobox.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Team') {
            
            segmentProsCombobox.allowBlank = false;
            segmentProsCombobox.labelEl.update('Refer Out Segment'+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            segmentProsCombobox.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && (record.get('pvalue') == 'Other Segment' || record.get('pvalue') == 'Nationality')) {
            var grid = Ext.getCmp('yearEndGrid');
            var selections = grid.getView().getSelectionModel().getSelection();
            if(selections.length > 1){
                Ext.Msg.alert(config.map_label.YearEnd_Servererror,'สามารถทำได้ทีละรายเท่านั้น');
            }else{
                if(record.get('pvalue') == 'Other Segment' &&  (selections[0].data.Sales_Size__c < 400000000 || selections[0].data.Sales_Size__c ==null || selections[0].data.Sales_Size__c == '')){
                    Ext.Msg.alert(config.map_label.YearEnd_Servererror,config.map_label.YearEnd_InvalidSaleSize);
                }else{
                    segmentProsCombobox.allowBlank = false;
                    segmentProsCombobox.labelEl.update('Refer Out Segment'+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
                    segmentProsCombobox.show();
                }
            }
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Company Related') {

            //cisRelatedText.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            teamCombobox.allowBlank = false;
            cisRelatedText.allowBlank =false;
            teamStore.proxy.extraParams.cisRelated = cisRelatedText.value;
            teamStore.proxy.extraParams.reason = record.get('pvalue');
            teamStore.reload();

            cisRelatedText.show();
            teamCombobox.show();
        }
        segmentProsStore.proxy.extraParams.subScope = reasonCombobox.value;
        segmentProsStore.reload();

        segmentCombobox.clearInvalid();
        provinceCombobox.clearInvalid();
        teamCombobox.clearInvalid();
        segmentProsCombobox.clearInvalid();
        percentShareCombobox.clearInvalid();
        languageCombobox.clearInvalid();
    });

    segmentCombobox.on('select', function(cmb, record, index) {
        provinceCombobox.clearValue();
        teamCombobox.clearValue();

        provinceCombobox.clearInvalid();
        teamCombobox.clearInvalid();

        delete provinceStore.proxy.extraParams.segment;
        delete teamStore.proxy.extraParams.segment;

        delete provinceStore.proxy.extraParams.province;
        delete teamStore.proxy.extraParams.province;

        if (record.get('pvalue') && record.get('pvalue') != '') {
            provinceStore.proxy.extraParams.segment = record.get('pvalue');
            provinceStore.reload();

            teamStore.proxy.extraParams.segment = record.get('pvalue');
            teamStore.reload();
        }
    });


    segmentProsCombobox.on('select', function(cmb, record, index) {
        percentShareCombobox.hide();
        languageCombobox.hide();

        provinceCombobox.clearValue();
        teamCombobox.clearValue();

        provinceCombobox.clearInvalid();
        teamCombobox.clearInvalid();

        delete provinceStore.proxy.extraParams.segment;
        delete provinceStore.proxy.extraParams.province;
        delete teamStore.proxy.extraParams.segment;
        delete teamStore.proxy.extraParams.province;

        if (record.get('pvalue') && record.get('pvalue') == 'CBS') {
            percentShareCombobox.show();
            languageCombobox.show();
        }else if (record.get('pvalue') && record.get('pvalue') != '') {
            provinceStore.proxy.extraParams.segment = record.get('pvalue');
            provinceStore.reload();

            teamStore.proxy.extraParams.segment = record.get('pvalue');
            teamStore.reload();
            provinceCombobox.show();
            teamStore.show();
        }
    });

    percentShareCombobox.on('select', function(cmb, record, index) {

        provinceCombobox.hide();
        teamCombobox.hide();

        provinceCombobox.clearValue();
        teamCombobox.clearValue();

        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');

        provinceCombobox.allowBlank = true;
        teamCombobox.allowBlank = true;
        cisRelatedText.allowBlank=true;

        console.log('percentShareCombobox :'+record.get('pvalue'));
        console.log('languageCombobox.value :'+languageCombobox.value);
        if (record.get('pvalue') && record.get('pvalue') != '' && languageCombobox.value != '') {
            //alert('reload Store');
            delete provinceStore.proxy.extraParams.reason;
            delete provinceStore.proxy.extraParams.percentShare;
            delete provinceStore.proxy.extraParams.language;
            delete provinceStore.proxy.extraParams.businessCode;
            delete provinceStore.proxy.extraParams.saleSize;

            var grid = Ext.getCmp('yearEndGrid');
            var selections = grid.getView().getSelectionModel().getSelection();

            if(record.get('pvalue') == 'Thai / Others' && languageCombobox.value !=null && languageCombobox.value == 'Thai / Others'){
                if(reasonCombobox.value =='Nationality'){
                    Ext.Msg.alert(config.map_label.YearEnd_Servererror,config.map_label.YearEnd_InvalidNationalitySaleSize);
                }else{
                    provinceCombobox.labelEl.update(config.map_label.YearEnd_SelectaProvince+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
                    provinceCombobox.allowBlank = false;
                    teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
                    teamCombobox.allowBlank = false;
                    provinceStore.proxy.extraParams.reason = reasonCombobox.value;
                    provinceStore.proxy.extraParams.percentShare = record.get('pvalue');
                    provinceStore.proxy.extraParams.language = languageCombobox.value;
                    provinceStore.proxy.extraParams.businessCode = selections[0].data.Business_Code__c;
                    provinceStore.proxy.extraParams.saleSize = selections[0].data.Sales_Size__c;
                    provinceStore.reload(); 
                    provinceCombobox.show();
                }
            }else{
                

                teamStore.proxy.extraParams.reason = reasonCombobox.value;
                teamStore.proxy.extraParams.percentShare = record.get('pvalue');
                teamStore.proxy.extraParams.language = languageCombobox.value;
                teamStore.proxy.extraParams.businessCode = selections[0].data.Business_Code__c;
                teamStore.proxy.extraParams.saleSize = selections[0].data.Sales_Size__c;
                teamStore.reload(); 
                teamCombobox.show();
            }

        } 

    });

    languageCombobox.on('select', function(cmb, record, index) {

        provinceCombobox.hide();
        teamCombobox.hide();
        provinceCombobox.clearValue();
        teamCombobox.clearValue();

        provinceCombobox.labelEl.update(config.map_label.YearEnd_Refer_Out_Province+':');
        teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':');

        provinceCombobox.allowBlank = true;
        teamCombobox.allowBlank = true;
        cisRelatedText.allowBlank=true;

        console.log('languageCombobox :'+record.get('pvalue'));
        console.log('percentShareCombobox.value :'+percentShareCombobox.value);
        if (record.get('pvalue') && record.get('pvalue') != '' && percentShareCombobox.value !=null  && percentShareCombobox.value != '') {
            //alert('reload Store');
            delete provinceStore.proxy.extraParams.reason;
            delete provinceStore.proxy.extraParams.percentShare;
            delete provinceStore.proxy.extraParams.language;
            delete provinceStore.proxy.extraParams.businessCode;
            delete provinceStore.proxy.extraParams.saleSize;
            var grid = Ext.getCmp('yearEndGrid');
            var selections = grid.getView().getSelectionModel().getSelection();
            console.log(selections[0]);
            console.log('Sales_Size__c :'+selections[0].data.Sales_Size__c);
            if(record.get('pvalue') == 'Thai / Others' && percentShareCombobox.value == 'Thai / Others'){
                if(reasonCombobox.value =='Nationality'){
                    Ext.Msg.alert(config.map_label.YearEnd_Servererror,config.map_label.YearEnd_InvalidNationalitySaleSize);
                }else{
                    provinceCombobox.labelEl.update(config.map_label.YearEnd_SelectaProvince+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
                    provinceCombobox.allowBlank = false;
                    teamCombobox.labelEl.update(config.map_label.YearEnd_ReferOutTeam+':<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
                    teamCombobox.allowBlank = false;
                    
                    provinceStore.proxy.extraParams.reason = reasonCombobox.value;
                    provinceStore.proxy.extraParams.percentShare = percentShareCombobox.value;
                    provinceStore.proxy.extraParams.language = record.get('pvalue');
                    provinceStore.proxy.extraParams.businessCode = selections[0].data.Business_Code__c;
                    provinceStore.proxy.extraParams.saleSize = selections[0].data.Sales_Size__c;
                    provinceStore.reload();
                    provinceCombobox.show();
                }
            }else{
                

                teamStore.proxy.extraParams.reason = reasonCombobox.value;
                teamStore.proxy.extraParams.percentShare = percentShareCombobox.value;
                teamStore.proxy.extraParams.language = record.get('pvalue');
                teamStore.proxy.extraParams.businessCode = selections[0].data.Business_Code__c;
                teamStore.proxy.extraParams.saleSize = selections[0].data.Sales_Size__c;
                teamStore.reload(); 
                teamCombobox.show();
            }
        } 

    });

    provinceCombobox.on('select', function(cmb, record, index) {
        teamCombobox.clearValue();

        teamCombobox.clearInvalid();
        
        delete provinceStore.proxy.extraParams.reason;
        delete provinceStore.proxy.extraParams.percentShare;
        delete provinceStore.proxy.extraParams.language;
        delete provinceStore.proxy.extraParams.businessCode;
        delete provinceStore.proxy.extraParams.saleSize;

        if (record.get('pvalue') && record.get('pvalue') != '') {
            var grid = Ext.getCmp('yearEndGrid');
            var selections = grid.getView().getSelectionModel().getSelection();
            
            teamStore.proxy.extraParams.reason = reasonCombobox.value;
            teamStore.proxy.extraParams.percentShare = percentShareCombobox.value;
            teamStore.proxy.extraParams.language = record.get('pvalue');
            teamStore.proxy.extraParams.businessCode = selections[0].data.Business_Code__c;
            teamStore.proxy.extraParams.saleSize = selections[0].data.Sales_Size__c;
            teamStore.proxy.extraParams.province = record.get('pvalue');

            teamStore.reload();
            teamCombobox.show();
        }
    });



    var selectedCountStore = createStoreModel(yearEndSelModelName, 200, {
        autoLoad: false
    });

    var is_confirmlist = false;
    var request_id;
    
    var yearEndCheckbox = function(record) {//&& record.Selected_By_Team__c!=config.user_team
       
        var valid = true;
        // console.log(record.Year_End_Assignment_Selections__r[0].Selected_By_Team__c);

        if(!config.submit_flag && record.Status__c=='New' && ((!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined"))){
            if(!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined" || record.Year_End_Assignment_Selections__r.length == 0){
                valid = true;
            }else{
                if(record.Year_End_Assignment_Selections__r.length > 0){
                    for(var i=0 ;i <record.Year_End_Assignment_Selections__r.length;i++){
                        if(record.Year_End_Assignment_Selections__r[i].Selected_By_Team__c==config.user_team || record.Year_End_Assignment_Selections__r[i].CreatedBy.Employee_ID__c==config.user_empid){
                            valid = false;
                            break;
                        }
                    }
                }
            }
        }else valid = false;

        return valid;
    };
    var yearEndSelCheckbox = function(record) {
        //console.log('----');
        //console.log('config.user_rc_code'+ config.user_rc_code);
        return !config.submit_flag && record.Selected_By_Next_Year__r && (record.Selected_By_Next_Year__r.RC_Code__c == config.user_rc_code || record.CreatedBy.RC_Code__c == config.user_rc_code)&& record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    };
    // var yearEndDuplicateCheckbox = function(record) {
    //     return !config.submit_flag && record.Selected_By_Next_Year__r && (record.Selected_By_Next_Year__r.RC_Code__c == config.user_rc_code || record.CreatedBy.RC_Code__c == config.user_rc_code)&& record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    // };
    var yearEndDuplicateCheckbox = function(record) {
        return !config.submit_flag && record.Selected_By_Next_Year__r && (record.Selected_By_Next_Year__r.RC_Code__c == config.user_rc_code || record.CreatedBy.RC_Code__c == config.user_rc_code)&& record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    };
    var filterRBS = function(record) {
        return record.Able_Refer_To_RBS__c;
    };
    var yearEndSelConfirmCheckbox = function(record) {
        return !config.submit_flag && record.Selected_By_Next_Year__r && record.Selected_By_Next_Year__r.RC_Code__c == config.user_rc_code && record.Year_End_Assignment__r.Status__c=='New' && record.Final_Assigned_Next_Year__c && record.Final_Assigned_Next_Year__c != null && typeof record.Final_Assigned_Next_Year__c !== "undefined";
    };
    var ownershipCheckbox = function(record) {
        return !config.submit_flag && (record.Approval_Status__c=='Open' || record.Approval_Status__c=='Approval In Progress');
    };
    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: config.map_label.YearEnd_Refer_Out,
        items: [reasonCombobox,cisRelatedText,segmentCombobox,segmentProsCombobox,percentShareCombobox,languageCombobox,provinceCombobox,teamCombobox],
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
                            console.log(segmentProsCombobox.getValue());
                            if(!segmentProsCombobox.hidden && segmentProsCombobox.getValue()=='RBS'){
                                
                                final_selections = _.filter(before_final_selections, function(record){
                                    var final_rec = filterRBS(record.data); 

                                    if(!final_rec) blacklist_records.push(record.data.CIS_ID_Unique__c);
                                    return final_rec;
                                });
                                if(blacklist_records.length){
                                    Ext.Msg.alert('Warning!' ,config.map_label.YearEnd_CannotReferToRBSSegment + ' '+ blacklist_records.join(','));
                                }
                            }else final_selections = before_final_selections;
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

                                        customerOwnerStore.sync();
                                        customerOwnerStore.reload();
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
        yearEndSelMoreOneStore.reload();
        yearEndRefOutStore.reload();
        yearEndSelSelectedStore.reload();
        yearEndSelConfirmStore.reload();
        customerOwnerStore.reload();
    };
    var usable_element = {
        remove_selection :function(){
            return {
                text: config.map_label.YearEnd_Remove_RM_Selection,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var before_final_selections = _.filter(selections, function(record){
                        return yearEndSelCheckbox(record.data);
                    });
                    if (selections.length > 0) {
                        if(selections.length <=before_final_selections.length){
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
                        }else{
                            Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, 'Invalid Selection');
                        }
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
        },
        customer_selected_by_team :function(flisteners){
            return {
                xtype: 'combobox',
                labelWidth: 155,
                fieldLabel: config.map_label.YearEnd_CustomerSelectedbyTeam,
                triggerAction: 'all',
                editable: false,
                lazyRender: true,
                mode: 'remote',
                store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                        'property',
                        'value'
                    ],
                    data: [
                        [config.map_label.YearEnd_ShowAll, ''],
                        [config.map_label.YearEnd_MyTeam, 'false']
                    ]
                }),
                value: '',
                valueField: 'value',
                displayField: 'property',
                listeners: flisteners
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
                    hidden:config.submit_flag,
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                grid.store.removeFilter("CreatedBy.RC_Code__c");
                                if (selected.data.value == 'false') {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.enable();
                                    grid.store.filter("CreatedBy.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.disable();
                                    grid.store.removeFilter("CreatedBy.RC_Code__c");
                                }
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
                    if (yearEndDuplicateCheckbox(record.data)) {
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
                    hidden:config.submit_flag,
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By_Next_Year__c");
                                if (selected.data.value == 'false') {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.enable();
                                    grid.store.filter("Selected_By_Next_Year__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.disable();
                                    grid.store.removeFilter("Selected_By_Next_Year__r.RC_Code__c");
                                }
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
                    hidden:config.submit_flag,
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                grid.store.removeFilter("CreatedBy.RC_Code__c");
                                if (selected.data.value == 'false') {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.enable();
                                    grid.store.filter("CreatedBy.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.disable();
                                    grid.store.removeFilter("CreatedBy.RC_Code__c");
                                }
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
        createGridObject('<span style="color:red;">4.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, { //extra here
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                hidden:config.submit_flag,
                items: [{
                    text: config.map_label.YearEnd_SelectCheckedCustomer,
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();

                        var final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            selectByPanelCombobox.clearValue();
                            portPoolPanelCombobox.clearValue();
                            servicePanelCombobox.clearValue();

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
                            segmentCombobox.clearValue();
                            languageCombobox.clearValue();
                            percentShareCombobox.clearValue();
                            provinceCombobox.clearValue();
                            teamCombobox.clearValue();
                            segmentProsCombobox.clearValue();
                            cisRelatedText.setValue('');

                            reasonCombobox.clearInvalid();
                            languageCombobox.clearInvalid();
                            percentShareCombobox.clearInvalid();
                            segmentCombobox.clearInvalid();
                            provinceCombobox.clearInvalid();
                            teamCombobox.clearInvalid();
                            segmentProsCombobox.clearInvalid();

                            segmentCombobox.hide();
                            languageCombobox.hide();
                            percentShareCombobox.hide();
                            provinceCombobox.hide();
                            teamCombobox.hide();
                            segmentProsCombobox.hide();
                            cisRelatedText.hide();
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
            title: '<span style="color:red;">5.</span> '+config.map_label.YearEnd_OwnershipRequest,
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
                                        if (final_selections.length > 0) {

                                            Ext.MessageBox.confirm(
                                                config.map_label.YearEnd_ConfirmRecall,
                                                config.map_label.YearEnd_AreYouSureToRecall,
                                                function(btn, text) {
                                                    if (btn == 'yes') {
                                                        var savingObj = sendRequest('changeStatusYearStruc', {
                                                            yearlist: _.pluck(selections, 'id'),
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
            title: '<span style="color:red;">6.</span> '+config.map_label.YearEnd_Submitted,
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
        },
        createGridObject(config.map_label.YearEnd_ConfirmList, 'yearEndSelConfirmGrid', yearEndSelConfirmStore, yearSelConfirmColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        usable_element.customer_selected_by_team({
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                grid.store.removeFilter("Selected_By_Next_Year__c");
                                if (selected.data.value == 'false') {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.enable();
                                    grid.store.filter("Selected_By_Next_Year__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.disable();
                                    grid.store.removeFilter("Selected_By_Next_Year__r.RC_Code__c");
                                }
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
            }
        })
    ];
    config.container_items = [request_popup,selectconfirm_popup,referout_popup,selectedcount_popup];
};
