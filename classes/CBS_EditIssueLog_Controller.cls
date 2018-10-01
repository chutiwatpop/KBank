public with sharing class CBS_EditIssueLog_Controller {
    private static final String LV3PREFIX = 'LV3PREFIX';

	public Issue_Log__c issueLog {get;set;}
    public Boolean isOwnerMode {get;set;}
    public Boolean isEditableIssueMode {get;set;}

    public String rejectReason {get;set;}
    public String reOpenReason {get;set;}

    // ---- Editable Issue Information
    private Map<String, Map<String, Map<String, Map<String, Id>>>> issueMasterLv1234;
    public Map<Id, Issue_Master__c> issueMasterMap {get;set;}
    public String selectDivision {get;set;}
    public String selectProduct {get;set;}
    public String selectCategory {get;set;}
    public String selectSubCategory {get;set;}
    public String selectReassignTo{get;set;}
    public String selectReassignName{get;set;}

    public Map<String,Map<String,Boolean>> otherProductMapByProduct;
    public Map<String,Map<String,Map<String,Boolean>>> otherCatMapByCat;
    public Map<String,Map<String,Map<String,Map<String,Boolean>>>> otherSubCatMapBySubCat;
    public Boolean otherProductRender {get;set;}
    public Boolean otherCategoryRender {get;set;}
    public Boolean otherSubCategoryRender {get;set;}

    public Boolean productDisabled {get;set;}
    public Boolean categoryDisabled {get;set;}
    public Boolean subCatagoryDisabled {get;set;}
    public Integer subCategoryCount;
    // ----

    public String selectStatus {get;set;}
    //key:dev name,value:id
    private Map<String,RecordType> devNameIssueLogRecordType;
    private Set<String> openIssueRecordTypeDevName = new Set<String>{GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC,GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC};
    //private Set<String> closedIssueRecordTypeDevName = new Set<String>{GlobalConstants.CBS_CLOSED_ISSUE_PARENT_REC,GlobalConstants.CBS_CLOSED_ISSUE_SECOND_REC};
    private String currentProfileName;
    private List<GroupMember>groupMembers;
    private Map<String,List<GroupMember>>groupNameAndItsMembers;
    private Map<String,User>usersMap;
    public Boolean disableReAssignName{get;set;}
    List<CBS_Issue_Log_Management__c>cbsIssueLogManagements;

    public String divisionHelpText{get;set;}

    public CBS_EditIssueLog_Controller(ApexPages.StandardController stdController) {
        this.issueLog = (Issue_Log__c)stdController.getRecord();
        this.issueLog = [SELECT Id, Subject__c, Name, Parent_Issue__c, IsParentIssue__c, Date_Time_Opened__c, Date_Time_Closed__c, Status__c, Time_Used_Days__c, CIS_ID_or_Prospect_Name__c, CIS_ID_or_Prospect_Name__r.Name, CIS_ID_or_Prospect_Name__r.Name_TH__c, Group__c, Sub_Group__c, OwnerId, Assigned_Team_Person__c, IssueLog_Creator__c, Issue_Log_Creator_Phone__c, IssueLog_Creator_TL__c,IssueLog_Creator_TL__r.Name,Issue_Log_Creator_TL_Phone__c, IssueLog_Creator_FSVP__c,IssueLog_Creator_FSVP__r.Name, Issue_Log_Creator_FSVP_Phone__c, Division_Formula__c, Product_Formula__c, Product_Text__c, Category_Formula__c, Category_Specify__c, Sub_Category_Formula__c, Sub_Category_Specify__c, Issue_Description__c, Progress_Solution__c, Call_Plan_Call_Report__c, Opportunity__c, Re_Open_Reason__c, Reject_Reason__c, Owner.Profile.Name, Issue_Master__c,Re_Assign_Reason__c, Issue_Log_Owner__c FROM Issue_Log__c WHERE Id = :issueLog.Id];
        init();
    }

    private void init() {
        getIssueMaster();

        rejectReason = '';
        reOpenReason = '';
        isEditableIssueMode = false;
        isOwnerMode = false;

        divisionHelpText = '';

        this.selectDivision = this.issueLog.Division_Formula__c;
        this.selectProduct = this.issueLog.Product_Formula__c;
        this.selectCategory = this.issueLog.Category_Formula__c;
        this.selectSubCategory = this.issueLog.Sub_Category_Formula__c;
        this.selectStatus = this.issueLog.Status__c;
        if(this.selectStatus == GlobalConstants.RECALLED) {
            isEditableIssueMode = true;
        }

        this.disableReAssignName = true;
        List<User>users = [SELECT Id,Name FROM User];
        this.usersMap = new Map<String,User>();
        for(User user:users){
            this.usersMap.put(user.Id,user);
        }
        Set<String>cbsServicePublicGroupNames = new Set<String>{GlobalConstants.GROUP_CBS_SP,GlobalConstants.GROUP_CBS_SC};
        this.groupMembers = [SELECT GroupId,Id,UserOrGroupId,Group.Name FROM GroupMember WHERE Group.Name IN: cbsServicePublicGroupNames];
        this.groupNameAndItsMembers = new Map<String,List<GroupMember>>();
        for(GroupMember groupMember:this.groupMembers){
            if(!this.groupNameAndItsMembers.containsKey(groupMember.Group.Name)){
                this.groupNameAndItsMembers.put(groupMember.Group.Name,new List<GroupMember>());
            }
            this.groupNameAndItsMembers.get(groupMember.Group.Name).add(groupMember);
        }
        this.currentProfileName = getProfileName();
        //for test
        //this.currentProfileName = GlobalConstants.CBS_SC;
        //for test

        String issueMode = ApexPages.currentPage().getParameters().get('issueMode');
        if(issueMode == 'owner') {
            isOwnerMode = true;
        } else {
            isOwnerMode = false;
        }
        
        List<RecordType>issueLogRecordTypes = [SELECT DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Issue_Log__c'];
        devNameIssueLogRecordType = new Map<String,RecordType>();
        for(RecordType issueLogRecordType:issueLogRecordTypes){
            devNameIssueLogRecordType.put(issueLogRecordType.Id,issueLogRecordType);
        }
    }

    private String getProfileName(){
        Id currentUserId = Userinfo.getUserId();
        Id currentUserProfileId = Userinfo.getProfileId();
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId];
        String profileName = currentUserProfile.Name;

        //check SP,SC
        Map<String,GroupMember>groupMemberMap = new Map<String,GroupMember>();
        for(GroupMember groupMember:this.groupMembers){
            groupMemberMap.put(groupMember.UserOrGroupId,groupMember);
        }
        if(groupMemberMap.containsKey(currentUserId)){
            String groupName = groupMemberMap.get(currentUserId).Group.Name;
            if(groupName.equalsIgnoreCase(GlobalConstants.GROUP_CBS_SP)){
                profileName = GlobalConstants.CBS_SP;
            }else if(groupName.equalsIgnoreCase(GlobalConstants.GROUP_CBS_SC)){
                profileName = GlobalConstants.CBS_SC;
            }
        }
        
        System.debug('profileName>>>' + profileName);
        return profileName;
    }

    public List<SelectOption> getDivisionList() {
        List<SelectOption> divisionList = new List<SelectOption>();
        List<SelectOption> tempDivisionList = new List<SelectOption>();
        divisionList.add(new SelectOption('None', 'None'));
        for (String eachDivision : issueMasterLv1234.keySet()) {
            tempDivisionList.add(new SelectOption(eachDivision, eachDivision));
        }
        tempDivisionList.sort();
        divisionList.addAll(tempDivisionList);
        return divisionList;
    }

    public List<SelectOption> getProductList() {
        List<SelectOption> productList = new List<SelectOption>();
        List<SelectOption> tempProductList = new List<SelectOption>();
        productList.add(new SelectOption('None', 'None'));
        if(selectDivision != null && selectDivision != 'None' && issueMasterLv1234.containsKey(selectDivision)) {
            for (String eachProduct : issueMasterLv1234.get(selectDivision).keySet()) {
                tempProductList.add(new SelectOption(eachProduct, eachProduct));
            }
        }
        tempProductList.sort();
        productList.addAll(tempProductList);
        if(tempProductList.size()>1){
            productDisabled = false;    
        }
        return productList;
    }

    public List<SelectOption> getCategoryList() {
        List<SelectOption> categoryList = new List<SelectOption>();
        List<SelectOption> tempCategoryList = new List<SelectOption>();
        categoryList.add(new SelectOption('None', 'None'));
        if(selectDivision != null && selectDivision != 'None' && issueMasterLv1234.containsKey(selectDivision) && selectProduct != null && selectProduct != 'None' && issueMasterLv1234.get(selectDivision).containsKey(selectProduct)) {
            for (String eachCategory : issueMasterLv1234.get(selectDivision).get(selectProduct).keySet()) {
                tempCategoryList.add(new SelectOption(eachCategory, eachCategory));
            }
        }
        tempCategoryList.sort();
        categoryList.addAll(tempCategoryList);
        if(categoryList.size() > 1){
            categoryDisabled = false;   
        }
        return categoryList;
    }

    public List<SelectOption> getSubCategoryList() {
        List<SelectOption> subCategoryList = new List<SelectOption>();
        List<SelectOption> tempSubCategoryList = new List<SelectOption>();
        subCategoryList.add(new SelectOption('None', 'None'));
        if(selectDivision != null && selectDivision != 'None' && issueMasterLv1234.containsKey(selectDivision) && selectProduct != null && selectProduct != 'None' && issueMasterLv1234.get(selectDivision).containsKey(selectProduct) && selectCategory != null && selectCategory != 'None' && issueMasterLv1234.get(selectDivision).get(selectProduct).containsKey(selectCategory)) {
            for (String eachSubCategory : issueMasterLv1234.get(selectDivision).get(selectProduct).get(selectCategory).keySet()) {
                if(!eachSubCategory.contains(LV3PREFIX)) {
                    tempSubCategoryList.add(new SelectOption(eachSubCategory, eachSubCategory));    
                }
            }
        }
        tempSubCategoryList.sort();
        subCategoryList.addAll(tempSubCategoryList);
        subCategoryCount = subCategoryList.size();
        return subCategoryList;
    }

    public List<SelectOption> getReAssignToList() {
        List<SelectOption> reAssignToList = new List<SelectOption>();
        List<String> reassignToOptions = new List<String>();
        Boolean isAdmin = this.currentProfileName.equalsIgnoreCase(GlobalConstants.CBS_ADMIN);
        Boolean isTL = this.currentProfileName.equalsIgnoreCase(GlobalConstants.CBS_TL);
        Boolean isFSVP = this.currentProfileName.equalsIgnoreCase(GlobalConstants.CBS_FSVP);
        Boolean isSP = this.currentProfileName.equalsIgnoreCase(GlobalConstants.CBS_SP);
        Boolean isSC = this.currentProfileName.equalsIgnoreCase(GlobalConstants.CBS_SC);
        this.cbsIssueLogManagements = [SELECT Name FROM CBS_Issue_Log_Management__c];
        if(isTL){
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_FSVP,'FSVP'));
        }else if(isFSVP){
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_TL,'TL'));
        }else if(isSP){
            //TL/FSVP/SC/PM
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_TL,'TL'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_FSVP,'FSVP'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_SC,'SC'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_PM,'PM'));
        }else if(isSC){
            //TL/FSVP/SP/PM
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_TL,'TL'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_FSVP,'FSVP'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_SP,'SP'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_PM,'PM'));
        }else if(isAdmin) {
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_TL,'TL'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_FSVP,'FSVP'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_SC,'SC'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_SP,'SP'));
            reAssignToList.add(new SelectOption(GlobalConstants.CBS_PM,'PM'));
        }
        return reAssignToList;
    }

    public List<SelectOption> getReAssignNameList(){
        List<SelectOption> reAssignNameList = new List<SelectOption>();
        System.debug('selectReassignTo >> ' + this.selectReassignTo);
        if(String.isBlank(this.selectReassignTo)){
            this.disableReAssignName = true;
            reAssignNameList.add(new SelectOption('',''));
        }else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_TL)){
            if(String.isNotBlank(this.issueLog.IssueLog_Creator_TL__r.Name)){
                reAssignNameList.add(new SelectOption(this.issueLog.IssueLog_Creator_TL__c,this.issueLog.IssueLog_Creator_TL__r.Name));
                this.disableReAssignName = false;
            }else{
                reAssignNameList.add(new SelectOption('',''));
                this.disableReAssignName = true;
            }
        }else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_FSVP)){
            if(String.isNotBlank(this.issueLog.IssueLog_Creator_FSVP__r.Name)){
                reAssignNameList.add(new SelectOption(this.issueLog.IssueLog_Creator_FSVP__c,this.issueLog.IssueLog_Creator_FSVP__r.Name));
                this.disableReAssignName = false;
            }else{
                reAssignNameList.add(new SelectOption('',''));
                this.disableReAssignName = true;
            }
        }else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_SC)){
            if(!this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SC).isEmpty()){
                for(GroupMember groupmember:this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SC)){
                    String userId = groupmember.UserOrGroupId;
                    String userName = (this.usersMap.get(groupmember.UserOrGroupId)).Name;
                    reAssignNameList.add(new SelectOption(userId,userName));
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
            
        }else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_SP)){
            if(!this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SP).isEmpty()){
                for(GroupMember groupmember:this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SP)){
                    String userId = groupmember.UserOrGroupId;
                    String userName = (this.usersMap.get(groupmember.UserOrGroupId)).Name;
                    reAssignNameList.add(new SelectOption(userId,userName));
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
        }
        else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_PM)){
            if(!this.cbsIssueLogManagements.isEmpty()){
                for(CBS_Issue_Log_Management__c cbsIssueLogManagement:this.cbsIssueLogManagements){
                    reAssignNameList.add(new SelectOption(cbsIssueLogManagement.Name,cbsIssueLogManagement.Name));
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
        }
        return reAssignNameList;
    }

    //Version 1
    /*public void getIssueMaster() {
        System.debug('getIssueMaster');
        issueMasterMap = new Map<Id, Issue_Master__c>([SELECT Id, Available_Closed_Status__c, Division__c, Product__c, Category__c, Sub_Category__c, Required_Product__c, Require_Category__c, Require_Sub_Category__c,Assigned_To__c,Assign_To_Internal_User__c,Assign_To_Non_User__c FROM Issue_Master__c]);
        issueMasterLv1234 = new Map<String, Map<String, Map<String, Map<String, Id>>>>();
        for(Issue_Master__c eachIssueMaster : issueMasterMap.values()) {
            if(!issueMasterLv1234.containsKey(eachIssueMaster.Division__c)) issueMasterLv1234.put(eachIssueMaster.Division__c, new Map<String, Map<String, Map<String, Id>>>());
            Map<String, Map<String, Map<String, Id>>> lv2 = issueMasterLv1234.get(eachIssueMaster.Division__c);

            if(!lv2.containsKey(eachIssueMaster.Product__c)) lv2.put(eachIssueMaster.Product__c, new Map<String, Map<String, Id>>());
            Map<String, Map<String, Id>> lv3 = lv2.get(eachIssueMaster.Product__c);

            if(!lv3.containsKey(eachIssueMaster.Category__c)) lv3.put(eachIssueMaster.Category__c, new Map<String, Id>());
            Map<String, Id> lv4 = lv3.get(eachIssueMaster.Category__c);

            if(eachIssueMaster.Sub_Category__c == null) {
                lv4.put(LV3PREFIX + eachIssueMaster.Category__c, eachIssueMaster.Id);
            } else {
                lv4.put(eachIssueMaster.Sub_Category__c, eachIssueMaster.Id);
            }
        }
    }*/

    //Version 2
    public void getIssueMaster() {
        System.debug('getIssueMaster');
        issueMasterMap = new Map<Id, Issue_Master__c>([SELECT Id, Available_Closed_Status__c, Division__c, Product__c, Category__c, Sub_Category__c, Required_Product__c, Require_Category__c, Require_Sub_Category__c,Assigned_To__c,Assign_To_Internal_User__c,Assign_To_Non_User__c FROM Issue_Master__c]);
        issueMasterLv1234 = new Map<String, Map<String, Map<String, Map<String, Id>>>>();

        otherProductMapByProduct = new Map<String,Map<String,Boolean>>();
        otherCatMapByCat = new Map<String,Map<String,Map<String,Boolean>>>();
        otherSubCatMapBySubCat = new Map<String,Map<String,Map<String,Map<String,Boolean>>>>();

        for(Issue_Master__c eachIssueMaster : issueMasterMap.values()) {
            if(!issueMasterLv1234.containsKey(eachIssueMaster.Division__c)) issueMasterLv1234.put(eachIssueMaster.Division__c, new Map<String, Map<String, Map<String, Id>>>());
            Map<String, Map<String, Map<String, Id>>> lv2 = issueMasterLv1234.get(eachIssueMaster.Division__c);

            if(!lv2.containsKey(eachIssueMaster.Product__c)) lv2.put(eachIssueMaster.Product__c, new Map<String, Map<String, Id>>());
            Map<String, Map<String, Id>> lv3 = lv2.get(eachIssueMaster.Product__c);

            if(!lv3.containsKey(eachIssueMaster.Category__c)) lv3.put(eachIssueMaster.Category__c, new Map<String, Id>());
            Map<String, Id> lv4 = lv3.get(eachIssueMaster.Category__c);

            if(eachIssueMaster.Sub_Category__c == null) {
                lv4.put(LV3PREFIX + eachIssueMaster.Category__c, eachIssueMaster.Id);
            } else {
                lv4.put(eachIssueMaster.Sub_Category__c, eachIssueMaster.Id);
            }

            //Create Map for rendering Required_Product_Section
            if(!otherProductMapByProduct.containsKey(eachIssueMaster.Division__c)){
                otherProductMapByProduct.put(eachIssueMaster.Division__c, new Map<String, Boolean>());
            }
            Map<String, Boolean> lv2RequireProduct = otherProductMapByProduct.get(eachIssueMaster.Division__c);
            if(!lv2RequireProduct.containsKey(eachIssueMaster.Product__c)){
                lv2RequireProduct.put(eachIssueMaster.Product__c, eachIssueMaster.Required_Product__c);
            }

            //Create Map for rendering Require_Category_Section
            if(!otherCatMapByCat.containsKey(eachIssueMaster.Division__c)){
                otherCatMapByCat.put(eachIssueMaster.Division__c, new Map<String,Map<String,Boolean>>());
            }
            Map<String, Map<String,Boolean>> lv2RequireCat = otherCatMapByCat.get(eachIssueMaster.Division__c);
            if(!lv2RequireCat.containsKey(eachIssueMaster.Product__c)){
                lv2RequireCat.put(eachIssueMaster.Product__c, new Map<String,Boolean>());
            }
            Map<String,Boolean> lv3RequireCat = lv2RequireCat.get(eachIssueMaster.Product__c);
            if(!lv3RequireCat.containsKey(eachIssueMaster.Category__c)){
                lv3RequireCat.put(eachIssueMaster.Category__c,eachIssueMaster.Require_Category__c);
            }

            //Create Map for rendering Require_SubCat_Section
            if(!otherSubCatMapBySubCat.containsKey(eachIssueMaster.Division__c)){
                otherSubCatMapBySubCat.put(eachIssueMaster.Division__c, new Map<String,Map<String,Map<String,Boolean>>>());
            }
            Map<String,Map<String,Map<String,Boolean>>> lv2RequireSubCat = otherSubCatMapBySubCat.get(eachIssueMaster.Division__c);
            if(!lv2RequireSubCat.containsKey(eachIssueMaster.Product__c)){
                lv2RequireSubCat.put(eachIssueMaster.Product__c, new Map<String,Map<String,Boolean>>());
            }
            Map<String,Map<String,Boolean>> lv3RequireSubCat = lv2RequireSubCat.get(eachIssueMaster.Product__c);
            if(!lv3RequireSubCat.containsKey(eachIssueMaster.Category__c)){
                lv3RequireSubCat.put(eachIssueMaster.Category__c,new Map<String,Boolean>());
            }
            Map<String,Boolean> lv4RequireSubCat = lv3RequireSubCat.get(eachIssueMaster.Category__c);
            if(!lv4RequireSubCat.containsKey(eachIssueMaster.Sub_Category__c)){
                lv4RequireSubCat.put(eachIssueMaster.Sub_Category__c,eachIssueMaster.Require_Sub_Category__c);
            }
        }
    }


    public String getRejectedRecordTypeID(String devName){
        boolean isCBSOpenIssueRecordType = openIssueRecordTypeDevName.contains(devName);
        if(isCBSOpenIssueRecordType){
            if(devName.equalsIgnoreCase(GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC)){
                devName = GlobalConstants.CBS_CLOSED_ISSUE_PARENT_REC;
            }
            if(devName.equalsIgnoreCase(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC)){
                devName = GlobalConstants.CBS_CLOSED_ISSUE_SECOND_REC;
            }
        }
        String toChangeIssueRecordTypeId = null;
        List<RecordType>recordTypes = devNameIssueLogRecordType.values();
        for(RecordType recordType:recordTypes){
            if((recordType.DeveloperName).equalsIgnoreCase(devName)){
                toChangeIssueRecordTypeId = recordType.Id;
                break;
            }
        }
        return toChangeIssueRecordTypeId;
    }

    public PageReference save() {
        this.issueLog.Status__c = this.selectStatus;
        update this.issueLog;
        
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        System.debug('save pageRef : '+pageRef);
        return pageRef;
    }

    public PageReference cancelEdit() {
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public PageReference rejectIssue() {
        this.selectStatus = GlobalConstants.REJECTED;
        this.issueLog.Status__c = this.selectStatus;

        String thisRecordTypeDevName = devNameIssueLogRecordType.get(this.issueLog.RecordTypeId).DeveloperName;
        this.issueLog.RecordTypeId = getRejectedRecordTypeID(thisRecordTypeDevName);
        System.debug('issueLog >> ' + issueLog);
        update this.issueLog;
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public void setEditableIssueModeTrue(){
        this.selectStatus = GlobalConstants.RECALLED;
        this.issueLog.Status__c = this.selectStatus;
        this.isEditableIssueMode = true;
        //return null;
    }
    public PageReference doSaveDraftAfterRecall(){
        //this.issueLog.Status__c = this.selectStatus;
        update this.issueLog;
        
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public PageReference escalateOwnerAndSave() {
        try {
            IssueLog_Service.escalateOwner(this.issueLog);
        } catch(Exception ex) {
            showError(ex.getMessage());
            return null;
        }
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public PageReference doSaveAfterRecall(){
        // Update Status to On Process by 'Role of Assigned User'
        try {
            String issueMasterID = getSelectIssueMaster();
            String assignTo = issueMasterMap.get(issueMasterID).Assigned_To__c;
            this.issueLog.Issue_Master__c = issueMasterID;
            this.issueLog.Status__c = getOnProcessStatus(assignTo);
            update this.issueLog;
        } catch (Exception e) {
            showError(e.getMessage());
            System.debug('doSaveAfterRecall error : '+e);
            return null;
        }

        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        System.debug('doSaveAfterRecall pageRef : '+pageRef);
        return pageRef;
    }
    public PageReference doSaveReAssign(){
        this.cbsIssueLogManagements = [SELECT Name FROM CBS_Issue_Log_Management__c];
        if(selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_FSVP)){
            this.issueLog.Assigned_Internal_Lookup__c = this.issueLog.IssueLog_Creator_FSVP__c;
            this.issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
        }else if(selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_TL)){
            this.issueLog.Assigned_Internal_Lookup__c = this.issueLog.IssueLog_Creator_TL__c; 
            this.issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_TL;
        }else if(selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_SP)){
            this.issueLog.Assigned_Internal_Lookup__c = this.selectReassignName;
            this.issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_SP;
        }else if(selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_SC)){
            this.issueLog.Assigned_Internal_Lookup__c = this.selectReassignName;
            this.issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_SC;
        }else if(selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_PM)){
            this.issueLog.Assigned_Team_Person_Text__c = this.selectReassignName;
            this.issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_PM;
        }
        update this.issueLog;
        System.debug('doSaveReAssign issueLog >> ' + this.issueLog);
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public List<SelectOption> getStatusList() {
        List<SelectOption> statusList = new List<SelectOption>();
        statusList.add(new SelectOption(this.selectStatus, this.selectStatus));
        if(issueMasterMap.containsKey(this.issueLog.Issue_Master__c)) {
            List<String> closeStatus = new List<String>();
            closeStatus = (issueMasterMap.get(this.issueLog.Issue_Master__c).Available_Closed_Status__c).split(';');
            for(String eachStatus : closeStatus) {
                statusList.add(new SelectOption(eachStatus, eachStatus));
            }
        }
        return statusList;
    }

    public List<SelectOption> setStatusList() {
        List<SelectOption> statusList = new List<SelectOption>();
        statusList.add(new SelectOption(this.selectStatus, this.selectStatus));
        if(issueMasterMap.containsKey(this.issueLog.Issue_Master__c)) {
            List<String> closeStatus = new List<String>();
            closeStatus = (issueMasterMap.get(this.issueLog.Issue_Master__c).Available_Closed_Status__c).split(';');
            for(String eachStatus : closeStatus) {
                statusList.add(new SelectOption(eachStatus, eachStatus));
            }
        }
        return statusList;
    }

    private Id getSelectIssueMaster() {
        if(issueMasterLv1234.containsKey(this.selectDivision)) {
            if(issueMasterLv1234.get(this.selectDivision).containsKey(this.selectProduct)) {
                if(issueMasterLv1234.get(this.selectDivision).get(this.selectProduct).containsKey(this.selectCategory)) {
                    if(issueMasterLv1234.get(this.selectDivision).get(this.selectProduct).get(this.selectCategory).containsKey(this.selectSubCategory)) {
                        return issueMasterLv1234.get(this.selectDivision).get(this.selectProduct).get(this.selectCategory).get(this.selectSubCategory);
                    } else if(issueMasterLv1234.get(this.selectDivision).get(this.selectProduct).get(this.selectCategory).containsKey(LV3PREFIX + this.selectCategory)){
                        return issueMasterLv1234.get(this.selectDivision).get(this.selectProduct).get(this.selectCategory).get(LV3PREFIX + this.selectCategory);
                    } else {
                        throw new IssueLogException('Not found Select Sub Category');
                    }
                } else {
                    throw new IssueLogException('Not found Select Category');
                }
            } else {
                throw new IssueLogException('Not found Select Product');
            }
        } else {
            throw new IssueLogException('Not found Select Division');
        }

        return null;
    }

    private String getOnProcessStatus(String assignTo){
        if(this.issueLog.Owner.Profile.Name.equalsIgnoreCase(GlobalConstants.CBS_RM)){
            return GlobalConstants.ON_PROCESS_BY_TL;
        }else if(assignTo.equalsIgnoreCase('TL;FSVP') && this.issueLog.Owner.Profile.Name.equalsIgnoreCase(GlobalConstants.CBS_TL)){
            return GlobalConstants.ON_PROCESS_BY_FSVP;
        }else if(assignTo.equalsIgnoreCase('SC')){
            return GlobalConstants.ON_PROCESS_BY_SC;
        }else if(assignTo.equalsIgnoreCase('SP')){
            return GlobalConstants.ON_PROCESS_BY_SP;
        }else if(assignTo.equalsIgnoreCase('PM')){
            return GlobalConstants.ON_PROCESS_BY_PM;
        }else if(assignTo.equalsIgnoreCase('TL')){
            return GlobalConstants.ON_PROCESS_BY_TL;
        }else if(assignTo.equalsIgnoreCase('FSVP')){
            return GlobalConstants.ON_PROCESS_BY_FSVP;
        }
        return '';
    }

    public void showError (String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public class IssueLogException extends Exception{}

    public void renderDivisionHelpText(){
        if(selectDivision == 'None') {
            divisionHelpText = '';
        }
        else if(selectDivision == 'CBS') {
            divisionHelpText = Label.IssueLog_CBS_Definition;
        }
        else if(selectDivision == 'CMB') {
            divisionHelpText = Label.IssueLog_CMB_Definition;
        }
        else if(selectDivision == 'CSF') {
            divisionHelpText = Label.IssueLog_CSF_Definition;
        }
        else if(selectDivision == 'CSP') {
            divisionHelpText = Label.IssueLog_CSP_Definition;
        }
        else if(selectDivision == 'ERM') {
            divisionHelpText = Label.IssueLog_ERM_Definition;
        }
        else if(selectDivision == 'FCL') {
            divisionHelpText = Label.IssueLog_FCL_Definition;
        }
        else if(selectDivision == 'IBB') {
            divisionHelpText = Label.IssueLog_IBB_Definition;
        }
        else if(selectDivision == 'RBS') {
            divisionHelpText = Label.IssueLog_RBS_Definition;
        }
        else if(selectDivision == 'WBS') {
            divisionHelpText = Label.IssueLog_WBS_Definition;
        }
        else {
            divisionHelpText = '';
        }
    }

    public void validateSelectDivision() {
        System.debug('validateSelectDivision');
        otherProductRender = false;
        otherCategoryRender = false;
        otherSubCategoryRender = false;

        selectProduct = 'None';
        selectCategory = 'None';
        selectSubCategory = 'None';

        issueLog.Product_Text__c = '';
        issueLog.Category_Specify__c = '';
        issueLog.Sub_Category_Specify__c = '';

        if(selectDivision == 'None') {
            productDisabled = true;
        } else{
            productDisabled = false;
        }

        categoryDisabled = true;
        subCatagoryDisabled = true;

        renderDivisionHelpText();
    }

    public void validateSelectProduct() {
        System.debug('validateSelectProduct');
        otherProductRender = false;
        otherCategoryRender = false;
        otherSubCategoryRender = false;

        selectCategory = 'None';
        selectSubCategory = 'None';

        issueLog.Product_Text__c = '';
        issueLog.Category_Specify__c = '';
        issueLog.Sub_Category_Specify__c = '';

        if(otherProductMapByProduct.containsKey(selectDivision)){
            if(otherProductMapByProduct.get(selectDivision).containsKey(selectProduct)){
                otherProductRender = otherProductMapByProduct.get(selectDivision).get(selectProduct);
            }
        }

        if(selectProduct == 'None') {
            categoryDisabled = true;
        } else {
            categoryDisabled = false;
        }
        subCatagoryDisabled = true;
    }

    public void validateSelectCategory(){
        otherCategoryRender = false;
        otherSubCategoryRender = false;

        selectSubCategory = 'None';

        issueLog.Category_Specify__c = '';
        issueLog.Sub_Category_Specify__c = '';

        if(otherCatMapByCat.containsKey(selectDivision)){
            if(otherCatMapByCat.get(selectDivision).containsKey(selectProduct)){
                if(otherCatMapByCat.get(selectDivision).get(selectProduct).containsKey(selectCategory)){
                    otherCategoryRender = otherCatMapByCat.get(selectDivision).get(selectProduct).get(selectCategory);
                }
            }
        }

        getSubCategoryList();
        System.debug('subCategoryCount>>>>'+subCategoryCount);
        if(selectCategory == 'None' || subCategoryCount <= 1){
            subCatagoryDisabled = true;
        }
        else{
            subCatagoryDisabled = false;
        }
    }
    public void validataSelectSubCategory(){
        otherSubCategoryRender = false;

        issueLog.Sub_Category_Specify__c = '';

        if(otherSubCatMapBySubCat.containsKey(selectDivision)){
            if(otherSubCatMapBySubCat.get(selectDivision).containsKey(selectProduct)){
                if(otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).containsKey(selectCategory)){
                    if(otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).get(selectCategory).containsKey(selectSubCategory)){
                        otherSubCategoryRender = otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).get(selectCategory).get(selectSubCategory);
                    }                   
                }
            }
        }
    }
}