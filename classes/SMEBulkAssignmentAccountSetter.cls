public with sharing class SMEBulkAssignmentAccountSetter implements IBulkAssignmentAccountSetter{
	
	private Map<Id,User> userMap;
	public SMEBulkAssignmentAccountSetter(Map<Id,User> userMap) {
		this.userMap = userMap;
	}

	public void setAccountInfo(Account eachAccount,Bulk_Assignment__c eachAssignment){
		if(eachAssignment.AssignmentOwner__c != null){
			eachAccount.OwnerId = eachAssignment.AssignmentOwner__c;
		}
		eachAccount.Port_Pool__c = eachAssignment.Port_Pool__c;
		eachAccount.Permanent_Owner__c = eachAssignment.Permanent_Owner__c;
		eachAccount.Service_RM__c = eachAssignment.Service_RM__c;
		eachAccount.SME_Temporary_Customer__c = getTempPoraryCustomer(eachAssignment);
	}

	private Id getTempPoraryCustomer(Bulk_Assignment__c eachAssignment){
		Id temp;
		if(eachAssignment.SME_Temporary_Customer__c != null){
        	User eachUser = userMap.containsKey(eachAssignment.SME_Temporary_Customer__c) ? userMap.get(eachAssignment.SME_Temporary_Customer__c) : null;
        	if(eachUser != null){
        		temp = eachUser.User_Extension__r[0].id ;
        	}
        }else{
        	temp = null;
        }
        return temp;
	}
}