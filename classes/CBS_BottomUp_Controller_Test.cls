@isTest
private class CBS_BottomUp_Controller_Test {
    
    @testSetup static void setup(){
        Mockup_Test.setUpTestForBottomUp();
    }
    @isTest static void testBasic(){
        String thisYear = CBS_BottomUp_Controller.getThisYear();
        System.debug('this year >> '+thisYear);
        String lastYear = CBS_BottomUp_Controller.getLastYear();
        System.debug('last year >> '+lastYear);
        CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();

    }
    //EVP
    @isTest static void test_EVP() {
        User evpUser = [SELECT Id,Employee_ID__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBEVP];
        System.debug('evp user >> '+evpUser);
        List<Team_Structure__c> teamStructures = [SELECT Id FROM Team_Structure__c];
        System.debug('teamStructures >> '+teamStructures);
        System.runAs(evpUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            ModelExtensions.QueryPickListObj qobj = new ModelExtensions.QueryPickListObj();
            ModelExtensions.PicklistResponse fsvpResponses = CBS_BottomUp_Controller.getAllFSVPs(qobj);
            System.debug('fsvpResponses >> '+fsvpResponses);

            ModelExtensions.QueryPickListObj qobj1 = new ModelExtensions.QueryPickListObj();    
            qobj1.fsvpID = 'ALL';   
            ModelExtensions.PicklistResponse teamResponsesIfPickAll = CBS_BottomUp_Controller.getTeamsThatRelatedToSelectedFSVP(qobj1);
            System.debug('teamResponsesIfPickAll >> '+teamResponsesIfPickAll);
            ModelExtensions.QueryPickListObj qobj2 = new ModelExtensions.QueryPickListObj();
            qobj2.fsvpID = 'MOCK777777';
            ModelExtensions.PicklistResponse teamResponsesIfPickSomeFSVP = CBS_BottomUp_Controller.getTeamsThatRelatedToSelectedFSVP(qobj2);
            System.debug('teamResponsesIfPickSomeFSVP >> '+teamResponsesIfPickSomeFSVP);

            ModelExtensions.QueryPickListObj qobj3 = new ModelExtensions.QueryPickListObj();
            qobj3.teamRCCode = 'ALL';
            ModelExtensions.PicklistResponse ownerMembersResponsesIfPickAll = CBS_BottomUp_Controller.getOwnerMemberThatRelatedToSelectedTeam(qobj3);
            System.debug('ownerMembersResponsesIfPickAll >> '+ownerMembersResponsesIfPickAll);
            ModelExtensions.QueryPickListObj qobj4 = new ModelExtensions.QueryPickListObj();
            qobj4.teamRCCode = Mockup_Test.TL_CB_RC_CODE;
            ModelExtensions.PicklistResponse ownerMembersResponsesIfPickSomeTeam = CBS_BottomUp_Controller.getOwnerMemberThatRelatedToSelectedTeam(qobj4);
            System.debug('ownerMembersResponsesIfPickSomeTeam >> '+ownerMembersResponsesIfPickSomeTeam);
            ModelExtensions.QueryPickListObj qobj11 = new ModelExtensions.QueryPickListObj();
            qobj11.userEmployeeID = evpUser.Employee_ID__c;
            ModelExtensions.PicklistResponse ownerMembersResponsesIfPickSomeTeamForTM = CBS_BottomUp_Controller.getOwnerMemberThatRelatedToSelectedTeamForTM(qobj11);
            System.debug('ownerMembersResponsesIfPickSomeTeamForTM >> '+ownerMembersResponsesIfPickSomeTeamForTM);

            ModelExtensions.QueryObj qobj5 = new ModelExtensions.QueryObj();
            qobj5.filter = new List<Map<String, String>>();
            qobj5.filter.add(new Map<String,String>());
            qobj5.filter[0].put('teamRCCode','tlRCCode');
            qobj5.filter[0].put('salesEmployeeId','none');
            qobj5.filter[0].put('tmRequest','false');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse salesTargetTeamLevelResponses = CBS_BottomUp_Controller.querySalesTargetTable(qobj5);
            System.debug('salesTargetTeamLevelResponses >> '+salesTargetTeamLevelResponses);

            ModelExtensions.QueryObj qobj6 = new ModelExtensions.QueryObj();
            qobj6.filter = new List<Map<String, String>>();
            qobj6.filter.add(new Map<String,String>());
            qobj6.filter[0].put('teamRCCode','none');
            qobj6.filter[0].put('salesEmployeeId',Mockup_Test.userCBSEmpIdTM);
            qobj6.filter[0].put('tmRequest','false');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse salesTargetSalesLevelResponses = CBS_BottomUp_Controller.querySalesTargetTable(qobj6);
            System.debug('salesTargetSalesLevelResponses >> '+salesTargetSalesLevelResponses);

            ModelExtensions.QueryObj qobj7 = new ModelExtensions.QueryObj();
            qobj7.filter = new List<Map<String, String>>();
            qobj7.filter.add(new Map<String,String>());
            qobj7.filter[0].put('FSVPEmployeeID','none');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse teamTargetResponseWhenFSVPEmployeeIDIsNull = CBS_BottomUp_Controller.queryTeamTargetTable(qobj7);
            System.debug('teamTargetResponseWhenFSVPEmployeeIDIsNull >> '+teamTargetResponseWhenFSVPEmployeeIDIsNull);

            ModelExtensions.QueryObj qobj8 = new ModelExtensions.QueryObj();
            qobj8.filter = new List<Map<String, String>>();
            qobj8.filter.add(new Map<String,String>());
            qobj8.filter[0].put('FSVPEmployeeID','MOCK77771');
            qobj8.sortParams = new List<Map<String, String>>();
            qobj8.sortParams.add(new Map<String, String>());
            qobj8.sortParams[0].put('property','targetName');
            qobj8.sortParams[0].put('direction','ASC');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse teamTargetResponseWhenFSVPEmployeeIDIsEntered = CBS_BottomUp_Controller.queryTeamTargetTable(qobj8);
            System.debug('teamTargetResponseWhenFSVPEmployeeIDIsEntered >> '+teamTargetResponseWhenFSVPEmployeeIDIsEntered);

            ModelExtensions.QueryObj qobj9 = new ModelExtensions.QueryObj();
            qobj9.filter = new List<Map<String, String>>();
            qobj9.filter.add(new Map<String,String>());
            qobj9.filter[0].put('teamRCCode','tlRCCode');
            qobj9.sortParams = new List<Map<String, String>>();
            qobj9.sortParams.add(new Map<String, String>());
            qobj9.sortParams[0].put('property','targetName');
            qobj9.sortParams[0].put('direction','ASC');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse teamTargetResponseWhenTeamRCCodeIsEntered = CBS_BottomUp_Controller.queryTeamTargetTable(qobj9);
            System.debug('teamTargetResponseWhenTeamRCCodeIsEntered >> '+teamTargetResponseWhenTeamRCCodeIsEntered);

            ModelExtensions.QueryObj qobj10 = new ModelExtensions.QueryObj();
            qobj10.sortParams = new List<Map<String, String>>();
            qobj10.sortParams.add(new Map<String, String>());
            qobj10.sortParams[0].put('property','targetName');
            qobj10.sortParams[0].put('direction','ASC');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','transactionFeeTarget');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','transactionFeeBottomUp');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','mainOperatingBankTarget');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','mainOperatingBankBottomUp');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','dealBaseFeeTarget');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            qobj10.sortParams[0].put('property','dealBaseFeeBottomUp');
            fsvpResponsesSortASC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj10);
            System.debug('fsvpResponsesSortASC >> '+fsvpResponsesSortASC);

            Test.stopTest();
        }
    }
    @isTest static void test_EVP2() {
        User evpUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBEVP];
        System.debug('evp user >> '+evpUser);
        List<Team_Structure__c> teamStructures = [SELECT Id FROM Team_Structure__c];
        System.debug('teamStructures >> '+teamStructures);
        User_Extension__c rm1UserExtension = [SELECT ID FROM User_Extension__c WHERE User__r.FirstName =: Mockup_Test.userFirstNameCBRM LIMIT 1];
        Bottom_Up_Annualized__c bottomUp = [SELECT Id FROM Bottom_Up_Annualized__c LIMIT 1];
        System.runAs(evpUser){
            Test.startTest();
            ModelExtensions.QueryObj qobj11 = new ModelExtensions.QueryObj();
            qobj11.sortParams = new List<Map<String, String>>();
            qobj11.sortParams.add(new Map<String, String>());
            qobj11.sortParams[0].put('property','targetName');
            qobj11.sortParams[0].put('direction','DESC');
            ModelExtensions.CRUDCustomBottomUpAnnualizedResponse fsvpResponsesSortDESC = CBS_BottomUp_Controller.queryFSVPTargetTable(qobj11);
            System.debug('fsvpResponsesSortDESC >> '+fsvpResponsesSortDESC);

            ModelExtensions.savingSalesTargetRequest savingSalesTargetObject = new ModelExtensions.savingSalesTargetRequest();
            savingSalesTargetObject.salesTargetId = [SELECT Id FROM Sales_Target__c WHERE Name__c =: rm1UserExtension.Id].Id;
            savingSalesTargetObject.transactionFeeTarget = 200;
            savingSalesTargetObject.mainOperatingBankTarget = 300;
            savingSalesTargetObject.dealBaseFeeTarget = 400;
            ModelExtensions.savingSalesTargetsRequests savingSalesTargetObjects = new ModelExtensions.savingSalesTargetsRequests();
            savingSalesTargetObjects.salesTargetRequests = new List<ModelExtensions.savingSalesTargetRequest>();
            savingSalesTargetObjects.salesTargetRequests.add(savingSalesTargetObject);
            ModelExtensions.SavingResponse saveSalesTargetResponse = CBS_BottomUp_Controller.saveSalesTargetTable(savingSalesTargetObjects);

            ModelExtensions.savingBottomUpAnnualizedRequest savingBottomUpObject = new ModelExtensions.savingBottomUpAnnualizedRequest();
            savingBottomUpObject.bottomUpAnnualizedId = bottomUp.Id;
            savingBottomUpObject.transactionFeeTF = 200;
            savingBottomUpObject.transactionFeeFX = 200;
            savingBottomUpObject.transactionFeeLI = 200;
            savingBottomUpObject.transactionFeeSS = 200;
            savingBottomUpObject.mainOperatingBankFloat = 200;
            savingBottomUpObject.mainOperatingBankCash = 200;
            savingBottomUpObject.mainOperatingBankKA = 200;
            savingBottomUpObject.dealBaseFeeFrontEnd = 200;
            savingBottomUpObject.dealBaseFeeDeriverative = 200;
            savingBottomUpObject.dealBaseFeeIBB = 200;
            savingBottomUpObject.dealBaseFeeInvestmentFee = 200;
            savingBottomUpObject.dealBaseFeeBA = 200;
            savingBottomUpObject.businessClosed = 'No';
            ModelExtensions.savingBottomUpAnnualizedRequests savingBottomUpObjects = new ModelExtensions.savingBottomUpAnnualizedRequests();
            savingBottomUpObjects.bottomUpAnnualizedRequests = new List<ModelExtensions.savingBottomUpAnnualizedRequest>();
            savingBottomUpObjects.bottomUpAnnualizedRequests.add(savingBottomUpObject);
            ModelExtensions.SavingResponse saveBottomUpResponse = CBS_BottomUp_Controller.saveBottomUpAnnualizedTable(savingBottomUpObjects);

            Test.stopTest();
        }
    }
    //FSVP
    @isTest static void test_FSVP() {
        User fsvpUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBFSVP];
        System.runAs(fsvpUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            Test.stopTest();
        }
    }

    //CBSAdmin
    @isTest static void test_CBSAdmin() {
        User cbsAdminUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBSAdmin];
        System.runAs(cbsAdminUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            Test.stopTest();
        }
    }
    
    //NHTL
    @isTest static void test_NHTL() {
        User nhUser = [SELECT Id,Employee_ID__c,Name,RC_Code__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
        User_Mirror_Management__c thisNHTLUserMirrorManagement = new User_Mirror_Management__c();
        thisNHTLUserMirrorManagement.Employee_ID__c = nhUser.Employee_ID__c;
        thisNHTLUserMirrorManagement.Employee_Name__c = nhUser.Name;
        thisNHTLUserMirrorManagement.Mirror_Type__c = 'RC_Code';
        thisNHTLUserMirrorManagement.Mirror_Value__c = MOckup_Test.userCBSEmpIdTL;
        thisNHTLUserMirrorManagement.User_Value__c = nhUser.RC_Code__c;
        thisNHTLUserMirrorManagement.Name = 'testNHTLMOCK033';
        insert thisNHTLUserMirrorManagement;
        System.runAs(nhUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            Test.stopTest();
        }
    }

    //TL
    @isTest static void test_TL() {
        User tlUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBTL];
        System.runAs(tlUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            Team_Target__c teamTarget = [SELECT Id FROM Team_Target__c WHERE External_ID__c = 'tlTeamTargetExtId'];
            Team_Target__c updateTeamTarget = new Team_Target__c(Id = teamTarget.Id);
            updateTeamTarget.Transaction_Fee_Team_Target__c = 7777777;
            update updateTeamTarget;
            PageReference checkurl = cbsController.validateProfileAndRedirect();
            System.assertEquals(null,checkurl);
            Test.stopTest();
        }
    }
    
    //STL
    @isTest static void test_Stl(){
        User tlUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBSTL];
        System.runAs(tlUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            PageReference checkurl = cbsController.validateProfileAndRedirect();
            System.assertEquals(null,checkurl);
            Test.stopTest();
        }
    }

    //TMv
    @isTest static void test_TM() {
        User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBTM];
        System.runAs(tmUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            PageReference checkurl = cbsController.validateProfileAndRedirect();
            System.assertEquals(null,checkurl);
            Test.stopTest();
        }
    }

    //RM
    @isTest static void test_RM() {
        User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameCBRM];
        System.runAs(rmUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            PageReference checkurl = cbsController.validateProfileAndRedirect();
            System.assertEquals(null,checkurl);
            Test.stopTest();
        }
    }

    @isTest static void testRMSME(){
        User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.runAs(rmUser){
            Test.startTest();
            CBS_BottomUp_Controller cbsController = new CBS_BottomUp_Controller();
            PageReference checkurl = cbsController.validateProfileAndRedirect();
            System.assertNotEquals(null,checkurl);
            Test.stopTest();
        }
    }
    
}