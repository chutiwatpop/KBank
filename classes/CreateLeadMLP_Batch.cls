global class CreateLeadMLP_Batch implements Database.Batchable<sObject>,Database.Stateful {
    
    String query;
    Campaign campaignMLP;
    String leadSalutation = 'คุณ';
    String leadStatus = 'Opened';
    String groupNameTelesales = 'MLP';
    String prefixDate;
    Id recordTypeLeadMLP;
    Map<String,User> tmOwnerByEmpIdMap = new Map<String,User>();
    Map<String,Integer> roundRobinMap = new Map<String,Integer>();
    Map<String,Telesales_Product_Name_to_Field_Mapping__c> mapProductNameFieldByName = new Map<String,Telesales_Product_Name_to_Field_Mapping__c>();
    public Boolean isManual = false;

    //Lead_MLP_Code
    
    global CreateLeadMLP_Batch() {
        query = 'SELECT Id,IP_ID__c FROM Lead_MLP__c WHERE IP_ID__c !=NULL AND REL_ST__c =\'New\' AND CreatedDate = TODAY ORDER BY IP_ID__c';
        initData();
    }

    global CreateLeadMLP_Batch(String conditionDate) {
        query = 'SELECT Id,IP_ID__c FROM Lead_MLP__c WHERE IP_ID__c !=NULL AND REL_ST__c =\'New\' AND DAY_ONLY(CreatedDate)='+conditionDate+'  ORDER BY IP_ID__c';
        prefixDate = conditionDate;
        isManual = true;
        initData();
    }

    private void initData(){
        List<MLP_Owner__c>  ownerList = [SELECT Id, Name FROM MLP_Owner__c];
        campaignMLP = [SELECT Id,Name,Lead_Campaign_Event_Code__c FROM Campaign WHERE Lead_Campaign_Event_Code__c=:Label.Lead_MLP_Code LIMIT 1];
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
        String errorMessage = '';
        Set<String> cisRelateSet = new Set<String>();
        for(Lead_MLP__c eachLead : leadList){
            cisRelateSet.add(eachLead.IP_ID__c);
        }
        System.debug('Date.valueOf(prefixDate) :'+Date.valueOf(prefixDate));
        Date tempDate = Date.valueOf(prefixDate);
        //Date tempDate = Date.valueOf('2018-07-06');
        Map<String,List<Lead_MLP__c>> leadMLPRelateByCISMap = new Map<String,List<Lead_MLP__c>>();
        //List<Lead_MLP__c> leadMLPRelateList = [SELECT Id, IDENT_NO__c, IP_ID__c, Is_Sync_Completed__c, LEAD_ID__c, PERSZ_MSG__c, PROSP_NM__c, REFR_ID__c, REL_ST__c FROM Lead_MLP__c WHERE IP_ID__c=:cisRelateSet AND REL_ST__c ='New' AND (DAY_IN_MONTH(CreatedDate)=:tempDate.day() AND CALENDAR_MONTH(CreatedDate)=:tempDate.month() AND CALENDAR_YEAR(CreatedDate)=:tempDate.year()) ORDER BY IP_ID__c]; 
        List<Lead_MLP__c> leadMLPRelateList = [SELECT Id, IDENT_NO__c, IP_ID__c, Is_Sync_Completed__c, LEAD_ID__c, PERSZ_MSG__c, PROSP_NM__c, REFR_ID__c, REL_ST__c FROM Lead_MLP__c WHERE IP_ID__c=:cisRelateSet AND REL_ST__c ='New' AND  DAY_ONLY(CreatedDate)=:tempDate ORDER BY IP_ID__c]; 
        
        List<Account> accountRelateList = [SELECT Id,CIS__c,OwnerId FROM Account WHERE CIS__c =:cisRelateSet];
        Set<String> recordTypeTelesales = new Set<String>{GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME,GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME};
        List<Lead> exitingLeadRelateList = [SELECT Id,MLP_ExternalKey__c,Latest_Lead__c,Customer__r.CIS__c,OwnerId,Assigned_Owner__c FROM Lead WHERE RecordType.DeveloperName in :recordTypeTelesales AND Latest_Lead__c =true  AND Owner.IsActive =true];
        List<Lead> removeLatestLeadList = new List<Lead>();
        Map<String,Account> accountRelateByCisMap =  new Map<String,Account>();
        Map<String,Lead> leadRelateByCisMap =  new Map<String,Lead>();
        Map<String,Lead> createLeadByCisMap = new Map<String,Lead>();

        for(Account eachAccount : accountRelateList){
            accountRelateByCisMap.put(eachAccount.CIS__c, eachAccount);
        }

        for(Lead eachLead : exitingLeadRelateList){
            leadRelateByCisMap.put(eachLead.Customer__r.CIS__c, eachLead);
        }

        for(Lead_MLP__c eachMLP : leadMLPRelateList){
            if(leadMLPRelateByCISMap.containsKey(eachMLP.IP_ID__c)){
                leadMLPRelateByCISMap.get(eachMLP.IP_ID__c).add(eachMLP);
            }else{
                List<Lead_MLP__c> tempMLPList = new List<Lead_MLP__c>();
                tempMLPList.add(eachMLP);
                leadMLPRelateByCISMap.put(eachMLP.IP_ID__c,tempMLPList);
            }
        }

        //CreateLead

        for(String eachCIS : leadMLPRelateByCISMap.keySet()){
            List<Lead_MLP__c> tempMLPList = leadMLPRelateByCISMap.get(eachCIS);
            if(!tempMLPList.isEmpty() && tempMLPList.get(0).PROSP_NM__c !=null  && tempMLPList.get(0).IDENT_NO__c !=null){
                List<String> prosFieldList = tempMLPList.get(0).PROSP_NM__c.split('\\|');
                String tempFirstName;
                String tempLastName;
                String mobileNumber;

                if(prosFieldList.size() >= 3){
                    tempFirstName = prosFieldList[0];
                    tempLastName = prosFieldList[1];
                    mobileNumber = prosFieldList[2];
                } 
                String tempPrefix = eachCIS+'_'+prefixDate;
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
                newLead.Mobile_No__c = mobileNumber;
                newLead.Group_Name_Telesales__c = groupNameTelesales; 
                newLead.Lead_MLP_Reference_Mapping__c = JSON.serialize(tempJsonMap);
                newLead.Product_Interest_as_registered__c = String.join(productList,',');
                newLead.MLP_ExternalKey__c = tempPrefix;
                newLead.CIS_ID__c = eachCIS;
                newLead.Campaign_Code__c = Label.Lead_MLP_Code;
                newLead.Identification_No__c = tempMLPList.get(0).IDENT_NO__c;
                newLead.Lead_Campaign_Event_Name__c = campaignMLP.Id;
                newLead.Latest_Lead__c = true;
                if(leadRelateByCisMap.containsKey(eachCIS)){
                    Lead oldLatestLead = leadRelateByCisMap.get(eachCIS);
                    if(oldLatestLead.Assigned_Owner__c !=null){
                        newLead.Assigned_Owner__c = oldLatestLead.Assigned_Owner__c;
                        newLead.OwnerId = oldLatestLead.Assigned_Owner__c;
                    }else{
                        newLead.Assigned_Owner__c = oldLatestLead.OwnerId;
                        newLead.OwnerId = oldLatestLead.OwnerId;
                    }
                    newLead.Customer__c = oldLatestLead.Customer__c;
                    if(oldLatestLead.MLP_ExternalKey__c != tempPrefix){
                        oldLatestLead.Latest_Lead__c = false;
                        removeLatestLeadList.add(oldLatestLead);
                    }
                }else{
                    if(accountRelateByCisMap.containsKey(eachCIS)){
                        Account accountRecord =  accountRelateByCisMap.get(eachCIS);
                        newLead.Customer__c =  accountRecord.Id;
                    }
                    String tempOwnerEmpId = getQueueRoundRobin();
                    newLead.OwnerId =  tmOwnerByEmpIdMap.get(tempOwnerEmpId).Id;
                    newLead.Assigned_Owner__c =  tmOwnerByEmpIdMap.get(tempOwnerEmpId).Id;
                }
                createLeadByCisMap.put(eachCIS,newLead);
            }
        }

        for(Lead eachLead : createLeadByCisMap.values()){
            System.debug(eachLead);
        }

        if(!createLeadByCisMap.isEmpty()){
            Schema.SobjectField keyField = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get('MLP_ExternalKey__c');
            Database.UpsertResult[] srList = Database.upsert(createLeadByCisMap.values(),keyField, false);
            Integer index  = 0;
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                       //String errorId = (createLeadByCisMap.values()[index]!=null && createLeadByCisMap.values()[index].ID!=null)?createLeadByCisMap.values()[index].ID:''; 
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
        for(String eachCIS : createLeadByCisMap.keySet()){
            Lead eachLead = createLeadByCisMap.get(eachCIS);
            if(eachLead.Id != NULL){
                CampaignMember campaignMemberRecord = new CampaignMember();
                campaignMemberRecord.CampaignId = campaignMLP.Id;
                campaignMemberRecord.LeadId = eachLead.Id;
                campaignMemberRecord.MLP_ExternalKey__c = eachCIS+'_'+prefixDate;
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
        if(!isManual){
            Database.executeBatch(new CreateLeadWebsite_Batch());
        }
    }
    
}