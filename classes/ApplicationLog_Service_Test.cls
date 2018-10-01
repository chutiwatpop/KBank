/**
* @author komsan.wi@beryl8.com
* @17/07/2015 createddate
*/
@isTest
private class ApplicationLog_Service_Test {
  private static ApplicationLog_Service_Test.TestLog logging;
  static {
    logging = new ApplicationLog_Service_Test.TestLog();
  }
  @isTest static void addLogWithNoException() {
      String expectedClass = 'classTest';
      String expectedMessage = 'messageTest';
      logging.addLog(expectedClass,expectedMessage);
      Test.startTest();
        logging.clearance();
      Test.stopTest();

      List<Application_Log__c> result = [SELECT Id,Debug_Level__c,Message__c,Source__c,Source_Function__c,Stack_Trace__c,Exception_Type__c FROM Application_Log__c];
      System.assertEquals(1,result.size());
    }

    @isTest static void addLogWithException() {
      String expectedClass = 'classTest';
      String expectedMessage = 'messageTest';

      Test.startTest();
      try {
        Integer newInt = 10;
        Integer newInt2 = 0;

        newInt = newInt/newInt2;
      } catch(Exception e) {
        System.assertNotEquals(null, e);
        logging.addLog(expectedClass, e);
        logging.addLog(expectedClass, e,expectedMessage);
      }

        logging.clearance();
      Test.stopTest();

    }

  private class TestLog extends ApplicationLog_Service {
  }
}