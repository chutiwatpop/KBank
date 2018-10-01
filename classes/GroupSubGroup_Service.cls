//Pan Rein 31052017

public without sharing class GroupSubGroup_Service {

    private class groupSubgroupJunction{
        public Account account;
        public String beforeUpdateGroupSubgroupID;
        public String updatedGroupSubgroupID;
        public groupSubgroupJunction(Account account,String beforeUpdateGroupSubgroupID,String updatedGroupSubgroupID){
            this.account = account;
            this.beforeUpdateGroupSubgroupID = beforeUpdateGroupSubgroupID;
            this.updatedGroupSubgroupID = updatedGroupSubgroupID;
        }
    }

    public static List<Account> assignValuesForToCreateAccount(List<Account> accounts){
        List<Account> toUpdateAccounts = new List<Account>();
        for(Account account:accounts){
            Id updatedGroupSubgroup = account.Group_Sub_Group__c;
            boolean accountGroupSubgroupIsNull = (updatedGroupSubgroup != null);
            boolean isInAllowedSegments = GlobalConstants.CBS_SEGMENT_CODE_SET.contains(account.Primary_Segment_Code__c);
            if(accountGroupSubgroupIsNull && isInAllowedSegments){
                toUpdateAccounts.add(account);
            }   
        }
        Set<Id>groupSubgroupIDsFromAccounts = new Set<Id>();
        for(Account account:toUpdateAccounts){
            groupSubgroupIDsFromAccounts.add(account.Group_Sub_Group__c);
        }
        Map<String,Group_Sub_Group__c>groupSubgroupMap = new Map<String,Group_Sub_Group__c>();
        if(groupSubgroupIDsFromAccounts.size() > 0){
            List<Group_Sub_Group__c>groupSubgroups = [SELECT Id,Group_Lookup__c,Sub_Group_Lookup__c,Group_Lookup__r.Group_Name__c,Sub_Group_Lookup__r.Sub_Group_Name__c FROM Group_Sub_Group__c WHERE Id IN: groupSubgroupIDsFromAccounts];
            for(Group_Sub_Group__c groupSubgroup:groupSubgroups){
                groupSubgroupMap.put(groupSubgroup.Id,groupSubgroup);
            }   
        }
        for(Account account:toUpdateAccounts){
            account.Group_Sub_Group_Transaction_Update__c = true;
            account.Group__c = groupSubgroupMap.get(account.Group_Sub_Group__c).Group_Lookup__r.Group_Name__c;
            account.Sub_Group__c = groupSubgroupMap.get(account.Group_Sub_Group__c).Sub_Group_Lookup__r.Sub_Group_Name__c;
        }
        return toUpdateAccounts;
    }
    public static List<Account> assignValuesForToUpdateAccount(List<Account> accounts,Map<Id,Account> beforeUpdateAccounts){
        List<Account> toUpdateAccounts = new List<Account>();
        for(Account account:accounts){
            Id updatedGroupSubgroup = account.Group_Sub_Group__c;
            boolean accountGroupSubgroupIsNull = (updatedGroupSubgroup != null);
            boolean isInAllowedSegments = GlobalConstants.CBS_SEGMENT_CODE_SET.contains(account.Primary_Segment_Code__c);
            if(accountGroupSubgroupIsNull && isInAllowedSegments){
                toUpdateAccounts.add(account);
            }   
        }
        Set<Id>groupSubgroupIDsFromAccounts = new Set<Id>();
        for(Account account:toUpdateAccounts){
            groupSubgroupIDsFromAccounts.add(account.Group_Sub_Group__c);
        }
        Map<String,Group_Sub_Group__c> groupSubgroupMap = new Map<String,Group_Sub_Group__c>();
        if(groupSubgroupIDsFromAccounts.size() > 0){
            List<Group_Sub_Group__c>groupSubgroups = [SELECT Id,Group_Lookup__c,Sub_Group_Lookup__c,Group_Lookup__r.Group_Name__c,Sub_Group_Lookup__r.Sub_Group_Name__c FROM Group_Sub_Group__c WHERE Id IN: groupSubgroupIDsFromAccounts];
            for(Group_Sub_Group__c groupSubgroup:groupSubgroups){
                groupSubgroupMap.put(groupSubgroup.Id,groupSubgroup);
            }   
        }
        for(Account account : toUpdateAccounts){
            account.Group_Sub_Group_Transaction_Update__c = true;
            account.Group__c = groupSubgroupMap.get(account.Group_Sub_Group__c).Group_Lookup__r.Group_Name__c;
            account.Sub_Group__c = groupSubgroupMap.get(account.Group_Sub_Group__c).Sub_Group_Lookup__r.Sub_Group_Name__c;
        }
        return toUpdateAccounts;
    }
    //When create new account if that account has groupsubgroup create customergroupsubgroup and set Group_Sub_Group_Transaction_Update__c to true
    public static void insertCustomerGroupSubgroup(List<Account> accounts){
        List<Customer_Group_Sub_Group__c> customerGroupSubgroups = new List<Customer_Group_Sub_Group__c>();
        List<Account> toUpdateAccounts = new List<Account>();
        Profile cbsAdmin = AccountTriggerHandler.profileMapByName.get(GlobalConstants.CBS_ADMIN);
        Id cbsAdminProfileID = cbsAdmin.Id;
        for(Account account:accounts){
            boolean accountHasGroupSubgroup = (account.Group_Sub_Group__c != null);
            boolean isInAllowedSegments = GlobalConstants.CBS_SEGMENT_CODE_SET.contains(account.Primary_Segment_Code__c);
            User relatedUser = AccountTriggerHandler.allUserMap.get(account.ownerId);
            boolean isOwnedByCBSAdmin = false;
            if(relatedUser != null && relatedUser.ProfileId == cbsAdminProfileID) isOwnedByCBSAdmin = true;
            if(isInAllowedSegments && !isOwnedByCBSAdmin){
                Customer_Group_Sub_Group__c customerGroupSubgroup = new Customer_Group_Sub_Group__c();
                customerGroupSubgroup.Customer__c = account.Id;
                customerGroupSubgroup.Group_Sub_Group__c = account.Group_Sub_Group__c;
                customerGroupSubgroup.OwnerID = account.OwnerID;
                customerGroupSubgroup.External_ID__c = createExternalId(account,'Group_Sub_Group__c');
                customerGroupSubgroup.Is_Active__c = accountHasGroupSubgroup;
                customerGroupSubgroups.add(customerGroupSubgroup);
            }   
        }
        System.debug('Debug -- customerGroupSubgroups ::'+customerGroupSubgroups);
        insert customerGroupSubgroups;
    }

    public static void updateCustomerGroupSubGroup(Map<Id,Account> updatedAccounts,Map<Id,Account> beforeUpdateAccounts){

        List<Customer_Group_Sub_Group__c>toInsertCustomerGroupSubgroups = new List<Customer_Group_Sub_Group__c>();
        List<Customer_Group_Sub_Group__c>toUpdateCustomerGroupSubgroups = new List<Customer_Group_Sub_Group__c>();
        List<Group_Sub_Group_Transaction__c> toUpdateGroupSubgroupTransaction = new List<Group_Sub_Group_Transaction__c>();
     
        Profile cbsAdmin = AccountTriggerHandler.profileMapByName.get(GlobalConstants.CBS_ADMIN);
        Id cbsAdminProfileID = cbsAdmin.Id;

        List<Customer_Group_Sub_Group__c>customerGroupSubgroups = [
            SELECT Id,Customer__c,Group_Sub_Group__c,Group_Sub_Group__r.Group_Lookup__c,Group_Sub_Group__r.Sub_Group_Lookup__c,Is_Active__c,Group_Sub_Group_Transaction_Update__c
            FROM Customer_Group_Sub_Group__c 
            WHERE Customer__c IN: updatedAccounts.values()
        ];
        Map<Id,Map<Id,Customer_Group_Sub_Group__c>>customerGroupSubgroupMapByAccountID =  new Map<Id,Map<Id,Customer_Group_Sub_Group__c>>();
        Map<Id, Id> groupSubgroupIdMapByAccountId = new Map<Id, Id>();

        for(Account eachAccount : updatedAccounts.values()){
            Account beforeUpdateAccount = beforeUpdateAccounts.get(eachAccount.Id);
            if(eachAccount.Group_Sub_Group__c != beforeUpdateAccount.Group_Sub_Group__c){
                groupSubgroupIdMapByAccountId.put(eachAccount.Id, eachAccount.Group_Sub_Group__c);
            }
        }

        Map<Id, Group_Sub_Group__c> newGroupSubgroupMapById = new Map<Id, Group_Sub_Group__c>();
        if(!groupSubgroupIdMapByAccountId.isEmpty()) {
            newGroupSubgroupMapById = new Map<Id, Group_Sub_Group__c>([
                SELECT Id, Group__c, Sub_Group__c, Sub_Group_Lookup__r.Team_Lead_Name__r.FirstName, Sub_Group_Lookup__r.Team_Lead_Name__r.LastName
                FROM Group_Sub_Group__c
                WHERE Id IN :groupSubgroupIdMapByAccountId.values()
            ]);
        }
        
        for(Customer_Group_Sub_Group__c customerGroupSubgroup:customerGroupSubgroups){
            if(!customerGroupSubgroupMapByAccountID.containsKey(customerGroupSubgroup.Customer__c)){
                customerGroupSubgroupMapByAccountID.put(customerGroupSubgroup.Customer__c,new Map<Id,Customer_Group_Sub_Group__c>());
            }
            customerGroupSubgroupMapByAccountID.get(customerGroupSubgroup.Customer__c).put(customerGroupSubgroup.Group_Sub_Group__c,customerGroupSubgroup);
        }
        for(Account updateAccount:updatedAccounts.values()){
            boolean isGroupSubgroupChangetoNull = updateAccount.Group_Sub_Group__c == null;
            Account beforeUpdateAccount = beforeUpdateAccounts.get(updateAccount.Id);
            boolean isGroupSubgroupChange = beforeUpdateAccount.Group_Sub_Group__c != updateAccount.Group_Sub_Group__c;

            User relatedUser = AccountTriggerHandler.allUserMap.get(updateAccount.ownerId);
            boolean isOwnedByCBSAdmin = false;
            if(relatedUser != null && relatedUser.ProfileId == cbsAdminProfileID){
                isOwnedByCBSAdmin = true;
            }   

            boolean isCustomerGroupSubgroupExists = false;
            if(!customerGroupSubgroups.isEmpty() && customerGroupSubgroupMapByAccountID.containsKey(updateAccount.Id) 
                && customerGroupSubgroupMapByAccountID.get(updateAccount.Id) != null 
                && customerGroupSubgroupMapByAccountID.get(updateAccount.Id).containsKey(beforeUpdateAccount.Group_Sub_Group__c)){
                isCustomerGroupSubgroupExists = true;
            } 
            boolean isInAllowedSegments = GlobalConstants.CBS_SEGMENT_CODE_SET.contains(updateAccount.Primary_Segment_Code__c);

            if(isGroupSubgroupChangetoNull && isCustomerGroupSubgroupExists){
                Customer_Group_Sub_Group__c customerGroupSubgroup = customerGroupSubgroupMapByAccountID.get(updateAccount.Id).get(beforeUpdateAccount.Group_Sub_Group__c);
                customerGroupSubgroup.Is_Active__c = false;
                customerGroupSubgroup.External_ID__c = createExternalId(updateAccount,'Group_Sub_Group__c');
                customerGroupSubgroup.Group_Sub_Group__c = null;
                toUpdateCustomerGroupSubgroups.add(customerGroupSubgroup);
            }else if(!isGroupSubgroupChangetoNull && isCustomerGroupSubgroupExists && isInAllowedSegments){
                Customer_Group_Sub_Group__c customerGroupSubgroup = customerGroupSubgroupMapByAccountID.get(updateAccount.Id).get(beforeUpdateAccount.Group_Sub_Group__c);
                customerGroupSubgroup.Is_Active__c = true && !isOwnedByCBSAdmin;
                customerGroupSubgroup.External_ID__c = createExternalId(updateAccount,'Group_Sub_Group__c');
                customerGroupSubgroup.Group_Sub_Group__c = updateAccount.Group_Sub_Group__c;
                toUpdateCustomerGroupSubgroups.add(customerGroupSubgroup);
            }else if(!isGroupSubgroupChangetoNull && !isCustomerGroupSubgroupExists && isInAllowedSegments){
                Customer_Group_Sub_Group__c customerGroupSubgroup = new Customer_Group_Sub_Group__c();
                customerGroupSubgroup.Customer__c = updateAccount.Id;
                customerGroupSubgroup.Group_Sub_Group__c = updateAccount.Group_Sub_Group__c;
                customerGroupSubgroup.OwnerID = updateAccount.OwnerID;
                customerGroupSubgroup.External_ID__c = createExternalId(updateAccount,'Group_Sub_Group__c');
                customerGroupSubgroup.Is_Active__c = true && !isOwnedByCBSAdmin;
                toInsertCustomerGroupSubgroups.add(customerGroupSubgroup);
            }else if(!isGroupSubgroupChangetoNull && isCustomerGroupSubgroupExists && !isInAllowedSegments){
                Customer_Group_Sub_Group__c customerGroupSubgroup = customerGroupSubgroupMapByAccountID.get(updateAccount.Id).get(beforeUpdateAccount.Group_Sub_Group__c);
                customerGroupSubgroup.Is_Active__c = false;
                customerGroupSubgroup.Group_Sub_Group__c = updateAccount.Group_Sub_Group__c;
                customerGroupSubgroup.External_ID__c = createExternalId(updateAccount,'Group_Sub_Group__c');
                toUpdateCustomerGroupSubgroups.add(customerGroupSubgroup);
            }

            if(isGroupSubgroupChange && isInAllowedSegments && !isGroupSubgroupChangetoNull){
                Group_Sub_Group__c newGroupSubgroup = newGroupSubgroupMapById.get(groupSubgroupIdMapByAccountId.get(updateAccount.Id));
                updateAccount.Group__c                          = newGroupSubgroup.Group__c;
                updateAccount.Sub_Group__c                      = newGroupSubgroup.Sub_Group__c;
                if(newGroupSubgroup.Sub_Group_Lookup__r.Team_Lead_Name__r.FirstName == null) 
                    updateAccount.Group_SubGroup_TeamLeadName__c    = '' + newGroupSubgroup.Sub_Group_Lookup__r.Team_Lead_Name__r.LastName;
                else 
                    updateAccount.Group_SubGroup_TeamLeadName__c    = '' + newGroupSubgroup.Sub_Group_Lookup__r.Team_Lead_Name__r.FirstName + ' ' + newGroupSubgroup.Sub_Group_Lookup__r.Team_Lead_Name__r.LastName;
            }else if(isGroupSubgroupChange && isInAllowedSegments && isGroupSubgroupChangetoNull){
                updateAccount.Group__c                          = null;
                updateAccount.Sub_Group__c                      = null;
                updateAccount.Group_SubGroup_TeamLeadName__c    = null;
            }
        }
        update toUpdateCustomerGroupSubgroups;
        insert toInsertCustomerGroupSubgroups;

        Map<Id,Customer_Group_Sub_Group__c> customerGroupSubgroupsMap = new Map<Id,Customer_Group_Sub_Group__c>(toUpdateCustomerGroupSubgroups);
        if(!toUpdateCustomerGroupSubgroups.isEmpty()) {
            toUpdateGroupSubgroupTransaction = [
                SELECT Id,Group_Lookup__c,Customer_Group_Sub_Group__c,Group_Sub_Group_Lookup__c,Sub_Group_Lookup__c 
                FROM Group_Sub_Group_Transaction__c 
                WHERE Customer_Group_Sub_Group__c IN :toUpdateCustomerGroupSubgroups
            ];
        }
            
        for(Group_Sub_Group_Transaction__c eachGroupSubgroupTran : toUpdateGroupSubgroupTransaction){
        	if(customerGroupSubgroupsMap.containsKey(eachGroupSubgroupTran.Customer_Group_Sub_Group__c)){
        		Customer_Group_Sub_Group__c customerGroupSubgroup = customerGroupSubgroupsMap.get(eachGroupSubgroupTran.Customer_Group_Sub_Group__c);
        		if(customerGroupSubgroup.Group_Sub_Group__c != null){
	        		eachGroupSubgroupTran.Group_Lookup__c = customerGroupSubgroup.Group_Sub_Group__r.Group_Lookup__c;
	        		eachGroupSubgroupTran.Sub_Group_Lookup__c = customerGroupSubgroup.Group_Sub_Group__r.Sub_Group_Lookup__c;
	        		eachGroupSubgroupTran.Group_Sub_Group_Lookup__c = customerGroupSubgroup.Group_Sub_Group__c;
        		}else{
                    eachGroupSubgroupTran.Group_Lookup__c = null;
                    eachGroupSubgroupTran.Sub_Group_Lookup__c = null;
                    eachGroupSubgroupTran.Group_Sub_Group_Lookup__c = null;
                }
        	}
        }

        if(!toUpdateGroupSubgroupTransaction.isEmpty()) update toUpdateGroupSubgroupTransaction;
    }

	public static List<Account> setAccountGroupSubGroupUpdate(List<sObject> sObjectList){
		List<Account> updateAccounts = new List<Account>();
		Set<Id>accountIDs = new Set<Id>();
		String lookupAccount;

		if(sObjectList.get(0) instanceof Opportunity){
			lookupAccount = 'AccountId';
		}else if(sObjectList.get(0) instanceof Target_List__c){
			lookupAccount = 'CIS_ID_Prospect_Name__c';
		}

		for(sObject obj:sObjectList){
			accountIDs.add((Id)obj.get(lookupAccount));
		}
		List<Account> accounts = [SELECT Id FROM Account WHERE Id IN: accountIDs AND Primary_Segment_Code__c IN: GlobalConstants.CBS_SEGMENT_CODE_SET AND Group_Sub_Group__c != NULL];
		for(Account account:accounts){
			
			Account updateAccount = new Account(Id = account.Id,
				Group_Sub_Group_Transaction_Update__c = true
			);
			updateAccounts.add(updateAccount);
		}
		if(!updateAccounts.isEmpty()){
			TriggerHandler.bypass('AccountTriggerHandler');
				update updateAccounts;
			TriggerHandler.clearbypass('AccountTriggerHandler');
		}
		return updateAccounts;
	}

    public static String createExternalId(Account account,String junctionLookupFieldName){
        Map<String,String> objectNameByIDPrefixs = GlobalUtility.getObjectDescriptionMapByIDPrefix();
        String cisNumber = account.CIS__c;
        String externalID = cisNumber + ':';
        String junctionPrefix = '';

        boolean isExternalIdForGroupSubgroup = junctionLookupFieldName.equalsIgnoreCase('Group_Sub_Group__c');
        if(isExternalIdForGroupSubgroup && account.Group_Sub_Group__c != null){
            String objectIdPrefix = String.valueOf(account.Group_Sub_Group__c).substring(0,3);
            boolean isGroupSubgroup = objectNameByIDPrefixs.get(objectIdPrefix).equalsIgnoreCase('Group_Sub_Group__c');
            if(isGroupSubgroup){
                junctionPrefix = 'GSG';
            }
            externalID += (junctionPrefix+':'+account.Group_Sub_Group__c);
        }

        return externalID;
    }

}