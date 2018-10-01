/**
 * @27/04/2017 Nareerat Wo., CR035 Lead Register
*/
@isTest
private class LeadRegister_Controller_Test {
    public static String accountNameAH = 'accountNameAH';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String newBooking = 'NewBooking';
    public static String uputilized = 'Uputilized';

     @testSetup static void setUpTest(){
       SME_GroupChatterService.isByPassGroupChatterService = true;
        TriggerHandler.bypass('UserTriggerHandler');
        TriggerHandler.bypass('CampaignTriggerHandler');
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            Account newAccount1 = Mockup_Test.newAccountWithSegment(accountNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            newAccount1.Capacity_Max_Reward_Amount__c = 30000;
            newAccount1.Used_Reward_Amount__c = 0;
            insert newAccount1;
            setupCampaign_LeadMaster();
            setupLocationCode();
            setupNewTargetList();
            setUpCampaignReward();
        }
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    public static void setupCampaign_LeadMaster(){
            List<Campaign> campaignList = new List<Campaign>();

            Campaign newBookingCampaign = new Campaign();
            newBookingCampaign.name=newBooking;
            newBookingCampaign.type__c='Lead';
            newBookingCampaign.Lead_Campaign_Event_Code__c=newBooking;
            newBookingCampaign.StartDate=system.today();
            newBookingCampaign.EndDate=system.today().addMonths(1);
            newBookingCampaign.status='Active';
            newBookingCampaign.IsActive=true;

            Campaign uputilizedCampaign = new Campaign();
            uputilizedCampaign.name=uputilized;
            uputilizedCampaign.type__c='Lead';
            uputilizedCampaign.Lead_Campaign_Event_Code__c=uputilized;
            uputilizedCampaign.StartDate=system.today();
            uputilizedCampaign.EndDate=system.today().addMonths(1);
            uputilizedCampaign.status='Active';
            uputilizedCampaign.IsActive=true;

            campaignList.add(newBookingCampaign);
            campaignList.add(uputilizedCampaign);

            insert campaignList;
    }
    
    public static void setupLocationCode() {
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

    public static void setupNewTargetList(){
        Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
        Campaign lead = [SELECT Id FROM Campaign WHERE Name =: newBooking];

        List<Target_List__c> targetLists = new List<Target_List__c>();
        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.Setup_Amount__c = 20000;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        targetLists.add(targetList);

        Campaign lead2 = [SELECT id From Campaign WHERE Name =:uputilized];
        Target_List__c targetList2 = new Target_List__c();
        targetList2.Lead_Campaign__c = lead2.Id;
        targetList2.Setup_Amount__c = 10000;
        targetList2.CIS_ID_Prospect_Name__c = account.Id;
        targetList2.Status__c = GlobalConstants.STATUS_NEW;
        targetLists.add(targetList2);

        insert targetLists;

    }

    public static void setUpCampaignReward() {
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
            Reward_Amount_Baht__c = 5000, 
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
    static void testRegisterNewBookingOwnerBangkokME() {
        String expectRewardCampaignId;
        Business_Code__c buCode;
        User userRM;
        System.runAs(new User(Id=UserInfo.getUserId())){
            userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c = 'ME';
            update userRM;

            buCode = new Business_Code__c(Name = '111111',Segment__c = 'ME',External_ID__c='111111:ME');
            insert buCode;
        }
            
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){    
            Test.startTest();
                Target_List__c target1 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];

                ApexPages.StandardController ctrlLeadRegister = new ApexPages.StandardController(target1);
                ApexPages.currentPage().getParameters().put('id',target1.Id);
                ApexPages.currentPage().getParameters().put('mode','NEW_BOOKING');
                LeadRegister_Controller vcLeadRegister = new LeadRegister_Controller(ctrlLeadRegister);
                List<SelectOption>  rewardOptions = vcLeadRegister.getRewardItems();
                expectRewardCampaignId = rewardOptions.get(rewardOptions.size()-1).getValue();
                vcLeadRegister.campaignReward = expectRewardCampaignId;
                vcLeadRegister.validatePickReward();

                vcLeadRegister.target.Account_Number__c = '0123456789';
                vcLeadRegister.savingtarget();
            Test.stopTest();
        }
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED, targetLeadRegister.Status__c);
        Rewards__c expectRewardCampaign = [SELECT Id, Reward_Amount_Baht__c, Reward_Name__c, Bankok_Zone__c FROM Rewards__c WHERE Id = :expectRewardCampaignId LIMIT 1];
        Team_Structure__c ownerTeam = [SELECT Id, RC_Code__c, Is_Bangkok_Zone__c FROM Team_Structure__c WHERE External_ID__c = :targetLeadRegister.CIS_ID_Prospect_Name__r.Owner.RC_Code__c LIMIT 1];
        System.assertEquals(expectRewardCampaign.Reward_Name__c, targetLeadRegister.Campaign_Reward_Calc__c);
        System.assertEquals(expectRewardCampaign.Reward_Amount_Baht__c, targetLeadRegister.Campaign_Reward_Amount__c);
        System.assertEquals(expectRewardCampaign.Bankok_Zone__c, ownerTeam.Is_Bangkok_Zone__c);
    }

