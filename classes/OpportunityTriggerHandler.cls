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
public class OpportunityTriggerHandler extends TriggerHandler {
    private Map<Id,Account> accountUpdateList;
    private User currentUser;
    private User_Extension__c userExtension;
    private Boolean isCurrentUser_UW;
    private Id recordTypeClosedServicing;

    private Map<String, Id> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;

    private static Map<Id, Account> accountMap;
    private static Map<Id,User> userMap;

    private static Set<Id> accountSetStatic;
 
    private Map<Id,String> businessCodeTextMapOppId;
    private static Map<Id,Target_List__c> mapChangeStatusTglById;

    private Map<String,Id> businessCodeIdMapbyExternalKey;
    private Map<Id,List<OpportunityLineItem>> opportunityLineItemByOppIdMap;
    private Map<Id,List<Event>> eventByOppIdMap;
    private Map<Id,List<Application_History__c>> appHistoryByOppIdMap;
    private Map<id,List<AccountTeamMember>> accountTeamMembersByIdMap;
    private List<Pool_Visibility__c> poolList;
    Set<String> eventStatusCloseSet = new Set<String>{GlobalConstants.CONTACTED,GlobalConstants.CANCELLED,GlobalConstants.CLOSED,GlobalConstants.REJECTED};
    
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
        businessCodeTextMapOppId = new Map<Id,String>();
        accountUpdateList   = new Map<Id,Account>();
        teamMapByRc         = new Map<String, Id>();
        userExtMapByEmpId   = new Map<String, Id>();
        businessCodeIdMapbyExternalKey  = new Map<String,Id>();
        Set<String> relateBusinessCodeSet = new Set<String>();
       
        accountMap = Opportunity_Service.getAccountMapByOpportunity((List<Opportunity>)Trigger.new);

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

