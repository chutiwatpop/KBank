/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Convert prospect batch for gap of customer type retails

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_ConvertProspect_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private String query;

    global SME_ConvertProspect_Batch(){
        this.query = 'SELECT Id,Name,Birthdate_Registration_Date__c,RecordtypeId,RecordType.DeveloperName,Encrypt_Identification_No__c,Convert_Prospect_Date__c FROM Account WHERE (Recordtype.DeveloperName = \'' + 
                GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME + '\' OR Recordtype.DeveloperName = \'' + GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME + 
                '\') AND CIS__c = null AND Temporary_Customer__c = false';
    } 

    global SME_ConvertProspect_Batch(String queryCondition) {
        this.query = 'SELECT Id,Name,Birthdate_Registration_Date__c,RecordtypeId,RecordType.DeveloperName,Encrypt_Identification_No__c,Convert_Prospect_Date__c FROM Account' + queryCondition;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            if(scope.size() > 0){
               SME_CIRestAsyncWebservice.convertProspectRequest(scope); 
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('ERROR','SME_ConvertProspect_Batch','execute_SME_ConvertProspect_Batch',null,null,'Error when execute batch',null,ex,null);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!test.isrunningtest()){
            SME_CIRestAsyncWebservice.convertProspectWithZeroRecord('WithIdentification');
        }
    }
}