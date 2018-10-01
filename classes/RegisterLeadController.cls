public without sharing class RegisterLeadController {
	public static final String ERROR = 'ERROR';
	public static final String SUCCESS = 'SUCCESS';
	public static final String SUCCESS_MESSAGE = 'Save success.';
	public static final String CUSTOMER_ALREADY_REGISTERED = Label.Lead_Customer_Already_Register;
	public static final String STATUS_MUST_BE_NEW = Label.Lead_Status_Must_Be_New;
	public static final String TYPE_MUST_BE_CAMPAIGN = Label.Lead_Type_Must_Be_Campaign;
	public static final String PLEASE_INPUT_REWARD = Label.Lead_Please_Input_Reward;
	public static final String USED_OVER_CAP_MAX = Label.Lead_Used_Over_Cap_Max;
	public static final String REGISTER_REWARD = Label.Lead_Register_Reward;
	public static final String REGISTER_ADDRESS = Label.Lead_Register_Address;
	public static Boolean isBangkokZone;
	public static List<String> listDistrict;
	public static List<String> listSubDistrict;
	public static List<String> listProvince;
	public static Map<Id, Rewards__c> allCampaignRewardMap;
	public class WrapperTargetList{
		public Target_List__c targetList;
		public String contactPersonLabel;
		public String mobileNoLabel;
		public String houseNoLabel;
		public String mooLabel;
		public String villageLabel;
		public String buildingLabel;
		public String floorLabel;
		public String roomLabel;
		public String soiLabel;
		public String streetLabel;
		public String provinceLabel;
		public String districtLabel;
		public String subDistrictLabel;
		public String postCodeLabel;
		public String memoLabel;
		public String accountNumberLabel;
		public Integer maxHeight;
		public Boolean canUpdateImmediately;
		public Boolean isNewBooking;
		public Boolean mustSelectReward;
		public Boolean isShowAddressSection;
		public Boolean isShowRewardSection;
		public String pageHeaderTitle;
		public String pageDetailTitle = 'กรุณากรอกข้อมูลของลูกค้าที่ได้รับของรางวัลให้ครบถ้วน';
		public String rewardLabel = 'ของรางวัล';
		public Map<String,String> mapReward;
    }
    public class ResultResponse{
    	public String result;
    	public String message;
        public Boolean isMobile;
    }

    @Auraenabled
    public static String canRegister(String tglIdString) {
    	ResultResponse response = new ResultResponse();
    	response.result=SUCCESS;
        response.isMobile = UserInfo.getUiThemeDisplayed() == 'Theme4t'?true:false;
    	Target_List__c currentTgl = [SELECT Status__c,Lead_Campaign__r.Type__c FROM Target_List__c WHERE Id =:tglIdString];
        if(currentTgl.Status__c == GlobalConstants.REGISTERED){
        	response.result=ERROR;
        	response.message=CUSTOMER_ALREADY_REGISTERED;
        }else if(currentTgl.Lead_Campaign__r.Type__c != GlobalConstants.CAMPAIGN){
            response.result=ERROR;
            response.message=TYPE_MUST_BE_CAMPAIGN;
        }else if(currentTgl.Status__c != GlobalConstants.STATUS_NEW){
        	response.result=ERROR;
        	response.message=STATUS_MUST_BE_NEW;
        }
        return Json.serialize(response);
    }

    @Auraenabled
    public static String getRecordInfo(String tglIdString) {
    	WrapperTargetList wrapObject = new WrapperTargetList();
    	getTargetListInfo(wrapObject,tglIdString);
        getFieldLabel(wrapObject);
        wrapObject.mapReward = getRewardItems(String.valueOf(wrapObject.targetList.Setup_Amount__c),wrapObject.targetList.CIS_ID_Prospect_Name__r.Owner.Segment__c);
        return Json.serialize(wrapObject);
    }

    @Auraenabled
    public static String getDistrictPickListValues(String selectedProvince){
    	Set<String> setDistrict = new Set<String>();
        setDistrict.add('');
        List<Global_Master_Data__c> listLocation = [Select LocationCode_District__c From Global_Master_Data__c Where LocationCode_Province__c = :selectedProvince AND RecordType.DeveloperName='LocationCode'];
        for(Global_Master_Data__c eachDistrict : listLocation) {
            setDistrict.add(eachDistrict.LocationCode_District__c);
        }
        List<String> listDistrict = new List<String>(setDistrict);
        listDistrict.sort();
        return Json.serialize(listDistrict);
    }

    @Auraenabled
    public static String getSubDistrictPickListValues(String selectedProvince,String selectedDistrict){
        Set<String> setSubDistrict = new Set<String>();
        setSubDistrict.add('');
        List<Global_Master_Data__c> listLocation = [Select LocationCode_SubDistrict__c From Global_Master_Data__c Where LocationCode_Province__c = :selectedProvince And LocationCode_District__c = :selectedDistrict AND RecordType.DeveloperName='LocationCode'];
        for(Global_Master_Data__c eachSubDistrict : listLocation) {
            setSubDistrict.add(eachSubDistrict.LocationCode_SubDistrict__c);
        }
        List<String> listSubDistrict = new List<String>(setSubDistrict);
        listSubDistrict.sort();
        return Json.serialize(listSubDistrict);
    }

    @Auraenabled
    public static String getProvincePickListValues(){
        Set<String> setProvince = new Set<String>();
        setProvince.add('');
        List<Global_Master_Data__c> listLocation = [Select LocationCode_Province__c From Global_Master_Data__c WHERE LocationCode_District__c = null AND LocationCode_SubDistrict__c = null AND RecordType.DeveloperName='LocationCode'];
        for(Global_Master_Data__c eachProvince : listLocation) {
            setProvince.add(eachProvince.LocationCode_Province__c);
        }
        List<String> listProvince = new List<String>(setProvince);
        listProvince.sort();
        return Json.serialize(listProvince);
    }

    @Auraenabled
    public static String getPostCode(String selectedProvince,String selectedDistrict,String selectedSubDistrict){
        List<Global_Master_Data__c> lc = [Select LocationCode_PostCode__c From Global_Master_Data__c Where LocationCode_Province__c =:selectedProvince And LocationCode_District__c =:selectedDistrict And LocationCode_SubDistrict__c =:selectedSubDistrict AND RecordType.DeveloperName='LocationCode'];
        if(lc.size() > 0) return lc[0].LocationCode_PostCode__c;
        return '';
    }

    @Auraenabled
    public static Boolean validatePickReward(String campaignReward) {
        getRewardMap();
        if(!String.isBlank(campaignReward) && allCampaignRewardMap.containsKey(campaignReward)) {
            if(allCampaignRewardMap.get(campaignReward).Reward_Type__c != null && allCampaignRewardMap.get(campaignReward).Reward_Type__c.equalsIgnoreCase(GlobalConstants.CASHBACK)) {
                return false;
            }
        }
        return true;
    }

    @Auraenabled
    public static String savingTargetListImmediately(String inputWrapTargetListString){
    	ResultResponse response = new ResultResponse();
    	try{
	    	getRewardMap();
	    	WrapperTargetList inputWrapTglObject = (WrapperTargetList)JSON.deserialize(inputWrapTargetListString,WrapperTargetList.class);
	    	Target_List__c inputTglObject = inputWrapTglObject.targetList;
	        Target_List__c oldTarget = [Select Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.Used_Reward_Amount__c ,CIS_ID_Prospect_Name__r.Capacity_Max_Reward_Amount__c,CIS_ID_Prospect_Name__r.Name, CIS_ID_Prospect_Name__r.Name_TH__c, Campaign_Reward_Amount__c, Campaign_Reward_Calc__c, Contact_Name__c,Mobile_No__c,Address_House_No__c,Address_Moo__c,Address_Mooban__c,Address_Building__c,Address_Floor__c,Address_Room__c,Address_Soi__c,Address_Street__c,Province__c,District__c,Sub_District__c,PostCode__c,Memo__c,Account_Number__c FROM Target_List__c WHERE  Id = :inputTglObject.Id LIMIT 1];
	        inputTglObject.Status__c = GlobalConstants.REGISTERED;
	        inputTglObject.Registered_DateTime__c = System.Now();
	        inputTglObject.Register__c = true;
        	update inputTglObject;
        	response.result = SUCCESS;
        	response.message = SUCCESS_MESSAGE;
    	}catch(Exception e){
    		response.result = ERROR;
    		response.message = e.getMessage();
    	}
        return JSON.serialize(response);
    }

    @Auraenabled
    public static String saveNotRegisterImmediately(String inputWrapTargetListString){
        ResultResponse response = new ResultResponse();
        try{
     
            WrapperTargetList inputWrapTglObject = (WrapperTargetList)JSON.deserialize(inputWrapTargetListString,WrapperTargetList.class);
            Target_List__c inputTglObject = inputWrapTglObject.targetList;
            inputTglObject.Status__c = GlobalConstants.NOT_REGISTER;
            inputTglObject.Registered_DateTime__c = System.Now();
            inputTglObject.Register__c = true;
            update inputTglObject;
            response.result = SUCCESS;
            response.message = SUCCESS_MESSAGE;
        }catch(Exception e){
            response.result = ERROR;
            response.message = e.getMessage();
        }
        return JSON.serialize(response);
    }

    @Auraenabled
    public static String savingTargetList(String inputWrapTargetListString,String inputRewardAmount){
    	ResultResponse response = new ResultResponse();
    	try{
	    	getRewardMap();
	    	WrapperTargetList inputWrapTglObject = (WrapperTargetList)JSON.deserialize(inputWrapTargetListString,WrapperTargetList.class);
	    	Target_List__c inputTglObject = inputWrapTglObject.targetList;
	        Target_List__c oldTarget = [Select Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.Used_Reward_Amount__c ,CIS_ID_Prospect_Name__r.Capacity_Max_Reward_Amount__c,CIS_ID_Prospect_Name__r.Name, CIS_ID_Prospect_Name__r.Name_TH__c, Campaign_Reward_Amount__c, Campaign_Reward_Calc__c, Contact_Name__c,Mobile_No__c,Address_House_No__c,Address_Moo__c,Address_Mooban__c,Address_Building__c,Address_Floor__c,Address_Room__c,Address_Soi__c,Address_Street__c,Province__c,District__c,Sub_District__c,PostCode__c,Memo__c,Account_Number__c FROM Target_List__c WHERE  Id = :inputTglObject.Id LIMIT 1];
	        inputTglObject.Status__c = GlobalConstants.REGISTERED;
	        inputTglObject.Registered_DateTime__c = System.Now();
	        inputTglObject.Register__c = true;
	        Account targetAccount;
	        if(inputWrapTglObject.isNewBooking && inputWrapTglObject.isShowRewardSection) {
	            if(String.isBlank(inputRewardAmount) && inputWrapTglObject.mustSelectReward) {
	                response.result = ERROR;
	                response.message = PLEASE_INPUT_REWARD;
	                return JSON.serialize(response);
	            }
	            if(inputWrapTglObject.mustSelectReward && allCampaignRewardMap.containsKey(inputRewardAmount)) {
	                inputTglObject.Campaign_Reward_Calc__c = allCampaignRewardMap.get(inputRewardAmount).Reward_Name__c;
	                inputTglObject.Campaign_Reward_Amount__c = allCampaignRewardMap.get(inputRewardAmount).Reward_Amount_Baht__c;
	            }
	            Decimal capMax = convertNullDecimaltoZero(oldTarget.CIS_ID_Prospect_Name__r.Capacity_Max_Reward_Amount__c);
	            Decimal newUsed = convertNullDecimaltoZero(oldTarget.CIS_ID_Prospect_Name__r.Used_Reward_Amount__c) + convertNullDecimaltoZero(inputTglObject.Campaign_Reward_Amount__c);
	            if(newUsed > capMax) {
	                response.result = ERROR;
	                response.message = USED_OVER_CAP_MAX;
	                return JSON.serialize(response);
	            }
	            targetAccount = new Account(
	                Id = inputTglObject.CIS_ID_Prospect_Name__c, 
	                Used_Reward_Amount__c = newUsed
	            );
	        }
            if(targetAccount != null) {
                TriggerHandler.bypass('AccountTriggerHandler');
                update targetAccount;
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
            update inputTglObject;
            response.result = SUCCESS;
            response.message = SUCCESS_MESSAGE;
        }catch(Exception ex){
            response.result = ERROR;
            response.message = ex.getMessage();
        }
        return JSON.serialize(response);
    }

    private static Decimal convertNullDecimaltoZero(Decimal inputDecimal) {
        if(inputDecimal == null) return 0;
        return inputDecimal;
    }

    private static void getFieldLabel(WrapperTargetList wrapObject) {
        wrapObject.contactPersonLabel = Schema.SObjectType.Target_List__c.fields.Contact_Name__c.Label;
        wrapObject.mobileNoLabel = Schema.SObjectType.Target_List__c.fields.Mobile_No__c.Label;
        wrapObject.houseNoLabel = Schema.SObjectType.Target_List__c.fields.Address_House_No__c.Label;
        wrapObject.mooLabel = Schema.SObjectType.Target_List__c.fields.Address_Moo__c.Label;
        wrapObject.villageLabel = Schema.SObjectType.Target_List__c.fields.Address_Mooban__c.Label;
        wrapObject.buildingLabel = Schema.SObjectType.Target_List__c.fields.Address_Building__c.Label;
        wrapObject.floorLabel = Schema.SObjectType.Target_List__c.fields.Address_Floor__c.Label;
        wrapObject.roomLabel = Schema.SObjectType.Target_List__c.fields.Address_Room__c.Label;
        wrapObject.soiLabel = Schema.SObjectType.Target_List__c.fields.Address_Soi__c.Label;
        wrapObject.streetLabel = Schema.SObjectType.Target_List__c.fields.Address_Street__c.Label;
        wrapObject.provinceLabel = Schema.SObjectType.Target_List__c.fields.Province__c.Label;
        wrapObject.districtLabel = Schema.SObjectType.Target_List__c.fields.District__c.Label;
        wrapObject.subDistrictLabel = Schema.SObjectType.Target_List__c.fields.Sub_District__c.Label;
        wrapObject.postCodeLabel = Schema.SObjectType.Target_List__c.fields.PostCode__c.Label;
        wrapObject.memoLabel = Schema.SObjectType.Target_List__c.fields.Memo__c.Label;
        wrapObject.accountNumberLabel = Schema.SObjectType.Target_List__c.fields.Account_Number__c.Label;
    }

    public static Map<String,String> getRewardItems(String setupAmount,String segment){
    	Map<String,String> mapMatchingReward = new Map<String,String>();
        for(Rewards__c eachCampaignReward : getRewardMap().values()) {
            if(setupAmount != null && (Decimal.valueOf(setupAmount) >= eachCampaignReward.Min_Amount__c && Decimal.valueOf(setupAmount) <= eachCampaignReward.Max_Amount__c)
                && segment == eachCampaignReward.RM_Segment__c 
                && isBangkokZone == eachCampaignReward.Bankok_Zone__c){
            	mapMatchingReward.put(eachCampaignReward.Id,eachCampaignReward.Reward_Name__c + ' ' + eachCampaignReward.Reward_Amount_Baht__c);
            }
        }
        return mapMatchingReward;
    }

    private static void getTargetListInfo(WrapperTargetList wrapObject,String tglId){
    	Target_List__c currentTgl = [SELECT Id,Mobile_No__c,Address_House_No__c,Campaign_Reward_Calc__c,Account_Number__c,Reward__c,Campaign_Reward_Amount__c,CIS_ID_Prospect_Name__r.Name,CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.Owner.Segment__c,Setup_Amount__c,CIS_ID_Prospect_Name__r.Owner.RC_Code__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c,Lead_Campaign__r.Address_Registration__c FROM Target_List__c WHERE Id = :tglId];
        wrapObject.targetList = currentTgl;
    	if(currentTgl.CIS_ID_Prospect_Name__r.Owner.RC_Code__c != null) {
            Team_Structure__c ownerTeam = [SELECT Id, RC_Code__c, Is_Bangkok_Zone__c FROM Team_Structure__c WHERE External_ID__c = :currentTgl.CIS_ID_Prospect_Name__r.Owner.RC_Code__c];
            isBangkokZone = ownerTeam.Is_Bangkok_Zone__c;
        }

    	String configNewBookingCode = Campaign_Setting__c.getInstance().NewBooking_Code__c;
    	wrapObject.isShowAddressSection = true;
    	wrapObject.maxHeight = 760;
    	wrapObject.isNewBooking = false;
    	if(currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c == configNewBookingCode){
    		wrapObject.pageHeaderTitle = REGISTER_REWARD;
    		wrapObject.isNewBooking = true;
    		wrapObject.isShowRewardSection = true;
    		wrapObject.mustSelectReward = true;
    		if(currentTgl.Campaign_Reward_Calc__c != null && currentTgl.Campaign_Reward_Amount__c != null) {
				wrapObject.mustSelectReward = false;
                if(currentTgl.Account_Number__c != null || (currentTgl.Reward__c != null && currentTgl.Reward__c.equalsIgnoreCase(GlobalConstants.CASHBACK))){
                    wrapObject.isShowAddressSection = false;
                    wrapObject.maxHeight = 250;
                }
			}
    	}else if(currentTgl.Lead_Campaign__r.Address_Registration__c == 'Yes'){
    		wrapObject.pageHeaderTitle = REGISTER_ADDRESS;
			wrapObject.isShowRewardSection = false;
    		if(currentTgl.Campaign_Reward_Calc__c != null) {
                wrapObject.mustSelectReward = false;
                wrapObject.isShowRewardSection = true;
            }
    	}else{
    		wrapObject.canUpdateImmediately = true;
    		wrapObject.maxHeight = 100;
    	}
    }

    private static Map<Id, Rewards__c> getRewardMap(){
    	if(allCampaignRewardMap == null){
    		allCampaignRewardMap = new Map<Id, Rewards__c>([SELECT Id,Reward_Name__c, Reward_Amount_Baht__c, Reward_Type__c, Min_Amount__c, Max_Amount__c, Bankok_Zone__c, RM_Segment__c FROM Rewards__c]);
    	}
    	return allCampaignRewardMap;
    }
}