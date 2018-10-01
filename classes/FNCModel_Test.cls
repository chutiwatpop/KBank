@isTest
private class FNCModel_Test {
    @isTest
    static void testCallHelperInFNCDetail() {
        FNCModel.FNCDetailInfo fncDetail = new FNCModel.FNCDetailInfo();
        system.assertEquals('', fncDetail.PD_DSC);
    }

    @isTest
    static void testFinanceServiceLimitTypeInFNCDetail() {
        FNCModel.FNCDetailInfo fncDetail = new FNCModel.FNCDetailInfo();
        fncDetail.LMT_TP_CD = '1';
        system.assertEquals('ทบทวนปีต่อปี', fncDetail.LMT_TP_CD_TYPE);
        fncDetail.LMT_TP_CD = '2';
        system.assertEquals('ชั่วคราว', fncDetail.LMT_TP_CD_TYPE);
        fncDetail.LMT_TP_CD = '3';
        system.assertEquals('เฉพาะราย', fncDetail.LMT_TP_CD_TYPE);
    }

    @isTest
    static void testLimitTypeInFNCDetailIPInFNCDetail() {
        FNCModel.FNCDetailInfo fncDetail = new FNCModel.FNCDetailInfo();
        fncDetail.PCB_LMT_IP_LIST = new FNCModel.FNCDetailIPList();
        FNCModel.FNCDetailIP ipDetail1 = new FNCModel.FNCDetailIP();
        FNCModel.FNCDetailIP ipDetail2 = new FNCModel.FNCDetailIP();
        FNCModel.FNCDetailIP ipDetail3 = new FNCModel.FNCDetailIP();

        ipDetail1.AR_OWN_TP_CD = '0';
        ipDetail2.AR_OWN_TP_CD = '1';
        ipDetail3.AR_OWN_TP_CD = '2';
        
        fncDetail.PCB_LMT_IP_LIST.PCB_LMT_IP_INF = new List<FNCModel.FNCDetailIP>{ipDetail1, ipDetail2, ipDetail3};

        system.assertEquals('กู้ร่วม(รอง)', ipDetail1.AR_OWN_TP_CD_TYPE);
        system.assertEquals('กู้ร่วม(หลัก)', ipDetail2.AR_OWN_TP_CD_TYPE);
        system.assertEquals('กู้เดี่ยว', ipDetail3.AR_OWN_TP_CD_TYPE);
    }

    @isTest
    static void testCallHelperInARDetail() {
        FNCModel.FNCDetailInfoAR arDetail = new FNCModel.FNCDetailInfoAR();
        arDetail.EFF_INT_RATE_TP_CD = '0';
        arDetail.DDC_AR_ID = '0000000000';
        system.assertEquals('', arDetail.PD_DSC);
        system.assertEquals('', arDetail.EFF_INT_RATE_TP_TEXT);
        system.assertEquals('', arDetail.AR_NM_TH_TEXT);
        system.assert(arDetail.DDC_AR_ID_FORMATTED != arDetail.DDC_AR_ID);
    }

    @isTest
    static void testFeeRateTypeInARDetail() {
        FNCModel.FNCDetailInfoAR arDetail = new FNCModel.FNCDetailInfoAR();
        arDetail.PYMT_TP_CD = '0';
        system.assertEquals('ชำระด้วยตัวเอง', arDetail.PYMT_TP_CD_TYPE);
        arDetail.PYMT_TP_CD = '2';
        system.assertEquals('หักบัญชีเงินฝากอัตโนมัติ', arDetail.PYMT_TP_CD_TYPE);
    }

    @isTest
    static void testDeductedInterestTypeInARDetail() {
        FNCModel.FNCDetailInfoAR arDetail = new FNCModel.FNCDetailInfoAR();
        arDetail.DDC_INT_TP_CD = '1';
        system.assertEquals('เก็บดอกเบี้ยล่วงหน้า', arDetail.DDC_INT_TP_CD_TYPE);
        arDetail.DDC_INT_TP_CD = '2';
        system.assertEquals('เก็บดอกเบี้ย Monthly', arDetail.DDC_INT_TP_CD_TYPE);
        arDetail.DDC_INT_TP_CD = '3';
        system.assertEquals('เก็บดอกเบี้ย ณ วันที่ครบกำหนด', arDetail.DDC_INT_TP_CD_TYPE);
    }

    @isTest
    static void testCommissionTypeInARDetail() {
        FNCModel.FNCDetailInfoAR arDetail = new FNCModel.FNCDetailInfoAR();
        arDetail.CMSN_TP_CD = '1';
        system.assertEquals('คิดตามเกณฑ์', arDetail.CMSN_TP_CD_TYPE);
        arDetail.CMSN_TP_CD = '2';
        system.assertEquals('คิดตามจริง มีค่าธรรมเนียมขั้นต่ำ', arDetail.CMSN_TP_CD_TYPE);
        arDetail.CMSN_TP_CD = '3';
        system.assertEquals('คิดตามจริง มีระยะเวลาขั้นต่ำ', arDetail.CMSN_TP_CD_TYPE);
        arDetail.CMSN_TP_CD = '7';
        system.assertEquals('คิดครั้งแรก 1 เดือน', arDetail.CMSN_TP_CD_TYPE);
    }

    @isTest
    static void testLimitTypeInARDetailIP() {
        FNCModel.FNCDetailInfoARIP ipDetail = new FNCModel.FNCDetailInfoARIP();
        ipDetail.AR_OWN_TP_CD = '0';
        system.assertEquals('กู้ร่วม(รอง)', ipDetail.AR_OWN_TP_CD_TYPE);
        ipDetail.AR_OWN_TP_CD = '1';
        system.assertEquals('กู้ร่วม(หลัก)', ipDetail.AR_OWN_TP_CD_TYPE);
        ipDetail.AR_OWN_TP_CD = '2';
        system.assertEquals('กู้เดี่ยว', ipDetail.AR_OWN_TP_CD_TYPE);
    }

    @isTest
    static void testInitialDetailInfoSHD() {
        FNCModel.FNCDetailInfoSHD shdDetail = new FNCModel.FNCDetailInfoSHD();
        system.assertEquals('', shdDetail.CNDT_STRT_DT);
        system.assertEquals('', shdDetail.PYMT_MTH_CD);
        system.assertEquals('', shdDetail.PYMT_MTH_DSC);
        system.assertEquals('', shdDetail.PNP_PYMT_FRQ_CYC_CD);
        system.assertEquals('', shdDetail.PNP_PYMT_FRQ_UNIT_CD);
        system.assertEquals('', shdDetail.PNP_PYMT_FRQ_TP_CD);
        system.assertEquals('', shdDetail.PNP_PYMT_FRQ_DAY_CD);
        system.assertEquals('', shdDetail.PNP_AMT);
        system.assertEquals('', shdDetail.INT_PYMT_FRQ_CYC_CD);
        system.assertEquals('', shdDetail.INT_PYMT_FRQ_UNIT_CD);
        system.assertEquals('', shdDetail.INT_PYMT_FRQ_TP_CD);
        system.assertEquals('', shdDetail.INT_PYMT_FRQ_DAY_CD);
        system.assertEquals('', shdDetail.INT_AMT);
    }
}