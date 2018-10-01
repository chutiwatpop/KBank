/**************************************************************************
*  Description      : Test class for ContactTriggerHandler
*
*  Modification List:
*  Name             Date            Modification Description
*  ----------       -----------     ------------------------------
*  Chumphon K.      17-Feb-2017     ISCR073 UpdateContactOfLeadCustSat
*  Worrapol A.      05-Jul-2018     CreateContactContactRelationshipCustSat
*  Worrapol A.      11-Jul-2018     UpdateEditContactOfLeadCustSat
*  
***************************************************************************/
@isTest
private class Contact_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String leadCustSat = System.label.LeadCustSat; // Add by Chumphon K., ISCR073
    @testSetup static void setupAccount(){
        //Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        //Test.stopTest();
        SetupLead(); // Add by Chumphon K., ISCR073
    }
    
    static testMethod void  checkPrimaryContact() {
        //Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Contact_Test.accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Contact_Test.accountNameRM, 'Id,Delete_Flag__c');
        Contact con = new Contact();
        con.LastName = 'lastname';
        con.Contact_Firstname__c = 'Firstname';
        con.Birthdate__c = '11/11/2550';
        con.AccountId = targetAccount.Id;
        con.Phone_Numbers__c = '023450789';
        con.Primary_Contact__c = true;
        insert con;

        Contact con2 = new Contact();
        con2.LastName = 'lastname';
        con2.Contact_Firstname__c = 'Firstname';
        con2.Birthdate__c = '11/11/2550';
        con2.AccountId = targetAccount.Id;
        con2.Phone_Numbers__c = '023450789';        
        
        Test.startTest();
        try {
            insert con2;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('already has primary'));
        }
            
        Test.stopTest();
    }
    
    static testMethod void  noPrimaryContact() {
        //Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Contact_Test.accountNameRM LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Contact_Test.accountNameRM, 'Id,Delete_Flag__c');       
        Contact con = new Contact();
        con.LastName = 'lastname';
        con.Contact_Firstname__c = 'Firstname';
        con.Birthdate__c = '11/11/2550';
        con.AccountId = targetAccount.Id;
        con.Phone_Numbers__c = '023450789';
        insert con;

        Contact con2 = new Contact();
        con2.LastName = 'lastname';
        con2.Contact_Firstname__c = 'Firstname';
        con2.Birthdate__c = '11/11/2550';
        con2.AccountId = targetAccount.Id;
        con2.Phone_Numbers__c = '023450789';        
        
        Test.startTest();
        insert con2;
        Test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM Contact WHERE AccountId = :targetAccount.Id].size());
    }
    // [Start] Add by Chumphon K., ISCR073
    public static void setupLead(){
        Campaign mockLeadCustSat = new Campaign();
        mockLeadCustSat.Start_Date_Time__c = System.now();
        mockLeadCustSat.Lead_Campaign_Event_Code__c = leadCustSat;
        mockLeadCustSat.Type__c = GlobalConstants.LEAD_FOR_SALES;
        mockLeadCustSat.Name = leadCustSat;
        mockLeadCustSat.Status = GlobalConstants.ACTIVE;
        mockLeadCustSat.IsActive = false;
        mockLeadCustSat.StartDate = System.today() - 1;
        mockLeadCustSat.EndDate = System.Today() + 1;
        mockLeadCustSat.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
        insert mockLeadCustSat;
          

        //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
        Account account = Mockup_Test.getFirstAccountFromName(Contact_Test.accountNameRM, 'Id, CIS__c,OwnerId');
        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = mockLeadCustSat.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        targetList.Personalised_Message__c = System.label.IncorrectPhoneNumber + ' ' + System.label.IncorrectContactName;
        targetList.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard');
        insert targetList;
    }

    // [Start] Created by Worrapol A. for, CreateContactContactRelationship
    // @isTest
    // public static void test_CreateANewContactContactRelationship() {
    //     //Mock up the account and contact-contact relationship record
    //     Account acct = new Account(
    //         FirstName = 'firstname',
    //         LastName = 'lastname',
    //         RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Individual Customer')
    //     );
    //     FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c();
    //     reciprocalRole.Name = 'ผู้ติดต่อ';
    //     reciprocalRole.Role_Code__c = 'MGT';
    //     reciprocalRole.FinServ__InverseRole__c = 'ผู้ติดต่อ';
    //     reciprocalRole.Inverse_Role_Code__c = 'MGT';
    //     reciprocalRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
    //     reciprocalRole.FinServ__CreateInverseRole__c = false;
    //     reciprocalRole.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole');

    //     insert acct;
    //     insert reciprocalRole;
    //     insert new MigrationConfig__c(ContactRelation__c=reciprocalRole.Id);

    //     //Test to create contact and build relationship
    //     Contact cont = new Contact(
    //         FirstName = 'First',
    //         LastName = 'Last',
    //         Phone_Numbers__c = '081234567',
    //         CIS__c = acct.Id
    //     );
    //     insert cont;
    // }

    // @isTest
    // public static void test_CreateBulkContactContactRelationship() {
    //     List<Contact> contList = new List<Contact>();

    //     //Mock up the account and contact-contact relationship record
    //     Account acct = new Account(
    //         FirstName = 'firstname',
    //         LastName = 'lastname',
    //         RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Individual Customer')
    //     );

    //     FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c();
    //     reciprocalRole.Name = 'ผู้ติดต่อ';
    //     reciprocalRole.Role_Code__c = 'MGT';
    //     reciprocalRole.FinServ__InverseRole__c = 'ผู้ติดต่อ';
    //     reciprocalRole.Inverse_Role_Code__c = 'MGT';
    //     reciprocalRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
    //     reciprocalRole.FinServ__CreateInverseRole__c = false;
    //     reciprocalRole.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('FinServ__ReciprocalRole__c', 'ContactRole');

    //     insert acct;
    //     insert reciprocalRole;
    //     insert new MigrationConfig__c(ContactRelation__c=reciprocalRole.Id);

    //     //Test to create contact and build relationship
    //     for (Integer i = 0; i < 200; i++) {
    //         contList.add(new Contact(
    //             FirstName = 'First',
    //             LastName = 'Last',
    //             Phone_Numbers__c = '081234567',
    //             CIS__c = acct.Id
    //         ));
    //     }
    //     insert contList;
    // }
    // [End] Created by Worrapol A. for, CreateContactContactRelationship

    // [Start] Create by Worrapol A., UpdateContactOfLeadCusSat
    @isTest
    public static void test_editContactOrganizeAccountGroup1() {
        //mockup Campaign, Account, Contact, AccountContactrealtion, Target
        Campaign camp = new Campaign(
            Name = 'Cust Sat',
            Lead_Campaign_Event_Code__c = 'SLQT17011',
            Status = 'Planned',
            Type__c = 'Lead To Do',
            Sub_Type__c = 'เพื่อติดตาม RM',
            StartDate = System.Today(),
            EndDate = System.Today().addMonths(3),
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Campaign', 'SME_Lead_Campaign')
        );
        insert camp;

        Account acct = new Account(
            CIS__c = '11',
            Encrypt_Name_TH__c = 'Org customer',
            Name = 'Org customer',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Organization Customer'),
                Is_createby_Integration__c  = true
        );
        insert acct;
        
        Contact cont = new Contact(
            FirstName = 'A',
            LastName = 'Org',
            Phone_Numbers__c = '091111111',
            AccountId = acct.Id
        );
        insert cont;

        Target_List__c target = new Target_List__c(
            Contact_Name__c = 'A Org',
            Customer_Contact_Number__c = '092222222',
            CIS_ID_Prospect_Name__c = acct.Id,
            Personalised_Message__c = '1. เบอร์โทรผู้ติดต่อผิด',
            Lead_Campaign__c = camp.Id,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard')
        );
        insert target;

        Test.startTest();
        cont.Phone_Numbers__c = '092222222';
        update cont;
        Test.stopTest();
    }

    @isTest
    public static void test_editContactOrganizeAccountGroup2() {
        //mockup Campaign, Account, Contact, AccountContactrealtion, Target
        Campaign camp = new Campaign(
            Name = 'Cust Sat',
            Lead_Campaign_Event_Code__c = 'SLQT17011',
            Status = 'Planned',
            Type__c = 'Lead To Do',
            Sub_Type__c = 'เพื่อติดตาม RM',
            StartDate = System.Today(),
            EndDate = System.Today().addMonths(3),
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Campaign', 'SME_Lead_Campaign')
        );
        insert camp;

        Account acct = new Account(
            CIS__c = '11',
            Encrypt_Name_TH__c = 'Org customer',
            Name = 'Org customer',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Organization Customer'),
                Is_createby_Integration__c  = true
        );
        insert acct;
        
        Contact cont = new Contact(
            FirstName = 'A',
            LastName = 'Org',
            Phone_Numbers__c = '091111111',
            AccountId = acct.Id
        );
        insert cont;

        Target_List__c target = new Target_List__c(
            Contact_Name__c = 'newA Org',
            Customer_Contact_Number__c = '092222222',
            CIS_ID_Prospect_Name__c = acct.Id,
            Personalised_Message__c = 'กลุ่ม 2: ชื่อผู้ติดต่อผิด-ไม่ใช่เป็นคนที่ติดต่อกับ RM/SA เป็นหลัก (ไม่ใช่ผู้ติดต่อหลัก)',
            Lead_Campaign__c = camp.Id,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard')
        );
        insert target;

        Test.startTest();
        cont.Phone_Numbers__c = '092222222';
        cont.FirstName = 'newA';
        update cont;
        Test.stopTest();
    }

    @isTest
    public static void test_editContactPersonalAccountGroup1() {
        //mockup Campaign, Account, Contact, AccountContactrealtion, Target
        Campaign camp = new Campaign(
            Name = 'Cust Sat',
            Lead_Campaign_Event_Code__c = 'SLQT17011',
            Status = 'Planned',
            Type__c = 'Lead To Do',
            Sub_Type__c = 'เพื่อติดตาม RM',
            StartDate = System.Today(),
            EndDate = System.Today().addMonths(3),
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Campaign', 'SME_Lead_Campaign')
        );
        insert camp;

        Account acct = new Account(
            FirstName = 'firstname',
            LastName = 'lastname',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Individual Customer'),
            Is_createby_Integration__c  = true
        );
        insert acct;
        
        Contact cont = new Contact(
            FirstName = 'A',
            LastName = 'Indi',
            Phone_Numbers__c = '091111111',
            CIS__c = acct.Id
        );
        insert cont;

        Target_List__c target = new Target_List__c(
            Contact_Name__c = 'A Indi',
            Customer_Contact_Number__c = '092222222',
            CIS_ID_Prospect_Name__c = acct.Id,
            Personalised_Message__c = '1. เบอร์โทรผู้ติดต่อผิด',
            Lead_Campaign__c = camp.Id,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard')
        );
        insert target;

        Test.startTest();
        cont.Phone_Numbers__c = '092222222';
        update cont;
        Test.stopTest();
    }

    @isTest
    public static void test_editContactPersonalAccountGroup2() {
        //mockup Campaign, Account, Contact, AccountContactrealtion, Target
        Campaign camp = new Campaign(
            Name = 'Cust Sat',
            Lead_Campaign_Event_Code__c = 'SLQT17011',
            Status = 'Planned',
            Type__c = 'Lead To Do',
            Sub_Type__c = 'เพื่อติดตาม RM',
            StartDate = System.Today(),
            EndDate = System.Today().addMonths(3),
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Campaign', 'SME_Lead_Campaign')
        );
        insert camp;

        Account acct = new Account(
            FirstName = 'firstname',
            LastName = 'lastname',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Individual Customer'),
            Is_createby_Integration__c = true
        );
        insert acct;
        
        Contact cont = new Contact(
            FirstName = 'A',
            LastName = 'Indi',
            Phone_Numbers__c = '091111111',
            CIS__c = acct.Id
        );
        insert cont;

        Target_List__c target = new Target_List__c(
            Contact_Name__c = 'newA Indi',
            Customer_Contact_Number__c = '092222222',
            CIS_ID_Prospect_Name__c = acct.Id,
            Personalised_Message__c = 'กลุ่ม 2: ชื่อผู้ติดต่อผิด-ไม่ใช่เป็นคนที่ติดต่อกับ RM/SA เป็นหลัก (ไม่ใช่ผู้ติดต่อหลัก)',
            Lead_Campaign__c = camp.Id,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c', 'Standard')
        );
        insert target;

        Test.startTest();
        cont.Phone_Numbers__c = '092222222';
        cont.FirstName = 'newA';
        update cont;
        Test.stopTest();
    }
    // [End] Create by Worrapol A., UpdateContactOfLeadCusSat
   
  //  static testMethod void updateContactCustSat(){
  //      //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
  //      Account account = Mockup_Test.getFirstAccountFromName(Contact_Test.accountNameRM, 'Id, CIS__c,OwnerId');
  //      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadCustSat];
        
  //      Contact cont1 = new Contact();
  //      cont1.FirstName = 'Firstname';
        //cont1.LastName = 'lastname';
        //cont1.Birthdate__c = '11/11/2550';
        //cont1.AccountId = account.Id;
        //cont1.Phone_Numbers__c = '023456789';
        //insert cont1;
        
  //      Call_Report__c callReport = new Call_Report__c();
  //      callReport.CIS_ID__c = account.Id;
  //      callReport.Contact__c = cont1.Id;
  //      callReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME);
  //      callReport.Status__c = GlobalConstants.CONTACTED;
  //      callReport.Actual_Visit_Date__c = System.Today();
  //      callReport.Offer_Credit_Product__c = true;
  //      callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
  //      callReport.Expected_Credit_Amount__c = 1000000;
            
  //      Test.startTest();
  //          TriggerHandler.bypass('CallReportTriggerHandler');
  //           insert callReport;
  //          TriggerHandler.clearbypass('CallReportTriggerHandler');
  //        cont1.FirstName = 'Firstname2';
  //        cont1.Phone_Numbers__c = '023456666';
  //        cont1.Ext_CBS__c = '1000';
  //        update cont1;
  //      Test.stopTest();
        
  //      Contact resultContact = [Select Id, Phone_Numbers__c, Ext_CBS__c From Contact Where Id = :cont1.Id LIMIT 1];
  //      Call_Report__c resultCallReport = [Select Id, Phone_Number__c, Phone_Extension__c From Call_Report__c Where Id = :callReport.Id LIMIT 1];
  //      System.assertEquals(resultContact.Phone_Numbers__c, resultCallReport.Phone_Numbers__c);
  //      System.assertEquals(resultContact.Ext_CBS__c, resultCallReport.Phone_Extension__c);
  //  }
    // [End] Add by Chumphon K., ISCR073
}