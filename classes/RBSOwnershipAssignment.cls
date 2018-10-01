public with sharing class RBSOwnershipAssignment implements IOwnershipAssignment {

    private Map<String,Team_Structure__c> teamStructureMapByRc;
    private Map<String,User_MaskModel> userMaskMapByEmpId;
    private Boolean isSetAccount;
	public RBSOwnershipAssignment(Map<String,User_MaskModel> userMaskMapByEmpId, Map<String,Team_Structure__c> teamStructureMapByRc) {
        this.userMaskMapByEmpId = userMaskMapByEmpId;
        this.teamStructureMapByRc = teamStructureMapByRc;
    }

	public Boolean shouldAssignAccountOwner(User_MaskModel userMask){
		Boolean sholdAssignNewOwner = false;
        return sholdAssignNewOwner;
    }

	public Id getAssignedAccountOwner(){
		return null;
	}

	public Id getAssignedJobOwner(User_MaskModel userMask){ 
		return null;
	}

	public void setBulkAssignmentInfo(BulkAssignmentWrapper bulkWrapper,Account account){
		// done nothing here
 	}

 	public Boolean isAccountSetted(){
 		return this.isSetAccount;
 	}


}