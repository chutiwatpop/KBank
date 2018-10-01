@isTest
private class User_Test {

    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRMPer = 'tmCreatedAccountPer';
    public static String accountNameRMTemp = 'rmCreatedAccountTemp';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String newRMEmpId = '2000000001';
    public static String newTMEmpId = '2000000002';
    public static String newAHEmpId = '2000000003';
    public static String newNHEmpId = '2000000004';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    public static Map<String,User> mapUserMapByFirstName = new Map<String,User>();
    

    @testSetup static void setupUser(){
        Test.startTest();
            TriggerHandler.bypass('TeamStructureTriggerHandler');
            Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
            List<User> listUser = [SELECT Id,FirstName FROM User];

            for(User eachUser : listUser){
                mapUserMapByFirstName.put(eachUser.FirstName, eachUser);
            }

            System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM LIMIT 1][0]){
                mt.newAccount(accountNameRMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
                mt.newAccount(accountNameRMTemp,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
                //Account accountPer = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
                Account accountPer = Mockup_Test.getFirstAccountFromName(User_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c');
                // New Task
                Task newTask = Mockup_Test.newTask(UserInfo.getuserid(), accountPer.Id);
                insert newTask;

                // New Customer Owner Request
                Mockup_Test.newCustomerRequest(accountPer.Id,'Open',UserInfo.getUserId(),GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
                Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountPer.Id LIMIT 1];
                customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
                update customerRequest;
            }

            System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM LIMIT 1][0]){
                User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
                mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
                //Account targetAccount = [SELECT Id FROM Account WHERE Name = :User_Test.accountNameTM LIMIT 1];
                Account targetAccount = Mockup_Test.getFirstAccountFromName(User_Test.accountNameTM, 'Id, OwnerId, Owner.Employee_Id__c');
                targetAccount.Service_RM__c = rmUser.Id;
                update targetAccount;
            }

            System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH LIMIT 1][0]){
                mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            }
        Test.stopTest();
    }

    @isTest static void updateUser() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        
        String RM_SEC_RC = '78201';

        Team_Structure__c tsTm2 = new Team_Structure__c(
            Name = 'Test Team',
            RC_Code__c = RM_SEC_RC,
            External_ID__c = RM_SEC_RC
            );
        insert tsTm2;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Test.startTest();
                User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
                targetRM.RC_Code__c = RM_SEC_RC;
                update targetRM;
            Test.stopTest();
        }
    
        User newTargetRM = [SELECT Id, RC_Code__c, Employee_Id__c, ManagerId FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c newRmUserExt = [SELECT Id, External_Id__c, Team_Structure__r.External_Id__c FROM User_Extension__c WHERE User__c = :newTargetRM.Id LIMIT 1];
        System.assertEquals(RM_SEC_RC, newRmUserExt.Team_Structure__r.External_Id__c);

        //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        Account targetTempAccount = Mockup_Test.getFirstAccountFromName(accountNameRMTemp, 'Id, OwnerId, Owner.Employee_Id__c');
        System.assertEquals(newTargetRM.Id, targetTempAccount.OwnerId);
    }

    //@isTest static void updateUserChangeVisibility() {
    //    TriggerHandler.bypass('TeamStructureTriggerHandler');
        
    //    Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
    //    Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
    //    Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
    //    Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

    //    UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
    //    User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

    //    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
    //        List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();
    //        List<UserRole> listUserRole = new List<UserRole>();
    //        UserRole newNHRole = Mockup_Test.newRole(newNHRCCode, 'RC' + newNHRCCode, null);
    //        listUserRole.add(newNHRole);

    //        UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, newNHRole.Id);
    //        listUserRole.add(newAHRole);

    //        UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
    //        listUserRole.add(newTmRole);

    //        UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
    //        listUserRole.add(newRmRole);
    //        insert listUserRole;

    //        Team_Structure__c tsNh = new Team_Structure__c(
    //            RC_Code__c = newNHRCCode,
    //            External_ID__c = newNHRCCode
    //        );
    //        listTeamStructure.add(tsNh);

    //        Team_Structure__c tsAh = new Team_Structure__c(
    //            NH_RC_Code__c = newNHRCCode,
    //            RC_Code__c = newAHRCCode,
    //            External_ID__c = newAHRCCode
    //        );
    //        listTeamStructure.add(tsAh);

    //        Team_Structure__c tsTm = new Team_Structure__c(
    //            NH_RC_Code__c = newNHRCCode,
    //            AH_RC_Code__c = newAHRCCode,
    //            RC_Code__c = newRCCode,
    //            External_ID__c = newRCCode
    //        );
    //        listTeamStructure.add(tsTm);

    //        insert listTeamStructure;

    //        Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
    //        areaBKK2.Group_Indicate__c = 'Chiangmai';
    //        areaBKK2.Name = 'RC' + newNHRCCode;
    //        areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
    //        insert areaBKK2;

    //        Test.startTest();
    //            User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
    //            targetRM.RC_Code__c = newRCCode;
    //            targetRM.AH_RC_Code__c = newAHRCCode;
    //            targetRM.NH_RC_Code__c = newNHRCCode;
    //            update targetRM;
    //        Test.stopTest();
    //    }
    //    User newTargetRM = [SELECT Id, RC_Code__c, Employee_Id__c, ManagerId FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
        
    //    //Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(User_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c');
    //    System.assertEquals(newTargetRM.ManagerId, targetAccount.OwnerId);
        
    //    //Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
    //    Account targetTempAccount = Mockup_Test.getFirstAccountFromName(User_Test.accountNameRMTemp, 'Id, OwnerId, Owner.Employee_Id__c');
    //    System.assertEquals(newTargetRM.ManagerId, targetTempAccount.OwnerId);

    //}

    //@isTest static void inactiveRM() {
    //    Test.startTest();
    //        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
    //            User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
    //            targetRM.IsActive = false;
    //            targetRM.Status__c = 'I';
    //            update targetRM;
    //        }
    //    Test.stopTest();
        
    //    User newTargetTM = [SELECT Id FROM User WHERE FirstName = :Mockup_Test.userFirstNameTM LIMIT 1];

    //    //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(User_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c');
    //    System.assertEquals(newTargetTM.Id, targetAccount.OwnerId);
        
    //    Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
    //    System.assertEquals('Closed by System', targetTask.Status);

    //    //Account targetAccountTM = [SELECT Id, Service_RM__c FROM Account WHERE Name = :User_Test.accountNameTM LIMIT 1];
    //    Account targetAccountTM = Mockup_Test.getFirstAccountFromName(User_Test.accountNameTM, 'Id, Service_RM__c');
    //    System.assertEquals(null, targetAccountTM.Service_RM__c);
    //}

    @isTest static void testCurrentOpportunityApproverWhenAHisActiveAndNHisActiveRM(){
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            
            System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisActiveRM(){
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            
            userAH.IsActive = false;
            update userAH;
            userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            System.assertEquals(userNH.Id,userRM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisInactiveRM(){
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            
            System.assertEquals(userRM.Manager.ManagerId,userRM.Current_Opportunity_Approval__c);
            List<User> userAHandNH = new List<User>();

            userAH.IsActive = false;
            userAHandNH.add(userAH);
            userNH.IsActive = false;
            userAHandNH.add(userNH);
            update userAHandNH;
            
            userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            System.assertEquals(null,userRM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisActiveAndNHisActiveTM(){
        Test.startTest();
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];
            
            System.assertEquals(userAH.Id,userTM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisActiveTM(){
        Test.startTest();
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];
            
            System.assertEquals(userTM.ManagerId,userTM.Current_Opportunity_Approval__c);
            
            userAH.IsActive = false;
            update userAH;
            

            userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            System.assertEquals(userNH.Id,userTM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisInactiveTM(){
        Test.startTest();
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];

            System.assertEquals(userTM.ManagerId,userTM.Current_Opportunity_Approval__c);

            List<User> userAHandNH = new List<User>();
            
            userAH.IsActive = false;
            userAHandNH.add(userAH);
            userNH.IsActive = false;
            userAHandNH.add(userNH);
            update userAHandNH;

            userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            System.assertEquals(null,userTM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisActiveAndNHisActiveAndUpdateRM(){
        User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
        User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
        
        System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);

        List<User> userToUpdateList = new List<User>();

        Test.startTest();
            userRM.Effective_Date__c = null;
            userToUpdateList.add(userRM);
            userAH.IsActive = true;
            userToUpdateList.add(userAH);
            userNH.IsActive = true;
            userToUpdateList.add(userNH);
            update userToUpdateList;
        Test.stopTest();

        userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisActiveAndUpdateRM(){
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            
            System.assertEquals(userRM.Manager.ManagerId,userRM.Current_Opportunity_Approval__c);

            List<User> userToUpdateList = new List<User>();
            
            userRM.Effective_Date__c = null;
            userToUpdateList.add(userRM);
            userAH.IsActive = false;
            userToUpdateList.add(userAH);
            userNH.IsActive = true;
            userToUpdateList.add(userNH);
            update userToUpdateList;

            userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            System.assertEquals(userNH.Id,userRM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisInactiveAndUpdateRM(){
        User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
        User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
        
        System.assertEquals(userRM.Manager.ManagerId,userRM.Current_Opportunity_Approval__c);

        List<User> userToUpdateList = new List<User>();
        System.runAs([SELECT Id, FirstName FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Test.startTest();
                userRM.Effective_Date__c = null;
                userToUpdateList.add(userRM);
                userAH.IsActive = false;
                userToUpdateList.add(userAH);
                userNH.IsActive = false;
                userToUpdateList.add(userNH);
                update userToUpdateList;
            Test.stopTest();    
        }

        userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(null,userRM.Current_Opportunity_Approval__c);
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisActiveAndNHisActiveAndUpdateTM(){
        Test.startTest();
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];

            System.assertEquals(userAH.Id,userTM.Current_Opportunity_Approval__c);

            List<User> userToUpdateList = new List<User>();

            userTM.Effective_Date__c = null;
            userToUpdateList.add(userTM);
            userAH.IsActive = true;
            userToUpdateList.add(userAH);
            userNH.IsActive = true;
            userToUpdateList.add(userNH);
            update userToUpdateList;
            
            userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            System.assertEquals(userAH.Id,userTM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisActiveAndUpdateTM(){
        Test.startTest();
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];

            System.assertEquals(userAH.Id,userTM.Current_Opportunity_Approval__c);

            List<User> userToUpdateList = new List<User>();
            
            userTM.Effective_Date__c = null;
            userToUpdateList.add(userTM);
            userAH.IsActive = false;
            userToUpdateList.add(userAH);
            userNH.IsActive = true;
            userToUpdateList.add(userNH);
            update userToUpdateList;

            userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
            System.assertEquals(userNH.Id,userTM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testCurrentOpportunityApproverWhenAHisInactiveAndNHisInactiveAndUpdateTM(){
        User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.ManagerId];
        User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userTM.Manager.ManagerId];

        System.assertEquals(userAH.Id,userTM.Current_Opportunity_Approval__c);

        List<User> userToUpdateList = new List<User>();
        
        System.runAs([SELECT Id, FirstName FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Test.startTest();
                userTM.Effective_Date__c = null;
                userToUpdateList.add(userTM);
                userAH.IsActive = false;
                userToUpdateList.add(userAH);
                userNH.IsActive = false;
                userToUpdateList.add(userNH);
                update userToUpdateList;
            Test.stopTest();    
        }

        userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        System.assertEquals(null,userTM.Current_Opportunity_Approval__c);
    }

    @isTest static void testOverrideCurrentOpportunityApproval(){
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            
            List<User> userToUpdateList = new List<User>();

            System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);
            
            userRM.Current_Opportunity_Approval__c = userNH.Id;
            update userRM;

            userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            System.assertEquals(userNH.Id,userRM.Current_Opportunity_Approval__c);
        Test.stopTest();
    }

    @isTest static void testUserChangeManagerAndAHNHIsInactiveAndCurrentOpportunityApprovalShouldChangeToNull(){
        String newTMRCCode1 = '77877';
        String newAHRCCode1 = '77876';
        String newNHRCCode1 = '77875';

        String userEmpIdRM2 = '1000000095';
        String userEmpIdTM2 = '1000000096';
        String userEmpIdAH2 = '1000000097';
        String userEmpIdNH2 = '1000000098';

        String nhTeamName1 = 'nhTeam2';
        String ahTeamName1 = 'ahTeam2';
        String tmTeamName1 = 'tmTeam2';

        String userFirstNameAH2 = 'FirstAH2';
        String userLastNameAH2 = 'LastAH2';

        String userFirstNameNH2 = 'FirstNH2';
        String userLastNameNH2 = 'LastNH2';

        String teamSegment1 = 'Test segment 11';
        
        Test.startTest();
            User userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
            User userTM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.ManagerId];
            User userAH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, ProfileId, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.ManagerId];
            User userNH = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, ProfileId, Current_Opportunity_Approval__c FROM User WHERE Id =: userRM.Manager.Manager.ManagerId];
            List<User> userToUpdateList = new List<User>();

            System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);

            System.runAs(new User(Id = UserInfo.getUserId())){
                Team_Structure__c newTsNH = new Team_Structure__c(
                    External_ID__c = newNHRCCode1,
                    RC_Code__c = newNHRCCode1,
                    AH_RC_Code__c = null,
                    NH_RC_Code__c = null,
                    Name = nhTeamName1,
                    Segment__c = teamSegment1,
                    Type__c = 'Network'
                );
                insert newTsNH;

                Team_Structure__c newTsAH = new Team_Structure__c(
                    External_ID__c = newAHRCCode1,
                    RC_Code__c = newAHRCCode1,
                    AH_RC_Code__c = null,
                    NH_RC_Code__c = newNHRCCode1,
                    AH_Name__c = null,
                    NH_Name__c = newTsNH.Id,
                    Name = ahTeamName1,
                    Segment__c = teamSegment1,
                    Type__c = 'Area'
                );
                insert newTsAH;

                Team_Structure__c newTsTM = new Team_Structure__c(
                    External_ID__c = newTMRCCode1,
                    RC_Code__c = newTMRCCode1,
                    AH_RC_Code__c = newAHRCCode1,
                    NH_RC_Code__c = newNHRCCode1,
                    AH_Name__c = newTsAH.Id,
                    NH_Name__c = newTsNH.Id,
                    Name = tmTeamName1,
                    Segment__c = teamSegment1,
                    Type__c = 'Team'
                );
                insert newTsTM;

                User nh2 = new User(
                    FirstName = userFirstNameNH2,
                    LastName = userLastNameNH2,
                    IsActive = false,
                    RC_Code__c = newNHRCCode1,
                    AH_RC_Code__c = newNHRCCode1,
                    UserName = userFirstNameNH2+'@testmail.com',
                    Email = userFirstNameNH2+'@testmail.com',
                    Alias = userFirstNameNH2,
                    CommunityNickName = userFirstNameNH2+'commu',
                    ProfileId = userNH.ProfileId,
                    Employee_Id__c = userEmpIdNH2
                );
                insert nh2;

                User ah2 = new User(
                    FirstName = userFirstNameAH2,
                    LastName = userLastNameAH2,
                    IsActive = false,
                    RC_Code__c = newAHRCCode1,
                    AH_RC_Code__c = newAHRCCode1,
                    UserName = userFirstNameAH2+'@testmail.com',
                    Email = userFirstNameAH2+'@testmail.com',
                    Alias = userFirstNameAH2,
                    CommunityNickName = userFirstNameAH2+'commu',
                    ProfileId = userAH.ProfileId,
                    ManagerId = nh2.Id,
                    Employee_Id__c = userEmpIdAH2
                );
                insert ah2;

                User tm2 = new User(
                    FirstName = 'tm2',
                    LastName = 'tm2',
                    IsActive = true,
                    RC_Code__c = newTMRCCode1,
                    UserName = 'tm2@testmail.com',
                    Email = 'tm2@testmail.com',
                    Alias = 'tm2',
                    CommunityNickName = 'tm2commu',
                    ProfileId = userTM.ProfileId,
                    ManagerId = ah2.Id,
                    Employee_Id__c = userEmpIdTM2
                );
                insert tm2;
            }

            User userTM2 = [SELECT Id FROM User WHERE FirstName = 'tm2'];
            User userAH2 = [SELECT Id FROM User WHERE FirstName =: userFirstNameAH2];
            User userNH2 = [SELECT Id FROM User WHERE FirstName =: userFirstNameNH2];

            System.runAs(new User(Id=UserInfo.getUserId())){
                userRM.AH_RC_Code__c = newAHRCCode1;
                userRM.NH_RC_Code__c = newNHRCCode1;
                userRM.ManagerId = userTM2.Id;
                update userRM;
            }
        Test.stopTest();

        userRM = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(null,userRM.Current_Opportunity_Approval__c);
    }
}