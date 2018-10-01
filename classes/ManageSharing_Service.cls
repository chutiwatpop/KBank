public without sharing class ManageSharing_Service {
	public static List<Opportunity> listAllOpportunityByAccountAndOwner;
	private static List<Opportunity> listOpenOpportunityByAccountAndOwner;
	private static List<Opportunity> listOpenOpportunityByAccount;
	private static List<Call_Report__c> listOpenCallPlanCallReportByAccount;
	public static List<Call_Report__c> listAllCallPlanCallReportByAccountAndOwner;
	private static List<Call_Report__c> listOpenCallPlanCallReportByAccountAndOwner;
	public static Set<String> setClosedOpportunityStatus = new Set<String>{GlobalConstants.ALL_LOAN_SETUP,GlobalConstants.CLOSE_LOST,GlobalConstants.AUTO_CLOSED,GlobalConstants.DELETED_OPPORTUNITY};
	public static Set<String> setOpenCallPlanStatus = new Set<String>{GlobalConstants.PLAN};
	private static Map<Id,Date> mapMaxLeadSharingExpireByAccountId = new Map<Id,Date>();

	public static void calculateCreateAccountShareFromGoodToBad(List<Target_List__c> listTargetList){
		List<AccountShare> listNewAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		listNewAccountShare.addAll(createAccountShareFromTargetList(listTargetList));

		if(!listNewAccountShare.isEmpty()){			
			insert listNewAccountShare;

			listUpdateAccountSharingInfo = getListUpdateShareInfoInAccount(listNewAccountShare);
			
			if(!listUpdateAccountSharingInfo.isEmpty()){
				TriggerHandler.bypass('AccountTriggerHandler');
				update listUpdateAccountSharingInfo;
				TriggerHandler.clearbypass('AccountTriggerHandler');
			}

			for(Target_List__c eachTargetList : listTargetList){
				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}
			listUpdateTargetListSharingInfo = getListUpdateShareInfoInTargetList(listNewAccountShare,mapListTargetListMapByAccountId);

			if(!listUpdateTargetListSharingInfo.isEmpty()){
				TriggerHandler.bypass('TargetListTriggerHandler');
				update listUpdateTargetListSharingInfo;
				TriggerHandler.clearbypass('TargetListTriggerHandler');
			}
		}
	}

	public static void calculateCreateAccountShareFromOldBadToNewBad(List<Target_List__c> listNewTargetList,Map<Id,Target_List__c> mapOldTargetList){
		Set<String> setAccountId = new Set<String>();
		Set<String> setOldSharedUserId = new Set<String>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listNewTargetListChangeShareWith = new List<Target_List__c>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<Id,Id> mapNewOwnerIdMapByAccountId = new Map<Id,Id>();
		Map<Id,Target_List__c> mapTargetListMapByOldShareWith = new Map<Id,Target_List__c>();
		Map<Id,Target_List__c> mapOldTargetListChangeShareWithMapById = new Map<Id,Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Boolean isCheckExpireDate = false;
		Boolean isCheckOpenCallPlanCallReport = false;
		Boolean isCheckOpenOpportunity = false;
		Boolean isDeleteTargetList = false;
		Boolean isChangeBad = true;
		Boolean isLeadExpired = false;
		Boolean isTargetlistChangeBad = false;

		for(Target_List__c eachTargetList : listNewTargetList){
			Target_List__c oldTargetList = mapOldTargetList.get(eachTargetList.Id);
			if(eachTargetList.Share_With__c != oldTargetList.Share_With__c){
				isTargetlistChangeBad = true;
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				setOldSharedUserId.add(oldTargetList.Share_With__c);
				mapTargetListMapByOldShareWith.put(oldTargetList.Share_With__c, oldTargetList);
				mapOldTargetListChangeShareWithMapById.put(oldTargetList.Id, oldTargetList);
				mapNewOwnerIdMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
				listNewTargetListChangeShareWith.add(eachTargetList);

				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}
		}

		if(isTargetlistChangeBad){
			List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();
			List<Opportunity> listUpdateOpportunityToClosed = new List<Opportunity>();

			listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setOldSharedUserId,GlobalConstants.CLOSED));
			listUpdateOpportunityToClosed.addAll(getListChangeOpenOpportunityToSpecificStageName(setAccountId,setOldSharedUserId,mapTargetListMapByOldShareWith,GlobalConstants.AUTO_CLOSED));

			if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
				update listUpdateCallPlanCallReportToClosed;
			}

			if(!listUpdateOpportunityToClosed.isEmpty()){
				update listUpdateOpportunityToClosed;
			}

			List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
			listDeleteAccountShare.addAll(getListDeleteAccountSharesFromTargetList(mapOldTargetListChangeShareWithMapById.values(),isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity,isDeleteTargetList,isChangeBad,isLeadExpired));

			if(!listDeleteAccountShare.isEmpty()){
				delete listDeleteAccountShare;
			}

			List<AccountShare> listNewAccountShare = new List<AccountShare>();
			listNewAccountShare.addAll(createAccountShareFromTargetList(listNewTargetListChangeShareWith,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity));

			if(!listNewAccountShare.isEmpty()){
				insert listNewAccountShare;

				listUpdateAccountSharingInfo = getListUpdateShareInfoInAccount(listNewAccountShare);
				if(!listUpdateAccountSharingInfo.isEmpty()){
					TriggerHandler.bypass('AccountTriggerHandler');
					update listUpdateAccountSharingInfo;
					TriggerHandler.clearbypass('AccountTriggerHandler');

					List<Contact> listContactChangedOwner = getListChangeContactOwner(listUpdateAccountSharingInfo,setOldSharedUserId,isDeleteTargetList);
					update listContactChangedOwner;
				}

				listUpdateTargetListSharingInfo = getListUpdateShareInfoInTargetList(listNewAccountShare,mapListTargetListMapByAccountId);

				if(!listUpdateTargetListSharingInfo.isEmpty()){
					TriggerHandler.bypass('TargetListTriggerHandler');
					update listUpdateTargetListSharingInfo;
					TriggerHandler.clearbypass('TargetListTriggerHandler');
				}
			}
		}
	}

	public static void calculateTargetListExpiredThenDeleteSharing(Set<Id> setAccountId){
		List<Target_List__c> listTargetListId = [SELECT Id FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :setAccountId];
		calculateTargetListExpiredThenDeleteSharing(listTargetListId);
	}

	public static void calculateTargetListExpiredThenDeleteSharing(List<Target_List__c> listTargetList){
		Set<String> setAccountId = new Set<String>();
		Set<String> setOldSharedUserId = new Set<String>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listTargetListWithInfo = new List<Target_List__c>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<Id,Target_List__c> mapTargetListMapByOldShareWith = new Map<Id,Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Boolean isCheckExpireDate = false;
		Boolean isCheckOpenCallPlanCallReport = true;
		Boolean isCheckOpenOpportunity = true;
		Boolean isDeleteTargetList = false;
		Boolean isChangeBad = false;
		Boolean isLeadExpired = true;
		Boolean changeContactOwnerToAccountOwner = true;

		listTargetListWithInfo = [SELECT Id,Sharing_Status__c,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN :listTargetList];
		for(Target_List__c eachTargetList : listTargetListWithInfo){
			if(eachTargetList.Sharing_Status__c == GlobalConstants.SHARING_WITH_AN){
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				setOldSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
				mapTargetListMapByOldShareWith.put(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c, eachTargetList);
				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}
		}

		List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();
		List<Opportunity> listUpdateOpportunityToClosed = new List<Opportunity>();

		listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setOldSharedUserId,GlobalConstants.CLOSED));
		listUpdateOpportunityToClosed.addAll(getListChangeOpenOpportunityToSpecificStageName(setAccountId,setOldSharedUserId,mapTargetListMapByOldShareWith,GlobalConstants.AUTO_CLOSED));
	
        //INC000000663998
		if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
			update listUpdateCallPlanCallReportToClosed;
		}
		
        //INC000000663998
		if(!listUpdateOpportunityToClosed.isEmpty()){
			update listUpdateOpportunityToClosed;
		}

		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		listDeleteAccountShare.addAll(getListDeleteAccountSharesFromTargetList(listTargetListWithInfo,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity,isDeleteTargetList,isChangeBad,isLeadExpired));

		if(!listDeleteAccountShare.isEmpty()){
			delete listDeleteAccountShare;

			listUpdateAccountSharingInfo = getListUpdateStopShareInfoInAccount(listDeleteAccountShare);

			if(!listUpdateAccountSharingInfo.isEmpty()){
				TriggerHandler.bypass('AccountTriggerHandler');
				update listUpdateAccountSharingInfo;
				TriggerHandler.clearbypass('AccountTriggerHandler');

				List<Contact> listContactChangedOwner = getListChangeContactOwner(listUpdateAccountSharingInfo,setOldSharedUserId,changeContactOwnerToAccountOwner);
				update listContactChangedOwner;
			}

			listUpdateTargetListSharingInfo = getListUpdateStopShareInfoInTargetListCheckExpired(listDeleteAccountShare,mapListTargetListMapByAccountId);
			if(!listUpdateTargetListSharingInfo.isEmpty()){
				TriggerHandler.bypass('TargetListTriggerHandler');
				update listUpdateTargetListSharingInfo;
				TriggerHandler.clearbypass('TargetListTriggerHandler');
			}
		}
	}

	public static void calculateDeleteTargetListThenDeleteSharing(List<Target_List__c> listOldTargetList){
		Set<String> setAccountId = new Set<String>();
		Set<String> setOldSharedUserId = new Set<String>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listOldTargetListWithInfo = new List<Target_List__c>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<Id,Target_List__c> mapTargetListMapByOldShareWith = new Map<Id,Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Boolean isCheckExpireDate = false;
		Boolean isCheckOpenCallPlanCallReport = false;
		Boolean isCheckOpenOpportunity = false;
		Boolean isDeleteTargetList = true;
		Boolean isChangeBad = false;
		Boolean isLeadExpired = false;

		listOldTargetListWithInfo = [SELECT Id,Sharing_Status__c,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN :listOldTargetList];
		for(Target_List__c eachTargetList : listOldTargetListWithInfo){
			if(eachTargetList.Sharing_Status__c == GlobalConstants.SHARING_WITH_AN){
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				setOldSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
				mapTargetListMapByOldShareWith.put(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c, eachTargetList);
				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}
		}

		List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();
		List<Opportunity> listUpdateOpportunityToClosed = new List<Opportunity>();

		listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setOldSharedUserId,GlobalConstants.CLOSED));
		listUpdateOpportunityToClosed.addAll(getListChangeOpenOpportunityToSpecificStageName(setAccountId,setOldSharedUserId,mapTargetListMapByOldShareWith,GlobalConstants.AUTO_CLOSED));

		if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
			update listUpdateCallPlanCallReportToClosed;
		}

		if(!listUpdateOpportunityToClosed.isEmpty()){
			update listUpdateOpportunityToClosed;
		}

		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		listDeleteAccountShare.addAll(getListDeleteAccountSharesFromTargetList(listOldTargetListWithInfo,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity,isDeleteTargetList,isChangeBad,isLeadExpired));

		if(!listDeleteAccountShare.isEmpty()){
			delete listDeleteAccountShare;

			listUpdateAccountSharingInfo = getListUpdateStopShareInfoInAccount(listDeleteAccountShare);

			if(!listUpdateAccountSharingInfo.isEmpty()){
				TriggerHandler.bypass('AccountTriggerHandler');
				update listUpdateAccountSharingInfo;
				TriggerHandler.clearbypass('AccountTriggerHandler');

				List<Contact> listContactChangedOwner = getListChangeContactOwner(listUpdateAccountSharingInfo,setOldSharedUserId,isDeleteTargetList);
				update listContactChangedOwner;
			}
		}

		Map<Id,Account> mapAccountById = new Map<Id,Account>([SELECT Id, Lead_Sharing_Expired_Date__c, (SELECT Id, Lead_Campaign__r.EndDate FROM Campaign_Members_Leads__r WHERE Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND Id NOT IN :listOldTargetListWithInfo AND Lead_Campaign__r.IsActive = true ORDER BY Lead_Campaign__r.EndDate DESC LIMIT 1) FROM Account WHERE Id IN :setAccountId]);
		List<Account> listAccountUpdateMaxExpDate = new List<Account>();
		for(Account eachUpdateAccountSharingInfo : mapAccountById.values()){
			Account accountForCheckMaxExpDate = mapAccountById.get(eachUpdateAccountSharingInfo.Id);
			if(accountForCheckMaxExpDate != null){
				if(accountForCheckMaxExpDate.Campaign_Members_Leads__r != null && accountForCheckMaxExpDate.Campaign_Members_Leads__r.size() > 0){
					eachUpdateAccountSharingInfo.Lead_Sharing_Expired_Date__c = accountForCheckMaxExpDate.Campaign_Members_Leads__r[0].Lead_Campaign__r.EndDate;
					listAccountUpdateMaxExpDate.add(eachUpdateAccountSharingInfo);
				}
			}
		}

		if(!listAccountUpdateMaxExpDate.isEmpty()){
			TriggerHandler.bypass('AccountTriggerHandler');
			update listAccountUpdateMaxExpDate;
			TriggerHandler.clearbypass('AccountTriggerHandler');
		}
	}

	public static void updateCampaignInfoThenUpdateAccountInfo(Map<Id,Campaign> mapUpdateCampaignInfo){
		Boolean isUpdate = true;
		Database.executeBatch(new SME_BatchCreateLeadSharing(mapUpdateCampaignInfo,isUpdate));
	}

	public static void updateAccountInfoFromCampaignInfo(List<Target_List__c> listTargetListWithInfo,Map<Id,Campaign> mapUpdateCampaignInfo){
		Set<Id> setAccountId = new Set<Id>();
        Map<Id,Account> mapUpdateAccount = new Map<Id,Account>();
		for(Target_List__c eachTargetList : listTargetListWithInfo){
			setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
		}

		Map<Id,Account> mapAccountById = new Map<Id,Account>([SELECT Id, Lead_Sharing_Expired_Date__c, (SELECT Id, Lead_Campaign__r.EndDate FROM Campaign_Members_Leads__r WHERE Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND Lead_Campaign__r.IsActive = true ORDER BY Lead_Campaign__r.EndDate DESC LIMIT 1) FROM Account WHERE Id IN :setAccountId]);
		
		for(Target_List__c eachTargetList : listTargetListWithInfo){
			Account accountOfTargetList = mapAccountById.get(eachTargetList.CIS_ID_Prospect_Name__c);
			
			if(accountOfTargetList.Lead_Sharing_Expired_Date__c == null){
				accountOfTargetList.Lead_Sharing_Expired_Date__c = mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate;
                if(!mapUpdateAccount.containsKey(accountOfTargetList.Id)){
                    mapUpdateAccount.put(accountOfTargetList.Id, accountOfTargetList);
                }
			}else if(mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate > accountOfTargetList.Lead_Sharing_Expired_Date__c){
				accountOfTargetList.Lead_Sharing_Expired_Date__c = mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate;
                if(!mapUpdateAccount.containsKey(accountOfTargetList.Id)){
                    mapUpdateAccount.put(accountOfTargetList.Id, accountOfTargetList);
                }
			}else if(accountOfTargetList.Campaign_Members_Leads__r != null && accountOfTargetList.Campaign_Members_Leads__r.size() > 0){
				if(mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate > accountOfTargetList.Campaign_Members_Leads__r[0].Lead_Campaign__r.EndDate){
					accountOfTargetList.Lead_Sharing_Expired_Date__c = mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate;
                    if(!mapUpdateAccount.containsKey(accountOfTargetList.Id)){
                        mapUpdateAccount.put(accountOfTargetList.Id, accountOfTargetList);
                    }
				}else{
					accountOfTargetList.Lead_Sharing_Expired_Date__c = accountOfTargetList.Campaign_Members_Leads__r[0].Lead_Campaign__r.EndDate;
                    if(!mapUpdateAccount.containsKey(accountOfTargetList.Id)){
                        mapUpdateAccount.put(accountOfTargetList.Id, accountOfTargetList);
                    }
				}
			}else if(accountOfTargetList.Campaign_Members_Leads__r == null || accountOfTargetList.Campaign_Members_Leads__r.size() == 0){
				accountOfTargetList.Lead_Sharing_Expired_Date__c = mapUpdateCampaignInfo.get(eachTargetList.Lead_Campaign__c).EndDate;
				if(!mapUpdateAccount.containsKey(accountOfTargetList.Id)){
                	mapUpdateAccount.put(accountOfTargetList.Id, accountOfTargetList);
                }
			}
		}

		TriggerHandler.bypass('AccountTriggerHandler');
		update mapUpdateAccount.values();
		TriggerHandler.clearbypass('AccountTriggerHandler');

	}

	public static void createAccountShareFromActiveCampaign(List<Id> listActiveCampaign){
		Boolean isUpdate = false;
		Database.executeBatch(new SME_BatchCreateLeadSharing(listActiveCampaign,isUpdate));
	}
	
	public static void createAccountShareFromActiveCampaign(List<Target_List__c> listTargetListWithInfo){
		List<AccountShare> listNewAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();

		listNewAccountShare.addAll(createAccountShareFromTargetListWithInfo(listTargetListWithInfo));

		if(!listNewAccountShare.isEmpty()){
			insert listNewAccountShare;

			listUpdateAccountSharingInfo = getListUpdateShareInfoInAccount(listNewAccountShare);
			if(!listUpdateAccountSharingInfo.isEmpty()){
				TriggerHandler.bypass('AccountTriggerHandler');
				update listUpdateAccountSharingInfo;
				TriggerHandler.clearbypass('AccountTriggerHandler');
			}

			for(Target_List__c eachTargetList : listTargetListWithInfo){
				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}
			listUpdateTargetListSharingInfo = getListUpdateShareInfoInTargetList(listNewAccountShare,mapListTargetListMapByAccountId);
			if(!listUpdateTargetListSharingInfo.isEmpty()){
				TriggerHandler.bypass('TargetListTriggerHandler');
				update listUpdateTargetListSharingInfo;
				TriggerHandler.clearbypass('TargetListTriggerHandler');
			}
		}
	}

	public static void createAccountShareWhenAccountOwnerChange(List<Account> listAccount){
		List<AccountShare> listNewAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();

		listNewAccountShare = createAccountShare(listAccount);

		if(!listNewAccountShare.isEmpty()){
			insert listNewAccountShare;
		}
	}

	public static void updateCallPlanCallReportThenCheckStopSharingCondition(List<Call_Report__c> listUpdateCallPLanCallReport){
		Set<String> setAccountId = new Set<String>();
		List<Target_List__c> listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN (SELECT Target_List__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c IN :listUpdateCallPLanCallReport) AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c < :System.today()];
		if(listTargetListWithInfo.isEmpty()){
			for(Call_Report__c eachCallReport : listUpdateCallPLanCallReport){
				setAccountId.add(eachCallReport.CIS_ID__c);
			}

			listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :setAccountId AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c < :System.today()];
			setAccountId.clear();
		}
		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		List<Call_Report__c> listUpdateCallReportStatus = new List<Call_Report__c>();
		List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Set<String> setSharedUserId = new Set<String>();
		Boolean isCheckExpireDate = true;
		Boolean isCheckOpenCallPlanCallReport = true;
		Boolean isCheckOpenOpportunity = true;
		Boolean changeContactOwnerToAccountOwner = true;

		if(!listTargetListWithInfo.isEmpty()){
			listDeleteAccountShare = getListDeleteAccountSharesFromTargetList(listTargetListWithInfo,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);

			if(!listDeleteAccountShare.isEmpty()){
				for(Call_Report__c eachCallReport : listUpdateCallPLanCallReport){
					Call_Report__c updateCallReport = new Call_Report__c();
					updateCallReport.Id = eachCallReport.Id;
					updateCallReport.Status__c = GlobalConstants.CLOSED;
					listUpdateCallReportStatus.add(updateCallReport);
				}
				TriggerHandler.bypass('CallReportTriggerHandler');
				update listUpdateCallReportStatus;
				TriggerHandler.clearbypass('CallReportTriggerHandler');

				for(Target_List__c eachTargetList : listTargetListWithInfo){
					if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
						mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
					}
					mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
					setSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
					setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				}

				listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setSharedUserId,GlobalConstants.CLOSED));

				if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
					TriggerHandler.bypass('CallReportTriggerHandler');
					update listUpdateCallPlanCallReportToClosed;
					TriggerHandler.clearbypass('CallReportTriggerHandler');
				}

				delete listDeleteAccountShare;
				
				listUpdateAccountSharingInfo = getListUpdateStopShareInfoInAccount(listDeleteAccountShare);
				if(!listUpdateAccountSharingInfo.isEmpty()){
					TriggerHandler.bypass('AccountTriggerHandler');
					update listUpdateAccountSharingInfo;
					TriggerHandler.clearbypass('AccountTriggerHandler');

					List<Contact> listContactChangedOwner = getListChangeContactOwner(listUpdateAccountSharingInfo,setSharedUserId,changeContactOwnerToAccountOwner);
					update listContactChangedOwner;
				}

				listUpdateTargetListSharingInfo = getListUpdateStopShareInfoInTargetListCheckExpired(listDeleteAccountShare,mapListTargetListMapByAccountId);
				if(!listUpdateTargetListSharingInfo.isEmpty()){
					TriggerHandler.bypass('TargetListTriggerHandler');
					update listUpdateTargetListSharingInfo;
					TriggerHandler.clearbypass('TargetListTriggerHandler');
				}
			}
		}
	}

	public static void updateOpportunityThenCheckStopSharingCondition(List<Opportunity> listUpdateOpportunity){
		List<Opportunity> listOpportunityStatusClosed = new List<Opportunity>();
		List<Target_List__c> listTargetListWithInfo = new List<Target_List__c>();
		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Set<String> setSharedUserId = new Set<String>();
		Set<String> setAccountId = new Set<String>();
		Boolean isCheckExpireDate = true;
		Boolean isCheckOpenCallPlanCallReport = true;
		Boolean isCheckOpenOpportunity = true;
		Boolean changeContactOwnerToAccountOwner = true;

        for(Opportunity eachOpportunity : listUpdateOpportunity){
            if(ManageSharing_Service.setClosedOpportunityStatus.contains(eachOpportunity.StageName)){
                listOpportunityStatusClosed.add(eachOpportunity);
            }
        }

        if(!listOpportunityStatusClosed.isEmpty()){
        	listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN (SELECT Target_List__c FROM Opportunity_Lead__c WHERE Opportunity__c IN :listUpdateOpportunity) AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c < :System.today()];

        	if(listTargetListWithInfo.isEmpty()){
				for(Opportunity eachOpp : listUpdateOpportunity){
					setAccountId.add(eachOpp.AccountId);
				}

				listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :setAccountId AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c < :System.today()];
				setAccountId.clear();
			}
        	if(!listTargetListWithInfo.isEmpty()){
				listDeleteAccountShare = getListDeleteAccountSharesFromTargetList(listTargetListWithInfo,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);

				if(!listDeleteAccountShare.isEmpty()){

					for(Target_List__c eachTargetList : listTargetListWithInfo){
						if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
							mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
						}
						mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
						setSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
						setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
					}

					List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();

					listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setSharedUserId,GlobalConstants.CLOSED));
					
                    //INC000000663998
					if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
						update listUpdateCallPlanCallReportToClosed;
					}

					delete listDeleteAccountShare;

					listUpdateAccountSharingInfo = getListUpdateStopShareInfoInAccount(listDeleteAccountShare);
					if(!listUpdateAccountSharingInfo.isEmpty()){
						TriggerHandler.bypass('AccountTriggerHandler');
						update listUpdateAccountSharingInfo;
						TriggerHandler.clearbypass('AccountTriggerHandler');

						List<Contact> listContactChangedOwner = getListChangeContactOwner(listUpdateAccountSharingInfo,setSharedUserId,changeContactOwnerToAccountOwner);
						update listContactChangedOwner;
					}
				
					listUpdateTargetListSharingInfo = getListUpdateStopShareInfoInTargetList(listDeleteAccountShare,mapListTargetListMapByAccountId);
					if(!listUpdateTargetListSharingInfo.isEmpty()){
						TriggerHandler.bypass('TargetListTriggerHandler');
						update listUpdateTargetListSharingInfo;
						TriggerHandler.clearbypass('TargetListTriggerHandler');
					}
				}
			}
        }
	}

	public static void deleteAccountShareWhenLeadSharingExpiredDateMoreThan90Days(List<Account> listLeadSharingExpiredAccount){
		Set<String> setAccountId = new Set<String>();
		Set<String> setSharedUserId = new Set<String>();
		List<Target_List__c> listTargetListWithInfo = new List<Target_List__c>();
		List<Target_List__c> listUpdateTargetListSharingInfo = new List<Target_List__c>();
		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		List<Account> listUpdateAccountSharingInfo = new List<Account>();
		Map<String,List<Target_List__c>> mapListTargetListMapByAccountId = new Map<String,List<Target_List__c>>();
		Map<Id,Target_List__c> mapTargetListMapByShareWith = new Map<Id,Target_List__c>();
		Boolean isCheckExpireDate = true;
		Boolean isCheckOpenCallPlanCallReport = false;
		Boolean isCheckOpenOpportunity = false;

		if(!listLeadSharingExpiredAccount.isEmpty()){
			listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,End_Date__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,Lead_Campaign__r.Status,Lead_Campaign__r.IsActive FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :listLeadSharingExpiredAccount];
		}
		
		if(!listTargetListWithInfo.isEmpty()){

			for(Target_List__c eachTargetList : listTargetListWithInfo){
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				setSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
				mapTargetListMapByShareWith.put(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c, eachTargetList);
				if(!mapListTargetListMapByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
					mapListTargetListMapByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
				}
				mapListTargetListMapByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c).add(eachTargetList);
			}

			List<Call_Report__c> listUpdateCallPlanCallReportToClosed = new List<Call_Report__c>();
			List<Opportunity> listUpdateOpportunityToClosed = new List<Opportunity>();

			listUpdateCallPlanCallReportToClosed.addAll(getListChangeAllCallPlanCallReportStatusToSpecificStatus(setAccountId,setSharedUserId,GlobalConstants.CLOSED));
			listUpdateOpportunityToClosed.addAll(getListChangeOpenOpportunityToSpecificStageName(setAccountId,setSharedUserId,mapTargetListMapByShareWith,GlobalConstants.AUTO_CLOSED));
			
            //INC000000663998
			if(!listUpdateCallPlanCallReportToClosed.isEmpty()){
				update listUpdateCallPlanCallReportToClosed;
			}
			//INC000000663998
			if(!listUpdateOpportunityToClosed.isEmpty()){
				update listUpdateOpportunityToClosed;
			}

			List<Target_List__c> listExpiredTargetListWithInfo = new List<Target_List__c>();

			for(Target_List__c eachTargetListWithInfo : listTargetListWithInfo){
				if(eachTargetListWithInfo.Lead_Status__c != GlobalConstants.ACTIVE && !setClosedOpportunityStatus.contains(eachTargetListWithInfo.Lead_Status__c)){
					listExpiredTargetListWithInfo.add(eachTargetListWithInfo);
				}
			}
			listDeleteAccountShare = getListDeleteAccountSharesFromTargetList(listExpiredTargetListWithInfo,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);

			if(!listDeleteAccountShare.isEmpty()){
				delete listDeleteAccountShare;

				listUpdateAccountSharingInfo = getListUpdateStopShareInfoInAccount(listDeleteAccountShare);
				if(!listUpdateAccountSharingInfo.isEmpty()){
					TriggerHandler.bypass('AccountTriggerHandler');
					update listUpdateAccountSharingInfo;
					TriggerHandler.clearbypass('AccountTriggerHandler');
				}

				listUpdateTargetListSharingInfo = getListUpdateStopShareInfoInTargetListSpecificStatus(listDeleteAccountShare,mapListTargetListMapByAccountId,GlobalConstants.AUTO_CLOSED);
				
				if(!listUpdateTargetListSharingInfo.isEmpty()){
					TriggerHandler.bypass('TargetListTriggerHandler');
					update listUpdateTargetListSharingInfo;
					TriggerHandler.clearbypass('TargetListTriggerHandler');
				}
			}
		}
	}


	// private method
	private static List<AccountShare> createAccountShareFromTargetListWithInfo(List<Target_List__c> listTargetListWithInfo){
		List<AccountShare> listAccountShare = new List<AccountShare>();
		Boolean isCheckOpenCallPlanCallReport = true;
		Boolean isCheckOpenOpportunity = true;
		if(!listTargetListWithInfo.isEmpty()){
			listAccountShare = createAccountShare(listTargetListWithInfo,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);
		}
		return listAccountShare;
	}

	private static List<AccountShare> createAccountShareFromTargetList(List<Target_List__c> listTargetList){
		List<AccountShare> listAccountShare = new List<AccountShare>();
		Boolean isCheckOpenCallPlanCallReport = true;
		Boolean isCheckOpenOpportunity = true;
		List<Target_List__c> listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN :listTargetList];
		if(!listTargetListWithInfo.isEmpty()){
			listAccountShare = createAccountShare(listTargetListWithInfo,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);
		}
		return listAccountShare;
	}

	private static List<AccountShare> createAccountShareFromTargetList(List<Target_List__c> listTargetList,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity){
		List<AccountShare> listAccountShare = new List<AccountShare>();
		List<Target_List__c> listTargetListWithInfo = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN :listTargetList];
		if(!listTargetListWithInfo.isEmpty()){
			listAccountShare = createAccountShare(listTargetListWithInfo,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);
		}
		return listAccountShare;
	}

	private static List<AccountShare> createAccountShare(List<Account> listAccount){
		List<AccountShare> listAccountShare = new List<AccountShare>();
		for(Account eachAccount : listAccount){
			AccountShare accountShare = new AccountShare();
			accountShare.AccountId = eachAccount.Id;
			accountShare.UserOrGroupId = eachAccount.Share_With__c;
			accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
			accountShare.AccountAccessLevel = 'Edit';
			accountShare.OpportunityAccessLevel = 'Read';
			accountShare.CaseAccessLevel = 'none';

			listAccountShare.add(accountShare);
		}
		return listAccountShare;
	}

	private static List<AccountShare> createAccountShare(List<Target_List__c> listTargetList,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity){
		Set<String> setAccountId = new Set<String>();
		Set<String> setAccountIdAndCalNewMaxExpDate = new Set<String>();
		Set<String> setSharedUserId = new Set<String>();
		Set<String> setOwnerAccountId = new Set<String>();
		List<Target_List__c> listTargetListUnshare = new List<Target_List__c>();
		List<Target_List__c> listTargetListAlreadyShare = new List<Target_List__c>();
		List<Target_List__c> listTargetListAlreadyShareAndCalNewMaxExpDate = new List<Target_List__c>();
		Map<String,AccountShare> mapNewAccountShare = new Map<String,AccountShare>();
		Map<String,List<AccountShare>> mapAccountShareMapByAccountId = new Map<String,List<AccountShare>>();
		Map<String,List<AccountShare>> mapAccountShareOtherUserMapByAccountId = new Map<String,List<AccountShare>>();
		Map<String,List<Call_Report__c>> mapListOpenCallReportMapByAccountId;
		Map<String,List<Opportunity>> mapListOpenOpportunityMapByAccountId;

		for(Target_List__c eachTargetList : listTargetList){
			if(isLeadForSharing(eachTargetList.Lead_Sharing__c,eachTargetList.Lead_Type__c,eachTargetList.Lead_Subtype__c)){
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
				setSharedUserId.add(eachTargetList.Share_With__c);
				setOwnerAccountId.add(eachTargetList.CIS_ID_Prospect_Name__r.OwnerId);
			}
		}

		List<AccountShare> listExistsAccountShare = [SELECT Id,AccountId,UserOrGroupId,UserOrGroup.Profile.Name FROM AccountShare WHERE AccountId IN :setAccountId AND RowCause != 'ImplicitParent'];
		for(AccountShare eachAccountShare : listExistsAccountShare){
			if(!mapAccountShareMapByAccountId.containsKey(eachAccountShare.AccountId)){
				mapAccountShareMapByAccountId.put(eachAccountShare.AccountId,new List<AccountShare>());
			}

			if(!mapAccountShareOtherUserMapByAccountId.containsKey(eachAccountShare.AccountId)){
				mapAccountShareOtherUserMapByAccountId.put(eachAccountShare.AccountId,new List<AccountShare>());
			}

			if(setSharedUserId.contains(eachAccountShare.UserOrGroupId)){
				mapAccountShareMapByAccountId.get(eachAccountShare.AccountId).add(eachAccountShare);
			}else{
				mapAccountShareOtherUserMapByAccountId.get(eachAccountShare.AccountId).add(eachAccountShare);
			}
		}

		if(isCheckOpenCallPlanCallReport){
			mapListOpenCallReportMapByAccountId = getMapListOpenCallPlanCallReportAllOwnerByAccount(setAccountId);
		}

		if(isCheckOpenOpportunity){
			mapListOpenOpportunityMapByAccountId = getMapListOpenOpportunityAllOwnerMapByAccount(setAccountId);
		}

		for(Target_List__c eachTargetList : listTargetList){
			if(isLeadForSharing(eachTargetList.Lead_Sharing__c,eachTargetList.Lead_Type__c,eachTargetList.Lead_Subtype__c)){
				AccountShare accountShare = null;
				if(eachTargetList.Lead_Status__c != GlobalConstants.ACTIVE){
					continue;
				}

				if(isAccountAlreadyShareToThisAccount(eachTargetList,mapAccountShareMapByAccountId)){
					Target_List__c targetListAlreadyShare = new Target_List__c();
					targetListAlreadyShare.Id = eachTargetList.Id;
					targetListAlreadyShare.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
					targetListAlreadyShare.Sharing_Completed__c = true;
					targetListAlreadyShare.Sharing_Remark__c = Label.LeadSharing_Customer_already_shared;
					listTargetListAlreadyShare.add(targetListAlreadyShare);
					listTargetListAlreadyShareAndCalNewMaxExpDate.add(eachTargetList);
					setAccountIdAndCalNewMaxExpDate.add(eachTargetList.CIS_ID_Prospect_Name__c);
					continue;
				}

				if(!eachTargetList.Share_With__r.IsActive){
					Target_List__c shareUserInTargetListIsInactive = new Target_List__c();
					shareUserInTargetListIsInactive.Id = eachTargetList.Id;
					shareUserInTargetListIsInactive.Sharing_Remark__c = 'Sharing user is inactive';
					listTargetListAlreadyShare.add(shareUserInTargetListIsInactive);
					continue;
				}

				if(isAccountAlreadShareToAnotherUser(eachTargetList,mapAccountShareOtherUserMapByAccountId)){
					Target_List__c targetListAlreadyShare = new Target_List__c();
					targetListAlreadyShare.Id = eachTargetList.Id;
					targetListAlreadyShare.Sharing_Remark__c = Label.LeadSharing_Customer_shared_to_different_AN;
					setAccountIdAndCalNewMaxExpDate.add(eachTargetList.CIS_ID_Prospect_Name__c);
					listTargetListAlreadyShare.add(targetListAlreadyShare);
					continue;
				}

				if(!isTargetListHasCallPlanOrOpportunity(eachTargetList,mapListOpenCallReportMapByAccountId,mapListOpenOpportunityMapByAccountId,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity)){
					accountShare = new AccountShare();
					accountShare.AccountId = eachTargetList.CIS_ID_Prospect_Name__c;
					accountShare.UserOrGroupId = eachTargetList.Share_With__c;
					accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
					accountShare.AccountAccessLevel = 'Edit';
					accountShare.OpportunityAccessLevel = 'Read';
					accountShare.CaseAccessLevel = 'none';

					if(mapMaxLeadSharingExpireByAccountId.containsKey(eachTargetList.CIS_ID_Prospect_Name__c)){
						Date maxDate = mapMaxLeadSharingExpireByAccountId.get(eachTargetList.CIS_ID_Prospect_Name__c);
						if(maxDate < eachTargetList.End_Date__c){
							mapMaxLeadSharingExpireByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, eachTargetList.End_Date__c);
						}
					}else{
						mapMaxLeadSharingExpireByAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c, eachTargetList.End_Date__c);
					}
				}else{
					eachTargetList.Sharing_Remark__c = Label.LeadSharing_Opened_CallPlanOpp;
					listTargetListUnshare.add(eachTargetList);
				}

				if(accountShare != null){
                    if(!mapNewAccountShare.containsKey(accountShare.AccountId +''+ accountShare.UserOrGroupId)){
                        mapNewAccountShare.put(accountShare.AccountId +''+ accountShare.UserOrGroupId, accountShare);
                    }
					if(!mapAccountShareMapByAccountId.containsKey(accountShare.AccountId)){
						mapAccountShareMapByAccountId.put(accountShare.AccountId,new List<AccountShare>());
					}
					mapAccountShareMapByAccountId.get(accountShare.AccountId).add(accountShare);
				}
			}
		}

		if(!listTargetListUnshare.isEmpty()){
			TriggerHandler.bypass('TargetListTriggerHandler');
			update listTargetListUnshare;
			TriggerHandler.clearbypass('TargetListTriggerHandler');
		}

		if(!listTargetListAlreadyShare.isEmpty()){
			TriggerHandler.bypass('TargetListTriggerHandler');
			update listTargetListAlreadyShare;
			TriggerHandler.clearbypass('TargetListTriggerHandler');
		}

		Map<Id,Account> mapAccountById = new Map<Id,Account>([SELECT Id, Lead_Sharing_Expired_Date__c, (SELECT Id, Lead_Campaign__r.EndDate FROM Campaign_Members_Leads__r WHERE Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND Lead_Campaign__r.IsActive = true ORDER BY Lead_Campaign__r.EndDate DESC LIMIT 1) FROM Account WHERE Id IN :setAccountIdAndCalNewMaxExpDate]);
		List<Account> listAccountUpdateMaxExpDate = new List<Account>();
		for(Account eachUpdateAccountSharingInfo : mapAccountById.values()){
			Account accountForCheckMaxExpDate = mapAccountById.get(eachUpdateAccountSharingInfo.Id);
			if(accountForCheckMaxExpDate != null){
				if(accountForCheckMaxExpDate.Campaign_Members_Leads__r != null && accountForCheckMaxExpDate.Campaign_Members_Leads__r.size() > 0){
					eachUpdateAccountSharingInfo.Lead_Sharing_Expired_Date__c = accountForCheckMaxExpDate.Campaign_Members_Leads__r[0].Lead_Campaign__r.EndDate;
					listAccountUpdateMaxExpDate.add(eachUpdateAccountSharingInfo);
				}
			}
		}

		if(!listAccountUpdateMaxExpDate.isEmpty()){
			TriggerHandler.bypass('AccountTriggerHandler');
			update listAccountUpdateMaxExpDate;
			TriggerHandler.clearbypass('AccountTriggerHandler');
		}

		return mapNewAccountShare.values();
	}

	private static List<AccountShare> getListDeleteAccountSharesFromTargetList(List<Target_List__c> listTargetList,Boolean isCheckExpireDate,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity){
		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		if(!listTargetList.isEmpty()){
			listDeleteAccountShare = getListDeleteAccountShare(listTargetList,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity);
		}
		return listDeleteAccountShare;
	}

	private static List<AccountShare> getListDeleteAccountSharesFromTargetList(List<Target_List__c> listTargetList,Boolean isCheckExpireDate,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity,Boolean isDeleteTargetList,Boolean isChangeBad,Boolean isLeadExpired){
		List<AccountShare> listDeleteAccountShare = new List<AccountShare>();
		if(!listTargetList.isEmpty()){
			listDeleteAccountShare = getListDeleteAccountShare(listTargetList,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity,isDeleteTargetList,isChangeBad,isLeadExpired);
		}
		return listDeleteAccountShare;
	}

	private static Boolean isAccountAlreadyShareToThisAccount(Target_List__c targetList,Map<String,List<AccountShare>> mapAccountShareMapByAccountId){
		if(mapAccountShareMapByAccountId.containsKey(targetList.CIS_ID_Prospect_Name__c)){
			List<AccountShare> listAccountShare = mapAccountShareMapByAccountId.get(targetList.CIS_ID_Prospect_Name__c);
			for(AccountShare eachAccountShare : listAccountShare){
				if(eachAccountShare.UserOrGroupId == targetList.Share_With__c){
					return true;
				}
			}
		}
		return false;
	}

	private static Boolean isAccountAlreadShareToAnotherUser(Target_List__c targetList,Map<String,List<AccountShare>> mapAccountShareOtherUserMapByAccountId){
		if(mapAccountShareOtherUserMapByAccountId.containsKey(targetList.CIS_ID_Prospect_Name__c)){
			List<AccountShare> listAccountShare = mapAccountShareOtherUserMapByAccountId.get(targetList.CIS_ID_Prospect_Name__c);
			for(AccountShare eachAccountShare : listAccountShare){
				if(GlobalConstants.PROFILE_AN_SET.contains(eachAccountShare.UserOrGroup.Profile.Name)){
					return true;
				}
			}
		}
		return false;
	}

	private static List<AccountShare> getListDeleteAccountShare(List<Target_List__c> listTargetList,Boolean isCheckExpireDate,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity){
		Boolean isDeleteTargetList = false;
		Boolean isChangeBad = false;
		Boolean isLeadExpired = false;
		return getListDeleteAccountShare(listTargetList,isCheckExpireDate,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity,isDeleteTargetList,isChangeBad,isLeadExpired);
	}

	private static List<AccountShare> getListDeleteAccountShare(List<Target_List__c> listTargetList,Boolean isCheckExpireDate,Boolean isCheckOpenCallPlanCallReport,Boolean isCheckOpenOpportunity,Boolean isDeleteTargetList,Boolean isChangeBad,Boolean isLeadExpired){
		Set<String> setAccountId = new Set<String>();
		Set<String> setSharedUserId = new Set<String>();
		Map<Id,AccountShare> mapDeleteAccountShare = new Map<Id,AccountShare>();
		Map<Id,Map<Id,Target_List__c>> mapOtherSharingTargetListMapByAccountAndShareWith = new Map<Id,Map<Id,Target_List__c>>();
		Map<String,Target_List__c> mapTargetListWithAccountId = new Map<String,Target_List__c>();

		for(Target_List__c eachTargetList : listTargetList){
			if(isLeadForSharing(eachTargetList.Lead_Sharing__c,eachTargetList.Lead_Type__c,eachTargetList.Lead_Subtype__c)){
				mapTargetListWithAccountId.put(eachTargetList.CIS_ID_Prospect_Name__c,eachTargetList);
				if(isChangeBad){
					setSharedUserId.add(eachTargetList.Share_With__c);
				}else{
					setSharedUserId.add(eachTargetList.CIS_ID_Prospect_Name__r.Share_With__c);
				}
				setAccountId.add(eachTargetList.CIS_ID_Prospect_Name__c);
			}
		}

		List<AccountShare> listExistsAccountShare = [SELECT Id,AccountId,Account.Share_With__c,UserOrGroupId FROM AccountShare WHERE UserOrGroupId IN :setSharedUserId AND AccountId IN :setAccountId AND RowCause = 'Manual'];
		List<Target_List__c> listOtherSharingTargetListFromAccountId = [SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Status__c,End_Date__c,Share_With__r.IsActive FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :setAccountId AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Sharing_Status__c = :GlobalConstants.SHARING_WITH_AN AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND Lead_Campaign__r.IsActive = true AND ID NOT IN :listTargetList];

		for(Target_List__c eachSharingTargetList : listOtherSharingTargetListFromAccountId){
			if(!mapOtherSharingTargetListMapByAccountAndShareWith.containsKey(eachSharingTargetList.CIS_ID_Prospect_Name__c)){
				mapOtherSharingTargetListMapByAccountAndShareWith.put(eachSharingTargetList.CIS_ID_Prospect_Name__c, new Map<Id,Target_List__c>());
			}
			mapOtherSharingTargetListMapByAccountAndShareWith.get(eachSharingTargetList.CIS_ID_Prospect_Name__c).put(eachSharingTargetList.CIS_ID_Prospect_Name__r.Share_With__c,eachSharingTargetList);
		}

		Map<String,List<Call_Report__c>> mapListCallReportMapByAccountId = getMapListCallPlanMapByAccountId(setAccountId,setSharedUserId,isCheckOpenCallPlanCallReport);
		Map<String,List<Opportunity>> mapListOpportunityMapByAccountId = getMapListOpportunityMapByAccountId(setAccountId,setSharedUserId,isCheckOpenOpportunity);

		for(AccountShare eachAccountShare : listExistsAccountShare){
			if(mapTargetListWithAccountId.containsKey(eachAccountShare.AccountId)){
				if(isDeleteTargetList && !mapOtherSharingTargetListMapByAccountAndShareWith.containsKey(eachAccountShare.AccountId)){
					mapDeleteAccountShare.put(eachAccountShare.Id, eachAccountShare);
				}else if(!isDeleteTargetList){
					Target_List__c sharedTargetList = mapTargetListWithAccountId.get(eachAccountShare.AccountId);
					if(!isTargetListHasCallPlanOrOpportunity(sharedTargetList,mapListCallReportMapByAccountId,mapListOpportunityMapByAccountId,isCheckOpenCallPlanCallReport,isCheckOpenOpportunity)){
						if(isChangeBad || isLeadExpired || (isCheckExpireDate && isTodayOverDueMaxCampaignEndDate(sharedTargetList))){
							mapDeleteAccountShare.put(eachAccountShare.Id, eachAccountShare);
						}
					}
				}
			}
		}
		return mapDeleteAccountShare.values();
	}

	public static List<Contact> getListChangeContactOwner(List<Account> listAccountId,Set<String> setOldShareWith,Boolean isDeleteTargetList){
		List<Contact> contactUpdateList = [SELECT Id,OwnerId,AccountId,Account.OwnerId,Account.Share_With__c FROM Contact WHERE AccountId IN :listAccountId AND OwnerId IN :setOldShareWith];
		for(Contact eachContact : contactUpdateList){
			if(isDeleteTargetList){
				eachContact.OwnerId = eachContact.Account.OwnerId;
			}else{
				eachContact.OwnerId = eachContact.Account.Share_With__c;
			}
			
		}
		return contactUpdateList;
	}

	public static Boolean isTodayOverDueMaxCampaignEndDate(Target_List__c sharedTargetList){
		if(sharedTargetList.CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c < System.today()){
			return true;
		}
		return false;
	}

	private static Boolean isTargetListHasCallPlanOrOpportunity(Target_List__c targetList,Map<String,List<Call_Report__c>> mapListCallReportMapByAccountId,Map<String,List<Opportunity>> mapListOpportunityMapByAccountId,Boolean isCheckCallPLanStatus,Boolean isCheckOpportunityStatus){
		if((isCheckCallPLanStatus && isTargetListHasCallPlan(targetList, mapListCallReportMapByAccountId)) 
			|| (isCheckOpportunityStatus && isTargetListHasOpportunity(targetList, mapListOpportunityMapByAccountId))){
			return true;
		}

		return false;
	}

	private static Boolean isTargetListHasCallPlan(Target_List__c targetList,Map<String,List<Call_Report__c>> mapListCallReportMapByAccountId){
		if(mapListCallReportMapByAccountId != null && mapListCallReportMapByAccountId.containsKey(targetList.CIS_ID_Prospect_Name__c) && !(mapListCallReportMapByAccountId.get(targetList.CIS_ID_Prospect_Name__c)).isEmpty()){
			return true;
		}

		return false;
	}

	private static Boolean isTargetListHasOpportunity(Target_List__c targetList,Map<String,List<Opportunity>> mapListOpportunityMapByAccountId){
		if(mapListOpportunityMapByAccountId != null && mapListOpportunityMapByAccountId.containsKey(targetList.CIS_ID_Prospect_Name__c) && !(mapListOpportunityMapByAccountId.get(targetList.CIS_ID_Prospect_Name__c).isEmpty())){
			return true;
		}

		return false;
	}

	private static Map<String,List<Opportunity>> getMapListOpenOpportunityAllOwnerMapByAccount(Set<String> setAccountId){
		if(listOpenOpportunityByAccount == null){
			listOpenOpportunityByAccount = new List<Opportunity>();
			listOpenOpportunityByAccount = [SELECT Id,AccountId,StageName,OwnerId FROM Opportunity WHERE Active_Opportunity__c IN :setAccountId AND StageName NOT IN :setClosedOpportunityStatus];
		}
		
		Map<String,List<Opportunity>> mapListOpenOpportunityMapByAccountId = new Map<String,List<Opportunity>>();
		for(Opportunity eachOpp : listOpenOpportunityByAccount){
			if(!mapListOpenOpportunityMapByAccountId.containsKey(eachOpp.AccountId)){
				mapListOpenOpportunityMapByAccountId.put(eachOpp.AccountId, new List<Opportunity>());
			}
			mapListOpenOpportunityMapByAccountId.get(eachOpp.AccountId).add(eachOpp);
		}

		return mapListOpenOpportunityMapByAccountId;
	}

	private static Map<String,List<Opportunity>> getMapListOpportunityMapByAccountId(Set<String> setAccountId,Set<String> setSharedUserId,Boolean isGetOnlyOpenOpportunity){
		List<Opportunity> listOpenOpportunity = getListOpportunityByAccountAndOwner(setAccountId,setSharedUserId,isGetOnlyOpenOpportunity);
		Map<String,List<Opportunity>> mapListOpenOpportunityMapByAccountId = new Map<String,List<Opportunity>>();
		for(Opportunity eachOpp : listOpenOpportunity){
			if(!mapListOpenOpportunityMapByAccountId.containsKey(eachOpp.AccountId)){
				mapListOpenOpportunityMapByAccountId.put(eachOpp.AccountId, new List<Opportunity>());
			}
			mapListOpenOpportunityMapByAccountId.get(eachOpp.AccountId).add(eachOpp);
		}

		return mapListOpenOpportunityMapByAccountId;
	}

	private static Map<String,List<Call_Report__c>> getMapListCallPlanNotInUserSetMapByAccountId(Set<String> setAccountId,Set<String> setUserId,Boolean isGetOnlyOpenCallPlan){
		List<Call_Report__c> listOpenCallPlan = getListCallPlanCallReportByAccountAndOwner(setAccountId,setUserId,isGetOnlyOpenCallPlan);
		Map<String,List<Call_Report__c>> mapListOpenCallReportMapByAccountId = new Map<String,List<Call_Report__c>>();
		for(Call_Report__c eachRep : listOpenCallPlan){
			if(!mapListOpenCallReportMapByAccountId.containsKey(eachRep.CIS_ID__c)){
				mapListOpenCallReportMapByAccountId.put(eachRep.CIS_ID__c, new List<Call_Report__c>());
			}
			mapListOpenCallReportMapByAccountId.get(eachRep.CIS_ID__c).add(eachRep);
		}

		return mapListOpenCallReportMapByAccountId;
	}

	private static Map<String,List<Call_Report__c>> getMapListOpenCallPlanCallReportAllOwnerByAccount(Set<String> setAccountId){
		if(listOpenCallPlanCallReportByAccount == null){
			listOpenCallPlanCallReportByAccount = new List<Call_Report__c>();
			listOpenCallPlanCallReportByAccount = [SELECT Id,CIS_ID__c,Status__c,Current_Owner_Extension__r.OwnerId FROM Call_Report__c WHERE CIS_ID__c IN :setAccountId AND Status__c IN :setOpenCallPlanStatus];
		}

		Map<String,List<Call_Report__c>> mapListOpenCallReportAllOwnerMapByAccountId = new Map<String,List<Call_Report__c>>();

		for(Call_Report__c eachRep : listOpenCallPlanCallReportByAccount){
			if(!mapListOpenCallReportAllOwnerMapByAccountId.containsKey(eachRep.CIS_ID__c)){
				mapListOpenCallReportAllOwnerMapByAccountId.put(eachRep.CIS_ID__c, new List<Call_Report__c>());
			}
			mapListOpenCallReportAllOwnerMapByAccountId.get(eachRep.CIS_ID__c).add(eachRep);
		}

		return mapListOpenCallReportAllOwnerMapByAccountId;
	}

	private static Map<String,List<Call_Report__c>> getMapListCallPlanMapByAccountId(Set<String> setAccountId,Set<String> setUserId,Boolean isGetOnlyOpenCallPlan){
		List<Call_Report__c> listOpenCallPlan = getListCallPlanCallReportByAccountAndOwner(setAccountId,setUserId,isGetOnlyOpenCallPlan);
		Map<String,List<Call_Report__c>> mapListOpenCallReportMapByAccountId = new Map<String,List<Call_Report__c>>();
		for(Call_Report__c eachRep : listOpenCallPlan){
			if(!mapListOpenCallReportMapByAccountId.containsKey(eachRep.CIS_ID__c)){
				mapListOpenCallReportMapByAccountId.put(eachRep.CIS_ID__c, new List<Call_Report__c>());
			}
			mapListOpenCallReportMapByAccountId.get(eachRep.CIS_ID__c).add(eachRep);
		}

		return mapListOpenCallReportMapByAccountId;
	}

	private static List<Call_Report__c> getListCallPlanCallReportByAccountAndOwner(Set<String> setAccountId,Set<String> setUserId,Boolean isGetOnlyOpenCallPlan){
		if(listAllCallPlanCallReportByAccountAndOwner == null){
			listAllCallPlanCallReportByAccountAndOwner = new List<Call_Report__c>();
			listOpenCallPlanCallReportByAccountAndOwner = new List<Call_Report__c>();
			listAllCallPlanCallReportByAccountAndOwner = [SELECT Id,CIS_ID__c,Status__c FROM Call_Report__c WHERE CIS_ID__c IN :setAccountId AND Current_Owner_Extension__r.OwnerId IN :setUserId];
			for(Call_Report__c eachCall : listAllCallPlanCallReportByAccountAndOwner){
				if(setOpenCallPlanStatus.contains(eachCall.Status__c)){
					listOpenCallPlanCallReportByAccountAndOwner.add(eachCall);
				}
			}
		}
		if(isGetOnlyOpenCallPlan){
			return listOpenCallPlanCallReportByAccountAndOwner;
		}
		return listAllCallPlanCallReportByAccountAndOwner;
	}

	private static List<Opportunity> getListOpenOpportunityByAccountAndOwner(Set<String> setAccountId,Set<String> setSharedUserId){
		Boolean isGetOnlyOpenOpportunity = true;
		return getListOpportunityByAccountAndOwner(setAccountId,setSharedUserId,isGetOnlyOpenOpportunity);
	}

	private static List<Opportunity> getListOpportunityByAccountAndOwner(Set<String> setAccountId,Set<String> setUserId,Boolean isGetOnlyOpenOpportunity){
		if(listAllOpportunityByAccountAndOwner == null){
			listAllOpportunityByAccountAndOwner = new List<Opportunity>();
			listOpenOpportunityByAccountAndOwner = new List<Opportunity>();
			listAllOpportunityByAccountAndOwner = [SELECT Id,AccountId,StageName,OwnerId FROM Opportunity WHERE Active_Opportunity__c IN :setAccountId AND OwnerId IN :setUserId];
			for(Opportunity eachOpp : listAllOpportunityByAccountAndOwner){
				if(!setClosedOpportunityStatus.contains(eachOpp.StageName)){
					listOpenOpportunityByAccountAndOwner.add(eachOpp);
				}
			}
		}
		if(isGetOnlyOpenOpportunity){
			return listOpenOpportunityByAccountAndOwner;
		}
		return listAllOpportunityByAccountAndOwner;
	}

	private static List<Call_Report__c> getListChangeAllCallPlanCallReportStatusToSpecificStatus(Set<String> setAccountId,Set<String> setSharedUserId,String changeStatusTo){
		Boolean isGetOnlyOpenCallPlan = false;
		List<Call_Report__c> listAllCallPlanCallReport = getListCallPlanCallReportByAccountAndOwner(setAccountId,setSharedUserId,isGetOnlyOpenCallPlan);

		for(Call_Report__c eachCallPlanCallReport : listAllCallPlanCallReport){
			eachCallPlanCallReport.Status__c = changeStatusTo;
		}
		return listAllCallPlanCallReport;
	}

	private static List<Opportunity> getListChangeOpenOpportunityToSpecificStageName(Set<String> setAccountId,Set<String> setSharedUserId,Map<Id,Target_List__c> mapTargetListMapByShareWith,String changeStageNameTo){
		List<Opportunity> listOpenOpportunity = getListOpenOpportunityByAccountAndOwner(setAccountId,setSharedUserId);
		for(Opportunity eachOpp : listOpenOpportunity){
			Target_List__c shareTargetList = mapTargetListMapByShareWith.get(eachOpp.OwnerId);
			if(shareTargetList != null){
				eachOpp.StageName = changeStageNameTo;
			}
		}
		return listOpenOpportunity;
	}

	public static Boolean isLeadForSharing(String sharingType,String leadType,String leadSubtype){
		if((String.isNotEmpty(sharingType) && sharingType.equalsIgnoreCase(GlobalConstants.LEAD_SHARING))
			&& (String.isNotEmpty(leadType) && leadType.equalsIgnoreCase(GlobalConstants.LEAD_FOR_SALES))){
			return true;
		}
		return false;
	}

	private static List<Account> getListUpdateShareInfoInAccount(List<AccountShare> listNewAccountShare){
		List<Account> listUpdateAccount = new List<Account>();
		for(AccountShare eachAccountShare : listNewAccountShare){
			Account updateAccount = new Account();
			updateAccount.Id = eachAccountShare.AccountId;
			updateAccount.Share_With__c = eachAccountShare.UserOrGroupId;
			updateAccount.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
			updateAccount.Lead_Sharing_Expired_Date__c = mapMaxLeadSharingExpireByAccountId.get(eachAccountShare.AccountId);
			listUpdateAccount.add(updateAccount);
		}
		return listUpdateAccount;
	}

	private static List<Target_List__c> getListUpdateShareInfoInTargetList(List<AccountShare> listNewAccountShare,Map<String,List<Target_List__c>> mapTargetListMapByAccountId){
		List<Target_List__c> listAllUpdateTargetList = new List<Target_List__c>();
		for(AccountShare eachAccountShare : listNewAccountShare){
			List<Target_List__c> listUpdateTargetList = mapTargetListMapByAccountId.get(eachAccountShare.AccountId);
			for(Target_List__c eachUpdateTargetList : listUpdateTargetList){
				Target_List__c updateTargetList = new Target_List__c();
				updateTargetList.Id = eachUpdateTargetList.Id;
				updateTargetList.Sharing_Remark__c = null;
				updateTargetList.Sharing_Completed__c = true;
				updateTargetList.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
				listAllUpdateTargetList.add(updateTargetList);
			}
		}
		return listAllUpdateTargetList;
	}

	private static List<Account> getListUpdateStopShareInfoInAccount(List<AccountShare> listStopAccountShare){
		Map<Id,Account> mapUpdateAccount = new Map<Id,Account>();
		for(AccountShare eachAccountShare : listStopAccountShare){
			Account updateAccount = new Account();
			updateAccount.Id = eachAccountShare.AccountId;
			updateAccount.Share_With__c = null;
			updateAccount.Sharing_Status__c = null;
			updateAccount.Lead_Sharing_Expired_Date__c = null;
            if(!mapUpdateAccount.containsKey(updateAccount.Id)){
                mapUpdateAccount.put(updateAccount.Id, updateAccount);
            }
		}
		return mapUpdateAccount.values();
	}

	private static List<Target_List__c> getListUpdateStopShareInfoInTargetList(List<AccountShare> listStopAccountShare,Map<String,List<Target_List__c>> mapTargetListMapByAccountId){
		List<Target_List__c> listAllUpdateTargetList = new List<Target_List__c>();
		for(AccountShare eachAccountShare : listStopAccountShare){
			List<Target_List__c> listUpdateTargetList = mapTargetListMapByAccountId.get(eachAccountShare.AccountId);
			for(Target_List__c eachUpdateTargetList : listUpdateTargetList){
				
				Target_List__c updateTargetList = new Target_List__c();
				updateTargetList.Id = eachUpdateTargetList.Id;
				updateTargetList.Sharing_Status__c = null;
				listAllUpdateTargetList.add(updateTargetList);
			}
		}
		return listAllUpdateTargetList;
	}

	private static List<Target_List__c> getListUpdateStopShareInfoInTargetListCheckExpired(List<AccountShare> listStopAccountShare,Map<String,List<Target_List__c>> mapTargetListMapByAccountId){
		List<Target_List__c> listAllUpdateTargetList = new List<Target_List__c>();
		for(AccountShare eachAccountShare : listStopAccountShare){
			List<Target_List__c> listUpdateTargetList = mapTargetListMapByAccountId.get(eachAccountShare.AccountId);
			for(Target_List__c eachUpdateTargetList : listUpdateTargetList){
				
				Target_List__c updateTargetList = new Target_List__c();
				updateTargetList.Id = eachUpdateTargetList.Id;
				updateTargetList.Sharing_Status__c = null;
				
				if(eachUpdateTargetList.Lead_Status__c == GlobalConstants.LEAD_EXPIRED || eachUpdateTargetList.Lead_Status__c == GlobalConstants.EXPIRED || eachUpdateTargetList.Lead_Status__c == GlobalConstants.EXPIRE_PROCESS){
					updateTargetList.Status__c = GlobalConstants.LEAD_EXPIRED;
					updateTargetList.Sharing_Remark__c = null;
					updateTargetList.Active_Target_List__c = null;
				}else{
					updateTargetList.Sharing_Remark__c = Label.LeadSharing_CallReport_Opp_not_updated;
					updateTargetList.Status__c = GlobalConstants.AUTO_CLOSED;
				}

				listAllUpdateTargetList.add(updateTargetList);
			}
		}
		return listAllUpdateTargetList;
	}

	private static List<Target_List__c> getListUpdateStopShareInfoInTargetListSpecificStatus(List<AccountShare> listStopAccountShare,Map<String,List<Target_List__c>> mapTargetListMapByAccountId,String status){
		List<Target_List__c> listAllUpdateTargetList = new List<Target_List__c>();
		for(AccountShare eachAccountShare : listStopAccountShare){
			List<Target_List__c> listUpdateTargetList = mapTargetListMapByAccountId.get(eachAccountShare.AccountId);
			for(Target_List__c eachUpdateTargetList : listUpdateTargetList){
				
				Target_List__c updateTargetList = new Target_List__c();
				updateTargetList.Id = eachUpdateTargetList.Id;
				updateTargetList.Sharing_Status__c = null;
				updateTargetList.Status__c = status;
				updateTargetList.Sharing_Remark__c = Label.LeadSharing_CallReport_Opp_not_updated;

				listAllUpdateTargetList.add(updateTargetList);
			}
		}
		return listAllUpdateTargetList;
	}
}