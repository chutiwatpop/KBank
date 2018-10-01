global class CreateTargetListFromDPD_Batch implements Database.Batchable<sObject>,Database.Stateful {
  
  String query;
  //private Map<String,Target_List__c> targetListMapByLPMId;
  private Campaign leadDPD;
  public Generate_Lead_DPD__c genLeadDPDCustomSetting;
  private Set<String> CLSR_SET;
  private Set<String> CLSR_SET_WITH_OD;

  //private List<Target_List__c> targetListToUpsert;

  //global CreateTargetListFromDPD_Batch(Set<Id> accountIdSet) {
  //  targetListToUpsert = new List<Target_List__c>();
  //  List<Id> accountListToQuery = new List<Id>(accountIdSet);
  //      this.query = 'SELECT Id,LPM__c,LPM__r.LPM__c,LPM__r.Display_DPD__c,LPM__r.CLS_Reason__c,LPM__r.TDR_Date__c,LPM__r.Note__c,LPM__r.Generate_Lead__c,CIS__c,CIS__r.Owner.Segment__c,CIS__r.IsCredit__c,CIS__r.IsNonCredit__c,Primary__c From LPM_Customer__c';
  //  //String condition = ' WHERE LPM__c IN (\'' + String.join(LPMListToQuery, '\',\'') +'\') ORDER BY CIS__c ASC';
  //  String condition = ' WHERE CIS__c IN (\'' + String.join(accountListToQuery, '\',\'') +'\') ORDER BY CIS__c ASC';
  //      this.query = this.query + condition;
  //      this.genLeadDPDCustomSetting = Generate_Lead_DPD__c.getOrgDefaults();
  //      this.CLSR_SET =  new Set<String>(genLeadDPDCustomSetting.CLS_Reason__c.split(';'));
  //      this.CLSR_SET_WITH_OD =  new Set<String>(genLeadDPDCustomSetting.CLS_Reason_OD__c.split(';'));
  //      try{
  //        this.leadDPD = [SELECT Id,Lead_Campaign_Event_Code__c,Sub_Type__c From Campaign WHERE Lead_Campaign_Event_Code__c = :genLeadDPDCustomSetting.Lead_Code__c AND Sub_Type__c = :GlobalConstants.LEAD_SUB_TYPE_DPD LIMIT 1];
  //        this.targetListMapByLPMId = CampaignLead_Service.getTargetListMapByExternalId(accountIdSet,leadDPD);

  //      }catch(exception e){

  //      }
  //      //this.targetListMapByLPMId = CampaignLead_Service.getTargetListMapByExternalId(LPMIdSet,leadDPD);
  //  }

    global CreateTargetListFromDPD_Batch() {
        this.query = 'SELECT Id,LPM__c,LPM__r.LPM__c,LPM__r.Display_DPD__c,LPM__r.CLS_Reason__c,LPM__r.TDR_Date__c,LPM__r.Note__c,LPM__r.Generate_Lead__c,CIS__c,CIS__r.Owner.Segment__c,CIS__r.IsCredit__c,CIS__r.IsNonCredit__c,Primary__c From LPM_Customer__c';
        this.genLeadDPDCustomSetting = Generate_Lead_DPD__c.getOrgDefaults();
        this.CLSR_SET =  new Set<String>(genLeadDPDCustomSetting.CLS_Reason__c.split(';'));
        this.CLSR_SET_WITH_OD =  new Set<String>(genLeadDPDCustomSetting.CLS_Reason_OD__c.split(';'));
        try{
          this.leadDPD = [SELECT Id,Lead_Campaign_Event_Code__c,Sub_Type__c,Type__c From Campaign WHERE Lead_Campaign_Event_Code__c = :genLeadDPDCustomSetting.Lead_Code__c AND Sub_Type__c = :GlobalConstants.LEAD_SUB_TYPE_DPD LIMIT 1];
          //this.targetListMapByLPMId = CampaignLead_Service.getTargetListMapByExternalId(accountIdSet,leadDPD);

        }catch(exception e){

        }

    }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

    global void execute(Database.BatchableContext BC, List<LPM_Customer__c> LPMCustomerList) {

      Set<Id> accountIdSet = new Set<Id>();
      for(LPM_Customer__c eachLPMCustomer : LPMCustomerList){
        accountIdSet.add(eachLPMCustomer.CIS__c);
      }
      Map<String,Target_List__c> targetListMapByLPMId = CampaignLead_Service.getTargetListMapByExternalId(accountIdSet,leadDPD);

      if(this.leadDPD != null){
          List<Target_List__c> targetListToUpsert = new List<Target_List__c>();
          //Integer disPlayDPDthreshold;
          Boolean isCreateTargetList;
          Boolean isUpsertThisTargetList;
          String eachTargetListExternalId;
          for(LPM_Customer__c eachLPMCustomer : LPMCustomerList){
            isCreateTargetList = false;
            isUpsertThisTargetList = false;
                  eachTargetListExternalId = this.leadDPD.Lead_Campaign_Event_Code__c +':'+ eachLPMCustomer.CIS__c+':'+eachLPMCustomer.LPM__r.LPM__c;
            //Integer disPlayDPD =  Integer.valueOf(eachLPMCustomer.LPM__r.Display_DPD__c);
            Target_List__c eachTargetList;
            if(targetListMapByLPMId.containsKey(eachTargetListExternalId) ){
              eachTargetList = targetListMapByLPMId.get(eachTargetListExternalId);
            }

                  isCreateTargetList = isGenerateLeadDPD(eachLPMCustomer);

                  if(eachTargetList != null){ // already have targetlist and create TargetList
                    if(isCreateTargetList){
                      if(eachTargetList.Active_Target_List__c == null){
                        eachTargetList.Active_Target_List__c = eachLPMCustomer.CIS__c;
                        eachTargetList.Active_Date__c = System.today();
                        eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
                        eachTargetList.Response_Level_1__c = null;
                        eachTargetList.Response_Level_2__c = null;
                        eachTargetList.Memo__c = null;
                        eachTargetList.Application_ID__c = null;
                        eachTargetList.Arr_of_end_month__c = null;
                        eachTargetList.DES_NPL__c = null;
                        eachTargetList.INC_NPL__c = null;
                        eachTargetList.Desc_Way__c = null;
                        eachTargetList.EST_DES_NPL__c = null;
                        eachTargetList.INC_PRL__c = null;
                        eachTargetList.DES_PRL__c = null;
                        eachTargetList.Desc_Way_RPL__c = null;
                        eachTargetList.EST_DES_PRL__c = null;
                        eachTargetList.No_of_Active_Times__c = eachTargetList.No_of_Active_Times__c + 1;
                        eachTargetList.IsRespLeadToDo__c = false;

                        isUpsertThisTargetList = true;
                      }
                    }else{ // already have targetList , and not create => inactive TargetList
                      if(eachTargetList.Active_Target_List__c != null){
                        eachTargetList.Active_Target_List__c = null;
                        isUpsertThisTargetList = true;
                      }
                    }
                  }else{ // does't have targetList and have to create one
                    if(isCreateTargetList){
                      eachTargetList = new Target_List__c(Active_Target_List__c = eachLPMCustomer.CIS__c, CIS_ID_Prospect_Name__c = eachLPMCustomer.CIS__c,
                                        Lead_Campaign__c = this.leadDPD.id, LPM__c = eachLPMCustomer.LPM__c, Active_Date__c = System.today(),
                                                              Personalised_Message__c = eachLPMCustomer.LPM__r.Note__c);
                          Map<Id,Account> accountMapById = new Map<Id,Account>{eachLPMCustomer.CIS__c => new Account(Id = eachLPMCustomer.CIS__c)};
                          Map<Id,Campaign> campaignMapById = new Map<Id,Campaign>{this.leadDPD.id => this.leadDPD};
                          TargetList_Service.generateExternalId(eachTargetList,null,campaignMapById,accountMapById, true, eachLPMCustomer);
                          isUpsertThisTargetList = true;
                    }
                  }

                  if(eachTargetList != null && isUpsertThisTargetList){
                    targetListToUpsert.add(eachTargetList);
                  }
          }
          if(targetListToUpsert.size() > 0){
              TargetListTriggerHandler.isBypassGenerateExternalId = true;
              TargetListTriggerHandler.isBypassLeadBackward = true;
          upsert targetListToUpsert External_ID__c;
          }
      }
  }
  
  global void finish(Database.BatchableContext BC) {

  }

  private Boolean isTRDDateWithInRageToCreateLead(Date tdr_date){
    Boolean isSameYearandMonth = false;
    if(tdr_date != null){
            if( (tdr_date.month() == System.today().month() || (System.today().day() <= Integer.valueOf(genLeadDPDCustomSetting.Cut_Off_Date__c) && tdr_date.month() == System.today().addMonths(-1).month())   ) 
            && tdr_date.monthsBetween(System.today()) < 12 ) {
                isSameYearandMonth = true;
            }
    }
    return isSameYearandMonth;
  }

    private Boolean isGenerateLeadDPD(LPM_Customer__c eachLPMCustomer){
        Integer disPlayDPD =  Integer.valueOf(eachLPMCustomer.LPM__r.Display_DPD__c);
        Boolean isCreateTargetList = false;
        Integer disPlayDPDthreshold;

        if(!String.isBlank(eachLPMCustomer.LPM__r.Generate_Lead__c)){
          if(String.valueOf(eachLPMCustomer.LPM__r.Generate_Lead__c).equalsIgnoreCase('Yes') && eachLPMCustomer.Primary__c){
              return true;
          }else if(String.valueOf(eachLPMCustomer.LPM__r.Generate_Lead__c).equalsIgnoreCase('No')){
              return false;
          }
        }
        
        if( !(((genLeadDPDCustomSetting.Credit__c && eachLPMCustomer.CIS__r.IsCredit__c != null  && eachLPMCustomer.CIS__r.IsCredit__c == 1 ) || (genLeadDPDCustomSetting.NonCredit__c && eachLPMCustomer.CIS__r.IsNonCredit__c != null && eachLPMCustomer.CIS__r.IsNonCredit__c == 1))
                    && eachLPMCustomer.Primary__c) ) {
                return false;
        }

        if(eachLPMCustomer.CIS__r.Owner.Segment__c == GlobalConstants.SEGMENT_SE) {
            disPlayDPDthreshold = Integer.valueOf(genLeadDPDCustomSetting.SE__c);
        }else if(eachLPMCustomer.CIS__r.Owner.Segment__c == GlobalConstants.SEGMENT_ME) {
            disPlayDPDthreshold = Integer.valueOf(genLeadDPDCustomSetting.ME__c);
        }else if(eachLPMCustomer.CIS__r.Owner.Segment__c == GlobalConstants.SEGMENT_CB){
            disPlayDPDthreshold = Integer.valueOf(genLeadDPDCustomSetting.CB__c);
        }else if(eachLPMCustomer.CIS__r.Owner.Segment__c == GlobalConstants.SEGMENT_MB){
            disPlayDPDthreshold = Integer.valueOf(genLeadDPDCustomSetting.MB__c);
        }else{
            return false;
        }

        // logic to determine if to create TargetList Or Not
        if(disPlayDPD >= disPlayDPDthreshold){
            isCreateTargetList = true;
        }else{
            //if(disPlayDPD == 0){
                if( CLSR_SET.contains(eachLPMCustomer.LPM__r.CLS_Reason__c) || CLSR_SET_WITH_OD.contains(eachLPMCustomer.LPM__r.CLS_Reason__c) || isTRDDateWithInRageToCreateLead(eachLPMCustomer.LPM__r.TDR_Date__c) ){
                    isCreateTargetList = true;
                }
            //}
        }

        return isCreateTargetList;
    }
  
}