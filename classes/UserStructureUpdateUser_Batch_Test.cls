/**
* @author chutiwat.s@beryl8.com
* @11/09/2015 createddate
*/
@isTest
private class UserStructureUpdateUser_Batch_Test {

    public static String newRMEmpId = '7000999991';
    public static String newTMEmpId = '7000999992';
    public static String newAHEmpId = '7000999993';
    public static String newNHEmpId = '7000999994';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    @testSetup static void setupUser(){
        TestUtils.enable_isRunningTest = true;
        Mockup_Test.setUpCustomSetting();
        Mockup_Test mt = new Mockup_Test();
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            List<Profile> listProfile = new List<Profile>();
            //listProfile = [SELECT Id, Name FROM Profile];

            Map<String,Profile> mapProfileByName = new Map<String,Profile>();
            for(Profile eachProfile : [SELECT Id, Name FROM Profile]){
                mapProfileByName.put(eachProfile.Name, eachProfile);
            }

            List<Job_Code__c> listJobCode = new List<Job_Code__c>();
            Profile nhProfile = mapProfileByName.get(GlobalConstants.SME_NH);//[SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
            insert new Job_Code__c(Name = 'ME1A', Profile_Name__c = nhProfile.Name);
            
            Profile ahProfile = mapProfileByName.get(GlobalConstants.SME_AH);//[SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
            insert new Job_Code__c(Name = 'ME2A', Profile_Name__c = ahProfile.Name);
        
            Profile tmProfile = mapProfileByName.get(GlobalConstants.SME_TM);//[SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
            insert new Job_Code__c(Name = 'ME3A', Profile_Name__c = tmProfile.Name);
          
            Profile rmProfile = mapProfileByName.get(GlobalConstants.SME_RM);//[SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
            insert new Job_Code__c(Name = 'ME4A', Profile_Name__c = rmProfile.Name);

            UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
            UserRole nhRole = Mockup_Test.newRole(Mockup_Test.NH_RC_CODE, 'RC' + Mockup_Test.NH_RC_CODE, adminRole.Id);
            insert nhRole;
            UserRole ahRole = Mockup_Test.newRole(Mockup_Test.AH_RC_CODE, 'RC' + Mockup_Test.AH_RC_CODE, nhRole.Id);
            insert ahRole;
            UserRole tmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RC' + Mockup_Test.RC_CODE, ahRole.Id);
            insert tmRole;
            UserRole rmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RCRM' + Mockup_Test.RC_CODE, tmRole.Id);
            insert rmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = Mockup_Test.NH_RC_CODE,
                RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = Mockup_Test.nhTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                External_ID__c = Mockup_Test.AH_RC_CODE,
                RC_Code__c = Mockup_Test.AH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_Name__c = null,
                NH_Name__c = tsNh.Id,
                Name = Mockup_Test.ahTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Area'
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                External_ID__c = Mockup_Test.RC_CODE,
                RC_Code__c = Mockup_Test.RC_CODE,
                AH_RC_Code__c = Mockup_Test.AH_RC_CODE,
                NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
                AH_Name__c = tsAh.Id,
                NH_Name__c = tsNh.Id,
                Name = Mockup_Test.tmTeamName,
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Team'
            );
            insert tsTm;

