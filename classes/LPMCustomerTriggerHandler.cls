/**
* @author anan.b@beryl8.com
* @07/02/2017 created new
*/
public class LPMCustomerTriggerHandler extends TriggerHandler{
	private Set<Id> accountIdSet = new Set<Id>();
	private Set<Id> LPMIdSet  = new Set<Id>();
	private Map<Id,LPM__c> LPMmapById; 
	private Map<Id,Account> accountMapById;

	public override void allBefore(){
		for(LPM_Customer__c eachLPMCustomer : (List<LPM_Customer__c>)Trigger.new ){
			accountIdSet.add(eachLPMCustomer.CIS__c);
			LPMIdSet.add(eachLPMCustomer.LPM__c);
		}

		accountMapById = new Map<Id,Account>([SELECT Id,CIS__c From Account WHERE Id IN :accountIdSet]);
		LPMmapById = new Map<Id,LPM__c>([SELECT Id,LPM__c From LPM__c WHERE Id IN :LPMIdSet]);

		Account eachAccount;
		LPM__c eachLPM;
		for(LPM_Customer__c eachLPMCustomer : (List<LPM_Customer__c>)Trigger.new ){
			if(accountMapById.containsKey(eachLPMCustomer.CIS__c) && LPMmapById.containsKey(eachLPMCustomer.LPM__c)){
				eachAccount = accountMapById.get(eachLPMCustomer.CIS__c);
				eachLPM = LPMmapById.get(eachLPMCustomer.LPM__c);
				eachLPMCustomer.External__c = getLPMCustomerExternalId(eachAccount,eachLPM);
			}else{
				eachLPMCustomer.addError('LPM OR Account is Blank');
			}
		}
	}

	public override void afterDelete(){
		Set<Id> LPMIdSetInactiveTargetList = new Set<Id>();
		for(LPM_Customer__c eachLPMCustomer : (List<LPM_Customer__c>)Trigger.old ){
			if(eachLPMCustomer.Primary__c){
				LPMIdSetInactiveTargetList.add(eachLPMCustomer.LPM__c);
			}
		}
		TargetList_Service.inActiveTargetListFromLPMId(LPMIdSetInactiveTargetList);
	}

	private String getLPMCustomerExternalId(Account accObj, LPM__c LPMObj){
		String externalId = LPMObj.LPM__c+':'+accObj.CIS__c;
		return externalId;
	}	
}