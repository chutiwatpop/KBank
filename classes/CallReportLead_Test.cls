@isTest
private class CallReportLead_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static Map<String, Id> recordTypeIdMapByDevName;

    @testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    public static Id getRecordTypeIdMapByDevName(String devName){
        if(CallReportLead_Test.recordTypeIdMapByDevName == null) {
            CallReportLead_Test.recordTypeIdMapByDevName = new Map<String, Id>();
            CallReportLead_Test.recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Call_Report__c');
        }
        return CallReportLead_Test.recordTypeIdMapByDevName.get(devName);
    }

    public static Campaign mockCreateCampaign(String campaignName, String campaignType, Boolean campaignIsActive, String campaignStatus, String campaignSubType){
        Campaign mockCampaign = new Campaign();
        mockCampaign.Lead_Campaign_Event_Code__c = campaignName;
        mockCampaign.Type__c = campaignType;
        mockCampaign.Sub_Type__c = campaignSubType;
        mockCampaign.Name = campaignName;
        mockCampaign.Status = campaignStatus;

        if(campaignIsActive || campaignStatus == GlobalConstants.ACTIVE) {
            mockCampaign.IsActive = true;
            mockCampaign.StartDate = System.today() - 1;
        } else {
            mockCampaign.IsActive = false;
            mockCampaign.StartDate = System.today() + 1;
        }

        mockCampaign.EndDate = System.Today() + 1;
        mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
        return mockCampaign;
    }

    public static Target_List__c mockCreateTargerList(String accountId, String campaignId){
        Target_List__c eachTargetList = new Target_List__c();
        eachTargetList.CIS_ID_Prospect_Name__c = accountId;
        eachTargetList.Lead_Campaign__c = campaignId;
        eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
        return eachTargetList;
    }

    public static Map<String,String> mockDataForNewCallReport (String campaignType, Boolean campaignIsActive, Boolean hasTargetList, String campaignStatus, String campaignSubType){
        Map<String,String> resultIdMap = new Map<String,String>();
        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        resultIdMap.put('accountId',targetAccount.Id);

        Campaign mockCampaign = mockCreateCampaign('Lead1', campaignType,campaignIsActive,campaignStatus, campaignSubType);
        insert mockCampaign;
        resultIdMap.put('campaignId',mockCampaign.Id);

        if(hasTargetList){
            Target_List__c eachTargetList = mockCreateTargerList(targetAccount.Id,mockCampaign.Id);
            insert eachTargetList;
            resultIdMap.put('targetListId',eachTargetList.Id);
        }       

        Contact mockContact = new Contact(
                LastName = 'lastname',
                Contact_Firstname__c = 'Firstname',
                AccountId = targetAccount.Id,
                Phone_Number__c = '023450789'
            );
        insert mockContact;
        resultIdMap.put('contactId',mockContact.Id);
        return resultIdMap;
    }

    public static Call_Report__c mockCallReportBeforeCreate (Map<String,String> mockIdMap){
        Call_Report__c callReport = new Call_Report__c(
                CIS_ID__c = mockIdMap.get('accountId'),
                Status__c = GlobalConstants.CONTACTED,
                Actual_Visit_Date__c = Date.today()-1,
                Contact_Channel__c = 'Phone Call',
                Contact__c = mockIdMap.get('contactId'),
                Expected_Credit_Amount__c = 500000,
                RecordtypeId = getRecordTypeIdMapByDevName(GlobalConstants.CALL_REPORT_DEVNAME)
            );
        return callReport;
    }

    public static Call_Report__c mockCallPlanBeforeCreate (String accountId){
        Call_Report__c callPlan = new Call_Report__c(
            RecordTypeId = getRecordTypeIdMapByDevName(GlobalConstants.NEW_CALL_PLAN_DEVNAME),
            CIS_ID__c = accountId,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today()
        );
        return callPlan;
    }

    @isTest static void newCallPlanAndExistCallPlan() {
        
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        TriggerHandler.bypass('CampaignTriggerHandler');
        TriggerHandler.bypass('TargetListTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        TriggerHandler.clearAllBypasses();
        Account_Service.callReportRunOnce = false;
        Call_Report__c callPlan = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
        insert callPlan;
        Test.startTest();
            Account_Service.callReportRunOnce = false;     
            Call_Report__c callPlan2 = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
            insert callPlan2;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        //Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        //resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        //System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Status__c);
        //System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testAddTargetList() {
        Boolean expectedTargetListFlag = true;

        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_TO_DO;
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        cm.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER;
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Call_Report__c callreportObj;
        callreportObj = new Call_Report__c(
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today()
        );

        Test.startTest();
            insert callreportObj;
        Test.stopTest();

        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
        
        System.assert(resultLead != null);
        System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
        System.assertEquals(tl.Id, resultLead.Target_List__c);
        System.assertEquals(expectedTargetListFlag, resultLead.Target_List__r.In_Call_Plan__c);
    }

    @isTest static void testDeleteTargetList() {
        Boolean expectedTargetListFlag = false;

        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_TO_DO;
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        cm.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER;
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Call_Report__c callreportObj;
        callreportObj = new Call_Report__c(
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today()
        );

        Test.startTest();
            insert callreportObj;

            Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
            resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
            
            System.assert(resultLead != null);
            System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
            System.assertEquals(tl.Id, resultLead.Target_List__c);
            System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);
        
            delete resultLead;
        Test.stopTest();

        Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id];

        System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
    }
    
    @isTest static void testUpdateTargetList() {
        Boolean expectedTargetListFlag = true;

        Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Call_Report__c callreportObj;
        callreportObj = new Call_Report__c(
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today()
        );
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            insert callreportObj;
        }
        
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Call_Report_Lead_Status__c, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
        
        System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
        System.assertEquals(tl.Id, resultLead.Target_List__c);
        System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);
        System.assertEquals(GlobalConstants.PLAN, resultLead.Call_Report_Lead_Status__c);

        Test.startTest();
            resultLead.Target_List__c = tl.Id;
            update resultLead;
        Test.stopTest();

        Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];

        System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
        System.assertEquals(GlobalConstants.PLAN, finalTarget.Status__c);
    }
    
    @isTest static void testStatusNewCallRepExistCallPlan() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c finalCallReport = mockCallReportBeforeCreate(mockIdMap); 
            finalCallReport.Offer_Credit_Product__c = true;
            finalCallReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;
            finalCallReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            finalCallReport.RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME);
            insert finalCallReport;
        Test.stopTest();

        Call_Report_Lead__c resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c  FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :finalCallReport.Id LIMIT 1];
        
        System.assertEquals(GlobalConstants.NOT_INTERESTED_THIS_TIME, resultLead.Status__c);
        System.assertEquals(GlobalConstants.NOT_INTERESTED_THIS_TIME, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatusNewAndUpdateCallRepExistCallPlan() {
        TriggerHandler.bypass('CampaignTriggerHandler');
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        TriggerHandler.clearBypass('CampaignTriggerHandler');

        Account_Service.callReportRunOnce = false;
        Call_Report__c finalCallReport = mockCallReportBeforeCreate(mockIdMap); 
        finalCallReport.Offer_Credit_Product__c = true;
        finalCallReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;
        finalCallReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
        
        insert finalCallReport;
       
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            finalCallReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
            update finalCallReport;
        Test.stopTest();

        Call_Report_Lead__c resultLead2 = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :finalCallReport.Id LIMIT 1];
        
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead2.Call_Report_Lead_Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead2.Status__c);

    }

 /* Being of NewCallPlan/Report Test LEAD_FOR_SALES */
    @isTest static void testStatus_LeadForSale_NewCallPlan() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        Call_Report__c callreportObj;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
                Account_Service.callReportRunOnce = false;     
                callreportObj = new Call_Report__c(
                    RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
                    CIS_ID__c = mockIdMap.get('accountId'),
                    Status__c = GlobalConstants.PLAN,
                    Plan_Date__c = System.Today()
                );
                insert callreportObj;
            }
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
        System.assertEquals(GlobalConstants.PLAN, resultLead.Status__c);
        System.assertEquals(GlobalConstants.PLAN, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_OfferCreditProduct_InterestAndCanApply() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;                
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
            User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
            rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
            
            System.runAs(new User(Id=UserInfo.getUserId())){
                TriggerHandler.bypass('UserTriggerHandler');
                update rmUser;
            }

            Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
            System.runAs(rmUser){
                Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
                insert newBusCode;
                Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
                insert newCusBusCode;
                callReport.Customer_Business_Code__c = newCusBusCode.Id;
                callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
                insert callReport;
            }
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STOCK_NEGOTIATION, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_OfferCreditProduct_InterestWithCondition() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_OfferCreditProduct_CanNotApply() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.NOT_INTERESTED_THIS_TIME, resultLead.Status__c);
        System.assertEquals(GlobalConstants.NOT_INTERESTED_THIS_TIME, resultLead.Call_Report_Lead_Status__c);

    }

    @isTest static void testStatus_LeadForSale_NewCallReport_OfferCreditProduct_NotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_NOT_INTEREST;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_CollecteDoc_CustomerInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;                
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_CollecteDoc_InterestWithCondition() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;                
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_CollecteDoc_CustomerNotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negotiation_CustomerInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negotiation_CustomerInterestWithCondition() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;                
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }


    @isTest static void testStatus_LeadForSale_NewCallReport_Negotiation_CustomerNotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Status__c);
        System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Servicing() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
            
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }
        Call_Report__c callReport;
        System.runAs(rmUser){
            Test.startTest();
                Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
                insert newBusCode;
                Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
                newCusBusCode.Account_Owner_Segment__c = GlobalConstants.SEGMENT_ME;
                insert newCusBusCode;
                Account_Service.callReportRunOnce = false;
                callReport = mockCallReportBeforeCreate(mockIdMap);
                callReport.Servicing__c = true;
                callReport.Customer_Business_Code__c = newCusBusCode.Id;
                callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
                insert callReport;
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Insight() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Customer_Insight__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_NonCredit() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Non_Credit__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_NoChange() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.No_Change__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Pain() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Pain__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    }
 /* End of NewCallPlan/Report Test LEAD_FOR_SALES */

 /* Being of NewCallPlan/Report Test LEAD_TO_DO */
    @isTest static void testStatus_LeadToDo_NewCallPlan() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;     
            Call_Report__c callreportObj;

            User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
            Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
            System.runAs(rmUser){
                callreportObj = new Call_Report__c(
                    RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
                    CIS_ID__c = mockIdMap.get('accountId'),
                    Status__c = GlobalConstants.PLAN,
                    Plan_Date__c = System.Today()
                );
                insert callreportObj;
            }
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
        System.assertEquals(GlobalConstants.PLAN, resultLead.Status__c);
        System.assertEquals(GlobalConstants.PLAN, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_OfferCreditProduct_InterestAndCanApply() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);

        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }

        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        Call_Report__c callReport;
        System.runAs(rmUser){
            Test.startTest();
            Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
            insert newBusCode;
            Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
            insert newCusBusCode;
            Account_Service.callReportRunOnce = false;
            callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
            callReport.Customer_Business_Code__c = newCusBusCode.Id;
            callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
            insert callReport;
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_OfferCreditProduct_InterestWithCondition() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_OfferCreditProduct_CanNotApply() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);

    }

    @isTest static void testStatus_LeadToDo_NewCallReport_OfferCreditProduct_NotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_NOT_INTEREST;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_CollecteDoc_CustomerInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;                
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_CollecteDoc_CustomerNotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Negotiation_CustomerInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Negotiation_CustomerNotInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Servicing() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }
        Call_Report__c callReport;
        System.runAs(rmUser){
            Test.startTest();
                Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
                insert newBusCode;
                Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
                newCusBusCode.Account_Owner_Segment__c = GlobalConstants.SEGMENT_ME;
                insert newCusBusCode;
                Account_Service.callReportRunOnce = false;
                callReport = mockCallReportBeforeCreate(mockIdMap);
                callReport.Customer_Business_Code__c = newCusBusCode.Id;
                callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
                callReport.Servicing__c = true;                              
                insert callReport;
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Insight() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Customer_Insight__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_NonCredit() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Non_Credit__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_NoChange() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.No_Change__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Pain() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Pain__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
        System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Call_Report_Lead_Status__c);
    }