            List<User> listUser = new List<User>();
            User nhUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameNH,
                    Mockup_Test.userLastNameNH,
                    true,
                    Mockup_Test.userFirstNameNH+'@mail.com',
                    Mockup_Test.userFirstNameNH+'@mail.com',
                    Mockup_Test.userFirstNameNH.substring(0, 4),
                    nhProfile.Id,
                    nhRole.Id,
                    null,
                    Mockup_Test.userEmpIdNH
            );
            nhUser.RC_Code__c = Mockup_Test.NH_RC_CODE;
            nhUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            nhUser.Job_Code__c = 'ME1A';
            nhUser.Status__c = 'A';
            nhUser.Segment__c = Mockup_Test.teamSegment1;
            insert nhUser;
            //listUser.add(nhUser);

            User ahUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameAH,
                    Mockup_Test.userLastNameAH,
                    true,
                    Mockup_Test.userFirstNameAH+'@mail.com',
                    Mockup_Test.userFirstNameAH+'@mail.com',
                    Mockup_Test.userFirstNameAH.substring(0, 4),
                    ahProfile.Id,
                    ahRole.Id,
                    nhUser.Id,
                    Mockup_Test.userEmpIdAH
            );
            ahUser.RC_Code__c = Mockup_Test.AH_RC_CODE;
            ahUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            ahUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
            ahUser.Job_Code__c = 'ME2A';
            ahUser.Status__c = 'A';
            ahUser.Segment__c = Mockup_Test.teamSegment1;
            ahUser.ManagerId = nhUser.Id;
            insert ahUser;
            //listUser.add(ahUser);

            User tmUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameTM,
                    Mockup_Test.userLastNameTM,
                    true,
                    Mockup_Test.userFirstNameTM+'@mail.com',
                    Mockup_Test.userFirstNameTM+'@mail.com',
                    Mockup_Test.userFirstNameTM.substring(0, 4),
                    tmProfile.Id,
                    tmRole.Id,
                    ahUser.Id,
                    Mockup_Test.userEmpIdTM
             );
            tmUser.Job_Code__c = 'ME3A';
            tmUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
            tmUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            tmUser.RC_Code__c = Mockup_Test.RC_CODE;
            tmUser.Status__c = 'A';
            tmUser.Segment__c = Mockup_Test.teamSegment1;
            tmUser.ManagerId = ahUser.Id;
            insert tmUser;
            //listUser.add(tmUser);

            User rmUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameRM,
                    Mockup_Test.userLastNameRM,
                    true,
                    Mockup_Test.userFirstNameRM+'@mail.com',
                    Mockup_Test.userFirstNameRM+'@mail.com',
                    Mockup_Test.userFirstNameRM.substring(0, 4),
                    rmProfile.Id,
                    rmRole.Id,
                    tmUser.Id,
                    Mockup_Test.userEmpIdRM
             );
            rmUser.Job_Code__c = 'ME4A';
            rmUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
            rmUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            rmUser.RC_Code__c = Mockup_Test.RC_CODE;
            rmUser.Status__c = 'A';
            rmUser.Segment__c = Mockup_Test.teamSegment1;
            rmUser.ManagerId = tmUser.Id;
            insert rmUser;
            //listUser.add(rmUser);
            //insert listUser;

            //ahUser.managerId = nhUser.Id;
            //tmUser.managerId = ahUser.Id;
            //rmUser.managerId = tmUser.Id;
            //List<User> listUpdateManager = new List<User>();
            //listUpdateManager.add(ahUser);
            //listUpdateManager.add(tmUser);
            //listUpdateManager.add(rmUser);
            //update listUpdateManager;

            Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
            areaBKK1.Group_Indicate__c = 'Bangkok';
            areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
            areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.1)';
            insert areaBKK1;
            mt.setUpTestAdmin();
            Test.stopTest();
        }
        
    }

    @isTest static void testHRISSendNewUserProfileSmeRmTmAndSystemHasAhNhButAhIsInactiveThenCurrentOpportunityApprovalOfRmAndTmMustBeNH(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
        User userNH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            User_Structure__c inactiveAhUserStruc = Mockup_Test.newUserStructure(
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
            inactiveAhUserStruc.Segment__c = 'segment01';
            inactiveAhUserStruc.Team_Name__c = 'team01';

            insert inactiveAhUserStruc;

            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
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
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
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
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(userNH.Id,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(userNH.Id,secondTmUserFinal.Current_Opportunity_Approval__c);
        }
    }

    @isTest static void testHRISSendNewUserProfileSmeRmTmAndSystemHasAhNhButAhNhIsInactiveThenCurrentOpportunityApprovalOfRmAndTmMustBeNull(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            User_Structure__c inactiveNhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'I', 
                System.today() - 1
            );
            inactiveNhUserStruc.Segment__c = 'segment01';
            inactiveNhUserStruc.Team_Name__c = 'team01';

            insert inactiveNhUserStruc;

            User_Structure__c inactiveAhUserStruc = Mockup_Test.newUserStructure(
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
            inactiveAhUserStruc.Segment__c = 'segment01';
            inactiveAhUserStruc.Team_Name__c = 'team01';

            insert inactiveAhUserStruc;

            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
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
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
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
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(null,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(null,secondTmUserFinal.Current_Opportunity_Approval__c);
        }
    }

    @isTest static void testHRISSendNewUserProfileSmeRmTmAndSystemHasAhNhThenCurrentOpportunityApprovalOfRmAndTmMustBeAH(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
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
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
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
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(userAH.Id,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(userAH.Id,secondTmUserFinal.Current_Opportunity_Approval__c);
        }
    }

    @isTest static void testHRISSendNewUserProfileSmeRmTmAndSystemHasNoAHButHasNHThenCurrentOpportunityApprovalOfRmAndTmMustBeNH(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userNH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.RC_CODE,
                newTMName,
                newTMName,
                'ME3A', 
                'A',
                System.today() - 1
            );
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;
            System.debug('SecondTMUserStruc : '+secondTmUserStruc);

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.RC_CODE,
                newRMName,
                newRMName,
                'ME4A', 
                'A',
                System.today() - 1
            );
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;
            System.debug('SecondRMUserStruc : '+secondRmUserStruc);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(userNH.Id,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(userNH.Id,secondTmUserFinal.Current_Opportunity_Approval__c);
        }
    }

    @isTest static void testHRISSendExistingUserProfileSmeRmTmAndSystemHasAHNHThenCurrentOpportunityApprovalOfRmAndTmMustBeAH(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userNH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

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

            User secondRmUser = Mockup_Test.newUser(
                newRMName,
                newRMName,
                newRMEmpId, 
                false, 
                rmProfile.Id,
                newRmRole.Id,
                secondTMUser.Id
            );
            secondRmUser.Segment__c = 'segment01';
            secondRmUser.Team_Name__c = 'team01';

            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
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
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;
            System.debug('SecondTMUserStruc : '+secondTmUserStruc);

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
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
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;
            System.debug('SecondRMUserStruc : '+secondRmUserStruc);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(userAH.Id,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(userAH.Id,secondTmUserFinal.Current_Opportunity_Approval__c);
        }
    }

    @isTest static void testHRISSendExistingUserProfileSmeRmTmAndSystemHasNoAHThenCurrentOpportunityApprovalOfRmAndTmMustBeNH(){
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userNH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

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

            User secondRmUser = Mockup_Test.newUser(
                newRMName,
                newRMName,
                newRMEmpId, 
                false, 
                rmProfile.Id,
                newRmRole.Id,
                secondTMUser.Id
            );
            secondRmUser.Segment__c = 'segment01';
            secondRmUser.Team_Name__c = 'team01';

            User_Structure__c secondTmUserStruc = Mockup_Test.newUserStructure(
                newTMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.RC_CODE,
                newTMName,
                newTMName,
                'ME3A', 
                'A',
                System.today() - 1
            );
            secondTmUserStruc.Segment__c = 'segment01';
            secondTmUserStruc.Team_Name__c = 'team01';
            insert secondTmUserStruc;
            System.debug('SecondTMUserStruc : '+secondTmUserStruc);

            User_Structure__c secondRmUserStruc = Mockup_Test.newUserStructure(
                newRMEmpId, 
                Mockup_Test.NH_RC_CODE, 
                null, 
                Mockup_Test.RC_CODE,
                newRMName,
                newRMName,
                'ME4A', 
                'A',
                System.today() - 1
            );
            secondRmUserStruc.Segment__c = 'segment01';
            secondRmUserStruc.Team_Name__c = 'team01';

            insert secondRmUserStruc;
            System.debug('SecondRMUserStruc : '+secondRmUserStruc);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User secondTmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newTMName];
            User secondRmUserFinal = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE FirstName = :newRMName];

            System.assertEquals(userNH.Id,secondRmUserFinal.Current_Opportunity_Approval__c);
            System.assertEquals(userNH.Id,secondTmUserFinal.Current_Opportunity_Approval__c);
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                'ME1A', 
                'A', 
                System.today() - 1);
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            System.assertEquals(0, [SELECT Id FROM User WHERE FirstName =:newRMName].size());

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 3;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal = [SELECT Id, IsActive, Status__c FROM User WHERE FirstName =:newAHName LIMIT 1];

            System.assertNotEquals(0, [SELECT Id FROM User WHERE FirstName =:newAHName].size());
            System.assertEquals(true, ahFinal.IsActive);
            System.assertEquals('A', ahFinal.Status__c);
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                //UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                //batch.totalActiveUser = 0;
                //batch.totalMaxLicense = 2000;
                //Database.executeBatch(batch);
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                //UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                //batch.totalActiveUser = 0;
                //batch.totalMaxLicense = 2000;
                //Database.executeBatch(batch);
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
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
            newAHUser.Job_Code__c = 'ME2A';
            newAHUser.RC_Code__c = newAHRCCode;

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
                //UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                //batch.totalActiveUser = 0;
                //batch.totalMaxLicense = 2000;
                //Database.executeBatch(batch);
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal2 = [SELECT Id,Name FROM User WHERE FirstName =:newAHName LIMIT 1];
            User tmFinal = [SELECT Id, ManagerId, Manager.Name FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            User tmFinal2 = [SELECT Id, ManagerId FROM User WHERE FirstName =:newTMName LIMIT 1];

            System.assertEquals(ahFinal2.Name, tmFinal.Manager.Name);
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
                '8000000001', 
                true, 
                tmProfile.Id,
                tmRole3.Id,
                userAh.Id
            );

            insert tmUser3;

            User rmUser3 = Mockup_Test.newUser(
                'thrdRMName',
                'thrdRMName',
                '8000000002', 
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
                '8000000001', 
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
                '8000000002', 
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User tmFinal2 = [SELECT Id,Name FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId,Manager.Name FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User rmFinal2 = [SELECT ManagerId FROM User WHERE FirstName =:newRMName LIMIT 1];

            System.assertEquals(tmFinal2.Name, rmFinal.Manager.Name);
            System.assertEquals(tmFinal2.Id, rmFinal.ManagerId);
            System.assertEquals(tmFinal2.Id, rmFinal2.ManagerId);

            User tmFinal3 = [SELECT Id FROM User WHERE FirstName = 'thrdTMName' LIMIT 1];
            User rmFinal3 = [SELECT ManagerId FROM User WHERE FirstName = 'thrdRMName' LIMIT 1];

            System.assertEquals(tmFinal3.Id, rmFinal3.ManagerId);

        }
    }

   @isTest static void testUpdateToActive(){

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            SME_GroupChatterService.allOldUserMap = new Map<Id,User>([SELECT Id,Profile.Name,NH_RC_Code__c,RC_Code__c,Segment__c FROM User]);

            TriggerHandler.bypass('UserTriggerHandler');
            User tmUser = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            tmUser.IsActive = false;
            tmUser.Status__c = 'I';
            update tmUser;
            TriggerHandler.clearbypass('UserTriggerHandler');

            List<CollaborationGroupMember> deleteCollaborationGroupMemberList = new List<CollaborationGroupMember>();
            SME_GroupChatterService.addDeleteUserToList(tmUser,deleteCollaborationGroupMemberList);
            
            delete deleteCollaborationGroupMemberList;

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
            ahUserStruc.Segment__c = 'segment07';
            ahUserStruc.Team_Name__c = 'team07';

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME3A', 
                'A', 
                System.today() - 1
            );
            tmUserStruc.Segment__c = 'segment07';
            tmUserStruc.Team_Name__c = 'team07';

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
            rmUserStruc.Segment__c = 'segment01';
            rmUserStruc.Team_Name__c = 'team01';

            insert rmUserStruc;

            Test.startTest();
                //UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                //batch.totalActiveUser = 0;
                //batch.totalMaxLicense = 2000;
                //Database.executeBatch(batch);
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User tmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];
            User ahFinal = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameAH LIMIT 1];

            System.assertEquals(tmFinal.Id, rmFinal.ManagerId);
            System.assertEquals(ahFinal.Id, tmFinal.ManagerId);
        }
    }

    @isTest static void testChangeRoleTmToAh(){

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
                'A', 
                System.today() - 1
            );

            User_Structure__c tmToAhUserStruc = Mockup_Test.newUserStructure(
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
            tmToAhUserStruc.Segment__c = 'segment01';
            tmToAhUserStruc.Team_Name__c = 'team01';

            insert tmToAhUserStruc;

            User rmBefore    = [SELECT Id, ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User tmBefore = [SELECT Id, ManagerId, UserRoleId FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];

            rmBefore.managerId = tmBefore.Id;
            update rmBefore;
            System.assertEquals(tmBefore.Id, rmBefore.ManagerId);           

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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

        Team_Structure__c secondTsNh = new Team_Structure__c(
            External_ID__c = Mockup_Test.userEmpIdNH,
            RC_Code__c = Mockup_Test.userEmpIdNH,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = Mockup_Test.nhTeamName + '1',
            Segment__c = Mockup_Test.teamSegment1,
            Type__c = 'Network'
        );
        insert secondTsNh;

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
                //UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                //batch.totalActiveUser = 0;
                //batch.totalMaxLicense = 2000;
                //Database.executeBatch(batch);
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            User ahFinal = [SELECT Acting_Flag__c FROM User WHERE Employee_ID__c =:Mockup_Test.userEmpIdAH LIMIT 1];

            System.assertEquals(false, ahFinal.Acting_Flag__c);
        }
    }

    @istest static void testUpdateRoleLabelandRoleNameNotUpdate(){
         /*
         * Created by: nareerat.wo@kbtg.tech
         * Created date: 10-May-2016
         * Description: Test code for Test case BU Updated Role Label and not updated Role Name at class UserStructureUpdateUser_Batch.
        */

         System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
             
                UserRole userRoleNh = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
                UserRole userRoleAh = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.AH_RC_CODE)];
                
                user userRm= [SELECT Id, Employee_ID__c, Network_Name__c, Area_Name__c FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM];             
                userRm.Network_Name__c=userRoleNh.Name;
                userRm.Area_Name__c=userRoleAh.Name;             
                update userRm;
             
             User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE,
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                'ME4A', 
                'A',
                System.today()
            );
            insert rmUserStruc;                   
                           
            Test.startTest();               
                
                userRoleNh.Name = userRoleNh.Name + 'Test' ;
                update userRoleNh;
                userRoleAh.Name = userRoleAh.Name + 'Test' ;
                update userRoleAh;
                          
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
             
            Test.stopTest();

            User rmFinal = [SELECT Employee_ID__c, Area_Name__c, Network_Name__c  FROM User WHERE Employee_ID__c =:Mockup_Test.userEmpIdRM LIMIT 1];
             System.assertEquals(Mockup_Test.userEmpIdRM, rmFinal.Employee_ID__c);
             System.assertEquals( userRoleNh.Name  , rmFinal.Network_Name__c);
             System.assertEquals( userRoleAh.Name  , rmFinal.Area_Name__c);
        }
    }

    @isTest static void testChangeToNewTmByPrepare(){
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
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User newTmFinal = [SELECT Id,Name FROM User WHERE FirstName =:newTMName LIMIT 1];
            User rmFinal = [SELECT ManagerId FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            
            System.assertEquals(newTmFinal.Id, rmFinal.ManagerId);

            User newRmFinal = [SELECT ManagerId,Manager.Name FROM User WHERE FirstName =:newRMName LIMIT 1];
            System.assertEquals(newTmFinal.Name, newRmFinal.Manager.Name);
            System.assertEquals(newTmFinal.Id, newRmFinal.ManagerId);

        }
    }

    @isTest static void testAddUserThenAddUserToGroup(){
       
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
            ahUserStruc.Segment__c = Mockup_Test.teamSegment1;
            ahUserStruc.Team_Name__c = Mockup_Test.nhTeamName;

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
            rmUserStruc.Segment__c = Mockup_Test.teamSegment1;
            rmUserStruc.Team_Name__c = Mockup_Test.nhTeamName;

            insert rmUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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
            tmUserStruc.Segment__c = Mockup_Test.teamSegment1;
            tmUserStruc.Team_Name__c = Mockup_Test.nhTeamName;

            insert tmUserStruc;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                newNHEmpId, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.NH_RC_CODE, 
                newNHName, 
                newNHName, 
                'ME1A', 
                'A', 
                System.today() - 1
            );
            nhUserStruc.Segment__c = Mockup_Test.teamSegment1;
            nhUserStruc.Team_Name__c = Mockup_Test.nhTeamName;

            insert nhUserStruc;

            // System.assertEquals(2, [SELECT Id FROM CollaborationGroup].size());
            // System.assertEquals(5, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'].MemberCount);
            // System.assertEquals(5, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1].MemberCount);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 3;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            // System.assertEquals(2, [SELECT Id FROM CollaborationGroup].size());
            // System.assertEquals(9, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'].MemberCount);
            // System.assertEquals(9, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1].MemberCount);
            
        }
    }

    @isTest static void testInactiveUserThenRemoveUserFromGroup(){
       
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            User_Structure__c rmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdRM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                newRMName, 
                newRMName, 
                'ME4A', 
                'I', 
                System.today()
            );
            rmUserStruc.Segment__c = Mockup_Test.teamSegment1;
            rmUserStruc.Team_Name__c = Mockup_Test.nhTeamName;

            insert rmUserStruc;

            // System.assertEquals(2, [SELECT Id FROM CollaborationGroup].size());
            // System.assertEquals(5, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'].MemberCount);
            // System.assertEquals(5, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1].MemberCount);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 3;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            // System.assertEquals(2, [SELECT Id FROM CollaborationGroup].size());
            // System.assertEquals(4, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'].MemberCount);
            // System.assertEquals(4, [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.teamSegment1].MemberCount);
            
        }
    }

    @isTest static void testInactiveOldTmAndAddNewTmRmThenDeleteOldTmFromGroupChatterAndAddNewTmRmToGroupChatter(){
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userTM = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Team_Structure__c secondTsNh = new Team_Structure__c(
                External_ID__c = Mockup_Test.userEmpIdNH,
                RC_Code__c = Mockup_Test.userEmpIdNH,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = Mockup_Test.nhTeamName + '1',
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );
            insert secondTsNh;

            User secondTMUser = Mockup_Test.newUser(
                newTMName,
                newTMName,
                newTMEmpId, 
                true, 
                tmProfile.Id,
                userTM.UserRoleId,
                userAH.Id
            );
            secondTMUser.Segment__c = Mockup_Test.teamSegment1;
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
            nhUserStruc.Segment__c = Mockup_Test.teamSegment1;
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
            ahUserStruc.Segment__c = Mockup_Test.teamSegment1;
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
            secondTMUserStruc.Segment__c = Mockup_Test.teamSegment1;
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
            tmUserStruc.Segment__c = Mockup_Test.teamSegment1;
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
            newRmUserStruc.Segment__c = Mockup_Test.teamSegment1;
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
            rmUserStruc.Segment__c = Mockup_Test.teamSegment1;
            insert rmUserStruc;

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            List<CollaborationGroup> listCollaborationGroup = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];
            CollaborationGroup secondNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam1'];
            List<CollaborationGroupMember> listNewTmOldTm = [SELECT Id,Member.Name FROM CollaborationGroupMember WHERE CollaborationGroup.Name = 'SE nhTeam' AND Member.Name IN ('NewTM NewTM','FirstNameTM LastNameTM')];
            // CollaborationGroupMember newTmInGroup = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationGroup.Name = 'SE nhTeam' AND Member.Name = 'NewTM NewTM'];
			// List<CollaborationGroupMember> listFirstNhGroupMember = [SELECT Id,Member.Name FROM CollaborationGroupMember WHERE CollaborationGroup.Name = 'SE nhTeam'];

            // System.assertEquals(3,listCollaborationGroup.size());
            // System.assertEquals(6,listFirstNhGroupMember.size());
            // System.assertEquals(1,secondNhGroup.MemberCount);
            // System.assertEquals(1,listNewTmOldTm.size());
            // System.assertNotEquals(null,newTmInGroup.Id);

        }
    }

    @isTest static void testUpdateNhAhTmRmToNewNhRcCodeThenRemoveThemFromOldGroupChatterAndAddThemToNewGroupChatter(){
        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        User userNH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        User userAH = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userTM = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userRM = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
        UserRole newNhRole = Mockup_Test.newRole(newNHRCCode, 'RC' + newNHRCCode, adminRole.Id);
        insert newNhRole;
        
        UserRole newAhRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, newNhRole.Id);
        insert newAhRole;
        
        UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAhRole.Id);
        insert newTmRole;

        UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
        insert newRmRole;
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Team_Structure__c secondTsNh = new Team_Structure__c(
                External_ID__c = newNHRCCode,
                RC_Code__c = newNHRCCode,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = Mockup_Test.nhTeamName + '1',
                Segment__c = Mockup_Test.teamSegment1,
                Type__c = 'Network'
            );
            insert secondTsNh;

            User_Structure__c nhUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdNH, 
                newNHRCCode, 
                null, 
                newNHRCCode, 
                Mockup_Test.userFirstNameNH,
                Mockup_Test.userLastNameNH,
                'ME1A', 
                'A', 
                System.today() - 1
            );

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                newNHRCCode, 
                newAHRCCode, 
                newAHRCCode, 
                Mockup_Test.userFirstNameAH,
                Mockup_Test.userLastNameAH,
                'ME2A', 
                'A', 
                System.today() - 1
            );

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
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

            insert tmUserStruc;

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
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            List<CollaborationGroup> listCollaborationGroup = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];
            CollaborationGroup secondNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam1'];

            // System.assertEquals(3,listCollaborationGroup.size());
            // System.assertEquals(1,firstNhGroup.MemberCount);
            // System.assertEquals(5,secondNhGroup.MemberCount);

        }
    }


    @isTest static void testUserInactiveButHRISDataIsActiveAndEffectiveDateLessOrEqualSysdateThenAddUserToGroupChatter(){
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

            List<CollaborationGroup> listCollaborationGroupBeforeRunBatch = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroupBeforeRunBatch = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];

            // System.assertEquals(2,listCollaborationGroupBeforeRunBatch.size());
            // System.assertEquals(5,firstNhGroupBeforeRunBatch.MemberCount);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            List<CollaborationGroup> listCollaborationGroup = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];

            // System.assertEquals(3,listCollaborationGroup.size());
            // System.assertEquals(6,firstNhGroup.MemberCount);
        }
    }

    @isTest static void testUserInactiveButHRISDataIsActiveAndEffectiveMoreThanSysdateThenDoNotThing(){
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

            List<CollaborationGroup> listCollaborationGroupBeforeRunBatch = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroupBeforeRunBatch = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];

            // System.assertEquals(2,listCollaborationGroupBeforeRunBatch.size());
            // System.assertEquals(5,firstNhGroupBeforeRunBatch.MemberCount);

            Test.startTest();
                UserStructureUpdateUser_Batch batch = new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH);
                batch.totalActiveUser = 0;
                batch.totalMaxLicense = 2000;
                Database.executeBatch(batch);
            Test.stopTest();

            List<CollaborationGroup> listCollaborationGroup = [SELECT Id FROM CollaborationGroup];
            CollaborationGroup firstNhGroup = [SELECT Id,MemberCount FROM CollaborationGroup WHERE Name = 'SE nhTeam'];
            // System.debug('listCollaborationGroup = '+listCollaborationGroup);
            // System.assertEquals(2,listCollaborationGroup.size());
            // System.assertEquals(5,firstNhGroup.MemberCount);
        }
    }

    @isTest static void testDemoteTmToRmAndNoNewTmThenSetTmEmpIdAndNameEqualNull(){
        
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

            insert ahUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME4A', 
                'A', 
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
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User ahUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH];
            User nhUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH];

            User rmFinal = [SELECT ManagerId,Manager.Name,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User newRmFinal = [SELECT ManagerId,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:newRMName LIMIT 1];
            User tmToRm = [SELECT ManagerId,Manager.Name,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];

            System.assertEquals(null, rmFinal.TM_Name__c);
            System.assertEquals(null, rmFinal.TM_Employee_ID__c);
            System.assertEquals(ahUser.Name, rmFinal.Manager.Name);
            System.assertEquals(ahUser.Id, rmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, rmFinal.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, rmFinal.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, rmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, rmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, rmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, rmFinal.NH_Name__c);

            System.assertEquals(null, newRmFinal.TM_Name__c);
            System.assertEquals(null, newRmFinal.TM_Employee_ID__c);
            System.assertEquals(ahUser.Id, newRmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, newRmFinal.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, newRmFinal.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, newRmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, newRmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, newRmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, newRmFinal.NH_Name__c);

            System.assertEquals(null, tmToRm.TM_Name__c);
            System.assertEquals(null, tmToRm.TM_Employee_ID__c);
            System.assertEquals(ahUser.Name, tmToRm.Manager.Name);
            System.assertEquals(ahUser.Id, tmToRm.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, tmToRm.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, tmToRm.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, tmToRm.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, tmToRm.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, tmToRm.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, tmToRm.NH_Name__c);
        }
    }

    @isTest static void testDemoteTmToRmAndHasNewTmThenSetTmEmpIdAndNameToRm(){
        
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

            insert ahUserStruc;

            User_Structure__c newTmUserStruc = Mockup_Test.newUserStructure(
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

            insert newTmUserStruc;

            User_Structure__c tmUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdTM, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                'ME4A', 
                'A', 
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
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User newTmUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:newTMName];
            User ahUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH];
            User nhUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH];

            User rmFinal = [SELECT ManagerId,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User newRmFinal = [SELECT ManagerId,Manager.Name,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:newRMName LIMIT 1];
            User tmToRm = [SELECT ManagerId,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];

            System.assertEquals(newTmUser.Name, rmFinal.TM_Name__c);
            System.assertEquals(newTmUser.Employee_ID__c, rmFinal.TM_Employee_ID__c);
            System.assertEquals(newTmUser.Id, rmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, rmFinal.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, rmFinal.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, rmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, rmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, rmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, rmFinal.NH_Name__c);

            System.assertEquals(newTmUser.Name, newRmFinal.TM_Name__c);
            System.assertEquals(newTmUser.Employee_ID__c, newRmFinal.TM_Employee_ID__c);
            System.assertEquals(newTmUser.Name,newRmFinal.Manager.Name);
            System.assertEquals(newTmUser.Id, newRmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, newRmFinal.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, newRmFinal.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, newRmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, newRmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, newRmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, newRmFinal.NH_Name__c);

            System.assertEquals(newTmUser.Name, tmToRm.TM_Name__c);
            System.assertEquals(newTmUser.Employee_ID__c, tmToRm.TM_Employee_ID__c);
            System.assertEquals(newTmUser.Id, tmToRm.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, tmToRm.AH_RC_Code__c);
            System.assertEquals(ahUser.Employee_ID__c, tmToRm.AH_Employee_ID__c);
            System.assertEquals(ahUser.Name, tmToRm.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, tmToRm.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, tmToRm.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, tmToRm.NH_Name__c);
        }
    }

    @isTest static void testInactiveAhAndNoNewAhThenSetAhEmpIdAndNameAllTmRmToNull(){
        
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
            nhUserStruc.Segment__c = 'segment01';
            nhUserStruc.Team_Name__c = 'team01';

            insert nhUserStruc;

            User_Structure__c ahUserStruc = Mockup_Test.newUserStructure(
                Mockup_Test.userEmpIdAH, 
                Mockup_Test.NH_RC_CODE, 
                Mockup_Test.AH_RC_CODE, 
                Mockup_Test.RC_CODE, 
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
                'A', 
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
                SME_PrepareOwnershipAssignment_Batch batch = new SME_PrepareOwnershipAssignment_Batch();
                Database.executeBatch(batch);
            Test.stopTest();

            User ahUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH];
            User nhUser = [SELECT Id,Employee_ID__c,Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH];
            User tmUser = [SELECT Id,Employee_ID__c,Name,ManagerId,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameTM LIMIT 1];

            User rmFinal = [SELECT ManagerId,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            User newRmFinal = [SELECT ManagerId,Manager.Name,TM_Employee_ID__c,TM_Name__c,AH_RC_Code__c,AH_Employee_ID__c,AH_Name__c,NH_RC_Code__c,NH_Employee_ID__c,NH_Name__c FROM User WHERE FirstName =:newRMName LIMIT 1];            

            System.assertEquals(tmUser.Name, rmFinal.TM_Name__c);
            System.assertEquals(tmUser.Employee_ID__c, rmFinal.TM_Employee_ID__c);
            System.assertEquals(tmUser.Id, rmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, rmFinal.AH_RC_Code__c);
            System.assertEquals(null, rmFinal.AH_Employee_ID__c);
            System.assertEquals(null, rmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, rmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, rmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, rmFinal.NH_Name__c);

            System.assertEquals(tmUser.Name, newRmFinal.TM_Name__c);
            System.assertEquals(tmUser.Employee_ID__c, newRmFinal.TM_Employee_ID__c);
            System.assertEquals(tmUser.Name,newRmFinal.Manager.Name);
            System.assertEquals(tmUser.Id, newRmFinal.ManagerId);

            System.assertEquals(Mockup_Test.AH_RC_CODE, newRmFinal.AH_RC_Code__c);
            System.assertEquals(null, newRmFinal.AH_Employee_ID__c);
            System.assertEquals(null, newRmFinal.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, newRmFinal.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, newRmFinal.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, newRmFinal.NH_Name__c);

            System.assertEquals(Mockup_Test.AH_RC_CODE, tmUser.AH_RC_Code__c);
            System.assertEquals(null, tmUser.AH_Employee_ID__c);
            System.assertEquals(null, tmUser.AH_Name__c);

            System.assertEquals(Mockup_Test.NH_RC_CODE, tmUser.NH_RC_Code__c);
            System.assertEquals(nhUser.Employee_ID__c, tmUser.NH_Employee_ID__c);
            System.assertEquals(nhUser.Name, tmUser.NH_Name__c);
        }
    }
}