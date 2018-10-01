public with sharing class HRISBulkAssignmentAccountSetter implements IBulkAssignmentAccountSetter{
	private Map<Id,User> userMap;
	public HRISBulkAssignmentAccountSetter(Map<Id,User> userMap) {
		this.userMap = userMap;
	}

	public void setAccountInfo(Account eachAccount,Bulk_Assignment__c eachAssignment){
		if(eachAssignment.AssignmentOwner__c != null){
            eachAccount.OwnerId = eachAssignment.AssignmentOwner__c;
        }
		if(eachAssignment.Permanent_Owner__c != null){
            eachAccount.Permanent_Owner__c = eachAssignment.Permanent_Owner__c;
            eachAccount.Port_Pool__c = eachAssignment.Port_Pool__c;
        }
        if(eachAssignment.Assignment_Dual_Owner__c != null){
        	eachAccount.Dual_RM_Name__c = eachAssignment.Assignment_Dual_Owner__c;
        }
        if(eachAssignment.Port_Pool_Dual_RM__c != null){
        	eachAccount.Port_Pool_Dual_RM__c = eachAssignment.Port_Pool_Dual_RM__c;
        }
        if(eachAssignment.AF_Temporary_Customer__c != null){
        	eachAccount.AF_Temporary_Customer__c = eachAssignment.AF_Temporary_Customer__c;
        }
        if(eachAssignment.SME_Temporary_Customer__c != null){
        	User eachUser = userMap.containsKey(eachAssignment.SME_Temporary_Customer__c) ? userMap.get(eachAssignment.SME_Temporary_Customer__c) : null;
        	if(eachUser != null){
        		eachAccount.SME_Temporary_Customer__c = eachUser.User_Extension__r[0].id ;
        	}
        }
	}
}