/* End of NewCallPlan/Report Test LEAD_TO_DO */

/* Being of UpdateCallPlan/Report Test LEAD_FOR_SALES */
    @isTest static void testStatus_LeadForSale_UpdateCallReport_OfferCreditProduct_InterestAndCanApply_ToCannotApply() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE;
        TriggerHandler.bypass('CampaignTriggerHandler');
        TriggerHandler.bypass('TargetListTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Account_Service.callReportRunOnce = false;
        
        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }

        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        Call_Report__c callReport;
        System.runAs(rmUser){
            Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
            insert newBusCode;
            Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
            insert newCusBusCode;
            Account_Service.callReportRunOnce = false;
            callReport = new Call_Report__c(
                Offer_Credit_Product__c = true,
                CIS_ID__c = mockIdMap.get('accountId'),
                Status__c = GlobalConstants.CONTACTED,
                Actual_Visit_Date__c = Date.today()-1,
                Contact_Channel__c = 'Phone Call',
                Contact__c = mockIdMap.get('contactId'),
                Expected_Credit_Amount__c = 500000,
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
                RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Customer_Business_Code__c = newCusBusCode.Id,
                Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
            );
            insert callReport;
        }
        TriggerHandler.clearAllBypasses();
        
        Account_Service.callReportRunOnce = false;
        callReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){    
            Test.startTest();
                update callReport;
            Test.stopTest();
        }
        

        System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
        System.assertEquals(GlobalConstants.NOT_INTERESTED_THIS_TIME, resultLead.Call_Report_Lead_Status__c);
        System.assertEquals(GlobalConstants.STOCK_NEGOTIATION, resultLead.Status__c);
    }
