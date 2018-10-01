@isTest
private class LPMModel_Test {
    @isTest
    static void testTDRFlagInLPMDetailInfo() {
        LPMModel.LPMDetailInfo lpmDetail = new LPMModel.LPMDetailInfo();
        lpmDetail.TDR_F = 'Y';
        system.assertEquals('Yes', lpmDetail.TDR_F_TEXT);
        lpmDetail.TDR_F = 'N';
        system.assertEquals('No', lpmDetail.TDR_F_TEXT);
        lpmDetail.TDR_F = 'yes';
        system.assertEquals('', lpmDetail.TDR_F_TEXT);
    }
}