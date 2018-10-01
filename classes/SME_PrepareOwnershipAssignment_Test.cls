@isTest
private class SME_PrepareOwnershipAssignment_Test {
    
    public static String accountNameTM = 'TMAccount';
    public static String accountNameTMTemp = 'TMAccount';
    public static String accountNameRMPer = 'RMAccountPermanent';
    public static String accountNameRMTemp = 'RMAccountTemporary';
    public static String accountNameAH = 'AHAccount';

    public static String newRMEmpId = '2000000003';
    public static String newTMEmpId = '2000000005';
    public static String newAHEmpId = '2000000006';

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
            //Account accountPer = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name = :SME_PrepareOwnershipAssignment_Test.accountNameRMPer LIMIT 1];
            Account accountPer = Mockup_Test.getFirstAccountFromName(SME_PrepareOwnershipAssignment_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c');
            // New Task
            Task newTask = Mockup_Test.newTask(UserInfo.getuserid(), accountPer.Id);
            insert newTask;
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            mt.newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameTMTemp,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            Account targetAccount = Mockup_Test.getFirstAccountFromName(SME_PrepareOwnershipAssignment_Test.accountNameTM, 'Id, OwnerId, Owner.Employee_Id__c');
            targetAccount.Service_RM__c = rmUser.Id;
            update targetAccount;
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
    }

