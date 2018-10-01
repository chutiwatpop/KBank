/**
* @author anan.b@beryl8.com
* @15/08/2017 INC000000764605 For TrackError Batch
*/
global class CustomerBusinessCode_Initial_Batch implements Database.Batchable<sObject>{
	
	String query;
	
	global CustomerBusinessCode_Initial_Batch() {
		this.query = 'SELECT Id,CIS__c,Customer_s_Business_Code__c,Owner.Segment__c From Account';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accountList) { 
   		Set<String> businessCodeSet = new Set<String>();
   		//List<Call_Report__c> callReportList = [SELECT CIS_ID__r.Owner.Segment__c,Business_Code_Text__c,CIS_ID__c,CIS_ID__r.CIS__c,Business_Code__c,Business_Code__r.External_ID__c,Risky_Control__c,Exception__c,Description__c,Keyword__c,Industry_Room_Left__c,Ratio__c,Industry_Risk_Rating__c,Estimate_Credit_Model__c From Call_Report__c WHERE CIS_ID__c IN :accountList AND Business_Code_Text__c != null];
		List<Opportunity> opportunityList = [SELECT Account.Owner.Segment__c,Owner.Segment__c,Business_Code_Text__c,AccountId,Account.CIS__c,Business_Code__c,Business_Code__r.External_ID__c From Opportunity WHERE AccountId IN :accountList AND Business_Code_Text__c != null ];
		
		for(Account eachAccount : accountList){
			if(eachAccount.Customer_s_Business_Code__c != null && eachAccount.Owner.Segment__c != null) {
				eachAccount.Customer_s_Business_Code__c = Customer_BusinessCode_Service.fillPreFixBusinessCode(eachAccount.Customer_s_Business_Code__c);
				if(!businessCodeSet.contains(eachAccount.Customer_s_Business_Code__c+':'+eachAccount.Owner.Segment__c)){
					businessCodeSet.add(eachAccount.Customer_s_Business_Code__c+':'+eachAccount.Owner.Segment__c);
				}
			}
		}

		//for(Call_Report__c eachCallReport : callReportList){
		//	if(eachCallReport.CIS_ID__r.Owner.Segment__c != null && !businessCodeSet.contains(eachCallReport.Business_Code_Text__c+':'+eachCallReport.CIS_ID__r.Owner.Segment__c))
		//		businessCodeSet.add(eachCallReport.Business_Code_Text__c+':'+eachCallReport.CIS_ID__r.Owner.Segment__c);
		//}
		for(Opportunity eachOpportunity : opportunityList){
			if(eachOpportunity.Account.Owner.Segment__c != null && !businessCodeSet.contains(eachOpportunity.Business_Code_Text__c+':'+eachOpportunity.Account.Owner.Segment__c))
				businessCodeSet.add(eachOpportunity.Business_Code_Text__c+':'+eachOpportunity.Account.Owner.Segment__c);
			if(eachOpportunity.Owner.Segment__c != null && !businessCodeSet.contains(eachOpportunity.Business_Code_Text__c+':'+eachOpportunity.Owner.Segment__c))
				businessCodeSet.add(eachOpportunity.Business_Code_Text__c+':'+eachOpportunity.Owner.Segment__c);
		}

		Map<String,Business_Code__c> businessCodeMapByExId =Customer_BusinessCode_Service.getBusinessCodeMapByExternalId(businessCodeSet);
		Map<String,Customer_Business_Code__c> customerBusinessCodeMap = new Map<String,Customer_Business_Code__c>();

		for(Account eachAccount : accountList){
			if(eachAccount.Customer_s_Business_Code__c != null && eachAccount.Owner.Segment__c != null) {
				String businessCodeExternalId = eachAccount.Customer_s_Business_Code__c+':'+eachAccount.Owner.Segment__c;
				if(businessCodeMapByExId.containsKey(businessCodeExternalId)){
					Business_Code__c businessCodeObj = businessCodeMapByExId.get(businessCodeExternalId);
					String customerBusinessCodeKey = Customer_BusinessCode_Service.generateExternalId(eachAccount,businessCodeObj.External_ID__c);
					if(!customerBusinessCodeMap.containsKey(customerBusinessCodeKey)){
						Customer_Business_Code__c customerBusinessCodeObj = new Customer_Business_Code__c(Name=businessCodeObj.Name,CIS__c = eachAccount.id, Business_Code__c = businessCodeObj.id,External__c = customerBusinessCodeKey,Account_Owner_Segment__c=eachAccount.Owner.Segment__c,Keyword_text__c=businessCodeObj.Keyword__c,Description_Text__c = businessCodeObj.Business_Code_Description__c);
						customerBusinessCodeMap.put(customerBusinessCodeKey,customerBusinessCodeObj);
					}
				}
			}
		}

		//for(Call_Report__c eachCallReport : callReportList){
		//	if(eachCallReport.Business_Code_Text__c != null && eachCallReport.CIS_ID__r.Owner.Segment__c != null){
		//		String businessCodeExternalId = eachCallReport.Business_Code_Text__c+':'+eachCallReport.CIS_ID__r.Owner.Segment__c;
		//		if(businessCodeMapByExId.containsKey(businessCodeExternalId)){
		//			Business_Code__c businessCodeObj = businessCodeMapByExId.get(businessCodeExternalId);
		//			String customerBusinessCodeKey = Customer_BusinessCode_Service.generateExternalId(eachCallReport,businessCodeObj.External_ID__c);
		//			if(!customerBusinessCodeMap.containsKey(customerBusinessCodeKey)){
		//				if(eachCallReport.CIS_ID__c != null){
		//					Customer_Business_Code__c customerBusinessCodeObj = new Customer_Business_Code__c(Name=businessCodeObj.Name,CIS__c = eachCallReport.CIS_ID__c, Business_Code__c = businessCodeObj.id,External__c = customerBusinessCodeKey,Account_Owner_Segment__c=eachCallReport.CIS_ID__r.Owner.Segment__c,Keyword_text__c=businessCodeObj.Keyword__c,Description_Text__c = businessCodeObj.Business_Code_Description__c);
		//					customerBusinessCodeMap.put(customerBusinessCodeKey,customerBusinessCodeObj);
		//				}
		//			}
		//		}
		//	}
		//}
		
		for(Opportunity eachOpportunity : opportunityList){
			if(eachOpportunity.Business_Code_Text__c != null && eachOpportunity.Owner.Segment__c != null){
				String businessCodeExternalId;
				Business_Code__c businessCodeObj;
				if(eachOpportunity.Owner.Segment__c != null){
					businessCodeExternalId = eachOpportunity.Business_Code_Text__c+':'+ eachOpportunity.Owner.Segment__c;
					if(businessCodeMapByExId.containsKey(businessCodeExternalId)){
						businessCodeObj = businessCodeMapByExId.get(businessCodeExternalId);
						eachOpportunity.Business_Code__c = businessCodeObj.id;

					}
				}
				businessCodeExternalId = null;
				businessCodeObj = null;

				if( eachOpportunity.Account.Owner.Segment__c != null){
					businessCodeExternalId = eachOpportunity.Business_Code_Text__c+':'+ eachOpportunity.Account.Owner.Segment__c;
					businessCodeObj = businessCodeMapByExId.get(businessCodeExternalId);
					if(businessCodeObj != null){
						String customerBusinessCodeKey = Customer_BusinessCode_Service.generateExternalId(eachOpportunity,businessCodeObj.External_ID__c);
						if(!customerBusinessCodeMap.containsKey(customerBusinessCodeKey)){
							if(eachOpportunity.AccountId != null){
								Customer_Business_Code__c customerBusinessCodeObj = new Customer_Business_Code__c(Name=businessCodeObj.Name,CIS__c = eachOpportunity.AccountId, Business_Code__c = businessCodeObj.id,External__c = customerBusinessCodeKey,Account_Owner_Segment__c=eachOpportunity.Account.Owner.Segment__c,Keyword_text__c=businessCodeObj.Keyword__c,Description_Text__c = businessCodeObj.Business_Code_Description__c);
								customerBusinessCodeMap.put(customerBusinessCodeKey,customerBusinessCodeObj);
							}
						}

					}

				}
			}

		}
		upsert customerBusinessCodeMap.values() External__c;
		customerBusinessCodeMap = Customer_BusinessCode_Service.getCustomerBuisnessCodeMapByExternalId(customerBusinessCodeMap.keySet());
		//for(Call_Report__c eachCallReport : callReportList){		
		//	if(eachCallReport.Business_Code_Text__c != null && eachCallReport.CIS_ID__r.Owner.Segment__c != null){
		//		String businessCodeExternalId = eachCallReport.Business_Code_Text__c+':'+eachCallReport.CIS_ID__r.Owner.Segment__c;
		//		String customerBusinessCodeKey = Customer_BusinessCode_Service.generateExternalId(eachCallReport,businessCodeExternalId);
		//		if( customerBusinessCodeMap.containsKey(customerBusinessCodeKey)){
		//			eachCallReport.Customer_Business_Code__c = customerBusinessCodeMap.get(customerBusinessCodeKey).id;
		//			CallReport_Service.setBusinessCodeDataInCallReport(eachCallReport,customerBusinessCodeMap.get(customerBusinessCodeKey));
		//		}
		//	}
		//}
		//INC000000764605
		//if(!callReportList.isEmpty()){
		//	DB_Service.updateSObjectWithBypass(callReportList,true);
		//}
		if(!opportunityList.isEmpty()){
			DB_Service.updateSObjectWithBypass(opportunityList,true);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
	}

}