public without sharing class Customer_BusinessCode_Service {

	//public static Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById;
	public static List<Customer_Business_Code__c> customerBusinessCodeListSortByAccountId;
	public static String defaultValue;

	public static String generateExternalId(sObject thisObject,String businessCodeExternalId){
		String externalId;
		String objectType = GlobalUtility.getType(thisObject);
		//if(objectType == 'Call_Report__c'){
		//	Call_Report__c eachCallReport = (Call_Report__c)thisObject;
		//	externalId = eachCallReport.CIS_ID__c+':'+businessCodeExternalId;
		//}else 
		if(objectType == 'Opportunity' ){
			Opportunity eachOpportunity = (Opportunity)thisObject;
			externalId = eachOpportunity.AccountId+':'+businessCodeExternalId;
		}else if(objectType == 'Account'){
			Account eachAccount = (Account)thisObject;
			externalId = eachAccount.id+':'+businessCodeExternalId;
		}else if(objectType == 'Customer_Business_Code__c'){
			Customer_Business_Code__c eachCustomerBu = (Customer_Business_Code__c)thisObject;
			externalId = eachCustomerBu.CIS__c+':'+businessCodeExternalId;
		}
		return externalId;
	}

	public static Map<Id,Customer_Business_Code__c> getCustomerBusinessCodeMapById(Set<Id> customerBusinessCodeList){
		Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById = new Map<Id,Customer_Business_Code__c>([SELECT CIS__c,Industry_Risk_Rating__c,Ratio__c,Room_Left__c,Business_Code__c,Risky_Control_FL__c,Exception_FL__c,Risky_Control_HPL__c,Exception_HPL__c,Risky_Control_PL__c,Exception_PL__c,Business_Code__r.Name,Keyword_Text__c,Description_Text__c From Customer_Business_Code__c WHERE Id IN :customerBusinessCodeList]);
		return customerBusinessCodeMapById;
	}

	public static List<Customer_Business_Code__c> getCustomerBusinessCodeSortedByAccountId(Set<Id> accountIdSet){
		List<Customer_Business_Code__c> customerBusinessCodeList = [SELECT CIS__c,Latest_Used_when__c,Latest_Used__c,Id From Customer_Business_Code__c WHERE CIS__c IN :accountIdSet ORDER BY CIS__c ASC];
		return customerBusinessCodeList;
	}


	public static Map<String,Business_Code__c> getBusinessCodeMapByExternalId(Set<String> businessCodeExternalIdSet){
		Map<String,Business_Code__c> businessCodeMapByExId = new Map<String,Business_Code__c>();
		List<Business_Code__c> businessCodeList =  [SELECT Id,External_ID__c,Segment__c,Name,Keyword__c,Business_Code_Description__c From Business_Code__c WHERE External_ID__c IN :businessCodeExternalIdSet];
		for(Business_Code__c eachBusinessCode : businessCodeList){
			businessCodeMapByExId.put(eachBusinessCode.External_ID__c,eachBusinessCode);
		}
		return businessCodeMapByExId;
	}

	public static Map<String,Customer_Business_Code__c> getCustomerBuisnessCodeMapByExternalId(Set<String> customerBusinessCodeExIdSet){
		Map<String,Customer_Business_Code__c> customerBusinessCodeMapByExId = new Map<String,Customer_Business_Code__c>();
		List<Customer_Business_Code__c> customerBusinessCodeList = [SELECT Id,External__c,Business_Code__r.Name,Risky_Control_FL__c,Risky_Control_HPL__c,Risky_Control_PL__c,Exception_PL__c,Exception_FL__c,Exception_HPL__c,Industry_Risk_Rating__c,Room_Left__c,Keyword_text__c,Description_Text__c,Ratio__c From Customer_Business_Code__c WHERE External__c IN :customerBusinessCodeExIdSet];
		for(Customer_Business_Code__c eachCustomerBusinessCode : customerBusinessCodeList){
			customerBusinessCodeMapByExId.put(eachCustomerBusinessCode.External__c,eachCustomerBusinessCode);
		}
		return customerBusinessCodeMapByExId;
	}

	public static Map<String,Decimal> getTotalCustomerBusinessCodeRatioMapByAccountId(Set<String> accountIdSet,Set<String> customerBusinessCodeIdSet){
		Map<String,Decimal> customerBusinessCodeRatioMapByAccountId = new Map<String,Decimal>();
		List<AggregateResult> totalRatioAggregateResultList = [SELECT SUM(Ratio__c) TOTAL_RATIO, CIS__c From Customer_Business_Code__c WHERE CIS__c IN :accountIdSet AND id NOT IN :customerBusinessCodeIdSet  Group By CIS__c];
		for(AggregateResult eachTotalRaito : totalRatioAggregateResultList){
            customerBusinessCodeRatioMapByAccountId.put(String.valueof(eachTotalRaito.get('CIS__c')), (Decimal)eachTotalRaito.get('TOTAL_RATIO')  );
        }
        return customerBusinessCodeRatioMapByAccountId;
	}

	public static void setLatestUsedCustomerBusinessCode(Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById){
		Set<Id> accountIdSet = new Set<Id>();
		for(Customer_Business_Code__c eachCustomerBusienssCode : customerBusinessCodeMapById.values()){
			accountIdSet.add(eachCustomerBusienssCode.CIS__c);
		}
		List<Customer_Business_Code__c> customerBusinessCodeList = [SELECT CIS__c,Latest_Used_when__c,Latest_Used__c,Id From Customer_Business_Code__c WHERE CIS__c IN :accountIdSet ORDER BY CIS__c ASC];
		if(!customerBusinessCodeList.isEmpty()){
			String oldAccountId;
			Boolean thisAccountChecked;
			for(Customer_Business_Code__c eachCustomerBusienssCode :  customerBusinessCodeList){
				if(eachCustomerBusienssCode.CIS__c != oldAccountId){
					thisAccountChecked = false;
					oldAccountId = eachCustomerBusienssCode.CIS__c;
				}
				if(customerBusinessCodeMapById.containsKey(eachCustomerBusienssCode.id)){
					eachCustomerBusienssCode.Latest_Used_when__c = System.now();
					if(!thisAccountChecked){
							eachCustomerBusienssCode.Latest_Used__c = true;
							thisAccountChecked = true;
					}
				}else{
					eachCustomerBusienssCode.Latest_Used__c = false;
				}
			}
			DB_Service.updateSObjectWithBypass(customerBusinessCodeList,false);
		}
	}

	// edit for INC000000815154
    public static void setCustomerBusinessCodeOnOwnerChangeSegment(List<Account_MaskModel> accountTargetList){
        Set<String> profileToKeepCustomerBusinessCodes = new Set<String>{GlobalConstants.SME_ADMIN,GlobalConstants.CBS_ADMIN};
        Map<Id,String> accountNewSegmentMapByaccountId = new Map<Id,String>();
        for(Account_MaskModel accountMask : accountTargetList){
            if(accountMask.ownerUser.Segment__c != accountMask.previousOwnerUser.Segment__c && !profileToKeepCustomerBusinessCodes.contains(accountMask.ownerUser.Profile.Name) ){
                if(!accountNewSegmentMapByaccountId.containsKey(accountMask.accObj.id)){
                    accountNewSegmentMapByaccountId.put(accountMask.accObj.id,accountMask.ownerUser.Segment__c);
                }
            }
        }
        if(!accountNewSegmentMapByaccountId.isEmpty()){
            Map<String,Customer_Business_Code__c> customerBusinessCodeMapByExId = new Map<String,Customer_Business_Code__c>();
            Map<Id,Customer_Business_Code__c> customerBusienssCodeMapToDelete = new Map<Id,Customer_Business_Code__c>([SELECT Id,Business_Code__c,CIS__c,CIS__r.CIS__c,Business_Code__r.Name,Latest_Used_when__c,Ratio__c,Latest_Used__c,Description_text__c From Customer_Business_Code__c WHERE CIS__c IN :accountNewSegmentMapByaccountId.keySet()]);
            if(!customerBusienssCodeMapToDelete.isEmpty()){
                Set<String> businessCodeExternalIdSet = new Set<String>();
                for(Customer_Business_Code__c eachCustomerBusienssCode: customerBusienssCodeMapToDelete.values()){
                    String businessCodeExternalId = eachCustomerBusienssCode.Business_Code__r.Name+':'+accountNewSegmentMapByaccountId.get(eachCustomerBusienssCode.CIS__c);
                    if(!businessCodeExternalIdSet.contains(businessCodeExternalId)){
                        businessCodeExternalIdSet.add(businessCodeExternalId);
                    }
                }

                Map<String,Business_Code__c> businessCodeMapByExId = Customer_BusinessCode_Service.getBusinessCodeMapByExternalId(businessCodeExternalIdSet);
                if(!businessCodeMapByExId.isEmpty()){
                    for(Customer_Business_Code__c eachCustomerBusienssCode : customerBusienssCodeMapToDelete.values()){
                        String businessCodeExternalId = eachCustomerBusienssCode.Business_Code__r.Name+':'+accountNewSegmentMapByaccountId.get(eachCustomerBusienssCode.CIS__c);
                        if(businessCodeMapByExId.containsKey(businessCodeExternalId)){
                            Business_Code__c businessCode =  businessCodeMapByExId.get(businessCodeExternalId);
                            Customer_Business_Code__c newCustomerBusinessCode = new Customer_Business_Code__c(
                                Name = businessCode.Name,
                                Business_Code_for_Serach__c = businessCode.Name,
                                Business_Code__c = businessCode.id,
                                Keyword_Text__c = businessCode.Keyword__c,
                                Description_Text__c = businessCode.Business_Code_Description__c,
                                External__c = Customer_BusinessCode_Service.generateExternalId(eachCustomerBusienssCode,businessCode.External_ID__c),
                                CIS__c = eachCustomerBusienssCode.CIS__c,
                                Ratio__c = eachCustomerBusienssCode.Ratio__c,
                                Latest_Used__c = eachCustomerBusienssCode.Latest_Used__c,
                                Latest_Used_when__c = eachCustomerBusienssCode.Latest_Used_when__c,
                                Account_Owner_Segment__c = accountNewSegmentMapByaccountId.get(eachCustomerBusienssCode.CIS__c)
                                );
                            customerBusinessCodeMapByExId.put(newCustomerBusinessCode.External__c,newCustomerBusinessCode);
                        }
                    }

                }
                delete customerBusienssCodeMapToDelete.values();
                if(!customerBusinessCodeMapByExId.isEmpty()){
                    TriggerHandler.bypass('CustomerBusinessCodeTriggerHandler');
                    upsert customerBusinessCodeMapByExId.values() External__c;
                    TriggerHandler.clearbypass('CustomerBusinessCodeTriggerHandler');
                }
                //if change owner From Callreport Ex Take Temp
                //if(Account_Service.callReportTriggerList != null){
                //    for(Call_Report__c eachCallReport : Account_Service.callReportTriggerList){
                //        if(eachCallReport.Customer_Business_Code__c != null && customerBusienssCodeMapToDelete.containsKey(eachCallReport.Customer_Business_Code__c) && accountNewSegmentMapByaccountId.containsKey(eachCallReport.CIS_ID__c)){
                //            String businessCodeExternalId = customerBusienssCodeMapToDelete.get(eachCallReport.Customer_Business_Code__c).Business_Code__r.Name+':'+accountNewSegmentMapByaccountId.get(eachCallReport.CIS_ID__c);
                //            if(businessCodeMapByExId.containsKey(businessCodeExternalId)){
                //                String newCustomerBusinessCodeExternalId = Customer_BusinessCode_Service.generateExternalId(eachCallReport,businessCodeExternalId);
                //                eachCallReport.Customer_Business_Code__c = customerBusinessCodeMapByExId.get(newCustomerBusinessCodeExternalId).id;
                //            }else{
                //                //INC000000815154
                //                eachCallReport.addError('กรุณาระบุ Customer Business Code ในส่วนล่างของหน้าลูกค้า (ไม่ใช่หน้านี้) ก่อนมากรอกที่หน้า Call Report');
                //            }
                //        }
                //    }
                //}
            }
        }
    }

	public static void upsertCustomerBusinessCodeFromOpportunity(List<Opportunity> oppList,Map<Id,Opportunity> oppOldMap,Map<Id,String> businessCodeTextMapOppId,Boolean isUWUpdateBusinessCodeText,Map<Id, Account> accouuntMap){
		Map<String,Business_Code__c> businessCodeMapById;
		if(!isUWUpdateBusinessCodeText){
			businessCodeMapById = new Map<String,Business_Code__c>([SELECT Id,Name,External_ID__c,Keyword__c,Business_Code_Description__c From Business_Code__c WHERE Id IN : businessCodeTextMapOppId.values()]);
		}else{
			businessCodeMapById = Customer_BusinessCode_Service.getBusinessCodeMapByExternalId(new Set<String>(businessCodeTextMapOppId.values())  );
		}
		Map<String,Customer_Business_Code__c> customerBusinessCodeMapByExId = new Map<String,Customer_Business_Code__c>();
		for(Opportunity eachOpp : oppList){
			if(Trigger.isInsert){
				if(eachOpp.Business_Code__c != null && (eachOpp.IsConvertFromCallReport__c == null || eachOpp.IsConvertFromCallReport__c == false)){
					if(businessCodeMapById.containsKey(eachOpp.Business_Code__c)){
						eachOpp.Business_Code_Text__c = businessCodeMapById.get(eachOpp.Business_Code__c).Name;
						Customer_Business_Code__c customerBusinessCode = Customer_BusinessCode_Service.newCustomerBusinessCode(accouuntMap.get(eachOpp.AccountId),businessCodeMapById.get(eachOpp.Business_Code__c));
						customerBusinessCode.Account_Owner_Segment__c = eachOpp.Owner_Segment_Business_Code__c;
						customerBusinessCodeMapByExId.put(customerBusinessCode.External__c,customerBusinessCode);
					}
				}
			}
			if(Trigger.isUpdate && eachOpp.Business_Code__c != null){
				Opportunity oldOpp = oppOldMap.get(eachOpp.id);
				if(!isUWUpdateBusinessCodeText){
					if(eachOpp.Business_Code__c != oldOpp.Business_Code__c && businessCodeMapById.containsKey(eachOpp.Business_Code__c)){
						eachOpp.Business_Code_Text__c = businessCodeMapById.get(eachOpp.Business_Code__c).Name;
						Customer_Business_Code__c customerBusinessCode =  Customer_BusinessCode_Service.newCustomerBusinessCode(accouuntMap.get(eachOpp.AccountId),businessCodeMapById.get(eachOpp.Business_Code__c));
						customerBusinessCode.Account_Owner_Segment__c = eachOpp.Owner_Segment_Business_Code__c;
						customerBusinessCodeMapByExId.put(customerBusinessCode.External__c,customerBusinessCode);
					}
				}else{
					if(eachOpp.Business_Code_Text__c != oldOpp.Business_Code_Text__c){
						String businessCodeExId = businessCodeTextMapOppId.get(eachOpp.id);
						if(businessCodeMapById.containsKey(businessCodeExId)){
							eachOpp.Business_Code__c = businessCodeMapById.get(businessCodeExId).id;
							Customer_Business_Code__c customerBusinessCode = Customer_BusinessCode_Service.newCustomerBusinessCode(accouuntMap.get(eachOpp.AccountId),businessCodeMapById.get(businessCodeExId));
							customerBusinessCode.Account_Owner_Segment__c = eachOpp.Owner_Segment_Business_Code__c;
						customerBusinessCodeMapByExId.put(customerBusinessCode.External__c,customerBusinessCode);
						}else{
							eachOpp.addError(ExceptionMessage.NO_BUSINESSCODE_MATCH_IN_SYSTEM);
						}
					}
				}
			}
		}
		upsert customerBusinessCodeMapByExId.values() External__c;
		Customer_BusinessCode_Service.setLatestUsedCustomerBusinessCode(new Map<Id,Customer_Business_Code__c>(customerBusinessCodeMapByExId.values()));
	}
	public static String getDefaultValue() {
		if(Customer_BusinessCode_Service.defaultValue == null) {
			List<CustomerBusinessCodeField__c> listCustomerBusinessCodeField = CustomerBusinessCodeField__c.getall().values();
			if(listCustomerBusinessCodeField.size() > 0) {
				Customer_BusinessCode_Service.defaultValue = listCustomerBusinessCodeField[0].DefaultName__c;	
			}
		}
		return Customer_BusinessCode_Service.defaultValue;
	}
	public static Customer_Business_Code__c newCustomerBusinessCode(Account account,Business_Code__c businessCode){
		Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c(Name=businessCode.Name,CIS__c =account.id,Business_Code__c =businessCode.id,External__c = Customer_BusinessCode_Service.generateExternalId(account, businessCode.External_ID__c) ,Keyword_Text__c = businessCode.Keyword__c,Description_Text__c = businessCode.Business_Code_Description__c);
		return customerBusinessCode;
	}

	public static String fillPreFixBusinessCode(String buCode){
		Integer businessCodeSize = buCode.length();
		String prefix = '0'.repeat(9-businessCodeSize);
		buCode = prefix+buCode;
		return buCode;
	}
}