function init(config) {

    var selectedUserStatus = '';
    var selectedUserId = '';

    var selectedUserIdPopup = '';
    var selectedRequestReasonPopup = '';

    var selectedApprovalStatus = '';
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

    var reAssignCBSAdminColumn = mappingColumn(config.reAssignPermanenceForMap,["CIS__c","CBS_Account_Name","Primary_Segment_Code__c","CBS_Account_Group","CBS_Account_Sub_Group","CBS_Account_Current_Owner","CBS_Account_Current_Team_Name","CBS_Account_Status__c","CBS_Account_Income_To_Bank_This_Year__c"]);
    var reAssignCBSAdminModelName = Ext.String.capitalize("AccountCBSAdmin");

    var approvalProcessBulkAssignColumn = mappingColumn(config.approvalProcessBulkAssignMapForCBS,["Bulk_Queue_Name__c","Bulk_Account_Submit_Date__c","Status__c","Bulk_Account_CIS__c","Bulk_Account_Name_Report__c","Bulk_Queue_Request_Reason_Picklist__c","Bulk_Queue_Request_Reason_Text__c","Rejected_Reason__c","Rejected_Reason_Text__c","Bulk_Account_Primary_Segment_Code__c","Bulk_Account_Group__c","Bulk_Account_Sub_Group__c","Bulk_Account_Owner_Name__c","Bulk_Account_Owner_Team_Name__c","Bulk_Account_AssignTo_Owner_Name__c","Bulk_Account_AssignTo_Team_Name__c","Bulk_Account_Status__c","Bulk_Account_Income_To_Bank_This_Year__c"]);
    var approvalProcessBulkAssignModelName = Ext.String.capitalize("ApprovalRequestsBulkAssign");

    var salesTargetColumn = mappingColumn(config.salesTargetMapForCBS,["Sales_Target_Name__c","Total_Miracle_Income__c","Transaction_Fee__c","Main_Operating_Bank__c","Deal_Base_Fee__c"]);
    var salesTargetModelName = Ext.String.capitalize("SalesTarget");

    var bulkSalesTargetColumn = mappingColumn(config.salesTargetMapForCBS,["Bulk_Sales_Target_Name__c","Bulk_Sales_Total_Miracle_Income__c","Bulk_Sales_Transaction_Fee__c","Bulk_Sales_Main_Operating_Bank__c","Bulk_Sales_Deal_Base_Fee__c"]);
    var bulkSalesTargetModelName = Ext.String.capitalize("BulkSalesTarget");
    
    var user_rc_code;
    
    if(config.rc_codes != null){

        user_rc_code = config.rc_codes.replace('[','').replace(']','');
    }else{
        user_rc_code = config.user_rc_code;
    }
    
    

    /////////////////////////////////////////////////////////////////////////////////////////////
    // Create Model

    createModel(reAssignPermanenceModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Account',
            fields: config.reAssignPermanencefieldlistForCBS.join(',')
        }
    );

    createModel(reAssignCBSAdminModelName, 'records', 'Id',
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

    createModel(salesTargetModelName, 'records', 'Id',
        customerRequestModelColumn, RemoterExtensions.query, {
            sobjname: 'Sales_Target__c',
            fields: config.salesTargetfieldlistForCBS.join(',')
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
            property: 'Current_Team_Name__r.RC_Code__c',
            value: '#'+user_rc_code
        },{
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

    var reAssignCBSAdminStore = createStoreModel(reAssignCBSAdminModelName, config.pagesize, {
        filters: [{
            property: 'Owner.Profile.Name',
            value:'#CBS-Admin'
        },{
            property: 'Primary_Segment_Code__c',
            operator: 'IN ',
            value:'[CB, MB]'
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
            property: 'BulkAssignmentQueue__r.OwnerId',
            value: '#'+config.user_id
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

    var salesTargetStore = createStoreModel(salesTargetModelName, config.pagesize, {
        filters: [{
            property: 'Team_Target__r.Team_Name__r.RC_Code__c',
            value: '#'+user_rc_code
        },{
            property: 'Is_Active__c',
            value: true
        },{
            property: 'Year__c',
            value: '#'+config.year
        }],
        sorters:[{
            property: 'Id',
            direction: 'ASC'
        }]
    });
    

    var bulkSalesTargetStore = createStoreModel(bulkSalesTargetModelName, config.pagesize, {
        filters: [{
            property: 'Bulk_Assignment_Queue__r.OwnerId',
            value: '#'+config.user_id
        }],
        sorters:[{
            property: 'Id',
            direction: 'ASC'
        }]
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // To open check box or not
    var reAssignPermanenceCheckbox = function(record) {
        return (record.Bulk_Assignments__r == null)||(record.Bulk_Assignments__r[0].Status__c == "Complete")||(record.Bulk_Assignments__r[0].Status__c == "Rejected")||(record.Bulk_Assignments__r[0].Status__c == "Recalled")||(record.Bulk_Assignments__r[0].Status__c == "Approved");//(!record.Owner.RC_Code__c || record.Owner.RC_Code__c == null || typeof record.Owner.RC_Code__c === "undefined") && (!record.Owner.AH_RC_Code__c || record.Owner.AH_RC_Code__c == null || typeof record.Owner.AH_RC_Code__c === "undefined") && (!record.Owner.NH_RC_Code__c || record.Owner.NH_RC_Code__c == null || typeof record.Owner.NH_RC_Code__c === "undefined");
    };

    var reAssignCBSAdminCheckbox = function(record) {
        return (record.Bulk_Assignments__r == null)||(record.Bulk_Assignments__r[0].Status__c == "Complete")||(record.Bulk_Assignments__r[0].Status__c == "Rejected")||(record.Bulk_Assignments__r[0].Status__c == "Recalled")||(record.Bulk_Assignments__r[0].Status__c == "Approved");//(!record.Owner.RC_Code__c || record.Owner.RC_Code__c == null || typeof record.Owner.RC_Code__c === "undefined") && (!record.Owner.AH_RC_Code__c || record.Owner.AH_RC_Code__c == null || typeof record.Owner.AH_RC_Code__c === "undefined") && (!record.Owner.NH_RC_Code__c || record.Owner.NH_RC_Code__c == null || typeof record.Owner.NH_RC_Code__c === "undefined");
    };

    var reAssignApprovalBulkAssignCheckbox = function(record) {
        return (record.Status__c == 'Waiting for Approval');
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////

    var viewUserLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam,{extra:'All',scope:user_rc_code,isActive:true},true);
    viewUserLevel.load();

    var popupUserLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam,{scope:user_rc_code,isActive:true},true);
    var popupRequestReasonLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPickListOfObj,{sobjname: 'Bulk_Assignment_Queue__c',field: 'Request_Reason_Picklist__c'},true);
    
    var popupUserCBSAdminLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.querySelectedByUserByTeam,{scope:user_rc_code,isActive:true},true);
    var popupRequestReasonCBSAdminLevel = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPickListOfObj,{sobjname: 'Bulk_Assignment_Queue__c',field: 'Request_Reason_Picklist__c'},true);;
    popupRequestReasonCBSAdminLevel.load();

    var requestReasonFilter = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryPickListOfObj,{sobjname: 'Bulk_Assignment_Queue__c',field: 'Request_Reason_Picklist__c'},true);
    requestReasonFilter.load();

    var accountBottomUpSumStore = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryAccountBottomUpSum,{});
    var accountBottomUpSumStoreCBS = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryAccountBottomUpSum,{});
    var accountBottomUpSumStoreBulkSales = createStorePicklistModel(SME_BulkAssignment_ListView_Controller.queryAccountBottomUpSum,{});
    
    
    // Header Active/Inactive

    var activeInactiveFilterStore = createStaticStore(['id', 'value', 'key'],[
            {"id":"Active", "value":"Active", "key":true},
            {"id":"Inactive", "value":"Inactive", "key":false}
        ]);
    
    var requestReasonCBSAdminStore = createStaticStore(['pname','pvalue'],[
            {"pname":"อื่นๆ (โปรดระบุ)","pvalue":"อื่นๆ (โปรดระบุ)"}
        ]);

    var activeInactiveFilterComboxbox = createStaticComboxbox(config.map_label.BulkAssign_User_Status,'userStatusFilter',activeInactiveFilterStore,'local','value','id',{
        labelWidth: 90,
        emptyText: 'Active',
        listeners: {
            select: function(combox,selected,index){
                var grid = this.up('grid');
                selectedUserStatus = selected.get('key');
                delete viewUserLevel.proxy.extraParams.isActive;
                viewUserLevel.proxy.extraParams.isActive = selectedUserStatus;
                viewUserLevel.reload();
                customerSelectedByUserCombobox.setValue('');
                grid.store.removeFilter("OwnerId");
                grid.store.filter('Owner.IsActive',selectedUserStatus);
            },
            afterrender: function(combox){
                var record = combox.store.getAt(0);
                combox.setValue(record.id);
            }
        }
    });

    var customerSelectedByUserCombobox = createComboxbox(config.map_label.BulkAssign_User_Level_Name, 'customerUserSelectedFilter', false, viewUserLevel, config.map_label.BulkAssign_ShowAll, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        mode: 'remote',
        value: config.map_label.BulkAssign_ShowAll,
        listeners: {
            load: function(a,b,c) {
            },
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                var selectedUserId = selected.get("pvalue");
                if (selected.data.pvalue == '') {
                    grid.store.removeFilter("OwnerId");

                }else {
                    grid.store.filter("OwnerId","#"+selectedUserId);
                }
                
                grid.getView().getSelectionModel().deselectAll();
            }
        }
    });

    // Popup User
    var selectByRefUserPanelComboboxTwo = createComboxbox(config.map_label.BulkAssign_User_Level_Name, 'selectedByUserId', false, popupUserLevel, config.map_label.BulkAssign_User_Level_Name, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                selectedUserIdPopup = selected.get('pvalue');
                
            }
        }
    });

    

    var requestReasonPopupFilterComboxbox = createComboxbox(config.map_label.BulkAssign_Request_Reason,'requestReason',false,popupRequestReasonLevel,'Request Reason','pname','pvalue',false,true,{
        labelWidth: 90,
        listeners: {
            select: function(combox,selected,index){
                var panel = this.up('panel');


                var salesTargetGrid = Ext.getCmp('salesTargetGrid');
                

                selectedRequestReasonPopup = selected.get('pvalue');
                if(selectedRequestReasonPopup == 'อื่นๆ (โปรดระบุ)'){
                    requestReasonText.enable();
                    requestReasonText.show();
                    
                    setPanelSizeAndPosition(panel,350);

                    accountBottomUpSumGrid.disable();
                    accountBottomUpSumGrid.hide();

                    salesTargetGrid.store.reload();
                    salesTargetGrid.disable();
                    salesTargetGrid.hide();
                }else{
                    setPanelSizeAndPosition(panel,1300);

                    accountBottomUpSumGrid.enable();
                    accountBottomUpSumGrid.show();
                    
                    salesTargetGrid.enable();
                    salesTargetGrid.show();

                    requestReasonText.reset();
                    requestReasonText.disable();
                    requestReasonText.hide();
                }
            }
        }
    });

    //////////////////////////////


    /*
    Popup CBS Admin Tab
    */

    // Popup User CBS Admin
    var selectByRefUserPanelComboboxTwoCBSAdmin = createComboxbox(config.map_label.BulkAssign_User_Level_Name, 'selectedByUserId', false, popupUserCBSAdminLevel, config.map_label.BulkAssign_User_Level_Name, 'pname', 'pvalue', false, true, {
        labelWidth: 90,
        listeners: {
            select: function(combox, selected, index) {
                selectedUserIdPopup = selected.get('pvalue');
                
            }
        }
    });

    var requestReasonPopupFilterCBSAdminComboxbox = createComboxbox(config.map_label.BulkAssign_Request_Reason,'requestReason',false,requestReasonCBSAdminStore,'Request Reason','pname','pvalue',false,true,{
        labelWidth: 90,
        listeners: {
            select: function(combox,selected,index){
                // var panel = this.up('panel');

                // var salesTargetGridCBS = Ext.getCmp('salesTargetGridCBS');
                // selectedRequestReasonPopup = selected.get('pvalue');
                // if(selected.get('pvalue') == 'อื่นๆ (โปรดระบุ)'){

                //     requestReasonTextCBSAdmin.enable();
                //     requestReasonTextCBSAdmin.show();

                //     setPanelSizeAndPosition(panel,350);

                //     accountBottomUpSumGridCBS.disable();
                //     accountBottomUpSumGridCBS.hide();

                //     salesTargetGridCBS.store.reload();
                //     salesTargetGridCBS.disable();
                //     salesTargetGridCBS.hide();
                // }else{
                //     setPanelSizeAndPosition(panel,1300);
                    
                //     accountBottomUpSumGridCBS.enable();
                //     accountBottomUpSumGridCBS.show();

                //     salesTargetGridCBS.enable();
                //     salesTargetGridCBS.show();

                //     requestReasonTextCBSAdmin.reset();
                //     requestReasonTextCBSAdmin.disable();
                //     requestReasonTextCBSAdmin.hide();
                // }
            },
            afterrender: function(combox){
                combox.setValue('อื่นๆ (โปรดระบุ)');
            }
        }
    });
    /////////////////////////////////////////////////////

    // Approval Requests

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
            {"id":"Recalled", "value":"Recalled"}
        ]);

    var approvalComboxbox = createStaticComboxbox(config.map_label.BulkAssign_Approval_Status,'approvalStatusFilter',approvalStatus,'local','value','id',{
        labelWidth: 90,
        emptyText: 'Waiting for Approval',
        listeners: {
            select: function(combox,selected,index){
                var grid = this.up('grid');
                selectedApprovalStatus = selected.get('value');
                grid.store.filter('Status__c','#'+selectedApprovalStatus);
            },
            afterrender: function(combox){
                var record = combox.store.getAt(0);
                
                combox.setValue(record.id);
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

    function setPanelSizeAndPosition(panel,width){
        var screenWidth = Ext.getBody().getViewSize().width;
        var screenHeight = Ext.getBody().getViewSize().height;

        panel.width = width;
        panel.setPosition((screenWidth-panel.width)/2,screenHeight/3);
    }
    
    function reloadAllStore(){
        reAssignPermanenceStore.reload();
        reAssignCBSAdminStore.reload();
        approvalProcessBulkAssignStore.reload();
        salesTargetStore.reload();
        bulkSalesTargetStore.reload();
    };

    Ext.util.Format.currencySign = ' ';
    Ext.util.Format.currencyPrecision = 0;

    function rerenderSalesTargetGrid(grid){

        
        var record = grid.store.data.items[0];

        var transactionFeeTeamTarget;
        var mainOperatingBankTeamTarget;
        var dealBaseFeeTeamTarget;
        var miracleTeamTargetSum = 0;

        var transactionFeeTeamTargetElement = document.getElementsByClassName('TransactionFeeTeamTargetElement');
        var mainOperatingBankTeamTargetElement = document.getElementsByClassName('MainOperatingBankTeamTargetElement');
        var dealBaseFeeTeamTargetElement = document.getElementsByClassName('DealBaseFeeTeamTargetElement');
        var miracleTeamTargetSumElement = document.getElementsByClassName('MiracleTeamTargetSum');

        var records = grid.store.data.items;
        
        if(record !== undefined){
            transactionFeeTeamTarget = record.data.Team_Target__r.Transaction_Fee_Team_Target__c;
            mainOperatingBankTeamTarget = record.data.Team_Target__r.Main_Operating_Bank_Team_Target__c;
            dealBaseFeeTeamTarget = record.data.Team_Target__r.Deal_Base_Fee_Team_Target__c;
        }
        
         
        if(transactionFeeTeamTarget === undefined){
            transactionFeeTeamTarget = 0;
        }

        if(mainOperatingBankTeamTarget === undefined){
            mainOperatingBankTeamTarget = 0;
        }

        if(dealBaseFeeTeamTarget === undefined){
            dealBaseFeeTeamTarget = 0;
        }

        miracleTeamTargetSum = transactionFeeTeamTarget+mainOperatingBankTeamTarget+dealBaseFeeTeamTarget;

        transactionFeeTeamTarget = Ext.util.Format.currency(transactionFeeTeamTarget);
        mainOperatingBankTeamTarget = Ext.util.Format.currency(mainOperatingBankTeamTarget);
        dealBaseFeeTeamTarget = Ext.util.Format.currency(dealBaseFeeTeamTarget);
        miracleTeamTargetSum= Ext.util.Format.currency(miracleTeamTargetSum);

        for(var i=0; i<transactionFeeTeamTargetElement.length;i++){
            transactionFeeTeamTargetElement[i].innerHTML = '<span><table class="x-grid-item"><tr><td style="border: 1px;width:240px;">Team Target</td><td style="border: 1px;width:310px;">'+transactionFeeTeamTarget+'</td></tr></table></span>';
            mainOperatingBankTeamTargetElement[i].innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+mainOperatingBankTeamTarget+'</td></tr></table>';
            dealBaseFeeTeamTargetElement[i].innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+dealBaseFeeTeamTarget+'</td></tr></table>';
            miracleTeamTargetSumElement[i].innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Miracle Team Target Sum</td><td style="border: 1px;width:310px;align:center;">'+miracleTeamTargetSum+'</td></tr></table>';
        }
        
    }



    var requestReasonText = new Ext.form.field.TextArea({
        fieldLabel: config.map_label.BulkAssign_Request_Reason_Text,
        id: 'requestReasonText',
        name: 'requestReasonText',
        allowBlank: false,
        labelWidth: 90,
        labelStyle: 'width:120px'
    });
    requestReasonText.disable();
    requestReasonText.hide();

    

    var accountBottomUpSumGrid = new Ext.grid.GridPanel({
        xtype: 'yearendgrid',
        id: 'accountBottomUpSum',
        store: accountBottomUpSumStore,
        columns: accountBottomUpSumColumn,
        title: 'Bottom Up from Selected Customers',
        forceFit: true,
        width: 950,
        scrollOffset: 0
    });
    accountBottomUpSumGrid.hide();

    
    //sales target popup in bulk assignment page
    var salesTargetGrid = new Ext.grid.GridPanel({
        xtype: 'yearendgrid',
        id: 'salesTargetGrid',
        store: salesTargetStore,
        columns: salesTargetColumn,
        title: 'Sales Target',
        plugins: {
                ptype: 'cellediting',
                clicksToEdit: 1,
                editing:true
        },
        features: [{
            ftype: 'summary'
        }],
        listeners:{
                'afterrender': function(grid) {
                    rerenderSalesTargetGrid(grid);
                },
                'cellclick': function(view, cell, cellIndex, record,row, rowIndex, e) {

                    if(record.data.Bulk_Assignments_Sales_target__r !== undefined && record.dirty == false){
                        record.data.Transaction_Fee_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                        record.data.Main_Operating_Bank_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                        record.data.Deal_Base_Fee_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                    }
                }
            }
    });
    salesTargetGrid.hide();
    

    var selectconfirm_popup = createPanel({
        id: 'selectedPanel',
        title: 'Assign To',
        draggable: true,
        resizable: true,
        items: [selectByRefUserPanelComboboxTwo,requestReasonPopupFilterComboxbox,requestReasonText,accountBottomUpSumGrid,salesTargetGrid],
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

                            var salesTargetGrid = Ext.getCmp('salesTargetGrid');
                            var itemsOfSalesTarget = salesTargetGrid.store.data.items;
                            var salesTargetList = [];


                            var transactionFeeNewTarget;
                            var mainOperatingBankNewTarget;
                            var dealBaseFeeNewTarget;

                            var sumTransactionFeeNewTarget = 0;
                            var sumMainOperatingBankNewTarget = 0;
                            var sumDealBaseFeeNewTarget = 0;

                            var salesTargetTransactionFeeTeamTarget = 0;
                            var salesTargetMainOperatingBankTeamTarget = 0;
                            var salesTargetDealBaseFeeTeamTarget = 0;

                            if(itemsOfSalesTarget[0] !== undefined){
                                salesTargetTransactionFeeTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Transaction_Fee_Team_Target__c;
                                salesTargetMainOperatingBankTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Main_Operating_Bank_Team_Target__c;
                                salesTargetDealBaseFeeTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Deal_Base_Fee_Team_Target__c;
                            }

                            if(salesTargetTransactionFeeTeamTarget === undefined || salesTargetTransactionFeeTeamTarget == null){
                                salesTargetTransactionFeeTeamTarget = 0;
                            }

                            if(salesTargetMainOperatingBankTeamTarget === undefined || salesTargetMainOperatingBankTeamTarget == null){
                                salesTargetMainOperatingBankTeamTarget = 0;
                            }

                            if(salesTargetDealBaseFeeTeamTarget === undefined || salesTargetDealBaseFeeTeamTarget == null){
                                salesTargetDealBaseFeeTeamTarget = 0;
                            }

                            if(selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                for(var i=0; i < itemsOfSalesTarget.length; i++){
                                    
                                    transactionFeeNewTarget = itemsOfSalesTarget[i].data.Transaction_Fee_New_Target__c;
                                    mainOperatingBankNewTarget = itemsOfSalesTarget[i].data.Main_Operating_Bank_New_Target__c;
                                    dealBaseFeeNewTarget = itemsOfSalesTarget[i].data.Deal_Base_Fee_New_Target__c;


                                    if(transactionFeeNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            transactionFeeNewTarget = 0;
                                        }else{
                                            transactionFeeNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                                        }
                                    }

                                    if(mainOperatingBankNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            mainOperatingBankNewTarget = 0;
                                        }else{
                                            mainOperatingBankNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                                        }
                                    }

                                    if(dealBaseFeeNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            dealBaseFeeNewTarget = 0;
                                        }else{
                                            dealBaseFeeNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                                        }
                                    }

                                    if(transactionFeeNewTarget == null){
                                        transactionFeeNewTarget = 0;
                                    }

                                    if(mainOperatingBankNewTarget == null){
                                        mainOperatingBankNewTarget = 0;
                                    }

                                    if(dealBaseFeeNewTarget == null){
                                        dealBaseFeeNewTarget = 0;
                                    }

                                    if(transactionFeeNewTarget !== undefined && transactionFeeNewTarget != null && transactionFeeNewTarget != ''){
                                        sumTransactionFeeNewTarget = sumTransactionFeeNewTarget+transactionFeeNewTarget;
                                    }

                                    if(mainOperatingBankNewTarget !== undefined && mainOperatingBankNewTarget != null && mainOperatingBankNewTarget != ''){
                                        sumMainOperatingBankNewTarget = sumMainOperatingBankNewTarget+mainOperatingBankNewTarget;
                                    }

                                    if(dealBaseFeeNewTarget !== undefined && dealBaseFeeNewTarget != null && dealBaseFeeNewTarget != ''){
                                        sumDealBaseFeeNewTarget = sumDealBaseFeeNewTarget+dealBaseFeeNewTarget;
                                    }
                                    
                                    
                                    salesTargetList.push({salesTargetId:itemsOfSalesTarget[i].data.Id, transactionFeeNewTarget:transactionFeeNewTarget, mainOperatingBankNewTarget:mainOperatingBankNewTarget , dealBaseFeeNewTarget:dealBaseFeeNewTarget});
                                }
                            }

                            

                            
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPermanenceCheckbox(record.data);
                            });


                            
                            
                            
                            if(sumTransactionFeeNewTarget != salesTargetTransactionFeeTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert('....');
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Transaction Fee New Target does not match team target');
                            }else if(sumMainOperatingBankNewTarget != salesTargetMainOperatingBankTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Main Operating Bank new target does not match team target');
                            }else if(sumDealBaseFeeNewTarget != salesTargetDealBaseFeeTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Deal Base Fee New Target does not match team target');
                            }else if (final_selections.length > 0 && form.getFieldValues().selectedByUserId != null && form.getFieldValues().requestReason
                             != null) {
                                grid.setLoading(true);
                                selectconfirm_popup.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignPermanenceGrid',
                                        salesTargets : salesTargetList,
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
                            } else if(form.getFieldValues().selectedByUserId == null){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_No_User_Assignment);
                            } else if(form.getFieldValues().requestReason == null){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'No request reason defined');
                            } else if(usersSalesTargetNotSet != null){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Sales Target for users : '+usersSalesTargetNotSet+' has not been set');
                            }
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

    
    var requestReasonTextCBSAdmin = new Ext.form.field.TextArea({
        fieldLabel: config.map_label.BulkAssign_Request_Reason_Text,
        id: 'requestReasonTextCBSAdmin',
        name: 'requestReasonText',
        allowBlank: true,
        labelWidth: 90,
        labelStyle: 'width:120px'
    });
    // var requestReasonTextCBSAdmin = requestReasonText.cloneConfig();
    // requestReasonText.allowBlank = true;
    requestReasonTextCBSAdmin.disable();
    requestReasonTextCBSAdmin.hide();

    var accountBottomUpSumGridCBS = new Ext.grid.GridPanel({
        xtype: 'yearendgrid',
        id: 'accountBottomUpSumCBS',
        store: accountBottomUpSumStoreCBS,
        columns: accountBottomUpSumColumn,
        title: 'Bottom Up from Selected Customers',
        width: 950,
        forceFit: true,
        scrollOffset: 0
    });
    accountBottomUpSumGridCBS.hide();

    var salesTargetGridCBS = new Ext.grid.GridPanel({
        id: 'salesTargetGridCBS',
        store: salesTargetStore,
        columns: salesTargetColumn,
        title: 'Sales Target CBS',
        plugins: {
                ptype: 'cellediting',
                clicksToEdit: 1,
                editing:true
        },
        features: [{
            ftype: 'summary'
        }],
        listeners:{
                'afterrender': function(grid) {
                    rerenderSalesTargetGrid(grid);
                },
                'cellclick': function(view, cell, cellIndex, record,row, rowIndex, e) {
                    // var clickedColumnName = view.panel.headerCt.getHeaderAtIndex(cellIndex).text;

                    if(record.data.Bulk_Assignments_Sales_target__r !== undefined && record.dirty == false){
                        record.data.Transaction_Fee_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                        record.data.Main_Operating_Bank_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                        record.data.Deal_Base_Fee_New_Target__c = record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                    }
                }
            }
    });
    salesTargetGridCBS.hide();
    
    
    var selectconfirm_popupCBSAdmin = createPanel({
        id: 'selectedPanelCBSAdminTab',
        title: 'Assign To',
        draggable: true,
        resizable: true,
        items: [selectByRefUserPanelComboboxTwoCBSAdmin,requestReasonPopupFilterCBSAdminComboxbox,requestReasonTextCBSAdmin,accountBottomUpSumGridCBS,salesTargetGridCBS],
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
                            var grid = Ext.getCmp('reAssignCBSAdminGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();

                            var salesTargetGridCBS = Ext.getCmp('salesTargetGridCBS');
                            var itemsOfSalesTarget = salesTargetGridCBS.store.data.items;
                            var salesTargetListCBS = [];


                            var transactionFeeNewTarget;
                            var mainOperatingBankNewTarget;
                            var dealBaseFeeNewTarget;

                            var sumTransactionFeeNewTarget = 0;
                            var sumMainOperatingBankNewTarget = 0;
                            var sumDealBaseFeeNewTarget = 0;

                            var salesTargetTransactionFeeTeamTarget = 0;
                            var salesTargetMainOperatingBankTeamTarget = 0;
                            var salesTargetDealBaseFeeTeamTarget = 0;

                            if(itemsOfSalesTarget[0] !== undefined){
                                salesTargetTransactionFeeTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Transaction_Fee_Team_Target__c;
                                salesTargetMainOperatingBankTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Main_Operating_Bank_Team_Target__c;
                                salesTargetDealBaseFeeTeamTarget = itemsOfSalesTarget[0].data.Team_Target__r.Deal_Base_Fee_Team_Target__c;
                            }


                            if(salesTargetTransactionFeeTeamTarget === undefined || salesTargetTransactionFeeTeamTarget == null){
                                salesTargetTransactionFeeTeamTarget = 0;
                            }

                            if(salesTargetMainOperatingBankTeamTarget === undefined || salesTargetMainOperatingBankTeamTarget == null){
                                salesTargetMainOperatingBankTeamTarget = 0;
                            }

                            if(salesTargetDealBaseFeeTeamTarget === undefined || salesTargetDealBaseFeeTeamTarget == null){
                                salesTargetDealBaseFeeTeamTarget = 0;
                            }

                            if(selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)'){
                                for(var i=0; i < itemsOfSalesTarget.length; i++){
                                    
                                    transactionFeeNewTarget = itemsOfSalesTarget[i].data.Transaction_Fee_New_Target__c;
                                    mainOperatingBankNewTarget = itemsOfSalesTarget[i].data.Main_Operating_Bank_New_Target__c;
                                    dealBaseFeeNewTarget = itemsOfSalesTarget[i].data.Deal_Base_Fee_New_Target__c;


                                    if(transactionFeeNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            transactionFeeNewTarget = '';
                                        }else{
                                            transactionFeeNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                                        }
                                    }

                                    if(mainOperatingBankNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            mainOperatingBankNewTarget = '';
                                        }else{
                                            mainOperatingBankNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                                        }
                                    }

                                    if(dealBaseFeeNewTarget === undefined){
                                        if(itemsOfSalesTarget[i].data['Bulk_Assignments_Sales_target__r'] === undefined){
                                            dealBaseFeeNewTarget = '';
                                        }else{
                                            dealBaseFeeNewTarget = itemsOfSalesTarget[i].data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                                        }
                                    }

                                    if(transactionFeeNewTarget == null){
                                        transactionFeeNewTarget = '';
                                    }

                                    if(mainOperatingBankNewTarget == null){
                                        mainOperatingBankNewTarget = '';
                                    }

                                    if(dealBaseFeeNewTarget == null){
                                        dealBaseFeeNewTarget = '';
                                    }

                                    if(transactionFeeNewTarget !== undefined && transactionFeeNewTarget != null && transactionFeeNewTarget != ''){
                                        sumTransactionFeeNewTarget = sumTransactionFeeNewTarget+transactionFeeNewTarget;
                                    }

                                    if(mainOperatingBankNewTarget !== undefined && mainOperatingBankNewTarget != null && mainOperatingBankNewTarget != ''){
                                        sumMainOperatingBankNewTarget = sumMainOperatingBankNewTarget+mainOperatingBankNewTarget;
                                    }

                                    if(dealBaseFeeNewTarget !== undefined && dealBaseFeeNewTarget != null && dealBaseFeeNewTarget != ''){
                                        sumDealBaseFeeNewTarget = sumDealBaseFeeNewTarget+dealBaseFeeNewTarget;
                                    }
                                    
                                    
                                    salesTargetListCBS.push({salesTargetId:itemsOfSalesTarget[i].data.Id, transactionFeeNewTarget:transactionFeeNewTarget, mainOperatingBankNewTarget:mainOperatingBankNewTarget , dealBaseFeeNewTarget:dealBaseFeeNewTarget});
                                }
                            }
                            

                            
                            var final_selections = _.filter(selections, function(record) {
                                return reAssignPermanenceCheckbox(record.data);
                            });

                            if(sumTransactionFeeNewTarget != salesTargetTransactionFeeTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Transaction Fee New Target does not match team target');
                            }else if(sumMainOperatingBankNewTarget != salesTargetMainOperatingBankTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Main Operating Bank new target does not match team target');
                            }else if(sumDealBaseFeeNewTarget != salesTargetDealBaseFeeTeamTarget && selectedRequestReasonPopup != 'อื่นๆ (โปรดระบุ)' && selectedRequestReasonPopup != ''){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'Deal Base Fee New Target does not match team target');
                            }else if (final_selections.length > 0 && form.getFieldValues().selectedByUserId != null && form.getFieldValues().requestReason
                             != null) {
                                grid.setLoading(true);
                                selectconfirm_popupCBSAdmin.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveBulkAssignment', {
                                        contx: 'SAVE_BULK',
                                        selectName: form.getFieldValues(),
                                        bulkCISlist: _.pluck(final_selections, 'id'),
                                        gridName: 'reAssignCBSAdminGrid',
                                        salesTargets : salesTargetListCBS,
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
                            } else if(form.getFieldValues().selectedByUserId == null){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_No_User_Assignment);
                            } else if(form.getFieldValues().requestReason == null){
                                Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, 'No request reason defined');
                            }
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

    var selectconfirm_popupApprovalRecall = createPanel({
        id: 'selectConfirmApprovalRecall',
        draggable: true,
        resizable: true,
        title: config.map_label.BulkAssign_Recall_Confirmation_Display,
        layout:{
            type:'vbox',
            align:'center'
        },
        items: [{
                xtype: 'displayfield',
                value: config.map_label.BulkAssign_Recall_Confirmation
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
                            selectconfirm_popupApprovalRecall.hide();

                            Ext.Deferred
                                .all([sendRequest('handleBulkApproval', {
                                        contx: 'RECALL',
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
        store: accountBottomUpSumStoreBulkSales,
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
        title: config.map_label.BulkAssign_Bulk_Sales_Target,
        draggable: true,
        resizable: true,
        header: true,
        width: 1300,
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

                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignPermanenceCheckbox(record.data);
                        });
                        

                        if (final_selections.length > 0) {
                            selectedUserIdPopup = '';
                            selectedRequestReasonPopup = '';

                            selectByRefUserPanelComboboxTwo.store.reload();
                            selectByRefUserPanelComboboxTwo.reset();

                            requestReasonPopupFilterComboxbox.store.reload();
                            requestReasonPopupFilterComboxbox.reset();

                            requestReasonText.reset();
                            requestReasonText.disable();
                            requestReasonText.hide();

                            delete accountBottomUpSumStore.proxy.extraParams.bulkQueueId;
                            accountBottomUpSumGrid.store.proxy.extraParams.accIds = _.pluck(final_selections, 'id');
                            accountBottomUpSumGrid.store.reload();

                            accountBottomUpSumGrid.hide();

                            salesTargetGrid.store.reload();
                            salesTargetGrid.hide();

                            
                            var panel = Ext.getCmp('selectedPanel');
                            setPanelSizeAndPosition(panel,350);

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
                    activeInactiveFilterComboxbox
                    ,
                    {
                        xtype: 'tbspacer'
                    }
                    ,
                    customerSelectedByUserCombobox,
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
        })
        ,
        createGridObject(config.map_label.BulkAssign_CBS_Admin, 'reAssignCBSAdminGrid', reAssignCBSAdminStore, reAssignCBSAdminColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Submitted,
                    handler: function() {
                        
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignCBSAdminCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            selectedUserIdPopup = '';
                            selectedRequestReasonPopup = '';

                            selectByRefUserPanelComboboxTwoCBSAdmin.store.reload();
                            selectByRefUserPanelComboboxTwoCBSAdmin.reset();

                            // requestReasonPopupFilterCBSAdminComboxbox.store.reload();
                            // requestReasonPopupFilterCBSAdminComboxbox.reset();
                            requestReasonPopupFilterCBSAdminComboxbox.setValue('อื่นๆ (โปรดระบุ)');

                            requestReasonTextCBSAdmin.reset();
                            requestReasonTextCBSAdmin.enable();
                            requestReasonTextCBSAdmin.show();

                            delete accountBottomUpSumStoreCBS.proxy.extraParams.bulkQueueId;
                            accountBottomUpSumGridCBS.store.proxy.extraParams.accIds = _.pluck(final_selections, 'id');
                            accountBottomUpSumGridCBS.store.reload();
                            accountBottomUpSumGridCBS.hide();

                            salesTargetGridCBS.store.reload();
                            salesTargetGridCBS.hide();

                            
                            var panel = Ext.getCmp('selectedPanelCBSAdminTab');
                            
                            setPanelSizeAndPosition(panel,350);
                            selectconfirm_popupCBSAdmin.show();
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
                    }
                ] 
            }],
            listeners:{
                'afterrender': function(grid) {
                    reAssignCBSAdminStore.sync();
                    reAssignCBSAdminStore.reload();

                    hideClearAll();
                    
                },
                'headerclick': function(g, index, ev) {
                    
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (reAssignCBSAdminCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        })
        ,
        createGridObject(config.map_label.BulkAssign_Approval_History, 'approvalProcessBulkAssignGrid', approvalProcessBulkAssignStore, approvalProcessBulkAssignColumn, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: config.map_label.BulkAssign_Recall,
                    handler: function(){
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return reAssignApprovalBulkAssignCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            
                            selectconfirm_popupApprovalRecall.show();
                        } else {
                            Ext.Msg.alert(config.map_label.BulkAssign_Invalid_Fields, config.map_label.BulkAssign_NoAssignmentSelected);
                        }
                    }
                }, {
                    xtype: 'tbspacer'
                }]
            },{
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    xtype: 'tbspacer'
                },
                requestReasonApprovalFilterComboxbox,
                {
                    xtype: 'tbspacer'
                },
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
                    
                    var grid = Ext.getCmp('bulkSalesTargetGrid');
                    var clickedColumnName = view.panel.headerCt.getHeaderAtIndex(cellIndex).text;
                    if(clickedColumnName == 'Bulk Assignment Queue Name' && record.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c != 'อื่นๆ (โปรดระบุ)'){
                        accountBottomUpSumStoreBulkSales.proxy.extraParams.bulkQueueId = record.data.BulkAssignmentQueue__c;
                        accountBottomUpSumStoreBulkSales.load();
                        bulkSalesTargetGrid.store.filter('Bulk_Assignment_Queue__c','#'+record.data.BulkAssignmentQueue__c);
                        bulkSalesTargetGrid.store.load();
                        showBulkSalesPanel.show();
                    }
                },
                select: function(selModel,recordSelect){
                    if(recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c != 'อื่นๆ (โปรดระบุ)'){
                        var grid = this;
                        grid.store.each(function(record){
                            if(record.data.BulkAssignmentQueue__c == recordSelect.data.BulkAssignmentQueue__c){
                                grid.getSelectionModel().select(record,true,true);
                            }
                            
                        });
                    }
                    
                },
                deselect: function(model, recordSelect, index) {
                    if(recordSelect.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c != 'อื่นๆ (โปรดระบุ)'){
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
                
            })
        })
    ];
};
