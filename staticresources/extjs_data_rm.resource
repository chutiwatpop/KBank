function init(config) {
    
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
    
    var yearColumn = mappingColumn(config.yearEndForMap,["CIS_ID_Unique__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c","Sales_Size__c"]);

    var yearSelColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Created_Name","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelRefOutColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Selected_Port_Pool__c","Created_Name","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearSelConfirmColumn = mappingColumn(config.yearEndSelForMap,["CIS_ID__c","Customer_Name__c","Selected_Count__c","Segment_Original__c","High_Value_Flag__c","Credit_Flag__c","Group__c","UW_Color_Group__c","Final_Port_Pool__c","Final_Team__c","Final_Refer_Out__c","Final_Refer_Out_Reason__c","Final_Refer_Out_Reason_Detail__c","Selected_Port_Pool__c","Selected_By_Name__c","Selected_By_Service_RM_Text__c","Selected_By_Team__c","Refer_Out__c","Refer_Out_Reason__c","Refer_Out_Detail__c","Port_Pool__c","RM_Name__c","TM_Name__c","Team__c","Business_Code__c","Business_Desc__c","Credit_Status__c","Total_Income__c","Total_SME_Limit__c","SME_Limit_LI__c","SME_Limit_TF__c","Total_SME_Out__c","Total_SME_Exposure__c","SOW_SME_Exposure__c","SME_Wallet_Size__c","DPD6M__c","NPL12M__c","Court_Case_12M__c","Court_Case_Current_Year__c","SME_BSCORE_1M__c","SME_BSCORE_3M__c","Relationship_Spouse__c","Relationship_Joint_Obligor__c","Relationship_Affiliate__c","Relationship_Stockholder__c","Relationship_Authorized_Director__c","Visited_Count__c","RM_Last_Visited__c"]);

    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");

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
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
        filters: [{ // move to controller
            property: 'AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
        },{
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
            property: 'Refer_Out__c',
            value: 'true'
        },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
        },{
            property: 'CreatedBy.Id',
            value: '#'+config.userUserLookup
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    //Create Store
    var yearEndSelSelectedStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        autoLoad:false,
        filters: [{
            property: 'Refer_Out__c',
            value: 'false'
         },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
        },{
            property: 'Need_Approval__c',
            value: 'false',
            default: true
        },{
            property: 'CreatedBy.Id',
            value: '#'+config.userUserLookup
        }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });

    var yearEndSelConfirmStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Selected_By_Next_Year__c',
            value: config.user_id
        },{
            property: 'Year_End_Assignment__r.Final_Assigned_Next_Year__c !',
            value: 'null'
        },{
            property: 'Selected_Count__c',
            value: '1'
        },{ // move to controller
            property: 'Year_End_Assignment__r.AH_RC_Code__c',
            value: '#'+config.user_ah_rc_code
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
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryReason,{scope:'SME'},true);

    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Segment'},true);
    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Province'},false);
    var teamStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryTeamMaster,{scope:'Team'},false);
    var percentShareStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Percent_Shareholder__c'},true);
    var languageStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Language__c'},true);

    var segmentProsStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySegment,{scope:'SME'},true);

    // Create Component
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

    var segmentProsCombobox = createComboxbox(config.yearEndSelForMap['Segment_Proposed__c'].label, 'referoutSegmentPros', true, segmentProsStore, config.map_label.YearEnd_Select_a_Segment, 'pname', 'pvalue', false, false);

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
        teamCombobox.clearValue();
        teamCombobox.clearInvalid();

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
                if(record.get('pvalue') == 'Other Segment' && (selections[0].data.Sales_Size__c < 400000000 || selections[0].data.Sales_Size__c ==null || selections[0].data.Sales_Size__c == '')){
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
            //console.log(selections[0]);
            //console.log('Sales_Size__c :'+selections[0].data.Sales_Size__c);
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

    var yearEndCheckbox = function(record) {//&& record.Selected_By_Team__c!=config.user_team
        //console.log(record);
        var valid = true;
        if(!config.submit_flag && record.Status__c=='New' && ((!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c == null || typeof record.Final_Assigned_Next_Year__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined"))){
            if(!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined" || record.Year_End_Assignment_Selections__r.length == 0){
                valid = true;
            }else{
                
                if(typeof record.Year_End_Assignment_Selections__r !=="undefined" && record.Year_End_Assignment_Selections__r.length){
                    for(var i=0 ;i <record.Year_End_Assignment_Selections__r.length;i++){
                        if(record.Year_End_Assignment_Selections__r[i].Selected_By_Next_Year__c==config.user_id || record.Year_End_Assignment_Selections__r[i].CreatedBy.Employee_ID__c==config.user_empid){
                            valid = false;
                            break;
                        }
                    }
                }
            }
        }else valid = false;

        return valid;
    };
    var filterRMS = function(record) {
        return record.Able_Refer_To_RBS__c;
    };
    var yearEndSelCheckbox = function(record) {
        console.log(record.CreatedBy.Employee_ID__c);
        console.log('user_id : '+config.user_id);
        return !config.submit_flag && record.Year_End_Assignment__r.Status__c=='New' && (record.Selected_By_Next_Year__c == config.user_id || record.CreatedBy.Employee_ID__c == config.user_empid) && (!record.Final_Assigned_Next_Year__c || record.Final_Assigned_Next_Year__c==null || typeof record.Final_Assigned_Next_Year__c === "undefined" || record.Final_Assigned_Next_Year__c=='');
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
                            console.log(selections);
                            var before_final_selections = _.filter(selections, function(record){
                                return yearEndCheckbox(record.data);
                            });
                            var blacklist_records = [];
                            var final_selections = [];
                            if(!segmentProsCombobox.hidden && segmentProsCombobox.getValue()=='RBS'){
                                
                                final_selections = _.filter(before_final_selections, function(record){
                                    var final_rec = filterRMS(record.data);

                                    if(!final_rec) blacklist_records.push(record.data.CIS_ID_Unique__c);
                                    return final_rec;
                                });
                                if(blacklist_records.length){
                                    Ext.Msg.alert('Warning!' ,config.map_label.YearEnd_CannotReferToRBSSegment+ ' ' + blacklist_records.join(','));
                                }
                            }else final_selections = before_final_selections;
                            console.log(final_selections.length);
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
                        grid.store.filter("CreatedBy.Id", config.userUserLookup);
                        grid.store.sort("CIS_ID__c", 'ASC');
                    }else {
                       grid.store.removeFilter("CreatedBy.Id");
                    }
                    grid.getView().getSelectionModel().deselectAll();
                }
            };
        }
    };
    config.panel_items = [
        createGridObject('<span style="color:red;">1.</span> '+config.map_label.YearEnd_CustomersList, 'yearEndGrid', yearEndStore, yearColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                hidden:config.submit_flag,
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
                                               }else {
                                                    if(errors[0].errorMessage)
                                                        Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0].errorMessage);
                                                    else Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors);
                                                }
                                            }
                                            grid.setLoading(false);
                                        },function (errors) {
                                            if(errors[0].errorMessage)
                                                Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors[0].errorMessage);
                                            else Ext.Msg.alert(config.map_label.YearEnd_Servererror, errors);
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
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_SelectedList, 'yearEndSelSelectedGrid', yearEndSelSelectedStore, yearSelColumn, {
            dockedItems: [{
                    xtype: 'tbspacer'
                }, {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    hidden:config.submit_flag,
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
                    hidden:config.submit_flag,
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
        },
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
