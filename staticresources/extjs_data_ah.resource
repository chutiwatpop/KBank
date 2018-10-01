function init(config) {
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
            //         selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
            //         selectedcount_popup.show();
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
            "name": "Year_End_Assignment_Selection__r.Language__c",
            "mapping": 'Year_End_Assignment_Selection__r.Language__c'
        }
    ];
    var selectionModelColumn = [
        {
            "name": "CreatedBy.Name",
            "mapping": 'CreatedBy.Name'
        }
    ];

    var testColumns = [
        {
            "dataIndex": "name",
            "text": config.customerOwnerForMap["Customer_Name__c"].label,
            "width": 150,
            "locked": true,
            sortable: false
        }
    ];

    var selectedCountColumn = mappingColumn(config.yearEndSelForMap,["RM_Name__c","Team__c","TM_Name__c","Created_Name","Selected_By_Name__c","Selected_By_Team__c"]);

    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Sales_Size__c"]);

    var yearSelMoreOneColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Type__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Selected_Port_Pool__c","Created_Name","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Created_Name","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearStrucColumn = mappingColumn(config.customerOwnerForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Port_Pool__c","Credit_Status__c","RM_Name__c","Team__c","TM_Name__c","Type__c","Requester_Name_Text__c","Requester_Team__c","Assigned_Port_Pool__c","Service_RM_Name_Text__c","Refer_Out_Reason__c","Language__c","Refer_Out_From_Name__c","Refer_Out_From_Team__c","Refer_Out_To_Name__c","Refer_Out_To_Team__c","Approver_Name__c","Approval_Status__c"]);

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
        customerRequestModelColumn, RemoterExtensions.query, {
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
        sorters: [{
            property: 'Selected_Count__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelMoreOneStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c',
            value: 'null',
            default: true
         },{
            property: 'Selected_Count__c',
            operator: '>',
            value: 1,
            default: true
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        },{
            property: 'ID',
            operator: 'NOT IN',
            value: '(Select Year_End_Assignment_Selection__c from Year_End_Ownership_Request__c where Requester_Manager_Approve_Flag__c=false)'
        }],
        sorters:[{
            property: 'CIS_ID__c',
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
            property: 'Selected_Count__c',
            value: '1',
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
         },{ // move to controller
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
        filters: [{ // move to controller
            property: 'Approver__c',
            value: config.user_id,
            default: true
        },{
            property: 'Year_End_Assignment__r.Selected_Count__c',
            value: '1',
            default: true
        },{
            property: 'Approval_Status__c',
            value: 'Approval In Progress',
            default: true
        },{
            property: 'Requester_Manager_Approve_Flag__c',
            value: 'true',
            default: true
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var yearStrucPendingStore = createStoreModel(yearStrucModelName, config.pagesize, {
        autoLoad:false,
        filters: [{ // move to controller
            property: 'Creator_AH_RC_Code__c',
            value: '#'+config.user_rc_code,
            default: true
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var selectedCountStore = createStoreModel(yearEndSelModelName, 200, {
        autoLoad: false
    });
    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByAH,{extra:'All',subScope:'User__c',isAH:true,selfInclude:true},true);
    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByAH,{isAH:true,selfInclude:false},true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryAHSelectedByOnlyRM,{scope:config.user_rc_code,isAH:true},true);
    var selectByTeamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{extra:'All'},true);
    var selectByTeamPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByTeam,{},true);

    /*refer out panel*/
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryReason,{scope:'SME'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Segment'},true);
    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Province'},false);
    var percentShareStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Percent_Shareholder__c'},true);
    var languageStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Language__c'},true);

    var teamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Team'},false);
    var segmentProsStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'SME'},true);

    //Condition Checkbox First Column
    var yearEndCheckbox = function(record) {
        return !config.submit_flag && record.Status__c=='New' && record.Selected_Count__c==0 && ((!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined") && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined") && record.Selected_Count__c==0);
    };
    var yearEndSelCheckbox = function(record) {
        
        //Edit for Incident 19/12/2016   TM Promote to AH  Other RC_CODE
        return !config.submit_flag && record.Year_End_Assignment__r.Status__c=='New'  && record.Selected_Count__c!=0  && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    };
    var yearEndDuplicateCheckbox = function(record) {
        return !config.submit_flag  && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    };
    // var yearEndDuplicateCheckbox = function(record) {
    //     return !config.submit_flag && record.Selected_By_Next_Year__r && (record.Selected_By_Next_Year__r.AH_RC_Code__c == config.user_rc_code || record.CreatedBy.AH_RC_Code__c == config.user_rc_code)&& record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined");
    // };
    var ownershipCheckbox = function(record) {
        return record.Approval_Status__c=='Open' || record.Approval_Status__c=='Approval In Progress';
    };
    var filterRBS = function(record) {
        return record.Able_Refer_To_RBS__c;
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
    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.yearEndSelForMap['Segment_Proposed__c'].label, 'pname', 'pvalue', false, false);
    var percentShareCombobox = createCustomComboxbox(config.map_label.YearEnd_Refer_PercentShare, 'referoutPercentShare', false, percentShareStore, '% Shareholder', 'pname', 'pvalue', false, false);
    var languageCombobox = createComboxbox(config.map_label.YearEnd_Refer_Language, 'referoutLanguage', false, languageStore, 'Language', 'pname', 'pvalue', false, false);

    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.yearEndSelForMap['Segment_Proposed__c'].label, 'pname', 'pvalue', false, false);

    var cisRelatedText = new Ext.form.TextField({
        fieldLabel: 'Related CIS',//,
        name: 'referoutrelateCIS',
        labelStyle: 'width:120px'
    });

    languageStore.on('load',function (store, records, successful, eOpts ){
         console.log('languageStore length:'+records.length);
    });

    teamStore.on('load',function (store, records, successful, eOpts ){
         //Block of codes
         console.log('--');
         console.log(records.length);
         //Block of codes
    });
    // Event Handler
    cisRelatedText.on('blur', function(cmb, record, index) {
        //console.log(cisRelatedText.value);
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
            teamCombobox.show();
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
            delete provinceStore.proxy.extraParams.reason;
            delete provinceStore.proxy.extraParams.percentShare;
            delete provinceStore.proxy.extraParams.language;
            delete provinceStore.proxy.extraParams.businessCode;
            delete provinceStore.proxy.extraParams.saleSize;
            var grid = Ext.getCmp('yearEndGrid');
            var selections = grid.getView().getSelectionModel().getSelection();

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

    var selectByRefOutCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyName, 'selectedbyname', false, selectByStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, true, {
        labelWidth: 210,
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    grid.store.filter("Createdby.Id", selected.get('pvalue'));
                } else grid.store.removeFilter("Createdby.Id");
            }
        }
    });
    var selectByMoreOneCombobox = selectByRefOutCombobox.cloneConfig();
    //selectByMoreOneCombobox.disable();
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
                    //grid.store.removeFilter("Selected_By_Next_Year__r.RC_Code__c");
                    delete selectByPanelStore.proxy.extraParams.scope;
                }else {
                    selectByPanelCombobox.clearValue();
                    selectByPanelCombobox.enable();
                    //grid.store.filter("Selected_By_Next_Year__r.RC_Code__c", '#'+selected.data.pvalue);
                    console.log(selected.data.pvalue);
                    selectByPanelStore.proxy.extraParams.scope = selected.data.pvalue;
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
        }
    };
    config.panel_items = [
        {
            title: '<span style="color:red;">1.</span> '+config.map_label.YearEnd_DuplicateAndPendingApproveList,
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
                            items: [usable_element.remove_selection()]
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
                                },
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
                }),
            ]
        },
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_SelectedList, 'yearEndSelSelectedGrid', yearEndSelSelectedStore, yearSelColumn, {
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
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{
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
                    items: [usable_element.remove_selection()]
                }, {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        
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
        createGridObject('<span style="color:red;">5.</span> '+config.map_label.YearEnd_PendingApprovalList, 'pendingApprvalGrid',yearStrucPendingStore , yearStrucColumn, {
            width: '100%',
            height: 500,
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
                    if (ownershipCheckbox(record.data)) {
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