({
    validateRecord : function(component, event, helper) {
        var mRecordId = component.get('v.recordId');
        console.log('mRecordId:' + mRecordId);
        if(mRecordId == undefined || mRecordId == null) {
            var urlName = window.location.href;
            var str = urlName.split('/');
            var length = str.length - 2;
            if(str[length] == 'Opportunity'){      
                 str[length] = null;
            }
            mRecordId = str[length];
        }
        var getAccountInfo = component.get('c.getAccountInformation');
        getAccountInfo.setParams({
            "CustomerId" :  mRecordId
        });
        getAccountInfo.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var resp = JSON.parse(a.getReturnValue());
                if(resp.result == 'SUCCESS') {
                    var data = resp.account;
                    helper.createNewRecord(component, event, helper, data);
                } else {
                    console.log('error:' + resp.message);
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast(resp.message, 'error');
                }
            }
        });
        if(mRecordId != null){
            $A.enqueueAction(getAccountInfo);
        }else{            
            helper.createNewRecord(component, event, helper, null);
        }
    },
    createNewRecord : function(component, event, helper, data) {
        console.log('helper.createNewRecord');
        var createOpportunity = $A.get("e.force:createRecord");
        var mToday = new Date();
        var yearInt = mToday.getFullYear();
        var monthString = '' + (mToday.getMonth() + 1);
        var dayString = '' + mToday.getDate();
        var needToCloseSubTab = false;
        var locale = $A.get("$Locale.language");
        if(locale == 'th') yearInt = mToday.getFullYear() + 543;
        if(monthString.length < 2) monthString = '0' + monthString;
        if(dayString.length < 2) dayString = '0' + dayString;
        var dateString = yearInt + "/" + monthString+ "/" + dayString;
        mToday.setDate(mToday.getDate()+7);
        var dateToday = mToday;
        component.set('v.dateToday', dateToday);
        
        if(data){
            if(data.Customer_s_Business_Code__c) {
                createOpportunity.setParams({
                    "entityApiName": "Opportunity",
                    "defaultFieldValues": {
                        'CloseDate' : dateToday,
                        'AccountId' : data.Id,
                        'StageName' : 'Open',
                        'Name'      : dateString + '_' + data.Name,
                        'Business_Code_Formula__c' :  data.Customer_s_Business_Code__c   
                    }
                });  
            } else {
                createOpportunity.setParams({
                    "entityApiName": "Opportunity",
                    "defaultFieldValues": {
                        'CloseDate' : dateToday,
                        'AccountId' : data.Id,
                        'StageName' : 'Open',
                        'Name'      : dateString + '_' + data.Name
                    }
                });
            }
        } else {
            needToCloseSubTab = true;
            createOpportunity.setParams({
                "entityApiName": "Opportunity",
                "defaultFieldValues": {
                    'CloseDate' : dateToday,
                    'StageName' : 'Open'
                }
            }); 
        }
        $A.get("e.force:closeQuickAction").fire();
        console.log('before createOpportunity');
        window.loaded = true;
        createOpportunity.fire();
        console.log('after createOpportunity');
        var workspaceAPI = component.find("workspace");
        if(needToCloseSubTab && workspaceAPI != undefined) {
             helper.closeTab(component, createOpportunity, workspaceAPI);
        }
    },
    showToast: function(message, type) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": "dismissible",
            "message": message,
            "type": type,
            "duration": "5000"
        });
        resultsToast.fire();
    },
    closeTab : function(component, createOpportunity, workspaceAPI) {
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            window.setTimeout(
                $A.getCallback(function() {
                    workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                        console.log('closeTab response:' + response);
                    }).catch(function(error) {
                        console.log('closeTab error:'+error);
                    });
                }), 500
            );
        }).catch(function(error) {
            console.log('getFocusedTabInfo error:'+error);
        });
    },
})