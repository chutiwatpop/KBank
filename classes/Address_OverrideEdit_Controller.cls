public with sharing class Address_OverrideEdit_Controller {
	private ApexPages.StandardController mController;
	public Address__c ctrlAddress {get; set;}
	public Boolean isSFDCAddress {get; set;}
	private String accountId;

	public Address_OverrideEdit_Controller(ApexPages.StandardController stdController) {
		this.mController = stdController;
		this.accountId = ApexPages.currentPage().getParameters().get('CF00N28000007g1Qc_lkid');
		try {
			this.ctrlAddress = (Address__c) this.mController.getRecord();
			Address__c editAddress = [SELECT Id,CIS_ID__c,Sales_Smart_Address__c,Address_Type_SalesSmart__c,Street__c,Place__c,Alley__c,House_Number_Encrypt__c,Sub_District__c,Village_Number__c,District__c,Village__c,Province__c,Building__c,Postcode__c,Floor__c,Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :ctrlAddress.Id];
			this.accountId = editAddress.CIS_ID__c;
			if(editAddress.Sales_Smart_Address__c == null || editAddress.Sales_Smart_Address__c == false) {
				isSFDCAddress = false;
			} else isSFDCAddress = true;
		} catch (Exception e) {
		    this.ctrlAddress.Sales_Smart_Address__c = true;
		    isSFDCAddress = true;
		}
	}

	public PageReference save() {
		PageReference pageRef;
		try {
			this.mController.save();
		} catch (Exception ex) {
			System.debug('Error:' + ex.getMessage());
			return null;
		}
		return pageRef;
	}
}