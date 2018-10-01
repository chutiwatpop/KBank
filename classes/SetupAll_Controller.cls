/**
* @author komsan.wi@beryl8.com
* @20/10/2015 created new
*/
public without sharing class SetupAll_Controller {
	public Setup_History__c setupall {get;set;}
	public Boolean shouldReload {get;set;}
	private String opId;
    public SetupAll_Controller(ApexPages.StandardController stdController) {
        opId = ApexPages.currentPage().getParameters().get('opid');
        shouldReload = false;
        setupall = new Setup_History__c();
        setupall.Setup_Date__c = System.Today();
        setupall.Setup_Amount__c = 0;
    }
    public SetupAll_Controller() {
    	opId = ApexPages.currentPage().getParameters().get('opid');
    	shouldReload = false;
    	setupall = new Setup_History__c();
    	setupall.Setup_Date__c = System.Today();
    	setupall.Setup_Amount__c = 0;
    }
    public void savingSetupall(){
    	shouldReload = true;
    	List<Setup_History__c> opProductUpdateList = new List<Setup_History__c>();
    	/*opProductUpdateList = [SELECT Id,Status__c FROM Setup_History__c WHERE Opportunity__c =:opId];
    	for(Setup_History__c eachOpProduct : opProductUpdateList){
    		//Setup_History__c tmpOpProduct = setupall.clone(false,true,false,false);
    		eachOpProduct.Setup_Date__c = setupall.Setup_Date__c;
    		eachOpProduct.Setup_Amount__c = setupall.Setup_Amount__c;
    		eachOpProduct.Status__c = 'Setup';

            // [Start] *** Add by Chumphon K. 23-Mar-2016 to support CR-006 Auto assign targer list to campaign NewBooking
            eachOpProduct.Front_End_Fee__c = 0;
            eachOpProduct.BA_Prosaving__c = 0;
            eachOpProduct.BA_Protection__c = 0;
            // [End] ***
    	}
    	try{
    		update opProductUpdateList;	
    	}catch(Exception ex){
            system.debug('Error savingSetupall');
            ApexPages.addMessages(ex);
    		shouldReload = false;
    	}*/
    }
}