@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    public static final String SEARCH_POSITIVE = 'SEARCH_POSITIVE';
    public static final String SEARCH_ERROR_ONLY = 'SEARCH_ERROR_ONLY';
    public static final String SEARCH_PARTIAL_ERROR = 'SEARCH_PARTIAL_ERROR';
    public static final String SEARCH_STATUS_500 = 'SEARCH_STATUS_500';
    public static final String SORT_POSITIVE = 'SORT_POSITIVE';
    public static final String SORT_PARTIAL_ERROR = 'TH_FRST_NM';
    public static final String EMPTY_RESPONSE = 'EMPTY_RESPONSE';
    public static final String EMPTY_JSON = 'EMPTY_JSON';
    public static final String SORT_TYPE = 'SORT_COLUMN';
    public static final String SORT_INVALID_RESPONSE = 'SORT_INVALID_RESPONSE';
    public static final String SEARCH_INVALID_RESPONSE = 'SEARCH_INVALID_RESPONSE';
    public static final String EN_FRST_NM = 'EN_FRST_NM';
    public static final String TH_FRST_NM = 'TH_FRST_NM';
    public static final String SORT_DESC = 'DESC';
    public static final String SORT_ASC = 'ASC';
    // public static String TIME_OUT = 'TIME_OUT';
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res;
        // vary the response by req 
        String bodyStr = req.getBody();
        System.debug('bodyStr :' +bodyStr);
        if(req.getEndPoint() == SME_CIRestWebservice.CURRENT_ENDPOINT) {
            return getCurrentResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.FIXED_ENDPOINT) {
            return getFixedResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.SAVING_ENDPOINT) {
            return getSavingResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.TAWEESUP_ENDPOINT) {
            return getTaweesupResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.MUTUALFUND_ENDPOINT) {
            return getMutualFundResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.NON_CREDIT_OUTSTANDING_ENDPOINT) {
            return getNonCreditResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.CREDIT_OUTSTANDING_ENDPOINT) {
            return getCreditResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.TRANSACTBP_ENDPOINT) {
            return getTransactResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.CREDIT_CARD_ENDPOINT){
            return getCreditCardResponse();
        } else if(req.getEndPoint() == SME_CIRestWebservice.K_EXPRESS_CASH_ENDPOINT){
            return getKECResponse();
        }

        if(bodyStr.containsIgnoreCase(SEARCH_POSITIVE)){
            res = positiveSearchResponse();
        }else if(bodyStr.containsIgnoreCase(SEARCH_ERROR_ONLY)){
            res = errorSearchResponse();
        }else if(bodyStr.containsIgnoreCase(SEARCH_PARTIAL_ERROR)){
            res = partialErrorSearchResponse();
        }else if(bodyStr.containsIgnoreCase(SEARCH_STATUS_500)){
            //System.debug(SEARCH_STATUS_500);
            res = errorStatus500SearchResponse();
        }else if(bodyStr.containsIgnoreCase(SEARCH_INVALID_RESPONSE)){
            //System.debug(SEARCH_STATUS_500);
            res = invalidFormatSearchResponse();
        }else if(bodyStr.containsIgnoreCase(SORT_TYPE) && bodyStr.containsIgnoreCase(EN_FRST_NM)){
            res = positiveSortResponse();
        }else if(bodyStr.containsIgnoreCase(EN_FRST_NM) && bodyStr.containsIgnoreCase(SORT_ASC)){
            res = partialErrorSortResponse();
        //}else if(bodyStr.containsIgnoreCase(TIME_OUT)){
        //    timeoutResponse();
        }else if(bodyStr.containsIgnoreCase(TH_FRST_NM) && bodyStr.containsIgnoreCase(SORT_DESC)){
            res = invalidFormatSortResponse();
        }else if(bodyStr.containsIgnoreCase(EMPTY_RESPONSE)){
            res = emptyResponse();
        }else if(bodyStr.containsIgnoreCase(EMPTY_JSON)){
            res = emptyJson();
        }else{
            res = positiveSearchResponse();
        }
        return res;
    }

    public static HttpResponse getCreditDetailDataResponse(String productName) {
        if(productName == 'CC'){
            return getCreditCardResponse();
        }else if(productName == 'KEC'){
            return getKECResponse();
        }

        return null;
    }

    public static HttpResponse getCreditCardResponse(){
        String body = '{"returnResponse":{"creditcard":[{"CARD_NO_MASK":"441770******1943", "CARD_TP1":"99","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","DUE_DT":"25","EXP_DT":"0717","ST_CD":"2","ISMAIN":"0000000000000000","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":""}';
        body +=  ',{"CARD_NO_MASK":"441770******1944", "CARD_TP1":"99","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","MN_PYMT_AMT":"0.00","DUE_DT":"25","EXP_DT":"0717","ST_CD":"2","ISMAIN":"1111111111111111","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":"5756398"}';
        body +=  ',{"CARD_NO_MASK":"441770******1945", "CARD_TP1":"99","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","MN_PYMT_AMT":"0.00","DUE_DT":"25","EXP_DT":"","ST_CD":"2","ISMAIN":"1111111111111111","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":"5756398"}';
        body +=  ']}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;

    }
     public static HttpResponse getKECResponse(){
        String body = '{"returnResponse":{"kec":[{"CARD_NO_MASK":"441770******1943", "CARD_TP1":"01","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","DUE_DT":"30","EXP_DT":"0717","ST_CD":"2","ISMAIN":"0000000000000000","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":""}';
        body +=  ',{"CARD_NO_MASK":"441770******1944", "CARD_TP1":"01","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","MN_PYMT_AMT":"0.00","DUE_DT":"30","EXP_DT":"0717","ST_CD":"2","ISMAIN":"1111111111111111","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":"5756398"}';
        body +=  ',{"CARD_NO_MASK":"441770******1945", "CARD_TP1":"01","OPN_DT":"2554-12-07","CR_LMT_AMT":"85000.00","CRN_BAL":"-0.67","MN_PYMT_AMT":"0.00","DUE_DT":"30","EXP_DT":"","ST_CD":"2","ISMAIN":"1111111111111111","IP_ID_MAINCARD":"5756398","IP_ID_ALTCARD":"5756398"}';
        body +=  ']}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }

    public static HTTPResponse getTransactResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"transactBP":[{"APL_CRT_DT":"13012552", "BSN_CD":"003150112", "PCT_BS_PRCH_CR":"90.00", "PCT_BS_PRCH_CASH":"80.00", "PCT_BS_SALE_CR":"70.00", "PCT_BS_SALE_CASH":"60.00"  }]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HTTPResponse getCreditResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"outstanding":[{"AR_TYPE":"LN", "OST":"12395320.34"},{"AR_TYPE":"TP", "OST":"20000.00"},{"AR_TYPE":"PN", "OST":"30.00"},{"AR_TYPE":"OD", "OST":"20.00"},{"AR_TYPE":"TF", "OST":"10.00"},{"AR_TYPE":"CC", "OST":"100.00"},{"AR_TYPE":"CC_Limit", "OST":"150.00"},{"AR_TYPE":"POD", "OST":"200.00"},{"AR_TYPE":"POD_Limit", "OST":"250.00"}]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse getNonCreditResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"outstanding":[{"AR_TYPE":"SA", "OST":"12395320.34"},{"AR_TYPE":"CA", "OST":"20000.00"},{"AR_TYPE":"KA", "OST":"20000.00"},{"AR_TYPE":"FD", "OST":"20000.00"},{"AR_TYPE":"TW", "OST":"20000.00"}]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse getNonCreditDetailDataResponse(String productName) {
        if(productName == 'Current') {
            return getCurrentResponse();
        } else if(productName == 'Fixed_Deposit') {
            return getFixedResponse();
        } else if(productName == 'Saving') {
            return getSavingResponse();
        } else if(productName == 'Taweesup') {
            return getTaweesupResponse();
        } else if(productName == 'Mutual_Fund') {
            return getMutualFundResponse();
        }

        return null;
    }

    public static HttpResponse getCurrentResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"current":[{"AR_ID":"0011004482", "CRN_BAL":"10000.00"}]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse getFixedResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"fixed":[{"AR_ID":"0011004482", "SUB_AR":"0011004482-2", "CRN_BAL":"10.00"}]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse getSavingResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"saving":[{"AR_ID":"XXX-2-0033-X", "CRN_BAL":"4138436.96"},{"AR_ID":"XXX-2-9459-X","CRN_BAL":"2664630.23","HLD_BAL_AMT":"0.00"}]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse getTaweesupResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"taweesup":[{"AR_ID":"XXX-2-0033-X", "CRN_BAL":"4138436.96"}]}}');
        res.setStatusCode(200);
        return res;
        
    }

    public static HttpResponse getMutualFundResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"returnResponse":{"mutualfund":[{"AR_ID":"0011004482", "SUB_AR":"0011004482-2", "NAV":"5.00" , "UNIT_BAL":"10.00"}]}}');
        res.setStatusCode(200);
        return res;
        
    }

    public static HttpResponse positiveSearchResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"searchResponse":{"cis_id":["001O000000kfDTl1","001O000000kfDTm1"]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse errorSearchResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"searchResponse":{"errorMessage":"Mock error message"}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse errorSortResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sortResponse":{"errorMessage":"Mock error message"}}');
        res.setStatusCode(200);
        return res;
    }
    public static HttpResponse invalidFormatSortResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sortResponse44":<[{"errorMessage77":"Mock error message"}]}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse invalidFormatSearchResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sortResponse44":<[{"errorMessage77":"Mock error message"}]}');
        res.setStatusCode(200);
        return res;
    }
    public static HttpResponse errorStatus500SearchResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"searchResponse":{"cis_id":["001O000000kfDTl","001O000000kfDTm"]}}');
        res.setStatusCode(500);
        return res;
    }

    public static HttpResponse partialErrorSearchResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        String json = '{\"searchResponse\":{'+
        '\"cis_id\": [\"001O000000kfDTl\",\"001O000000kfDTm\",\"001\",\"5137447\", \"5137448\", \"2309876\"],'+
        '\"errorMessage\":\"Incomplete Response\"'+
        '}}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse partialErrorSortResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        String json = '{\"sortResponse\":{'+
        '\"cis_id\": [\"001O000000kfDTl\",\"001O000000kfDTm\",\"001\",\"5137447\", \"5137448\", \"2309876\"],'+
        '\"errorMessage\":\"Incomplete Response\"'+
        '}}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse positiveSortResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sortResponse":{"cis_id":["5137448","5137447"]}}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse emptyResponse(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(200);
        return res;
    }

    public static HttpResponse emptyJson(){
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(null);
        res.setStatusCode(200);
        return res;
    }

    //public static HttpResponse timeoutResponse(){
    //     // Create a fake response
    //    //throw System.CalloutException('IO Exception: Read timed out');
    //    HTTPResponse res = http.send(null);
    //}

}