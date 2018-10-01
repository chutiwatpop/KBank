/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Service Class for Re-Calculate Ownership
Test Class:    SME_ReCalculateOwnership_Service_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/18/2017  Charnun.T           First Create
------------------------------------------------------------*/
public class SME_ReCalculateOwnership_Service {
	// Sequence SME-Admin -> Permanent -> Temporary
    // SME_ReCalculateSMEAdminOwnership_Batch();
    // SME_ReCalculatePermanentOwnership_Batch();
    // SME_ReCalculateTemporaryOwnership_Batch();
	public static void reCalculateAll(){
		Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
	}

	public static void reCalculateAll(Set<Id> accountIdSet, String sourceValue){
		Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch(accountIdSet,sourceValue));
	}

	public static void reCalculatePermanent(){
		Database.executeBatch(new SME_ReCalculatePermanentOwnership_Batch());
	}

	public static void reCalculatePermanent(Set<Id> accountIdSet, String sourceValue){
		Database.executeBatch(new SME_ReCalculatePermanentOwnership_Batch(accountIdSet,sourceValue));
	}

	public static void reCalculateTemporary(){
		Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch());
	}

	public static void reCalculateTemporary(Set<Id> accountIdSet, String sourceValue){
		Database.executeBatch(new SME_ReCalculateTemporaryOwnership_Batch(accountIdSet,sourceValue));
	}

	public static void reCalculateSMEAdmin(){
		Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch());
	}

	public static void reCalculateSMEAdmin(Set<Id> accountIdSet, String sourceValue){
		Database.executeBatch(new SME_ReCalculateSMEAdminOwnership_Batch(accountIdSet,sourceValue));
	}
}