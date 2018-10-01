@isTest
private class Opportunity_Custom_Test {
    public static Account testAccount;
    public static Call_Report__c testCallReport;
    public static Opportunity existingOpp;
    public static Opportunity_Planning__c testOppPlan;
    public static Opportunity_Planning_Line_Item__c testOppPlanningLineItem;
    
    @isTest static void test_Constructor(){
        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
        }
    }
    @isTest static void test_checkBeforeFilter(){
        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            controller.checkBeforeFilter();
        }
    }
    @isTest static void test_Next_Prev(){
        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            controller.checkBeforeNext();
            //controller.Next();
            controller.checkBeforePrev();
            //controller.Prev();
        }
    }
    @isTest static void test_Save(){

        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

        Opportunity_Custom_Controller.OppPlanningWrapper oppPlanWrapper = new Opportunity_Custom_Controller.OppPlanningWrapper();
        List<Opportunity_Custom_Controller.OppPlanningWrapper> oppWrapperList = new List<Opportunity_Custom_Controller.OppPlanningWrapper> ();
        oppWrapperList = controller.oppPlanningWrapperList;
        for(Opportunity_Custom_Controller.OppPlanningWrapper eachOppWrapper : oppWrapperList){
            eachOppWrapper.newOppPlanning.Status__c = 'Pitching';
        }
        controller.saveAll();
    }

    @isTest static void test_Edit_Cancel(){

        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
        controller.editAll();
        controller.cancel();
    }
    @isTest static void test_checkWin(){
        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            controller.checkWin();
        }
    }
    @isTest static void test_getStatusItem(){
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
        List<SelectOption> getOptionItem = new List<SelectOption>();
        getOptionItem = controller.getStatusItems();
    }
    @isTest static void test_changeStatusFilter(){
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

        controller.selectedStatus = 'All';
        controller.doStatusGroup();
        controller.selectedStatus = 'Inactive';
        controller.doStatusGroup();
    }

    @isTest static void test_changeStatusFilterToAll(){
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

        controller.selectedStatus = 'Inactive';
        controller.doStatusGroup();
        controller.selectedStatus = 'All';
        controller.doStatusGroup();
    }

    @isTest static void testChangeAddToExistingThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            //change Add_to_Existing_Opportunity__c
            controller.oppPlanningWrapperList[0].newOppPlanning.Add_to_Existing_Opportunity__c = null;
            controller.oppPlanningWrapperList[0].oldOppPlanning.Add_to_Existing_Opportunity__c = existingOpp.Id;
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }
    }

    @isTest static void testChangeRemarkThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            
            //change Remark__c
            controller.oppPlanningWrapperList[0].newOppPlanning.Remark__c = null;
            controller.oppPlanningWrapperList[0].oldOppPlanning.Remark__c = 'Remark__c';
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }
    }

    @isTest static void testChangeNewLimitThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            
            //change New_Limit__c
            controller.oppPlanningWrapperList[0].newOppPlanning.New_Limit__c = 0;
            controller.oppPlanningWrapperList[0].oldOppPlanning.New_Limit__c = 1;
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }
    }

    @isTest static void testChangeVolOutThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

            //change Volume_Outstanding__c
            controller.oppPlanningWrapperList[0].newOppPlanning.Volume_Outstanding__c = 2;
            controller.oppPlanningWrapperList[0].oldOppPlanning.Volume_Outstanding__c = 3;
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }   
    }

    @isTest static void testChangeFrontendFeeThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

            //change Front_End_Fee__c
            controller.oppPlanningWrapperList[0].newOppPlanning.Front_End_Fee__c = 4;
            controller.oppPlanningWrapperList[0].oldOppPlanning.Front_End_Fee__c = 5;
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }
    }

    @isTest static void testChangeFeeThenMethodCheckChamgeReturnTrue(){
        Boolean expectedResult = true;
        Boolean result = false;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

            //change Fee__c
            controller.oppPlanningWrapperList[0].newOppPlanning.Fee__c = 6;
            controller.oppPlanningWrapperList[0].oldOppPlanning.Fee__c = 7;
            result = controller.checkChange(controller.oppPlanningWrapperList[0]);
            System.assertEquals(expectedResult,result);
        }
    }

    @isTest static void testCancelChangeThenChangeFlagToFalse(){
        Boolean expectedResult = false;
        Boolean result;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initiateTestObject();

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();

            controller.hasChangeBeforePrev = true;
            controller.hasChangeBeforeNext = true;
            controller.hasChangeBeforeGo = true;
            controller.cancelChange();
            System.assertEquals(expectedResult,controller.hasChangeBeforePrev);
            System.assertEquals(expectedResult,controller.hasChangeBeforeNext);
            System.assertEquals(expectedResult,controller.hasChangeBeforeGo);
        }
    }

    @isTest static void testValidateWithProductListMasterIfAllFieldActiveAndAllFieldRequiredButNotInputValueThenReturnFalseAndHasErrorMsg(){
        String expectedResult = ExceptionMessage.THIS_FIELD_IS_REQUIRED;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initFilterView();
            initAccount();
            initExistingOpp();
            initCallRep();
            initOppPlanCustomSetting();
            Opportunity_Planning__c oppPlan = createTestOppPlanning();
            oppPlan.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
            insert oppPlan;


            Product_List_Master__c productListMaster = new Product_List_Master__c(
                Product_Group__c = 'Product_Group__c',
                Is_Active__c = true,
                Is_Active_New_Limit__c = true,
                Is_Active_Volume_Outstanding__c = true,
                Is_Active_Front_End_Fee__c = true,
                Is_Active_Fee__c = true,
                Is_Required_New_Limit__c = true,
                Is_Required_Volume_Outstanding__c = true,
                Is_Required_Front_End_Fee__c = true,
                Is_Required_Fee__c = true
            );
            insert productListMaster;

            Opportunity_Planning_Line_Item__c oppPlanLineItem = createTestOppPlanningLineItem(oppPlan,productListMaster);
            insert oppPlanLineItem;

            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            Boolean reuslt = controller.validateWithProductListMaster(controller.oppPlanningWrapperList[0]);

            System.assertEquals(false,reuslt);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgNewLimit);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgVolOut);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFronEndFee);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFee);
        }
    }

    @isTest static void testValidateWithProductListMasterIfAllFieldActiveAndAllFieldCannotBe0ButInputValue0ThenReturnFalseAndHasErrorMsg(){
        String expectedResult = ExceptionMessage.ZERO_IS_NOT_ALLOWED;

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initFilterView();
            initAccount();
            initExistingOpp();
            initCallRep();
            initOppPlanCustomSetting();

            Opportunity_Planning__c oppPlan = createTestOppPlanningWithType(GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING);
            oppPlan.New_Limit__c = 0;
            oppPlan.Volume_Outstanding__c = 0;
            oppPlan.Front_End_Fee__c = 0;
            oppPlan.Fee__c = 0;
            insert oppPlan;

            Product_List_Master__c productListMaster = new Product_List_Master__c(
                Product_Group__c = 'Product_Group__c',
                Is_Active__c = true,
                Is_Active_New_Limit__c = true,
                Is_Active_Volume_Outstanding__c = true,
                Is_Active_Front_End_Fee__c = true,
                Is_Active_Fee__c = true,
                Is_not_Allow_0_New_Limit__c = true,
                Is_not_Allow_0_Volume_Outstanding__c = true,
                Is_not_Allow_0_Front_End_Fee__c = true,
                Is_not_Allow_0_Fee__c = true
            );
            insert productListMaster;

            Opportunity_Planning_Line_Item__c oppPlanLineItem = createTestOppPlanningLineItem(oppPlan,productListMaster);
            insert oppPlanLineItem;
            
            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            Boolean reuslt = controller.validateWithProductListMaster(controller.oppPlanningWrapperList[0]);

            System.assertEquals(false,reuslt);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgNewLimit);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgVolOut);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFronEndFee);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFee);
        }
    }

    @isTest static void testValidateWithProductListMasterIfAllFieldActiveAndAllFieldRequireAndAllFieldCannotBe0AndInputValueMoreThan0ThenReturnTrueAndErrorMsgIsSpace(){
        String expectedResult = '&nbsp;';

        User cbsAdminUser = new User();
        cbsAdminUser = createUser();
        System.runAs(cbsAdminUser){
            initFilterView();
            initAccount();
            initExistingOpp();
            initCallRep();
            initOppPlanCustomSetting();

            Opportunity_Planning__c oppPlan = createTestOppPlanningWithType(GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING);
            oppPlan.New_Limit__c = 0;
            oppPlan.New_Limit__c = 1;
            oppPlan.Volume_Outstanding__c = 2;
            oppPlan.Front_End_Fee__c = 3;
            oppPlan.Fee__c = 4;
            insert oppPlan;

            Product_List_Master__c productListMaster = new Product_List_Master__c(
                Product_Group__c = 'Product_Group__c',
                Is_Active__c = true,
                Is_Active_New_Limit__c = true,
                Is_Active_Volume_Outstanding__c = true,
                Is_Active_Front_End_Fee__c = true,
                Is_Active_Fee__c = true,
                Is_not_Allow_0_New_Limit__c = true,
                Is_not_Allow_0_Volume_Outstanding__c = true,
                Is_not_Allow_0_Front_End_Fee__c = true,
                Is_not_Allow_0_Fee__c = true,
                Is_Required_New_Limit__c = true,
                Is_Required_Volume_Outstanding__c = true,
                Is_Required_Front_End_Fee__c = true,
                Is_Required_Fee__c = true
            );
            insert productListMaster;

            Opportunity_Planning_Line_Item__c oppPlanLineItem = createTestOppPlanningLineItem(oppPlan,productListMaster);
            insert oppPlanLineItem;
            
            PageReference pageRef = Page.Opportunity_Custom_page;
            Test.setCurrentPage(pageRef);

            Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
            Boolean reuslt = controller.validateWithProductListMaster(controller.oppPlanningWrapperList[0]);

            System.assertEquals(true,reuslt);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgNewLimit);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgVolOut);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFronEndFee);
            System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].errorMsgFee);
        }
    }

    @isTest static void testMethodCheckWinIfSelectedRecordStatusWinMandateAndProductTypeCreditThenFlagIsTrue(){
        Boolean expectedResult = true;
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
        apexpages.currentpage().getParameters().put('clickedId',controller.oppPlanningWrapperList[0].oldOppPlanning.Id);
        controller.oppPlanningWrapperList[0].newOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
        controller.oppPlanningWrapperList[0].newOppPlanning.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;

        controller.checkWin();
        System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].isWin);
    }

    @isTest static void testMethodcheckifOppTypeNewBookingThenAllowOppPlanAddToExisingOppty(){
        Boolean expectedResult = true;
        initFilterView();
        initAccount();
        initCallRep();
        initOppPlanCustomSetting();

            Opportunity_Planning__c oppPlan = createTestOppPlanningWithType(GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING);
            oppPlan.New_Limit__c = 0;
            oppPlan.Volume_Outstanding__c = 0;
            oppPlan.Front_End_Fee__c = 0;
            oppPlan.Fee__c = 0;
            insert oppPlan;

            Product_List_Master__c productListMaster = new Product_List_Master__c(
                Product_Group__c = 'Product_Group__c',
                Is_Active__c = true,
                Is_Active_New_Limit__c = true,
                Is_Active_Volume_Outstanding__c = true,
                Is_Active_Front_End_Fee__c = true,
                Is_Active_Fee__c = true,
                Is_not_Allow_0_New_Limit__c = true,
                Is_not_Allow_0_Volume_Outstanding__c = true,
                Is_not_Allow_0_Front_End_Fee__c = true,
                Is_not_Allow_0_Fee__c = true
            );
            insert productListMaster;

            Opportunity_Planning_Line_Item__c oppPlanLineItem = createTestOppPlanningLineItem(oppPlan,productListMaster);
            insert oppPlanLineItem;

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();
        apexpages.currentpage().getParameters().put('clickedId',controller.oppPlanningWrapperList[0].oldOppPlanning.Id);
        System.assertEquals(expectedResult,controller.oppPlanningWrapperList[0].allowAddtoExistingOpp);
    }

    @isTest static void testGroup2OpplanningThenGroupSizeEqual1AndAllGroupedOpplanEqual2(){
        Integer expectedResult = 1;
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();      
        controller.oppPlanningWrapperList[0].isChecked = true;
        controller.oppPlanningWrapperList[0].isGrouped = false;
        controller.oppPlanningWrapperList[0].allowEditAmont = true; 
        controller.oppPlanningWrapperList[0].newOppPlanning.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
        controller.oppPlanningWrapperList[1].isChecked = true;
        controller.oppPlanningWrapperList[1].isGrouped = false;
        controller.oppPlanningWrapperList[1].allowEditAmont = true;    
        controller.oppPlanningWrapperList[1].newOppPlanning.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;

        controller.groupOppPlanning();
        System.assertEquals(expectedResult,controller.groupSize);
        System.assertEquals(2,controller.mapAllGroupedOppPlanning.values().size());
    }

    @isTest static void testUnGroupAllOpplanningThenGroupSizeEqual0AndAllGroupedOpplanEqual0AndFlagIsGroupedFalseAndFlagIsCheckedFalse(){
        initiateTestObject();

        PageReference pageRef = Page.Opportunity_Custom_page;
        Test.setCurrentPage(pageRef);

        Opportunity_Custom_Controller controller = new Opportunity_Custom_Controller();        
        controller.oppPlanningWrapperList[0].isChecked = true;
        controller.oppPlanningWrapperList[0].isGrouped = false;
        controller.oppPlanningWrapperList[0].allowEditAmont = true; 
        controller.oppPlanningWrapperList[0].newOppPlanning.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
        controller.oppPlanningWrapperList[1].isChecked = true;
        controller.oppPlanningWrapperList[1].isGrouped = false;
        controller.oppPlanningWrapperList[1].allowEditAmont = true;  
        controller.oppPlanningWrapperList[1].newOppPlanning.Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;

        controller.groupOppPlanning();
        System.assertEquals(1,controller.groupSize);
        System.assertEquals(2,controller.mapAllGroupedOppPlanning.values().size());
        System.assertEquals(true,controller.oppPlanningWrapperList[0].isGrouped);
        System.assertEquals(true,controller.oppPlanningWrapperList[1].isGrouped);

        controller.unGroupAllOppPlanning();

        System.assertEquals(0,controller.groupSize);
        System.assertEquals(0,controller.mapAllGroupedOppPlanning.values().size());
        System.assertEquals(false,controller.oppPlanningWrapperList[0].isGrouped);
        System.assertEquals(false,controller.oppPlanningWrapperList[1].isGrouped);        
        System.assertEquals(false,controller.oppPlanningWrapperList[0].isChecked);
        System.assertEquals(false,controller.oppPlanningWrapperList[1].isChecked);
    }

    public static void initFilterView(){
        CBS_OppPlanning_Filter_View__c cbsAdminFilter = new CBS_OppPlanning_Filter_View__c();
        cbsAdminFilter.All_Owner__c = true;
        cbsAdminFilter.All_Product__c = true;
        cbsAdminFilter.All_Stage__c = true;
        cbsAdminFilter.All_Status__c = true;
        cbsAdminFilter.All_Team__c = true;
        cbsAdminFilter.All_Product_Group__c = true;
        insert cbsAdminFilter;
    }

    public static void initAccount(){
        testAccount = createTestAccount();
        insert testAccount;
    }

    public static void initExistingOpp(){
        existingOpp = Mockup_Test.newOpportunity(testAccount.Id, testAccount.Name, GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.CMAS);
        insert existingOpp;
    }

    public static void initCallRep(){
        testCallReport = createTestCallReport();
        insert testCallReport;
    }

    public static void initOppPlanCustomSetting(){
        List<Opportunity_Planning_Type__c> oppPlanCSList = new List<Opportunity_Planning_Type__c>();
        Opportunity_Planning_Type__c oppPlanCS = Mockup_Test.newOpplanningCustomSetting('New Booking',GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,true,true,GlobalConstants.NEW_CREDIT,'New_Limit__c','Credit');
        Opportunity_Planning_Type__c oppPlanCS2 = Mockup_Test.newOpplanningCustomSetting('Non-Credit',GlobalConstants.OPP_PLAN_NON_CREDIT,false,false,null,'New_Limit__c','Non-Credit');
        oppPlanCSList.add(oppPlanCS);
        oppPlanCSList.add(oppPlanCS2);
        insert oppPlanCSList;
    }

    public static List<Opportunity_Planning__c> initOppPlanning(){
        Integer i = 0;
        List<Opportunity_Planning__c> oppPlanList = new List<Opportunity_Planning__c>();
        for(i=0; i<20; i++){
            testOppPlan = new Opportunity_Planning__c();
            testOppPlan = createTestOppPlanning();
            oppPlanList.add(testOppPlan);
        }
        insert oppPlanList;
        return oppPlanList;
    }

    public static void initiateTestObject(){
        initFilterView();
        initAccount();
        initExistingOpp();
        initCallRep();
        initOppPlanCustomSetting();
        List<Opportunity_Planning__c> oppPlanList = initOppPlanning();

        Product_List_Master__c productListMaster = new Product_List_Master__c();
        productListMaster.Product_Group__c = 'Product_Group__c';        
        insert productListMaster;

        List<Opportunity_Planning_Line_Item__c> oppPlanLineItemList = new List<Opportunity_Planning_Line_Item__c>();
        for(Opportunity_Planning__c eachOppPlan : oppPlanList){
            oppPlanLineItemList.add(createTestOppPlanningLineItem(eachOppPlan,productListMaster));
        }
        insert oppPlanLineItemList;

    }
    public static Account createTestAccount(){
        Account account = Mockup_Test.newAccountObj('Testname',GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        return account;
    }
    public static Call_Report__c createTestCallReport(){
        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = testAccount.Id;
        return callReport;
    }
    public static Opportunity_Planning__c createTestOppPlanning(){
        Opportunity_Planning__c oppPlan = new Opportunity_Planning__c();
        oppPlan.CIS_ID__c = testAccount.Id;
        oppPlan.Call_Report_CBS__c = testCallReport.Name;
        return oppPlan;
    }

    public static Opportunity_Planning__c createTestOppPlanningWithType(String oppPlanType){
        Opportunity_Planning__c oppPlan = new Opportunity_Planning__c();
        oppPlan.CIS_ID__c = testAccount.Id;
        oppPlan.Call_Report_CBS__c = testCallReport.Name;
        oppPlan.Product_Type__c = oppPlanType;
        return oppPlan;
    }
    public static Opportunity_Planning_Line_Item__c createTestOppPlanningLineItem(Opportunity_Planning__c eachOppPlan,Product_List_Master__c masterConfig){
        Opportunity_Planning_Line_Item__c oppLineItem = new Opportunity_Planning_Line_Item__c();
        oppLineItem.Opportunity_Planning__c = eachOppPlan.Id;
        oppLineItem.Product_Name__c = 'Product_Name_A';
        oppLineItem.Call_Report_Product_List_Master__c = masterConfig.Id;
        return oppLineItem;
    }
    public static User createUser(){
        String cbsProfile = GlobalConstants.CBS_ADMIN;
        Profile p = [SELECT Id FROM Profile WHERE Name=:cbsProfile]; 
        User u = new User(Alias = 'cbsAdmin', Email='cbsadmin@kasikornbank.com', 
        EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Asia/Bangkok', UserName='cbsadmin@kasikornbank.com');
        return u; 
    }
    
}