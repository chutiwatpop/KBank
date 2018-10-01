/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A test class for SME_PurgeApplicationLog_Batch

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.t           First Create
------------------------------------------------------------*/
@isTest
private class SME_PurgeApplicationLog_Batch_Test {

    static testmethod void testPurgeApplicationLogBatch() {

       Application_Log__c[] multiAppLog = new List<Application_Log__c>();
       for (Integer i=0;i<10;i++) {
           Application_Log__c appLog = new Application_Log__c(
               Name = 'Application_Log__c ' + i,
               Message__c = 'Some description' + i,
               Source_Function__c = 'SFDC');
           multiAppLog.add(appLog);
       }
       insert multiAppLog;

       //System_Settings__c systemSetting = [SELECT Id, Log_Purge_Days__c FROM System_Settings__c];
       //systemSetting.Log_Purge_Days__c = 0;
       //update systemSetting;

       Test.startTest();
       SME_PurgeApplicationLog_Batch purgeBatch = new SME_PurgeApplicationLog_Batch();
       Database.executeBatch(purgeBatch);
       Test.stopTest();

       Integer i = [SELECT COUNT() FROM Application_Log__c];
       System.assertEquals(i,10);
    }
}