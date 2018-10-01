function init(config) {
    var selectedOwnerId = '';
    var selectedOwnerTempId = '';

    var selectedTeamId = '';
    var selectedTeamRCCode = '';
    var selectedUserStatus = '';
    var selectedUserId = '';


    var selectedTeamIdPopup = '';
    var selectedUserIdPopup = '';

    var selectedReasonFilter = '';

    var customerRequestModelColumn = [
        {
            "name": "Current_Owner_Extension__r.Name",
            "mapping": 'Current_Owner_Extension__r.Name'
        },{
            "name": "Current_Team_Name__r.Name",
            "mapping": 'Current_Team_Name__r.Name'
        },{
            "name": "Current_Team_Name__r.RC_Code__c",
            "mapping": 'Current_Team_Name__r.RC_Code__c'
        },{
            "name": "Permanent_Owner_Extension__r.Name",
            "mapping": 'Permanent_Owner_Extension__r.Name'
        },{
            "name": "Permanent_Team_Name__r.Name",
            "mapping": 'Permanent_Team_Name__r.Name'
        },{
            "name": "Previous_Owner__r.Name",
            "mapping": 'Previous_Owner__r.Name'
        },{
            "name": "Previous_Team_Name__r.Name",
            "mapping": 'Previous_Team_Name__r.Name'
        },{
            "name": "Service_RM__r.Name",
            "mapping": 'Service_RM__r.Name'
        }
        ,{
            "name": "BulkAssignmentQueue__r.Request_Reason_Picklist__c",
            "mapping": 'BulkAssignmentQueue__r.Request_Reason_Picklist__c'
        },{
            "name": "BulkAssignmentQueue__r.Request_Reason_Text__c",
            "mapping": 'BulkAssignmentQueue__r.Request_Reason_Text__c'
        },{
            "name": "BulkAssignmentQueue__r.OwnerId",
            "mapping": 'BulkAssignmentQueue__r.OwnerId'
        },{
            "name": "BulkAssignmentQueue__r.Name",
            "mapping": 'BulkAssignmentQueue__r.Name'
        },{
            "name": "BulkAssignmentQueue__r.CBS_Admin_To_Approve__c",
            "mapping": 'BulkAssignmentQueue__r.CBS_Admin_To_Approve__c'
        },{
            "name": "BulkAssignmentQueue__r.Submit_Date__c",
            "mapping": 'BulkAssignmentQueue__r.Submit_Date__c'
        },{
            "name": "CIS_ID__r.CIS__c",
            "mapping": 'CIS_ID__r.CIS__c'
        },{
            "name": "CIS_ID__r.CIS_Number__c",
            "mapping": 'CIS_ID__r.CIS_Number__c'
        },{
            "name": "CIS_ID__r.Name_Report__c",
            "mapping": 'CIS_ID__r.Name_Report__c'
        },{
            "name": "CIS_ID__r.Primary_Segment_Code__c",
            "mapping": 'CIS_ID__r.Primary_Segment_Code__c'
        },{
            "name": "CIS_ID__r.Group__c",
            "mapping": 'CIS_ID__r.Group__c'
        },{
            "name": "CIS_ID__r.Sub_Group__c",
            "mapping": 'CIS_ID__r.Sub_Group__c'
        },{
            "name": "CIS_ID__r.Owner.Name",
            "mapping": 'CIS_ID__r.Owner.Name'
        },{
            "name": "CIS_ID__r.Current_Team_Name__r.Name",
            "mapping": 'CIS_ID__r.Current_Team_Name__r.Name'
        },{
            "name": "CIS_ID__r.Status__c",
            "mapping": 'CIS_ID__r.Status__c'
        },{
            "name": "CIS_ID__r.Income_to_Bank_This_Year__c",
            "mapping": 'CIS_ID__r.Income_to_Bank_This_Year__c'
        },{
            "name": "AssignmentOwner__r.Name",
            "mapping": 'AssignmentOwner__r.Name'
        },{
            "name": "AssignmentOwner__r.Team_Name__c",
            "mapping": 'AssignmentOwner__r.Team_Name__c'
        },{
            "name": "Owner.IsActive",
            "mapping": 'Owner.IsActive'
        },{
            "name": "Owner.Profile.Name",
            "mapping": 'Owner.Profile.Name'
        },
        {
            "name": "Name__r.Name",
            "mapping": 'Name__r.Name'
        },{
            "name": "Team_Target__r.Team_Name__r.RC_Code__c",
            "mapping": 'Team_Target__r.Team_Name__r.RC_Code__c'
        },{
            "name": "Team_Target__r.Transaction_Fee_Team_Target__c",
            "mapping": 'Team_Target__r.Transaction_Fee_Team_Target__c'
        },{
            "name": "Sales_Name__r.Name__r.Name",
            "mapping": 'Sales_Name__r.Name__r.Name'
        },{
            "name": "Sales_Name__r.Transaction_Fee_Target__c",
            "mapping": 'Sales_Name__r.Transaction_Fee_Target__c'
        },{
            "name": "Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c",
            "mapping": 'Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c'
        },{
            "name": "Sales_Name__r.Team_Target__r.Transaction_Fee_Team_Target__c",
            "mapping": 'Sales_Name__r.Team_Target__r.Transaction_Fee_Team_Target__c'
        },{
            "name": "Sales_Name__r.Main_Operating_Bank_Target__c",
            "mapping": 'Sales_Name__r.Main_Operating_Bank_Target__c'
        },{
            "name": "Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c",
            "mapping": 'Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c'
        },{
            "name": "Sales_Name__r.Team_Target__r.Main_Operating_Bank_Team_Target__c",
            "mapping": 'Sales_Name__r.Team_Target__r.Main_Operating_Bank_Team_Target__c'
        },{
            "name": "Sales_Name__r.Deal_Base_Fee_Target__c",
            "mapping": 'Sales_Name__r.Deal_Base_Fee_Target__c'
        },{
            "name": "Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c",
            "mapping": 'Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c'
        },{
            "name": "Sales_Name__r.Team_Target__r.Deal_Base_Fee_Team_Target__c",
            "mapping": 'Sales_Name__r.Team_Target__r.Deal_Base_Fee_Team_Target__c'
        },{
            "name": "Bulk_Assignment_Queue__r.OwnerId",
            "mapping": 'Bulk_Assignment_Queue__r.OwnerId'
        },{
            "name": "Bulk_Assignments_Sales_target__r.Transaction_Fee_New_Target__c",
            "mapping": 'Bulk_Assignments_Sales_target__r.Transaction_Fee_New_Target__c'
        },{
            "name": "Bulk_Assignments_Sales_target__r.Main_Operating_Bank_New_Target__c",
            "mapping": 'Bulk_Assignments_Sales_target__r.Main_Operating_Bank_New_Target__c'
        },{
            "name": "Bulk_Assignments_Sales_target__r.Deal_Base_Fee_New_Target__c",
            "mapping": 'Bulk_Assignments_Sales_target__r.Deal_Base_Fee_New_Target__c'
        }
    ];


    var reAssignPermanenceColumn = mappingColumn(config.reAssignPermanenceForMap,["CIS__c","CBS_Account_Name","Primary_Segment_Code__c","CBS_Account_Group","CBS_Account_Sub_Group","CBS_Account_Current_Owner","CBS_Account_Current_Team_Name","CBS_Account_Status__c","CBS_Account_Income_To_Bank_This_Year__c"]);
    var reAssignPermanenceModelName = Ext.String.capitalize("AccountPermanence");

    var approvalProcessBulkAssignColumn = mappingColumn(config.approvalProcessBulkAssignMapForCBS,["Bulk_Queue_Name__c","Bulk_Account_Submit_Date__c","Status__c","Bulk_Account_CIS__c","Bulk_Account_Name_Report__c","Bulk_Queue_Request_Reason_Picklist__c","Bulk_Queue_Request_Reason_Text__c","Rejected_Reason__c","Rejected_Reason_Text__c","Bulk_Account_Primary_Segment_Code__c","Bulk_Account_Group__c","Bulk_Account_Sub_Group__c","Bulk_Account_Owner_Name__c","Bulk_Account_Owner_Team_Name__c","Bulk_Account_AssignTo_Owner_Name__c","Bulk_Account_AssignTo_Team_Name__c","Bulk_Account_Status__c","Bulk_Account_Income_To_Bank_This_Year__c"]);
    var approvalProcessBulkAssignModelName = Ext.String.capitalize("ApprovalRequestsBulkAssign");

    var bulkSalesTargetColumn = mappingColumn(config.salesTargetMapForCBS,["Bulk_Sales_Target_Name__c","Bulk_Sales_Total_Miracle_Income__c","Bulk_Sales_Transaction_Fee__c","Bulk_Sales_Main_Operating_Bank__c","Bulk_Sales_Deal_Base_Fee__c"]);
    var bulkSalesTargetModelName = Ext.String.capitalize("BulkSalesTarget");
    
    var user_rc_code = config.user_rc_code;

    /////////////////////////////////////////////////////////////////////////////////////////////
    // Create Model
    createModel(reAssignPermanenceModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignPermanencefieldlistForCBS.join(',')
        }
    );

    createModel(approvalProcessBulkAssignModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Bulk_Assignment__c',
            fields: config.approvalProcessBulkAssignfieldlistForCBS.join(',')
        }
    );

    createModel(bulkSalesTargetModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Bulk_Assignment_Sale_Target__c',
            fields: config.bulkSalesTargetfieldlistForCBS.join(',')
        }
    );
    /////////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////
    // Create Store Model
    var reAssignPermanenceStore = createStoreModel(reAssignPermanenceModelName, config.pagesize, {
        filters: [{
            property: 'Primary_Segment_Code__c',
            operator: 'IN ',
            value:'[CB, MB]'
        },{
            property: 'Owner.IsActive',
            value: true
        }],
        sorters:[{
            property: 'CIS__c',
            direction: 'ASC'
        }]
    });

    var approvalProcessBulkAssignStore = createStoreModel(approvalProcessBulkAssignModelName, config.pagesize, {
        filters: [{
            property: 'BulkAssignmentQueue__r.CBS_Admin_To_Approve__c',
            value: 'true'
        },{
            property: 'Status__c',
            value: '#Waiting For Approval'
        },{
            property: 'BulkAssignmentQueue__r.Request_Reason_Picklist__c',
            value: '#โยกย้าย-ลาออก'
        }],
        sorters:[{
            property: 'BulkAssignmentQueue__r.Name',
            direction: 'ASC'
        },{
            property: 'CIS_ID__r.CIS__c',
            direction: 'ASC'
        }]
    });

    var bulkSalesTargetStore = createStoreModel(bulkSalesTargetModelName, config.pagesize, {
        filters: [{
            property: 'Processed__c',
            value: false
        }],
        sorters:[{
            property: 'Id',
            direction: 'ASC'
        }]
    });
    
    //////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////
    var reAssignPermanenceCheckbox = function(record) {
        return (record.Bulk_Assignments__r == null)||(record.Bulk_Assignments__r[0].Status__c == "Complete")||(record.Bulk_Assignments__r[0].Status__c == "Rejected")||(record.Bulk_Assignments__r[0].Status__c == "Recalled")||(record.Bulk_Assignments__r[0].Status__c == "Approved");//(!record.Owner.RC_Code__c || record.Owner.RC_Code__c == null || typeof record.Owner.RC_Code__c === "undefined") && (!record.Owner.AH_RC_Code__c || record.Owner.AH_RC_Code__c == null || typeof record.Owner.AH_RC_Code__c === "undefined") && (!record.Owner.NH_RC_Code__c || record.Owner.NH_RC_Code__c == null || typeof record.Owner.NH_RC_Code__c === "undefined");
    };

    var reAssignApprovalBulkAssignCheckbox = function(record) {
        return (record.Status__c == 'Waiting for Approval');
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////

    var viewTMLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByTeamName,{extra:'All'},true);
    viewTMLevel.load();

    var viewUserLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam,{extra:'All',isActive:true},true);
    viewUserLevel.load();

    var popupTMLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByTeamName,{},true);
    var popupUserLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam,{},true);

    var requestReasonFilter = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPickListOfObj,{sobjname: 'Bulk_Assignment_Queue__c',field: 'Request_Reason_Picklist__c'},true);
    requestReasonFilter.load();
    
    var rejectReasonPicklist = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPickListOfObj,{sobjname: 'Bulk_Assignment__c',field: 'Rejected_Reason__c'},true);
    rejectReasonPicklist.load();

    var accountBottomUpSumStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryAccountBottomUpSum,{});
    //////////////////////////////////////////////////////////////////////////////////////////////////

    //Pan Rein
    var customerSelectedByTeamCombobox = createComboxbox(config.map_label.BulkAssign_Team_Level_Name,
     'customerTeamSelectedFilter', false, viewTMLevel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        mode: 'remote',
        value: viewTMLevel.data.items,
        listeners: {
            load: function(a,b,c) {},
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                grid.store.removeFilter("Current_Team_Name__r.RC_Code__c");
                grid.store.removeFilter("Current_Team_Name__c");
                grid.store.removeFilter("Owner.Profile.Name");
                grid.store.removeFilter("Owner.IsActive");
                grid.store.removeFilter("OwnerId");
                
                if (selected.data.pvalue == '') {

                    selectedTeamRCCode = '';
                    grid.store.removeFilter("Current_Team_Name__c");

                    activeInactiveFilterComboxbox.setValue(activeInactiveFilterComboxbox.store.data.items[0]);
                    activeInactiveFilterComboxbox.disable();

                    selectByRefComboboxTwo.setValue(selectByRefComboboxTwo.store.data.items[0]);
                    selectByRefComboboxTwo.disable();
                    
                    viewTMLevel.reload();

                }else {
                    
                    selectedTeamId = selected.data.pvalue;
                    selectedTeamRCCode = selected.data.pkey;

                    if(selectedTeamId != 'CBS-Admin'){
                        delete viewUserLevel.proxy.extraParams.scope;
                        viewUserLevel.proxy.extraParams.scope = selectedTeamRCCode;
                        viewUserLevel.proxy.extraParams.isActive = true;
                        viewUserLevel.reload();

                        grid.store.filter("Current_Team_Name__c", '#'+selected.data.pvalue);
                        grid.store.filter("Owner.IsActive", true);

                        // activeInactiveFilterComboxbox.clearValue();
                        activeInactiveFilterComboxbox.setValue(activeInactiveFilterComboxbox.store.data.items[0]);
                        activeInactiveFilterComboxbox.enable();

                        // selectByRefComboboxTwo.clearValue();
                        selectByRefComboboxTwo.setValue(selectByRefComboboxTwo.store.data.items[0]);
                        selectByRefComboboxTwo.enable();
                    }else{
                        
                        grid.store.filter("Owner.Profile.Name", '#'+selected.data.pvalue);

                        activeInactiveFilterComboxbox.clearValue();
                        activeInactiveFilterComboxbox.disable();

                        selectByRefComboboxTwo.clearValue();
                        selectByRefComboboxTwo.disable();
                    }
                    
                }
                
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });
    //Pan Rein
    

    var activeInactiveFilterStore = createStaticStore(['id', 'value', 'key'],[
            {"id":"Active", "value":"Active", "key":true},
            {"id":"Inactive", "value":"Inactive", "key":false}
        ]);
    
    var activeInactiveFilterComboxbox = createStaticComboxbox(config.map_label.BulkAssign_User_Status,'userLevelFilter',activeInactiveFilterStore,'local','value','id',{
        labelWidth: 90,
        emptyText: 'Active',
        listeners: {
            select: function(combox,selected,index){
                var grid = this.up('grid');

                selectedUserStatus = selected.get('key');

                grid.store.removeFilter('OwnerId');
                selectByRefComboboxTwo.setValue(selectByRefComboboxTwo.store.data.items[0]);
                delete viewUserLevel.proxy.extraParams.isActive;
                viewUserLevel.proxy.extraParams.isActive = selectedUserStatus;
                viewUserLevel.reload();

                grid.store.filter('Owner.IsActive',selectedUserStatus);
            },
            afterrender: function(combox){
                var record = combox.store.getAt(0);
                combox.setValue(record.id);
            }
        }
    });
    activeInactiveFilterComboxbox.disable();

    // Header Filter User
    var selectByRefComboboxTwo = createComboxbox(config.map_label.BulkAssign_User_Level_Name, 'filterByUserId', false, viewUserLevel, config.map_label.BulkAssign_User_Level_Name, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                
                var grid = this.up('grid');
                if (selected.get('pvalue') && selected.get('pvalue') != '') {
                    selectedUserId = selected.get('pvalue');

                    grid.store.filter("OwnerId",'#'+selectedUserId);
                    
                } else {
                    grid.store.removeFilter("OwnerId");
                }
            },
            afterrender: function(combox){
                combox.setValue(viewUserLevel.data.items[0]);
            }
        }
    });
    selectByRefComboboxTwo.disable();

    // Header Approval Filter By Request Reason

    var requestReasonApprovalFilterComboxbox = createComboxbox(config.map_label.BulkAssign_Request_Reason,'requestReasonFilter',false,requestReasonFilter,'Request Reason','pname','pvalue',false,true,{
        labelWidth: 90,
        emptyText: 'โยกย้าย-ลาออก',
        listeners: {
            select: function(combox,selected,index){
                var grid = this.up('grid');
                selectedReasonFilter = selected.get('pvalue');
                grid.store.filter('BulkAssignmentQueue__r.Request_Reason_Picklist__c','#'+selectedReasonFilter);

            },
            afterrender: function(combox){
                combox.setValue(requestReasonFilter.data.items[0]);
            }
        }
    });

    var approvalStatus = createStaticStore(['id', 'value'],[
            {"id":"Waiting for Approval", "value":"Waiting for Approval"},
            {"id":"Approved", "value":"Approved"},
            {"id":"Rejected", "value":"Rejected"},
            {"id":"Recalled", "value":"Recalled"},
            {"id":"All", "value":"All"}
        ]);

    var approvalComboxbox = createStaticComboxbox(config.map_label.BulkAssign_Approval_Status,'approvalStatusFilter',approvalStatus,'local','value','id',{
        labelWidth: 90,
        emptyText: 'Waiting for Approval',
        listeners: {
            select: function(combox,selected,index){
                var grid = this.up('grid');
                selectedApprovalStatus = selected.get('value');
                if(selectedApprovalStatus != 'All'){
                    grid.store.filter('Status__c','#'+selectedApprovalStatus);
                }else{
                    grid.store.removeFilter('Status__c');
                }
                
            },
            afterrender: function(combox){
                var record = combox.store.getAt(0);
                
                combox.setValue(record.id);
            }
        }
    });

    
    ///////////////////////////////////////////

    /*
    Popup Permanent Tab
    */
    

    // Popup Team
    var selectByRefTeamPanelComboboxTwo = createComboxbox(config.map_label.BulkAssign_Team_Level_Name, 'selectedByTeamRCCode', false, popupTMLevel, config.map_label.BulkAssign_Team_Level_Name, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                
                delete popupUserLevel.proxy.extraParams.scope;
                delete popupUserLevel.proxy.extraParams.isActive;

                selectByRefUserPanelComboboxTwo.clearValue();
                selectByRefUserPanelComboboxTwo.enable();
                selectedTeamIdPopup = selected.get('pkey');

                console.log(selected.get('pvalue'));
                console.log(selected.get('pname'));
                console.log(selected.get('pkey'));
        
                popupUserLevel.proxy.extraParams.scope = selectedTeamIdPopup;
                popupUserLevel.proxy.extraParams.isActive = true;
                popupUserLevel.reload();
            }
        }
    });
    selectByRefTeamPanelComboboxTwo.disable();

    // Popup User
    var selectByRefUserPanelComboboxTwo = createComboxbox(config.map_label.BulkAssign_User_Level_Name, 'selectedByUserId', false, popupUserLevel, config.map_label.BulkAssign_User_Level_Name, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                selectedUserIdPopup = selected.get('pvalue');
                
            }
        }
    });
    selectByRefUserPanelComboboxTwo.disable();

    // Popup reject
    var rejectReasonCombobox = createComboxbox(config.map_label.BulkAssign_Reject_Reason, 'rejectReason', false, rejectReasonPicklist, 'Reject Reason', 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                // if(selected.get('pvalue') != 'อื่นๆ(โปรดระบุ)'){
                //     rejectReasonText.disable();
                //     rejectReasonText.hide();
                // }else{
                //     rejectReasonText.enable();
                //     rejectReasonText.show();
                // }
            }
        }
    });

    function hideClearAll(){
        var dom = Ext.dom.Query.select('.ClearAll');
        var el;
        for(var i=0; i<dom.length; i++){
            el = Ext.get(dom[i]);
            el.hide(); 
        }
    }
   
    function reloadAllStore(){
        reAssignPermanenceStore.reload();
        approvalProcessBulkAssignStore.reload();
        bulkSalesTargetStore.reload();
    };


    var selectconfirm_popup = createPanel({
        id: 'selectedPanel',
        title: 'Assign To',
        draggable: true,
        resizable: true,
        items: [selectByRefTeamPanelComboboxTwo,selectByRefUserPanelComboboxTwo],
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

                            
                            if (final_selections.length > 0 && form.getFieldValues().selectedByUserId != null) {
                                grid.setLoading(true);
                                selectconfirm_popup.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignPermanenceGrid',
                                        fromCBS: true
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
                            } else Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_No_User_Assignment);
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

    var selectconfirm_popupApprovalApprove = createPanel({
        id: 'selectConfirmApprovalApprove',
        draggable: true,
        resizable: true,
        title: config.map_label.BulkAssignApproval_Confirmation_Display,
        layout:{
            type:'vbox',
            align:'center'
        },
        items: [{
                xtype: 'displayfield',
                value: config.map_label.BulkAssign_Approval_Confirmation
            }
        ],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [{
                xtype: 'tbspacer'
            },{
                text: config.map_label.BulkAssign_Confirm,
                handler: function(){
                    var panel = this.up('form');
                    var form = panel.getForm();
                    if(form.isValid()){
                        var grid = Ext.getCmp('approvalProcessBulkAssignGrid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignApprovalBulkAssignCheckbox(record.data);
                        });

                        if(final_selections.length > 0){
                            grid.setLoading(true);
                            selectconfirm_popupApprovalApprove.hide();
                            Ext.Deferred
                                .all([sendRequest('handleBulkApproval', {
                                        contx: 'APPROVE',
                                        approvalIdList: _.pluck(final_selections, 'id'),
                                        gridName: 'approvalProcessBulkAssignGrid'
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
                        }
                    }

                    
                }
            },{
                xtype: 'tbspacer'
            }]
        }]
    });

    var rejectReasonText = new Ext.form.field.TextArea({
        fieldLabel: config.map_label.BulkAssign_Reject_Reason_Text,
        id: 'rejectReasonText',
        name: 'rejectReasonText',
        allowBlank:true,
        labelWidth: 90,
        labelStyle: 'width:120px'
    });
    rejectReasonText.enable();
    rejectReasonText.show();

    var selectconfirm_popupApprovalReject = createPanel({
        id: 'selectConfirmApprovalReject',
        draggable: true,
        resizable: true,
        title: config.map_label.BulkAssign_Reject_Confirmation,
        layout:{
            type:'vbox',
            align:'center'
        },
        items: [
            rejectReasonCombobox,rejectReasonText
        ],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [{
                xtype: 'tbspacer'
            },{
                text: config.map_label.BulkAssign_Confirm,
                handler: function(){
                    var panel = this.up('form');
                    var form = panel.getForm();
                    
                    if(form.isValid()){
                        var grid = Ext.getCmp('approvalProcessBulkAssignGrid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignApprovalBulkAssignCheckbox(record.data);
                        });

                        if(final_selections.length > 0){
                            grid.setLoading(true);
                            selectconfirm_popupApprovalReject.hide();

                            Ext.Deferred
                                .all([sendRequest('handleBulkApproval', {
                                        contx: 'REJECT',
                                        selectName: form.getFieldValues(),
                                        approvalIdList: _.pluck(final_selections, 'id'),
                                        gridName: 'approvalProcessBulkAssignGrid'
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
                        }
                    }

                    
                }
            },{
                xtype: 'tbspacer'
            }]
        }]
    });

    var accountBottomUpSumGridBulkSales = new Ext.grid.GridPanel({
        xtype: 'yearendgrid',
        id: 'accountBottomUpSumGridBulkSales',
        store: accountBottomUpSumStore,
        columns: accountBottomUpSumColumn,
        title: 'Bottom Up from Selected Customers',
        width: 950,
        forceFit: true,
        scrollOffset: 0
    });

    var bulkSalesTargetGrid = new Ext.grid.GridPanel({
        id: 'bulkSalesTargetGrid',
        store: bulkSalesTargetStore,
        columns: bulkSalesTargetColumn,
        header: false,
        features: [{
            ftype: 'summary'
        }]
    });
    

    var showBulkSalesPanel = createPanel({
        id: 'showBulkSalesPanel',
        title: config.map_label.Bulk_Assign_Bulk_Sales_Target,
        draggable: true,
        floating: true,
        resizable: true,
        header: true,
        width: 1100,
        items: [accountBottomUpSumGridBulkSales,bulkSalesTargetGrid],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom'
        },{
            xtype: 'toolbar',
            dock: 'top'
        }],
        listeners:{
            'afterrender': function(panel){
                var screenWidth = Ext.getBody().getViewSize().width;
                var screenHeight = Ext.getBody().getViewSize().height;
                panel.setPosition((screenWidth-panel.width)/2,screenHeight/3);
            }
        }
    });



    config.panel_items = [
        createGridObject(config.map_label.BulkAssign_Port, 'reAssignPermanenceGrid', reAssignPermanenceStore, reAssignPermanenceColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function() {
                        
                        delete popupTMLevel.proxy.extraParams.scope;

                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignPermanenceCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            popupTMLevel.clearFilter();
                            popupTMLevel.reload();

                            selectByRefTeamPanelComboboxTwo.clearValue();
                            selectByRefTeamPanelComboboxTwo.store.reload();

                            selectByRefUserPanelComboboxTwo.clearValue();
                            selectByRefUserPanelComboboxTwo.store.reload();

                            selectByRefTeamPanelComboboxTwo.enable();
                            
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
                    customerSelectedByTeamCombobox
                    ,
                    {
                        xtype: 'tbspacer'
                    }
                    ,
                    activeInactiveFilterComboxbox,
                    {
                        xtype: 'tbspacer'
                    },
                    selectByRefComboboxTwo,
                    {
                        xtype: 'tbspacer'
                    }
                ]
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignPermanenceStore.sync();
                    reAssignPermanenceStore.reload();

                    hideClearAll();
                },
                'headerclick': function(g, index, ev) {
                    
                }
            }
            ,
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
        })
        ,
        createGridObject(config.map_label.BulkAssign_To_Approve, 'approvalProcessBulkAssignGrid', approvalProcessBulkAssignStore, approvalProcessBulkAssignColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Approve,
                    handler: function(){
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignApprovalBulkAssignCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            
                            selectconfirm_popupApprovalApprove.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }, {
                    xtype: 'tbspacer'
                },{
                    text: config.map_label.BulkAssign_Reject,
                    handler: function(){
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignApprovalBulkAssignCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            rejectReasonCombobox.clearValue();
                            rejectReasonCombobox.store.reload();

                            rejectReasonText.reset();
                            

                            
                            selectconfirm_popupApprovalReject.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }]
            },{
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    xtype: 'tbspacer'
                },
                    requestReasonApprovalFilterComboxbox
                ,
                {
                    xtype: 'tbspacer'
                }
                ,
                    approvalComboxbox
                ]
            }],
            listeners:{
                'afterrender': function(grid) {

                    approvalProcessBulkAssignStore.sync();
                    approvalProcessBulkAssignStore.reload();

                    hideClearAll();
                },
                'headerclick': function(g, index, ev) {
                    
                },
                'cellclick': function(view, cell, cellIndex, record,row, rowIndex, e) {
                    var clickedColumnName = view.panel.headerCt.getHeaderAtIndex(cellIndex).text;
                    
                    if(clickedColumnName == 'Bulk Assignment Queue Name' && record.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c != 'อื่นๆ (โปรดระบุ)'){
                        accountBottomUpSumStore.proxy.extraParams.bulkQueueId = record.data.BulkAssignmentQueue__c;
                        accountBottomUpSumStore.reload();
                        bulkSalesTargetGrid.store.filter('Bulk_Assignment_Queue__c','#'+record.data.BulkAssignmentQueue__c);
                        bulkSalesTargetGrid.store.load();
                        showBulkSalesPanel.show();

                    }
                    
                    
                },
                select: function(selModel,recordSelect){
                    if(recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c == 'โยกย้าย-ลาออก' || recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c == 'โยกย้าย-เข้าใหม่'){
                        var grid = this;
                        grid.store.each(function(record){
                            if(record.data.BulkAssignmentQueue__c == recordSelect.data.BulkAssignmentQueue__c){
                                grid.getSelectionModel().select(record,true,true);
                            }
                            
                        });
                    }
                    
                },
                deselect: function(model, recordSelect, index) {
                    if(recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c == 'โยกย้าย-ลาออก' || recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c == 'โยกย้าย-เข้าใหม่'){
                        var grid = this;
                        grid.store.each(function(record){
                            if(record.data.BulkAssignmentQueue__c == recordSelect.data.BulkAssignmentQueue__c){
                                grid.getSelectionModel().deselect(record,true,true);
                            }
                        });
                    }
                }
            }
            ,
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignApprovalBulkAssignCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            }),
            plugins: {
                ptype: 'cellediting',
                clicksToEdit: 1,
                editing:true
            }
        })
    ];
};
