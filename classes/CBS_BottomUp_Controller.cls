/**
* @author Panachai Reinthavorn
*/
public without sharing class CBS_BottomUp_Controller {
	private User currentUser;
	public String currentUserID;
	public String currentUserName;
	public String currentUserProfile;
	public String currentUserRCCode;
	public String currentUserEmployeeID;
	public String currentYear;
	public String previousYear;
	public String staticResourceFileName;
	public String salesForcebaseURL;
	public boolean canEditBottomUpTable;
	public boolean canEditTargetTable;
	private Map<String,BottomUpSettings__c> cutomsettingBottomUpSettingMap;
	private String cbsStaticResourcePrefix = 'cbs_BottomUp_Data_';
	private Map<String,Profile> profileMaps;
	private Map<String,User> relatedFSVPNamesMap;
	private Map<String,Team_Structure__c> relatedTeamNamesMap;
	private Map<String,User> relatedSalesMembersMap;
	boolean isEVP;
	boolean isFSVP;
	boolean isCBSAdmin;
	boolean isNHTL;
	boolean isTL;
	boolean isTM;
	boolean isRM;
    public static String getThisYear(){
        //String currentYear = String.valueOf(System.today().year() - 543);
        String currentYear = String.valueOf(GlobalUtility.getYearInChristianCalendar( System.today()) );
        return currentYear;
    }
    public static String getLastYear(){
    	//String lastYear = String.valueOf(System.now().addYears(-1).year()-543);
    	String lastYear = String.valueOf(GlobalUtility.getYearInChristianCalendar( System.today().addYears(-1) ) );
    	return lastYear;
    }
	public CBS_BottomUp_Controller() {
		this.currentUserID = UserInfo.getUserId();
		this.currentUser = [SELECT Id,ProfileId,Name,Profile.Name,Employee_ID__c,RC_Code__c FROM User WHERE Id = :currentUserID LIMIT 1];
		this.currentUserEmployeeID = this.currentUser.Employee_ID__c;
		Map<String,String>profileAndRCCodeMap = getProfileAndRCCode();
		this.currentUserProfile = profileAndRCCodeMap.get('profileName');
		this.currentUserRCCode = profileAndRCCodeMap.get('rcCode');
		this.currentUserName = this.currentUser.Name;
		this.currentYear = getThisYear();
		this.previousYear = getLastYear();
		this.salesForcebaseURL = ''+URL.getSalesforceBaseUrl().toExternalForm();
		this.isEVP = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_EVP);
		this.isFSVP = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_FSVP);
		this.isCBSAdmin = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_ADMIN);
		this.isNHTL = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_NHTL);
		this.isTL = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_TL);
		this.isTM = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_TM);
		this.isRM = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_RM);
		initialAccordingToProileData();
	}
	private Boolean isSTL(){
		Boolean isTLProfile = this.currentUserProfile.equalsIgnoreCase(GlobalConstants.CBS_TL);
		if(isTLProfile){
			List<Sales_Target__c>cbsTLSubOrdinates = [SELECT Id,Name__c,Name__r.User__r.managerId FROM Sales_Target__c WHERE Name__r.User__r.managerId =: this.currentUserID AND (Name__r.User__r.Profile.Name = 'CBS-TL' OR Name__r.User__r.Profile.Name = 'CBS-TM')];
			Boolean hasCBSTLasSubOrdinate = !cbsTLSubOrdinates.isEmpty();
			if(hasCBSTLasSubOrdinate){
				return true;
			}
		}
		return false;
	}
	private Map<String,String> getProfileAndRCCode(){
		String currentUserProfile = this.currentUser.Profile.Name;
		String currentUserRCCode = this.currentUser.RC_Code__c==null?'none':this.currentUser.RC_Code__c;
		String profileName;
		String rcCode;
		Map<String,String> profileAndRCCodeMap = new Map<String,String>();
		//check if he/she is NHTL
		//Mirror_Value__c is TL RCcode for NHTL profile in CBS
		List<User_Mirror_Management__c> userMirrorManagement = [SELECT Employee_ID__c,Employee_Name__c,Mirror_Type__c,Mirror_Value__c,User_Value__c FROM User_Mirror_Management__c WHERE Employee_ID__c =: this.currentUserEmployeeID AND Mirror_Type__c = 'RC_Code'];
		boolean isNHTL = !userMirrorManagement.isEmpty();
		if(isNHTL){
			profileAndRCCodeMap.put('profileName',GlobalConstants.CBS_NHTL);
			profileAndRCCodeMap.put('rcCode',userMirrorManagement[0].Mirror_Value__c);
		}else{
			profileAndRCCodeMap.put('profileName',currentUserProfile);
			profileAndRCCodeMap.put('rcCode',currentUserRCCode);
		}
		return profileAndRCCodeMap;
	}
	private void initialAccordingToProileData(){
		//get setting from CUSTOM SETTINGs
		getCustomBottomUpSettingMap();
		for(String key:this.cutomsettingBottomUpSettingMap.keySet()){
		}
		if(this.isEVP){
			this.staticResourceFileName = getSelectedResourceByProfile('evp');
			this.canEditBottomUpTable = false;
			this.canEditTargetTable = false;
		}else if(this.isFSVP){
			this.staticResourceFileName = getSelectedResourceByProfile('fsvp');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-FSVP').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-FSVP').Edit_Target_Table__c;
		}else if(this.isCBSAdmin){
			this.staticResourceFileName = getSelectedResourceByProfile('cbsadmin');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-Admin').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-Admin').Edit_Target_Table__c;
		}else if(this.isNHTL){
			this.staticResourceFileName = getSelectedResourceByProfile('nhtl');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Target_Table__c;
		}else if(isSTL()){
			this.staticResourceFileName = getSelectedResourceByProfile('nhtl');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Target_Table__c;
		}else if(this.isTL){
			this.staticResourceFileName = getSelectedResourceByProfile('tl');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-TL').Edit_Target_Table__c;
		}else if(this.isTM){
			this.staticResourceFileName = getSelectedResourceByProfile('tm');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-TM').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-TM').Edit_Target_Table__c;
		}else if(this.isRM){
			this.staticResourceFileName = getSelectedResourceByProfile('rm');
			this.canEditBottomUpTable = this.cutomsettingBottomUpSettingMap.get('CBS-RM').Edit_Bottom_Up_Table__c;
			this.canEditTargetTable = this.cutomsettingBottomUpSettingMap.get('CBS-RM').Edit_Target_Table__c;
		}
	}
	public String getCurrentUserName(){
		return this.currentUserName;
	}
	public String getCurrentUserProfile(){
		return this.currentUserProfile;
	}
	public String getCurrentUserRCCode(){
		return this.currentUserRCCode;
	}
	public String getCurrentUserEmployeeID(){
		return this.currentUserEmployeeID;
	}
	public String getSelectedResource(){
		return this.staticResourceFileName;
	}
	public String getStaticResourceFileName(){
		return this.staticResourceFileName;
	}
	public String getCurrentYear(){
		return this.currentYear;
	}
	public String getPreviousYear(){
		return this.previousYear;
	}
	public String getSalesForcebaseURL(){
		return this.salesForcebaseURL;
	}
	public String getCurrentUserID(){
		return this.currentUserID;
	}
	public String getSelectedResourceByProfile(String suffix){
		String staticResourceName = cbsStaticResourcePrefix + suffix;
		return staticResourceName;
	}
	public Boolean getCanEditBottomUpTable(){
		return this.canEditBottomUpTable;
	}
	public Boolean getCanEditTargetTable(){
		return this.canEditTargetTable;
	}
    @RemoteAction
    public static ModelExtensions.SavingResponse saveSalesTargetTable(ModelExtensions.savingSalesTargetsRequests svobj){
    	ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
    	List<ModelExtensions.savingSalesTargetRequest>savingSalesTargetRequests = svobj.salesTargetRequests;
    	List<Sales_Target__c>toUpdateSalesTargets = new List<Sales_Target__c>();
    	for(ModelExtensions.savingSalesTargetRequest savingSalesTargetRequest:savingSalesTargetRequests){
    		Sales_Target__c salesTargetToUpdate = new Sales_Target__c(Id = savingSalesTargetRequest.salesTargetId);
    		salesTargetToUpdate.Transaction_Fee_Target__c = savingSalesTargetRequest.transactionFeeTarget;
    		salesTargetToUpdate.Main_Operating_Bank_Target__c = savingSalesTargetRequest.mainOperatingBankTarget;
    		salesTargetToUpdate.Deal_Base_Fee_Target__c = savingSalesTargetRequest.dealBaseFeeTarget;
    		toUpdateSalesTargets.add(salesTargetToUpdate);
    	}
    	List<Database.SaveResult> updateResults = BottomUp_Service.updateSalesTarget(toUpdateSalesTargets);
    	boolean allSuccess = true;
    	List<String>errMessages = new List<String>();
    	for (Database.SaveResult updateResult : updateResults) {
    		boolean isError = !updateResult.isSuccess();
		    if (isError){
		        allSuccess = false;
		        for(Database.Error err : updateResult.getErrors()) {
		        	errMessages.add(err.getMessage() + ' : ' + err.getStatusCode() + ' : ' + err.getFields());
		        }
		    }
		}
		resp.success = allSuccess;
		string allErrors = string.join(errMessages,',');
		resp.errorMessage = allErrors;
    	return resp;
	}
	@RemoteAction
    public static ModelExtensions.SavingResponse saveBottomUpAnnualizedTable(ModelExtensions.savingBottomUpAnnualizedRequests svobj){
    	ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
    	List<ModelExtensions.savingBottomUpAnnualizedRequest>savingBottomUpAnnualizedRequests = svobj.bottomUpAnnualizedRequests;
    	List<Bottom_Up_Annualized__c>toUpdateBottomUpAnnualizeds = new List<Bottom_Up_Annualized__c>();
    	for(ModelExtensions.savingBottomUpAnnualizedRequest savingBottomUpAnnualizedRequest:savingBottomUpAnnualizedRequests){
    		Bottom_Up_Annualized__c bottomUpToUpdate = new Bottom_Up_Annualized__c(Id = savingBottomUpAnnualizedRequest.bottomUpAnnualizedId);
    		bottomUpToUpdate.BottomUp_SS__c = savingBottomUpAnnualizedRequest.transactionFeeSS;
    		bottomUpToUpdate.BottomUp_FX__c = savingBottomUpAnnualizedRequest.transactionFeeFX;
    		bottomUpToUpdate.BottomUp_LI__c = savingBottomUpAnnualizedRequest.transactionFeeLI;
    		bottomUpToUpdate.BottomUp_TF__c = savingBottomUpAnnualizedRequest.transactionFeeTF;
    		bottomUpToUpdate.BottomUp_KA__c = savingBottomUpAnnualizedRequest.mainOperatingBankKA;
			bottomUpToUpdate.BottomUp_Float__c = savingBottomUpAnnualizedRequest.mainOperatingBankFloat;
    		bottomUpToUpdate.BottomUp_Cash__c = savingBottomUpAnnualizedRequest.mainOperatingBankCash;
    		bottomUpToUpdate.BottomUp_BA__c = savingBottomUpAnnualizedRequest.dealBaseFeeBA;
    		bottomUpToUpdate.BottomUp_Derivative__c = savingBottomUpAnnualizedRequest.dealBaseFeeDeriverative;
    		bottomUpToUpdate.BottomUp_Front_End__c = savingBottomUpAnnualizedRequest.dealBaseFeeFrontEnd;
    		bottomUpToUpdate.BottomUp_IBB__c = savingBottomUpAnnualizedRequest.dealBaseFeeIBB;
    		bottomUpToUpdate.BottomUp_Investment_Fee__c = savingBottomUpAnnualizedRequest.dealBaseFeeInvestmentFee;
    		bottomUpToUpdate.Business_Closed__c = savingBottomUpAnnualizedRequest.businessClosed;
    		toUpdateBottomUpAnnualizeds.add(bottomUpToUpdate);
    	}
    	List<Database.SaveResult> updateResults = BottomUp_Service.updateBottomUp(toUpdateBottomUpAnnualizeds);
    	boolean allSuccess = true;
    	List<String>errMessages = new List<String>();
    	for (Database.SaveResult updateResult : updateResults) {
    		boolean isError = !updateResult.isSuccess();
		    if (isError){
		        allSuccess = false;
		        for(Database.Error err : updateResult.getErrors()) {
		        	errMessages.add(err.getMessage() + ' : ' + err.getStatusCode() + ' : ' + err.getFields());
		        }
		    }
		}
		resp.success = allSuccess;
		string allErrors = string.join(errMessages,',');
		resp.errorMessage = allErrors;
    	return resp;
	}
	public void getCustomBottomUpSettingMap(){
		this.cutomsettingBottomUpSettingMap = new Map<String,BottomUpSettings__c>();
		List<BottomUpSettings__c>bottomUpSettings = [SELECT Edit_Bottom_Up_Table__c,Edit_Target_Table__c,Id,Name,SetupOwnerId,SetupOwner.Name FROM BottomUpSettings__c];
		if(!bottomUpSettings.isEmpty()){
			Set<String>setupOwnerIds = new Set<String>();
			for(BottomUpSettings__c bottomUpSetting:bottomUpSettings){
				setupOwnerIds.add(bottomUpSetting.SetupOwnerId);
			}
			List<Profile>profiles = [SELECT Id,Name FROM Profile WHERE Id IN: setupOwnerIds];
			Map<String,Profile>profileByProfileID = new Map<String,Profile>();
			for(Profile profile:profiles){
				profileByProfileID.put(profile.Id,profile);
			}
		 	for(BottomUpSettings__c bottomUpSetting:bottomUpSettings){
		 		//this.cutomsettingBottomUpSettingMap.put(bottomUpSetting.SetupOwner.Name,bottomUpSetting);
		 		if(profileByProfileID.get(bottomUpSetting.SetupOwnerId) != null){
		 			String profileName = profileByProfileID.get(bottomUpSetting.SetupOwnerId).Name;
		 			this.cutomsettingBottomUpSettingMap.put(profileName,bottomUpSetting);	
		 		}
		 	}
		}
	}
	public PageReference validateProfileAndRedirect(){
		if(!(this.isEVP || this.isFSVP || this.isCBSAdmin || this.isNHTL || this.isTL || this.isTM || this.isRM)){
			PageReference retURL = new PageReference('/apex/CBS_Error_Page');
		    retURL.setRedirect(true);
		    return retURL;	
		}
	    return null;
 	}
    @RemoteAction
    public static ModelExtensions.PicklistResponse getAllFSVPs(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            String fsvpUsersQuery = 'SELECT Id,Name,Employee_ID__c FROM User WHERE Profile.Name = \''+GlobalConstants.CBS_FSVP+'\' ORDER BY Name ASC NULLS FIRST';
            List<User> fsvpUsers = Database.query(fsvpUsersQuery);
            resp.records.add(new ModelExtensions.Picklist('ALL','All'));
            for(User  fsvpUser : fsvpUsers){
                resp.records.add(new ModelExtensions.Picklist(fsvpUser.Employee_ID__c,fsvpUser.Name));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static ModelExtensions.PicklistResponse getTeamsThatRelatedToSelectedFSVP(ModelExtensions.QueryPickListObj qobj){
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
            String fsvpEmployeeID = qobj.fsvpID;
            String teamRCCode = qobj.teamRCCode;
            if(!String.isBlank(fsvpEmployeeID)){
                boolean isAll = fsvpEmployeeID.equalsIgnoreCase('ALL');
                try {
                    if(isAll){
                        List<FSVP_Teams__c>fsvpTeams = [SELECT Employee_ID__c,Id,Name,RC_Code__c FROM FSVP_Teams__c];
                        Set<String>teamRCCodes = new Set<String>();
                        for(FSVP_Teams__c fsvpTeam : fsvpTeams ){
                        	teamRCCodes.add(fsvpTeam.RC_Code__c);
                        }
                        List<Team_Target__c>teamTargets = [SELECT Id,Name,Team_Name__r.Name,Team_Name__r.Id,Team_Name__r.RC_Code__c FROM Team_Target__c WHERE Team_Name__r.RC_Code__c IN: teamRCCodes ORDER BY Team_Name__r.RC_Code__c ASC NULLS FIRST];
                        resp.records.add(new ModelExtensions.Picklist('ALL','All'));
                        for(Team_Target__c teamTarget : teamTargets){
                            resp.records.add(new ModelExtensions.Picklist(teamTarget.Team_Name__r.RC_Code__c,teamTarget.Team_Name__r.Name));
                        }
                    }else{
                        String fsvpTeamsQuery = 'SELECT Employee_ID__c,Id,Name,RC_Code__c FROM FSVP_Teams__c WHERE Employee_ID__c = \''+fsvpEmployeeID+'\'';
                        List<FSVP_Teams__c>fsvpTeams = Database.query(fsvpTeamsQuery);
                        Set<String>teamRCCodes = new Set<String>();
                        for(FSVP_Teams__c fsvpTeam : fsvpTeams ){
                        	teamRCCodes.add(fsvpTeam.RC_Code__c);
                        }
                        List<Team_Target__c>teamTargets = [SELECT Id,Name,Team_Name__r.Name,Team_Name__r.Id,Team_Name__r.RC_Code__c FROM Team_Target__c WHERE Team_Name__r.RC_Code__c IN: teamRCCodes ORDER BY Team_Name__r.RC_Code__c ASC NULLS FIRST];
                        resp.records.add(new ModelExtensions.Picklist('ALL','All'));
                        for(Team_Target__c teamTarget : teamTargets){
                            resp.records.add(new ModelExtensions.Picklist(teamTarget.Team_Name__r.RC_Code__c,teamTarget.Team_Name__r.Name));
                        }
                    }
                } catch (Exception e) {
                    resp.success = false;
                    resp.records = null;
                    resp.errorMessage = e.getMessage();
                    return resp;
                }
            }
            //NHTL OR STL Request
            if(!String.isBlank(teamRCCode)){
                try{
                    List<Team_Target__c>teamTargets = [SELECT Id,Name,Team_Name__r.Name,Team_Name__r.Id,Team_Name__r.RC_Code__c FROM Team_Target__c WHERE Team_RC_Code__c =: teamRCCode OR Team_Name__r.AH_Name__r.RC_Code__c =: teamRCCode ORDER BY Team_Name__r.RC_Code__c ASC NULLS FIRST];
                    resp.records.add(new ModelExtensions.Picklist('ALL','All'));
                    for(Team_Target__c teamTarget : teamTargets){
                        resp.records.add(new ModelExtensions.Picklist(teamTarget.Team_Name__r.RC_Code__c,teamTarget.Team_Name__r.Name));
                    } 
                }catch (Exception e){

                }
            } 
        return resp;
    }
    @RemoteAction
    public static ModelExtensions.PicklistResponse getOwnerMemberThatRelatedToSelectedTeam(ModelExtensions.QueryPickListObj qobj){
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        String teamRCCode = qobj.teamRCCode;
        Boolean isTL = false;
        if(qobj.isTL != null){
            isTL = qobj.isTL;
        }
        if(!String.isBlank(teamRCCode)){
            try {
                String ownersQueryString = 'SELECT AH_RC_Code__c,Id,Name,NH_RC_Code__c,RC_Code__c,Employee_ID__c FROM User';
                boolean hasFilter = !teamRCCode.equalsIgnoreCase('ALL');
                if(hasFilter){
                     ownersQueryString += ' WHERE RC_Code__c =: teamRCCode ORDER BY Name ASC NULLS FIRST';
                }
                List<User> owners = Database.query(ownersQueryString);
                resp.records.add(new ModelExtensions.Picklist('ALL','All'));
                for(User owner : owners){
                    resp.records.add(new ModelExtensions.Picklist(owner.Employee_ID__c,owner.Name));
                }
                if(!isTL){
                	List<User_Mirror_Management__c> userMirrorManagements = [SELECT Employee_ID__c,Employee_Name__c,Mirror_Type__c,Mirror_Value__c,User_Value__c FROM User_Mirror_Management__c WHERE Mirror_Value__c =: teamRCCode AND Mirror_Type__c = 'RC_Code' ORDER BY Employee_Name__c ASC NULLS FIRST];
                    //List<CBS_NHTL_Management__c>cbsMgmts = [SELECT AH_RC_Code__c,Employee_ID__c,Employee_Name__c FROM CBS_NHTL_Management__c WHERE AH_RC_Code__c =: teamRCCode];
                    for(User_Mirror_Management__c userMirrorManagement:userMirrorManagements){
                        resp.records.add(new ModelExtensions.Picklist(userMirrorManagement.Employee_ID__c,userMirrorManagement.Employee_Name__c));
                    }    
                }
            } catch (Exception e) {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = e.getMessage();
                return resp;
            }
        }
        return resp;
    }
    @RemoteAction
    public static ModelExtensions.PicklistResponse getOwnerMemberThatRelatedToSelectedTeamForTM(ModelExtensions.QueryPickListObj qobj){
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        String userEmployeeID = qobj.userEmployeeID;
        if(!String.isBlank(userEmployeeID)){
            try {
                List<User> currentUser= [SELECT Id FROM User WHERE Employee_ID__c =: userEmployeeID];
                if(!currentUser.isEmpty()){
                    String currentUserId = currentUser[0].Id;
                    String ownersQueryString = 'SELECT AH_RC_Code__c,Id,Name,NH_RC_Code__c,RC_Code__c,Employee_ID__c,ManagerId FROM User';
                    ownersQueryString += ' WHERE ID =: currentUserId OR ManagerId =: currentUserId ORDER BY Name ASC NULLS FIRST';
                    List<User> owners = Database.query(ownersQueryString);
                    resp.records.add(new ModelExtensions.Picklist('ALL','All'));
                    for(User owner : owners){
                        resp.records.add(new ModelExtensions.Picklist(owner.Employee_ID__c,owner.Name));
                    }  
                }
            } catch (Exception e) {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = e.getMessage();
                return resp;
            }
        }
        return resp;
    }
    @RemoteAction
    public static ModelExtensions.CRUDCustomBottomUpAnnualizedResponse querySalesTargetTable(ModelExtensions.QueryObj qobj) {
        ModelExtensions.CRUDCustomBottomUpAnnualizedResponse resp = new ModelExtensions.CRUDCustomBottomUpAnnualizedResponse();
        String teamRCCode = qobj.filter[0].get('teamRCCode');
        String salesEmployeeID = qobj.filter[0].get('salesEmployeeId');
        Boolean tmRequest = (String.isNotBlank(qobj.filter[0].get('tmRequest')) && qobj.filter[0].get('tmRequest').equalsIgnoreCase('true'));
        if(teamRCCode.equalsIgnoreCase('none') && salesEmployeeID.equalsIgnoreCase('none')){
            resp.records = new List<ModelExtensions.targetTableRecord>();
            return resp;
        }
        //String tableLevel = qobj.extraquery;
        //boolean isTeam = tableLevel.equalsIgnoreCase('teamLevel');
        boolean isTeam = !teamRCCode.equalsIgnoreCase('none') && salesEmployeeID.equalsIgnoreCase('none');
        String targetQuery = '';	
        String targetCondition = '';

        Map<String,String> targetTableRecordFieldNameMap = new Map<String,String>{
            'targetName' => 'Name__r.User__r.Name',
            'targetId' => 'Id',
            'transactionFeeTarget' => 'Transaction_Fee_Target__c',
            'transactionFeeBottomUp' => 'Transaction_Fee_Bottom_Up_Sum__c',
            'mainOperatingBankTarget' => 'Main_Operating_Bank_Target__c',
            'mainOperatingBankBottomUp' => 'Main_Operating_Bank_Bottom_Up_Sum__c',
            'dealBaseFeeTarget' => 'Deal_Base_Fee_Target__c',
            'dealBaseFeeBottomUp' => 'Deal_Base_Fee_Bottom_Up_Sum__c',
            'transactionFeeTeamTarget' => 'Team_Target__r.Transaction_Fee_Team_Target__c',
            'mainOperatingBankTeamTarget' => 'Team_Target__r.Main_Operating_Bank_Team_Target__c',
            'dealBaseFeeTeamTarget' => 'Team_Target__r.Deal_Base_Fee_Team_Target__c',
            'totalBottomUp' => 'salesTarget.Total_Bottom_Up__c',
            'totalMiracle' => 'salesTarget.Total_Miracle_Target__c'
        };

        String orderCondition = '';
        if(qobj.sortParams != null && !qobj.sortParams.isEmpty() && String.isNotBlank(qobj.sortParams[0].get('property')) && String.isNotBlank(qobj.sortParams[0].get('direction'))){
            String sortProperty = targetTableRecordFieldNameMap.get(qobj.sortParams[0].get('property'));
            String sortDirection = qobj.sortParams[0].get('direction');
            String nullOrder = (sortDirection.equalsIgnoreCase('ASC'))?' NULLS FIRST':' NULLS LAST';
            orderCondition = ' ORDER BY '+sortProperty+' '+sortDirection+nullOrder;
        }

        if(isTeam && String.isNotBlank(teamRCCode) && !tmRequest){
            targetQuery = 'SELECT Id,Deal_Base_Fee_Bottom_Up_Sum__c,Deal_Base_Fee_Target__c,Main_Operating_Bank_Bottom_Up_Sum__c,Main_Operating_Bank_Target__c,Name__c,Name__r.User__r.Name,Transaction_Fee_Bottom_Up_Sum__c,Transaction_Fee_Target__c,Team_Target__r.Team_Name__r.Name,Team_Target__r.Transaction_Fee_Team_Target__c,Team_Target__r.Main_Operating_Bank_Team_Target__c,Team_Target__r.Deal_Base_Fee_Team_Target__c,Total_Bottom_Up__c,Total_Miracle_Target__c FROM Sales_Target__c';
            targetCondition = ' WHERE Year__c = \'' + getThisYear() + '\' AND Team_Target__r.Team_RC_Code__c = \''+teamRCCode+'\' AND Is_Active__c  = true';
            targetCondition+=orderCondition;
            //targetCondition = ' WHERE ';
        }else if(!isTeam && !tmRequest){
            targetQuery = 'SELECT Id,Name__r.Employee_ID__c,Deal_Base_Fee_Bottom_Up_Sum__c,Deal_Base_Fee_Target__c,Main_Operating_Bank_Bottom_Up_Sum__c,Main_Operating_Bank_Target__c,Name__c,Name__r.User__r.Name,Transaction_Fee_Bottom_Up_Sum__c,Transaction_Fee_Target__c,Total_Bottom_Up__c,Total_Miracle_Target__c FROM Sales_Target__c';
            targetCondition = ' WHERE Year__c = \'' + getThisYear() + '\' AND Name__r.Employee_ID__c =: salesEmployeeID  AND Is_Active__c  = true';
            targetCondition+=orderCondition;
        }else if(tmRequest){
            List<User>rms = [SELECT Id FROM User WHERE Employee_ID__c =: salesEmployeeID];
            if(!rms.isEmpty()){
                String rmId = rms[0].Id;
                targetQuery = 'SELECT Id,Name__r.Employee_ID__c,Deal_Base_Fee_Bottom_Up_Sum__c,Deal_Base_Fee_Target__c,Main_Operating_Bank_Bottom_Up_Sum__c,Main_Operating_Bank_Target__c,Name__c,Name__r.User__r.Name,Transaction_Fee_Bottom_Up_Sum__c,Transaction_Fee_Target__c,Total_Bottom_Up__c,Total_Miracle_Target__c FROM Sales_Target__c';
                targetCondition = ' WHERE Year__c = \'' + getThisYear() + '\' AND (Name__r.User__r.ManagerId =: rmId OR Name__r.User__c =: rmId)  AND Is_Active__c  = true';    
                targetCondition+=orderCondition;
            }
        }   
        targetQuery += targetCondition;
        List<Sales_Target__c>salesTargets = Database.query(targetQuery);
        if(isTeam){
            for(Sales_Target__c salesTarget:salesTargets){
                ModelExtensions.targetTableRecord targetTableRecord = new ModelExtensions.targetTableRecord(
                    salesTarget.Name__r.User__r.Name,
                    salesTarget.Id,
                    salesTarget.Transaction_Fee_Target__c,
                    salesTarget.Transaction_Fee_Bottom_Up_Sum__c,
                    salesTarget.Main_Operating_Bank_Target__c,
                    salesTarget.Main_Operating_Bank_Bottom_Up_Sum__c,
                    salesTarget.Deal_Base_Fee_Target__c,
                    salesTarget.Deal_Base_Fee_Bottom_Up_Sum__c,
                    salesTarget.Team_Target__r.Transaction_Fee_Team_Target__c,
                    salesTarget.Team_Target__r.Main_Operating_Bank_Team_Target__c,
                    salesTarget.Team_Target__r.Deal_Base_Fee_Team_Target__c,
                    salesTarget.Total_Bottom_Up__c,
                    salesTarget.Total_Miracle_Target__c
                    );
                resp.records.add(targetTableRecord);
            }
        }
        else{
            for(Sales_Target__c salesTarget:salesTargets){
                ModelExtensions.targetTableRecord targetTableRecord = new ModelExtensions.targetTableRecord(
                    salesTarget.Name__r.User__r.Name,
                    salesTarget.Id,
                    salesTarget.Transaction_Fee_Target__c,
                    salesTarget.Transaction_Fee_Bottom_Up_Sum__c,
                    salesTarget.Main_Operating_Bank_Target__c,
                    salesTarget.Main_Operating_Bank_Bottom_Up_Sum__c,
                    salesTarget.Deal_Base_Fee_Target__c,
                    salesTarget.Deal_Base_Fee_Bottom_Up_Sum__c,
                    salesTarget.Total_Bottom_Up__c,
                    salesTarget.Total_Miracle_Target__c
                    );
                resp.records.add(targetTableRecord);
            }
        }
        return resp;
    }
    @RemoteAction
    public static ModelExtensions.CRUDCustomBottomUpAnnualizedResponse queryTeamTargetTable(ModelExtensions.QueryObj qobj) {
        ModelExtensions.CRUDCustomBottomUpAnnualizedResponse resp = new ModelExtensions.CRUDCustomBottomUpAnnualizedResponse();
        String fsvpEmployeeID = qobj.filter[0].get('FSVPEmployeeID');
        String teamRCCode = qobj.filter[0].get('teamRCCode');

        if(String.isNotBlank(fsvpEmployeeID) && fsvpEmployeeID.equalsIgnoreCase('none')){
            resp.records = new List<ModelExtensions.targetTableRecord>();
            return resp;
        }

        Set<String> relatedFSVPTeamRCcodes = new Set<String>();
        if(String.isNotBlank(fsvpEmployeeID)){
            List<FSVP_Teams__c>relatedFSVPTeams = [SELECT Employee_ID__c,RC_Code__c FROM FSVP_Teams__c WHERE Employee_ID__c =: fsvpEmployeeID];    
            for(FSVP_Teams__c fsvpTeam:relatedFSVPTeams){
                relatedFSVPTeamRCcodes.add(fsvpTeam.RC_Code__c); 
            }
        }else if(String.isNotBlank(teamRCCode)){
            List<Team_Target__c>teamTargets = [SELECT Id,Name,Team_Name__r.Name,Team_Name__r.Id,Team_Name__r.RC_Code__c FROM Team_Target__c WHERE Team_RC_Code__c =: teamRCCode OR Team_Name__r.AH_Name__r.RC_Code__c =: teamRCCode];
            for(Team_Target__c teamTarget:teamTargets){
                relatedFSVPTeamRCcodes.add(teamTarget.Team_Name__r.RC_Code__c); 
            }
        }

        Map<String,String> targetTableRecordFieldNameMap = new Map<String,String>{
            'targetName' => 'Team_Name__r.Name',
            'targetId' => 'Id',
            'transactionFeeTarget' => 'Transaction_Fee_Team_Target__c',
            'transactionFeeBottomUp' => 'Transaction_Fee_Team_Bottom_Up_Sum__c',
            'mainOperatingBankTarget' => 'Main_Operating_Bank_Team_Target__c',
            'mainOperatingBankBottomUp' => 'Main_Operating_Bank_Team_Bottom_Up_Sum__c',
            'dealBaseFeeTarget' => 'Deal_Base_Fee_Team_Target__c',
            'dealBaseFeeBottomUp' => 'Deal_Base_Fee_Team_Bottom_Up_Sum__c',
            'totalMiracle' => 'Total_Miracle_Target__c',
            'totalBottomUp' => 'Total_Miracle_Bottom_Up__c'

        };
        String teamQuery = 'SELECT Deal_Base_Fee_Target_Sum__c,Deal_Base_Fee_Team_Bottom_Up_Sum__c,Deal_Base_Fee_Team_Target__c,'+
        'Id,Main_Operating_Bank_Target_Sum__c,Main_Operating_Bank_Team_Bottom_Up_Sum__c,Main_Operating_Bank_Team_Target__c,Name,'+
        'Team_Name__c,Team_Name__r.Name,Transaction_Fee_Target_Sum__c,Transaction_Fee_Team_Bottom_Up_Sum__c,Transaction_Fee_Team_Target__c,Year__c,Team_RC_Code__c,Total_Miracle_Bottom_Up__c,Total_Miracle_Target__c FROM Team_Target__c';
        String teamCondition = ' WHERE Year__c = \'' + getThisYear() + '\'';
        boolean isAll = (String.isNotBlank(fsvpEmployeeID) && fsvpEmployeeID.equalsIgnoreCase('ALL'));
        if(!isAll || String.isNotBlank(teamRCCode)){
            teamCondition += ' AND Team_RC_Code__c IN: relatedFSVPTeamRCcodes';
        }
        String orderCondition = '';
        if(!qobj.sortParams.isEmpty() && String.isNotBlank(qobj.sortParams[0].get('property')) && String.isNotBlank(qobj.sortParams[0].get('direction'))){
            String sortProperty = targetTableRecordFieldNameMap.get(qobj.sortParams[0].get('property'));
            String sortDirection = qobj.sortParams[0].get('direction');
            String nullOrder = (sortDirection.equalsIgnoreCase('ASC'))?' NULLS FIRST':' NULLS LAST';
            orderCondition = ' ORDER BY '+sortProperty+' '+sortDirection+nullOrder;
        }
        teamQuery += teamCondition;
        teamQuery += orderCondition;
        List<Team_Target__c> teamTargets = Database.query(teamQuery);
        for(Team_Target__c teamTarget : teamTargets){
            ModelExtensions.targetTableRecord targetTableRecord = new ModelExtensions.targetTableRecord(
                    teamTarget.Team_Name__r.Name,
                    teamTarget.Id,
                    teamTarget.Transaction_Fee_Target_Sum__c,
                    teamTarget.Transaction_Fee_Team_Bottom_Up_Sum__c,
                    teamTarget.Main_Operating_Bank_Target_Sum__c,
                    teamTarget.Main_Operating_Bank_Team_Bottom_Up_Sum__c,
                    teamTarget.Deal_Base_Fee_Target_Sum__c,
                    teamTarget.Deal_Base_Fee_Team_Bottom_Up_Sum__c,
                    teamTarget.Total_Miracle_Bottom_Up__c,
                    teamTarget.Total_Miracle_Target__c);
            resp.records.add(targetTableRecord);
        }
        return resp;
    }
    private class fsvpObj{
        Double transactionFeeTarget;
        Double transactionFeeBottomUp;
        Double mainOperatingBankTarget;
        Double mainOperatingBankBottomUp;
        Double dealBaseFeeTarget;
        Double dealBaseFeeBottomUp;
        Double totalTarget;
        Double totalBottomUp;
        public fsvpObj(Double transactionFeeTarget,Double transactionFeeBottomUp,Double mainOperatingBankTarget,Double mainOperatingBankBottomUp,Double dealBaseFeeTarget,Double dealBaseFeeBottomUp){   
            this.transactionFeeTarget = transactionFeeTarget;
            this.transactionFeeBottomUp = transactionFeeBottomUp;
            this.mainOperatingBankTarget = mainOperatingBankTarget;
            this.mainOperatingBankBottomUp = mainOperatingBankBottomUp;
            this.dealBaseFeeTarget = dealBaseFeeTarget;
            this.dealBaseFeeBottomUp = dealBaseFeeBottomUp;
            this.totalTarget = transactionFeeTarget + mainOperatingBankTarget + dealBaseFeeTarget;
            this.totalBottomUp = transactionFeeBottomUp + mainOperatingBankBottomUp + dealBaseFeeBottomUp;
        }
    }
    @RemoteAction
    public static ModelExtensions.CRUDCustomBottomUpAnnualizedResponse queryFSVPTargetTable(ModelExtensions.QueryObj qobj) {
        ModelExtensions.CRUDCustomBottomUpAnnualizedResponse resp = new ModelExtensions.CRUDCustomBottomUpAnnualizedResponse();
        Map<String,List<String>> fsvpEmployeeIDTeamRCCode = new Map<String,List<String>>();
        List<FSVP_Teams__c>fsvpTeams = [SELECT Employee_ID__c,Id,Name,RC_Code__c FROM FSVP_Teams__c];
        Set<String> fsvpEmployeeIDs = new Set<String>();
        for(FSVP_Teams__c fsvpTeam : fsvpTeams){
            fsvpEmployeeIDs.add(fsvpTeam.Employee_ID__c);
        }
        String fsvpQuery = 'SELECT Id,Name,Employee_ID__c FROM User WHERE Employee_ID__c IN: fsvpEmployeeIDs';
        List<User> fsvpUsers = Database.query(fsvpQuery);
        Map<String,User> fsvpMap = new Map<String,User>();
        for(User fsvpUser : fsvpUsers){
            fsvpMap.put(fsvpUser.Employee_ID__c,fsvpUser);
        }
        for(FSVP_Teams__c fsvpTeam:fsvpTeams){
            Set<String>fsvpEmployeeIDKeys = fsvpEmployeeIDTeamRCCode.keySet();
            if(!fsvpEmployeeIDKeys.contains(fsvpTeam.Employee_ID__c)){
                fsvpEmployeeIDTeamRCCode.put(fsvpTeam.Employee_ID__c,new List<String>());
            }
            fsvpEmployeeIDTeamRCCode.get(fsvpTeam.Employee_ID__c).add(fsvpTeam.RC_Code__c);
        }
        for(String fsvpEmployeeID : fsvpEmployeeIDTeamRCCode.keySet()){
        }
        Map<String,fsvpObj> teamRCCodeFSVPObj = new Map<String,fsvpObj>();
        String currentYear = getThisYear();
        AggregateResult[] groupedResults = [SELECT Team_Name__r.RC_Code__c teamRCCode,SUM(Transaction_Fee_Target_Sum__c)transactionFeeTarget,SUM(Transaction_Fee_Team_Bottom_Up_Sum__c)transactionFeeBottomUp,SUM(Main_Operating_Bank_Target_Sum__c)mainOperatingBankTarget,SUM(Main_Operating_Bank_Team_Bottom_Up_Sum__c)mainOperatingBankBottomUp,SUM(Deal_Base_Fee_Target_Sum__c)dealBaseFeeTarget,SUM(Deal_Base_Fee_Team_Bottom_Up_Sum__c)dealBaseFeeBottomUp FROM Team_Target__c WHERE Year__c =: currentYear GROUP BY Team_Name__r.RC_Code__c];
            for (AggregateResult ar : groupedResults)  {
                Set<String>teamRCCodeKeys = teamRCCodeFSVPObj.keySet();
                teamRCCodeFSVPObj.put(String.valueOf(ar.get('teamRCCode')),new fsvpObj(Double.valueOf(ar.get('transactionFeeTarget')),
                        Double.valueOf(ar.get('transactionFeeBottomUp')),
                        Double.valueOf(ar.get('mainOperatingBankTarget')),
                        Double.valueOf(ar.get('mainOperatingBankBottomUp')),
                        Double.valueOf(ar.get('dealBaseFeeTarget')),
                        Double.valueOf(ar.get('dealBaseFeeBottomUp'))
                        ));
        }
        for(String key : teamRCCodeFSVPObj.keySet()){
        }
        List<ModelExtensions.targetTableRecord>targetTableRecords = new List<ModelExtensions.targetTableRecord>();
        for(String key:fsvpEmployeeIDTeamRCCode.keySet()){
            Double transactionFeeTarget = 0;
            Double transactionFeeBottomUp = 0;
            Double mainOperatingBankTarget = 0;
            Double mainOperatingBankBottomUp = 0;
            Double dealBaseFeeTarget = 0;
            Double dealBaseFeeBottomUp = 0;
            String fsvpName = fsvpMap.get(key).Name;
            String fsvpID = fsvpMap.get(key).Id;
            Double totalBottomUp = 0;
            Double totalMiracle = 0;
            for(String teamRCCode : fsvpEmployeeIDTeamRCCode.get(key)){
                if(teamRCCodeFSVPObj.containsKey(teamRCCode)) {
                	fsvpObj fsvp = teamRCCodeFSVPObj.get(teamRCCode);
	                transactionFeeTarget += fsvp.transactionFeeTarget;
	                transactionFeeBottomUp += fsvp.transactionFeeBottomUp;
	                mainOperatingBankTarget += fsvp.mainOperatingBankTarget;
	                mainOperatingBankBottomUp += fsvp.mainOperatingBankBottomUp;
	                dealBaseFeeTarget += fsvp.dealBaseFeeTarget;
	                dealBaseFeeBottomUp += fsvp.dealBaseFeeBottomUp;
	                totalBottomUp += fsvp.totalBottomUp;
	                totalMiracle += fsvp.totalTarget;
                }
            }
            ModelExtensions.targetTableRecord targetTableRecord = new ModelExtensions.targetTableRecord(
                    fsvpName,
                    fsvpID,
                    transactionFeeTarget,
                    transactionFeeBottomUp,
                    mainOperatingBankTarget,
                    mainOperatingBankBottomUp,
                    dealBaseFeeTarget,
                    dealBaseFeeBottomUp,
                    totalBottomUp,
                    totalMiracle);
            targetTableRecords.add(targetTableRecord);
        }
        for(ModelExtensions.targetTableRecord targetTableRecord:targetTableRecords){
            resp.records.add(targetTableRecord);
        }
        if(!qobj.sortParams.isEmpty() && String.isNotBlank(qobj.sortParams[0].get('property')) && String.isNotBlank(qobj.sortParams[0].get('direction'))){
            String sortProperty = qobj.sortParams[0].get('property');
            String sortDirection = qobj.sortParams[0].get('direction');
            if(sortProperty.equalsIgnoreCase('targetName')){
                ModelExtensions.SORT_BY = ModelExtensions.name_sort;
            }
            else if(sortProperty.equalsIgnoreCase('transactionFeeTarget')){
                ModelExtensions.SORT_BY = ModelExtensions.transactionFeeTarget_sort;
            }
            else if(sortProperty.equalsIgnoreCase('transactionFeeBottomUp')){
                ModelExtensions.SORT_BY = ModelExtensions.transactionFeeBottomUp_sort;
            }
            else if(sortProperty.equalsIgnoreCase('mainOperatingBankTarget')){
                ModelExtensions.SORT_BY = ModelExtensions.mainOperatingBankTarget_sort;
            }
            else if(sortProperty.equalsIgnoreCase('mainOperatingBankBottomUp')){
                ModelExtensions.SORT_BY = ModelExtensions.mainOperatingBankBottomUp_sort;
            }
            else if(sortProperty.equalsIgnoreCase('dealBaseFeeTarget')){
                ModelExtensions.SORT_BY = ModelExtensions.dealBaseFeeTarget_sort;
            }
            else if(sortProperty.equalsIgnoreCase('dealBaseFeeBottomUp')){
                ModelExtensions.SORT_BY = ModelExtensions.dealBaseFeeBottomUp_sort;
            }
            else if(sortProperty.equalsIgnoreCase('totalBottomUp')){
                ModelExtensions.SORT_BY = ModelExtensions.totalBottomUp_sort;
            }
            else if(sortProperty.equalsIgnoreCase('totalMiracle')){
                ModelExtensions.SORT_BY = ModelExtensions.totalMiracle_sort;
            }
            boolean sortASC = sortDirection.equalsIgnoreCase('ASC');
            boolean sortDESC = sortDirection.equalsIgnoreCase('DESC');
            if(sortASC){
                targetTableRecords.sort();
            }else if(sortDESC){
                targetTableRecords.sort();
                targetTableRecords = reverse(targetTableRecords);
            }
        }
        for(ModelExtensions.targetTableRecord targetTableRecord:targetTableRecords){
            resp.records.add(targetTableRecord);
        }
        return resp;
    }
    public static List<ModelExtensions.targetTableRecord> reverse(List<ModelExtensions.targetTableRecord> targetTableRecs) {
        List<ModelExtensions.targetTableRecord> tmpList = new List<ModelExtensions.targetTableRecord>();
        //List<ModelExtensions.targetTableRecord> copyOfTargetTableRecs = targetTableRecs;
        Integer size = targetTableRecs.size();
        for (Integer i = 0; i < size; i++) {
            tmpList.add(targetTableRecs.remove(targetTableRecs.size() - 1));
        }
        return tmpList;
    }
}