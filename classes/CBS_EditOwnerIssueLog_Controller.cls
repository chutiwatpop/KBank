public with sharing class CBS_EditOwnerIssueLog_Controller {
    private static final String LV3PREFIX = 'LV3PREFIX';

	public Issue_Log__c issueLog {get;set;}
    private User currentUser;

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
    public List<SelectOption> statusList{get;set;}
    public String selectStatus {get;set;}
    public String statusHelpText {get;set;}

    public String divisionHelpText{get;set;}
    
    private Map<String,User>usersMap;
    public Boolean disableReAssignName{get;set;}
    List<CBS_Issue_Log_Management__c>cbsIssueLogManagements;

    public CBS_EditOwnerIssueLog_Controller(ApexPages.StandardController stdController) {
        this.issueLog = (Issue_Log__c)stdController.getRecord();
        this.issueLog = [SELECT Id, Subject__c, Name, Parent_Issue__c, IsParentIssue__c, Date_Time_Opened__c, Date_Time_Closed__c, Status__c, Time_Used_Days__c, CIS_ID_or_Prospect_Name__c, CIS_ID_or_Prospect_Name__r.Name, CIS_ID_or_Prospect_Name__r.Name_TH__c, Group__c, Sub_Group__c, OwnerId, Assigned_Team_Person__c, IssueLog_Creator__c, Issue_Log_Creator_Phone__c, IssueLog_Creator_TL__c,IssueLog_Creator_TL__r.Name,Issue_Log_Creator_TL_Phone__c, IssueLog_Creator_FSVP__c,IssueLog_Creator_FSVP__r.Name, Issue_Log_Creator_FSVP_Phone__c, Division_Formula__c, Product_Formula__c, Product_Text__c, Category_Formula__c, Category_Specify__c, Sub_Category_Formula__c, Sub_Category_Specify__c, Issue_Description__c, Progress_Solution__c, Call_Plan_Call_Report__c, Opportunity__c, Re_Open_Reason__c, Reject_Reason__c, Owner.Profile.Name, Issue_Master__c,Re_Assign_Reason__c, Issue_Log_Owner__c, Need_Long_Term_Solution__c FROM Issue_Log__c WHERE Id = :issueLog.Id];
        init();
    }

    private void init() {
        getIssueMaster();
        currentUser = [SELECT Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        this.selectDivision = this.issueLog.Division_Formula__c;
        this.selectProduct = this.issueLog.Product_Formula__c;
        this.selectCategory = this.issueLog.Category_Formula__c;
        this.selectSubCategory = this.issueLog.Sub_Category_Formula__c;
        this.selectStatus = this.issueLog.Status__c;
        validateAllSelectedIssueMaster();

        divisionHelpText = '';
        statusHelpText = '';

        statusList = new List<SelectOption>();
        statusList = getStatusList();

        renderDivisionHelpText();
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

    //Version 2
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

    public PageReference saveSubmit(){
        // Update Status to On Process by 'Role of Assigned User'
        try {
            if(selectStatus == GlobalConstants.STATUS_DONE) {
                throw new IssueLogException('ไม่ให้ Done ตอน Submit');
            }
            String issueMasterID = getSelectIssueMaster();
            this.issueLog.Issue_Master__c = issueMasterID;
            this.issueLog.IsSaveDraft__c = false;

            getIssueAssignedUser();
            
            update this.issueLog;
        } catch (Exception e) {
            showError(e.getMessage());
            return null;
        }

        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public PageReference saveDraft(){
        // Update Status to On Process by 'Role of Assigned User'
        try {
            String issueMasterID = getSelectIssueMaster();
            String assignTo = issueMasterMap.get(issueMasterID).Assigned_To__c;
            this.issueLog.Issue_Master__c = issueMasterID;
            getIssueAssignedUser();
            if(selectStatus == GlobalConstants.STATUS_DONE) {
                this.issueLog.IsSaveDraft__c = false;
                update this.issueLog;
            } else {
                this.issueLog.IsSaveDraft__c = true;
                this.issueLog.Status__c = GlobalConstants.RECALLED;
                update this.issueLog;
            }
        } catch (Exception e) {
            showError(e.getMessage());
            return null;
        }
        
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public List<SelectOption> getStatusList() {
        statusList.add(new SelectOption(this.selectStatus, this.selectStatus));
        statusList.add(new SelectOption(GlobalConstants.STATUS_DONE, GlobalConstants.STATUS_DONE));

        return statusList;
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

    private void getIssueAssignedUser() {
        if(issueMasterMap.containsKey(issueLog.Issue_Master__c) && issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c != null){
            issueLog.Assigned_Internal_Lookup__c = null;
            issueLog.Assigned_Team_Person_Text__c = null;

            List<String> assignToList = issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c.split(';');
            Set<String> assignToSet = new Set<String>(assignToList);

            if(assignToSet.contains('SP')) {
                issueLog.Assigned_Internal_Lookup__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Internal_User__c;
                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_SP;
            } else if(assignToSet.contains('SC')) {
                issueLog.Assigned_Internal_Lookup__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Internal_User__c;
                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_SC;
            } else if(assignToSet.contains('PM')) {
                issueLog.Assigned_Team_Person_Text__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Non_User__c;
                issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_PM;
            } else if(assignToSet.contains('TL') || assignToSet.contains('FSVP')) {
                if(currentUser.Profile.Name == GlobalConstants.CBS_FSVP){
                    issueLog.Assigned_Internal_Lookup__c = currentUser.Id;
                    issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
                } else {
                    if(IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_TL) != null) {
                        issueLog.Assigned_Internal_Lookup__c = IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_TL);
                        issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_TL;
                    } else if(IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_FSVP) != null){
                        issueLog.Assigned_Internal_Lookup__c = IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_FSVP);
                        issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
                    }
                }
            }
            if(selectStatus == GlobalConstants.STATUS_DONE){
                issueLog.Status__c = selectStatus;
            }
        } else {
            throw new IssueLogException('Cannot find Assign To for issue master : ' + issueLog.Issue_Master__c);
        }
    }

    public void showError (String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public class IssueLogException extends Exception{}
}