public without sharing class Account_ReferOutInformation_Controller {
	public Boolean isSF1 {
		get{
			String UItheme = UserInfo.getUiThemeDisplayed();
	        if (UItheme == 'Theme4t') {
	            return true;
	        }else{
	            return false;
	        }
		} set;
	}

	private String ON_GOING_RECORD_TYPE_ID;
	public Customer_Ownership_Request__c mysObject {get; set;}
	public List<SelectOption> provinceList = new List<SelectOption>();
	public List<SelectOption> teamList = new List<SelectOption>();
	public String selectedProvince {get; set;}
	public String selectedTeam {get; set;}
	public Boolean disabledFlag {get; set;}
	public List<String> bkkHubList {get; set;}
	
	public Account accountRefer {get; set;}
	private ApexPages.StandardController stdController;

	private static final String SELECT_NONE = ' - ';

	public Account_ReferOutInformation_Controller(ApexPages.StandardController stdCtrl) {
		this.ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		this.stdController = stdCtrl;
		this.mysObject = (Customer_Ownership_Request__c) stdCtrl.getRecord();

		if (this.mysObject != null && this.mysObject.Id != null){
			this.mysObject = [SELECT Id, CIS_ID__c,Refer_Out_Reason__c, Request_Type__c, Requested_Date__c, Refer_Out_Team__c, Refer_Out_Province__c,Percent_Shareholder__c,Language__c FROM Customer_Ownership_Request__c WHERE Id = :this.mysObject.Id];
		}
		init();
	}

	private void init() {
		this.mysObject.Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP;
		this.mysObject.Requested_Date__c = System.today();
		this.bkkHubList = new List<String>(GlobalConstants.CBS_BKK_HUBLIST);
		if (this.mysObject.CIS_ID__c == null)
			this.mysObject.CIS_ID__c = ApexPages.currentPage().getParameters().get('cisID');
		
		accountRefer = [Select ID,OwnerId,Owner.Segment__c,Customer_s_Business_Code__c,Sales_Size__c  from account where id =:this.mysObject.CIS_ID__c ][0];

		if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(accountRefer.Owner.Segment__c)){
			this.mysObject.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Customer_Ownership_Request__c', GlobalConstants.RELEASE_OWNERSHIP_DEVNAME_CBS);
		}else{
			this.mysObject.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Customer_Ownership_Request__c', GlobalConstants.RELEASE_OWNERSHIP_DEVNAME);
		}
		
		disabledFlag = true;
		getSelectedProvince();
		getSelectedTeam();
			
	}
	
	public void checkReasonCondition(){
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedReason = customerOwnerShip.Refer_Out_Reason__c;
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		disabledFlag = true;
		if(selectedReason == GlobalConstants.REASON_OTHER_TEAM || selectedReason == GlobalConstants.REASON_WRONG_AREA ){
			selectedProvince = SELECT_NONE;
			selectedTeam = SELECT_NONE;
			if(isSelectSegment(selectedRefSegment)){
				disabledFlag = false;
			}
		}else if(selectedReason == GlobalConstants.REASON_NOT_SME || selectedReason == GlobalConstants.REASON_NATIONALITY || selectedReason == GlobalConstants.REASON_NOT_CBS  || selectedReason == GlobalConstants.REASON_COMPANY_RELATED){
			
			disabledFlag = false;
		}else{
			disabledFlag = true;
			customerOwnerShip.Refer_Out_Segment__c = '';
		}
	}

	public void checkSegmentCondition(){
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		String selectedReason = customerOwnerShip.Refer_Out_Reason__c;
		if(isSelectSegment(selectedRefSegment)){
			disabledFlag = false;
			if(selectedReason == GlobalConstants.REASON_NOT_CBS || selectedReason == GlobalConstants.REASON_COMPANY_RELATED){
				disabledFlag = false;
				customerOwnerShip.Refer_Out_Province__c = null;
				customerOwnerShip.Refer_Out_Team__c = null;
				selectedProvince = SELECT_NONE;
				selectedTeam = SELECT_NONE;
			}
		}else if(selectedReason == GlobalConstants.REASON_NOT_SME || selectedReason == GlobalConstants.REASON_NATIONALITY){
			disabledFlag = false;
			selectedProvince = SELECT_NONE;
			selectedTeam = SELECT_NONE;

		}else{
			disabledFlag = true;
			selectedProvince = SELECT_NONE;
			selectedTeam = SELECT_NONE;
			getTeamList();
		}
	}

	public String getSelectedTeam() {
		if (selectedTeam == null && this.mysObject.Refer_Out_Team__c != null) {
			selectedTeam = this.mysObject.Refer_Out_Team__c;
		} else if (selectedTeam == null) {
			selectedTeam = SELECT_NONE;
		}
		return selectedTeam;
	}

	public String getSelectedProvince() {
		if (selectedProvince == null && this.mysObject.Refer_Out_Province__c != null) {
			selectedProvince = this.mysObject.Refer_Out_Province__c;
		} else if (selectedProvince == null) {
			selectedProvince = SELECT_NONE;
		}
		return selectedProvince;
	}

	public List<SelectOption> getProvinceList() {
		Set<String> provinceSet = new Set<String>();
		provinceList = new List<SelectOption>();
		teamList = new List<SelectOption>();
		List<Team_Province_Master_Data__c> provinceObjList = new List<Team_Province_Master_Data__c>();
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		String selectReason = customerOwnerShip.Refer_Out_Reason__c;

		if(isSelectSegment(selectedRefSegment) && (selectReason == GlobalConstants.REASON_OTHER_TEAM || selectReason == GlobalConstants.REASON_WRONG_AREA)){
			provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment ORDER BY Province_Name__c];
		}else if(selectReason == GlobalConstants.REASON_NOT_SME || selectReason == GlobalConstants.REASON_NATIONALITY){
			if(accountRefer.Sales_Size__c <= GlobalConstants.SEGMENT_CB_MAX_SALE_SIZE){
				provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :GlobalConstants.SEGMENT_CB  ORDER BY Province_Name__c];
			}else{
				provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :GlobalConstants.SEGMENT_MB ORDER BY Province_Name__c];
			}
		}else if(selectReason == GlobalConstants.REASON_NOT_CBS ){
			provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment ORDER BY Province_Name__c];
		}
		provinceList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
		for (Team_Province_Master_Data__c eachProvince : provinceObjList) {
			if (!provinceSet.contains(eachProvince.Province_Name__c)) {
				provinceSet.add(eachProvince.Province_Name__c);
				provinceList.add(new SelectOption(eachProvince.Province_Name__c, eachProvince.Province_Name__c));
			}
			teamList.add(new SelectOption(eachProvince.Team_Structure__c, eachProvince.Team_Structure__r.Name));
		}
		return provinceList;
	}

	public List<SelectOption> getTeamList() {
		teamList = new List<SelectOption>();
		Set<String> teamSet = new Set<String>();
		List<Team_Province_Master_Data__c> provinceObjList = new List<Team_Province_Master_Data__c>();
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectReason = customerOwnerShip.Refer_Out_Reason__c;
		String language = customerOwnerShip.Language__c;
		String percent_Shareholder = '';
		if(!GlobalConstants.CBS_SEGMENT_CODE_SET.contains(accountRefer.Owner.Segment__c)){
			percent_Shareholder = customerOwnerShip.Percent_Shareholder__c;
		}
		if(selectReason == GlobalConstants.REASON_NOT_SME || selectReason == GlobalConstants.REASON_NATIONALITY){
			if(accountRefer.Sales_Size__c <= GlobalConstants.SEGMENT_CB_MAX_SALE_SIZE){
				customerOwnerShip.Refer_Out_Segment__c = GlobalConstants.SEGMENT_CB;
			}else{
				customerOwnerShip.Refer_Out_Segment__c = GlobalConstants.SEGMENT_MB;
			}
		}
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;

		if(isSelectSegment(selectedRefSegment) && (selectReason == GlobalConstants.REASON_OTHER_TEAM || selectReason == GlobalConstants.REASON_WRONG_AREA || selectReason == GlobalConstants.REASON_NOT_CBS)){
			if (selectedProvince == SELECT_NONE || selectedProvince == null) {
				if(selectedRefSegment == GlobalConstants.SEGMENT_ME){
					provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment AND Team_Structure__r.External_id__c != '99999' AND Team_Structure__r.Name LIKE :(System.Label.Filter_ME_Team +'%') ORDER BY Team_Structure__r.Name];
				}else if(selectedRefSegment == GlobalConstants.SEGMENT_SE){
					provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment AND Team_Structure__r.External_id__c != '99999' AND Team_Structure__r.Name LIKE :(System.Label.Filter_SE_Team +'%') ORDER BY Team_Structure__r.Name];
				}else{
					provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment AND Team_Structure__r.External_id__c != '99999'  ORDER BY Team_Structure__r.Name];
				}
			} else {
				provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Province_Name__c = :selectedProvince AND Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment ORDER BY Team_Structure__r.Name];
			}

			teamList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
			for (Team_Province_Master_Data__c eachProvince : provinceObjList) {
				if (eachProvince.Team_Structure__c != null && !teamSet.contains(eachProvince.Team_Structure__r.Name)){
					teamSet.add(eachProvince.Team_Structure__r.Name);
					teamList.add(new SelectOption(eachProvince.Team_Structure__r.Name, eachProvince.Team_Structure__r.Name));
				}
			}
		}else if(selectReason == GlobalConstants.REASON_NOT_SME || selectReason == GlobalConstants.REASON_NATIONALITY){
			List<Team_Structure__c> cbsTeamlist = Ownership_Service.selectTeamReferOutSegment(percent_Shareholder,language,selectedProvince,accountRefer.Customer_s_Business_Code__c,accountRefer.Sales_Size__c);
			teamList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
			if(cbsTeamlist.size() > 0){
				for(Team_Structure__c eachTeam : cbsTeamlist){
					if (!teamSet.contains(eachTeam.Name)){
					teamSet.add(eachTeam.Name);
					teamList.add(new SelectOption(eachTeam.Name, eachTeam.Name));
					}
				}
			}
		}else if(selectReason == GlobalConstants.REASON_COMPANY_RELATED){
			User currentUser = [SELECT Id, RC_Code__c, Segment__c FROM User WHERE Id = :UserInfo.getUserId()];
			if(customerOwnerShip.Company_Related_Text__c != null && customerOwnerShip.Company_Related_Text__c !=''){
				teamList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
				try{
					List<String> filterSegment = new List<String>();
					if(GlobalConstants.SME_SEGMENT_CODE_SET.contains(currentUser.Segment__c)){
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_MB);
					}else{
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_UM);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_PC);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_XS);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_UR);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_SR);
						filterSegment.add(GlobalConstants.PRIMARY_SEGMENT_CODE_LR);
					}
					List<Account> relatedAccountList = [select Current_Team_Name__c ,Current_Team_Name__r.Name from Account WHERE CIS__c = :customerOwnerShip.Company_Related_Text__c AND Primary_Segment_Code__c IN :filterSegment];
					for (Account eachAccount : relatedAccountList) {
						if (eachAccount.Current_Team_Name__c != null && !teamSet.contains(eachAccount.Current_Team_Name__r.Name)){
							teamSet.add(eachAccount.Current_Team_Name__r.Name);
							teamList.add(new SelectOption(eachAccount.Current_Team_Name__r.Name, eachAccount.Current_Team_Name__r.Name));
						}
					}
				}catch(Exception ex){
	       		}
			}
		}
		
		return teamList;
	}

	public PageReference selectProvince() {
		getTeamList();

		return null;
	}

	public void showError(String errorMsg) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
		ApexPages.addMessage(msg);
	}

	public PageReference save() {
		Customer_Ownership_Request__c updateCustomerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		if(updateCustomerOwnerShip.Approval_Status__c != GlobalConstants.CANCEL){
			if (updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_OTHER_TEAM || updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_WRONG_AREA || updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_SME || updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_NATIONALITY || updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_CBS) {
			updateCustomerOwnerShip.Refer_Out_Province__c = selectedProvince == SELECT_NONE ? null : selectedProvince;
			updateCustomerOwnerShip.Refer_Out_Team__c = selectedTeam == SELECT_NONE ? null : selectedTeam;
			} else if(updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_COMPANY_RELATED){
				updateCustomerOwnerShip.Refer_Out_Province__c = selectedProvince == SELECT_NONE ? null : selectedProvince;
				updateCustomerOwnerShip.Refer_Out_Team__c = selectedTeam == SELECT_NONE ? null : selectedTeam;
			} else {
				updateCustomerOwnerShip.Refer_Out_Province__c = null;
				updateCustomerOwnerShip.Refer_Out_Team__c = null;
			}
		}
		if(isBlockTeam(selectedTeam)){
			return null;
		}
		PageReference pageRef;
		try {
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			validateRelease(currentUser);
			ReleaseOwnershipService.setRequestorApprover(updateCustomerOwnerShip, accountRefer, currentUser);
			return this.stdController.save();
		} catch (OwnershipException releaseException) {
			showError(releaseException.getMessage());
		} catch (DmlException dmlEx) {
            showError(dmlEx.getDmlMessage(0));
        } catch (Exception ex) {
			showError(ex.getMessage());
		}
		return null;
	}

	private void validateRelease(User currentUser) {
        Account accountObj = Account_Service.getAccountInformation(accountRefer.Id);
        String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
        IReleaseOwnership releaseOwnership;
        switch on userSegment {
            when 'SME' {
                releaseOwnership = new SMEReleaseOwnership();
            } 
            when 'CBS' {
                releaseOwnership = new CBSReleaseOwnership();
            } 
        }
        releaseOwnership.validateCustomer(accountObj, currentUser);
	}

	private Boolean isBlockTeam(String selectedTeam){
		Team_Structure__c listBlockTeam = [SELECT External_Id__C ,Name FROM Team_Structure__c WHERE External_Id__C = '99999'];
		if(listBlockTeam.Name == selectedTeam){
			showError(Schema.Customer_Ownership_Request__c.fields.Refer_Out_Team__c.getDescribe().getLabel() + ':' + System.Label.Cannot_Refer_Out_to_this_Province);
			return true;
		}
		return false;
	}

	private Boolean isSelectSegment(String selectedRefSegment){
		if(selectedRefSegment == GlobalConstants.SEGMENT_SE || selectedRefSegment == GlobalConstants.SEGMENT_ME || selectedRefSegment == GlobalConstants.SEGMENT_CB || selectedRefSegment == GlobalConstants.SEGMENT_MB){
			return true;
		}
		return false;
	}
}