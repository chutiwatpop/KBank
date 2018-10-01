global class AddressInitialPinLocation_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    String query;
    String requestURL;
    String apiKey;

    global AddressInitialPinLocation_Batch() { // initial all
        initialQuery(false);
    }

    global AddressInitialPinLocation_Batch(Boolean isInitialAll) {
        initialQuery(isInitialAll);
    }

    global void initialQuery(Boolean isInitialAll) {
        Around_Pin_Config__c configValue = Around_Pin_Config__c.getOrgDefaults();
        if(configValue == null || configValue.API_KEY__c == null || configValue.Geocoding_URL__c == null) {
            throw new CIWebserviceException('No config value for Geocoding API key and/or API URL');
        } else {
            this.apiKey = configValue.API_KEY__c;
            this.requestURL = configValue.Geocoding_URL__c;
            if(isInitialAll == true) {
                this.query = 'SELECT Id,Street__c,Place__c,Alley__c,House_Number_Encrypt__c,Sub_District__c,Village_Number__c,District__c,Village__c,Province__c,Postcode__c FROM Address__c LIMIT 100000';  
            } else {
                this.query = 'SELECT Id,Street__c,Place__c,Alley__c,House_Number_Encrypt__c,Sub_District__c,Village_Number__c,District__c,Village__c,Province__c,Postcode__c FROM Address__c WHERE Need_Initial_Location__c = true LIMIT 100000';    
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Address__c> scope) {
        List<Address__c> updateList = new List<Address__c>();
        for(Address__c eachAddress : scope) {
            try { 
                GoogleGeocoding_Webservice geocodingWS = new GoogleGeocoding_Webservice(eachAddress,apiKey,requestURL);
                GoogleGeocoding_Webservice.GoogleLocation respModel = geocodingWS.calloutWebservice();
                if(respModel != null && respModel.lat != null && respModel.lng != null) {
                    eachAddress.Pin_Location__Latitude__s = respModel.lat;
                    eachAddress.Pin_Location__Longitude__s = respModel.lng;
                    eachAddress.Initial_Location_Date__c = System.now();
                    updateList.add(eachAddress);
                } else if(respModel != null && respModel.statusMsg != null) {
                    throw new CIWebserviceException(respModel.statusMsg);
                } else {
                    eachAddress.Initial_Location_Date__c = System.now();
                    updateList.add(eachAddress);
                }
            } catch (Exception e) {
                if(e.getMessage().containsIgnoreCase('Daily limit has been reached.') || e.getMessage().containsIgnoreCase('Please ensure this API is activated.')) {
                    addLog('GoogleGeocoding_Webservice', e.getMessage() + ' for Batch Job ID:' + BC.getJobId());
                    System.abortJob(BC.getJobId());
                    break;
                } else {
                    eachAddress.Initial_Location_Date__c = System.now();
                    updateList.add(eachAddress);
                    addLog('GoogleGeocoding_Webservice', e.getMessage() + ' for ID:' + eachAddress.Id);
                }
            }
        }
        clearance(updateList);
    }
    
    global void finish(Database.BatchableContext BC) {}

    @TestVisible
    private void clearance(List<Address__c> updateList){
        super.clearance();
        if(updateList.size() > 0)
            Database.update(updateList,false);
    }
    
}