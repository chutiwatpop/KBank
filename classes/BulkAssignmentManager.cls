public without sharing class BulkAssignmentManager extends OwnershipAssignmentManager {
	
	// Expected value => inactive || change Jobcode || change Rc Code UserMap
	private Map<Id,User_MaskModel> userMaskMapByUserId;
	// ***************************************** //
	private User_Admin__c userAdmin;
	private Map<String, User> userMapByNewRoleRC;
	private Map<String,Team_Structure__c> teamStructureMapByRc;

	private List<Account> accountList;
	private Map<Id,User> userMap;

	private Bulk_Assignment_Queue__c bulkAssignmentQueue;
	private List<Bulk_Assignment__c> bulkAssignList;
	private Boolean isFromBulkReassign;

	public BulkAssignmentManager(Map<Id,User_MaskModel> userMaskMapByUserId) {
		this.userMaskMapByUserId = userMaskMapByUserId;
		this.userAdmin = User_Admin__c.getOrgDefaults();
		this.isFromBulkReassign = false;
		User_Service.getAllProfile();
		init();
	}

	public BulkAssignmentManager(List<Bulk_Assignment_Queue__c> bulkAssignmentQueues){
		this.bulkAssignmentQueue = [SELECT Id,Status__c,FinishTime__c FROM Bulk_Assignment_Queue__c WHERE Id = :bulkAssignmentQueues.get(0).id AND Status__c = 'Execute'];
		this.isFromBulkReassign = true;
		this.bulkAssignList = [SELECT Id, BulkAssignmentQueue__c, CIS_ID__c,CIS_ID__r.Owner.Profile.Name,CIS_ID__r.Dual_RM_Name__c, Created_Source__c,
			Permanent_Owner__c, CurrentOwner__c, Port_Pool__c, Ownership__c, 
			Service_RM__c, Process__c, Status__c, 
			AssignmentOwner__c,AssignmentOwner__r.Profile.Name, 
			SME_Temporary_Customer__c,
			Assignment_Dual_Owner__c,Assignment_Dual_Owner__r.Profile.Name,Port_Pool_Dual_RM__c,
			AF_Temporary_Customer__c,AF_Port2__c
		FROM Bulk_Assignment__c 
		WHERE BulkAssignmentQueue__r.Status__c = 'Execute' AND BulkAssignmentQueue__c = :bulkAssignmentQueue.Id];
		Set<Id> userIds = new Set<Id>();
		for(Bulk_Assignment__c eachAssignment : bulkAssignList) {
            if(eachAssignment.SME_Temporary_Customer__c != null ){
            	userIds.add(eachAssignment.SME_Temporary_Customer__c);
            }
        }
		setUpUsersMap(userIds);
	}

	public void createBulkAssignment(){
		List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
		for(Account eachAccount : accountList){
			IOwnershipAssignment ownershipAssigner;
			//Identify account segment by owner

   			if(userMaskMapByUserId.containsKey(eachAccount.OwnerId)){
   				User_MaskModel eachMask = userMaskMapByUserId.get(eachAccount.OwnerId);
	   			if(eachMask.isOldSMEProfile){
	            	ownershipAssigner = new SMEOwnershipAssignment(userMaskMapByUserId, teamStructureMapByRc, userMap, userMapByNewRoleRC, userAdmin);
	            }else if(eachMask.isOldAFProfile){
	            	ownershipAssigner = new AFOwnershipAssignment(userMaskMapByUserId, teamStructureMapByRc, userMap, userAdmin);
	            }
	            //else if(eachMask.isOldCBSProfile){
	            //	ownershipAssigner = new CBSOwnershipAssignment(userMaskMapByUserId, teamStructureMapByRc, userMap, userAdmin);
	            //}
	        }

			Bulk_Assignment__c bulkAssignment = new Bulk_Assignment__c(CIS_ID__c = eachAccount.Id,
	            Port_Pool__c = eachAccount.Port_Pool__c,
	            Ownership__c = eachAccount.Ownership_Text__c,
	            Created_Source__c = GlobalConstants.BULKASSIGNMENT_SOURCE_HRIS
			);
			BulkAssignmentWrapper bulkWrapper = new BulkAssignmentWrapper(bulkAssignment);

			// if not implement should not executed
			if(ownershipAssigner != null){
		        ownershipAssigner.setBulkAssignmentInfo(bulkWrapper, eachAccount);
		        bulkWrapper.setShouldAssignedBulk(ownershipAssigner.isAccountSetted());
	    	}
	        // should execute in all Segment
            setAssignedDualCustomerOwner(bulkWrapper, eachAccount);
            setAssigneAFTempCustomerOwner(bulkWrapper, eachAccount);
            setAssignedSMETempCustomerOwner(bulkWrapper, eachAccount);
            if(bulkWrapper.setShouldAssignedBulk){
            	bulkAssignList.add(bulkAssignment);
            }
	       	
		}
		setBulkAssignment(bulkAssignList);
	}

	public void setAccountInfoFromBulkInfo(){
		List<Account> accountList = new List<Account>();
		for(Bulk_Assignment__c eachAssignment : bulkAssignList){
			IBulkAssignmentAccountSetter accountSetter;
			if((eachAssignment.Status__c == GlobalConstants.STATUS_NEW || eachAssignment.Status__c == GlobalConstants.APPROVED) &&
				eachAssignment.Process__c
			){
                Account eachAccount = new Account( Id = eachAssignment.CIS_ID__c,
                	is_from_Bulk_Reassign__c = isFromBulkReassign,
                	OwnerChangeExecutedByTrigger__c = true,
                	Ownership_Text__c = eachAssignment.Ownership__c
                );
                if(eachAssignment.Created_Source__c == GlobalConstants.BULKASSIGNMENT_SOURCE_HRIS){
                	accountSetter = new HRISBulkAssignmentAccountSetter(userMap);
                }else{
                	 if(eachAssignment.Created_Source__c == GlobalConstants.BULKASSIGNMENT_SOURCE_SME ){
	                	accountSetter = new SMEBulkAssignmentAccountSetter(userMap);
	                }else if(eachAssignment.Created_Source__c == GlobalConstants.BULKASSIGNMENT_SOURCE_AF){
	                	accountSetter = new AFBulkAssignmentAccountSetter();
	                }
	                //else if(eachAssignment.Created_Source__c == GlobalConstants.BULKASSIGNMENT_SOURCE_CBS){
	                //	accountSetter = new CBSBulkAssignmentAccountSetter();
	                //}
                }

                if(accountSetter != null){
	                accountSetter.setAccountInfo(eachAccount,eachAssignment);
	            }
      			accountList.add(eachAccount);
            }
		}
		setAccounts(accountList);
	}

	private void setAssignedDualCustomerOwner(BulkAssignmentWrapper bulkWrapper,Account account){	
		User_MaskModel userMask;
		Bulk_Assignment__c bulkAssignment = bulkWrapper.bulkAssignment;
		if(account.Dual_RM_Name__c != null && userMaskMapByUserId.containsKey(account.Dual_RM_Name__c)){
			userMask = userMaskMapByUserId.get(account.Dual_RM_Name__c);
			if(userMask.isChangeToInactive || (userMask.isChangeRCCode && userMask.isChangeSegment)){
				User assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
				if(assignedUser != null){
					bulkAssignment.Assignment_Dual_Owner__c = assignedUser.id;
					bulkWrapper.setShouldAssignedBulk(true);
				}
			}
		}
	}

	private void setAssigneAFTempCustomerOwner(BulkAssignmentWrapper bulkWrapper,Account account){
		System.debug('Debug -- setAssigneAFTempCustomerOwner');
		User_MaskModel userMask;
		Bulk_Assignment__c bulkAssignment = bulkWrapper.bulkAssignment;
		if(account.AF_Temporary_Customer__c != null && userMaskMapByUserId.containsKey(account.AF_Temporary_Customer__r.User__c)){
			userMask = userMaskMapByUserId.get(account.AF_Temporary_Customer__r.User__c);
			if(userMask.isChangeToInactive || (userMask.isChangeRCCode && userMask.isChangeSegment)){
				User assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
				System.debug('Debug -- assignedUser ::'+assignedUser);
				if(assignedUser != null && assignedUser.User_Extension__r != null){
					bulkAssignment.AF_Temporary_Customer__c = assignedUser.User_Extension__r[0].id;
					bulkWrapper.setShouldAssignedBulk(true);
				}
			}
		}
	}

	private void setAssignedSMETempCustomerOwner(BulkAssignmentWrapper bulkWrapper, Account account){
		User_MaskModel userMask;
		Bulk_Assignment__c bulkAssignment = bulkWrapper.bulkAssignment;
		if(account.SME_Temporary_Customer__c != null && userMaskMapByUserId.containsKey(account.SME_Temporary_Customer__r.User__c) ){
			userMask = userMaskMapByUserId.get(account.SME_Temporary_Customer__r.User__c);
			if(userMask.isChangeToInactive || userMask.isChangeRCCode){
				User assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
				if(assignedUser == null){
					assignedUser = OwnershipAssignmentManager.getAdminFromUserMask(userMask,userAdmin, userMap);
				}
				if(assignedUser != null){
					bulkAssignment.SME_Temporary_Customer__c = assignedUser.id;
					bulkWrapper.setShouldAssignedBulk(true);
				}
			}
		}

	}

	public void updateAccount(){
		System.debug('Debug -- updateAccount');
		if(!accountList.isEmpty()){
            String errorMessage = '';
            try{
            	System.debug('Debug -- accountList ::'+accountList);
                Database.SaveResult[] srList =  executeUpdate(accountList,false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = errorMessage + String.valueOf(err.getMessage()) + '\n';
                        }
                    }
                }
                if(errorMessage != ''){
                	System.debug('Debug -- errorMessage ::'+errorMessage);
                    BulkAssignment_Email_Error__c customSettingMap = BulkAssignment_Email_Error__c.getInstance();
                    if(customSettingMap.toRecipients__c != null && customSettingMap.toRecipients__c != '' && customSettingMap.subjectMessage__c != null && customSettingMap.subjectMessage__c != ''){
                        String[] toRecipients = customSettingMap.toRecipients__c.split(',');
                        String[] ccRecipients = customSettingMap.ccRecipients__c.split(',');
                        GlobalUtility.sendEmail(toRecipients, ccRecipients, customSettingMap.senderDisplayName__c, customSettingMap.subjectMessage__c, errorMessage);
                    }
                }
            }catch(Exception e){
                errorMessage = errorMessage + String.valueOf(e.getMessage()) + '\n';
            }
        }
	}

	private void init(){
		setUpTeamStructureMap();
		Set<Id> userIds = new Set<Id>();
		for(Team_Structure__c eachTeam : teamStructureMapByRc.values()){
			userIds.add(eachTeam.OwnerId);
		}
		userIds.addAll(super.getAdminIds(userAdmin));
		setUpUsersMap(userIds);
		setUserMapByNewRoleRC();
		setUpAccount();	
	}

	private void setUpTeamStructureMap(){
		this.teamStructureMapByRc = super.getTeamStructureMapByRCCode();
	}

	private void setUpUsersMap(Set<Id> userIds){
		this.userMap = super.getUsersMap(userIds);
	}
	private void setUpAccount(){
		this.accountList = (List<Account>)getObjectList();
	}

	public override List<SObject> getObjectList(){
		List<Account> accountList = [SELECT Id, Permanent_Owner_Extension__c, Permanent_Owner_Extension__r.User__c, Ownership_Text__c, Port_Pool__c, Service_RM__c, 
		OwnerId, Owner.Profile.Name, Owner.Employee_Id__c, Owner.RC_Code__c, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Owner.Job_Code__c, Owner.ManagerId,
		SME_Temporary_Customer__c,SME_Temporary_Customer__r.User__c,SME_Temporary_Customer__r.User__r.Employee_Id__c,
		Dual_RM_Name__c,Dual_RM_Name__r.Employee_Id__c,AF_Temporary_Customer__c,AF_Temporary_Customer__r.User__c,AF_Temporary_Customer__r.User__r.Employee_Id__c
		FROM Account 
		WHERE (OwnerId IN :userMaskMapByUserId.keySet()) OR 
			SME_Temporary_Customer__r.User__c IN :userMaskMapByUserId.keySet() OR
			Service_RM__c IN :userMaskMapByUserId.keySet() OR
			Dual_RM_Name__c IN :userMaskMapByUserId.keySet() OR
			AF_Temporary_Customer__r.User__c IN :userMaskMapByUserId.keySet()
		];
		return accountList;
	}

	private void setUserMapByNewRoleRC(){
		this.userMapByNewRoleRC = super.getUserMapByNewRoleRC(this.userMaskMapByUserId);
  	}

	public void insertBulkAssignmentQueueAndBulkAssignment(){
		this.bulkAssignmentQueue = new Bulk_Assignment_Queue__c();
			bulkAssignmentQueue.Status__c = 'Create';
			bulkAssignmentQueue.StartTime__c = System.now();
		insert this.bulkAssignmentQueue;
		for(Bulk_Assignment__c eachAssign : this.bulkAssignList) {
			eachAssign.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
			eachAssign.Process__c = true;
			eachAssign.Status__c = GlobalConstants.STATUS_NEW;
		}
		insert this.bulkAssignList;
	}

	public void completeJobUpdateBulkQueueAndBulkAssignmentStatus(){
		this.bulkAssignmentQueue.Status__c = GlobalConstants.COMPLETE;
		this.bulkAssignmentQueue.FinishTime__c = System.now();
		for(Bulk_Assignment__c eachAssignment : bulkAssignList){
			if(eachAssignment.Status__c == GlobalConstants.STATUS_NEW){
                    eachAssignment.Status__c = GlobalConstants.COMPLETE;
                }
            eachAssignment.Process__c = false;
		}
		update this.bulkAssignmentQueue;
		TriggerHandler.bypass('BulkAssignmentTriggerHandler');
		update this.bulkAssignList;
		TriggerHandler.clearBypass('BulkAssignmentTriggerHandler');
	}

	public void setBulkAssignment(List<Bulk_Assignment__c> bulkAssignList){
		this.bulkAssignList = bulkAssignList;
	}
	public List<Bulk_Assignment__c> getBulkAssignments(){
		return this.bulkAssignList;
	}
	public void setAccounts(List<Account> accountList){
		this.accountList = accountList;
	}

}