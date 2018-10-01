@isTest
private class SME_BulkAssignment_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRMPer = 'tmCreatedAccountPer';
    public static String accountNameRMTemp = 'rmCreatedAccountTemp';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String newRMEmpId = '9999999991';
    public static String newTMEmpId = '9999999992';
    public static String newAHEmpId = '9999999993';
    public static String newNHEmpId = '9999999994';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    @testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMTemp,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

    @isTest static void executeWithOutQueueNo() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];

        UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, userRoleAh.Id);
        insert newTmRole;

        UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
        insert newRmRole;

            User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

            User secondRMUser = Mockup_Test.newUser(
                    newRMName,
                    newRMName,
                    newRMEmpId, 
                    false, 
                    rmProfile.Id,
                    newTmRole.Id,
                    userTM.Id
                );
            secondRMUser.IsActive = true;
            insert secondRMUser;

        }

        User targetRMUser = [SELECT Id FROM User WHERE Firstname=:newRMName LIMIT 1];
        //Account targetPerAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];
        //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, Owner.Employee_Id__c');
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, Owner.Employee_Id__c');

            Bulk_Assignment_Queue__c bulkQueue1 = new Bulk_Assignment_Queue__c();
            bulkQueue1.Status__c = 'Execute';
            insert bulkQueue1;

            Bulk_Assignment__c assignObjPer1 = new Bulk_Assignment__c();
            assignObjPer1.CIS_ID__c = targetPerAccount.Id;
            assignObjPer1.BulkAssignmentQueue__c = bulkQueue1.Id;
            assignObjPer1.CurrentOwner__c = targetPerAccount.OwnerId;
            assignObjPer1.AssignmentOwner__c = targetRMUser .Id;
            assignObjPer1.Process__c = true;
            insert assignObjPer1;

            Bulk_Assignment__c assignObjTemp1 = new Bulk_Assignment__c();
            assignObjTemp1.CIS_ID__c = targetTempAccount.Id;
            assignObjTemp1.BulkAssignmentQueue__c = bulkQueue1.Id;
            assignObjTemp1.CurrentOwner__c = targetTempAccount.OwnerId;
            assignObjTemp1.AssignmentOwner__c = targetRMUser.Id;
            assignObjTemp1.Process__c = true;
            insert assignObjTemp1;

            Bulk_Assignment_Queue__c bulkQueue2 = new Bulk_Assignment_Queue__c();
            bulkQueue2.Status__c = 'Execute';
            insert bulkQueue2;

            Bulk_Assignment__c assignObjPer = new Bulk_Assignment__c();
            assignObjPer.CIS_ID__c = targetPerAccount.Id;
            assignObjPer.BulkAssignmentQueue__c = bulkQueue2.Id;
            assignObjPer.CurrentOwner__c = targetPerAccount.OwnerId;
            assignObjPer.AssignmentOwner__c = targetRMUser  .Id;
            assignObjPer.Process__c = true;
            insert assignObjPer;

            Bulk_Assignment__c assignObjTemp = new Bulk_Assignment__c();
            assignObjTemp.CIS_ID__c = targetTempAccount.Id;
            assignObjTemp.BulkAssignmentQueue__c = bulkQueue2.Id;
            assignObjTemp.CurrentOwner__c = targetTempAccount.OwnerId;
            assignObjTemp.AssignmentOwner__c = targetRMUser .Id;
            assignObjTemp.Process__c = true;
            insert assignObjTemp;
        
        Test.startTest();
        
            SME_CalculateOwnershipAssignment_Service.executeBulkAssignmentBatch();
  
        Test.stopTest();
        

        Account targetPerAccount2 = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Id = :targetPerAccount.Id];
        Account targetTempAccount2 = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Id = :targetTempAccount.Id];

        System.assertEquals(newRMEmpId, targetPerAccount2.Owner.Employee_Id__c);
        System.assertEquals(newRMEmpId, targetTempAccount2.Owner.Employee_Id__c);
    }
}