/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Batch Class for Re-Calculate Permanent Ownership
Test Class:    SME_ReCalculatePermanentOwnership_Batch_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/18/2017  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_ReCalculatePermanentOwnership_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
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

    global SME_ReCalculatePermanentOwnership_Batch() {
        this.sourceValueParameter = 'All';
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'Permanent\' AND IsSame__c = 1';
    }

    global SME_ReCalculatePermanentOwnership_Batch(String sourceValue) {
        this.sourceValueParameter = sourceValue;
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'Permanent\' AND IsSame__c = 1';
    }
    
    global SME_ReCalculatePermanentOwnership_Batch(Set<Id> accountIdSet, String sourceValue) {
        this.accountIdSetParameter = accountIdSet;
        this.sourceValueParameter = sourceValue;

        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(accountIdSet);
        String queryJoinSet = String.join(queryOwnerIds,'\',\'');

        this.query =    mainQuery + 'FROM account WHERE id IN (\''+queryJoinSet+'\') AND '
                        +'Ownership_Text__c = \'Permanent\' AND IsSame__c = 1';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        Map<Id,Account> updateAccountMap = new Map<Id,Account>();
        Set<Id> possibleExtensionSet = new Set<Id>();
        List<Account> updateAccountList = new List<Account>();

        sa = SME_Admin__c.getOrgDefaults();
        //Map<String,sObject> accountSMEAdminUserExtension = GlobalUtility.toMap('User__c', [SELECT Id, Name, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE User__c =:sa.User_Record_ID__c]);
        Map<String,sObject> accountSMEAdminUserExtension = GlobalUtility.toMap('Name', [SELECT Id, Name, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE Name IN('CBS Admin','SME-Admin')]);
        
        for(Account eachAccount : accountList){
            if(eachAccount.Port_Pool__c == null && eachAccount.Owner.Name == 'SME-Admin'){
                User_Extension__c tempUserExtension = (User_Extension__c)accountSMEAdminUserExtension.get(eachAccount.Owner.Name);
                eachAccount.Ownership_Text__c = '';
                eachAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                eachAccount.Permanent_Owner_Extension__c = null;
                
                eachAccount.Current_Team_Name__c = null;
                eachAccount.Permanent_Team_Name__c = null;

                eachAccount.Current_AH_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null;

                eachAccount.Current_NH_Name__c = null;
                eachAccount.Permanent_NH_Name__c = null;
                updateAccountList.add(eachAccount);
            }else if (eachAccount.Port_Pool__c == null && eachAccount.Owner.Name == 'CBS Admin'){
                User_Extension__c tempUserExtension = (User_Extension__c)accountSMEAdminUserExtension.get(eachAccount.Owner.Name);
                eachAccount.Port_Pool__c = 'Port';
                eachAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                eachAccount.Permanent_Owner_Extension__c = null;
                
                eachAccount.Current_Team_Name__c = null;
                eachAccount.Permanent_Team_Name__c = null;

                eachAccount.Current_AH_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null;

                eachAccount.Current_NH_Name__c = null;
                eachAccount.Permanent_NH_Name__c = null;
                updateAccountList.add(eachAccount);
            }
        }
        
        for(Account eachAccount : accountList){
            if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c == null && eachAccount.Permanent_Owner_Extension__c == null){
                possibleExtensionSet.add(Id.valueOf(eachAccount.OwnerId));
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c != null && eachAccount.Permanent_Owner_Extension__c != null && eachAccount.OwnerId != eachAccount.Current_Owner_Extension__r.User__c && eachAccount.OwnerId != eachAccount.Permanent_Owner_Extension__r.User__c){
                possibleExtensionSet.add(Id.valueOf(eachAccount.OwnerId));
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c != null && eachAccount.Permanent_Owner_Extension__c == null && eachAccount.OwnerId != eachAccount.Current_Owner_Extension__r.User__c){
                possibleExtensionSet.add(Id.valueOf(eachAccount.OwnerId));
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c == null && eachAccount.Permanent_Owner_Extension__c != null && eachAccount.OwnerId != eachAccount.Permanent_Owner_Extension__r.User__c){
                possibleExtensionSet.add(Id.valueOf(eachAccount.OwnerId));
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c != null && eachAccount.OwnerId == eachAccount.Current_Owner_Extension__r.User__c && eachAccount.Permanent_Owner_Extension__c == null && eachAccount.OwnerId != eachAccount.Permanent_Owner_Extension__r.User__c){
                eachAccount.Permanent_Owner_Extension__c = eachAccount.Current_Owner_Extension__c;
                eachAccount.Current_Team_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__c;
                eachAccount.Permanent_Team_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__c;

                eachAccount.Current_AH_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__r.AH_Name__c;
                eachAccount.Permanent_AH_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__r.AH_Name__c;
                
                eachAccount.Current_NH_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__r.NH_Name__c;
                eachAccount.Permanent_NH_Name__c = eachAccount.Current_Owner_Extension__r.Team_Structure__r.NH_Name__c;
                updateAccountList.add(eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Permanent_Owner_Extension__c != null && eachAccount.OwnerId == eachAccount.Permanent_Owner_Extension__r.User__c && eachAccount.Current_Owner_Extension__c == null && eachAccount.OwnerId != eachAccount.Current_Owner_Extension__r.User__c){
                eachAccount.Current_Owner_Extension__c = eachAccount.Permanent_Owner_Extension__c;
                eachAccount.Current_Team_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__c;
                eachAccount.Permanent_Team_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__c;

                eachAccount.Current_AH_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__r.AH_Name__c;
                eachAccount.Permanent_AH_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__r.AH_Name__c;

                eachAccount.Current_NH_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__r.NH_Name__c;
                eachAccount.Permanent_NH_Name__c = eachAccount.Permanent_Owner_Extension__r.Team_Structure__r.NH_Name__c;
                updateAccountList.add(eachAccount);
            }else if(eachAccount.Port_Pool__c != null && eachAccount.Current_Owner_Extension__c != null && eachAccount.Permanent_Owner_Extension__c != null && eachAccount.OwnerId == eachAccount.Permanent_Owner_Extension__r.User__c && eachAccount.OwnerId == eachAccount.Current_Owner_Extension__r.User__c && eachAccount.Current_Team_Name__c != eachAccount.Permanent_Team_Name__c){
                possibleExtensionSet.add(Id.valueOf(eachAccount.OwnerId));
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }
        }

        Map<String,sObject> accountWithUserExtension = GlobalUtility.toMap('User__c', [SELECT Id, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE User__c IN :possibleExtensionSet]);
        for(Id eachAccountId : updateAccountMap.keySet()){
            if(updateAccountMap.get(eachAccountId) != null){
                Account tempAccount = updateAccountMap.get(eachAccountId);
                if(tempAccount.OwnerId != null && accountWithUserExtension.get(tempAccount.OwnerId) != null){
                    User_Extension__c tempUserExtension = (User_Extension__c)accountWithUserExtension.get(tempAccount.OwnerId);
                    tempAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                    tempAccount.Permanent_Owner_Extension__c = tempUserExtension.Id;

                    tempAccount.Current_Team_Name__c = tempUserExtension.Team_Structure__c;
                    tempAccount.Permanent_Team_Name__c = tempUserExtension.Team_Structure__c;

                    tempAccount.Current_AH_Name__c = tempUserExtension.Team_Structure__r.AH_Name__c;
                    tempAccount.Permanent_AH_Name__c = tempUserExtension.Team_Structure__r.AH_Name__c;
                
                    tempAccount.Current_NH_Name__c = tempUserExtension.Team_Structure__r.NH_Name__c;
                    tempAccount.Permanent_NH_Name__c = tempUserExtension.Team_Structure__r.NH_Name__c;
                    updateAccountList.add(tempAccount);
                }
            }
        }
        System.debug(updateAccountList);
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.update(updateAccountList,false);
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
    
    global void finish(Database.BatchableContext BC) {
        if(accountIdSetParameter != null && accountIdSetParameter.size() > 0 && sourceValueParameter != ''){
            SME_ReCalculateOwnership_Service.reCalculateTemporary(accountIdSetParameter,sourceValueParameter);
        }else if (accountIdSetParameter == null && sourceValueParameter != ''){
            SME_ReCalculateOwnership_Service.reCalculateTemporary();
        }
    }
}