public class AccountRequestReleaseOwnership {

    public static Customer_Ownership_Request__Share createShare(Id userId, Customer_Ownership_Request__c requestObj) {
        Customer_Ownership_Request__Share shareRecord = new Customer_Ownership_Request__Share();
        shareRecord.ParentId      = requestObj.Id;
        shareRecord.UserOrGroupId = userId;
        shareRecord.AccessLevel   = 'Read';
        shareRecord.RowCause      = 'Manual';
        return shareRecord;
    }

    public void shareRequestReleaseRecord(Customer_Ownership_Request__c eachRequest, Customer_Ownership_Request__c oldRequest){
         Set<Id> userIds;
        if(eachRequest.Approval_Status__c != GlobalConstants.CANCEL) {
            userIds = new Set<Id>();
            if(eachRequest.OwnerId != eachRequest.Current_Owner__c &&
                eachRequest.Current_Owner__c != oldRequest.Current_Owner__c) {
                userIds.add(eachRequest.Current_Owner__c);
            }
            if(eachRequest.OwnerId != eachRequest.Approver__c &&
                eachRequest.Approver__c != oldRequest.Approver__c) {
                userIds.add(eachRequest.Approver__c);
            }
            if(eachRequest.OwnerId != eachRequest.SME_Temporary_Customer__c &&
                eachRequest.SME_Temporary_Customer__c != oldRequest.SME_Temporary_Customer__c) {
                userIds.add(eachRequest.Approver__c);
            }
            for(Id userId : userIds) {
                if(userId != null)
                Ownership_Service.shareRecordToUpdate.add(AccountRequestReleaseOwnership.createShare(userId, eachRequest));
            }
        }
    }

    public Account approveRequest(Customer_Ownership_Request__c eachOwnerRequest, Account accountRecord, User ownerUser, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap){
        if(eachOwnerRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP){
            Account_Service.isRequest = true;
            if(eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.PORT) {
                accountRecord.Port_Pool__c = GlobalConstants.PORT;
                accountRecord.OwnerId = eachOwnerRequest.OwnerId;
                accountRecord.Service_RM__c = null;
                accountRecord.SME_Temporary_Customer__c = null;
                accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                calculatePrimarySegment(ownerUser, accountRecord, eachOwnerRequest);
                calculatePreviousTeam(accountRecord, eachOwnerRequest, currentUser, teamStructerMapByRC, currentUserExtensionMap);                                         
            } else {
                accountRecord.SME_Temporary_Customer__c = currentUserExtensionMap.get(eachOwnerRequest.OwnerId);
                accountRecord.Last_CallReprt_Opty_Updated_Date__c = System.now();
                accountRecord.Port_Pool__c = (accountRecord.Port_Pool__c != null) ? GlobalConstants.POOL : null;
                accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
            }
            accountRecord.Temporary_Ownership_Flag__c = false;
            accountRecord.OwnerChangeExecutedByTrigger__c = true;
            Account_Service.callingFromYearEndBatch = false;
        }
        return accountRecord;
    }