    @isTest static void rmInactive() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'I',
                System.today() - 1
            );
            insert rmUserStruc;

            Test.startTest();
                Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
            Test.stopTest();
        }
        User targetRM = [SELECT Id, Status__c, IsActive FROM User WHERE Employee_Id__c=:Mockup_Test.userEmpIdRM LIMIT 1];
        System.assertEquals('I', targetRM.Status__c);
        System.assertEquals(false, targetRM.IsActive);

        //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];

        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(SME_PrepareOwnershipAssignment_Test.accountNameRMTemp, 'Id, OwnerId, Owner.Employee_Id__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(SME_PrepareOwnershipAssignment_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c');

        Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetPerAccount.Id];
        System.assertEquals('Closed by System', targetTask.Status);

        System.assertEquals(Mockup_Test.userEmpIdTM, targetTempAccount.Owner.Employee_Id__c);
        System.assertEquals(Mockup_Test.userEmpIdTM, targetPerAccount.Owner.Employee_Id__c);

        //Account targetAccountTM = [SELECT Id, Service_RM__c FROM Account WHERE Name = :SME_PrepareOwnershipAssignment_Test.accountNameTM LIMIT 1];
        Account targetAccountTM = Mockup_Test.getFirstAccountFromName(SME_PrepareOwnershipAssignment_Test.accountNameTM, 'Id, OwnerId, Owner.Employee_Id__c,Service_RM__c');
        System.assertEquals(null, targetAccountTM.Service_RM__c);   
    }

    @isTest static void rmMoveTeamSameArea() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        Team_Structure__c tsTm = new Team_Structure__c(
            NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
            AH_RC_Code__c = Mockup_Test.AH_RC_CODE,
            RC_Code__c = newRCCode,
            External_ID__c = newRCCode
        );
        insert tsTm;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, userRoleAh.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                newTmRole.Id,
                userAH.Id
            );
            secondTMUser.Job_Code__c = 'ME3A';
            secondTMUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
            secondTMUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            secondTMUser.RC_Code__c = newRCCode;
            secondTMUser.Status__c = 'A';
            insert secondTMUser;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );
            insert rmUserStruc;
            
            Test.startTest();
                Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
            Test.stopTest();
        }
        
        //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Employee_Id__c,Service_RM__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c,Service_RM__c');

        User newTargetRM = [SELECT Id, RC_Code__c, Employee_Id__c, ManagerId FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c newRmUserExt = [SELECT Id, External_Id__c, Team_Structure__r.External_Id__c FROM User_Extension__c WHERE User__c = :newTargetRM.Id LIMIT 1];
        System.assertEquals(newRCCode, newRmUserExt.Team_Structure__r.External_Id__c);

        System.assertEquals(Mockup_Test.userEmpIdRM, targetTempAccount.Owner.Employee_Id__c);
        System.assertEquals(Mockup_Test.userEmpIdTM, targetPerAccount.Owner.Employee_Id__c);

        Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetPerAccount.Id];
        System.assertEquals('Closed by System', targetTask.Status);
    }

    @isTest static void rmMoveTeamDiffArea() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode
            );
            insert tsTm;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                newTmRole.Id,
                null
            );
            insert secondTMUser;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                newNHRCCode, 
                newAHRCCode, 
                newRCCode,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmUserStruc;
                
            Test.startTest();
                Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
            Test.stopTest();
        }
        //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        
        System.assertEquals(Mockup_Test.userEmpIdTM, targetTempAccount.Owner.Employee_Id__c);
        System.assertEquals(Mockup_Test.userEmpIdTM, targetPerAccount.Owner.Employee_Id__c);
    }

    @isTest static void rmMoveTeamDiffAreaHaveReplacedRM() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode,
                Name = 'เครือข่ายลูกค้าผู้ประกอบการ 2 tsNh'
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode
            );
            insert tsTm;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                newTmRole.Id,
                null
            );
            insert secondTMUser;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                newNHRCCode, 
                newAHRCCode, 
                newRCCode,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmUserStruc;

            User_Structure__c rmHRIS2 = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                newRMName,
                newRMName,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmHRIS2;
        
        Test.startTest();
            Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
        Test.stopTest();

        }
        User targetReplacedRM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :newRMEmpId];
        //Account targetTempAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');

        System.assertEquals(targetReplacedRM.Name, targetTempAccount.Owner.Name);
        System.assertEquals(targetReplacedRM.Name, targetPerAccount.Owner.Name);
    }

    @isTest static void tmInactiveRmPromoteReplacedTM() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode
            );
            insert tsTm;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            User_Structure__c rmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME3A', 
                'A',
                System.today() - 1
            );

            insert rmHRIS;

            User_Structure__c tmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME4A', 
                'I',
                System.today() - 1
            );

            insert tmHRIS;
        
        Test.startTest();
            Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
        Test.stopTest();

        }
        User targetReplacedRM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :Mockup_Test.userEmpIdRM];
        //Account targetAccount = [SELECT Id, Owner.Name FROM Account WHERE Name = :accountNameTM LIMIT 1];
        //Account targetTempAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];

        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');

        System.assertEquals(targetReplacedRM.Name, targetTempAccount.Owner.Name);
        System.assertEquals(targetReplacedRM.Name, targetPerAccount.Owner.Name);
        System.assertEquals(targetReplacedRM.Name, targetAccount.Owner.Name);   
    }

    @isTest static void ahInactiveTMPromoteReplacedAH() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode
            );
            insert tsTm;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            User_Structure__c ahHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE,
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'I',
                System.today() - 1
            );

            insert ahHRIS;

            User_Structure__c tmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE,
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME2A', 
                'A',
                System.today() - 1
            );

            insert tmHRIS;

            User_Structure__c rmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmHRIS;
        
            Test.startTest();
                Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
            Test.stopTest();

        }
        User targetReplacedTM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :Mockup_Test.userEmpIdTM];
        //Account targetAccount = [SELECT Id, Owner.Name FROM Account WHERE Name = :accountNameTM LIMIT 1];
        //Account targetAccountAH = [SELECT Id, Owner.Name FROM Account WHERE Name = :accountNameAH];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetAccountAH = Mockup_Test.getFirstAccountFromName(accountNameAH, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');

        System.assertEquals(targetReplacedTM.Name, targetAccount.Owner.Name);
        System.assertEquals(targetReplacedTM.Name, targetAccountAH.Owner.Name);   
    }

    @isTest static void swapTMInactiveRM() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsTm;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                newTmRole.Id,
                userAH.Id
            );
            secondTMUser.Job_Code__c = 'ME3A';
            secondTMUser.AH_RC_Code__c = newAHRCCode;
            secondTMUser.NH_RC_Code__c = newNHRCCode;
            secondTMUser.RC_Code__c = newRCCode;
            secondTMUser.Status__c = 'A';

            insert secondTMUser;

            User_Structure__c secTM = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                newTMName,
                newTMName,
                'ME3A', 
                'A',
                System.today() - 1
            );

            insert secTM;

            User_Structure__c tmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                newNHRCCode, 
                newAHRCCode, 
                newRCCode,
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'A',
                System.today() - 1
            );

            insert tmHRIS;
            
            User_Structure__c rmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'I',
                System.today() - 1
            );

            insert rmHRIS;
        
            Test.startTest();
                Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
            Test.stopTest();

        }
        User targetTM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :Mockup_Test.userEmpIdTM];
        User targetSecTM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :newTMEmpId];
        //Account targetAccount = [SELECT Id, Owner.Name FROM Account WHERE Name = :accountNameTM LIMIT 1];
        //Account targetTempAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        //Account targetPerAccount = [SELECT Id, OwnerId, Owner.Name, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMPer];

        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        Account targetPerAccount = Mockup_Test.getFirstAccountFromName(accountNameRMPer, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        
        System.assertEquals(targetSecTM.Name, targetTempAccount.Owner.Name);
        System.assertEquals(targetSecTM.Name, targetPerAccount.Owner.Name);
        System.assertEquals(targetSecTM.Name, targetAccount.Owner.Name);
    }

    @isTest static void ahInactiveAndReplaced() {
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNh.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1
            );
            insert tsTm;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                newTmRole.Id,
                userAH.Id
            );
            secondTMUser.Job_Code__c = 'ME3A';
            secondTMUser.AH_RC_Code__c = newAHRCCode;
            secondTMUser.NH_RC_Code__c = newNHRCCode;
            secondTMUser.RC_Code__c = newRCCode;
            secondTMUser.Status__c = 'A';

            insert secondTMUser;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            User_Structure__c secondTMHRIS = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                newTMName,
                newTMName,
                'ME3A', 
                'A',
                System.today() - 1
            );

            insert secondTMHRIS;

            User_Structure__c tmHRIS = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'I',
                System.today() - 1
            );

            insert tmHRIS;
        
        Test.startTest();
            Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
        Test.stopTest();

        }
        User targetReplacedTM = [SELECT Id, Name FROM User WHERE Employee_Id__c = :newTMEmpId];
        //Account targetAccount = [SELECT Id, Owner.Name FROM Account WHERE Name = :accountNameTM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, OwnerId, Owner.Name, Owner.Employee_Id__c');
        System.assertEquals(targetReplacedTM.Name, targetAccount.Owner.Name);
    }

}