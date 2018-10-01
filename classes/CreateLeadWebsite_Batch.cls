global class CreateLeadWebsite_Batch implements Database.Batchable<sObject> {
	
	String query;
    Campaign campaignMLP;
    String leadSalutation = 'คุณ';
    String leadStatus = 'Opened';
    String groupNameTelesales = 'Lead Online from Website';
    String prefixDate;
    Id recordTypeLeadMLP;
    Map<String,User> tmOwnerByEmpIdMap = new Map<String,User>();
    Map<String,Integer> roundRobinMap = new Map<String,Integer>();
    Map<String,Telesales_Product_Name_to_Field_Mapping__c> mapProductNameFieldByName = new Map<String,Telesales_Product_Name_to_Field_Mapping__c>();


    //Lead_MLP_Code
    
    global CreateLeadWebsite_Batch() {
        query = 'SELECT Id,Mobile_Number__c FROM Lead_MLP__c WHERE IP_ID__c =NULL AND Mobile_Number__c !=NULL AND Source_System_ID__c =\'452\' AND REL_ST__c =\'New\' AND CreatedDate = TODAY';
        initData();
    }

    global CreateLeadWebsite_Batch(String conditionDate) {
        query = 'SELECT Id,Mobile_Number__c FROM Lead_MLP__c WHERE IP_ID__c =NULL AND Mobile_Number__c !=NULL AND Source_System_ID__c =\'452\' AND REL_ST__c =\'New\' AND DAY_ONLY(CreatedDate)='+conditionDate;
        prefixDate = conditionDate;
        initData();
    }

    private void initData(){
        List<MLP_Owner__c>  ownerList = [SELECT Id, Name FROM MLP_Owner__c];
        campaignMLP = [SELECT Id,Name,Lead_Campaign_Event_Code__c FROM Campaign WHERE Lead_Campaign_Event_Code__c=:Label.Lead_Online_from_Website_Code LIMIT 1];
        Set<String> empIdSet = new Set<String>();
        if(!ownerList.isEmpty()){
            for(MLP_Owner__c eachMLPOwner : ownerList){
                empIdSet.add(eachMLPOwner.Name);
                roundRobinMap.put(eachMLPOwner.Name,0);
            }
            List<User> ownerUserList = [SELECT ID,Employee_ID__c FROM User WHERE Employee_ID__c=:empIdSet ];
            for(User eachUser : ownerUserList){
                tmOwnerByEmpIdMap.put(eachUser.Employee_ID__c,eachUser);
            }
        }
        Date today = Date.today();
        if(prefixDate == NULL){
            if(today.year() > 2500){
                prefixDate = today.year()-543 +'-'+ today.month()+'-'+today.day();
            }else{
                prefixDate = today.year()+'-'+ today.month()+'-'+today.day();        
            }
        }
        recordTypeLeadMLP = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Lead',GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);

        for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
            mapProductNameFieldByName.put(eachMapping.Name, eachMapping);
        }
    }
	
	private String getQueueRoundRobin(){
        String tmpEMPId;
        for(String  eachEmpId : roundRobinMap.keySet()){
            if(tmpEMPId == NULL){
                tmpEMPId = eachEmpId;
            }else{
                if(roundRobinMap.get(eachEmpId) < roundRobinMap.get(tmpEMPId)){
                    tmpEMPId = eachEmpId;
                }
            }
        }
        Integer tmpvalue = roundRobinMap.get(tmpEMPId)+1;
        roundRobinMap.put(tmpEMPId, tmpvalue);
        return tmpEMPId;
    }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Lead_MLP__c> leadList) {
   		System.debug('execute');
   		System.debug(leadList);
        String errorMessage = '';
        Set<String> phoneNoRelateSet = new Set<String>();
        for(Lead_MLP__c eachLead : leadList){
            phoneNoRelateSet.add(eachLead.Mobile_Number__c);
        }
        Date tempDate = Date.valueOf(prefixDate);
        Map<String,List<Lead_MLP__c>> leadMLPRelateByMobileNoMap = new Map<String,List<Lead_MLP__c>>();
        List<Lead_MLP__c> leadMLPRelateList = [SELECT Id, IDENT_NO__c, Mobile_Number__c, Is_Sync_Completed__c, LEAD_ID__c, PERSZ_MSG__c, PROSP_NM__c, REFR_ID__c, REL_ST__c FROM Lead_MLP__c WHERE Mobile_Number__c=:phoneNoRelateSet AND REL_ST__c ='New' AND  DAY_ONLY(CreatedDate)=:tempDate ORDER BY Mobile_Number__c]; 
        
        Set<String> recordTypeTelesales = new Set<String>{GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME,GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME};
        List<Lead> exitingLeadRelateList = [SELECT Id,MLP_ExternalKey__c,Latest_Lead__c,Mobile_No__c,OwnerId,Assigned_Owner__c FROM Lead WHERE RecordType.DeveloperName in :recordTypeTelesales AND Latest_Lead__c =true AND Customer__c=NULL AND Mobile_No__c=:phoneNoRelateSet  AND Owner.IsActive =true];
        List<Lead> removeLatestLeadList = new List<Lead>();
        Map<String,Lead> leadRelateByMobileNoMap =  new Map<String,Lead>();
        Map<String,Lead> createLeadByMobileNoMap = new Map<String,Lead>();

      
        for(Lead eachLead : exitingLeadRelateList){
            leadRelateByMobileNoMap.put(eachLead.Mobile_No__c, eachLead);
        }

        for(Lead_MLP__c eachMLP : leadMLPRelateList){
            if(leadMLPRelateByMobileNoMap.containsKey(eachMLP.Mobile_Number__c)){
                leadMLPRelateByMobileNoMap.get(eachMLP.Mobile_Number__c).add(eachMLP);
            }else{
                List<Lead_MLP__c> tempMLPList = new List<Lead_MLP__c>();
                tempMLPList.add(eachMLP);
                leadMLPRelateByMobileNoMap.put(eachMLP.Mobile_Number__c,tempMLPList);
            }
        }

        //CreateLead

        for(String eachMobileNo : leadMLPRelateByMobileNoMap.keySet()){
        	System.debug('eachMobileNo:'+eachMobileNo);
            List<Lead_MLP__c> tempMLPList = leadMLPRelateByMobileNoMap.get(eachMobileNo);
            if(!tempMLPList.isEmpty() && tempMLPList.get(0).PROSP_NM__c !=null ){
                List<String> prosFieldList = tempMLPList.get(0).PROSP_NM__c.split('\\|');
                String tempFirstName;
                String tempLastName;

                if(prosFieldList.size() >= 3){
                    tempFirstName = prosFieldList[0];
                    tempLastName = prosFieldList[1];
                } 
                String tempPrefix = eachMobileNo+'_'+prefixDate;
                Map<String,String> tempJsonMap = new Map<String,String>();
                Set<String> setProduct = new Set<String>();
                if(!tempMLPList.isEmpty()){
                    for(Lead_MLP__c eachMLP: tempMLPList){
                        if(mapProductNameFieldByName.containsKey(eachMLP.PERSZ_MSG__c)){
                            setProduct.add(mapProductNameFieldByName.get(eachMLP.PERSZ_MSG__c).Display_Product_Name_As__c);
                        }else{
                            setProduct.add(eachMLP.PERSZ_MSG__c);
                        }
                        tempJsonMap.put(eachMLP.PERSZ_MSG__c,eachMLP.REFR_ID__c);
                    }
                }
                
                List<String> productList = new List<String>(setProduct);    
                Lead newLead = new Lead();
                newLead.RecordTypeId = recordTypeLeadMLP;
                newLead.Salutation = leadSalutation;
                newLead.Status = leadStatus;
                newLead.FirstName = tempFirstName;
                newLead.LastName = tempLastName;
                newLead.Mobile_No__c = eachMobileNo;
                newLead.Group_Name_Telesales__c = groupNameTelesales; 
                newLead.Lead_MLP_Reference_Mapping__c = JSON.serialize(tempJsonMap);
                newLead.Product_Interest_as_registered__c = String.join(productList,',');
                newLead.MLP_ExternalKey__c = tempPrefix;
                newLead.Campaign_Code__c = Label.Lead_MLP_Code;
                newLead.Lead_Campaign_Event_Name__c = campaignMLP.Id;
                newLead.Latest_Lead__c = true;
                newLead.Identification_No__c = tempMLPList.get(0).IDENT_NO__c;
                if(leadRelateByMobileNoMap.containsKey(eachMobileNo)){
                    Lead oldLatestLead = leadRelateByMobileNoMap.get(eachMobileNo);
                    if(oldLatestLead.Assigned_Owner__c !=null){
                        newLead.Assigned_Owner__c = oldLatestLead.Assigned_Owner__c;
                        newLead.OwnerId = oldLatestLead.Assigned_Owner__c;
                    }else{
                        newLead.Assigned_Owner__c = oldLatestLead.OwnerId;
                        newLead.OwnerId = oldLatestLead.OwnerId;
                    }
                    if(oldLatestLead.MLP_ExternalKey__c != tempPrefix){
                        oldLatestLead.Latest_Lead__c = false;
                        removeLatestLeadList.add(oldLatestLead);
                    }
                }else{
                    String tempOwnerEmpId = getQueueRoundRobin();
                    newLead.OwnerId =  tmOwnerByEmpIdMap.get(tempOwnerEmpId).Id;
                    newLead.Assigned_Owner__c =  tmOwnerByEmpIdMap.get(tempOwnerEmpId).Id;
                }
                createLeadByMobileNoMap.put(eachMobileNo,newLead);
            }
        }

        if(!createLeadByMobileNoMap.isEmpty()){
            Schema.SobjectField keyField = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get('MLP_ExternalKey__c');
            Database.UpsertResult[] srList = Database.upsert(createLeadByMobileNoMap.values(),keyField, false);
            Integer index  = 0;
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                       //String errorId = (createLeadByMobileNoMap.values()[index]!=null && createLeadByMobileNoMap.values()[index].ID!=null)?createLeadByMobileNoMap.values()[index].ID:''; 
                        errorMessage = errorMessage + 'Lead ID : - Error Msg :'+ String.valueOf(err.getMessage()) +  '\n' ;
                    }
                }
                index++;
            }

            System.debug('errorMessage'+errorMessage);
        }

        if(!removeLatestLeadList.isEmpty()){
            List<Database.SaveResult> leadUpdateResult = DB_Service.updateSObject(removeLatestLeadList,false);
            if(leadUpdateResult !=null && leadUpdateResult.isEmpty()== false){
                for (Database.SaveResult sr : leadUpdateResult) {
                    if (!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = errorMessage + 'Lead Error:'+ String.valueOf(err.getMessage()) +  '\n' ;
                        }
                    }
                }
            }
        }

        //CreateCampaignMember
        List<CampaignMember>  createCampaignMemberList = new List<CampaignMember>();
        for(String eachMobileNo : createLeadByMobileNoMap.keySet()){
            Lead eachLead = createLeadByMobileNoMap.get(eachMobileNo);
            if(eachLead.Id != NULL){
                CampaignMember campaignMemberRecord = new CampaignMember();
                campaignMemberRecord.CampaignId = campaignMLP.Id;
                campaignMemberRecord.LeadId = eachLead.Id;
                campaignMemberRecord.MLP_ExternalKey__c = eachMobileNo+'_'+prefixDate;
                createCampaignMemberList.add(campaignMemberRecord);
            }
        }
        
        if(!createCampaignMemberList.isEmpty()){
            Schema.SobjectField keyField = Schema.getGlobalDescribe().get('CampaignMember').getDescribe().fields.getMap().get('MLP_ExternalKey__c');
            Database.UpsertResult[] srList = Database.upsert(createCampaignMemberList,keyField, false);
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage = errorMessage + 'CampaignMember Error Msg :'+ String.valueOf(err.getMessage()) +  '\n' ;
                    }
                }
            }
        }
    }
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}