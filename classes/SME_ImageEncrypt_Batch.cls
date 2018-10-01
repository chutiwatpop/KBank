/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_ImageEncrypt_Batch implements Database.Batchable<sObject> {
    
    public static String CUSTOMER = 'SME-Customer';
    public static String customerRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CUSTOMER).GetRecordTypeId());

    public String query(){
        return  'SELECT Id,CIS__c,Encrypt_Title_TH__c,Encrypt_Title_EN__c,Encrypt_Surname_TH__c,Encrypt_Surname_EN__c,Encrypt_Name_TH__c,Encrypt_Name_EN__c,' + 
                'Encrypt_Middle_Name_TH__c,Encrypt_Middle_Name_EN__c,Encrypt_Fullname_EN__c,Encrypt_Fullname_TH__c ' +
                'FROM Account WHERE RecordtypeId = \'' + customerRecordTypeId + '\' ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query());
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            SME_ImageEncrypt_Management imageManagement = new SME_ImageEncrypt_Management();
            imageManagement.updateEncryptFields(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}