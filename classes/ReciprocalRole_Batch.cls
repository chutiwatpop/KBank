global class ReciprocalRole_Batch implements Database.Batchable<sObject>,Database.Stateful  {
	
	String query;
	Map<String,String> relationCodeMap = new Map<String,String>();
	Map<String, Id> recordTypeMap;
	Set<String> existExternalRole = new Set<String>();
	List<String> householdList = new List<String>();
	private final String relationShipTypeContactContact = 'Contact Contact Relation';
	private final String relationShipTypeAccountAccount = 'Account Account Relation';
	private final String recordTypeDevNameContact = 'ContactRole';
	private final String recordTypeDevNameAccount = 'AccountRole';

	
	global ReciprocalRole_Batch() {
		
		List<SLL_Relationship_Code__mdt> relationCodeList = [SELECT MasterLabel,SLL_Description__c,Is_Household__c FROM SLL_Relationship_Code__mdt ORDER BY MasterLabel];
		for(SLL_Relationship_Code__mdt eachRelationCode : relationCodeList){
			relationCodeMap.put(eachRelationCode.MasterLabel,eachRelationCode.SLL_Description__c);
			if(eachRelationCode.Is_Household__c){
				householdList.add(eachRelationCode.MasterLabel);
			}
		}
		recordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('FinServ__ReciprocalRole__c');
		List<FinServ__ReciprocalRole__c> existReciprocalRolelist = [SELECT Id, Role_External_ID__c from FinServ__ReciprocalRole__c];
		for(FinServ__ReciprocalRole__c eachRole :existReciprocalRolelist ){
			existExternalRole.add(eachRole.Role_External_ID__c);
		}

		query = 'SELECT ID,Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c from SLL_Relation__c WHERE  Subject_Relation_Code__c !=:householdList and Object_Relation_Code__c !=:householdList and ((Subject_Type_Code__c=\'I\' AND Object_Type_Code__c =\'I\') OR (Subject_Type_Code__c=\'O\' AND Object_Type_Code__c =\'O\'))  ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<SLL_Relation__c> relation_sll_list) {
   		List<FinServ__ReciprocalRole__c> updateReciprocalRoleList = new List<FinServ__ReciprocalRole__c>();
   		for(SLL_Relation__c eachSLL : relation_sll_list){
   			
   			if(relationCodeMap.containsKey(eachSLL.Subject_Relation_Code__c) && relationCodeMap.containsKey(eachSLL.Object_Relation_Code__c)){
   				String recordTypeByDevName = '';
	   			String prefix_External = '';
	   			String relationShipType = '';
	   			if(eachSLL.Subject_Type_Code__c =='I' && eachSLL.Object_Type_Code__c =='I'){
	   				prefix_External = 'C';
	   				recordTypeByDevName  = recordTypeDevNameContact;
	   				relationShipType = relationShipTypeContactContact;
	   			}else if(eachSLL.Subject_Type_Code__c =='O' && eachSLL.Object_Type_Code__c =='O'){
	   				prefix_External = 'A';
	   				recordTypeByDevName  = recordTypeDevNameAccount;
	   				relationShipType = relationShipTypeAccountAccount;
	   			}

	   			String externalID = eachSLL.Subject_Relation_Code__c + '_'+ eachSLL.Object_Relation_Code__c + '_'+prefix_External;
				if(!existExternalRole.contains(externalID)){
					FinServ__ReciprocalRole__c roleObj = setReciprocalRole(externalID, eachSLL.Subject_Relation_Code__c, eachSLL.Object_Relation_Code__c,
						relationCodeMap.get(eachSLL.Subject_Relation_Code__c), relationCodeMap.get(eachSLL.Object_Relation_Code__c), 
						recordTypeMap.get(recordTypeByDevName), relationShipType, false);
					updateReciprocalRoleList.add(roleObj);
					existExternalRole.add(externalID);
				}

	   			if(eachSLL.Subject_Relation_Code__c != eachSLL.Object_Relation_Code__c){
	   				String reverseExternalID = eachSLL.Object_Relation_Code__c + '_'+ eachSLL.Subject_Relation_Code__c + '_'+prefix_External;
	   				if(!existExternalRole.contains(reverseExternalID)){
						FinServ__ReciprocalRole__c roleObj = setReciprocalRole(reverseExternalID, eachSLL.Object_Relation_Code__c, eachSLL.Subject_Relation_Code__c,
							relationCodeMap.get(eachSLL.Object_Relation_Code__c), relationCodeMap.get(eachSLL.Subject_Relation_Code__c),
							recordTypeMap.get(recordTypeByDevName), relationShipType, false);
						updateReciprocalRoleList.add(roleObj);
						existExternalRole.add(reverseExternalID);
					}
				}
   			}
   		}
   		if(updateReciprocalRoleList.size() > 0){
			upsert updateReciprocalRoleList Role_External_ID__c;
		}
	}

	private FinServ__ReciprocalRole__c setReciprocalRole(String externalId, String roleCode, String inverseRoleCode, String name, 
		String inverseRole, Id recordTypeId, String relationShipType, Boolean createInverseRole) {
		FinServ__ReciprocalRole__c  roleObj  = new FinServ__ReciprocalRole__c();
		roleObj.Role_External_ID__c = externalId;
		roleObj.Role_Code__c = roleCode;
		roleObj.Inverse_Role_Code__c = inverseRoleCode;
		roleObj.Name = name;
		roleObj.FinServ__InverseRole__c = inverseRole;
		roleObj.RecordTypeId = recordTypeId;
		roleObj.FinServ__RelationshipType__c = relationShipType;
		roleObj.FinServ__CreateInverseRole__c = createInverseRole;

		return roleObj;
	}
	
	global void finish(Database.BatchableContext BC) {
		List<FinServ__ReciprocalRole__c> allRelationList = [SELECT Id,Name,RecordTypeId,RecordType.Name, FinServ__CreateInverseRole__c, FinServ__InverseRelationship__c, FinServ__InverseRole__c,FinServ__RelationshipType__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c ];
		List<FinServ__ReciprocalRole__c> blankRelationList = new List<FinServ__ReciprocalRole__c>();
		Map<String,ID> relationMapByExternalKey = new Map<String,ID>();
		for(FinServ__ReciprocalRole__c eachRole : allRelationList){
			relationMapByExternalKey.put(eachRole.Role_External_ID__c, eachRole.Id);
			if(eachRole.Role_Code__c != eachRole.Inverse_Role_Code__c && eachRole.FinServ__InverseRelationship__c == NULL){
				blankRelationList.add(eachRole);
			}
		}

		for(FinServ__ReciprocalRole__c eachBlankRole : blankRelationList){
			
			String prefixKey = '';
			if(eachBlankRole.FinServ__RelationshipType__c == relationShipTypeContactContact){
				prefixKey = 'C';
			}else if(eachBlankRole.FinServ__RelationshipType__c == relationShipTypeAccountAccount){
				prefixKey = 'A'; 
			}
			String inverseExternalKey = eachBlankRole.Inverse_Role_Code__c + '_'+ eachBlankRole.Role_Code__c + '_' + prefixKey;
			if(relationMapByExternalKey.containsKey(inverseExternalKey)){
				eachBlankRole.FinServ__InverseRelationship__c =  relationMapByExternalKey.get(inverseExternalKey);
			}
		}
		upsert blankRelationList Role_External_ID__c;
	}
	
}