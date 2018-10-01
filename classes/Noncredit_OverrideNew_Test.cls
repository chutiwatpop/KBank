@isTest
public class Noncredit_OverrideNew_Test {

    // Mock data for test
    @testSetup static void setupMockData() {
        Test.startTest();

        // Mock account Object
        Account accMock = Mockup_Test.newAccountObj('AccMock1', GlobalConstants.PORT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        insert accMock; 

        // Mock callReport Object
        Call_Report__c callReportItem = new Call_Report__c(
            Recommend_Product__c = 'K PLUS SME\nK PLUS SHOP\nPromptPay\nEDC/mPOS',
            Allow_New_Non_Credit__c = false,
            Non_Credit__c = true,
            CIS_ID__c = accMock.Id
        );
        insert callReportItem;

        // Mock data for allSMEProductMasterList
        List<Product_List_Master__c> smeProducts = Test.loadData(Product_List_Master__c.sObjectType, 'smeproductmock');
        RecordType smeRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'For_SME' LIMIT 1];
        for(Integer i = 0; i < smeProducts.size(); i++) {
            smeProducts.get(i).RecordTypeId = smeRecordType.Id; 
        }
        update smeProducts;
    }

    @isTest static void instanceNewObjectWithoutCallReportThenIsNocallReportSet() {
        // Given
        ApexPages.currentPage().getParameters().put('CallReportId', '');
        MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mockrequest);

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();      

