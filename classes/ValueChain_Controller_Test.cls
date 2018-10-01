/*
 * Created by: Chumphon K.
 * Created date: 07-Sep-2016
 * Description: ISCR035 Change reward for Thankyou Campaign
 * Modification List:
 * Name             Date            Modification Description
 * ----------       -----------     ------------------------------
 * Chumphon K.      23-Jan-2017     ISCR055 Campaign Thankyou Change Condition
 */
@isTest
private class ValueChain_Controller_Test {
    public static String accountNameAH = 'accountNameAH';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static string strNewBooking='NEWBOOKING';
    public static string strThankyou='THANKYOU';

    @testSetup static void setUpTest(){
        /*
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        } */
        
        TriggerHandler.bypass('UserTriggerHandler');
        TriggerHandler.bypass('CampaignTriggerHandler');
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            setupCampaign();
            setupLocationCode();
        }
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    public static void setupCampaign(){
            Campaign_Setting__c cSetting = new Campaign_Setting__c();
            cSetting.NewBooking_Code__c= strNewBooking;
            cSetting.ThankYou_Code__c= strThankyou;
            cSetting.Register_Period__c=30;
            
            //[Start] Change by Chumphon K., 23/01/2017 ISCR055
            //cSetting.Thankyou_Setup_Amount__c = 1000000;
            //cSetting.Thankyou_Max_Reward__c = 50000;
            //cSetting.Thankyou_Divisor__c = 1000000;
            //cSetting.Thankyou_ME_Prize__c = 1000;
            //cSetting.Thankyou_SE_Prize__c = 2000;
            insert cSetting;
            
            List<Campaign_Reward__c> listCampaignReward = new List<Campaign_Reward__c>();
            listCampaignReward.add(new Campaign_Reward__c(Name='ลดค่าประเมิน', Reward_Type__c = 'REWARD TYPE', Reward_Name__c = 'ลดค่าประเมิน'));
            listCampaignReward.add(new Campaign_Reward__c(Name='ลดค่าจำนอง', Reward_Type__c = 'REWARD TYPE', Reward_Name__c = 'ลดค่าจำนอง'));
            listCampaignReward.add(new Campaign_Reward__c(Name='Cashback', Reward_Type__c = 'REWARD TYPE', Reward_Name__c = 'Cashback'));
            listCampaignReward.add(new Campaign_Reward__c(Name='Voucher', Reward_Type__c = 'REWARD TYPE', Reward_Name__c = 'Voucher'));
            listCampaignReward.add(new Campaign_Reward__c(Name='PTT', Reward_Type__c = 'VOUCHER', Reward_Name__c = 'บัตรเติมน้ำมัน ปตท'));
            listCampaignReward.add(new Campaign_Reward__c(Name='Centara', Reward_Type__c = 'VOUCHER', Reward_Name__c = 'บัตรเงินสด Centara'));
            listCampaignReward.add(new Campaign_Reward__c(Name='Central', Reward_Type__c = 'VOUCHER', Reward_Name__c = 'บัตรเงินสด Central'));
            listCampaignReward.add(new Campaign_Reward__c(Name='Tesco', Reward_Type__c = 'VOUCHER', Reward_Name__c = 'บัตรเงินสด Tesco'));
            insert listCampaignReward;
            //[End] Change by Chumphon K., 23/01/2017 ISCR055
            
            List<Campaign> campaignList = new List<Campaign>();
            Campaign CampaignNewBooking = new Campaign();
            CampaignNewBooking.name=strNewBooking;
            CampaignNewBooking.type__c='Campaign';
            CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
            CampaignNewBooking.StartDate=system.today();
            CampaignNewBooking.status='Active';
            CampaignNewBooking.IsActive=true;      
            //CampaignNewBooking.Address_Registration__c = 'Yes';    
            campaignList.add(CampaignNewBooking);
        
            Campaign CampaignThankyou = new Campaign();
            CampaignThankyou.name=strThankyou;
            CampaignThankyou.type__c='Campaign';
            CampaignThankyou.Lead_Campaign_Event_Code__c=strThankyou;
            CampaignThankyou.StartDate=system.today();
            CampaignThankyou.status='Active';
            CampaignThankyou.IsActive=true;
            CampaignThankyou.Address_Registration__c = 'Yes';         
            campaignList.add(CampaignThankyou);
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

    @isTest static  void testStandard() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

            Account testAcc = [SELECT Id FROM Account WHERE Name = :ValueChain_Controller_Test.accountNameAH LIMIT 1];
            testAcc.OwnerId = UserInfo.getUserId();
            update testAcc;
            
            Test.startTest();
                Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
                insert camp;

                Target_List__c target = new Target_List__c();
                target.Lead_Campaign__c = camp.Id;
                target.CIS_ID_Prospect_Name__c = testAcc.Id;
                insert target;

                ApexPages.StandardController stdController = new ApexPages.StandardController(target);

                ApexPages.currentPage().getParameters().put('id',target.Id);
                ValueChain_Controller ctrl = new ValueChain_Controller(stdController);
                ctrl.savingtarget();

            Test.stopTest();
        }
    }

    @isTest static  void testArray() {
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

            Account testAcc = [SELECT Id FROM Account WHERE Name = :ValueChain_Controller_Test.accountNameAH LIMIT 1];
            testAcc.OwnerId = UserInfo.getUserId();
            update testAcc;
            
            Test.startTest();
                Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
                insert camp;

                Target_List__c target = new Target_List__c();
                target.Lead_Campaign__c = camp.Id;
                target.CIS_ID_Prospect_Name__c = testAcc.Id;
                insert target;

                ApexPages.currentPage().getParameters().put('valuelist',target.Id);

                ValueChain_Controller ctrl = new ValueChain_Controller();
                                
                ctrl.savingtarget();
            Test.stopTest();

            Target_List__c finalTarget = [SELECT Id, Status__c FROM Target_List__c WHERE Id = :target.Id];
            System.assertEquals('Registered', finalTarget.Status__c);
        }
    }
    
    @isTest static  void testRegisterCampaign() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = GlobalConstants.SEGMENT_ME;
        TriggerHandler.bypass('UserTriggerHandler');
        update userRM;
        TriggerHandler.clearBypass('UserTriggerHandler');

        Account targetAccount;
        Campaign[] targetCampaign;
        Business_Code__c newBusinessCode;
        System.runAs(new User(Id=UserInfo.getUserId())){
            newBusinessCode = new Business_Code__c();
            newBusinessCode.Name = 'test class';
            newBusinessCode.Segment__c = GlobalConstants.SEGMENT_ME;
            newBusinessCode.External_ID__c = 'testRegisterCampaign';
            insert newBusinessCode;
        }

        System.runAs(userRM) {
            targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
            targetAccount.Customer_s_Business_Code__c = '111111';
            TriggerHandler.bypass('AccountTriggerHandler');
            update targetAccount;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }

        Opportunity opp1;
        System.runAs(userRM){
            opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestNewOpp_1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
            opp1.Owner = userRM;
            opp1.Owner_Segment_Business_Code__c = GlobalConstants.SEGMENT_ME;
            opp1.Business_Code__c = newBusinessCode.Id;
            opp1.Application_Number__c = 'testRegisterCampaign';
            insert opp1;

            targetCampaign = [select id, Lead_Campaign_Event_Code__c, name from Campaign];
            System.debug('Phon targetCampaign1 : ' +targetCampaign[0]);
            System.debug('Phon targetCampaign2 : ' +targetCampaign[1]);


            List<Target_List__c> targetList = new List<Target_List__c>();

            Target_List__c target1 = new Target_List__c();
            target1.Lead_Campaign__c = targetCampaign[0].Id;
            target1.CIS_ID_Prospect_Name__c = targetAccount.Id;
            target1.Status__c = GlobalConstants.STOCK_NEGOTIATION;
            target1.opportunity__c = opp1.id;
            targetList.add(target1);

            Target_List__c target2 = new Target_List__c();
            target2.Lead_Campaign__c = targetCampaign[1].Id;
            target2.CIS_ID_Prospect_Name__c = targetAccount.Id;
            target2.Status__c = GlobalConstants.STOCK_NEGOTIATION;
            target2.opportunity__c = opp1.id;
            targetList.add(target2);

            insert targetList;
        }    

        System.runAs(userRM){ 
            opp1.Actual_Application_Submit_Date__c=system.today();
            opp1.Actual_RM_Submit_Date__c=system.today();
            opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
            opp1.Approval_Status__c = 'Final Approve';
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update opp1;
            TriggerHandler.clearbypass('OpportunityTriggerHandler');

            Application_History__c appHis = new Application_History__c(
                OppName__c = opp1.Id,
                RMCreditModel__c = 'DLA',
                RMSubmitChannel__c = 'Non CMAS',
                TentativeSubmitDate__c = System.today() + 1
            );
            insert appHis;
            
            Opportunity_Product__c newOppPro = new Opportunity_Product__c();
            newOppPro.Opportunity__c = opp1.Id;
            newOppPro.Approved_Amount__c = 10000000;
            insert newOppPro;
        }

        Test.startTest();  
        Setup_History__c oppProduct1 = new Setup_History__c();
        System.runAs(userRM){    
                opp1.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
                opp1.Approval_Status__c = 'Final Approve';
                TriggerHandler.bypass('OpportunityTriggerHandler');
                update opp1;
                TriggerHandler.clearbypass('OpportunityTriggerHandler');
                oppProduct1.Product__c='ตั้งวงเงินทั้งหมดในครั้งแรก';
                oppProduct1.Status__c='Setup';
                oppProduct1.Opportunity__c=opp1.Id;
                oppProduct1.Setup_Amount__c=1000001;
                oppProduct1.Setup_Date__c=system.today();
                oppProduct1.Front_End_Fee__c=500000;
                oppProduct1.BA_Prosaving__c=500000;
                oppProduct1.BA_Protection__c=500000;
                oppProduct1.For_Refinance_In__c='TISCO-ธ.ทิสโก้';

                insert oppProduct1;
        }
        
        System.runAs(userRM){
                Target_List__c target1 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and opportunity__c = :opp1.Id LIMIT 1];
        
                System.debug('Phon target1 : ' + target1);
                ApexPages.StandardController ctrlNewBooking = new ApexPages.StandardController(target1);
                ApexPages.currentPage().getParameters().put('id',target1.Id);
                ValueChain_Controller vcNewBooking = new ValueChain_Controller(ctrlNewBooking);
                vcNewBooking.getProvinceItems();
                vcNewBooking.getDistrictItems();
                vcNewBooking.getSubDistrictItems();
                vcNewBooking.getPostCode();
                vcNewBooking.getOptionTypeItems();
                vcNewBooking.getRewardTypeItems();
                //vcNewBooking.getTypeItems();
            
                vcNewBooking.target.Mobile_No__c = '0123456789';
                vcNewBooking.target.Contact_Name__c = '1';
                vcNewBooking.target.Address_House_No__c = '2';
                vcNewBooking.Province = 'กรุงเทพมหานคร';
                vcNewBooking.District = 'เขตพระนคร';
                vcNewBooking.SubDistrict = 'พระบรมมหาราชวัง';
                vcNewBooking.target.PostCode__c = '12345';
                vcNewBooking.target.Memo__c = 'Test';
                vcNewBooking.savingtarget();

                opp1.StageName = GlobalConstants.ALL_LOAN_SETUP;            
                update opp1; 
            
                Target_List__c target2 = [SELECT Id, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strThankyou and opportunity__c = :opp1.Id LIMIT 1];
                ApexPages.StandardController ctrlThankyou = new ApexPages.StandardController(target2);
                ApexPages.currentPage().getParameters().put('id',target2.Id);
                ValueChain_Controller vcThankyou = new ValueChain_Controller(ctrlThankyou);
                
                //[Start] Add by Chumphon K., 23/01/2017 ISCR055
                //vcThankyou.getProvinceItems();
                //vcThankyou.getDistrictItems();
                //vcThankyou.getSubDistrictItems();
                //vcThankyou.getPostCode();
                //vcThankyou.getThankyouRewardTypeItems();
                //vcThankyou.getVoucherItems();
            
                vcThankyou.ThankyouRewardType = 'Voucher';
                vcThankyou.Voucher = 'บัตรเงินสด Centara';
                vcThankyou.Province = 'กรุงเทพมหานคร';
                vcThankyou.District = 'เขตพระนคร';
                vcThankyou.SubDistrict = 'พระบรมมหาราชวัง';
                vcThankyou.target.Contact_Name__c = 'Test';
                vcThankyou.target.Mobile_No__c = '0123456789';
                vcThankyou.target.Send_by_RM__c = true;
                vcThankyou.savingtarget();
                
                vcThankyou.ThankyouRewardType = 'ลดค่าประเมิน';
                vcThankyou.AccountNumber = '0123456789';
                vcThankyou.RefundAmount = 1000;
                //[End] Add by Chumphon K., 23/01/2017 ISCR055
                
                vcThankyou.savingtarget();
            
            Test.stopTest();
            
            Target_List__c targetNewBooking = [SELECT Id, Status__c, Campaign_Reward_Calc__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and opportunity__c = :opp1.Id LIMIT 1];
            System.assertEquals('Registered', targetNewBooking.Status__c);
            System.assertNotEquals('-', targetNewBooking.Campaign_Reward_Calc__c);
        }
    }
}