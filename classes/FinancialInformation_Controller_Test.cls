@isTest
    public class FinancialInformation_Controller_Test {

        @testSetup static void setUpCustomSettingAndLimit() {
            List<accounts__c> customSetting = new List<accounts__c>{
                new accounts__c(Name='Outstanding', EN__c='Outstanding', TH__c='ยอดหนี้'), 
                new accounts__c(Name='Limit', EN__c='Limit', TH__c='วงเงิน' ), 
                new accounts__c(Name='CREDIT_LIMIT', EN__c='CREDIT LIMIT', TH__c='วงเงิน'), 
                new accounts__c(Name='CARD_NUMBER', EN__c='CARD NUMBER', TH__c='หมายเลขบัตร'), 
                new accounts__c(Name='SPENDING', EN__c='SPENDING', TH__c='ยอด Spending ล่าสุด'), 
                new accounts__c(Name='PRINCIPLE_CARD_FLAG', EN__c='PRINCIPLE CARD FLAG', TH__c='บัตรหลัก/บัตรเสริม'), 
                new accounts__c(Name='CARD_EXPIRE_DATE', EN__c='CARD EXPIRE DATE', TH__c='วันหมดอายุ'), 
                new accounts__c(Name='MAIN_CUSTOMER_NAME', EN__c='MAIN CUSTOMER NAME', TH__c='ชื่อเจ้าของบัตรหลัก'), 
                new accounts__c(Name='DUE_DATE', EN__c='DUE DATE', TH__c='วันที่ครบกำหนดชำระ'), 
                new accounts__c(Name='CARD_TYPE', EN__c='CARD TYPE', TH__c='ประเภทบัตรเครดิต'),
                new accounts__c(Name='MIN. PAYMENT', EN__c='MIN. PAYMENT', TH__c='ยอดชำระขั้นต่ำตามรอบStatement'), 
                new accounts__c(Name='CARD_STATUS', EN__c='CARD_STATUS', TH__c='สถานะบัตร'), 
                new accounts__c(Name='ACTIVATED_DATE', EN__c='ACTIVATED_DATE', TH__c='วันที่เริ่มใช้บัตร'), 
                new accounts__c(Name='CREDIT_BALANCE', EN__c='CREDIT_BALANCE', TH__c='วงเงินคงเหลือ'), 
                new accounts__c(Name='SUPPLEMENTARY NAME', EN__c='SUPPLEMENTARY NAME', TH__c='ชื่อเจ้าของบัตรเสริม') 
            };
            insert customSetting;

            List<FinancialInfoFCD__c> fcdCustomSetting = new List<FinancialInfoFCD__c>{
                new FinancialInfoFCD__c(Name='Acc_No' ,EN__c= 'Acc No',TH__c='เลขทีบัญชี' ),
                new FinancialInfoFCD__c(Name='Acc_Type' ,EN__c= 'Acc Type',TH__c='ประเภทบัญชี' ),
                new FinancialInfoFCD__c(Name='Closed_Date' ,EN__c= 'Closed Date',TH__c='วันที่ปิดบัญชี' ),
                new FinancialInfoFCD__c(Name='Currency' ,EN__c= 'Currency',TH__c='สกุลเงิน' ),
                new FinancialInfoFCD__c(Name='Open_Date' ,EN__c= 'Open Date',TH__c='วันที่เปิดบัญชี' ),
                new FinancialInfoFCD__c(Name='Outstanding_CCY' ,EN__c= 'Outstanding CCY',TH__c='ยอดคงเหลือ (CCY)' ),
                new FinancialInfoFCD__c(Name='Outstanding_THB' ,EN__c= 'Outstanding THB',TH__c='ยอดคงเหลือ (THB)' ),
                new FinancialInfoFCD__c(Name='Product_Name' ,EN__c= 'Product Name',TH__c='ชื่อผลิตภัณฑ์' ),
                new FinancialInfoFCD__c(Name='Status' ,EN__c= 'Status',TH__c='สถานะ' )
            };
            insert fcdCustomSetting;
        }

        public static Account createAccount() {
            Account account = new Account();
            account.Name = 'AccountName';
            account.CIS__c = '7749454';
            account.Is_createby_Integration__c = true;
            return account;
        }

        @isTest static void testValidateResponse() {
            Account account = new Account();
            account.CIS__c = '123';
            account.Name = 'AccountName';
            account.Is_createby_Integration__c = true;
            insert account;

            ApexPages.currentPage().getParameters().put('id', account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(new ApexPages.StandardController(account));
            HttpResponse response404 = new HttpResponse();
            response404.setStatusCode(404);
            System.assertEquals(false, ctrl.validateResponse('123', response404));
            System.assertEquals(ExceptionMessage.ADAPTER_NOT_AVAILABLE, (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

            HttpResponse response503 = new HttpResponse();
            response503.setStatusCode(503);
            System.assertEquals(false, ctrl.validateResponse('123', response503));
            System.assertEquals(ExceptionMessage.ADAPTER_NOT_AVAILABLE, (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

            HttpResponse response504 = new HttpResponse();
            response504.setStatusCode(504);
            System.assertEquals(false, ctrl.validateResponse('123', response504));
            System.assertEquals(ExceptionMessage.DATABASE_NOT_AVAILABLE, (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

            HttpResponse response500 = new HttpResponse();
            response500.setStatusCode(500);
            System.assertEquals(false, ctrl.validateResponse('123', response500));
            System.assertEquals(ExceptionMessage.ADAPTER_NOT_AVAILABLE, (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));


            HttpResponse responseError = new HttpResponse();
            responseError.setStatusCode(200);
            responseError.setHeader('Content-Type', 'application/json');
            responseError.setBody('{"error":{"message":"error message"}}');
            System.assertEquals(false, ctrl.validateResponse('123', responseError));
            System.assertEquals('error message', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));
        }

        public static FinancialInformation_Controller processNonCreditDetailDataContinuation(String productName) {
            Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis','444');
            ApexPages.currentPage().getParameters().put('productName',productName);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            Continuation continuation = (Continuation)ctrl.requestNonCreditDetailData();
            Map<String, HttpRequest> requests = continuation.getRequests();
            System.assertEquals(1, requests.size());
            System.assert(requests.get(ctrl.requestLabelMap.get(productName)) != null);
            Test.setContinuationResponse(ctrl.requestLabelMap.get(productName), MockHttpResponseGenerator.getNonCreditDetailDataResponse(productName));
            Object result = Test.invokeContinuationMethod(ctrl, continuation);
            System.assertEquals(null, result);
            return ctrl;
        }
        public static FinancialInformation_Controller processCreditDetailDataContinuation(String productName) {
            Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis','444');
            ApexPages.currentPage().getParameters().put('productName',productName);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.currentDate = Datetime.newInstance(2016,12,26);
            Continuation continuation = (Continuation)ctrl.requestCreditDetailData();
            Map<String, HttpRequest> requests = continuation.getRequests();
            System.assertEquals(1, requests.size());
            System.assert(requests.get(ctrl.requestLabelMap.get(productName)) != null);
            Test.setContinuationResponse(ctrl.requestLabelMap.get(productName), MockHttpResponseGenerator.getCreditDetailDataResponse(productName));
            Object result = Test.invokeContinuationMethod(ctrl, continuation);
            System.assertEquals(null, result);
            return ctrl;
        }
        @isTest static void testRequestCreidtCardCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processCreditDetailDataContinuation('CC');

            System.assert(ctrl.responseMap.get('CC') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('CC');
            System.assertEquals('441770******1943', dataList.get(0).get(0) );
            System.assertEquals('Platinum', dataList.get(0).get(1));
            System.assertEquals('07/12/2554', dataList.get(0).get(2));
            System.assertEquals('85,000.00', dataList.get(0).get(3));
            System.assertEquals('85,000.67', dataList.get(0).get(4));
            System.assertEquals('-0.67', dataList.get(0).get(5));
            System.assertEquals('25/01/2560', dataList.get(0).get(6));
            System.assertEquals('บัตรหลัก', dataList.get(0).get(7));
            System.assertEquals('ก.ค.-17', dataList.get(0).get(8));
            System.assertEquals('INACTIVE-ACCOUNT', dataList.get(0).get(9));

            System.assertEquals('441770******1944', dataList.get(1).get(0) );
            System.assertEquals('441770******1945', dataList.get(2).get(0) );
        }
        @isTest static void testRequestKECCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processCreditDetailDataContinuation('KEC');
            System.assert(ctrl.responseMap.get('KEC') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('KEC');
            System.assertEquals('441770******1943', dataList.get(0).get(0) );
            System.assertEquals('30/12/2559', dataList.get(0).get(6) );
            System.assertEquals('ROBINSON CARD', dataList.get(0).get(1));
            System.assertEquals('441770******1944', dataList.get(1).get(0) );
            System.assertEquals('441770******1945', dataList.get(2).get(0) );
    
        }

       @isTest static void testRequestMutualFundNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Mutual_Fund');
            System.assert(ctrl.responseMap.get('Mutual_Fund') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Mutual_Fund');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('0011004482-2', dataList.get(0).get(1));
            System.assertEquals('10.00', dataList.get(0).get(5));
        }
     
        @isTest static void testRequestTaweesupNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Taweesup');
            System.assert(ctrl.responseMap.get('Taweesup') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Taweesup');
            System.assertEquals('XXX-2-0033-X', dataList.get(0).get(0));
            System.assertEquals('4,138,436.96', dataList.get(0).get(3));
        }

        @isTest static void testRequestFixedNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Fixed_Deposit');
            System.assert(ctrl.responseMap.get('Fixed_Deposit') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Fixed_Deposit');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('0011004482-2', dataList.get(0).get(1));
            System.assertEquals('10.00', dataList.get(0).get(3));
        }

        @isTest static void testRequestSavingNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Saving');
            System.assert(ctrl.responseMap.get('Saving') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Saving');
            System.assertEquals('XXX-2-0033-X', dataList.get(0).get(0));
            System.assertEquals('4,138,436.96', dataList.get(0).get(2));
            System.assertEquals('XXX-2-9459-X', dataList.get(1).get(0));
            System.assertEquals('2,664,630.23', dataList.get(1).get(2));
        }

        @isTest static void testRequestCurrentNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Current');
            System.assert(ctrl.responseMap.get('Current') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Current');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('10,000.00', dataList.get(0).get(2));
        }
        
        @isTest static void testSetupKBankStmData() {
            Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            KBANK_STM__c stm01 = new KBANK_STM__c();
            stm01.Name = '01';
            stm01.Amount_Inflow__c = 10;
            stm01.Amount_Outflow__c = 20;
            stm01.CIS_ID__c = account.Id;
            insert stm01;
            
            KBANK_STM__c stm02 = new KBANK_STM__c();
            stm02.Name = '02';
            stm02.Amount_Inflow__c = 20;
            stm02.Amount_Outflow__c = 10;
            stm02.CIS_ID__c = account.Id;
            insert stm02;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupKBankStmData();

            System.assertEquals(14, ctrl.kbankSTMHeader.size());
            System.assertEquals('Statement', ctrl.kbankSTMHeader.get(0));
            System.assertEquals('Summary 12 Months', ctrl.kbankSTMHeader.get(1));

            System.assertEquals(9, ctrl.kbankSTMData.size());
            System.assertEquals('Amount Inflow', ctrl.kbankSTMData.get(0).get(0));
            System.assertEquals('30.00', ctrl.kbankSTMData.get(0).get(1));
            System.assertEquals('10.00', ctrl.kbankSTMData.get(0).get(2));
            System.assertEquals('20.00', ctrl.kbankSTMData.get(0).get(3));

            System.assertEquals('Amount Outflow', ctrl.kbankSTMData.get(1).get(0));
            System.assertEquals('30.00', ctrl.kbankSTMData.get(1).get(1));
            System.assertEquals('20.00', ctrl.kbankSTMData.get(1).get(2));
            System.assertEquals('10.00', ctrl.kbankSTMData.get(1).get(3));

            System.assertEquals('CASA Avg. Balance', ctrl.kbankSTMData.get(2).get(0));
            System.assertEquals('Cheque (Items)', ctrl.kbankSTMData.get(3).get(0));
            System.assertEquals('Cheque Amount', ctrl.kbankSTMData.get(4).get(0));
            System.assertEquals('Cheque Return (Items)', ctrl.kbankSTMData.get(5).get(0));
            System.assertEquals('Cheque Return Amount', ctrl.kbankSTMData.get(6).get(0));
            System.assertEquals('TXN Inflow', ctrl.kbankSTMData.get(7).get(0));
            System.assertEquals('TXN Outflow', ctrl.kbankSTMData.get(8).get(0));
        }
        

        @isTest static void testSetupUtilizationData() {
            Account account = new Account();
            account.Name = 'AccountName';
            account.CIS__c = '7749454';
            account.Is_createby_Integration__c = true;
            insert account;

            Utilization__c utilization1 = new Utilization__c();
            utilization1.CIS_ID__c = account.Id;
            utilization1.Name = '01';
            utilization1.OD_Limit__c = 1;
            utilization1.OD_AVG_OUT__c = 2;
            utilization1.OD_Utilization__c = 3;
            utilization1.PN_Limit__c = 4;
            utilization1.PN_AVG_OUT__c = 5;
            utilization1.PN_Utilization__c = 6;
            utilization1.TF_Limit__c = 7;
            utilization1.TF_AVG_OUT__c = 8;
            utilization1.TF_Utilization__c = 9;
            insert utilization1;

            Utilization__c utilization2 = new Utilization__c();
            utilization2.CIS_ID__c = account.Id;
            utilization2.Name = '02';
            utilization2.OD_Limit__c = 1;
            utilization2.OD_AVG_OUT__c = 2;
            utilization2.OD_Utilization__c = 3;
            utilization2.PN_Limit__c = 4;
            utilization2.PN_AVG_OUT__c = 5;
            utilization2.PN_Utilization__c = 6;
            utilization2.TF_Limit__c = 7;
            utilization2.TF_AVG_OUT__c = 8;
            utilization2.TF_Utilization__c = 9;
            insert utilization2;

            Utilization__c utilization3 = new Utilization__c();
            utilization3.CIS_ID__c = account.Id;
            utilization3.Name = '03';
            utilization3.OD_Limit__c = 1;
            utilization3.OD_AVG_OUT__c = 2;
            utilization3.OD_Utilization__c = 3;
            utilization3.PN_Limit__c = 4;
            utilization3.PN_AVG_OUT__c = 5;
            utilization3.PN_Utilization__c = 6;
            utilization3.TF_Limit__c = 7;
            utilization3.TF_AVG_OUT__c = 8;
            utilization3.TF_Utilization__c = 9;
            insert utilization3;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupUtilizationData();
            System.assertEquals(12, ctrl.utilizationData.headerList.size());
            System.assertEquals(3, ctrl.utilizationData.utilizationMap.size());
            System.assertEquals('OD', ctrl.utilizationData.utilizationMap.get('OD').productName);
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').limitList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').limitValueList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').outstandingList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').utilizationList.size());

            System.debug('utilizationData :'+ctrl.utilizationData);
        }

        @isTest static void testRequestFinancialInformation() {
            Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis','444');
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupFinancialData();
            //System.debug('Debug - ctrl ::'+ctrl);
            // System.debug('Debug - (Continuation)ctrl.requestFinancialInformation() ::'+(Continuation)ctrl.requestFinancialInformation());
            Continuation continuation = (Continuation)ctrl.requestFinancialInformation();
            Map<String, HttpRequest> requests = continuation.getRequests();
            System.assertEquals(3, requests.size());
            System.assert(requests.get(ctrl.requestLabelMap.get('creditData')) != null);
            System.assert(requests.get(ctrl.requestLabelMap.get('nonCreditData')) != null);
            System.assert(requests.get(ctrl.requestLabelMap.get('FCD')) != null);
            Test.setContinuationResponse(ctrl.requestLabelMap.get('creditData'), MockHttpResponseGenerator.getCreditResponse());
            Test.setContinuationResponse(ctrl.requestLabelMap.get('nonCreditData'), MockHttpResponseGenerator.getNonCreditResponse());
            Test.setContinuationResponse(ctrl.requestLabelMap.get('FCD'), MockHttpResponseGenerator.getCreditResponse());
            Object result = Test.invokeContinuationMethod(ctrl, continuation);
            System.assertEquals(null, result);

            Map<String, Object> nonCreditDataMap = (Map<String, Object>)ctrl.responseMap.get('nonCreditData');
            System.assertEquals('12,395,320.34', (String)nonCreditDataMap.get('Saving_Outstanding'));
            System.assertEquals('20,000.00', (String)nonCreditDataMap.get('Current_Outstanding'));

            Map<String, String> creditDataMap = (Map<String, String>)ctrl.responseMap.get('creditData');
            System.assertEquals('12,395,320.34', creditDataMap.get('LN_Outstanding'));
            System.assertEquals('20,000.00', creditDataMap.get('TP_Outstanding'));
        }

        @isTest static void testSetupFinancialData() {
            Account account = new Account();
            account.Name = 'AccountName';
            account.CIS__c = '7749454';
            account.Is_createby_Integration__c = true;
            insert account;

            Financial_Information__c financialInfo1 = new Financial_Information__c();

            financialInfo1.HL_Limit__c = 20;
            financialInfo1.LI_Limit__c = 30;
            financialInfo1.LN_Limit__c = 35;
            financialInfo1.OD_Limit__c = 40;
            financialInfo1.PN_Limit__c = 50;
            financialInfo1.TF_Limit__c = 70;
            financialInfo1.CIS_ID__c = account.Id;
            insert financialInfo1;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis',account.CIS__c);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupFinancialData();
            System.assertEquals('35.00', ctrl.financialInformationData.creditData.get('LN').get(0));
            System.assertEquals('40.00', ctrl.financialInformationData.creditData.get('OD').get(0));
            System.assertEquals('50.00', ctrl.financialInformationData.creditData.get('PN').get(0));
            System.assertEquals('70.00', ctrl.financialInformationData.creditData.get('TF').get(0));
            System.assertEquals('30.00', ctrl.financialInformationData.creditData.get('LI').get(0));
            System.assertEquals('20.00', ctrl.financialInformationData.creditData.get('HL').get(0));
          //  System.assertEquals('10.00', ctrl.financialInformationData.creditData.get('CC').get(0));
        }

        @isTest static void testLimitOSTDataMap(){
            Account account = new Account();
            account.Name = 'AccountName';
            account.CIS__c = '7749454';
            account.Is_createby_Integration__c = true;
            insert account;

            Financial_Information__c financialInfo1 = new Financial_Information__c();
            financialInfo1.CC_Limit__c = 10;
            financialInfo1.CIS_ID__c = account.Id;
            insert financialInfo1;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis',account.CIS__c);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.handleCreditData(MockHttpResponseGenerator.getCreditResponse());

        }

        // This this class just do the code coverage / other test already assert 
        @isTest static void testInitData() {
            Account account = new Account();
            account.Name = 'AccountName';
            account.CIS__c = '7749454';
            account.Is_createby_Integration__c = true;
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.initData();
        }
    }