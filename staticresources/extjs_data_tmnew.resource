function init(config) {
    var customerRequestModelColumn = [
        {
            "name": "CIS_ID_Text__c",
            "mapping": 'CIS_ID_Text__c',
        },
        {
            "name": "Customer_Name__c",
            "mapping": 'Customer_Name__c',
        },
        {
            "name": "Segment_Original__c",
            "mapping": 'Segment_Original__c',
        },
        {
            "name": "High_Value_Flag__c",
            "mapping": 'High_Value_Flag__c',
        },
        {
            "name": "Port_Pool__c",
            "mapping": 'Port_Pool_YearEnd__c',
        },
        {
            "name": "Credit_Status__c",
            "mapping": 'Credit_Status__c',
        },
        {
            "name": "Owner.Name",
            "mapping": 'Owner.Name',
        },
        {
            "name": "Assigned_Port_Pool__c",
            "mapping": 'Assigned_Port_Pool__c',
        },
        {
            "name": "Service_RM_User__r.Name",
            "mapping": 'Service_RM_User__r.Name',
        },
        {
            "name": "Team__c",
            "mapping": 'Team__c',
        },
        {
            "name": "TM_Name__c",
            "mapping": 'TM_Name__c',
        },
        {
            "name": "AH_Name__c",
            "mapping": 'AH_Name__c',
        },
        {
            "name": "NH_Name__c",
            "mapping": 'NH_Name__c',
        },
        {
            "name": "Approval Status",
            "mapping": "Approval_Status__c"
        }
    ];
    var selectedCountColumn = [
        {
            "dataIndex": "RM_Name__c",
            "text": config.yearEndSelForMap["RM_Name__c"],
            "flex": 1
        }, {
            "dataIndex": "Team__c",
            "text": config.yearEndSelForMap["Team__c"],
            "flex": 1
        }, {
            "dataIndex": "TM_Name__c",
            "text": config.yearEndSelForMap["TM_Name__c"],
            "flex": 1
        }, {
            "dataIndex": "Selected_By_Name__c",
            "text": config.yearEndSelForMap["Selected_By_Name__c"],
            "flex": 1
        }, {
            "dataIndex": "Selected_By_Team__c",
            "text": config.yearEndSelForMap["Selected_By_Team__c"],
            "flex": 1
        }
    ];
    var customerRequestColumn = [
        {
            "text": config.customerOwnerForMap["Name"],
            "dataIndex": "Name"
        },
        {
            "text": config.customerOwnerForMap["CIS_ID_Text__c"],
            "align": "right",
            "dataIndex": "CIS_ID_Text__c",
            "locked": true
        },
        {
            "text": config.customerOwnerForMap["Customer_Name__c"],
            "dataIndex": "Customer_Name__c",
            "renderer": Ext.util.Format.htmlDecode,
            "locked": true
        },
        {
            "text": config.customerOwnerForMap["Segment_Original__c"],
            "dataIndex": "Segment_Original__c"
        },
        {
            "text": config.customerOwnerForMap["High_Value_Flag__c"],
            "dataIndex": "High_Value_Flag__c"
        },
        {
            "text": config.customerOwnerForMap["Port_Pool__c"],
            "dataIndex": "Port_Pool__c"
        },
        {
            "text": config.customerOwnerForMap["Credit_Status__c"],
            "dataIndex": "Credit_Status__c"
        },
        {
            "text": config.map_label.YearEnd_Requested,
            "dataIndex": "Owner.Name"
        },
        {
            "text": config.customerOwnerForMap["Assigned_Port_Pool__c"],
            "dataIndex": "Assigned_Port_Pool__c"
        },
        {
            "text": config.map_label.YearEnd_Requested_Servicing_RM,
            "dataIndex": "Service_RM_User__r.Name"
        },
        {
            "text": config.customerOwnerForMap["RM_Name__c"],
            "dataIndex": "RM_Name__c"
        },
        {
            "text": config.customerOwnerForMap["Team__c"],
            "dataIndex": "Team__c"
        },
        {
            "text": config.customerOwnerForMap["TM_Name__c"],
            "dataIndex": "TM_Name__c"
        },/*
        {
            "text": config.customerOwnerForMap["AH_Name__c"],
            "dataIndex": "AH_Name__c"
        },
        {
            "text": config.customerOwnerForMap["NH_Name__c"],
            "dataIndex": "NH_Name__c"
        },*/
        {
            "text": config.customerOwnerForMap["Approval_Status__c"],
            "dataIndex": "Approval_Status__c"
        }
    ];
    var yearColumn = [
        {
            "dataIndex": "CIS_ID_Unique__c",
            "text": config.yearEndForMap["CIS_ID_Unique__c"],
            "sortable": true,
            "align": "right",
            "locked": true
        }, {
            "dataIndex": "Customer_Name__c",
            "text": config.yearEndForMap["Customer_Name__c"],
            "sortable": false,
            "renderer": Ext.util.Format.htmlDecode,
            "locked": true
        }, {
            "dataIndex": "Segment_Original__c",
            "text": config.yearEndForMap["Segment_Original__c"],
            "sortable": true
        },/* {
            "dataIndex": "Segment_Proposed__c",
            "text": config.yearEndForMap["Segment_Proposed__c"],
            "sortable": true,
            "width": 150
        },*/ {
            "dataIndex": "High_Value_Flag__c",
            "text": config.yearEndForMap["High_Value_Flag__c"],
            "sortable": true
        }, {
            "dataIndex": "Port_Pool__c",
            "text": config.yearEndForMap["Port_Pool__c"],
            "sortable": true
        }, {
            "dataIndex": "Credit_Status__c",
            "text": config.yearEndForMap["Credit_Status__c"],
            "sortable": true
        }, {
            "dataIndex": "RM_Name__c",
            "text": config.yearEndForMap["RM_Name__c"],
            "sortable": true
        }, {
            "dataIndex": "Team__c",
            "text": config.yearEndForMap["Team__c"],
            "sortable": true
        }, {
            "dataIndex": "TM_Name__c",
            "text": config.yearEndForMap["TM_Name__c"],
            "sortable": true
        }, {
            "dataIndex": "Final_Assigned_SelectedBy_Text__c",
            "text": config.yearEndForMap["Final_Assigned_SelectedBy_Text__c"],
            "align": "right",
            "sortable": true
        }, {
            "dataIndex":"Final_Service_RM_Text__c",
            "text": config.yearEndForMap["Final_Service_RM_Text__c"],
            "sortable":true
        }, {
            "dataIndex":"Final_Port_Pool__c",
            "text": config.yearEndForMap["Final_Port_Pool__c"],
            "sortable":true
        }, {
            "dataIndex": "Final_Team__c",
            "text": config.yearEndForMap["Final_Team__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Final_Refer_Out__c",
            "text": config.yearEndForMap["Final_Refer_Out__c"],
            "sortable": true,
            "xtype": "checkcolumn",
            "disabled": true,
            "disabledCls" : "x-item-enabled"
        }, {
            "dataIndex": "Refer_Out_Reason__c",
            "text": config.yearEndForMap["Refer_Out_Reason__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Refer_Out_Detail__c",
            "text": config.yearEndForMap["Refer_Out_Detail__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Selected_Count__c",
            "text": config.yearEndForMap["Selected_Count__c"],
            "align": "right",
            "format": "0,000",
            "sortable": true,
            "xtype": "numbercolumn",
            "listeners":{
                "click": function(gridtable,gridtable_html,index,col,record){
                    var record_data = record.record.data;
                    if(record_data.Selected_Count__c > 1){
                        selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
                        selectedcount_popup.show();
                    }
                }
            }
        }, /*{
            "dataIndex": "AH_Name__c",
            "text": config.yearEndForMap["AH_Name__c"],
            "sortable": true
        }, {
            "dataIndex": "NH_Name__c",
            "text": config.yearEndForMap["NH_Name__c"],
            "sortable": true
        },*/ {
            "dataIndex": "Business_Code__c",
            "text": config.yearEndForMap["Business_Code__c"],
            "sortable": true
        }, {
            "dataIndex": "Business_Desc__c",
            "text": config.yearEndForMap["Business_Desc__c"],
            "sortable": true
        }, {
            "dataIndex": "Credit_Flag__c",
            "text": config.yearEndForMap["Credit_Flag__c"],
            "sortable": true
        }, {
            "dataIndex": "Income_1M__c",
            "text": config.yearEndForMap["Income_1M__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true
        }, {
            "dataIndex": "Total_SME_Limit__c",
            "text": config.yearEndForMap["Total_SME_Limit__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true
        }, {
            "dataIndex":"SME_Limit_LI__c",
            "text": config.yearEndForMap["SME_Limit_LI__c"],
            "format":"0,000",
            "align": "right",
            "text":"SME Limit - LI",
            "sortable":true
        }, {
            "dataIndex":"SME_Limit_TF__c",
            "text": config.yearEndForMap["SME_Limit_TF__c"],
            "xtype": "numbercolumn",
            "format":"0,000",
            "align": "right",
            "sortable":true
        }, {
            "dataIndex": "Total_SME_Out__c",
            "text": config.yearEndForMap["Total_SME_Out__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true
        }, {
            "dataIndex": "Total_SME_Exposure__c",
            "text": config.yearEndForMap["Total_SME_Exposure__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true
        }, {
            "dataIndex": "SOW_SME_Exposure__c",
            "text": config.yearEndForMap["SOW_SME_Exposure__c"],
            "sortable": true,
            "renderer": function(value) {
                return (value) ? (value + "%") : "";
            }
        }, {
            "dataIndex": "SME_Wallet_Size__c",
            "text": config.yearEndForMap["SME_Wallet_Size__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true
        }, {
            "dataIndex": "DPD6M__c",
            "text": config.yearEndForMap["DPD6M__c"],
            "sortable": true
        }, {
            "dataIndex": "NPL12M__c",
            "text": config.yearEndForMap["NPL12M__c"],
            "sortable": true
        }, {
            "dataIndex": "Court_Case_12M__c",
            "text": config.yearEndForMap["Court_Case_12M__c"],
            "sortable": true
        },
        {
            "dataIndex": "Court_Case_Current_Year__c",
            "text": config.yearEndForMap["Court_Case_Current_Year__c"],
            "sortable": true
        },
        {
            "dataIndex": "SME_BSCORE_1M__c",
            "text": config.yearEndForMap["SME_BSCORE_1M__c"],
            "sortable": true
        }, {
            "dataIndex": "SME_BSCORE_2M__c",
            "text": config.yearEndForMap["SME_BSCORE_2M__c"],
            "sortable": true
        }, {
            "dataIndex": "SME_BSCORE_3M__c",
            "text": config.yearEndForMap["SME_BSCORE_3M__c"],
            "sortable": true
        }
    ];
    var yearSelColumn = [
        {
            "dataIndex": "CIS_ID__c",
            "text": config.yearEndSelForMap["CIS_ID__c"],
            "sortable": true,
            "align": "right",
            "width": 70,
            "locked": true
        }, {
            "dataIndex": "Customer_Name__c",
            "text": config.yearEndSelForMap["Customer_Name__c"],
            "sortable": false,
            "renderer": Ext.util.Format.htmlDecode,
            "locked": true
        }, {
            "dataIndex": "Segment_Original__c",
            "text": config.yearEndSelForMap["Segment_Original__c"],
            "sortable": true,
            "width": 150
        }, /*{
            "dataIndex": "Segment_Proposed__c",
            "text": config.yearEndSelForMap["Segment_Proposed__c"],
            "sortable": true,
            "width": 150
        },*/ {
            "dataIndex": "High_Value_Flag__c",
            "text": config.yearEndSelForMap["High_Value_Flag__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Credit_Status__c",
            "text": config.yearEndSelForMap["Credit_Status__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "RM_Name__c",
            "text": config.yearEndSelForMap["RM_Name__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Team__c",
            "text": config.yearEndSelForMap["Team__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "TM_Name__c",
            "text": config.yearEndSelForMap["TM_Name__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Selected_By_Name__c",
            "text": config.yearEndSelForMap["Selected_By_Name__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Selected_By_Team__c",
            "text": config.yearEndSelForMap["Selected_By_Team__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Port_Pool__c",
            "text": config.yearEndSelForMap["Port_Pool__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Refer_Out__c",
            "text": config.yearEndSelForMap["Refer_Out__c"],
            "sortable": true,
            "xtype": "checkcolumn",
            "disabled": true,
            "disabledCls" : "x-item-enabled"
        }, {
            "dataIndex": "Refer_Out_Reason__c",
            "text": config.yearEndSelForMap["Refer_Out_Reason__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Refer_Out_Detail__c",
            "text": config.yearEndSelForMap["Refer_Out_Detail__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Final_Assigned_RM__c",
            "text": config.yearEndSelForMap["Final_Assigned_RM__c"],
            "sortable": true,
            "width": 150
        },
        {
            "dataIndex":"Final_Service_RM__c",
            "text": config.yearEndSelForMap["Final_Service_RM__c"],
            "sortable":true
        },
        {
            "dataIndex":"Final_Port_Pool__c",
            "text": config.yearEndSelForMap["Final_Port_Pool__c"],
            "sortable":true
        },
        {
            "dataIndex": "Final_Team__c",
            "text": config.yearEndSelForMap["Final_Team__c"],
            "sortable": true,
            "width": 150
        },
        {
            "dataIndex": "Final_Refer_Out__c",
            "text": config.yearEndSelForMap["Final_Refer_Out__c"],
            "sortable": true,
            "xtype": "checkcolumn",
            "disabled": true,
            "disabledCls" : "x-item-enabled"
        }, {
            "dataIndex": "Final_Refer_Out_Reason__c",
            "text": config.yearEndSelForMap["Final_Refer_Out_Reason__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Final_Refer_Out_Reason_Detail__c",
            "text": config.yearEndSelForMap["Final_Refer_Out_Reason_Detail__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Selected_Count__c",
            "text": config.yearEndSelForMap["Selected_Count__c"],
            "align": "right",
            "format": "0,000",
            "sortable": true,
            "xtype": "numbercolumn",
            "listeners":{
                "click": function(gridtable,gridtable_html,index,col,record){
                    var record_data = record.record.data;
                    if(record_data.Selected_Count__c > 1){
                        selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
                        selectedcount_popup.show();
                    }
                }
            }
        },/* {
            "dataIndex": "AH_Name__c",
            "text": config.yearEndSelForMap["AH_Name__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "NH_Name__c",
            "text": config.yearEndSelForMap["NH_Name__c"],
            "sortable": true,
            "width": 150
        },*/ {
            "dataIndex": "Business_Code__c",
            "text": config.yearEndSelForMap["Business_Code__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Business_Desc__c",
            "text": config.yearEndSelForMap["Business_Desc__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Credit_Flag__c",
            "text": config.yearEndSelForMap["Credit_Flag__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Income_1M__c",
            "text": config.yearEndSelForMap["Income_1M__c"],
            "format": "0,000",
            "align": "right",
            "text": "Income Last1Month",
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Total_SME_Limit__c",
            "text": config.yearEndSelForMap["Total_SME_Limit__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true,
            "width": 150
        }, {
            "dataIndex":"SME_Limit_LI__c",
            "text": config.yearEndSelForMap["SME_Limit_LI__c"],
            "xtype": "numbercolumn",
            "format":"0,000",
            "align": "right",
            "sortable":true
        }, {
            "dataIndex":"SME_Limit_TF__c",
            "text": config.yearEndSelForMap["SME_Limit_TF__c"],
            "xtype": "numbercolumn",
            "format":"0,000",
            "align": "right",
            "sortable":true
        }, {
            "dataIndex": "Total_SME_Out__c",
            "text": config.yearEndSelForMap["Total_SME_Out__c"],
            "xtype": "numbercolumn",
            "format": "0,000",
            "align": "right",
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Total_SME_Exposure__c",
            "text": config.yearEndSelForMap["Total_SME_Exposure__c"],
            "align": "right",
            "format": "0,000",
            "text": "Total SME Exposure",
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "SOW_SME_Exposure__c",
            "text": config.yearEndSelForMap["SOW_SME_Exposure__c"],
            "sortable": true,
            "renderer": function(value) {
                return (value) ? (value + "%") : "";
            }
        }, {
            "dataIndex": "SME_Wallet_Size__c",
            "text": config.yearEndSelForMap["SME_Wallet_Size__c"],
            "xtype": "numbercolumn",
            "align": "right",
            "format": "0,000",
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "DPD6M__c",
            "text": config.yearEndSelForMap["DPD6M__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "NPL12M__c",
            "text": config.yearEndSelForMap["NPL12M__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Court_Case_12M__c",
            "text": config.yearEndSelForMap["Court_Case_12M__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "Court_Case_Current_Year__c",
            "text": config.yearEndSelForMap["Court_Case_Current_Year__c"],
            "sortable": true
        }, {
            "dataIndex": "SME_BSCORE_1M__c",
            "text": config.yearEndSelForMap["SME_BSCORE_1M__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "SME_BSCORE_2M__c",
            "text": config.yearEndSelForMap["SME_BSCORE_2M__c"],
            "sortable": true,
            "width": 150
        }, {
            "dataIndex": "SME_BSCORE_3M__c",
            "text": config.yearEndSelForMap["SME_BSCORE_3M__c"],
            "sortable":true,
            "width":150
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
                    request_id = button.getWidgetRecord().getId();
                    selectByPanelRequestCombobox.clearValue();
                    portPoolPanelRequestCombobox.clearValue();
                    servicePanelRequestCombobox.clearValue();

                    selectByPanelRequestCombobox.clearInvalid();
                    portPoolPanelRequestCombobox.clearInvalid();
                    servicePanelRequestCombobox.clearInvalid();

                    servicePanelRequestCombobox.hide();

                    request_popup.show();
                },
                listeners: {
                    beforerender: function(record) {
                        //console.log(record,record.getWidgetRecord());
                        //var record_data = record.getWidgetRecord().data;

                        //if(record_data.approval_status && typeof record_data.approval_status!=="undefined" && record_data.approval_status!=""){
                            //this.text = approval_status;
                            //this.disable();
                        //}
                        /*if(record_data.approval_status == 'Approval In Progress'){
                            this.text = 'Approval In Progress';
                            this.disable();
                        }else if(record_data.approval_status == 'Approved'){
                            this.text = 'Approved';
                            this.disable();
                        }*/
                    }
                }
            }
        },{
            "dataIndex": "cis_id",
            "text": config.customerOwnerForMap["CIS_ID_Text__c"],
            "align": "right",
            "width": 70,
            "locked": true
        }, {
            "dataIndex": "name",
            "text": config.customerOwnerForMap["Customer_Name__c"],
            "width": 150,
            "locked": true
        }, {
            "dataIndex": "segment",
            "text": config.customerOwnerForMap["Segment_Original__c"],
            "width": 150
        }, {
            "dataIndex": "high_value",
            "text": config.customerOwnerForMap["High_Value_Flag__c"],
            "width": 150
        }, {
            "dataIndex": "flag_port",
            "text": config.customerOwnerForMap["Port_Pool_YearEnd__c"],
            "width": 150
        }, {
            "dataIndex": "credit_status",
            "text": config.customerOwnerForMap["Credit_Status__c"],
            "width": 150
        }, {
            "dataIndex": "existing_rm_name",
            "text": config.customerOwnerForMap["RM_Name__c"],
            "width": 150
        }, {
            "dataIndex": "team",
            "text": config.customerOwnerForMap["Team__c"],
            "width": 150
        }, {
            "dataIndex": "tm_name",
            "text": config.customerOwnerForMap["TM_Name__c"],
            "width": 150
        }/*, {
            "dataIndex": "ah_name",
            "text": config.customerOwnerForMap["AH_Name__c"],
            "width": 150
        }, {
            "dataIndex": "nh_name",
            "text": config.customerOwnerForMap["NH_Name__c"],
            "width": 150
        }*/
    ];
    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");

    Ext.define('customerModel', {
        extend: 'Ext.data.Model',
        fields: [{
            name: 'year_id',
            type: 'string'
        },{
            name: 'customer_id',
            type: 'string'
        }, {
            name: 'cis_id',
            type: 'string'
        }, {
            name: 'name',
            type: 'string'
        }, {
            name: 'segment',
            type: 'string'
        }, {
            name: 'high_value',
            type: 'string'
        }, {
            name: 'flag_port',
            type: 'string'
        }, {
            name: 'credit_status',
            type: 'string'
        }, {
            name: 'existing_rm_name',
            type: 'string'
        }, {
            name: 'team',
            type: 'string'
        }, {
            name: 'tm_name',
            type: 'string'
        }, {
            name: 'ah_name',
            type: 'string'
        }, {
            name: 'nh_name',
            type: 'string'
        }, {
            name: 'approval_status',
            type: 'string'
        }],
        idProperty: 'year_id',
    });
    createModel(yearEndModelName, 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment__c',
            fields: config.fieldlist.join(',')
        }
    );
    createModel('customerOwnerRequest', 'records', 'Id',
        customerRequestModelColumn, YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Customer_Ownership_Request__c',
            fields: config.fieldrequestlist.join(',')
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
            property: 'Team__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelMoreOneStore = createStoreModel(yearEndSelModelName, config.pagesize, {
        filters: [{
            property: 'Selected_By__r.RC_Code__c',
            value: '#' + config.user_rc_code
        },{
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
        filters: [{
            property: 'Selected_By__r.RC_Code__c',
            value: '#' + config.user_rc_code
        },{
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
        filters: [{
            property: 'Selected_By__r.RC_Code__c',
            value: '#' + config.user_rc_code
        },{
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
        filters: [{
            property: 'Selected_By__r.RC_Code__c',
            value: '#' + config.user_rc_code
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
    var customerOwnerStore = createStoreModel('customerOwnerRequest', 200, {
        autoLoad: false,
        filters: [{
            property: 'Source_is_On_Going__c',
            value: false
        }],
        sorters: [{
            property: 'Name',
            direction: 'DESC'
        }]
    });
    var selectedCountStore = createStoreModel('selectedCount', 200, {
        autoLoad: false
    });
    var customerStore = new Ext.data.ArrayStore({
        model: 'customerModel',
        autoLoad: false,
        pageSize: 200
    });

    var is_confirmlist = false;
    var request_id;
    var yearEndCheckbox = function(record) {
        return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c == null || typeof record.Final_Assigned_RM__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c == null || typeof record.Final_Refer_Out__c === "undefined") && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r == null || typeof record.Year_End_Assignment_Selections__r === "undefined") && record.Selected_Count__c==0);
    };
    var yearEndSelCheckbox = function(record) {
        return record.Selected_By__r && record.Selected_By__r.RC_Code__c == config.user_rc_code && record.Year_End_Assignment__r.Status__c=='New' && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c == null || typeof record.Final_Assigned_RM__c === "undefined");
    };
    var yearEndSelConfirmCheckbox = function(record) {
        return record.Selected_By__r && record.Selected_By__r.RC_Code__c == config.user_rc_code && record.Year_End_Assignment__r.Status__c=='New' && record.Final_Assigned_RM__c && record.Final_Assigned_RM__c != null && typeof record.Final_Assigned_RM__c !== "undefined";
    };

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
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist, {
        scope: 'Refer_Out_Reason__c'
    }, true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist, {
        scope: 'Refer_Out_Segment__c'
    }, true);

    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation, {
        scope: 'Province'
    }, true);
    var aumpurStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation, {
        scope: 'District'
    }, false);
    var tumbonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation, {
        scope: 'Sub District'
    }, false);

    var selectByMoreOneCombobox = createComboxbox(config.map_label.YearEnd_CustomerSelectedbyName, 'selectedbyname', false, selectByStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, true, {
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
    var selectByRefOutCombobox = selectByMoreOneCombobox.cloneConfig();
    var selectBySelectedCombobox = selectByMoreOneCombobox.cloneConfig();
    var selectByConfirmCombobox = selectByMoreOneCombobox.cloneConfig();

    var selectByPanelCombobox = createComboxbox(config.map_label.YearEnd_SelectRM_TM, 'selectedbyNamepanel', false, selectByPanelStore, config.map_label.YearEnd_SelectRM_TM, 'pname', 'pvalue', false, false, {
        listeners: {
            select: function(combox, selected, index) {
                var grid = this.up('grid');
                servicePanelCombobox.hide();
                servicePanelCombobox.clearValue();

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
        }), config.map_label.YearEnd_Port + ' ' + config.map_label.YearEnd_Port, 'pname', 'pvalue', false, false, {
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
    var servicePanelCombobox = createComboxbox(config.map_label.YearEnd_SelectServicingRM, 'serviceRMpanel', true, servicePanelStore, config.map_label.YearEnd_Servicing_RM, 'pname', 'pvalue', false, true, {
        value: ''
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
        items: [selectByPanelCombobox, portPoolPanelCombobox, servicePanelCombobox],
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
                                .all([requestApex('createRequest',{
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
                value: 'false',
                valueField: 'value',
                displayField: 'property',
                listeners: flisteners
            };
        }
    };

    config.panel_items = [
        createGridObject('<span style="color:red;">1.</span> '+config.map_label.YearEnd_SelectedCountMoreThanOne, 'yearEndSelMoreOneGrid', yearEndSelMoreOneStore, yearSelColumn, {
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
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                if (selected.data.value == 'false') {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.enable();
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByMoreOneCombobox.clearValue();
                                    selectByMoreOneCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
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
                    if (yearEndSelCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('<span style="color:red;">2.</span> '+config.map_label.YearEnd_ReferOutList, 'yearEndRefOutGrid', yearEndRefOutStore, yearSelColumn,{
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
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                if (selected.data.value == 'false') {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.enable();
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByRefOutCombobox.clearValue();
                                    selectByRefOutCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
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
        createGridObject('<span style="color:red;">3.</span> '+config.map_label.YearEnd_SelectedList, 'yearEndSelSelectedGrid', yearEndSelSelectedStore, yearSelColumn, {
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
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                if (selected.data.value == 'false') {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.enable();
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectBySelectedCombobox.clearValue();
                                    selectBySelectedCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
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
        createGridObject('<span style="color:red;">4.</span> '+config.map_label.YearEnd_ConfirmList, 'yearEndSelConfirmGrid', yearEndSelConfirmStore, yearSelColumn, {
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
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                if (selected.data.value == 'false') {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.enable();
                                    grid.store.filter("Selected_By__r.RC_Code__c", '#' + config.user_rc_code);
                                }else {
                                    selectByConfirmCombobox.clearValue();
                                    selectByConfirmCombobox.disable();
                                    grid.store.removeFilter("Selected_By__r.RC_Code__c");
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

                            selectByPanelCombobox.clearValue();
                            portPoolPanelCombobox.clearValue();
                            servicePanelCombobox.clearValue();

                            selectByPanelCombobox.clearInvalid();
                            portPoolPanelCombobox.clearInvalid();
                            servicePanelCombobox.clearInvalid();

                            servicePanelCombobox.hide();
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
            title: '<span style="color:red;">6.</span> '+config.map_label.YearEnd_OwnershipRequest,
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
                createGridObject(config.map_label.YearEnd_ListofRequest, 'customeRequestGrid', customerOwnerStore, customerRequestColumn, {
                    width: '100%',
                    height: 350,
                    listeners:{
                        'afterrender': function(grid) {
                            customerOwnerStore.sync();
                            customerOwnerStore.reload();
                        }
                    }
                }, false)
            ]
        },

    ];
    config.container_items = [referout_popup, selectconfirm_popup, request_popup,selectedcount_popup];
};
