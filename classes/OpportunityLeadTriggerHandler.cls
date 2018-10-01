public class OpportunityLeadTriggerHandler extends TriggerHandler {

	public override void allBefore() {

		/*Set<Id> oppIds = new Set<Id>();
		Set<Id> targetIds = new Set<Id>();

		for (Opportunity_Lead__c oppLead : (List<Opportunity_Lead__c>) Trigger.new) {
			if (oppLead.Opportunity__c != null) {
				oppIds.add(oppLead.Opportunity__c);
			}
		}

		List<Call_Report_Opportunity__c > callReportOppList = new List<Call_Report_Opportunity__c >();
		callReportOppList = [SELECT Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Opportunity_Name__c IN :oppIds];
        Set<Id> oppInCallReportIds = new Set<Id>();
        for (Call_Report_Opportunity__c callOpp : callReportOppList) {
        	if (callOpp.Opportunity_Name__c != null)
            oppInCallReportIds.add(callOpp.Opportunity_Name__c);
        }


		List<Opportunity> filteredOppList = new List<Opportunity>();
		filteredOppList = [SELECT AccountId FROM Opportunity WHERE Id IN :oppInCallReportIds];
		
		if(!filteredOppList.isEmpty()) {
			Set<Id> accountIds = new Set<Id>();
			for (Opportunity eachOpp : filteredOppList) {
				if (eachOpp.AccountId != null) {
					accountIds.add(eachOpp.AccountId);
				}
			}

			List<Call_Report_Lead__c> callReportLeadList = new List<Call_Report_Lead__c>();
			callReportLeadList = [SELECT Id, Target_List__c, Target_List__r.Name FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__r.CIS_ID__c IN :accountIds];

			Set<Id> callReportTargetList = new Set<Id>();
			for (Call_Report_Lead__c callReportLead : callReportLeadList) {
				callReportTargetList.add(callReportLead.Target_List__c);
			}

			for (Opportunity_Lead__c oppLead : (List<Opportunity_Lead__c>) Trigger.new) {
				if (oppLead.Target_List__c != null) {
					if (!callReportTargetList.contains(oppLead.Target_List__c)) {
						oppLead.addError('Opportunity Lead need to be the same name as Call Report Lead');
					}
				}
			}
		}*/
		
	}
}