    public Account approveRelease(Customer_Ownership_Request__c eachOwnerRequest, Account accountRecord, User ownerUser, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap, Map<String,User_Mirror_Management__c> rcCodeNHTLMap, Id cbsAdmin, Id smeAdmin, Map<String,Account> accountRelateMap){
        if(eachOwnerRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP){
            Account_Service.isRelease = true;
            if(!GlobalConstants.REFEROUT_RELEASE_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
                accountRecord.OwnerChangeExecutedByTrigger__c = true;
                if(!(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c))){
                    if (eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.REASON_TM_POOL) {
                        Account_Service.isTMPool = true;
                        Account_Service.isChangeOwnership = true;
                        Account_Service.forceOwnerShipText = true;
                        accountRecord.Previous_Owner__c = null;
                        accountRecord.Temporary_Ownership_Flag__c = false;
                        accountRecord.Port_Pool__c = GlobalConstants.POOL;
                        accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
                        accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                        accountRecord.SME_Temporary_Customer__c = null;
                        if (eachOwnerRequest.Service_RM__c == 'Yes') {
                            accountRecord.Service_RM__c = eachOwnerRequest.OwnerId;
                        }
                    }else if(GlobalConstants.REFEROUT_BAD_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
                        accountRecord.Service_RM__c = null;
                        accountRecord.Previous_Owner__c = null;
                        accountRecord.SME_Temporary_Customer__c = null;
                        if(accountRecord.RecordType.Name == GlobalConstants.ORGANIZATION_PROSPECT){
                            accountRecord.Port_Pool__c = null;
                            accountRecord.OwnerId = smeAdmin;
                        }else{
                            Account_Service.isTMPool = true;
                            accountRecord.Trash_Pool_Flag__c = true;
                            accountRecord.Port_Pool__c = GlobalConstants.POOL;
                            accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                            accountRecord.OwnerId = (currentUser.Profile.Name == GlobalConstants.SME_RM)?currentUser.ManagerId:currentUser.Id;
                            Account_Service.forceOwnerShipText = true;
                        }
                    }
                }else{
                    if(eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.CLOSED_BUSINESS || 
                        eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.LOW_POTENTIAL){
                        accountRecord.OwnerId = cbsAdmin;
                        accountRecord.Port_Pool__c = GlobalConstants.PORT;
                        accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                    } 
                }
            }else {
                accountRecord.Service_RM__c = null;
                accountRecord.Temporary_Ownership_Flag__c = false;
                accountRecord.OwnerChangeExecutedByTrigger__c = true;
                accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                accountRecord.SME_Temporary_Customer__c = null;

                if(GlobalConstants.REFEROUT_NOT_SME_CBS_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
                    accountRecord.Port_Pool__c = GlobalConstants.PORT;
                }else{
                    accountRecord.Port_Pool__c = GlobalConstants.POOL;
                }
                
                Account_Service.isChangeOwnership = true;
                Account_Service.callingFromYearEndBatch = false;
                
                if(eachOwnerRequest.Current_Owner__c != null){
                    accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
                }else{
                    if(GlobalConstants.REFEROUT_CBS_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
                        accountRecord.OwnerId = cbsAdmin;
                        accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB;
                    }
                }
                calculatePreviousTeam(accountRecord, eachOwnerRequest, ownerUser, teamStructerMapByRC, currentUserExtensionMap);  

                if(currentUser != null && teamStructerMapByRC != null) {
                    if(!rcCodeNHTLMap.containsKey(currentUser.RC_Code__c)){
                        calculatePermanentTeam(accountRecord, currentUser, teamStructerMapByRC);
                        calculateCurrentTeam(accountRecord, currentUser, teamStructerMapByRC);
                        calculatePrimarySegment(currentUser, accountRecord, eachOwnerRequest);
                    }else{
                        if(rcCodeNHTLMap.containsKey(currentUser.RC_Code__c)){
                            String tL_RC_Code = rcCodeNHTLMap.get(currentUser.RC_Code__c).Mirror_Value__c;
                            if(teamStructerMapByRC.containsKey(tL_RC_Code)){
                                Team_Structure__c teamStrcutureCBS = teamStructerMapByRC.get(tL_RC_Code);
                                accountRecord.Primary_Segment_Code__c = teamStrcutureCBS.Segment__c;
                                accountRecord.Permanent_Team_Name__c  = teamStrcutureCBS.id;
                                accountRecord.Current_Team_Name__c    = teamStrcutureCBS.id;
                                if(teamStrcutureCBS.AH_Name__c != null)
                                    accountRecord.Current_AH_Name__c = teamStrcutureCBS.AH_Name__c;
                                if(teamStrcutureCBS.NH_Name__c != null)
                                    accountRecord.Permanent_NH_Name__c = teamStrcutureCBS.NH_Name__c;
                            }
                        }
                    }  
                }

                if(eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.REASON_COMPANY_RELATED){
                    if(accountRelateMap.containsKey(eachOwnerRequest.Company_Related_Text__c)){
                        accountRecord.Group__c = accountRelateMap.get(eachOwnerRequest.Company_Related_Text__c).Group__c;
                        accountRecord.Sub_Group__c = accountRelateMap.get(eachOwnerRequest.Company_Related_Text__c).Sub_Group__c;
                    }
                }
            }
        }
        return accountRecord;
    }

    public void changeReferOutTeam(Customer_Ownership_Request__c eachOwnerRequest, Map<String, User> userMapByTeamName){
        User assignUser;
        String tmString;
        String ahString;
        String nhString;
        String currentOwner;

        if(userMapByTeamName.containsKey(eachOwnerRequest.Refer_Out_Team__c)) {
            assignUser = userMapByTeamName.get(eachOwnerRequest.Refer_Out_Team__c);
        }

        if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_RM){
            tmString = assignUser.ManagerId;
            ahString = (assignUser.Manager!=null)?assignUser.Manager.ManagerId:null;
            nhString = (assignUser.Manager!=null && assignUser.Manager.Manager!=null)?assignUser.Manager.Manager.ManagerId:null;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_TM){
            tmString = assignUser.Id;
            ahString = assignUser.ManagerId;
            nhString = (assignUser.Manager!=null)?assignUser.Manager.ManagerId:null;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_AH){
            ahString = assignUser.Id;
            nhString = assignUser.ManagerId;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_NH){
            nhString = assignUser.Id;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.CBS_RM){
            tmString = (assignUser.Manager.Manager!=null)?assignUser.ManagerId:null;
            ahString = (assignUser.Manager.Manager!=null)?assignUser.Manager.ManagerId:assignUser.ManagerId;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.CBS_TM){
            tmString = assignUser.Id;
            ahString = assignUser.ManagerId;
        }else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.CBS_TL){
            ahString = assignUser.Id;
        }

        if(assignUser != null && assignUser.Manager != null)
            currentOwner = assignUser.ManagerId;
        else if(assignUser != null && assignUser.Manager.Manager != null)
            currentOwner = assignUser.Manager.ManagerId;
        else if(assignUser != null && assignUser.Manager.Manager.Manager != null)
            currentOwner = assignUser.Manager.Manager.ManagerId;

        eachOwnerRequest.Current_Owner__c = currentOwner;
        eachOwnerRequest.Current_Owner_TM__c = tmString;
        eachOwnerRequest.Current_Owner_AH__c = ahString;
        eachOwnerRequest.Current_Owner_NH__c = nhString;
    }

    private void calculatePermanentOwner(Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest){
        if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT) {
            if(eachOwnerRequest.Current_Owner_TM__c!=null)
                accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_TM__c;
            else if(eachOwnerRequest.Current_Owner_AH__c!=null)
                accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_AH__c;
            else if(eachOwnerRequest.Current_Owner_NH__c!=null)
                accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_NH__c;
        }
    }

    private void calculatePreviousTeam(Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap){
        if(currentUserExtensionMap.containsKey(eachOwnerRequest.Current_Owner__c))
            accountRecord.Previous_Owner_Extension__c = currentUserExtensionMap.get(eachOwnerRequest.Current_Owner__c);

        if(currentUser != null && teamStructerMapByRC != null) {
            if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
                accountRecord.Previous_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
            if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
                accountRecord.Previous_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
            if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
                accountRecord.Previous_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
        }
    }

    private void calculatePermanentTeam(Account accountRecord, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC){
        if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
            accountRecord.Permanent_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
        if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
            accountRecord.Permanent_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
        if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
            accountRecord.Permanent_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
    }

    private void calculateCurrentTeam(Account accountRecord, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC){
        if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
            accountRecord.Current_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
        if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
            accountRecord.Current_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
        if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
            accountRecord.Current_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
    }

    private void calculatePrimarySegment(User ownerUser, Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest){
        AccountChangeOwner accountService = new AccountChangeOwner();
        accountRecord.Primary_Segment_Code__c = accountService.calculatePrimarySegment(ownerUser, accountRecord, String.valueOf(eachOwnerRequest.Sales_Size__c));
    }
}