@isTest
private class EditOpportunityProductControllerTest {

    @testSetup static void setupMockData() {
        Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTest();
        }
        setupProductData();
        setupProductResult();

        User rmCBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1];
        User rmRBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Account accountSME = new Account(
                Firstname = 'accountNameSME',
                Lastname = 'accountNameSME',
                CIS__c = '0000001',
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME),
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
                Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
                Is_createby_Integration__c = true
            );
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountSME;
            TriggerHandler.clearbypass('AccountTriggerHandler');
            /*insert new AccountTeamMember(
                AccountId = accountSME.Id,
                UserId = rmCBSUser.Id,
                AccountAccessLevel = 'Edit'
            );
            insert new AccountTeamMember(
                AccountId = accountSME.Id,
                UserId = rmRBSUser.Id,
                AccountAccessLevel = 'Edit'
            );*/
            Opportunity opp = new Opportunity(
                AccountId = accountSME.Id,
                Name = 'oppNameSME',
                StageName = 'Open',
                Amount = 10,
                CloseDate = System.today() + 7
            );
            TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            insert new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = rmCBSUser.Id,
                OpportunityAccessLevel = 'Edit'
            );
            insert new OpportunityTeamMember(
                OpportunityId = opp.Id,
                UserId = rmRBSUser.Id,
                OpportunityAccessLevel = 'Edit'
            );
            Application_History__c appHis = new Application_History__c(
                AppNum_NonCMAS__c = '',
                OppName__c = opp.Id,
                RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = GlobalConstants.NON_CMAS,
                TentativeSubmitDate__c = System.today(),
                RMActualRequestedAmt__c = 100000
            );
            TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
            insert appHis;
            TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
            PricebookEntry pricebookEntry = [SELECT Id, Name FROM PricebookEntry LIMIT 1];
            insert new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pricebookEntry.Id,
                Application__c = appHis.Id
            );
        }

        Test.stopTest();
    }

    private static void setupProductData() {
        List<Product2> productList = new List<Product2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        productList.add(new Product2(Name = 'Deposit', Product_Code__c = 'P001', IsActive = true));
        insert productList;
        
        for(Product2 eachProduct : productList) {
            pricebookEntryList.add(new PricebookEntry(
                Product2Id = eachProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1,
                IsActive = eachProduct.IsActive
            ));
        }
        insert pricebookEntryList;
    }

    private static void setupProductResult() {
        Id productResultRecType = GlobalUtility.getRecordTypeId('Global_Master_Data__c', 'ProductResult');
        List<Global_Master_Data__c> productResultList = new List<Global_Master_Data__c>();
        productResultList.add(new Global_Master_Data__c(
            RecordTypeId = productResultRecType,
            ProductResult_Product_Code__c = 'P001', 
            ProductResult_Product_Result__c = '1. สนใจ และขายได้'));
        productResultList.add(new Global_Master_Data__c(
            RecordTypeId = productResultRecType,
            ProductResult_Product_Code__c = 'P001', 
            ProductResult_Product_Result__c = '2. สนใจ แต่ติดเงื่อนไข', 
            ProductResult_Reason__c = '2.1 อยู่ระหว่างจัดทำราคา/สิทธิประโยชน์ เพื่อนำเข้าไปเสนออีกครั้ง'));
        productResultList.add(new Global_Master_Data__c(
            RecordTypeId = productResultRecType,
            ProductResult_Product_Code__c = 'P001', 
            ProductResult_Product_Result__c = '2. สนใจ แต่ติดเงื่อนไข', 
            ProductResult_Reason__c = '2.2 ต้องการข้อมูลเพิ่มเติม'));
        productResultList.add(new Global_Master_Data__c(
            RecordTypeId = productResultRecType,
            ProductResult_Product_Code__c = 'P001', 
            ProductResult_Product_Result__c = '3. ไม่สนใจ'));
        insert productResultList;
    }

    static testMethod void loadFormWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            EditOpportunityProductController.FieldSetForm formObj = EditOpportunityProductController.getForm(oppProduct.Id);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(3, formObj.Fields.size());
            OpportunityLineItem oppProductRecord = (OpportunityLineItem) formObj.Record;
            System.assertEquals(oppProduct.Id, oppProductRecord.Id);
        }
    }

    static testMethod void loadFormWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            EditOpportunityProductController.FieldSetForm formObj = EditOpportunityProductController.getForm(oppProduct.Id);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(3, formObj.Fields.size());
            OpportunityLineItem oppProductRecord = (OpportunityLineItem) formObj.Record;
            System.assertEquals(oppProduct.Id, oppProductRecord.Id);
        }
    }

    static testMethod void loadFormWithRBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            EditOpportunityProductController.FieldSetForm formObj = EditOpportunityProductController.getForm(oppProduct.Id);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(3, formObj.Fields.size());
            OpportunityLineItem oppProductRecord = (OpportunityLineItem) formObj.Record;
            System.assertEquals(oppProduct.Id, oppProductRecord.Id);
        }
    }

    static testMethod void loadFormWithoutOppProductId() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            EditOpportunityProductController.FieldSetForm formObj = EditOpportunityProductController.getForm(null);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(0, formObj.Fields.size());
        }
    }

    static testMethod void saveOppProduct() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            Set<String> fieldSet = EditOpportunityProductController.getFieldSetList();
            oppProduct = (OpportunityLineItem) EditOpportunityProductController.getRecord(oppProduct.Id, EditOpportunityProductController.getFields(oppProduct.Id, fieldSet));
            oppProduct.Product_Results__c = '1. สนใจ และขายได้';
            Application_History__c appHis = [SELECT Id, OppName__c, App_Result__c FROM Application_History__c WHERE Id = :oppProduct.Application__c];
            EditOpportunityProductController.ResultResponse responseObj = EditOpportunityProductController.save(oppProduct, appHis);
            System.assert(responseObj.isSuccess);
            OpportunityLineItem oppProductRecord = [SELECT Id, Product_Results__c FROM OpportunityLineItem WHERE Id = :oppProduct.Id];
            System.assertEquals('1. สนใจ และขายได้', oppProductRecord.Product_Results__c);
        }
    }

    static testMethod void saveOppProductWithError() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Application_History__c appHis = new Application_History__c();
            OpportunityLineItem oppProduct = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            EditOpportunityProductController.ResultResponse responseObj;
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM2 LIMIT 1][0]) {
                responseObj = EditOpportunityProductController.save(oppProduct, appHis);
            }
            System.assertEquals(false, responseObj.isSuccess);
            System.assertNotEquals(null, responseObj.message);
        }
    }

    static testMethod void clearApplicationHistory() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'oppNameSME' LIMIT 1];
            List<Id> idList = new List<Id>();
            Application_History__c appHis = new Application_History__c(
                AppNum_NonCMAS__c = '',
                OppName__c = opp.Id,
                RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_PL,
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = GlobalConstants.NON_CMAS,
                TentativeSubmitDate__c = System.today(),
                RMActualRequestedAmt__c = 100000
            );
            TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
            insert appHis;
            TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
            idList.add(appHis.Id);
            EditOpportunityProductController.ResultResponse responseObj = EditOpportunityProductController.clearNewApplicationHistory(idList);
            System.assert(responseObj.isSuccess);
            List<Application_History__c> result = [SELECT Id FROM Application_History__c WHERE Id = :appHis.Id];
            System.assertEquals(0, result.size());
        }
    }
}