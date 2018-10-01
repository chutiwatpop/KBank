global interface IUserManagement {
	String getQuery();

	void calculateUser(List<User_Structure__c> listUserStructure);
	void calculateNextRole();
	void executeOtherObject(DML_Queueable dmlQueue);

	User createNewUser(User_Structure__c userStructure);
	User updateUser(User_Structure__c userStructure,User existingUser);
	User inactiveUser(Map<String, User> mapExistingUserByEmpId,User_Structure__c userStructure);
	
	User_Extension__c createUserExtension(User newUser);
	User_Structure__c updateUserStructureInfo(User existingUser,User_Structure__c userStructure);

	Boolean executeUpdateInactiveUser();
	Boolean executeInsertActiveUser();
	Boolean executeUpdateActiveUser();
	Boolean executeInsertUserPermission();
	Boolean prepareUpsertUserExtension(DML_Queueable dmlQueue);
	Boolean prepareUpdateUserStructure(DML_Queueable dmlQueue);
	Boolean isDataChange(User user, User_Structure__c deltaUser);
	Boolean hasNextRole();
}