/**
* @author komsan.wi@beryl8.com
* @23/09/2015 createddate
*/
public with sharing class CreditBureauTriggerHandler extends TriggerHandler{
	public override void beforeInsert() {
		Map<Id,Integer> opportunityMap = new Map<Id,Integer>();
		for(Credit_Bureau__c eachCredit : (List<Credit_Bureau__c>)Trigger.new){
			if(eachCredit.Opportunity__c!=null) opportunityMap.put(eachCredit.Opportunity__c,null);
		}
		if(opportunityMap.size() > 0){
			List<Credit_Bureau__c> currentCreditList = new List<Credit_Bureau__c>();
			currentCreditList = [SELECT Opportunity__c,Running_Number__c FROM Credit_Bureau__c WHERE Opportunity__c in : opportunityMap.keySet() ORDER BY Running_Number__c DESC LIMIT 1];
			for(Credit_Bureau__c eachCredit : currentCreditList){
				if(opportunityMap.get(eachCredit.Opportunity__c)==null){
					opportunityMap.put(eachCredit.Opportunity__c,Integer.valueOf(eachCredit.Running_Number__c));
				}
			}
			for(Credit_Bureau__c eachCredit : (List<Credit_Bureau__c>)Trigger.new){
				if(opportunityMap.get(eachCredit.Opportunity__c)==null)
					eachCredit.Running_Number__c = '0001';
				else {
					String runningString = '000' + (Integer.valueOf(opportunityMap.get(eachCredit.Opportunity__c)) + 1);
					eachCredit.Running_Number__c = runningString.substring(runningString.length() - 4);
				}
			}
		}
	}
}