@isTest
private class UserExtension_Test {
    
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRMPer = 'tmCreatedAccountPer';
    public static String accountNameRMTemp = 'rmCreatedAccountTemp';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String newRMEmpId = '1000010001';
    public static String newTMEmpId = '1000010002';
    public static String newAHEmpId = '1000010003';
    public static String newNHEmpId = '1000010004';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    @testSetup static void setupUser(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            mt.newAccount(accountNameRMTemp,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            
            User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            User_Extension__c targetRMExt = [SELECT Id FROM User_Extension__c WHERE User__c = :userRm.Id LIMIT 1];
            //Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :UserExtension_Test.accountNameRMPer LIMIT 1];
            Account targetAccount = Mockup_Test.getFirstAccountFromName(UserExtension_Test.accountNameRMPer, 'Id, OwnerId, Owner.Employee_Id__c,Ownership_Text__c, Port_Pool__c');
            RecordType recordType = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName = 'New_Call_Plan'];

            Call_Report__c callReport1 = new Call_Report__c();
            callReport1.Plan_Date__c = System.today() + 1;
            callReport1.CIS_ID__c = targetAccount.Id;
            callReport1.Status__c = GlobalConstants.PLAN;
            callReport1.Visit_Objective__c = 'Relationship';
            callReport1.RecordTypeId = recordType.Id;
            insert callReport1;
        }
        Test.stopTest();
    }

    @isTest static void testUpdateTeam() {
        User targetRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User targetTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User targetAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User targetNH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

        Account targetAccount = Mockup_Test.getFirstAccountFromName(UserExtension_Test.accountNameRMPer, 'Id, Current_Team_Name__c, Current_Team_Name__r.RC_Code__c, OwnerId');
        System.runAs(targetRM){
            Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
            insert opp1;
        }
        Team_Structure__c teamStrucNH = new Team_Structure__c(
            OwnerId = targetNH.Id,
            External_ID__c = newNHRCCode,
            RC_Code__c = newNHRCCode,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            NH_Name__c = null,
            AH_Name__c = null,
            Name = 'NetworkName'
        );
        insert teamStrucNH;

        Team_Structure__c teamStrucAH = new Team_Structure__c(
            OwnerId = targetAH.Id,
            External_ID__c = newAHRCCode,
            RC_Code__c = newAHRCCode,
            AH_RC_Code__c = null,
            NH_RC_Code__c = newNHRCCode,
            NH_Name__c = teamStrucNH.Id,
            AH_Name__c = null,
            Name = 'AreaName'
        );
        insert teamStrucAH;

        Team_Structure__c teamStrucTM = new Team_Structure__c(
            OwnerId = targetTM.Id,
            External_ID__c = newRCCode,
            RC_Code__c = newRCCode,
            AH_RC_Code__c = newAHRCCode,
            NH_RC_Code__c = newNHRCCode,
            NH_Name__c = teamStrucNH.Id,
            AH_Name__c = teamStrucAH.Id,
            Name = 'TeamName'
        );
        insert teamStrucTM;
        User_Extension__c targetRMExt = [SELECT Id,Team_Structure__r.Id,Team_Structure__c FROM User_Extension__c WHERE User__c = :targetRM.Id LIMIT 1];
        
        Test.startTest();
            UserExtension_Service.allTeamStructureMap = null;
            TeamStructure_Service.teamStructureMap = null;
            targetRMExt.Team_Structure__c = teamStrucTM.Id;
            update targetRMExt;
        Test.stopTest();

        Opportunity targetOpp = [SELECT Id, Current_Team_Name__r.Name, Current_Team_Name__r.RC_Code__c FROM Opportunity WHERE AccountId = :targetAccount.Id];
        Team_Structure__c targetTeam = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE External_ID__c = :newRCCode];
        
        System.assertEquals(targetTeam.RC_Code__c, targetOpp.Current_Team_Name__r.RC_Code__c);
    }
}