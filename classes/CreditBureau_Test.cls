/**
* @author komsan.wi@beryl8.com
* @23/09/2015 createddate
*/
@isTest
private class CreditBureau_Test {
    public static String accountNameRM = 'rmCreatedAccountName';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
	} 
	static testMethod void updateRunningNumber(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			//Account targetAccount = [SELECT Id FROM Account WHERE Name = :CreditBureau_Test.accountNameRM LIMIT 1];
			Account targetAccount = Mockup_Test.getFirstAccountFromName(CreditBureau_Test.accountNameRM, 'Id');
			Opportunity opportunity = Mockup_Test.newOpportunity(targetAccount.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opportunity;

			Credit_Bureau__c credit1 = new Credit_Bureau__c(
				Opportunity__c = opportunity.Id
			);
			insert credit1;

			List<Credit_Bureau__c> creditList = [SELECT Id,Running_Number__c FROM Credit_Bureau__c WHERE Opportunity__c =: opportunity.Id];
			System.assertEquals(1,creditList.size());
			System.assertEquals('0001',creditList.get(0).Running_Number__c);

			Credit_Bureau__c credit2 = new Credit_Bureau__c(
				Opportunity__c = opportunity.Id
			);
			Test.startTest();
				insert credit2;
			Test.stopTest();

			List<Credit_Bureau__c> finalCreditList = [SELECT Id,Running_Number__c FROM Credit_Bureau__c WHERE Opportunity__c =: opportunity.Id ORDER BY Running_Number__c DESC];
			System.assertEquals(2,finalCreditList.size());
			System.assertEquals('0002',finalCreditList.get(0).Running_Number__c);
		}
	}  
}