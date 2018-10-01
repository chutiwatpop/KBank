/*------------------------------------------------------------
Author: Sasitorn Saisuttichai
Company : Beryl8
Description:   A test class for CustomerSearch_Controller

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Sasitorn.S          First Create
26/04/2018  Wongsakorn.S        Delete unused field Name_EN_Prospect__c,Surname_TH_Prospect__c,Surname_EN_Prospect__c
------------------------------------------------------------*/
@isTest
public class CustomerSearch_Controller_Test {
    public CustomerSearch_Controller_Test() {

    }
    public static final String FIRSTNAME_TH = 'TH_FRST_NM';
    public static final String FIRSTNAME_EN = 'EN_FRST_NM';
    public static final String SURNAME_TH = 'TH_SURNM';
    public static final String SURNAME_EN = 'EN_SURNM';
    public static final String FULLNAME_TH = 'FULLNAME_TH';
    public static final String FULLNAME_EN = 'FULLNAME_EN';
    public static final String IDENT_NO = 'IDENT_NO';
    public static final String CIS_ID = 'IP_ID';
    public static final String LIMIT_VAR = 'LIMIT';
    public static final String CIS_LIST = 'IP_ID';
    public static final String SORT_TYPE = 'SORT_TYPE';
    public static final String SORT_COLUMN = 'SORT_COLUMN';

    public static final String SEARCH_POSITIVE = 'SEARCH_POSITIVE';
    public static final String SEARCH_ERROR_ONLY = 'SEARCH_ERROR_ONLY';
    public static final String SEARCH_PARTIAL_ERROR = 'SEARCH_PARTIAL_ERROR';
    public static final String SEARCH_STATUS_500 = 'SEARCH_STATUS_500';
    public static final String SORT_POSITIVE = 'SORT_POSITIVE';
    public static final String EMPTY_RESPONSE = 'EMPTY_RESPONSE';
    public static CustomerSearch_Controller testController = new CustomerSearch_Controller();
    public static Map<String, Id> RecordTypeAccount = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');

    public static String nhANRCCode = 'NHANRC';
    public static String ahANRCCode = 'AHANRC';
    public static String tmANRCCode = 'ANRC';

    public static String nhANTeamName = 'nhANTeamName';
    public static String ahANTeamName = 'ahANTeamName';
    public static String tmANTeamName = 'tmANTeamName';

    public static String teamSegment = 'testSegment';

    public static String nhANUserFirstName = 'nhANUserFirstName';
    public static String ahANUserFirstName = 'ahANUserFirstName';
    public static String tmANUserFirstName = 'tmANUserFirstName';
    public static String rmANUserFirstName = 'rmANUserFirstName';

    public static String nhANUserLastName = 'nhANUserLastName';
    public static String ahANUserLastName = 'ahANUserLastName';
    public static String tmANUserLastName = 'tmANUserLastName';
    public static String rmANUserLastName = 'rmANUserLastName';

    public static String nhANEmpId = '9999999991';
    public static String ahANEmpId = '9999999992';
    public static String tmANEmpId = '9999999993';
    public static String rmANEmpId = '9999999994';

    public static String accountName = '1993';
    public static String cisIDForBlue = '1993';

