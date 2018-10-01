public with sharing class Contact_Override_Controller {
	public String callReportId{get;set;}
	public String cisId{get;set;}
	public Contact_Override_Controller(ApexPages.StandardController stdController) {
		callReportId = ApexPages.currentPage().getParameters().get('id');
		Call_Report__c callReportObj = [SELECT Id,CIS_ID__c FROM Call_Report__c WHERE Id=:callReportId];
		cisId = callReportObj.CIS_ID__c;
	}
    /*public PageReference redirect(){
    	Call_Report__c callReportObj = [SELECT Id,CIS_ID__c FROM Call_Report__c WHERE Id=:callReportId];
        PageReference pageRef = new PageReference('/003/e?accid='+callReportObj.CIS_ID__c);
        pageRef.getParameters().put('retURL', callReportId);
        pageRef.getParameters().put('saveURL', callReportId);
        pageRef.getParameters().put('cancelURL', callReportId);
        
        //pageRef.setRedirect(true);
        return pageRef;
    }
    public void redirectMobile() {
        Call_Report__c callReportObj = [SELECT Id,CIS_ID__c FROM Call_Report__c WHERE Id=:callReportId];
        cisId = callReportObj.CIS_ID__c;
    }*/
}