        // Then isNocallreport flag = true
        System.assertEquals(noncreditController.isNoCallReport, true);
    }

    private static void mockCallReportRequestParam() {
        Call_Report__c callReportMock = [SELECT Id FROM Call_Report__c LIMIT 1];
        system.debug(System.LoggingLevel.INFO, 'Selected call report from mock : ' + callReportMock.Id);
        ApexPages.currentPage().getParameters().put('CallReportId', callReportMock.Id);
        MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mockrequest);
    }


    @isTest static void instanceNewObjectWithCallReportThenAllObjectReady() {
        // Given
        mockCallReportRequestParam();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then isNocallreport flag = false and other initial object is not null such as 
        // Product, Product's answer, Product list wrapper
        System.assertEquals(noncreditController.isNoCallReport, false);
        System.assert(noncreditController.callResultsByProductId != null);
        System.assert(noncreditController.reasonSetMapByProductIdCallResult != null);
        System.assert(noncreditController.isRequiredRemarkMapByProductIdCallResultReason != null);
        System.assert(noncreditController.recommendProductList != null);
        System.assert(noncreditController.productWrapperList != null);
    }

    @isTest static void defaultRecommendedProductFromCallPlan() {
        // Given
        mockCallReportRequestParam();
        String productsJson = '[{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUHUA2"},"Id":"a2J5D0000000NUHUA2","Name":"PM-100126","Product_Name__c":"K PLUS SME","Is_Active__c":true,"Priority__c":1,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUIUA2"},"Id":"a2J5D0000000NUIUA2","Name":"PM-100127","Product_Name__c":"K PLUS SHOP","Is_Active__c":true,"Priority__c":2,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUJUA2"},"Id":"a2J5D0000000NUJUA2","Name":"PM-100128","Product_Name__c":"PromptPay","Is_Active__c":true,"Priority__c":3,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUKUA2"},"Id":"a2J5D0000000NUKUA2","Name":"PM-100129","Product_Name__c":"EDC/mPOS","Is_Active__c":true,"Priority__c":5,"RecordTypeId":"0125D0000008YpnQAE"}]';
        List<Product_List_Master__c> expectedProducts = (List<Product_List_Master__c>) JSON.deserialize(productsJson, List<Product_List_Master__c>.class);

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then
        System.assertEquals(expectedProducts.get(0).Product_Name__c, noncreditController.recommendProductList.get(0).Product_Name__c);
        System.assertEquals(expectedProducts.get(1).Product_Name__c, noncreditController.recommendProductList.get(1).Product_Name__c);
        System.assertEquals(expectedProducts.get(2).Product_Name__c, noncreditController.recommendProductList.get(2).Product_Name__c);
        System.assertEquals(expectedProducts.get(3).Product_Name__c, noncreditController.recommendProductList.get(3).Product_Name__c);
    }

    @isTest static void defaultRecommendedProductFromProductMaster() {
        // Given
        mockCallReportRequestParam();

        Call_Report__c callReport = [SELECT Recommend_Product__c FROM Call_Report__c LIMIT 1];
        callReport.Recommend_Product__c = '';
        update callReport;

        String productsJson = '[{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUHUA2"},"Id":"a2J5D0000000NUHUA2","Name":"PM-100126","Product_Name__c":"K PLUS SME","Is_Active__c":true,"Priority__c":1,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUIUA2"},"Id":"a2J5D0000000NUIUA2","Name":"PM-100127","Product_Name__c":"K PLUS SHOP","Is_Active__c":true,"Priority__c":2,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUJUA2"},"Id":"a2J5D0000000NUJUA2","Name":"PM-100128","Product_Name__c":"PromptPay","Is_Active__c":true,"Priority__c":3,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUKUA2"},"Id":"a2J5D0000000NUKUA2","Name":"PM-100129","Product_Name__c":"EDC/mPOS","Is_Active__c":true,"Priority__c":5,"RecordTypeId":"0125D0000008YpnQAE"}]';
        List<Product_List_Master__c> expectedProducts = (List<Product_List_Master__c>) JSON.deserialize(productsJson, List<Product_List_Master__c>.class);

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then
        System.assertEquals(expectedProducts.get(0).Product_Name__c, noncreditController.recommendProductList.get(0).Product_Name__c);
        System.assertEquals(expectedProducts.get(1).Product_Name__c, noncreditController.recommendProductList.get(1).Product_Name__c);
        System.assertEquals(expectedProducts.get(2).Product_Name__c, noncreditController.recommendProductList.get(2).Product_Name__c);
        System.assertEquals(expectedProducts.get(3).Product_Name__c, noncreditController.recommendProductList.get(3).Product_Name__c);
    }

    @isTest static void defaultRecommendedProductFromCallMasterAndProductMaster() {
        // Given
        mockCallReportRequestParam();

        Call_Report__c callReport = [SELECT Recommend_Product__c FROM Call_Report__c LIMIT 1];
        callReport.Recommend_Product__c = 'K PLUS SME\nK PLUS SHOP';
        update callReport;

        String productsJson = '[{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUHUA2"},"Id":"a2J5D0000000NUHUA2","Name":"PM-100126","Product_Name__c":"K PLUS SME","Is_Active__c":true,"Priority__c":1,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUIUA2"},"Id":"a2J5D0000000NUIUA2","Name":"PM-100127","Product_Name__c":"K PLUS SHOP","Is_Active__c":true,"Priority__c":2,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUJUA2"},"Id":"a2J5D0000000NUJUA2","Name":"PM-100128","Product_Name__c":"PromptPay","Is_Active__c":true,"Priority__c":3,"RecordTypeId":"0125D0000008YpnQAE"},{"attributes":{"type":"Product_List_Master__c","url":"/services/data/v41.0/sobjects/Product_List_Master__c/a2J5D0000000NUKUA2"},"Id":"a2J5D0000000NUKUA2","Name":"PM-100129","Product_Name__c":"EDC/mPOS","Is_Active__c":true,"Priority__c":5,"RecordTypeId":"0125D0000008YpnQAE"}]';
        List<Product_List_Master__c> expectedProducts = (List<Product_List_Master__c>) JSON.deserialize(productsJson, List<Product_List_Master__c>.class);

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then
        System.assertEquals(expectedProducts.get(0).Product_Name__c, noncreditController.recommendProductList.get(0).Product_Name__c);
        System.assertEquals(expectedProducts.get(1).Product_Name__c, noncreditController.recommendProductList.get(1).Product_Name__c);
        System.assertEquals(expectedProducts.get(2).Product_Name__c, noncreditController.recommendProductList.get(2).Product_Name__c);
        System.assertEquals(expectedProducts.get(3).Product_Name__c, noncreditController.recommendProductList.get(3).Product_Name__c);
    }

    private static void mockPriorityProductToCallReport() {
        Call_Report__c callReportMock = [SELECT Id FROM Call_Report__c LIMIT 1];
        // Mock non credit product 
        List<Cross_Selling_Products__c> productsListAtCallReport = new List<Cross_Selling_Products__c>();
        Cross_Selling_Products__c productAtCallReport = new Cross_Selling_Products__c();
        productAtCallReport.Call_Plan_Call_Report__c = callReportMock.Id;
        productAtCallReport.Product_Name1__c = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'K PLUS SME' LIMIT 1][0].Id;
        productAtCallReport.Call_Result__c = 'CallResult';
        productsListAtCallReport.add(productAtCallReport);

        productAtCallReport = new Cross_Selling_Products__c();
        productAtCallReport.Call_Plan_Call_Report__c = callReportMock.Id;
        productAtCallReport.Product_Name1__c = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'K PLUS SHOP' LIMIT 1][0].Id;
        productAtCallReport.Call_Result__c = 'CallResult';
        productsListAtCallReport.add(productAtCallReport);

        productAtCallReport = new Cross_Selling_Products__c();
        productAtCallReport.Call_Plan_Call_Report__c = callReportMock.Id;
        productAtCallReport.Product_Name1__c = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'PromptPay' LIMIT 1][0].Id;
        productAtCallReport.Call_Result__c = 'CallResult';
        productsListAtCallReport.add(productAtCallReport);

        productAtCallReport = new Cross_Selling_Products__c();
        productAtCallReport.Call_Plan_Call_Report__c = callReportMock.Id;
        productAtCallReport.Product_Name1__c = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'EDC/mPOS' LIMIT 1][0].Id;
        productAtCallReport.Call_Result__c = 'CallResult';
        productsListAtCallReport.add(productAtCallReport);

        insert productsListAtCallReport;
    }

    @isTest static void setupProductListFromProductInCallReport() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then
        System.assertEquals(false, noncreditController.productWrapperList.get(0).isRecordEditable);
        System.assertEquals(false, noncreditController.productWrapperList.get(1).isRecordEditable);
        System.assertEquals(false, noncreditController.productWrapperList.get(2).isRecordEditable);
        System.assertEquals(false, noncreditController.productWrapperList.get(3).isRecordEditable);

    }

    @isTest static void setupProductListFromNoProductInCallReport() {
        // Given
        mockCallReportRequestParam();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();

        // Then
        System.assertEquals(true, noncreditController.productWrapperList.get(0).isRecordEditable);
        System.assertEquals(true, noncreditController.productWrapperList.get(1).isRecordEditable);
        System.assertEquals(true, noncreditController.productWrapperList.get(2).isRecordEditable);
        System.assertEquals(true, noncreditController.productWrapperList.get(3).isRecordEditable);
    }

    private static void mockResultAnswerProduct() {
        Product_List_Master__c product = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'K PLUS SME' LIMIT 1];
        system.debug(System.LoggingLevel.INFO, 'Product Testing : ' + product);
        List<Call_Result_Non_Credit_Master__c> resultAnswerProductList = new List<Call_Result_Non_Credit_Master__c>();
        Call_Result_Non_Credit_Master__c resultAnswerProduct = new Call_Result_Non_Credit_Master__c();

        resultAnswerProduct.Cross_Selling_Products__c = product.Id;
        resultAnswerProduct.Call_Result__c = 'สนใจ';
        resultAnswerProduct.Reason__c = 'และสมัครใช้ผลิตภัณฑ์/บริการแล้ว';
        resultAnswerProduct.Required_Remark__c = false;
        resultAnswerProduct.Remark_Placeholder__c = '';
        resultAnswerProductList.add(resultAnswerProduct);

        resultAnswerProduct = new Call_Result_Non_Credit_Master__c();
        resultAnswerProduct.Cross_Selling_Products__c = product.Id;
        resultAnswerProduct.Call_Result__c = 'สนใจ';
        resultAnswerProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        resultAnswerProduct.Required_Remark__c = true;
        resultAnswerProduct.Remark_Placeholder__c = 'โปรดระบุประเภทเอกสารในช่อง Remark';
        resultAnswerProductList.add(resultAnswerProduct);

        resultAnswerProduct = new Call_Result_Non_Credit_Master__c();
        resultAnswerProduct.Cross_Selling_Products__c = product.Id;
        resultAnswerProduct.Call_Result__c = 'ไม่สนใจ';
        resultAnswerProduct.Reason__c = 'ผลิตภัณฑ์ไม่สอดคล้องกับธุรกิจของลูกค้า';
        resultAnswerProduct.Required_Remark__c = false;
        resultAnswerProduct.Remark_Placeholder__c = '';
        resultAnswerProductList.add(resultAnswerProduct);

        resultAnswerProduct = new Call_Result_Non_Credit_Master__c();
        resultAnswerProduct.Cross_Selling_Products__c = product.Id;
        resultAnswerProduct.Call_Result__c = 'ไม่สนใจ';
        resultAnswerProduct.Reason__c = 'ผลิตภัณฑ์ของธนาคารยังไม่น่าสนใจ';
        resultAnswerProduct.Required_Remark__c = false;
        resultAnswerProduct.Remark_Placeholder__c = '';
        resultAnswerProductList.add(resultAnswerProduct);

        insert resultAnswerProductList;
    }

    @isTest static void resultIsSelectedAndEditableThenReasonVisibleAndClearErrMsg() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.productWrapperList.get(0).errorMsg_CallResult = 'test error message';
        noncreditController.productWrapperList.get(0).errorMsg_Reason = 'test error message';
        noncreditController.productWrapperList.get(0).errorMsg_Remark = 'test error message';
        noncreditController.onChangeCallResult();

        // Then
        System.assert(noncreditController.productWrapperList.get(0).reasonOptions.size() > 0);
        System.assert(noncreditController.productWrapperList.get(0).errorMsg_CallResult == null);
        System.assert(noncreditController.productWrapperList.get(0).errorMsg_Reason == null);
        System.assert(noncreditController.productWrapperList.get(0).errorMsg_Remark == null);
    }

    @isTest static void resultIsNotSelectedThenReasonInvisible() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.onChangeCallResult();

        // Then
        System.assert(noncreditController.productWrapperList.get(0).reasonOptions.size() == 0);
    }

    @isTest static void reasonIsSelectedAndRemarkRequiredAndPlaceHolderExist() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        noncreditController.onChangeReason();

        // Then
        System.assertEquals(true, noncreditController.productWrapperList.get(0).isRequired_remark);
        System.assertNotEquals('', noncreditController.productWrapperList.get(0).placeHolder_remark);
    }

    @isTest static void reasonIsSelectedAndRemarkNotRequiredAndPlaceHolderNotExist() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'และสมัครใช้ผลิตภัณฑ์/บริการแล้ว';
        noncreditController.onChangeReason();

        // Then
        System.assertEquals(false, noncreditController.productWrapperList.get(0).isRequired_remark);
        System.assertEquals(null, noncreditController.productWrapperList.get(0).placeHolder_remark);
    }

    @isTest static void addProductThenKeepCorrectRemainingList() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();
        Set<String> expectedRemainingList = new Set<String>();
        expectedRemainingList.add('ATM/CDM');
        expectedRemainingList.add('Account Link');
        expectedRemainingList.add('Third Party Transfer');

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        noncreditController.addProduct();

        // Then
        System.assertEquals(expectedRemainingList, noncreditController.remain_Products);
    }

    @isTest static void removeProductThenSelectedItemShouldBeRemoved() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();
        ApexPages.currentPage().getParameters().put('removed_index', '1');
        Set<String> mockSelectedProduct = new Set<String>();
        mockSelectedProduct.add('K PLUS SME');
        mockSelectedProduct.add('PromptPay');
        mockSelectedProduct.add('EDC/mPOS');

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        noncreditController.removeProduct();

        // Then
        System.assertEquals(mockSelectedProduct, noncreditController.selected_Products);
    }

    @isTest static void validateSaveProductThenReasonIsRequired() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.save();

        // Then
        System.assertEquals(ExceptionMessage.THIS_FIELD_IS_REQUIRED, noncreditController.productWrapperList.get(0).errorMsg_Reason);
    }

    @isTest static void validateSaveProductThenRemarkIsRequired() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();
        mockPriorityProductToCallReport();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        noncreditController.onChangeReason();
        noncreditController.save();

        // Then
        System.assertEquals(ExceptionMessage.THIS_FIELD_IS_REQUIRED, noncreditController.productWrapperList.get(0).errorMsg_Remark);
    }

    @isTest static void validateSrNumberLowerThan11CharsThenSrNumberInvalid() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        noncreditController.onChangeReason();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Remark__c = 'Remark';
        noncreditController.productWrapperList.get(0).nonCreditProduct.SR_Number__c = '0123456789';
        noncreditController.save();

        // Then
        System.assertEquals(ExceptionMessage.SR_NUMBER_CHARACTERS_LIMIT, noncreditController.productWrapperList.get(0).errorMsg_SRNumber);
    }

    @isTest static void validateSrNumberHigherThan14CharsThenSrNumberInvalid() {
        // Given
        mockCallReportRequestParam();
        mockPriorityProductToCallReport();

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        noncreditController.onChangeReason();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Remark__c = 'Remark';
        noncreditController.productWrapperList.get(0).nonCreditProduct.SR_Number__c = '012345678912345';
        noncreditController.save();

        // Then
        System.assertEquals(ExceptionMessage.SR_NUMBER_CHARACTERS_LIMIT, noncreditController.productWrapperList.get(0).errorMsg_SRNumber);
    }

    private static void updateMockProduct() {
        List<Product_List_Master__c> mockProductList = [SELECT Id, Product_Name__c, Priority__c FROM Product_List_Master__c WHERE Product_Name__c IN ('K PLUS SHOP', 'PromptPay', 'EDC/mPOS')];

        for(Integer i = 0; i < mockProductList.size(); i++) {
            mockProductList.get(i).Priority__c = null;
        }

        update mockProductList;
    }

    @isTest static void saveWithoutAnyError() {
        // Given
        mockCallReportRequestParam();
        mockResultAnswerProduct();
        updateMockProduct();

        Call_Report__c callReportMock = [SELECT Id FROM Call_Report__c LIMIT 1];
        // Mock non credit product 
        List<Cross_Selling_Products__c> productsListAtCallReport = new List<Cross_Selling_Products__c>();
        Cross_Selling_Products__c productAtCallReport = new Cross_Selling_Products__c();
        productAtCallReport.Call_Plan_Call_Report__c = callReportMock.Id;
        productAtCallReport.Product_Name1__c = [SELECT Id FROM Product_List_Master__c WHERE Product_Name__c = 'K PLUS SME' LIMIT 1][0].Id;
        productAtCallReport.Call_Result__c = 'สนใจ';
        productsListAtCallReport.add(productAtCallReport);
        insert productsListAtCallReport;

        // When
        Noncredit_OverrideNew_Controller noncreditController = new Noncredit_OverrideNew_Controller();
        system.debug(System.LoggingLevel.INFO, 'Productwrapper at save point : ' + noncreditController.productWrapperList);
        ApexPages.currentPage().getParameters().put('index', '0');
        noncreditController.productWrapperList.get(0).nonCreditProduct.Call_Result__c = 'สนใจ';
        noncreditController.onChangeCallResult();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Reason__c = 'แต่ติดปัญหาเรื่องเอกสารประกอบการสมัคร';
        noncreditController.onChangeReason();
        noncreditController.productWrapperList.get(0).nonCreditProduct.Remark__c = 'Remark';
        noncreditController.productWrapperList.get(0).nonCreditProduct.SR_Number__c = '01234';

        noncreditController.save();

        // Then
        callReportMock = [SELECT Id, Allow_New_Non_Credit__c FROM Call_Report__c LIMIT 1];
        System.assertEquals(false, callReportMock.Allow_New_Non_Credit__c);
    }
}