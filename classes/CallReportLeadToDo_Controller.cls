public without sharing class CallReportLeadToDo_Controller {
	public ApexPages.StandardController stdController {get; set;}
	public Call_Report__c callReportObject {get; set;}
	public List<Call_Report_Lead__c> listCallReportLead = new List<Call_Report_Lead__c>();
	public String cisId {get; set;}
	public Map<Id,CustomCallReportLeadObject> mapCustomCallReportLead;
	public Map<String,List<SelectOption>> mapListResponseLevel1MapByCampaignCode = new Map<String,List<SelectOption>>();
	public Map<String,List<SelectOption>> mapListResponseLevel2MapByCampaignCodeAndLevel1 = new Map<String,List<SelectOption>>();
	public Map<String,CustomResponse> mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2 = new Map<String,CustomResponse>();
	public List<CustomCallReportLeadObject> listCustomCallReportLead {get; set;}
	public Map<String,Set<String>> mapSetResponseLevel1MapByCampaignCode = new Map<String,Set<String>>();
	public Map<String,Set<String>> mapSetResponseLevel2MapByCampaignCodeAndLevel1 = new Map<String,Set<String>>();
	private static final String SELECT_NONE = '-';
	public String editId {get; set;}
	public String cancelId {get; set;}
	public Boolean showError {get; set;}
	public Boolean needRequireField {get; set;}
	public Boolean errorNumberField {get;set;}
	public Boolean refreshPage {get; set;}
	public Boolean hasData {get; set;}

	public class CustomResponse{
        public Boolean isRequireLv2 {get;private set;}
        public Boolean isRequireMemo {get;private set;}
        public Boolean isRequireAppId {get;private set;}
    }

    public class OldCallReportLeadData{
        public String responseLevel1 {get;private set;}
        public String responseLevel2 {get;private set;}
        public String memo {get;private set;}
        public String appId {get;private set;}
        public String arrOfEndMonth {get;private set;}
        public String inc_NPL {get;private set;}
        public String desc_NPL {get;private set;}
        public String desc_Way {get;private set;}
        public Decimal est_DES_NPL {get;private set;}
        public String inc_PRL {get;private set;}
        public String des_PRL {get;private set;}
        public String desc_Way_RPL {get;private set;}
        public Decimal est_DES_PRL {get;private set;}
        public List<SelectOption> listLevel1 {get;private set;}
        public List<SelectOption> listlevel2 {get;private set;}
    }

	public class CustomCallReportLeadObject{
        public Call_Report_Lead__c callReportLeadData {get;set;}
        public OldCallReportLeadData oldCallReportLeadData {get;set;}
        public String est_DES_NPL {get; set;}
        public String est_DES_PRL {get; set;}
        //public Boolean isLeadActive {get;private set;}
        public Boolean isEditMode {get;private set;}
        public Boolean showCancel {get;private set;}
        public Boolean isSelectedLv1 {get;private set;}
        public Boolean isRequireLv2 {get;private set;}
        public Boolean isRequireMemo {get;private set;}
        public Boolean isRequiredAppId {get;private set;}
        public List<SelectOption> listLevel1 {get;private set;}
        public List<SelectOption> listlevel2 {get;private set;}
        public Boolean isFieldsForLeadDPD {get {return this.callReportLeadData.Target_List__r.Lead_Subtype__c == Globalconstants.LEAD_SUB_TYPE_DPD;} private set;}
    }

	public CallReportLeadToDo_Controller(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		callReportObject = (Call_Report__c)stdController.getRecord();
		listCallReportLead = [SELECT Call_Plan_Call_Report__r.CIS_ID__r.CIS__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__r.Id = :callReportObject.Id AND Target_List__r.Active_Target_List__c != null AND Target_List__r.Status__c != :GlobalConstants.STATUS_CHANGED_OWNER LIMIT 1];

		if(!listCallReportLead.isEmpty()){
			cisId = listCallReportLead.get(0).Call_Plan_Call_Report__r.CIS_ID__r.CIS__c;
		}
		refreshPage = false;
		hasData = false;
		if(!listCallReportLead.isEmpty()){
				
			initialResponseMap();
			mapCustomCallReportLead = new Map<Id,CustomCallReportLeadObject>();
			listCustomCallReportLead = new List<CustomCallReportLeadObject>();
			
			List<Call_Report_Lead__c> listCallReportLead = [SELECT Id,Name,Campaign_Name__c,End_Date__c,Start_Date__c,Call_Report_Lead_Status__c,Status__c,Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,Target_List__r.Lead_Campaign__r.Sub_Type__c,Target_List__r.Lead_Campaign__r.Priority_Group__c,Target_List__r.IsRespLeadToDo__c,Target_List__r.Response_Level_1__c,Target_List__r.Response_Level_2__c,Target_List__r.Memo__c,Target_List__r.Id,Target_List__r.Status__c,Target_List__r.Priority__c,Target_List__r.Personalised_Message__c,Target_List__r.Lead_Campaign__r.Status,Target_List__r.Priority_Group_Display__c,Target_List__r.Application_ID__c ,Target_List__r.Lead_Subtype__c ,Target_List__r.Response_Date__c,Target_List__r.Arr_of_end_month__c,Target_List__r.DES_NPL__c,Target_List__r.INC_NPL__c,Target_List__r.Desc_Way__c,Target_List__r.EST_DES_NPL__c,Target_List__r.INC_PRL__c,Target_List__r.DES_PRL__c,Target_List__r.Desc_Way_RPL__c,Target_List__r.EST_DES_PRL__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__r.Id = :callReportObject.Id AND Call_Plan_Call_Report__r.CIS_ID__r.CIS__c = :cisId AND Target_List__r.Lead_Campaign__r.Type__c  = :GlobalConstants.LEAD_TO_DO AND Target_List__r.Status__c != :GlobalConstants.STATUS_CHANGED_OWNER ORDER BY Target_List__r.Priority_Group_Display__c DESC]; 

			for(Call_Report_Lead__c eachCallReportLead : listCallReportLead){
				CustomCallReportLeadObject customCallReportLeadObject = new CustomCallReportLeadObject();
				customCallReportLeadObject.callReportLeadData = eachCallReportLead;
				customCallReportLeadObject.listLevel1 = getListLevel1ByCampaignCode(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c);
				customCallReportLeadObject.listlevel2 = getListLevel2ByCampaignCodeAndLevel1(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c);
				customCallReportLeadObject.isEditMode = eachCallReportLead.Target_List__r.IsRespLeadToDo__c?false:true;
				customCallReportLeadObject.isRequireLv2 = checkRequireLevel2(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c);
				customCallReportLeadObject.est_DES_NPL = String.valueOf(eachCallReportLead.Target_List__r.EST_DES_NPL__c);
				customCallReportLeadObject.est_DES_PRL = String.valueOf(eachCallReportLead.Target_List__r.EST_DES_PRL__c);
				customCallReportLeadObject.showCancel = false;

				customCallReportLeadObject.oldCallReportLeadData = new OldCallReportLeadData();
				customCallReportLeadObject.oldCallReportLeadData.responseLevel1 = eachCallReportLead.Target_List__r.Response_Level_1__c;
				customCallReportLeadObject.oldCallReportLeadData.responseLevel2 = eachCallReportLead.Target_List__r.Response_Level_2__c;
				customCallReportLeadObject.oldCallReportLeadData.memo = eachCallReportLead.Target_List__r.Memo__c;
				customCallReportLeadObject.oldCallReportLeadData.listLevel1 = getListLevel1ByCampaignCode(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c);
				customCallReportLeadObject.oldCallReportLeadData.listLevel2 = getListLevel2ByCampaignCodeAndLevel1(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c);
				customCallReportLeadObject.oldCallReportLeadData.appId = eachCallReportLead.Target_List__r.Application_ID__c;
                customCallReportLeadObject.oldCallReportLeadData.arrOfEndMonth = eachCallReportLead.Target_List__r.Arr_of_end_month__c;
                customCallReportLeadObject.oldCallReportLeadData.inc_NPL = eachCallReportLead.Target_List__r.INC_NPL__c;
                customCallReportLeadObject.oldCallReportLeadData.desc_NPL = eachCallReportLead.Target_List__r.DES_NPL__c;
                customCallReportLeadObject.oldCallReportLeadData.desc_Way = eachCallReportLead.Target_List__r.Desc_Way__c;
                customCallReportLeadObject.oldCallReportLeadData.est_DES_NPL = eachCallReportLead.Target_List__r.EST_DES_NPL__c;
                customCallReportLeadObject.oldCallReportLeadData.inc_PRL = eachCallReportLead.Target_List__r.INC_PRL__c;
                customCallReportLeadObject.oldCallReportLeadData.des_PRL = eachCallReportLead.Target_List__r.DES_PRL__c;
                customCallReportLeadObject.oldCallReportLeadData.desc_Way_RPL = eachCallReportLead.Target_List__r.Desc_Way_RPL__c;
                customCallReportLeadObject.oldCallReportLeadData.est_DES_PRL = eachCallReportLead.Target_List__r.EST_DES_PRL__c;


				if(eachCallReportLead.Target_List__r.Response_Level_2__c != null){
					customCallReportLeadObject.isRequireMemo = checkLevel2RequireMemo(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c,eachCallReportLead.Target_List__r.Response_Level_2__c);
					customCallReportLeadObject.isRequiredAppId = checkLevel2RequireApplicationId(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c,eachCallReportLead.Target_List__r.Response_Level_2__c);
                }else{
					customCallReportLeadObject.isRequireMemo = checkLevel2RequireMemo(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c,SELECT_NONE);
					customCallReportLeadObject.isRequiredAppId = checkLevel2RequireApplicationId(eachCallReportLead.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,eachCallReportLead.Target_List__r.Response_Level_1__c,SELECT_NONE);
                }
				//customCallReportLeadObject.isLeadActive = (eachCallReportLead.Target_List__r.Lead_Campaign__r.Status == Globalconstants.Active && eachCallReportLead.Target_List__r.Status__c != Globalconstants.REJECTED) ? true: false;
				customCallReportLeadObject.isSelectedLv1 = eachCallReportLead.Target_List__r.Response_Level_1__c != null?true:false;
				mapCustomCallReportLead.put(eachCallReportLead.Id, customCallReportLeadObject);
			}
			if(!mapCustomCallReportLead.isEmpty()){
				hasData = true;
				listCustomCallReportLead.addAll(mapCustomCallReportLead.values());
			}
		}
	}

	private void initialResponseMap(){
		List<Lead_To_Do_Response__c> listLeadToDoResponse = [SELECT Campaign_Code__c,Response_Level_1__c,Response_Level_2__c,Required_Level_2__c,Required_Memo__c,Required_App_ID__c FROM Lead_To_Do_Response__c WHERE Team__c = 'SME' ORDER BY Response_Level_1__c,Response_Level_2__c];
		for(Lead_To_Do_Response__c eachResponse : listLeadToDoResponse){
			if(!mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c)){
				CustomResponse newCustomResponseLevel1 = new CustomResponse();
				newCustomResponseLevel1.isRequireLv2 = eachResponse.Required_Level_2__c;
				newCustomResponseLevel1.isRequireMemo = eachResponse.Required_Memo__c;
				newCustomResponseLevel1.isRequireAppId = eachResponse.Required_App_ID__c;
				mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.put(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c, newCustomResponseLevel1);
			}else{
				if(eachResponse.Required_Level_2__c){
					mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).isRequireLv2 = true;
				}

				if(eachResponse.Required_App_ID__c){
					mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).isRequireAppId = true;
				}

				if(!eachResponse.Required_Memo__c){
					mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).isRequireMemo = false;
				}
			}
			CustomResponse newCustomResponseLevel2 = new CustomResponse();
			newCustomResponseLevel2.isRequireLv2 = eachResponse.Required_Level_2__c;
			newCustomResponseLevel2.isRequireMemo = eachResponse.Required_Memo__c;
			newCustomResponseLevel2.isRequireAppId = eachResponse.Required_App_ID__c;
			mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.put(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c +'-'+ eachResponse.Response_Level_2__c, newCustomResponseLevel2);

			if(!mapListResponseLevel1MapByCampaignCode.containsKey(eachResponse.Campaign_Code__c)){
				mapSetResponseLevel1MapByCampaignCode.put(eachResponse.Campaign_Code__c, new Set<String>());
				mapListResponseLevel1MapByCampaignCode.put(eachResponse.Campaign_Code__c, new List<SelectOption>());
			}
			if(!mapSetResponseLevel1MapByCampaignCode.get(eachResponse.Campaign_Code__c).contains(eachResponse.Response_Level_1__c)){
				mapSetResponseLevel1MapByCampaignCode.get(eachResponse.Campaign_Code__c).add(eachResponse.Response_Level_1__c);
				mapListResponseLevel1MapByCampaignCode.get(eachResponse.Campaign_Code__c).add(new SelectOption(eachResponse.Response_Level_1__c,eachResponse.Response_Level_1__c));
			}
			
			if(!mapListResponseLevel2MapByCampaignCodeAndLevel1.containsKey(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c)){
				mapSetResponseLevel2MapByCampaignCodeAndLevel1.put(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c, new Set<String>());
				mapListResponseLevel2MapByCampaignCodeAndLevel1.put(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c, new List<SelectOption>());
			}
			if(eachResponse.Response_Level_2__c != null && !mapSetResponseLevel2MapByCampaignCodeAndLevel1.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).contains(eachResponse.Response_Level_2__c)){
				mapSetResponseLevel2MapByCampaignCodeAndLevel1.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).add(eachResponse.Response_Level_2__c);
				mapListResponseLevel2MapByCampaignCodeAndLevel1.get(eachResponse.Campaign_Code__c +'-'+ eachResponse.Response_Level_1__c).add(new SelectOption(eachResponse.Response_Level_2__c,eachResponse.Response_Level_2__c));
			}
		}
    }
    
	public PageReference save(){
		showError = false;
		needRequireField = false;
		refreshPage = false;
		errorNumberField = false;

		List<Call_Report_Lead__c> listUpdateCallReportLead = new List<Call_Report_Lead__c>();
		List<Target_List__c> listUpdateTargetList = new List<Target_List__c>();
		Boolean hasError = false;
		for(CustomCallReportLeadObject eachCustomCallReportLead : mapCustomCallReportLead.values()){
			if((eachCustomCallReportLead.isRequireLv2 && (eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c == null || eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c == SELECT_NONE))
				||(eachCustomCallReportLead.isRequireMemo && (eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c == null || (eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c).trim() == ''))
                ||(eachCustomCallReportLead.isRequiredAppId && (eachCustomCallReportLead.callReportLeadData.Target_List__r.Application_ID__c == null || (eachCustomCallReportLead.callReportLeadData.Target_List__r.Application_ID__c).trim() == '' ))){
				hasError = true;
				showError = true;
				needRequireField = true;
				break;
			}

			if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c != null && (eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c).length() > 255){
				hasError = true;
				showError = true;
				break;
			}
			if(!String.isBlank(eachCustomCallReportLead.est_DES_NPL) && !GlobalUtility.isValidDecimal(eachCustomCallReportLead.est_DES_NPL)
				|| !String.isBlank(eachCustomCallReportLead.est_DES_PRL) && !GlobalUtility.isValidDecimal(eachCustomCallReportLead.est_DES_PRL)) {
				hasError = true;
				showError = true;
				errorNumberField = true;
				break;
			}

			if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c == null 
				&& (eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c == null || (eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c).trim() == '')){
				continue;
			}

			if(eachCustomCallReportLead.isEditMode && eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c != SELECT_NONE && eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c != ''){
				Call_Report_Lead__c updateCallReportLead = new Call_Report_Lead__c();
				updateCallReportLead.Id = eachCustomCallReportLead.callReportLeadData.Id;
				if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c != null && eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c != SELECT_NONE){
					updateCallReportLead.Call_Report_Lead_Status__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c;
				}else{
					updateCallReportLead.Call_Report_Lead_Status__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c;
				}
				updateCallReportLead.Memo__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c;
				
				listUpdateCallReportLead.add(updateCallReportLead);

				Target_List__c updateTargetList = new Target_List__c();
				updateTargetList.Id = eachCustomCallReportLead.callReportLeadData.Target_List__r.Id;
				updateTargetList.Memo__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Memo__c;
				updateTargetList.Response_Level_1__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c;
				updateTargetList.Response_Level_2__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c;
				updateTargetList.Application_ID__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Application_ID__c;
				updateTargetList.Arr_of_end_month__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Arr_of_end_month__c;
				updateTargetList.DES_NPL__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.DES_NPL__c;
				updateTargetList.INC_NPL__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.INC_NPL__c;
				updateTargetList.Desc_Way__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Desc_Way__c;
				updateTargetList.EST_DES_NPL__c = ( String.isBlank(eachCustomCallReportLead.est_DES_NPL) ? null : Decimal.valueOf(eachCustomCallReportLead.est_DES_NPL.trim()));
				updateTargetList.INC_PRL__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.INC_PRL__c;
				updateTargetList.DES_PRL__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.DES_PRL__c;
				updateTargetList.Desc_Way_RPL__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Desc_Way_RPL__c;
				updateTargetList.EST_DES_PRL__c = ( String.isBlank(eachCustomCallReportLead.est_DES_PRL)  ? null : Decimal.valueOf(eachCustomCallReportLead.est_DES_PRL.trim()));
				updateTargetList.IsRespLeadToDo__c = true;
				if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c != null && eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c != SELECT_NONE){
					if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c != eachCustomCallReportLead.oldCallReportLeadData.responseLevel2){
						updateTargetList.Status__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c;
					}
				}else{
					if(eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c != eachCustomCallReportLead.oldCallReportLeadData.responseLevel1){
						updateTargetList.Status__c = eachCustomCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c;
					}
				}
				listUpdateTargetList.add(updateTargetList);
			}
		}

		if(!hasError){
			if(!listUpdateCallReportLead.isEmpty()){
				update listUpdateCallReportLead;
			}

			if(!listUpdateTargetList.isEmpty()){
				update listUpdateTargetList;
			}
			for(Call_Report_Lead__c eachUpdatedCallReportLead : listUpdateCallReportLead){
				mapCustomCallReportLead.get(eachUpdatedCallReportLead.Id).callReportLeadData.Call_Report_Lead_Status__c = eachUpdatedCallReportLead.Call_Report_Lead_Status__c;
				mapCustomCallReportLead.get(eachUpdatedCallReportLead.Id).isEditMode = false;
			}

			refreshPage = true;
		}
        return null;
    }

    public void cancelRow(){
    	CustomCallReportLeadObject selectedCallReportLead = mapCustomCallReportLead.get(cancelId);
    	selectedCallReportLead.isEditMode = false;
    	selectedCallReportLead.showCancel = false;
    	selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c = selectedCallReportLead.oldCallReportLeadData.responseLevel1;
		selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c = selectedCallReportLead.oldCallReportLeadData.responseLevel2;
		selectedCallReportLead.callReportLeadData.Target_List__r.Memo__c = selectedCallReportLead.oldCallReportLeadData.memo;
        selectedCallReportLead.callReportLeadData.Target_List__r.Application_ID__c = selectedCallReportLead.oldCallReportLeadData.appId;
        selectedCallReportLead.callReportLeadData.Target_List__r.Arr_of_end_month__c = selectedCallReportLead.oldCallReportLeadData.arrOfEndMonth;
       	selectedCallReportLead.callReportLeadData.Target_List__r.INC_NPL__c = selectedCallReportLead.oldCallReportLeadData.inc_NPL;
        selectedCallReportLead.callReportLeadData.Target_List__r.DES_NPL__c = selectedCallReportLead.oldCallReportLeadData.desc_NPL;
        selectedCallReportLead.callReportLeadData.Target_List__r.Desc_Way__c = selectedCallReportLead.oldCallReportLeadData.desc_Way;
		selectedCallReportLead.callReportLeadData.Target_List__r.INC_PRL__c = selectedCallReportLead.oldCallReportLeadData.inc_PRL;
		selectedCallReportLead.callReportLeadData.Target_List__r.DES_PRL__c = selectedCallReportLead.oldCallReportLeadData.des_PRL;
		selectedCallReportLead.callReportLeadData.Target_List__r.Desc_Way_RPL__c = selectedCallReportLead.oldCallReportLeadData.desc_Way_RPL;
		selectedCallReportLead.est_DES_NPL = String.valueOf(selectedCallReportLead.oldCallReportLeadData.est_DES_NPL);
		selectedCallReportLead.est_DES_PRL = String.valueOf(selectedCallReportLead.oldCallReportLeadData.est_DES_PRL);
		selectedCallReportLead.listLevel1 = selectedCallReportLead.oldCallReportLeadData.listLevel1;
		selectedCallReportLead.listLevel2 = selectedCallReportLead.oldCallReportLeadData.listLevel2;

    }
    public void edit(){
    	CustomCallReportLeadObject selectedCallReportLead = mapCustomCallReportLead.get(editId);
    	String campaignCode = selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c;
    	String level1 = selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c;
    	String level2 = selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c;
    	selectedCallReportLead.listLevel1 = getListLevel1ByCampaignCode(campaignCode);
    	selectedCallReportLead.listLevel1.remove(0);
    	selectedCallReportLead.isRequireLv2 = checkRequireLevel2(campaignCode,level1);
    	if(level2 == SELECT_NONE){
    		selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c = null;
    	}
    	selectedCallReportLead.isRequireMemo = checkLevel2RequireMemo(campaignCode,level1,level2);
		selectedCallReportLead.isSelectedLv1 = true;
    	selectedCallReportLead.isEditMode = true;
    	selectedCallReportLead.showCancel = true;
    }

    private List<SelectOption> getListLevel1ByCampaignCode(String campaignCode){
    	List<SelectOption> returnList = new List<SelectOption>{new SelectOption(SELECT_NONE, SELECT_NONE)};
     	if(campaignCode != null){
     		if(mapListResponseLevel1MapByCampaignCode.containsKey(campaignCode)){
     			returnList.addAll(mapListResponseLevel1MapByCampaignCode.get(campaignCode));
     		}
     	}
     	return returnList;
    }

    private List<SelectOption> getListLevel2ByCampaignCodeAndLevel1(String campaignCode,String level1){
    	List<SelectOption> returnList = new List<SelectOption>{new SelectOption(SELECT_NONE, SELECT_NONE)};
     	if(campaignCode != null && level1 != null){
     		if(mapListResponseLevel2MapByCampaignCodeAndLevel1.containsKey(campaignCode +'-'+ level1)){
     			returnList.addAll(mapListResponseLevel2MapByCampaignCodeAndLevel1.get(campaignCode +'-'+ level1));
     		}
     	}
     	return returnList;
    }

    public void loadListLevel2ByCampaignCodeAndLevel1() {
    	String clickedId = apexpages.currentpage().getParameters().get('clickedId');
    	CustomCallReportLeadObject selectedCallReportLead = mapCustomCallReportLead.get(clickedId);
    	if(selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c == SELECT_NONE){
    		selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c = null;
    		selectedCallReportLead.isSelectedLv1 = false;
    	}else{
    		selectedCallReportLead.isSelectedLv1 = true;
    	}
    	selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c = null;
    	selectedCallReportLead.listLevel2 = getListLevel2ByCampaignCodeAndLevel1(selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c);
    	selectedCallReportLead.isRequireLv2 = checkRequireLevel2(selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c);
    	selectedCallReportLead.isRequireMemo = checkLevel1RequireMemo(selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c);
        selectedCallReportLead.isRequiredAppId = checkLevel1RequireApplicationId(selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c,selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c);
        selectedCallReportLead.isEditMode = true;
    }

    public Boolean checkRequireLevel2(String campaignCode, String level1){
    	if(mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(campaignCode +'-'+ level1)){
     		CustomResponse leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1);
     		return leadToDoResponse.isRequireLv2;
     	}
     	return false;
    }

    public Boolean checkLevel1RequireMemo(String campaignCode, String level1){
    	if(mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(campaignCode +'-'+ level1)){
     		CustomResponse leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1);
     		return leadToDoResponse.isRequireMemo;
     	}
     	return false;
    }

    public Boolean checkLevel2RequireMemo(String campaignCode, String level1, String level2){
    	CustomResponse leadToDoResponse;
    	if(level2 != null){
     		leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1 +'-'+ level2);
     	}else if(mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(campaignCode +'-'+ level1)){
     		leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1);
     	}

     	if(leadToDoResponse != null){
     		return leadToDoResponse.isRequireMemo;
 		}else{
 			return false;
 		}
    }

    public Boolean checkLevel1RequireApplicationId(String campaignCode, String level1){
    	if(mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(campaignCode +'-'+ level1)){
     		CustomResponse leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1);
     		return leadToDoResponse.isRequireAppId;
     	}
     	return false;
    }

	public Boolean checkLevel2RequireApplicationId(String campaignCode,String level1,String level2){
    	CustomResponse leadToDoResponse;
    	if(level2 != null){
     		leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1 +'-'+ level2);
     	}else if(mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.containsKey(campaignCode +'-'+ level1)){
     		leadToDoResponse = mapAllResponseMapByCampaignCodeLevel1OrCampaignCodeLevel1Level2.get(campaignCode +'-'+ level1);
     	}

     	if(leadToDoResponse != null){
     		return leadToDoResponse.isRequireAppId;
 		}else{
 			return false;
 		}
    }
    
    public void checkRequireMemo(){
    	String clickedId = apexpages.currentpage().getParameters().get('clickedId');
    	CustomCallReportLeadObject selectedCallReportLead = mapCustomCallReportLead.get(clickedId);
    	String campaignCode = selectedCallReportLead.callReportLeadData.Target_List__r.Lead_Campaign__r.Lead_Campaign_Event_Code__c;
    	String level1 = selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_1__c;
    	String level2 = selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c;
    	if(level2 == SELECT_NONE){
    		selectedCallReportLead.callReportLeadData.Target_List__r.Response_Level_2__c = null;
     	}
     	selectedCallReportLead.isRequireMemo = checkLevel2RequireMemo(campaignCode,level1,level2);
     	selectedCallReportLead.isRequiredAppId = checkLevel2RequireApplicationId(campaignCode,level1,level2);
    }

    public void checkMemo(){
    	String clickedId = apexpages.currentpage().getParameters().get('clickedId');
    	CustomCallReportLeadObject selectedCallReportLead = mapCustomCallReportLead.get(clickedId);
    	selectedCallReportLead.isEditMode = true;
    }

}