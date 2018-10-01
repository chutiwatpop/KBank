/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global utility Test

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015      Charnun.T                       First Create
------------------------------------------------------------*/
@isTest
private class GlobalUtility_Test {

    static testMethod void setApplicationLogWrapper(){
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        msg.source = 'source';
        msg.logMessage = 'logMessage';
        msg.sourceFunction = 'sourceFunction';
        msg.referenceId = 'referenceId';
        msg.referenceInfo = 'referenceInfo';
        msg.payload = 'payLoad';
        msg.debugLevel = GlobalConstants.DEBUG_LOG;
        msg.logCode = 'logCode';
        msg.timer = Long.valueOf('1234567');
        msg.ex = null;
    }

    static testMethod void toDateFormat(){
        Date todayDate = System.today();
        String newDate = GlobalUtility.toDateFormat('2558', '2', '16');
        System.assertEquals('16/02/2015', newDate);
    }

    static testMethod void toCurrency(){
        String stringCurrency = GlobalUtility.toCurrency('1900000');
        System.assertEquals('1,900,000.00', stringCurrency);
    }

    static testMethod void dropLeadingZero(){
        String zeroLead = '000099';
        System.assertEquals('99', GlobalUtility.dropLeadingZero(zeroLead));
    }

    static testMethod void isEmailValid(){
        String validEmail = 'ttt11@comdfdf.com';
        String invalidEmail = 'ttt121424@dfsfgsgsg';

        System.assertEquals(true, GlobalUtility.isEmailValid(validEmail));
        System.assertEquals(false, GlobalUtility.isEmailValid(invalidEmail));
    }

    static testMethod void isValidDecimalPositive(){
        System.assertEquals(true, GlobalUtility.isValidDecimal('1,000'));
    }

    static testMethod void isValidDecimalNegative(){
        System.assertEquals(false, GlobalUtility.isValidDecimal('1SDSFG0XF0'));
    }

    static testMethod void isDataOfSetTwoInSetOnePositive(){
        System.assertEquals(true, GlobalUtility.isDataOfSetTwoInSetOne(new Set<String>{'1','2'}, new Set<String>{'1'}));
    }

    static testMethod void isDataOfSetTwoInSetOneNegative(){
        System.assertEquals(false, GlobalUtility.isDataOfSetTwoInSetOne(new Set<String>{'1','2'}, new Set<String>{'3'}));
    }
    
    static testMethod void randomStringAll(){
        System.assertNotEquals(null, GlobalUtility.randomStringAll(7));
    }

    static testMethod void logInsertSaveResults(){
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        List<Account> accounts = new List<Account>();
        //Given
        accounts.add(new Account(
            LastName = 'accountCBS',
            RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB
        ));

        accounts.add(new Account(
            Name = 'accountSME',
            RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM
        ));

        Test.startTest();
        Database.SaveResult[] results = Database.insert(accounts,false);
        GlobalUtility.logSaveResults(results, 'GlobalUtility_Test', 'InsertAccounts');
        Test.stopTest();
        List<Application_Log__c> appLogs = [SELECT Id, Source__c, Source_Function__c, Message__c FROM Application_Log__c];
        for(Application_Log__c appLog : appLogs) {
            System.assertEquals('GlobalUtility_Test', appLog.Source__c);
            System.assertEquals('InsertAccounts', appLog.Source_Function__c);
            //System.assertEquals('Message__c', appLog.Message__c);
        }
    }

    static testMethod void logUpdateSaveResults(){
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        List<Account> accounts = new List<Account>();
        //Given
        accounts.add(new Account(
            LastName = 'accountCBS',
            RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB, 
            Is_createby_Integration__c = true
        ));
        accounts.add(new Account(
            Name = 'accountSME',
            RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM,
            Is_createby_Integration__c = true
        ));
        insert accounts;
        for(Account eAccount : accounts) {
            eAccount.Is_createby_Integration__c = false;
        }
        Test.startTest();
        
        Database.SaveResult[] results = Database.update(accounts,false);
        GlobalUtility.logSaveResults(results, 'GlobalUtility_Test', 'UpdateAccounts');
        Test.stopTest();
        List<Application_Log__c> appLogs = [SELECT Id, Source__c, Source_Function__c, Message__c FROM Application_Log__c];
        for(Application_Log__c appLog : appLogs) {
            System.assertEquals('GlobalUtility_Test', appLog.Source__c);
            System.assertEquals('UpdateAccounts', appLog.Source_Function__c);
            //System.assertEquals('Message__c', appLog.Message__c);
        }
    }

    //static testMethod void logUpsertSaveResults(){
    //    Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
    //    List<Account> accounts = new List<Account>();
    //    //Given
    //    accounts.add(new Account(
    //        LastName = 'accountCBS',
    //        RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME),
    //        Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_CB, 
    //        Is_createby_Integration__c = true
    //    ));
    //    insert accounts;

    //    for(Account eAccount : accounts) {
    //        eAccount.Is_createby_Integration__c = false;
    //    }

    //    accounts.add(new Account(
    //        Name = 'accountSME',
    //        RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
    //        Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_LM,
    //        Is_createby_Integration__c = false
    //    ));
        
    //    Test.startTest();
    //    Database.UpsertResult[] results = Database.upsert(accounts,false);
    //    GlobalUtility.logSaveResults(results, 'GlobalUtility_Test');
    //    Test.stopTest();
    //    List<Application_Log__c> appLogs = [SELECT Id, Source__c, Message__c FROM Application_Log__c];
    //    for(Application_Log__c appLog : appLogs) {
    //        System.assertEquals('GlobalUtility_Test', appLog.Source__c);
    //        //System.assertEquals('Message__c', appLog.Message__c);
    //    }
    //}
}