public without sharing class CustomTaskSection_Controller {
    public List<Task> allTasks {get; set;}
    public List<CustomTasks> listCustomTasks {get; set;}
    public List<CustomTasks> customTasksWithOffset;
    public Map<Id, CustomTasks> mapCustomTasksById;
    public Map<Id,Target_List__c> mapTargetListById {get;set;}
    public Map<String, Boolean> mapCheckDateByResponseLvl1 {get;set;}
    public String jsonMapCheckDateByResponseLvl1 {get;set;}
    public Map<String, Boolean> mapCheckResponseLvl1CBS;
    public Map<String, Boolean> mapCheckResponseLvl2CBS;
    public Map<String, Boolean> mapCheckMemoCBS {get;set;}
    public String mapParentChildrenJSON {get;set;}

    public Opportunity dummyOpp {get;set;}
    
    public String selectFilter {get;set;}
    public String selectedResponse {get;set;}
    public String selectedResponseLV1 {get;set;}
    public String selectedResponseLV2 {get;set;}
    public Date dateInput {get;set;}
    public String taskRecordSelected {get;set;}
    
    public Boolean showErrorDate {get;set;}
    public Boolean atLeastOneChecked {get;set;}    
    public Boolean sameTypeCheck {get;set;}
    public Boolean displayErrorAtLeastOneRecordChecked {get; set;}
    public Boolean displayErrorNotSameType {get; set;}
    public Boolean displaySubTypePopUp {get; set;}
    public Boolean displaySubTypePopUpCBS {get; set;} /*-----Taranyoo.B-----*/
    public Boolean showDate {get;set;}
    public Boolean showMemo {get;set;} /*-----Taranyoo.B-----*/
    public Boolean showResponseLV2 {get;set;} /*-----Taranyoo.B-----*/
    public Boolean hasTargetList {get;set;}
    public Boolean isCheckedAll {get;set;}
    public Boolean singleSelect {
        get;
        set{
            singleSelect = value;
        }
    }

    public Boolean checkUserCBSForHideFields {get;set;}

    public List<Lead_To_Do_Response__c> leadToDoResponseList {get;set;}
    public List<SelectOption> responseOptions {get;set;}
    public List<SelectOption> responseOptionsLV1CBS {get;set;}
    public List<SelectOption> responseOptionsLV2CBS {get;set;}

    public Integer offsetSize {get;set;}
    private Integer queryLimit;

    public Integer sizeOfAllTask {get;set;}
    public Integer sizeOfRecordsShowing {get;set;}
    public Integer startSize {get;set;}

    public String regexForCutResponse;
    
    public class CustomTasks{
        public Task eachTask {get;  set;}
        public Boolean isChecked {get;  set;}
        public Boolean isTargetList {get;  set;}
        
    }

    public CustomTaskSection_Controller(){

        taskRecordSelected = null;
        singleSelect = false;
        showDate = false;
        showMemo = false;
        atLeastOneChecked = false;
        sameTypeCheck = false;

        mapTargetListById = new Map<Id,Target_List__c>();
        
        
        offsetSize = 0;

        selectFilter = 'All_Open';
        dummyOpp = new Opportunity(CloseDate = null,Remark__c = null);
        
        dateInput = null;

        leadToDoResponseList = new List<Lead_To_Do_Response__c>();
        customTasksWithOffset = new List<CustomTasks>();
        
        this.initCustomTasks(selectFilter);
    }

    public void initCustomTasks(String filter){
        hasTargetList = false;
        isCheckedAll = false;
        sizeOfAllTask = 0;
        startSize = 0;

        customTasksWithOffset = new List<CustomTasks>();
        mapCustomTasksById = new Map<Id,CustomTasks>();
        mapCheckDateByResponseLvl1 = new Map<String,Boolean>();
        mapCheckResponseLvl1CBS = new Map<String,Boolean>();
        mapCheckResponseLvl2CBS = new Map<String,Boolean>();
        mapCheckMemoCBS = new Map<String,Boolean>();
        listCustomTasks = new List<CustomTasks>();
        mapParentChildrenJSON = '';

        Set<Id> setOfRelatedTo = new Set<Id>();
        Map<String,CBS_Profiles__c> cbsProfileNameMap = CBS_Profiles__c.getAll();

        Map<Id,Profile> cbsProfileMap = new Map<Id,Profile>([SELECT Id,Name FROM Profile WHERE Name IN :cbsProfileNameMap.keySet()]);

        checkUserCBSForHideFields = true;

        queryLimit = 15;
        
            if(cbsProfileMap.containsKey(UserInfo.getProfileId())){
                checkUserCBSForHideFields = false;
            }
            
            if(filter.equals('All_Open')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '', 'OPEN', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Today')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '=', 'TODAY', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Overdue')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '<', 'TODAY', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Today_Overdue')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '<=', 'TODAY', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Tomorrow')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '=', 'TOMORROW', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Next_7_Days')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '', 'NEXT_N_DAYS:', '7', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Next_7_Days_Overdue')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '<=', 'NEXT_N_DAYS:', '7', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('This_Month')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '', 'THIS_MONTH', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('New')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '', 'New', '', 'false', !checkUserCBSForHideFields);
            }else if(filter.equals('Completed')){
                allTasks = Task_Service.initializeFilter(UserInfo.getUserId(), '', '', '', 'true', !checkUserCBSForHideFields);
            }
        
        if(allTasks.size()>0){
            startSize = 1;
            for(Task eachTask : allTasks){
                setOfRelatedTo.add(eachTask.WhatId);
            }
            mapTargetListById = new Map<Id,Target_List__c>([SELECT Id, Lead_Subtype__c,Lead_Campaign__r.Lead_Campaign_Event_Code__c,Active_Target_List__c, Status__c, Memo__c, Personalised_Message__c, Priority__c, Priority_Group__c, Priority_Group_Display__c, Start_Date__c,End_Date__c,Lead_Subtype_CBS__c FROM Target_List__c WHERE Id IN: setOfRelatedTo AND  Active_Target_List__c != null ORDER BY Priority_Group_Display__c DESC]);

            for(Task eachTask : allTasks){
                CustomTasks eachCustomTask = new CustomTasks();
                eachCustomTask.eachTask = eachTask;
                eachCustomTask.isChecked = false;
                eachCustomTask.isTargetList = false;

                if(eachTask.What.Type == GlobalConstants.TARGET_LIST_TYPE){
                    if(mapTargetListById.containsKey(eachTask.WhatId)){
                        if(mapTargetListById.get(eachTask.WhatId).Active_Target_List__c != null){
                            listCustomTasks.add(eachCustomTask);
                            mapCustomTasksById.put(eachTask.Id, eachCustomTask);
                        }
                    }
                }else{
                    listCustomTasks.add(eachCustomTask);
                    mapCustomTasksById.put(eachTask.Id, eachCustomTask);
                }
            }

            Integer counter = 0;
            for(Integer i=0; i<listCustomTasks.size();i++){

                CustomTasks eachCustomTask = listCustomTasks.get(i);

                if(eachCustomTask.eachTask.What.Type == GlobalConstants.TARGET_LIST_TYPE){

                    if(eachCustomTask.eachTask.Lead_Sub_Type__c != null){
                        eachCustomTask.isTargetList = true;
                        hasTargetList = true;
                    }
                }
                
                if(listCustomTasks.size() >= 5){
                    sizeOfRecordsShowing = 5;
                }else{
                    counter = counter+1;
                    sizeOfRecordsShowing = counter;
                }
                sizeOfAllTask = listCustomTasks.size();
            }
            
            if(filter.equals('Completed')){
                List<CustomTasks> nullCompleteDateList = new List<CustomTasks>();
                List<CustomTasks> notNullCompleteDateList = new List<CustomTasks>();
                for(Integer i=0; i<listCustomTasks.size(); i++){
                    CustomTasks eachCustomTask = listCustomTasks.get(i);

                    eachCustomTask.isTargetList = false;

                    if(eachCustomTask.eachTask.Complete_Date__c == null){
                        nullCompleteDateList.add(eachCustomTask);
                    }else{
                        notNullCompleteDateList.add(eachCustomTask);
                    }
                }

                listCustomTasks.clear();
                listCustomTasks.addAll(notNullCompleteDateList);
                listCustomTasks.addAll(nullCompleteDateList);
                
            }
        }
    }

    public List<CustomTasks> getCustomTasksWithOffset(){
        
        hasTargetList = false;
        customTasksWithOffset = new List<CustomTasks>();
        Integer maxIndex = offsetSize+queryLimit;
        if(maxIndex >= listCustomTasks.size()){
            sizeOfRecordsShowing = listCustomTasks.size();
        }else{
            sizeOfRecordsShowing = maxIndex;
        }
        
        if(listCustomTasks.size()>0){
            for(Integer i=offsetSize; i < maxIndex ; i++){
                if(listCustomTasks.get(i).isTargetList){
                    hasTargetList = true;
                }
                customTasksWithOffset.add(listCustomTasks.get(i));
                if(listCustomTasks.size() == (i+1)){
                    break; 
                }
            }
            
            return customTasksWithOffset;
        }else{
            return null;
        }
    }

    public PageReference filterTasks(){
        this.initCustomTasks(selectFilter);
        offsetSize = 0;
        return null;
    }

    public String getselectFilter(){
        selectFilter = 'All_Open';
        return selectFilter;
    }

    public PageReference redirectPopup(){
        displaySubTypePopUp = true;
        return null;
    }

    public PageReference showDateInput(){
        showDate = true;
        return null;
    }

    public PageReference showMemoInput(){
        showMemo = true;
        return null;
    }

    public PageReference answer(){
        String checkSubTypeOrCode;
        if(!singleSelect){
            checkSubTypeOrCode = null;
            atLeastOneChecked = false;
            sameTypeCheck = false;

            for(CustomTasks eachCustomTask : mapCustomTasksById.values()){
                if(mapTargetListById.containsKey(eachCustomTask.eachTask.WhatId)){
                    Target_List__c eachTargetList = mapTargetListById.get(eachCustomTask.eachTask.WhatId);
                    if(eachCustomTask.isChecked){
                        atLeastOneChecked = true;
                        if(checkSubTypeOrCode == null){
                            if(!checkUserCBSForHideFields){
                                checkSubTypeOrCode = eachTargetList.Lead_Subtype_CBS__c;
                                sameTypeCheck = true;
                            }else{
                                checkSubTypeOrCode = eachTargetList.Lead_Campaign__r.Lead_Campaign_Event_Code__c;
                                sameTypeCheck = true;
                            }
                        }

                        if(!checkUserCBSForHideFields){
                            if(!checkSubTypeOrCode.equals(eachTargetList.Lead_Subtype_CBS__c)){
                                sameTypeCheck = false;
                            }
                        }else{
                            if(!checkSubTypeOrCode.equals(eachTargetList.Lead_Campaign__r.Lead_Campaign_Event_Code__c)){
                                sameTypeCheck = false;
                            }
                        } 
                    }
                }
            }

            if(!atLeastOneChecked){
                displayErrorAtLeastOneRecordChecked = true;
            }else if(!sameTypeCheck){
                displayErrorNotSameType = true;
            }else if(atLeastOneChecked && sameTypeCheck){
                if(!checkUserCBSForHideFields){
                    leadToDoResponseList = [SELECT Response_Level_1__c,Response_Level_2__c,Required_Memo__c,Required_Level_2__c, Required_Date__c, Type__c, Campaign_Code__c FROM Lead_To_Do_Response__c WHERE Type__c =: checkSubTypeOrCode ORDER BY Response_Level_1__c,Response_Level_2__c];
                }else{
                    leadToDoResponseList = [SELECT Response_Level_1__c,Response_Level_2__c,Required_Memo__c,Required_Level_2__c, Required_Date__c, Type__c, Campaign_Code__c FROM Lead_To_Do_Response__c WHERE Campaign_Code__c =: checkSubTypeOrCode ORDER BY Response_Level_1__c,Response_Level_2__c];
                }
                this.setResponseOptions();
                this.setResponseOptionsLV1CBS();
                
                if(!checkUserCBSForHideFields){

                    displaySubTypePopUp = false;
                    displaySubTypePopUpCBS = true;
                }
                else{
                    
                    displaySubTypePopUp = true;
                    displaySubTypePopUpCBS = false;
                }
            }
        }else{
            checkSubTypeOrCode = null;
            if(mapCustomTasksById.containsKey(taskRecordSelected)){
                CustomTasks selectedCustomTask = new CustomTasks();
                selectedCustomTask = mapCustomTasksById.get(taskRecordSelected);

                Target_List__c selectedTargetList = mapTargetListById.get(selectedCustomTask.eachTask.WhatId);
                if(checkSubTypeOrCode == null){
                    if(!checkUserCBSForHideFields){
                        checkSubTypeOrCode = selectedTargetList.Lead_Subtype_CBS__c;
                    }else{
                        checkSubTypeOrCode = selectedTargetList.Lead_Campaign__r.Lead_Campaign_Event_Code__c;
                    }
                }

                if(selectedTargetList != null){
                    if(!checkUserCBSForHideFields){
                        leadToDoResponseList = [SELECT Response_Level_1__c,Response_Level_2__c,Required_Memo__c,Required_Level_2__c, Required_Date__c , Type__c FROM Lead_To_Do_Response__c WHERE Type__c =: checkSubTypeOrCode ORDER BY Response_Level_1__c,Response_Level_2__c];
                    }else{
                        leadToDoResponseList = [SELECT Response_Level_1__c,Response_Level_2__c,Required_Memo__c,Required_Level_2__c, Required_Date__c , Type__c FROM Lead_To_Do_Response__c WHERE Campaign_Code__c =: checkSubTypeOrCode ORDER BY Response_Level_1__c,Response_Level_2__c];
                    }
                    
                    if(!checkUserCBSForHideFields){
                        this.setResponseOptionsLV1CBS();

                        displaySubTypePopUp = false;
                        displaySubTypePopUpCBS = true;
                    }
                    else{
                        this.setResponseOptions();

                        displaySubTypePopUp = true;
                        displaySubTypePopUpCBS = false;
                    }
                }
            }
        }
        
        return null;
    }

    public PageReference submitAnswer(){
        showErrorDate = false;
        Boolean dateInputHasValue = true;
        Boolean memoInputHasValue = true;

        List<Task> taskToUpdate = new List<Task>();
        if(String.isBlank(selectedResponse)){
            return null;
        }
        
        if(!singleSelect){
            for(CustomTasks eachCustomTask : mapCustomTasksById.values()){
                if(eachCustomTask.isChecked){
                    eachCustomTask.isChecked = false;
                    if(!checkUserCBSForHideFields){
                        
                        eachCustomTask.eachTask.Memo__c = dummyOpp.Remark__c;
                        eachCustomTask.eachTask.Status = selectedResponseLV1;
                        eachCustomTask.eachTask.Response_Level_1__c = selectedResponseLV1;
                        eachCustomTask.eachTask.Response_Level_2__c = selectedResponseLV2;
                    }else{
                        if(showDate){
                            if(dummyOpp.CloseDate != null){
                                eachCustomTask.eachTask.Answered_Date__c = dummyOpp.CloseDate;
                            }else{
                                dateInputHasValue = false;
                                showErrorDate = true;
                            }
                        }

                        eachCustomTask.eachTask.Status = selectedResponse;
                        eachCustomTask.eachTask.Response_Level_1__c = selectedResponse;
                    }

                    taskToUpdate.add(eachCustomTask.eachTask);
                }
            }

            if(dateInputHasValue){
                
                if(!taskToUpdate.isEmpty()){
                    update taskToUpdate;
                }

                displaySubTypePopUp = false;
                displaySubTypePopUpCBS = false;
                dummyOpp.CloseDate = null;
                initCustomTasks(selectFilter);
                offsetSize = 0;
                getCustomTasksWithOffset();
            }
        }else{
            
            CustomTasks selectedCustomTask = new CustomTasks();
            if(mapCustomTasksById.containsKey(taskRecordSelected)){
                selectedCustomTask = mapCustomTasksById.get(taskRecordSelected);
                if(!checkUserCBSForHideFields){
                    
                    selectedCustomTask.eachTask.Memo__c = dummyOpp.Remark__c;
                    selectedCustomTask.eachTask.Status = selectedResponseLV1;
                    selectedCustomTask.eachTask.Response_Level_1__c = selectedResponseLV1;
                    selectedCustomTask.eachTask.Response_Level_2__c = selectedResponseLV2;

                }else{
                    if(showDate){
                        if(dummyOpp.CloseDate != null){
                            selectedCustomTask.eachTask.Answered_Date__c = dummyOpp.CloseDate;
                        }else{
                            dateInputHasValue = false;
                            showErrorDate = true;
                        }
                    }

                    selectedCustomTask.eachTask.Status = selectedResponse;
                }
                if(dateInputHasValue){
                    taskToUpdate.add(selectedCustomTask.eachTask);

                    if(!taskToUpdate.isEmpty()){
                        update taskToUpdate;
                    }

                    displaySubTypePopUp = false;
                    displaySubTypePopUpCBS = false;
                    showErrorDate = false;
                    showDate = false;
                    singleSelect = false;
                    dummyOpp.CloseDate = null;
                    dummyOpp.Remark__c = null;
                    initCustomTasks(selectFilter);
                    offsetSize = 0;
                    getCustomTasksWithOffset();
                }
            }
        }
        
        return null;
    }

    public List<SelectOption> setResponseOptions(){
        responseOptions = new List<SelectOption>();
        Set<String> responseLvl1 = new Set<String>();
        for(Lead_To_Do_Response__c eachResponse : leadToDoResponseList){
            if(!responseLvl1.contains(eachResponse.Response_Level_1__c)){
                responseLvl1.add(eachResponse.Response_Level_1__c);
                mapCheckDateByResponseLvl1.put(eachResponse.Response_Level_1__c, eachResponse.Required_Date__c);
            }
        }

        jsonMapCheckDateByResponseLvl1 = JSON.serializePretty(mapCheckDateByResponseLvl1);

        for(String eachResponseLvl1 : responseLvl1){
            responseOptions.add(new SelectOption(eachResponseLvl1,eachResponseLvl1));
        }

        if(!singleSelect && responseOptions.size() > 0){
            selectedResponse = responseOptions.get(0).getValue();
            showDate = mapCheckDateByResponseLvl1.get(selectedResponse);
            for(CustomTasks eachCustomTask : mapCustomTasksById.values()){
                if(eachCustomTask.isChecked){
                    if(String.isBlank(eachCustomTask.eachTask.Response_Level_1__c)){
                        continue;
                    }else{
                        selectedResponse = eachCustomTask.eachTask.Response_Level_1__c;
                        showDate = mapCheckDateByResponseLvl1.get(selectedResponse);

                        if(showDate){
                            dummyOpp.CloseDate = eachCustomTask.eachTask.Answered_Date__c;
                        }
                        break;
                    }
                }
            }
        }else{
            if(mapCustomTasksById.containsKey(taskRecordSelected)){
                if(String.isBlank(mapCustomTasksById.get(taskRecordSelected).eachTask.Response_Level_1__c)){
                    selectedResponse = responseOptions.get(0).getValue();
                    showDate = mapCheckDateByResponseLvl1.get(selectedResponse);
                }else{
                    selectedResponse = mapCustomTasksById.get(taskRecordSelected).eachTask.Response_Level_1__c;
                    showDate = mapCheckDateByResponseLvl1.get(selectedResponse);
                }

                if(showDate){
                    dummyOpp.CloseDate = mapCustomTasksById.get(taskRecordSelected).eachTask.Answered_Date__c;
                }
            }
        }

        
        


        return responseOptions;
    }

    public PageReference checkShowDate(){
        if(mapCheckDateByResponseLvl1.containsKey(selectedResponse)){
            showDate = mapCheckDateByResponseLvl1.get(selectedResponse);
            dummyOpp.CloseDate = null;
        }
        return null;
    }

    public List<SelectOption> setResponseOptionsLV1CBS(){
        responseOptionsLV1CBS = new List<SelectOption>();
        Set<String> responseLv1Set = new Set<String>();
        showMemo = true;
        dummyOpp.Remark__c = null;
        for(Lead_To_Do_Response__c leadToDoRes :leadToDoResponseList){
            if(!responseLv1Set.contains(leadToDoRes.Response_Level_1__c)){
                responseLv1Set.add(leadToDoRes.Response_Level_1__c);
                responseOptionsLV1CBS.add(new SelectOption(leadToDoRes.Response_Level_1__c,leadToDoRes.Response_Level_1__c));
            }
            mapCheckResponseLvl1CBS.put(leadToDoRes.Response_Level_1__c, leadToDoRes.Required_Level_2__c);
            
            if(leadToDoRes.Response_Level_2__c != null){
                mapCheckMemoCBS.put(leadToDoRes.Response_Level_1__c + '-' + leadToDoRes.Response_Level_2__c, leadToDoRes.Required_Memo__c);
            } else {
                mapCheckMemoCBS.put(leadToDoRes.Response_Level_1__c, leadToDoRes.Required_Memo__c);
            }
        }
        
        if(!responseOptionsLV1CBS.isEmpty()) {
            selectedResponseLV1 = (new List<String> (responseLv1Set)).get(0);
            checkShowResponseLV2();
        }
        mapParentChildrenJSON = JSON.serialize(mapCheckMemoCBS);
        
        return responseOptionsLV1CBS;
    }
    public PageReference checkShowResponseLV2(){
        if(mapCheckResponseLvl1CBS.get(selectedResponseLV1)){
            
            showResponseLV2 = true;

            responseOptionsLV2CBS = new List<SelectOption>();
            Set<String> responseLv2Set = new Set<String>();

            if(mapCheckResponseLvl1CBS.containsKey(selectedResponseLV1)){
                for(Lead_To_Do_Response__c leadToDoRes :leadToDoResponseList){
                    if(leadToDoRes.Response_Level_1__c == selectedResponseLV1 && leadToDoRes.Response_Level_2__c != null){
                            responseLv2Set.add(leadToDoRes.Response_Level_2__c);
                            mapCheckResponseLvl2CBS.put(leadToDoRes.Response_Level_2__c, leadToDoRes.Required_Memo__c);
                    }
                }

                if(!responseLv2Set.isEmpty()){
                    for(String eachResponseLvl2 : responseLv2Set){
                        responseOptionsLV2CBS.add(new SelectOption(eachResponseLvl2,eachResponseLvl2));
                    }

                    selectedResponseLV2 = (new List<String> (responseLv2Set)).get(0);
                }
            }
        }
        else{
            showResponseLV2 = false;
            
        }

        return null;
    }

    public PageReference closePopUp(){
        
            displayErrorAtLeastOneRecordChecked = false;
            displayErrorNotSameType = false;
            displaySubTypePopUp = false;
            displaySubTypePopUpCBS = false;

            showErrorDate = false;
            showResponseLV2 = false;
            showMemo = false;
            showDate = false;
            singleSelect = false;

            dummyOpp.CloseDate = null;
            dummyOpp.Remark__c = null;
            isCheckedAll = false;
            setCheckAll();
        
        

        return null;
    }

    public Boolean getDisablePrevious(){
        if(offsetSize>0){
            return false;
        }
        else return true;
    }
 
    public Boolean getDisableNext(){
        if (offsetSize + queryLimit < listCustomTasks.size()){
            return false;
        }
        else return true;
    }
 
    public PageReference Next(){
        isCheckedAll = false;
        offsetSize += queryLimit;
        startSize = offsetSize+1;
        sizeOfRecordsShowing = sizeOfRecordsShowing + offsetSize;
        setMapIsCheckedFalse();
        return null;
    }
 
    public PageReference Previous(){
        isCheckedAll = false;
        sizeOfRecordsShowing = sizeOfRecordsShowing - offsetSize;
        offsetSize -= queryLimit;
        startSize = offsetSize+1;
        setMapIsCheckedFalse();
        return null;
    }

    public void setMapIsCheckedFalse(){
        for(CustomTasks eachTask : mapCustomTasksById.values()){
            eachTask.isChecked = false;
        }
    }

    public void setCheckAll(){
        if(isCheckedAll){
            for(CustomTasks eachTask : customTasksWithOffset){
                mapCustomTasksById.get(eachTask.eachTask.Id).isChecked = true;
                
            }
        }else{
            for(CustomTasks eachTask : customTasksWithOffset){
                mapCustomTasksById.get(eachTask.eachTask.Id).isChecked = false;
            }
        }
        getCustomTasksWithOffset();
    }
}