    @isTest
    static void testRegisterNewBookingOwnerBangkokSE() {
        String expectRewardCampaignId;
        Business_Code__c buCode;
        User userRM;
        System.runAs(new User(Id=UserInfo.getUserId())){
            userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c = 'SE';
            update userRM;

            buCode = new Business_Code__c(Name = '111111',Segment__c = 'SE',External_ID__c='111111:SE');
            insert buCode;
        }
            
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){    
            Test.startTest();
                Target_List__c target1 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];

                ApexPages.StandardController ctrlLeadRegister = new ApexPages.StandardController(target1);
                ApexPages.currentPage().getParameters().put('id',target1.Id);
                ApexPages.currentPage().getParameters().put('mode','NEW_BOOKING');
                LeadRegister_Controller vcLeadRegister = new LeadRegister_Controller(ctrlLeadRegister);
                vcLeadRegister.getProvinceItems();
                vcLeadRegister.getDistrictItems();
                vcLeadRegister.getSubDistrictItems();
                vcLeadRegister.getPostCode();
                List<SelectOption>  rewardOptions = vcLeadRegister.getRewardItems();
                expectRewardCampaignId = rewardOptions.get(rewardOptions.size()-1).getValue();
                vcLeadRegister.campaignReward = expectRewardCampaignId;
                vcLeadRegister.validatePickReward();

