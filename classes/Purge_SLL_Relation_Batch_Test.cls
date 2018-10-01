@isTest
private class Purge_SLL_Relation_Batch_Test {
	
	@testSetup static void setupMockData() {
        // Mock SLL
        List<SLL_Relation__c> listSllRel = new List<SLL_Relation__c>();
		SLL_Relation__c sllIndividualIndividual = new SLL_Relation__c();
		sllIndividualIndividual.Subject_CIS_ID__c = '1';
		sllIndividualIndividual.Subject_Relation_Code__c = '105';
		sllIndividualIndividual.Subject_Type_Code__c = 'I';
		sllIndividualIndividual.Object_CIS_ID__c = '1';
		sllIndividualIndividual.Object_Relation_Code__c = 'A05';
		sllIndividualIndividual.Object_Type_Code__c = 'I';
		sllIndividualIndividual.Percent_Share__c = 80;
		listSllRel.add(sllIndividualIndividual);

		SLL_Relation__c sllIndividualOrganization = new SLL_Relation__c();
		sllIndividualOrganization.Subject_CIS_ID__c = '1';
		sllIndividualOrganization.Subject_Relation_Code__c = '205';
		sllIndividualOrganization.Subject_Type_Code__c = 'I';
		sllIndividualOrganization.Object_CIS_ID__c = '2';
		sllIndividualOrganization.Object_Relation_Code__c = 'B05';
		sllIndividualOrganization.Object_Type_Code__c = 'O';
		sllIndividualOrganization.Percent_Share__c = 80;
		listSllRel.add(sllIndividualOrganization);

		SLL_Relation__c sllOrganizationIndividual = new SLL_Relation__c();
		sllOrganizationIndividual.Subject_CIS_ID__c = '2';
		sllOrganizationIndividual.Subject_Relation_Code__c = '305';
		sllOrganizationIndividual.Subject_Type_Code__c = 'O';
		sllOrganizationIndividual.Object_CIS_ID__c = '1';
		sllOrganizationIndividual.Object_Relation_Code__c = 'C05';
		sllOrganizationIndividual.Object_Type_Code__c = 'I';
		sllOrganizationIndividual.Percent_Share__c = 65;
		listSllRel.add(sllOrganizationIndividual);

		SLL_Relation__c sllOrganizationOrganization = new SLL_Relation__c();
		sllOrganizationOrganization.Subject_CIS_ID__c = '2';
		sllOrganizationOrganization.Subject_Relation_Code__c = '405';
		sllOrganizationOrganization.Subject_Type_Code__c = 'O';
		sllOrganizationOrganization.Object_CIS_ID__c = '2';
		sllOrganizationOrganization.Object_Relation_Code__c = 'D05';
		sllOrganizationOrganization.Object_Type_Code__c = 'O';
		sllOrganizationOrganization.Percent_Share__c = 65;
		listSllRel.add(sllOrganizationOrganization);

		insert listSllRel;
    }

	@isTest static void purgeAllSllData() {
		System.assertNotEquals(0,[SELECT Count() FROM SLL_Relation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_SLL_Relation_Batch(true));
        Test.stopTest();
        System.assertEquals(0,[SELECT Count() FROM SLL_Relation__c]);
	}

	@isTest static void purgeSllDataExcludeHousehold() {
		System.assertNotEquals(0,[SELECT Count() FROM SLL_Relation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_SLL_Relation_Batch());
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM SLL_Relation__c]);
	}
	
}