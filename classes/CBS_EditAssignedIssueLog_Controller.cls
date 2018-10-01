public with sharing class CBS_EditAssignedIssueLog_Controller {
    private static final String LV3PREFIX = 'LV3PREFIX';

    private User currentUser;

    public Boolean showEscalate {get;set;}
    public Boolean showReAssign {get;set;}
    public Boolean showReject {get;set;}
    public Boolean disableReAssignName{get;set;}

	public Issue_Log__c issueLog {get;set;}

    public Map<Id, Issue_Master__c> issueMasterMap {get;set;}

	public String selectReassignTo{get;set;}
    public String selectReassignName{get;set;}
    public String selectStatus {get;set;}
    public String reassignReasonTextArea {get;set;}
    
    private List<GroupMember> groupMembers;
    private Map<String,Set<Id>> groupNameAndItsMembers;
    private Map<Id, User> userMap;

    public List<SelectOption> statusList {get;set;}
    public String statusHelpText {get;set;}
    
    List<CBS_Issue_Log_Management__c> cbsIssueLogManagements;
    private Map<String, Map<String, Map<String, Map<String, Id>>>> issueMasterLv1234;
    public String selectDivision {get;set;}
    public String selectProduct {get;set;}
    public String selectCategory {get;set;}
    public String selectSubCategory {get;set;}

    public Boolean productDisabled {get;set;}
    public Boolean categoryDisabled {get;set;}
    public Boolean subCatagoryDisabled {get;set;}
    public Integer subCategoryCount;

    public Map<String,Map<String,Boolean>> otherProductMapByProduct;
    public Map<String,Map<String,Map<String,Boolean>>> otherCatMapByCat;
    public Map<String,Map<String,Map<String,Map<String,Boolean>>>> otherSubCatMapBySubCat;
    public Boolean otherProductRender {get;set;}
    public Boolean otherCategoryRender {get;set;}
    public Boolean otherSubCategoryRender {get;set;}

    public Boolean renderForAdmin {get;set;}

    public String divisionHelpText {get;set;}

    public CBS_EditAssignedIssueLog_Controller(ApexPages.StandardController stdController) {
        this.issueLog = (Issue_Log__c)stdController.getRecord();
        this.issueLog = [SELECT Id, Subject__c, Name, Parent_Issue__c, IsParentIssue__c, Date_Time_Opened__c, Date_Time_Closed__c, Status__c, Time_Used_Days__c, CIS_ID_or_Prospect_Name__c, CIS_ID_or_Prospect_Name__r.Name, CIS_ID_or_Prospect_Name__r.Name_TH__c, Group__c, Sub_Group__c, OwnerId, Assigned_Team_Person__c, Assigned_Internal_Lookup__c, IssueLog_Creator__c, Issue_Log_Creator_Phone__c, IssueLog_Creator_TL__c,IssueLog_Creator_TL__r.Name,Issue_Log_Creator_TL_Phone__c, IssueLog_Creator_FSVP__c,IssueLog_Creator_FSVP__r.Name, Issue_Log_Creator_FSVP_Phone__c, Division_Formula__c, Product_Formula__c, Product_Text__c, Category_Formula__c, Category_Specify__c, Sub_Category_Formula__c, Sub_Category_Specify__c, Issue_Description__c, Progress_Solution__c, Call_Plan_Call_Report__c, Opportunity__c, Re_Open_Reason__c, Reject_Reason__c, Owner.Profile.Name, Issue_Master__c,Re_Assign_Reason__c, Issue_Log_Owner__c, Need_Long_Term_Solution__c FROM Issue_Log__c WHERE Id = :issueLog.Id];
        init();
    }

    private void init() {
        groupNameAndItsMembers = new Map<String,Set<Id>>();
        issueMasterMap = new Map<Id, Issue_Master__c>([SELECT Id, Available_Closed_Status__c, Division__c, Product__c, Category__c, Sub_Category__c, Required_Product__c, Require_Category__c, Require_Sub_Category__c,Assigned_To__c,Assign_To_Internal_User__c,Assign_To_Non_User__c FROM Issue_Master__c]);
        currentUser = [SELECT Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name,Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        cbsIssueLogManagements = [SELECT Name FROM CBS_Issue_Log_Management__c];

        this.selectReassignTo = GlobalConstants.CBS_TL;
        this.selectStatus = this.issueLog.Status__c;

        reassignReasonTextArea = '';
        showEscalate = false;
        showReAssign = false;
        showReject = false;
        disableReAssignName = true;
        //isReAssignNameRequire = 'none';

        getGroupMember();
        statusList = new List<SelectOption>();
        statusList = getStatusList();
        statusList.add(new SelectOption(this.selectStatus, this.selectStatus));

        Boolean isInNHTLGroup = false;
        if(currentUser.Employee_ID__c != null){
            isInNHTLGroup = checkUserManagement(currentUser.Employee_ID__c);
        }

        if(this.issueLog.Assigned_Internal_Lookup__c == currentUser.Id) {
            showReject = true;
        }
        //if(this.currentUser.Profile.Name == GlobalConstants.CBS_TL || this.currentUser.Profile.Name == GlobalConstants.CBS_NHTL) {
        //if(this.currentUser.Profile.Name == GlobalConstants.CBS_TL || this.currentUser.Profile.Name == GlobalConstants.SME_NH) {
        if(this.currentUser.Profile.Name == GlobalConstants.CBS_TL || isInNHTLGroup) {
            showEscalate = true;
        }

        renderForAdmin = false;

        if(this.currentUser.Profile.Name == GlobalConstants.CBS_ADMIN || this.currentUser.Profile.Name == GlobalConstants.CBS_SC ||(this.groupNameAndItsMembers.containsKey(GlobalConstants.GROUP_CBS_SC) && this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SC).contains(currentUser.Id))) {
            showReAssign = true;

            renderForAdmin = true;
        }
        getIssueMaster();

        this.selectDivision = this.issueLog.Division_Formula__c;
        this.selectProduct = this.issueLog.Product_Formula__c;
        this.selectCategory = this.issueLog.Category_Formula__c;
        this.selectSubCategory = this.issueLog.Sub_Category_Formula__c;
        this.selectStatus = this.issueLog.Status__c;
        validateAllSelectedIssueMaster();

        statusHelpText = '';
        divisionHelpText = '';
        renderStatusHelpText();
        renderDivisionHelpText();
    }

    public Boolean checkUserManagement(String emp_Id){
        Boolean isNHTL = false;
        List<User_Mirror_Management__c> userMM = [SELECT Employee_ID__c,Employee_Name__c,Mirror_Type__c,Mirror_Value__c,User_Value__c FROM User_Mirror_Management__c WHERE Employee_ID__c = :emp_Id];
        if(userMM.size() == 1){
            isNHTL = true;
            return isNHTL;
        }
        else{
            return isNHTL;
        }        
    }

    private void getGroupMember() {
        Set<String>cbsServicePublicGroupNames = new Set<String>{GlobalConstants.GROUP_CBS_SP, GlobalConstants.GROUP_CBS_SC};   
        this.groupMembers = [SELECT GroupId,Id,UserOrGroupId,Group.Name FROM GroupMember WHERE Group.Name IN :cbsServicePublicGroupNames];
        Set<Id> userIds = new Set<Id>();
        for(GroupMember eachMember : groupMembers) {
            userIds.add(eachMember.UserOrGroupId);
        }
        userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);

        this.groupNameAndItsMembers = new Map<String,Set<Id>>();
        for(GroupMember groupMember : this.groupMembers) {
            if(!this.groupNameAndItsMembers.containsKey(groupMember.Group.Name)){
                this.groupNameAndItsMembers.put(groupMember.Group.Name, new Set<Id>());
            }
            this.groupNameAndItsMembers.get(groupMember.Group.Name).add(groupMember.UserOrGroupId);
        }
    }

    public List<SelectOption> getReAssignToList() {
        List<SelectOption> reAssignToList = new List<SelectOption>();        
        reAssignToList.add(new SelectOption(GlobalConstants.CBS_TL,'TL'));
        reAssignToList.add(new SelectOption(GlobalConstants.CBS_FSVP,'FSVP'));
        reAssignToList.add(new SelectOption(GlobalConstants.CBS_SC,'SC'));
        reAssignToList.add(new SelectOption(GlobalConstants.CBS_SP,'SP'));
        reAssignToList.add(new SelectOption(GlobalConstants.CBS_PM,'PM'));
        return reAssignToList;
    }

    public List<SelectOption> getReAssignNameList(){
        List<SelectOption> reAssignNameList = new List<SelectOption>();
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
            if(!this.groupNameAndItsMembers.isEmpty() && this.groupNameAndItsMembers.containsKey(GlobalConstants.GROUP_CBS_SC)){
                for(Id groupMemberId : this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SC)){
                    if(userMap.containsKey(groupMemberId)) {
                        reAssignNameList.add(new SelectOption(groupMemberId, userMap.get(groupMemberId).Name));
                    }
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
            
        }else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_SP)){
            if(!this.groupNameAndItsMembers.isEmpty() && this.groupNameAndItsMembers.containsKey(GlobalConstants.GROUP_CBS_SP)){
                for(Id groupMemberId : this.groupNameAndItsMembers.get(GlobalConstants.GROUP_CBS_SP)){
                    if(userMap.containsKey(groupMemberId)) {
                        reAssignNameList.add(new SelectOption(groupMemberId, userMap.get(groupMemberId).Name));
                    }
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
        }
        else if(this.selectReassignTo.equalsIgnoreCase(GlobalConstants.CBS_PM)){
            if(!this.cbsIssueLogManagements.isEmpty()){
                for(CBS_Issue_Log_Management__c cbsIssueLogManagement:this.cbsIssueLogManagements){
                    reAssignNameList.add(new SelectOption(cbsIssueLogManagement.Name, cbsIssueLogManagement.Name));
                }
                this.disableReAssignName = false;
            }else{
                this.disableReAssignName = true;
            }
        }
        return reAssignNameList;
    }

    public List<SelectOption> getStatusList() {
        
        if(issueMasterMap.containsKey(this.issueLog.Issue_Master__c)) {
            List<String> closeStatus = new List<String>();
            closeStatus = (issueMasterMap.get(this.issueLog.Issue_Master__c).Available_Closed_Status__c).split(';');
            for(String eachStatus : closeStatus) {
                statusList.add(new SelectOption(eachStatus, eachStatus));
            }
        }
        return statusList;
    }

    public PageReference save() {
        this.issueLog.Status__c = this.selectStatus;
        if(renderForAdmin){
            //this.issueLog.Assigned_Internal_Lookup__c = null;
            //this.issueLog.Assigned_Team_Person_Text__c = null;
            if(selectDivision != null && selectDivision != 'None' && selectProduct != null && selectProduct != 'None' && selectCategory != null && selectCategory != 'None') {
                if(issueMasterLv1234.containsKey(selectDivision) && 
                    issueMasterLv1234.get(selectDivision).containsKey(selectProduct) && 
                    issueMasterLv1234.get(selectDivision).get(selectProduct).containsKey(selectCategory)) {
                    if(selectSubCategory != null && selectSubCategory != 'None' && issueMasterLv1234.get(selectDivision).get(selectProduct).get(selectCategory).containsKey(selectSubCategory)) {
                        issueLog.Issue_Master__c = issueMasterLv1234.get(selectDivision).get(selectProduct).get(selectCategory).get(selectSubCategory); 
                    } else if(issueMasterLv1234.get(selectDivision).get(selectProduct).get(selectCategory).containsKey(LV3PREFIX + selectCategory)) {
                        issueLog.Issue_Master__c = issueMasterLv1234.get(selectDivision).get(selectProduct).get(selectCategory).get(LV3PREFIX + selectCategory);    
                    } else {
                        throw new IssueLogException(Label.Have_to_select_sub_category);
                    }
                } else {
                    throw new IssueLogException(Label.Division_Product_Category_Sub_Category);
                }
            } else {
                throw new IssueLogException(Label.Select_Division_Product_Category_Sub_Category);
            }
            if(issueLog.Issue_Master__c != null && issueMasterMap.containsKey(issueLog.Issue_Master__c)) {
                if(issueMasterMap.get(issueLog.Issue_Master__c).Required_Product__c && String.isBlank(issueLog.Product_Text__c)) {
                    throw new IssueLogException(Label.CBSIssueLog_RequiredOtherProduct);
                }

                if(issueMasterMap.get(issueLog.Issue_Master__c).Require_Category__c && String.isBlank(issueLog.Category_Specify__c)) {
                    throw new IssueLogException(Label.CBSIssueLog_RequiredOtherCategory);
                }

                if(issueMasterMap.get(issueLog.Issue_Master__c).Require_Sub_Category__c && String.isBlank(issueLog.Sub_Category_Specify__c)) {
                    throw new IssueLogException(Label.CBSIssueLog_RequiredOtherSubCategory);
                }
      
                if(issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c != null && shouldReassign()){
                    User issueCreatorUser = [SELECT Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name FROM User WHERE Id = :issueLog.IssueLog_Creator__c LIMIT 1];
                    List<String> assignToList = new List<String>();
                    assignToList = issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c.split(';');
                    for(String eachAssignTo: assignToList){
                        if(eachAssignTo == 'SP' || eachAssignTo == 'SC'){
                            issueLog.Assigned_Internal_Lookup__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Internal_User__c;
                            if(selectStatus == GlobalConstants.STATUS_DONE || selectStatus == GlobalConstants.STATUS_CLOSED){
                                issueLog.Status__c = selectStatus;
                            }
                            else{
                                issueLog.Status__c = 'On process by ' + eachAssignTo;
                            }                       
                        } else if(eachAssignTo == 'TL' || eachAssignTo == 'FSVP'){
                            
                            if(issueCreatorUser.Profile.Name == GlobalConstants.CBS_FSVP || issueCreatorUser.Profile.Name == GlobalConstants.CBS_TL || issueCreatorUser.Profile.Name == GlobalConstants.SME_NH){
                                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
                                issueLog.Assigned_Internal_Lookup__c = issueLog.IssueLog_Creator_FSVP__c;
                            }
                            else if(issueCreatorUser.Profile.Name == GlobalConstants.CBS_RM){
                                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_TL;
                                issueLog.Assigned_Internal_Lookup__c = issueLog.IssueLog_Creator_TL__c;
                            } 
                            if(selectStatus == GlobalConstants.STATUS_DONE || selectStatus == GlobalConstants.STATUS_CLOSED){
                                issueLog.Status__c = selectStatus;
                            } 
                            
                        } else if(eachAssignTo == 'PM'){
                            //issueLog.Assigned_Team_Person_Text__c = eachAssignTo;
                            issueLog.Assigned_Internal_Lookup__c = null;
                            issueLog.Assigned_Team_Person_Text__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Non_User__c;
                            if(selectStatus == GlobalConstants.STATUS_DONE || selectStatus == GlobalConstants.STATUS_CLOSED){
                                issueLog.Status__c = selectStatus;
                            }
                            else{
                                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_PM;
                            }
                        }
                    }
                }
            }
        }

        update this.issueLog;
        
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    private Boolean shouldReassign(){
        Boolean reassign = false;
        if(this.selectDivision != this.issueLog.Division_Formula__c  ||
            this.selectProduct != this.issueLog.Product_Formula__c   ||
            this.selectCategory != this.issueLog.Category_Formula__c ||
            this.selectSubCategory != this.issueLog.Sub_Category_Formula__c
            ){
            reassign = true;
        }   

        return reassign;
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

    public PageReference rejectIssue() {
        this.selectStatus = GlobalConstants.REJECTED;
        this.issueLog.Status__c = this.selectStatus;
        update this.issueLog;

        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }
    
    public PageReference doSaveReAssign(){
        this.issueLog.Assigned_Team_Person_Text__c = null;
        this.issueLog.Assigned_Internal_Lookup__c = null;
        this.issueLog.Re_Assign_Reason__c = this.reassignReasonTextArea;
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
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public void showError (String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public class IssueLogException extends Exception{}

    public void clearReassignValue(){
        
    }
    public void renderStatusHelpText(){
        if(selectStatus == GlobalConstants.STATUS_NEW){
            statusHelpText = '';
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_DONE){
            statusHelpText = Label.CBSIssueLog_Status_Done;
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_CLOSE){
            statusHelpText = Label.CBSIssueLog_Status_Closed;
        }
        else{
            statusHelpText = '';
        }
    }

    public void getIssueMaster() {

        issueMasterMap = new Map<Id, Issue_Master__c>([SELECT Id, Available_Closed_Status__c, Division__c, Product__c, Category__c, Sub_Category__c, Required_Product__c, Require_Category__c, Require_Sub_Category__c,Assigned_To__c,Assign_To_Internal_User__c,Assign_To_Non_User__c FROM Issue_Master__c WHERE Active__c = true OR id = :this.issueLog.Issue_Master__c]);
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

    public List<SelectOption> getDivisionList() {
        List<SelectOption> divisionList = new List<SelectOption>();
        List<SelectOption> tempDivisionList = new List<SelectOption>();
        divisionList.add(new SelectOption('None', 'Please select......'));
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
        productList.add(new SelectOption('None', 'Please select......'));
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
        categoryList.add(new SelectOption('None', 'Please select......'));
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
        subCategoryList.add(new SelectOption('None', 'Please select......'));
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
    public void validateSelectDivision() {
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
    private void validateAllSelectedIssueMaster() {
        otherProductRender = false;
        otherCategoryRender = false;
        otherSubCategoryRender = false;

        if(otherSubCatMapBySubCat.containsKey(selectDivision)){
            if(otherSubCatMapBySubCat.get(selectDivision).containsKey(selectProduct)){
                // Product
                otherProductRender = otherProductMapByProduct.get(selectDivision).get(selectProduct);
                if(otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).containsKey(selectCategory)){
                    // Cat
                    otherCategoryRender = otherCatMapByCat.get(selectDivision).get(selectProduct).get(selectCategory);
                    if(otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).get(selectCategory).containsKey(selectSubCategory)){
                        // Sub Cat
                        otherSubCategoryRender = otherSubCatMapBySubCat.get(selectDivision).get(selectProduct).get(selectCategory).get(selectSubCategory);
                    }                   
                }
            }
        }
        getSubCategoryList();
        productDisabled = (selectDivision == 'None');
        categoryDisabled = (selectProduct == 'None');
        subCatagoryDisabled = (selectCategory == 'None' || subCategoryCount <= 1);
    }
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
}