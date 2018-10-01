@isTest
private class SME_CIRestAsyncWebservice_Test
{
    @isTest
    static void testConvertProspectRequest(){
        //Create fake response
        Test.setMock(HttpCalloutMock.class, new MockSME_CIRestWebservice());

        Account account = new Account();
        account.Name = '123456789';
        account.Is_createby_Integration__c = true;
        insert account;

        List<sObject> convertList = new List<sObject>();
        convertList.add(account);

        Test.startTest();
        SME_CIRestAsyncWebservice.convertProspectRequest(convertList);
        Test.stopTest();
    }
}