    public override void beforeInsert() {
        OpportunityProductField__c opportunityProductField = OpportunityProductField__c.getOrgDefaults();
        User_Extension__c currentUserExt = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
        for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
            if(opportunityProductField != null && opportunityProductField.Pricebook2Id__c != null) {
                eachOpportunity.Pricebook2Id = opportunityProductField.Pricebook2Id__c;
            }
            if(eachOpportunity.Business_Code_Text__c == null){
                if(accountMap.containsKey(eachOpportunity.AccountId) && accountMap.get(eachOpportunity.AccountId).Customer_s_Business_Code__c != null){
                    Account accountRecord = accountMap.get(eachOpportunity.AccountId);
                    eachOpportunity.Business_Code_Text__c = accountRecord.Customer_s_Business_Code__c.leftPad(9,'0');
                    if(businessCodeIdMapbyExternalKey.containsKey(accountRecord.Customer_s_Business_Code__c+':'+accountRecord.Owner.Segment__c)){
                        eachOpportunity.Business_Code__c = businessCodeIdMapbyExternalKey.get(accountRecord.Customer_s_Business_Code__c.leftPad(9,'0')+':'+accountRecord.Owner.Segment__c);
                    }
                }
            }
            if(accountMap.containsKey(eachOpportunity.AccountId)){
                eachOpportunity.Port_Pool__c = accountMap.get(eachOpportunity.AccountId).Port_Pool__c;
            }
            if(currentUserExt != null){

                eachOpportunity.Current_Owner_Extension__c = currentUserExt.Id;
                eachOpportunity.Current_Team_Name__c = currentUserExt.Team_Structure__c;
            }       
        }
        //Have update some record is cannot move to after insert
        UW_Service.setUW((List<Opportunity>)Trigger.new);       
    }

    public override void afterInsert(){
        accountUpdateList = new Map<Id,Account>();
        List<Id> possibleUserExtensionListId = new List<Id>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        Map<Id,User_Extension__c> userExtensionMapUserId = new Map<Id,User_Extension__c>();
        possibleUserExtensionListId.add(currentUser.Id);
        poolList = Pool_Visibility__c.getall().values();
        accountMap = Opportunity_Service.getAccountMapByOpportunity((List<Opportunity>)Trigger.new);

        Boolean addAccount;
        Set<Id> AccountIdItemSet = new Set<Id>();
        for (Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)) {
            AccountIdItemSet.add(eachOpportunity.AccountId);
            possibleUserExtensionListId.add(eachOpportunity.CreatedById);
        }
        userExtensionMapUserId = UserExtension_Service.getUserExtensionMapByUserId(possibleUserExtensionListId);
        if(userExtensionMapUserId.containsKey(currentUser.Id)) userExtension = userExtensionMapUserId.get(currentUser.Id);
        for(Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)){
            if(userExtensionMapUserId.containsKey(eachOpportunity.CreatedById)){
                updateOpportunityList.add(new Opportunity(Id = eachOpportunity.Id, Created_By_User_Extension__c = userExtensionMapUserId.get(eachOpportunity.CreatedById).Id));
            }
        }
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
        
        if(businessCodeTextMapOppId != null && !businessCodeTextMapOppId.isEmpty()){
            Customer_BusinessCode_Service.upsertCustomerBusinessCodeFromOpportunity((List<Opportunity>)Trigger.new,null,businessCodeTextMapOppId,false,accountMap);
        }
        if(updateOpportunityList.size() > 0){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update updateOpportunityList;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
        }
        GroupSubGroup_Service.setAccountGroupSubGroupUpdate((List<Opportunity>)Trigger.new);
    }


    private void checkConditionsFinishJob(Account accountRecord, Opportunity eachOpportunity){
        System.debug(Account_Service.isBulk);
        System.debug(currentUser.Profile.Name);
        System.debug(eachOpportunity);
        if(eachOpportunity.StageName == GlobalConstants.FINISHED){
           if(currentUser.id == eachOpportunity.OwnerId || currentUser.Profile.Name == GlobalConstants.SYSTEM_ADMIN || currentUser.Profile.Name == GlobalConstants.PROFILE_SOLAR || currentUser.Profile.Name == GlobalConstants.INTEGRATION_USER || (Account_Service.isBulk && currentUser.Profile.Name == GlobalConstants.RBS_ADMIN) || (Account_Service.isBulk && GlobalConstants.PROFILE_AF_HEAD_SET.contains(currentUser.Profile.Name)) || (Account_Service.isBulk && currentUser.Profile.Name == GlobalConstants.PROFILE_ITID)){
                List<Event> events = eventByOppIdMap.get(eachOpportunity.Id);
                if(events != null){
                    for(Event event : events){
                        if(!eventStatusCloseSet.contains(event.Status__c)){
                            eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_CALLPLAN);
                            return;
                        }
                    }
                }      

                List<OpportunityLineItem> oppLineItems =  opportunityLineItemByOppIdMap.get(eachOpportunity.Id);
                if(oppLineItems != null){
                    for(OpportunityLineItem oppItem : oppLineItems){
                        String statusClose = String.isNotBlank(oppItem.Status__c) ? oppItem.Status__c : oppItem.Status_CBS__c;
                        if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)){
                            if(GlobalConstants.OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB_RBS.contains(statusClose)){
                                eachOpportunity.addError(ExceptionMessage.CANNOT_CLOSEJOB_OPPPRODUCT);
                                return;
                            }      
                        }else if(GlobalConstants.OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB.contains(statusClose)){
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
        Boolean addAccount;
        Boolean isNotBypassAccountTrigger;
        accountUpdateList = new Map<Id,Account>();
        Map<String,List<Opportunity>> checkMultiJobWithSameOwner = new Map<String,List<Opportunity>>();

        Set<Id> oppLineItemSet = new Set<Id>();
        Set<Id> oppOwnerSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for (Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)) {
            oppLineItemSet.add(eachOpportunity.id);
            oppOwnerSet.add(eachOpportunity.OwnerId);
            accountIdSet.add(eachOpportunity.AccountId);
        }
        checkMultiJobWithSameOwner = queryMapWithAllOwnerJob(accountIdSet,oppOwnerSet,(List<Opportunity>) Trigger.new);

        eventByOppIdMap = new Map<Id,List<Event>>();
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> opportItemList = new List<OpportunityLineItem>();
        List<Application_History__c> appHistoryList = new List<Application_History__c>();
        if(!oppLineItemSet.isEmpty()) {
            eventList = [SELECT Id, Job__c , Status__c FROM event WHERE job__c IN :oppLineItemSet];
            opportItemList = [SELECT id, OpportunityId, Statusformula__c, Status__c, Status_CBS__c, CreatedBy.Profile.Name, CreatedById FROM OpportunityLineItem WHERE OpportunityId IN :oppLineItemSet];
            appHistoryList = [SELECT id, OppName__c, App_Result__c FROM Application_History__c WHERE OppName__c IN :oppLineItemSet];
        }
        
        for(Event eachOpp : eventList){
            if(eventByOppIdMap.get(eachOpp.job__c) != null){
                eventByOppIdMap.get(eachOpp.job__c).add(eachOpp);
            }else{
                eventByOppIdMap.put(eachOpp.job__c, new List<Event>{eachOpp});
            }          
        }
        
        opportunityLineItemByOppIdMap = new Map<Id,List<OpportunityLineItem>>();
        
        for(OpportunityLineItem eachOpp : opportItemList){
            if(opportunityLineItemByOppIdMap.get(eachOpp.OpportunityId) != null){
                opportunityLineItemByOppIdMap.get(eachOpp.OpportunityId).add(eachOpp);
            }else{
                opportunityLineItemByOppIdMap.put(eachOpp.OpportunityId, new List<OpportunityLineItem>{eachOpp});
            }          
        }

        appHistoryByOppIdMap = new Map<Id,List<Application_History__c>>();
        
        for(Application_History__c eachOpp : appHistoryList){
            if(appHistoryByOppIdMap.get(eachOpp.OppName__c) != null){
                appHistoryByOppIdMap.get(eachOpp.OppName__c).add(eachOpp);
            }else{
                appHistoryByOppIdMap.put(eachOpp.OppName__c, new List<Application_History__c>{eachOpp});
            }          
        }

        for(Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)){
            isNotBypassAccountTrigger = false;
            Opportunity oldRecord = (Opportunity)Trigger.oldMap.get(eachOpportunity.Id);
            
            addAccount = false;
            Account accountRecord = accountMap.get(eachOpportunity.AccountId);
            User oppOwner = userMap.get(eachOpportunity.OwnerId);
            if(accountRecord != null) {
                if(oldRecord.StageName != GlobalConstants.FINISHED && eachOpportunity.StageName == GlobalConstants.FINISHED){
                    // Add more check about many job to open under temporary
                    if(oldRecord.StageName != GlobalConstants.REOPEN){
                        checkConditionsFinishJob(accountRecord, eachOpportunity);
                    }
                    if(GlobalConstants.PROFILE_SME_SET.contains(oppOwner.Profile.Name) && checkMultiJobWithSameOwner.get(accountRecord.Id+' '+eachOpportunity.OwnerId) == null){
                        accountRecord.SME_Temporary_Customer__c = null;
                    }else if(GlobalConstants.PROFILE_AF_SET.contains(oppOwner.Profile.Name) && checkMultiJobWithSameOwner.get(accountRecord.Id+' '+eachOpportunity.OwnerId) == null){
                        accountRecord.AF_Temporary_Customer__c = null;
                    }
                    accountUpdateList.put(accountRecord.Id,accountRecord);
                }             
            }
        }

        if(!businessCodeTextMapOppId.isEmpty()){
            Customer_BusinessCode_Service.upsertCustomerBusinessCodeFromOpportunity((List<Opportunity>)Trigger.new,(Map<Id,Opportunity>)Trigger.oldMap,businessCodeTextMapOppId,isCurrentUser_UW,accountMap);
        }
        if(accountUpdateList != null && !accountUpdateList.values().isEmpty()){
            TriggerHandler.bypass('AccountTriggerHandler');
            update accountUpdateList.values();
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }

    public override void afterFinally(){
        if(mapChangeStatusTglById.values().size() > 0){
            TriggerHandler.bypass('TargetListTriggerHandler');
            update mapChangeStatusTglById.values();
            TriggerHandler.clearbypass('TargetListTriggerHandler');
        }

        if(accountUpdateList != null && !accountUpdateList.values().isEmpty()){
            TriggerHandler.bypass('AccountTriggerHandler');
            update accountUpdateList.values();
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }

        Opportunity_Service.stampLastCallOpptyToAccount((List<Opportunity>)Trigger.new,accountMap,currentUser);
    }

    private Map<String,List<Opportunity>> queryMapWithAllOwnerJob(Set<Id> accountIdSet,Set<Id> oppOwnerSet,List<Opportunity> listUpdateOpportunity){
        Map<String,List<Opportunity>> possibleOpportunityMap  = new Map<String,List<Opportunity>>();
        List<Opportunity> possibleOpportunity = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id NOT IN :listUpdateOpportunity AND AccountId IN :accountIdSet AND OwnerId IN:oppOwnerSet AND StageName IN('On Process','Open','Plan')];
        
        for(Opportunity eachOpp : possibleOpportunity){
            if(possibleOpportunityMap.containsKey(eachOpp.AccountId+' '+eachOpp.OwnerId)){
                possibleOpportunityMap.get(eachOpp.AccountId+' '+eachOpp.OwnerId).add(eachOpp);
            }else{
                List<Opportunity> tempOpp = new List<Opportunity>();
                tempOpp.add(eachOpp);
                possibleOpportunityMap.put(eachOpp.AccountId+' '+eachOpp.OwnerId, tempOpp);
            }
        }
        return possibleOpportunityMap;
    }

    private void stampTemporary(String segment, Account account){
        if(segment == 'SME'){
            account.SME_Temporary_Customer__c = userExtension.Id;
        }else if(segment == 'AF'){
            account.AF_Temporary_Customer__c = userExtension.Id;
        }
        accountUpdateList.put(account.Id,account);    
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
        }else if((segment == 'SME' && account.SME_Temporary_Customer__c == null)){
            return true;
        }else if((segment == 'AF' && account.AF_Temporary_Customer__c == null)){
            return true;
        }
        
        dataOpportunity.addError(Label.CantCreateJobAlreadyTakeTemp);
        return false;
    }

    private Boolean isSamePoolVisibility(Account account){
        Map<String,String> currentUserAHGroup = getGroupIndicate(currentUser.AH_RC_Code__c);
        Map<String,String> currentUserNHGroup = getGroupIndicate(currentUser.NH_RC_Code__c);
        Map<String,String> accountUserAHGroup = getGroupIndicate(account.Owner.AH_RC_Code__c);
        Map<String,String> accountUserNHGroup = getGroupIndicate(account.Owner.NH_RC_Code__c);

        for(String currentUserAHGroupVal : currentUserAHGroup.values()){
            if(accountUserAHGroup.containsKey(currentUserAHGroupVal) || accountUserNHGroup.containsKey(currentUserAHGroupVal)){
                return true;
            }
        }
        for(String currentUserNHGroupVal : currentUserNHGroup.values()){
            if(accountUserAHGroup.containsKey(currentUserNHGroupVal) || accountUserNHGroup.containsKey(currentUserNHGroupVal)){
                return true;
            }
        } 
        return false;
    }

    private Map<String,String> getGroupIndicate(String code){
        Map<String,String> poolVisibilityGroupMap = new Map<String,String>();
        for(Pool_Visibility__c pool : poolList){
            if(pool.Name == 'RC'+code){
                poolVisibilityGroupMap.put(pool.Group_Indicate__c, pool.Group_Indicate__c);
            }               
        }
        return poolVisibilityGroupMap;
    }

    private void checkJobPermission(Opportunity dataOpportunity){
        Boolean canNewJob = true;
        if(accountMap.containsKey(dataOpportunity.AccountId)){
            Account accountRecord = accountMap.get(dataOpportunity.AccountId);
            if(GlobalConstants.PROFILE_KBANK_ADMIN_SET.contains(currentUser.Profile.Name)){
                return;
            }else if(GlobalConstants.PROFILE_RBS_SET.contains(currentUser.Profile.Name) && !GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                return;
            }else if(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)){
                if(GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name) || GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Dual_RM_Name__r.Profile.Name)){
                    if(accountRecord.AF_Port_Pool_Formula__c == GlobalConstants.PORT 
                        && accountRecord.OwnerId != currentUser.Id && accountRecord.Owner.ManagerId != currentUser.Id && accountRecord.Owner.Manager.ManagerId != currentUser.Id 
                        && accountRecord.Dual_RM_Name__c != currentUser.Id && accountRecord.Dual_RM_Name__r.ManagerId != currentUser.Id && accountRecord.Dual_RM_Name__r.Manager.ManagerId != currentUser.Id){
                        canNewJob = false;
                    }else if(!isCanCreateByCheckTemporaryCustomer('AF', accountRecord, dataOpportunity)){
                        return;
                    }else if(accountRecord.AF_Port_Pool_Formula__c == GlobalConstants.POOL){
                        if(isCanCreateByCheckTemporaryCustomer('AF', accountRecord, dataOpportunity)){
                            stampTemporary('AF', accountRecord);
                        }
                        return;
                    }else {
                        return;
                    }
                }else if(!GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)
                    && !GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                    if(accountRecord.Port_Pool__c == GlobalConstants.PORT){
                        if(checkAccountTeam(accountRecord.Id)){
                            return;
                        }else{
                            stampTemporary('AF', accountRecord);
                            return;
                        }
                    }else if(isCanCreateByCheckTemporaryCustomer('AF', accountRecord, dataOpportunity)){
                        stampTemporary('AF', accountRecord);
                        return;
                    }
                }
            }else if(GlobalConstants.PROFILE_SME_SET.contains(currentUser.Profile.Name) && isCanCreateByCheckTemporaryCustomer('SME', accountRecord, dataOpportunity) && !GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                if(checkAccountTeam(accountRecord.Id)){
                    if(accountRecord.Port_Pool__c == GlobalConstants.PORT && accountRecord.OwnerId != currentUser.Id && Account_Service.isConvertLead){
                        canNewJob = false;
                    }else{
                        return;
                    }
                }else if(GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c) || GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                    stampTemporary('SME', accountRecord);
                    return;
                }else if(accountRecord.Port_Pool__c == GlobalConstants.PORT){
                    if(accountRecord.OwnerId != currentUser.Id){
                        canNewJob = false;
                    }else{
                        return;
                    }
                }else if(GlobalConstants.OT_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c) || isCanCreateByCheckTemporaryCustomer('SME', accountRecord, dataOpportunity)){
                    stampTemporary('SME', accountRecord);
                    return;
                }else{
                    if(accountRecord.Port_Pool__c == null || accountRecord.Port_Pool__c == GlobalConstants.POOL){
                        stampTemporary('SME', accountRecord);
                        return;
                    }else if(!isSamePoolVisibility(accountRecord)){
                        canNewJob = false;
                    }else{
                        stampTemporary('SME', accountRecord);
                        return;
                    }
                }
            }else if(GlobalConstants.PROFILE_CBS_SET.contains(currentUser.Profile.Name)){
                if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                    if(accountRecord.Port_Pool__c == GlobalConstants.PORT){
                        canNewJob = false;
                    }else{
                        return;
                    }
                }else if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountRecord.Primary_Segment_Code__c)){
                    if(accountRecord.OwnerId != currentUser.Id){
                        canNewJob = false;
                    }else{
                        return;
                    }
                }else{
                    return;
                }
            }
            canNewJob = false;

            if(!canNewJob){
                dataOpportunity.addError(Label.CantCreateJobNotOwner);
            }
        }
    }
    
    private Boolean checkAccountTeam(Id accountId){
        Boolean isHaveAccountTeam = false;
        if(accountTeamMembersByIdMap.get(accountId) != null){
            isHaveAccountTeam = true;
        }
        return isHaveAccountTeam;
    }
}