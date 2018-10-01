@isTest
private class SME_SyncLeadToCDB_Test {
    @isTest static void testCallSME_SyncLeadToCDB(){
        Test.startTest();
            SME_SyncLeadToCDB dummyTest = new SME_SyncLeadToCDB();
            dummyTest.execute(null);
        Test.stopTest();
    }
}