                vcLeadRegister.target.Mobile_No__c = '0123456789';
                vcLeadRegister.target.Contact_Name__c = '1';
                vcLeadRegister.target.Mobile_No__c = '1';
                vcLeadRegister.target.Address_House_No__c = '2';
                vcLeadRegister.target.Province__c = 'กรุงเทพมหานคร';
                vcLeadRegister.target.District__c = 'เขตพระนคร';
                vcLeadRegister.target.PostCode__c = '12345';
                vcLeadRegister.target.Memo__c = 'Test';
                vcLeadRegister.savingtarget();
            Test.stopTest();
        }
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED, targetLeadRegister.Status__c);
        Rewards__c expectRewardCampaign = [SELECT Id, Reward_Amount_Baht__c, Reward_Name__c, Bankok_Zone__c FROM Rewards__c WHERE Id = :expectRewardCampaignId LIMIT 1];
        Team_Structure__c ownerTeam = [SELECT Id, RC_Code__c, Is_Bangkok_Zone__c FROM Team_Structure__c WHERE External_ID__c = :targetLeadRegister.CIS_ID_Prospect_Name__r.Owner.RC_Code__c LIMIT 1];
        System.assertEquals(expectRewardCampaign.Reward_Name__c, targetLeadRegister.Campaign_Reward_Calc__c);
        System.assertEquals(expectRewardCampaign.Reward_Amount_Baht__c, targetLeadRegister.Campaign_Reward_Amount__c);
        System.assertEquals(expectRewardCampaign.Bankok_Zone__c, ownerTeam.Is_Bangkok_Zone__c);
    }

    @isTest
    static void testRegisterNewBookingOwnerBangkokSEBIULoadReward() {
        String expectRewardCampaignId;
        Business_Code__c buCode;
        User userRM;
        System.runAs(new User(Id=UserInfo.getUserId())){
            userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c = 'SE';
            update userRM;

            buCode = new Business_Code__c(Name = '111111',Segment__c = 'SE',External_ID__c='111111:SE');
            insert buCode;
        }
        Target_List__c target1 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        target1.Campaign_Reward_Calc__c = 'บัตรเงินสด Central';
        target1.Campaign_Reward_Amount__c = 1000;
        update target1;
            
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){    
            Test.startTest();
                ApexPages.StandardController ctrlLeadRegister = new ApexPages.StandardController(target1);
                ApexPages.currentPage().getParameters().put('id',target1.Id);
                ApexPages.currentPage().getParameters().put('mode','NEW_BOOKING');
                LeadRegister_Controller vcLeadRegister = new LeadRegister_Controller(ctrlLeadRegister);
                vcLeadRegister.getProvinceItems();
                vcLeadRegister.getDistrictItems();
                vcLeadRegister.getSubDistrictItems();
                vcLeadRegister.getPostCode();

                vcLeadRegister.target.Mobile_No__c = '0123456789';
                vcLeadRegister.target.Contact_Name__c = '1';
                vcLeadRegister.target.Mobile_No__c = '1';
                vcLeadRegister.target.Address_House_No__c = '2';
                vcLeadRegister.target.Province__c = 'กรุงเทพมหานคร';
                vcLeadRegister.target.District__c = 'เขตพระนคร';
                vcLeadRegister.target.PostCode__c = '12345';
                vcLeadRegister.target.Memo__c = 'Test';
                vcLeadRegister.savingtarget();
            Test.stopTest();
        }
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :newBooking LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED, targetLeadRegister.Status__c);
    }

    @isTest
    static void testRegisterUputilizedWithAddressFlag() {
        Business_Code__c buCode;
        User userRM;
        System.runAs(new User(Id=UserInfo.getUserId())){
            userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c = 'ME';
            update userRM;

            buCode = new Business_Code__c(Name = '111111',Segment__c = 'ME',External_ID__c='111111:ME');
            insert buCode;
        }
            
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){    
            Test.startTest();
                Target_List__c target1 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilized LIMIT 1];

                ApexPages.StandardController ctrlLeadRegister = new ApexPages.StandardController(target1);
                ApexPages.currentPage().getParameters().put('id',target1.Id);
                ApexPages.currentPage().getParameters().put('mode','UP_UTILIZED');
                LeadRegister_Controller vcLeadRegister = new LeadRegister_Controller(ctrlLeadRegister);
                vcLeadRegister.getProvinceItems();
                vcLeadRegister.getDistrictItems();
                vcLeadRegister.getSubDistrictItems();
                vcLeadRegister.getPostCode();

                vcLeadRegister.target.Mobile_No__c = '0123456789';
                vcLeadRegister.target.Contact_Name__c = '1';
                vcLeadRegister.target.Mobile_No__c = '1';
                vcLeadRegister.target.Address_House_No__c = '2';
                vcLeadRegister.target.Province__c = 'กรุงเทพมหานคร';
                vcLeadRegister.target.District__c = 'เขตพระนคร';
                vcLeadRegister.target.PostCode__c = '12345';
                vcLeadRegister.target.Memo__c = 'Test';
                vcLeadRegister.savingtarget();
            Test.stopTest();
        }
        Target_List__c targetLeadRegister = [SELECT Id, Status__c, Campaign_Reward_Calc__c, Campaign_Reward_Amount__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :uputilized LIMIT 1];
        System.assertEquals(GlobalConstants.REGISTERED, targetLeadRegister.Status__c);
    }
}