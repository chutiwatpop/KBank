/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
31/10/2016  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_YearEndOpportunityChangeOwner_Batch implements Database.Batchable<sObject> {
    private Map<String,String> userChangeOpportunityOwnerMap = new Map<String,String>();
    private Map<String,Account> userOwnerAccountMap;
    private Set<Id> relatedUpdateSet = new Set<Id>();
    
    global SME_YearEndOpportunityChangeOwner_Batch(Set<Id> relatedUpdateSetInput, Map<String,String> userChangeOpportunityOwnerMapInput){
        relatedUpdateSet.addAll(relatedUpdateSetInput);
        userChangeOpportunityOwnerMap.putAll(userChangeOpportunityOwnerMapInput);
        userOwnerAccountMap = new Map<String,Account>();
        //List<Account> accountList = [SELECT Id,CIS__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Current_Owner_Extension__c,Ownership_Text__c,Port_Pool__c FROM Account WHERE Id IN:relatedUpdateSet];
        //for(Account eachAccount : accountList){
        //   userOwnerAccountMap.put(eachAccount.Id, eachAccount);
        //}
    }

    public String query(){
        return  'SELECT Id,StageName,IsClosed,OwnerId,AccountId,Account.OwnerId,Account.Owner.ProfileId,Account.Owner.Profile.Name,Owner_Segment_Business_Code__c,Business_Code_Text__c,Business_Code__c FROM Opportunity WHERE AccountId IN:relatedUpdateSet';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query());
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        if(scope.size() > 0){
            Set<Id> accountRelateList = new Set<Id>();
            for(Opportunity eachOpportunity : scope){
                if(!accountRelateList.contains(eachOpportunity.AccountId)){
                    accountRelateList.add(eachOpportunity.AccountId);
                }
            }
            List<Account> accountList = [SELECT Id,CIS__c,Current_Team_Name__c,Current_AH_Name__c,Current_NH_Name__c,Current_Owner_Extension__c,Ownership_Text__c,Port_Pool__c,Owner.Segment__c FROM Account WHERE Id IN:accountRelateList];
            for(Account eachAccount : accountList){
                userOwnerAccountMap.put(eachAccount.Id, eachAccount);
            }

            Map<String,String> oppIdMapByBusinessCodeExId = new Map<String,String>();
            Map<String,Business_Code__c> businessCodeMapByExternalId;
            List<Opportunity> tempOpportunityList = new List<Opportunity>();
            List<Opportunity> tempOppChangeBusinessCodeList = new List<Opportunity>();
            Boolean isOppBusinessCodeChange;
            for(Opportunity eachOpportunity : scope){
                isOppBusinessCodeChange = false;
                if(userChangeOpportunityOwnerMap.get(eachOpportunity.AccountId) != null && !eachOpportunity.IsClosed && (eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)){
                    eachOpportunity.OwnerId = userChangeOpportunityOwnerMap.get(eachOpportunity.AccountId);
                    eachOpportunity.Current_Team_Name__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Current_Team_Name__c;
                    eachOpportunity.Current_AH_Name__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Current_AH_Name__c;
                    eachOpportunity.Current_NH_Name__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Current_NH_Name__c;
                    eachOpportunity.Current_Owner_Extension__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Current_Owner_Extension__c;
                    eachOpportunity.Ownership__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Ownership_Text__c;
                    eachOpportunity.Port_Pool__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Port_Pool__c;
                    
                    if(userOwnerAccountMap.get(eachOpportunity.AccountId).Owner.Segment__c != eachOpportunity.Owner_Segment_Business_Code__c){
                        eachOpportunity.Owner_Segment_Business_Code__c = userOwnerAccountMap.get(eachOpportunity.AccountId).Owner.Segment__c;
                        if(eachOpportunity.Business_Code__c != null && eachOpportunity.Business_Code_Text__c != null){
                            isOppBusinessCodeChange = true;
                            String businessCodeExternald = eachOpportunity.Business_Code_Text__c+':'+userOwnerAccountMap.get(eachOpportunity.AccountId).Owner.Segment__c;
                            oppIdMapByBusinessCodeExId.put(eachOpportunity.id,businessCodeExternald);
                            eachOpportunity.Business_Code__c = null;
                            eachOpportunity.Business_Code_Text__c = null;
                        }
                    }
                    if(!isOppBusinessCodeChange){
                        tempOpportunityList.add(eachOpportunity);
                    }else{
                        tempOppChangeBusinessCodeList.add(eachOpportunity);
                    }
                }
            }
            businessCodeMapByExternalId = Customer_BusinessCode_Service.getBusinessCodeMapByExternalId(new Set<String>(oppIdMapByBusinessCodeExId.values()));
            if(!businessCodeMapByExternalId.isEmpty()){
                for(Opportunity eachOpportunity : tempOppChangeBusinessCodeList){
                   if(eachOpportunity.Business_Code__c != null){
                        String businessCodeExternalId = oppIdMapByBusinessCodeExId.get(eachOpportunity.id);
                        Business_Code__c beCode = businessCodeMapByExternalId.get(businessCodeExternalId);
                        if(beCode != null){
                            eachOpportunity.Business_Code__c = beCode.id;
                            eachOpportunity.Business_Code_Text__c = beCode.Name;
                        }
                   }
                }

            }
            tempOpportunityList.addAll(tempOppChangeBusinessCodeList);

            if(tempOpportunityList.size() > 0){
                update tempOpportunityList;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}