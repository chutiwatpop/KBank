public with sharing class Customer_OverrideListView_Controller {
    public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }
}