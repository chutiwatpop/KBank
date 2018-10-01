function createCustomerOwnership(accountObj,userObj,profileName){
    /*var additionUserObj = sforce.connection.query("SELECT Id,Segment__c FROM User WHERE Id='"+userObj.Id+"'");
    var additionUserRecords = additionUserObj.getArray("records");
    var additionUserRecord = additionUserRecords[0];*/

    var customerRequestObj = sforce.connection.query("SELECT Id,Approval_Status__c FROM Customer_Ownership_Request__c WHERE CIS_ID__c='"+accountObj.Id+"' AND OwnerID='"+userObj.Id+"' AND Approval_Status__c='Approval In Progress' ORDER BY CreatedDate DESC LIMIT 1");
    var customerRequestRecords = customerRequestObj.getArray("records");
    
    if(profileName!='SME-RM') alert('Only RM can request for official ownership');
    else if(accountObj.OwnerId == userObj.Id && accountObj.Port_Pool__c == 'Port') alert('Customer already in your port');
    else if(customerRequestRecords && customerRequestRecords.length > 0) alert('Request Ownership in Progress');
    else if(!(accountObj.Primary_Segment_Code__c=='SM' || accountObj.Primary_Segment_Code__c=='SR' || accountObj.Primary_Segment_Code__c=='LM' || accountObj.Primary_Segment_Code__c=='LR' || accountObj.Primary_Segment_Code__c=='UM' || accountObj.Primary_Segment_Code__c=='UR')) alert('Customer must be SME customer');
    else{
        
        /*var accountUserObj = sforce.connection.query("SELECT Id,ManagerId,Manager.Manager.Email,Manager.Manager.Manager.Email,Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id='"+accountObj.OwnerId+"'");
        var accountUserRecords = accountUserObj.getArray("records");
        if(accountUserRecords && accountUserRecords.length > 0){*/
            var response = sforce.apex.execute('Ownership_Service', 'createOwnerShip',{accountString : JSON.stringify(accountObj),userString : JSON.stringify(userObj)});

            if(response[0].success){
                alert('Create Ownership Request Success.');
                window.location.reload();
            }
            else alert('Failed to Create Ownership Request ' + response[0].msg);
            /*var accountUserRecord = accountUserRecords[0];
            var ownerObj = new sforce.SObject('Customer_Ownership_Request__c');
            ownerObj.Request_Type__c = "Request Ownership";
            ownerObj.CIS_ID__c = accountObj.Id;
            ownerObj.OwnerID = userObj.Id;
            ownerObj.Requestor_TM__c = userObj.ManagerId;
            ownerObj.Current_Owner__c = accountObj.OwnerId;
            ownerObj.Current_Owner_TM__c = (accountUserRecord.ManagerId)?accountUserRecord.ManagerId:'';
            ownerObj.Current_Owner_Email_Same_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c == userObj.RC_Code__c && accountUserRecord.Profile && accountUserRecord.Profile.Name == "SME-RM")?accountUserRecord.Email:'';
            ownerObj.Current_Owner_Email_Other_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c != userObj.RC_Code__c && accountUserRecord.Profile && accountUserRecord.Profile.Name == "SME-RM")?accountUserRecord.Email:'';
            ownerObj.Other_Team_NH_Email__c = (additionUserObj.NH_Employee_ID__c != additionUserObj.NH_Employee_ID__c && additionUserObj.Manager!=null && additionUserObj.Manager.Manager!=null && additionUserObj.Manager.Manager.Manager!=null)?additionUserObj.Manager.Manager.Manager.Email:'';
            ownerObj.Other_Team_AH_Email__c = (additionUserObj.Manager!=null && additionUserObj.Manager.Manager!=null && ((additionUserObj.NH_Employee_ID__c != additionUserObj.NH_Employee_ID__c) || ((additionUserObj.NH_Employee_ID__c == additionUserObj.NH_Employee_ID__c) && (additionUserObj.AH_Employee_ID__c != additionUserObj.AH_Employee_ID__c))))?additionUserObj.Manager.Manager.Email:'';

            if(accountUserRecord.Profile.Name != "SME-SME Admin"){
                var resultOwner = sforce.connection.create([ownerObj]);
                if(resultOwner[0].success == 'true')
                {
                    alert('Create Ownership Request Success.');
                    window.location.reload();
                }else alert('Failed to Create Ownership Request ' + resultOwner[0].errors.message);
            }else{
                var result = sforce.connection.create([ownerObj]);
                if(result[0].success == 'true')
                {
                    alert('Create Ownership Request Success.');
                    window.location.reload();
                }else alert('Failed to Create Ownership Request : ' + result[0].errors.message);
            }*/
        //}
    }
};
function releaseCustomerOwnership(accountObj,userObj,ProfileName){ 
    //if(accountObj.OwnerId != userObj.Id || accountObj.Port_Pool__c != 'Port') 
    console.log(accountObj,userObj);
    if((accountObj.OwnerId == userObj.Id && accountObj.Port_Pool__c == 'Port' && ProfileName=='SME-RM') || (accountObj.OwnerId == userObj.Id && accountObj.Port_Pool__c != '' && ProfileName=='SME-TM')){
        var response = sforce.apex.execute('Ownership_Service', 'releaseOwnership',{accountString : JSON.stringify(accountObj),userString : JSON.stringify(userObj)});
        console.log(response);
        if(response[0].success){
            alert('Create Ownership Release Success.');
            window.location.reload();
        }
        else alert('Failed to Create Ownership Release ' + response[0].msg);
        /*var accountUserObj = sforce.connection.query("SELECT Id,ManagerId,Profile.Name,Email FROM User WHERE Id='"+accountObj.OwnerId+"'");
        var accountUserRecords = accountUserObj.getArray("records");
        if(accountUserRecords && accountUserRecords.length > 0){
            var accountUserRecord = accountUserRecords[0];
            var ownerObj = new sforce.SObject('Customer_Ownership_Request__c');
            ownerObj.Request_Type__c = "Release Ownership";
            ownerObj.CIS_ID__c = accountObj.Id;
            ownerObj.OwnerID = userObj.Id;
            ownerObj.Requestor_TM__c = userObj.ManagerId;
            ownerObj.Current_Owner__c = accountObj.OwnerId;
            var resultOwner = sforce.connection.create([ownerObj]);
            if(resultOwner[0].success == 'true')
            {
                alert('Create Ownership Request Success.');
                window.location.reload();
            }else alert('Failed to Release Ownership Request' + resultOwner[0].errors.message);
        }*/
    }else alert('Customer must be in your port to release ownership');
};