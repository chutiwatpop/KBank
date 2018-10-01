function init(config) {
    fields_base["Selected_Count_Unlock"] = {
        "dataIndex": "Selected_Count__c",
        "align": "right",
        "format": "0,000",
        "sortable":false,
        "xtype": "numbercolumn",
        renderer: function (val, metadata, record) {
            metadata.style = 'cursor: pointer;'; 
            return val;
        },
        "listeners":{
            "click": function(gridtable,gridtable_html,index,col,record){
                var record_data = record.record.data;
                if(record_data.Selected_Count__c > 1){
                    selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
                    selectedcount_popup.show();
                }
            }
        }
    };

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
     
    var yearColumn  = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Segment_Original__c","RM_TM_Name__c","TL_Name__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Total_Income__c","Business_Code__c","Business_Desc__c","Credit_Status__c","CreatedBy_Selection__c","AssignTo_Selection__c","ReferOut_Reason_Selection__c","Refer_Out_Selection__c"]);
    var selectedCountColumn = mappingColumn(config.yearEndSelForMap,["RM_TM_Name__c","Team__c","TM_Name__c","Selected_By_Name__c","Selected_By_Team__c"]);
    var yearSelMoreOneColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Type__c","Segment_Original__c","RM_TM_Name__c","TL_Name__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Total_Income__c","Business_Code__c","Business_Desc__c","Created_Name","Selected_By_Name__c","Refer_Out__c","Selected_By_Team__c","Refer_Out_Reason__c","Selected_Count_Unlock"]);
    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Segment_Original__c","RM_TM_Name__c","TL_Name__c","CBS_Group__c","CBS_Sub_Group__c","Sales_Size__c","Total_Income__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Created_Name","Selected_By_Name__c","Refer_Out_Team__c","Refer_Out_Reason__c","Selected_Count_Unlock"]);
    
    var yearStrucColumn = mappingColumn(config.customerOwnerForMap,["CIS_ID__c","Customer_Name__c","Type__c","Requester_Name_Text__c","Requester_AH_Name__c","Requester_Team__c","Segment_Original__c","High_Value_Flag__c","Credit_Status__c","RM_Name__c","Team__c","TM_Name__c","Assigned_Port_Pool__c","Refer_Out_Reason__c","Refer_Out_From_Name__c","Refer_Out_From_Team__c","Refer_Out_To_Name__c","Refer_Out_To_Team__c","Approver_Name__c","Approval_Status__c","Requester_Manager_Approve_Flag__c","Selected_Count_Unlock"]);
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
    var selectionModelColumn = [
        {
            "name": "CreatedBy.Name",
            "mapping": 'CreatedBy.Name'
        }
    ];
    var yearendselectionModelColumn = [
        {
            "name": "Year_End_Assignment_Selections__Refer_Out__c",
            "mapping": 'Year_End_Assignment_Selections__r.Refer_Out__c'
        }
    ];
    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");
    var yearStrucModelName = Ext.String.capitalize("Year_End_Ownership_Request__c");

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
    createModel('selectedCount', 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldselcountlist.join(',')
        }
    );
    createModel(yearStrucModelName, 'records', 'Id',
        '', RemoterExtensions.query, {
            sobjname: 'Year_End_Ownership_Request__c',
            fields: config.fieldrequestlist.join(',')
        }
    );
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        autoLoad:false,
        filters: [{ // move to controller
            property: 'AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        }],
        sorters:[{
            property: 'CIS_ID_Unique__c',
            direction: 'ASC'
        }]
    });
   
    var yearEndRefOutStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,

        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            value: 'null',
            default: true
         },{
            property: 'Refer_Out__c',
            value: 'true',
            default: true
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    var yearEndSelSelectedStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            value: 'null',
            default: true
         },{
            property: 'Selected_Count__c',
            value: '1',
            default: true
         },{
            property: 'Refer_Out__c',
            value: 'false',
            default: true
         },{ 
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        },{
            property: 'Need_Approval__c',
            value: 'false',
            default: true
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearStrucStore = createStoreModel(yearStrucModelName, config.pagesize, {
        autoLoad:false,
        filters: [
        {
            property: 'Selected_Count__c',
            value: '1',
            default: true
        },{
            property: 'Approval_Status__c = \'Approval In Progress\'',
            operator: 'AND',
            value: '(Approver__c =\''+config.user_id+'\' OR ( Requester_AH__c =\''+config.user_id+'\' AND Requester_Manager_Approve_Flag__c = false ) )',
            default: true
        }]
        ,
        sorters:[{
            property: 'Requester_Manager_Approve_Flag__c',
            direction: 'ASC'
        }]
        
    });
    
    var yearStrucPendingStore = createStoreModel(yearStrucModelName, config.pagesize, {
        autoLoad:false,
        filters: [{ 
            property: 'Creator_AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelMoreOneStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            value: 'null',
            default: true
         },{
            property: 'Selected_Count__c > 1 ',
            operator: 'AND',
            value: ' (Year_End_Assignment__r.AH_RC_Code__c =\''+config.user_rc_code+'\' OR CreatedBy.RC_Code__c =\''+config.user_rc_code+'\')',
            default: true
         }
        //  ,{ 
        //     property: 'Year_End_Assignment__r.AH_RC_Code__c',
        //     value: '#'+config.user_rc_code,
        //     default: true
        // }
        ],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var customerOwnerStore = createStoreModel(yearStrucModelName, 200, {
        autoLoad: false,
        filters: [{
            property: 'Requester__r.RC_Code__c',
            value: '#'+config.user_rc_code
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


    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200,
        sorters: []
    });

    var selectedCountStore = createStoreModel(yearEndSelModelName, 200, {
        autoLoad: false
    });

    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByAH,{extra:'All',subScope:'User__c',isAH:true,selfInclude:true},true);
    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedBy, {scope: config.user_rc_code}, true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM,{scope:config.user_rc_code,isAH:true},true);
    var selectByTeamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},true);
    var selectByTeamPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{},true);

    /*refer out panel*/
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryReason,{scope:'CBS'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'SME'},true);
    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Province'},false);
    var languageStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Language__c'},true);
    var teamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Team'},false);
    var segmentProsStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'CBS'},true);

    var cisText = new Ext.form.TextField({
        fieldLabel: config.yearEndForMap["CIS_ID_Unique__c"].label,//,
        name: 'search_box',
    });

    var yearEndCheckbox = function(record) {
        //return !config.submit_flag && record.Status__c=='New' && record.Selected_Count__c==0 && ((!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined") && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined") && record.Selected_Count__c==0);
        return true;
    };
    var yearEndCheckboxfilter = function(record) {
        return (record.Year_End_Assignment_Selections__r !=null && record.Year_End_Assignment_Selections__r[0].Refer_Out__c == true);
    };

    var yearEndSelCheckbox = function(record) {
        console.log(!config.submit_flag);
        console.log(record.Year_End_Assignment__r.Status__c=='New');
        console.log(record.Selected_Count__c!=0);
        console.log((!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined"));
        return !config.submit_flag && record.Year_End_Assignment__r.Status__c=='New' && record.Selected_Count__c!=0 && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    };

    var yearEndDuplicateCheckbox = function(record) {
        console.log(record);
        return !config.submit_flag && record.Year_End_Assignment__r.Status__c=='New' && record.Selected_Count__c >1;
    };
    
    var ownershipCheckbox = function(record) {
        return record.Approval_Status__c=='New' || record.Approval_Status__c=='Approval In Progress';
    };
    var ownershipAllListCheckbox = function(record) {
        //Remove by requirement 4/11/2016 return record.Requester_Manager_Approve_Flag__c==true && record.Approval_Status__c=='Approval In Progress';
        return false;
    };
    
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
    var languageCombobox = createComboxbox(config.map_label.YearEnd_Refer_Language, 'referoutLanguage', false, languageStore, config.map_label.YearEnd_Refer_Language, 'pname', 'pvalue', false, false);
    
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

    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.map_label.YearEnd_Select_a_Segment, 'pname', 'pvalue', false, false);

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

    var selectByRefOutCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyName, 'selectedbyname', false, selectByStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 210,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    grid.store.filter("Createdby.Id", '#'+selected.get('pvalue'));
                } else grid.store.removeFilter("Createdby.Id");
            }
        }
    });
    var selectByMoreOneCombobox = selectByRefOutCombobox.cloneConfig();
    
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
                    //grid.store.removeFilter("Selected_By_Next_Year__r.RC_Code__c");
                    delete selectByPanelStore.proxy.extraParams.subScope;
                }else {
                    selectByPanelCombobox.clearValue();
                    selectByPanelCombobox.enable();
                    //grid.store.filter("Selected_By_Next_Year__r.RC_Code__c", '#'+selected.data.pvalue);
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
                [config.map_label.YearEnd_Port,'Port']
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

    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: config.map_label.YearEnd_Refer_Out,
        items: [reasonCombobox,segmentCombobox,languageCombobox,segmentProsCombobox,cisRelatedText,provinceCombobox,teamCombobox],
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
                            
                            if(before_final_selections.length){
                                grid.setLoading(true);
                                referout_popup.hide();
                                Ext.Deferred
                                .all([sendRequest('saveYearEnd',{
                                          contx:'REFER_OUT',
                                          referOut:form.getFieldValues(),
                                          yearlist:_.pluck(before_final_selections,'id')
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
        yearEndSelMoreOneStore.reload();
        yearEndRefOutStore.reload();
        yearEndSelSelectedStore.reload();
        yearStrucStore.reload();
        yearStrucPendingStore.reload();
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
        remove_selection :function(){
            return {
                text: config.map_label.YearEnd_Remove_RM_Selection,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var final_selections = _.filter(selections, function(record) {
                        return yearEndSelCheckbox(record.data);
                    });
                    if (final_selections.length > 0) {

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
        remove_dup_selection :function(){
            return {
                text: config.map_label.YearEnd_Remove_RM_Selection,
                handler: function() {
                    var grid = this.up('grid');
                    var selections = grid.getView().getSelectionModel().getSelection();
                    var final_selections = _.filter(selections, function(record) {
                        return yearEndDuplicateCheckbox(record.data);
                    });
                    
                    if (final_selections.length > 0) {

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
        }
    };
    config.panel_items = [
        {
            title: '<span style="color:red;">1.</span> Pending for Approve',
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
                    createGridObject(config.map_label.YearEnd_DuplicateSelected, 'yearEndSelMoreOneGrid', yearEndSelMoreOneStore, yearSelMoreOneColumn, {
                        width: '100%',
                        height: 250,
                        clearAll: function(){
                            //console.log('clear all');
                            selectByMoreOneCombobox.clearValue();
                        },
                        dockedItems: [{
                                xtype: 'tbspacer'
                            }, {
                                xtype: 'toolbar',
                                dock: 'bottom',
                                hidden:config.submit_flag,
                                items: [usable_element.remove_dup_selection()]
                            }, {
                                xtype: 'toolbar',
                                dock: 'top',
                                items: [
                                    {
                                        xtype: 'tbspacer'
                                    },
                                    selectByMoreOneCombobox
                                ]
                            }
                            ],
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
                    createGridObject(config.map_label.YearEnd_ApprovalList, 'apprvalGrid',yearStrucStore , yearStrucColumn, {
                        width: '100%',
                        height: 250,
                        dockedItems: [{
                                xtype: 'tbspacer'
                                }, {
                                xtype: 'toolbar',
                                dock: 'bottom',
                                hidden:config.submit_flag,
                                items: [
                                    {
                                        xtype: 'button',
                                        text: config.map_label.YearEnd_Approve,
                                        handler: function() {
                                            var grid = this.up('grid');
                                            var selections = grid.getView().getSelectionModel().getSelection();
                                            if (selections.length > 0) {
                                                Ext.MessageBox.confirm(
                                                    config.map_label.YearEnd_PleaseApprove,
                                                    config.map_label.YearEnd_ConfirmApprove,
                                                    function(btn, text) {
                                                        if (btn == 'yes') {
                                                            var savingObj = sendRequest('changeStatusYearStruc', {
                                                                yearlist: _.pluck(selections, 'id'),
                                                                approveStatus: 'Approve'
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
                                    {
                                        xtype: 'button',
                                        text: config.map_label.YearEnd_Reject,
                                        handler: function() {
                                            var grid = this.up('grid');
                                            var selections = grid.getView().getSelectionModel().getSelection();
                                            if (selections.length > 0) {

                                                Ext.MessageBox.confirm(
                                                    config.map_label.YearEnd_PleaseReject,
                                                    config.map_label.YearEnd_ConfirmReject,
                                                    function(btn, text) {
                                                        if (btn == 'yes') {
                                                            var savingObj = sendRequest('changeStatusYearStruc', {
                                                                yearlist: _.pluck(selections, 'id'),
                                                                approveStatus: 'Rejected'
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
                                    }
                                ]
                            }],
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
                        })
                    })
            ]
        },
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, { //extra here

            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                hidden:config.submit_flag,
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
                            //return record.data.Selected_Count__c == 0;
                            console.log(record);
                            return true;
                        });
                        var referout_selections = _.filter(before_final_selections, function(record) {
                            return yearEndCheckboxfilter(record.data);
                        });
                        if(referout_selections.length >0){
                            Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, 'have refer out record');
                        }else{
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
                        var referout_selections = _.filter(final_selections, function(record) {
                            return yearEndCheckboxfilter(record.data);
                        });
                        if(referout_selections.length >0){
                            Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, 'have refer out record');
                        }else{
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
                    }
                }]
            }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndStore.sync();
                    yearEndStore.reload();
                },
                'headerclick': function(g, index, ev) {
                    //console.log(index.dataIndex);
                    if(index.dataIndex === 'Year_End_Assignment_Selections__r'){
                        return false;
                    }
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
        createGridObject('<span style="color:red;">3.</span> '+config.map_label.YearEnd_ReferOutList, 'yearEndRefOutGrid', yearEndRefOutStore, yearSelColumn,{
            // clearAll: function(){
            //     selectByMoreOneCombobox.clearValue();
            // },
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'tbspacer'
                        },
                        selectByRefOutCombobox
                    ]
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
            title: '<span style="color:red;">4.</span> '+config.map_label.YearEnd_OwnershipRequest,
            id: 'ownerrequest-tab2',
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
                createGridObject(config.map_label.YearEnd_OwnershipRequest, 'customerGrid', customerStore, customerColumns, {
                    width: '100%',
                    height: 200,
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
                    height: 300,
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
        createGridObject('<span style="color:red;">5. </span>'+config.map_label.YearEnd_RequestReferOutStatus, 'pendingApprvalGrid',yearStrucPendingStore , yearStrucColumn, {
            width: '100%',
            height: 500,
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    hidden:config.submit_flag,
                    items: [
                        // {
                        //     xtype: 'button',
                        //     text: config.map_label.YearEnd_Recall,
                        //     handler: function() {
                        //         var grid = this.up('grid');
                        //         var selections = grid.getView().getSelectionModel().getSelection();
                        //         var final_selections = _.filter(selections, function(record) {
                        //             return ownershipCheckbox(record.data);
                        //         });
                        //         if (final_selections.length > 0) {

                        //             Ext.MessageBox.confirm(
                        //                 config.map_label.YearEnd_ConfirmRecall,
                        //                 config.map_label.YearEnd_AreYouSureToRecall,
                        //                 function(btn, text) {
                        //                     if (btn == 'yes') {
                        //                         var savingObj = sendRequest('changeStatusYearStruc', {
                        //                             yearlist: _.pluck(final_selections, 'id'),
                        //                             approveStatus: 'Recalled'
                        //                         });
                        //                         grid.setLoading(true);
                        //                         Ext.Deferred
                        //                             .all([savingObj])
                        //                             .then(function(results) {
                        //                                 if (results[0].success) {
                        //                                     grid.getView().getSelectionModel().deselectAll();
                        //                                     reloadAllStore();
                        //                                 } else {
                        //                                     if(results[0].duplicate){
                        //                                       Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                        //                                    }else Ext.Msg.alert(config.map_label.YearEnd_Servererror, results[0].errorMessage);
                        //                                 }
                        //                                 grid.setLoading(false);
                        //                             }, function(errors) {
                        //                                 Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0]);
                        //                             });

                        //                     }
                        //                 });
                        //         } else Ext.Msg.alert(config.map_label.YearEnd_InvalidSelection, config.map_label.YearEnd_NoYearendhavebeenselected);
                        //     }
                        // },
                    ]
                }
            ],
            listeners:{
                'afterrender': function(grid) {
                    yearStrucPendingStore.sync();
                    yearStrucPendingStore.reload();
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (ownershipAllListCheckbox(record.data)) {
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
                                Ext.application({
                                    name: 'Fiddle',
                                    launch: function() {
                                        Ext.getBody().mask("Please wait...");
                                    }
                                });
                                Ext.Deferred
                                    .all([sendRequest('saveYearEnd', {
                                        contx: 'SUBMITTED_AH'
                                    })])
                                    .then(function(results) {
                                        Ext.getBody().unmask();
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
                                        Ext.getBody().unmask();
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