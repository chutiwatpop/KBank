/**
* @author chutiwat.s@beryl8.com
* @11/09/2015 createddate
*/
@isTest
private class ForceUpdateUsers_Batch_Test {

    public static String newRMEmpId = 'TEST01';
    public static String newTMEmpId = 'TEST02';
    public static String newAHEmpId = 'TEST03';
    public static String newNHEmpId = 'TEST04';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    @testSetup static void setupUser(){
        //Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        //Test.stopTest();
        System.runAs( [SELECT Id FROM User WHERE Firstname =:Mockup_Test.userFirstNameAdmin LIMIT 1][0] ){
            User smeRM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            User smeTM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
            smeRM.Current_Opportunity_Approval__c = null;
            smeTM.Current_Opportunity_Approval__c = null;
            TriggerHandler.bypass('UserTriggerHandler');
            update smeRM;
            update smeTM;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
    }

    @isTest static void testAddNoJobCode(){
       
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                newRMName, 
                newRMName, 
                'job', 
                'A', 
                System.today() - 1);
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newRMName].size());

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2;
                Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newRMName].size());
        }
    }

    @isTest static void testAddNoDevName(){
       
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                '71375', 
                newRMName, 
                newRMName, 
                'ME4A', 
                'A', 
                System.today() - 1);
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newRMName].size());

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2;
                Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newRMName].size());
        }
    }

    @isTest static void testAddUser(){
       
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                newAHEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newAHName, 
                newAHName, 
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newAHName].size());

            System.assertEquals(1, [SELECT Id FROM User WHERE UserRole.DeveloperName =:('RCRM' + Mockup_Test.RC_CODE) AND IsActive = true].size());

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 3;
                batch.totalMaxLicense = 4;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal = [SELECT Id, IsActive, Status__c FROM User WHERE FirstName =:newAHName LIMIT 1];

            System.assertNotEquals(0, [SELECT Id FROM User WHERE FirstName =:newAHName].size());
            System.assertEquals(true, ahFinal.IsActive);
            System.assertEquals('A', ahFinal.Status__c);

            System.assertEquals(1, [SELECT Id FROM User WHERE UserRole.DeveloperName =:('RCRM' + Mockup_Test.RC_CODE) AND IsActive = true].size());
        }
    }

   @isTest static void testInactiveTmAndAh(){
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
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

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'I', 
                System.today()
            );

            insert tmUserStruc;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User nhFinal = [SELECT Id, FirstName FROM User WHERE FirstName =:Mockup_Test.userFirstNameNH LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];

            User rmManager = [SELECT Id, Firstname, UserRole.DeveloperName FROM User WHERE Id =:rmFinal.ManagerId LIMIT 1];
            
            List<User> activeTmList = new List<User>();
            activeTmList = [SELECT Id FROM User WHERE User.IsActive = true AND UserRole.DeveloperName = :('RC' + Mockup_Test.RC_CODE)];

            if (activeTmList.isEmpty()) {
                List<User> activeAhList = new List<User>();
                activeAhList = [SELECT Id FROM User WHERE User.IsActive = true AND UserRole.DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];
                
                if (activeAhList.isEmpty()) {
                    System.assertEquals('RC' + Mockup_Test.NH_RC_CODE, rmManager.UserRole.DeveloperName);
                    System.assertEquals(nhFinal.FirstName, rmManager.FirstName);
                    System.assertEquals(nhFinal.Id, rmFinal.ManagerId);
                } else {
                    System.assertEquals('RC' + Mockup_Test.AH_RC_CODE, rmManager.UserRole.DeveloperName); 
                }
            } else {
                System.assertEquals('RC' + Mockup_Test.RC_CODE, rmManager.UserRole.DeveloperName);
            }

        }
    }

    @isTest static void testInactiveTm(){
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'I', 
                System.today()
            );

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
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
            newRmUserStruc.Segment__c = 'segment01';
            newRmUserStruc.Team_Name__c = 'team01';

            insert newRmUserStruc;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal = [SELECT Id FROM User WHERE FirstName =:Mockup_Test.userFirstNameAH LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User newRmFinal = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];

            User rmManager = [SELECT FirstName, UserRole.DeveloperName FROM User WHERE Id = :rmFinal.ManagerId LIMIT 1];
            User newRmFinalManager = [SELECT UserRole.DeveloperName FROM User WHERE Id = :newRmFinal.ManagerId LIMIT 1];

            System.assertEquals('RC' + Mockup_Test.AH_RC_CODE, rmManager.UserRole.DeveloperName);
            System.assertEquals('RC' + Mockup_Test.AH_RC_CODE, newRmFinalManager.UserRole.DeveloperName);

            System.assertEquals(ahFinal.Id, rmFinal.ManagerId);
            System.assertEquals(ahFinal.Id, newRmFinal.ManagerId);
        }
    }

    
    @isTest static void testInActiveRm() {
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
                System.today()
            );

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User finalRm = [SELECT Id, IsActive, Status__c FROM User WHERE Firstname =:Mockup_Test.userFirstNameRM LIMIT 1];
            System.assertEquals('I', finalRm.Status__c);
            System.assertEquals(false, finalRm.IsActive);
        }
    }

    @isTest static void testChangeTm(){
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];

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

            insert secondTMUser;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c secondTMUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newTMName,
                newTMName,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            secondTMUserStruc.Segment__c = 'segment01';
            secondTMUserStruc.Team_Name__c = 'team01';

            insert secondTMUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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
            tmUserStruc.Segment__c = 'segment01';
            tmUserStruc.Team_Name__c = 'team01';

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newRMName,
                newRMName,
                'ME4A', 
                'A', 
                System.today() - 1
            );
            newRmUserStruc.Segment__c = 'segment01';
            newRmUserStruc.Team_Name__c = 'team01';

            insert newRmUserStruc;

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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User tmFinal = [SELECT Id FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];

            System.assertEquals(tmFinal.Id, rmFinal.ManagerId);

            User newRmFinal = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];
            System.assertEquals(tmFinal.Id, newRmFinal.ManagerId);

            User oldTm = [SELECT Id, IsActive, Status__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            System.assertEquals('I', oldTm.Status__c);
            System.assertEquals(false, oldTm.IsActive);
        }
    }

    @isTest static void testChangeTmButNotEffective(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];

        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, userAH.UserRoleId);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                false, 
                tmProfile.Id,
                newTmRole.Id,
                userAH.Id
            );

            insert secondTMUser;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c secondTMUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newTMName,
                newTMName,
                'ME3A', 
                'A', 
                System.today() + 1
            );
            secondTMUserStruc.Segment__c = 'segment01';
            secondTMUserStruc.Team_Name__c = 'team01';

            insert secondTMUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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
            tmUserStruc.Segment__c = 'segment01';
            tmUserStruc.Team_Name__c = 'team01';

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newRMName,
                newRMName,
                'ME4A', 
                'A', 
                System.today() - 1
            );
            newRmUserStruc.Segment__c = 'segment01';
            newRmUserStruc.Team_Name__c = 'team01';

            insert newRmUserStruc;

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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User tmFinal = [SELECT Id FROM User WHERE FirstName =:newTMName LIMIT 1];
            User ahFinal = [SELECT Id FROM User WHERE FirstName =:Mockup_Test.userFirstNameAH LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];

            System.assertNotEquals(tmFinal.Id, rmFinal.ManagerId);
            System.assertEquals(ahFinal.Id, rmFinal.ManagerId);

            User newRmFinal = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];
            System.assertNotEquals(tmFinal.Id, newRmFinal.ManagerId);
            System.assertEquals(ahFinal.Id, newRmFinal.ManagerId);
        }
    }

    @isTest static void testChangeToNewTm(){
        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, userRoleAh.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                null, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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
            tmUserStruc.Segment__c = 'segment01';
            tmUserStruc.Team_Name__c = 'team01';

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newRMName,
                newRMName,
                'ME4A', 
                'A', 
                System.today() - 1
            );
            newRmUserStruc.Segment__c = 'segment01';
            newRmUserStruc.Team_Name__c = 'team01';

            insert newRmUserStruc;

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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            User_Structure__c newTMUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newTMName,
                newTMName,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            newTMUserStruc.Segment__c = 'segment01';
            newTMUserStruc.Team_Name__c = 'team01';

            insert newTMUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User newTmFinal = [SELECT Id FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            
            System.assertEquals(newTmFinal.Id, rmFinal.ManagerId);

            User newRmFinal = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];
            System.assertEquals(newTmFinal.Id, newRmFinal.ManagerId);

        }
    }

    @isTest static void testChangeAh(){
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        User userNH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        UserRole userRoleNH = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole newAhRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, userRoleNH.Id);
            insert newAhRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAhRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            User newAHUser = Mockup_Test.newUser(
                newAHName,
                newAHName,
                newAHEmpId, 
                true, 
                ahProfile.Id,
                newAhRole.Id,
                userNH.Id
            );

            insert newAHUser;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
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
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c ahUserStruc2 = Mockup_Test.newUserStructure(
                newAHEmpId, 
                Mockup_Test.NH_RC_CODE, 
                newAHRCCode, 
                newAHRCCode, 
                newAHName,
                newAHName,
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc2.Segment__c = 'segment01';
            ahUserStruc2.Team_Name__c = 'team01';

            insert ahUserStruc2;

            User_Structure__c newTMUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                newAHRCCode, 
                newRCCode, 
                newTMName,
                newTMName,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            newTMUserStruc.Segment__c = 'segment01';
            newTMUserStruc.Team_Name__c = 'team01';

            insert newTMUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                newAHRCCode, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            tmUserStruc.Segment__c = 'segment01';
            tmUserStruc.Team_Name__c = 'team01';

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newRMName,
                newRMName,
                'ME4A', 
                'A', 
                System.today() - 1
            );
            newRmUserStruc.Segment__c = 'segment01';
            newRmUserStruc.Team_Name__c = 'team01';

            insert newRmUserStruc;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal2 = [SELECT Id FROM User WHERE FirstName =:newAHName LIMIT 1];
            User tmFinal = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            User tmFinal2 = [SELECT Id, ManagerId FROM User WHERE FirstName =:newTMName LIMIT 1];

            System.assertEquals(ahFinal2.Id, tmFinal.ManagerId);
            System.assertEquals(ahFinal2.Id, tmFinal2.ManagerId);

            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];

            System.assertEquals(tmFinal.Id, rmFinal.ManagerId);

            User rmFinal2 = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];
            System.assertEquals(tmFinal2.Id, rmFinal2.ManagerId);
        }
    }

    @isTest static void testTmChangeTeam(){
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole tmRole2 = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, userRoleAh.Id);
            insert tmRole2;

            UserRole rmRole2 = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, tmRole2.Id);
            insert rmRole2;

            UserRole tmRole3 = Mockup_Test.newRole('33333', 'RC' + '33333', userRoleAh.Id);
            insert tmRole3;

            UserRole rmRole3 = Mockup_Test.newRole('33333', 'RCRM' + '33333', tmRole3.Id);
            insert rmRole3;

            User tmUser2 = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                tmRole2.Id,
                userAh.Id
            );

            insert tmUser2;

            User rmUser2 = Mockup_Test.newUser(
                newRMName,
                newRMName,
                newRMEmpId, 
                true, 
                rmProfile.Id,
                rmRole2.Id,
                userTM.Id // old tm 
            );

            insert rmUser2;

            User tmUser3 = Mockup_Test.newUser(
                'thrdTMName',
                'thrdTMName',
                'TCH002', 
                true, 
                tmProfile.Id,
                tmRole3.Id,
                userAh.Id
            );

            insert tmUser3;

            User rmUser3 = Mockup_Test.newUser(
                'thrdRMName',
                'thrdRMName',
                'TCH001', 
                true, 
                rmProfile.Id,
                rmRole3.Id,
                tmUser2.Id //old tm 02
            );

            insert rmUser3;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                '070707', 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            tmUserStruc.Segment__c = 'segment07';
            tmUserStruc.Team_Name__c = 'team07';

            insert tmUserStruc;

            User_Structure__c tmUserStruc2 = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newTMName,
                newTMName,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            tmUserStruc2.Segment__c = 'segment01';
            tmUserStruc2.Team_Name__c = 'team01';

            insert tmUserStruc2;

            User_Structure__c tmUserStruc3 = Mockup_Test.newUserStructure(
                'TCH002', 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                '33333', 
                'thrdTMName',
                'thrdTMName',
                'ME3A', 
                'A', 
                System.today() - 1
            );
            tmUserStruc3.Segment__c = 'segment02';
            tmUserStruc3.Team_Name__c = 'team02';

            insert tmUserStruc3;

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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            User_Structure__c rmUserStruc2 = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                newRCCode, 
                newRMName,
                newRMName,
                'ME4A', 
                'A', 
                System.today() - 1
            );
            rmUserStruc2.Segment__c = 'segment01';
            rmUserStruc2.Team_Name__c = 'team01';

            insert rmUserStruc2;

            User_Structure__c rmUserStruc3 = Mockup_Test.newUserStructure(
                'TCH001', 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                '33333', 
                'thrdRMName',
                'thrdRMName',
                'ME4A', 
                'A', 
                System.today() - 1
            );
            rmUserStruc3.Segment__c = 'segment02';
            rmUserStruc3.Team_Name__c = 'team02';

            insert rmUserStruc3;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 11;
                Database.executeBatch(batch);
            Test.stopTest();

            User tmFinal2 = [SELECT Id FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User rmFinal2 = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];

            System.assertEquals(tmFinal2.Id, rmFinal.ManagerId);
            System.assertEquals(tmFinal2.Id, rmFinal2.ManagerId);

            User tmFinal3 = [SELECT Id FROM User WHERE FirstName = 'thrdTMName' LIMIT 1];
            User rmFinal3 = [SELECT ManagerId FROM User WHERE FirstName = 'thrdRMName' LIMIT 1];

            System.assertEquals(tmFinal3.Id, rmFinal3.ManagerId);

        }
    }

   //@isTest static void testUpdateToActive(){

   //     System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

   //         User tmUser = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
   //         tmUser.IsActive = false;
   //         tmUser.Status__c = 'I';
   //         update tmUser;

   //         User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
   //             Mockup_Test.userEmpIdTM, 
   //             Mockup_Test.NH_RC_CODE, 
   //             Mockup_Test.AH_RC_CODE, 
   //             Mockup_Test.RC_CODE, 
   //             Mockup_Test.userFirstNameTM,
   //             Mockup_Test.userLastNameTM,
   //             'ME3A', 
   //             'A', 
   //             System.today() - 1
   //         );
   //         tmUserStruc.Segment__c = 'segment07';
   //         tmUserStruc.Team_Name__c = 'team07';

   //         insert tmUserStruc;

   //         User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
   //             Mockup_Test.userEmpIdRM, 
   //             Mockup_Test.NH_RC_CODE, 
   //             Mockup_Test.AH_RC_CODE, 
   //             Mockup_Test.RC_CODE,
   //             Mockup_Test.userFirstNameRM,
   //             Mockup_Test.userLastNameRM,
   //             'ME4A', 
   //             'A',
   //             System.today() - 1
   //         );
   //         rmUserStruc.Segment__c = 'segment01';
   //         rmUserStruc.Team_Name__c = 'team01';

   //         insert rmUserStruc;

   //         Test.startTest();
   //             ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
   //             batch.totalActiveUser = 0;
   //             batch.totalMaxLicense = 4;
   //             Database.executeBatch(batch);
   //         Test.stopTest();

   //         User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
   //         User tmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
   //         User ahFinal = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameAH LIMIT 1];

   //         System.assertEquals(tmFinal.Id, rmFinal.ManagerId);
   //         System.assertEquals(ahFinal.Id, tmFinal.ManagerId);
   //     }
   // }

    @isTest static void testChangeRoleTmToAhAndAddNewNH(){

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            //UserRole nhRole2 = Mockup_Test.newRole(newNHRCCode, 'RC' + newNHRCCode, null);
            //insert nhRole2;

            //User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
            //    newNHEmpId, 
            //    newNHRCCode, 
            //    null, 
            //    newNHRCCode, 
            //    newNHName,
            //    newNHName,
            //    'ME1A', 
            //    'A', 
            //    System.today() - 1
            //);
            //nhUserStruc.Segment__c = 'segment01';
            //nhUserStruc.Team_Name__c = 'team01';

            //insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
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
            ahUserStruc.Segment__c = 'segment01';
            ahUserStruc.Team_Name__c = 'team01';

            insert ahUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            System.assertNotEquals(null, [SELECT Id FROM User WHERE Firstname = :newNHName LIMIT 1]);

            User rmFinal    = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User tmAsAhFinal = [SELECT Id, ManagerId, UserRoleId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            User nhFinal    = [SELECT Id FROM User WHERE FirstName =:Mockup_Test.userFirstNameNH LIMIT 1];
            UserRole ahRole = [SELECT Id FROM UserRole WHERE DeveloperName  = :('RC' + Mockup_Test.AH_RC_CODE) LIMIT 1];

            System.assertEquals(tmAsAhFinal.Id, rmFinal.ManagerId);
            System.assertEquals(ahRole.Id, tmAsAhFinal.UserRoleId);

            User managerOfNewAh = [SELECT Id, UserRole.DeveloperName FROM User WHERE Id = :tmAsAhFinal.ManagerId LIMIT 1];
            System.assertEquals('RC' + Mockup_Test.NH_RC_CODE, managerOfNewAh.UserRole.DeveloperName);

        }
    }

    @isTest static void testChangeTmSameRcCode(){
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userTM = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        UserRole userRoleAh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                userTM.UserRoleId,
                userAH.Id
            );

            insert secondTMUser;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );

            insert ahUserStruc;

            User_Structure__c secondTMUserStruc = Mockup_Test.newUserStructure(
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

            insert secondTMUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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

            insert tmUserStruc;

            User_Structure__c newRmUserStruc = Mockup_Test.newUserStructure(
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

            insert newRmUserStruc;

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today() - 1
            );

            insert rmUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 5;
                Database.executeBatch(batch);
            Test.stopTest();

            User oldTmFinal = [SELECT Status__c, IsActive FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            System.assertEquals('I', oldTmFinal.Status__c);
            System.assertEquals(false, oldTmFinal.IsActive);

            User tmFinal = [SELECT Id FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User rmManager = [SELECT UserRole.DeveloperName FROM User WHERE Id = :rmFinal.ManagerId LIMIT 1];

            //System.assertEquals(tmFinal.Id, rmFinal.ManagerId);

            System.assertEquals('RC' + Mockup_Test.RC_CODE, rmManager.UserRole.DeveloperName);

            User newRmFinal = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];
            User newRmFinalManager = [SELECT UserRole.DeveloperName FROM User WHERE Id = :newRmFinal.ManagerId LIMIT 1];

            System.assertEquals('RC' + Mockup_Test.RC_CODE, newRmFinalManager.UserRole.DeveloperName);
            //System.assertEquals(tmFinal.Id, newRmFinal.ManagerId);

        }
    }

    @isTest static void testUpdateField(){

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
            insert new Job_Code__c(Name = 'SE1A', Profile_Name__c = nhProfile.Name);

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                newNHName,
                newNHName + 'lastname',
                'SE1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = 'segment02';
            nhUserStruc.Team_Name__c = 'team02';

            insert nhUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2;
                Database.executeBatch(batch);
            Test.stopTest();

            User nhFinal = [SELECT Firstname, LastName, RC_Code__c, Status__c, IsActive, Job_Code__c FROM User WHERE Employee_ID__c =:Mockup_Test.userEmpIdNH LIMIT 1];

            System.assertEquals(newNHName, nhFinal.Firstname);
            System.assertEquals(newNHName + 'lastname', nhFinal.LastName);
            System.assertEquals(true, nhFinal.IsActive);
            System.assertEquals('SE1A', nhFinal.Job_Code__c);
        }
    }

    @isTest static void testUncheckActingFlag(){

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User userAH = [SELECT Id, Acting_Flag__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
            userAH.Acting_Flag__c = true;

            update userAH;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 5
            );

            insert ahUserStruc;

            Test.startTest();
                ForceUpdateUsers_Batch batch = new ForceUpdateUsers_Batch();
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal = [SELECT Acting_Flag__c FROM User WHERE Employee_ID__c =:Mockup_Test.userEmpIdAH LIMIT 1];

            System.assertEquals(false, ahFinal.Acting_Flag__c);
        }
    }

}