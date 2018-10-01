/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Service Class for Re-Calculate Ownership for All Segment
Test Class:    ReCalculateOwnership_Service_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/03/2018  Charnun.T           First Create
08/03/2018  Charnun.T           Correct Service API to call prospect batch
------------------------------------------------------------*/
public class ReCalculateOwnership_Service {

    // Prospect -> RBS -> AF -> SME -> CBS
    //public static void reCalculateAllSegment(){
    //    Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
    //}

    //public static void reCalculateWithAccountList(Set<Id> accountIdSet, String sourceValue){
    //    Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch(accountIdSet,sourceValue));
    //}

    //public static void reCalculateProspect(){
    //    Database.executeBatch(new ReCalculateOwnershipProspect_Batch());
    //}

    //public static void reCalculateProspectWithAccountList(Set<Id> accountIdSet){
    //    Database.executeBatch(new ReCalculateOwnershipProspect_Batch(accountIdSet));
    //}

    //public static void reCalculateRBSSegment(){
    //    Database.executeBatch(new SME_ReCalculatePermanentOwnership_Batch());
    //}

    //public static void reCalculateAFSegment(){
    //    Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
    //}

    //public static void reCalculateSMESegment(){
    //    Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
    //}

    //public static void reCalculateCBSSegment(){
    //    Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
    //}

    public static UserExtensionAndTeam getRelatedUserExtensionAndTeam(List<Account> accountList) {
        Set<Id> relatedOwnerIds = new Set<Id>();
        Set<String> relatedTeamRCCodes = new Set<String>();
        Map<String, Id> teamMapByRc = new Map<String, Id>();
        Map<Id, User_Extension__c> userExtMapByUserId = new Map<Id, User_Extension__c>();
        for(Account eachAccount : accountList) {
            relatedOwnerIds.add(eachAccount.OwnerId);
            relatedOwnerIds.add(eachAccount.Previous_Owner__c);
            relatedTeamRCCodes.add(eachAccount.RC_Code__c);
            relatedTeamRCCodes.add(eachAccount.AH_RC_Code__c);
            relatedTeamRCCodes.add(eachAccount.NH_RC_Code__c);
            relatedTeamRCCodes.add(eachAccount.Previous_Owner__r.RC_Code__c);
            relatedTeamRCCodes.add(eachAccount.Previous_Owner__r.AH_RC_Code__c);
            relatedTeamRCCodes.add(eachAccount.Previous_Owner__r.NH_RC_Code__c);
        }
        for(Team_Structure__c eachTeam : [SELECT Id, RC_Code__c, External_ID__c FROM Team_Structure__c WHERE RC_Code__c IN :relatedTeamRCCodes]) {
            if(eachTeam.RC_Code__c != null) teamMapByRc.put(eachTeam.RC_Code__c, eachTeam.Id);
        }
        for(User_Extension__c eachUserExt : [SELECT Id, User__c, External_ID__c FROM User_Extension__c WHERE User__c IN :relatedOwnerIds]) {
            if(eachUserExt.User__c != null) userExtMapByUserId.put(eachUserExt.User__c, eachUserExt);
        }
        UserExtensionAndTeam userExtensionAndTeam = new UserExtensionAndTeam();
        userExtensionAndTeam.teamMapByRc        = teamMapByRc;
        userExtensionAndTeam.userExtMapByUserId = userExtMapByUserId;
        return UserExtensionAndTeam;
    }

    public class UserExtensionAndTeam {
        public Map<String, Id> teamMapByRc;
        public Map<Id, User_Extension__c> userExtMapByUserId;
        public UserExtensionAndTeam() {
            teamMapByRc = new Map<String, Id>();
            userExtMapByUserId = new Map<Id, User_Extension__c>();
        }
    }
}