/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Batch Class for Re-Calculate Temporary Ownership
Test Class:    SME_ReCalculateTemporaryOwnership_Batch_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/18/2017  Charnun.T           First Create
------------------------------------------------------------*/
global class SME_ReCalculateTemporaryOwnership_Batch implements Database.Batchable<sObject>, Database.Stateful {

    String query;
    String sourceValueParameter = '';
    Set<Id> accountIdSetParameter;

    private List<Id> queryOwnerIds;
    private SME_Admin__c sa;
    private static List<Id> accountReCalculatePermanentPort = new List<Id>();

    private static string mainQuery = 'SELECT id, name, cis__c, Ownership_Text__c, Port_Pool__c, ownerId, owner.Name, owner.ProfileId, owner.Profile.Name, IsSame__c, '
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

    global SME_ReCalculateTemporaryOwnership_Batch() {
        this.sourceValueParameter = 'All';
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'Temporary\'';
    }

    global SME_ReCalculateTemporaryOwnership_Batch(String sourceValue) {
        this.sourceValueParameter = sourceValue;
        this.query =    mainQuery + 'FROM account WHERE Ownership_Text__c = \'Temporary\'';
    }
    
    global SME_ReCalculateTemporaryOwnership_Batch(Set<Id> accountIdSet, String sourceValue) {
        this.accountIdSetParameter = accountIdSet;
        this.sourceValueParameter = sourceValue;

        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(accountIdSet);
        String queryJoinSet = String.join(queryOwnerIds,'\',\'');

        this.query =    mainQuery + 'FROM account WHERE id IN (\''+queryJoinSet+'\') AND '
                        +'Ownership_Text__c = \'Temporary\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        Map<String,sObject> accountAdminWithUserExtension = GlobalUtility.toMap('Name', [SELECT Id, Name, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE Name IN('CBS Admin','SME-Admin')]);
        Map<Id,Account> updateAccountMap = new Map<Id,Account>();
        Set<Id> possibleExtensionSet = new Set<Id>();
        Set<Id> checkFromYearEnd = new Set<Id>();
        List<Account> updateAccountList = new List<Account>();

        for(Account eachAccount : accountList){
            if(eachAccount.Port_Pool__c == 'Port' && eachAccount.IsSame__c == 1){
                accountReCalculatePermanentPort.add(eachAccount.Id);
                eachAccount.Ownership_Text__c = 'Permanent';
                updateAccountList.add(eachAccount);
            }else if(eachAccount.Port_Pool__c == null){
                if(eachAccount.Owner.Name == 'SME-Admin'){
                    User_Extension__c tempUserExtension = (User_Extension__c)accountAdminWithUserExtension.get(eachAccount.Owner.Name);
                    eachAccount.Current_Owner_Extension__c = tempUserExtension.Id;
                    eachAccount.Ownership_Text__c = '';
                    eachAccount.Permanent_Team_Name__c = null;
                    eachAccount.Current_Team_Name__c = null;

                    eachAccount.Current_AH_Name__c = null;
                    eachAccount.Permanent_AH_Name__c = null;

                    eachAccount.Current_NH_Name__c = null;
                    eachAccount.Permanent_NH_Name__c = null;
                    updateAccountList.add(eachAccount);
                }else if(eachAccount.owner.Name == 'CBS Admin'){
                    User_Extension__c tempUserExtension = (User_Extension__c)accountAdminWithUserExtension.get(eachAccount.owner.Name);
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
                }else if(eachAccount.OwnerId != eachAccount.Current_Owner_Extension__r.User__c){
                    possibleExtensionSet.add(eachAccount.OwnerId);
                    updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
                }
            }else if(eachAccount.Port_Pool__c == 'Pool'){
                checkFromYearEnd.add(eachAccount.Id);
                possibleExtensionSet.add(eachAccount.OwnerId);
                updateAccountMap.put(Id.valueOf(eachAccount.Id), eachAccount);
            }
        }

        Map<String,sObject> accountYearEndFinalAssign = GlobalUtility.toMap('CIS_ID__c', [SELECT Id,CIS_ID__c,Final_Assigned_Next_Year__c, Final_Assigned_Next_Year__r.User__c, Final_Assigned_Next_Year__r.User__r.Profile.Name FROM Year_End_Assignment__c WHERE CIS_ID__c IN :checkFromYearEnd]);
        for(sObject eachFinalAssign : accountYearEndFinalAssign.values()){
            Year_End_Assignment__c tempFinalAssign = (Year_End_Assignment__c)eachFinalAssign;
            if(tempFinalAssign.Final_Assigned_Next_Year__r.User__c != null){
                possibleExtensionSet.add(tempFinalAssign.Final_Assigned_Next_Year__r.User__c);
            }
        }

        Map<String,sObject> accountWithUserExtension = GlobalUtility.toMap('User__c', [SELECT Id, User__c, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE User__c IN :possibleExtensionSet]);
        for(Id eachAccountId : updateAccountMap.keySet()){
            if(updateAccountMap.get(eachAccountId) != null){
                Account tempAccount = updateAccountMap.get(eachAccountId);
                if(tempAccount.OwnerId != null && accountYearEndFinalAssign.get(tempAccount.Id) != null) {
                    Year_End_Assignment__c tempYearEnd = (Year_End_Assignment__c)accountYearEndFinalAssign.get(tempAccount.Id);
                    if(accountWithUserExtension.get(tempAccount.OwnerId) != null && tempAccount.OwnerId == tempYearEnd.Final_Assigned_Next_Year__r.User__c){
                        tempAccount.Ownership_Text__c = 'Permanent';
                        updateAccountList.add(tempAccount);
                    }else if(accountWithUserExtension.get(tempAccount.OwnerId) != null && tempAccount.OwnerId != tempYearEnd.Final_Assigned_Next_Year__r.User__c){
                        if (tempAccount.Owner != null && Account_Util.isProfile(GlobalConstants.SME_RM, tempAccount.Owner) && Account_Util.isProfile(GlobalConstants.SME_TM,tempYearEnd.Final_Assigned_Next_Year__r.User__r)){
                            User_Extension__c tempUserExtensionRM = (User_Extension__c)accountWithUserExtension.get(tempAccount.OwnerId);
                            User_Extension__c tempUserExtensionTM = (User_Extension__c)accountWithUserExtension.get(tempYearEnd.Final_Assigned_Next_Year__r.User__c);
                            tempAccount.Current_Owner_Extension__c = tempUserExtensionRM.Id;
                            tempAccount.Permanent_Owner_Extension__c = tempUserExtensionTM.Id;

                            tempAccount.Current_Team_Name__c = tempUserExtensionRM.Team_Structure__c;
                            tempAccount.Permanent_Team_Name__c = tempUserExtensionTM.Team_Structure__c;

                            tempAccount.Current_AH_Name__c = tempUserExtensionRM.Team_Structure__r.AH_Name__c;
                            tempAccount.Permanent_AH_Name__c = tempUserExtensionTM.Team_Structure__r.AH_Name__c;
                    
                            tempAccount.Current_NH_Name__c = tempUserExtensionRM.Team_Structure__r.NH_Name__c;
                            tempAccount.Permanent_NH_Name__c = tempUserExtensionTM.Team_Structure__r.NH_Name__c;
                            updateAccountList.add(tempAccount);
                        }
                    }
                }
            }
        }

        System.debug('updateAccountList:'+updateAccountList);
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.update(updateAccountList,false);
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('accountReCalculatePermanentPort:'+accountReCalculatePermanentPort);
    
    }
}