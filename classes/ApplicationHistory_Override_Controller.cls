public with sharing class ApplicationHistory_Override_Controller {
    private String applicationHistoryObjPrefix;
    private Application_History__c appHistory;
    private Opportunity lookBackToOpp;
    private Map<String,ApplicationHistoryField__c> mapCusSettingMapByName;
    public ApplicationHistory_Override_Controller(ApexPages.StandardController stdController) {
        this.applicationHistoryObjPrefix = GlobalUtility.getObjectPrefixByAPIName('Application_History__c');
        appHistory = (Application_History__c)stdController.getRecord();
        if(appHistory != null  &&  appHistory.OppName__c != null){
            lookBackToOpp = [SELECT Id,Credit_Model__c,Name,Amount,RecordTypeId,Submit_Issue__c From Opportunity WHERE id = :appHistory.OppName__c LIMIT 1];
        }

        List<ApplicationHistoryField__c> appHisCustomSettingList = ApplicationHistoryField__c.getall().values();
        mapCusSettingMapByName = new Map<String,ApplicationHistoryField__c>();
        for(ApplicationHistoryField__c eachAppHisCustomSettingList : appHisCustomSettingList){
            mapCusSettingMapByName.put(eachAppHisCustomSettingList.Name, eachAppHisCustomSettingList);
        }
    }
    
    public PageReference redirect(){
        PageReference pageRef;
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id recordTypeServicingAppHistory = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Servicing_Application_History');
        Id recordTypeCreditAppHistory = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Credit_Application_History');
    
        if(currentUser.Profile.Name != null && currentUser.Profile.Name.containsIgnoreCase('CBS')){
            if(mapCusSettingMapByName.containsKey('ApplicationHistoryCBSField')){
                ApplicationHistoryField__c cbsConfig = mapCusSettingMapByName.get('ApplicationHistoryCBSField');
                pageRef = new PageReference('/'+this.applicationHistoryObjPrefix+'/e?');
                pageRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
                if(lookBackToOpp != null && cbsConfig != null && cbsConfig.OpportunityLookBackId__c != null){
                    pageRef.getParameters().put(cbsConfig.OpportunityLookBackId__c, lookBackToOpp.id);
                    pageRef.getParameters().put(cbsConfig.OpportunityLookBackNameId__c, lookBackToOpp.Name);
                    pageRef.getParameters().put(cbsConfig.Submit_Issue_Field__c, lookBackToOpp.Submit_Issue__c);
                    pageRef.getParameters().put(cbsConfig.OppAmountId__c, lookBackToOpp.Amount.toPlainString());
                }
            }
        }else{
            if(mapCusSettingMapByName.containsKey('ApplicationHistorySMEField')){
                ApplicationHistoryField__c smeConfig = mapCusSettingMapByName.get('ApplicationHistorySMEField');
                pageRef = new PageReference('/'+this.applicationHistoryObjPrefix+'/e?');
                pageRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
                if(lookBackToOpp != null && smeConfig != null && smeConfig.OpportunityLookBackId__c != null){
                    pageRef.getParameters().put(smeConfig.OpportunityLookBackId__c, lookBackToOpp.id);
                    pageRef.getParameters().put(smeConfig.OpportunityLookBackNameId__c, lookBackToOpp.Name);
                    pageRef.getParameters().put(smeConfig.Submit_Issue_Field__c, lookBackToOpp.Submit_Issue__c);
                    if(lookBackToOpp.Credit_Model__c != null && smeConfig.Credit_Model_Id__c != null){
                        pageRef.getParameters().put(smeConfig.Credit_Model_Id__c,lookBackToOpp.Credit_Model__c);
                    }
                }
            }
        }

        if(lookBackToOpp != null){
            pageRef.getParameters().put('RecordType', recordTypeCreditAppHistory);
            //if(lookBackToOpp.Submit_Issue__c == GlobalConstants.SERVICING){
            //  pageRef.getParameters().put('RecordType', recordTypeServicingAppHistory);
            //}else{
            //  pageRef.getParameters().put('RecordType', recordTypeCreditAppHistory);
            //}
        }

        pageRef.getParameters().put('nooverride', '1');
        pageRef.setRedirect(true);
        return pageRef;
    }
}