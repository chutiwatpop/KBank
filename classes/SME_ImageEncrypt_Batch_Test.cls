/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
@isTest
private class SME_ImageEncrypt_Batch_Test
{
	public static String CUSTOMER = 'SME-Customer';
	public static String customerRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CUSTOMER).GetRecordTypeId());

	@isTest
	static void imageEncryptExecute()
	{
		Account tempAccount = new Account();
		tempAccount.Name = '457397';
		tempAccount.CIS__c = '457397';
		tempAccount.RecordtypeId = customerRecordTypeId;
		insert tempAccount;

        Test.startTest();
            Database.executeBatch(new SME_ImageEncrypt_Batch());
        Test.stopTest();

        Account resultAccount = [SELECT Id,CIS__c,Encrypt_Title_TH__c from Account where CIS__c = '457397'];
        System.debug(resultAccount);
        System.assertNotEquals(null,resultAccount.Encrypt_Title_TH__c);
	}
}