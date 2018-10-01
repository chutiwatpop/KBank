public without sharing class CreateRBSPortController {

public List<Account> accountLists {get;set;}
public string callfunc {get;set;}
public String accountListsJSONString {get {return JSON.serialize(accountLists);} }

	public CreateRBSPortController(){

	}

	public CreateRBSPortController(ApexPages.StandardSetController controller) {

		this.accountLists = [SELECT Id, CIS__c, Select_Branch__C From Account WHERE Id IN :controller.getSelected()];	
	}

	 public PageReference saveRBSPort() {
	 	
	 	if(!this.accountLists.isEmpty()){
				User currentUser = [SELECT Id, Name, ManagerId, RC_Code__c, Profile.Name FROM User where Id =: UserInfo.getUserId() limit 1];			
				Team_Structure__c team = [SELECT Id,External_ID__c from Team_Structure__c where External_ID__c =: currentUser.RC_Code__c limit 1];
				List<RBS_Port_Selection__c> createRBSPorts = new List<RBS_Port_Selection__c>();
				for(Account accountData : accountLists){
					RBS_Port_Selection__c rbsPort = new RBS_Port_Selection__c();
					rbsPort.Customer__c = accountData.Id;
					rbsPort.OwnerId = getIdTM(currentUser);
					rbsPort.Team__c = team.Id;
					rbsPort.External_ID__c = accountData.CIS__c + currentUser.RC_Code__c;

					createRBSPorts.add(rbsPort);

					String oldData = accountData.Select_Branch__C == null ? '' : accountData.Select_Branch__C;
					accountData.Select_Branch__C = oldData + currentUser.RC_Code__c + ';';
				}
				update accountLists;

				System.debug('createRBSPorts : '+createRBSPorts);
				List<Database.UpsertResult> errorCreateResult = Database.upsert(createRBSPorts, RBS_Port_Selection__c.Fields.External_ID__c, false);
				if(errorCreateResult != null && errorCreateResult.isEmpty() == false){
					set<Id> idErrorSet = new set<Id>();
					String errorMessage = '';
					for (Database.UpsertResult sr : errorCreateResult) {
			            if (!sr.isSuccess()){
			                for(Database.Error err : sr.getErrors()) {	
			                	errorMessage = errorMessage + err.getMessage() +  ', ' ;
			                }               
			            }
	        		}
	        		if(errorMessage != ''){
	        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Cannot Create : '+ errorMessage));
	        			return null;
	        		}
	        	        	
				}
				callfunc = '<script> resultSaveRBSPort(); </script>';
				return null;
				//return gotoRecentListView();
		}
		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select at least one Customer.'));
		return null;
	}

	 public PageReference gotoRecentListView(){
        return new ApexPages.Action('{!List}').invoke();
    }

    @AuraEnabled
    public static String createCustomerRBSPort(String CustomerId){
   
		Account account = [SELECT Id, CIS__c, Select_Branch__C From Account WHERE Id =: CustomerId];
    	User currentUser = [SELECT Id, Name, ManagerId, RC_Code__c, Profile.Name FROM User where Id =: UserInfo.getUserId() limit 1];	
		if(GlobalConstants.PROFILE_RBS_CREATE_PORT.contains(currentUser.Profile.Name)){
			try{	

				Team_Structure__c team = [SELECT Id,External_ID__c from Team_Structure__c where External_ID__c =: currentUser.RC_Code__c limit 1];
				RBS_Port_Selection__c rbsPort = new RBS_Port_Selection__c();
				rbsPort.Customer__c = account.Id;
				rbsPort.OwnerId = getIdTM(currentUser);
				rbsPort.Team__c = team.Id;
				rbsPort.External_ID__c = account.CIS__c + currentUser.RC_Code__c;
				upsert rbsPort External_ID__c;

				String oldData = account.Select_Branch__C == null ? '' : account.Select_Branch__C;
				account.Select_Branch__C = oldData + currentUser.RC_Code__c + ';';
				update account;

	    		return 'true';
	    	}catch(exception ex){

	    	 	return ex.getMessage();	
	    	}
		}else{
			return 'not authorized';
		}	
    	
    }

    private static id getIdTM(User currentUser){
    	Id idTM;
    	if(currentUser.Profile.Name == 'RBS-BAR' || currentUser.Profile.Name == 'RBS-ABM'){
			idTM = currentUser.ManagerId;
		}else{
			idTM = currentUser.Id;
		}

		return idTM;
    }
}