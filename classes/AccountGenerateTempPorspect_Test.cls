/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Test Class for Generate Temporary prospect
Test Class:    AccountGenerateTempPorspect_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
06/03/2018  Charnun.T           First Create
------------------------------------------------------------*/
    
@isTest
private class AccountGenerateTempPorspect_Test{
    static testmethod void  testSchedule(){
        Test.StartTest();
        AccountGenerateTempPorspect_Schedule schedule1 = new AccountGenerateTempPorspect_Schedule();      
        String timeScheduler = '0 00 1 3 * ?';
        system.schedule('Test', timeScheduler, schedule1);
        Test.stopTest();
    }
}