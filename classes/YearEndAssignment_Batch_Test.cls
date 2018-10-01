/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
* @17/09/2015 update
*/
@isTest
private class YearEndAssignment_Batch_Test {
    /*public static String accountNameTM = 'tmCreatedAccountName';
    public static String yearEndCISNo1 = '111111';
    public static String yearEndCISNo2 = '222222';
    public static String yearEndCISNo3 = '333333';
    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        Integer pagesize = 150;
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();

        User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userRMCBS = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        User userTLCBS = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
        Team_Structure__c tmTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.RC_CODE LIMIT 1];
        Team_Structure__c ahTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.AH_RC_CODE LIMIT 1];
        Team_Structure__c tlTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.TL_CB_RC_CODE LIMIT 1];

        List<Business_Code__c> businessCodeList = new List<Business_Code__c>();
        Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c=Mockup_Test.teamSegment1,External_ID__c='123456:'+GlobalConstants.SEGMENT_ME);
        businessCodeList.add(buCodeTest);
        insert businessCodeList;

        Test.startTest();
        //Create Account
        Account account1 = new Account(
            Name = YearEndAssignment_Batch_Test.yearEndCISNo1,
            Cis__c = YearEndAssignment_Batch_Test.yearEndCISNo1,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            OwnerId = userRM.Id,
            Primary_Segment_Code__c = 'SM',
            Temporary_Customer__c = true,
            OwnerChangeExecutedByTrigger__c = true
        );

        Account account2 = new Account(
            Name = YearEndAssignment_Batch_Test.yearEndCISNo2,
            Cis__c = YearEndAssignment_Batch_Test.yearEndCISNo2,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            OwnerId = userRM.Id,
            Primary_Segment_Code__c = 'SM',
            Temporary_Customer__c = true,
            OwnerChangeExecutedByTrigger__c = true
        );
        Account account3 = new Account(
            Name = YearEndAssignment_Batch_Test.yearEndCISNo3,
            Cis__c = YearEndAssignment_Batch_Test.yearEndCISNo3,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            OwnerId = userRM.Id,
            Primary_Segment_Code__c = 'CB',
            Temporary_Customer__c = true,
            OwnerChangeExecutedByTrigger__c = true
        );
        accountList.add(account1);
        accountList.add(account2);
        accountList.add(account3);
        insert accountList;

        contactList.add(new Contact(
            AccountId = account1.Id,
            Contact_Firstname__c = 'contactName1',
            LastName = 'contactLastName1',
            Phone_Numbers__c = '0000000001'
        ));
        insert contactList;
        //Create callreport
        Business_Code__c buCode = [SELECT Name,External_ID__c,Segment__c FROM Business_Code__c WHERE Name = '123456' LIMIT 1];
        Customer_Business_Code__c customerbusinessCode = new Customer_Business_Code__c(CIS__c = account1.id,Business_Code__c=buCode.id, Account_Owner_Segment__c = Mockup_Test.teamSegment1,External__c = account1.CIS__c+':'+buCode.External_ID__c);
        insert customerBusinessCode;

        Call_Report__c callreportObj = new Call_Report__c(
            CIS_ID__c = account1.Id,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today(),
            Contact__c = contactList[0].id,
            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
            Expected_Credit_Amount__c = 100000,
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
            Offer_Credit_Product__c = true,
            Actual_Visit_Date__c  = System.Today()-1,
            Customer_Business_Code__c = customerbusinessCode.Id,
            Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
        );

        insert callreportObj;
        //Create YearEnd
        
        List<Year_End_Sales_Structure__c> yearSaleStruclist = new List<Year_End_Sales_Structure__c>();
        Year_End_Sales_Structure__c  ahSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdAH,RC_Code__c=Mockup_Test.AH_RC_CODE,Role__c='AH',Segment__c='ME',Submitted_Flag__c=false,Team__c=ahTeam.Id,User__c=userAH.Id);
        Year_End_Sales_Structure__c  tmSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdTM,RC_Code__c=Mockup_Test.RC_CODE,Role__c='TM',Segment__c='ME',Submitted_Flag__c=false,Team__c=tmTeam.Id,User__c=userTM.Id,AH_Name__c=ahSaleStruct.Id,Manager__c=ahSaleStruct.Id);
        Year_End_Sales_Structure__c  rmSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdRM,RC_Code__c=Mockup_Test.RC_CODE,Role__c='RM',Segment__c='ME',Submitted_Flag__c=false,Team__c=tmTeam.Id,User__c=userRM.Id,AH_Name__c=ahSaleStruct.Id,Manager__c=tmSaleStruct.Id);
        Year_End_Sales_Structure__c  tlCBSSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userCBSEmpIdTL,RC_Code__c=Mockup_Test.TL_CB_RC_CODE,Role__c='TL',Segment__c='CB',Submitted_Flag__c=false,Team__c=tlTeam.Id,User__c=userTLCBS.Id);
        Year_End_Sales_Structure__c  rmCBSSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userCBSEmpIdRM,RC_Code__c=Mockup_Test.TL_CB_RC_CODE,Role__c='RM',Segment__c='CB',Submitted_Flag__c=false,Team__c=tlTeam.Id,User__c=userRMCBS.Id,AH_Name__c=tlCBSSaleStruct.Id,Manager__c=tlCBSSaleStruct.Id);
        
        yearSaleStruclist.add(ahSaleStruct);
        yearSaleStruclist.add(tmSaleStruct);
        yearSaleStruclist.add(rmSaleStruct);
        yearSaleStruclist.add(tlCBSSaleStruct);
        yearSaleStruclist.add(rmCBSSaleStruct);
        insert yearSaleStruclist;

        List<Year_End_Assignment__c> yearEndlist = new List<Year_End_Assignment__c>();
        Year_End_Assignment__c yearObj = Mockup_Test.newYearEndAssignment(yearEndCISNo1,Mockup_Test.userFirstNameRM,Mockup_Test.AH_RC_CODE);
        Year_End_Assignment__c yearObj2 = Mockup_Test.newYearEndAssignment(yearEndCISNo2,Mockup_Test.userFirstNameRM,Mockup_Test.AH_RC_CODE);
        Year_End_Assignment__c yearObj3 = Mockup_Test.newYearEndAssignment(yearEndCISNo3,Mockup_Test.userFirstNameCBRM,Mockup_Test.TL_CB_RC_CODE);
        
        yearObj.Sales_Size__c = 100000000;
        yearObj.Final_Refer_Out__c = false;
        yearObj.Final_Assigned_Next_Year__c = rmCBSSaleStruct.Id;
        yearObj.Final_Port_Pool__c = GlobalConstants.PORT;
        yearObj.Status__c = 'Submitted';

        yearObj2.Sales_Size__c = 100000000;
        yearObj2.Final_Refer_Out__c = false;
        yearObj2.Final_Assigned_Next_Year__c = rmSaleStruct.Id;
        yearObj2.Final_Port_Pool__c = GlobalConstants.PORT;
        yearObj2.Status__c = 'Submitted';

        yearEndlist.add(yearObj);
        yearEndlist.add(yearObj2);
        yearEndlist.add(yearObj3);
        insert yearEndlist;
        Test.stopTest();



    }

    static testMethod void yearEndAssignAccount(){
        //Account targetAccount = [SELECT Id,Owner.Name,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name =:YearEndAssignment_Batch_Test.yearEndCISNo1 LIMIT 1];
        Account targetAccount = Mockup_Test.getFirstAccountFromName(YearEndAssignment_Batch_Test.yearEndCISNo1, 'Id,Owner.Name,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name');
        System.debug('Before run' +targetAccount.Owner.Name);
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userRMCBS = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        System.runAs(userRM){
            Test.startTest();
                Database.executeBatch(new YearEndAssignment_Batch());
            Test.stopTest();
        }
        Account finalAccount = [SELECT Id,Owner.Name,OwnerId,Previous_Owner__c,Port_Pool__c,Customer_Owner_Changed_Date__c,Service_RM__c FROM Account WHERE Id=:targetAccount.Id LIMIT 1];
        System.debug('After run' +finalAccount.Owner.Name);
        System.assertEquals(userRMCBS.Id, finalAccount.OwnerId);
        System.assertEquals(userRM.Id, finalAccount.Previous_Owner__c);
        System.assertEquals(GlobalConstants.PORT, finalAccount.Port_Pool__c);

    }*/

}