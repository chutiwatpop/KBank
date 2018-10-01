@isTest 
private class BottomUp_Section_Test
{
	public static Account accountTest;
	public static Sales_Target__c salesTarget;
	public static User_Extension__c userEx;
	public static Team_Target__c teamTarget;
	public static Team_Structure__c teamStructure;
	@isTest	static void test_Constructor(){
		iniateTest();
		PageReference pageRef = Page.BottomUp_Section_Page;
        Test.setCurrentPage(pageRef);

        //Account customer1 = [SELECT Id FROM Account WHERE Name = 'Customer1'];
        Account customer1 = Mockup_Test.getFirstAccountFromName('Customer1', 'Id');
        pageRef.getParameters().put('Id', String.valueOf(customer1.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(customer1);

        BottomUp_Section_Controller controller = new BottomUp_Section_Controller(sc);

	}
	public static void iniateTest(){
  		Mockup_Test mockup = new Mockup_Test();
  		Mockup_Test.setUpTestForBottomUp();
	}
}