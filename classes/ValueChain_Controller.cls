/**
* @author komsan.wi@beryl8.com
* @28/09/2015 created new
 * @02/09/2016 Chumphon K., ISCR035 Change reward for Thankyou Campaign
 * @18/01/2017 Chumphon K., ISCR055 Campaign Thankyou Change Condition
*/
public without sharing class ValueChain_Controller {
    public Target_List__c target {get;set;}
    public Boolean shouldReload {get;set;}
    private String[] targetIdArray;
    public static final Id campaignNewBookingID;
    public static final Id campaignThankyouID;
    public static Id OpportunityID;
    public Boolean isNewBooking {get;set;}
    public Boolean isThankyou {get;set;}
    public String optionType {get;set;}
    public String rewardType {get;set;}

    public String Province {get;set;}
    public String District {get;set;}
    public String SubDistrict {get;set;}
    public Target_List__c oldTargetNewBooking {get;set;}
    
    // [Start] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition
    public String ThankyouRewardType {get;set;}
    public Decimal RewardAmount {get;set;}
    public Decimal RefundAmount {get;set;}
    public String Voucher {get;set;}
    public String AccountNumber {get;set;}
    public String ContactName {get;set;}
    public String MobileNumber {get;set;}
    public String AddressHouseNo {get;set;}
    public String AddressMoo {get;set;}
    public String AddressMooban {get;set;}
    public String AddressBuilding {get;set;}
    public String AddressFloor {get;set;}
    public String AddressRoom {get;set;}
    public String AddressSoi {get;set;}
    public String AddressStreet {get;set;}
    public String PostCode {get;set;}
    public String Memo {get;set;}
    // [End] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition

    static {
        String campaignNewBookingCode = Campaign_Setting__c.getOrgDefaults().NewBooking_Code__c;
        String campaignThankyouCode = Campaign_Setting__c.getOrgDefaults().Thankyou_Code__c;
        List<Campaign> listCampaign = [SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign Where (Lead_Campaign_Event_Code__c = :campaignNewBookingCode OR Lead_Campaign_Event_Code__c = :campaignThankyouCode) And IsActive = true];
        for(Campaign eachCampaign : listCampaign) {
            if(eachCampaign.Lead_Campaign_Event_Code__c == campaignNewBookingCode)
                campaignNewBookingID = eachCampaign.Id;
            if(eachCampaign.Lead_Campaign_Event_Code__c == campaignThankyouCode)
                campaignThankyouID = eachCampaign.Id;
        }
    }

    public ValueChain_Controller(ApexPages.StandardController stdController) {
        String valuelist = ApexPages.currentPage().getParameters().get('valuelist');
        String targetid = ApexPages.currentPage().getParameters().get('id');        
        shouldReload = false;
        optionType = '';
        if(valuelist!=null){
            targetIdArray = valuelist.split(',');
        }else {
            targetIdArray = new String[]{targetid};
        }
        CheckNewBooking();
        target = new Target_List__c();

        CheckThankyou();
        if(isThankyou) getRelatedNewBookingAddress();
    }
    
    public ValueChain_Controller() {                
        String valuelist = ApexPages.currentPage().getParameters().get('valuelist');
        targetIdArray = valuelist.split(',');
        optionType = '';
        shouldReload = false;
        CheckNewBooking();
        target = new Target_List__c();

        CheckThankyou();
        if(isThankyou) getRelatedNewBookingAddress();
    }
    
    public void getRelatedNewBookingAddress() {
        if(campaignNewBookingID != null && OpportunityID != null) {
            List<Target_List__c> tmpNewBooking = [Select Id, Mobile_No__c, Contact_Name__c, Address_House_No__c, Address_Moo__c, Address_Mooban__c, Address_Building__c, Address_Floor__c, Address_Room__c, Address_Soi__c, Address_Street__c, Province__c, District__c, Sub_District__c, PostCode__c, Memo__c FROM Target_List__c where Lead_Campaign__c = :campaignNewBookingID And Opportunity__c = :OpportunityID And Status__c = 'Registered'];
            if(tmpNewBooking.size() > 0) {
                oldTargetNewBooking = tmpNewBooking[0];
                //target.Mobile_No__c = oldTargetNewBooking.Mobile_No__c;
                //target.Contact_Name__c = oldTargetNewBooking.Contact_Name__c;
                target.Address_House_No__c = oldTargetNewBooking.Address_House_No__c;
                target.Address_Moo__c = oldTargetNewBooking.Address_Moo__c;
                target.Address_Mooban__c = oldTargetNewBooking.Address_Mooban__c;
                target.Address_Building__c = oldTargetNewBooking.Address_Building__c;
                target.Address_Floor__c = oldTargetNewBooking.Address_Floor__c;
                target.Address_Room__c = oldTargetNewBooking.Address_Room__c;
                target.Address_Soi__c = oldTargetNewBooking.Address_Soi__c;
                target.Address_Street__c = oldTargetNewBooking.Address_Street__c;
                Province = oldTargetNewBooking.Province__c;
                District = oldTargetNewBooking.District__c;
                SubDistrict = oldTargetNewBooking.Sub_District__c;
                target.PostCode__c = oldTargetNewBooking.PostCode__c;
                target.Memo__c = oldTargetNewBooking.Memo__c;

                MobileNumber = oldTargetNewBooking.Mobile_No__c;
                ContactName = oldTargetNewBooking.Contact_Name__c;
            }
        }
    }

    private void CheckNewBooking(){
        List<Target_List__c> targetListNewBooking = [Select Id FROM Target_List__c WHERE Lead_Campaign__c = :campaignNewBookingID and Id in :targetIdArray];
        isNewBooking = (targetListNewBooking !=null && targetListNewBooking.size() > 0) ? true : false;
    }

    private void CheckThankyou(){
        //List<Target_List__c> targetListThankyou = [Select Id, Opportunity__c FROM Target_List__c WHERE Lead_Campaign__c = :campaignThankyouID and Id in :targetIdArray];
        List<Target_List__c> targetListThankyou = [Select Id, Opportunity__c, CIS_ID_Prospect_Name__r.Name, CIS_ID_Prospect_Name__r.Name_TH__c, Campaign_Reward_Amount__c, Send_by_RM__c FROM Target_List__c WHERE Lead_Campaign__c = :campaignThankyouID and Id in :targetIdArray];
        if(targetListThankyou.size() > 0) {
            OpportunityID = targetListThankyou[0].Opportunity__c;

            // [Start] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition
            RewardAmount = (targetListThankyou[0].Campaign_Reward_Amount__c == null)? 0 : targetListThankyou[0].Campaign_Reward_Amount__c;
            target = targetListThankyou[0];
            // [End] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition

            isThankyou = true;
        } else 
            isThankyou = false;
    }

    public void savingtarget(){
        shouldReload = true;
        List<Target_List__c> targetUpdateList = new List<Target_List__c>();
        for(Target_List__c tmpTarget : [Select Id, Lead_Campaign__c, Campaign_Reward_Calc__c FROM Target_List__c WHERE Id IN : targetIdArray]){
            tmpTarget.Status__c = 'Registered';
            tmpTarget.Registered_DateTime__c = System.Now();

            // [Start] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition
            /*
            tmpTarget.Mobile_No__c = target.Mobile_No__c;
            tmpTarget.Registered_DateTime__c = System.Now();
            tmpTarget.Contact_Name__c = target.Contact_Name__c;
            tmpTarget.Address_House_No__c = target.Address_House_No__c;
            tmpTarget.Address_Moo__c = target.Address_Moo__c;
            tmpTarget.Address_Mooban__c = target.Address_Mooban__c;
            tmpTarget.Address_Building__c = target.Address_Building__c;
            tmpTarget.Address_Floor__c = target.Address_Floor__c;
            tmpTarget.Address_Room__c = target.Address_Room__c;
            tmpTarget.Address_Soi__c = target.Address_Soi__c;
            tmpTarget.Address_Street__c = target.Address_Street__c;
            tmpTarget.Province__c = Province;
            tmpTarget.District__c = District;
            tmpTarget.Sub_District__c = SubDistrict;
            tmpTarget.PostCode__c = target.PostCode__c;
            tmpTarget.Memo__c = target.Memo__c;
            */
            tmpTarget.Contact_Name__c = ContactName;
            tmpTarget.Mobile_No__c = MobileNumber;
            tmpTarget.Address_House_No__c = AddressHouseNo;
            tmpTarget.Address_Moo__c = AddressMoo;
            tmpTarget.Address_Mooban__c = AddressMooban;
            tmpTarget.Address_Building__c = AddressBuilding;
            tmpTarget.Address_Floor__c = AddressFloor;
            tmpTarget.Address_Room__c = AddressRoom;
            tmpTarget.Address_Soi__c = AddressSoi;
            tmpTarget.Address_Street__c = AddressStreet;
            tmpTarget.Province__c = Province;
            tmpTarget.District__c = District;
            tmpTarget.Sub_District__c = SubDistrict;
            tmpTarget.PostCode__c = PostCode;
            tmpTarget.Memo__c = Memo;

            if(tmpTarget.Lead_Campaign__c == campaignThankyouID) {
                if(ThankyouRewardType.toUpperCase() == 'VOUCHER') {
                    tmpTarget.Campaign_Reward_Calc__c = Voucher;
                    if(target.Send_by_RM__c) {
                        tmpTarget.Send_by_RM__c = target.Send_by_RM__c;
                    }
                }
                else {
                    List<String> args = new String[]{'0','number','###,###,##0.00'};
                    tmpTarget.Campaign_Reward_Calc__c = ThankyouRewardType +' '+ String.format(RefundAmount.format(), args) + ' บาท';
                    tmpTarget.Campaign_Account_Number__c = AccountNumber;
                    tmpTarget.Campaign_Refund_Amount__c = RefundAmount;
                }
            }
            // [End] Change by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition

            if(tmpTarget.Lead_Campaign__c == campaignNewBookingID){
                tmpTarget.Reward__c = rewardType;
                tmpTarget.Option__c = optionType;
            }
            if(tmpTarget.Lead_Campaign__c == campaignThankyouID) {
                if(oldTargetNewBooking != null) {
                    if(tmpTarget.Mobile_No__c != oldTargetNewBooking.Mobile_No__c || 
                    tmpTarget.Contact_Name__c != oldTargetNewBooking.Contact_Name__c || 
                    tmpTarget.Address_House_No__c != oldTargetNewBooking.Address_House_No__c ||
                    tmpTarget.Address_Moo__c != oldTargetNewBooking.Address_Moo__c ||
                    tmpTarget.Address_Mooban__c != oldTargetNewBooking.Address_Mooban__c ||
                    tmpTarget.Address_Building__c != oldTargetNewBooking.Address_Building__c ||
                    tmpTarget.Address_Floor__c != oldTargetNewBooking.Address_Floor__c ||
                    tmpTarget.Address_Room__c != oldTargetNewBooking.Address_Room__c ||
                    tmpTarget.Address_Soi__c != oldTargetNewBooking.Address_Soi__c ||
                    tmpTarget.Address_Street__c != oldTargetNewBooking.Address_Street__c ||
                    tmpTarget.Province__c != oldTargetNewBooking.Province__c || 
                    tmpTarget.District__c != oldTargetNewBooking.District__c ||
                    tmpTarget.Sub_District__c != oldTargetNewBooking.Sub_District__c ||
                    tmpTarget.PostCode__c != oldTargetNewBooking.PostCode__c) {
                        oldTargetNewBooking.Mobile_No__c = tmpTarget.Mobile_No__c;
                        oldTargetNewBooking.Contact_Name__c = tmpTarget.Contact_Name__c;
                        oldTargetNewBooking.Address_House_No__c = tmpTarget.Address_House_No__c;
                        oldTargetNewBooking.Address_Moo__c = tmpTarget.Address_Moo__c;
                        oldTargetNewBooking.Address_Mooban__c = tmpTarget.Address_Mooban__c;
                        oldTargetNewBooking.Address_Building__c = tmpTarget.Address_Building__c;
                        oldTargetNewBooking.Address_Floor__c = tmpTarget.Address_Floor__c;
                        oldTargetNewBooking.Address_Room__c = tmpTarget.Address_Room__c;
                        oldTargetNewBooking.Address_Soi__c = tmpTarget.Address_Soi__c;
                        oldTargetNewBooking.Address_Street__c = tmpTarget.Address_Street__c;
                        oldTargetNewBooking.Province__c = tmpTarget.Province__c;
                        oldTargetNewBooking.District__c = tmpTarget.District__c;
                        oldTargetNewBooking.Sub_District__c = tmpTarget.Sub_District__c;
                        oldTargetNewBooking.PostCode__c = tmpTarget.PostCode__c;
                        targetUpdateList.add(oldTargetNewBooking);
                    }
                }
            }
            targetUpdateList.add(tmpTarget);
        }
        try{
            update targetUpdateList;    
        }catch(Exception ex){
            shouldReload = false;
        }
    }

    public List<SelectOption> getOptionTypeItems() {        
        return getTypeItems(Target_List__c.Option__c.getDescribe(),false);
    }

    public List<SelectOption> getRewardTypeItems() {         
        return getTypeItems(Target_List__c.Reward__c.getDescribe(),true);
    }

    private List<SelectOption> getTypeItems(Schema.DescribeFieldResult fieldResult,boolean isCombobox) {
        List<SelectOption> options = new List<SelectOption>();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(isCombobox){
            options.add(new SelectOption('','Please Select'));   
        }
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getValue(),f.getLabel()));
        }       
        return options;
    }

    public List<SelectOption> getProvinceItems() {
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));
        for(AggregateResult[] ProvinceList : [Select Province__c From Location_Code__c Group by Province__c ]) {
            for(AggregateResult ar : ProvinceList) {
                options.add(new SelectOption((String)ar.get('Province__c'), (String)ar.get('Province__c')));
            }
        }
        return options;
    }

    public List<SelectOption> getDistrictItems() {
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));
        if(Province != 'none'){
            for(AggregateResult[] DistrictList : [Select District__c From Location_Code__c Where Province__c = :Province Group by District__c ]) {
                for(AggregateResult ar : DistrictList) {
                    options.add(new SelectOption((String)ar.get('District__c'), (String)ar.get('District__c')));
                }
            }
        }
        return options;
    }

    public List<SelectOption> getSubDistrictItems() {
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));
        if(Province != 'none' && District != 'none'){
            for(AggregateResult[] DistrictList : [Select Sub_District__c From Location_Code__c Where Province__c = :Province And District__c = :District Group by Sub_District__c ]) {
                for(AggregateResult ar : DistrictList) {
                    options.add(new SelectOption((String)ar.get('Sub_District__c'), (String)ar.get('Sub_District__c')));
                }
            }
        }
        return options;
    }

    public void getPostCode() {
        //target.PostCode__c = '';
        PostCode = '';
        if(Province != 'none' && District != 'none' && SubDistrict != 'none') {
            List<Location_Code__c> lc = [Select PostCode__c From Location_Code__c Where Province__c =:Province And District__c =:District And Sub_District__c =:SubDistrict];
            //if(lc.size() > 0) target.PostCode__c = lc[0].PostCode__c;
            if(lc.size() > 0) PostCode = lc[0].PostCode__c;
        }
    }

    // [Start] Add by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition
    public List<SelectOption> getThankyouRewardTypeItems() {         
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));

        List<Campaign_Reward__c> listCampaignReward = Campaign_Reward__c.getAll().Values();
        for (Campaign_Reward__c eachVoucher : listCampaignReward) {
            if(eachVoucher.Reward_Type__c.toUpperCase() == 'REWARD TYPE') {
                options.add(new SelectOption(eachVoucher.Reward_Name__c, eachVoucher.Reward_Name__c));
            }
        }
        return options;
    }

    public List<SelectOption> getVoucherItems() {
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));

        List<Campaign_Reward__c> listCampaignReward = Campaign_Reward__c.getAll().Values();
        Decimal DynamicAmount = 0;
        String DynamicVoucher;
        for (Campaign_Reward__c eachVoucher : listCampaignReward) {
            if(eachVoucher.Reward_Type__c.toUpperCase() == 'DYNAMIC') {
                if(RewardAmount >= eachVoucher.Reward_Amount__c){
                    if(eachVoucher.Reward_Amount__c > DynamicAmount){
                        DynamicAmount = eachVoucher.Reward_Amount__c;
                        DynamicVoucher = eachVoucher.Reward_Name__c;
                    }
                }
            }
        }
        if(DynamicVoucher != null){
            options.add(new SelectOption(DynamicVoucher, DynamicVoucher));
        }
        else{
            for (Campaign_Reward__c eachVoucher : listCampaignReward) {
                if(eachVoucher.Reward_Type__c.toUpperCase() == 'VOUCHER') {
                    options.add(new SelectOption(eachVoucher.Reward_Name__c, eachVoucher.Reward_Name__c));
                }
            }
        }
        return options;
    } 
    // [End] Add by Chumphon K., 18/01/2017 ISCR055 Campaign Thankyou Change Condition
}