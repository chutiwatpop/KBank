@isTest
private class FCDResponseModel_Test {
    @isTest
    static void testCallHelperInFCDDetailInfo() {
        FCDResponseModel.FCDDetailInfo fcdInfo = new FCDResponseModel.FCDDetailInfo();
        fcdInfo.AR_ID = '0000000000';
        system.assert(fcdInfo.AR_ID != fcdInfo.AR_ID_FORMATTED);
    }
    
    @isTest
    static void testProductTypeInFCDDetailInfo() {
        FCDResponseModel.FCDDetailInfo fcdInfo = new FCDResponseModel.FCDDetailInfo();
        fcdInfo.PD_TP_CD = '1101';
        system.assertEquals('กระแสรายวัน', fcdInfo.PD_TP_CD_TXT);
        fcdInfo.PD_TP_CD = '2101';
        system.assertEquals('ออมทรัพย์', fcdInfo.PD_TP_CD_TXT);
        fcdInfo.PD_TP_CD = '3101';
        fcdInfo.AR_TERM = '6';
        fcdInfo.AR_TERM_UOM_TP_CD = 'M';
        system.assertEquals('ฝากประจำ 6M', fcdInfo.PD_TP_CD_TXT);
        fcdInfo.PD_TP_CD = '4101';
        system.assertEquals('4101', fcdInfo.PD_TP_CD_TXT);
    }
    
    @isTest
    static void testAccountTypeInFCDDetailInfo() {
        FCDResponseModel.FCDDetailInfo fcdInfo = new FCDResponseModel.FCDDetailInfo();
        fcdInfo.AR_OWN_TP_CD = '0';
        system.assertEquals('บัญชีร่วมรอง', fcdInfo.AR_OWN_TP_CD_TYPE);
        fcdInfo.AR_OWN_TP_CD = '1';
        system.assertEquals('บัญชีร่วมหลัก', fcdInfo.AR_OWN_TP_CD_TYPE);
        fcdInfo.AR_OWN_TP_CD = '2';
        system.assertEquals('บัญชีเดี่ยว', fcdInfo.AR_OWN_TP_CD_TYPE);
    }
    
    @isTest
    static void testInterestRateTypeInFCDDetailInfo() {
        FCDResponseModel.FCDDetailInfo fcdInfo = new FCDResponseModel.FCDDetailInfo();
        fcdInfo.EFF_INT_RATE_TP_ID = 'CDUSD';
        fcdInfo.EFF_SPRD_INT_RATE = '+0.25000';
        system.assertEquals('CDUSD+0.25000%', fcdInfo.EFF_INT_RATE_TP_ID_TXT);
        fcdInfo.EFF_INT_RATE_TP_ID = 'DDAUSD';
        fcdInfo.EFF_SPRD_INT_RATE = '';
        system.assertEquals('DDAUSD', fcdInfo.EFF_INT_RATE_TP_ID_TXT);
    }
}