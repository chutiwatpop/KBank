/**
* @07/02/2017 Remove unused variable
* @30/11/2017 INC000000850055 ownerchange not stamp fields
*/
global without sharing class Account_Service {

    global static Boolean isBulk = false;
    global static Boolean isPage = false;
    global static Boolean isHRIS = false;
    global static Boolean isConvertLead = false;
    global static Boolean isRequest = false;
    global static Boolean isRelease = false;
    global static Boolean isAdminChange = false;
    global static Boolean isApplication = false;

    global static Boolean isAFDual = false;
    global static Boolean isAFTemp = false;
    global static Boolean isReleaseAFTemp = false;
    global static Boolean isReleaseSMETemp = false;

    public static Map<Id,Account> accountTriggerMap;
    public static Map<Id,Account> allUserAccountMap;
    public static Map<Id,Account> allAccountMapWithId;
    public static Boolean updateContactPrefOnce = false;
    public static Boolean triggerInitialCall = false;
    public static Boolean callingFromYearEndBatch = false;
    public static Boolean isTMPool = false;
    public static Boolean isChangeOwnership = false;
    public static Boolean forceUnloadRelatedObject = false;
    public static Boolean forceOwnerShipText = false;
    public static Boolean callingFromCalculateBatch =false;
    public static Boolean callingFromAccountTrigger =false;
    public static List<Opportunity> opportunityTriggerList;
    public static List<Pool_Visibility__c> poolVisibilityList;
    public static List<sObject> updateGlobalList;
    public static Boolean byPassValidateOpportunityProduct = false;

    public static void resetAllFlagOwnership(){
        Account_Service.isBulk = false;
        Account_Service.isPage = false;
        Account_Service.isHRIS = false;
        Account_Service.isRequest = false;
        Account_Service.isRelease = false;
        Account_Service.isAdminChange = false;
        Account_Service.isApplication = false;
        Account_Service.isConvertLead = false;
    }
    /*
    Service Change Owner Account
    */

    global class Response{
        @Auraenabled
        webservice String colorCode{get;set;}
        @Auraenabled
        webservice Boolean success{get;set;}
        @Auraenabled
        webservice String msg{get;set;}
    }

    /*
    Service Get Account
    */

    public static Map<Id,Account> getAllAccount(){
        if(Account_Service.allUserAccountMap == null){
            allUserAccountMap = new Map<Id,Account>([SELECT Id,Port_Pool__c,Ownership_Text__c FROM Account]);
        }
        return Account_Service.allUserAccountMap;
    }

    public static Map<Id,Account> getAllAccountWithId(Set<Id> accountIdSet){
        allAccountMapWithId = new Map<Id,Account>([SELECT Id,SME_Temporary_Customer__c,Is_SME_Customer__c,Is_CBS_Customer__c,Is_RBS__c,Port_Pool__c,Ownership_Text__c,RecordType.DeveloperName,RBS_Branch_Closeness__c,RBS_Branch_Closeness__r.OwnerId, RBS_Branch_Closeness__r.RC_Code__c, RBS_Previous_Branch_Closeness__c, RBS_Previous_Branch_Closeness__r.OwnerId, RBS_Previous_Branch_Closeness__r.RC_Code__c, RecordType.Name,Owner.Profile.Name,Customer_Owner_Release_Flag__c,Previous_Owner__c,Previous_Owner__r.Profile.Name,Primary_Segment_Code__c,Previous_Owner__r.Email,Customer_Owner_Changed_Date__c,OwnerId,RC_Code__c,Permanent_Owner_Extension__c,Customer_s_Business_Code__c,Trash_Pool_Flag__c,Owner.Segment__c,Owner.SME_User__c,Owner.RBS_User__c,Owner.CBS_User__c FROM Account WHERE Id IN :accountIdSet]);
        return Account_Service.allAccountMapWithId;
    }

    public static List<Pool_Visibility__c> getAllPoolVisibility(){
        if(Account_Service.poolVisibilityList == null){
            poolVisibilityList =[SELECT Group_Indicate__c,Name FROM Pool_Visibility__c];
        }
        return Account_Service.poolVisibilityList;
    }

    public static Boolean isSamePoolVisibility(Account account, User currentUser){
        Set<String> currentUserAHGroup = getGroupIndicate(currentUser.AH_RC_Code__c);
        Set<String> currentUserNHGroup = getGroupIndicate(currentUser.NH_RC_Code__c);
        Set<String> accountUserAHGroup = getGroupIndicate(account.Owner.AH_RC_Code__c);
        Set<String> accountUserNHGroup = getGroupIndicate(account.Owner.NH_RC_Code__c);

        //if(!currentUserAHGroup.isEmpty() && !accountUserAHGroup.isEmpty()){
            for(String currentUserAHGroupVal : currentUserAHGroup){
                if(accountUserAHGroup.contains(currentUserAHGroupVal)){

                    return true;
                }
            } 
        //}else if(!currentUserNHGroup.isEmpty() && !accountUserNHGroup.isEmpty()){
            for(String currentUserNHGroupVal : currentUserNHGroup){
                if(accountUserNHGroup.contains(currentUserNHGroupVal)){

                    return true;
                }
            } 
        //}
        return false;
    }

    public static Set<String> getGroupIndicate(String code){
        Set<String> poolVisibilitySet = new Set<String>();
        for(Pool_Visibility__c pool : getAllPoolVisibility()){
            if(pool.Name == 'RC'+code){
                poolVisibilitySet.add(pool.Group_Indicate__c);
            }               
        }
        return poolVisibilitySet;
    }

    /*
    CBS Service Get Account
    */

    public static List<Account> getAccountByID(Id accountId){
        String getAccountQuery = 'SELECT Id,Name,CIS__c,Customer_s_Business_Code__c, RecordType.DeveloperName, Encrypt_Fullname_TH__c, Encrypt_Fullname_EN__c, Name_Surname_TH__c, Wallet_Size_Limit__c, Wallet_Size_Outstanding__c, Wallet_Size_Exposure__c, SOW_Limit__c, SOW_Outstanding__c, SOW_Exposure__c, OwnerID  FROM Account WHERE Id =: accountId';
        List<Account> accounts = Database.query(getAccountQuery);
        return accounts;
    }

    public static Account getAccountInformation(String accountId){
        String query = 'SELECT id,RBS_Branch_Closeness__c,RBS_Branch_Closeness__r.OwnerId, RBS_Branch_Closeness__r.RC_Code__c, RBS_Previous_Branch_Closeness__c, RBS_Previous_Branch_Closeness__r.OwnerId, RBS_Previous_Branch_Closeness__r.RC_Code__c, RecordType.Name,Temporary_Ownership_Flag__c,SME_Temporary_Customer__c,RecordType.DeveloperName,Encrypt_Identification_No__c,Birthdate_Registration_Date__c,Owner.SME_User__c,Port_Pool__c,Is_RBS__c,Is_SME_Customer__c,Owner.CBS_User__c,Is_CBS_Customer__c,Owner.Profile.Name,Owner.RBS_User__c,CIS__c,Exit__c,OwnerId,Primary_Segment_Code__c,Allow_Request_Ownership__c FROM Account';
        String condition = ' WHERE id = :accountId Limit 1';
        List<Account> accounts = Database.query(query + condition);
        if(accounts.isEmpty()){
            return new Account(id = accountId);
        }else{
            return accounts[0];
        }
    }

    // CR Fraud
    public static String calculateFraud(String exitField, String fraudStatus) {
        String OTHER = 'Other', flagChar = OTHER;
        if(exitField == 'Y') {
            flagChar = GlobalConstants.FRAUD_COLOR_BROWN;
        } else if(exitField == 'N' || exitField == null || exitField == '') {
            if(fraudStatus == 'D') {
                flagChar = GlobalConstants.FRAUD_COLOR_BROWN;
            } else if(fraudStatus == 'G') {
                flagChar = GlobalConstants.FRAUD_COLOR_PINK;
            } else if(fraudStatus == 'N') {
                flagChar = GlobalConstants.FRAUD_COLOR_BLUE;
            } else if(fraudStatus == null || fraudStatus == 'null' || fraudStatus == '') {
                flagChar = GlobalConstants.FRAUD_COLOR_BLUE;
            } else {
                flagChar = OTHER;
            }
        } else {
            if(fraudStatus == 'D') {
                flagChar = GlobalConstants.FRAUD_COLOR_BROWN;
            } else if(fraudStatus == 'G') {
                flagChar = GlobalConstants.FRAUD_COLOR_BROWN;
            } else {
                flagChar = OTHER;
            }
        }
        return flagChar;
    }

    webservice static Response getFraudStatus(String accountString){
        Account accountObj = (Account) JSON.deserialize(accountString,Account.class);
        return getFraudStatus(accountObj);
    }

    public static Response getFraudStatus(Account accountObj) {
        Response res = new Response();
        try{
            String fraudStatus = calloutWebservice(accountObj);
            res.success = true;
            res.colorCode = Account_Service.calculateFraud(accountObj.Exit__c, fraudStatus);
        }catch(CIWebserviceException e){
            res.success = false;
            res.msg = GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage());
        }catch(Exception e){
            res.success = false;
            res.msg = e.getMessage();
        }
        return res;
    }

    static String calloutWebservice(Account accountObj) {
        String fraudStatus = '';
        GetFraud_Webservice webserviceInstance = GetFraud_Webservice.getInstance();
        webserviceInstance.cisId = accountObj.CIS__c;
        GetFraud_Webservice.ResponseModel responseModel = webserviceInstance.calloutWebservice();
        // Handle Response
        List<GetFraud_Webservice.CustomerFraud> respCustomers = responseModel.customerModel;
        if(respCustomers != null && respCustomers.size() > 0 && respCustomers[0].IP_ID == accountObj.CIS__c) {
            fraudStatus = responseModel.customerModel[0].BLIST_TP_CD;
        } else {
            throw new CIWebserviceException('Customer fraud status cannot found');
        }
        return fraudStatus;
    }

    @future 
    public static void updateAccountFuture(String accountListstr){
        List<Account> accountList = (List<Account>) JSON.deserialize(accountListstr, List<Account>.class);
        DB_Service.updateSObjectWithBypass(accountList,false);
    }

    public static Integer countQuery(String queryString) {
        return Database.countQuery(queryString);
    }

    /*
    * Check user segment(profile name) is same primary segment of account
    */
    public static Boolean isSameSegment(Account currentAccount, User currentUser) {
        String primarySegment = currentAccount.Primary_Segment_Code__c;
        String profileName = currentUser.Profile.Name;
        if(currentAccount.Is_CBS_Customer__c) {
            if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) { return true; } else { return false; }
        } else if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(primarySegment)) {
            if(GlobalConstants.PROFILE_SME_SET.contains(profileName) || GlobalConstants.PROFILE_AN_SET.contains(profileName)) { return true; } else { return false; }
        } else if(currentAccount.is_RBS__c) {
            if(GlobalConstants.PROFILE_RBS_SET.contains(profileName)) { return true; } else { return false; }
        } else if(currentAccount.Is_AF_Customer__c) {
            if(GlobalConstants.PROFILE_AF_SET.contains(profileName)) { return true; } else { return false; }
        } else {
            return false;
        }
    }

    /*
    * Check user is owner of account with manager
    */
    public static Boolean isOwnerWithManager(Account currentAccount) {
        if(currentAccount.OwnerId == UserInfo.getUserId() || (!String.isBlank(currentAccount.Owner.ManagerId) && currentAccount.Owner.ManagerId == UserInfo.getUserId()) || (!String.isBlank(currentAccount.Owner.Manager.ManagerId) && currentAccount.Owner.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(currentAccount.Owner.Manager.Manager.ManagerId) && currentAccount.Owner.Manager.Manager.ManagerId == UserInfo.getUserId())) {
            return true;
        }
        return false;
    }

    /*
    * Check user is dual rm of account with manager
    */
    public static Boolean isDualOwnerWithManager(Account currentAccount) {
        if(currentAccount.Dual_RM_Name__c == UserInfo.getUserId() || (!String.isBlank(currentAccount.Dual_RM_Name__r.ManagerId) && currentAccount.Dual_RM_Name__r.ManagerId == UserInfo.getUserId()) || (!String.isBlank(currentAccount.Dual_RM_Name__r.Manager.ManagerId) && currentAccount.Dual_RM_Name__r.Manager.ManagerId == UserInfo.getUserId()) || (!String.isBlank(currentAccount.Dual_RM_Name__r.Manager.Manager.ManagerId) && currentAccount.Dual_RM_Name__r.Manager.Manager.ManagerId == UserInfo.getUserId())) {
            return true;
        }
        return false;
    }

    public static Id createNewAccountTeam(Id accountId, Id userId,String accountAccessLevel,String opportunityAccessLevel,String caseAccessLevel,String contactAccessLevel){
        List<Id> result = createNewAccountTeam(new List<Id>{accountId}, userId,accountAccessLevel,opportunityAccessLevel,caseAccessLevel,contactAccessLevel);
        if(!result.isEmpty()){
            return result[0];
        }
        return null;
    }

    public static List<Id> createNewAccountTeam(List<Id> accountId, Id userId,String accountAccessLevel,String opportunityAccessLevel,String caseAccessLevel,String contactAccessLevel){
        List<Id> listTempAccountTeamId = new List<Id>();
        List<AccountTeamMember> autoCreateNewAccountTeamList = new List<AccountTeamMember>();
        for(Id eachAccId : accountId){
            autoCreateNewAccountTeamList.add(new AccountTeamMember(
                                            AccountId = eachAccId,
                                            UserId = UserInfo.getUserId(),
                                            AccountAccessLevel = accountAccessLevel,
                                            OpportunityAccessLevel = opportunityAccessLevel,
                                            CaseAccessLevel = caseAccessLevel,
                                            ContactAccessLevel = contactAccessLevel));
        }
        Database.SaveResult[] results = Database.insert(autoCreateNewAccountTeamList);
        for (Database.SaveResult eachResult : results) {
            if (eachResult.isSuccess()) {
                listTempAccountTeamId.add(eachResult.getId());
            }
        }
        return listTempAccountTeamId;
    }
}