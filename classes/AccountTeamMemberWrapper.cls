public without sharing class AccountTeamMemberWrapper {

    private List<AccountTeamMember> newAccountTeamMember;
    private List<AccountTeamMember> toDeleteAccountTeamMember;
    private User_Admin__c userAdmin;
    public AccountTeamMemberWrapper(User_Admin__c userAdmin) {
        this.newAccountTeamMember = new List<AccountTeamMember>();
        this.toDeleteAccountTeamMember = new List<AccountTeamMember>();
        this.userAdmin = userAdmin;
    }

    public void calculateAccountTeamMember(List<Account> newAccounts,Map<Id,Account> oldMapAccount){
    	List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();
        Map<Id,Id> accountIdMapByUserIdToDelete = new Map<Id,Id>();
    	for(Account eachAccount : newAccounts){
    		AccountTeamMember eachAccountTeam;
    		if(oldMapAccount != null && !oldMapAccount.isEmpty()){ // case update
    			Account oldAccount = oldMapAccount.get(eachAccount.id);
    			if(eachAccount.Dual_RM_Name__c != oldAccount.Dual_RM_Name__c){
    				if(oldAccount.Dual_RM_Name__c != null && !isRBSAdmin(oldAccount.Dual_RM_Name__c)){
                        accountIdMapByUserIdToDelete.put(oldAccount.Dual_RM_Name__c,oldAccount.id);
    				}
    				if(eachAccount.Dual_RM_Name__c != null && !isRBSAdmin(eachAccount.Dual_RM_Name__c)){
    					eachAccountTeam = newAccountTeamMember(eachAccount);
    				}
    			}
    		}else{ // insert
    			if(eachAccount.Dual_RM_Name__c != null && !isRBSAdmin(eachAccount.Dual_RM_Name__c)){
    				eachAccountTeam = newAccountTeamMember(eachAccount);
    			}
    		}
            if(eachAccountTeam != null){
                accountTeams.add(eachAccountTeam);
            }
        }

        setNewAccountTeamMember(accountTeams);
        if(!accountIdMapByUserIdToDelete.isEmpty()){
            List<AccountTeamMember> accountTeamMembers = queryAccountTeamMemberFromUserId(accountIdMapByUserIdToDelete.keySet(),new Set<Id>(accountIdMapByUserIdToDelete.values()));
            accountTeamMembers = filterToDeleteAccountTeamMember(accountTeamMembers,accountIdMapByUserIdToDelete);
            setToDeleteAccountTeamMember(accountTeamMembers);
        }
    }

    public void executeAccountTeamMember(){
    	insertNewAccountTeamMember();
    	deleteToDeleteAccountTeamMember();
    }

    private void setToDeleteAccountTeamMember(List<AccountTeamMember> accountTeams){
    	this.toDeleteAccountTeamMember = accountTeams;
    }

    private void setNewAccountTeamMember(List<AccountTeamMember> accountTeams){
    	this.newAccountTeamMember = accountTeams;
    }

    private List<AccountTeamMember> queryAccountTeamMemberFromUserId(Set<Id> userIds,Set<Id> accountIds){
        List<AccountTeamMember> accountTeamMembers = [SELECT Id,UserId,AccountId From AccountTeamMember WHERE UserId IN :userIds OR AccountId IN :accountIds];
    	return accountTeamMembers;
    }

    private List<AccountTeamMember> filterToDeleteAccountTeamMember(List<AccountTeamMember> accountTeamMembers,Map<Id,Id> accountMapUserId){
        List<AccountTeamMember> toDeleteAccountTeams = new List<AccountTeamMember>();
        for(AccountTeamMember eachAccountTeam : accountTeamMembers){
            if(accountMapUserId.containsKey(eachAccountTeam.UserId)){
                Id accountId = accountMapUserId.get( eachAccountTeam.UserId );
                if( eachAccountTeam.AccountId == accountId){
                    toDeleteAccountTeams.add(eachAccountTeam);
                }
            }
        }
        return toDeleteAccountTeams;
    }

    private AccountTeamMember newAccountTeamMember(Account account){
        AccountTeamMember accountTeam = new AccountTeamMember(AccountId = account.id,
            UserId = account.Dual_RM_Name__c,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Read',
            ContactAccessLevel = 'Read',
            TeamMemberRole  = GlobalConstants.NONE
        );
        return accountTeam;
    }

    private void insertNewAccountTeamMember(){
        if(!newAccountTeamMember.isEmpty()){
            Database.insert(this.newAccountTeamMember,false);
        }
    }

    private void deleteToDeleteAccountTeamMember(){
        if(!toDeleteAccountTeamMember.isEmpty()){
            Database.delete(this.toDeleteAccountTeamMember,false);
        }
    }

    private Boolean isRBSAdmin(Id userId){
        return this.userAdmin.RBS_User_ID__c == userId;
    }



}