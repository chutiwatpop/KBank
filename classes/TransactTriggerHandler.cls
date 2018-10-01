public without sharing class TransactTriggerHandler extends TriggerHandler{
	private Map<String,String> mapCreditModel = new Map<String,String>{'A' => 'DLA','1' => 'FL','8' => 'HPL','9' => 'PL'};
	private Map<String,Map<String,Priority_Master_Table__c>> mapPriorityMasterByProductCode;
	private Map<String,Application_History__c> mapRecentAppByApplicationNo;
	private Map<String,String> lastTransactAppNoMap;

	public override void allAfter() {
		mapPriorityMasterByProductCode = new Map<String,Map<String,Priority_Master_Table__c>>();
		mapRecentAppByApplicationNo = new Map<String,Application_History__c>();
		lastTransactAppNoMap = new Map<String,String>();
		Set<String> tempApplicationNumberKeyByYearSet = new Set<String>();

		List<Priority_Master_Table__c> listPriorityMasterTable = [SELECT ID,Name,Pcode__c,Campcode__c,PID__c,PriorityRank__c,ProductGroupPP__c,ProductNameMain__c,ProductNameMain2__c,ProductNameSub__c,Ptype__c FROM Priority_Master_Table__c ORDER BY Pcode__c,Campcode__c,PID__c,PriorityRank__c DESC,Name];
		for(Priority_Master_Table__c eachPriorityMaster : listPriorityMasterTable){
			if(!mapPriorityMasterByProductCode.containsKey(eachPriorityMaster.Pcode__c)){
				mapPriorityMasterByProductCode.put(eachPriorityMaster.Pcode__c, new Map<String,Priority_Master_Table__c>());
			}

			if(!(mapPriorityMasterByProductCode.get(eachPriorityMaster.Pcode__c)).containsKey(eachPriorityMaster.Campcode__c)){
				(mapPriorityMasterByProductCode.get(eachPriorityMaster.Pcode__c)).put(eachPriorityMaster.Campcode__c,eachPriorityMaster);
			}
		}

		Set<String> firstApplicationNoSet = new Set<String>();
		List<String> transactListAppNo = new List<String>();
		for(TransactBP__c eachTransact : (List<TransactBP__c>) Trigger.new){
			String applicationNoLike =  this.removeLastNChar(eachTransact.Application_No_From_BP_SF__c,4) + '%';
     		firstApplicationNoSet.add(applicationNoLike);
     		transactListAppNo.add(eachTransact.Application_No_From_BP_SF__c);
		}
		transactListAppNo.sort();
		for(String eachAppNo : transactListAppNo){
			String tempKey = this.removeLastNChar(eachAppNo,4);
			System.debug('temp key :'+tempKey);
			if(lastTransactAppNoMap.containsKey(tempKey)){
				System.debug('containsKey');
				lastTransactAppNoMap.remove(tempKey);
				lastTransactAppNoMap.put(tempKey,eachAppNo);
			}else{
				System.debug('Not containsKey');
				lastTransactAppNoMap.put(tempKey,eachAppNo);
			}
		}

		List<Application_History__c> appHistoryRelatedList = [SELECT ID,OppName__c,AppNum_NonCMAS__c,Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Team__c,Current_NH_Team__c,Report_Actual_Visit_Date__c,AppInDate__c FROM Application_History__c WHERE  AppNum_NonCMAS__c LIKE:firstApplicationNoSet ORDER BY CreatedDate DESC];
		System.debug('appHistoryRelatedList :' + appHistoryRelatedList.size());
		for(Application_History__c eachApp : appHistoryRelatedList){
			mapRecentAppByApplicationNo.put(this.createTempApplicationNumberKey(eachApp.AppNum_NonCMAS__c), eachApp);
			System.debug('key mapRecentAppByApplicationNo :'+this.createTempApplicationNumberKey(eachApp.AppNum_NonCMAS__c));
		}
	}

	public override void afterInsert() {
		upsertApplicationHistoryByTransact((List<TransactBP__c>) Trigger.new,mapPriorityMasterByProductCode);
	}

	public override void afterUpdate() {
		upsertApplicationHistoryByTransact((List<TransactBP__c>) Trigger.new,mapPriorityMasterByProductCode);
	}

	private void upsertApplicationHistoryByTransact(List<TransactBP__c> listTransact,Map<String,Map<String,Priority_Master_Table__c>> mapPriorityMasterByProductCode){
		Map<String,Application_History__c> mapNewAppHis = new Map<String,Application_History__c>();
		List<Priority_Master_Table__c> listTempPriorityMaster = new List<Priority_Master_Table__c>();
		for(TransactBP__c eachNewTransact : listTransact){
			listTempPriorityMaster.clear();

			System.debug('eachNewTransact App no:'+this.createTempApplicationNumberKey(eachNewTransact.Application_No_From_BP_SF__c));
			if(mapRecentAppByApplicationNo.containsKey(this.createTempApplicationNumberKey(eachNewTransact.Application_No_From_BP_SF__c))){
				Priority_Master_Table__c maxPriorityMaster = new Priority_Master_Table__c();
				Application_History__c newAppHis = new Application_History__c();
				String tempTempApplicationNumberKey = this.createTempApplicationNumberKey(eachNewTransact.Application_No_From_BP_SF__c);
				Application_History__c relatedRecentApp = mapRecentAppByApplicationNo.get(tempTempApplicationNumberKey);
				String appNoLast4Char = this.getLastNChar(eachNewTransact.Application_No_From_BP_SF__c,4);
				
				if(mapPriorityMasterByProductCode.containsKey(eachNewTransact.Product_Program__c)){
					listTempPriorityMaster.add(mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR1_Campaign_Code__c));
					listTempPriorityMaster.add(mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR2_Campaign_Code__c));
					listTempPriorityMaster.add(mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR3_Campaign_Code__c));
					listTempPriorityMaster.add(mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR4_Campaign_Code__c));
					listTempPriorityMaster.add(mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR5_Campaign_Code__c));

					maxPriorityMaster = mapPriorityMasterByProductCode.get(eachNewTransact.Product_Program__c).get(eachNewTransact.CR1_Campaign_Code__c);

					for(Priority_Master_Table__c eachPriority : listTempPriorityMaster){
						if(eachPriority != null){
							if(maxPriorityMaster != null){
								if(GlobalUtility.toDecimal(eachPriority.PriorityRank__c) > GlobalUtility.toDecimal(maxPriorityMaster.PriorityRank__c)){
									maxPriorityMaster = eachPriority;
								}
							}else{
								maxPriorityMaster = eachPriority;
							}
						}
					}
				}
				if(maxPriorityMaster!=null){
					newAppHis.PID__c = maxPriorityMaster.PID__c;
					newAppHis.Ptype__c = maxPriorityMaster.Ptype__c;
					newAppHis.PriorityRank__c = maxPriorityMaster.PriorityRank__c;
					newAppHis.Pcode__c = maxPriorityMaster.Pcode__c;
					newAppHis.Campcode__c = maxPriorityMaster.Campcode__c;
					newAppHis.ProductNameSub__c = maxPriorityMaster.ProductNameSub__c;
					newAppHis.ProductNameMain__c = maxPriorityMaster.ProductNameMain__c;
					newAppHis.ProductNameMain2__c = maxPriorityMaster.ProductNameMain2__c;
					newAppHis.ProductGroupPP__c = maxPriorityMaster.ProductGroupPP__c;
				}
				if(lastTransactAppNoMap.containsKey(tempTempApplicationNumberKey)){
					if(lastTransactAppNoMap.get(tempTempApplicationNumberKey) != eachNewTransact.Application_No_From_BP_SF__c){
						newAppHis.App_Result__c = GlobalConstants.CANCELLED;
					}else{
						newAppHis.App_Result__c = GlobalConstants.WORK_IN_PROGRESS;
					}
				}
				
				newAppHis.OppName__c = relatedRecentApp.OppName__c;
				newAppHis.AppInDate__c = relatedRecentApp.AppInDate__c;
				newAppHis.Current_Owner_Extension__c = relatedRecentApp.Current_Owner_Extension__c;
				newAppHis.Current_Team_Name__c = relatedRecentApp.Current_Team_Name__c;
				newAppHis.Current_AH_Team__c = relatedRecentApp.Current_AH_Team__c;
				newAppHis.Current_NH_Team__c = relatedRecentApp.Current_NH_Team__c;
				newAppHis.Report_Actual_Visit_Date__c = relatedRecentApp.Report_Actual_Visit_Date__c;
				if(relatedRecentApp.AppNum_NonCMAS__c != eachNewTransact.Application_No_From_BP_SF__c){
					newAppHis.IS_Create_By_Integration__c = true;
				}else{
					newAppHis.IS_Create_By_Integration__c = false;
				}
				
				newAppHis.AppNum_NonCMAS__c = eachNewTransact.Application_No_From_BP_SF__c;
				newAppHis.ManualSP__c = true;
				newAppHis.SP_Submit_Issue__c = GlobalConstants.NEW_CREDIT;
				newAppHis.RMSubmitIssue__c = GlobalConstants.NEW_CREDIT;
				newAppHis.SPBusinessCode__c = eachNewTransact.Business_Code__c;
				newAppHis.RMActualRequestedAmt__c = GlobalUtility.toDecimal(eachNewTransact.CR_1_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_2_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_3_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_4_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_5_Amount_Requested__c);
				newAppHis.SP_Requested_Amt__c = GlobalUtility.toDecimal(eachNewTransact.CR_1_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_2_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_3_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_4_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_5_Amount_Requested__c);
				newAppHis.RMSubmitChannel__c = GlobalConstants.NON_CMAS;
				

				if(appNoLast4Char.substring(2,3).isAlpha() && appNoLast4Char.substring(appNoLast4Char.length()-1).isNumeric()){
					newAppHis.RMSubmitRound__c = 'Resubmit ครั้งที่ ' + appNoLast4Char.substring(appNoLast4Char.length()-1);
				}

				String creditModelCode = eachNewTransact.Application_No_From_BP_SF__c.substring(2,3);
				newAppHis.RMCreditModel__c = mapCreditModel.get(creditModelCode);
				newAppHis.SP_Credit_Model__c = newAppHis.RMCreditModel__c;

				//order by user priority D>A>B>C
				if(eachNewTransact.Customer_Option_D__c != null && eachNewTransact.Customer_Option_D__c.equalsIgnoreCase('Y')){
					newAppHis.SP_Approved_Amt__c = GlobalUtility.toDecimal(eachNewTransact.UW_Recommend_Amount_Credit_Request_1__c) + GlobalUtility.toDecimal(eachNewTransact.UW_Recommend_Amount_Credit_Request_2__c) + GlobalUtility.toDecimal(eachNewTransact.UW_Recommend_Amount_Credit_Request_3__c) + GlobalUtility.toDecimal(eachNewTransact.UW_Recommend_Amount_Credit_Request_4__c) + GlobalUtility.toDecimal(eachNewTransact.UW_Recommend_Amount_Credit_Request_5__c);
					newAppHis.SP_Approve_Option__c = 'D';
				}else if(eachNewTransact.Customer_Option_A__c != null && eachNewTransact.Customer_Option_A__c.equalsIgnoreCase('Y')){
					newAppHis.SP_Approved_Amt__c = GlobalUtility.toDecimal(eachNewTransact.CR_1_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_2_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_3_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_4_Amount_Requested__c) + GlobalUtility.toDecimal(eachNewTransact.CR_5_Amount_Requested__c);
					newAppHis.SP_Approve_Option__c = 'A';
				}else if(eachNewTransact.Customer_Option_B__c != null && eachNewTransact.Customer_Option_B__c.equalsIgnoreCase('Y')){
					newAppHis.SP_Approved_Amt__c = GlobalUtility.toDecimal(eachNewTransact.SM_P1_Offer_Amount_B__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P2_Offer_Amount_B__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P3_Offer_Amount_B__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P4_Offer_Amount_B__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P5_Offer_Amount_B__c);
					newAppHis.SP_Approve_Option__c = 'D';
				}else if(eachNewTransact.Customer_Option_C__c != null && eachNewTransact.Customer_Option_C__c.equalsIgnoreCase('Y')){
					newAppHis.SP_Approved_Amt__c = GlobalUtility.toDecimal(eachNewTransact.SM_P1_Offer_Amount_C__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P2_Offer_Amount_C__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P3_Offer_Amount_C__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P4_Offer_Amount_C__c) + GlobalUtility.toDecimal(eachNewTransact.SM_P5_Offer_Amount_C__c);
					newAppHis.SP_Approve_Option__c = 'D';
				}

				if(eachNewTransact.Application_Initial_Date_Buddhist_era__c != null){
					String day = eachNewTransact.Application_Initial_Date_Buddhist_era__c.substring(0,2);
					String month = eachNewTransact.Application_Initial_Date_Buddhist_era__c.substring(2,4);
					String year = eachNewTransact.Application_Initial_Date_Buddhist_era__c.substring(4);
					Integer yearNum = 0;
					if(UserInfo.getLocale()=='th_TH' && Integer.valueOf(year) <= 2500){
						yearNum = Integer.valueOf(year)+543;
					}else if(UserInfo.getLocale()=='en_US' && Integer.valueOf(year) >= 2500){
						yearNum = Integer.valueOf(year)-543;
					}else{
						yearNum = Integer.valueOf(year);
					}
					newAppHis.SP_CAPF_Received_DT__c = Date.newinstance(yearNum,Integer.valueOf(month),Integer.valueOf(day));
					newAppHis.TentativeSubmitDate__c = newAppHis.SP_CAPF_Received_DT__c;
				}else{
					newAppHis.SP_CAPF_Received_DT__c = null;
					newAppHis.TentativeSubmitDate__c = null;
				}
				
				if(eachNewTransact.UW_Date_Send_to_Cust_Verification_Post__c != null){
					String day = eachNewTransact.UW_Date_Send_to_Cust_Verification_Post__c.substring(0,2);
					String month = eachNewTransact.UW_Date_Send_to_Cust_Verification_Post__c.substring(2,4);
					String year = eachNewTransact.UW_Date_Send_to_Cust_Verification_Post__c.substring(4);
					Integer yearNum = 0;
					if(UserInfo.getLocale()=='th_TH' && Integer.valueOf(year) <= 2500){
						yearNum = Integer.valueOf(year)+543;
					}else if(UserInfo.getLocale()=='en_US' && Integer.valueOf(year) >= 2500){
						yearNum = Integer.valueOf(year)-543;
					}else{
						yearNum = Integer.valueOf(year);
					}
					newAppHis.SP_CAPB_Workout_DT__c = Date.newinstance(yearNum,Integer.valueOf(month),Integer.valueOf(day));
				}else{
					newAppHis.SP_CAPB_Workout_DT__c = null;
				}

				if(eachNewTransact.UW_Final_Decision__c == null || eachNewTransact.UW_Final_Decision__c == '' || eachNewTransact.UW_Final_Decision__c == GlobalConstants.FINAL_DECISION_PA){
					newAppHis.SP_Approval_Result__c = GlobalConstants.WORK_IN_PROGRESS;
				}else if(eachNewTransact.UW_Final_Decision__c == GlobalConstants.FINAL_DECISION_LP || eachNewTransact.UW_Final_Decision__c == GlobalConstants.FINAL_DECISION_DC){
					newAppHis.SP_Approval_Result__c = GlobalConstants.DECLINE;
				}else if(eachNewTransact.UW_Final_Decision__c == GlobalConstants.FINAL_DECISION_FA){
					newAppHis.IsActive__c = true;
					newAppHis.SP_Approval_Result__c = GlobalConstants.FINAL_APPROVE;
				}
				
				newAppHis.SP_UW_Name__c = eachNewTransact.UW_Code__c;
				newAppHis.SP_UWA_Name__c = eachNewTransact.UWA_Code__c;
				mapNewAppHis.put(newAppHis.AppNum_NonCMAS__c, newAppHis);
			}
		}

		ApplicationHistory_Service.byPassStampUserExtensionWhenInsert = true;
		if(!mapNewAppHis.values().isEmpty()){
			Schema.SObjectField externalField = Application_History__c.Fields.AppNum_NonCMAS__c;
			List<Database.UpsertResult> results = Database.upsert(mapNewAppHis.values(),externalField,false);
			List<Application_Log__c> listErrorLog = new List<Application_Log__c>();
			for(Database.UpsertResult eachResult : results){
				if(!eachResult.isSuccess()){
					System.debug('eachResult :'+eachResult.getErrors());
					Application_Log__c al = new Application_Log__c();

					Datetime dt = Datetime.now();
			        String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
			        al.Name = 'ALOG-'+formattedDt;
					al.Debug_Level__c = 'Error';
					al.Message__c = JSON.serialize(eachResult.getId()) +'-'+ JSON.serialize(eachResult.getErrors());
					al.Source__c = 'TransactTriggerHandler';
					listErrorLog.add(al);
				}
			}

			System.debug('listErrorLog = '+listErrorLog);
			if(!listErrorLog.isEmpty()){
				System.enqueueJob(new ApplicationLog_Queue(listErrorLog));
			}
		}
	}

	private String removeLastNChar(String inputString,Integer nNumber){
		if(inputString.length() > nNumber){
			String newString = inputString.substring(0,inputString.length() - nNumber);
			return newString;
		}
		return inputString;
	}

	private String createTempApplicationNumberKey(String appNo){
		String last2char = getLastNChar(appNo,2);
		String last4char = getLastNChar(appNo,4);
		String lastChar = getLastNChar(appNo,1);
		String secondCharFromLast = appNo.substring(appNo.length()-2, appNo.length()-1);
		if(last2char.isAlpha()){//60FA,61FA,60SR,61SR,60CG,61CG,60ED,61ED
			return appNo.substring(0,appNo.length()-1);
		}else if(last4char.isNumeric()){//2560,2561
			return appNo;
		}else if(lastChar.isNumeric() && secondCharFromLast.isAlpha() && secondCharFromLast != 'R'){//resubmit F1,F2,S1,C1,E1
			return appNo.substring(0,appNo.length()-2) +secondCharFromLast;
		}else{
			return appNo.substring(0,appNo.length()-4) +'25'+ last4char.substring(0,2);
		}
		
		//String tempApp ='';
		//if(appNo.length() > 4){
		//	tempApp = appNo.substring(0,appNo.length()-4);
		//}
		//return tempApp;
	}
	//private boolean isFirstApplicationNumber(String appNo){
	//	boolean isFirstApp = false;
	//	if(appNo.length() > 2){
	//		String last2char = appNo.substring(appNo.length() -2);
	//		if(last2char.substring(0,1).isAlpha() == last2char.substring(1,1).isAlpha()){
	//			isFirstApp = true; 
	//		}	
	//	}
	//	System.debug('isFirstApplicationNumber' + isFirstApp);
	//	return isFirstApp;
	//}

	private String getLastNChar(String inputString,Integer nNumber){
		if(inputString.length() > nNumber){
			String newString = inputString.substring(inputString.length() - nNumber);
			return newString;
		}
		return inputString;
	}
}