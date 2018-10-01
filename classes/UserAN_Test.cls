@isTest
private class UserAN_Test {

    public static String nhANRCCode = 'NHANRC';
    public static String ahANRCCode = 'AHANRC';
    public static String tmANRCCode = 'ANRC';

    public static String nhANTeamName = 'nhANTeamName';
    public static String ahANTeamName = 'ahANTeamName';
    public static String tmANTeamName = 'tmANTeamName';

    public static String nhANRCCode2 = 'NHANRC2';
    public static String ahANRCCode2 = 'AHANRC2';
    public static String tmANRCCode2 = 'ANRC2';

    public static String nhANTeamName2 = 'nhANTeamName2';
    public static String ahANTeamName2 = 'ahANTeamName2';
    public static String tmANTeamName2 = 'tmANTeamName2';

    public static String teamSegment = 'testSegment';

    public static String nhANUserFirstName = 'nhANUserFirstName';
    public static String ahANUserFirstName = 'ahANUserFirstName';
    public static String tmANUserFirstName = 'tmANUserFirstName';
    public static String rmANUserFirstName = 'rmANUserFirstName';

    public static String nhANUserLastName = 'nhANUserLastName';
    public static String ahANUserLastName = 'ahANUserLastName';
    public static String tmANUserLastName = 'tmANUserLastName';
    public static String rmANUserLastName = 'rmANUserLastName';

    public static String nhANEmpId = '90000090001';
    public static String ahANEmpId = '90000090002';
    public static String tmANEmpId = '90000090003';
    public static String rmANEmpId = '90000090004';

    public static String accountANRMName = 'accountANRMName';
    public static String accountANTMName = 'accountANTMName';
    public static String accountANAHName = 'accountANAHName';
    public static String accountANNHName = 'accountANNHName';

    //@testSetup static void setupANTeam(){
    //  Mockup_Test mock = new Mockup_Test();
    //  Test.startTest();
    //  Mockup_Test.setUpCustomSetting();
    //  mock.setUpTestAdmin();

    //    Mockup_Test.setupANTeam();
    //    Test.stopTest();

    //    System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.rmANUserFirstName LIMIT 1][0]){
    //        mock.newAccount(accountANRMName,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }

    //    System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.tmANUserFirstName LIMIT 1][0]){
    //        mock.newAccount(accountANTMName,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }

    //    System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.ahANUserFirstName LIMIT 1][0]){
    //        mock.newAccount(accountANAHName,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }

    //    System.runAs([SELECT Id FROM User WHERE FirstName =: Mockup_Test.nhANUserFirstName LIMIT 1][0]){
    //        mock.newAccount(accountANNHName,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
    //    }

    //}

    /** CR023 Ownership Bad --*/
  //  @isTest static void inactiveBadRM() {
        //Test.startTest();
  //          System.runAs(new User(Id=UserInfo.getUserId())){
  //              User targetBadRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: rmANUserFirstName LIMIT 1];
  //              User targetBadTM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];
  //              targetBadRM.IsActive = false;
  //              targetBadRM.Status__c = 'I';
  //              update targetBadRM;
  //          }

  //      Test.stopTest();
        
  //      User targetBadRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: rmANUserFirstName LIMIT 1];
  //      User newTargetBadTM = [SELECT Id FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];

  //        //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name =: accountANRMName LIMIT 1];
  //      Account targetAccount = Mockup_Test.getFirstAccountFromName(accountANRMName, 'Id, OwnerId, Owner.Employee_Id__c');
  //      System.assertEquals(newTargetBadTM.Id, targetAccount.OwnerId);
  //      //Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
  //      //System.assertEquals('Closed by System', targetTask.Status);
  //  }

  //  @isTest static void inactiveBadTM() {
        //Test.startTest();
  //          System.runAs(new User(Id=UserInfo.getUserId())){
  //              User targetBadTM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];
  //              User targetBadAH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];
  //              targetBadTM.IsActive = false;
  //              targetBadTM.Status__c = 'I';
  //              update targetBadTM;
  //          }

