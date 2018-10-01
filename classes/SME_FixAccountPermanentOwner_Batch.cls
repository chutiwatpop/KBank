global class SME_FixAccountPermanentOwner_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.stateful {
    
    private static final String CLASS_NAME = 'SME_FixAccountPermanentOwner_Batch';

    Map<String, Id> userExMapByUser;
    Map<Id, User> userMap;
    Map<String, Team_Structure__c> teamIdMapByRC;
    String query;
    
    global SME_FixAccountPermanentOwner_Batch() {
        userMap = new Map<Id, User>([SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, IsActive, Profile.Name, ManagerId, Manager.ManagerId, Manager.IsActive, Manager.Manager.Id, Manager.Manager.IsActive FROM User]);

        teamIdMapByRC = new Map<String, Team_Structure__c>();
        List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c, AH_Name__c, NH_Name__c FROM Team_Structure__c];
        for(Team_Structure__c eachTeam : teamList) {
            if(eachTeam.RC_Code__c != null)
                teamIdMapByRc.put(eachTeam.RC_Code__c, eachTeam);
        }

        userExMapByUser = new Map<String, Id>();
        List<User_Extension__c> userExList = [SELECT Id, User__c FROM User_Extension__c];
        for(User_Extension__c eachEx : userExList) {
            if(eachEx.User__c != null)
                userExMapByUser.put(eachEx.User__c, eachEx.Id);
        }

        this.query = 'SELECT Id, Port_Pool__c, Ownership_Text__c, RecordType.DeveloperName, OwnerId FROM Account';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        User ownerUser;
        List<Account> updateAccount = new List<Account>();
        for(Account eachAccount : scope) {
            if(userMap.containsKey(eachAccount.OwnerId)) {
                ownerUser = userMap.get(eachAccount.OwnerId);
            } else {
                addLog(CLASS_NAME,'Cannot find Account Owner from Owner Id : ' + eachAccount.OwnerId);
                continue;
            }

            if(ownerUser.Profile.Name == GlobalConstants.SME_ADMIN || eachAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) { // Prospect
                if(eachAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) {
                    eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;    
                }
                if(ownerUser.Profile.Name == GlobalConstants.SME_ADMIN) {
                    eachAccount.Ownership_Text__c = null;
                }
                
                eachAccount.Port_Pool__c = null;
                eachAccount.Permanent_Owner_Extension__c = null;
                eachAccount.Permanent_Team_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null; 
                eachAccount.Permanent_NH_Name__c = null;
            } else if (eachAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME) { // Customer
                if(eachAccount.Port_Pool__c == GlobalConstants.PORT) { // Port
                    // If Port_Pool__c = Port Ownership = Permanent only
                    eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                    // Permanent Owner = Current Owner
                    eachAccount = setPermanentOwner(ownerUser, eachAccount);
                    if(eachAccount == null) continue;
                } else if(eachAccount.Port_Pool__c == GlobalConstants.POOL) { // Pool
                    if(ownerUser.Profile.Name == GlobalConstants.SME_RM) {
                        eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
                        // Permanent Owner = Current Owner Manager
                        if(ownerUser.Manager != null) {
                            eachAccount = setPermanentOwner(userMap.get(ownerUser.ManagerId), eachAccount);
                            if(eachAccount == null) continue;
                        } else {
                            addLog(CLASS_NAME,'Cannot find Manager of RM User Id : ' + ownerUser.Id);
                            continue;
                        }
                    } else if(ownerUser.Profile.Name == GlobalConstants.SME_TM || ownerUser.Profile.Name == GlobalConstants.SME_AH) {
                        eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                        // Permanent Owner = Current Owner
                        eachAccount = setPermanentOwner(ownerUser, eachAccount);
                        if(eachAccount == null) continue;
                    }
                } else if(eachAccount.Port_Pool__c == null && (eachAccount.Ownership_Text__c == null || eachAccount.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY)) { // Converted Customer
                    eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
                    eachAccount.Permanent_Owner_Extension__c = null;
                    eachAccount.Permanent_Team_Name__c = null;
                    eachAccount.Permanent_AH_Name__c = null; 
                    eachAccount.Permanent_NH_Name__c = null;
                } else {
                    addLog(CLASS_NAME,'Port/Pool is null from Account Id : ' + eachAccount.Id);
                    continue;
                }
            }
            updateAccount.add(eachAccount);
        }
        clearance(updateAccount);
    }
    
    private Account setPermanentOwner(User ownerUser, Account eachAccount) {
        if(ownerUser.IsActive) { // Check Is Active
            if(userExMapByUser.containsKey(ownerUser.Id)) {
                eachAccount.Permanent_Owner_Extension__c = userExMapByUser.get(ownerUser.Id);
            } else {
                addLog(CLASS_NAME,'Cannot map User Extension from User Id : ' + ownerUser.Id);
                return null;
            }
            
            if(teamIdMapByRC.containsKey(ownerUser.RC_Code__c)) {
                Team_Structure__c eachTeam = teamIdMapByRC.get(ownerUser.RC_Code__c);
                if(ownerUser.Profile.Name == GlobalConstants.SME_RM || ownerUser.Profile.Name == GlobalConstants.SME_TM) {
                    eachAccount.Permanent_Team_Name__c = eachTeam.Id;
                    eachAccount.Permanent_AH_Name__c = eachTeam.AH_Name__c;
                    eachAccount.Permanent_NH_Name__c = eachTeam.NH_Name__c;
                } else if(ownerUser.Profile.Name == GlobalConstants.SME_AH) {
                    eachAccount.Permanent_Team_Name__c = null;
                    eachAccount.Permanent_AH_Name__c = eachTeam.Id;
                    eachAccount.Permanent_NH_Name__c = eachTeam.NH_Name__c;
                } else if(ownerUser.Profile.Name == GlobalConstants.SME_NH) {
                    eachAccount.Permanent_Team_Name__c = null;
                    eachAccount.Permanent_AH_Name__c = null;
                    eachAccount.Permanent_NH_Name__c = eachTeam.Id;
                }
                
            } else {
                addLog(CLASS_NAME,'Cannot map Team Structure from RC Code : ' + ownerUser.RC_Code__c);
                return null;
            }

            return eachAccount;
        } else {
            if(ownerUser.Manager != null) {
                return setPermanentOwner(userMap.get(ownerUser.ManagerId), eachAccount);    
            } else {
                eachAccount.Permanent_Owner_Extension__c = null;
                eachAccount.Permanent_Team_Name__c = null;
                eachAccount.Permanent_AH_Name__c = null;
                eachAccount.Permanent_NH_Name__c = null;
                return eachAccount;
            }
        }
    }

    private void clearance(List<Account> updateAccount){
        if(!updateAccount.isEmpty()){
            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccount;
        }
        super.clearance();
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
}