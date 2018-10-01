public with sharing class CBS_NewIssueLog_Controller {
	private static final String LV3PREFIX = 'LV3PREFIX';
	public Issue_Log__c issueLog {get;set;}
	public Issue_Log__c parentIssue {get;set;}
    public Account selectAccount {get;set;}
    
    private Map<String, Map<String, Map<String, Map<String, Id>>>> issueMasterLv1234;
    public Map<Id, Issue_Master__c> issueMasterMap {get;set;}
    public String selectDivision {get;set;}
    public String selectProduct {get;set;}
    public String selectCategory {get;set;}
    public String selectSubCategory {get;set;}
    
    public String selectStatus {get;set;}
    public String accountId {get;set;}
    public String callReportId {get;set;}
    public String opportunityId {get;set;}

    public Boolean hasEditAccount {get;set;}
    public Boolean hasEditCallReport {get;set;}
    public Boolean hasEditOpportunity {get;set;}

    public Boolean closeDateRender {get;set;}

    public Map<String,Map<String,Boolean>> otherProductMapByProduct;
    public Map<String,Map<String,Map<String,Boolean>>> otherCatMapByCat;
    public Map<String,Map<String,Map<String,Map<String,Boolean>>>> otherSubCatMapBySubCat;
    public Boolean otherProductRender {get;set;}
    public Boolean otherCategoryRender {get;set;}
    public Boolean otherSubCategoryRender {get;set;}

    public Boolean productDisabled {get;set;}
    public Boolean categoryDisabled {get;set;}
    public Integer subCategoryCount;
    public Boolean subCatagoryDisabled {get;set;}

    public Boolean isChildIssue {get;set;}

    public Boolean reOpenReasonRender {get;set;}

    public String divisionHelpText{get;set;}

    public String statusHelpText{get;set;}

	public CBS_NewIssueLog_Controller(ApexPages.StandardController stdController) {
		this.issueLog = (Issue_Log__c)stdController.getRecord();
		init();
	}

	private void init() {

		isChildIssue = false;
		closeDateRender = false;
		otherProductRender = false;
		otherCategoryRender =  false;
		otherSubCategoryRender = false;

		reOpenReasonRender = false;

		productDisabled = true;
		categoryDisabled = true;
		subCategoryCount = 0;
		subCatagoryDisabled = true;

		selectDivision = 'None';
		selectProduct = 'None';
		selectCategory = 'None';
		selectSubCategory = 'None';

		divisionHelpText = '';
		statusHelpText = '';

		accountId = ApexPages.currentPage().getParameters().get('accountId');
		callReportId = ApexPages.currentPage().getParameters().get('callReportId');
		opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');

		hasEditCallReport = ApexPages.currentPage().getParameters().containsKey('callReportId');
		hasEditOpportunity = ApexPages.currentPage().getParameters().containsKey('opportunityId');

		isChildIssue = ApexPages.currentPage().getParameters().containsKey('parentId');

		if(isChildIssue){
			String parentId = ApexPages.currentPage().getParameters().get('parentId');
			this.parentIssue = [SELECT Id, Subject__c, Issue_Description__c, Issue_Master__c, CIS_ID_or_Prospect_Name__c, Call_Plan_Call_Report__c, Opportunity__c, Division_Formula__c, Product_Formula__c, Product_Text__c, Category_Formula__c, Category_Specify__c,  Sub_Category_Formula__c, Sub_Category_Specify__c FROM Issue_Log__c WHERE Id = :parentId];
			this.issueLog.Parent_Issue__c = parentId;
			this.issueLog.Subject__c = parentIssue.Subject__c;
			this.issueLog.Issue_Description__c = parentIssue.Issue_Description__c;
			this.issueLog.Issue_Master__c = parentIssue.Issue_Master__c;
			this.issueLog.CIS_ID_or_Prospect_Name__c = parentIssue.CIS_ID_or_Prospect_Name__c;
		}

		getIssueMaster();

		if(isChildIssue) {
			if(parentIssue.Call_Plan_Call_Report__c != null) {
				hasEditCallReport = true;
				this.issueLog.Call_Plan_Call_Report__c = parentIssue.Call_Plan_Call_Report__c;
			}
			if(parentIssue.Opportunity__c != null) {
				hasEditOpportunity = true;
				this.issueLog.Opportunity__c = parentIssue.Opportunity__c;
			}


			selectDivision = parentIssue.Division_Formula__c;
			validateSelectDivision();
			selectProduct = parentIssue.Product_Formula__c;
			validateSelectProduct();
			this.issueLog.Product_Text__c = parentIssue.Product_Text__c;
			selectCategory = parentIssue.Category_Formula__c;
			validateSelectCategory();
			this.issueLog.Category_Specify__c = parentIssue.Category_Specify__c;
			selectSubCategory = parentIssue.Sub_Category_Formula__c;
			validataSelectSubCategory();
			this.issueLog.Sub_Category_Specify__c = parentIssue.Sub_Category_Specify__c;

			reOpenReasonRender = true;
		}

		if(accountId != null) {
			selectAccount = [SELECT Id, Name, Name_TH__c, Group__c, Sub_Group__c FROM Account WHERE Id = :accountId];
			this.issueLog.CIS_ID_or_Prospect_Name__c = selectAccount.Id;
		} else {
			selectAccount = new Account();
		}

		if(callReportId != null) {
			this.issueLog.Call_Plan_Call_Report__c = callReportId;
		}

		if(opportunityId != null) {
			this.issueLog.Opportunity__c = opportunityId;
		}
		this.issueLog.Date_Time_Opened__c = System.now();

		selectStatus = GlobalConstants.STATUS_NEW;
	}

	public void updateSelectAccount() {
		try {
			selectAccount = IssueLog_Service.getSelectAccount(this.issueLog.CIS_ID_or_Prospect_Name__c);    
		} catch (Exception e) {
		    showError(e.getMessage());
		}
	}

	public List<SelectOption> getStatusList() {
		List<SelectOption> statusList = new List<SelectOption>();
		statusList.add(new SelectOption(GlobalConstants.STATUS_NEW, GlobalConstants.STATUS_NEW));
		statusList.add(new SelectOption(GlobalConstants.STATUS_DONE, GlobalConstants.STATUS_DONE));
		return statusList;
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
    	if(categoryList.size()>1){
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

	public void getIssueMaster() {
		issueMasterMap = new Map<Id, Issue_Master__c>([SELECT Id, Division__c, Product__c, Category__c, Sub_Category__c, Required_Product__c, Require_Category__c, Require_Sub_Category__c,Assigned_To__c,Assign_To_Internal_User__c,Assign_To_Non_User__c FROM Issue_Master__c WHERE Active__c = true OR id = :this.issueLog.Issue_Master__c ]);
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

			if(!otherProductMapByProduct.containsKey(eachIssueMaster.Division__c)){
				otherProductMapByProduct.put(eachIssueMaster.Division__c, new Map<String, Boolean>());
			}
			Map<String, Boolean> lv2RequireProduct = otherProductMapByProduct.get(eachIssueMaster.Division__c);
			if(!lv2RequireProduct.containsKey(eachIssueMaster.Product__c)){
				lv2RequireProduct.put(eachIssueMaster.Product__c, eachIssueMaster.Required_Product__c);
			}

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

	public PageReference cancel(){
		String perentId = ApexPages.currentPage().getParameters().get('parentId');
		PageReference pageRef = new PageReference('/' + perentId);
		return pageRef;
	}

	public PageReference save() {
		try {
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

			if(selectStatus == GlobalConstants.STATUS_DONE){
				issueLog.Status__c = selectStatus;
				Datetime startDate = issueLog.Date_Time_Opened__c;
				Datetime closeDate = issueLog.Date_Time_Closed__c;
				if(startDate >= closeDate){
					throw new IssueLogException(Label.Start_Date_End_Date);
				}
				if(startDate==null||closeDate==null){
					throw new IssueLogException(Label.Input_Start_Date_Close_Date);
				}
				if(startDate>System.now()||closeDate>System.now()){
					throw new IssueLogException(Label.Start_Date_End_Date_not_beyond);
				}
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

				if(issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c != null){
					User currentUser = [SELECT Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

					List<String> assignToList = new List<String>();
					assignToList = issueMasterMap.get(issueLog.Issue_Master__c).Assigned_To__c.split(';');
					for(String eachAssignTo: assignToList){
						if(eachAssignTo == 'SP' || eachAssignTo == 'SC'){
							issueLog.Assigned_Internal_Lookup__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Internal_User__c;
							if(selectStatus == GlobalConstants.STATUS_DONE){
								issueLog.Status__c = selectStatus;
							}
							else{
								issueLog.Status__c = 'On process by ' + eachAssignTo;
							}						
						} else if(eachAssignTo == 'TL' || eachAssignTo == 'FSVP'){
							if(currentUser.Profile.Name == GlobalConstants.CBS_FSVP){
								issueLog.Assigned_Internal_Lookup__c = currentUser.Id;
								if(selectStatus == GlobalConstants.STATUS_DONE){
									issueLog.Status__c = selectStatus;
								}
								else{
									issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
								}							
							} else {
								if(IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_TL) != null) {
									issueLog.Assigned_Internal_Lookup__c = IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_TL);
									if(selectStatus == GlobalConstants.STATUS_DONE){
										issueLog.Status__c = selectStatus;
									}
									else{
										issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_TL;
									}								
								} else if(IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_FSVP) != null){
									issueLog.Assigned_Internal_Lookup__c = IssueLog_Service.getManagerFromUserWithManagerProfile(currentUser, GlobalConstants.CBS_FSVP);
									if(selectStatus == GlobalConstants.STATUS_DONE){
										issueLog.Status__c = selectStatus;
									}
									else{
										issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
									}								
								}
							}
								
						} else if(eachAssignTo == 'PM'){
							issueLog.Assigned_Team_Person_Text__c = issueMasterMap.get(issueLog.Issue_Master__c).Assign_To_Non_User__c;
							if(selectStatus == GlobalConstants.STATUS_DONE){
								issueLog.Status__c = selectStatus;
							}
							else{
								issueLog.Status__c = GlobalConstants.ON_PROCESS_BY_PM;
							}
						}
					}
				}			
			}

			if(isChildIssue) {
				issueLog.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Issue_Log__c', GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			} else {
				issueLog.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Issue_Log__c', GlobalConstants.CBS_OPEN_ISSUE_NORMAL_REC);	
			}
			insert issueLog;

			PageReference pageRef = new PageReference('/' + issueLog.Id);
			return pageRef;
		} catch (Exception e) {
			showError(e.getMessage());
			return null;
		}
	}

	public void checkCloseDate(){
		closeDateRender = false;
		issueLog.Date_Time_Closed__c = null;
		if(selectStatus == GlobalConstants.STATUS_DONE){
			closeDateRender = true;
		}
		renderStatusHelpText();
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

	public void showError (String errorMsg) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
	    ApexPages.addMessage(msg);
	}

	public class IssueLogException extends Exception{}
}