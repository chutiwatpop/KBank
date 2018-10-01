@isTest
private class IssueLogController_Test {

	@isTest static void test_getRatingValue() {

		List<String> dataVal =  IssueLogController.getRatingValue();

		System.assertNotEquals(null, dataVal);
		System.assertNotEquals(0, dataVal.size());
	}

	@isTest static void test_getIssueLogs() {

		Test.startTest();
		Issue_Log__c issueLog = new Issue_Log__c();
		insert issueLog;

		Issue_Log__c dataVal =  IssueLogController.getIssueLogs(issueLog.Id);
		Test.stopTest();

		System.assertNotEquals(null, dataVal);
	}

	@isTest static void test_getProfileUser() {

		String dataVal =  IssueLogController.getProfileUser();

		System.assertNotEquals(null, dataVal);
	}

	@isTest static void test_getUrlReOpen_NotSameOwnerId() {

		Test.startTest();
		Issue_Log__c issueLog = new Issue_Log__c();
		insert issueLog;

		User rmUser = new User();
		rmUser = createRMUser();
        rmUser.id = '005280000064jxSAAQ';

		Map<boolean, String> dataVal =  IssueLogController.getUrlReOpen(issueLog.Id, rmUser.Id);

		Test.stopTest();

		Map<boolean, String> expectedValue = new Map<boolean, String>{false => Label.CBSIssueLog_OnlyOwnerAllowToReOpen};
		System.assertEquals(expectedValue, dataVal);
	}

	@isTest static void test_getUrlReOpen_SameOwnerId() {

		Test.startTest();
		Issue_Log__c issueLog = new Issue_Log__c();
		issueLog.ownerId = '005280000064jxSAAQ';
		insert issueLog;

		User rmUser = new User();
		rmUser = createRMUser();
        rmUser.id = '005280000064jxSAAQ';

		Map<boolean, String> dataVal =  IssueLogController.getUrlReOpen(issueLog.Id, rmUser.Id);

		Test.stopTest();

		Map<boolean, String> expectedValue = new Map<boolean, String>{false => Label.CBSIssueLog_NotAllowToReOpen};
		System.assertEquals(expectedValue, dataVal);
	}

	@isTest static void test_getUrlReOpen_SameOwnerIdAndStatusEqualDone() {

		Test.startTest();
		Issue_Log__c issueLog = new Issue_Log__c();
		issueLog.ownerId = '005280000064jxSAAQ';
		issueLog.Status__c = 'Done';
		insert issueLog;

		User rmUser = new User();
		rmUser = createRMUser();
        rmUser.id = '005280000064jxSAAQ';

		Map<boolean, String> dataVal =  IssueLogController.getUrlReOpen(issueLog.Id, rmUser.Id);

		Test.stopTest();

		Map<boolean, String> expectedValue = new Map<boolean, String>{true => '/apex/CBS_NewIssueLog_Page?&parentId='+issueLog.Id+'&nooverride=1'};
		System.assertEquals(expectedValue, dataVal);
	}

	public static User createRMUser(){
		String rmProfile = GlobalConstants.CBS_RM;
		Profile p = [SELECT Id FROM Profile WHERE Name=:rmProfile]; 
		User u = new User(Alias = 'reUser', Email='rmUser@kasikornbank.com', 
		EmailEncodingKey='UTF-8', LastName='rm1', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='Asia/Bangkok', UserName='rmUser@kasikornbank.com');
		return u; 
	}
	
}