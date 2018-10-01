/**
* @author komsan.wi@beryl8.com
* @16/07/2015 Create
* @06/10/2015 use normal map for target list instead of map of list to prevent duplicate list, beware for wrong stage when uploading object
* @27/01/2015 Add Temporary_Ownership_Flag__c = true on case create opportunity from pool (UAT-RMS-00415)
* @30/06/2016 Chumphon K., ISCR030 Change condition for NewBooking Campaign
* @08/07/2016 Chumphon K., ISCR032 Add targetlist to NewBooking campaign only for RM segment SE and ME
* @06/07/2016 Update Target status based on RTM : A2 - ISCR028
* @07/07/2016 Stamp Current AH and Current NH
* @18/01/2017 Chumphon K., ISCR055 Campaign Thankyou Change Condition
* @14/02/2017 Add CR023 and Refactor code
* @14/02/2018 Refactor & Re process for FSC RBS
*/
public class OpportunityTriggerHandler_Old extends TriggerHandler {
    private List<Account> accountUpdateList;
    //private List<Account> accountUpdateWithNoByPass;
    private User currentUser;
    private User_Extension__c userExtension;
    private Boolean isCurrentUser_UW;
    private Id recordTypeClosedServicing;
    private Boolean isErrorTemporary;

    private Map<String, Id> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;

    private static Map<Id, Account> accountMap;
    private static Map<Id,User> userMap;
    private static Map<Id, User> oppOwnerMap; 

    private static Set<Id> accountSetStatic;
 
    private Map<Id,String> businessCodeTextMapOppId;
    //private List<String> effectiveDate = Label.opportunityRequireBusinessCodeDate.split('-');
    private static Map<Id,Target_List__c> mapChangeStatusTglById;

    private Map<String,Id> businessCodeIdMapbyExternalKey;
    private Map<Id,List<OpportunityLineItem>> opportunityLineItemByOppIdMap;
    private Map<Id,List<Event>> eventByOppIdMap;
    private Map<Id,List<Application_History__c>> appHistoryByOppIdMap;
    private Map<id,List<AccountTeamMember>> accountTeamMembersByIdMap;
    
    public override void init() {
        if(userMap == null) {
            userMap = new Map<Id,User>([SELECT Id, Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, ProfileId, Profile.Name, IsActive, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, AH_Employee_ID__c, NH_Employee_ID__c, UserRole.Name, Segment__c,RBS_User__c FROM User]);    
        }
        currentUser = userMap.get(UserInfo.getUserId());
        isCurrentUser_UW = currentUser.Profile.Name.contains('UW');
        recordTypeClosedServicing = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity','Closed_Servicing_Opportunity');
        if(mapChangeStatusTglById == null){
            mapChangeStatusTglById = new Map<Id,Target_List__c>();
        }
    }

