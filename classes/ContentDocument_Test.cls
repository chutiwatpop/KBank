@isTest
private class ContentDocument_Test {
	
	@isTest 
	static void test_method_insertDocumentInWrongBudgetStage() {
		Budget__c mainBudget = new Budget__c(
			Stage__c = GlobalConstants.BUDGET_CANCELLED,
			recordTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME)
		);
		TriggerHandler.bypass('BudgetTriggerHandler');
			insert mainBudget;
		TriggerHandler.clearBypass('BudgetTriggerHandler');

		Test.startTest();
		ContentVersion contentVer = new ContentVersion(
			Title = 'Test',
			PathOnclient = 'test.pdf',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = mainBudget.id;
		cdl.shareType = 'V';
		try {
			insert contentVer;
			List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
			cdl.ContentDocumentId = documents[0].Id;
			insert cdl;
		} catch (Exception e) {
			System.assert(e.getMessage().contains(Label.NotAllowAddDeleteFile));
		}
		Test.stopTest();
	}

	@isTest 
	static void test_method_updateDocumentInWrongBudgetStage() {
		Budget__c mainBudget = new Budget__c(
			Stage__c = GlobalConstants.BUDGET_OPEN,
			recordTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_DEVNAME)
		);
		TriggerHandler.bypass('BudgetTriggerHandler');
			insert mainBudget;
		TriggerHandler.clearBypass('BudgetTriggerHandler');

		ContentVersion contentVer = new ContentVersion(
			Title = 'Test',
			PathOnclient = 'test.pdf',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
		insert contentVer;
		List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = mainBudget.id;
		cdl.shareType = 'V';
		cdl.ContentDocumentId = documents[0].Id;
		insert cdl;

		mainBudget = new Budget__c(
			Id = mainBudget.Id,
			Stage__c = GlobalConstants.BUDGET_CANCELLED,
			recordTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME)
		);
		update mainBudget;

		Test.startTest();
		try {
			ContentDocument document = new ContentDocument(
				Id = documents[0].Id,
				Title = 'newTest'
			);
			update document;
		} catch (Exception e) {
			System.assert(e.getMessage().contains(Label.NotAllowAddDeleteFile));
		}
		Test.stopTest();
	}

	@isTest 
	static void test_method_deleteDocumentInWrongBudgetStage() {
		Budget__c mainBudget = new Budget__c(
			Stage__c = GlobalConstants.BUDGET_OPEN,
			recordTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_DEVNAME)
		);
		TriggerHandler.bypass('BudgetTriggerHandler');
			insert mainBudget;
		TriggerHandler.clearBypass('BudgetTriggerHandler');

		ContentVersion contentVer = new ContentVersion(
			Title = 'Test',
			PathOnclient = 'test.pdf',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
		insert contentVer;
		List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = mainBudget.id;
		cdl.shareType = 'V';
		cdl.ContentDocumentId = documents[0].Id;
		insert cdl;

		mainBudget = new Budget__c(
			Id = mainBudget.Id,
			Stage__c = GlobalConstants.BUDGET_CANCELLED,
			recordTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME)
		);
		update mainBudget;

		Test.startTest();
		try {
			delete documents;
		} catch (Exception e) {
			System.assert(e.getMessage().contains(Label.NotAllowAddDeleteFile));
		}
		Test.stopTest();
	}
}