/* End of UpdateCallPlan/Report Test LEAD_FOR_SALES */

/* Being of NewCallPlan/Report NegativeCase Test LEAD_FOR_SALES */
    @isTest static void testStatus_LeadForSale_NewCallPlan_Negative_IsInActive() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = true;
        String campaignStatus = GlobalConstants.PLANNED;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
            Account_Service.callReportRunOnce = false;     
            Call_Report__c callreportObj;
            callreportObj = new Call_Report__c(
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
                CIS_ID__c = mockIdMap.get('accountId'),
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today()
            );
            insert callreportObj;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW ,actualTargetList.Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_ExpiryProcess_OfferCreditProduct() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = true;
        //Case Campaign status is Expiry Process.
        String campaignStatus = GlobalConstants.EXPIRE_PROCESS;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        
        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }

        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        System.runAs(rmUser){
            Test.startTest();
            Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
            insert newBusCode;
            Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
            insert newCusBusCode;
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY; 
            callReport.Customer_Business_Code__c = newCusBusCode.Id;
            callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;      
            insert callReport;
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);        
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.LEAD_EXPIRED ,actualTargetList.Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_NoTargetList_CollectDocuments() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = false;
        //Case No targetList.
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Collect_Documents__c = true;            
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;              
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c]);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_ExpiryProcessAndNoTargetList_OfferCreditProduct() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = false;
        //Case Campaign status is Expiry Process and No targetList.
        String campaignStatus = GlobalConstants.EXPIRE_PROCESS;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Offer_Credit_Product__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;               
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c]);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_Servicing_WithOfferCreditProduct() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true, expectedException = true, actualException = false;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        Test.startTest();
        try{
                Account_Service.callReportRunOnce = false;
                Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
                callReport.Servicing__c = true;                 
                callReport.Offer_Interest__c = GlobalConstants.OFFER_NOT_INTEREST;
                insert callReport;
           }catch(Exception e){
                actualException = true;
           }
        Test.stopTest();

        //System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
        //System.assertEquals(expectedException,actualException);
    }

    //@isTest static void testStatus_LeadForSale_NewCallReport_Negative_Insight_WithCollectDocuments() {
    //  Map<String,String> mockIdMap = new Map<String,String>();
    //  Boolean campaignIsActive = true, hasTargetList = true;
    //  String campaignStatus = GlobalConstants.ACTIVE;
    //  TriggerHandler.bypass('CampaignTriggerHandler');
    //  TriggerHandler.bypass('TargetListTriggerHandler');
    //  TriggerHandler.bypass('ContactTriggerHandler');
    //  mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
    //  TriggerHandler.clearAllBypasses();
    //  Test.startTest();
    //      Account_Service.callReportRunOnce = false;
 //           Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
 //           callReport.Customer_Insight__c = true;
 //           callReport.Collect_Documents__c = true;
 //           callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;                
 //           insert callReport;
    //  Test.stopTest();

    //  System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
    //  Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
    //  resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
    //  System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
    //  System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    //}

    //@isTest static void testStatus_LeadForSale_NewCallReport_Negative_NonCredit_withNegotiation() {
    //  Map<String,String> mockIdMap = new Map<String,String>();
    //  Boolean campaignIsActive = true, hasTargetList = true;
    //  String campaignStatus = GlobalConstants.ACTIVE;

    //  TriggerHandler.bypass('CampaignTriggerHandler');
    //  TriggerHandler.bypass('TargetListTriggerHandler');
    //  TriggerHandler.bypass('ContactTriggerHandler');
    //  mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
    //  TriggerHandler.clearAllBypasses();
    //  Test.startTest();
    //      Account_Service.callReportRunOnce = false;
 //           Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
 //           callReport.Non_Credit__c = true;
 //           callReport.Negotiation__c = true;                
 //           callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
 //           callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;                            
 //           insert callReport;
    //  Test.stopTest();

    //  System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
    //  Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
    //  resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReport.Id LIMIT 1];
    //  System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
    //  System.assertEquals(null, resultLead.Call_Report_Lead_Status__c);
    //}

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_ExpiryProcess_NoChange() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = true;
        //Case Campaign status is Expiry Process.
        String campaignStatus = GlobalConstants.EXPIRE_PROCESS;
        Test.startTest();
            mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.No_Change__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);        
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.LEAD_EXPIRED ,actualTargetList.Status__c);
    }

    @isTest static void testStatus_LeadForSale_NewCallReport_Negative_NoTargetList_Pain() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = false;
        //Case No targetList.
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);

        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Pain__c = true;                              
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c]);      
    }
