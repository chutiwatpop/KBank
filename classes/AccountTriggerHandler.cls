/**
* @author Charnun.t@beryl8.com
*/
public class AccountTriggerHandler extends TriggerHandler{
    AccountChangeOwner accountService = new AccountChangeOwner();
    public static Map<Id, User> allUserMap;
    public static Map<String,Profile> profileMapByName;
    public static User_Admin__c userAdmin;

    User currentUser;
    String profileName;
    Map<Id,String> prospectRecordTypeId;
    Map<Id,User_Extension__c> userExtensionMapWithId;
    Map<Id,User_Extension__c> userExtensionMapWithUserId;
    private static Set<Id> userIdSet = new Set<Id>();

    public override void init(){
        if(allUserMap == null) allUserMap = User_Service.getAllUserMapWithId(userIdSet);
        if(profileMapByName == null) profileMapByName = GlobalUtility.getProfileMapNameKey();
        if(userAdmin == null) userAdmin = User_Admin__c.getOrgDefaults();

    }

    public override void allBefore(){
        Id profileId = UserInfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
        prospectRecordTypeId = accountService.getProspectRecordTypeId();
        userExtensionMapWithId = accountService.getUserExtensionMapWithId((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap);
        userExtensionMapWithUserId = accountService.getUserExtensionMapWithUserId((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap);
    }

    public override void beforeInsert() {
        userIdSet.add(UserInfo.getUserId());
        for(Account eachAccount : (List<Account>)Trigger.new){
            userIdSet.add(eachAccount.OwnerId);
            if(!accountService.isProspectAccount(eachAccount, prospectRecordTypeId)){
                eachAccount.Primary_Segment_Code__c = eachAccount.Customer_Segment_Code__c;
            }
            // Set new owner for integration customer - RBS, AF owner is salesforceintegration
            if(eachAccount.Is_createby_Integration__c && (userAdmin.Integration_User_ID__c != null && userAdmin.Integration_User_ID__c.contains(eachAccount.OwnerId))) {
                if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
                    eachAccount.OwnerId = userAdmin.SME_User_ID__c;
                } else if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
                    eachAccount.OwnerId = userAdmin.CBS_User_ID__c;
                } else if(GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c) || GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
                    eachAccount.OwnerId = userAdmin.RBS_User_ID__c;
                }
                userIdSet.add(eachAccount.OwnerId);
            }
        }
    }

    public override void beforeUpdate() {
        Account_Service.callingFromAccountTrigger = true;
        userIdSet.add(UserInfo.getUserId());
        for(Account eachAccount : (List<Account>)Trigger.new){
            userIdSet.add(eachAccount.OwnerId);
        }
        Map<String,Id> teamMapByRc = TeamStructure_Service.getAllTeamStructureMapByRCTeamId();
        IOwnerExecution ownerChangeExecute;
        if(GlobalConstants.PROFILE_RBS_ADMIN_SET.contains(profileName)){
            ownerChangeExecute = new RBSAdminChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }else if(GlobalConstants.PROFILE_SME_SET.contains(profileName)){
            ownerChangeExecute = new SMEChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }else if(GlobalConstants.PROFILE_RBS_SET.contains(profileName)){
            ownerChangeExecute = new RBSChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }else if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)){
            ownerChangeExecute = new CBSChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }else if(GlobalConstants.PROFILE_AF_SET.contains(profileName)){
            ownerChangeExecute = new AFChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }else{
            ownerChangeExecute = new AdminChangeOwner((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap, currentUser);
        }

        ownerChangeExecute.executeChangeOwner((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap, currentUser, userExtensionMapWithUserId, teamMapByRc);
        ownerChangeExecute.executeChangeJob((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);
        ownerChangeExecute.executeChangeEvent((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap, userExtensionMapWithUserId, userExtensionMapWithId, teamMapByRc);

        updatePrimarySegment((List<Account>)Trigger.new);
        updateLastCallOppty((List<Account>)Trigger.new);
        updateLeadDoNotContact((List<Account>)Trigger.new);
        GroupSubGroup_Service.updateCustomerGroupSubGroup((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap);
    }

    public override void afterInsert(){
        GroupSubGroup_Service.insertCustomerGroupSubgroup((List<Account>)Trigger.new);
    }

    public override void afterfinally(){
        AccountTeamMemberWrapper accountTeamWrapper = new AccountTeamMemberWrapper(userAdmin);
        accountTeamWrapper.calculateAccountTeamMember((List<Account>)Trigger.new, (Map<Id, Account>) Trigger.oldMap);
        accountTeamWrapper.executeAccountTeamMember();
    }

    public override void afterUpdate(){
        updateContactLookupAccount((List<Account>)Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }

    private void updatePrimarySegment(List<Account> accountList) {
        for(Account eachAccount : accountList){
            Account oldAccount = (Account)Trigger.oldMap.get(eachAccount.Id);
            if(eachAccount.Customer_Segment_Code__c != oldAccount.Customer_Segment_Code__c && eachAccount.Primary_Segment_Code__c == null) {
                eachAccount.Primary_Segment_Code__c = eachAccount.Customer_Segment_Code__c;
            }
        }
    }

    private void updateLastCallOppty(List<Account> accountList) {
        for(Account eachAccount : accountList){
            Account oldAccount = (Account)Trigger.oldMap.get(eachAccount.Id);
            if(isStampSmeTempValue(oldAccount,eachAccount) || isChangeSmeTempValue(oldAccount,eachAccount)) {
                eachAccount.Last_CallReprt_Opty_Updated_Date__c = System.now();
            }

            if(isStampAFTempValue(oldAccount,eachAccount) || isChangeAFTempValue(oldAccount,eachAccount)) {
                eachAccount.AF_Last_CallReprt_Opty_Updated_Date__c = System.now();
            }
        }
    }

    private Boolean isStampAFTempValue(Account oldAccount ,Account newAccount){
        if(oldAccount.AF_Temporary_Customer__c == null && newAccount.AF_Temporary_Customer__c != null){
            return true;
        }
        return false;
    }

    private Boolean isChangeAFTempValue(Account oldAccount ,Account newAccount){
        if(oldAccount.AF_Temporary_Customer__c != null && newAccount.AF_Temporary_Customer__c != null && (oldAccount.AF_Temporary_Customer__c != newAccount.AF_Temporary_Customer__c)){
            return true;
        }
        return false;
    }

    private Boolean isStampSmeTempValue(Account oldAccount ,Account newAccount){
        if(oldAccount.SME_Temporary_Customer__c == null && newAccount.SME_Temporary_Customer__c != null){
            return true;
        }
        return false;
    }

    private Boolean isChangeSmeTempValue(Account oldAccount ,Account newAccount){
        if(oldAccount.SME_Temporary_Customer__c != null && newAccount.SME_Temporary_Customer__c != null && (oldAccount.SME_Temporary_Customer__c != newAccount.SME_Temporary_Customer__c)){
            return true;
        }
        return false;
    }

    public void updateContactLookupAccount(List<Account> accountList, Map<Id, Account> oldAccountMapById){
        
        Set<Id> newOrgCustIdSet = new Set<Id>();
        Set<Id> newIndiCustIdSet = new Set<Id>();
        for(Account newAccount : accountList){
            Account oldAccount = oldAccountMapById.get(newAccount.Id);
            if(newAccount.Customer_Type_Code__c == 'O' && oldAccount.Customer_Type_Code__c == null && newAccount.PersonContactId != null) {
                newOrgCustIdSet.add(newAccount.Id);
            }else if(newAccount.Customer_Type_Code__c == 'I' && oldAccount.Customer_Type_Code__c == null && newAccount.PersonContactId == null) {
                newIndiCustIdSet.add(newAccount.Id);
            }
        }

        List<Contact> contactList = new List<Contact>();
        List<Contact> orgContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE CIS__c IN :newOrgCustIdSet AND RecordTypeId != null];
        for(Contact eachContact : orgContactList) {
            eachContact.AccountId = eachContact.CIS__c;
            eachContact.CIS__c = null;
        }
        contactList.addAll(orgContactList);
        List<Contact> indiContactList = [SELECT Id, AccountId, CIS__c FROM Contact WHERE AccountId IN :newIndiCustIdSet AND RecordTypeId != null];
        for(Contact eachContact : indiContactList) {
            eachContact.CIS__c = eachContact.AccountId;
            eachContact.AccountId = null;
        }
        contactList.addAll(indiContactList);
        
        if(!contactList.isEmpty()) update contactList;
    }
    
    public void updateLeadDoNotContact(List<Account> accountList){
        for(Account eachAccount : accountList){
            if((eachAccount.Office_Phone__c != NULL && eachAccount.Office_Phone__c == GlobalConstants.DO_NOT_CONTACT_TEXT)
                || (eachAccount.Home_Phone__c != NULL && eachAccount.Home_Phone__c == GlobalConstants.DO_NOT_CONTACT_TEXT)
                || (eachAccount.Mobile__c != NULL && eachAccount.Mobile__c == GlobalConstants.DO_NOT_CONTACT_TEXT) ){
                eachAccount.HidePhoneFlag__c = true;
            }else{
                eachAccount.HidePhoneFlag__c = false;
            }
        }
    }
}