  //      Test.stopTest();
        
  //      User targetBadTM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];
  //      User newTargetBadAH = [SELECT Id FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];

  //      System.debug('Bad TM : '+targetBadTM);
  //      System.debug('Bad AH : '+newTargetBadAH);

  //      //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name =: accountANTMName LIMIT 1];
  //      Account targetAccount = Mockup_Test.getFirstAccountFromName(accountANTMName, 'Id, OwnerId, Owner.Employee_Id__c');
  //      System.assertEquals(newTargetBadAH.Id, targetAccount.OwnerId);
  //      //Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
  //      //System.assertEquals('Closed by System', targetTask.Status);
  //  }

  //  @isTest static void inactiveBadAH() {
        //Test.startTest();
  //          System.runAs(new User(Id=UserInfo.getUserId())){
  //              User targetBadAH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];
  //              targetBadAH.IsActive = false;
  //              targetBadAH.Status__c = 'I';
  //              update targetBadAH;
  //          }

  //      Test.stopTest();
        
  //      User targetBadAH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];
  //      User newTargetBadNH = [SELECT Id FROM User WHERE FirstName =: nhANUserFirstName LIMIT 1];

  //      //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name =: accountANAHName LIMIT 1];
  //      Account targetAccount = Mockup_Test.getFirstAccountFromName(accountANAHName, 'Id, OwnerId, Owner.Employee_Id__c');
  //      System.assertEquals(newTargetBadNH.Id, targetAccount.OwnerId);
  //      //Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
  //      //System.assertEquals('Closed by System', targetTask.Status);
  //  }

  //  @isTest static void inactiveBadNH() {

  //    User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        //Test.startTest();
  //          System.runAs(new User(Id=UserInfo.getUserId())){
  //              User targetBadNH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: nhANUserFirstName LIMIT 1];
  //              targetBadNH.IsActive = false;
  //              targetBadNH.Status__c = 'I';
  //              update targetBadNH;
  //          }

  //      Test.stopTest();
        
  //      User targetBadNH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: nhANUserFirstName LIMIT 1];
  //      //User newTargetBadNH = [SELECT Id FROM User WHERE FirstName =: nhANUserFirstName LIMIT 1];

  //      //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c, Ownership_Text__c, Port_Pool__c FROM Account WHERE Name =: accountANNHName LIMIT 1];
  //      Account targetAccount = Mockup_Test.getFirstAccountFromName(accountANNHName, 'Id, OwnerId, Owner.Employee_Id__c,Ownership_Text__c, Port_Pool__c');
  //      System.assertEquals(userAdmin.Bad_User_ID__c, targetAccount.OwnerId);
  //      System.assertEquals(null, targetAccount.Ownership_Text__c);
  //      System.assertEquals(null, targetAccount.Port_Pool__c);
  //      //Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
  //      //System.assertEquals('Closed by System', targetTask.Status);
  //  }

  //  @isTest static void changeTeamBadTM() {
  //    Test.startTest();
  //          System.runAs(new User(Id=UserInfo.getUserId())){
  //              User targetBadTM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];
  //              User targetBadAH = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];
  //              targetBadTM.RC_Code__c = tmANRCCode2;
  //              update targetBadTM;
  //          }

  //      Test.stopTest();
        
  //      User targetBadTM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName =: tmANUserFirstName LIMIT 1];
  //      User newTargetBadAH = [SELECT Id FROM User WHERE FirstName =: ahANUserFirstName LIMIT 1];

  //      //Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name =: accountANTMName LIMIT 1];
  //      Account targetAccount = Mockup_Test.getFirstAccountFromName(accountANTMName, 'Id, OwnerId, Owner.Employee_Id__c,Ownership_Text__c, Port_Pool__c');
  //      System.assertEquals(newTargetBadAH.Id, targetAccount.OwnerId);
  //  }
    /*-- -- */
    
    
}