    public override void allBefore() {
        System.debug('allBefore');
        businessCodeTextMapOppId = new Map<Id,String>();
        //accountUpdateWithNoByPass = new List<Account>();
        accountUpdateList   = new List<Account>();
        teamMapByRc         = new Map<String, Id>();
        userExtMapByEmpId   = new Map<String, Id>();
        oppOwnerMap         = new Map<Id, User>();
        businessCodeIdMapbyExternalKey  = new Map<String,Id>();
        Set<String> relateBusinessCodeSet = new Set<String>();
        // Init in All Before use in Before and After

        //Set<Id> accountSet = new Set<Id>();
        
        //Boolean reQueryAccount = false;
        //for (Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
        //    accountSet.add(eachOpportunity.AccountId);
        //    //if(accountSetStatic == null){
        //    //    accountSetStatic = new Set<Id>();
        //    //}
        //    //if(!accountSetStatic.contains(eachOpportunity.AccountId)){
        //    //    reQueryAccount = true;
        //    //    accountSetStatic.add(eachOpportunity.AccountId);
        //    //}
        //}

        //if(reQueryAccount){
            
        //}
        if(accountMap == null){
            accountMap = Opportunity_Service.getAccountMapByOpportunity((List<Opportunity>)Trigger.new);
        }
        //
        for(Account eachAccount : accountMap.values()){
            relateBusinessCodeSet.add(eachAccount.Customer_s_Business_Code__c+':'+eachAccount.Owner.Segment__c);
        }
        List<Business_Code__c> businessCodeList = [SELECT Id,External_ID__c FROM Business_Code__c WHERE External_ID__c=:relateBusinessCodeSet];
        for(Business_Code__c  eachBusiness :businessCodeList){
            businessCodeIdMapbyExternalKey.put(eachBusiness.External_ID__c,eachBusiness.Id);
        }
        userExtMapByEmpId = Opportunity_Service.getAllUserExtensionMapByEmp();
        teamMapByRc = Opportunity_Service.getAllRelatedTeamMapByExternalId();
    }
    /*private Boolean isHaveOwnerJobStage(id accountId,Set<String> segments){

       Boolean isOwner = false;
       List<Opportunity> opp = [SELECT Id, Owner.Profile.name, ownerid, Jobstage__c, AccountId FROM Opportunity where AccountId = :accountId AND Owner.profile.name in :segments AND Jobstage__c  != :GlobalConstants.FINISHED]; //ownerid  = :ownerId AND
       if(opp.size() != 0){
         isOwner = true;
       }
       return isOwner;
    }*/

