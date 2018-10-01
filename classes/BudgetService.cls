public without sharing class BudgetService {
	static final Id TRANSFER_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_DEVNAME);
	static final Id TRANSFER_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME);
	static final Id TRANSFER_BUDGET_APPROVE		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_APPROVE_DEVNAME);
	static final Id REQUEST_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_DEVNAME);
	static final Id REQUEST_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_READ_ONLY_DEVNAME);
	static final Id REQUEST_BUDGET_APPROVE		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_APPROVE_DEVNAME);
	
	static final Id DECREASE_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.DECREASE_BUDGET_ITEM_DEVNAME);
	static final Id INCREASE_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.INCREASE_BUDGET_ITEM_DEVNAME);
	static final Id REQUEST_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_ITEM_DEVNAME);

	private static Set<Id> budgetIdSet;
	private static Set<Id> transferBudgeIdSet;
	private static Set<Id> requestBudgetIdSet;
	private static Set<Id> mainBudgetIdSet;
	private static Set<Id> itemBudgetIdSet;

	private class noTeamStructureException extends Exception {}

	public static void stampInsertedMainBudget(List<Budget__c> insertedBudgetInfo) {
		setMainBudgetRecordTypeId();
		Id userId = userInfo.getUserId();
		User currentUser = [SELECT Id, RC_CODE__c FROM User WHERE Id = :userId LIMIT 1];
		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;
		List<Team_Structure__c> listTeam = [SELECT Id FROM Team_Structure__c WHERE OwnerId = :userId AND RC_CODE__c = :currentUser.RC_CODE__c];
		for(Budget__c insertedBudget : insertedBudgetInfo) {
			if(mainBudgetIdSet.contains(insertedBudget.recordTypeId) && listTeam != null && listTeam.size() > 0) {
				insertedBudget.Owner_Team_Name__c = listTeam[0].Id;
			}
		}
	}

	public static void createNewItemBudget(Map<Id, Budget__c> newBudgetInfoMapById, Map<Id, Budget__c> oldBudgetInfoMapById) {
		setMainBudgetRecordTypeId();
		List<Budget__c> newItemBudgetList = new List<Budget__c>();
		
		for(Budget__c newBudgetInfo : newBudgetInfoMapById.values()) {
			if(mainBudgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				Budget__c newItemBudget = new Budget__c();
				Budget__c oldMainBudgetInfo = oldBudgetInfoMapById.get(newBudgetInfo.Id);
				if(oldMainBudgetInfo.Account_Increase_Subtype__c == null 
				&& newBudgetInfo.Account_Increase_Subtype__c != null) {
					newItemBudget.Budget_ParentId__c			= newBudgetInfo.Id;
					newItemBudget.Team_Name__c 					= newBudgetInfo.Team_Name__c;
					newItemBudget.Account_Decrease_Type__c 		= newBudgetInfo.Account_Decrease_Type__c;
					newItemBudget.Account_Increase_Type__c 		= newBudgetInfo.Account_Increase_Type__c;
					newItemBudget.Account_Increase_Subtype__c 	= newBudgetInfo.Account_Increase_Subtype__c;
					newItemBudget.Increase_Amount__c			= newBudgetInfo.Increase_Amount__c;
					newItemBudget.Reason__c 					= newBudgetInfo.Reason__c;
					newItemBudget.recordTypeId					= INCREASE_BUDGET_ITEM;
					newItemBudgetList.add(newItemBudget);
				}
				else if(oldMainBudgetInfo.Account_Decrease_Subtype__c == null 
				&& newBudgetInfo.Account_Decrease_Subtype__c != null) {
					newItemBudget.Budget_ParentId__c			= newBudgetInfo.Id;
					newItemBudget.Team_Name__c 					= newBudgetInfo.Team_Name__c;
					newItemBudget.Account_Decrease_Type__c 		= newBudgetInfo.Account_Decrease_Type__c;
					newItemBudget.Account_Decrease_Subtype__c 	= newBudgetInfo.Account_Decrease_Subtype__c;
					newItemBudget.Total_Decrease__c				= newBudgetInfo.Total_Decrease__c;
					newItemBudget.Reason__c 					= newBudgetInfo.Reason__c;
					newItemBudget.recordTypeId					= DECREASE_BUDGET_ITEM;
					newItemBudgetList.add(newItemBudget);
				}
				else if(oldMainBudgetInfo.Account_Subtype__c == null 
				&& newBudgetInfo.Account_Subtype__c != null) {
					newItemBudget.Budget_ParentId__c			= newBudgetInfo.Id;
					newItemBudget.Team_Name__c 					= newBudgetInfo.Team_Name__c;
					newItemBudget.Account_Type__c				= newBudgetInfo.Account_Type__c;
					newItemBudget.Account_Subtype__c			= newBudgetInfo.Account_Subtype__c;
					newItemBudget.Increase_Amount__c			= newBudgetInfo.Increase_Amount__c;
					newItemBudget.Reason__c 					= newBudgetInfo.Reason__c;
					newItemBudget.recordTypeId					= REQUEST_BUDGET_ITEM;
					newItemBudgetList.add(newItemBudget);
				}
			}
		}
		try {
			if(!newItemBudgetList.isEmpty()) Database.insert(newItemBudgetList);
		}
		catch (DMLException e) {
			//throw only error label
			for (Integer i = 0; i < e.getNumDml(); i++) {
				Integer rowI = e.getDmlIndex(i);
				Id errorParentId = newItemBudgetList[rowI].Budget_ParentId__c;
				newBudgetInfoMapById.get(errorParentId).addError(e.getDMLMessage(i));
			}
			// throw new DMLException(errMsg.subString(errIndex, errMsg.indexOf(':', errIndex)));
		}
	}

	public static void clearAndStampMainBudgetFieldAfterCreateItemBudget(List<Budget__c> newMainBudgetInfoList, Map<Id, Budget__c> oldMainBudgetInfoMapById) {
		setMainBudgetRecordTypeId();
		List<Budget__c> updatedMainBudgetList = new List<Budget__c>();

		Map<Id, Budget__c> budgetInfoTeamNameMapById = getMainBudgetAdditionalInfoMapById(new Map<Id, Budget__c>(newMainBudgetInfoList).keySet());
		
		for(Budget__c newMainBudgetInfo : newMainBudgetInfoList) {
			if(mainBudgetIdSet.contains(newMainBudgetInfo.recordTypeId)) {
				Budget__c updatedMainBudget = new Budget__c();
				Budget__c mainBudgetAdditionalInfo 	= budgetInfoTeamNameMapById.get(newMainBudgetInfo.Id);
				Budget__c oldMainBudgetInfo = oldMainBudgetInfoMapById.get(newMainBudgetInfo.Id);
				if(oldMainBudgetInfo.Account_Increase_Subtype__c == null 
				&& newMainBudgetInfo.Account_Increase_Subtype__c != null) {
					updatedMainBudget.Id							= newMainBudgetInfo.Id;
					updatedMainBudget.Team_Name__c 					= null;
					updatedMainBudget.Account_Increase_Type__c		= null;
					updatedMainBudget.Account_Increase_Subtype__c	= null;
					updatedMainBudget.Increase_Amount__c			= 0;
					updatedMainBudget.Reason__c						= null;
					updatedMainBudget.Total_Increase__c				= newMainBudgetInfo.Total_Increase__c + newMainBudgetInfo.Increase_Amount__c;
					updatedMainBudget.Increase_Branch__c			= addingIncreaseBranchName(newMainBudgetInfo.Increase_Branch__c, mainBudgetAdditionalInfo.Team_Name__r.Name);
					updatedMainBudgetList.add(updatedMainBudget);
					}
				else if(oldMainBudgetInfo.Account_Decrease_Subtype__c == null 
				&& newMainBudgetInfo.Account_Decrease_Subtype__c != null) {
					updatedMainBudget.Id							= newMainBudgetInfo.Id;
					updatedMainBudget.Account_Decrease_Subtype__c	= null;
					updatedMainBudget.Team_Name__c 					= null;
					updatedMainBudget.Reason__c						= null;
					updatedMainBudget.Is_Code_Update__c				= true;
					updatedMainBudget.Is_Increase__c				= true;
					updatedMainBudget.Decrease_Branch__c			= addingIncreaseBranchName(newMainBudgetInfo.Decrease_Branch__c, mainBudgetAdditionalInfo.Team_Name__r.Name);
					updatedMainBudgetList.add(updatedMainBudget);
				}
				else if(oldMainBudgetInfo.Account_Subtype__c == null 
				&& newMainBudgetInfo.Account_Subtype__c != null) {
					updatedMainBudget.Id							= newMainBudgetInfo.Id;
					updatedMainBudget.Team_Name__c 					= null;
					updatedMainBudget.Account_Subtype__c			= null;
					updatedMainBudget.Increase_Amount__c			= 0;
					updatedMainBudget.Reason__c						= null;
					updatedMainBudget.Total_Increase__c				= newMainBudgetInfo.Total_Increase__c + newMainBudgetInfo.Increase_Amount__c;
					updatedMainBudget.Increase_Branch__c			= addingIncreaseBranchName(newMainBudgetInfo.Increase_Branch__c, mainBudgetAdditionalInfo.Team_Name__r.Name);
					updatedMainBudgetList.add(updatedMainBudget);
				}
			}
		}
		TriggerHandler.bypass('BudgetTriggerHandler');
		if(!updatedMainBudgetList.isEmpty()) update updatedMainBudgetList;
		TriggerHandler.clearBypass('BudgetTriggerHandler');
	}

	@testVisible
	private static Map<Id, Budget__c> getMainBudgetAdditionalInfoMapById(Set<Id> mainBudgetIdSet) {
		return new Map<Id, Budget__c>([
			SELECT Id, Stage__c, Total_Increase__c, Team_Name__r.Name
			FROM Budget__c
			WHERE Id IN :mainBudgetIdSet
		]);
	}

	@testVisible
	private static String addingIncreaseBranchName(String branchNameList, String newBranchName) {
		String newBranchNameList = '';
		if(String.isBlank(branchNameList)) {
			newBranchNameList = newBranchName  + ', ';
		}else {
			Set<String> branchNameSet = new Set<String>(branchNameList.split(', ')); 
			branchNameSet.add(newBranchName);
			for(String branchName : branchNameSet) {
				newBranchNameList += branchName + ', ';
			}
		}
		return newBranchNameList.substring(0, newBranchNameList.length() - 2);
	}

	public static void updateItemBudgetInfo(List<Budget__c> newItemBudgetInfoList, Map<Id, Budget__c> oldItemBudgetInfoMapById){
		setItemBudgetRecordTypeId();

		List<Budget__c> updatedMainBudgetList = new List<Budget__c>();
		Set<Id> mainBudgetOfChangedItemBudget = new Set<Id>();
		Set<Id> assignedTeamStructureIdSet = new Set<Id>();

		for(Budget__c newItemBudgetInfo : newItemBudgetInfoList) {
			if(itemBudgetIdSet.contains(newItemBudgetInfo.recordTypeId)) {
				assignedTeamStructureIdSet.add(newItemBudgetInfo.Team_Name__c);
				mainBudgetOfChangedItemBudget.add(newItemBudgetInfo.Budget_ParentId__c);
			}
		}
		Map<Id, Team_Structure__c> assignedTeamStructureMapById = getAssignedTeamStructureMapById(assignedTeamStructureIdSet);
		Map<Id, Budget__c> mainBudgetOfItemInfoMapById = getMainBudgetAdditionalInfoMapById(mainBudgetOfChangedItemBudget);
		Map<Id, List<Budget__c>> itemBudgetListMapByMainBudgetId = getItemBudgetListMapByMainBudgetId(mainBudgetOfChangedItemBudget);
		for(Budget__c newItemBudgetInfo : newItemBudgetInfoList) {
			Budget__c updatedMainBudget = new Budget__c();
			Budget__c oldItemBudgetInfo = oldItemBudgetInfoMapById.get(newItemBudgetInfo.Id);
			if(newItemBudgetInfo.recordTypeId == DECREASE_BUDGET_ITEM) {
				if(oldItemBudgetInfo.Account_Increase_Type__c != newItemBudgetInfo.Account_Increase_Type__c
				|| oldItemBudgetInfo.Total_Decrease__c != newItemBudgetInfo.Total_Decrease__c) {
					if(!isHaveDecreaseItemOnly(itemBudgetListMapByMainBudgetId.get(newItemBudgetInfo.Budget_ParentId__c))) {	
						newItemBudgetInfo.addError(Label.Budget_Not_Allow_To_Edit_Decrease_Budget);
					}
					if(oldItemBudgetInfo.Account_Decrease_Type__c != newItemBudgetInfo.Account_Decrease_Type__c) {
						updatedMainBudget.Id 						= newItemBudgetInfo.Budget_ParentId__c;
						updatedMainBudget.Account_Decrease_Type__c	= newItemBudgetInfo.Account_Decrease_Type__c;
					}
					if(oldItemBudgetInfo.Total_Decrease__c != newItemBudgetInfo.Total_Decrease__c) {
						updatedMainBudget.Id 					= newItemBudgetInfo.Budget_ParentId__c;
						updatedMainBudget.Total_Decrease__c 	= newItemBudgetInfo.Total_Decrease__c;
						updatedMainBudget.Is_Code_Update__c		= true;
					}
					updatedMainBudgetList.add(updatedMainBudget);
				}
			}else if(newItemBudgetInfo.recordTypeId == INCREASE_BUDGET_ITEM || newItemBudgetInfo.recordTypeId == REQUEST_BUDGET_ITEM) {
				Team_Structure__c assignedTeamStructure = assignedTeamStructureMapById.get(newItemBudgetInfo.Team_Name__c);
				Budget__c mainBudgetOfItemInfo = mainBudgetOfItemInfoMapById.get(newItemBudgetInfo.Budget_ParentId__c);
				List<Budget__c> siblingItemBudgetList = itemBudgetListMapByMainBudgetId.get(newItemBudgetInfo.Budget_ParentId__c);
				if(oldItemBudgetInfo.Team_Name__c != newItemBudgetInfo.Team_Name__c || oldItemBudgetInfo.Increase_Amount__c != newItemBudgetInfo.Increase_Amount__c) {
					if(oldItemBudgetInfo.Team_Name__c != newItemBudgetInfo.Team_Name__c) {
						updatedMainBudget.Id					= newitemBudgetInfo.Budget_ParentId__c;
						updatedMainBudget.Increase_Branch__c	= changeIncreaseBranchName(newItemBudgetInfo, assignedTeamStructure, siblingItemBudgetList, false);
					}
					if(oldItemBudgetInfo.Increase_Amount__c != newItemBudgetInfo.Increase_Amount__c) {
						updatedMainBudget.Id					= newitemBudgetInfo.Budget_ParentId__c;
						updatedMainBudget.Total_Increase__c 	= mainBudgetOfItemInfo.Total_Increase__c + (newItemBudgetInfo.Increase_Amount__c - oldItemBudgetInfo.Increase_Amount__c);
					}
					updatedMainBudgetList.add(updatedMainBudget);
				}
			}
		}

		TriggerHandler.bypass('BudgetTriggerHandler');
			if(!updatedMainBudgetList.isEmpty()) Database.update(updatedMainBudgetList);
		TriggerHandler.clearBypass('BudgetTriggerHandler');
	}

	@testVisible
	private static boolean isHaveDecreaseItemOnly(List<Budget__c> childrenBudgetList) {
		boolean isOnlyDecrease = false;
		if(childrenBudgetList.size() == 1 && childrenBudgetList[0].recordTypeId == DECREASE_BUDGET_ITEM) isOnlyDecrease = true;
		return isOnlyDecrease;
	}

	@testVisible
	private static Map<Id, Team_Structure__c> getAssignedTeamStructureMapById(Set<Id> teamStructureIdSet) {
		return new Map<Id, Team_Structure__c>([
			SELECT Id, Name
			FROM Team_Structure__c
			WHERE Id IN : teamStructureIdSet
		]);
	}

	@testVisible
	private static Map<Id, List<Budget__c>> getItemBudgetListMapByMainBudgetId(Set<Id> mainBudgetOfChangedItemBudget) {
		List<Budget__c> itemBudgetList = [
			SELECT Id, Budget_ParentId__c, Increase_Amount__c, Team_Name__r.Name, recordTypeId
			FROM Budget__c
			WHERE Budget_ParentId__c IN :mainBudgetOfChangedItemBudget
		];
		Map<Id, List<Budget__c>> itemBudgetListMapByMainBudgetId = new Map<Id, List<Budget__c>>();
		for(Budget__c itemBudget : itemBudgetList) {
			if(!itemBudgetListMapByMainBudgetId.containsKey(itemBudget.Budget_ParentId__c)) {
				itemBudgetListMapByMainBudgetId.put(itemBudget.Budget_ParentId__c, new List<Budget__c>());
			}
			itemBudgetListMapByMainBudgetId.get(itemBudget.Budget_ParentId__c).add(itemBudget);
		}
		return itemBudgetListMapByMainBudgetId;
	}

	@testVisible
	private static String changeIncreaseBranchName(Budget__c itemBudgetInfo, Team_Structure__c assignedTeamStructure, List<Budget__c> siblingItemBudgetList, boolean isItDelete) {
		String newBranchNameList = '';
		Set<Id> branchNameSet = new Set<Id>();
		for(Budget__c siblingItemBudget : siblingItemBudgetList) {
			if(itemBudgetInfo.Id != siblingItemBudget.Id && siblingItemBudget.recordTypeId != DECREASE_BUDGET_ITEM) {
				if(!branchNameSet.contains(siblingItemBudget.Team_Name__c)) {
					branchNameSet.add(siblingItemBudget.Team_Name__c);
					newBranchNameList += siblingItemBudget.Team_Name__r.Name + ', ';
				}
			}else if(siblingItemBudget.recordTypeId != DECREASE_BUDGET_ITEM && !isItDelete) {
				if(!branchNameSet.contains(itemBudgetInfo.Team_Name__c)) {
					branchNameSet.add(itemBudgetInfo.Team_Name__c);
					newBranchNameList += assignedTeamStructure.Name + ', ';
				}
			}
		}
		if(String.isBlank(newBranchNameList)){
			newBranchNameList = null;
		}else {
			newBranchNameList = newBranchNameList.substring(0, newBranchNameList.length() - 2);
		}
		return newBranchNameList;
	}

	public static void checkBudgetSubmissionAndStampRecordType(List<Budget__c> newBudgetInfoList, Map<Id, Budget__c> oldBudgetInfoMapById) {
		setBudgetRecordTypeId();
		setTransferBudgetRecordTypeId();
		setRequestBudgetRecordTypeId();

		Set<Id> budgetOwnerIdSet = new Set<Id>();
		Set<Id> approvedBudgetIdSet = new Set<Id>();

		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;

		for(Budget__c newBudgetInfo : newBudgetInfoList) {
			Budget__c oldBudgetInfo = oldBudgetInfoMapById.get(newBudgetInfo.Id);
			if((oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_OPEN && newBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE)
			|| (oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE && newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED)
			|| (oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE && newBudgetInfo.Stage__c == GlobalConstants.BUDGET_REJECTED)
			|| (oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_COLLECT_DOCUMENT && newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED)
			|| ((oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE || oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WITH_IN_PROCESS)
			 && (newBudgetInfo.Stage__c == GlobalConstants.BUDGET_INCORRECT || newBudgetInfo.Stage__c == GlobalConstants.BUDGET_REJECTED || newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED))
			|| (oldBudgetInfo.Approve_Results__c == null && newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_PROCESSED)
			|| (oldBudgetInfo.Approve_Results__c == null && newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_REFUSE)
			|| (oldBudgetInfo.Approve_Results__c == null && newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_REQUIRE_DOCUMENT)) {
				budgetOwnerIdSet.add(newBudgetInfo.OwnerId);
			}
			if(oldBudgetInfo.Approve_Results__c == null && newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_PROCESSED) {
				approvedBudgetIdSet.add(newBudgetInfo.Id);
			}
		}

		Map<Id, Set<Id>> itemBudgetTeamOwnerIdSetMapByMainBudgetId = getItemBudgetInfoSetMapByMainBudgetId(approvedBudgetIdSet);
		Map<Id, User> budgetOwnerMapById = getBudgetOwnermapById(budgetOwnerIdSet);
		List<User> budgetAdminList = getBudgetAdminList();

		for(Budget__c newBudgetInfo : newBudgetInfoList) {
			Budget__c oldBudgetInfo = oldBudgetInfoMapById.get(newBudgetInfo.Id);
			User budgetOwner 		= budgetOwnerMapById.get(oldBudgetInfo.OwnerId);

			if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_OPEN 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				if(oldBudgetInfo.recordTypeId == TRANSFER_BUDGET) {
					if(newBudgetInfo.Total_Decrease__c != newBudgetInfo.Total_Increase__c) {
						newBudgetInfo.addError(Label.Not_Allow_To_Submit_Transfer_Budget);
					}else if(profileName == GlobalConstants.RBS_NH) {
						newBudgetInfo.recordTypeId = convertToBudgetReadOnly(newBudgetInfo.recordTypeId);
						newBudgetInfo.Stage__c = GlobalConstants.BUDGET_APPROVED;
						Set<Id> itemBudgetTeamOwnerIdSet = itemBudgetTeamOwnerIdSetMapByMainBudgetId.get(newBudgetInfo.Id);
						if(budgetOwner != null) {
							String msg = 'คุณ';
							for(Integer i = 0; i < budgetAdminList.size(); i++) {
								msg += ' @' + budgetAdminList[i].id;
							}
							msg += ' ได้รับคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name; 
							msg += ' จากคุณ ' + budgetOwner.Name;
							GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
						}
					}else if(profileName == GlobalConstants.RBS_TM || profileName == GlobalConstants.RBS_AH){
						newBudgetInfo.recordTypeId = convertToBudgetApproved(newBudgetInfo.recordTypeId);
						newBudgetInfo.Is_Code_Update__c = false;
						if(budgetOwner != null) {
							String msg = 'คุณ @' + budgetOwner.ManagerId;
							msg += ' ได้รับคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
							msg += ' จากคุณ @' + budgetOwner.Id;
							GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
						}
					}
				}else if(oldBudgetInfo.recordTypeId == REQUEST_BUDGET) {
					if(profileName == GlobalConstants.RBS_TM || profileName == GlobalConstants.RBS_AH) {
						newBudgetInfo.recordTypeId = convertToBudgetApproved(newBudgetInfo.recordTypeId);
						newBudgetInfo.Is_Code_Update__c = false;
						if(budgetOwner != null) {
							String msg = 'คุณ @' + budgetOwner.ManagerId;
							msg += ' ได้รับคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
							msg += ' จากคุณ @' + budgetOwner.Id;
							GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
						}
					}
				}
			}
			else if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_OPEN 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				newBudgetInfo.recordTypeId = convertToBudget(newBudgetInfo.recordTypeId);
				newBudgetInfo.Is_Code_Update__c = false;
			}
			else if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_OPEN 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_CANCELLED 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				newBudgetInfo.recordTypeId = convertToBudgetReadOnly(newBudgetInfo.recordTypeId);
				newBudgetInfo.Is_Code_Update__c = false;
			}
			else if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				newBudgetInfo.recordTypeId = convertToBudgetReadOnly(newBudgetInfo.recordTypeId);
				newBudgetInfo.Is_Code_Update__c = true;
				if(budgetOwner != null) {
					String msg = 'คุณ';
					for(Integer i = 0; i < budgetAdminList.size(); i++) {
						msg += ' @' + budgetAdminList[i].id;
					}
					msg += ' ได้รับคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name; 
					msg += ' จากคุณ ' + budgetOwner.Name;
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				
					msg = 'คำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
					msg += ' ของคุณ @' + budgetOwner.Id;
					msg += ' ได้รับการอนุมัติจากคุณ @' + budgetOwner.ManagerId;
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
			}
			else if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_REJECTED 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				newBudgetInfo.recordTypeId = convertToBudgetReadOnly(newBudgetInfo.recordTypeId);
				newBudgetInfo.Is_Code_Update__c = true;
				if(budgetOwner != null) {
					String msg = 'คำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
					msg += ' ของคุณ @' + budgetOwner.Id;
					msg += ' ถูกปฎิเสธจากคุณ @' + budgetOwner.ManagerId;
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
			}
			else if(oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_COLLECT_DOCUMENT 
			&& newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				newBudgetInfo.Is_Code_Update__c = true;
				if(budgetOwner != null) {
					String msg = 'คุณ';
					for(Integer i = 0; i < budgetAdminList.size(); i++) {
						msg += ' @' + budgetAdminList[i].id;
					}
					msg += ' ได้รับคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name; 
					msg += ' จากคุณ @' + budgetOwner.Id;
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
			}
			else if(oldBudgetInfo.Approve_Results__c == null 
			&& budgetIdSet.contains(newBudgetInfo.recordTypeId)){
				if(newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_PROCESSED) {
					Set<Id> itemBudgetTeamOwnerIdSet = itemBudgetTeamOwnerIdSetMapByMainBudgetId.get(newBudgetInfo.Id);
					newBudgetInfo.Stage__c = GlobalConstants.BUDGET_COMPLETE;
					newBudgetInfo.Approve_Results__c = null;
					newBudgetInfo.Is_Code_Update__c = false;

					if(itemBudgetTeamOwnerIdSet != null) {
						String msg = 'คุณ';
						for(Id eachTeamOwnerId : itemBudgetTeamOwneridSet) {
									msg += ' @' + eachTeamOwnerId;
						}
						msg += ' สาขาของคุณถูกเลือกในคำขออนุมัติงบประมาณ ' + newBudgetInfo.Name; 
						msg += ' โดยคุณ ' + budgetOwner.Name;							
						GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
					}

					if(budgetOwner != null) {
						String msg = 'คำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
						msg += ' ของคุณ @' + budgetOwner.Id;
						msg += ' ได้รับการอนุมัติจากทีม Budget แล้ว';
						GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
					}
				}else if(newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_REFUSE) {
					newBudgetInfo.Stage__c = GlobalConstants.BUDGET_CONTACT_BUDGET_ADMIN;
					newBudgetInfo.Approve_Results__c = null;
					newBudgetInfo.Is_Code_Update__c = false;
					if(budgetOwner != null) {
						String msg = 'คำขออนุมัติงบประมาณ ' + newBudgetInfo.Name;
						msg += ' ของคุณ @' + budgetOwner.Id;
						msg += ' ถูกปฎิเสธจากทีม Budget';
						GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
					}
				}else if(newBudgetInfo.Approve_Results__c == GlobalConstants.BUDGET_APPROVE_REQUIRE_DOCUMENT) {
					newBudgetInfo.Stage__c = GlobalConstants.BUDGET_COLLECT_DOCUMENT;
					newBudgetInfo.Approve_Results__c = null;
					newBudgetInfo.Is_Code_Update__c = false;
					if(budgetOwner != null) {
						String msg = 'ทีม Budget ต้องการเอกสารเพิ่มเติมเพื่อพิจราณาคำขออนุมัติงบประมาณ @' + budgetOwner.Id;
						GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
					}
				}
			}
			else if((oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE || oldBudgetInfo.Stage__c == GlobalConstants.BUDGET_WITH_IN_PROCESS) && !budgetIdSet.contains(newBudgetInfo.recordTypeId)) {
				if(newBudgetInfo.Stage__c == GlobalConstants.BUDGET_INCORRECT && budgetOwner != null) {
					String msg = 'คุณ @' + budgetOwner.Id;
					msg += '  ทีม Veto ต้องการให้แก้ไขข้อมูลหรือแนบเอกสารเพิ่มเติม เพื่อพิจราณาคำขอ Veto ' + newBudgetInfo.Name;
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
				else if(newBudgetInfo.Stage__c == GlobalConstants.BUDGET_REJECTED && budgetOwner != null) {
					String msg = 'คำขอการ Veto ' + newBudgetInfo.Name;
					msg += ' ของคุณ @' + budgetOwner.Id;
					msg += ' ถูกปฏิเสธจากทีม Veto';
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
				else if(newBudgetInfo.Stage__c == GlobalConstants.BUDGET_APPROVED && budgetOwner != null) {
					String msg = 'คำขอการ Veto ' + newBudgetInfo.Name;
					msg += ' ของคุณ @' + budgetOwner.Id;
					msg += ' ได้รับการอนุมัติจากทีม Veto';
					GlobalUtility.createNotifyingChatter(newBudgetInfo.Id, msg);
				}
			}
		}
	}

	@testVisible
	private static Id convertToBudgetReadOnly(Id recTypeId) {
		if(transferBudgeIdSet.contains(recTypeId)) recTypeId = TRANSFER_BUDGET_READ_ONLY;
		else if(requestBudgetIdSet.contains(recTypeId)) recTypeId = REQUEST_BUDGET_READ_ONLY;
		return recTypeId;
	}

	@testVisible
	private static Id convertToBudgetApproved(Id recTypeId) {
		if(transferBudgeIdSet.contains(recTypeId)) recTypeId = TRANSFER_BUDGET_APPROVE;
		else if(requestBudgetIdSet.contains(recTypeId)) recTypeId = REQUEST_BUDGET_APPROVE;
		return recTypeId;
	}

	@testVisible
	private static Id convertToBudget(Id recTypeId) {
		if(transferBudgeIdSet.contains(recTypeId)) recTypeId = TRANSFER_BUDGET;
		else if(requestBudgetIdSet.contains(recTypeId)) recTypeId = REQUEST_BUDGET;
		return recTypeId;
	}

	@testVisible
	private static Map<Id, User> getBudgetOwnerMapById(Set<Id> budgetOwnerIdSet) {
		return new Map<Id, User>([
			SELECT Id, Name, ManagerId 
			FROM User
			WHERE Id IN :budgetOwnerIdSet
		]);
	}

	@testVisible
	private static List<User> getBudgetAdminList() {
		return new List<User> ([
			SELECT Id
			FROM User
			WHERE Profile.Name = :GlobalConstants.RBS_BUDGET_ADMIN
		]);
	}

	@testVisible
	private static Map<Id, Set<Id>> getItemBudgetInfoSetMapByMainBudgetId(Set<Id> approvedMainBudgetIdSet){
		Map<Id, Set<Id>> itemBudgetTeamOwnerIdSetMapByMainBudgetId = new Map<Id, Set<Id>>();
		List<Budget__c> approvedItemBudgetList = [
			SELECT Id, Budget_ParentId__c, Team_Name__r.OwnerId
			FROM Budget__c
			WHERE Budget_ParentId__c IN :approvedMainBudgetIdSet
		];

		for(Budget__c approvedItemBudget : approvedItemBudgetList) {
				if(!itemBudgetTeamOwnerIdSetMapByMainBudgetId.containsKey(approvedItemBudget.Budget_ParentId__c)) {
					itemBudgetTeamOwnerIdSetMapByMainBudgetId.put(approvedItemBudget.Budget_ParentId__c, new Set<Id>());
				}
				itemBudgetTeamOwnerIdSetMapByMainBudgetId.get(approvedItemBudget.Budget_ParentId__c).add(approvedItemBudget.Team_Name__r.OwnerId);
		}
		return itemBudgetTeamOwnerIdSetMapByMainBudgetId;
	}

	public static void deleteBudget(List<Budget__c> deletedBudgetInfoList) {
		setItemBudgetRecordTypeId();
		setBudgetRecordTypeId();
		Id profileId = userInfo.getProfileId();
		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;

		Set<Id> mainBudgetOfDeletedItemIdSet = new Set<Id>();
		List<Budget__c> updatedMainList = new List<Budget__c>();

		for(Budget__c deletedBudgetInfo : deletedBudgetInfoList) {
			if(budgetIdSet.contains(deletedBudgetInfo.recordTypeId)) {
				if(deletedBudgetInfo.Budget_ParentId__c == null) {
					//delete main budget
					if(!Label.Profile_can_delete_budget.contains(profileName)) deletedBudgetInfo.addError(Label.Not_Allow_To_Delete_Decrease_Budget);
				}else if(deletedBudgetInfo.Budget_ParentId__c != null) {
					//delete item budget
					mainBudgetOfDeletedItemIdSet.add(deletedBudgetInfo.Budget_ParentId__c);
				}
			}
		}

		Map<Id, Budget__c> mainBudgetOfItemInfoMapById = getMainBudgetAdditionalInfoMapById(mainBudgetOfDeletedItemIdSet);
		Map<Id, List<Budget__c>> itemBudgetListMapByMainBudgetId = getItemBudgetListMapByMainBudgetId(mainBudgetOfDeletedItemIdSet);

		for(Budget__c deletedBudgetInfo : deletedBudgetInfoList) {
			if(itemBudgetIdSet.contains(deletedBudgetInfo.recordTypeId)) {
				if(deletedBudgetInfo.OwnerId == userInfo.getUserId() && !Label.Profile_can_delete_budget.contains(profileName)) {
					if(deletedBudgetInfo.recordTypeId == INCREASE_BUDGET_ITEM 
					|| deletedBudgetInfo.recordTypeId == REQUEST_BUDGET_ITEM) {
						Budget__c mainBudgetOfItemInfo = mainBudgetOfItemInfoMapById.get(deletedBudgetInfo.Budget_ParentId__c);
						if(mainBudgetOfItemInfo.Stage__c != GlobalConstants.BUDGET_OPEN){
							deletedBudgetInfo.addError(Label.Not_Allow_To_Delete_Decrease_Budget);
						}else {
							Budget__c updatedMain = deletedIncreaseItemBudget(deletedBudgetInfo, mainBudgetOfItemInfo, itemBudgetListMapByMainBudgetId.get(deletedBudgetInfo.Budget_ParentId__c));
							updatedMainList.add(updatedMain);
						}
					}else {
						deletedBudgetInfo.addError(Label.Not_Allow_To_Delete_Decrease_Budget);
					}
				}else if(!Label.Profile_can_delete_budget.contains(profileName)) deletedBudgetInfo.addError(Label.Not_Allow_To_Delete_Decrease_Budget);
			}
		}
		TriggerHandler.bypass('BudgetTriggerHandler');
			if(!updatedMainList.isEmpty()) Database.update(updatedMainList);
		TriggerHandler.clearBypass('BudgetTriggerHandler');
	}

	@testVisible
	private static Budget__c deletedIncreaseItemBudget(Budget__c item, Budget__c mainBudgetOfItemInfo, List<Budget__c> siblingItemBudgetList) {
		Budget__c updatedMain = new Budget__c();
		updatedMain.Id					= item.Budget_ParentId__c;
		updatedMain.Increase_Branch__c 	= changeIncreaseBranchName(item, null, siblingItemBudgetList, true);
		updatedMain.Is_Code_Update__c	= true;
		updatedMain.Total_Increase__c 	= mainBudgetOfItemInfo.Total_Increase__c - item.Increase_Amount__c;
		return updatedMain;
	}
	
	@testVisible
	private static Set<Id> setBudgetRecordTypeId() {
		budgetIdSet = new Set<Id>();
		budgetIdSet.add(TRANSFER_BUDGET);
		budgetIdSet.add(TRANSFER_BUDGET_APPROVE);
		budgetIdSet.add(TRANSFER_BUDGET_READ_ONLY);
		budgetIdSet.add(REQUEST_BUDGET);
		budgetIdSet.add(REQUEST_BUDGET_APPROVE);
		budgetIdSet.add(REQUEST_BUDGET_READ_ONLY);
		budgetIdSet.add(DECREASE_BUDGET_ITEM);
		budgetIdSet.add(INCREASE_BUDGET_ITEM);
		budgetIdSet.add(REQUEST_BUDGET_ITEM);
		return budgetIdSet;
	}

	@testVisible
	private static Set<Id> setTransferBudgetRecordTypeId() {
		transferBudgeIdSet = new Set<Id>();
		transferBudgeIdSet.add(TRANSFER_BUDGET);
		transferBudgeIdSet.add(TRANSFER_BUDGET_APPROVE);
		transferBudgeIdSet.add(TRANSFER_BUDGET_READ_ONLY);
		transferBudgeIdSet.add(DECREASE_BUDGET_ITEM);
		transferBudgeIdSet.add(INCREASE_BUDGET_ITEM);
		return transferBudgeIdSet;
	}
	
	@testVisible
	private static Set<Id> setRequestBudgetRecordTypeId() {
		requestBudgetIdSet = new Set<Id>();
		requestBudgetIdSet.add(REQUEST_BUDGET);
		requestBudgetIdSet.add(REQUEST_BUDGET_APPROVE);
		requestBudgetIdSet.add(REQUEST_BUDGET_READ_ONLY);
		requestBudgetIdSet.add(REQUEST_BUDGET_ITEM);
		return requestBudgetIdSet;
	}

	@testVisible
	private static Set<Id> setMainBudgetRecordTypeId() {
		mainBudgetIdSet = new Set<Id>();
		mainBudgetIdSet.add(TRANSFER_BUDGET);
		mainBudgetIdSet.add(TRANSFER_BUDGET_APPROVE);
		mainBudgetIdSet.add(TRANSFER_BUDGET_READ_ONLY);
		mainBudgetIdSet.add(REQUEST_BUDGET);
		mainBudgetIdSet.add(REQUEST_BUDGET_APPROVE);
		mainBudgetIdSet.add(REQUEST_BUDGET_READ_ONLY);
		return mainBudgetIdSet;
	}

	@testVisible
	private static Set<Id> setItemBudgetRecordTypeId() {
		itemBudgetIdSet = new Set<Id>();
		itemBudgetIdSet.add(DECREASE_BUDGET_ITEM);
		itemBudgetIdSet.add(INCREASE_BUDGET_ITEM);
		itemBudgetIdSet.add(REQUEST_BUDGET_ITEM);
		return itemBudgetIdSet;
	}
}