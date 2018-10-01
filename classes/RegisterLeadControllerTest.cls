@isTest
private class RegisterLeadControllerTest {
	public static String accountNameAH = 'accountNameAH';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String newBooking = 'NewBooking';
    public static String uputilizedYes = 'UputilizedYes';
    public static String uputilizedNo = 'UputilizedNo';
    public static String lead = 'lead';
    public static Integer capacityMaxRewardAmount = 30000;

    @testSetup static void setUpTest(){
        SME_GroupChatterService.isByPassGroupChatterService = true;
        TriggerHandler.bypass('UserTriggerHandler');
        TriggerHandler.bypass('CampaignTriggerHandler');
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        Account newAccount1;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            newAccount1 = Mockup_Test.newAccountWithSegment(accountNameRM,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT),'MI');
            newAccount1.Capacity_Max_Reward_Amount__c = capacityMaxRewardAmount;
            newAccount1.Used_Reward_Amount__c = 0;
            insert newAccount1;
            insert new Campaign_Setting__c(NewBooking_Code__c = newBooking);
            setupCampaign_LeadMaster();
            setupLocationCode();
            setUpCampaignReward();
        }
        setupNewTargetList(newAccount1);
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    private static void createLocation(){
        List<Global_Master_Data__c> listLocation = new List<Global_Master_Data__c>();
        Id locationRecType = GlobalUtility.getRecordTypeId('Global_Master_Data__c', 'LocationCode');
        Global_Master_Data__c location1 = new Global_Master_Data__c(
            RecordTypeId = locationRecType,
            LocationCode_Province__c = 'จังหวัดกรุงเทพมหานคร'
        );

        Global_Master_Data__c location2 = new Global_Master_Data__c(
            RecordTypeId = locationRecType,
            LocationCode_Province__c = 'จังหวัดกรุงเทพมหานคร',
            LocationCode_District__c = 'เขตธนบุรี',
            LocationCode_SubDistrict__c = 'แขวงบุคคโล',
            LocationCode_PostCode__c = '10600'
        );
        listLocation.add(location1);
        listLocation.add(location2);
        insert listLocation;
    }

    private static void setupCampaign_LeadMaster(){
    	String campaignType = 'Campaign';
    	String leadType = 'Lead';
        List<Campaign> campaignList = new List<Campaign>();
        Campaign newBookingCampaign = Mockup_Test.newCampaign(UserInfo.getUserId(),newBooking, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,campaignType);
        campaignList.add(newBookingCampaign);
        Campaign uputilizedCampaignYes = Mockup_Test.newCampaign(UserInfo.getUserId(),uputilizedYes, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,campaignType);
        uputilizedCampaignYes.Address_Registration__c = 'Yes';
        campaignList.add(uputilizedCampaignYes);

        Campaign uputilizedCampaignNo = Mockup_Test.newCampaign(UserInfo.getUserId(),uputilizedNo, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,campaignType);
        uputilizedCampaignNo.Address_Registration__c = 'No';
        campaignList.add(uputilizedCampaignNo);

        campaignList.add(Mockup_Test.newCampaign(UserInfo.getUserId(),lead, System.today(), system.today().addMonths(1), System.today()+1, GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC,leadType));
        insert campaignList;
    }
    
    private static void setupLocationCode() {
        List<Location_Code__c> LocationList = new List<Location_Code__c>();
        Location_Code__c eachLocation = new Location_Code__c();
        eachLocation.Name = '100101';
        eachLocation.Province__c = 'กรุงเทพมหานคร';
        eachLocation.District__c = 'เขตพระนคร';
        eachLocation.Sub_District__c = 'พระบรมมหาราชวัง';
        eachLocation.PostCode__c = '10200';
        LocationList.add(eachLocation);
        insert LocationList;
    }

    private static void setupNewTargetList(Account newAccount){
        List<Target_List__c> targetLists = new List<Target_List__c>();
        Campaign lead1 = [SELECT Id FROM Campaign WHERE Name =: newBooking];
        Target_List__c targetList1 = Mockup_Test.newTargetList(newAccount.Id,lead1.Id,lead1.Id,GlobalConstants.STATUS_NEW);
        targetList1.Setup_Amount__c = 20000;
        targetLists.add(targetList1);

        Campaign lead2 = [SELECT id From Campaign WHERE Name =:uputilizedYes];
        Target_List__c targetList2 = Mockup_Test.newTargetList(newAccount.Id,lead2.Id,lead2.Id,GlobalConstants.STATUS_NEW);
        targetList2.Setup_Amount__c = 10000;
        targetLists.add(targetList2);

        Campaign lead3 = [SELECT id From Campaign WHERE Name =:uputilizedNo];
        Target_List__c targetList3 = Mockup_Test.newTargetList(newAccount.Id,lead3.Id,lead3.Id,GlobalConstants.STATUS_NEW);
        targetList3.Setup_Amount__c = 10000;
        targetLists.add(targetList3);

        Campaign lead4 = [SELECT id From Campaign WHERE Name =:lead];
        Target_List__c targetList4 = Mockup_Test.newTargetList(newAccount.Id,lead4.Id,lead4.Id,GlobalConstants.STATUS_NEW);
        targetList4.Setup_Amount__c = 10000;
        targetLists.add(targetList4);
        insert targetLists;
    }

    private static void setUpCampaignReward() {
        Rewards__c campaingReward1 = new Rewards__c(
            Name = 'R01',
            Reward_Name__c = 'บัตรเงินสด Central', 
            Reward_Amount_Baht__c = 1000, 
            Reward_Type__c = 'Voucher',
            Min_Amount__c = 0,
            Max_Amount__c =  10000,
            Bankok_Zone__c = false,
            RM_Segment__c = 'SE'
        );

        Rewards__c campaingReward2 = new Rewards__c(
            Name = 'R02',
            Reward_Name__c = 'บัตรเติมน้ำมัน ปตท', 
            Reward_Amount_Baht__c = 500, 
            Reward_Type__c = 'VOUCHER',
            Min_Amount__c = 0,
            Max_Amount__c =  10000,
            Bankok_Zone__c = false,
            RM_Segment__c = 'ME'
        );
        
        Rewards__c campaingReward3 = new Rewards__c(
            Name = 'R03',
            Reward_Name__c = 'ลดค่าประเมิน', 
            Reward_Amount_Baht__c = 5000, 
            Reward_Type__c = 'Voucher',
            Min_Amount__c = 0,
            Max_Amount__c =  50000,
            Bankok_Zone__c = true,
            RM_Segment__c = 'SE'
        );

        Rewards__c campaingReward4 = new Rewards__c(
            Name = 'R04',
            Reward_Name__c = 'ลดค่าจำนอง', 
            Reward_Amount_Baht__c = 5000, 
            Reward_Type__c = 'CASHBACK',
            Min_Amount__c = 10001,
            Max_Amount__c =  50000,
            Bankok_Zone__c = false,
            RM_Segment__c = 'ME'
        );

        Rewards__c campaingReward5 = new Rewards__c(
            Name = 'R05',
            Reward_Name__c = 'ลดค่าจำนอง', 
            Reward_Amount_Baht__c = 5000, 
            Reward_Type__c = 'CASHBACK',
            Min_Amount__c = 10001,
            Max_Amount__c =  50000,
            Bankok_Zone__c = true,
            RM_Segment__c = 'ME'
        );

        Rewards__c campaingReward6 = new Rewards__c(
            Name = 'R06',
            Reward_Name__c = 'ลดค่าประเมิน', 
            Reward_Amount_Baht__c = 50000, 
            Reward_Type__c = 'Voucher',
            Min_Amount__c = 0,
            Max_Amount__c =  50000,
            Bankok_Zone__c = false,
            RM_Segment__c = 'SE'
        );

        List<Rewards__c> campaignRewardList = new List<Rewards__c>();
        campaignRewardList.add(campaingReward1);
        campaignRewardList.add(campaingReward2);
        campaignRewardList.add(campaingReward3);
        campaignRewardList.add(campaingReward4);
        campaignRewardList.add(campaingReward5);
        campaignRewardList.add(campaingReward6);
        insert campaignRewardList;
    }

    @isTest
    static void testIfStatusNewAndTypeCampaignThenReturnSuccess() {
    	String expectedResult = RegisterLeadController.SUCCESS;
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.canRegister(targetLeadRegister.Id);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(resultString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(expectedResult,resultResponse.result);
    }

    @isTest
    static void testIfStatusRegisteredThenErrorAlreadyRegister() {
    	String expectedResult = RegisterLeadController.ERROR;
    	String expectedMessageResult = RegisterLeadController.CUSTOMER_ALREADY_REGISTERED;
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        targetLeadRegister.Status__c = GlobalConstants.REGISTERED;
        TriggerHandler.bypass('TargetListTriggerHandler');
        update targetLeadRegister;
        TriggerHandler.clearBypass('TargetListTriggerHandler');
        String resultString = RegisterLeadController.canRegister(targetLeadRegister.Id);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(resultString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(expectedResult,resultResponse.result);
        System.assertEquals(expectedMessageResult,resultResponse.message);
    }

    @isTest
    static void testIfStatusNotNewThenErrorStatusMustBeNew() {
    	String expectedResult = RegisterLeadController.ERROR;
    	String expectedMessageResult = RegisterLeadController.STATUS_MUST_BE_NEW;
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        targetLeadRegister.Status__c = 'Other';
        TriggerHandler.bypass('TargetListTriggerHandler');
        update targetLeadRegister;
        TriggerHandler.clearBypass('TargetListTriggerHandler');
        String resultString = RegisterLeadController.canRegister(targetLeadRegister.Id);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(resultString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(expectedResult,resultResponse.result);
        System.assertEquals(expectedMessageResult,resultResponse.message);
    }

    @isTest
    static void testIfStatusNotNewThenErrorTypeMustBeCampaign() {
    	String expectedResult = RegisterLeadController.ERROR;
    	String expectedMessageResult = RegisterLeadController.TYPE_MUST_BE_CAMPAIGN;
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :lead LIMIT 1];
        String resultString = RegisterLeadController.canRegister(targetLeadRegister.Id);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(resultString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(expectedResult,resultResponse.result);
        System.assertEquals(expectedMessageResult,resultResponse.message);
    }

    @isTest
    static void testGetFieldLabel() {
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(Schema.SObjectType.Target_List__c.fields.Contact_Name__c.Label,wrapObject.contactPersonLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Mobile_No__c.Label,wrapObject.mobileNoLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_House_No__c.Label,wrapObject.houseNoLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Moo__c.Label,wrapObject.mooLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Mooban__c.Label,wrapObject.villageLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Building__c.Label,wrapObject.buildingLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Floor__c.Label,wrapObject.floorLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Room__c.Label,wrapObject.roomLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Soi__c.Label,wrapObject.soiLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Address_Street__c.Label,wrapObject.streetLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Province__c.Label,wrapObject.provinceLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.District__c.Label,wrapObject.districtLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Sub_District__c.Label,wrapObject.subDistrictLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.PostCode__c.Label,wrapObject.postCodeLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Memo__c.Label,wrapObject.memoLabel);
		System.assertEquals(Schema.SObjectType.Target_List__c.fields.Account_Number__c.Label,wrapObject.accountNumberLabel);
    }

    @isTest
    static void testGetRewardItemsIfSetupAmountBetweenMinMaxAndSegmentEqualRewardSegmentAndIsBangkokZoneEqualRewardBangkokZoneThenReturnRaward() {
        RegisterLeadController.isBangkokZone = true;
        String expectedResult = 'ลดค่าจำนอง ' + '5000';
        Map<String,String> result = RegisterLeadController.getRewardItems('20000','ME');
        for(String eachEesult : result.values()){
        	System.assertEquals(expectedResult,eachEesult);
        }
    }

    @isTest
    static void testGetRewardItemsIfSetupAmountNotBetweenMinMax() {
        RegisterLeadController.isBangkokZone = true;
        Integer expectedResult = 0;
        Map<String,String> result = RegisterLeadController.getRewardItems('20000000','ME');
        System.assertEquals(expectedResult,result.values().size());
    }

    @isTest
    static void testGetRecordInfoIfCampaignNewBookingAndTglNoExistingRewardThenIsNewBookingTrueAndIsShowRewardSectionTrueAndMustSelectRewardTrue() {
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(RegisterLeadController.REGISTER_REWARD,wrapObject.pageHeaderTitle);
        System.assertEquals(true,wrapObject.isNewBooking);
        System.assertEquals(true,wrapObject.isShowRewardSection);
        System.assertEquals(true,wrapObject.mustSelectReward);
        System.assertEquals(true,wrapObject.isShowAddressSection);
    }

    @isTest
    static void testGetRecordInfoIfCampaignNewBookingAndTglAccountNoNotNullAndCampaignRewardCalcNotNullThenIsNewBookingTrueAndIsShowRewardSectionTrueAndMustSelectRewardTrue() {
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        targetLeadRegister.Reward__c = GlobalConstants.CASHBACK;
        targetLeadRegister.Campaign_Reward_Calc__c = 'Cash';
        targetLeadRegister.Campaign_Reward_Amount__c = 1000;
        targetLeadRegister.Account_Number__c = '1234567890';
        TriggerHandler.bypass('TargetListTriggerHandler');
        update targetLeadRegister;
        TriggerHandler.clearBypass('TargetListTriggerHandler');

        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(RegisterLeadController.REGISTER_REWARD,wrapObject.pageHeaderTitle);
        System.assertEquals(true,wrapObject.isNewBooking);
        System.assertEquals(true,wrapObject.isShowRewardSection);
        System.assertEquals(false,wrapObject.mustSelectReward);
        System.assertEquals(false,wrapObject.isShowAddressSection);
    }

    @isTest
    static void testGetRecordInfoIfCampaignUtilizeAddressYesAndTglCampaignRewardCalcNullThenIsShowRewardSectionFalse() {
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilizedYes LIMIT 1];

        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(RegisterLeadController.REGISTER_ADDRESS,wrapObject.pageHeaderTitle);
        System.assertEquals(false,wrapObject.isShowRewardSection);
    }

    @isTest
    static void testGetRecordInfoIfCampaignUtilizeAddressYesAndTglCampaignRewardCalcNotNullThenIsShowRewardSectionFalse() {
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilizedYes LIMIT 1];
        targetLeadRegister.Campaign_Reward_Calc__c = 'Cash';
        TriggerHandler.bypass('TargetListTriggerHandler');
        update targetLeadRegister;
        TriggerHandler.clearBypass('TargetListTriggerHandler');

        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(RegisterLeadController.REGISTER_ADDRESS,wrapObject.pageHeaderTitle);
        System.assertEquals(true,wrapObject.isShowRewardSection);
        System.assertEquals(false,wrapObject.mustSelectReward);
    }

    @isTest
    static void testGetRecordInfoIfCampaignUtilizeAddressNoThenCanUpdateImmediatelyTrue() {
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilizedNo LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        System.assertEquals(true,wrapObject.canUpdateImmediately);
    }

    @isTest
    static void testGetProvincePickListValues() {
        createLocation();
        String resultString = RegisterLeadController.getProvincePickListValues();
        List<String> wrapObject = (List<String>)JSON.deserialize(resultString,List<String>.class);
        System.assertNotEquals(0,wrapObject.size());
    }


    @isTest
    static void testGetDistrictPickListValues() {
        createLocation();
        String resultString = RegisterLeadController.getDistrictPickListValues('จังหวัดกรุงเทพมหานคร	');
        List<String> wrapObject = (List<String>)JSON.deserialize(resultString,List<String>.class);
        System.assertNotEquals(0,wrapObject.size());
    }

    @isTest
    static void testGetSubDistrictPickListValues() {
        createLocation();
        String resultString = RegisterLeadController.getSubDistrictPickListValues('จังหวัดกรุงเทพมหานคร','เขตธนบุรี');
        List<String> wrapObject = (List<String>)JSON.deserialize(resultString,List<String>.class);
        System.assertNotEquals(0,wrapObject.size());
    }

    @isTest
    static void testGetPostCodeFoundThenReturnPostCode() {
        createLocation();
        String resultString = RegisterLeadController.getPostCode('จังหวัดกรุงเทพมหานคร','เขตธนบุรี','แขวงบุคคโล');
        System.assertEquals('10600',resultString);
    }

    @isTest
    static void testGetPostCodeNotFoundThenReturnBlank() {
        String resultString = RegisterLeadController.getPostCode('abc','def','');
        System.assertEquals('',resultString);
    }

    @isTest
    static void testValidatePickRewardIfUserNotPickCampaignRewardThenReturnTrueToShowAddressSection() {
        System.assertEquals(true,RegisterLeadController.validatePickReward(''));
    }

    @isTest
    static void testValidatePickRewardIfUserPickCampaignRewardAndRewardTypeNotCashBackThenReturnTrueToShowAddressSection() {
    	Rewards__c reward = [SELECT Id FROM Rewards__c WHERE NAME = 'R01' LIMIT 1];
        System.assertEquals(true,RegisterLeadController.validatePickReward(reward.Id));
    }

    @isTest
    static void testValidatePickRewardIfUserPickCampaignRewardAndRewardTypeCashBackThenReturnFalseToShowAccountSection() {
    	Rewards__c reward = [SELECT Id FROM Rewards__c WHERE NAME = 'R04' LIMIT 1];
        System.assertEquals(false,RegisterLeadController.validatePickReward(reward.Id));
    }

    @isTest
    static void testSavingTargetListImmediatelySuccess(){
    	Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilizedNo LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        //RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        String responseString = RegisterLeadController.savingTargetListImmediately(resultString);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.SUCCESS,resultResponse.result);
        System.assertEquals(RegisterLeadController.SUCCESS_MESSAGE,resultResponse.message);
        Target_List__c targetLeadAfterRegister = [SELECT Id,Account_Number__c, Status__c,Register__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilizedNo LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED,targetLeadAfterRegister.Status__c);
        System.assertEquals(true,targetLeadAfterRegister.Register__c);
    }

    @isTest
    static void testSavingTargetListImmediatelyError(){
        String responseString = RegisterLeadController.savingTargetListImmediately('dummy string to make error');
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.ERROR,resultResponse.result);
    }

    @isTest
    static void testSavingTargetListIsShowRewardTrueButNotSelectRewardThenErrorPleaseInputReward(){
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        //RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        String responseString = RegisterLeadController.savingTargetList(resultString,'');
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.ERROR,resultResponse.result);
        System.assertEquals(RegisterLeadController.PLEASE_INPUT_REWARD,resultResponse.message);
    }

    @isTest
    static void testSavingTargetListUsedCapMoreThanMaxCapThenErrorUsedOverCap(){
        Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        targetLeadRegister.Campaign_Reward_Amount__c = 30001;
        TriggerHandler.bypass('TargetListTriggerHandler');
        update targetLeadRegister;
        TriggerHandler.clearbypass('TargetListTriggerHandler');
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        Rewards__c reward = [SELECT Id FROM Rewards__c WHERE NAME = 'R06' LIMIT 1];
        String responseString = RegisterLeadController.savingTargetList(resultString,reward.Id);
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.ERROR,resultResponse.result);
        System.assertEquals(RegisterLeadController.USED_OVER_CAP_MAX,resultResponse.message);
    }

    @isTest
    static void testSavingTargetListError(){
        String responseString = RegisterLeadController.savingTargetList('dummy string to make error','');
        RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.ERROR,resultResponse.result);
    }

    @isTest
    static void testSavingTargetListWithNewAddress(){
    	String newContact = 'newContact';
    	String newMobileNo = '1234567890';
    	String newAddressNo = 'newAddressNo';
    	String newMoo = 'newMoo';
    	String newMooBan = 'newMooBan';
    	String newBuilding = 'newBuilding';
    	String newFloor = 'newFloor';
    	String newStreet = 'newStreet';
    	String newRoom = 'newRoom';
    	String newSoi = 'newSoi';
    	String newProvince = 'newProvince';
    	String newDistrict = 'newDistrict';
    	String newSubDistrict = 'newSubDistrict';
    	String newPostCode = '12345';
    	String newMemo = 'newMemo';

    	Rewards__c reward = [SELECT Id FROM Rewards__c WHERE NAME = 'R01' LIMIT 1];
    	Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
		wrapObject.targetList.Contact_Name__c = newContact;
		wrapObject.targetList.Mobile_No__c = newMobileNo;
		wrapObject.targetList.Address_House_No__c = newAddressNo;
		wrapObject.targetList.Address_Moo__c = newMoo;
		wrapObject.targetList.Address_Mooban__c = newMooBan;
		wrapObject.targetList.Address_Building__c = newBuilding;
		wrapObject.targetList.Address_Floor__c = newFloor;
		wrapObject.targetList.Address_Room__c = newRoom;
		wrapObject.targetList.Address_Soi__c = newSoi;
		wrapObject.targetList.Address_Street__c = newStreet;
		wrapObject.targetList.Province__c = newProvince;
		wrapObject.targetList.District__c = newDistrict;
		wrapObject.targetList.Sub_District__c = newSubDistrict;
		wrapObject.targetList.PostCode__c = newPostCode;
		wrapObject.targetList.Memo__c = newMemo;

        String responseString = RegisterLeadController.savingTargetList(JSON.serialize(wrapObject),reward.Id);
		RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.SUCCESS,resultResponse.result);

        Target_List__c targetLeadAfterRegister = [SELECT Id,Status__c,Register__c,Account_Number__c,Memo__c,PostCode__c,Province__c,District__c,Sub_District__c,Address_Street__c,Address_Soi__c,Address_Room__c,Address_Floor__c,Address_Building__c,Address_Mooban__c,Address_Moo__c,Contact_Name__c,Mobile_No__c,Address_House_No__c,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED,targetLeadAfterRegister.Status__c);
        System.assertEquals(true,targetLeadAfterRegister.Register__c);
        System.assertEquals(newContact,targetLeadAfterRegister.Contact_Name__c);
        System.assertEquals(newMobileNo,targetLeadAfterRegister.Mobile_No__c);
        System.assertEquals(newAddressNo,targetLeadAfterRegister.Address_House_No__c);
        System.assertEquals(newMoo,targetLeadAfterRegister.Address_Moo__c);
        System.assertEquals(newMooBan,targetLeadAfterRegister.Address_Mooban__c);
        System.assertEquals(newBuilding,targetLeadAfterRegister.Address_Building__c);
        System.assertEquals(newFloor,targetLeadAfterRegister.Address_Floor__c);
        System.assertEquals(newRoom,targetLeadAfterRegister.Address_Room__c);
        System.assertEquals(newSoi,targetLeadAfterRegister.Address_Soi__c);
        System.assertEquals(newStreet,targetLeadAfterRegister.Address_Street__c);
        System.assertEquals(newProvince,targetLeadAfterRegister.Province__c);
        System.assertEquals(newDistrict,targetLeadAfterRegister.District__c);
        System.assertEquals(newSubDistrict,targetLeadAfterRegister.Sub_District__c);
        System.assertEquals(newPostCode,targetLeadAfterRegister.PostCode__c);
        System.assertEquals(newMemo,targetLeadAfterRegister.Memo__c);
        System.assertEquals(null,targetLeadAfterRegister.Account_Number__c);

        Account accountAfterRegister = [SELECT Id,Used_Reward_Amount__c FROM Account WHERE Id = :targetLeadAfterRegister.CIS_ID_Prospect_Name__c];
        System.assertEquals(1000.00,accountAfterRegister.Used_Reward_Amount__c);
    }

    @isTest
    static void testSavingTargetListWithNewAccount(){
    	String newAccountNumber = '1234567890';
    	Rewards__c reward = [SELECT Id,Reward_Name__c,Reward_Amount_Baht__c FROM Rewards__c WHERE NAME = 'R01' LIMIT 1];
 		Target_List__c targetLeadRegister = [SELECT Id,Account_Number__c, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];

        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        RegisterLeadController.WrapperTargetList wrapObject = (RegisterLeadController.WrapperTargetList)JSON.deserialize(resultString,RegisterLeadController.WrapperTargetList.class);
        wrapObject.targetList.Account_Number__c = newAccountNumber;
        String responseString = RegisterLeadController.savingTargetList(JSON.serialize(wrapObject),reward.Id);
		RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.SUCCESS,resultResponse.result);

        Target_List__c targetLeadAfterRegister = [SELECT Id,Status__c,Register__c,Account_Number__c,Memo__c,PostCode__c,Province__c,District__c,Sub_District__c,Address_Street__c,Address_Soi__c,Address_Room__c,Address_Floor__c,Address_Building__c,Address_Mooban__c,Address_Moo__c,Contact_Name__c,Mobile_No__c,Address_House_No__c,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED,targetLeadAfterRegister.Status__c);
        System.assertEquals(true,targetLeadAfterRegister.Register__c);
        System.assertEquals(newAccountNumber,targetLeadAfterRegister.Account_Number__c);

        Account accountAfterRegister = [SELECT Id,Used_Reward_Amount__c FROM Account WHERE Id = :targetLeadAfterRegister.CIS_ID_Prospect_Name__c];
        System.assertEquals(1000.00,accountAfterRegister.Used_Reward_Amount__c);
    }

    @isTest
    static void testSavingTargetListWithNewReward(){
    	Rewards__c reward = [SELECT Id,Reward_Name__c,Reward_Amount_Baht__c FROM Rewards__c WHERE NAME = 'R01' LIMIT 1];
    	Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        String resultString = RegisterLeadController.getRecordInfo(targetLeadRegister.Id);
        String responseString = RegisterLeadController.savingTargetList(resultString,reward.Id);
		RegisterLeadController.ResultResponse resultResponse = (RegisterLeadController.ResultResponse)JSON.deserialize(responseString,RegisterLeadController.ResultResponse.class);
        System.assertEquals(RegisterLeadController.SUCCESS,resultResponse.result);

        Target_List__c targetLeadAfterRegister = [SELECT Id,Status__c,Register__c,Account_Number__c,Campaign_Reward_Calc__c,Campaign_Reward_Amount__c,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED,targetLeadAfterRegister.Status__c);
        System.assertEquals(true,targetLeadAfterRegister.Register__c);
        System.assertEquals(reward.Reward_Name__c,targetLeadAfterRegister.Campaign_Reward_Calc__c);
        System.assertEquals(reward.Reward_Amount_Baht__c,targetLeadAfterRegister.Campaign_Reward_Amount__c);
    }
}