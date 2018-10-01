@isTest
private class OpportunityProductApexController_Test {
    
    @testSetup static void setupMockData() {
        Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTest();
        }
        setupProductData();
        setupProductResult();
        Test.stopTest();
        
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

            Opportunity opp = new Opportunity(
                AccountId = accountSME.Id,
                Name = 'oppNameSME',
                StageName = 'Open',
                Amount = 10,
                CloseDate = System.today() + 7
            );
            insert opp;
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
            TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
            PricebookEntry pricebookEntry = [SELECT Id, Name FROM PricebookEntry LIMIT 1];
            insert new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pricebookEntry.Id,
                Application__c = appHis.Id,
                Remark__c = 'before'
            );
        }
    }

    private static void setupProductData() {
        List<Product2> productList = new List<Product2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        productList.add(new Product2(Name = 'Deposit', Product_Code__c = 'P001', IsActive = true, Product_Segment__c = 'SME'));
        productList.add(new Product2(Name = 'Account Link', Product_Code__c = 'P002', IsActive = true, Product_Segment__c = 'SME'));
        productList.add(new Product2(Name = 'Inter Account Funds Transfer', Product_Code__c = 'P003', IsActive = true, Product_Segment__c = 'SME'));
        insert productList;
        
        for(Product2 eachProduct : productList) {
            pricebookEntryList.add(new PricebookEntry(
                Product2Id = eachProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1,
                IsActive = true
            ));
        }
        insert pricebookEntryList;
    }

    private static void setupProductResult() {
        Id productResultRecType = GlobalUtility.getRecordTypeId('Global_Master_Data__c', 'ProductResult');
        List<Global_Master_Data__c> productResultList = new List<Global_Master_Data__c>();
        productResultList.add(new Global_Master_Data__c(
            RecordTypeId = productResultRecType,
            ProductResult_Product_Code__c = 'P002', 
            ProductResult_Product_Result__c = '1. สนใจ และขายได้'));
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

    static testMethod void loadProductListWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductList();
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.products);
        }
    }

    static testMethod void loadProductListWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductList();
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.products);
        }
    }

    static testMethod void loadProductListWithRBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductList();
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.products);
        }
    }

    static testMethod void loadEditProductWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialEditProduct(opportunity.Id);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.oppWrapperList);
        }
    }

    static testMethod void loadEditProductWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialEditProduct(opportunity.Id);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.oppWrapperList);
        }
    }

    static testMethod void loadEditProductWithRBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]) {
            Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialEditProduct(opportunity.Id);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.oppWrapperList);
        }
    }

    static testMethod void loadProductResultWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResult();
            System.assertEquals(false, oppProductComponent.isError);
        }
    }

    static testMethod void loadProductResultWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResult();
            System.assertEquals(false, oppProductComponent.isError);
        }
    }

    static testMethod void loadProductResultWithRBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]) {
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResult();
            System.assertEquals(false, oppProductComponent.isError);
        }
    }

    static testMethod void loadProductResultRowWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id, Product_Results__c, Application__c, Application_CBS__c FROM OpportunityLineItem LIMIT 1];
            String oppProductString = JSON.serialize(oppProduct);
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResultRow(oppProductString);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.existingProduct);
            System.assertNotEquals(null, oppProductComponent.existingApplication);
        }
    }

    static testMethod void loadProductResultRowWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id, Product_Results__c, Application__c, Application_CBS__c FROM OpportunityLineItem LIMIT 1];
            String oppProductString = JSON.serialize(oppProduct);
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResultRow(oppProductString);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.existingProduct);
            System.assertNotEquals(null, oppProductComponent.existingApplication);
        }
    }

    static testMethod void loadProductResultRowWithRBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRBSTM LIMIT 1][0]) {
            OpportunityLineItem oppProduct = [SELECT Id, Product_Results__c, Application__c, Application_CBS__c FROM OpportunityLineItem LIMIT 1];
            String oppProductString = JSON.serialize(oppProduct);
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialProductResultRow(oppProductString);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.existingProduct);
            System.assertNotEquals(null, oppProductComponent.existingApplication);
        }
    }

    static testMethod void searchProductFromInput() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            String inputSearch = 'Account';
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = 
                OpportunityProductApexController.initialProductList();
            
            String lightningTablesString = JSON.serialize(oppProductComponent.lightningTables);
            SObject[] searchResults = 
                OpportunityProductApexController.getProductFromInput(inputSearch, oppProductComponent.queryCondition, lightningTablesString);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertEquals(2, searchResults.size());
        }
    }

    static testMethod void getProductSettings() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            String productCode = 'P001';
            List<Global_Master_Data__c> productSettings = OpportunityProductApexController.getProductSettings(productCode);
            
            System.assertEquals(4, productSettings.size());
        }
    }

    static testMethod void saveEditProductWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
            OpportunityProductApexController.OpportunityProductComponent oppProductComponent = OpportunityProductApexController.initialEditProduct(opportunity.Id);
            System.assertEquals(false, oppProductComponent.isError);
            System.assertNotEquals(null, oppProductComponent.oppWrapperList);

            for(OpportunityProductApexController.OpportunityProductWrapper eachWrapper : oppProductComponent.oppWrapperList) {
                eachWrapper.oppLineItem.Remark__c = 'after';
            }
            String oppWrapperString = JSON.serialize(oppProductComponent.oppWrapperList);
            OpportunityProductApexController.updateOpportunityProduct(oppWrapperString, opportunity.Id);
        }
    }

    static testMethod void saveNewProductWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Remark__c = 'before'
            );

            List<OpportunityProductApexController.OpportunityProductWrapper> oppWrapperList = new List<OpportunityProductApexController.OpportunityProductWrapper>();
            OpportunityProductApexController.OpportunityProductWrapper eachWrapper = new OpportunityProductApexController.OpportunityProductWrapper();
            eachWrapper.oppLineItem = oppLineItem;
            oppWrapperList.add(eachWrapper);

            String oppWrapperString = JSON.serialize(oppWrapperList);
            OpportunityProductApexController.saveOpportunityProduct(oppWrapperString);
        }
    }
}