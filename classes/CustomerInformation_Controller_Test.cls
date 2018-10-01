@isTest
private class CustomerInformation_Controller_Test {

    @isTest static void testValidateResponse() {
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = 'AccountName';
        account.Is_createby_Integration__c = true;
        insert account;
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        HttpResponse response404 = new HttpResponse();
        response404.setStatusCode(404);
        System.assertEquals(false, ctrl.validateResponse('123', response404));
        System.assertEquals('Adapter is not available', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

        HttpResponse response503 = new HttpResponse();
        response503.setStatusCode(503);
        System.assertEquals(false, ctrl.validateResponse('123', response503));
        System.assertEquals('Host is not available', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

        HttpResponse responseError = new HttpResponse();
        responseError.setStatusCode(200);
        responseError.setHeader('Content-Type', 'application/json');
        responseError.setBody('{"error":{"message":"error message"}}');
        System.assertEquals(false, ctrl.validateResponse('123', responseError));
        System.assertEquals('error message', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));
    }

    @isTest static void testRequestCustomerInformation() {
        
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = '123';
        account.Is_createby_Integration__c = true;
        //TriggerHandler.bypass('AccountTriggerHandler');
        insert account;
        //TriggerHandler.clearBypass('AccountTriggerHandler');

        Financial_Information__c financialInformation = new Financial_Information__c();
        financialInformation.CIS_ID__c = account.Id;
        financialInformation.PN_Limit__c = 10;
        financialInformation.OD_Limit__c = 20;
        financialInformation.TF_Limit__c = 30;
        insert financialInformation;

        Account testacc = [SELECT Id, CIS__c, Name FROM Account WHERE Id =: account.Id];
        System.debug('testacc : '+testacc.CIS__c);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('cis','123');
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        Continuation continuation = (Continuation)ctrl.requestCustomerInformation();
        Map<String, HttpRequest> requests = continuation.getRequests();
        System.assertEquals(2, requests.size());
        System.assert(requests.get(ctrl.requestLabelMap.get('interactionHistory')) != null);
        System.assert(requests.get(ctrl.requestLabelMap.get('totalDebt')) != null);
        Test.setContinuationResponse(ctrl.requestLabelMap.get('interactionHistory'), MockHttpResponseGenerator.getTransactResponse());
        Test.setContinuationResponse(ctrl.requestLabelMap.get('totalDebt'), MockHttpResponseGenerator.getCreditResponse());
        Object result = Test.invokeContinuationMethod(ctrl, continuation);
        System.assertEquals(null, result);
        System.debug('ctrl.responseMap :'+ctrl.responseMap);

        Test.stopTest();

        Map<String, Object> interactionHistoryDataMap = (Map<String, Object>)ctrl.responseMap.get('interactionHistory');
        System.assertEquals('90.00', (String)interactionHistoryDataMap.get('purchaseCredit'));
        System.assertEquals('80.00', (String)interactionHistoryDataMap.get('purchaseCash'));
        System.assertEquals('70.00', (String)interactionHistoryDataMap.get('salesCredit'));
        System.assertEquals('60.00', (String)interactionHistoryDataMap.get('salesCash'));

        Map<String, List<String>> totalDebtDataMap = (Map<String, List<String>>)ctrl.responseMap.get('totalDebt');
        System.assertEquals('60.00', (String)totalDebtDataMap.get('total_outstanding').get(0));
        System.assertEquals('30.00', (String)totalDebtDataMap.get('pn_outstanding').get(0));
        System.assertEquals('20.00', (String)totalDebtDataMap.get('od_outstanding').get(0));
        System.assertEquals('10.00', (String)totalDebtDataMap.get('tf_outstanding').get(0));
        
        System.assertEquals('10', (String)totalDebtDataMap.get('pn_limit').get(0));
        System.assertEquals('20', (String)totalDebtDataMap.get('od_limit').get(0));
        System.assertEquals('30', (String)totalDebtDataMap.get('tf_limit').get(0));
        System.assertEquals('60.00', (String)totalDebtDataMap.get('total_limit').get(0));
    }

    @isTest static void testCannotFoundCustomerId() {
        Account account = new Account();
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        System.assertEquals(true, ApexPages.hasMessages());
    }

    @isTest static void testSetupCollateralList() {
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = 'AccountName';
        account.Is_createby_Integration__c = true;
        insert account;

        Collateral__c collateral = new Collateral__c();
        collateral.Amount_Guarantee__c = 100;
        collateral.Amount_Guarantor__c = 150;
        collateral.Value__c = 1000;
        collateral.CIS_ID__c = account.Id;
        insert collateral;

        ApexPages.currentPage().getParameters().put('id', account.Id);
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        CustomerInformation_Controller.AccountObj accObj = ctrl.getObj();
        System.assertEquals('250', accObj.amountCollateral);
        System.assertEquals('1000', accObj.valueCollateral);
    }

    @isTest static void testSetupBehaviorScore() {
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = 'AccountName';
        account.Is_createby_Integration__c = true;
        insert account;

        LPM__c lpm = new LPM__c(Name ='LPM1',LPM__c='LPM1',Count_Display_DPD__c='No');
        insert lpm;

        List<Behaviour_Score__c> behaviorScoreList = new List<Behaviour_Score__c>();
        behaviorScoreList.add(new Behaviour_Score__c(Name = '1', HL__c = 'Not Pass', CIS__c = account.Id,LPM__c=lpm.id));
        behaviorScoreList.add(new Behaviour_Score__c(Name = '2', HL__c = 'Pass', CIS__c = account.Id,LPM__c=lpm.id));
        behaviorScoreList.add(new Behaviour_Score__c(Name = '3', HL__c = 'Pass', CIS__c = account.Id,LPM__c=lpm.id));
        behaviorScoreList.add(new Behaviour_Score__c(Name = '4', HL__c = 'Not Pass', CIS__c = account.Id,LPM__c=lpm.id));
        insert behaviorScoreList;

        List<Integer> expectList = new List<Integer> {1, 5, 5, 1};
        ApexPages.currentPage().getParameters().put('id', account.Id);
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        System.debug('ctrl.errorMessage :'+ctrl.errorMessage);
        CustomerInformation_Controller.AccountObj accObj = ctrl.getObj();
        System.debug('accObj.bScoreMap :'+accObj.bScoreMap);
        System.assertEquals(expectList.size(), accObj.bScoreMap.get('HL').size());
        for(Integer i=0; i<expectList.size(); i++) {
            System.assertEquals(expectList.get(i), accObj.bScoreMap.get('HL').get(i));
        }
    }

    @isTest static void testDataOfAccount() {
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = 'AccountName';
        account.Stock_Day_on_Hand_Days__c = 10;
        account.Current_Ratio__c = 20;
        account.SOW_Exposure__c = 30;
        account.SOW_Outstanding__c = 40;
        account.Is_createby_Integration__c = true;
        insert account;

        ApexPages.currentPage().getParameters().put('id', account.Id);
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        System.assertEquals('10.00', ctrl.getObj().stockDayOnHand);
        System.assertEquals('20.00', ctrl.getObj().currentRatio);
        System.assertEquals(30, ctrl.getObj().kBankSOWExposure);
        System.assertEquals(70, ctrl.getObj().otherSOWExposure);
        System.assertEquals(40, ctrl.getObj().kBankSOWOutstanding);
        System.assertEquals(60, ctrl.getObj().otherSOWOutStanding);
    }

    @isTest static void test() {
        String accountNameTM = 'tmCreatedAccountName';
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }

        //Account account = [SELECT Id FROM Account WHERE Name = :accountNameTM LIMIT 1];
        Account account = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id');
        ApexPages.currentPage().getParameters().put('id', account.Id);
        CustomerInformation_Controller ctrl = new CustomerInformation_Controller(new ApexPages.StandardController(account));
        // Implement test code
    }
}