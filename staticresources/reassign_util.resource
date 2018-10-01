function requestApex(method,mdata) {
    var deferred = new Ext.Deferred();
    var response = sforce.apex.execute("YearEndAssignment_Webservice", method, mdata);

    if (response && response[0].success) {
        deferred.resolve(response[0]);
    } else deferred.reject(response[0].errorMessage);

    return deferred.promise;
};
function requestApexWithClassName(className,method,mdata) {
    var deferred = new Ext.Deferred();
    var response = sforce.apex.execute(className, method, mdata);

    if (response && response[0].success) {
        deferred.resolve(response[0]);
    } else deferred.reject(response[0].errorMessage);

    return deferred.promise;
};
function savingBulk(requestObj) {
    var deferred = new Ext.Deferred();
    SME_BulkAssignment_ListView_Controller.saveBulk(requestObj, function(results, e) {
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
    SME_BulkAssignment_ListView_Controller[operate](requestObj, function(results, e) {
        console.log(results, e);
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
};

Ext.util.Format.currencySign = ' ';
Ext.util.Format.currencyPrecision = 0;

var accountBottomUpSumColumn = [
            {   
                dataIndex:'summary',
                width: 190
            },{
                text: "<div style='text-align:center;'>Transaction Fee</div>",  
                dataIndex:'totalTransActionFee',
                width: 190,
                align: "right",
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = Ext.util.Format.currency(value);
                    return value;
                }
            },{
                text: "<div style='text-align:center;'>Main Operating Bank</div>",  
                dataIndex:'totalMainOperatingBank',
                width: 190,
                align: "right",
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = Ext.util.Format.currency(value);
                    return value;
                }
            },{
                text: "<div style='text-align:center;'>Deal Base Fee</div>",  
                dataIndex:'totalDealBaseFee',
                width: 190,
                align: "right",
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = Ext.util.Format.currency(value);
                    return value;
                }
            },{
                text: "<div style='text-align:center;'>Total Bottom Up</div>",  
                dataIndex:'totalBottomUp',
                width: 190,
                align: "right",
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = Ext.util.Format.currency(value);
                    return value;
                }
            }
    ];

