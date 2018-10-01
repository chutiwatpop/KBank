@isTest
private class Opportunity_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameCBRM = 'cbRmCreatedAccountName';
    private static String userFirstNameFranchiseRM = 'FirstNameFranRM';
    private static String userFirstNameAfRm = 'userFirstNameAfRm';
    private static String userEmpAfRm = '90909';

    @testSetup static void setupUser(){
        Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTestWithRCCode();
            createUserFranchise();
            Mockup_Test.setupANTeam();
            
            setUpProduct();
        }

        System.runAs(new User(Id=UserInfo.getUserId())){
            UserRole rmRole = [SELECT Id FROM UserRole WHERE Name=:Mockup_Test.RC_CODE LIMIT 1];
            insert Mockup_Test.newUser(
                userFirstNameAfRm,
                userFirstNameAfRm,
                true,
                userFirstNameAfRm+'@mail.com',
                userFirstNameAfRm+'@mail.com',
                GlobalConstants.AF_RM,
                Mockup_Test.mapProfileByName.get(GlobalConstants.AF_RM).Id,
                rmRole.Id,
                null,
                userEmpAfRm
            );
        }
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Opportunity_Test.setUpUW();
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            mt.newAccount(accountNameCBRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        setUpRbsUser(mt);
        Test.stopTest();
    }

    public static void setUpUW() {
        insert new Segment_UW_Assignment__c(Name = 'ME');

        Id uwProfileId = [SELECT Id FROM Profile WHERE Name = :'SME-Head of UW' LIMIT 1].Id;
        Id uwSeniorProfileId = [SELECT Id FROM Profile WHERE Name = 'SME-Senior UW' LIMIT 1].Id;
        Id uwRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_UW' LIMIT 1].Id;

        Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;
        Business_Code__c buCode = new Business_Code__c(Name = '111111',Segment__c = 'ME',External_ID__c='111111:ME');
        insert buCode;
        Business_Code__c buCode7 = new Business_Code__c(Name = '777777',Segment__c = 'ME',External_ID__c='777777:ME');
        insert buCode7;

        List<User> uwUserList = new List<User>();
        User uwAHHeadUser = Mockup_Test.newUser(
                'uwAHHeadUser',
                'uwAHHeadUser',
                true,
                'uwAHHeadUser@mail.com',
                'uwAHHeadUser@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '7001770000'
            );
        uwUserList.add(uwAHHeadUser);

        User uwAHSeniorUser = Mockup_Test.newUser(
                'uwAHSeniorUser',
                'uwAHSeniorUser',
                true,
                'uwAHSeniorUser@mail.com',
                'uwAHSeniorUser@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '9901770000'
            );
        uwUserList.add(uwAHSeniorUser);

        User uwNHHeadUser = Mockup_Test.newUser(
                'uwNHHeadUser',
                'uwNHHeadUser',
                true,
                'uwNHHeadUser@mail.com',
                'uwNHHeadUser@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '6600660000'
            );
        uwUserList.add(uwNHHeadUser);

        User uwNHSeniorUser = Mockup_Test.newUser(
                'uwNHSeniorUser',
                'uwNHSeniorUser',
                true,
                'uwNHSeniorUser@mail.com',
                'uwNHSeniorUser@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '9898980000'
            );
        uwUserList.add(uwNHSeniorUser);

        User userHeadBUAH = Mockup_Test.newUser(
                'userHeadBUAH',
                'userHeadBUAH',
                true,
                'userHeadBUAH@mail.com',
                'userHeadBUAH@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '1234600000'
            );
        uwUserList.add(userHeadBUAH);

        User userSeniorBUAH = Mockup_Test.newUser(
                'userSeniorBUAH',
                'userSeniorBUAH',
                true,
                'userSeniorBUAH@mail.com',
                'userSeniorBUAH@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '5242500000'
            );
        uwUserList.add(userSeniorBUAH);

        User userHeadBUNH = Mockup_Test.newUser(
                'userHeadBUNH',
                'userHeadBUNH',
                true,
                'userHeadBUNH@mail.com',
                'userHeadBUNH@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '3123460000'
            );
        uwUserList.add(userHeadBUNH);

        User userSeniorBUNH = Mockup_Test.newUser(
                'userSeniorBUNH',
                'userSeniorBUNH',
                true,
                'userSeniorBUNH@mail.com',
                'userSeniorBUNH@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '3524250000'
            );
        uwUserList.add(userSeniorBUNH);

        User userHeadBUAH2 = Mockup_Test.newUser(
                'userHeadBUAH2',
                'userHeadBUAH2',
                true,
                'userHeadBUAH2@mail.com',
                'userHeadBUAH2@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '1283460000'
            );
        uwUserList.add(userHeadBUAH2);

        User userSeniorBUAH2 = Mockup_Test.newUser(
                'userSeniorBUAH2',
                'userSeniorBUAH2',
                true,
                'userSeniorBUAH2@mail.com',
                'userSeniorBUAH2@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '5824250000'
            );
        uwUserList.add(userSeniorBUAH2);

        User userHeadBUNH2 = Mockup_Test.newUser(
                'uwBUHeadUser',
                'uwBUHeadUser',
                true,
                'userHeadBUNH2@mail.com',
                'userHeadBUNH2@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '8823460000'
            );
        uwUserList.add(userHeadBUNH2);

        User userSeniorBUNH2 = Mockup_Test.newUser(
                'userSeniorBUNH2',
                'userSeniorBUNH2',
                true,
                'userSeniorBUNH2@mail.com',
                'userSeniorBUNH2@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '8824250000'
            );
        uwUserList.add(userSeniorBUNH2);

        User userHeadNoRC = Mockup_Test.newUser(
                'userHeadNoRC',
                'userHeadNoRC',
                true,
                'userHeadNoRC@mail.com',
                'userHeadNoRC@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '8877770000'
            );
        uwUserList.add(userHeadNoRC);

        User userSeniorNoRC = Mockup_Test.newUser(
                'userSeniorNoRC',
                'userSeniorNoRC',
                true,
                'userSeniorNoRC@mail.com',
                'userSeniorNoRC@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '7722220000'
            );
        uwUserList.add(userSeniorNoRC);

        insert uwUserList;

        List<UW_Area__c> uwAreaList = new List<UW_Area__c>();
        UW_Area__c uwAHArea = new UW_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            Head_of_UW_Name__c = uwAHHeadUser.Id,
            Senior_UW_Name__c = uwAHSeniorUser.Id
        );
        uwAreaList.add(uwAHArea);

        UW_Area__c uwNHArea = new UW_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            Head_of_UW_Name__c = uwNHHeadUser.Id,
            Senior_UW_Name__c = uwNHSeniorUser.Id
        );
        uwAreaList.add(uwNHArea);
        insert uwAreaList;

        List<UW_Business_Area__c> uwBuList = new List<UW_Business_Area__c>();
        UW_Business_Area__c uwBUAH = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            External_ID__c = Mockup_Test.AH_RC_CODE+'-'+buCodeTest.Name,
            Business_Code__c = buCodeTest.Id,
            Head_of_UW_Name__c = userHeadBUAH.Id,
            Senior_UW_Name__c = userSeniorBUAH.Id
        );
        uwBuList.add(uwBUAH);

        UW_Business_Area__c uwBUNH = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            External_ID__c = Mockup_Test.NH_RC_CODE+'-'+buCodeTest.Name,
            Business_Code__c = buCodeTest.Id,
            Head_of_UW_Name__c = userHeadBUNH.Id,
            Senior_UW_Name__c = userSeniorBUNH.Id
        );
        uwBuList.add(uwBUNH);

        UW_Business_Area__c uwBUAH2 = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            External_ID__c = Mockup_Test.AH_RC_CODE+'-'+buCode.Name,
            Business_Code__c = buCode.Id,
            Head_of_UW_Name__c = userHeadBUAH2.Id,
            Senior_UW_Name__c = userSeniorBUAH2.Id
        );
        uwBuList.add(uwBUAH2);

        UW_Business_Area__c uwBUNH2 = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            External_ID__c = Mockup_Test.NH_RC_CODE+'-'+buCode.Name,
            Business_Code__c = buCode.Id,
            Head_of_UW_Name__c = userHeadBUNH2.Id,
            Senior_UW_Name__c = userSeniorBUNH2.Id
        );
        uwBuList.add(uwBUNH2);


        UW_Business_Area__c uwBUNoRC = new UW_Business_Area__c(
            External_ID__c =  System.Label.Apply_All_Area+'-'+buCode7.Name,
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            Business_Code__c = buCode7.Id,
            Head_of_UW_Name__c = userHeadNoRC.Id,
            Senior_UW_Name__c = userSeniorNoRC.Id
        );
        uwBuList.add(uwBUNoRC);
        insert uwBuList;
    }
    
    static testMethod void testInsertNoBU(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

        //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Opportunity_Test.accountNameRM, 'Id, RC_Code__c');
        System.runAs(userRM){
            Test.startTest();
            try{
               Opportunity opp1 = Mockup_Test.newOpportunityWithAppHis(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
            }catch(Exception e){
                System.assertEquals( true,e.getMessage().contains(ExceptionMessage.REQUIRE_BUSINESS_CODE));
            }
            Test.stopTest();
        }
    }

    static testMethod void testInsertWithBU(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

        System.runAs(userRM){
            //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
            Account targetAccount = Mockup_Test.getFirstAccountFromName(Opportunity_Test.accountNameRM, 'Id, RC_Code__c');
            targetAccount.Customer_s_Business_Code__c = '111111';
            update targetAccount;

            Test.startTest();
            Opportunity opp1 = Mockup_Test.newOpportunityWithAppHis(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);   
            Test.stopTest();
        }
        Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
        UW_Business_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode.Id AND RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

        Opportunity finalOpp = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Name = 'TestUW1'];
        System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalOpp.Head_of_UW_Name__c);
        System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalOpp.Senior_UW_Name__c);
    }

    @isTest static void testLatestStageModifiedDateWhenChangeStage(){
        TriggerHandler.bypass('AccountTriggerHandler');
        //Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        Account customer = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, Name, Trash_Pool_Flag__c');
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');
        
        Opportunity opportunity = Mockup_Test.newOpportunityWithAppHis(customer.Id, 'TestOPP1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
        //insert opportunity;

        opportunity = [SELECT Id, Previous_Stage__c, Latest_Stage_Modified_Date__c FROM Opportunity WHERE Name = 'TestOPP1'];
        //System.assertEquals(null,opportunity.Latest_Stage_Modified_Date__c);

        opportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
        Test.startTest();
        Date dateTest = System.today();
        update opportunity;
        Test.stopTest();


        opportunity = [SELECT Id, Previous_Stage__c, Latest_Stage_Modified_Date__c FROM Opportunity WHERE Name = 'TestOPP1'];
        //System.assertEquals(dateTest.day(),opportunity.Latest_Stage_Modified_Date__c.day());
        //System.assertEquals(dateTest.month(),opportunity.Latest_Stage_Modified_Date__c.month());
        //System.assertEquals(dateTest.year(),opportunity.Latest_Stage_Modified_Date__c.year());

    }

    private static User createUserFranchise(){

        UserRole smeuw = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_UW'];
        UserRole franchiseRole = Mockup_Test.newRole('แฟรนไชส์', 'RC22223', smeuw.Id);
        insert franchiseRole;
        
        User rmUserFranchise = Mockup_Test.newUser(
                    userFirstNameFranchiseRM,
                    'LastNameFranRM',
                    true,
                    userFirstNameFranchiseRM+'@mail.com',
                    userFirstNameFranchiseRM+'@mail.com',
                    userFirstNameFranchiseRM.substring(0, 4),
                    Mockup_Test.getMapProfileByName(GlobalConstants.SME_RM).Id,
                    franchiseRole.Id,
                    null,
                    'FRAN03'
             );
            rmUserFranchise.Current_Opportunity_Approval__c = null;
            rmUserFranchise.Job_Code__c = 'SP4E';
            rmUserFranchise.AH_RC_Code__c = null;
            rmUserFranchise.NH_RC_Code__c = '41201';
            rmUserFranchise.RC_Code__c = '22223';
            rmUserFranchise.Status__c = 'A';
            rmUserFranchise.Segment__c = 'MI';
            rmUserFranchise.Employee_ID__c = '400000010';

            insert rmUserFranchise;

        return rmUserFranchise;    
    }
    
    @isTest static void testFranchiseCreateOpportunity(){
        User rmFranchise = [SELECT Id, Name FROM User WHERE FirstName =: userFirstNameFranchiseRM];
        //Account customer = [SELECT Id, Name, OwnerId FROM Account WHERE Name =: accountNameRM];
        Account customer = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, Name, OwnerId');

        User customerOwner = [SELECT Id, Profile.Name FROM User WHERE Id =: customer.OwnerId];
        AccountShare accountShare = new AccountShare(
            AccountAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit',
            UserOrGroupId = rmFranchise.Id,
            AccountId = customer.Id
            );
        insert accountShare;
        
        System.runAs(rmFranchise){
            Opportunity opportunityTest = Mockup_Test.newOpportunityWithAppHis(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
        }

        customer = [SELECT Id, Name, OwnerId FROM Account WHERE Id =: customer.Id];
        System.assertEquals(customerOwner.Id,customer.OwnerId);
    }

    @isTest static void testFranchiseUpdateOpportunity(){
        User rmFranchise = [SELECT Id, Name FROM User WHERE FirstName =: userFirstNameFranchiseRM];
        //Account customer = [SELECT Id, Name, OwnerId FROM Account WHERE Name =: accountNameRM];
        Account customer = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, Name, OwnerId');

        User customerOwner = [SELECT Id, Profile.Name FROM User WHERE Id =: customer.OwnerId];
        AccountShare accountShare = new AccountShare(
            AccountAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit',
            UserOrGroupId = rmFranchise.Id,
            AccountId = customer.Id
            );
        insert accountShare;
        Opportunity opportunityTest;
        System.runAs(rmFranchise){
            opportunityTest = Mockup_Test.newOpportunityWithAppHis(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
            opportunityTest.Name = 'ChangeTestOPP1';
            update opportunityTest;
        }

        customer = [SELECT Id, Name, OwnerId FROM Account WHERE Id =: customer.Id];
        Opportunity opp = [SELECT Name FROM Opportunity WHERE Id =: opportunityTest.Id LIMIT 1];
        
        System.assertEquals(customerOwner.Id,customer.OwnerId);
        System.assertEquals('ChangeTestOPP1',opp.Name);
    }

    @isTest static void testInsertOppWithBusinessCodeThenCreateCustomerBusinessCode(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.Segment__c = 'ME';
        update userRM;

        //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Opportunity_Test.accountNameRM, 'Id,CIS__c, Name,RC_Code__c, Trash_Pool_Flag__c,OwnerId, Owner.Name');
        Business_Code__c buCode = [SELECT id,Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
        System.runAs(userRM){
            Map<String, Object> mapFieldValue = new Map<String, Object>();
            mapFieldValue.put('Business_Code__c', buCode.Id);
            Test.startTest();
            Opportunity opp1 = Mockup_Test.newOpportunityWithAppHis(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS, mapFieldValue);
            //insert opp1;    
            Test.stopTest();
        }
        //Integer customerBusinessCodeCount = [SELECT count() From Customer_Business_Code__c WHERE CIS__c =:targetAccount.id AND Business_Code__c =:buCode.id];
        //System.assertEquals(1, customerBusinessCodeCount);
    }

    @isTest static void testUserUpdateBusinessCodeInOpp(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.Segment__c = 'ME';
        update userRM;

        Account targetAccount = Mockup_Test.getFirstAccountFromName(Opportunity_Test.accountNameRM, 'Id,CIS__c, Name,RC_Code__c, Trash_Pool_Flag__c,OwnerId, Owner.Name');
        Business_Code__c buCode = [SELECT id,Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
        Business_Code__c buCode2 = [SELECT id,Name FROM Business_Code__c WHERE Name = '777777' LIMIT 1];
        Opportunity opp1;
        System.runAs(userRM){

            opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
            opp1.Business_Code__c = buCode.id;
            insert opp1;
        }
        System.runAs(userRM){
            Test.startTest();
            opp1.Business_Code__c = buCode2.id;
            update opp1;
            Test.stopTest();
        }
        Integer customerBusinessCodeCount = [SELECT count() From Customer_Business_Code__c WHERE CIS__c =:targetAccount.id AND Business_Code__c =:buCode2.id];
    }

    @isTest static void testUWUpdateBusinessCodeTextInOpp(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.Segment__c = GlobalConstants.SEGMENT_ME;
        update userRM;

        User uwUser = [ SELECT Id From User WHERE FirstName = 'uwAHHeadUser' LIMIT 1];
        //Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Opportunity_Test.accountNameRM, 'Id,CIS__c, Name,RC_Code__c, Trash_Pool_Flag__c,OwnerId, Owner.Name');
        Business_Code__c buCode = [SELECT id,Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
        Opportunity opp1;
        System.runAs(userRM){
            opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
            opp1.Business_Code__c = buCode.id;
            opp1.CloseDate = System.today();
            insert opp1;    
        }

        System.runAs(new User(Id = UserInfo.getUserId())){
            OpportunityShare os = new OpportunityShare();
               os.OpportunityId = opp1.id; 
               os.OpportunityAccessLevel = 'edit';
               os.UserOrGroupId = uwUser.id;
            insert os;
        }

        System.runAs(uwUser){
            opp1.Business_Code_Text__c = '777777';
            Test.startTest();
            update opp1;
            Test.stopTest();
        }
        Business_Code__c buCode2 = [SELECT id,Name FROM Business_Code__c WHERE Name = '777777' LIMIT 1];
        opp1 = [SELECT id,Business_Code__c From Opportunity WHERE Id =:opp1.id LIMIT 1];
        //System.assertEquals(buCode2.id,opp1.Business_Code__c);
    }

    public static void setUpProduct() {
        List<Product2> productList = new List<Product2>();
        productList.add(new Product2(Name = 'Deposit'));
        productList.add(new Product2(Name = 'Credit Card'));
        insert productList;

        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for(Product2 eachProduct : productList) {
            pricebookEntryList.add(new PricebookEntry(
                Product2Id = eachProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1,
                IsActive = true
            ));
        }
        insert pricebookEntryList;
    }

    public static void setUpRbsUser(Mockup_Test mt) {
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = 'RBS-BAR'];
        User userRM = new User(
            FirstName = 'FirstNameRbsRM',
            LastName = 'LastNameRbsRM',
            IsActive = true,
            Username = 'FirstNameRbsRM@mail.com',
            Email = 'FirstNameRbsRM@mail.com',
            Alias = 'FRBS',
            TimeZoneSidKey = 'Asia/Bangkok',
            LocaleSidKey = 'th_TH',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = rmProfile.Id,
            Employee_ID__c = '8000000001'
        );
        insert userRM;
        insert new User(
            FirstName = 'FirstNameRbsRM2',
            LastName = 'LastNameRbsRM2',
            IsActive = true,
            Username = 'FirstNameRbsRM2@mail.com',
            Email = 'FirstNameRbsRM2@mail.com',
            Alias = 'FRBS2',
            TimeZoneSidKey = 'Asia/Bangkok',
            LocaleSidKey = 'th_TH',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = rmProfile.Id,
            Employee_ID__c = '8000000002'
        );

        System.runAs(userRM) {
            TriggerHandler.bypass('AccountTriggerHandler');
            mt.newAccount('rmRbsCreatedAccountName',GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            TriggerHandler.clearbypass('AccountTriggerHandler');
        }
    }

    static testMethod void testFinishJob() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        System.runAs(userRM) {
            Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestFinishSuccess', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;
            
            eventList.add(new Event(
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addDays(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CONTACTED,
                Collect_Documents__c = true
            ));
            eventList.add(new Event(
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1).addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CLOSED
            ));

            insert eventList;

            Test.startTest();
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(0).Id,
                Status__c = GlobalConstants.CLOSED_WON,
                Quantity = 1,
                TotalPrice = 1
            ));
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(1).Id,
                Status__c = GlobalConstants.CLOSE_LOST,
                Quantity = 1,
                TotalPrice = 1
            ));

            insert oppProductList;
          
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22519/0001/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today().addDays(-1),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Cancelled'
            ));
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22519/0002/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today(),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Closed Lost'
            ));
            insert appsList;
            Test.stopTest();

            targetOpp.StageName = GlobalConstants.FINISHED;
            update targetOpp;
        }
        Opportunity finalOpp = [SELECT Id, StageName, OwnerId, Port_Pool__c FROM Opportunity WHERE Name = 'TestFinishSuccess'];
        System.assertEquals(GlobalConstants.FINISHED, finalOpp.StageName);
    }

    static testMethod void testFinishJobWhenEventNotClose() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        String result = '';
       
        System.runAs(userRM) {
            Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestEventNotClose', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;

            eventList.add(new Event(
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addDays(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CONTACTED,
                Collect_Documents__c = true
            ));
            eventList.add(new Event(
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1).addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.PLAN
            ));
            insert eventList;

            Test.startTest();
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(0).Id,
                Status__c = GlobalConstants.CLOSED_WON,
                Quantity = 1,
                TotalPrice = 1
            ));
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(1).Id,
                Status__c = GlobalConstants.CLOSE_LOST,
                Quantity = 1,
                TotalPrice = 1
            ));
     
            insert oppProductList;

            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22520/0001/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today().addDays(-1),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Cancelled'
            ));
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22520/0002/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today(),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Closed Lost'
            ));
            insert appsList;
           
            try{
                targetOpp.StageName = GlobalConstants.FINISHED;
                update targetOpp;
            } catch(Exception e) {
                result = e.getMessage();
            }          
        }
        Test.stopTest();
        System.assertEquals(true, result.contains(ExceptionMessage.CANNOT_CLOSEJOB_CALLPLAN));
    }

    /*
    * SME and CBS
    */
    static testMethod void testFinishJobWhenSMEOppProductNotClose() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        String result = '';
       
        System.runAs(userRM) {
            Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestSMEOppProductNotClose', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;

            eventList.add(new Event(
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CONTACTED,
                Collect_Documents__c = true
            ));
            eventList.add(new Event(
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1).addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CLOSED
            ));
            insert eventList;
             Test.startTest();
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(0).Id,
                Status__c = GlobalConstants.CLOSED_WON,
                Quantity = 1,
                TotalPrice = 1
            ));
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(1).Id,
                Status__c = 'On Process',
                Quantity = 1,
                TotalPrice = 1
            ));
            insert oppProductList;
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22521/0001/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today().addDays(-1),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Cancelled'
            ));
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22521/0002/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today(),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Closed Lost'
            ));
            insert appsList;
            Test.stopTest();
            try{
                targetOpp.StageName = GlobalConstants.FINISHED;
                update targetOpp;
            } catch(Exception e) {
                result = e.getMessage();
            }
            
        }
        System.assertEquals(true, result.contains(ExceptionMessage.CANNOT_CLOSEJOB_OPPPRODUCT));
    }

    static testMethod void testFinishJobWhenRBSOppProductNotClose() {
        User userRM = [SELECT Id FROM User WHERE Firstname='FirstNameRbsRM' LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName('rmRbsCreatedAccountName', 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        String result = '';
        
        System.runAs(userRM) {
            Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestRBSOppProductNotClose', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;

            eventList.add(new Event(
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CONTACTED,
                Collect_Documents__c = true
            ));
            eventList.add(new Event(
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1).addHours(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CLOSED
            ));
            insert eventList;

            Test.startTest();
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(0).Id,
                Status__c = GlobalConstants.CLOSED_WON,
                Quantity = 1,
                TotalPrice = 1
            ));
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(1).Id,
                Status__c = GlobalConstants.ON_PROCESS,
                Quantity = 1,
                TotalPrice = 1
            ));
            insert oppProductList;

            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/2252120001/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today().addDays(-1),
                RMActualRequestedAmt__c = 100000
                // ,
                // App_Result__c = 'Cancelled'
            ));
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22522/0002/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today(),
                RMActualRequestedAmt__c = 100000
                // ,
                // App_Result__c = 'Closed Lost'
            ));
            insert appsList;
            Test.stopTest();
            try{
                targetOpp.StageName = GlobalConstants.FINISHED;
                update targetOpp;
            } catch(Exception e) {
                result = e.getMessage();
            }
            
        }
        System.assertEquals(true, result.contains(ExceptionMessage.CANNOT_CLOSEJOB_OPPPRODUCT));
    }

    static testMethod void testFinishJobWhenAppHistoryNotClose() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        String result = '';
        
        System.runAs(userRM) {
            Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestAppHistNotClose', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;

            eventList.add(new Event(
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addDays(1),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CONTACTED,
                Collect_Documents__c = true
            ));
            eventList.add(new Event(
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(2),
                Job__c = targetOpp.Id,
                WhatId = targetOpp.Id,
                Status__c = GlobalConstants.CLOSED
            ));
            insert eventList;

            Test.startTest();
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(0).Id,
                Status__c = GlobalConstants.CLOSED_WON,
                Quantity = 1,
                TotalPrice = 1
            ));
            oppProductList.add(new OpportunityLineItem(
                OpportunityId = targetOpp.Id,
                PricebookEntryId = pricebookEntryList.get(1).Id,
                Status__c = GlobalConstants.CLOSE_LOST,
                Quantity = 1,
                TotalPrice = 1
            ));
            insert oppProductList;

            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22523/0001/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'ส่งครั้งแรก',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today().addDays(-1),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = 'Cancelled'
            ));
            appsList.add(new Application_History__c(
                AppNum_NonCMAS__c = 'SE1/22523/0002/61S1',
                OppName__c = targetOpp.Id,
                RMCreditModel__c = 'HL',
                RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = Date.today(),
                RMActualRequestedAmt__c = 100000,
                App_Result__c = GlobalConstants.WORK_IN_PROGRESS
            ));
            insert appsList;
            Test.stopTest();
            try{
                targetOpp.StageName = GlobalConstants.FINISHED;
                update targetOpp;
            } catch(Exception e) {
                result = e.getMessage();
            }
            
        }
        System.assertEquals(true, result.contains(ExceptionMessage.CANNOT_CLOSEJOB_APPRESULT));
    }

    static testMethod void testFinishJobWhenNotOwner() {
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, RC_Code__c');
        List<PricebookEntry> pricebookEntryList = [SELECT Id, Name FROM PricebookEntry];
        List<Event> eventList = new List<Event>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<Application_History__c> appsList = new List<Application_History__c>();
        String result = '';
      
        Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOwner', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
        insert targetOpp;

        eventList.add(new Event(
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addDays(1),
            Job__c = targetOpp.Id,
            WhatId = targetOpp.Id,
            Status__c = GlobalConstants.CONTACTED,
            Collect_Documents__c = true
        ));
        eventList.add(new Event(
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(2),
            Job__c = targetOpp.Id,
            WhatId = targetOpp.Id,
            Status__c = GlobalConstants.CLOSED
        ));
        insert eventList;

        Test.startTest();
        oppProductList.add(new OpportunityLineItem(
            OpportunityId = targetOpp.Id,
            PricebookEntryId = pricebookEntryList.get(0).Id,
            Status__c = GlobalConstants.CLOSED_WON,
            Quantity = 1,
            TotalPrice = 1
        ));
        oppProductList.add(new OpportunityLineItem(
            OpportunityId = targetOpp.Id,
            PricebookEntryId = pricebookEntryList.get(1).Id,
            Status__c = GlobalConstants.CLOSE_LOST,
            Quantity = 1,
            TotalPrice = 1
        ));
        insert oppProductList;

        appsList.add(new Application_History__c(
            AppNum_NonCMAS__c = 'SE1/22524/0001/61S1',
            OppName__c = targetOpp.Id,
            RMCreditModel__c = 'HL',
            RMSubmitRound__c = 'ส่งครั้งแรก',
            RMSubmitChannel__c = 'Non CMAS',
            TentativeSubmitDate__c = Date.today().addDays(-1),
            RMActualRequestedAmt__c = 100000,
            App_Result__c = 'Cancelled'
        ));
        appsList.add(new Application_History__c(
            AppNum_NonCMAS__c = 'SE1/22524/0002/61S1',
            OppName__c = targetOpp.Id,
            RMCreditModel__c = 'HL',
            RMSubmitRound__c = 'Resubmit ครั้งที่ 1',
            RMSubmitChannel__c = 'Non CMAS',
            TentativeSubmitDate__c = Date.today(),
            RMActualRequestedAmt__c = 100000,
            App_Result__c = 'Closed Lost'
        ));
        insert appsList;
        Test.stopTest();               
     
        System.runAs(userTM) {
            try{
                targetOpp.StageName = GlobalConstants.FINISHED;
                update targetOpp;           
            } catch(Exception e) {
                result = e.getMessage();
            }
        }
         
        System.assertEquals(true, result.contains(ExceptionMessage.NO_AUTHORIZATION_UPDATEJOB));
    }

    //static testMethod void testIsCanCreateByCheckTemporaryCustomer() {
    //    Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, RC_Code__c');
    //    Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOwner', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
    //    OpportunityTriggerHandler oppTrigger = new OpportunityTriggerHandler();
    //    targetAccount.SME_Temporary_Customer__c = null;
    //    targetAccount.AF_Temporary_Customer__c = null;
    //    Boolean resultSME = oppTrigger.isCanCreateByCheckTemporaryCustomer('SME',targetAccount,targetOpp);
    //    System.assertEquals(true,resultSME);
    //    Boolean resultAF = oppTrigger.isCanCreateByCheckTemporaryCustomer('AF',targetAccount,targetOpp);
    //    System.assertEquals(true,resultAF);

    //    User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    //    System.runAs(userRM) {
    //        User_Extension__c userExtRM = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =:userRM.Id LIMIT 1];
    //        System.debug(userExtRM);
    //        targetAccount.SME_Temporary_Customer__c = userExtRM.Id;
    //        targetAccount.SME_Temporary_Customer__r.User__c = userRM.Id;
    //        Boolean resultSMEUserExtension = oppTrigger.isCanCreateByCheckTemporaryCustomer('SME',targetAccount,targetOpp);
    //    }
    //}

    static testMethod void Given_OpportunityOwnedByAfTemporary_When_FinishedLastAfOwnJobInAccount_Then_ClearFieldAfTemporaryCustomerInAccount() {
        User userAfRm = [SELECT Id FROM User WHERE Employee_ID__c=:userEmpAfRm LIMIT 1];
        User_Extension__c userExAfRm = [SELECT Id FROM User_Extension__c WHERE User__c = :userAfRm.Id];

        Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c,owner.profile.name');
        targetAccount.Primary_Segment_Code__c = 'LM';
        targetAccount.Customer_Segment_Code__c = 'LM';
        update targetAccount;

        System.debug('targetAccount.owner.profile.name = '+targetAccount.owner.profile.name);
        Opportunity targetOpp;
        System.runAs(userAfRm) {

            Account test = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, RC_Code__c,owner.profile.name');
            System.debug('test ='+test);

            targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOwner', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
            insert targetOpp;
        }

        Account resultTargetAccountStep1 = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, AF_Temporary_Customer__c');
        System.assertEquals(userExAfRm.Id,resultTargetAccountStep1.AF_Temporary_Customer__c);

        System.runAs(userAfRm) {
            targetOpp.StageName = GlobalConstants.FINISHED;
            update targetOpp;
        }
        
        Account resultTargetAccountStep2 = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, AF_Temporary_Customer__c');
        System.assertEquals(null,resultTargetAccountStep2.AF_Temporary_Customer__c);
    }   
}