public without sharing class CallReport_OverrideListView_Controller {
    public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Call_Report__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }
}