    public static void setupANTeam(){
        System.runAs(new User(Id=UserInfo.getUserId())){

            List<Profile> listProfile = new List<Profile>();
            listProfile = [SELECT Id,Name FROM Profile];

            Map<String,Profile> mapProfileByName = new Map<String,Profile>();
            for(Profile eachProfile : listProfile){
                mapProfileByName.put(eachProfile.Name, eachProfile);
            }

            UserRole anRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Name =: GlobalConstants.AN_TEAM_NAME];

            Profile nhANProfile = mapProfileByName.get(GlobalConstants.AN_NH);
            Profile ahANProfile = mapProfileByName.get(GlobalConstants.AN_AH);
            Profile tmANProfile = mapProfileByName.get(GlobalConstants.AN_TM);
            Profile rmANProfile = mapProfileByName.get(GlobalConstants.AN_RM);

            Team_Structure__c tsNhAN = new Team_Structure__c(
                External_ID__c = nhANRCCode,
                RC_Code__c = nhANRCCode,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = nhANTeamName,
                Segment__c = teamSegment,
                Type__c = 'Network'
            );
            insert tsNhAN;

            Team_Structure__c tsAhAN = new Team_Structure__c(
                External_ID__c = ahANRCCode,
                RC_Code__c = ahANRCCode,
                AH_RC_Code__c = null,
                NH_RC_Code__c = nhANRCCode,
                AH_Name__c = null,
                NH_Name__c = tsNhAN.Id,
                Name = ahANTeamName,
                Segment__c = teamSegment,
                Type__c = 'Area'
            );
            insert tsAhAN;

            Team_Structure__c tsTmAN = new Team_Structure__c(
                External_ID__c = tmANRCCode,
                RC_Code__c = tmANRCCode,
                AH_RC_Code__c = ahANRCCode,
                NH_RC_Code__c = nhANRCCode,
                AH_Name__c = tsAhAN.Id,
                NH_Name__c = tsNhAN.Id,
                Name = tmANTeamName,
                Segment__c = teamSegment,
                Type__c = 'Team'
            );
            insert tsTmAN;

            User nhANUser = Mockup_Test.newUser(
                    nhANUserFirstName,
                    nhANUserLastName,
                    true,
                    nhANUserFirstName+'@mail.com',
                    nhANUserFirstName+'@mail.com',
                    nhANUserFirstName.substring(0, 4),
                    nhANProfile.Id,
                    anRole.Id,
                    null,
                    nhANEmpId
            );
            nhANUser.RC_Code__c = nhANRCCode;
            nhANUser.NH_RC_Code__c = nhANRCCode;
            nhANUser.Job_Code__c = 'AN1A';
            nhANUser.Status__c = 'A';
            nhANUser.Segment__c = teamSegment;
            insert nhANUser;

            User ahANUser = Mockup_Test.newUser(
                    ahANUserFirstName,
                    ahANUserLastName,
                    true,
                    ahANUserFirstName+'@mail.com',
                    ahANUserFirstName+'@mail.com',
                    ahANUserFirstName.substring(0, 4),
                    ahANProfile.Id,
                    anRole.Id,
                    nhANUser.Id,
                    ahANEmpId
            );
            ahANUser.RC_Code__c = ahANRCCode;
            ahANUser.NH_RC_Code__c = nhANRCCode;
            ahANUser.AH_RC_Code__c = ahANRCCode;
            ahANUser.Job_Code__c = 'AN2A';
            ahANUser.Status__c = 'A';
            ahANUser.Segment__c = teamSegment;
            insert ahANUser;

            User tmANUser = Mockup_Test.newUser(
                    tmANUserFirstName,
                    tmANUserLastName,
                    true,
                    tmANUserFirstName+'@mail.com',
                    tmANUserFirstName+'@mail.com',
                    tmANUserFirstName.substring(0, 4),
                    tmANProfile.Id,
                    anRole.Id,
                    ahANUser.Id,
                    tmANEmpId
             );
            tmANUser.Current_Opportunity_Approval__c = ahANUser.Id;
            tmANUser.Job_Code__c = 'AN3A';
            tmANUser.AH_RC_Code__c = ahANRCCode;
            tmANUser.NH_RC_Code__c = nhANRCCode;
            tmANUser.RC_Code__c = tmANRCCode;
            tmANUser.Status__c = 'A';
            tmANUser.Segment__c = teamSegment;
            insert tmANUser;            

            User rmANUser = Mockup_Test.newUser(
                    rmANUserFirstName,
                    tmANUserLastName,
                    true,
                    rmANUserFirstName+'@mail.com',
                    rmANUserFirstName+'@mail.com',
                    rmANUserFirstName.substring(0, 4),
                    rmANProfile.Id,
                    anRole.Id,
                    tmANUser.Id,
                    rmANEmpId
             );
            rmANUser.Current_Opportunity_Approval__c = ahANUser.Id;
            rmANUser.Job_Code__c = 'AN4A';
            rmANUser.AH_RC_Code__c = ahANRCCode;
            rmANUser.NH_RC_Code__c = nhANRCCode;
            rmANUser.RC_Code__c = tmANRCCode;
            rmANUser.Status__c = 'A';
            rmANUser.Segment__c = teamSegment;

            insert rmANUser;
        }

    }
 
    @isTest static void testSearchData_PositiveData_Mobile() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE+'001O000000kfDTl1';
        tController.id = '001O000000kfDTl';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        Test.startTest();
            tController.searchDataSyncronous();
        Test.stopTest();
    }

    @isTest static void testSearchData_PositiveData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE+'001O000000kfDTl1';
        tController.id = '001O000000kfDTl';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        Test.startTest();
        tController.searchData();
        Test.stopTest();
        String sortExp = tController.getSortDirection();
        System.assertEquals('ASC',sortExp);
        tController.setSortDirection('DESC');
        sortExp = tController.getSortDirection();
        System.assertEquals('DESC',sortExp);
    }
    @isTest static void testSortData_PositiveData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        List<String> searchResultList = new List<String>();
        searchResultList.add('5137447');
        searchResultList.add('5137448');


        List<String> expectedResultList = new List<String>();
        expectedResultList.add('5137448');
        expectedResultList.add('5137447');


        tController.firstname = 'ENGLISH';
        tController.lastname = SORT_TYPE;
        tController.sortDirection = 'DESC';
        tController.displayedCisList = searchResultList;
        Test.startTest();
            List<CustomerSearch_Controller.Customer> customerListResult = tController.sortBackendData(tController.sortDirection);
        Test.stopTest();
        System.assertEquals(2,customerListResult.size());

        verifyCISList(expectedResultList,tController.displayedCisList);

    }


    @isTest static void testSearchData_ByNamePositiveData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'SEARCH_POSITIVE+testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        Test.startTest();
        tController.searchData();
        Test.stopTest();
    }

    private static void verifyCISList(List<String> expectedCISList,List<String> actualCISList){
        for(Integer i=0; i<expectedCISList.size(); i++) {
            String expectedValue = expectedCISList.get(i);
            String actualValue = actualCISList.get(i);
            System.assertEquals(expectedValue,actualValue);
        }
    }


    @isTest static void testSearchData_SomeInvalidCIS() {
     
    }

    @isTest static void testSearchData_ErrorFromCIWebservice() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_STATUS_500;
        tController.lastname = 'testLastName';
        Test.startTest();

        tController.searchData();

        Test.stopTest();

        System.assertEquals(0,tController.displayedCisList.size());
    }

    @isTest static void testSortData_PositiveDataFromCIWebservice() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE;
        tController.id = '5137447';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.sortDirection = 'ASC';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;

        List<String> expectedCisList = new List<String>();
        expectedCisList.add('5137447');
        expectedCisList.add('5137448');

        Test.startTest();
       
        Account acc = new Account(name='accname');
        acc.CIS__c = '5137447';
        acc.Encrypt_Identification_No__c = '1111111111';
        acc.RecordTypeId = RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        acc.Temporary_Customer__c = true;
        insert acc;

        tController.sortData();
        Test.stopTest();

        System.assertEquals(expectedCISList.size(),tController.displayedCisList.size());
        verifyCISList(expectedCISList,tController.displayedCisList);

    }
    @isTest static void testSortData_ErrorFromCIWebservice() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE;
        tController.id = '00001';
        tController.firstname = 'ตอง';
        tController.lastname = 'ตอง';
        tController.sortDirection = 'ASC';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;

        List<String> expectedCisList = new List<String>();
        expectedCisList.add('5137447');
        expectedCisList.add('5137448');

        // execute httpcallout
        Test.startTest();
       
        Account acc = new Account();
        tController.sortData();
        Test.stopTest();

        verifyCISList(expectedCISList,tController.displayedCisList);

    }
    @isTest static void testGetSearchModel_AllRequstFieldsAreNull() {
        CustomerSearchRequestModel expectedModel = new CustomerSearchRequestModel();
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(True,actualModel.requestMap.isEmpty());

    }

    @isTest static void testGetSearchModel_Priority_InputAllFields_ExpectedCISOnly() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.cis = '4444';
        tController.id = '55555';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(True,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
    }


    @isTest static void testGetSearchModel_Priority_InputTHNameFields_ExpectedTHName() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'หหหหหห';
        tController.lastname = 'กกกกกก';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(True,actualModel.requestMap.containsKey(FIRSTNAME_TH));
        System.assertEquals(True,actualModel.requestMap.containsKey(SURNAME_TH));
    }



    @isTest static void testGetSearchModel_Priority_InputIDENT_NAME_Fields_ExpectedIDENTOnly() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.id = '4444';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(True,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
    }
    @isTest static void testGetSearchModel_Priority_InputFirstLast_ExpectedFirstLast() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(True,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(True,actualModel.requestMap.containsKey(SURNAME_EN));
        System.debug('actualModel'+actualModel);
    }

    @isTest static void testGetSearchModel_Validation_InputFirstName_ExpectedMinCharError() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'j';
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
        System.assertEquals(True,ApexPages.hasMessages(ApexPages.Severity.INFO));

        System.debug('actualModel'+actualModel);
    }

    @isTest static void testGetSortModel_Name_ASC() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.searchData();
        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('ASC', actualModel.requestMap.get(SORT_TYPE));

    }


    @isTest static void testGetSortModel_Name_DESC() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
    }


  
    @isTest static void testGetSortModel_InputOnlyLastname_NameTH() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
        System.assertEquals(FIRSTNAME_TH, actualModel.requestMap.get(SORT_COLUMN));
    }

    @isTest static void testGetSortModel_InputOnlyThaiFirstName_NameTH() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'กกกกกก';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
        System.assertEquals(FIRSTNAME_TH, actualModel.requestMap.get(SORT_COLUMN));
    }


    @isTest static void testIsEnglishAlphabet_AllEn() {
        String name = 'ABC445';
        Boolean expectedResult = True;
        Boolean actual = testController.isEnglishAlphabet(name);
        System.assertEquals(expectedResult,actual);
    }


    @isTest static void testIsEnglishAlphabet_AllTh() {
        String name = 'กกกกกกก';
        Boolean expectedResult = False;
        Boolean actual = testController.isEnglishAlphabet(name);
        System.assertEquals(expectedResult,actual);
    }

    @isTest static void testIsEnglishAlphabet_MixThEn() {
        String name = 'sกกกกกกกs';
        Boolean expectedResult = False;
        Boolean actual = testController.isEnglishAlphabet(name);
        System.assertEquals(expectedResult,actual);
    }

    @isTest static void testIsEnglishAlphabet_MixEn_Dash() {
        String name = 'ABC-445';
        Boolean expectedResult = True;
        Boolean actual = testController.isEnglishAlphabet(name);
        System.assertEquals(expectedResult,actual);
     
    }

    @isTest static void testIsEnglishAlphabet_MixTh_Dash() {
        String name = 'แซ่-ตั้ง';
        Boolean expectedResult = False;
        Boolean actual = testController.isEnglishAlphabet(name);
        System.assertEquals(expectedResult,actual);
    }

    @isTest static void testGetCustomerListByCISList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();

        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        cisList.add('5137449');
        Test.startTest();
        Account acc = new Account(name='accname');
        acc.CIS__c = '5137447';
        acc.Encrypt_Identification_No__c = '1111111111';
        acc.RecordTypeId = RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        acc.Temporary_Customer__c = true;
        insert acc;

        acc = new Account(name='accname2');
        acc.CIS__c = '5137448';
        acc.Encrypt_Identification_No__c = '1111111111';
        acc.RecordTypeId = RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        acc.Temporary_Customer__c = true;
        insert acc;

        tController.getCustomerListByCISList(cisList);
        Test.stopTest();
        System.assertEquals(cisList.size(),tController.displayedCisList.size());
    }
    @isTest static void testQueryProspect() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';


        List<String> cisList = new List<String>();
        cisList.add('111');
        cisList.add('222');

        Test.startTest();
        Account acc = new Account(name='prospect1');
        acc.CIS__c = '1111';
        acc.Encrypt_Identification_No__c = '1111111111';
        acc.RecordTypeId = RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        acc.Temporary_Customer__c = true;
        insert acc;

        acc = new Account(name='prospect2');
        acc.CIS__c = '2222';
        acc.Encrypt_Identification_No__c = '1111111111';
        acc.RecordTypeId = RecordTypeAccount.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        acc.Temporary_Customer__c = true;
        insert acc;

        List<CustomerSearch_Controller.Customer> result = tController.sortProspectData('ASC');

        Test.stopTest();
    }

    @isTest static void testSortProspect() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = '';
        tController.id = '111111';
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        tController.prospect_id = '111111';
        tController.prospect_firstname = 'prospect1';
        tController.prospect_lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        Test.startTest();
        List<CustomerSearch_Controller.Customer> result = tController.sortProspectData(tController.sortDirection);

        Test.stopTest();
        System.assertEquals(0,result.size());
    }

    @isTest static void testSearchProspect() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = '';
        tController.id = '111111';
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        tController.prospect_id = '111111';
        tController.prospect_firstname = 'prospect1';
        tController.prospect_lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        Test.startTest();
        tController.queryProspectFromSFDC();
        Test.stopTest();
        System.assertEquals(0,tController.customerList.size());
    }


    @isTest static void testGetSearchModel_Priority_HasInvalidLastName() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.lastname = '    l';
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
    }

    /*--------------------*/
    private static void setupUserForTestRequest(){
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<User> listUser = new List<User>();
            new Mockup_Test().setUpTestWithRCCode();
            String rmRoleDevname = 'RCRM' + Mockup_Test.RC_CODE;
            UserRole smeRmRole = [SELECT Id FROM UserRole WHERE DeveloperName = :rmRoleDevname LIMIT 1];
            User rbsUser = Mockup_Test.newUser(
                Mockup_Test.userRbsFirstNameRM,
                Mockup_Test.userRbsLastNameRM,
                true,
                Mockup_Test.userRbsFirstNameRM +'@mail.com',
                Mockup_Test.userRbsFirstNameRM +'@mail.com',
                Mockup_Test.userRbsFirstNameRM.substring(0, 4),
                Mockup_Test.mapProfileByName.get(GlobalConstants.SME_RM).Id,
                smeRmRole.Id,
                null,
                null
            );
            rbsUser.One_Team__c = true;
            rbsUser.RBS_User__c = true;
            rbsUser.Segment__c = 'ME';
            listUser.add(rbsUser);

            User rbsUser2 = Mockup_Test.newUser(
                Mockup_Test.userRbsFirstNameRM2,
                Mockup_Test.userRbsLastNameRM2,
                true,
                Mockup_Test.userRbsFirstNameRM2 +'@mail.com',
                Mockup_Test.userRbsFirstNameRM2 +'@mail.com',
                Mockup_Test.userRbsFirstNameRM2.substring(0, 4),
                Mockup_Test.mapProfileByName.get(GlobalConstants.SME_RM).Id,
                smeRmRole.Id,
                null,
                null
            );
            rbsUser2.One_Team__c = true;
            rbsUser2.RBS_User__c = true;
            rbsUser2.Segment__c = 'ME';
            listUser.add(rbsUser2);

            User rmCBSUser2 = Mockup_Test.newUser(
                Mockup_Test.userCBSFirstNameRM2,
                Mockup_Test.userCBSLastNameRM2,
                true,
                'FirstNameRm2CBS@mail.com',
                'FirstNameRm2CBS@mail.com',
                'rmCBSU',
                Mockup_Test.mapProfileByName.get(GlobalConstants.CBS_RM).Id,
                null,
                null,
                null
            );
            rmCBSUser2.Segment__c = 'CB';
            listUser.add(rmCBSUser2);

            insert listUser;

            TriggerHandler.bypass('UserTriggerHandler');
            User smeRmUser = [SELECT Id,Segment__c FROM USER WHERE FirstName =:Mockup_Test.userFirstNameRM LIMIT 1];
            smeRmUser.Segment__c = 'ME';
            update smeRmUser;

            User cbsRmUser = [SELECT Id,Segment__c FROM USER WHERE FirstName =:Mockup_Test.userFirstNameCBRM LIMIT 1];
            cbsRmUser.Segment__c = 'CB';
            update cbsRmUser;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }

    @isTest static void testSearchCustomerOnSalesforceOnly() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        newAccount1.cis__c  = '12233';
        insert newAccount1;

        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        /*tController.firstname = 'SEARCH_POSITIVE+testFirst';
        tController.lastname = 'testLastName';*/
        tController.id = '';
        tController.cis = '12233';

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = newAccount1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        tController.searchData();
        Test.stopTest();
        System.assertEquals(1,tController.totalRecords);
        System.assertEquals('12233',tController.finalCustomerList[0].accountObj.cis__c);
        System.assertEquals('newAccount1',tController.finalCustomerList[0].accountObj.name);
    }
}