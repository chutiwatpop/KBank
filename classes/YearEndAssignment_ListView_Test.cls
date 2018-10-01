/**
* @author komsan.wi@beryl8.com
* @05/10/2015 createddate
*/
@isTest
private class YearEndAssignment_ListView_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String contactNameTM = 'tmCreatedContactName';
    public static String contactNameRM = 'rmCreatedContactName';
    public static String contactNameAH = 'ahCreatedContactName';

    public static String lastNameTM = 'tmCreatedLastName';
    public static String lastNameRM = 'rmCreatedLastName';
    public static String lastNameAH = 'ahCreatedLastName';

    public static String yearEndCISNo1 = '9999999999';
    public static String yearEndCISNo2 = '9999999998';
    public static String yearEndCISNo3 = '9999999997';

    @testSetup static void setupUser(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        Integer pagesize = 150;
        List<Account> accountList = new List<Account>();
        Account account1 = new Account(
            Name = YearEndAssignment_ListView_Test.yearEndCISNo1,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            Primary_Segment_Code__c = 'SM',
            CIS__c = yearEndCISNo1,
            Is_createby_Integration__c = true
        );
        Account account2 = new Account(
            Name = YearEndAssignment_ListView_Test.yearEndCISNo2,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            Primary_Segment_Code__c = 'SM',
            CIS__c = yearEndCISNo2,
            Is_createby_Integration__c = true
        );
        Account account3 = new Account(
            Name = YearEndAssignment_ListView_Test.yearEndCISNo3,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            Primary_Segment_Code__c = 'CB',
            CIS__c = yearEndCISNo3,
            Is_createby_Integration__c = true
        );
        accountList.add(account1);
        accountList.add(account2);
        accountList.add(account3);
        insert accountList;

        List<Year_End_Assignment__c> yearEndlist = new List<Year_End_Assignment__c>();
        Year_End_Assignment__c yearObj = Mockup_Test.newYearEndAssignment(yearEndCISNo1,Mockup_Test.userFirstNameRM,Mockup_Test.AH_RC_CODE);
        Year_End_Assignment__c yearObj2 = Mockup_Test.newYearEndAssignment(yearEndCISNo2,Mockup_Test.userFirstNameRM,Mockup_Test.AH_RC_CODE);
        Year_End_Assignment__c yearObj3 = Mockup_Test.newYearEndAssignment(yearEndCISNo3,Mockup_Test.userFirstNameCBRM,Mockup_Test.TL_CB_RC_CODE);
        yearEndlist.add(yearObj);
        yearEndlist.add(yearObj2);
        yearEndlist.add(yearObj3);
        insert yearEndlist;
        
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userRMCBS = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        User userTLCBS = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
        Team_Structure__c tmTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.RC_CODE LIMIT 1];
        Team_Structure__c ahTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.AH_RC_CODE LIMIT 1];
        Team_Structure__c tlTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c=:Mockup_Test.TL_CB_RC_CODE LIMIT 1];

        List<Year_End_Sales_Structure__c> yearSaleStruclist = new List<Year_End_Sales_Structure__c>();
        Year_End_Sales_Structure__c  ahSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdAH,RC_Code__c=Mockup_Test.AH_RC_CODE,Role__c='AH',Segment__c='ME',Submitted_Flag__c=false,Team__c=ahTeam.Id,User__c=userAH.Id);
        Year_End_Sales_Structure__c  tmSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdTM,RC_Code__c=Mockup_Test.RC_CODE,Role__c='TM',Segment__c='ME',Submitted_Flag__c=false,Team__c=tmTeam.Id,User__c=userTM.Id,AH_Name__c=ahSaleStruct.Id,Manager__c=ahSaleStruct.Id);
        Year_End_Sales_Structure__c  rmSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userEmpIdRM,RC_Code__c=Mockup_Test.RC_CODE,Role__c='RM',Segment__c='ME',Submitted_Flag__c=false,Team__c=tmTeam.Id,User__c=userRM.Id,AH_Name__c=ahSaleStruct.Id,Manager__c=tmSaleStruct.Id);
        Year_End_Sales_Structure__c  tlCBSSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userCBSEmpIdRM,RC_Code__c=Mockup_Test.TL_CB_RC_CODE,Role__c='TL',Segment__c='CB',Submitted_Flag__c=false,Team__c=tlTeam.Id,User__c=userTLCBS.Id);
        Year_End_Sales_Structure__c  rmCBSSaleStruct = new Year_End_Sales_Structure__c(Employee_Id__c=Mockup_Test.userCBSEmpIdTL,RC_Code__c=Mockup_Test.TL_CB_RC_CODE,Role__c='RM',Segment__c='CB',Submitted_Flag__c=false,Team__c=tlTeam.Id,User__c=userRMCBS.Id,AH_Name__c=tlCBSSaleStruct.Id,Manager__c=tlCBSSaleStruct.Id);
        
        yearSaleStruclist.add(ahSaleStruct);
        yearSaleStruclist.add(tmSaleStruct);
        yearSaleStruclist.add(rmSaleStruct);
        yearSaleStruclist.add(tlCBSSaleStruct);
        yearSaleStruclist.add(rmCBSSaleStruct);

        insert yearSaleStruclist;
        
        YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
        insert new Year_End_Config__c(
            Page_Size__c = pagesize
        );
        System.assertEquals(yearController.rows, pagesize);
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameAH,contactNameAH,lastNameAH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        Test.stopTest();
        
    }
    static testMethod void staticMethod(){
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            System.assertEquals(yearController.getSelectedResource(), yearController.staticPrefix + '_tm');
            System.assertNotEquals('', yearController.getSelectedCountFields());
            System.assertNotEquals('', yearController.getCustomerOwnerRequestFields());
            System.assertNotEquals('', yearController.getYearEndFields());
            System.assertNotEquals('', yearController.getYearEndSelFields());
            System.assertNotEquals('', yearController.getCustomerOwnerRequestFieldsForDes());
            System.assertNotEquals('', yearController.getYearEndFieldsForDes());
            System.assertNotEquals('', yearController.getYearEndSelFieldsForDes());
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController_rm = new YearEndAssignment_ListView_Controller();
            System.assertEquals(yearController_rm.getSelectedResource(), yearController_rm.staticPrefix + '_rm');
            System.assertNotEquals('', yearController_rm.getSelectedCountFields());
            System.assertNotEquals('', yearController_rm.getCustomerOwnerRequestFields());
            System.assertNotEquals('', yearController_rm.getYearEndFields());
            System.assertNotEquals('', yearController_rm.getYearEndSelFields());
            System.assertNotEquals('', yearController_rm.getCustomerOwnerRequestFieldsForDes());
            System.assertNotEquals('', yearController_rm.getYearEndFieldsForDes());
            System.assertNotEquals('', yearController_rm.getYearEndSelFieldsForDes());
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController_ah = new YearEndAssignment_ListView_Controller();
            System.assertEquals(yearController_ah.getSelectedResource(), yearController_ah.staticPrefix + '_ah');
            System.assertNotEquals('', yearController_ah.getSelectedCountFields());
            System.assertNotEquals('', yearController_ah.getCustomerOwnerRequestFields());
            System.assertNotEquals('', yearController_ah.getYearEndFields());
            System.assertNotEquals('', yearController_ah.getYearEndSelFields());
            System.assertNotEquals('', yearController_ah.getCustomerOwnerRequestFieldsForDes());
            System.assertNotEquals('', yearController_ah.getYearEndFieldsForDes());
            System.assertNotEquals('', yearController_ah.getYearEndSelFieldsForDes());
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController_rmCBS = new YearEndAssignment_ListView_Controller();
            System.assertEquals(yearController_rmCBS.getSelectedResource(), yearController_rmCBS.staticPrefix + '_rm_cbs');
            System.assertNotEquals('', yearController_rmCBS.getSelectedCountFields());
            System.assertNotEquals('', yearController_rmCBS.getCustomerOwnerRequestFields());
            System.assertNotEquals('', yearController_rmCBS.getYearEndFields());
            System.assertNotEquals('', yearController_rmCBS.getYearEndSelFields());
            System.assertNotEquals('', yearController_rmCBS.getCustomerOwnerRequestFieldsForDes());
            System.assertNotEquals('', yearController_rmCBS.getYearEndFieldsForDes());
            System.assertNotEquals('', yearController_rmCBS.getYearEndSelFieldsForDes());
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController_tl = new YearEndAssignment_ListView_Controller();
            System.assertEquals(yearController_tl.getSelectedResource(), yearController_tl.staticPrefix + '_tl_cbs');
            System.assertNotEquals('', yearController_tl.getSelectedCountFields());
            System.assertNotEquals('', yearController_tl.getCustomerOwnerRequestFields());
            System.assertNotEquals('', yearController_tl.getYearEndFields());
            System.assertNotEquals('', yearController_tl.getYearEndSelFields());
            System.assertNotEquals('', yearController_tl.getCustomerOwnerRequestFieldsForDes());
            System.assertNotEquals('', yearController_tl.getYearEndFieldsForDes());
            System.assertNotEquals('', yearController_tl.getYearEndSelFieldsForDes());
        }
    }
    @isTest static void testPicklist(){
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            List<String> yearFieldList = new List<String>();
            String[] yearEndFieldArray = yearController.getYearEndFieldsForDes().split(',');
            for(Integer i =0,yearEndSize = yearEndFieldArray.size(); i < yearEndSize; ++i){
                yearFieldList.add(yearEndFieldArray[i]);
            }
            Map<String,String> resultMap = RemoterExtensions.describeMapFields('Year_End_Assignment__c', yearFieldList);
            System.assert(resultMap.size() > 0);

            ModelExtensions.QueryObj qo = new ModelExtensions.QueryObj();
            qo.sobjname = 'Year_End_Assignment__c';
            qo.fields = yearController.getYearEndFields();
            qo.filter = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id !','value'=>'null'}};
            qo.start = 0;
            qo.recordCount = 10;
            qo.sortParams = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id','direction'=>'ASC'}};

            ModelExtensions.CRUDResponse yearResults = RemoterExtensions.query(qo);
            System.assertEquals(true,yearResults.success);
            System.assertEquals(2,yearResults.records.size());
            System.assertEquals(2,yearResults.total);

            ModelExtensions.QueryPickListObj qpo = new ModelExtensions.QueryPickListObj();
            qpo.scope = 'Status__c';

            ModelExtensions.PicklistResponse picklistResults = YearEndAssignment_ListView_Controller.queryPicklist(qpo);

            System.assertEquals(true,picklistResults.success);
            System.assert(picklistResults.records.size()>0);
            System.assertEquals(null,picklistResults.total);

            ModelExtensions.QueryPickListObj qplo = new ModelExtensions.QueryPickListObj();
            qplo.scope = 'Province';

            ModelExtensions.PicklistResponse picklistLoResults = YearEndAssignment_ListView_Controller.queryLocation(qplo);
            System.assertEquals(true,picklistLoResults.success);
            System.assertEquals(0,picklistLoResults.records.size());
            System.assertEquals(null,picklistLoResults.total);

            ModelExtensions.QueryPickListObj qpoBy = new ModelExtensions.QueryPickListObj();
            qpoBy.scope = Mockup_Test.RC_CODE;

            ModelExtensions.PicklistResponse picklistByResults = YearEndAssignment_ListView_Controller.querySelectedBy(qpoBy);
            System.assertEquals(true,picklistByResults.success);
            System.assertNotEquals(0,picklistByResults.records.size());
            System.assertEquals(null,picklistByResults.total);

            ModelExtensions.QueryPickListObj qpoByRM = new ModelExtensions.QueryPickListObj();
            qpoByRM.scope = Mockup_Test.RC_CODE;

            ModelExtensions.PicklistResponse picklistByRMResults = YearEndAssignment_ListView_Controller.querySelectedByOnlyRM(qpoByRM);
            System.assertEquals(true,picklistByRMResults.success);
            System.assertNotEquals(0,picklistByRMResults.records.size());
            System.assertEquals(null,picklistByRMResults.total);


            ModelExtensions.PicklistResponse queryTeamMaster = YearEndAssignment_ListView_Controller.queryTeamMaster(qpo);
            //System.assertEquals(true,picklistLoResults.success);
            //System.assertEquals(0,picklistLoResults.records.size());
            //System.assertEquals(null,picklistLoResults.total);
            ModelExtensions.PicklistResponse picklistSelectedTeam = YearEndAssignment_ListView_Controller.querySelectedByTeam(qpo);
            ModelExtensions.PicklistResponse picklistSelectedAH = YearEndAssignment_ListView_Controller.querySelectedByAH(qpo);
            ModelExtensions.PicklistResponse picklistSelectedAHByOnlyRM = YearEndAssignment_ListView_Controller.queryAHSelectedByOnlyRM(qpo);
            ModelExtensions.PicklistResponse picklistSelectedSegment = YearEndAssignment_ListView_Controller.querySegment(qpo);

            ModelExtensions.PicklistResponse picklistSelectedReason = YearEndAssignment_ListView_Controller.queryReason(qpo);




        }    
    }
    
    @isTest static void testAsAH(){
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            Year_End_Sales_Structure__c userRM = [SELECT Id,RC_Code__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c,Manager__c,Segment__c,Role__c,Team__c FROM Year_End_Sales_Structure__c where Employee_Id__c=:Mockup_Test.userEmpIdRM LIMIT 1][0];
            List<Year_End_Assignment__c> yearQueryObjList = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE AH_RC_Code__c=:Mockup_Test.AH_RC_CODE ];
            List<String> selectedList = new List<String>();
            for(Year_End_Assignment__c eachYearend : yearQueryObjList){
                selectedList.add(String.valueof(eachYearend.Id));
            }

            //#1 try to submitted
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();           
            sr.contx = 'SELECTED';
            sr.selectName = new YearEndModel.SelectedName();
            sr.selectName.selectedbyNamepanel = userRM.Id;
            sr.yearlist = selectedList;

            ModelExtensions.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            //#2 Submmit all  
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED_AH';
            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success); //have Record No Select

            List<Year_End_Assignment__c> yearQueryObjResult = [SELECT Id,Status__c,Final_Assigned_RM__c,Final_Refer_Out__c FROM Year_End_Assignment__c WHERE Status__c=:GlobalConstants.SUBMITTED AND Final_Assigned_Next_Year__c !=NULL ];
            System.assertEquals(yearQueryObjResult.size(),yearQueryObjList.size());
        }
        Test.stopTest();
    }

    @isTest static void testAsTM(){
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            Year_End_Sales_Structure__c userRM = [SELECT Id,RC_Code__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c,Manager__c,Segment__c,Role__c,Team__c FROM Year_End_Sales_Structure__c where Employee_Id__c=:Mockup_Test.userEmpIdRM LIMIT 1][0];
            List<Year_End_Assignment__c> yearQueryObjList = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE AH_RC_Code__c=:Mockup_Test.AH_RC_CODE ];
            List<String> selectedList = new List<String>();
            for(Year_End_Assignment__c eachYearend : yearQueryObjList){
                selectedList.add(String.valueof(eachYearend.Id));
            }

            //#1 try to submitted
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();           
            sr.contx = 'SELECTED';
            sr.selectName = new YearEndModel.SelectedName();
            sr.selectName.selectedbyNamepanel = userRM.Id;
            sr.yearlist = selectedList;

            ModelExtensions.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            List<Year_End_Assignment_Selection__c> yearendselectetionList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Selected_By_Next_Year__c=:userRM.Id  AND Refer_Out__c=false];
            System.assertEquals(yearQueryObjList.size(),yearendselectetionList.size());
            //#2 Submmit all  
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED';
            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success); //have Record No Select
        }
    }

    @isTest static void testAsRM(){
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            Year_End_Sales_Structure__c userRM = [SELECT Id,RC_Code__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c,Manager__c,Segment__c,Role__c,Team__c FROM Year_End_Sales_Structure__c where Employee_Id__c=:Mockup_Test.userEmpIdRM LIMIT 1][0];
            List<Year_End_Assignment__c> yearQueryObjList = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE AH_RC_Code__c=:Mockup_Test.AH_RC_CODE ];
            List<String> selectedList = new List<String>();
            for(Year_End_Assignment__c eachYearend : yearQueryObjList){
                selectedList.add(String.valueof(eachYearend.Id));
            }

            //#1 try to submitted
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();           
            sr.contx = 'SELECTED';
            sr.selectName = new YearEndModel.SelectedName();
            sr.selectName.selectedbyNamepanel = userRM.Id;
            sr.yearlist = selectedList;

            ModelExtensions.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            List<Year_End_Assignment_Selection__c> yearendselectetionList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Selected_By_Next_Year__c=:userRM.Id  AND Refer_Out__c=false];
            System.assertEquals(yearQueryObjList.size(),yearendselectetionList.size());
            //#2 Submmit all  
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED';
            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success); //have Record No Select
        }
    }
    @isTest static void testAsRM_REFEROUT(){
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
            Year_End_Sales_Structure__c userRM = [SELECT Id,RC_Code__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c,Manager__c,Segment__c,Role__c,Team__c FROM Year_End_Sales_Structure__c where Employee_Id__c=:Mockup_Test.userEmpIdRM LIMIT 1][0];
            List<Year_End_Assignment__c> yearQueryObjList = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE AH_RC_Code__c=:Mockup_Test.AH_RC_CODE ];
            List<String> selectedList = new List<String>();
            for(Year_End_Assignment__c eachYearend : yearQueryObjList){
                selectedList.add(String.valueof(eachYearend.Id));
            }

            //#1 try to submitted
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();           
            sr.contx = 'REFER_OUT';
            sr.selectName = new YearEndModel.SelectedName();
            sr.selectName.selectedbyNamepanel = userRM.Id;
            sr.yearlist = selectedList;

            ModelExtensions.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            //System.assertEquals(true,srs.success);

            List<Year_End_Assignment_Selection__c> yearendselectetionList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Selected_By_Next_Year__c=:userRM.Id  AND Refer_Out__c=false];
            //System.assertEquals(yearQueryObjList.size(),yearendselectetionList.size());
            //#2 Submmit all  
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED';
            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            //System.assertEquals(true,srs.success); //have Record No Select
        }
    }



}