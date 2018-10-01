public with sharing class Test_Controller {
	
	public String myValue{get;set;}
	public Boolean isMobile { get; set; }

	public Test_Controller(ApexPages.StandardController stdController) {
		
		myValue = 'What is that behind you!';
		isMobile = UserInfo.getUiTheme() == 'Theme4t';
	}
}