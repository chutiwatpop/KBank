public with sharing class TargetList_OverrideListView_Controller {

	public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Target_List__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }
}