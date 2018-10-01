// Refactor From SME_Performance_All_Batch
global class CalculatePerformanceFromAccount_Batch implements Database.Batchable<sObject>, Database.Stateful {
	private Map<String, User_Extension__c> userExtMapByUserId;
	private Map<Id,Integer> mapCountRmUnderTeamByTeamId;
	private Set<String> userIds{get{return userExtMapByUserId.keySet();}}
	String query;
	
	global CalculatePerformanceFromAccount_Batch() {
		Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>([SELECT Id,Team_Structure__c,Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, Call_Report__c, Call_Report_Customer_Others__c, Call_Report_Customer_Pool__c, Call_Report_Customer_Port__c, Call_Report_for_Relationship__c, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Face_to_Face__c, Months__c, Phone_Call__c, User__c, User__r.ProfileId, User__r.Profile.Name, User__r.RC_Code__c, User__r.Employee_Id__c, User__r.ManagerId, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__r.IsActive = true AND User__r.SME_User__c = true]);
		mapCountRmUnderTeamByTeamId = new Map<Id,Integer>();
		userExtMapByUserId = new Map<String, User_Extension__c>();
        for(User_Extension__c eachExt : userExtMap.values()){
        	if(eachExt.User__c != null) {
        		userExtMapByUserId.put(eachExt.User__c, eachExt);
        		clearPerformanceFieldValue(eachExt);
        		countRmUnderTeamToMap(eachExt,mapCountRmUnderTeamByTeamId);
        	}
        }
		this.query = 'SELECT Lookup_Customer__r.Id,Lookup_Customer__r.CIS__c,Lookup_Customer__r.Port_Pool__c,Lookup_Customer__r.Ownership_Text__c,Lookup_Customer__r.OwnerId,Count_Contacted_CR_My_Pen_Service_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_F2F__c,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Lookup_Customer__r.Owner.ProfileId,Lookup_Customer__r.Owner.Profile.Name,Lookup_Customer__r.Service_RM__c,Lookup_Customer__r.Service_RM__r.RC_Code__c,Lookup_Customer__r.Service_RM__r.AH_RC_Code__c,Lookup_Customer__r.Service_RM__r.NH_RC_Code__c,Lookup_Customer__r.Service_RM__r.ProfileId,Lookup_Customer__r.Service_RM__r.Profile.Name,Lookup_Customer__r.Owner.RC_Code__c,Lookup_Customer__r.Number_of_Visited__c FROM Contacted_Account__c WHERE Lookup_Customer__r.OwnerId IN :userIds AND Lookup_Customer__r.Owner.isActive=true';
	}

	private void countRmUnderTeamToMap(User_Extension__c ownerUserExt,Map<Id,Integer> mapCountRmUnderTeamByTeamId){
		if(!String.isBlank(ownerUserExt.Team_Structure__c)){
			if(!mapCountRmUnderTeamByTeamId.containsKey(ownerUserExt.Team_Structure__c)){
				mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__c,0);
			}
			Integer tempCountTm = mapCountRmUnderTeamByTeamId.get(ownerUserExt.Team_Structure__c) +1;
			mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__c,tempCountTm);
		}
		if(!String.isBlank(ownerUserExt.Team_Structure__r.AH_Name__c)){
			if(!mapCountRmUnderTeamByTeamId.containsKey(ownerUserExt.Team_Structure__r.AH_Name__c)){
				mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__r.AH_Name__c,0);
			}
			Integer tempCountAh = mapCountRmUnderTeamByTeamId.get(ownerUserExt.Team_Structure__r.AH_Name__c) +1;
			mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__r.AH_Name__c,tempCountAh);
		}
		if(!String.isBlank(ownerUserExt.Team_Structure__r.NH_Name__c)){
			if(!mapCountRmUnderTeamByTeamId.containsKey(ownerUserExt.Team_Structure__r.NH_Name__c)){
				mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__r.NH_Name__c,0);
			}
			Integer tempCountNh = mapCountRmUnderTeamByTeamId.get(ownerUserExt.Team_Structure__r.NH_Name__c) +1;
			mapCountRmUnderTeamByTeamId.put(ownerUserExt.Team_Structure__r.NH_Name__c,tempCountNh);
		}
	}

	private void clearPerformanceFieldValue(User_Extension__c ownerUserExt){
		ownerUserExt.Number_of_RM_under_Team__c = 0;
		ownerUserExt.Contacted_Port_CustF2F__c = 0;
		ownerUserExt.Contacted_Port_CustCall__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Port_CustF2F__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Port_CustCall__c = 0;
		ownerUserExt.Contacted_Pool_CustF2F__c = 0;
		ownerUserExt.Contacted_Pool_CustCall__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
		ownerUserExt.Contacted_Customer_Pool_My_Penetrate__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Pool_CustCall__c = 0;
		ownerUserExt.Contacted_Other_CustF2F__c = 0;
		ownerUserExt.Contacted_Other_CustCall__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Other_CustF2F__c = 0;
		ownerUserExt.My_Penetrate_Contacted_Other_CustCall__c = 0;
		ownerUserExt.Total_visited_Customer__c = 0;
		ownerUserExt.Customer_Port__c = 0;
		ownerUserExt.Contacted_Customer_Port__c = 0;
		ownerUserExt.Contacted_Customer_Port_My_Penetrate__c = 0;
		ownerUserExt.Customer_Pool__c = 0;
		ownerUserExt.Contacted_Customer_Pool__c = 0;
		ownerUserExt.Customer_Other__c = 0;
		ownerUserExt.Contacted_Customer_Other__c = 0;
		ownerUserExt.Contacted_Customer_Other_My_Penetrate__c = 0;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contacted_Account__c> contactedAccountList) {
   		List<Id> listAccountId = new List<Id>();
   		for(Contacted_Account__c eachContactedAccount : contactedAccountList){
   			listAccountId.add(eachContactedAccount.Lookup_Customer__r.Id);
   		}

		List<String> queryRecordType = new List<String>(GlobalConstants.CALL_PLAN_CALL_REPORT_SME_DEVNAME_SET);
		List<Event> callReportList = [SELECT Id, WhatId, OwnerId, ActivityDate, Contact_Channel__c, Status__c, Job__r.AccountId, Job__r.Account.OwnerId, Job__r.Account.Service_RM__c FROM Event WHERE RecordType.DeveloperName IN :queryRecordType AND Job__r.AccountId IN :listAccountId AND ActivityDate = THIS_YEAR];
        
        Set<String> callReportKeyFromAccountAndOwner = new Set<String>();
        for(Event eachCallReport : callReportList){
            if(eachCallReport.Job__r.AccountId != null)
                callReportKeyFromAccountAndOwner.add(eachCallReport.Job__r.AccountId + '' + eachCallReport.OwnerId);
        }
        //PerformanceService.initialUserExtensionValue(userExtMapByUserId);

        for(Contacted_Account__c eachContactedAccount : contactedAccountList){
            User_Extension__c ownerUserExt 		= userExtMapByUserId.get(eachContactedAccount.Lookup_Customer__r.OwnerId);
	        User_Extension__c serviceRMUserExt  = userExtMapByUserId.get(eachContactedAccount.Lookup_Customer__r.Service_RM__c);

	        if(eachContactedAccount.Lookup_Customer__r.Port_Pool__c == GlobalConstants.PORT) {
	        	if(eachContactedAccount.Lookup_Customer__r.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT){
		            ownerUserExt.Customer_Port__c++;
		            if(eachContactedAccount.Count_Contacted_Call_Report__c > 0){
		                ownerUserExt.Contacted_Customer_Port__c++;
		                if(callReportKeyFromAccountAndOwner.contains(eachContactedAccount.Lookup_Customer__r.Id+''+eachContactedAccount.Lookup_Customer__r.OwnerId)){
		                    ownerUserExt.Contacted_Customer_Port_My_Penetrate__c++;
		                }
		            }
		        }

	            if(eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	                ownerUserExt.Contacted_Port_CustF2F__c++;
	            } else if(eachContactedAccount.Count_Contacted_Call_Report_Phone_Call__c > 0){
	                ownerUserExt.Contacted_Port_CustCall__c++;
	            }

	            if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
	                ownerUserExt.My_Penetrate_Contacted_Port_CustF2F__c++;
	            } else if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
	                ownerUserExt.My_Penetrate_Contacted_Port_CustCall__c++;
	            }
	        } else if(eachContactedAccount.Lookup_Customer__r.Port_Pool__c == GlobalConstants.POOL) {
	        	if((eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name == GlobalConstants.SME_TM || 
	        	eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name == GlobalConstants.SME_AH || 
	        	eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name == GlobalConstants.SME_NH || 
	        	(eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name == GlobalConstants.SME_RM && eachContactedAccount.Lookup_Customer__r.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY))) {
		            if(serviceRMUserExt != null && eachContactedAccount.Lookup_Customer__r.Service_RM__c != null && eachContactedAccount.Lookup_Customer__r.Service_RM__c!=eachContactedAccount.Lookup_Customer__r.OwnerId && eachContactedAccount.Lookup_Customer__r.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (eachContactedAccount.Lookup_Customer__r.Service_RM__r.RC_Code__c==eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_AH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.AH_RC_Code__c) || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_NH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.NH_RC_Code__c)) && eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name!=GlobalConstants.SME_RM){
		                serviceRMUserExt.Customer_Pool__c++;
		            } else {
		                ownerUserExt.Customer_Pool__c++;
		            }

		            if(eachContactedAccount.Count_Contacted_Call_Report__c > 0){
		                if(serviceRMUserExt != null && eachContactedAccount.Lookup_Customer__r.Service_RM__c != null && eachContactedAccount.Lookup_Customer__r.Service_RM__c!=eachContactedAccount.Lookup_Customer__r.OwnerId && eachContactedAccount.Lookup_Customer__r.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (eachContactedAccount.Lookup_Customer__r.Service_RM__r.RC_Code__c==eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_AH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.AH_RC_Code__c) || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_NH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.NH_RC_Code__c)) && eachContactedAccount.Count_Contacted_Call_Report__c > 0 && eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name!=GlobalConstants.SME_RM){
		                    serviceRMUserExt.Contacted_Customer_Pool__c++;
		                } else {
		                    ownerUserExt.Contacted_Customer_Pool__c++;
		                }
		            }
		        }
	            if(eachContactedAccount.Lookup_Customer__r.Service_RM__c != null) {
	                if(serviceRMUserExt != null && eachContactedAccount.Lookup_Customer__r.OwnerId != eachContactedAccount.Lookup_Customer__r.Service_RM__c && eachContactedAccount.Lookup_Customer__r.Service_RM__r.Profile.Name == GlobalConstants.SME_RM
	                    && (eachContactedAccount.Lookup_Customer__r.Service_RM__r.RC_Code__c==eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_AH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.AH_RC_Code__c) || (eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name==GlobalConstants.SME_NH && eachContactedAccount.Lookup_Customer__r.Owner.RC_Code__c == eachContactedAccount.Lookup_Customer__r.Service_RM__r.NH_RC_Code__c)) && eachContactedAccount.Lookup_Customer__r.Owner.Profile.Name!=GlobalConstants.SME_RM){
	                    if(eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	                        serviceRMUserExt.Contacted_Pool_CustF2F__c++;
	                    }else if(eachContactedAccount.Count_Contacted_Call_Report_Phone_Call__c > 0){
	                        serviceRMUserExt.Contacted_Pool_CustCall__c++;
	                    }

	                    if(eachContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c > 0){
	                        serviceRMUserExt.My_Penetrate_Contacted_Pool_CustF2F__c++;
	                        serviceRMUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                    }else if(eachContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c > 0){
	                        serviceRMUserExt.My_Penetrate_Contacted_Pool_CustCall__c++;
	                        serviceRMUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                    }
	                } else {
	                    if(eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	                        ownerUserExt.Contacted_Pool_CustF2F__c++;
	                    } else if(eachContactedAccount.Count_Contacted_Call_Report_Phone_Call__c > 0){
	                        ownerUserExt.Contacted_Pool_CustCall__c++;
	                    }

	                    if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
	                        ownerUserExt.My_Penetrate_Contacted_Pool_CustF2F__c++;
	                        ownerUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                    }else if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
	                        ownerUserExt.My_Penetrate_Contacted_Pool_CustCall__c++;
	                        ownerUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                    }
	                }
	            } else {
	                if(eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	                    ownerUserExt.Contacted_Pool_CustF2F__c++;
	                } else if(eachContactedAccount.Count_Contacted_Call_Report_Phone_Call__c > 0){
	                    ownerUserExt.Contacted_Pool_CustCall__c++;
	                }

	                if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
	                    ownerUserExt.My_Penetrate_Contacted_Pool_CustF2F__c++;
	                    ownerUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                } else if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
	                    ownerUserExt.My_Penetrate_Contacted_Pool_CustCall__c++;
	                    ownerUserExt.Contacted_Customer_Pool_My_Penetrate__c++;
	                }
	            }
	        } else if (eachContactedAccount.Lookup_Customer__r.Port_Pool__c == null || eachContactedAccount.Lookup_Customer__r.Port_Pool__c == '') {
	        	if(eachContactedAccount.Lookup_Customer__r.Port_Pool__c == null && ((eachContactedAccount.Lookup_Customer__r.Ownership_Text__c==null) || (eachContactedAccount.Lookup_Customer__r.Ownership_Text__c== GlobalConstants.OWNERSHIP_TEMPORARY))){
		            ownerUserExt.Customer_Other__c++;
		            if(eachContactedAccount.Count_Contacted_Call_Report__c > 0) {
		                ownerUserExt.Contacted_Customer_Other__c++;
		    
		                if(callReportKeyFromAccountAndOwner.contains(eachContactedAccount.Lookup_Customer__r.Id+''+eachContactedAccount.Lookup_Customer__r.OwnerId)) {
		                    ownerUserExt.Contacted_Customer_Other_My_Penetrate__c++;
		                }
		            }
		        }

	            if(eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	                ownerUserExt.Contacted_Other_CustF2F__c++;
	    
	            } else if(eachContactedAccount.Count_Contacted_Call_Report_Phone_Call__c > 0) {
	                ownerUserExt.Contacted_Other_CustCall__c++;
	            }

	            if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
	                ownerUserExt.My_Penetrate_Contacted_Other_CustF2F__c++;
	    
	            } else if(eachContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c > 0) {
	                ownerUserExt.My_Penetrate_Contacted_Other_CustCall__c++;
	            }
	        }

	        if(eachContactedAccount.Count_Contacted_Call_Report__c > 0 && eachContactedAccount.Count_Contacted_Call_Report_F2F__c > 0){
	            ownerUserExt.Total_visited_Customer__c++;
	        }
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		for(User_Extension__c eachExtension : userExtMapByUserId.values()){
			if((eachExtension.User__r.Profile.Name == GlobalConstants.SME_RM || eachExtension.User__r.Profile.Name == GlobalConstants.SME_TM) && !String.isBlank(eachExtension.Team_Structure__c) && mapCountRmUnderTeamByTeamId.containsKey(eachExtension.Team_Structure__c)){
				eachExtension.Number_of_RM_under_Team__c = mapCountRmUnderTeamByTeamId.get(eachExtension.Team_Structure__c);
			}else if(eachExtension.User__r.Profile.Name == GlobalConstants.SME_AH && !String.isBlank(eachExtension.Team_Structure__r.AH_Name__c) && mapCountRmUnderTeamByTeamId.containsKey(eachExtension.Team_Structure__r.AH_Name__c)){
				eachExtension.Number_of_RM_under_Team__c = mapCountRmUnderTeamByTeamId.get(eachExtension.Team_Structure__r.AH_Name__c);
			}else if(eachExtension.User__r.Profile.Name == GlobalConstants.SME_NH && !String.isBlank(eachExtension.Team_Structure__r.NH_Name__c) && mapCountRmUnderTeamByTeamId.containsKey(eachExtension.Team_Structure__r.NH_Name__c)){
				eachExtension.Number_of_RM_under_Team__c = mapCountRmUnderTeamByTeamId.get(eachExtension.Team_Structure__r.NH_Name__c);
			}
		}

		TriggerHandler.bypass('UserExtensionTriggerHandler');
		update userExtMapByUserId.values();
		TriggerHandler.clearBypass('UserExtensionTriggerHandler');

		Database.executeBatch(new CalculatePerformanceFromCallReport_Batch(CalculatePerformanceFromCallReport_Batch.RUN_FOR_SME));
	}
}