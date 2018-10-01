public with sharing class NewAccount_Warning_Controller {
	public String warningMessage;
	private Id existingAccountId;
	private Boolean isVisible;

	public Boolean isSF1 {
		get{
			if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
			String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
			ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
			(ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
			   ) {
				return true;
			} else{
				return false;
			}
		} set;
	}

	public NewAccount_Warning_Controller() {
		this.existingAccountId = ApexPages.currentPage().getParameters().get('existingId');
		String warningMessage = ApexPages.currentPage().getParameters().get('warningMessage');
		if(warningMessage != null) {
			showInfo(warningMessage);
			this.isVisible = true;
		} else {
			checkOwner();
		}
	}

	private void checkOwner() {
		if(this.existingAccountId == null) return;

		Integer countExisting = 0;
		countExisting = [SELECT Count() FROM Account WHERE Id = :this.existingAccountId];

		if(countExisting > 0) {
			// Visibility Owner
			warningMessage = Label.Prospect_Warning_Create_Call_Plan;
			this.isVisible = true;
		} else {
			// Invisibility Owner
			warningMessage = Label.Prospect_Warning_Request_Ownership;
			this.isVisible = false;
		}
		showInfo(warningMessage);
	}

	public PageReference actionOK() {
		PageReference pageRef;
		if(this.isVisible) {
			pageRef = new PageReference('/' + this.existingAccountId);
        	return pageRef;
		}

		// Redirect to customer search
		if(isSF1) {
			pageRef = new PageReference('/apex/CustomerSearch_Mobile');
		} else {
			pageRef = new PageReference('/apex/CustomerSearch');
		}
    	pageRef.getParameters().put('existingId', this.existingAccountId);
    	return pageRef;
	}

	public void showInfo(String msgLog) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, msgLog);
	    ApexPages.addMessage(msg);
	}
}