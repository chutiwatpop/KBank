@isTest
public class SME_PurgeEnliteBatch_Controller_Test {
    
    @isTest static void positiveControllerCallPurgeFinancialRatio(){
        SME_PurgeEnliteBatch_Controller purgeBatchController = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.FNCRTO);
        Test.startTest();
        purgeBatchController.executeBatch();
        Test.stopTest();
    }
    @isTest static void positiveControllerCallPurgeBalanceSheet(){
        SME_PurgeEnliteBatch_Controller purgeBatchController = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.BALSHEET);
        Test.startTest();
        purgeBatchController.executeBatch();
        Test.stopTest();
    }
    @isTest static void positiveControllerCallPurgeIncomeStatement(){
        SME_PurgeEnliteBatch_Controller purgeBatchController = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.INCSTM);
        Test.startTest();
        purgeBatchController.executeBatch();
        Test.stopTest();
    }
    @isTest static void negativeControllerPurgeUnknownObject(){
        SME_PurgeEnliteBatch_Controller purgeBatchController = new SME_PurgeEnliteBatch_Controller('UnknownObject');
        Test.startTest();
        purgeBatchController.executeBatch();
        Test.stopTest();
    }

}