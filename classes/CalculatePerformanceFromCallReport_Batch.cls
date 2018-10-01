global class CalculatePerformanceFromCallReport_Batch implements Database.Batchable<sObject>, Database.Stateful {
	private Map<String, User_Extension__c> userExtMapByUserId;
	private Map<Id, User_Extension__c> userExtMap;
    private Set<String> userIds{get{return userExtMapByUserId.keySet();}}
	public Map<Id, Product2> mapProduct2ById;
	public Set<String> setProductResultInterest;
	public Set<String> setProductReasonInterest;
    public String runForSegment;
    public static final String RUN_FOR_SME = 'SME';
	String query;
	
	global CalculatePerformanceFromCallReport_Batch(String runForSegment) {
        this.runForSegment = runForSegment;
        if(RUN_FOR_SME == runForSegment){
            userExtMap = new Map<Id, User_Extension__c>([SELECT Id,User__r.FirstName, Call_Report__c, Call_Report_Customer_Others__c, Call_Report_Customer_Pool__c, Call_Report_Customer_Port__c, Call_Report_for_Relationship__c, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Face_to_Face__c, Months__c, Phone_Call__c, Team_Structure__c, User__c, User__r.ProfileId, User__r.Profile.Name, User__r.RC_Code__c, User__r.Employee_Id__c, User__r.ManagerId, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__c != null AND User__r.SME_User__c = true]);
        }else{
            userExtMap = new Map<Id, User_Extension__c>([SELECT Id,User__r.FirstName, Call_Report__c, Call_Report_Customer_Others__c, Call_Report_Customer_Pool__c, Call_Report_Customer_Port__c, Call_Report_for_Relationship__c, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Face_to_Face__c, Months__c, Phone_Call__c, Team_Structure__c, User__c, User__r.ProfileId, User__r.Profile.Name, User__r.RC_Code__c, User__r.Employee_Id__c, User__r.ManagerId, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__c != null AND User__r.Is_RBS_User__c = true]);
        }

		userExtMapByUserId = new Map<String, User_Extension__c>();
        for(User_Extension__c eachExt : userExtMap.values()){
    		userExtMapByUserId.put(eachExt.User__c, eachExt);
    		clearPerformanceFieldValue(eachExt);
    		clearConversionRatioFieldValue(eachExt);
        }
        setProductResultInterest = new Set<String>(Label.Performance_Conversion_Product_Result_Interest.split('\\|'));
		setProductReasonInterest = new Set<String>(Label.Performance_Conversion_Product_Reason_Interest.split('\\|'));

        mapProduct2ById = new Map<Id, Product2>([SELECT Id,Product_Type__c FROM Product2]);
        List<String> queryRecordType = new List<String>();
		queryRecordType.addAll(GlobalConstants.CALL_REPORT_SME_DEVNAME_SET);
		queryRecordType.addAll(GlobalConstants.CALL_REPORT_RBS_DEVNAME_SET);
		this.query = 'SELECT Id, Cross_Selling_Product__c, Visit_Objective__c, Offer_Credit_Product__c, Collect_Documents__c, Negotiation__c, WhatId, OwnerId, ActivityDate, Contact_Channel__c, Status__c, Job__c, Job__r.AccountId, Job__r.Account.Port_Pool__c, Job__r.Account.Ownership_Text__c, Job__r.Account.OwnerId, Job__r.Account.Service_RM__c FROM Event WHERE ActivityDate = THIS_YEAR AND OwnerId IN :userIds AND RecordType.DeveloperName IN (\'' + String.join(queryRecordType,'\',\'') + '\')';
	}

	private void clearPerformanceFieldValue(User_Extension__c ownerUserExt){
		ownerUserExt.Call_Report__c = 0;
		ownerUserExt.Call_Report_Customer_Port__c = 0;
		ownerUserExt.Call_Report_Customer_Pool__c = 0;
		ownerUserExt.Call_Report_Customer_Others__c = 0;
		ownerUserExt.Face_to_Face__c = 0;
		ownerUserExt.Phone_Call__c = 0;
		ownerUserExt.Call_Report_for_Sales__c = 0;
		ownerUserExt.Call_Report_for_Relationship__c = 0;
	}

	private void clearConversionRatioFieldValue(User_Extension__c ownerUserExt){
		ownerUserExt.Call_Report_Product_Interested__c = 0;
		ownerUserExt.Product_Interested__c = 0;
		ownerUserExt.Product_Final_Approved__c = 0;
		ownerUserExt.Product_Set_Up__c = 0;
		ownerUserExt.Call_Report_Credit_for_Sales__c = 0;
		ownerUserExt.Call_Report_Credit_Product_Interested__c = 0;
		ownerUserExt.Credit_Product_Interested__c = 0;
		ownerUserExt.Total_Opportunity_App_In__c = 0;
		ownerUserExt.Total_Opportunity_Setup__c = 0;
		ownerUserExt.Total_Opportunity_Close_Lost__c = 0;
	}

	private Boolean isProductInterest(OpportunityLineItem eachOppLineItem){
        if(!setProductReasonInterest.contains('null')){
    		if(setProductResultInterest.contains(eachOppLineItem.Product_Results__c) && setProductReasonInterest.contains(eachOppLineItem.Reasons__c)){
    			return true;
    		}
        }else{
            if(setProductResultInterest.contains(eachOppLineItem.Product_Results__c)){
                return true;
            }
        }
		return false;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Event> callreportList) {
		Map<String,String> mapJobIdByCallRepId = new Map<String,String>();
		Set<String> setVisitObjectiveForSales = new Set<String>(Label.Performance_Conversion_Visit_Objective_For_Sales.split('\\|'));
		for(Event eachCallreport : callreportList) {
            if(userExtMapByUserId.containsKey(eachCallreport.OwnerId) && eachCallreport.Job__r.AccountId != null){
            	mapJobIdByCallRepId.put(eachCallreport.Id,eachCallreport.Job__c);
            	User_Extension__c ownerUserExt = userExtMapByUserId.get(eachCallreport.OwnerId);
                ownerUserExt.Call_Report__c++;
                if(eachCallreport.Job__r.Account.Port_Pool__c == GlobalConstants.PORT) {
                    ownerUserExt.Call_Report_Customer_Port__c++;
                } else if(eachCallreport.Job__r.Account.Port_Pool__c == GlobalConstants.POOL) {
                    ownerUserExt.Call_Report_Customer_Pool__c++;
                } else if(eachCallreport.Job__r.Account.Port_Pool__c == null){
                    ownerUserExt.Call_Report_Customer_Others__c++;
                }

                if(GlobalConstants.PROFILE_SME_SET.contains(ownerUserExt.User__r.Profile.Name)){
                    if(eachCallreport.Offer_Credit_Product__c || eachCallreport.Collect_Documents__c || eachCallreport.Negotiation__c || eachCallreport.Cross_Selling_Product__c){
                        ownerUserExt.Call_Report_for_Sales__c++;
                        if(eachCallreport.Offer_Credit_Product__c || eachCallreport.Collect_Documents__c || eachCallreport.Negotiation__c){
                            ownerUserExt.Call_Report_Credit_for_Sales__c++;
                        }
                    } else {
                        ownerUserExt.Call_Report_for_Relationship__c++;
                    }
                }

                if(GlobalConstants.PROFILE_RBS_SET.contains(ownerUserExt.User__r.Profile.Name)){
                    if(setVisitObjectiveForSales.contains(eachCallreport.Visit_Objective__c)){
                        ownerUserExt.Call_Report_for_Sales__c++;
                    }
                }
                
                if(eachCallReport.Contact_Channel__c != NULL && eachCallReport.Contact_Channel__c.equalsIgnoreCase(GlobalConstants.FACE_TO_FACE)) {
                    ownerUserExt.Face_to_Face__c++;
                } else if(eachCallReport.Contact_Channel__c != NULL && eachCallReport.Contact_Channel__c.equalsIgnoreCase(GlobalConstants.PHONE_CALL)){
                    ownerUserExt.Phone_Call__c++;
                }
            }
        }
        
        List<OpportunityLineItem> listOpportunityLineItem = [SELECT Id,Application__c ,OwnerExtension__c,Status_CBS__c,Status__c,Product_Results__c ,Reasons__c ,Report_Latest_Call_Report_ID__c,Product2Id FROM OpportunityLineItem WHERE Report_Latest_Call_Report_ID__c IN :mapJobIdByCallRepId.keySet()];
        Set<String> setIdCountedCall = new Set<String>();
        Set<String> setAppllicationId = new Set<String>();
    	for(OpportunityLineItem eachOppLineItem : listOpportunityLineItem){
    		if(!String.isBlank(eachOppLineItem.Application__c)) setAppllicationId.add(eachOppLineItem.Application__c);
    		if(!userExtMap.containsKey(eachOppLineItem.OwnerExtension__c)) continue;
    		User_Extension__c ownerUserExt = userExtMap.get(eachOppLineItem.OwnerExtension__c);
    		//countByCallReport
    		if(!setIdCountedCall.contains(eachOppLineItem.Report_Latest_Call_Report_ID__c)){
    			setIdCountedCall.add(eachOppLineItem.Report_Latest_Call_Report_ID__c);
    			if(isProductInterest(eachOppLineItem)){
    				ownerUserExt.Call_Report_Product_Interested__c++;
    				if(mapProduct2ById.containsKey(eachOppLineItem.Product2Id) && mapProduct2ById.get(eachOppLineItem.Product2Id).Product_Type__c == 'Credit') ownerUserExt.Call_Report_Credit_Product_Interested__c++;
    			}
    			
    		}

	        //countByOppProduct
	        if(eachOppLineItem.Status__c == GlobalConstants.FINAL_APPROVE) ownerUserExt.Product_Final_Approved__c++;
	        if(eachOppLineItem.Status__c == GlobalConstants.SETUP) ownerUserExt.Product_Set_Up__c++;
	        if(isProductInterest(eachOppLineItem)){
	        	ownerUserExt.Product_Interested__c++;
	        	if(mapProduct2ById.containsKey(eachOppLineItem.Product2Id) && mapProduct2ById.get(eachOppLineItem.Product2Id).Product_Type__c == 'Credit') ownerUserExt.Credit_Product_Interested__c++;
	        }
        }

        //countByApp(Opportunity)
        List<Application_History__c> listAppHis = [SELECT Id,AppInDate__c,App_Result__c,CreditSetupDate__c,Current_Owner_Extension__c FROM Application_History__c WHERE Report_Actual_Visit_Date__c = THIS_YEAR AND Id IN :setAppllicationId];
        for(Application_History__c eachApp : listAppHis){
        	if(!userExtMap.containsKey(eachApp.Current_Owner_Extension__c)) continue;
    		User_Extension__c ownerUserExt = userExtMap.get(eachApp.Current_Owner_Extension__c);
        	if(eachApp.AppInDate__c != null){
                if(eachApp.App_Result__c==GlobalConstants.WORK_IN_PROGRESS || eachApp.App_Result__c==GlobalConstants.CLOSED_WON){
                    ownerUserExt.Total_Opportunity_App_In__c++;
                    if(eachApp.CreditSetupDate__c != null) ownerUserExt.Total_Opportunity_Setup__c++;
                }
        		//if(eachApp.CreditSetupDate__c != null && (eachApp.App_Result__c==GlobalConstants.WORK_IN_PROGRESS || eachApp.App_Result__c==GlobalConstants.CLOSED_WON)){
        		//	ownerUserExt.Total_Opportunity_Setup__c++;
        		//}
        		//if(eachApp.App_Result__c == GlobalConstants.WORK_IN_PROGRESS){
        		//	ownerUserExt.Total_Opportunity_App_In__c++;
        		//}
        	}

        	if(eachApp.App_Result__c == GlobalConstants.CLOSE_LOST) ownerUserExt.Total_Opportunity_Close_Lost__c++;
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		update userExtMapByUserId.values();
        if(RUN_FOR_SME == runForSegment){
            Database.executeBatch(new CalculatePerformanceFromCallReport_Batch(null),200);
        }else{
            Database.executeBatch(new CustomerContactedPerformance_Batch(),20);
        }
	}
	
}