/**
 * @author: komsan.wi@beryl8.com.com
 * @komsan.wi: 24/07/2015 create new
 * @charnun.t: 24/01/2017 INC000000488038 Recall Request Ownership ไม่ได้: Change solution
 * @charnun.t: 30/01/2017 Re-factor code and clean debug log
 */
global without sharing class Ownership_Service {
    global static Boolean fromTrigger = false;
    global static List<Customer_Ownership_Request__Share> shareRecordToUpdate;
    global static Map<Id, User_Extension__c>  userExtensionMap;
    global static User_Admin__c mUserAdmin;
    global class Response{
        public Customer_Ownership_Request__c customerRequest;
        @Auraenabled
        webservice String recordId{get;set;}
        @Auraenabled
        webservice Boolean success{get;set;}
        @Auraenabled
        webservice String msg{get;set;}
    }

    global class OwnershipException extends Exception{}

    global static Customer_Ownership_Request__c releaseOwnership(Account accountObj, User userObj){
        Customer_Ownership_Request__c ownerObj;
        User_Admin__c userAdmin;

        if(Ownership_Service.fromTrigger){
            ownerObj = (Customer_Ownership_Request__c)Trigger.new.get(0);
        }else ownerObj = new Customer_Ownership_Request__c();

        Savepoint sp = Database.setSavepoint();
        try{
            User requestorUser = [SELECT Id,
            ManagerId,
            Manager.Profile.Name,
            Manager.ManagerId,
            Manager.Manager.Profile.Name,
            Manager.IsActive,
            Manager.Manager.ManagerId,
            Manager.Manager.IsActive,
            Manager.Manager.Email,
            Manager.Manager.Manager.Email,
            Manager.Manager.Manager.Profile.Name,
            Manager.Manager.Manager.IsActive,
            Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE IsActive = true AND Id=:accountObj.OwnerId];
            
            String tmRequestor;
            String ahRequestor;
            String nhRequestor;
            String requestorManager;

            ownerObj.Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP;
            if(requestorUser !=null){
                if(requestorUser.Profile.Name == GlobalConstants.SME_TM || requestorUser.Profile.Name == GlobalConstants.CBS_TM) {
                    tmRequestor = requestorUser.Id;
                } else if(requestorUser.Profile.Name == GlobalConstants.SME_AH || requestorUser.Profile.Name == GlobalConstants.OT_AH_SALES || requestorUser.Profile.Name == GlobalConstants.CBS_TL) {
                    ahRequestor = requestorUser.Id;
                } else if(requestorUser.Profile.Name == GlobalConstants.SME_NH || requestorUser.Profile.Name == GlobalConstants.OT_NH_SALES) {
                    nhRequestor = requestorUser.Id;
                }
                // Edit for STL (CBS-Ongoing)
                if(requestorUser.Manager!=null && requestorUser.Manager.IsActive) {
                    if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_TM || requestorUser.Manager.Profile.Name == GlobalConstants.CBS_TM) {
                        tmRequestor = requestorUser.ManagerId;
                    } else if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_AH || requestorUser.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (requestorUser.Manager.Profile.Name == GlobalConstants.CBS_TL && requestorUser.Profile.Name != GlobalConstants.CBS_TL)) {
                        ahRequestor = requestorUser.ManagerId;
                    } else if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_NH || requestorUser.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || (requestorUser.Manager.Profile.Name == GlobalConstants.CBS_TL && requestorUser.Profile.Name == GlobalConstants.CBS_TL)) {
                        nhRequestor = requestorUser.ManagerId;
                    }
                }
                // Edit for STL (CBS-Ongoing)
                if(requestorUser.Manager.Manager!=null && requestorUser.Manager.Manager.IsActive) {
                    if(requestorUser.Manager.Manager.Profile.Name == GlobalConstants.SME_AH || requestorUser.Manager.Manager.Profile.Name == GlobalConstants.OT_AH_SALES ||(requestorUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL && requestorUser.Manager.Profile.Name != GlobalConstants.CBS_TL)) {
                        ahRequestor = requestorUser.Manager.ManagerId;
                    } else if(requestorUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || requestorUser.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || requestorUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                        nhRequestor = requestorUser.Manager.ManagerId;
                    }
                }
                // Edit for STL (CBS-Ongoing)
                if(requestorUser.Manager.Manager.Manager!=null && requestorUser.Manager.Manager.Manager.IsActive) {
                    if(requestorUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || requestorUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || requestorUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                        nhRequestor = requestorUser.Manager.Manager.ManagerId;
                    }
                }
                //Fix for industryData
                //List<Business_Code__c> businessCodelist = [SELECT ID FROM Business_Code__c WHERE Name =: accountObj.Customer_s_Business_Code__c LIMIT 1];
                List<Business_Code__c> businessCodelist = [SELECT ID FROM Business_Code__c WHERE Name =: accountObj.Customer_s_Business_Code__c AND Segment__c = :accountObj.Owner.Segment__c LIMIT 1];

                userAdmin = User_Admin__c.getOrgDefaults();
                ownerObj.CIS_ID__c = accountObj.Id;
                ownerObj.OwnerID = userObj.Id;
                ownerObj.Requestor_TM__c = tmRequestor;
                ownerObj.Requestor_AH__c = ahRequestor;
                ownerObj.Requestor_NH__c = nhRequestor;
                ownerObj.User_Admin__c = userAdmin.User_Record_ID__c;
                
                if(businessCodelist.size() >0){
                    ownerObj.Business_Code__c = businessCodelist.get(0).ID;
                }
                
                // Edit for NH-TL (CBS-Ongoing)
                String nhTLRcCode;
                Map<String,User_Mirror_Management__c> nhtlMirrorSettingMapByRcCode = CustomSettingUtil.getMirrorSettingMapByUserAndMirrorRcCode();
                if(ownerObj.Refer_Out_Reason__c == 'Wrong Area' || ownerObj.Refer_Out_Reason__c == 'Other Team' || ownerObj.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_SME || ownerObj.Refer_Out_Reason__c == GlobalConstants.REASON_NATIONALITY || ownerObj.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_CBS || ownerObj.Refer_Out_Reason__c == GlobalConstants.REASON_COMPANY_RELATED) {
                    List<User_Extension__c> userExtList = new List<User_Extension__c>();
                    if(ownerObj.Refer_Out_Team__c != null){
                        userExtList = [SELECT Id, User__c FROM User_Extension__c WHERE (User__r.Profile.Name=:GlobalConstants.SME_TM OR  User__r.Profile.Name=:GlobalConstants.CBS_TL ) AND Team_Structure__r.Name = :ownerObj.Refer_Out_Team__c AND Active__c = true];
                        // Edit for NH-TL (CBS-Ongoing) + In case of TM Inactive need to find AH
                        if(userExtList.size() == 0){
                            List<Team_Structure__c> teamStructureList = [SELECT id,RC_Code__c,Segment__c,AH_Name__c,AH_Name__r.RC_Code__c From Team_Structure__c WHERE Name = :ownerObj.Refer_Out_Team__c  LIMIT 1];
                            if(teamStructureList != null && teamStructureList.size() > 0){
            
                                if(teamStructureList.get(0).AH_Name__c != null){
                                    userExtList = [SELECT Id,User__c From User_Extension__c WHERE Team_Structure__r.id = :teamStructureList.get(0).AH_Name__c AND Active__c = true];
                                }
                                if(userExtList.size() == 0  ){
                                    if(nhtlMirrorSettingMapByRcCode.containsKey(teamStructureList.get(0).RC_Code__c)){
                                        nhTLRcCode = nhtlMirrorSettingMapByRcCode.get(teamStructureList.get(0).RC_Code__c).User_Value__c;
                                    }else if(nhTLRcCode == null && nhtlMirrorSettingMapByRcCode.containsKey(teamStructureList.get(0).AH_Name__r.RC_Code__c)){
                                         nhTLRcCode = nhtlMirrorSettingMapByRcCode.get(teamStructureList.get(0).AH_Name__r.RC_Code__c).Mirror_Value__c;
                                    }
                                    if(nhTLRcCode != null ){
                                         userExtList = [SELECT Id,User__c From User_Extension__c WHERE User__r.Profile.Name=:GlobalConstants.SME_NH AND Team_Structure__r.RC_Code__c = :nhTLRcCode];
                                    }

                                }
                            }   
                        }
                    }

                    User assignUser;
                    if(userExtList.size() > 0)
                        assignUser = [SELECT Id,IsActive,RC_Code__c,
                        ManagerId,
                        Manager.Profile.Name,
                        Manager.ManagerId,
                        Manager.Manager.Profile.Name,
                        Manager.IsActive,
                        Manager.Manager.ManagerId,
                        Manager.Manager.IsActive,
                        Manager.Manager.Email,
                        Manager.Manager.Manager.Email,
                        Manager.Manager.Manager.Profile.Name,
                        Manager.Manager.Manager.IsActive,
                        Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id=:userExtList.get(0).User__c];

                    String tmTarget;
                    String ahTarget;
                    String nhTarget;
                    String userTarget;
                    
                    if(assignUser != null) {
                        if(assignUser.IsActive && (assignUser.Profile.Name == GlobalConstants.SME_TM || assignUser.Profile.Name == GlobalConstants.CBS_TM)) {
                            tmTarget = assignUser.Id;
                        } else if(assignUser.Profile.Name == GlobalConstants.SME_AH || assignUser.Profile.Name == GlobalConstants.OT_AH_SALES ) {
                            ahTarget = assignUser.Id;
                        } else if(assignUser.Profile.Name == GlobalConstants.CBS_TL) {
                            if(!assignUser.IsActive){
                                List<User> cbsAdminList = [Select ID from User where Name='CBS Admin' Limit 1];
                                ahTarget = cbsAdminList.get(0).ID;
                            }else{
                                ahTarget = assignUser.Id;
                            }
                        } else if(assignUser.Profile.Name == GlobalConstants.SME_NH || assignUser.Profile.Name == GlobalConstants.OT_NH_SALES ) {
                            nhTarget = assignUser.Id;
                             //Add for STL (CBS-Ongoing)
                            if(nhtlMirrorSettingMapByRcCode.containsKey(assignUser.RC_Code__c)){
                                ownerObj.Is_Current_Owner_NHTL__c = true;
                            }
                        }
                        // Edit for STL (CBS-Ongoing)
                        if(assignUser.Manager!=null && assignUser.Manager.IsActive) {
                            if(assignUser.Manager.Profile.Name == GlobalConstants.SME_TM || assignUser.Manager.Profile.Name == GlobalConstants.CBS_TM) {
                                tmTarget = assignUser.ManagerId;
                            } else if(assignUser.Manager.Profile.Name == GlobalConstants.SME_AH || assignUser.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (assignUser.Manager.Profile.Name == GlobalConstants.CBS_TL && assignUser.Profile.Name != GlobalConstants.CBS_TL)) {
                                ahTarget = assignUser.ManagerId;
                            } else if(assignUser.Manager.Profile.Name == GlobalConstants.SME_NH || assignUser.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || (assignUser.Manager.Profile.Name == GlobalConstants.CBS_TL && assignUser.Profile.Name == GlobalConstants.CBS_TL)) {
                                nhTarget = assignUser.ManagerId;
                            }
                        }
                        // Edit for STL (CBS-Ongoing)
                        if(assignUser.Manager.Manager!=null && assignUser.Manager.Manager.IsActive) {
                            if(assignUser.Manager.Manager.Profile.Name == GlobalConstants.SME_AH || assignUser.Manager.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (assignUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL && assignUser.Manager.Profile.Name != GlobalConstants.CBS_TL)) {
                                ahTarget = assignUser.Manager.ManagerId;
                            } else if(assignUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || assignUser.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || assignUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                                nhTarget = assignUser.Manager.ManagerId;
                            }
                        }
                        // Edit for STL (CBS-Ongoing)
                        if(assignUser.Manager.Manager.Manager!=null && assignUser.Manager.Manager.Manager.IsActive) {
                            if(assignUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || assignUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || assignUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                                nhTarget = assignUser.Manager.Manager.ManagerId;
                            }
                        }

                        if(assignUser.Profile.Name != GlobalConstants.SME_RM && assignUser.IsActive)
                            userTarget = assignUser.Id;
                        else if(tmTarget!=null)
                            userTarget = tmTarget;
                        else if(ahTarget!=null)
                            userTarget = ahTarget;
                        else if(nhTarget!=null)
                            userTarget = nhTarget;
                    }
                    
                    ownerObj.Current_Owner__c = userTarget;
                    ownerObj.Current_Owner_TM__c = tmTarget;
                    ownerObj.Current_Owner_AH__c = ahTarget;
                    ownerObj.Current_Owner_NH__c = nhTarget;
                } else {
                    if(tmRequestor!=null) 
                        requestorManager = tmRequestor;
                    else if(ahRequestor!=null) 
                        requestorManager = ahRequestor;
                    else if(nhRequestor!=null) 
                        requestorManager = nhRequestor;
                    
                    ownerObj.Current_Owner_TM__c = tmRequestor;
                    ownerObj.Current_Owner_AH__c = ahRequestor;
                    ownerObj.Current_Owner_NH__c = nhRequestor;

                    if(ownerObj.Refer_Out_Reason__c == 'TM Pool') {
                        ownerObj.Current_Owner__c = requestorManager;
                    } else {
                        ownerObj.Current_Owner__c = accountObj.OwnerId;    
                    }
                }
            }

            if(!Ownership_Service.fromTrigger)
                insert ownerObj;

            if(tmRequestor!=null) 
                requestorManager = tmRequestor;
            else if(ahRequestor!=null) 
                requestorManager = ahRequestor;
            else if(nhRequestor!=null) 
                requestorManager = nhRequestor;

            if(!Ownership_Service.fromTrigger){
                List<Customer_Ownership_Request__Share> ownershipShareList = new List<Customer_Ownership_Request__Share>();
                Customer_Ownership_Request__Share ownerShareObj;

                if(ownerObj.Current_Owner__c != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.ParentId = ownerObj.Id;
                    ownerShareObj.UserOrGroupId = ownerObj.Current_Owner__c;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    ownershipShareList.add(ownerShareObj);
                }

                if(requestorManager != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.ParentId = ownerObj.Id;
                    ownerShareObj.UserOrGroupId = requestorManager;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    ownershipShareList.add(ownerShareObj);
                }

                insert ownershipShareList;
            }else {
                Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
                Customer_Ownership_Request__Share ownerShareObj;
                
                if(ownerObj.Current_Owner__c != null && ownerObj.Current_Owner__c != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.UserOrGroupId = ownerObj.Current_Owner__c;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                }

                if(requestorManager != null && requestorManager != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.UserOrGroupId = requestorManager;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                }
                // Add  for (CBS-Ongoing) share record for NH-TL
                if( ownerObj.Current_Owner_NH__c != null && ownerObj.Current_Owner_NH__c != ownerObj.OwnerID && ownerObj.Current_Owner_NH__c != requestorManager){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.UserOrGroupId = ownerObj.Current_Owner_NH__c;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                }

            }
        }catch(Exception ex){
            Database.rollback(sp);
            throw new Ownership_Service.OwnershipException(ex.getMessage());
        }
        return ownerObj;
    }

    global static List<Team_Structure__c> selectTeamReferOutSegment(String shareHolder,String language,String province,String businessCode,Decimal saleSize){

        List<Team_Structure__c> selectTeamList;
        List<String> teamRCcodeList = new List<String>();

        if(saleSize == null){
            saleSize = 0;
        }

        try{
            //Step 1 Check Sharholder & Language
            Integer countShareHolderLang = [SELECT count() FROM Team_Mapping_Refer_Out_Condition_1__c WHERE Shareholder__c =: shareHolder AND Language__c =: language AND Min_Sale_Size__c <=: saleSize AND Max_Sale_Size__c >=: saleSize ];
            if(countShareHolderLang > 0){
                List<Team_Mapping_Refer_Out_Condition_1__c> conditionShareHolderLangList = [Select Team_RC_Code__c FROM Team_Mapping_Refer_Out_Condition_1__c WHERE Shareholder__c =: shareHolder AND Language__c =: language AND Min_Sale_Size__c <=:saleSize AND Max_Sale_Size__c >=: saleSize LIMIT 1];
                for(Team_Mapping_Refer_Out_Condition_1__c eachMappingRCcode1 : conditionShareHolderLangList){
                    teamRCcodeList.add(eachMappingRCcode1.Team_RC_Code__c);
                }
            }else{
            //step 2 Check Province
                if(province != null){
                    if(GlobalConstants.CBS_BKK_HUBLIST.contains(province)){
                        //Step 3 Check Special
                        Integer countBusinessCode = [SELECT count() FROM Team_Mapping_Refer_Out_Condition_2__c WHERE Business_Code__c =:businessCode ];
                            
                        if(countBusinessCode > 0){
                            Team_Mapping_Refer_Out_Condition_2__c conditionBusinessCode = [Select RC_Code__c FROM Team_Mapping_Refer_Out_Condition_2__c WHERE Business_Code__c =: businessCode];
                            teamRCcodeList.add(conditionBusinessCode.RC_Code__c);
                        }else{
                            //Step4 check 97 industry
                            //countBusinessCode = [SELECT count() FROM Business_Code__c WHERE External_ID__c=:businessCode]; 
                            //fix for industry data
                            countBusinessCode = [SELECT count() FROM Business_Code__c WHERE Name=:businessCode]; 
                            if(countBusinessCode > 0){
                                //Business_Code__c businessCodeObj= [SELECT Sub_Industry_Group__c,X26_Industries_Group__c  FROM Business_Code__c WHERE External_ID__c=:businessCode];
                                Business_Code__c businessCodeObj= [SELECT Sub_Industry_Group__c,X26_Industries_Group__c  FROM Business_Code__c WHERE Name=:businessCode LIMIT 1];
                                Integer countTeam97Industry = [SELECT count() FROM Team_Mapping_Refer_Out_Condition_3__c WHERE Sub_Industry_Group__c =: businessCodeObj.Sub_Industry_Group__c  AND Min_Sale_Size__c <=: saleSize AND Max_Sale_Size__c >=: saleSize];
                                if(countTeam97Industry > 0){
                                    List<Team_Mapping_Refer_Out_Condition_3__c>  condition97IndustryList = [SELECT RC_Code__c FROM Team_Mapping_Refer_Out_Condition_3__c WHERE Sub_Industry_Group__c =: businessCodeObj.Sub_Industry_Group__c AND Min_Sale_Size__c <=: saleSize AND Max_Sale_Size__c >=: saleSize];
                                    for(Team_Mapping_Refer_Out_Condition_3__c eachMappingRCcode3 : condition97IndustryList){
                                        teamRCcodeList.add(eachMappingRCcode3.RC_Code__c);
                                    }
                                }
                            }
                        }
                    }else{
                        Integer countProvince = [SELECT count() from Team_Province_Master_Data__c where Province_Name__c =: province];
                        if(countProvince >0){
                            List<Team_Province_Master_Data__c> teamProvinceList = [Select Team_Structure__c,Team_Structure__r.RC_Code__c from Team_Province_Master_Data__c where Province_Name__c =: province AND Segment__c IN ('CB','MB')];
                            for(Team_Province_Master_Data__c eachTeamProvince : teamProvinceList){
                                teamRCcodeList.add(eachTeamProvince.Team_Structure__r.RC_Code__c);
                            }
                        }
                    }
                }
            }            
        }catch(Exception ex){
            throw new Ownership_Service.OwnershipException(ex.getMessage());
        }finally{
            if(teamRCcodeList.size() > 0){
                selectTeamList = [SELECT ID,Name FROM Team_Structure__c WHERE RC_Code__c IN :teamRCcodeList ];
            }else{
                selectTeamList = new List<Team_Structure__c>();
            }
        }
        return selectTeamList;
    }

    webservice static Response releaseOwnership(String accountString,String userString){
        Response res = new Response();
        try{
            Account accountObj = (Account)JSON.deserialize(accountString,Account.class);
            User userObj = (User)JSON.deserialize(userString,User.class);
            Customer_Ownership_Request__c resultObj = Ownership_Service.releaseOwnership(accountObj, userObj);

            res.recordId = resultObj.Id;
            res.success = true;
        }catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }
    /*
    @future
    public static void rejectCustomerOwnershipRequest(Set<Id> userIdSet){
        Map<Id,Customer_Ownership_Request__c> customerRequestMap = new Map<Id,Customer_Ownership_Request__c>([SELECT Id From Customer_Ownership_Request__c WHERE OwnerId IN :userIdSet AND Approval_Status__c = :GlobalConstants.APPROVAL_IN_PROGRESS]);
        List<ProcessInstanceWorkitem> pendingCustomerOwnershipList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: customerRequestMap.keySet()];
        String customerOwnerShipString = JSON.serialize(pendingCustomerOwnershipList);
        ApprovalProcessResult_Service.processWorkItems(customerOwnerShipString,'REJECT','');
    }*/

    public static boolean isOwnerSegmentOrProfileAllowToRequestOwnership(Account requestAccount){
        CBS_Admin_Ownership__c cbsAdminSetting = CBS_Admin_Ownership__c.getOrgDefaults();
        SME_Admin__c smeAdminSetting = SME_Admin__c.getOrgDefaults();
        Boolean isAllowRequest = true;
        if(!GlobalConstants.SME_SEGMENT_CODE_SET.contains(requestAccount.Owner.Segment__c) && !GlobalConstants.CBS_SEGMENT_CODE_SET.contains(requestAccount.Owner.Segment__c)
           && !(requestAccount.OwnerId == smeAdminSetting.User_Record_ID__c || requestAccount.OwnerId == cbsAdminSetting.User_Record_ID__c)){
            isAllowRequest = false;
        }
        return isAllowRequest;
    }

    private static User getUserInfo() {
        User user = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return user;
    }

    @AuraEnabled
    public static Response releaseTemporaryOwnership(Id accountId) {
        Response res = new Response();
        try {
            User userInfo = getUserInfo();
            User_Extension__c currentUserExtension;
            Account accountObj = [SELECT Id, SME_Temporary_Customer__c, AF_Temporary_Customer__c, Temp_Owner_Changed_Date__c, OwnerChangeExecutedByTrigger__c, Permanent_Owner_Extension__c, OwnerId, Previous_Owner__c, Ownership_Text__c FROM Account WHERE Id=:accountId];
            Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>([SELECT Id, User__c FROM User_Extension__c WHERE Id = :accountObj.Permanent_Owner_Extension__c OR User__c = :userInfo.Id]);
            for(User_Extension__c eachUserExtension : userExtMap.values()) {
                if(userInfo.Id == eachUserExtension.User__c) {
                    currentUserExtension = eachUserExtension;    
                }
            }

            if(currentUserExtension != null && accountObj.SME_Temporary_Customer__c == currentUserExtension.Id) {
                accountObj.Temp_Owner_Changed_Date__c = System.today();
                accountObj.OwnerChangeExecutedByTrigger__c = true;
                accountObj.SME_Temporary_Customer__c    = null;
                Account_Service.isChangeOwnership       = true;
                Account_Service.callingFromYearEndBatch = false;
                ApprovalProcess_Service.approvedCustomerOwnershipRequest(new Map<Id, Account>{accountObj.Id => accountObj});
                update accountObj;
                res.recordId = accountObj.Id;
                res.success = true;
            } else {
                res.success = false;
                res.msg = Label.Release_Temporary_Ownership_Error_User;
            }
        } catch(Exception ex) {
            res.success = false;
            res.msg = 'Failed to Release Temporary Ownership Request, ' + ex.getMessage();
        }
        return res;
    }

    /*
    @AuraEnabled
    public static Account getAccountInfo(String accountId) {
        return Account_Service.getAccountInformation(accountId);
    }

    @AuraEnabled
    public static Boolean getExistingOwnership(String accountId ,String userId) {
        List<Customer_Ownership_Request__c> cusOwnershipReq = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountId AND OwnerID=:userId AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC LIMIT 1];
        return cusOwnershipReq == null || cusOwnershipReq.size() == 0 ?false:true;
    }

    @AuraEnabled
    public static String getFraudStatus(String accountIdString) {
        Account accountObj = Account_Service.getAccountInformation(accountIdString);
        Account_Service.Response fraudResp = new Account_Service.Response();
        if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME ||
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            fraudResp.success = true;
            fraudResp.colorCode = GlobalConstants.FRAUD_COLOR_BLUE;
        } else {
            fraudResp = Account_Service.getFraudStatus(Json.serialize(accountObj));
        }
        return Json.serialize(fraudResp);
    }

    @AuraEnabled
    public static String getDefaultCbsAdminId() {
        CBS_Admin_Ownership__c cbsAdminSetting = CBS_Admin_Ownership__c.getOrgDefaults();
        return cbsAdminSetting.User_Record_ID__c;
    }

    @AuraEnabled
    public static Response validateReleaseOwnership(String accountId) {
        Response res = new Response();
        res.success = false;
        res.msg = 'Customer must be in your port to release ownership';
        
        try {
            User userInfo = getUserInfo();
            Account accountInfo = getAccountInfo(accountId);
            String profileName = userInfo.Profile.Name;
            String[] userProfileNameSplit = userInfo.Profile.Name.split('-');
            String userProfile = userProfileNameSplit[0];

            Integer countReleaseRequest = [SELECT Count() FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountId AND OwnerID=:userInfo.Id AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') LIMIT 1];
            if(userProfile.toLowerCase() == 'an'){
                res.msg = Label.Release_Ownership_Error_User;
            }else if(countReleaseRequest > 0) {
                res.msg = 'This Customer already submitted for ownership release, cannot re-submit';
            }else if(userInfo.Id == accountInfo.OwnerId) {
                if((accountInfo.Port_Pool__c == 'Port' && profileName=='SME-RM' ) ||
                    (accountInfo.Port_Pool__c != '' && profileName=='SME-TM' && accountInfo.Temporary_Ownership_Flag__c == false)){
                    res.msg = 'SME';
                    res.success = true;
                }

                if(accountInfo.Port_Pool__c == 'Port' && (profileName=='CBS-RM' || profileName=='CBS-TM' ||profileName=='CBS-TL')) {
                    Integer countBulkAssignment = [SELECT Count() FROM Bulk_Assignment__c WHERE CIS_ID__c=:accountId AND Status__c IN ('Waiting for Approval','New','Processing') LIMIT 1];
                    if(countBulkAssignment > 0) {
                        res.msg = 'This Customer already submitted for Bulk Assignment, cannot release';
                    } else {
                        res.msg = 'CBS';
                        res.success = true;
                    }
                }
            }
        } catch (Exception ex) {
            res.msg = ex.getMessage();
        }
        return res;
    }

    @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }
    
    private static User_Admin__c getUserAdmin() {
        if(mUserAdmin == null) {
            mUserAdmin = User_Admin__c.getOrgDefaults();
        }
        return mUserAdmin;
    }
    
    @AuraEnabled
    public static String validateRequestOwnership(String accountIdString) {
        Response resp = new Response();
        try {
            Account accountObj = Account_Service.getAccountInformation(accountIdString);
            User currentUser = [SELECT Id, ProfileId, Profile.Name, Name, Segment__c, IsActive, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Email, Manager.Manager.Manager.Email, Manager.Manager.Manager.Profile.Name, Email, AH_Employee_ID__c, NH_Employee_ID__c, SME_User__c, CBS_User__c, RBS_User__c FROM User WHERE Id = :UserInfo.getUserId()];
            
            // Validate User
            resp = validateUserPermission(accountObj, currentUser);
            if(resp.success == false) {
                return Json.serialize(resp);
            }
            // Validate Customer
            resp = validateAccount(accountObj, currentUser);

        } catch(Exception ex) {
            resp.msg = ex.getMessage();
            resp.success = false;
        }
        System.debug('resp all:' + resp);
        return Json.serialize(resp);
    }

    private static Response validateUserPermission(Account accountObj, User currentUser) {
        Response resp = new Response();
        resp.success = true;
        // Validate User
        if(currentUser.Profile.Name == GlobalConstants.SME_RM) {
            if (accountObj.SME_Temporary_Customer__c == currentUser.Id) {
                resp.msg = 'You already take temporary.';
                resp.success = false;
            }
        } else if(GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)) {
            if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(accountObj.OwnerId != getUserAdmin().CBS_User_ID__c) {
                    resp.msg = Label.CBS_Can_Request_Customer_from_CBS_Admin;
                    resp.success = false;
                }
            }
        } else if (accountObj.OwnerId == currentUser.Id) {
            resp.msg = 'Customer already in your port.';
            resp.success = false;
        } else if(getExistingOwnership(accountObj.Id, currentUser.Id)){
            resp.msg = 'This Customer already submitted for ownership request, cannot re-submit.';
            resp.success = false;
        } else {
            resp.msg = Label.Request_Ownership_Error_User;
            resp.success = false;
        }
        return resp;
    }

    private static Response validateAccount(Account accountObj, User currentUser) {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Customer_Ownership_Request__c');
        String poolRecordTypeId     = recordTypeMapByDevName.get(GlobalConstants.OWNERSHIP_REQUEST_POOL_DEVNAME);
        String portRecordTypeId     = recordTypeMapByDevName.get(GlobalConstants.OWNERSHIP_REQUEST_PORT_DEVNAME);
        String requestRecordType;
        String currentOwner;
        Response resp = new Response();
        resp.success = true;
        if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME) {
            if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)) { // CBS User
                    requestRecordType = portRecordTypeId;
                } else { // SME User
                    if(accountObj.Port_Pool__c == GlobalConstants.PORT) {
                        requestRecordType = portRecordTypeId;
                    } else if(accountObj.Port_Pool__c == GlobalConstants.POOL) {
                        requestRecordType = portRecordTypeId;
                    } else {
                        if(accountObj.OwnerId == getUserAdmin().SME_User_ID__c) {
                            requestRecordType = portRecordTypeId;
                        } else if(accountObj.SME_Temporary_Customer__c != null || GlobalConstants.PROFILE_SME_SET.contains(accountObj.Owner.Profile.Name)) {
                            requestRecordType = poolRecordTypeId;
                        } else {
                            // No permission to request
                            resp.success = false;
                        }
                    }
                }
            } else if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                requestRecordType = portRecordTypeId;
            } else if(GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(currentUser.Profile.Name == GlobalConstants.SME_RM && accountObj.SME_Temporary_Customer__c != null) {
                    requestRecordType = poolRecordTypeId;
                } else {
                    // No permission to request
                    resp.success = false;
                }
            } else if(GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(GlobalConstants.PROFILE_SME_SALE_SET.contains(currentUser.Profile.Name)) {
					if(accountObj.SME_Temporary_Customer__c != null) {
						requestRecordType = poolRecordTypeId;
					}
                } else {
                    resp.success = false;
                }
            }
        } else if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            if(accountObj.OwnerId == getUserAdmin().SME_User_ID__c || accountObj.SME_Temporary_Customer__c == null) {
                // No permission to request
                resp.success = false;
            } else if(accountObj.SME_Temporary_Customer__c != null) {
                requestRecordType = poolRecordTypeId;
            } else {
                resp.success = false;
            }
        } else {
            // No permission to request
            resp.success = false;
        }

        if(resp.success) {
            Customer_Ownership_Request__c requestObj = new Customer_Ownership_Request__c();    

            requestObj.Request_Type__c  = GlobalConstants.REQUEST_OWNERSHIP;
            //requestObj.Current_Owner__c = accountObj.OwnerId;
            requestObj.CIS_ID__c        = accountObj.Id;
            requestObj.OwnerID          = currentUser.Id;
            requestObj.Request_Ownership_Type__c = GlobalConstants.PORT;
            requestObj.RecordTypeId     = requestRecordType;
            if(requestRecordType == poolRecordTypeId && accountObj.SME_Temporary_Customer__c != null) {
                User_Extension__c userExtension = [SELECT Id, User__c FROM User_Extension__c WHERE Id = :accountObj.SME_Temporary_Customer__c];
                requestObj.Current_Owner__c = userExtension.User__c;
            } else {
                requestObj.Current_Owner__c = accountObj.OwnerId;
            }
            requestObj.User_Admin__c    = getUserAdmin().User_Record_ID__c;
            resp.customerRequest = requestObj;
        } else {
            resp.msg = Label.Request_Ownership_Error_Customer;
        }
        return resp;
    }

    global static void createOwnershipRequestShare(List<Customer_Ownership_Request__c> requestList) {
        List<Customer_Ownership_Request__Share> shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
        for(Customer_Ownership_Request__c requestObj : requestList) {
            if(requestObj.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP && (requestObj.Current_Owner__c != requestObj.OwnerId || requestObj.SME_Temporary_Customer__c != requestObj.OwnerId)) {
                if(requestObj.SME_Temporary_Customer__c != requestObj.OwnerId && requestObj.SME_Temporary_Customer__c != null){
                    Customer_Ownership_Request__Share ownerSMETempShareObj = new Customer_Ownership_Request__Share();
                    ownerSMETempShareObj.ParentId      = requestObj.Id;
                    ownerSMETempShareObj.UserOrGroupId = requestObj.SME_Temporary_Customer__c;
                    ownerSMETempShareObj.AccessLevel   = 'Read';
                    ownerSMETempShareObj.RowCause      = 'Manual';
                    shareRecordToUpdate.add(ownerSMETempShareObj);
                }else if(requestObj.Current_Owner__c != requestObj.OwnerId){
                    Customer_Ownership_Request__Share ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.ParentId      = requestObj.Id;
                    ownerShareObj.UserOrGroupId = requestObj.Current_Owner__c;
                    ownerShareObj.AccessLevel   = 'Read';
                    ownerShareObj.RowCause      = 'Manual';
                    shareRecordToUpdate.add(ownerShareObj);
                }
                
                String ownerManager = null;
                if(requestObj.Current_Owner_TM__c != null) {
                    ownerManager = requestObj.Current_Owner_TM__c;
                } else if(requestObj.Current_Owner_AH__c != null) {
                    ownerManager = requestObj.Current_Owner_AH__c;
                } else if(requestObj.Current_Owner_NH__c != null) {
                    ownerManager = requestObj.Current_Owner_NH__c;
                }

                if(ownerManager != null) {
                    Customer_Ownership_Request__Share requestObjShare = new Customer_Ownership_Request__Share();
                    requestObjShare.ParentId        = requestObj.Id;
                    requestObjShare.UserOrGroupId   = ownerManager;
                    requestObjShare.AccessLevel     = 'Read';
                    requestObjShare.RowCause        = 'Manual';
                    shareRecordToUpdate.add(requestObjShare);
                }
                // Add for (CBS-Ongoing) In case of NH-TL
                if(requestObj.Current_Owner_NH__c != null && requestObj.Current_Owner_NH__c != ownerManager){
                    Customer_Ownership_Request__Share requestObjShare = new Customer_Ownership_Request__Share();
                    requestObjShare.ParentId        = requestObj.Id;
                    requestObjShare.UserOrGroupId   = requestObj.Current_Owner_NH__c;
                    requestObjShare.AccessLevel     = 'Read';
                    requestObjShare.RowCause        = 'Manual';
                    shareRecordToUpdate.add(requestObjShare);
                }
            }
        }
        if(!shareRecordToUpdate.isEmpty()) {
            insert shareRecordToUpdate;
        }
    }

    global static void updateRequestOwnershipRequesterFields(Customer_Ownership_Request__c requestObj, User requester) {
        String requesterTM;
        String requesterAH;
        String requesterNH;

        if(requester.Profile.Name == GlobalConstants.SME_TM || requester.Profile.Name == GlobalConstants.CBS_TM) {
            requesterTM = requester.Id;
        } else if(requester.Profile.Name == GlobalConstants.SME_AH || requester.Profile.Name == GlobalConstants.CBS_TL || requester.Profile.Name == GlobalConstants.OT_AH_SALES) {
            requesterAH = requester.Id;
        } else if(requester.Profile.Name == GlobalConstants.SME_NH || requester.Profile.Name == GlobalConstants.OT_NH_SALES) {
            requesterNH = requester.Id;
        }
        //Add For (CBS-Ongoing)
        if(requester.ManagerId != null && requester.Manager.IsActive) {
            if(requester.Manager.Profile.Name == GlobalConstants.SME_TM || requester.Manager.Profile.Name == GlobalConstants.CBS_TM) {
                requesterTM = requester.ManagerId;
            } else if(requester.Manager.Profile.Name == GlobalConstants.SME_AH || requester.Profile.Name == GlobalConstants.OT_AH_SALES || (requester.Profile.Name != GlobalConstants.CBS_TL && requester.Manager.Profile.Name == GlobalConstants.CBS_TL) ) {
                requesterAH = requester.ManagerId;
            } else if(requester.Manager.Profile.Name == GlobalConstants.SME_NH || requester.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || (requester.Profile.Name == GlobalConstants.CBS_TL && requester.Manager.Profile.Name == GlobalConstants.CBS_TL)) {
                requesterNH = requester.ManagerId;
            }
        }
        //Add For (CBS-Ongoing)
        if(requester.Manager.ManagerId != null && requester.Manager.Manager.IsActive) {
            if(requester.Manager.Manager.Profile.Name == GlobalConstants.SME_AH || requester.Manager.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (requester.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL && requester.Manager.Profile.Name != GlobalConstants.CBS_TL)) {
                requesterAH = requester.Manager.ManagerId;
            } else if(requester.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || requester.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || requester.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                requesterNH = requester.Manager.ManagerId;
            }
        }
        //Add For (CBS-Ongoing)
        if(requester.Manager.Manager.ManagerId != null && requester.Manager.Manager.Manager.IsActive) {
            if(requester.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || requester.Manager.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || requester.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                requesterNH = requester.Manager.Manager.ManagerId;
            }
        }

        requestObj.Requestor_TM__c  = requesterTM;
        requestObj.Requestor_AH__c  = requesterAH;
        requestObj.Requestor_NH__c  = requesterNH;
    }

    global static void updateRequestOwnershipOwnerFields(Customer_Ownership_Request__c requestObj, User requester, User currentAccountOwner) {
        String tmCurrentOwner;
        String ahCurrentOwner;
        String nhCurrentOwner;

        System.debug('updateRequestOwnershipOwnerFields currentAccountOwner:' + currentAccountOwner);
        if(currentAccountOwner.Profile.Name == GlobalConstants.SME_TM || currentAccountOwner.Profile.Name == GlobalConstants.CBS_TM) {
            tmCurrentOwner = currentAccountOwner.Id;
        } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_AH || currentAccountOwner.Profile.Name == GlobalConstants.OT_AH_SALES || currentAccountOwner.Profile.Name == GlobalConstants.CBS_TL) {
            ahCurrentOwner = currentAccountOwner.Id;
        } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_NH || currentAccountOwner.Profile.Name == GlobalConstants.OT_NH_SALES) {
            nhCurrentOwner = currentAccountOwner.Id;
        }
        // Add for (CBS-Ongoing)
        if(currentAccountOwner.Manager!=null && currentAccountOwner.Manager.IsActive) {
            if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_TM || currentAccountOwner.Manager.Profile.Name == GlobalConstants.CBS_TM) {
                tmCurrentOwner = currentAccountOwner.ManagerId;
            } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_AH || currentAccountOwner.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (currentAccountOwner.Manager.Profile.Name == GlobalConstants.CBS_TL && currentAccountOwner.Profile.Name != GlobalConstants.CBS_TL)) {
                ahCurrentOwner = currentAccountOwner.ManagerId;
            } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_NH || currentAccountOwner.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || (currentAccountOwner.Profile.Name == GlobalConstants.CBS_TL && currentAccountOwner.Manager.Profile.Name == GlobalConstants.CBS_TL)) {
                nhCurrentOwner = currentAccountOwner.ManagerId;
            }
        }
        // Add for (CBS-Ongoing)
        if(currentAccountOwner.Manager.Manager!=null && currentAccountOwner.Manager.Manager.IsActive) {
            if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_AH || currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.OT_AH_SALES || (currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL && currentAccountOwner.Manager.Profile.Name != GlobalConstants.CBS_TL)) {
                ahCurrentOwner = currentAccountOwner.Manager.ManagerId;
            } else if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || (currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL)) {
                nhCurrentOwner = currentAccountOwner.Manager.ManagerId;
            }
        }
        // Add for (CBS-Ongoing)
        if(currentAccountOwner.Manager.Manager.Manager!=null && currentAccountOwner.Manager.Manager.Manager.IsActive) {
            if(currentAccountOwner.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || currentAccountOwner.Manager.Manager.Manager.Profile.Name == GlobalConstants.OT_NH_SALES || currentAccountOwner.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL) {
                nhCurrentOwner = currentAccountOwner.Manager.Manager.ManagerId;
            }
        }

        requestObj.Current_Owner_TM__c = tmCurrentOwner;
        requestObj.Current_Owner_AH__c = ahCurrentOwner;
        requestObj.Current_Owner_NH__c = nhCurrentOwner;
    }

    global static void updateRequestOwnership(Customer_Ownership_Request__c requestObj, Account accountObj, User requester, User currentAccountOwner) {
        System.debug('requestObj:' + requestObj);
        System.debug('requester:' + requester);
        updateRequestOwnershipRequesterFields(requestObj, requester);
        updateRequestOwnershipOwnerFields(requestObj, requester, currentAccountOwner);
    }*/
}