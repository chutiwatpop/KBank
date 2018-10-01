@isTest
private class QuickApplicationHistoryController_Test {

    @testSetup static void setupMockData() {
        Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTest();
        }

        User rmCBSUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1];

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
            insert new Business_Code__c(
                Name = '000000001'
            );
        }

        Test.stopTest();
    }

    static testMethod void loadFormWithSMEUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'oppNameSME' LIMIT 1];
            Application_History__c appHis = new Application_History__c(
                OppName__c = opp.Id
            );
            QuickApplicationHistoryController.FieldSetForm formObj = QuickApplicationHistoryController.getForm(appHis);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(8, formObj.Fields.size());
            Application_History__c appHistRecord = (Application_History__c) formObj.ApplicationHistory;
            System.assertEquals(opp.Id, appHistRecord.OppName__c);
        }
    }

    static testMethod void loadFormWithCBSUser() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'oppNameSME' LIMIT 1];
            Business_Code__c businessCode = [SELECT Id FROM Business_Code__c WHERE Name = '000000001' LIMIT 1];
            Application_History__c appHis = new Application_History__c(
                OppName__c = opp.Id,
                Business_Code__c = businessCode.Id
            );
            QuickApplicationHistoryController.FieldSetForm formObj = QuickApplicationHistoryController.getForm(appHis);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(8, formObj.Fields.size());
            Application_History__c appHistRecord = (Application_History__c) formObj.ApplicationHistory;
            System.assertEquals(opp.Id, appHistRecord.OppName__c);
        }
    }

    static testMethod void loadFormWithoutAppHist() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            QuickApplicationHistoryController.FieldSetForm formObj = QuickApplicationHistoryController.getForm(null);
            System.assertEquals(false, formObj.isError);
            System.assertEquals(8, formObj.Fields.size());
            Application_History__c appHistRecord = (Application_History__c) formObj.ApplicationHistory;
            System.assertNotEquals(null, appHistRecord);
        }
    }

    static testMethod void saveApplicationHistory() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'oppNameSME' LIMIT 1];
            Application_History__c appHis = new Application_History__c(
                AppNum_NonCMAS__c = '',
                OppName__c = opp.Id,
                RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = GlobalConstants.NON_CMAS,
                TentativeSubmitDate__c = System.today(),
                RMActualRequestedAmt__c = 100000
            );
            QuickApplicationHistoryController.ResultResponse responseObj = QuickApplicationHistoryController.save(appHis);
            System.assert(responseObj.isSuccess);
            Application_History__c newAppHist = [SELECT Id, RMCreditModel__c FROM Application_History__c WHERE Id = :responseObj.applicationHistory.Id];
            System.assertEquals(GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, newAppHist.RMCreditModel__c);
        }
    }

    static testMethod void saveApplicationHistoryWithError() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]) {
            Application_History__c appHis = new Application_History__c(
                AppNum_NonCMAS__c = '',
                OppName__c = '0060l000004KyN0',
                RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = GlobalConstants.NON_CMAS,
                TentativeSubmitDate__c = System.today(),
                RMActualRequestedAmt__c = 100000
            );
            QuickApplicationHistoryController.ResultResponse responseObj = QuickApplicationHistoryController.save(appHis);
            System.assertEquals(false, responseObj.isSuccess);
            System.assertNotEquals(null, responseObj.message);
        }
    }
}