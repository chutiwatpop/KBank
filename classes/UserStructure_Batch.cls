global class UserStructure_Batch implements Database.Batchable<sObject>{
	IUserManagement userManagement;

	global UserStructure_Batch() {
		this.userManagement = new SMEUserManagement();
	}

	global UserStructure_Batch(IUserManagement userManagement) {
		this.userManagement = userManagement;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(userManagement.getQuery());
	}

   	global void execute(Database.BatchableContext BC, List<User_Structure__c> listUserStructure) {
   		DML_Queueable dmlQueue = new DML_Queueable();
		userManagement.calculateUser(listUserStructure);
		userManagement.executeUpdateInactiveUser();
		userManagement.executeInsertActiveUser();
		userManagement.executeUpdateActiveUser();
		userManagement.executeInsertUserPermission();
		userManagement.prepareUpsertUserExtension(dmlQueue);
        userManagement.prepareUpdateUserStructure(dmlQueue);
		userManagement.executeOtherObject(dmlQueue);
	}
	
	global void finish(Database.BatchableContext BC) {
		if(!Test.isRunningTest()){
			if(userManagement.hasNextRole()){
				userManagement.calculateNextRole();
			}else{
				executeInitialTeamStructure();
				executeUserStructureOtherSegment();
			}
		}
	}

	private void executeUserStructureOtherSegment(){
		if(userManagement instanceof SMEUserManagement){
			if(GlobalUtility.isApexClassConfigActive('UserStructure_Batch') && GlobalUtility.isApexClassConfigActive('RBSUserManagement')){
				Database.executeBatch(new UserStructure_Batch(new RBSUserManagement()));
			}
		}else if(userManagement instanceof RBSUserManagement){
			if(GlobalUtility.isApexClassConfigActive('UserStructure_Batch') && GlobalUtility.isApexClassConfigActive('AFUserManagement')){
				Database.executeBatch(new UserStructure_Batch(new AFUserManagement()));
			}
		}
	}

	private void executeInitialTeamStructure(){
		if(userManagement instanceof SMEUserManagement){
			if(GlobalUtility.isApexClassConfigActive('InitialTeamStructure_Batch') && GlobalUtility.isApexClassConfigActive('SMEInitialTeamStructure')){
				Database.executeBatch(new InitialTeamStructure_Batch(new SMEInitialTeamStructure()));
			}
		}else if(userManagement instanceof RBSUserManagement){
			if(GlobalUtility.isApexClassConfigActive('InitialTeamStructure_Batch') && GlobalUtility.isApexClassConfigActive('RBSInitialTeamStructure')){
				Database.executeBatch(new InitialTeamStructure_Batch(new RBSInitialTeamStructure()));
			}
		}else if(userManagement instanceof AFUserManagement){
			if(GlobalUtility.isApexClassConfigActive('InitialTeamStructure_Batch') && GlobalUtility.isApexClassConfigActive('AFInitialTeamStructure')){
				Database.executeBatch(new InitialTeamStructure_Batch(new AFInitialTeamStructure()));
			}
		}
	}
	
}