public without sharing class Opportunity_Service {
    public static List<User_Extension__c> userExtList;
    public static Map<String, Id> userExtMapByEmpId;
    public static List<Team_Structure__c> teamStructureList;
    public static Map<String, Id> teamMapByRc;
    public static List<AccountTeamMember> accountTeamMemberList;
    public static Map<String, Id> accountTeamMemberMapResult;

    public static Map<Id,Account> getAccountMapByOpportunity(List<Opportunity> opportunityList){
        Set<Id> accountSet = getAccountIdsFromOpportunity(opportunityList);

        for (Opportunity eachOpportunity : opportunityList){
            accountSet.add(eachOpportunity.AccountId);
        }

        Map<Id, Account> accountMapResult = new Map<Id,Account>([SELECT Id,Customer_s_Business_Code__c, Dual_RM_Name__c, CIS__c,FinServ__ReferredByUser__c,Is_RBS__c,Trash_Pool_Flag__c,Dual_RM_Name__r.ManagerId,Dual_RM_Name__r.Manager.ManagerId,Dual_RM_Name__r.Manager.Manager.ManagerId,Dual_RM_Name__r.Profile.Name, Primary_Segment_Code__c, Current_Activity__c,Current_Activity_By__c,Last_Setup_By__c,Last_Setup_Date__c,Owner_Emp_ID__c, Port_Pool__c, OwnerId, Owner.Segment__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Ownership_Text__c, Owner.AH_RC_CODE__c, Owner.NH_RC_CODE__c, Customer_Owner_Release_Flag__c, Temp_Owner_Changed_Date__c, Owner.Name, Owner.Profile.Name, Previous_Owner__c,Sales_Size__c, Temporary_Customer__c,SME_Temporary_Customer__c, SME_Temporary_Customer__r.User__c , AF_Temporary_Customer__c, AF_Temporary_Customer__r.User__c, Owner.ManagerId, Owner.Manager.ManagerId, AF_Port_Pool_Formula__c, AF_Port2__c FROM Account WHERE Id IN :accountSet]);
        System.debug('accountMapResult:' + accountMapResult);
        return accountMapResult;
    }
   
    public static Set<Id> getAccountIdsFromOpportunity(List<Opportunity> opportunityList) {
        Set<Id> accountSet = new Set<Id>();
        for (Opportunity eachOpportunity : opportunityList){
            accountSet.add(eachOpportunity.AccountId);
        }

        return accountSet;
    }

    //Start INC000000774208
    public static Map<String, Id> getAllRelatedTeamMapByExternalId() {
        if(teamStructureList == null){
            teamStructureList = new List<Team_Structure__c>();
            teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c];
            teamMapByRc = new Map<String, Id>();
            for(Team_Structure__c eachTeam : teamStructureList) {
                teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
            }
        }

        return teamMapByRc;
    }

    public static Map<String, Id> getAllUserExtensionMapByEmp() {
        if(userExtList == null){
            userExtList = [SELECT Id, External_ID__c FROM User_Extension__c];
            userExtMapByEmpId = new Map<String, Id>();
            for(User_Extension__c eachUserExt : userExtList) {
                userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
            }
        }

        return userExtMapByEmpId;
    }

    public static Opportunity generateNewJob(Id accId,String accName,Id recordTypeId){
        Date currentDate = System.today();
        Integer year = currentDate.year();
        Integer month = currentDate.month();
        Integer day = currentDate.day();
        String stringMonth;
        if(month < 10){
            stringMonth = '0'+month;
        }
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId = accId;
        newOpp.Name = year+'/'+stringMonth+'/'+day+'_'+ accName;
        newOpp.StageName = Globalconstants.STATUS_OPEN;
        newOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Default_Job_CloseDate));
        newOpp.RecordTypeId = recordTypeId;
        return newOpp;
    }
    public static Opportunity generateNewJobCBS(Datetime createDate,String prefix,Id accId,String cisNum,Id recordTypeId){
        Integer year = createDate.year();
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId = accId;
        newOpp.Name = 'Job_'+prefix+'2017_'+ cisNum;
        newOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Default_Job_CloseDate));
        newOpp.RecordTypeId = recordTypeId;
        return newOpp;
    }
    //End INC000000774208

    //public static void setOpportunityBackwardField(Opportunity eachOpportunity, Opportunity oldRecord) {
    //    if(eachOpportunity.Allow_Backward_Stage__c){
    //        String currentStage = eachOpportunity.StageName;
    //        String currentRecordType = eachOpportunity.RecordTypeId;
    //        eachOpportunity.StageName = eachOpportunity.Previous_Stage__c;
    //        eachOpportunity.RecordTypeId = eachOpportunity.Previous_Record_Type__c;
    //        eachOpportunity.Previous_Record_Type__c = currentRecordType;
    //        eachOpportunity.Previous_Stage__c = currentStage;
    //    }
    //    if(eachOpportunity.StageName != oldRecord.StageName){
    //        if(!eachOpportunity.Allow_Backward_Stage__c){
    //            eachOpportunity.Previous_Record_Type__c = oldRecord.RecordTypeId;
    //            eachOpportunity.Previous_Stage__c = oldRecord.StageName;
    //        }
    //        eachOpportunity.Latest_Stage_Modified_Date__c = System.now();
    //    }
    //    eachOpportunity.Allow_Backward_Stage__c = false;
    //}

    //public static void setOpportunityCloseWonField(Opportunity eachOpportunity, User currentUser, Map<String, Id> userExtMapByEmpId, Map<String, Id> teamMapByRc) {
    //    eachOpportunity.Port_Pool__c = GlobalConstants.PORT;
    //    eachOpportunity.Ownership__c = GlobalConstants.OWNERSHIP_PERMANENT;
    //    eachOpportunity.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
    //    eachOpportunity.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
    //    eachOpportunity.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
    //    eachOpportunity.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
    //}

    //public static void setAccountInformationWhenCloseWonOpportunity(Opportunity eachOpportunity, User currentUser, Account accountRecord){
    //    if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE) {
    //        accountRecord.Last_Setup_By__c = UserInfo.getName();
    //        accountRecord.Last_Setup_Date__c = System.today();
    //        accountRecord.Current_Activity__c = GlobalConstants.CLOSE_WON;

    //        if(!GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name) && !isAccountTeamAreValid(eachOpportunity, currentUser, accountRecord)) {
    //            if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY) {
    //                accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
    //                accountRecord.Permanent_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
    //                accountRecord.Permanent_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
    //                accountRecord.Permanent_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
    //                accountRecord.Permanent_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
    //            }
    //            if(currentUser.Segment__c == GlobalConstants.SEGMENT_SE && !currentUser.RBS_User__c) {
    //                accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM;
    //            } else if(currentUser.Segment__c == GlobalConstants.SEGMENT_ME && !currentUser.RBS_User__c) {
    //                if(accountRecord.Sales_Size__c >= 100000000){
    //                    accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_UM;
    //                }else{
    //                    accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
    //                }
    //            }else if(currentUser.RBS_User__c){
    //                accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
    //            }
    //            accountRecord.Service_RM__c = null;
    //            accountRecord.Port_Pool__c = GlobalConstants.PORT;
    //        }
    //    }
    //}

    // CR099 for temporary use for oneteam 
    // Create by charnun.t on 25 Feb 2018
    public static Boolean isAccountTeamAreValid(Opportunity eachOpportunity, User currentUser, Account accountRecord){
        accountTeamMemberList = new List<AccountTeamMember>();
        accountTeamMemberList = [select Id, AccountId, UserId, CreatedById, LastModifiedById from AccountTeamMember where AccountId =: accountRecord.Id and UserId =: currentUser.Id];
        accountTeamMemberMapResult = new Map<String, Id>();
        for(AccountTeamMember eachAccountTeam : accountTeamMemberList) {
            accountTeamMemberMapResult.put(eachAccountTeam.AccountId, eachAccountTeam.Id);
        }
        if(accountTeamMemberMapResult.get(accountRecord.Id) != null && eachOpportunity.OwnerId != accountRecord.OwnerId){
            return true;
        }
        return false;
    }

    public static Boolean isAccountTeamMemberWithManager(Id accountId) {
        List<AccountTeamMember> listAccountTeamMember = [SELECT Id, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM AccountTeamMember WHERE AccountAccessLevel != 'None' AND AccountId = :accountId];
        for(AccountTeamMember eachAccountTeamMember : listAccountTeamMember) {
            if(eachAccountTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachAccountTeamMember.User.ManagerId) && eachAccountTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.ManagerId) && eachAccountTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachAccountTeamMember.User.Manager.Manager.ManagerId) && eachAccountTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isOpportunityTeamMemberWithManager(Id accountId) {
        List<OpportunityTeamMember> listOpportunityTeamMember = [SELECT Id, UserId, User.ManagerId, User.Manager.ManagerId, User.Manager.Manager.ManagerId FROM OpportunityTeamMember WHERE OpportunityAccessLevel != 'None' AND Opportunity.AccountId = :accountId AND Opportunity.StageName != :GlobalConstants.FINISHED];
        for(OpportunityTeamMember eachOpportunityTeamMember : listOpportunityTeamMember) {
            if(eachOpportunityTeamMember.UserId == UserInfo.getUserId() || (!String.isBlank(eachOpportunityTeamMember.User.ManagerId) && eachOpportunityTeamMember.User.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunityTeamMember.User.Manager.Manager.ManagerId) && eachOpportunityTeamMember.User.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isOpportunityOwnerWithManager(Id accountId) {
        List<Opportunity> listOpportunity = [SELECT Id, OwnerId, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId FROM Opportunity WHERE AccountId = :accountId AND StageName != :GlobalConstants.FINISHED];
        for(Opportunity eachOpportunity : listOpportunity) {
            if(eachOpportunity.OwnerId == UserInfo.getUserId() || (!String.isBlank(eachOpportunity.Owner.ManagerId) && eachOpportunity.Owner.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.ManagerId) && eachOpportunity.Owner.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(eachOpportunity.Owner.Manager.Manager.ManagerId) && eachOpportunity.Owner.Manager.Manager.ManagerId == UserInfo.getUserId())) {
                return true;
            }
        }
        return false;
    }

    public static void stampLastCallOpptyToAccount(List<Opportunity> listOpp,Map<Id, Account> accountMap, User currentUser){
        if(userExtMapByEmpId == null || Account_Service.callingFromAccountTrigger) return;
        Id currentUserExId = userExtMapByEmpId.get(currentUser.Employee_ID__c);
        Map<Id,Account> mapUpdateAccountLastCallOppty = new Map<Id,Account>();
        for(Opportunity eachOpp : listOpp){
            if(accountMap.containsKey(eachOpp.AccountId) && String.isNotBlank(accountMap.get(eachOpp.AccountId).SME_Temporary_Customer__c) && accountMap.get(eachOpp.AccountId).SME_Temporary_Customer__c == currentUserExId){
                Account updateAccountLastCallOppty = new Account();
                updateAccountLastCallOppty.Id = eachOpp.AccountId;
                updateAccountLastCallOppty.Last_CallReprt_Opty_Updated_Date__c = System.now();
                mapUpdateAccountLastCallOppty.put(updateAccountLastCallOppty.Id,updateAccountLastCallOppty);
            }else if(accountMap.containsKey(eachOpp.AccountId) && String.isNotBlank(accountMap.get(eachOpp.AccountId).AF_Temporary_Customer__c) && accountMap.get(eachOpp.AccountId).AF_Temporary_Customer__c == currentUserExId){
                Account updateAccountLastCallOppty = new Account();
                updateAccountLastCallOppty.Id = eachOpp.AccountId;
                updateAccountLastCallOppty.AF_Last_CallReprt_Opty_Updated_Date__c = System.now();
                mapUpdateAccountLastCallOppty.put(updateAccountLastCallOppty.Id,updateAccountLastCallOppty);
            }
        }

        if(mapUpdateAccountLastCallOppty.values().size() > 0){
            TriggerHandler.bypass('AccountTriggerHandler');
            update mapUpdateAccountLastCallOppty.values();
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
}