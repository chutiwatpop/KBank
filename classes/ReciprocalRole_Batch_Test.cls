@isTest
private class ReciprocalRole_Batch_Test {

	@isTest static void createReciprocalRole() {
		List<SLL_Relationship_Code__mdt> relationCodeList = [SELECT MasterLabel,SLL_Description__c,Is_Household__c FROM SLL_Relationship_Code__mdt WHERE Is_Household__c = false ORDER BY MasterLabel];
		List<RecordType> recordTypeAccountRoleList = [SELECT ID FROM RecordType WHERE DeveloperName ='AccountRole' AND SObjectType ='FinServ__ReciprocalRole__c'];
		System.assertNotEquals(NULL,relationCodeList);
		System.assertNotEquals(0,relationCodeList.size());
		System.assertEquals(true,(relationCodeList.size() > 2));

		if(relationCodeList != NULL && relationCodeList.size() > 2){
			List<SLL_Relation__c> updateSllList = new List<SLL_Relation__c>();
			SLL_Relation__c accountAccountRelation = new SLL_Relation__c();
			SLL_Relation__c accountAccountRelation2 = new SLL_Relation__c();
			SLL_Relation__c contactContactRelation = new SLL_Relation__c();
			SLL_Relation__c singleRelation = new SLL_Relation__c();
			FinServ__ReciprocalRole__c existRole = new FinServ__ReciprocalRole__c();

			accountAccountRelation.Subject_Relation_Code__c = relationCodeList.get(0).MasterLabel;
			accountAccountRelation.Object_Relation_Code__c  = relationCodeList.get(1).MasterLabel;
			accountAccountRelation.Subject_Type_Code__c = 'O';
			accountAccountRelation.Object_Type_Code__c = 'O';

			accountAccountRelation2.Subject_Relation_Code__c = relationCodeList.get(0).MasterLabel;
			accountAccountRelation2.Object_Relation_Code__c  = relationCodeList.get(1).MasterLabel;
			accountAccountRelation2.Subject_Type_Code__c = 'O';
			accountAccountRelation2.Object_Type_Code__c = 'O';

			contactContactRelation.Subject_Relation_Code__c = relationCodeList.get(0).MasterLabel;
			contactContactRelation.Object_Relation_Code__c  = relationCodeList.get(1).MasterLabel;
			contactContactRelation.Subject_Type_Code__c = 'I';
			contactContactRelation.Object_Type_Code__c = 'I';

			singleRelation.Subject_Relation_Code__c = relationCodeList.get(0).MasterLabel;
			singleRelation.Object_Relation_Code__c  = relationCodeList.get(0).MasterLabel;
			singleRelation.Subject_Type_Code__c = 'I';
			singleRelation.Object_Type_Code__c = 'I';

			existRole.Role_External_ID__c = relationCodeList.get(0).MasterLabel+'_'+relationCodeList.get(1).MasterLabel+'_A';
			existRole.Role_Code__c = relationCodeList.get(0).MasterLabel;
			existRole.Inverse_Role_Code__c = relationCodeList.get(1).MasterLabel;
			existRole.Name = relationCodeList.get(0).SLL_Description__c;
			existRole.FinServ__InverseRole__c = relationCodeList.get(1).SLL_Description__c;
			existRole.RecordTypeId = recordTypeAccountRoleList.get(0).ID;
			existRole.FinServ__RelationshipType__c = 'Account Account Relation';
			existRole.FinServ__CreateInverseRole__c = false;

			

			updateSllList.add(accountAccountRelation);
			updateSllList.add(accountAccountRelation2);
			updateSllList.add(contactContactRelation);
			updateSllList.add(singleRelation);
			
			insert existRole;
			insert updateSllList;

			Test.startTest();
			Database.executeBatch(new ReciprocalRole_Batch());
			Test.stopTest();

			List<FinServ__ReciprocalRole__c> allReciprocalRoleList = [SELECT ID, FinServ__InverseRelationship__c FROM FinServ__ReciprocalRole__c];
			Integer inverseRoleList = 0;
			Integer nonInverseRoleList = 0;
			for(FinServ__ReciprocalRole__c eachrole : allReciprocalRoleList){
				if(eachrole.FinServ__InverseRelationship__c == NULL){
					nonInverseRoleList++;
				}else{
					inverseRoleList++;
				}
			}
			System.assertEquals(5,allReciprocalRoleList.size());
			System.assertEquals(4,inverseRoleList);
			System.assertEquals(1,nonInverseRoleList);
		}
	}

}