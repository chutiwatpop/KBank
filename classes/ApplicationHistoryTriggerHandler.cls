public without sharing class ApplicationHistoryTriggerHandler extends TriggerHandler{
    private Map<String,String> mapCreditModel = new Map<String,String>{'DLA' => 'A','FL' => '1','HPL' => '8','PL' => '9'};
    public static Map<String,Business_Code__c> mapRelatedBusinessCode;
    public static  Set<String> saleProfileSME = new Set<String>{GlobalConstants.SME_RM,GlobalConstants.SME_TM,GlobalConstants.SME_AH,GlobalConstants.SME_NH};
    public static  Set<String> saleProfileRBS = new Set<String>{GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_RM_BAR,GlobalConstants.RBS_TM,GlobalConstants.RBS_AH};
    public static Set<String> appResultStatusClosed = new Set<String>{GlobalConstants.CLOSED_WON, GlobalConstants.CLOSE_LOST, GlobalConstants.AUTO_CLOSED, GlobalConstants.CANCELLED};
    private static Map<Id,User> userMap;
    private User currentUser;
    private List<Account> accountUpdateList;
    private User userData;
    private User_Extension__c userExtension;
    Map<Id,Opportunity> opportunityByOppIdMap;

    public override void init() {
        accountUpdateList   = new List<Account>();
        opportunityByOppIdMap = new Map<Id,Opportunity>();
        if(userMap == null) {
            userMap = new Map<Id,User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, ProfileId, Profile.Name, IsActive, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, AH_Employee_ID__c, NH_Employee_ID__c, UserRole.Name, Segment__c,RBS_User__c FROM User WHERE Id = :UserInfo.getUserId()]);    
        }
        currentUser = userMap.get(UserInfo.getUserId());
    }

    public override void allBefore() {
        userData = UserService.getCurrentUserInfo();
        List<User_Extension__c> userExtensions = [SELECT  Id,User__c,Name,Team_Structure__c,Team_Structure__r.Name, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE user__c = :userData.Id];
        if(userExtensions.size() > 0){

            userExtension = userExtensions[0];
        }
        Set<Id> relatedOppIDSet = new Set<Id>();
        Map<String, Application_Number__c> appNumberUpsertMapByRC = new Map<String, Application_Number__c>();
        String currentYear = String.valueOf(GlobalUtility.getYearInBuddhistCalendar(System.today()));

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
           relatedOppIDSet.add(eachApp.OppName__c);
        }

        List<Opportunity> oppList = [SELECT Id,Account.RC_Code__c,Business_Code_Text__c,Business_Code__c FROM Opportunity WHERE Id=:relatedOppIDSet];
        for(Opportunity eachOpp : oppList){
            opportunityByOppIdMap.put(eachOpp.Id,eachOpp);
        }

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new) {
            if(opportunityByOppIdMap.containsKey(eachApp.OppName__c)){
                if(eachApp.Business_Code_Text__c == null){
                    eachApp.Business_Code_Text__c = opportunityByOppIdMap.get(eachApp.OppName__c).Business_Code_Text__c;
                }
                if(eachApp.Business_Code__c == null){
                    eachApp.Business_Code__c = opportunityByOppIdMap.get(eachApp.OppName__c).Business_Code__c;
                }

                if(eachApp.RunningRC__c == null && eachApp.AppNum_NonCMAS__c == null && eachApp.RMSubmitChannel__c == GlobalConstants.NON_CMAS){
                    String rcCode;
                    if (opportunityByOppIdMap.get(eachApp.OppName__c) != null) {
                        rcCode = currentUser.RC_Code__c;
                        if(rcCode == null){
                            rcCode = GlobalConstants.NO_RC_CODE;
                        }
                    } else {
                        rcCode = GlobalConstants.NO_RC_CODE;
                    }
                    Application_Number__c applicationNumberByRC = Application_Number__c.getValues(rcCode);
                    if(applicationNumberByRC != null){
                        applicationNumberByRC.Running_Number__c = applicationNumberByRC.Running_Number__c + 1;
                        if (currentYear != applicationNumberByRC.Year__c) {
                            applicationNumberByRC.Year__c = currentYear;
                            applicationNumberByRC.Running_Number__c = 1;
                            applicationNumberByRC.Name = rcCode;
                        }
                    }else{
                        applicationNumberByRC = new Application_Number__c();
                        applicationNumberByRC.Name = rcCode;
                        applicationNumberByRC.Running_Number__c = 1;
                        applicationNumberByRC.Year__c = currentYear;
                    }
                    String runningNumberString = '000' + Integer.valueOf(applicationNumberByRC.Running_Number__c);
                    eachApp.RunningRC__c = runningNumberString.substring(runningNumberString.length() - 4);
                    appNumberUpsertMapByRC.put(rcCode, applicationNumberByRC);
                }
            }
        }

        if (appNumberUpsertMapByRC.size() > 0) {
            upsert appNumberUpsertMapByRC.values();
        }
    }

    public override void beforeInsert(){
        if(!ApplicationHistory_Service.byPassStampUserExtensionWhenInsert){
            for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new) {
                if(opportunityByOppIdMap.containsKey(eachApp.OppName__c)){
                    if(userExtension != null){
                        eachApp.Current_Owner_Extension__c = userExtension.Id;
                        eachApp.Current_Team_Name__c = userExtension.Team_Structure__c;
                    if(GlobalConstants.PROFILE_CBS_SET.contains(userData.Profile.Name)){
                        eachApp.Current_AH_Team__c = userExtension.Team_Structure__c; 
                    }else{
                        eachApp.Current_AH_Team__c = userExtension.Team_Structure__r.AH_Name__c; 
                    } 
                        eachApp.Current_NH_Team__c = userExtension.Team_Structure__r.NH_Name__c;
                    }
                }
            }
        }
    }

    public override void beforeUpdate() {
        Set<Id> applicationId = new Set<Id>();
        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new) {
            applicationId.add(eachApp.Id);
        }

        Set<Id> appIdRelateOppProductSet = new Set<Id>();
        List<OpportunityLineItem> oppLineItemsList = [SELECT Id, Application__c, Application_CBS__c FROM OpportunityLineItem WHERE Application__c IN :applicationId OR Application_CBS__c IN :applicationId];
        for(OpportunityLineItem eachOppLineItem : oppLineItemsList) {
            Id appRelatedId;
            if(eachOppLineItem.Application__c != NULL) {
                appRelatedId = eachOppLineItem.Application__c;
            } else if(eachOppLineItem.Application_CBS__c != NULL) {
                appRelatedId = eachOppLineItem.Application_CBS__c;
            }
            appIdRelateOppProductSet.add(appRelatedId);
        }

        User_Management__c userManagement = User_Management__c.getInstance();
        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new) {
            Application_History__c oldRecord = (Application_History__c)Trigger.oldMap.get(eachApp.Id);
            if(!userManagement.Allow_Change_Opportunity__c && 
               eachApp.Report_Actual_Visit_Date__c == oldRecord.Report_Actual_Visit_Date__c &&
               eachApp.Request_Process_Name__c == null &&
               appResultStatusClosed.contains(oldRecord.App_Result__c)) {
                eachApp.addError(Label.App_Not_Allow_Edit_Closed);
            }

            if(eachApp.App_Result__c == GlobalConstants.CLOSED_WON && !appIdRelateOppProductSet.contains(eachApp.Id)) {
                eachApp.addError(Label.Not_Allow_Close_Won_App);
            }

            if(eachApp.Request_Process_Name__c != null && oldRecord.App_Result__c != eachApp.App_Result__c){
                eachApp.Request_Process_Name__c = '';
            }
        }
    }

    public override void allAfter(){
        //industry data
        mapRelatedBusinessCode = new Map<String,Business_Code__c>();
        List<String> listBusinessCodeFromAppHis = new List<String>();
        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
            listBusinessCodeFromAppHis.add(eachApp.SPBusinessCode__c);
        }
        Map<String,Business_Code__c> mapTempBusinessCode = new Map<String,Business_Code__c>();
        List<Business_Code__c> listRelatedBusinessCode = [SELECT Id,Name,Segment__c FROM Business_Code__c WHERE Name IN :listBusinessCodeFromAppHis];
        for(Business_Code__c eachBusinessCode : listRelatedBusinessCode){
            mapTempBusinessCode.put(eachBusinessCode.Name+':'+eachBusinessCode.Segment__c, eachBusinessCode);
        }

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
            if(mapTempBusinessCode.containsKey(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c)){
                mapRelatedBusinessCode.put(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c, mapTempBusinessCode.get(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c));
            }
        }
        ApplicationHistory_Service.upsertOpportunityProductNonCMAS((List<Application_History__c>) Trigger.new);
    }

    public override void afterUpdate() {
        Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
        Map<String, Set<String>> completeOppIdsMapBySegment = new Map<String, Set<String>>();
        Map<Id, Target_List__c> targetNewbookingMapByAppId = new Map<Id, Target_List__c>();
        List<Target_List__c> deleteTargetList = new List<Target_List__c>();
        List<Opportunity> relatedOppList = new List<Opportunity>();
        Set<Id> relatedOppIDSet = new Set<Id>();
        Set<Id> relatedAccountIdSet = new Set<Id>();
        Map<Id,Account> allAccountRelateByIdMap = new Map<Id,Account>();
        Boolean addAccount;
        Map<Id,Account> oppAccountByOppIdMap = new Map<Id,Account>();
        Map<Id,Opportunity> opportunityByIdMap = new Map<Id,Opportunity>();
        Map<Id,Application_History__c> applicationChangeStatusMap = new Map<Id,Application_History__c>();
        List<AccountTeamMember> afAccountTeamList = new List<AccountTeamMember>();

        String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        String RECORDTYPE_TARGETLIST_STANDARD = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c','Standard'); 

        if(campaignNewBookingCode != null) {
            for(Target_List__c target : [Select Application_History__c, Lead_Campaign__c, Name, Status__c, Approved_Amount__c, Setup_Amount__c, Campaign_Reward_Calc__c, Option__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c = :campaignNewBookingCode AND Application_History__c IN :Trigger.New]){
                targetNewbookingMapByAppId.put(target.Application_History__c, target);    
            }
        }

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
            relatedOppIDSet.add(eachApp.OppName__c);
        }
        
        relatedOppList = [SELECT Id, OwnerId, AccountId, Account.OwnerId FROM Opportunity WHERE Id=:relatedOppIDSet];
        for(Opportunity eachOpp : relatedOppList){
            opportunityByIdMap.put(eachOpp.Id, eachOpp);
            relatedAccountIdSet.add(eachOpp.AccountId);
        }

        List<Account> appAccountList = [SELECT Id, Customer_s_Business_Code__c, CIS__c, FinServ__ReferredByUser__c, Is_RBS__c, Trash_Pool_Flag__c, Dual_RM_Name__r.Profile.Name, Primary_Segment_Code__c, Current_Activity__c, Current_Activity_By__c, Last_Setup_By__c,Last_Setup_Date__c,Owner_Emp_ID__c, Port_Pool__c, OwnerId, Owner.Segment__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Ownership_Text__c, Owner.AH_RC_CODE__c, Owner.NH_RC_CODE__c, Customer_Owner_Release_Flag__c, Temp_Owner_Changed_Date__c, Owner.Name, Owner.Profile.Name, Previous_Owner__c,Sales_Size__c FROM Account WHERE Id =:relatedAccountIdSet];
        for(Account eachAccount : appAccountList){
            allAccountRelateByIdMap.put(eachAccount.Id, eachAccount);
        }

        for(Opportunity eachOpp : relatedOppList){
            if(allAccountRelateByIdMap.containsKey(eachOpp.AccountId)){
                oppAccountByOppIdMap.put(eachOpp.Id,allAccountRelateByIdMap.get(eachOpp.AccountId));
            }
        }

        for(Application_History__c eachApplicationHistory : (List<Application_History__c>)Trigger.new){
            addAccount = false;
            Account accountRecord = oppAccountByOppIdMap.get(eachApplicationHistory.OppName__c);
            Application_History__c oldApp = (Application_History__c) Trigger.oldMap.get(eachApplicationHistory.Id);
            if(oldApp.App_Result__c != eachApplicationHistory.App_Result__c){
                if(eachApplicationHistory.App_Result__c == GlobalConstants.CLOSED_WON) {
                    Account_Service.isApplication = true;
                    if(eachApplicationHistory.SP_Submit_Issue__c == GlobalConstants.NEW_CREDIT) {
                        if(accountRecord.OwnerId != opportunityByIdMap.get(eachApplicationHistory.OppName__c).OwnerId) {
                            //move AF user to AF RM Name : 15/08/2018 : Wongsakorn.S
                            if(GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name)) {
                                accountRecord.Dual_RM_Name__c = accountRecord.OwnerId;
                                accountRecord.Port_Pool_Dual_RM__c = accountRecord.Port_Pool__c;
                                afAccountTeamList.add(addAFAccountTeamMember(accountRecord));
                            }
                            accountRecord.OwnerId                   = opportunityByIdMap.get(eachApplicationHistory.OppName__c).OwnerId;
                            accountRecord.SME_Temporary_Customer__c = null;
                            accountRecord.Port_Pool__c              = GlobalConstants.PORT;
                            accountRecord.Ownership_Text__c         = GlobalConstants.OWNERSHIP_PERMANENT;
                            addAccount = true;
                        }
                    }
                    if(!targetNewbookingMapByAppId.containsKey(eachApplicationHistory.Id)) {
                        if(!completeOppIdsMapBySegment.containsKey(currentUser.Segment__c)){
                            completeOppIdsMapBySegment.put(currentUser.Segment__c, new Set<String>());
                        }
                        completeOppIdsMapBySegment.get(currentUser.Segment__c).add(eachApplicationHistory.Id);
                    }
                } else if(oldApp.App_Result__c == GlobalConstants.CLOSED_WON) {
                    if(targetNewbookingMapByAppId.containsKey(eachApplicationHistory.Id)) {
                        if(targetNewbookingMapByAppId.get(eachApplicationHistory.Id).Status__c == GlobalConstants.STATUS_NEW)
                        deleteTargetList.add(targetNewbookingMapByAppId.get(eachApplicationHistory.Id));
                    }
                }

                applicationChangeStatusMap.put(eachApplicationHistory.Id,eachApplicationHistory);
            }
            if(addAccount){
                accountUpdateList.add(accountRecord);
            }
        }
        if(!applicationChangeStatusMap.isEmpty()) autoUpdateOppLineItemStatus(applicationChangeStatusMap);  
        if(accountUpdateList.size() > 0) update accountUpdateList;
        if(afAccountTeamList.size() > 0) insert afAccountTeamList;//add account team for AF user : 15/08/2018 : Wongsakorn.S
        if(!completeOppIdsMapBySegment.isEmpty()) CampaignRewardCalculation.insertTargetList(completeOppIdsMapBySegment, RECORDTYPE_TARGETLIST_STANDARD);
        
        TriggerHandler.bypass('TargetListTriggerHandler');
        if(!deleteTargetList.isEmpty()) delete deleteTargetList;
        TriggerHandler.clearBypass('TargetListTriggerHandler');
    }

    private AccountTeamMember addAFAccountTeamMember(Account accountRecord) {
        return new AccountTeamMember(
            AccountId               = accountRecord.Id,
            UserId                  = accountRecord.OwnerId,
            AccountAccessLevel      = 'Edit',
            OpportunityAccessLevel  = 'Edit',
            CaseAccessLevel         = 'None',
            ContactAccessLevel      = 'Edit'
        );
    }

    private void autoUpdateOppLineItemStatus(Map<Id,Application_History__c> applicationChangeStatusByAppIdMap){
        Set<Id> oppLineItemsId = new Set<Id>();
        oppLineItemsId = applicationChangeStatusByAppIdMap.keySet();
        List<OpportunityLineItem> oppLineItemsList = [SELECT Id, Application__c, Application_CBS__c, Status__c, Status_CBS__c,Close_Date__c FROM OpportunityLineItem WHERE Application__c IN:oppLineItemsId OR Application_CBS__c IN:oppLineItemsId];
        for(OpportunityLineItem eachOppLineItem : oppLineItemsList){
            Id appRelatedId;
            if(eachOppLineItem.Application__c != NULL){
                appRelatedId = eachOppLineItem.Application__c;
            }else if(eachOppLineItem.Application_CBS__c != NULL){
                appRelatedId = eachOppLineItem.Application_CBS__c;
            }
            if(appRelatedId != NULL && applicationChangeStatusByAppIdMap.containsKey(appRelatedId)){
                String appResult = applicationChangeStatusByAppIdMap.get(appRelatedId).App_Result__c;
                if(appResult == GlobalConstants.WORK_IN_PROGRESS) {
                    eachOppLineItem.Status_CBS__c = GlobalConstants.ON_PROCESS;
                } else {
                    eachOppLineItem.Status_CBS__c = appResult;
                    if(appResultStatusClosed.contains(appResult) && eachOppLineItem.Close_Date__c ==null){
                        eachOppLineItem.Close_Date__c = System.today();
                    }
                }
            }
        }
        ApplicationHistory_Service.byPassValidateOpportunityProduct = true;
        TriggerHandler.bypass('OpportunityProductTriggerHandler');
            update oppLineItemsList;
        TriggerHandler.clearBypass('OpportunityProductTriggerHandler');
    }
}