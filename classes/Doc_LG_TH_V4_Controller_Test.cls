/*
20/04/2017 ISCR109 Form Doc_LG_TH_V4
*/

@isTest 
private class Doc_LG_TH_V4_Controller_Test { 
    @testSetup static void setupUser(){ 
    Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode(); 
}
    
     @isTest static void testSetHtml(){
        Account newAccount;
        User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        System.runAs(rmUser){
        newAccount = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER)); 
                       newAccount.Owner = rmUser; 
                       insert newAccount; 
                        } 
        Doc_LG_TH_V4_Controller newController = new Doc_LG_TH_V4_Controller(new ApexPages.StandardController(newAccount)); 
        System.assertNotEquals(null, newController.html); 
        }
}