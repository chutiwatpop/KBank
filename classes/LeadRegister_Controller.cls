/**
 * @10/01/2018 PCR040
*/
public without sharing class LeadRegister_Controller {
    private ApexPages.StandardController mController;
    Map<Id, Rewards__c> campaignRewardMap;
    private Boolean isBangkokZone;

    public Target_List__c target {get;set;}
    public Boolean shouldReload {get;set;}
    public Boolean isSelectable {get;set;}
    public Boolean isShowAddressSection {get;set;}
    public Boolean isShowRewardSection {get;set;}
    public String pageTitle {get;set;}
    public String campaignReward {get;set;}
    public String campaignMode;

    public LeadRegister_Controller (ApexPages.StandardController stdController) {
        this.mController = stdController;
        campaignMode = ApexPages.currentPage().getParameters().get('mode');
        if(ApexPages.currentPage().getParameters().containsKey('id') == false) throw new NoAccessException();
        try {
            this.target = (Target_List__c) this.mController.getRecord();
            this.target = [Select Id, Reward__c, CIS_ID_Prospect_Name__r.Name, CIS_ID_Prospect_Name__r.Name_TH__c, CIS_ID_Prospect_Name__r.Owner.Segment__c, CIS_ID_Prospect_Name__r.Owner.RC_Code__c, Campaign_Reward_Amount__c, Campaign_Reward_Calc__c, Contact_Name__c,Mobile_No__c,Address_House_No__c,Address_Moo__c,Address_Mooban__c,Address_Building__c,Address_Floor__c,Address_Room__c,Address_Soi__c,Address_Street__c,Province__c,District__c,Sub_District__c,PostCode__c,Memo__c,Account_Number__c,Setup_Amount__c FROM Target_List__c WHERE  Id = :target.Id LIMIT 1];
            String ownerRcCode = this.target.CIS_ID_Prospect_Name__r.Owner.RC_Code__c;

            if(ownerRcCode != null) {
                Team_Structure__c ownerTeam = [SELECT Id, RC_Code__c, Is_Bangkok_Zone__c FROM Team_Structure__c WHERE External_ID__c = :ownerRcCode];
                isBangkokZone = ownerTeam.Is_Bangkok_Zone__c;
            }
            isShowAddressSection = true;
            if(campaignMode == 'UP_UTILIZED') {
                pageTitle = 'ลงทะเบียนที่อยู่';
                isShowRewardSection = false;
                if(target.Campaign_Reward_Calc__c != null) {
                    isSelectable = false;
                    isShowRewardSection = true;
                    campaignReward = target.Campaign_Reward_Calc__c;
                    if(target.Campaign_Reward_Amount__c != null) {
                        campaignReward = campaignReward + ' ' + target.Campaign_Reward_Amount__c;
                    }
                }
            } else if(campaignMode == 'NEW_BOOKING') {
                pageTitle = 'ลงทะเบียนรับของรางวัล';
                isSelectable = true;
                isShowRewardSection = true;
                if(target.Campaign_Reward_Calc__c != null && target.Campaign_Reward_Amount__c != null) {
                    isSelectable = false;
                    campaignReward = target.Campaign_Reward_Calc__c + ' ' + target.Campaign_Reward_Amount__c;
                    if(target.Account_Number__c != null || (target.Reward__c != null && target.Reward__c.equalsIgnoreCase(GlobalConstants.CASHBACK))) 
                        isShowAddressSection = false;
                }
            } else {
                throw new LeadRegisterException('Invalid Parameters!');
            }

            campaignRewardMap = new Map<Id, Rewards__c>([SELECT Id, Reward_Name__c, Reward_Amount_Baht__c, Reward_Type__c, Min_Amount__c, Max_Amount__c, Bankok_Zone__c, RM_Segment__c FROM Rewards__c]);
            shouldReload = false;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public List<SelectOption> getRewardItems() {
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('none',''));
        for(Rewards__c eachCampaignReward : campaignRewardMap.values()) {
            if((target.Setup_Amount__c >= eachCampaignReward.Min_Amount__c && target.Setup_Amount__c <= eachCampaignReward.Max_Amount__c)
                && target.CIS_ID_Prospect_Name__r.Owner.Segment__c == eachCampaignReward.RM_Segment__c 
                && isBangkokZone == eachCampaignReward.Bankok_Zone__c)
            options.add(new SelectOption(eachCampaignReward.Id, eachCampaignReward.Reward_Name__c + ' ' + eachCampaignReward.Reward_Amount_Baht__c));
        }
        return options;
    }

    public void validatePickReward() {
        if(campaignReward != 'none' && campaignRewardMap.containsKey(campaignReward)) {
            if(campaignRewardMap.get(campaignReward).Reward_Type__c != null && campaignRewardMap.get(campaignReward).Reward_Type__c.equalsIgnoreCase(GlobalConstants.CASHBACK)) {
                isShowAddressSection = false;
            } else {
                isShowAddressSection = true;
            }
        }
    }
    
    public void savingtarget(){
        shouldReload = false;
        Target_List__c oldTarget = [Select Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.Used_Reward_Amount__c ,CIS_ID_Prospect_Name__r.Capacity_Max_Reward_Amount__c,CIS_ID_Prospect_Name__r.Name, CIS_ID_Prospect_Name__r.Name_TH__c, Campaign_Reward_Amount__c, Campaign_Reward_Calc__c, Contact_Name__c,Mobile_No__c,Address_House_No__c,Address_Moo__c,Address_Mooban__c,Address_Building__c,Address_Floor__c,Address_Room__c,Address_Soi__c,Address_Street__c,Province__c,District__c,Sub_District__c,PostCode__c,Memo__c,Account_Number__c FROM Target_List__c WHERE  Id = :target.Id LIMIT 1];
        target.Status__c = GlobalConstants.REGISTERED;
        target.Registered_DateTime__c = System.Now();
        target.Register__c = true;
        Account targetAccount;
        if(campaignMode == 'NEW_BOOKING' && isShowRewardSection == true) {
            if(campaignReward == 'none') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'กรุณาเลือกของรางวัล'));
                return;
            }
            if(isSelectable == true && campaignRewardMap.containsKey(campaignReward)) {
                target.Campaign_Reward_Calc__c = campaignRewardMap.get(campaignReward).Reward_Name__c;
                target.Campaign_Reward_Amount__c = campaignRewardMap.get(campaignReward).Reward_Amount_Baht__c;
            } else if(isSelectable == false) {
                target.Campaign_Reward_Calc__c = oldTarget.Campaign_Reward_Calc__c;
                target.Campaign_Reward_Amount__c = oldTarget.Campaign_Reward_Amount__c;
            }
            
            Decimal capMax = convertNullDecimaltoZero(oldTarget.CIS_ID_Prospect_Name__r.Capacity_Max_Reward_Amount__c);
            Decimal newUsed = convertNullDecimaltoZero(oldTarget.CIS_ID_Prospect_Name__r.Used_Reward_Amount__c) + convertNullDecimaltoZero(target.Campaign_Reward_Amount__c);
            if(newUsed > capMax) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ไม่สามารถลงทะเบียนได้ เนื่องจากลูกค้าได้รับของรางวัลเกินมูลค่าที่ส่วนกลางกำหนดไว้'));
                return;
            }
            targetAccount = new Account(
                Id = target.CIS_ID_Prospect_Name__c, 
                Used_Reward_Amount__c = newUsed
            );
        }
            
        if(isShowAddressSection) {
            target.Account_Number__c = oldTarget.Account_Number__c;
        } else {
            target.Contact_Name__c = oldTarget.Contact_Name__c;
            target.Mobile_No__c = oldTarget.Mobile_No__c;
            target.Address_House_No__c = oldTarget.Address_House_No__c;
            target.Address_Moo__c = oldTarget.Address_Moo__c;
            target.Address_Mooban__c = oldTarget.Address_Mooban__c;
            target.Address_Building__c = oldTarget.Address_Building__c;
            target.Address_Floor__c = oldTarget.Address_Floor__c;
            target.Address_Room__c = oldTarget.Address_Room__c;
            target.Address_Soi__c = oldTarget.Address_Soi__c;
            target.Address_Street__c = oldTarget.Address_Street__c;
            target.Province__c = oldTarget.Province__c;
            target.District__c = oldTarget.District__c;
            target.Sub_District__c = oldTarget.Sub_District__c;
            target.PostCode__c = oldTarget.PostCode__c;
            target.Memo__c = oldTarget.Memo__c;
        }

        try{
            if(targetAccount != null) {
                TriggerHandler.bypass('AccountTriggerHandler');
                update targetAccount;
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
            update target;
            shouldReload = true;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return;
        }
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
        if(target.Province__c != 'none'){
            for(AggregateResult[] DistrictList : [Select District__c From Location_Code__c Where Province__c = :target.Province__c Group by District__c ]) {
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
        if(target.Province__c != 'none' && target.District__c != 'none'){
            for(AggregateResult[] DistrictList : [Select Sub_District__c From Location_Code__c Where Province__c = :target.Province__c And District__c = :target.District__c Group by Sub_District__c ]) {
                for(AggregateResult ar : DistrictList) {
                    options.add(new SelectOption((String)ar.get('Sub_District__c'), (String)ar.get('Sub_District__c')));
                }
            }
        }
        return options;
    }

    public void getPostCode() {
        target.PostCode__c = '';
        if(target.Province__c != 'none' && target.District__c != 'none' && target.Sub_District__c != 'none') {
            List<Location_Code__c> lc = [Select PostCode__c From Location_Code__c Where Province__c =:target.Province__c And District__c =:target.District__c And Sub_District__c =:target.Sub_District__c];
            if(lc.size() > 0) target.PostCode__c = lc[0].PostCode__c;
        }
    }

    private Decimal convertNullDecimaltoZero(Decimal inputDecimal) {
        if(inputDecimal == null) return 0;
        return inputDecimal;
    }

    public class LeadRegisterException extends Exception {}
}