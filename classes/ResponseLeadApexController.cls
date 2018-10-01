public with sharing class ResponseLeadApexController {

	public class ResponseLeadException extends Exception{}

	public class AnswerSelectedObject{
		public String answerId {get;set;}
		public String answerText {get;set;}
		public String memoText {get;set;}
		public String noteText {get;set;}
		public String level {get;set;}
		public String questionId {get;set;}
		public String responseId {get;set;}
		public Boolean isRequiredMemo {get;set;}
		public Boolean isShowMemo {get;set;}
		public Boolean isRequiredNextLv {get;set;}
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

	public List<Target_List__c> targetLists {get;set;}
	public String targetListsJSONString {get{return JSON.serialize(targetLists);}}

	// private Boolean hasDiffLeadType = false;
	public String leadType {get;set;}
	public String leadSubType {get;private set;}

	public Map<String,Map<String,Object>> questionMap{get;set;}
	public String questionMapJSONString {get;set;}

	public Map<String,Lead_Response_Master__c> responsesMap = new Map<String,Lead_Response_Master__c>();
	public Map<String,Lead_Master__c> masterMap = new Map<String,Lead_Master__c>();
	public Map<String,String> relationBetweenMasterAndAttrMap = new Map<String,String>();
	public String selectedAnswer {get;set;}
	public String answerQuestion {get;set;}
	public String nextLv {get;set;}
	public Map<String,String> mapQuestionAnswerSelected {get;set;}
	public String mapAnswerObjStr {get;set;}
 	private Integer MaxLevel = 5;
	public String selectedJSONString {get{return JSON.serialize(mapQuestionAnswerSelected);}}
 	public Map<Integer,AnswerSelectedObject> answerSelectedList {get;set;}
	public  FieldSetForm form {get;set;}
	public  String formJSONString {get{return JSON.serialize(form);}}
	public ResultResponse resultresponse {get;set;}
    public String resultResponseJSONString {get {return JSON.serialize(resultresponse);}}

    public String isCheckedNewJob {get;set;}
    public String opportunityId {get;set;}
	public Id recordId {get;set;}
    public Boolean isListViewPage {get;set;}
	public String isRedirectPage {get;set;}

	public Boolean hasExpireCampaign {get;set;}
    public Boolean hasOtherLeadType {get;set;}


 	public ResponseLeadApexController(ApexPages.StandardSetController controller){
		this.recordId = ApexPages.currentPage().getParameters().get('Id');
		this.isRedirectPage = ApexPages.currentPage().getParameters().get('isRedirectPage');
		List<Target_List__c> targetListSelected = new List<Target_List__c>();

		this.targetLists = new List<Target_List__c>();

		String queryString = ' SELECT Id,Lead_Type__c,Memo__c,Memo_2__c,Memo_3__c,Memo_4__c,Memo_5__c,Note_1__c, Note_2__c, Note_3__c, Note_4__c, Note_5__c,Response_Date__c,Response_Level_1__c,Response_Level_2__c,Response_Level_3__c,Response_Level_4__c,Response_Level_5__c,Lead_Subtype_CBS__c,Status__c,Create_New_Job__c,Lead_Campaign__r.EndDate,Lead_SubType__c,isCurrentOwner__c  From Target_List__c ';
		if(recordId != null){
			this.isListViewPage = false;
			queryString += ' WHERE Id =:recordId';
			this.targetLists = Database.query(queryString);
		}else{
			if(controller.getSelected() != null){
				targetListSelected = controller.getSelected();
				if(targetListSelected.size() > 0){
					queryString += ' WHERE Id IN :targetListSelected';
					this.targetLists = Database.query(queryString);
				}	
			}
			this.isListViewPage = true;
		}
		
		if(this.targetLists.size() > 0){
			setLeadType();
			this.form = getForm(recordId);
			this.leadSubType = this.targetLists.get(0).Lead_Subtype_CBS__c == null ? this.targetLists.get(0).Lead_Subtype__c: this.targetLists.get(0).Lead_Subtype_CBS__c;
			//Get old answers
			if(this.targetLists.size() == 1 && this.targetLists.get(0).Response_Date__c != null){
				this.answerSelectedList = new Map<Integer,AnswerSelectedObject>();

				mapQuestionAnswerSelected = new Map<String,String>();
				for(Integer i =1;i<=MaxLevel;i++){
					AnswerSelectedObject answerSelected = new AnswerSelectedObject();
					if(this.targetLists.get(0).get('Response_Level_' + i + '__c') != null){
						answerSelected.answerId = '1';
						answerSelected.answerText = this.targetLists.get(0).get('Response_Level_' + i + '__c').toString();
						answerSelected.level = String.valueOf(i);
						mapQuestionAnswerSelected.put(answerSelected.level,this.targetLists.get(0).get('Response_Level_' + i + '__c').toString());
					
					}
					if(i == 1){
						if(this.targetLists.get(0).Memo__c != null){
							answerSelected.memoText = this.targetLists.get(0).Memo__c;
							answerSelected.isShowMemo = true;
						}
					} else {
						if(this.targetLists.get(0).get('Memo_' + i + '__c') != null){
							answerSelected.memoText = this.targetLists.get(0).get('Memo_' + i + '__c').toString();
							answerSelected.isShowMemo = true;
						}
					}

					if(this.targetLists.get(0).get('Note_' + i + '__c') != null){
						answerSelected.noteText = this.targetLists.get(0).get('Note_' + i + '__c').toString();				
					}
					this.answerSelectedList.put(i,answerSelected);
				}
				if(this.targetLists.get(0).Create_New_Job__c){
					this.isCheckedNewJob = 'true';
				}else{
					this.isCheckedNewJob = 'false';
				}
				
			} else {
				this.answerSelectedList = null;
			}

			questionMap = new Map<String,Map<String,Object>>();
			setupQuestionAndChoices();
		}
	}

 	private Boolean validateTargetList(){
 		if(!this.targetLists.isEmpty()){
			hasExpireCampaign = false;
            hasOtherLeadType = false;
            for(Target_List__c  eachTargetList : this.targetLists ){
                if(eachTargetList.Lead_Type__c  == null || (eachTargetList.Lead_Type__c  != GlobalConstants.LEAD_FOR_FEEDBACK && isListViewPage)){
                    hasOtherLeadType = true;
                    return false;
                }
                if(eachTargetList.Lead_Campaign__r.EndDate < System.today()){
                    hasExpireCampaign = true;
                    return false;
                }
            }
        }
        return true;
 	}

 	private void setLeadType(){
 		if(validateTargetList()){
 			this.leadType = this.targetLists.get(0).Lead_Type__c;
 		} else {
 			this.leadType =  null;
 		}
 	}

	private List<Lead_Master__c> getLeadMaster(){
		List<Lead_Master__c> leadMaster = [SELECT Id,Is_Main_Level__c,Lead_Type__c,No_of_Level__c,Starting_Response_ID__c,Note__c 
									FROM Lead_Master__c WHERE Lead_Type__c = :this.leadSubType ORDER BY No_of_Level__c ASC];
		return leadMaster;
	}

	private List<Lead_Master__c> getLeadMasterByLevel(String level){
		List<Lead_Master__c> leadMaster = [SELECT Id,Is_Main_Level__c,Lead_Type__c,No_of_Level__c,Starting_Response_ID__c,Note__c 
									FROM Lead_Master__c WHERE Lead_Type__c = :this.leadSubType AND No_of_Level__c >= :level ORDER BY No_of_Level__c ASC];
		return leadMaster;
	}

	private List<Lead_Response_Master__c> getLeadResponseMaster(){
		List<Lead_Response_Master__c> leadResponseMasterMap = [SELECT Id,Response_ID__c,Message__c,Required_Memo__c,Show_Memo__c,Help_Text__c 
									FROM Lead_Response_Master__c ORDER BY Response_ID__c ASC];
		return leadResponseMasterMap;
	}

	private List<Lead_Relations_Master__c> getLeadRelationsMaster(Set<String> responseIDs){
		List<Lead_Relations_Master__c> leadResponseMasterMap = [SELECT Id,Response_ID__c,Related_Response_ID__c,Lead_Type__c 
									FROM Lead_Relations_Master__c WHERE Response_ID__c IN :responseIDs AND Lead_Type__c = :this.leadSubType ORDER BY Response_ID__c,Related_Response_ID__c ASC];
		return leadResponseMasterMap;
	}

	private Map<String,List<Lead_Relations_Master__c>> getLeadRelationsMasterMap(){
		Map<String,List<Lead_Relations_Master__c>> result = new Map<String,List<Lead_Relations_Master__c>>();
		List<Lead_Relations_Master__c> listLeadResponseMaster = [SELECT Id,Response_ID__c,Related_Response_ID__c,Lead_Type__c 
									FROM Lead_Relations_Master__c ORDER BY Response_ID__c,Related_Response_ID__c ASC];
		for(Lead_Relations_Master__c eachleadResponseMaster : listLeadResponseMaster){
			if(!result.containsKey(eachleadResponseMaster.Response_ID__c)){
				result.put(eachleadResponseMaster.Response_ID__c,new List<Lead_Relations_Master__c>());
			}
			result.get(eachleadResponseMaster.Response_ID__c).add(eachleadResponseMaster);
		}
		return result;
	}

	public List<Lead_Response_Master__c> manualSortChoices(List<Lead_Response_Master__c> choicesList){
		List<LeadResponseMasterComparator> listLeadResponseMasterComparator = new List<LeadResponseMasterComparator>();
		for(Lead_Response_Master__c eachChoice : choicesList){
			LeadResponseMasterComparator comparator = new LeadResponseMasterComparator(eachChoice);
			listLeadResponseMasterComparator.add(comparator);
		}
		listLeadResponseMasterComparator.sort();

		List<Lead_Response_Master__c> sortResult = new List<Lead_Response_Master__c>();
		for(LeadResponseMasterComparator eachSortResult : listLeadResponseMasterComparator){
			sortResult.add(eachSortResult.leadResponseMaster);
		}

		return sortResult;
	}

	@TestVisible
	private void setupQuestionAndChoices(){
		try{
			List<Lead_Master__c> masters = getLeadMaster();

			if(!(masters != null && masters.size() != 0)){
				return;
			}

			Set<String> responseIDs = new Set<String>();
			List<Lead_Response_Master__c> allChoices = null;

			//Format master to map
			Map<String,Object> attrMap = null;
			for(Lead_Master__c master:masters){
				responseIDs.add(master.Starting_Response_ID__c);
				masterMap.put(master.Starting_Response_ID__c,master);
				attrMap = new Map<String,Object>();
				allChoices = new List<Lead_Response_Master__c>();
				AnswerSelectedObject answerObjDefault = new AnswerSelectedObject();
				answerObjDefault.answerId = '0';
				answerObjDefault.noteText = master.Note__c;
				attrMap.put('Level',master.No_of_Level__c);
				attrMap.put('isMain',master.Is_Main_Level__c);
				attrMap.put('Lead_Code_Type',master.Lead_Type__c);
				attrMap.put('Answered',answerObjDefault);
				if(this.answerSelectedList != null && this.answerSelectedList.containsKey(Integer.valueof(master.No_of_Level__c))){
					if(this.answerSelectedList.get(Integer.valueof(master.No_of_Level__c)) != null){
						if(this.answerSelectedList.get(Integer.valueof(master.No_of_Level__c)).noteText == null && answerObjDefault.noteText != null){
							this.answerSelectedList.get(Integer.valueof(master.No_of_Level__c)).noteText = answerObjDefault.noteText;
						}
						attrMap.put('Answered',this.answerSelectedList.get(Integer.valueof(master.No_of_Level__c)));
					}
				}
				attrMap.put('Choices',allChoices);
				attrMap.put('Message','Response Level '+master.No_of_Level__c);	
				questionMap.put(master.Starting_Response_ID__c,attrMap);
				relationBetweenMasterAndAttrMap.put(master.No_of_Level__c,master.Starting_Response_ID__c);
			}

			List<Lead_Response_Master__c> responses = getLeadResponseMaster();
			
			for(Lead_Response_Master__c response :responses){
				if(answerSelectedList != null){
					for(AnswerSelectedObject eachAnswerSelected : answerSelectedList.values()){
						if(eachAnswerSelected.answerText == response.Message__c){
							responseIDs.add(response.Response_ID__c);
							eachAnswerSelected.responseId = response.Response_ID__c;
							break;
						}
					}
				}

				responsesMap.put(response.Response_ID__c,response);
				attrMap = questionMap.get(response.Response_ID__c);
				if(attrMap != null){
					if(response.Message__c != null){
						attrMap.put('Message',response.Message__c);
					}
					questionMap.put(response.Response_ID__c,attrMap);
				}
			}

			Lead_Master__c mMap = null;
			Lead_Response_Master__c rMap = null;
			Map<String,List<Lead_Relations_Master__c>> mapLeadRelationsMasterByResponseId = getLeadRelationsMasterMap();
			List<Lead_Relations_Master__c> relations = getLeadRelationsMaster(responseIDs);

			for(Lead_Relations_Master__c relation : relations){
				AnswerSelectedObject answerSelectedByLevel;
				if(answerSelectedList != null){
					for(Integer eachAnswerSelectedIndex : answerSelectedList.keySet()){
						AnswerSelectedObject eachAnswerSelected = answerSelectedList.get(eachAnswerSelectedIndex);
						if(eachAnswerSelected.responseId == relation.Related_Response_ID__c){
							answerSelectedByLevel = eachAnswerSelected;
							break;
						}
					}
				}
				String responseId;
				if(answerSelectedByLevel != null){
					responseId = relationBetweenMasterAndAttrMap.get(answerSelectedByLevel.level);
					rMap = responsesMap.get(answerSelectedByLevel.responseId);
				}else{
					responseId = relation.Response_ID__c;
					rMap = responsesMap.get(responseId);
				}
				attrMap = questionMap.get(responseId);
				if(rMap != null && attrMap != null){
					allChoices = (List<Lead_Response_Master__c>) questionMap.get(responseId).get('Choices');
					Set<Lead_Response_Master__c> setChoices = new Set<Lead_Response_Master__c>(allChoices);
					if(mapLeadRelationsMasterByResponseId.containsKey(relation.Response_ID__c)){
						for(Lead_Relations_Master__c eachReletion : mapLeadRelationsMasterByResponseId.get(relation.Response_ID__c)){
							setChoices.add(responsesMap.get(eachReletion.Related_Response_ID__c));
							allChoices = new List<Lead_Response_Master__c>(setChoices);
							if(allChoices.size()>1){
								allChoices = manualSortChoices(allChoices);
							}
						}
					}
					attrMap.put('Choices',allChoices);
					questionMap.put(responseId,attrMap);
				}
			}

			for(String eachIndex : relationBetweenMasterAndAttrMap.keySet()){
				String currentResponseId = relationBetweenMasterAndAttrMap.get(eachIndex);
				Map<String,Object> eachCurrentAttrMap = questionMap.get(currentResponseId);
				AnswerSelectedObject eachCurrentAnswerSelected = (AnswerSelectedObject)eachCurrentAttrMap.get('Answered');
				List<Lead_Response_Master__c> listCurrentChoices = (List<Lead_Response_Master__c>)eachCurrentAttrMap.get('Choices');
				if((listCurrentChoices == null || listCurrentChoices.size() == 0)){
					String previousResponseId = relationBetweenMasterAndAttrMap.get(String.valueOf(Integer.valueOf(eachIndex) - 1));
					Map<String,Object> previousAttrMap = questionMap.get(previousResponseId);
					AnswerSelectedObject previousAnswerSelected = (AnswerSelectedObject)previousAttrMap.get('Answered');
					if(previousAnswerSelected.answerText != null){
						List<Lead_Response_Master__c> allChoicesNextLevel = (List<Lead_Response_Master__c>) questionMap.get(currentResponseId).get('Choices');
						Set<Lead_Response_Master__c> setChoicesNextLevel = new Set<Lead_Response_Master__c>(allChoicesNextLevel);
						if(mapLeadRelationsMasterByResponseId.containsKey(previousAnswerSelected.responseId)){
							for(Lead_Relations_Master__c eachReletion : mapLeadRelationsMasterByResponseId.get(previousAnswerSelected.responseId)){
								setChoicesNextLevel.add(responsesMap.get(eachReletion.Related_Response_ID__c));
								allChoicesNextLevel = new List<Lead_Response_Master__c>(setChoicesNextLevel);
								if(allChoicesNextLevel.size()>1){
									allChoicesNextLevel = manualSortChoices(allChoicesNextLevel);
								}
							}
						}
						eachCurrentAttrMap.put('Choices',allChoicesNextLevel);
						questionMap.put(currentResponseId,eachCurrentAttrMap);
					}
				}
			}
		}catch(Exception e){
			System.debug(e.getStackTraceString());
			System.debug('Error setupQuestionAndChoices :'+e);
		}

	}

	public void mapListResponseIntoMap(){
		mapQuestionAnswerSelected = new Map<String,String>();

		List<AnswerSelectedObject> listResponseObj = null;
		if(mapAnswerObjStr != null){
			listResponseObj = (List<AnswerSelectedObject>) JSON.deserialize(mapAnswerObjStr,List<AnswerSelectedObject>.class);
		}
		if(listResponseObj != null){
			for(AnswerSelectedObject answerSelected : listResponseObj){
				if(this.questionMap.containsKey(answerSelected.questionId)){
					this.questionMap.get(answerSelected.questionId).put('Answered',answerSelected);
				}
				mapQuestionAnswerSelected.put(answerSelected.questionId,answerSelected.answerId);
			}
		}
	}

	public void onChangeResponse(){

		Set<String> ansIds = new Set<String>();

		if(selectedAnswer != '0'){
			ansIds.add(selectedAnswer); 
		}

		mapListResponseIntoMap();

		List<Lead_Relations_Master__c> relations = getLeadRelationsMaster(ansIds);
		List<Lead_Response_Master__c> allChoices = null;
		if(nextLv != null && nextLv != ''){
			List<Lead_Master__c> mOverLvList = getLeadMasterByLevel(nextLv);
			Lead_Response_Master__c rMap = null;
			Lead_Master__c mMap = null;

			//if(masterMap.containsKey(relationBetweenMasterAndAttrMap.get(String.valueOf(Integer.valueOf(nextLv)-1)))){
			//	AnswerSelectedObject previousLevelAnswerObj = (AnswerSelectedObject)questionMap.get(relationBetweenMasterAndAttrMap.get(String.valueOf(Integer.valueOf(nextLv)-1))).get('Answered');
			//	previousLevelAnswerObj.noteText = masterMap.get(relationBetweenMasterAndAttrMap.get(String.valueOf(Integer.valueOf(nextLv)-1))).Note__c;
			//}

			// check data next Levels
			for(Lead_Master__c m : mOverLvList){
					if(m.Is_Main_Level__c) break;
					// clear choices for next Level
					questionMap.get(m.Starting_Response_ID__c).put('Choices',new List<Lead_Response_Master__c>());

					// remove response next level
					if(mapQuestionAnswerSelected.containsKey(m.Starting_Response_ID__c) || mapQuestionAnswerSelected.containsKey(m.No_of_Level__c)){
						mapQuestionAnswerSelected.remove(m.Starting_Response_ID__c);
					}
					if(questionMap.get(m.Starting_Response_ID__c).get('Answered') != ''){
						AnswerSelectedObject answerObjDefault = new AnswerSelectedObject();
						answerObjDefault.answerId = '0';
						answerObjDefault.noteText = m.Note__c;
						questionMap.get(m.Starting_Response_ID__c).put('Answered',answerObjDefault);
					}
			}
			
			// get choices for next one Level
			for(Lead_Relations_Master__c relation : relations){
				rMap = responsesMap.get(relation.Response_ID__c);
				if(rMap != null){
					if(allChoices == null){
						allChoices = new List<Lead_Response_Master__c>();
					}
					if(mOverLvList[0].No_of_Level__c == nextLv){
						allChoices.add(responsesMap.get(relation.Related_Response_ID__c));
						if(allChoices.size()>1){
							allChoices = manualSortChoices(allChoices);
						}
						questionMap.get(mOverLvList[0].Starting_Response_ID__c).put('Choices',allChoices);
					}
				}
							
			}
		}
    }

    public void save(){

		mapListResponseIntoMap();
		this.resultresponse = new ResultResponse();
		
    	if(!this.targetLists.isEmpty()){
			List<String> keys = new List<String>(questionMap.keySet());
            for(Target_List__c  eachTargetList : this.targetLists ){
				if(keys.size() > 0){
					for(String key : keys){
						AnswerSelectedObject finalAnswer = new AnswerSelectedObject();
							finalAnswer = (AnswerSelectedObject) questionMap.get(key).get('Answered');
							if(finalAnswer.level != null){
								if(finalAnswer.answerId != '0'){
									eachTargetList.put('Response_Level_' + finalAnswer.level + '__c', finalAnswer.answerText);
									eachTargetList.Status__c = finalAnswer.answerText;
								}else{
									eachTargetList.put('Response_Level_' + finalAnswer.level + '__c', null);
								}
								eachTargetList.put('Note_' + finalAnswer.level + '__c', finalAnswer.noteText);

								if(finalAnswer.level == '1'){
									eachTargetList.put('Memo__c', finalAnswer.memoText);
								}else{
									eachTargetList.put('Memo_' + finalAnswer.level + '__c', finalAnswer.memoText);
								}
							}
					}
            	}
                eachTargetList.Response_Date__c = System.today();
            }
            if(this.targetLists.size() == 1 && !isListViewPage){
				if(opportunityId != ''){
            		this.targetLists.get(0).Opportunity__c = opportunityId;
				}else{
					this.targetLists.get(0).Opportunity__c = null;
				}

                if(isCheckedNewJob.equalsIgnoreCase('true')){
                	this.targetLists.get(0).Create_New_Job__c = true;
                }else{
					this.targetLists.get(0).Create_New_Job__c = false;
				}
                
            }
	        try{
				update this.targetLists;
				this.resultresponse.isSuccess = true;
            } catch(Exception ex){
				this.resultresponse.isSuccess = false;
				if(ex.getMessage().toLowerCase().contains('insufficient access')){
					this.resultresponse.message = Label.Not_Allow_to_update_record;
				}else if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
					this.resultresponse.message = ex.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',': []');
				}else{
					this.resultresponse.message = ex.getMessage();
				}
	        }
        }
    }
	
	public PageReference gotoRecentView() {
		if(isListViewPage){
			return gotoRecentListView();
		}else{
			return redirectToRecordView();
		}
    }
	
	public PageReference gotoRecentListView(){
        return new ApexPages.Action('{!List}').invoke();
    }

	public PageReference redirectToRecordView(){
        PageReference pg = new PageReference('/'+this.recordId);
        pg.setRedirect(true);
        return pg;
    }

	public class FieldSetForm {
        public String LeadCode { get; set; }
        public String LeadSubType { get; set; }
        public String ParentId { get; set; }
        public Opportunity Job { get; set; }
        public Boolean HasJobReadAccess { get; set; }
        public Boolean isMobile { get; set; }
        public Boolean isError { get; set; }       
    }

	public static FieldSetForm getForm(Id recordId) {
        FieldSetForm form = new FieldSetForm();
        try{
            Target_List__c currentTgl = [SELECT Opportunity__c,Opportunity__r.Name,Lead_Type__c,Lead_Subtype__c,Lead_Subtype_CBS__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c ,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Id =:recordId];
            UserRecordAccess hasJobReadAccess;
            if(currentTgl.Opportunity__c != null){
                hasJobReadAccess = [SELECT HasReadAccess,RecordId From UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:currentTgl.Opportunity__c Limit 1];
            }

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
        }
        form.isMobile = UserInfo.getUiThemeDisplayed() == 'Theme4t'?true:false;
        return form;
    }
	

}