/* End of NewCallPlan/Report NegativeCase Test LEAD_FOR_SALES */

/* Being of NewCallPlan/Report NegativeCase Test LEAD_TO_DO */
    @isTest static void testStatus_LeadToDo_NewCallPlan_Negative_CampaignPlanned() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = true;
        String campaignStatus = GlobalConstants.PLANNED;
        TriggerHandler.bypass('CampaignTriggerHandler');
        TriggerHandler.bypass('TargetListTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        TriggerHandler.clearAllBypasses();
        Test.startTest();
            Account_Service.callReportRunOnce = false;     
            Call_Report__c callreportObj;
            callreportObj = new Call_Report__c(
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
                CIS_ID__c = mockIdMap.get('accountId'),
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today()
            );
            insert callreportObj;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);        
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW ,actualTargetList.Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Negative_CancellingProcess_OfferCreditProduct() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = false, hasTargetList = true;
        String campaignStatus = GlobalConstants.CANCEL_PROCESS;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CANNOT_APPLY;
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);        
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.CANCEL_LEAD ,actualTargetList.Status__c);
    }
    
    @isTest static void testStatus_LeadToDo_NewCallReport_Negative_Cancel_CollecteDoc() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.CANCEL;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap); 
            callReport.Collect_Documents__c = true;
            callReport.Reason__c = '3.2 ที่อยู่ และเบอร์โทรศัพท์ไม่ถูกต้อง / ไม่มีข้อมูล/ ติดต่อไม่ได้';
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);        
        Target_List__c actualTargetList = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
        System.assertEquals(GlobalConstants.STATUS_NEW ,actualTargetList.Status__c);
    }

    @isTest static void testStatus_LeadToDo_NewCallReport_Negative_NoTargetList_Negotiation_CustomerInterest() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = false;
        String campaignStatus = GlobalConstants.ACTIVE;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Negotiation__c = true;
            callReport.Offer_Interest__c = GlobalConstants.OFFER_CUSTOMER_INTERESTED;
            insert callReport;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c]);
    }
    
    @isTest static void testStatus_LeadToDo_NewCallReport_Negative_ExpiryProcessAndNoTargetList_Servicing() {
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = false;
        String campaignStatus = GlobalConstants.EXPIRE_PROCESS;
        mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_TO_DO,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
        Account targetAccount = [SELECT Id,CIS__c,Owner.Segment__c FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];
        User rmUser = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
        rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
            
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
        }

        System.runAs(rmUser){
            Test.startTest();
            Account_Service.callReportRunOnce = false;
            Call_Report__c callReport = mockCallReportBeforeCreate(mockIdMap);
            callReport.Servicing__c = true; 
            Business_Code__c newBusCode = Mockup_Test.newBusinessCode('Bu1',GlobalConstants.SEGMENT_ME);
            insert newBusCode;
            Customer_Business_Code__c newCusBusCode = Mockup_Test.newCustomerBusinessCode(targetAccount,newBusCode);
            newCusBusCode.Account_Owner_Segment__c = GlobalConstants.SEGMENT_ME;
            insert newCusBusCode;
            callReport.Customer_Business_Code__c = newCusBusCode.Id;
            callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;                             
            insert callReport;
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Count() FROM Call_Report_Lead__c]);
    }   
