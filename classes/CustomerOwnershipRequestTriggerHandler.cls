/**
* @author charnun.t@beryl8.com
*/
public without sharing class CustomerOwnershipRequestTriggerHandler extends TriggerHandler{
    private String SME_ADMIN;
    private String CBS_ADMIN;
    private Map<Id,Account> accountMap;
    private Map<Id,User> currentUserMap;
    private Map<Id,Account> updateAccountMap;
    private Map<Id,Account> updateTempAccountMap;
    private Map<String,Id> currentUserExtensionMap;
    private Map<String,Team_Structure__c> teamStructerMapByRC;
    private Map<String,User_Mirror_Management__c> rcCodeNHTLMap;

    public override void allBefore() {
        // Reset All Flag Ownership
        Account_Service.resetAllFlagOwnership();

        Set<Id> accountSet = new Set<Id>();
        List<Id> currentOwnerSet = new List<Id>();
        accountMap = new Map<Id,Account>();
        currentUserMap = new Map<Id,User>();
        currentUserExtensionMap = new Map<String,Id>();
        teamStructerMapByRC = new Map<String,Team_Structure__c>();

        for(Customer_Ownership_Request__c eachRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            currentOwnerSet.add(eachRequest.OwnerId);
            if(eachRequest.CIS_ID__c!=null){
                accountSet.add(eachRequest.CIS_ID__c);
            }else{
                eachRequest.addError(ExceptionMessage.THIS_REQUEST_HAS_NO_CIS);
            }
            if(eachRequest.Current_Owner__c!=null){
                currentOwnerSet.add(eachRequest.Current_Owner__c);
            }
            if(eachRequest.Requestor__c!=null){
                currentOwnerSet.add(eachRequest.Requestor__c);
            }
            if(eachRequest.Approver__c!=null){
                currentOwnerSet.add(eachRequest.Approver__c);
            }
        }
        currentOwnerSet.add(UserInfo.getUserId());
        accountMap = Account_Service.getAllAccountWithId(accountSet);

        for(Account eachAccount : accountMap.values()) {
            currentOwnerSet.add(eachAccount.OwnerId);
        }

        currentUserMap = User_Service.getUserMapWithId(currentOwnerSet);
        
        Set<String> rcCodeSet = new Set<String>();
        for(User eachUser : currentUserMap.values()) {
            rcCodeSet.add(eachUser.RC_Code__c);
            rcCodeSet.add(eachUser.AH_RC_Code__c);
            rcCodeSet.add(eachUser.NH_RC_Code__c);
        }

        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>([SELECT Id, External_ID__c,RC_Code__c,Segment__c,AH_Name__c,NH_Name__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodeSet]);
        for(Team_Structure__c eachTeam : teamStructureList) {
            if(eachTeam.RC_Code__c != null)
            teamStructerMapByRC.put(eachTeam.RC_Code__c, eachTeam);
        }

        List<User_Extension__c> userExtensionList = new List<User_Extension__c>([SELECT Id, User__c FROM User_Extension__c WHERE User__c IN :currentOwnerSet]);
        for(User_Extension__c eachExt : userExtensionList) {
            currentUserExtensionMap.put(eachExt.User__c, eachExt.Id);
        }
    }

    public override void beforeInsert() {
        User currentUser = currentUserMap.get(UserInfo.getUserId());

        IRequestOwnership requestOwnership;
        IReleaseOwnership releaseOwnership;
        for(Customer_Ownership_Request__c eachRequest : (List<Customer_Ownership_Request__c>) Trigger.new) {
            try {
                Account accountObj = accountMap.get(eachRequest.CIS_ID__c);
                // Request
                if(eachRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP) {
                    User ownerUser = currentUserMap.get(accountObj.OwnerId);
                    RequestOwnershipService.updateRequesterFields(eachRequest, currentUser);
                    RequestOwnershipService.updateApproverFields(eachRequest, ownerUser);
                } 
                // Release
                else if(eachRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP) {
                    releaseOwnership = null;
                    switch on ReleaseOwnershipService.validateUserPermission(currentUser) {
                        when 'SME' {
                            releaseOwnership = new SMEReleaseOwnership();
                        } 
                        when 'CBS' {
                            releaseOwnership = new CBSReleaseOwnership();
                        } 
                    }
                    if(releaseOwnership != null) releaseOwnership.validateCustomer(accountObj, currentUser);
                }
                // RBS Branch Closeness 
                //else if(eachRequest.Request_Type__c == GlobalConstants.BRANCH_CLOSENESS) {}
            } catch (OwnershipException ownershipException) {
                eachRequest.addError(ownershipException.getMessage());
            }
        }
    }

    public override void beforeUpdate() {
        AccountRequestReleaseOwnership accountRequestReleaseService = new AccountRequestReleaseOwnership();
        SME_ADMIN = UserManager.getUserAdmin().SME_User_ID__c;
        CBS_ADMIN = UserManager.getUserAdmin().CBS_User_ID__c;
        updateAccountMap = new Map<Id,Account>();
        updateTempAccountMap = new Map<Id,Account>();
        rcCodeNHTLMap = CustomSettingUtil.getMirrorSettingMapByUserAndMirrorRcCode();
     
        Set<String> teamReferSet = new Set<String>();
        Customer_Ownership_Request__c oldRequest;
        List<String> cisRelateList = new List<String>();

        for(Customer_Ownership_Request__c eachRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            oldRequest = (Customer_Ownership_Request__c) Trigger.oldMap.get(eachRequest.Id);
            if(eachRequest.Refer_Out_Team__c != oldRequest.Refer_Out_Team__c && (eachRequest.Refer_Out_Reason__c == 'Wrong Area' || eachRequest.Refer_Out_Reason__c == 'Other Team')) {
                teamReferSet.add(eachRequest.Refer_Out_Team__c);
            }
            if(eachRequest.Refer_Out_Reason__c == GlobalConstants.REASON_COMPANY_RELATED){
                if(eachRequest.Company_Related_Text__c != null && eachRequest.Company_Related_Text__c !=''){
                    cisRelateList.add(eachRequest.Company_Related_Text__c);
                }
            }
        }

        List<User_Extension__c> userExtList = new List<User_Extension__c>([SELECT Id, User__c, Team_Structure__c, Team_Structure__r.Name FROM User_Extension__c WHERE Team_Structure__r.Name IN :teamReferSet]);
        Map<Id, String> teamMapByUserId = new Map<Id, String>();

        Set<Id> assignUserIds = new Set<Id>();
        for(User_Extension__c eachUserExt : userExtList) {
            assignUserIds.add(eachUserExt.User__c);
            teamMapByUserId.put(eachUserExt.User__c, eachUserExt.Team_Structure__r.Name);
        }

        Map<String, User> userMapByTeamName = new Map<String, User>();
        List<User> assignUserList = new List<User>([SELECT Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Email,Manager.Manager.Manager.Email,Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE IsActive = true AND Id IN :assignUserIds]);
        for(User eachUser : assignUserList) {
            if(teamMapByUserId.containsKey(eachUser.Id) && teamMapByUserId.containsKey(eachUser.Id)) {
                userMapByTeamName.put(teamMapByUserId.get(eachUser.Id), eachUser);
            }
        }

        if(Ownership_Service.shareRecordToUpdate == null) {
            Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
        }

        List<Account> accountRelateList = [SELECT ID,CIS__c,Group__c,Sub_Group__c FROM Account WHERE CIS__c=:cisRelateList];
        Map<String,Account> accountRelateMap = new Map<String,Account>();
        for(Account eachAccount : accountRelateList){
            accountRelateMap.put(eachAccount.CIS__c, eachAccount);
        }
        Id RBS_RELEASE_RECORDTYPE = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_RELEASE_RBS_READONLY_DEVNAME);
        Id RBS_REQUEST_RECORDTYPE = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_RBS_READONLY_DEVNAME);
        for(Customer_Ownership_Request__c eachRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            if(accountMap.containsKey(eachRequest.CIS_ID__c)){
                oldRequest = (Customer_Ownership_Request__c) Trigger.oldMap.get(eachRequest.Id);
                Account accountRecord = accountMap.get(eachRequest.CIS_ID__c);
                if(accountRecord != null) {
                    if(eachRequest.Approval_Status__c != GlobalConstants.CANCEL && 
                        accountRecord.Previous_Owner__c != null && 
                        accountRecord.Previous_Owner__r.Profile.Name != GlobalConstants.SME_ADMIN && 
                        accountRecord.Previous_Owner__c != eachRequest.Requestor_TM__c && 
                        (eachRequest.Current_Owner__c==null || (eachRequest.Current_Owner__c!=null && currentUserMap.containsKey(eachRequest.Current_Owner__c) && 
                        accountRecord.Previous_Owner__c != currentUserMap.get(eachRequest.Current_Owner__c).ManagerId))){
                        eachRequest.Previous_Owner_Email__c = accountRecord.Previous_Owner__r.Email;
                    }

                    // Status Approved
                    if(eachRequest.Approval_Status__c==GlobalConstants.APPROVED){
                        User ownerUser = currentUserMap.get(eachRequest.OwnerId);
                        User currentUser = currentUserMap.get(eachRequest.Current_Owner__c);
                        if(eachRequest.RecordTypeId == RBS_REQUEST_RECORDTYPE) {
                            User requestor = currentUserMap.get(eachRequest.Requestor__c);
                            if(teamStructerMapByRC.containsKey(requestor.RC_Code__c)) {
                                accountRecord = RBSRequestOwnership.approveRequest(eachRequest, accountRecord, teamStructerMapByRC.get(requestor.RC_Code__c));
                            } else {
                                eachRequest.addError('ไม่สามารถทำรายการได้ เนื่องจากไม่มีสาขานี้ในระบบ');
                            }
                        } else if(eachRequest.RecordTypeId == RBS_RELEASE_RECORDTYPE) {
                            accountRecord = RBSReleaseOwnership.approveRequest(eachRequest, accountRecord);
                        } else {
                            accountRecord = accountRequestReleaseService.approveRequest(eachRequest, accountRecord, ownerUser, currentUser, teamStructerMapByRC, currentUserExtensionMap);
                            accountRecord = accountRequestReleaseService.approveRelease(eachRequest, accountRecord, ownerUser, currentUser, teamStructerMapByRC, currentUserExtensionMap, rcCodeNHTLMap, CBS_ADMIN, SME_ADMIN, accountRelateMap);
                        }

                        if(eachRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP && eachRequest.Request_Ownership_Type__c != GlobalConstants.PORT){
                            updateTempAccountMap.put(accountRecord.Id, accountRecord);
                        }else{
                            updateAccountMap.put(accountRecord.Id, accountRecord);
                        }
                    } else {
                        if(eachRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP && 
                        eachRequest.Refer_Out_Team__c != oldRequest.Refer_Out_Team__c && 
                        (eachRequest.Refer_Out_Reason__c == GlobalConstants.REASON_WRONG_AREA || 
                        eachRequest.Refer_Out_Reason__c == GlobalConstants.REASON_OTHER_TEAM)) {
                            accountRequestReleaseService.changeReferOutTeam(eachRequest, userMapByTeamName);
                        }
                    }

                    accountRequestReleaseService.shareRequestReleaseRecord(eachRequest, oldRequest);
                }        
            }
        }
    }

    public override void afterInsert() {
        List<Customer_Ownership_Request__Share> requestShareList = new List<Customer_Ownership_Request__Share>();
        Set<Id> userIds;
        for(Customer_Ownership_Request__c eachRequest : (List<Customer_Ownership_Request__c>) Trigger.new) {
            userIds = new Set<Id>();
            if(eachRequest.OwnerId != eachRequest.Current_Owner__c) {
                userIds.add(eachRequest.Current_Owner__c);
            }
            if(eachRequest.OwnerId != eachRequest.Approver__c) {
                userIds.add(eachRequest.Approver__c);
            }
            if(eachRequest.OwnerId != eachRequest.SME_Temporary_Customer__c) {
                userIds.add(eachRequest.Approver__c);
            }
            if(eachRequest.OwnerId != eachRequest.Current_Owner_TM__c) {
                userIds.add(eachRequest.Current_Owner_TM__c);
            }
            if(eachRequest.OwnerId != eachRequest.Current_Owner_AH__c) {
                userIds.add(eachRequest.Current_Owner_AH__c);
            }
            if(eachRequest.OwnerId != eachRequest.Current_Owner_NH__c) {
                userIds.add(eachRequest.Current_Owner_NH__c);
            }
            for(Id userId : userIds) {
                if(userId != null)
                requestShareList.add(AccountRequestReleaseOwnership.createShare(userId, eachRequest));
            }
        }

        insert requestShareList;
        //Ownership_Service.createOwnershipRequestShare((List<Customer_Ownership_Request__c>) Trigger.new);
        //System.debug(Ownership_Service.shareRecordToUpdate);
        //if(Ownership_Service.fromTrigger && Ownership_Service.shareRecordToUpdate!=null){
        //    for(Customer_Ownership_Request__Share ownershipShare : Ownership_Service.shareRecordToUpdate){
        //        ownershipShare.ParentId = (Id)Trigger.new.get(0).get('Id');
        //    }
        //    insert Ownership_Service.shareRecordToUpdate;
        //    Ownership_Service.shareRecordToUpdate = null;
        //}
    }

    public override void afterUpdate() {
        if(Ownership_Service.shareRecordToUpdate != null){
            insert Ownership_Service.shareRecordToUpdate;
            Ownership_Service.shareRecordToUpdate = null;
        }
    }

    public override void beforeFinally() {
        if(updateAccountMap != null && !updateAccountMap.isEmpty()){
            Account_Service.triggerInitialCall = true;
            System.debug('updateAccountMap:' + updateAccountMap.values());
            update updateAccountMap.values();
        }
        if(updateTempAccountMap != null && !updateTempAccountMap.isEmpty()){
            AccountChangeOwner accountService = new AccountChangeOwner();
            Account_Service.triggerInitialCall = true;
            System.debug('updateTempAccountMap:' + updateTempAccountMap.values());
            update updateTempAccountMap.values();

            accountService.closeTempOwnerEvent(updateTempAccountMap);
            accountService.changeAllOpenJob(updateTempAccountMap, null);
        }
    }
}