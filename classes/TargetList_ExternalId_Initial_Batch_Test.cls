@isTest
public class TargetList_ExternalId_Initial_Batch_Test {
    public static String accountNameRM = 'rmCreatedAccountName';
    
    @testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    @isTest static void testGenerateExternalIdForTargetList() {
        //Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id');
        Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED, 'SME- Lead / Campaign', GlobalConstants.LEAD_FOR_SALES);
        camp.StartDate = System.Today() - 1;
        camp.EndDate = System.Today() + 1;
        insert camp;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = camp.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        TriggerHandler.bypass('TargetListTriggerHandler');
        insert tl;
        TriggerHandler.clearbypass('TargetListTriggerHandler');

        Test.startTest();
            GlobalUtility.runOnce = false;
            Database.executeBatch(new TargetList_ExternalId_Initial_Batch(), 2000);
        Test.stopTest();

        Target_List__c finalTgl = [SELECT Id, Lead_Campaign__r.Lead_Campaign_Event_Code__c, CIS_ID_Prospect_Name__c,External_ID__c,External_ID_CDB__c FROM Target_List__c WHERE Id = :tl.Id LIMIT 1];
        System.assertEquals(finalTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c + ':' + finalTgl.CIS_ID_Prospect_Name__c,finalTgl.External_ID__c);
        System.assertEquals(finalTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c + ':' + finalTgl.CIS_ID_Prospect_Name__c,finalTgl.External_ID_CDB__c);
    }
}