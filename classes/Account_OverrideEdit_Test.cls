@isTest
private class Account_OverrideEdit_Test {
	public static Id PROSPECT_REC_ID = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT);
	@isTest static void testEditWithCIS() {
		Account existAccount = Mockup_Test.newAccountObj('12345',GlobalConstants.PORT,PROSPECT_REC_ID);
		insert existAccount;

		ApexPages.StandardController stdController = new ApexPages.StandardController(existAccount);
		Account_OverrideEdit_Controller accController = new Account_OverrideEdit_Controller(stdController);
		Account controllerRecord = (Account) stdController.getRecord();
		controllerRecord.Name = 'test';
		controllerRecord.Identification_No_Prospect__c = '1231231231231';
		controllerRecord.Birthdate_Registration_Date__c = System.today() - 200;
		accController.save();

		Account expectedAccount = [SELECT Id, Name, CIS__c, Identification_No_Prospect__c, RecordType.DeveloperName FROM Account WHERE Id = :existAccount.Id];
		System.assertEquals('test',expectedAccount.Name);
		System.assertEquals(null,expectedAccount.CIS__c);
		System.assertEquals(GlobalConstants.SME_PROSPECT_DEVNAME,expectedAccount.RecordType.DeveloperName);
	}
}