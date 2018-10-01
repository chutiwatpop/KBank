public without sharing class BottomUp_Service {
	//public static String currentYear = GlobalUtility.toValue( System.Today().year() > 2500 ? System.Today().year()-543: System.Today().year() );
	public static String currentYear = GlobalUtility.toValue( GlobalUtility.getYearInChristianCalendar(System.Today()) );
	public static List<Bottom_Up_Annualized__c> globalBottomUpForUpsert;
	public static List<Sales_Target__c> globalSalesTargetForUpsert;
	public static Map<String,Sales_Target__c> userExIdSaleTargetMap;
	public static Map<String,Team_Target__c> rcCodeTeamTargetMap;
	private static Map<String,User_Mirror_Management__c> nHTLMirrorSettinByNHRcCode;
	private static Set<String> profileToCreateSaleTarget = new Set<String>{GlobalConstants.CBS_RM,GlobalConstants.CBS_TM,GlobalConstants.CBS_TL};

	public static void createBottomUpForNewAccountList(List<Account> newAccountList){
		Id customerRecTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
		List<Bottom_Up_Annualized__c> bottomUpList = new List<Bottom_Up_Annualized__c>();
		if(BottomUp_Service.userExIdSaleTargetMap == null)
			BottomUp_Service.userExIdSaleTargetMap = BottomUp_Service.getuserExtensionIdSalesTargetMap();
		for(Account eachAccount : newAccountList){
			if(eachAccount.is_CBS_user__c && eachAccount.Current_Owner_Extension__c != null && eachAccount.RecordTypeId == customerRecTypeId){
				if(BottomUp_Service.userExIdSaleTargetMap.containsKey(eachAccount.Current_Owner_Extension__c)){
					Sales_Target__c saleTargetObj = BottomUp_Service.userExIdSaleTargetMap.get(eachAccount.Current_Owner_Extension__c);
					if(saleTargetObj != null){
						Bottom_Up_Annualized__c bottomUpObj = createBottomUp_ThisYear(eachAccount,saleTargetObj);
	
						bottomUpList.add(bottomUpObj);
					}
				}
			}
		}
		if(bottomUpList != null && bottomUpList.size() > 0){
			if( globalBottomUpForUpsert == null ){
				BottomUp_Service.globalBottomUpForUpsert = new List<Bottom_Up_Annualized__c>();
			}
			BottomUp_Service.globalBottomUpForUpsert.addAll(bottomUpList);
		}
	}

	public static void createSaleTargetForNewUserExtension(List<User_Extension__c> newUserExtList){
		List<Sales_Target__c> saleTargetList = new List<Sales_Target__c>();
		if(BottomUp_Service.rcCodeTeamTargetMap == null){
					BottomUp_Service.rcCodeTeamTargetMap = BottomUp_Service.getRcCodeTeamTargetMap();
		}
	
		if(BottomUp_Service.nHTLMirrorSettinByNHRcCode == null){
			BottomUp_Service.nHTLMirrorSettinByNHRcCode = CustomSettingUtil.getMirrorSettingByUserRcCode();
		}
		for(User_Extension__c eachUserExt : newUserExtList){
			if(!eachUserExt.User__r.IsActive){
				continue;
			}
			User_Mirror_Management__c userNHTL = BottomUp_Service.nHTLMirrorSettinByNHRcCode.get(eachUserExt.User__r.RC_Code__c);
			if( (GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(eachUserExt.Segment__c) && profileToCreateSaleTarget.contains(eachUserExt.User__r.Profile.Name)) || userNHTL != null){
				Team_Target__c teamTarget;

				if(userNHTL == null){
					teamTarget = BottomUp_Service.rcCodeTeamTargetMap.get(eachUserExt.User__r.RC_Code__c);
				}else{
					teamTarget = BottomUp_Service.rcCodeTeamTargetMap.get(userNHTL.Mirror_Value__c);
				}

				if(eachUserExt != null && teamTarget != null){
					Sales_Target__c saleTarget = BottomUp_Service.createSalesTarger_ThisYear(eachUserExt,teamTarget);
					saleTargetList.add(saleTarget);
				}
			}
		}
		if(saleTargetList != null && saleTargetList.size() > 0){
			if(BottomUp_Service.globalSalesTargetForUpsert == null){
				BottomUp_Service.globalSalesTargetForUpsert = new List<Sales_Target__c>();
			}
			BottomUp_Service.globalSalesTargetForUpsert.addAll(saleTargetList);
		}
	}

	public static void setNewSalesTargetOnOwnerChange(List<Account_MaskModel> accountTargetList, Set<Id> relatedUpdateSet,Map<String, User_Extension__c> userExtMapByUserId){
		List<Bottom_Up_Annualized__c> bottomUpList = new List<Bottom_Up_Annualized__c>();
		Map<String,Bottom_Up_Annualized__c> accountIdBottomUpMap = new Map<String,Bottom_Up_Annualized__c>();
		if(BottomUp_Service.userExIdSaleTargetMap == null){
			BottomUp_Service.userExIdSaleTargetMap = BottomUp_Service.getuserExtensionIdSalesTargetMap();
		}
		for(Bottom_Up_Annualized__c bottomUpObj : [SELECT Id,Sales_Target__c,CIS_ID__c,Is_Active__c,External_ID__c From Bottom_Up_Annualized__c WHERE CIS_ID__c IN :relatedUpdateSet AND Year__c = :currentYear]){
			accountIdBottomUpMap.put(bottomUpObj.CIS_ID__c,bottomUpObj);
		}

		for(Account_MaskModel accountMask : accountTargetList){
			Bottom_Up_Annualized__c bottomUpObj = accountIdBottomUpMap.get(accountMask.accObj.id);
			User_Extension__c newUserExt = userExtMapByUserId.get(accountMask.ownerUser.id);
			Sales_Target__c newUserSaleTarget;
			if(newUserExt != null){
				newUserSaleTarget = BottomUp_Service.userExIdSaleTargetMap.get(newUserExt.id);
			}
			// Ownerchange in CBS || SME to CBS
			if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountMask.accObj.Primary_Segment_Code__c) && accountMask.ownerUser.Profile.Name != GlobalConstants.CBS_ADMIN  ){
			 	if(bottomUpObj != null && bottomUpObj.Is_Active__c && newUserSaleTarget != null){
						bottomUpObj.Sales_Target__c = newUserSaleTarget.id;
			 	}else if(bottomUpObj != null && !bottomUpObj.Is_Active__c && newUserSaleTarget != null){
			 		bottomUpObj.Sales_Target__c = newUserSaleTarget.id;
			 		bottomUpObj.Is_Active__c = true;
			 	}else{
			 		if(accountMask.accObj == null || newUserSaleTarget == null)
			 			continue;

			 		bottomUpObj = createBottomUp_ThisYear(accountMask.accObj,newUserSaleTarget);
			 	}
			}else if( GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountMask.accObj.Primary_Segment_Code__c) && accountMask.ownerUser.Profile.Name == GlobalConstants.CBS_ADMIN){
					if(bottomUpObj != null){
						bottomUpObj.Is_Active__c = false;
					}
			}else{ // OwnerChange from CBS to SME
				if(bottomUpObj != null)
					bottomUpObj.Is_Active__c = false;
			}

			if(bottomUpObj != null){
				bottomUpList.add(bottomUpObj);
			}
			
		}

		if(bottomUpList != null && bottomUpList.size() > 0){
			if( globalBottomUpForUpsert == null ){
				BottomUp_Service.globalBottomUpForUpsert = new List<Bottom_Up_Annualized__c>();
			}
			BottomUp_Service.globalBottomUpForUpsert.addAll(bottomUpList);
		}
	}

	public static void setSalesTargetOnUserUpdate(List<User> useList,Map<Id,User> userOldMap,Map<String,User_Extension__c> userExtMapByUserId){
		List<User> userListToInactiveSaleTarget = new List<User>();
		List<User> userListToUpdateTeamTarget = new List<User>();
		if(BottomUp_Service.nHTLMirrorSettinByNHRcCode == null){
			BottomUp_Service.nHTLMirrorSettinByNHRcCode = CustomSettingUtil.getMirrorSettingByUserRcCode();
		}

		for(User eachUser : useList){
			User_Mirror_Management__c userNHTL = BottomUp_Service.nHTLMirrorSettinByNHRcCode.get(eachUser.RC_Code__c);

			User oldUser = userOldMap.get(eachUser.id);
			if( (GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(eachUser.Segment__c)  && profileToCreateSaleTarget.contains(eachUser.Profile.Name)) ||  userNHTL != null ){
				if((eachUser.Status__c != oldUser.Status__c) || (eachUser.IsActive != oldUser.IsActive) ){
				 		userListToInactiveSaleTarget.add(eachUser);
				 	
				}else if(eachUser.RC_Code__c != oldUser.RC_Code__c){
				 		userListToUpdateTeamTarget.add(eachUser);
				}
			}else if( GlobalConstants.SME_SEGMENT_CODE_SET.contains(eachUser.Segment__c) && GlobalConstants.CBS_SEGMENT_CODE_SET.contains(oldUser.Segment__c) && (eachUser.RC_Code__c != oldUser.RC_Code__c) ) { /// Change to be SME User
						userListToUpdateTeamTarget.add(eachUser);
			}
		}
		List<Sales_Target__c> salesTargetListToUpdate = new List<Sales_Target__c>();
		if(userListToInactiveSaleTarget.size() > 0 || userListToUpdateTeamTarget.size() > 0){
			if(BottomUp_Service.userExIdSaleTargetMap == null){
				BottomUp_Service.userExIdSaleTargetMap = BottomUp_Service.getuserExtensionIdSalesTargetMap();
			}

			for(User eachUser : userListToInactiveSaleTarget){
				Sales_Target__c salesTarget;
				User_Extension__c userExt = userExtMapByUserId.get(eachUser.id);
				if(userExt != null){
				salesTarget = BottomUp_Service.userExIdSaleTargetMap.get(userExt.id);
				}
				if(salesTarget != null && !eachUser.IsActive){ // inactive User
					salesTarget.Is_Active__c = false;
					salesTargetListToUpdate.add(salesTarget);
				}else if(salesTarget != null && eachUser.IsActive){ /// re-active User
					salesTarget.Is_Active__c = true;
					salesTarget.Transaction_Fee_Target__c = 0;
					salesTarget.Main_Operating_Bank_Target__c = 0;
					salesTarget.Deal_Base_Fee_Target__c = 0;
					salesTargetListToUpdate.add(salesTarget);
				}
			}

			if(userListToUpdateTeamTarget.size() > 0 ){
				if(BottomUp_Service.rcCodeTeamTargetMap == null){
					BottomUp_Service.rcCodeTeamTargetMap = BottomUp_Service.getRcCodeTeamTargetMap();
				}
				for(User eachUser : userListToUpdateTeamTarget){
					User_Extension__c userExt = userExtMapByUserId.get(eachUser.id);
					Sales_Target__c salesTarget;
					Team_Target__c teamTarget;
					User oldUser = userOldMap.get(eachUser.id);
					if(userExt != null){
					salesTarget = BottomUp_Service.userExIdSaleTargetMap.get(userExt.id);
					}
					if(eachUser.RC_Code__c != null){
					teamTarget = BottomUp_Service.rcCodeTeamTargetMap.get(eachUser.RC_Code__c);
					}
					// change from CBS - to SME
					if( oldUser != null && ( GlobalConstants.SME_SEGMENT_CODE_SET.contains(eachUser.Segment__c) && GlobalConstants.CBS_SEGMENT_CODE_SET.contains(oldUser.Segment__c) ) ){
						if( salesTarget != null){
							salesTarget.Is_Active__c = false;
						}
					}else{ /// change team inside CBS || From SME - To CBS
						if(salesTarget != null && teamTarget != null){
							salesTarget.Team_Target__c = teamTarget.id;
							salesTarget.Transaction_Fee_Target__c = 0;
							salesTarget.Main_Operating_Bank_Target__c = 0;
							salesTarget.Deal_Base_Fee_Target__c = 0;
							salesTarget.Is_Active__c = true;
						}else if( salesTarget == null && teamTarget != null){ // case up date User Segment Change From SME to CBS
							if(userExt !=null && teamTarget != null){
								salesTarget = BottomUp_Service.createSalesTarger_ThisYear(userExt,teamTarget);
							}
						}
					}

					if(salesTarget != null)
						salesTargetListToUpdate.add(salesTarget);
				}
			}			
		}

		if(salesTargetListToUpdate.size() > 0 ){
			if(BottomUp_Service.globalSalesTargetForUpsert == null){
				BottomUp_Service.globalSalesTargetForUpsert = new List<Sales_Target__c>();
			}
			BottomUp_Service.globalSalesTargetForUpsert.addAll(salesTargetListToUpdate);
		}
	}

	//Pan Rein
	public static Database.SaveResult[] updateSalesTarget(List<Sales_Target__c> toUpdateSalesTarget){
		Database.SaveResult[] updateResults = Database.update(toUpdateSalesTarget, false);
		return updateResults;
	}
	public static Database.SaveResult[] updateBottomUp(List<Bottom_Up_Annualized__c> toUpdateBottomUps){
		Database.SaveResult[] updateResults = Database.update(toUpdateBottomUps, false);
		return updateResults;
	}
	//Pan Rein

	public static Map<String,Sales_Target__c> getuserExtensionIdSalesTargetMap(){
		Map<String,Sales_Target__c> userExIdSaleTargetMapTemp = new Map<String,Sales_Target__c>();
		List<Sales_Target__c> salesTargetList = [SELECT Id,Name__r.Id,Is_Active__c,External_Id__c,Team_Target__c,Transaction_Fee_Target__c,Main_Operating_Bank_Target__c,Deal_Base_Fee_Target__c From Sales_Target__c WHERE Year__c = :currentYear];
		for(Sales_Target__c eachSaleTarger : salesTargetList){
			if( eachSaleTarger.Name__r.Id != null){
				userExIdSaleTargetMapTemp.put(eachSaleTarger.Name__r.Id,eachSaleTarger);
			}
		}
		return userExIdSaleTargetMapTemp;
	}

	public static Map<String,Team_Target__c> getRcCodeTeamTargetMap(){
		Map<String,Team_Target__c> rcCodeTeamTargetMapTemp = new Map<String,Team_Target__c>();
		List<Team_Target__c> teamTargetList = [SELECT Id,Team_RC_Code__c From Team_Target__c WHERE Year__c = :currentYear];
		for(Team_Target__c eachTeamTarget : teamTargetList){
			if(eachTeamTarget.Team_RC_Code__c != null)
				rcCodeTeamTargetMapTemp.put(eachTeamTarget.Team_RC_Code__c,eachTeamTarget);
		}
		return rcCodeTeamTargetMapTemp;
	}

	private static Bottom_Up_Annualized__c createBottomUp_ThisYear(Account account,Sales_Target__c saleTarget){
		String externalId = currentYear+'-'+account.CIS__c;
		Bottom_Up_Annualized__c bottomUp = new Bottom_Up_Annualized__c(External_Id__c = externalId, Sales_Target__c = saleTarget.Id, CIS_ID__c = account.Id,Year__c = currentYear);
		return bottomUp;
	}

	private static Sales_Target__c createSalesTarger_ThisYear(User_Extension__c userExt,Team_Target__c teamTarget){
		String externalId = currentYear +'-'+userExt.Employee_ID__c;
		Sales_Target__c salesTarget = new Sales_Target__c(External_ID__c = externalId,Name__c = userExt.id,Team_Target__c = teamTarget.id,Year__c=currentYear);
		return salesTarget;
	}

	@future
	public static void upsertGlobalSalesTargetForUpsert(String salsTargetStringList){
		List<Sales_Target__c> salesTargetToUpsert = (List<Sales_Target__c>) JSON.deserialize(salsTargetStringList, List<Sales_Target__c>.class);
		upsert salesTargetToUpsert External_ID__c;
	}
}