    public override void beforeInsert() {

        //Boolean addAccount;
        //Set<Id> AccountIdItemSet = new Set<Id>();
        //for (Opportunity eachOpportunityItem : ((List<Opportunity>) Trigger.new)) {
        //    AccountIdItemSet.add(eachOpportunityItem.AccountId);
        //}
        //userExtension = [SELECT  Id,User__c,Name,Team_Structure__c,Team_Structure__r.Name, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE User__c = :currentUser.Id];
        //List<AccountTeamMember> accountTeamVal =  [SELECT Id, TeamMemberRole, Account.Name, Account.Id, User.Name, UserId FROM AccountTeamMember WHERE Account.Id in :AccountIdItemSet and UserId = :currentUser.Id];
        //accountTeamMembersByIdMap =  new Map<id,List<AccountTeamMember>>();

        //for(AccountTeamMember accountTeam : accountTeamVal){
        //    if(accountTeamMembersByIdMap.containsKey(accountTeam.Account.Id)){
        //        accountTeamMembersByIdMap.get(accountTeam.Account.Id).add(accountTeam);
        //    }else{
        //        accountTeamMembersByIdMap.put(accountTeam.Account.Id, new List<AccountTeamMember>{accountTeam});
        //    } 
        //}
        for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
            if(eachOpportunity.Business_Code_Text__c == null){
                if(accountMap.containsKey(eachOpportunity.AccountId) && accountMap.get(eachOpportunity.AccountId).Customer_s_Business_Code__c != null){
                    Account accountRecord = accountMap.get(eachOpportunity.AccountId);
                    eachOpportunity.Business_Code_Text__c = accountRecord.Customer_s_Business_Code__c;
                    if(businessCodeIdMapbyExternalKey.containsKey(accountRecord.Customer_s_Business_Code__c+':'+accountRecord.Owner.Segment__c)){
                        eachOpportunity.Business_Code__c = businessCodeIdMapbyExternalKey.get(accountRecord.Customer_s_Business_Code__c+':'+accountRecord.Owner.Segment__c);
                    }
                }
            }
            //checkJobPermission(eachOpportunity);
        }
        //UW_Service.setUW((List<Opportunity>)Trigger.new);
        //if(!businessCodeTextMapOppId.isEmpty()){
        //    Customer_BusinessCode_Service.upsertCustomerBusinessCodeFromOpportunity((List<Opportunity>)Trigger.new,null,businessCodeTextMapOppId,false,accountMap);
        //}        
    }

    public override void afterInsert(){
        //tua test binding with tgl for  P'N'Tong
        if(accountMap == null){
            accountMap = Opportunity_Service.getAccountMapByOpportunity((List<Opportunity>)Trigger.new);
        }
        Boolean addAccount;
        Set<Id> AccountIdItemSet = new Set<Id>();

        for (Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)) {
            AccountIdItemSet.add(eachOpportunity.AccountId);
        }



        userExtension = [SELECT  Id,User__c,Name,Team_Structure__c,Team_Structure__r.Name, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE User__c = :currentUser.Id];
        List<AccountTeamMember> accountTeamList =  [SELECT Id, TeamMemberRole, Account.Name, Account.Id, User.Name, UserId FROM AccountTeamMember WHERE Account.Id in :AccountIdItemSet and UserId = :currentUser.Id];
        accountTeamMembersByIdMap =  new Map<id,List<AccountTeamMember>>();

        for(AccountTeamMember accountTeam : accountTeamList){
            if(accountTeamMembersByIdMap.containsKey(accountTeam.Account.Id)){
                accountTeamMembersByIdMap.get(accountTeam.Account.Id).add(accountTeam);
            }else{
                accountTeamMembersByIdMap.put(accountTeam.Account.Id, new List<AccountTeamMember>{accountTeam});
            } 
        }

        for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){

            //if(eachOpportunity.Business_Code_Text__c == null){
            //    if(accountMap.containsKey(eachOpportunity.AccountId) && accountMap.get(eachOpportunity.AccountId).Customer_s_Business_Code__c != null){
            //        Account accountRecord = accountMap.get(eachOpportunity.AccountId);
            //        eachOpportunity.Business_Code_Text__c = accountRecord.Customer_s_Business_Code__c;
            //        if(businessCodeIdMapbyExternalKey.containsKey(accountRecord.Customer_s_Business_Code__c+':'+accountRecord.Owner.Segment__c)){
            //            eachOpportunity.Business_Code__c = businessCodeIdMapbyExternalKey.get(accountRecord.Customer_s_Business_Code__c+':'+accountRecord.Owner.Segment__c);
            //        }
            //    }
            //}
            checkJobPermission(eachOpportunity);
            if(accountMap.containsKey(eachOpportunity.AccountId)){
                Account accountRecord = accountMap.get(eachOpportunity.AccountId);
                if(accountRecord.Port_Pool__c == GlobalConstants.PORT){
                    if((GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name) && GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name))
                    ||(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name) && GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Owner.Profile.Name))
                    ||(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name) && GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Owner.Profile.Name))
                    ||(GlobalConstants.PROFILE_SME_SET.contains(currentUser.Profile.Name) && GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name))
                    ||(GlobalConstants.PROFILE_CBS_SET.contains(currentUser.Profile.Name) && GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name))){                 
                        String msg = System.Label.NotificationMsg_JobCreatedNotifyOwner + ' ' + currentUser.Name;
                        GlobalUtility.createBellNotification(accountRecord.OwnerId,eachOpportunity.Id,msg);
                    }
                }
            }

        }


        UW_Service.setUW((List<Opportunity>)Trigger.new);
        if(businessCodeTextMapOppId != null && !businessCodeTextMapOppId.isEmpty()){
            Customer_BusinessCode_Service.upsertCustomerBusinessCodeFromOpportunity((List<Opportunity>)Trigger.new,null,businessCodeTextMapOppId,false,accountMap);
        }

    }


    private void checkConditionsFinishJob(Account accountRecord, Opportunity eachOpportunity){
        if(eachOpportunity.StageName == GlobalConstants.FINISHED){
           if(currentUser.id == eachOpportunity.OwnerId || currentUser.Profile.Name == 'System Administrator'){              
                List<Event> events = eventByOppIdMap.get(eachOpportunity.Id);
                if(events != null){
                    for(Event event : events){
                        if(event.Status__c == GlobalConstants.PLAN){
                            eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_CALLPLAN);
                            return;
                        }
                    }
                }      

                List<OpportunityLineItem> oppLineItems =  opportunityLineItemByOppIdMap.get(eachOpportunity.Id);
                if(oppLineItems != null){
                    for(OpportunityLineItem oppItem : oppLineItems){
                        if((GlobalConstants.PROFILE_SME_SET.contains(oppItem.CreatedBy.Profile.Name) || GlobalConstants.PROFILE_CBS_SET.contains(oppItem.CreatedBy.Profile.Name)) && GlobalConstants.OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB.contains(oppItem.Status_CBS__c)){
                            eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_OPPPRODUCT);
                            return;
                        }else if((GlobalConstants.PROFILE_RBS_SET.contains(oppItem.CreatedBy.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(oppItem.CreatedBy.Profile.Name)) && GlobalConstants.OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB.contains(oppItem.Status__c)){

                            eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_OPPPRODUCT);
                            return;
                        }
                    }
                }                

                List<Application_History__c> appHistorys = appHistoryByOppIdMap.get(eachOpportunity.Id);
                if(appHistorys != null){
                    for(Application_History__c appHis : appHistorys){
                        if(appHis.App_Result__c == GlobalConstants.WORK_IN_PROGRESS || String.isBlank(appHis.App_Result__c)){
                            eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_APPRESULT);
                            return;
                        }
                    }
                }
                
                eachOpportunity.CloseDate = Date.today();
                eachOpportunity.Jobstage__c = 'Finished';
                eachOpportunity.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Opportunity','Closed_Job');
            }else{
                eachOpportunity.addError(ExceptionMessage.NO_AUTHORIZATION_UPDATEJOB);
            }    
        }
        
    }

    public override void beforeUpdate() {
        Account_Service.temporaryOwnershipFlag = false;
        Boolean addAccount;
        Boolean isNotBypassAccountTrigger;

        Set<Id> oppLineItemSet = new Set<Id>();
        for (Opportunity eachOpportunityItem : ((List<Opportunity>) Trigger.new)) {
            oppLineItemSet.add(eachOpportunityItem.id);
        }

        eventByOppIdMap = new Map<Id,List<Event>>();
        List<Event> eventList = [select id, job__c , Status__c from event where job__c in :oppLineItemSet];
        for(Event eachOpp : eventList){
            if(eventByOppIdMap.get(eachOpp.job__c) != null){
                eventByOppIdMap.get(eachOpp.job__c).add(eachOpp);
            }else{
                eventByOppIdMap.put(eachOpp.job__c, new List<Event>{eachOpp});
            }          
        }
        
        opportunityLineItemByOppIdMap = new Map<Id,List<OpportunityLineItem>>();

        List<OpportunityLineItem> opportItemList = [select id, OpportunityId, Status__c, Status_CBS__c, CreatedBy.Profile.Name, CreatedById from OpportunityLineItem where OpportunityId in :oppLineItemSet];

        for(OpportunityLineItem eachOpp : opportItemList){
            if(opportunityLineItemByOppIdMap.get(eachOpp.OpportunityId) != null){
                opportunityLineItemByOppIdMap.get(eachOpp.OpportunityId).add(eachOpp);
            }else{
                opportunityLineItemByOppIdMap.put(eachOpp.OpportunityId, new List<OpportunityLineItem>{eachOpp});
            }          
        }

        appHistoryByOppIdMap = new Map<Id,List<Application_History__c>>();
        List<Application_History__c> appHistoryList = [select id, OppName__c, App_Result__c from Application_History__c where OppName__c in :oppLineItemSet];
        for(Application_History__c eachOpp : appHistoryList){
            if(appHistoryByOppIdMap.get(eachOpp.OppName__c) != null){
                appHistoryByOppIdMap.get(eachOpp.OppName__c).add(eachOpp);
            }else{
                appHistoryByOppIdMap.put(eachOpp.OppName__c, new List<Application_History__c>{eachOpp});
            }          
        }


        for (Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)) {
            isNotBypassAccountTrigger = false;
            Opportunity oldRecord = (Opportunity)Trigger.oldMap.get(eachOpportunity.Id);
            
            addAccount = false;
            Account accountRecord = accountMap.get(eachOpportunity.AccountId);

            if(accountRecord != null) {
                if(oldRecord.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName == GlobalConstants.FINISHED){
                    checkConditionsFinishJob(accountRecord, eachOpportunity);
                    accountRecord.SME_Temporary_Customer__c = null;
                    accountRecord.AF_Temporary_Customer__c = null;  
                }             
            }
        }
        if(!businessCodeTextMapOppId.isEmpty()){
            Customer_BusinessCode_Service.upsertCustomerBusinessCodeFromOpportunity((List<Opportunity>)Trigger.new,(Map<Id,Opportunity>)Trigger.oldMap,businessCodeTextMapOppId,isCurrentUser_UW,accountMap);
        }
    }

    public override void afterFinally(){
        if(mapChangeStatusTglById.values().size() > 0){
            TriggerHandler.bypass('TargetListTriggerHandler');
            update mapChangeStatusTglById.values();
            TriggerHandler.clearbypass('TargetListTriggerHandler');
        }
    }

    public override void beforeFinally() {

        if(!accountUpdateList.isEmpty()){
            TriggerHandler.bypass('AccountTriggerHandler');
                update accountUpdateList;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
        
    }

    public override void afterUpdate(){
    }

    private void stampTemporary(String segment, Account account){

        if(account.Port_Pool__c != GlobalConstants.PORT){

            if(segment == 'SME'){
                account.SME_Temporary_Customer__c = userExtension.Id;
            }else if(segment == 'AF'){
                account.AF_Temporary_Customer__c = userExtension.Id;
            }
            accountUpdateList.add(account);
        }     
    }

    private Boolean isCanCreateByCheckTemporaryCustomer(String segment, Account account, Opportunity dataOpportunity){

        if(segment == 'SME' && account.SME_Temporary_Customer__c != null){
            if(account.SME_Temporary_Customer__r.User__c == currentUser.Id){
                return true;
            }
        }else if(segment == 'AF' && account.AF_Temporary_Customer__c != null){
            if(account.AF_Temporary_Customer__r.User__c == currentUser.Id){
                return true;
            }
        }else if((segment == 'SME' && account.SME_Temporary_Customer__c == null) 
              || (segment == 'AF' && account.AF_Temporary_Customer__c == null)){

            return true;
        }  

        dataOpportunity.addError(Label.CantCreateJobAlreadyTakeTemp);
        isErrorTemporary = true;
        return false;
    }

    private void checkJobPermission(Opportunity dataOpportunity){

        Boolean cannotInsert = true;
        isErrorTemporary = false;
        if(accountMap.containsKey(dataOpportunity.AccountId)){
            Account accountRecord = accountMap.get(dataOpportunity.AccountId);
            if(accountRecord.Temporary_Customer__c == true || checkAccountTeam(dataOpportunity.AccountId) || accountRecord.OwnerId == currentUser.Id || accountRecord.Dual_RM_Name__c == currentUser.Id){
                return;
            }
            if(GlobalConstants.PROFILE_SME_SET.contains(currentUser.Profile.Name)){ //SME Segment
                if(GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Owner.Profile.Name)){
                    //GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Dual_RM_Name__r.Profile.Name)
                   if(accountRecord.Port_Pool__c == GlobalConstants.PORT && (accountRecord.OwnerId == currentUser.Id || checkAccountTeam(dataOpportunity.AccountId))){
                        cannotInsert = false;
                    }else if(accountRecord.Port_Pool__c == GlobalConstants.POOL && isCanCreateByCheckTemporaryCustomer('SME', accountRecord, dataOpportunity)){
                        cannotInsert = false;
                        stampTemporary('SME', accountRecord);
                    }
                }else if((GlobalConstants.PROFILE_RBS_SET.contains(accountRecord.Owner.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name)) && isCanCreateByCheckTemporaryCustomer('SME', accountRecord, dataOpportunity)){
                    cannotInsert = false;
                    stampTemporary('SME', accountRecord);
                } 
            }else if(GlobalConstants.PROFILE_CBS_SET.contains(currentUser.Profile.Name)){ //CBS Segment
                if(GlobalConstants.PROFILE_RBS_SET.contains(accountRecord.Owner.Profile.Name) 
                    || (GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name))
                    || (accountRecord.Port_Pool__c == GlobalConstants.POOL && GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Owner.Profile.Name))){
                    cannotInsert = false;
                }else if(GlobalConstants.PROFILE_CBS_SET.contains(accountRecord.Owner.Profile.Name) && accountRecord.Port_Pool__c == GlobalConstants.PORT && (accountRecord.OwnerId == currentUser.Id || checkAccountTeam(dataOpportunity.AccountId))){
                    cannotInsert = false;
                }
            }else if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name)){ //RBS Segment
                    cannotInsert = false;
                    if(GlobalConstants.PROFILE_CBS_SET.contains(accountRecord.Owner.Profile.Name)){
                        cannotInsert = true;
                    }
            }else if(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)){ //AF Segment
                    if((GlobalConstants.PROFILE_RBS_SET.contains(accountRecord.Owner.Profile.Name) || GlobalConstants.PROFILE_SME_SET.contains(accountRecord.Owner.Profile.Name)) && isCanCreateByCheckTemporaryCustomer('AF', accountRecord, dataOpportunity)){
                        cannotInsert = false;
                        stampTemporary('AF', accountRecord);
                    }else if(accountRecord.Port_Pool__c == GlobalConstants.PORT && GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name)){
                        if(accountRecord.OwnerId == currentUser.Id || checkAccountTeam(dataOpportunity.AccountId)){
                           cannotInsert = false; 
                        }
                    }else if(accountRecord.Port_Pool__c == GlobalConstants.POOL && GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name) && isCanCreateByCheckTemporaryCustomer('AF', accountRecord, dataOpportunity)){
                        cannotInsert = false;
                        stampTemporary('AF', accountRecord);
                    }

            }else if(currentUser.Profile.Name == 'System Administrator'){
                cannotInsert = false;
            }
            
            if(cannotInsert && !isErrorTemporary){
                dataOpportunity.addError(Label.CantCreateJobNotOwner);
            }
        }
    }
    
    private Boolean checkAccountTeam(Id accountId){
        Boolean isHaveAccountTeam = false;
        //List<AccountTeamMember> accountTeamVal = [Select id, teammemberrole, Account.name, User.name from AccountTeamMember where User.name = :accountRecord.Owner.Name or User.name = :accountRecord.Dual_RM_Name__r.Name];
        if(accountTeamMembersByIdMap.get(accountId) != null){
            isHaveAccountTeam = true;
        }
        return isHaveAccountTeam;
    }

    //private Boolean isPassrequireBusinessCodeOpportunity(Opportunity eachOpp){
    //    Boolean isPass = true;
    //    Integer effectiveYear  = Integer.valueOf(effectiveDate.get(0));
    //    Integer effectiveMonth = Integer.valueOf(effectiveDate.get(1));
    //    Integer effectiveDay   = Integer.valueOf(effectiveDate.get(2));
    //    //if(eachOpp.Business_Code__c == null && GlobalConstants.SME_SEGMENT_CODE_SET.contains(eachOpp.Owner_Segment_Business_Code__c) ){
    //    if(eachOpp.Business_Code__c == null){
    //        if(eachOpp.createdDate == null){
    //            isPass = false;
    //        }else{
    //            Integer oppcreatedYear = GlobalUtility.getYearInChristianCalendar(eachOpp.createdDate);
    //                if(oppcreatedYear > effectiveYear
    //                || (oppcreatedYear == effectiveYear && eachOpp.createdDate.month() > effectiveMonth)
    //                || (oppcreatedYear == effectiveYear && eachOpp.createdDate.month() == effectiveMonth && eachOpp.createdDate.day() >= effectiveDay)){
    //                    isPass = false;
    //                }  
    //        }
    //    }
    //    return isPass;
    //}

    //private Boolean isPassOwnerAndCreditPLonOpportunity(Account tempAccountRecord, Opportunity eachOpp, User currentUser){
    //    Boolean isPass = true;
    //    if(tempAccountRecord.OwnerId != currentUser.Id && eachOpp.Credit_Model__c == 'PL' ){
    //        isPass = false;
    //    }
    //    return isPass;
    //}
}