/* End of NewCallPlan/Report Negative Test LEAD_TO_DO */

    @isTest static void testStatus_LeadForSale_New2CallPlanThenConvertToCallReport() {
        
        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE, campaignType = GlobalConstants.LEAD_FOR_SALES;
        TriggerHandler.bypass('CampaignTriggerHandler');
        TriggerHandler.bypass('TargetListTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        mockIdMap = mockDataForNewCallReport(campaignType,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        
        Account_Service.callReportRunOnce = false;     
        Call_Report__c callPlan = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
        insert callPlan;
        
        Campaign mockCampaign2 = mockCreateCampaign('Lead2',campaignType,campaignIsActive,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        insert mockCampaign2;

        Target_List__c mockTargetList2 = mockCreateTargerList(mockIdMap.get('accountId'), mockCampaign2.Id);
        insert mockTargetList2;
        TriggerHandler.clearAllBypasses();

        Account_Service.callReportRunOnce = false;     
        Call_Report__c callPlan2 = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
        insert callPlan2;

        Test.startTest();
            Account_Service.callReportRunOnce = false;
            callPlan.Status__c = GlobalConstants.CONTACTED;
            callPlan.Actual_Visit_Date__c = Date.today()-1;                
            callPlan.Contact__c = mockIdMap.get('contactId');
            callPlan.Expected_Credit_Amount__c = 500000;
            callPlan.Offer_Credit_Product__c = true;
            callPlan.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
            callPlan.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            callPlan.RecordtypeId = getRecordTypeIdMapByDevName(GlobalConstants.CALL_REPORT_DEVNAME);
            update callPlan;

            System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
            System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockTargetList2.Id]);
            Call_Report_Lead__c resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callPlan.Id LIMIT 1];
            Call_Report_Lead__c resultLead2 = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callPlan2.Id LIMIT 1];
            System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
            System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Status__c);
            System.assertEquals(GlobalConstants.PLAN, resultLead2.Call_Report_Lead_Status__c);
            System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead2.Status__c);
        Test.stopTest();
    }

    @isTest static void testStatus_LeadForSales_New2CallPlanThenConvertFirstCallPlanWithOppThenConvertSecondCallPlan(){

        Map<String,String> mockIdMap = new Map<String,String>();
        Boolean campaignIsActive = true, hasTargetList = true;
        String campaignStatus = GlobalConstants.ACTIVE, campaignType = GlobalConstants.LEAD_FOR_SALES;
        TriggerHandler.bypass('CampaignTriggerHandler');
        TriggerHandler.bypass('TargetListTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        mockIdMap = mockDataForNewCallReport(campaignType,campaignIsActive,hasTargetList,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        
        Account_Service.callReportRunOnce = false;     
        Call_Report__c callPlan = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
        insert callPlan;
        
        Campaign mockCampaign2 = mockCreateCampaign('Lead2',campaignType,campaignIsActive,campaignStatus,GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
        insert mockCampaign2;

        Target_List__c mockTargetList2 = mockCreateTargerList(mockIdMap.get('accountId'), mockCampaign2.Id);
        insert mockTargetList2;
        TriggerHandler.clearAllBypasses();

        Account_Service.callReportRunOnce = false;     
        Call_Report__c callPlan2 = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
        insert callPlan2;

        Test.startTest();
            Account_Service.callReportRunOnce = false;
            callPlan.Status__c = GlobalConstants.CONTACTED;
            callPlan.Actual_Visit_Date__c = Date.today()-1;                
            callPlan.Contact__c = mockIdMap.get('contactId');
            callPlan.Expected_Credit_Amount__c = 500000;
            callPlan.Offer_Credit_Product__c = true;
            callPlan.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
            callPlan.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            callPlan.RecordtypeId = getRecordTypeIdMapByDevName(GlobalConstants.CALL_REPORT_DEVNAME);
            update callPlan;

            Account_Service.callReportRunOnce = false;
            callPlan.Status__c = GlobalConstants.CONTACTED;
            callPlan.Actual_Visit_Date__c = Date.today()-1;                
            callPlan.Contact__c = mockIdMap.get('contactId');
            callPlan.Expected_Credit_Amount__c = 500000;
            callPlan.Offer_Credit_Product__c = true;
            callPlan.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION;
            callPlan.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
            callPlan.RecordtypeId = getRecordTypeIdMapByDevName(GlobalConstants.CALL_REPORT_DEVNAME);
            update callPlan2;

            Test.stopTest();

            System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockIdMap.get('targetListId')]);
            System.assertEquals(1, [SELECT Count() FROM Call_Report_Lead__c WHERE Target_List__c = :mockTargetList2.Id]);
            Call_Report_Lead__c resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callPlan.Id LIMIT 1];
            Call_Report_Lead__c resultLead2 = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callPlan2.Id LIMIT 1];
            System.assertEquals(GlobalConstants.STOCK_NEGOTIATION, resultLead.Status__c);

            Target_List__c targetList1 = [SELECT Id,Status__c From Target_List__c WHERE Id = :mockIdMap.get('targetListId') LIMIT 1];
            Target_List__c targetList2 = [SELECT Id,Status__c From Target_List__c WHERE Id = :mockTargetList2.Id LIMIT 1];

            System.assertEquals(GlobalConstants.STOCK_NEGOTIATION,targetList1.Status__c);
            System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED,targetList2.Status__c);

    }
}