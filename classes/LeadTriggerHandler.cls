public without sharing class LeadTriggerHandler extends TriggerHandler {
	
	private Map<Id,User_Extension__c> userExtensionMapUserId = new Map<Id,User_Extension__c>();
	private Map<Id,User> userMapUserId = new Map<Id,User>();
	private Map<Id,Team_Structure__c> teamStructureMap = new Map<Id,Team_Structure__c>();
	private Id currentUserId = UserInfo.getUserId();
	public Set<Id> recordTypeRefferalSet = new Set<Id>();
	public Set<Id> recordTypeTelesalesSet = new Set<Id>();
	public Map<String, Id> recordTypeRefferalMap;
	public static List<Id> listAccountTeamId = new List<Id>();
    
	public override void init(){
		Set<Id> teamStructureId = new Set<Id>();
		Set<Id> userId = new Set<Id>{currentUserId};

		for(Lead eachLead : (List<Lead>) Trigger.new){
			if(eachLead.Refer_To_User__c != null) {
				userId.add(eachLead.Refer_To_User__c);
			}
			if(eachLead.Assigned_Owner__c != null) {
				userId.add(eachLead.Assigned_Owner__c);
			}
			userId.add(eachLead.OwnerId);
		}

		userMapUserId = User_Service.getUserMapWithId(new List<Id>(userId));
		List<User_Extension__c> userExtensionList = [SELECT Id,User__c,Team_Structure__c,Segment__c  From User_Extension__c WHERE User__c IN :userId];
		for(User_Extension__c eachUserEx :  userExtensionList){
			userExtensionMapUserId.put(eachUserEx.User__c,eachUserEx);
			if(eachUserEx.Team_Structure__c != null){
				teamStructureId.add(eachUserEx.Team_Structure__c);
			}
		}

		recordTypeRefferalMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		for(String eachDevname : recordTypeRefferalMap.keySet()){
			if(eachDevname == GlobalConstants.LEAD_RECORDTYPE_REFERRAL){
				recordTypeRefferalSet.add(recordTypeRefferalMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL){
				recordTypeRefferalSet.add(recordTypeRefferalMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL_READ_ONLY){
				recordTypeRefferalSet.add(recordTypeRefferalMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME){
                recordTypeRefferalSet.add(recordTypeRefferalMap.get(eachDevname));
                recordTypeTelesalesSet.add(recordTypeRefferalMap.get(eachDevname));
            }else if(eachDevname == GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME){
                recordTypeTelesalesSet.add(recordTypeRefferalMap.get(eachDevname));
            }

		}
		teamStructureMap = new Map<Id,Team_Structure__c>([SELECT Id,AH_Name__c,NH_Name__c From Team_Structure__c WHERE Id IN:teamStructureId]);
	}
	public override void allBefore(){
		
		Set<Id> accountRelatedSet = new Set<Id>();
		Map<Id,Account> relatedAccountMap = new Map<Id,Account>();
		for(Lead eachLead : (List<Lead>) Trigger.new){
			if(eachLead.Customer__c != NULL){
				accountRelatedSet.add(eachLead.Customer__c);
			}
		}
		Set<Id> userSet = new Set<Id>();
		List<Account> relatedAccountList = [SELECT Id,Name,Owner.Profile.Name,Salutation,FirstName, LastName,OwnerId,Owner.Segment__c, Max_Wealth_Branch__c,Max_Wealth_Branch__r.OwnerId,Max_Frequency_Branch__c,Max_Frequency_Branch__r.OwnerId, Open_Account_Branch__c,Open_Account_Branch__r.OwnerId, RecordType.DeveloperName,CIS__c, Encrypt_Identification_No__c, Document_Type__c, Birthdate_Registration_Date__c FROM Account WHERE Id=:accountRelatedSet];
		for(Account eachAcc : relatedAccountList){
			relatedAccountMap.put(eachAcc.Id,eachAcc);
			userSet.add(eachAcc.Max_Wealth_Branch__r.OwnerId);
			userSet.add(eachAcc.Max_Frequency_Branch__r.OwnerId);
			userSet.add(eachAcc.Open_Account_Branch__r.OwnerId);
		}

		Map<Id,User>  userMap = new Map<ID, User>([SELECT Id,Segment__c FROM User WHERE ID =:userSet]);
		Map<Id,Lead> eventOldMap = (Map<Id,Lead>)Trigger.oldMap;
		TriggerHandler.bypass('UserTriggerHandler');
		for(Lead eachLead : (List<Lead>) Trigger.new){
			Boolean valuesChange = false;
			if(recordTypeRefferalSet.contains(eachLead.RecordTypeId)){
				if(eventOldMap != NULL && eventOldMap.containsKey(eachLead.Id)){
					if(eventOldMap.get(eachLead.Id).Customer__c != eachLead.Customer__c){
						valuesChange = true;
					}
				}else{
					valuesChange = true;
				}

				if(relatedAccountMap.containsKey(eachLead.Customer__c) && valuesChange ){
					Account relatedAccount = relatedAccountMap.get(eachLead.Customer__c);

					if(relatedAccount.Owner.Profile.Name == GlobalConstants.SME_ADMIN){
						eachLead.Refer_To_User__c = NULL;
						eachLead.Refer_To_Segment__c = '';
					}else if(relatedAccount.Owner.Profile.Name == GlobalConstants.RBS_ADMIN){
						if(relatedAccount.Max_Wealth_Branch__c !=NULL){
							eachLead.Refer_To_User__c = relatedAccount.Max_Wealth_Branch__r.OwnerId;
							if(userMap.containsKey(relatedAccount.Max_Wealth_Branch__r.OwnerId)){
								eachLead.Refer_To_Segment__c = userMap.get(relatedAccount.Max_Wealth_Branch__r.OwnerId).Segment__c;	
							}
						}else if(relatedAccount.Max_Frequency_Branch__c !=NULL){
							eachLead.Refer_To_User__c = relatedAccount.Max_Frequency_Branch__r.OwnerId;
							if(userMap.containsKey(relatedAccount.Max_Frequency_Branch__r.OwnerId)){
								eachLead.Refer_To_Segment__c = userMap.get(relatedAccount.Max_Frequency_Branch__r.OwnerId).Segment__c;	
							}
						}else if(relatedAccount.Open_Account_Branch__c !=NULL){
							eachLead.Refer_To_User__c = relatedAccount.Open_Account_Branch__r.OwnerId;
							if(userMap.containsKey(relatedAccount.Open_Account_Branch__r.OwnerId)){
								eachLead.Refer_To_Segment__c = userMap.get(relatedAccount.Open_Account_Branch__r.OwnerId).Segment__c;	
							}
						}else{
							eachLead.Refer_To_User__c = relatedAccount.OwnerId;
							eachLead.Refer_To_Segment__c = relatedAccount.Owner.Segment__c;
						}
					}else{
						eachLead.Refer_To_User__c = relatedAccount.OwnerId;
						eachLead.Refer_To_Segment__c = relatedAccount.Owner.Segment__c;
					}

					eachLead.Salutation = relatedAccount.Salutation;
					eachLead.CIS_ID__c = relatedAccount.CIS__c;
					eachLead.Identification_No__c = relatedAccount.Encrypt_Identification_No__c;
					eachLead.Document_Type__c = relatedAccount.Document_Type__c;
					eachLead.Birthdate_Registration_Date__c = relatedAccount.Birthdate_Registration_Date__c;

					if(relatedAccount.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME || relatedAccount.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME){
						eachLead.FirstName = relatedAccount.FirstName;
						eachLead.LastName = relatedAccount.LastName;
					}else if(relatedAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || relatedAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME){
						eachLead.Company = relatedAccount.Name;
					}
				}

			}
		}

	}
	public override void beforeInsert(){
		User_Extension__c defaultUserExFrom;
		Team_Structure__c defaultTeamFrom;
		for(Lead eachLead : (List<Lead>) Trigger.new){
			setTmNameTelesales(eachLead);
			if(recordTypeRefferalSet.contains(eachLead.RecordTypeId)){
				if(eachLead.RecordTypeId == recordTypeRefferalMap.get(GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME)){
					if(eachLead.Assigned_Owner__c!=null){
						eachLead.FinServ__ReferredByUser__c = eachLead.Assigned_Owner__c;
						defaultUserExFrom = userExtensionMapUserId.containsKey(eachLead.Assigned_Owner__c) ? userExtensionMapUserId.get(eachLead.Assigned_Owner__c) : null;
						defaultTeamFrom = (defaultUserExFrom != null && defaultUserExFrom.Team_Structure__c != null && teamStructureMap.containsKey(defaultUserExFrom.Team_Structure__c)) ? teamStructureMap.get(defaultUserExFrom.Team_Structure__c) : null;
					}else{
						eachLead.FinServ__ReferredByUser__c = eachLead.OwnerId;
						defaultUserExFrom = userExtensionMapUserId.containsKey(eachLead.OwnerId) ? userExtensionMapUserId.get(eachLead.OwnerId) : null;
						defaultTeamFrom = (defaultUserExFrom != null && defaultUserExFrom.Team_Structure__c != null && teamStructureMap.containsKey(defaultUserExFrom.Team_Structure__c)) ? teamStructureMap.get(defaultUserExFrom.Team_Structure__c) : null;
					}
				}else{
					eachLead.FinServ__ReferredByUser__c = currentUserId;
					defaultUserExFrom = userExtensionMapUserId.containsKey(currentUserId) ? userExtensionMapUserId.get(currentUserId) : null;
					defaultTeamFrom = (defaultUserExFrom != null && defaultUserExFrom.Team_Structure__c != null && teamStructureMap.containsKey(defaultUserExFrom.Team_Structure__c)) ? teamStructureMap.get(defaultUserExFrom.Team_Structure__c) : null;
				}
				eachLead.Refer_From_Segment__c =  (defaultUserExFrom != null ) ? defaultUserExFrom.Segment__c : null;
				if(defaultTeamFrom != null){
					eachLead.Refer_From_Team_Name__c = defaultTeamFrom.Id;
					eachLead.Refer_From_AH_Name__c = defaultTeamFrom.AH_Name__c;
					eachLead.Refer_From_NH_Name__c = defaultTeamFrom.NH_Name__c;
				}
				if(userExtensionMapUserId.containsKey(eachLead.FinServ__ReferredByUser__c)) eachLead.Refer_From_User_Extension__c = userExtensionMapUserId.get(eachLead.FinServ__ReferredByUser__c).Id;
			}
        }
	}

	private void setTmNameTelesales(Lead newLead){
		if(recordTypeTelesalesSet.contains(newLead.RecordTypeId)){
			User assignUserInfo;
			if(newLead.Assigned_Owner__c != null){
				assignUserInfo = userMapUserId.get(newLead.Assigned_Owner__c);
				newLead.AssignedOwnerProfile__c = assignUserInfo.Profile.Name;
			}else{
				assignUserInfo = userMapUserId.get(newLead.OwnerId);
			}

			if(assignUserInfo.Profile.Name == 'Telesales - TM'){
				newLead.TM_Name_Telesales__c = assignUserInfo.Id;
			}else if(assignUserInfo.Manager.Profile.Name == 'Telesales - TM'){
				newLead.TM_Name_Telesales__c = assignUserInfo.ManagerId;
			}else if(assignUserInfo.Manager.Manager.Profile.Name == 'Telesales - TM'){
				newLead.TM_Name_Telesales__c = assignUserInfo.Manager.ManagerId;
			}
		}
	}

	public override void beforeUpdate(){
		List<Id> possibleUserExtensionListId = new List<Id>();
		Set<Id> setAccountId = new Set<Id>();
		for(Lead eachLead : (List<Lead>) Trigger.new){
			possibleUserExtensionListId.add(eachLead.Assigned_Owner__c);
			possibleUserExtensionListId.add(eachLead.FinServ__ReferredByUser__c);
			possibleUserExtensionListId.add(eachLead.Refer_To_User__c);
			if(eachLead.Account__c!=null){
				setAccountId.add(eachLead.Account__c);
			}
		}
		listAccountTeamId = autoCreateNewAccountTeam(setAccountId);
		userExtensionMapUserId = UserExtension_Service.getUserExtensionMapByUserId(possibleUserExtensionListId);
		for(Lead eachLead : (List<Lead>) Trigger.new){
			Lead oldLead = (Lead)Trigger.oldMap.get(eachLead.id);
			User_Extension__c userExTo = userExtensionMapUserId.containsKey(eachLead.Refer_To_User__c) ? userExtensionMapUserId.get(eachLead.Refer_To_User__c) : null;
			Team_Structure__c teamTo = (userExTo != null && userExTo.Team_Structure__c != null  && teamStructureMap.containsKey(userExTo.Team_Structure__c)) ? teamStructureMap.get(userExTo.Team_Structure__c) : null;
			eachLead.Refer_To_User_Extension__c = userExTo != null ? userExTo.Id : null;
			eachLead.Refer_To_Segment__c = userExTo != null ? userExTo.Segment__c : null;
			if(oldLead.Refer_To_User__c != eachLead.Refer_To_User__c && teamTo != null){
				eachLead.Refer_To_Team_Name__c = teamTo.Id;
				eachLead.Refer_To_AH_Name__c = teamTo.AH_Name__c;
				eachLead.Refer_To_NH_Name__c = teamTo.NH_Name__c;
			}
			if(oldLead.Assigned_Owner__c != eachLead.Assigned_Owner__c){
				eachLead.FinServ__ReferredByUser__c = eachLead.Assigned_Owner__c;
				User_Extension__c userExFrom = userExtensionMapUserId.containsKey(eachLead.Assigned_Owner__c) ? userExtensionMapUserId.get(eachLead.Assigned_Owner__c) : null;
				Team_Structure__c teamFrom = (userExFrom != null && userExFrom.Team_Structure__c != null && teamStructureMap.containsKey(userExFrom.Team_Structure__c)) ? teamStructureMap.get(userExFrom.Team_Structure__c) : null;
				eachLead.Refer_From_Segment__c = (userExFrom != null ) ? userExFrom.Segment__c : null;
				if(teamFrom != null){
					eachLead.Refer_From_Team_Name__c = teamFrom.Id;
					eachLead.Refer_From_AH_Name__c = teamFrom.AH_Name__c;
					eachLead.Refer_From_NH_Name__c = teamFrom.NH_Name__c;
				}
			}

			if(eachLead.Submit_for_Approval__c != oldLead.Submit_for_Approval__c && eachLead.Submit_for_Approval__c == true){

			}

			setTmNameTelesales(eachLead);
			if(userExtensionMapUserId.containsKey(eachLead.FinServ__ReferredByUser__c)) eachLead.Refer_From_User_Extension__c = userExtensionMapUserId.get(eachLead.FinServ__ReferredByUser__c).Id;
			if(userExtensionMapUserId.containsKey(eachLead.Refer_To_User__c)) eachLead.Refer_To_User_Extension__c = userExtensionMapUserId.get(eachLead.Refer_To_User__c).Id;
        }
	}

	public override void afterFinally(){
		updateOpportunityReferral();
		autoDeleteNewAccountTeam(listAccountTeamId);
	}

	private static void updateOpportunityReferral(){
		if(!Account_Service.isConvertLead){
			Map<Id,Opportunity> mapUpdateJob = new Map<Id,Opportunity>();
			for(Lead eachLead : (List<Lead>) Trigger.new){
				if(Trigger.oldMap == null){
					if(eachLead.Job__c != null){
						Opportunity newJob = new Opportunity(Id = eachLead.Job__c,Referral__c = eachLead.Id);
						mapUpdateJob.put(newJob.Id,newJob);
					}
				}else {
					Lead oldLead = (Lead)Trigger.oldMap.get(eachLead.id);
					if(eachLead.Job__c != oldLead.Job__c){
						if(oldLead.Job__c != null){
							Opportunity oldJob = new Opportunity(Id = oldLead.Job__c,Referral__c = null);
							mapUpdateJob.put(oldJob.Id,oldJob);
						}
						
						if(eachLead.Job__c != null){
							Opportunity newJob = new Opportunity(Id = eachLead.Job__c,Referral__c = eachLead.Id);
							mapUpdateJob.put(newJob.Id,newJob);
						}
					}
				}
			}

			if(!mapUpdateJob.values().isEmpty()){
				update mapUpdateJob.values();
			}
		}
	}

	private static List<Id> autoCreateNewAccountTeam(Set<Id> accountId){
		return Account_Service.createNewAccountTeam(new List<Id>(accountId), UserInfo.getUserId(),'Edit','None','None','Read');
    }

    private static void autoDeleteNewAccountTeam(List<Id> listAccountTeamId){
    	if(!listAccountTeamId.isEmpty()){
        	Database.delete(listAccountTeamId);
        }
    }
}