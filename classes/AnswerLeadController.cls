public without sharing class AnswerLeadController {
	public static Map<String,String> fieldSetNameMapByLeadType = new Map<String,String>{GlobalConstants.LEAD_SUB_TYPE_DPD=>'Lead_DPD_Response',GlobalConstants.LEAD_FOR_SALES =>'Lead_Response' , GlobalConstants.LEAD_TO_DO=>'Lead_To_Do_Response', GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER=>'Lead_To_Do_Response'};
	public static Set<String> setFieldNotDependOnFieldSetTypePicklist = new Set<String>{Schema.SObjectType.Target_List__c.fields.Response_Level_1__c.getName(),Schema.SObjectType.Target_List__c.fields.Response_Level_2__c.getName()};
	public static Set<String> setFieldNotDependOnFieldSet = new Set<String>{Schema.SObjectType.Target_List__c.fields.Response_Level_1__c.getName(),Schema.SObjectType.Target_List__c.fields.Response_Level_2__c.getName(),Schema.SObjectType.Target_List__c.fields.Memo__c.getName(),Schema.SObjectType.Target_List__c.fields.Application_ID__c.getName()};
    public static Set<String> setProfileSmeHeadquater = new Set<String>{'KBANK-BIU','SME-Sales Management',GlobalConstants.SME_ADMIN,GlobalConstants.PROFILE_SOLAR};
    public static Set<String> setProfileAfHeadquater = new Set<String>{'RBS-Admin',GlobalConstants.PROFILE_SOLAR};

    public List<Target_List__c> targetLists {get;set;}
    public String targetListsJSONString {get {return  JSON.serialize(targetLists);} }
    public ResponseModel responseModel {get;set;}

    public String leadSubType {get;private set;}
    public String campaignCode;
    public String dafaultMemo;
    public List<SelectOption> optionLevel1 {get;set;}
    public List<SelectOption> optionLevel2 {get;set;}
    public ResultResponse resultresponse {get;set;}
    public String resultResponseJSONString {get {return JSON.serialize(resultresponse);}}
    public Boolean hasExpireCampaign {get;set;}
    public Boolean hasOtherLeadType {get;set;}

    public AnswerLeadController(ApexPages.StandardSetController controller){
        this.targetLists = [SELECT Id,Status__c,Lead_Subtype_CBS__c,Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c,Lead_Campaign__r.EndDate,IsCurrentOwner__c,Lead_Type__c,Memo__c  From Target_List__c WHERE Id IN :controller.getSelected()];
        if(!this.targetLists.isEmpty()){
            hasExpireCampaign = false;
            hasOtherLeadType = false;
            for(Target_List__c  eacgTargetList : targetLists ){
                if(eacgTargetList.Lead_Type__c  == null || eacgTargetList.Lead_Type__c  != GlobalConstants.LEAD_FOR_FEEDBACK ){
                    hasOtherLeadType = true;
                    break;
                }
                if(eacgTargetList.Lead_Campaign__r.EndDate < System.today()){
                    hasExpireCampaign = true;
                    break;
                }
                if(!String.isBlank(eacgTargetList.Memo__c)){
                    this.dafaultMemo = eacgTargetList.Memo__c;
                }
            }
            this.responseModel = new ResponseModel();
            this.optionLevel1 = new List<SelectOption>();
            this.optionLevel2 = new List<SelectOption>();
            this.campaignCode = this.targetLists.get(0).Lead_Campaign__r.Lead_Campaign_Event_Code__c;
            this.leadSubType = this.targetLists.get(0).Lead_Subtype_CBS__c == null ? this.targetLists.get(0).Lead_Subtype__c: this.targetLists.get(0).Lead_Subtype_CBS__c;
            this.optionLevel1 = getOptionResponseLevel1(campaignCode,leadSubType);
        }

    }

    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName) {
        FieldSetForm form = new FieldSetForm();
        try{
            String fieldSetName;
            Target_List__c currentTgl = [SELECT Opportunity__c,Opportunity__r.Name,Lead_Type__c,Lead_Subtype__c,Lead_Subtype_CBS__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c ,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Id =:recordId];
            UserRecordAccess hasJobReadAccess;
            if(currentTgl.Opportunity__c != null){
                hasJobReadAccess = [SELECT HasReadAccess,RecordId From UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:currentTgl.Opportunity__c Limit 1];
            }
      
            if(fieldSetNameMapByLeadType.containsKey(currentTgl.Lead_Subtype__c)){
            	fieldSetName = fieldSetNameMapByLeadType.get(currentTgl.Lead_Subtype__c);
            }else{
            	fieldSetName = fieldSetNameMapByLeadType.get(currentTgl.Lead_Type__c);
            }
            form.Fields = getFields(recordId, objectName, fieldSetName);
            form.Record = getRecord(recordId, objectName, form.Fields);
            form.LeadCode = currentTgl.Lead_Campaign__r.Lead_Campaign_Event_Code__c;
            form.LeadSubType = String.isBlank(currentTgl.Lead_Subtype__c) ? currentTgl.Lead_Subtype_CBS__c : currentTgl.Lead_Subtype__c;
            form.ParentId = currentTgl.CIS_ID_Prospect_Name__c;
            if(hasJobReadAccess != null && hasJobReadAccess.HasReadAccess){
                form.Job = new Opportunity(Id = currentTgl.Opportunity__c, Name = currentTgl.Opportunity__r.Name);
            }else{
                form.Job = new Opportunity();
            }
            form.isError = false;
        }catch(Exception e){
            form.isError = true;
            System.debug(e.getStackTraceString());
        }
        form.isMobile = UserInfo.getUiThemeDisplayed() == 'Theme4t'?true:false;
        return form;
    }

    @AuraEnabled
    public static List<AnswerObject> getResponseLevel1(String campaignCode,String subType) {
        String segment = AnswerLeadController.checkTeamSegmentFromCampaignCode(campaignCode);
        List<AnswerObject> listReponse = new List<AnswerObject>();
        Set<String> setResponse = new Set<String>();
        List<Global_Master_Data__c> listResponseLv1 = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level1__c,LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Campaign_Code__c =:campaignCode AND RecordType.DeveloperName = 'LeadResponse' ORDER BY LeadResponse_Response_Level1__c , LeadResponse_Response_Level2__c NULLS FIRST];
        if(listResponseLv1 == null || listResponseLv1.size() == 0){
        	listResponseLv1 = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level1__c,LeadResponse_Response_Level2__c  FROM Global_Master_Data__c WHERE LeadResponse_Type__c =:subType AND LeadResponse_Team__c = :segment AND LeadResponse_Campaign_Code__c = NULL AND RecordType.DeveloperName = 'LeadResponse' ORDER BY LeadResponse_Response_Level1__c , LeadResponse_Response_Level2__c NULLS FIRST];
        }
        for(Global_Master_Data__c eachRes : listResponseLv1){
        	if(setResponse.contains(eachRes.LeadResponse_Response_Level1__c)) continue;
        	setResponse.add(eachRes.LeadResponse_Response_Level1__c);
        	AnswerObject answerObject = new AnswerObject();
            answerObject.answer = eachRes.LeadResponse_Response_Level1__c;
        	if(String.isBlank(eachRes.LeadResponse_Response_Level2__c)){
	        	answerObject.isRequiredAppId = eachRes.LeadResponse_Required_App_ID__c;
	        	answerObject.isRequireMemo = eachRes.LeadResponse_Required_Memo__c;
	        	answerObject.isRequireLv2 = false;
	        	answerObject.isRequiredDate = eachRes.LeadResponse_Required_Date__c;
        	}else{
				answerObject.isRequiredAppId = false;
	        	answerObject.isRequireMemo = false;
	        	answerObject.isRequireLv2 = eachRes.LeadResponse_Required_Level2__c;
	        	answerObject.isRequiredDate = false;
        	}
        	listReponse.add(answerObject);
        }
        return listReponse;
    }

    
    public void onChangeResponseLevel1(){
        this.responseModel.responseLv2 = null;
        this.responseModel.memo = this.dafaultMemo;
        this.optionLevel2 = getOptionResponseLevel2(campaignCode,this.responseModel.responseLv1,leadSubType);
        List<Global_Master_Data__c> listLeadResponse =  [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level1__c,LeadResponse_Response_Level2__c  FROM Global_Master_Data__c WHERE LeadResponse_Response_Level1__c =:this.responseModel.responseLv1 AND LeadResponse_Type__c =:leadSubType AND LeadResponse_Campaign_Code__c = NULL AND RecordType.DeveloperName = 'LeadResponse'];
        AnswerObject answerObject;
        for(Global_Master_Data__c eachRes : listLeadResponse){
            answerObject = new AnswerObject();
            answerObject.answer = eachRes.LeadResponse_Response_Level2__c;
            answerObject.isRequiredAppId = eachRes.LeadResponse_Required_App_ID__c;
            answerObject.isRequireMemo = eachRes.LeadResponse_Required_Memo__c;
            answerObject.isRequireLv2 = eachRes.LeadResponse_Required_Level2__c;
            answerObject.isRequiredDate = eachRes.LeadResponse_Required_Date__c;
        }
        this.responseModel.answerObj = answerObject;
    }

    public List<SelectOption> getOptionResponseLevel1(String campaignCode,String leadSubType){
        List<AnswerObject> listResponse = getResponseLevel1(campaignCode,leadSubType);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- โปรดเลือก --'));
        for(AnswerObject eachAnswer : listResponse){
            options.add(new SelectOption(eachAnswer.answer,eachAnswer.answer));
        }
        return options;
    }

    @AuraEnabled
    public static List<AnswerObject> getResponseLevel2(String campaignCode,String responseLv1,String subType) {
        String segment = AnswerLeadController.checkTeamSegmentFromCampaignCode(campaignCode);
        List<AnswerObject> listReponse = new List<AnswerObject>();
        Set<String> setResponse = new Set<String>();
        List<Global_Master_Data__c> listResponseLv2 = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Campaign_Code__c =:campaignCode AND LeadResponse_Response_Level1__c =:responseLv1 AND LeadResponse_Response_Level2__c != NULL AND RecordType.DeveloperName = 'LeadResponse' ORDER BY LeadResponse_Response_Level2__c];
        if(listResponseLv2 == null || listResponseLv2.size() == 0){
        	listResponseLv2 = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Type__c = :subType and LeadResponse_Team__c = :segment AND LeadResponse_Response_Level1__c =:responseLv1 AND LeadResponse_Response_Level2__c != NULL AND LeadResponse_Campaign_Code__c = NULL AND RecordType.DeveloperName = 'LeadResponse' ORDER BY LeadResponse_Response_Level2__c];
        }
        for(Global_Master_Data__c eachRes : listResponseLv2){
        	if(setResponse.contains(eachRes.LeadResponse_Response_Level2__c)) continue;
        	setResponse.add(eachRes.LeadResponse_Response_Level2__c);
        	AnswerObject answerObject = new AnswerObject();
        	answerObject.answer = eachRes.LeadResponse_Response_Level2__c;
        	answerObject.isRequiredAppId = eachRes.LeadResponse_Required_App_ID__c;
        	answerObject.isRequireMemo = eachRes.LeadResponse_Required_Memo__c;
        	answerObject.isRequireLv2 = eachRes.LeadResponse_Required_Level2__c;
        	answerObject.isRequiredDate = eachRes.LeadResponse_Required_Date__c;
        	listReponse.add(answerObject);
        }
        return listReponse;
    }

    public void onChangeResponseLevel2(){
        this.responseModel.memo = this.dafaultMemo;
        List<AnswerObject> listResponse = getResponseMemoFromLv1_Lv2(campaignCode,this.responseModel.responseLv1,this.responseModel.responseLv2,leadSubType );
        for(AnswerObject eachAnswer : listResponse){
            this.responseModel.answerObj = eachAnswer;
        }
    }

    public List<SelectOption> getOptionResponseLevel2(String campaignCode,String responseLv1,String subType){

        List<AnswerObject> listResponse = getResponseLevel2(campaignCode,responseLv1,subType);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- โปรดเลือก --'));
        for(AnswerObject eachAnswer : listResponse){
            options.add(new SelectOption(eachAnswer.answer,eachAnswer.answer));
        }
        return options;
    }

    @AuraEnabled
    public static List<AnswerObject> getResponseMemoFromLv1_Lv2(String campaignCode,String responseLv1,String responseLv2,String subType) {
        String segment = AnswerLeadController.checkTeamSegmentFromCampaignCode(campaignCode);
        List<AnswerObject> listReponse = new List<AnswerObject>();
        Set<String> setResponse = new Set<String>();
        List<Global_Master_Data__c> listResponseMemo = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Type__c = :subType AND LeadResponse_Team__c = :segment AND LeadResponse_Response_Level1__c =:responseLv1 AND LeadResponse_Response_Level2__c = :responseLv2 AND RecordType.DeveloperName = 'LeadResponse' ORDER BY LeadResponse_Response_Level2__c];
        
        for(Global_Master_Data__c eachRes : listResponseMemo){
            if(setResponse.contains(eachRes.LeadResponse_Response_Level2__c)) continue;
            setResponse.add(eachRes.LeadResponse_Response_Level2__c);
            AnswerObject answerObject = new AnswerObject();
            answerObject.answer = eachRes.LeadResponse_Response_Level2__c;
            answerObject.isRequiredAppId = eachRes.LeadResponse_Required_App_ID__c;
            answerObject.isRequireMemo = eachRes.LeadResponse_Required_Memo__c;
            answerObject.isRequireLv2 = eachRes.LeadResponse_Required_Level2__c;
            answerObject.isRequiredDate = eachRes.LeadResponse_Required_Date__c;
            listReponse.add(answerObject);
        }
        return listReponse;
    }

    private static Boolean hasPermissionToUpdate(String recordId,Target_List__c tglWithReponse){
        Target_List__c tglWithUser = [SELECT Re_Assigned_To_UserEx__r.User__c,CIS_ID_Prospect_Name__r.Service_Rm__c,CIS_ID_Prospect_Name__r.Service_Rm__r.ManagerId,CIS_ID_Prospect_Name__r.Service_Rm__r.Manager.ManagerId,CIS_ID_Prospect_Name__r.Service_Rm__r.Manager.Manager.ManagerId,Recordtype.DeveloperName,CIS_ID_Prospect_Name__r.Port_Pool__c,CIS_ID_Prospect_Name__r.Owner.Profile.Name,CIS_ID_Prospect_Name__r.SME_Temporary_Customer__c,CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__c,CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.ManagerId,CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.Manager.ManagerId,CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.Manager.Manager.ManagerId, CIS_ID_Prospect_Name__r.AF_Temporary_Customer__c,CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__c,CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.ManagerId,CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.Manager.ManagerId,CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.Manager.Manager.ManagerId,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Owner.ManagerId,CIS_ID_Prospect_Name__r.Owner.Manager.ManagerId,CIS_ID_Prospect_Name__r.Owner.Manager.Manager.ManagerId FROM Target_List__c WHERE Id = :recordId];
        User currentUser = [SELECT Id,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if(tglWithUser.Recordtype.DeveloperName == 'OneTeam_Target_List'){
            return true;
        }else if(tglWithUser.Recordtype.DeveloperName == 'Standard' && String.isNotBlank(tglWithUser.Re_Assigned_To_UserEx__r.User__c)){
            return hasReAssignUserPermission(tglWithUser,currentUser);
        }else if(String.isNotBlank(tglWithUser.CIS_ID_Prospect_Name__r.SME_Temporary_Customer__c)){
            return hasTempSmePermission(tglWithUser,currentUser);
        }else if(String.isNotBlank(tglWithUser.CIS_ID_Prospect_Name__r.AF_Temporary_Customer__c)){
            return hasTempAfPermission(tglWithUser,currentUser);
        }else if(String.isNotBlank(tglWithUser.CIS_ID_Prospect_Name__r.Service_Rm__c)){
            return hasServiceRmPermission(tglWithUser,currentUser);
        }else{
            return hasOwnerPermission(tglWithUser,currentUser);
        }
    }

    private static Boolean hasReAssignUserPermission(Target_List__c tglWithUser,User currentUser){
        if(tglWithUser.Re_Assigned_To_UserEx__r.User__c == currentUser.Id){
            return true;
        }
        return false;
    }

    private static Boolean hasServiceRmPermission(Target_List__c tglWithUser,User currentUser){
        Set<Id> setServiceRmAndAbove = new Set<Id>();
        setServiceRmAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Service_Rm__c);
        setServiceRmAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Service_Rm__r.ManagerId);
        setServiceRmAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Service_Rm__r.Manager.ManagerId);
        setServiceRmAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Service_Rm__r.Manager.Manager.ManagerId);

        if(setServiceRmAndAbove.contains(currentUser.Id) || hasOwnerPermission(tglWithUser,currentUser)){
            return true;
        }
        return false;
    }

    private static Boolean hasTempSmePermission(Target_List__c tglWithUser,User currentUser){
        Set<Id> setTempOwnerAndAbove = new Set<Id>();
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__c);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.ManagerId);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.Manager.ManagerId);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.SME_Temporary_Customer__r.User__r.Manager.Manager.ManagerId);

        if(setTempOwnerAndAbove.contains(currentUser.Id) || hasOwnerPermission(tglWithUser,currentUser)){
            return true;
        }
        return false;
    }

    private static Boolean hasTempAfPermission(Target_List__c tglWithUser,User currentUser){
        Set<Id> setTempOwnerAndAbove = new Set<Id>();
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__c);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.ManagerId);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.Manager.ManagerId);
        setTempOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.AF_Temporary_Customer__r.User__r.Manager.Manager.ManagerId);

        if(setProfileAfHeadquater.contains(currentUser.Profile.Name) || setTempOwnerAndAbove.contains(currentUser.Id) || hasOwnerPermission(tglWithUser,currentUser)){
            return true;
        }
        return false;
    }
    
    private static Boolean hasOwnerPermission(Target_List__c tglWithUser,User currentUser){
        Set<Id> setOwnerAndAbove = new Set<Id>();
        setOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.OwnerId);
        setOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Owner.ManagerId);
        setOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Owner.Manager.ManagerId);
        setOwnerAndAbove.add(tglWithUser.CIS_ID_Prospect_Name__r.Owner.Manager.Manager.ManagerId);
        if(setOwnerAndAbove.contains(currentUser.Id)){
            return true;
        }else if(tglWithUser.Recordtype.DeveloperName == 'RBS_Target_List'){
            return true;
        }else if(String.isNotBlank(tglWithUser.CIS_ID_Prospect_Name__r.Owner.Profile.Name)){
            if(tglWithUser.CIS_ID_Prospect_Name__r.Owner.Profile.Name.containsIgnoreCase('SME-') || tglWithUser.CIS_ID_Prospect_Name__r.Owner.Profile.Name.containsIgnoreCase('AN-')){
                if(currentUser.Profile.Name.equalsIgnoreCase('AN-Admin') || setProfileSmeHeadquater.contains(currentUser.Profile.Name)){
                    return true;
                }
            }else if(tglWithUser.CIS_ID_Prospect_Name__r.Owner.Profile.Name.containsIgnoreCase('CBS-')){
                if(currentUser.Profile.Name.equalsIgnoreCase('CBS-Admin')){
                    return true;
                }
            }
        }
        return false;
    }

    @AuraEnabled
    public static ResultResponse saveResponse(String recordId,Map<String,Object> mapReponseByFieldApi,String jobId) {
    	ResultResponse response = new ResultResponse();
    	try{
    		String responseLv1,responseLv2;
	        Target_List__c tglWithReponse = new Target_List__c();
	        tglWithReponse.Id = recordId;
	        for(String key : mapReponseByFieldApi.keySet()){
	        	Object fieldValue = getCastedFieldValueByFieldType(key,mapReponseByFieldApi.get(key));
	        	tglWithReponse.put(key,fieldValue);
	        	if(key == 'Response_Level_1__c'){
	        		responseLv1 = String.valueOf(mapReponseByFieldApi.get(key));
	        	}else if(key == 'Response_Level_2__c'){
	        		responseLv2 = String.valueOf(mapReponseByFieldApi.get(key));
	        	}
	        }
	        tglWithReponse.Status__c = String.isBlank(responseLv2)?responseLv1:responseLv2;
	        tglWithReponse.Opportunity__c = jobId;
	        if(tglWithReponse.Create_New_Job__c == null) tglWithReponse.Create_New_Job__c = false;
            if(hasPermissionToUpdate(recordId,tglWithReponse)){
    	        update tglWithReponse;
    	        Target_List__c resultTglWithOpp = [SELECT Opportunity__c,Opportunity__r.Name FROM Target_List__c WHERE Id = :tglWithReponse.Id];
    	        response.isSuccess = true;
    	        response.relatedOpp = new Opportunity(Id=resultTglWithOpp.Opportunity__c,Name=resultTglWithOpp.Opportunity__r.Name);
            }else{
                response.isSuccess = false;
                response.message = Label.Not_Allow_to_update_record;
            }
    	}catch(Exception e){
    		response.isSuccess = false;
    		if(e.getMessage().toLowerCase().contains('insufficient access')){
    			response.message = Label.Not_Allow_to_update_record;
    		}else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
    			response.message = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',': []');
    		}else{
                response.message = e.getMessage();
            }
            System.debug(e.getStackTraceString());
    	}
    	return response;
    }

    private static Object getCastedFieldValueByFieldType(String apiName,Object fieldValue){
    	String fieldType = Schema.SObjectType.Target_List__c.fields.getMap().get(apiName).getDescribe().getType().name();
    	if(fieldValue == null || fieldValue == '') return null;
    	if(fieldType == 'DATE'){
    		List<String> inputDate = String.valueOf(fieldValue).split('-');
    		String userLocale = UserInfo.getLocale();
    		Integer year = Integer.valueOf(inputDate[0]);
    		if(userLocale.contains('th')){
    			year = year+543;
    		}
    		return Date.newInstance(year, Integer.valueOf(inputDate[1]), Integer.valueOf(inputDate[2]));
    	}else if(fieldType == 'DOUBLE'){
    		return Double.valueOf(fieldValue);
    	}else if(fieldType == 'INTEGER'){
    		return Integer.valueOf(fieldValue);
    	}else if(fieldType == 'BOOLEAN'){
    		return Boolean.valueOf(fieldValue);
    	}else if(fieldType == 'CURRENCY'){
    		return Decimal.valueOf(String.valueOf(fieldValue));
    	}else{
    		return String.valueOf(fieldValue);
    	}
    }

    public static List<StandardFieldSet> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        List<StandardFieldSet> fields = new List<StandardFieldSet>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            StandardFieldSet f = new StandardFieldSet(fsm);
			Schema.DescribeFieldResult fieldResult = fieldMap.get(f.APIName).getDescribe();
            if(fieldResult.getType().name() == 'Picklist'){
            	f.isPicklist = true;
            	f.picklistValues = new Map<String,String>();
            	Map<String,String> tempMapPickListValue = new Map<String,String>();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				tempMapPickListValue.put('','');
				for( Schema.PicklistEntry eachValue : ple){
					if(eachValue.isActive()) tempMapPickListValue.put(eachValue.getValue(),eachValue.getLabel());
			    }
				f.picklistValues = tempMapPickListValue;
            }else if(setFieldNotDependOnFieldSetTypePicklist.contains(f.APIName)){
            	f.isManualPicklist = true;
            }

            fields.add(f);
        }

        return fields;
    }
    
    public static SObject getRecord(Id recordId, String objectName, List<StandardFieldSet> fields) {

        if (recordId == null) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            return objectType.newSObject();
        }
        
        List<String> fieldsToQuery = new List<String>();
        for (StandardFieldSet f : fields) {
            fieldsToQuery.add(f.APIName);
        }
        
        Schema.SObjectType objectType = recordId.getSobjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        String objectAPIName = objectDescribe.getName();
        
        String recordSOQL = 'SELECT ' + String.join(fieldsToQuery, ',') +
                            '  FROM ' + objectName +
                            ' WHERE Id = :recordId';

        SObject record = Database.query(recordSOQL);
        
        return record;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<StandardFieldSet> Fields { get; set; }
        
        @AuraEnabled
        public SObject Record { get; set; }

        @AuraEnabled
        public String LeadCode { get; set; }

        @AuraEnabled
        public String LeadSubType { get; set; }
        @AuraEnabled
        public String ParentId { get; set; }
        @AuraEnabled
        public Opportunity Job { get; set; }
        @AuraEnabled
        public Boolean HasJobReadAccess { get; set; }
        @AuraEnabled
        public Boolean isMobile { get; set; }
        @AuraEnabled
        public Boolean isError { get; set; }
        
        public FieldSetForm() {
            Fields = new List<StandardFieldSet>();
        }
    }

    public PageReference submitResponse(){
        this.resultresponse = validate();
        if(this.resultresponse.isSuccess)
        {
            for(Target_List__c eachTargetList : this.targetLists){
                eachTargetList.Status__c = this.responseModel.responseLv1;
                eachTargetList.Response_Level_1__c = this.responseModel.responseLv1;
                eachTargetList.Response_Level_2__c = this.responseModel.responseLv2;
                eachTargetList.Memo__c = this.responseModel.memo;
            }
            update targetLists;
            return gotoRecentListView();
        }else{
                return null;
        }
    }

    public ResultResponse validate(){
        String segment = checkTeamSegmentFromCampaignCode(campaignCode);
        ResultResponse res = new ResultResponse();
        if(String.isBlank(this.responseModel.responseLv1)){
                res.isSuccess = false;
                res.message = 'Please Select ResponseLevel 1';
        }else{
            List<Global_Master_Data__c> leadResponse;
            if(String.isBlank(this.responseModel.responseLv2) ){
                leadResponse = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Team__c = :segment AND LeadResponse_Type__c = :leadSubType AND LeadResponse_Response_Level1__c =:this.responseModel.responseLv1 AND LeadResponse_Response_Level2__c = null AND RecordType.DeveloperName = 'LeadResponse'];
            }else{
                leadResponse = [SELECT LeadResponse_Required_Date__c,LeadResponse_Required_App_ID__c, LeadResponse_Required_Level2__c, LeadResponse_Required_Memo__c, LeadResponse_Response_Level2__c FROM Global_Master_Data__c WHERE LeadResponse_Team__c = :segment AND LeadResponse_Type__c = :leadSubType AND RecordType.DeveloperName = 'LeadResponse' AND (LeadResponse_Response_Level1__c =:this.responseModel.responseLv1 AND LeadResponse_Response_Level2__c = :this.responseModel.responseLv2)];
            }
           
            if(!leadResponse.isEmpty()){
                if(leadResponse.get(0).LeadResponse_Required_Level2__c && String.isBlank(this.responseModel.responseLv2) ){
                    res.isSuccess = false;
                    res.message = 'Please Select ResponseLevel 2';
                }else if(leadResponse.get(0).LeadResponse_Required_Memo__c && String.isBlank(this.responseModel.memo)){
                    res.isSuccess = false;
                    res.message = 'Please fill in MemoText';
                }
            }else{
               res.isSuccess = false;
                res.message = 'Cannot find LeadResponse'; 
            }
        }
        return res;
    }

    public static String checkTeamSegmentFromCampaignCode(String campaignCode){
        Campaign campaign = [SELECT id,RecordType.Name From Campaign WHERE Lead_Campaign_Event_Code__c =:campaignCode Limit 1];
        String segment;
        if(campaign.RecordType.Name.contains(GlobalConstants.SME) ){
            segment = GlobalConstants.SME;
        }else if(campaign.RecordType.Name.contains(GlobalConstants.CBS)){
            segment = GlobalConstants.CBS;
        }else if(campaign.RecordType.Name.contains(GlobalConstants.RBS)){
            segment = GlobalConstants.RBS;
        }else{
            segment = GlobalConstants.SME;
        }
        return segment;
    }

    public PageReference gotoRecentListView(){
        return new ApexPages.Action('{!List}').invoke();
    }
    public class AnswerObject{
        @AuraEnabled
        public Boolean isRequireLv2 { get; set; }
        @AuraEnabled
        public Boolean isRequireMemo { get; set; }
        @AuraEnabled
        public Boolean isRequiredAppId { get; set; }
        @AuraEnabled
        public Boolean isRequiredDate { get; set; }
        @AuraEnabled
        public String answer { get; set; }
    }

    public class ResultResponse{
    	@AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Opportunity relatedOpp;
        public ResultResponse(){
            message = null;
            isSuccess = true;
        }
    }

    public class ResponseModel{
        public AnswerObject answerObj {get;set;}
        public String responseLv1 {get;set;}
        public String responseLv2 {get;set;}
        public String memo {get;set;}
    }
}