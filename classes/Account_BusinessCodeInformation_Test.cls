@isTest
private class Account_BusinessCodeInformation_Test {
    public static String userRMSE_FirstName = 'userSE_FirstName';
    public static String userRMSE_LastName = 'userSE_LastName';
    public static String userRMSE_EmpId = '999999991';

    public static String accountNameRMSE = 'accountNameRMSE';
    public static String accountRMSECIS = '111222333';

    public static String businessCodeText1 = '003150112';
    public static String riskyControl_FL = 'riskyControl_FL';

    @testSetup static void setUpDate(){
        Test.startTest();
            List<User> userList = new List<User>();

            Profile rmProfile = [SELECT Id From Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
            User useRMSE = Mockup_Test.newUser(userRMSE_FirstName,userRMSE_LastName,userRMSE_EmpId,true,rmProfile.id,null,null);
            useRMSE.Segment__c = GlobalConstants.SEGMENT_SE;
            userList.add(useRMSE);
            insert userList;

            String recoedTypeIdAccountCustomer = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
            System.runAs(useRMSE){
                Account accountOwnerRMSE = Mockup_Test.newAccountWithSegment(accountNameRMSE,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
                accountOwnerRMSE.CIS__c = Account_BusinessCodeInformation_Test.accountRMSECIS;
                insert accountOwnerRMSE;
            }

            List<Business_Code__c> businessCodeList = new List<Business_Code__c>();
            Business_Code__c businessCode = new Business_Code__c(Name=businessCodeText1,Segment__c=GlobalConstants.SEGMENT_SE,External_ID__c=businessCodeText1+':'+GlobalConstants.SEGMENT_SE,
                                                                Risky_Control_FL__c = Account_BusinessCodeInformation_Test.riskyControl_FL);
            businessCodeList.add(businessCode);
            insert businessCodeList;
        Test.stopTest();
    }
    
    @isTest static void testRetiveDataFromTransact() {
        Account account = [SELECT Id From Account WHERE CIS__c = :Account_BusinessCodeInformation_Test.accountRMSECIS LIMIT 1]; 
        ApexPages.StandardController stdController = new ApexPages.StandardController(account);
        ApexPages.currentPage().getParameters().put('id',account.Id);
        Account_BusinessCodeInformation_CTRL ctrl = new Account_BusinessCodeInformation_CTRL(stdController);
        MockHttpResponseGenerator mockrequest = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mockrequest);
        ctrl.init();

        //System.assertEquals(Account_BusinessCodeInformation_CTRL.SOURCE_TRANSACT,ctrl.sourceData);
    }

    @isTest static void testRetiveDataFromCIS() {
        Account account = [SELECT Id From Account WHERE CIS__c = :Account_BusinessCodeInformation_Test.accountRMSECIS LIMIT 1]; 
        ApexPages.StandardController stdController = new ApexPages.StandardController(account);
        ApexPages.currentPage().getParameters().put('id',account.Id);
        Account_BusinessCodeInformation_CTRL ctrl = new Account_BusinessCodeInformation_CTRL(stdController);
        ctrl.init();

        System.assertEquals(Account_BusinessCodeInformation_CTRL.SOURCE_CIS,ctrl.sourceData);
    }
    
}