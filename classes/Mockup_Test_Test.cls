@isTest
private class Mockup_Test_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
	public static String contactNameTM = 'tmCreatedContactName';
	public static String lastNameTM = 'tmCreatedLastName';
	@isTest
    public static void testAdmin(){
    	Test.startTest();
    		new Mockup_Test().setUpTestOnlyAdmin();
    	Test.stopTest();
    }
    @isTest
    public static void testWithRCCode(){
    	Test.startTest();
    		new Mockup_Test().setUpTestWithRCCode();
    	Test.stopTest();
    }
    @isTest
    public static void testNormalState(){
    	Test.startTest();
    		new Mockup_Test().setUpTest();
    	Test.stopTest();
    }
    @isTest
    public static void testDifferentArea(){
    	Test.startTest();
    		new Mockup_Test().setUpTestDifferentArea();
    	Test.stopTest();
    }
    @isTest
    public static void testNewAccount(){
    	Test.startTest();
    		Mockup_Test mt = new Mockup_Test().setUpTest();
   
	        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
	        }
    	Test.stopTest();
    }
    @isTest
    public static void testNewAccountWithContact(){
    	Test.startTest();
    		Mockup_Test mt = new Mockup_Test().setUpTest();
   
	        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
	        }
    	Test.stopTest();
    }
}