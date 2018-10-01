@isTest
private class CallReport_Override_Controller_Test {
    
    public static String accountNameTM = 'tmCreatedAccountName';
    @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTest();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        Test.stopTest();
    }

    public static Contact newContact(Account account,String firstname,String lastname){
        Contact con = new Contact();
            con.LastName = 'lastname';
            con.Contact_Firstname__c = 'Firstname';
            con.AccountId = account.Id;
            con.Phone_Number__c = '023450789';
        return con;
    }    

    static testMethod void testRedirectToCallReport(){
        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReport_Override_Controller_Test.accountNameTM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            Contact con = CallReport_Override_Controller_Test.newContact(targetAccount,'Fname','Lname');
            insert con;

            Call_Report__c callreportObj = new Call_Report__c(
                Collect_Documents__c = true,
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Contact__c = con.Id,
                RecordtypeId = [SELECT Id FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName=:GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME][0].Id,
                Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION
            );

            insert callreportObj;
            
            CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller(new ApexPages.StandardController(callreportObj));
            controller.redirectToNewPage();

        }
    }

    static testMethod void testRedirectToCallPlan(){
        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReport_Override_Controller_Test.accountNameTM LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            Call_Report__c callPlanObj;
            callPlanObj = new Call_Report__c(
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName=:GlobalConstants.NEW_CALL_PLAN_DEVNAME][0].Id,
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Plan_Amount__c = 50000,
                Customer_Important_Note__c = 'expected'
            );
            insert callPlanObj;

            Test.startTest();
                ApexPages.currentPage().getParameters().put('newid', callPlanObj.Id);
                ApexPages.currentPage().getParameters().put('accountId', targetAccount.Id);
                CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller(new ApexPages.StandardController(callPlanObj));
                controller.redirect();
            Test.stopTest();
        }
    }

    static testMethod void testRedirectToCallPlanListView(){
        CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller();
        Test.startTest();
        controller.redirectToListView();
        Test.stopTest();
    }

    static testMethod void testCallPlanListViewRedirect(){
        CallReport_OverrideListView_Controller controller = new CallReport_OverrideListView_Controller();
        Test.startTest();
        controller.redirectToListView();
        Test.stopTest();
    }
    

    static testMethod void testRedirectToNonCreditOverrideNewPageWithOpp(){
        User userTM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0];
        userTM.Segment__c = GlobalConstants.SEGMENT_ME;
        System.runAs(new User(Id=UserInfo.getUserId()) ){
            update userTM;
        }
        Account targetAccount = [SELECT Id,Owner.Segment__c,CIS__c FROM Account WHERE Name = :CallReport_Override_Controller_Test.accountNameTM LIMIT 1];
        
        Business_Code__c businessCode = Mockup_Test.newBusinessCode('00001', GlobalConstants.SEGMENT_ME);
        insert businessCode;

        Customer_Business_Code__c customerBusinessCode = Mockup_Test.newCustomerBusinessCode(targetAccount,businessCode);
        insert customerBusinessCode;

        Call_Report__c callreportObj;
        System.runAs(userTM){
            Contact con = CallReport_Override_Controller_Test.newContact(targetAccount,'Fname','Lname');
            insert con;

            callreportObj = new Call_Report__c(
                        Collect_Documents__c = true,
                        CIS_ID__c = targetAccount.Id,
                        Status__c = GlobalConstants.CONTACTED,
                        Contact__c = con.Id,
                        Expected_Credit_Amount__c = 500000,
                        RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
                        Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
                        Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
                        Offer_Credit_Product__c = true,
                        Customer_Business_Code__c = customerBusinessCode.id,
                        Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
                        Non_Credit__c = true
                    );
            Test.startTest();
                insert callreportObj;
            Test.stopTest();
        }
        Opportunity opp = [SELECT id From Opportunity LIMIT 1];

        PageReference expectedPage = new PageReference('/apex/Noncredit_OverrideNew_Page?');
        expectedPage.getParameters().put(Noncredit_OverrideNew_Controller.CALLREPORTID_PARAM,callreportObj.id);
        expectedPage.getParameters().put(Noncredit_OverrideNew_Controller.OPPID_PARAM,opp.id);

        System.currentPageReference().getParameters().put('newid', callreportObj.id);
        CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller();
        PageReference pageReference = controller.redirect();
        System.assertEquals(expectedPage.getUrl(),pageReference.getUrl());
    }


}