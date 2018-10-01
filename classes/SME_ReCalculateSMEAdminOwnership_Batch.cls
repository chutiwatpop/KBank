/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Batch Class for Re-Calculate SMEAdmin Ownership
Test Class:    SME_ReCalculateSMEAdminOwnership_Batch_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/18/2017  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_ReCalculateSMEAdminOwnership_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    String sourceValueParameter = '';
    Set<Id> accountIdSetParameter;

    private List<Id> queryOwnerIds;
    private SME_Admin__c sa;

    private static string mainQuery = 'SELECT id, name, cis__c, Ownership_Text__c, Port_Pool__c, ownerId, owner.Name, owner.ProfileId, owner.Profile.Name, '
                        +'Current_Owner_Extension__c, Permanent_Owner_Extension__c, '
                        +'Current_Team_Name__c, Permanent_Team_Name__c, '
                        +'Current_AH_Name__c,Permanent_AH_Name__c, '
                        +'Current_NH_Name__c,Permanent_NH_Name__c, '
                        +'Current_Owner_Extension__r.User__c, Permanent_Owner_Extension__r.User__c, '
                        +'Current_Owner_Extension__r.Team_Structure__c, '
                        +'Current_Owner_Extension__r.Team_Structure__r.AH_Name__c, '
                        +'Current_Owner_Extension__r.Team_Structure__r.NH_Name__c, '
                        +'Permanent_Owner_Extension__r.Team_Structure__c, '
                        +'Permanent_Owner_Extension__r.Team_Structure__r.AH_Name__c, '
                        +'Permanent_Owner_Extension__r.Team_Structure__r.NH_Name__c ';

    global SME_ReCalculateSMEAdminOwnership_Batch() {
        this.sourceValueParameter = 'All';
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'\'';
    }

    global SME_ReCalculateSMEAdminOwnership_Batch(String sourceValue) {
        this.sourceValueParameter = sourceValue;
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'\'';
    }
    
    global SME_ReCalculateSMEAdminOwnership_Batch(Set<Id> accountIdSet, String sourceValue) {
        this.accountIdSetParameter = accountIdSet;
        this.sourceValueParameter = sourceValue;

        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(accountIdSet);
        String queryJoinSet = String.join(queryOwnerIds,'\',\'');

        this.query =    mainQuery + 'FROM account WHERE id IN (\''+queryJoinSet+'\') AND '
                        +'Ownership_Text__c = \'\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        sa = SME_Admin__c.getOrgDefaults();
        Map<String,sObject> accountWithUserExtension = GlobalUtility.toMap('Name', [SELECT Id, Name, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE Name IN('CBS Admin','SME-Admin')]);
        List<Account> updateAccountList = new List<Account>();

        for(Account eachAccount : accountList){
            if(eachAccount.owner.Name == 'SME-Admin'){
                User_Extension__c tempUserExtension = (User_Extension__c)accountWithUserExtension.get(eachAccount.owner.Name);
                eachAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                eachAccount.Port_Pool__c = null;
                eachAccount.Permanent_Team_Name__c = null;
                eachAccount.Current_Team_Name__c = null;

                eachAccount.Current_AH_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null;

                eachAccount.Current_NH_Name__c = null;
                eachAccount.Permanent_NH_Name__c = null;
                updateAccountList.add(eachAccount);
            }else if(eachAccount.owner.Name == 'CBS Admin'){
                User_Extension__c tempUserExtension = (User_Extension__c)accountWithUserExtension.get(eachAccount.owner.Name);
                eachAccount.Ownership_Text__c = 'Permanent';
                eachAccount.Port_Pool__c = 'Port';
                eachAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                eachAccount.Permanent_Team_Name__c = null;
                eachAccount.Current_Team_Name__c = null;

                eachAccount.Current_AH_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null;

                eachAccount.Current_NH_Name__c = null;
                eachAccount.Permanent_NH_Name__c = null;
                updateAccountList.add(eachAccount);
            }else if(eachAccount.Port_Pool__c == 'Port'){
                eachAccount.Ownership_Text__c = 'Permanent';
                updateAccountList.add(eachAccount);
            }else if(eachAccount.Port_Pool__c == 'Pool'){
                eachAccount.Ownership_Text__c = 'Temporary';
                updateAccountList.add(eachAccount);
            }
        }

        TriggerHandler.bypass('AccountTriggerHandler');
        Database.update(updateAccountList,false);
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
    
    global void finish(Database.BatchableContext BC) {
        if(accountIdSetParameter != null && accountIdSetParameter.size() > 0 && sourceValueParameter != ''){
            SME_ReCalculateOwnership_Service.reCalculatePermanent(accountIdSetParameter,sourceValueParameter);
        }else if (accountIdSetParameter == null && sourceValueParameter != ''){
            SME_ReCalculateOwnership_Service.reCalculatePermanent();
        }
    }
}