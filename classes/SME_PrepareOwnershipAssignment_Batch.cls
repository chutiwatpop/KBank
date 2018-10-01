global class SME_PrepareOwnershipAssignment_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.Stateful {
    
    private static final String CLASS_NAME = 'SME_PrepareOwnershipAssignment_Batch';
    private Set<Id> hrisDiffIds;
    private Set<Id> hrisInActiveIds;
    private Map<String, User> userMapByEmpId;
    private Map<String, User> userMapByNewRoleRC;
    private Map<String, User_MaskModel> userMaskMapByEmpId;
    private Map<Id, Profile> profileCBSMap;

    String query;
    
    global SME_PrepareOwnershipAssignment_Batch() {
        initialBatch();
    }

    private void initialBatch() {
        hrisDiffIds = new Set<Id>();
        hrisInActiveIds = new Set<Id>();
        userMapByNewRoleRC = new Map<String, User>();
        userMaskMapByEmpId = new Map<String, User_MaskModel>();

        userMapByEmpId = new Map<String, User>();
//Fix INC000000832046
        profileCBSMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name = :GlobalConstants.CBS_FSVP OR Name = :GlobalConstants.CBS_TM OR Name = :GlobalConstants.CBS_TL OR Name = :GlobalConstants.CBS_RM OR Name = :GlobalConstants.CBS_ADMIN OR Name = :GlobalConstants.CBS_MIDDLE_OFFICE OR Name = :GlobalConstants.CBS_NHTL]);

        for(User eachUser : [SELECT Id, Name, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c,
                            ManagerId,
                            Manager.ManagerId,
                            Manager.Manager.ManagerId,
                            Manager.IsActive, 
                            Manager.Manager.IsActive, 
                            Manager.Manager.Manager.IsActive,
                            Manager.RC_Code__c, 
                            Manager.Manager.RC_Code__c, 
                            Manager.Manager.Manager.RC_Code__c,
                            Manager.Job_Code__c, 
                            Manager.Manager.Job_Code__c, 
                            Manager.Manager.Manager.Job_Code__c  FROM User WHERE ProfileId NOT IN :profileCBSMap.keyset()]) {
            if (eachUser.Employee_ID__c != null) {
                userMapByEmpId.put(formatEmployeeId(eachUser.Employee_ID__c), eachUser);
            }
        }
        this.query = 'SELECT Id, Name, Team_Name__c, Email__c, First_Name__c, Last_Name__c, Segment__c, RC_Code__c, Job_Code__c, Status__c, AH_RC_Code__c, NH_RC_Code__c, Effective_Date__c, Username__c FROM User_Structure__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User_Structure__c> scope) {
        for (User_Structure__c eachHRISUser : scope) {
            if (userMapByEmpId.containsKey(formatEmployeeId(eachHRISUser.Name))) {
                User eachUser = userMapByEmpId.get(formatEmployeeId(eachHRISUser.Name));
                
                // Check acting flag
                if (eachUser.Acting_Flag__c == true && 
                    eachHRISUser.Job_Code__c != null && eachUser.RC_Code__c != null && (eachUser.Job_Code__c != eachHRISUser.Job_Code__c || eachUser.RC_Code__c != eachHRISUser.RC_Code__c)) {
                    continue;
                }

                User_MaskModel userMask = new User_MaskModel(eachUser);
                userMask.setUserStructure(eachHRISUser);
                if(eachHRISUser.Status__c == 'I' && eachHRISUser.Effective_Date__c != null && eachHRISUser.Effective_Date__c <= System.today() && (eachUser.Status__c != eachHRISUser.Status__c || eachUser.IsActive)) {
                    hrisInActiveIds.add(eachUser.Id);
                    userMaskMapByEmpId.put(eachUser.Employee_ID__c,userMask);
                } else if (eachUser.Job_Code__c != eachHRISUser.Job_Code__c || eachUser.RC_Code__c != eachHRISUser.RC_Code__c) {
                    hrisDiffIds.add(eachUser.Id);
                    userMapByNewRoleRC.put(eachHRISUser.Job_Code__c + '-' + eachHRISUser.RC_Code__c, eachUser);
                    userMaskMapByEmpId.put(eachUser.Employee_ID__c,userMask);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new UserStructureUpdateUser_Batch(userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds));
    }

    private String formatEmployeeId(String employeeId) {
        if(Test.isRunningTest()){
            return employeeId;
        }else{
            employeeId = '00000' + employeeId;
            return employeeId.substring(employeeId.length() - 6, employeeId.length());
        }
        
    }
}