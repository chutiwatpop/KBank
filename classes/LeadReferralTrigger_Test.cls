@isTest
private class LeadReferralTrigger_Test
{	
	public static String accountNameRMPort = 'accountNameRMPort';
	public static String accountCISRMPort = '9999999999';
	public static String accountIdentRMPort = '1234567890123';
	@testSetup static void setupAccount(){
        Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
		

		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        User rmUser = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
      	User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        Team_Structure__c tmTeam = [SELECT Id,OwnerId FROM Team_Structure__c WHERE RC_Code__c =:Mockup_Test.RC_CODE LIMIT 1]; 
        tmTeam.OwnerId = rmUser.ManagerId;
        update tmTeam;
        System.runAs(rmUser){
	        Account newAccount = new Account(
	        	LastName = accountNameRMPort,
	            Port_Pool__c = GlobalConstants.PORT,
	            RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME),
	            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
	            Primary_Segment_Code__c = 'MI',
	            Customer_Segment_Code__c = 'MI',
	            Is_createby_Integration__c = true,
	            Max_Wealth_Branch__c = tmTeam.Id,
	            Max_Frequency_Branch__c = tmTeam.Id,
	            Encrypt_Identification_No__c = accountIdentRMPort,
	            CIS__c = accountCISRMPort,
	            Open_Account_Branch__c = tmTeam.Id
	        );
	        insert newAccount;

	        insert new AccountShare(
	            UserOrGroupId = rmUser2.Id,
	            AccountId = newAccount.Id,
	            AccountAccessLevel = 'READ',
	            OpportunityAccessLevel = 'READ'
	        );
        }
        Test.stopTest();
	}

	@isTest
	static void createLeadRefferal(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		System.runAs(rmUser2){
			Lead lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
	        insert lead;
	        lead.Customer__c = accountRM.Id;
	        update lead;
		}
		Team_Structure__c tmTeam = [SELECT Id,OwnerId,Owner.Name FROM Team_Structure__c WHERE RC_Code__c =:Mockup_Test.RC_CODE LIMIT 1];
        Lead resultLead = [SELECT Id,FinServ__ReferredByUser__c,CIS_ID__c,Identification_No__c,Refer_To_User__c,Refer_To_Segment__c FROM Lead WHERE Customer__c =:accountRM.Id LIMIT 1];
        System.assertEquals(rmUser2.Id,resultLead.FinServ__ReferredByUser__c);
        System.assertEquals(accountIdentRMPort,resultLead.Identification_No__c);
        System.assertEquals(accountCISRMPort,resultLead.CIS_ID__c);
        System.assertEquals(accountRM.OwnerId,resultLead.Refer_To_User__c);
	}

	@isTest
	static void createLeadMLP(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		System.runAs(rmUser2){
			Lead lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME);
	        insert lead;
	        lead.Customer__c = accountRM.Id;
	        update lead;
		}
		Team_Structure__c tmTeam = [SELECT Id,OwnerId FROM Team_Structure__c WHERE RC_Code__c =:Mockup_Test.RC_CODE LIMIT 1]; 
        Lead resultLead = [SELECT Id,FinServ__ReferredByUser__c,CIS_ID__c,Identification_No__c,Refer_To_User__c,Refer_To_Segment__c FROM Lead WHERE Customer__c =:accountRM.Id LIMIT 1];
        System.assertEquals(rmUser2.Id,resultLead.FinServ__ReferredByUser__c);
        System.assertEquals(accountIdentRMPort,resultLead.Identification_No__c);
        System.assertEquals(accountCISRMPort,resultLead.CIS_ID__c);
        System.assertEquals(accountRM.OwnerId,resultLead.Refer_To_User__c);
	}

	@isTest
	static void Given_AccountAndUserRmAndJob_When_UserCreateLeadNoJob_Then_FieldReferralInJobNull(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		Opportunity newOpp;
		System.runAs(rmUser2){
			newOpp = new Opportunity();
	        newOpp.AccountId = accountRM.Id;
	        newOpp.Name = 'test';
	        newOpp.StageName = Globalconstants.STATUS_OPEN;
	        newOpp.CloseDate = System.today() + 7;
	        insert newOpp;

			Lead lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
	        insert lead;
		}
        Opportunity resultOpp = [SELECT Referral__c FROM Opportunity WHERE Id = :newOpp.Id];
        System.assertEquals(null,resultOpp.Referral__c);
	}

	@isTest
	static void Given_AccountAndUserRmAndJob_When_UserCreateLeadWithJob_Then_FieldReferralInJobEqualLeadId(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		Opportunity newOpp;
		Lead lead;
		System.runAs(rmUser2){
			newOpp = new Opportunity();
	        newOpp.AccountId = accountRM.Id;
	        newOpp.Name = 'test';
	        newOpp.StageName = Globalconstants.STATUS_OPEN;
	        newOpp.CloseDate = System.today() + 7;
	        insert newOpp;

			lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
	        lead.Job__c = newOpp.Id;
	        lead.Customer__c = accountRM.Id;
	        lead.Account__c = accountRM.Id;
	        insert lead;
		}
        Opportunity resultOpp = [SELECT Referral__c FROM Opportunity WHERE Id = :newOpp.Id];
        System.assertEquals(lead.Id,resultOpp.Referral__c);
	}

	@isTest
	static void Given_AccountAndUserRmAndJob_When_UserCreateLeadNoJobAndUpdateLeadRelateToJob_Then_FieldReferralInJobEqualLeadId(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		Opportunity newOpp;
		Lead lead;
		System.runAs(rmUser2){
			newOpp = new Opportunity();
	        newOpp.AccountId = accountRM.Id;
	        newOpp.Name = 'test';
	        newOpp.StageName = Globalconstants.STATUS_OPEN;
	        newOpp.CloseDate = System.today() + 7;
	        insert newOpp;

			lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
	        insert lead;

	        lead.Job__c = newOpp.Id;
	        lead.Customer__c = accountRM.Id;
	        lead.Account__c = accountRM.Id;
	        update lead;
		}
        Opportunity resultOpp = [SELECT Referral__c FROM Opportunity WHERE Id = :newOpp.Id];
        System.assertEquals(lead.Id,resultOpp.Referral__c);
	}

	@isTest
	static void Given_AccountAndUserRmAndJob_When_UserCreateLeadWithJobAndUpdateLeadToNoJob_Then_FieldReferralInJobNull(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
		Account accountRM  = [SELECT Id,OwnerId FROM  Account WHERE CIS__c=:accountCISRMPort LIMIT 1];
		User rmUser2 = [SELECT Id,RC_Code__c,ManagerId,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
		Opportunity newOpp;
		Lead lead;
		System.runAs(rmUser2){
			newOpp = new Opportunity();
	        newOpp.AccountId = accountRM.Id;
	        newOpp.Name = 'test';
	        newOpp.StageName = Globalconstants.STATUS_OPEN;
	        newOpp.CloseDate = System.today() + 7;
	        insert newOpp;

			lead = new Lead();
	        lead.LastName = 'Test';
	        lead.RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
	        lead.Job__c = newOpp.Id;
	        lead.Customer__c = accountRM.Id;
	        lead.Account__c = accountRM.Id;
	        insert lead;

	        lead.Job__c = null;
	        update lead;
		}
        Opportunity resultOpp = [SELECT Referral__c FROM Opportunity WHERE Id = :newOpp.Id];
        System.assertEquals(null,resultOpp.Referral__c);
	}
}