var fields_base = {
    //CBS
    /////////////////////////////////////////////////////////////////////////////////////
    "CBS_Account_Name":{
        "dataIndex": "Name_Report__c",
        "header": "Customer Name",
        "sortable": false,
        "locked": true,
        "renderer": Ext.util.Format.htmlDecode,
        "width": 200
    },
    "CBS_Account_Group":{
        "dataIndex": "Group__c",
        "header": "Group",
        "sortable": true,
        "locked": false,
        "width": 100
    },
    "CBS_Account_Sub_Group":{
        "dataIndex": "Sub_Group__c",
        "header": "Sub Group",
        "sortable": true,
        "locked": false,
        "width": 100
    },
    "CBS_Account_Current_Owner":{
        "dataIndex": "Current_Owner_Extension__r.Name",
        "header": "Current Owner",
        "sortable": true,
        "locked": false,
        "width": 200
    },
    "CBS_Account_Current_Team_Name":{
        "dataIndex": "Current_Team_Name__r.Name",
        "header": "Current Team Name",
        "sortable": true,
        "locked": false,
        "width": 300
    },
    "CBS_Account_Status__c":{
        "dataIndex": "Status__c",
        "header": "Credit Status",
        "sortable": true,
        "locked": false,
        "width": 100
    },
    "CBS_Account_Income_To_Bank_This_Year__c":{
        "dataIndex": "Income_to_Bank_This_Year__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "header": "Income To Bank This Year",
        "sortable": true,
        "locked": false,
        "width": 200
    },
    "AssignmentOwner__r.Name":{
        "dataIndex": "AssignmentOwner__r.Name",
        "header": "Assigned Owner Name",
        "sortable": true,
        "locked": false,
        "editable": false,
        "width": 120
    },
    "AssignmentOwner__r.Team_Name__c":{
        "dataIndex": "AssignmentOwner__r.Team_Name__c",
        "header": "Assigned Owner Team Name",
        "sortable": true,
        "locked": false,
        "editable": false,
        "width": 120
    },
    "Bulk_Queue_Name__c":{
        "dataIndex": "BulkAssignmentQueue__r.Name",
        "header": "Bulk Assignment Queue Name",
        "sortable": true,
        "locked": true,
        "width": 200,
        "renderer" : function(value,record,dataIndex,cell,column) {
            
            if(dataIndex.data.BulkAssignmentQueue__r.Request_Reason_Picklist__c != 'อื่นๆ (โปรดระบุ)'){
                value = "<a style='cursor:pointer;text-decoration: underline;'>"+value+"</a>";
            }
            
            return value;
        }
    },
    "Bulk_Account_CIS__c":{
        "dataIndex": "CIS_ID__r.CIS__c",
        "sortable": true,
        "header": "CIS",
        "text" : "CIS",
        "align": "right",
        "width": 70,
        "locked": true,
        "customSort": "CIS_ID__r.CIS_Number__c",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "Bulk_Account_CIS_Number__c":{
        "dataIndex": "CIS_ID__r.CIS__c",
        "sortable": true,
        "header": "CIS",
        "width": 70,
        "locked": true,
        "customSort": "CIS_ID__r.CIS_Number__c",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "Bulk_Account_Name_Report__c":{
        "dataIndex": "CIS_ID__r.Name_Report__c",
        "sortable": false,
        "header": "Customer Name",
        "renderer": Ext.util.Format.htmlDecode,
        "locked": true,
        "width": 150
    },
    "Bulk_Queue_Request_Reason_Picklist__c":{
        "dataIndex": "BulkAssignmentQueue__r.Request_Reason_Picklist__c",
        "header": "Request Reason",
        "sortable": false,
        "locked": false,
        "width": 200
    },
    "Bulk_Queue_Request_Reason_Text__c":{
        "dataIndex": "BulkAssignmentQueue__r.Request_Reason_Text__c",
        "header": "Request Reason Text",
        "sortable": false,
        "locked": false,
        "width": 200
    },
    "Bulk_Account_Primary_Segment_Code__c":{
        "dataIndex": "CIS_ID__r.Primary_Segment_Code__c",
        "header": "Segment",
        "sortable": true,
        "locked": false,
        "width": 70
    },
    "Bulk_Account_Group__c":{
        "dataIndex": "CIS_ID__r.Group__c",
        "header": "Group",
        "sortable": true,
        "locked": false,
        "width": 100
    },
    "Bulk_Account_Sub_Group__c":{
        "dataIndex": "CIS_ID__r.Sub_Group__c",
        "header": "Sub Group",
        "sortable": true,
        "locked": false,
        "width": 100
    },
    "Bulk_Account_Owner_Name__c":{
        "dataIndex": "CIS_ID__r.Owner.Name",
        "header": "Current Owner Name",
        "sortable": true,
        "locked": false,
        "width": 150
    },
    "Bulk_Account_Owner_Team_Name__c":{
        "dataIndex": "CIS_ID__r.Current_Team_Name__r.Name",
        "header": "Current Owner Team Name",
        "sortable": true,
        "locked": false,
        "width": 200
    },
    "Bulk_Account_AssignTo_Owner_Name__c":{
        "dataIndex": "AssignmentOwner__r.Name",
        "header": "Assigned Owner Name",
        "sortable": false,
        "locked": false,
        "width": 150
    },
    "Bulk_Account_AssignTo_Team_Name__c":{
        "dataIndex": "Assigned_Owner_Team_Name__c",
        "header": "Assigned Owner Team Name",
        "sortable": false,
        "locked": false,
        "width": 250
    },
    "Bulk_Account_Submit_Date__c":{
        "dataIndex": "BulkAssignmentQueue__r.Submit_Date__c",
        "header": "Submit Date",
        "sortable": false,
        "locked": false,
        "width": 200
    },
    "Bulk_Account_Status__c":{
        "dataIndex": "CIS_ID__r.Status__c",
        "header": "Credit Status",
        "sortable": false,
        "locked": false,
        "width": 100
    },
    "Bulk_Account_Income_To_Bank_This_Year__c":{
        "dataIndex": "CIS_ID__r.Income_to_Bank_This_Year__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "header": "Income To Bank This Year",
        "sortable": true,
        "locked": false,
        "width": 200
    },
    "Rejected_Reason__c":{
        "dataIndex": "Rejected_Reason__c",
        "header": "Reject Reason",
        "sortable": false,
        "locked": true,
        "editable": false,
        "width": 120,
        "editor": 'textarea'
    },
    "Rejected_Reason_Text__c":{
        "dataIndex": "Rejected_Reason_Text__c",
        "header": "Reject Reason Text",
        "sortable": false,
        "locked": true,
        "editable": false,
        "width": 120
    },

    ///////////////// Sales Target Grid Columns ///////////////////////
    "Sales_Target_Name__c":{
        "dataIndex": "Name__r.Name",
        "header": "Name",
        "sortable": false,
        "locked": false,
        "editable": false,
        "width": 190,
        summaryRenderer: function(value, summaryData, dataIndex) {
            return Ext.String.format('Summary ');
        }
    },
    "Total_Miracle_Income__c":{
        "dataIndex": "Total_Miracle_Income__c",
        "text": "<p>Total Miracle Income</p><p class ='MiracleTeamTargetSum'></p>",
        "columns":[
            {
                "dataIndex": "Total_Miracle_New_Target__c",
                "header": "<div style='text-align:center'>Total Miracle</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    value = 0;
                    meta.style = 'background-color:lightgrey';

                    if(dataIndex.data.Transaction_Fee_New_Target__c === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c !== undefined){
                                value = value+dataIndex.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                            }
                        }
                    }else{
                        value = value+dataIndex.data.Transaction_Fee_New_Target__c;
                    }

                    if(dataIndex.data.Main_Operating_Bank_New_Target__c === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c !== undefined){
                                value = value+dataIndex.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                            }
                        }
                    }else{
                        value = value+dataIndex.data.Main_Operating_Bank_New_Target__c;
                    }

                    if(dataIndex.data.Deal_Base_Fee_New_Target__c === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c !== undefined){
                                value = value+dataIndex.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                            }
                        }
                    }else{
                        value = value+dataIndex.data.Deal_Base_Fee_New_Target__c;
                    }

                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        
                        var recordData = 0;

                        if(record.data.Transaction_Fee_New_Target__c === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c !== undefined){
                                    recordData = recordData+record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                                }
                            }
                        }else{
                            recordData = recordData+record.data.Transaction_Fee_New_Target__c;
                        }

                        if(record.data.Main_Operating_Bank_New_Target__c === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c !== undefined){
                                    recordData = recordData+record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                                }
                            }
                        }else{
                            recordData = recordData+record.data.Main_Operating_Bank_New_Target__c;
                        }

                        if(record.data.Deal_Base_Fee_New_Target__c === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c !== undefined){
                                    recordData = recordData+record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                                }
                            }
                        }else{
                            recordData = recordData+record.data.Deal_Base_Fee_New_Target__c;
                        }
                        
                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Total_Miracle_Target__c",
                "header": "<div style='text-align:center'>Total Miracle</br>Target</div>",
                "sortable": false,
                "locked": false,
                "width": 190,
                "align": "right",
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = dataIndex.data.Transaction_Fee_Target__c+dataIndex.data.Main_Operating_Bank_Target__c+dataIndex.data.Deal_Base_Fee_Target__c;

                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        
                        var recordData = 0;


                        if(!isNaN(record.data.Transaction_Fee_Target__c)){
                            recordData = recordData+record.data.Transaction_Fee_Target__c;
                        }

                        if(!isNaN(record.data.Main_Operating_Bank_Target__c)){
                            recordData = recordData+record.data.Main_Operating_Bank_Target__c;
                        }

                        if(!isNaN(record.data.Deal_Base_Fee_Target__c)){
                            recordData = recordData+record.data.Deal_Base_Fee_Target__c;
                        }
                        
                        
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Total_Miracle_Bottom_Up__c",
                "header": "<div style='text-align:center'>Total Miracle</br>Bottom Up</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    
                    meta.style = 'background-color:lightgrey';
                    value = dataIndex.data.Transaction_Fee_Bottom_Up_Sum__c+dataIndex.data.Main_Operating_Bank_Bottom_Up_Sum__c+dataIndex.data.Deal_Base_Fee_Bottom_Up_Sum__c;
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }

                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData;
                        recordData = record.data.Transaction_Fee_Bottom_Up_Sum__c+record.data.Main_Operating_Bank_Bottom_Up_Sum__c+record.data.Deal_Base_Fee_Bottom_Up_Sum__c;

                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Transaction_Fee__c":{
        "dataIndex": "Transaction_Fee_Team_Target__c",
        "text": "<p>Transaction Fee</p><p class ='TransactionFeeTeamTargetElement'></p>",
        "columns" :[
                {
                "dataIndex": "Transaction_Fee_New_Target__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                "editable": true,
                "editor": 'numberfield',
                "allowBlank": true,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    
                    if(value === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c != null){
                                value = dataIndex.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                            }else{
                                value = null;
                            }
                        }else{
                            value = null;
                        }
                    }

                    if(value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }

                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){

                        var recordData = record.data.Transaction_Fee_New_Target__c;
                        if(recordData === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c != null){
                                    recordData = record.data.Bulk_Assignments_Sales_target__r[0].Transaction_Fee_New_Target__c;
                                }else{
                                    recordData = null;
                                }
                            }else{
                                recordData = null;
                            }
                        }

                        if(recordData != null){
                            summary += recordData;
                        }

                        
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Transaction_Fee_Target__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Transaction_Fee_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Transaction_Fee_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Transaction_Fee_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Main_Operating_Bank__c":{
        "dataIndex": "Main_Operating_Bank_Team_Target__c",
        "text": "<p>Main Operating Bank</p><p class='MainOperatingBankTeamTargetElement'></p>",
        "sortable": false,
        "locked": false,
        "editable": false,
        "columns" :[
                {
                "dataIndex": "Main_Operating_Bank_New_Target__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": true,
                "width": 190,
                "editor": 'numberfield',
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    
                    if(value === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c != null){
                                value = dataIndex.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                            }else{
                                value = null;
                            }
                        }else{
                            value = null;
                        }
                    }

                    

                    if(value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        
                        var recordData = record.data.Main_Operating_Bank_New_Target__c;
                        if(recordData === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c != null){
                                    recordData = record.data.Bulk_Assignments_Sales_target__r[0].Main_Operating_Bank_New_Target__c;
                                }else{
                                    recordData = null;
                                }
                            }else{
                                recordData = null;
                            }
                        }

                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Main_Operating_Bank_Target__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Main_Operating_Bank_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Main_Operating_Bank_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Main_Operating_Bank_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Deal_Base_Fee__c":{
        "dataIndex": "Deal_Base_Fee_Team_Target__c",
        "text": "<p>Deal Base Fee</p><p class='DealBaseFeeTeamTargetElement'></p>",
        "sortable": false,
        "locked": false,
        "editable": false,
        "columns" :[
                {
                "dataIndex": "Deal_Base_Fee_New_Target__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": true,
                "width": 190,
                "editor": 'numberfield',
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    if(value === undefined){
                        if(dataIndex.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                            if(dataIndex.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c != null){
                                value = dataIndex.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                            }else{
                                value = null;
                            }
                        }else{
                            value = null;
                        }
                    }

                    if(value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Deal_Base_Fee_New_Target__c;
                        if(recordData === undefined){
                            if(record.data['Bulk_Assignments_Sales_target__r'] !== undefined){
                                if(record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c != null){
                                    recordData = record.data.Bulk_Assignments_Sales_target__r[0].Deal_Base_Fee_New_Target__c;
                                }else{
                                    recordData = null;
                                }
                            }else{
                                recordData = null;
                            }
                        }
                        
                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Deal_Base_Fee_Target__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Deal_Base_Fee_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.number(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Deal_Base_Fee_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Deal_Base_Fee_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    //////////////////////////// Bulk Sales Target Grid Columns
    "Bulk_Sales_Target_Name__c":{
        "dataIndex": "Sales_Name__r.Name__r.Name",
        "header": "Name",
        "sortable": false,
        "locked": false,
        "editable": false,
        "width": 190,
        summaryRenderer: function(value, summaryData, dataIndex) {
            return Ext.String.format('Summary');
        }
    },
    "Bulk_Sales_Total_Miracle_Income__c":{
        "dataIndex": "Bulk_Sales_Total_Miracle_Income__c",
        "text": "<p>Total Miracle Income</p><p id ='BulkSalesMiracleTeamTargetSum'></p>",
        "columns":[
            {
                "dataIndex": "Bulk_Sales_Total_Miracle_New_Target__c",
                "header": "<div style='text-align:center'>Total Miracle</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    
                    var miracleFeeTeamTargetSum = dataIndex.data.Sales_Name__r.Team_Target__r.Transaction_Fee_Team_Target__c+dataIndex.data.Sales_Name__r.Team_Target__r.Main_Operating_Bank_Team_Target__c+dataIndex.data.Sales_Name__r.Team_Target__r.Deal_Base_Fee_Team_Target__c;
                    var miracleFeeTeamTargetSumElement = document.getElementById('BulkSalesMiracleTeamTargetSum');

                    if(miracleFeeTeamTargetSum === undefined){
                        miracleFeeTeamTargetSum = 0;
                    }

                    miracleFeeTeamTargetSum = Ext.util.Format.currency(miracleFeeTeamTargetSum);
                    miracleFeeTeamTargetSumElement.innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+miracleFeeTeamTargetSum+'</td></tr></table>';
                    
                    meta.style = 'background-color:lightgrey';
                    
                    value = dataIndex.data.Transaction_Fee_New_Target__c+dataIndex.data.Main_Operating_Bank_New_Target__c+dataIndex.data.Deal_Base_Fee_New_Target__c;

                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData;
                        recordData = record.data.Transaction_Fee_New_Target__c+record.data.Main_Operating_Bank_New_Target__c+record.data.Deal_Base_Fee_New_Target__c;

                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
            ,{
                "dataIndex": "Bulk_Sales_Total_Miracle_Target__c",
                "header": "<div style='text-align:center'>Total Miracle</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = dataIndex.data.Sales_Name__r.Transaction_Fee_Target__c+dataIndex.data.Sales_Name__r.Main_Operating_Bank_Target__c+dataIndex.data.Sales_Name__r.Deal_Base_Fee_Target__c;
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    return value;
                },
                summaryType:function(records){

                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData;
                        recordData = record.data.Sales_Name__r.Transaction_Fee_Target__c+record.data.Sales_Name__r.Main_Operating_Bank_Target__c+record.data.Sales_Name__r.Deal_Base_Fee_Target__c;

                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Bulk_Sales_Total_Miracle_Bottom_Up__c",
                "header": "<div style='text-align:center'>Total Miracle</br>Bottom Up</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    value = dataIndex.data.Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c+dataIndex.data.Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c+dataIndex.data.Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c;
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData;
                        recordData = record.data.Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c+record.data.Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c+record.data.Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c;

                        if(recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Bulk_Sales_Transaction_Fee__c":{
        "dataIndex": "Transaction_Fee_Team_Target__c",
        "text": "<p>Transaction Fee</p><p id='BulkSalesTransactionFeeTeamTargetElement'></p>",
        "sortable": false,
        "locked": false,
        "editable": false,
        "columns" :[
                {
                "dataIndex": "Transaction_Fee_New_Target__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    var transactionFeeTeamTarget = dataIndex.data.Sales_Name__r.Team_Target__r.Transaction_Fee_Team_Target__c;
                    var transactionFeeTeamTargetElement = document.getElementById('BulkSalesTransactionFeeTeamTargetElement');

                    if(transactionFeeTeamTarget === undefined){
                        transactionFeeTeamTarget = 0;
                    }

                    transactionFeeTeamTarget = Ext.util.Format.currency(transactionFeeTeamTarget);

                    transactionFeeTeamTargetElement.innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+transactionFeeTeamTarget+'</td></tr></table>';


                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Transaction_Fee_New_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }

            },{
                "dataIndex": "Sales_Name__r.Transaction_Fee_Target__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Transaction_Fee_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Transaction Fee</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Bulk_Sales_Main_Operating_Bank__c":{
        "dataIndex": "Main_Operating_Bank_Team_Target__c",
        "text": "<p>Main Operating Bank</p><p id='BulkSalesMainOperatingBankTeamTargetElement'></p>",
        "sortable": false,
        "locked": false,
        "editable": false,
        "columns" :[
                {
                "dataIndex": "Main_Operating_Bank_New_Target__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    var mainOperatingBankTeamTarget = dataIndex.data.Sales_Name__r.Team_Target__r.Main_Operating_Bank_Team_Target__c;
                    var mainOperatingBankTeamTargetElement = document.getElementById('BulkSalesMainOperatingBankTeamTargetElement');

                    if(mainOperatingBankTeamTarget === undefined){
                        mainOperatingBankTeamTarget = 0;
                    }

                    mainOperatingBankTeamTarget = Ext.util.Format.currency(mainOperatingBankTeamTarget);

                    mainOperatingBankTeamTargetElement.innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+mainOperatingBankTeamTarget+'</td></tr></table>';

                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Main_Operating_Bank_New_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Sales_Name__r.Main_Operating_Bank_Target__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Main_Operating_Bank_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.number(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Main Operating Bank</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    "Bulk_Sales_Deal_Base_Fee__c":{
        "dataIndex": "Deal_Base_Fee_Team_Target__c",
        "text": "<p>Deal Base Fee</p><p id='BulkSalesDealBaseFeeTeamTargetElement'></p>",
        "sortable": false,
        "locked": false,
        "editable": false,
        "columns" :[
                {
                "dataIndex": "Deal_Base_Fee_New_Target__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>New Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    var dealBaseFeeTeamTarget = dataIndex.data.Sales_Name__r.Team_Target__r.Deal_Base_Fee_Team_Target__c;
                    var dealBaseFeeTeamTargetElement = document.getElementById('BulkSalesDealBaseFeeTeamTargetElement');

                    if(dealBaseFeeTeamTarget === undefined){
                        dealBaseFeeTeamTarget = 0;
                    }

                    dealBaseFeeTeamTarget = Ext.util.Format.currency(dealBaseFeeTeamTarget);

                    dealBaseFeeTeamTargetElement.innerHTML = '<p><table class="x-grid-item"><tr><td style="border: 1px;width:240px;align:center;">Team Target</td><td style="border: 1px;width:310px;align:center;">'+dealBaseFeeTeamTarget+'</td></tr></table>';


                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Deal_Base_Fee_New_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            },{
                "dataIndex": "Sales_Name__r.Deal_Base_Fee_Target__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>Target</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Deal_Base_Fee_Target__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }

            },{
                "dataIndex": "Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c",
                "header": "<div style='text-align:center'>Deal Base Fee</br>Bottom Up Summary</div>",
                "align": "right",
                "sortable": false,
                "locked": false,
                "editable": false,
                "width": 190,
                "renderer" : function(value,meta,dataIndex,cell,column) {
                    meta.style = 'background-color:lightgrey';
                    if(value !== undefined && value != null){
                        value = Ext.util.Format.currency(value);
                    }else{
                        value = 0;
                    }
                    
                    return value;
                },
                summaryType:function(records){
                    var summary = 0;
                    Ext.Array.forEach(records, function (record){
                        var recordData = record.data.Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c;
                        if(recordData !== undefined && recordData != null){
                            summary += recordData;
                        }
                    });
                    return Ext.util.Format.currency(summary);
                },
                summaryRenderer: function(value, summaryData, dataIndex,metaData) {
                    metaData.style = "background-color:lightgrey";
                    return value;
                }
            }
        ]
    },
    //SME
    //////////////////////////////////////////////////////////////////////////////////
    "CIS__c":{
        "dataIndex": "CIS__c",
        "sortable": true,
        "header": "CIS ID",
        "align": "right",
        "width": 70,
        "locked": true,
        "customSort": "CIS_Number__c",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "CIS_Number__c":{
        "dataIndex": "CIS__c",
        "sortable": true,
        "header": "CIS",
        "align": "right",
        "width": 70,
        "locked": true,
        "customSort": "CIS_Number__c",
        "filter": {
            "type": "numstring",
            "operator": "=",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "NameSurnameTHCompanyName_Formula__c":{
        "dataIndex": "NameSurnameTHCompanyName_Formula__c",
        "header": "Name",
        "renderer": Ext.util.Format.htmlDecode,
        "locked": true,
        "sortable" : false,
        "width": 150
    },
    "Primary_Segment_Code__c":{
        "dataIndex": "Primary_Segment_Code__c",
        "header": "Primary Segment",
        "sortable": false,
        "locked": true,
        "width": 100
    },
    "SME_Temporary_Customer__c":{
        "dataIndex": "SME_Temporary_Customer__r.Name",
        "width": 150/*,
        "renderer": function(userExtensionArray){
            //console.log(userExtensionArray);
            if(Ext.isDefined(userExtensionArray)){
                return userExtensionArray.Name;
            }
        }*/
    },
    "Current_Owner_Extension__c":{
        "dataIndex": "Current_Owner_Extension__r.Name",
        "width": 150/*,
        "renderer": function(userExtensionArray){
            //console.log(userExtensionArray);
            if(Ext.isDefined(userExtensionArray)){
                return userExtensionArray.Name;
            }
        }*/
    },
    "Current_Team_Name__c":{
        "dataIndex": "Current_Team_Name__r.Name",
        "width": 150/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Permanent_Owner_Extension__c":{
        "dataIndex": "Permanent_Owner_Extension__r.Name",
        "width": 150/*,
        "renderer": function(userExtensionArray){
            //console.log(userExtensionArray);
            if(Ext.isDefined(userExtensionArray)){
                return userExtensionArray.Name;
            }
        }*/
    },
    "Permanent_Team_Name__c":{
        "dataIndex": "Permanent_Team_Name__r.Name",
        "width": 200/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Previous_Owner_Extension__c":{
        "dataIndex": "Previous_Owner_Extension__r.Name",
        "width": 150/*,
        "renderer": function(userArray){
            //console.log(userArray);
            if(Ext.isDefined(userArray)){
                return userArray.Name;
            }
        }*/
    },
    "Previous_Team_Name__c":{
        "dataIndex": "Previous_Team_Name__r.Name",
        "width": 200/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Service_RM__c":{
        "dataIndex": "Service_RM__r.Name",
        "width": 150/*,
        "renderer": function(userArray){
            //console.log(userArray);
            if(Ext.isDefined(userArray)){
                return userArray.Name;
            }
        }*/
    },
    "Last_Visited_Date__c":{
        "dataIndex": "Last_Visited_Date__c",
        "width": 150,
        "renderer": function(dateArray){
            if ((dateArray == null) || (dateArray == ''))
                return null;
            date_as_sent = new Date(parseInt(dateArray));
            //console.log(date_as_sent);
            return new Date(date_as_sent.getUTCFullYear(),
                            date_as_sent.getUTCMonth(),
                            date_as_sent.getUTCDate()).toDateString();
        }
    },
    "Last_Setup_Date__c":{
        "dataIndex": "Last_Setup_Date__c",
        "width": 150,
        "renderer": function(dateArray){
            if ((dateArray == null) || (dateArray == ''))
                return null;
            date_as_sent = new Date(parseInt(dateArray));
            //console.log(date_as_sent);
            return new Date(date_as_sent.getUTCFullYear(),
                            date_as_sent.getUTCMonth(),
                            date_as_sent.getUTCDate()).toDateString();
        }
    },
    "District__c":{
        "dataIndex": "Addresses__r",
        "sortable": false,
        "width": 100,
        "text": 'District',
        "renderer": function(addressesArray){
            if(Ext.isDefined(addressesArray) && addressesArray.length > 0){
            	return addressesArray[0].District__c;
            }
        }
    },
    "Province__c":{
        "dataIndex": "Addresses__r",
        "sortable": false,
        "width": 100,
        "text": 'Province',
        "renderer": function(addressesArray){
            if(Ext.isDefined(addressesArray) && addressesArray.length > 0){
            	return addressesArray[0].Province__c;
            }
        }
    },"AF_Port2__c":{
        "dataIndex": "AF_Port2__c",
        "sortable": false,
        "width": 70,
        "header": "Port2",
        "listeners" : {
            beforecheckchange : function(column, rowIndex) {
                return false;
            }
        },
        "menuDisabled" : true,
        "renderer": function(recordData){
            if(Ext.isDefined(recordData) && recordData == true){
                return "<input class='gridCheckbox'  type='checkbox' checked='checked'  disabled='disabled'";
            }else{
                return "<input class='gridCheckbox'  type='checkbox' disabled='disabled'";
            }
        }
    }, "Max_Wealth_Branch":{
        "dataIndex": "Max_Wealth_Branch__r.Name",
        "header": "Max Wealth Branch",
        "sortable": true,
        "width": 190,
        "customSort": "Max_Wealth_Branch__r.Name",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search สาขา..."
            }
        }
    }, "RBS_Branch_Closeness":{
        "dataIndex": "RBS_Branch_Closeness__r.Name",
        "header": "สาขาคนสนิท",
        "sortable": true,
        "width": 190,
        "customSort": "RBS_Branch_Closeness__r.Name",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search สาขาคนสนิท..."
            }
        }
    },
    "Port_Pool__c":{
        "dataIndex": "Port_Pool__c",
        "sortable": false,
        "width": 80,
        "header": 'Port/Pool'
    },
    "Secondary_Segment_Code__c":{
        "dataIndex": "Secondary_Segment_Code__c",
        "sortable": false,
        "width": 120,
        "header": 'Secondary Segment'
    }, "AF_Temporary_Customer":{
        "dataIndex": "AF_Temporary_Customer__r.Name",
        "header": "AF Temporary Customer",
        "sortable": true,
        "width": 190,
        "customSort": "AF_Temporary_Customer__r.Name",
    }, "AF_Port_Pool_Formula__c":{
        "dataIndex": "AF_Port_Pool_Formula__c",
        "header": "Port/Pool",
        "sortable": true,
        "width": 100,
    }








    //,
};