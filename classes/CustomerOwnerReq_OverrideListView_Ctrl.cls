public without sharing class CustomerOwnerReq_OverrideListView_Ctrl {
    public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Customer_Ownership_Request__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }
}