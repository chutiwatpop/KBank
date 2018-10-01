function requestApex(method,mdata) {
    var deferred = new Ext.Deferred();
    var response = sforce.apex.execute("YearEndAssignment_Webservice", method, mdata);

    if (response && response[0].success) {
        deferred.resolve(response[0]);
    } else deferred.reject(response[0].errorMessage);

    return deferred.promise;
};
function savingYearEnd(requestObj) {
    var deferred = new Ext.Deferred();
    YearEndAssignment_ListView_Controller.saveYearEnd(requestObj, function(results, e) {
        console.log(results, e);
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
};
function sendRequest(operate, requestObj) {
    var deferred = new Ext.Deferred();
    YearEndAssignment_ListView_Controller[operate](requestObj, function(results, e) {
        console.log(results, e);
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
};
var fields_base = {
    "CIS_ID_Unique__c":{
        "dataIndex": "CIS_ID_Unique__c",
        "sortable":true,
        "customSort": "CIS_Number__c",
        "align": "right",
        "width": 70,    
        "locked": true,
         renderer: function(val, meta, record, rowIndex) {
            return '<a href="../'+record.get('CIS_ID__c')+'" target="_blank" >'+val+'</a>';
            },
        "filter": {
            "type": "numstring",
            "typeahead": false,
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "CIS_ID__c":{
        "dataIndex": "CIS_ID__c",
        "sortable":true,
        "align": "right",
        "header": "CIS",
        "width": 70,
        "locked": true,
        "customSort": "CIS_Number__c",
        "filter": {
            //"type": 'string'
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "CIS_Number__c":{
        "dataIndex": "CIS_Number__c",
        "locked": true,
        "sortable": false,
        "renderer": Ext.util.Format.htmlDecode,
        "locked": true
    }, 
    "Customer_Name__c":{
        "dataIndex": "Customer_Name__c",
        "sortable": false,
        "width": 200,
        "renderer": Ext.util.Format.htmlDecode,
        "locked": true
    },  
    "Selected_Count__c":{
        "dataIndex": "Selected_Count__c",
        "align": "right",
        "format": "0,000",
        "sortable":false,
        "xtype": "numbercolumn",
        "listeners":{
            "click": function(gridtable,gridtable_html,index,col,record){
                var record_data = record.record.data;
                if(record_data.Selected_Count__c > 1){
                    selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
                    selectedcount_popup.show();
                }
            }
        },
        "locked": true
    },  
    "Selected_Count_Unlock":{
        "dataIndex": "Selected_Count__c",
        "align": "right",
        "format": "0,000",
        "header": "Selected Count",
        "sortable":false,
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
    },
    "Segment_Original__c":{
        "dataIndex": "Segment_Original__c",
        "sortable":true,
        "customSort": "Segment_Original__c",
        "width": 100
    },
     "Segment_Original_text":{
        "dataIndex": "Segment_Original__c",
        "sortable":true,
        "width": 100
    },
    "Segment_Proposed__c":{
        "dataIndex": "Segment_Proposed__c",
        "sortable":true,
        "width": 150
    },
    "High_Value_Flag__c":{
        "dataIndex": "High_Value_Flag__c",
        "sortable":true,
        "width": 150
    }, 
    "Credit_Status__c":{
        "dataIndex": "Credit_Status__c",
        "sortable":true,
        "width": 150
    }, 
    "RM_Name__c":{
        "dataIndex": "RM_Name__c",
        "header": 'RM Name',
        "customSort": "RM_Name__c",
        "sortable":true,
        "width": 150
    }, 
    "RM_TM_Name__c":{
        "dataIndex": "RM_Name__c",
        "customSort": "RM_Name__c",
        "header": 'RM/TM Name',
        "sortable":true,
        "width": 150
    }, 
    "Team__c":{
        "dataIndex": "Team__c",
        "sortable":true,
        "width": 150
    }, 
    "TM_Name__c":{
        "dataIndex": "TM_Name__c",
        "sortable":true,
        "width": 150
    },
    "TL_Name__c":{
        "dataIndex": "AH_Name__c",
        "header": 'TL Name',
        "sortable":true,
        "width": 150
    }, 
    "Selected_By_Name__c":{
        "dataIndex": "Selected_By_Name__c",
        "header": 'Assign To',
        "sortable":true,
        "width": 150
    }, 
    "Selected_Service_RM_Name_Text__c":{
        "dataIndex": "Selected_Service_RM_Name_Text__c",
        "sortable":false,
        "width": 150,
        "header": 'Assign Service RM Name'
    }, 
    "Selected_By_Service_RM_Text__c":{
        "dataIndex": "Selected_By_Service_RM_Text__c",
        "sortable":false,
        "width": 150,
        "header": 'Assign Service RM Name'
    },
    "Selected_Port_Pool__c":{
        "dataIndex": "Selected_Port_Pool__c",
        "sortable":false,
        "width": 150
    }, 
    "Selected_By_Team__c":{
        "dataIndex": "Selected_By_Team__c",
        "sortable":false,
        "width": 200,
        "header": 'Refer Out To Team'
    }, 
    "Port_Pool__c":{
        "dataIndex": "Port_Pool__c",
        "sortable":false,
        "width": 150
    }, 
    "Refer_Out__c":{
        "dataIndex": "Refer_Out__c",
        "sortable":false,
        "xtype": "checkcolumn",
        "listeners" : {
            beforecheckchange : function(column, rowIndex) {
                return false;
            }
        },
        "disabledCls" : "x-item-enabled"
    },
     "Refer_Out_Team__c":{
        "dataIndex": "Refer_Out_Team__c",
        "customSort": "Refer_Out_Team__c",
        "text": "Refer Out Team",
        "sortable":false,
        "width": 250
    },  
    "Refer_Out_Reason__c":{
        "dataIndex": "Refer_Out_Reason__c",
        "sortable":false,
        "width": 150
    },  
    "Refer_Out_Reason__c":{
        "dataIndex": "Refer_Out_Reason__c",
        "sortable":false,
        "width": 150
    }, 
    "Refer_Out_Detail__c":{
        "dataIndex": "Refer_Out_Detail__c",
        "sortable":false,
        "width": 150
    }, 
    "Final_Assigned_Next_Year__c":{
        "dataIndex": "Final_Assigned_Next_Year__c",
        "header":"Final Assigned Next Year/SelectedBy",
        "sortable":false,
        "width": 150
    },
    "Final_SVM_Next_Year__c":{
        "dataIndex":"Final_SVM_Next_Year__c",
        "sortable":false
    },
    "Final_Port_Pool__c":{
        "dataIndex":"Final_Port_Pool__c",
        "sortable":false
    },
    "Final_Team__c":{
        "dataIndex": "Final_Team__c",
        "sortable":false,
        "width": 150
    },
    "Final_Refer_Out__c":{
        "dataIndex": "Final_Refer_Out__c",
        "sortable":false,
        "xtype": "checkcolumn",
        "listeners" : {
            beforecheckchange : function(column, rowIndex) {
                return false;
            }
        },
        "disabledCls" : "x-item-enabled"
    }, 
    "Final_Assigned_SelectedBy_Text__c":{
        "dataIndex": "Final_Assigned_SelectedBy_Text__c",
        "align": "right",
        "sortable":false
    },
    "Final_Service_RM_Text__c":{
        "dataIndex":"Final_Service_RM_Text__c",
        "sortable":false
    },
    "Final_Refer_Out_Reason__c":{
        "dataIndex": "Final_Refer_Out_Reason__c",
        "sortable":false,
        "width": 150
    }, 
    "Final_Refer_Out_Reason_Detail__c":{
        "dataIndex": "Final_Refer_Out_Reason_Detail__c",
        "sortable":false,
        "width": 150
    },
    "Business_Code__c":{
        "dataIndex": "Business_Code__c",
        "sortable":false,
        "width": 150
    }, 
    "Business_Desc__c":{
        "dataIndex": "Business_Desc__c",
        "sortable":false,
        "width": 150
    }, 
    "Credit_Flag__c":{
        "dataIndex": "Credit_Flag__c",
        "sortable":false,
        "width": 150
    }, 
    "Group__c":{
        "dataIndex": "Group__c",
        "sortable":false,
        "customSort": "Group__c",
        "header": 'Flag อุตสาหกรรม',
        "width": 150
    },
    "Income_1M__c":{
        "dataIndex": "Income_1M__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "sortable":true,
        "width": 150
    }, 
    "Total_SME_Limit__c":{
        "dataIndex": "Total_SME_Limit__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "sortable":false,
        "width": 150
    }, 
    "SME_Limit_LI__c":{
        "dataIndex":"SME_Limit_LI__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "sortable":false
      }, 
    "SME_Limit_TF__c":{
        "dataIndex":"SME_Limit_TF__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "sortable":false
      }, 
    "Total_SME_Out__c":{
        "dataIndex": "Total_SME_Out__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "sortable":false,
        "width": 150
    }, 
    "Total_SME_Exposure__c":{
        "dataIndex": "Total_SME_Exposure__c",
        "xtype": "numbercolumn",
        "align": "right",
        "format": "0,000",
        "sortable":false,
        "width": 150
    }, 
    "SOW_SME_Exposure__c":{
        "dataIndex": "SOW_SME_Exposure__c",
        "sortable":false,

        "renderer": function(value) {
            return (value) ? (value + "%") : "";
        }
    }, 
    "SME_Wallet_Size__c":{
        "dataIndex": "SME_Wallet_Size__c",
        "xtype": "numbercolumn",
        "align": "right",
        "format": "0,000",
        "sortable":false,
        "width": 150
    }, 
    "DPD6M__c":{
        "dataIndex": "DPD6M__c",
        "sortable":false,
        "width": 150
    }, 
    "NPL12M__c":{
        "dataIndex": "NPL12M__c",
        "sortable":false,
        "width": 150
    }, 
    "Court_Case_12M__c":{
        "dataIndex": "Court_Case_12M__c",
        "sortable":false,
        "width": 150
    },
    "Court_Case_Current_Year__c":{
        "dataIndex": "Court_Case_Current_Year__c",
        "sortable":false
    }, 
    "SME_BSCORE_1M__c":{
        "dataIndex": "SME_BSCORE_1M__c",
        "header":"ลูกค้าที่ควรโอนขึ้น ME",
        "sortable":false,
        "width": 150
    }, 
    "SME_BSCORE_2M__c":{
        "dataIndex": "SME_BSCORE_2M__c",
        "sortable":false,
        "width": 150
    },
    "SME_BSCORE_3M__c":{
        "dataIndex":"SME_BSCORE_3M__c",
        "sortable":false,
        "width":150
    },
    "AH_Name__c":{
        "dataIndex":"SME_BSCORE_3M__c",
        "sortable":false,
        "width":150
    },
    "NH_Name__c":{
        "dataIndex":"SME_BSCORE_3M__c",
        "sortable":false,
        "width":150
    },
    "Relationship_Affiliate__c":{
        "dataIndex":"Relationship_Affiliate__c",
        "sortable":false,
        "width":150
    },
    "Relationship_Authorized_Director__c":{
        "dataIndex":"Relationship_Authorized_Director__c",
        "sortable":false,
        "width":150
    },
    "Relationship_Joint_Obligor__c":{
        "dataIndex":"Relationship_Joint_Obligor__c",
        "sortable":false,
        "width":150
    },
    "Relationship_Spouse__c":{
        "dataIndex":"Relationship_Spouse__c",
        "sortable":false,
        "width":150
    },
    "Relationship_Stockholder__c":{
        "dataIndex":"Relationship_Stockholder__c",
        "sortable":false,
        "width":150
    },
    "Requester_AH__c":{
        "dataIndex":"Requester_AH__c",
        "sortable":true,
        "width":150
    },
     "Requester_AH_Name__c":{
        "dataIndex":"Requester_AH_Name__c",
        "header":"Requester Approver",
        "sortable":true,
        "width":150
    },
    "Type__c":{
        "dataIndex":"Type__c",
        "text": 'Request Type',
        "sortable":false,
        "width":150
    },
    "Sales_Size__c":{
        "dataIndex":"Sales_Size__c",
        "header":'Sale Size',
        "text":'Sale Size',
        "sortable":true,
        "width":150
    },
    "Refer_Out_Selection__c":{
        "dataIndex": "Year_End_Assignment_Selections__r",
        "sortable": false,
        // "customSort": "Year_End_Assignment_Selections__r.Refer_Out__c",
        "width": 100,
        "text": 'Refer Out',
        // "xtype": "checkcolumn",
        // "editor": {
        //     "xtype": 'checkbox',
        //     "cls": 'x-grid-checkheader-editor'
        // },
        "listeners" : {
            beforecheckchange : function(column, rowIndex) {
                return false;
            }
        }
        ,
        "renderer": function(yearEndSelectionsArray){
            if(Ext.isDefined(yearEndSelectionsArray) && yearEndSelectionsArray.length > 0){
                if(yearEndSelectionsArray[0].Refer_Out__c){
                    return "<input class='gridCheckbox'  type='checkbox' checked='checked'  disabled='disabled'";
                }else{
                    return "<input class='gridCheckbox'  type='checkbox' disabled='disabled'";
                }
            }else{
                return "<input class='gridCheckbox'  type='checkbox' disabled='disabled'";
            }
        }
    },
    "Language__c":{
        "dataIndex": "Year_End_Assignment_Selection__r.Language__c",
        "width": 100,
        "text": 'Refer Out Language'
    },
    "Created_Name":{
        "dataIndex": "CreatedBy.Name",
        "width": 100,
        "text": 'Seleted By'
    },
    "CBS_Sub_Group__c":{
        "dataIndex":"CBS_Sub_Group__c",
        "header": 'CBS Sub Group',
        "sortable":true,
        "width":150
    },
    "CBS_Group__c":{
        "dataIndex":"CBS_Group__c",
        "header": 'CBS Group',
        "sortable":true,
        "width":150
    },
    "Approver_Name__c":{
        "dataIndex":"Approver_Name__c",
        "text": 'Approver Name',
        "sortable":true,
        "width":150
    },
    "Requester_Manager_Approve_Flag__c":{
        "dataIndex":"Requester_Manager_Approve_Flag__c",
        "text": 'TL Approve Flag',
        "sortable":true,
        "width":150
    },
    "Total_Income__c":{
        "dataIndex":"Total_Income__c",
        "header": 'Total Income (YTD)',
        "sortable":true,
        "width":150
    },
    "Requester_Name_Text__c":{
        "dataIndex":"Requester_Name_Text__c",
        "header": 'Requester Name',
        "sortable":true,
        "width":150
    },
    "CreatedBy_Selection__c":{
        "dataIndex": "Year_End_Assignment_Selections__r",
        "sortable": false,
        "width": 100,
        "text": 'Selected By',
        "renderer": function(yearEndSelectionsArray){
            if(Ext.isDefined(yearEndSelectionsArray) && yearEndSelectionsArray.length > 0){
                return yearEndSelectionsArray[0].CreatedBy.Name;
            }
        }
    },
    "AssignTo_Selection__c":{
        "dataIndex": "Year_End_Assignment_Selections__r",
        "sortable": false,
        "width": 100,
        "text": 'Assign To',
        "renderer": function(yearEndSelectionsArray){
            if(Ext.isDefined(yearEndSelectionsArray) && yearEndSelectionsArray.length > 0){
                return yearEndSelectionsArray[0].Selected_By_Name__c;
            }
        }
    },
    "ReferOut_Reason_Selection__c":{
        "dataIndex": "Year_End_Assignment_Selections__r",
        "sortable": false,
        "width": 100,
        "text": 'Refer Out Reason',
        "renderer": function(yearEndSelectionsArray){
            if(Ext.isDefined(yearEndSelectionsArray) && yearEndSelectionsArray.length > 0){
                return yearEndSelectionsArray[0].Refer_Out_Reason__c;
            }
        }
    }

};