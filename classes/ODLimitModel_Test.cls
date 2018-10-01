@isTest
private class ODLimitModel_Test {
    @isTest
    static void testCallHelperInODLimitAccountInfo() {
        ODLimitModel.ODLimitAccountInfo odLimitAccount = new ODLimitModel.ODLimitAccountInfo();
        odLimitAccount.AR_ID = '0000000000';
        system.assert(odLimitAccount.AR_ID_FORMATTED != odLimitAccount.AR_ID);
    }

    @isTest
    static void testCallHelperInODLimitDetailInfo() {
        ODLimitModel.ODLimitDetailInfo odLimitDetail = new ODLimitModel.ODLimitDetailInfo();
        odLimitDetail.LMT_INT_RATE_TP_DSC = '0';
        system.assertEquals('', odLimitDetail.LMT_INT_RATE_TP_TEXT);
    }
}