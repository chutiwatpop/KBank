@isTest
private class SME_CurrentApproverInitial_Test {
	
    
	@testSetup static void setup(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
	}


	@isTest static void testCurrentApproverInitialBatchAsRMWhenAHActive(){
        
        User currentUserRM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserAH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
        User currentUserNH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];

        
        //System.assertEquals(null,currentUserRM.Current_Opportunity_Approval__c);
        Test.startTest();
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();

        currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(currentUserAH.Id,currentUserRM.Current_Opportunity_Approval__c);
        
    }

    @isTest static void testCurrentApproverInitialBatchAsRMWhenAHInactive(){
        System.debug([SELECT Id, IsActive FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin]);
        User currentUserAdmin = [SELECT Id, IsActive FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin];
        User currentUserRM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserTM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        User currentUserAH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
        User currentUserNH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
        List<User> userToUpdateList = new List<User>();
        //System.assertEquals(null,currentUserRM.Current_Opportunity_Approval__c);
        
        Test.startTest();
        
        System.runAs(currentUserAdmin){
            TriggerHandler.bypass('UserTriggerHandler');
            currentUserRM.Current_Opportunity_Approval__c = null;
            currentUserTM.Current_Opportunity_Approval__c = null;
            userToUpdateList.add(currentUserRM);
            userToUpdateList.add(currentUserTM);
            update userToUpdateList;
            TriggerHandler.clearBypass('UserTriggerHandler');
            
        }
        
        System.runAs(currentUserAdmin){
            TriggerHandler.bypass('UserTriggerHandler');
            currentUserAH.IsActive = false;
            update currentUserAH;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
        
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();
        
        currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(currentUserNH.Id,currentUserRM.Current_Opportunity_Approval__c);
    }

    @isTest static void testCurrentApproverInitialBatchAsTMWhenAHActive(){
        
        User currentUserRM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserTM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        User currentUserAH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
        User currentUserNH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];

        //System.assertEquals(null,currentUserTM.Current_Opportunity_Approval__c);
        Test.startTest();
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();

        currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(currentUserAH.Id,currentUserRM.Current_Opportunity_Approval__c);
    }

    @isTest static void testCurrentApproverInitialBatchAsTMWhenAHInactive(){
        User currentUserAdmin = [SELECT Id, IsActive FROM User WHERE FirstName =: Mockup_Test.userFirstNameAdmin];
        User currentUserRM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserTM = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
        User currentUserAH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameAH];
        User currentUserNH = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameNH];
        List<User> userToUpdateList = new List<User>();
        //System.assertEquals(null,currentUserTM.Current_Opportunity_Approval__c);
        Test.startTest();
        System.runAs(currentUserAdmin){
            TriggerHandler.bypass('UserTriggerHandler');
            currentUserRM.Current_Opportunity_Approval__c = null;
            currentUserTM.Current_Opportunity_Approval__c = null;
            userToUpdateList.add(currentUserRM);
            userToUpdateList.add(currentUserTM);
            update userToUpdateList;
            TriggerHandler.clearBypass('UserTriggerHandler');
            
        }
        
        System.runAs(currentUserAdmin){
            TriggerHandler.bypass('UserTriggerHandler');
            currentUserAH.IsActive = false;
            update currentUserAH;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();
        
        currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        System.assertEquals(currentUserNH.Id,currentUserRM.Current_Opportunity_Approval__c);
    }
    /*
    @isTest static void testCurrentApproverInitialBatchAsRMFranchiseAndTMFranchiseActive(){
        User currentUserRMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseRM];
        User currentUserTMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseTM];

        Test.startTest();
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();

        currentUserRMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseRM];
        System.assertEquals(currentUserTMFranchise.Id,currentUserRMFranchise.Current_Opportunity_Approval__c);
    }

    @isTest static void testCurrentApproverInitialBatchAsRMFranchiseAndTMFranchiseInactive(){
        User currentUserRMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseRM];
        User currentUserTMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseTM];

        //TriggerHandler.bypass('UserTriggerHandler');
        currentUserTMFranchise.IsActive = false;
        update currentUserTMFranchise;
        //TriggerHandler.clearBypass('UserTriggerHandler');

        Test.startTest();
        Database.executeBatch(new SME_CurrentApproverInitial_Batch());
        Test.stopTest();

        currentUserRMFranchise = [SELECT Id, IsActive, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId, Current_Opportunity_Approval__c FROM User WHERE FirstName =: Mockup_Test.userFirstNameFranchiseRM];
        System.assertEquals(currentUserTMFranchise.Id,currentUserRMFranchise.Current_Opportunity_Approval__c);
    }
    */
    
}