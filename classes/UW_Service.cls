/**
* @author chutiwat.s@beryl8.com
* @08/02/2016 create
* @10/02/2016 update key for allUWBuMapByRC (key = Business_Code__c + '-' + RC_Code__c)
*/
public with sharing class UW_Service {
	public Map<String, UW_Business_Area__c> allUWBuMapByRC;
	public Map<String, UW_Area__c> allUWMapByRC;
	private static UW_Service instance = null;
    public static Map<String, Business_Code__c> buCodeMapByExternal;
    public static Map<Id, Business_Code__c> buCodeMap;
    public static Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById;
    public static List<String> segmentUWAssignments;

	public UW_Service() {
		List<UW_Business_Area__c> allUWBU = new List<UW_Business_Area__c>([SELECT Id, External_ID__c, RC_Code__c, Business_Code__c, Head_of_UW_Name__c, Senior_UW_Name__c FROM UW_Business_Area__c]);
		allUWBuMapByRC = new Map<String, UW_Business_Area__c>();
		for(UW_Business_Area__c eachUWBU : allUWBU) {
			//allUWBuMapByRC.put(eachUWBU.RC_Code__c +'-'+ eachUWBU.Business_Code__c, eachUWBU);
            allUWBuMapByRC.put(eachUWBU.External_ID__c, eachUWBU);
		}

		List<UW_Area__c> allUW = new List<UW_Area__c>([SELECT Id, RC_Code__c, Head_of_UW_Name__c, Senior_UW_Name__c FROM UW_Area__c]);
		allUWMapByRC = new Map<String, UW_Area__c>();
		for(UW_Area__c eachUW : allUW) {
			allUWMapByRC.put(eachUW.RC_Code__c, eachUW);
		}

        if(Segment_UW_Assignment__c.getall().values() != null) {
            segmentUWAssignments = new List<String>();
            for (Segment_UW_Assignment__c eachSegment : Segment_UW_Assignment__c.getall().values()) {
                segmentUWAssignments.add(eachSegment.Name);
            }
        }    
	}

    public static Map<String, Business_Code__c> getBUCodeMapByExternal() {
        if(buCodeMapByExternal == null) {
            buCodeMapByExternal = new Map<String, Business_Code__c>();
            buCodeMap = new Map<Id, Business_Code__c>([SELECT Id, Name FROM Business_Code__c]);
            for(Business_Code__c eachBU : buCodeMap.values()) {
                buCodeMapByExternal.put(eachBU.Name, eachBU);
            }
        }
        
        return buCodeMapByExternal;
    }

     public static Map<String, Business_Code__c> getBUCodeMapByExternal(Set<String> businessCodeIdSet,Set<String> businessCodeNameSet,Set<String> customerBusinessCodeIdSet) {
        if(buCodeMapByExternal == null) {
            buCodeMapByExternal = new Map<String, Business_Code__c>();
                if(businessCodeIdSet != null){
                    buCodeMap = new Map<Id, Business_Code__c>([SELECT Id, Name FROM Business_Code__c WHERE Id IN:businessCodeIdSet OR Name IN:businessCodeNameSet]);
                }
                if(customerBusinessCodeIdSet != null){
                    customerBusinessCodeMapById = new Map<Id, Customer_Business_Code__c>([SELECT Id,Business_Code__c,Business_Code__r.Name From Customer_Business_Code__c WHERE Id In:customerBusinessCodeIdSet]);
                    businessCodeIdSet = new Set<String>();
                    for(Customer_Business_Code__c eachCustomerBusinessCode : customerBusinessCodeMapById.values()){
                        businessCodeIdSet.add(eachCustomerBusinessCode.Business_Code__c);
                    }

                    buCodeMap = new Map<Id, Business_Code__c>([SELECT Id, Name FROM Business_Code__c WHERE Id IN:businessCodeIdSet OR Name IN:businessCodeNameSet]);
                }
            
            for(Business_Code__c eachBU : buCodeMap.values()) {
                buCodeMapByExternal.put(eachBU.Name, eachBU);
            }
        }
        
        return buCodeMapByExternal;
    }
    
	public static UW_Service getInstance() {
		if(instance == null) instance = new UW_Service();
		return instance;
	}

    public static void updateOppUW(Map<Id, Call_Report__c> callRepMapByOpp) {
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity eachOpp;
        for(Id eachOppId : callRepMapByOpp.keySet()) {
            eachOpp = new Opportunity(
                Id = eachOppId,
                Head_of_UW_Name__c = callRepMapByOpp.get(eachOppId).Head_of_UW_Name__c,
                Senior_UW_Name__c = callRepMapByOpp.get(eachOppId).Senior_UW_Name__c
            );
            oppList.add(eachOpp);
        }

        update oppList;
    }

	public static void setUW(List<Call_Report__c> callReportList) {
		Set<String> businessCodeNameSet = new Set<String>();
        Set<String> customerBusinessCodeIdSet = new Set<String>();
		Map<Id, Call_Report__c> callRepMapByAccId = new Map<Id, Call_Report__c>();

		for(Call_Report__c eachCallReport : callReportList){
        	callRepMapByAccId.put(eachCallReport.CIS_ID__c, eachCallReport);
            if(eachCallReport.Customer_Business_Code__c != null){
                customerBusinessCodeIdSet.add(eachCallReport.Customer_Business_Code__c);
            }
        }

		UW_Service uwService = getInstance();
        //getBUCodeMapByExternal();

        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Customer_s_Business_Code__c FROM Account WHERE Id IN :callRepMapByAccId.keySet() AND Owner.Segment__c IN :segmentUWAssignments];
        for(Account eachAcc : accountList) {
            if(eachAcc.Customer_s_Business_Code__c != null){
                businessCodeNameSet.add(eachAcc.Customer_s_Business_Code__c);
            }
        }

        getBUCodeMapByExternal(null,businessCodeNameSet,customerBusinessCodeIdSet);

        Call_Report__c tempCallReport;
        Id tempHeadUW = null;
        Id tempSeniorUW = null;
        String tempBUCode = '';
        Boolean isUpdateUW;

        for(Account eachAcc : accountList) {
            isUpdateUW = true;
            //if(callRepMapByAccId.get(eachAcc.Id).Business_Code__c != null) {
            //    if(buCodeMap.containsKey(callRepMapByAccId.get(eachAcc.Id).Business_Code__c))
            //        tempBUCode = buCodeMap.get(callRepMapByAccId.get(eachAcc.Id).Business_Code__c).Name;
            //} else if(eachAcc.Customer_s_Business_Code__c != null && buCodeMapByExternal.containsKey(eachAcc.Customer_s_Business_Code__c)) {
            //    tempBUCode = buCodeMapByExternal.get(eachAcc.Customer_s_Business_Code__c).Name;
            //}

            if(callRepMapByAccId.get(eachAcc.Id).Customer_Business_Code__c != null) {
                if(customerBusinessCodeMapById != null && customerBusinessCodeMapById.containsKey(callRepMapByAccId.get(eachAcc.Id).Customer_Business_Code__c))
                    tempBUCode = customerBusinessCodeMapById.get(callRepMapByAccId.get(eachAcc.Id).Customer_Business_Code__c).Business_Code__r.Name;
            } else if(eachAcc.Customer_s_Business_Code__c != null && buCodeMapByExternal.containsKey(eachAcc.Customer_s_Business_Code__c)) {
                tempBUCode = buCodeMapByExternal.get(eachAcc.Customer_s_Business_Code__c).Name;
            }
            
            //First Priority
            if(uwService.allUWBuMapByRC.containsKey(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode).Senior_UW_Name__c;
            } else if(uwService.allUWBuMapByRC.containsKey(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode).Senior_UW_Name__c;
            } else if (uwService.allUWBuMapByRC.containsKey(System.Label.Apply_All_Area + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(System.Label.Apply_All_Area + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(System.Label.Apply_All_Area + '-' + tempBUCode).Senior_UW_Name__c;
            } // Second Priority
            else if(uwService.allUWMapByRC.containsKey(eachAcc.Owner.AH_RC_Code__c)) {
                tempHeadUW = uwService.allUWMapByRC.get(eachAcc.Owner.AH_RC_Code__c).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWMapByRC.get(eachAcc.Owner.AH_RC_Code__c).Senior_UW_Name__c;
            } else if(uwService.allUWMapByRC.containsKey(eachAcc.Owner.NH_RC_Code__c)) {
                tempHeadUW = uwService.allUWMapByRC.get(eachAcc.Owner.NH_RC_Code__c).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWMapByRC.get(eachAcc.Owner.NH_RC_Code__c).Senior_UW_Name__c;
            } else {
                isUpdateUW = false;
            }

            if(isUpdateUW) {
                if(callRepMapByAccId.get(eachAcc.Id).Business_Code__c == null && buCodeMapByExternal.containsKey(tempBUCode))
                    callRepMapByAccId.get(eachAcc.Id).Business_Code__c = buCodeMapByExternal.get(tempBUCode).Id;
                callRepMapByAccId.get(eachAcc.Id).Head_of_UW_Name__c = tempHeadUW;
                callRepMapByAccId.get(eachAcc.Id).Senior_UW_Name__c = tempSeniorUW;    
            }
        }

	}

	public static void setUW(List<Opportunity> oppList) {
		Set<String> businessCodeNameSet = new Set<String>();
        Set<String> businessCodeIdSet = new Set<String>();

		Map<Id, Opportunity> oppMapByAccId = new Map<Id, Opportunity>();

		for(Opportunity eachOpp : oppList){
        	oppMapByAccId.put(eachOpp.AccountId, eachOpp);
            if(eachOpp.Business_Code__c != null){
                businessCodeIdSet.add(eachOpp.Business_Code__c);
            }
        }

		UW_Service uwService = getInstance();

        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Customer_s_Business_Code__c FROM Account WHERE Id IN :oppMapByAccId.keySet() AND Owner.Segment__c IN :segmentUWAssignments];
        for(Account eachAcc : accountList) {
            if(eachAcc.Customer_s_Business_Code__c != null){
                businessCodeNameSet.add(eachAcc.Customer_s_Business_Code__c);
            }
        }
        getBUCodeMapByExternal(businessCodeIdSet,businessCodeNameSet,null);

        Call_Report__c tempCallReport;
        Id tempHeadUW = null;
        Id tempSeniorUW = null;
        String tempBUCode = '';
        Boolean isUpdateUW;

        for(Account eachAcc : accountList) {
            isUpdateUW = true;
            if(oppMapByAccId.get(eachAcc.Id).Business_Code__c != null) {
                if(buCodeMap.containsKey(oppMapByAccId.get(eachAcc.Id).Business_Code__c))         
                    tempBUCode = buCodeMap.get(oppMapByAccId.get(eachAcc.Id).Business_Code__c).Name;
            } else if(eachAcc.Customer_s_Business_Code__c != null && buCodeMapByExternal.containsKey(eachAcc.Customer_s_Business_Code__c)) {
                tempBUCode = buCodeMapByExternal.get(eachAcc.Customer_s_Business_Code__c).Name;
            }

            //First Priority
            if(uwService.allUWBuMapByRC.containsKey(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.AH_RC_Code__c + '-' + tempBUCode).Senior_UW_Name__c;
            } else if(uwService.allUWBuMapByRC.containsKey(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(eachAcc.Owner.NH_RC_Code__c + '-' + tempBUCode).Senior_UW_Name__c;
            } else if (uwService.allUWBuMapByRC.containsKey(System.Label.Apply_All_Area + '-' + tempBUCode)) {
                tempHeadUW = uwService.allUWBuMapByRC.get(System.Label.Apply_All_Area + '-' + tempBUCode).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWBuMapByRC.get(System.Label.Apply_All_Area + '-' + tempBUCode).Senior_UW_Name__c;
            } // Second Priority
            else if(uwService.allUWMapByRC.containsKey(eachAcc.Owner.AH_RC_Code__c)) {
                tempHeadUW = uwService.allUWMapByRC.get(eachAcc.Owner.AH_RC_Code__c).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWMapByRC.get(eachAcc.Owner.AH_RC_Code__c).Senior_UW_Name__c;
            } else if(uwService.allUWMapByRC.containsKey(eachAcc.Owner.NH_RC_Code__c)) {
                tempHeadUW = uwService.allUWMapByRC.get(eachAcc.Owner.NH_RC_Code__c).Head_of_UW_Name__c;
                tempSeniorUW = uwService.allUWMapByRC.get(eachAcc.Owner.NH_RC_Code__c).Senior_UW_Name__c;
            } else {
                isUpdateUW = false;
            }

            if(isUpdateUW) {
                if(oppMapByAccId.get(eachAcc.Id).Business_Code__c == null && buCodeMapByExternal.containsKey(tempBUCode))
                    oppMapByAccId.get(eachAcc.Id).Business_Code__c = buCodeMapByExternal.get(tempBUCode).Id;
                oppMapByAccId.get(eachAcc.Id).Head_of_UW_Name__c = tempHeadUW;
                oppMapByAccId.get(eachAcc.Id).Senior_UW_Name__c = tempSeniorUW;    
            }
        }

	}

}