public class SMERequestReleaseOwnership {
	public SMERequestReleaseOwnership() {
		System.debug('SMERequestReleaseOwnership');
	}

	public void calculatePrimarySegment(User ownerUser, Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest){
		if(ownerUser.Segment__c == GlobalConstants.SEGMENT_SE){
            accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM;
        }else if(ownerUser.Segment__c  == GlobalConstants.SEGMENT_ME){
            if(eachOwnerRequest.Sales_Size__c > 100000000){
                accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_UM;
            }else{
                accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
            }
        }
	}

	// public Account approveRequest(Customer_Ownership_Request__c eachOwnerRequest, Account accountRecord, User ownerUser, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap){
    //     System.debug('approveRequest');
	// 	if(eachOwnerRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP){
    //         if(eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.PORT) {
    //             accountRecord.Port_Pool__c = GlobalConstants.PORT;
    //             calculatePrimarySegment(ownerUser, accountRecord, eachOwnerRequest);
    //         }else{
    //             accountRecord.Last_CallReprt_Opty_Updated_Date__c = System.now();
    //             accountRecord.Port_Pool__c = (accountRecord.Port_Pool__c!=null)?GlobalConstants.POOL:null;
	// 			calculatePermanentOwner(accountRecord, eachOwnerRequest);
    //         }
	// 		accountRecord.Service_RM__c = null;
    //         accountRecord.OwnerId = eachOwnerRequest.OwnerId;
    //         accountRecord.Temporary_Ownership_Flag__c = false;
    //         accountRecord.OwnerChangeExecutedByTrigger__c = true;
	// 		calculatePreviousTeam(accountRecord, eachOwnerRequest, currentUser, teamStructerMapByRC, currentUserExtensionMap);                                         
			
	// 		Account_Service.callingFromYearEndBatch = false;
    //     }
	// 	return accountRecord;
    // }

	// public Account approveRelease(Customer_Ownership_Request__c eachOwnerRequest, Account accountRecord, User currentUser, User ownerUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap, Map<String,User_Mirror_Management__c> rcCodeNHTLMap, CBS_Admin_Ownership__c cbsAdmin, SME_Admin__c smeAdmin){
	// 	System.debug('approveRelease');
	// 	if(eachOwnerRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP){
	// 		if(!GlobalConstants.REFEROUT_NOT_RELEASE_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
	// 			accountRecord.OwnerChangeExecutedByTrigger__c = true;
	// 			if (eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.REASON_TM_POOL) {
	// 				Account_Service.isTMPool = true;
	// 				Account_Service.isChangeOwnership = true;
	// 				Account_Service.forceOwnerShipText = true;
	// 				accountRecord.Previous_Owner__c = null;
	// 				accountRecord.Temporary_Ownership_Flag__c = false;
	// 				accountRecord.Port_Pool__c = GlobalConstants.POOL;
	// 				accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
	// 				accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
	// 				if (eachOwnerRequest.Service_RM__c == 'Yes') {
	// 					accountRecord.Service_RM__c = eachOwnerRequest.OwnerId;
	// 				}
	// 			}else if(GlobalConstants.REFEROUT_BAD_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
	// 				accountRecord.Service_RM__c = null;
	// 				accountRecord.Previous_Owner__c = null;
	// 				if(accountRecord.RecordType.Name == GlobalConstants.ORGANIZATION_PROSPECT){
	// 					accountRecord.Port_Pool__c = null;
	// 					accountRecord.OwnerId = smeAdmin.User_Record_ID__c;
	// 				}else{
	// 					accountRecord.Trash_Pool_Flag__c = true;
	// 					accountRecord.Port_Pool__c = GlobalConstants.POOL;
	// 					accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
	// 					accountRecord.OwnerId = (currentUser.Profile.Name == GlobalConstants.SME_RM)?currentUser.ManagerId:currentUser.Id;
	// 					Account_Service.forceOwnerShipText = true;
	// 				}
	// 			}
	// 		}else {
	// 			accountRecord.Service_RM__c = null;
	// 			accountRecord.Temporary_Ownership_Flag__c = false;
	// 			accountRecord.OwnerChangeExecutedByTrigger__c = true;
	// 			accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;

	// 			if(GlobalConstants.REFEROUT_NOT_SME_CBS_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
	// 				accountRecord.Port_Pool__c = GlobalConstants.PORT;
	// 			}else{
	// 				accountRecord.Port_Pool__c = GlobalConstants.POOL;
	// 			}
				
	// 			Account_Service.isChangeOwnership = true;
	// 			Account_Service.callingFromYearEndBatch = false;
				
	// 			if(eachOwnerRequest.Current_Owner__c != null){
	// 				accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
	// 			}else{
	// 				if(GlobalConstants.REFEROUT_CBS_REASON.contains(eachOwnerRequest.Refer_Out_Reason__c)){
	// 					accountRecord.OwnerId = cbsAdmin.User_Record_ID__c;
	// 					accountRecord.Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB;
	// 				}
	// 			}
	// 			calculatePreviousTeam(accountRecord, eachOwnerRequest, ownerUser, teamStructerMapByRC, currentUserExtensionMap);  

	// 			if(currentUser != null && teamStructerMapByRC != null) {
	// 				if(!rcCodeNHTLMap.containsKey(currentUser.RC_Code__c) ){
	// 					calculatePermanentTeam(accountRecord, currentUser, teamStructerMapByRC);
	// 					calculateCurrentTeam(accountRecord, currentUser, teamStructerMapByRC);
	// 					calculatePrimarySegment(ownerUser, accountRecord, eachOwnerRequest);
	// 				}
	// 			}
	// 		}
	// 	}
	// 	return accountRecord;
	// }

	// private void calculatePermanentOwner(Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest){
	// 	if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT) {
    //         if(eachOwnerRequest.Current_Owner_TM__c!=null)
    //             accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_TM__c;
    //         else if(eachOwnerRequest.Current_Owner_AH__c!=null)
    //             accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_AH__c;
    //         else if(eachOwnerRequest.Current_Owner_NH__c!=null)
    //             accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_NH__c;
    //     }
	// }

	// private void calculatePreviousTeam(Account accountRecord, Customer_Ownership_Request__c eachOwnerRequest, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC, Map<String,Id> currentUserExtensionMap){
	// 	if(currentUserExtensionMap.containsKey(eachOwnerRequest.Current_Owner__c))
    //         accountRecord.Previous_Owner_Extension__c = currentUserExtensionMap.get(eachOwnerRequest.Current_Owner__c);

    //     if(currentUser != null && teamStructerMapByRC != null) {
    //         if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
    //             accountRecord.Previous_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
    //         if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
    //             accountRecord.Previous_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
    //         if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
    //             accountRecord.Previous_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
    //     }
	// }

	// private void calculatePermanentTeam(Account accountRecord, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC){
	// 	if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
	// 		accountRecord.Permanent_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
	// 	if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
	// 		accountRecord.Permanent_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
	// 	if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
	// 		accountRecord.Permanent_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
	// }

	// private void calculateCurrentTeam(Account accountRecord, User currentUser, Map<String,Team_Structure__c> teamStructerMapByRC){
	// 	if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
	// 		accountRecord.Current_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c).id;
	// 	if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
	// 		accountRecord.Current_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c).id;
	// 	if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
	// 		accountRecord.Current_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c).id;
	// }
}