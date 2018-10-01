public with sharing class AFBulkAssignmentAccountSetter implements IBulkAssignmentAccountSetter{
	public AFBulkAssignmentAccountSetter() {}

	public void setAccountInfo(Account eachAccount,Bulk_Assignment__c eachAssignment){
		if(eachAssignment.AssignmentOwner__c != null){
			eachAccount.OwnerId = eachAssignment.AssignmentOwner__c;
			eachAccount.Permanent_Owner__c = eachAssignment.Permanent_Owner__c;
			eachAccount.Port_Pool__c = eachAssignment.Port_Pool__c;
		}else{
			eachAccount.Dual_RM_Name__c = eachAssignment.Assignment_Dual_Owner__c;
			eachAccount.Port_Pool_Dual_RM__c = eachAssignment.Port_Pool_Dual_RM__c;
		}  
        eachAccount.AF_Port2__c = eachAssignment.AF_Port2__c;
        clearAFTemporaryCustomer(eachAssignment, eachAccount);
	}

	private void clearAFTemporaryCustomer(Bulk_Assignment__c eachAssignment,Account eachAccount){
		Boolean shouldclear = false;
		if(eachAssignment.Assignment_Dual_Owner__c != null && eachAssignment.Port_Pool_Dual_RM__c == GlobalConstants.PORT){
			shouldclear = true;
		}else if(eachAssignment.Assignment_Dual_Owner__c == null){
			if(isProfileAF(eachAssignment.CIS_ID__r.Owner.Profile.Name) && eachAssignment.Port_Pool__c == GlobalConstants.PORT){
				shouldclear = true;
			}
		}
		if(shouldclear){
			eachAccount.AF_Temporary_Customer__c = null; 
		}
	}

	private Boolean isProfileAF(String profileName){
		return GlobalConstants.PROFILE_AF_SET.contains(profileName);
	}
}