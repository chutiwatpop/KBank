@isTest
private class CustomerWealthModel_Test {
    @isTest
    static void testCallHelperInCustWealthInfo() {
        CustomerWealthModel.CustWealthDetailInfo custWealthInfo = new CustomerWealthModel.CustWealthDetailInfo();
        custWealthInfo.AR_ID = '0000000000';
        system.assert(custWealthInfo.AR_ID != custWealthInfo.AR_ID_FORMATTED);
        custWealthInfo.AR_ID = '00000000000000';
        system.assert(custWealthInfo.AR_ID != custWealthInfo.AR_ID_FUND_FORMATTED);
        custWealthInfo.EFF_INT_RATE_TP_CD = '0';
        system.assertEquals('', custWealthInfo.EFF_INT_RATE_TP_TEXT);
    }

    @isTest
    static void testAccountTypeInCustWealthInfo() {
        CustomerWealthModel.CustWealthDetailInfo custWealthInfo = new CustomerWealthModel.CustWealthDetailInfo();
        custWealthInfo.AR_OWN_TP_CD = '0';
        system.assertEquals('บัญชีร่วมรอง', custWealthInfo.AR_OWN_TP_CD_TYPE);
        custWealthInfo.AR_OWN_TP_CD = '1';
        system.assertEquals('บัญชีร่วมหลัก', custWealthInfo.AR_OWN_TP_CD_TYPE);
        custWealthInfo.AR_OWN_TP_CD = '2';
        system.assertEquals('บัญชีเดี่ยว', custWealthInfo.AR_OWN_TP_CD_TYPE);
    }
    
    @isTest
    static void testTermFieldInCustWealthInfo() {
        CustomerWealthModel.CustWealthDetailInfo custWealthInfo = new CustomerWealthModel.CustWealthDetailInfo();
        custWealthInfo.AR_TERM = '6';
        custWealthInfo.AR_TERM_UOM_TP_CD = 'M';
        system.assertEquals('6M', custWealthInfo.AR_TERM_TEXT);
    }

    @isTest
    static void testCallHelperInSubAccount() {
        CustomerWealthModel.CustWealthDetailInfoSubAccount subInfo = new CustomerWealthModel.CustWealthDetailInfoSubAccount();
        subInfo.SUB_EFF_INT_RATE_TP_CD = '0';
        system.assertEquals('', subInfo.SUB_EFF_INT_RATE_TP_TEXT);
    }

    @isTest
    static void testTermFieldInSubAccount() {
        CustomerWealthModel.CustWealthDetailInfoSubAccount subInfo = new CustomerWealthModel.CustWealthDetailInfoSubAccount();
        subInfo.SUB_AR_TERM = '3';
        subInfo.SUB_AR_TERM_UOM_TP_CD = 'M';
        system.assertEquals('3M', subInfo.SUB_AR_TERM_TEXT);
    }
}