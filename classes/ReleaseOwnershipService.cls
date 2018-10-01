public with sharing class ReleaseOwnershipService {
	public static String validateUserPermission(User currentUser) {
		String userSegment;
		if(GlobalConstants.PROFILE_SME_SALE_SET.contains(currentUser.Profile.Name)) {
        	userSegment = 'SME';
        } else if(GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)) {
        	userSegment = 'CBS';
        } else if(GlobalConstants.PROFILE_RBS_SALE_SET.contains(currentUser.Profile.Name)) {
        	if(currentUser.Profile.Name == GlobalConstants.RBS_TM) {
        		userSegment = 'RBS';
        	} else {
        		throw new OwnershipException(Label.RBS_CantReleaseIfNotBM);
        	}
        } else if(GlobalConstants.PROFILE_AF_SET.contains(currentUser.Profile.Name)) {
        	throw new OwnershipException(Label.AF_CantReleaseRequestOwnership);
        } else {
        	throw new OwnershipException(Label.Release_Ownership_Error_User);
        }

        return userSegment;
	}

	public static User getCurrentUserManager() {
		return [SELECT Id,IsActive,RC_Code__c,
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
            Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
	}

    public static void validateExistingOppRequest(Id accountId, Map<Id, Opportunity_Request_for_Approval__c> existingRequestMap) {
        if(existingRequestMap.containsKey(accountId)) {
            throw new RequestOwnershipService.OwnershipException(Label.Release_Ownership_Error_Opp_Pending);
        }
    }

	// Set approver and requestor field set
	public static void setRequestorApprover(Customer_Ownership_Request__c ownershipRequest, Account accountObj, User currentUser) {
        UserApproverModel currentUserWrapper = UserApproverModel.getUserApproverHierachy(currentUser);
    
        ownershipRequest.Requestor_TM__c = currentUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM});
		ownershipRequest.Requestor_AH__c = currentUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL});
		ownershipRequest.Requestor_NH__c = currentUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
		ownershipRequest.User_Admin__c	 = User_Admin__c.getOrgDefaults().User_Record_ID__c;

		// BusinessCode
		List<Business_Code__c> businessCodelist = [SELECT ID FROM Business_Code__c WHERE Name =: accountObj.Customer_s_Business_Code__c AND Segment__c = :accountObj.Owner.Segment__c LIMIT 1];
		if(businessCodelist.size() >0){
            ownershipRequest.Business_Code__c = businessCodelist.get(0).ID;
        }

        if(ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_WRONG_AREA || 
        	ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_OTHER_TEAM || 
        	ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_SME || 
        	ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_NATIONALITY || 
        	ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_CBS || 
        	ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_COMPANY_RELATED) {
        	setCrossSegmentApprover(ownershipRequest);
        } else {
            ownershipRequest.Current_Owner_TM__c = ownershipRequest.Requestor_TM__c;
            ownershipRequest.Current_Owner_AH__c = ownershipRequest.Requestor_AH__c;
            ownershipRequest.Current_Owner_NH__c = ownershipRequest.Requestor_NH__c;
            if(ownershipRequest.Refer_Out_Reason__c == GlobalConstants.REASON_TM_POOL) {
                ownershipRequest.Current_Owner__c = currentUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM, GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL, GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
            } else {
                ownershipRequest.Current_Owner__c = accountObj.OwnerId;    
            }
        }
	}
	
	private static void setCrossSegmentApprover(Customer_Ownership_Request__c ownershipRequest) {
        Map<String, User_Mirror_Management__c> nhtlMirrorSettingMapByRcCode = CustomSettingUtil.getMirrorSettingMapByUserAndMirrorRcCode();
        Id approverId = getCrossSegmentApproverId(ownershipRequest.Refer_Out_Team__c, nhtlMirrorSettingMapByRcCode);
        if(approverId != null) {
        	User approverUser = [SELECT Id,IsActive,RC_Code__c,
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
            Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id = :approverId];

            UserApproverModel approverUserWrapper = UserApproverModel.getUserApproverHierachy(approverUser);
        
	        ownershipRequest.Current_Owner_TM__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM});
			ownershipRequest.Current_Owner_AH__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL});
			ownershipRequest.Current_Owner_NH__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
			if(nhtlMirrorSettingMapByRcCode.containsKey(approverUser.RC_Code__c)){
                ownershipRequest.Is_Current_Owner_NHTL__c = true;
            }
            ownershipRequest.Current_Owner__c = approverUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.SME_TM, GlobalConstants.CBS_TM, GlobalConstants.SME_AH, GlobalConstants.OT_AH_SALES, GlobalConstants.CBS_TL, GlobalConstants.SME_NH, GlobalConstants.OT_NH_SALES});
        }
	}

	private static Id getCrossSegmentApproverId(String referTeam, Map<String, User_Mirror_Management__c> nhtlMirrorSettingMapByRcCode) {
		Id approverId;
		if(referTeam != null) {
			for(Team_Structure__c eachTeam : [SELECT Id, RC_Code__c, OwnerId, Owner.IsActive, AH_Name__r.RC_Code__c From Team_Structure__c WHERE Name = :referTeam]) {
	        	if(eachTeam.Owner.IsActive == false) {
	        		/*String nhTLRcCode;
	        		if(nhtlMirrorSettingMapByRcCode.containsKey(eachTeam.RC_Code__c)) {
	        			nhTLRcCode = nhtlMirrorSettingMapByRcCode.get(eachTeam.RC_Code__c).User_Value__c;
	    			} else if(nhtlMirrorSettingMapByRcCode.containsKey(eachTeam.AH_Name__r.RC_Code__c)) {
	    				nhTLRcCode = nhtlMirrorSettingMapByRcCode.get(eachTeam.AH_Name__r.RC_Code__c).Mirror_Value__c;
	    			}

	    			if(nhTLRcCode != null ){
	    				List<User_Extension__c> userExtList = [SELECT Id,User__c From User_Extension__c WHERE Team_Structure__r.RC_Code__c = :nhTLRcCode];
	                    if(!userExtList.isEmpty()) {
	                    	approverId = userExtList.get(0).User__c;
	                    }
	                }*/
	                throw new OwnershipException('Owner of refer team is inactive!');
	        	} else {
	        		approverId = eachTeam.OwnerId;
	        	}
	        }
	    } else {
	    	throw new OwnershipException('Refer team is invalid!');
	    }
        return approverId;
	}
}