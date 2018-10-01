public class test_page_controller {
	public Id testId {get;set;}

    public test_page_controller(ApexPages.standardController con){
        testId = con.getId();
    }
}