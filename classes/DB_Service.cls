/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global database class
Test Class:
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
15/02/2017  Charnun.T           First Create
------------------------------------------------------------*/
public class DB_Service {

	/** 
    Insert session 
    **/
    public static List<Database.SaveResult> insertsObject(List<sObject> sObjectList){
    	List<Database.SaveResult> dbErrorList;
	    dbErrorList = dbCheckResult(Database.Insert(sObjectList, false),dbErrorList);
	    return dbErrorList;
    }

    public static List<Database.SaveResult> insertAccountShare(List<accountShare> accountShareList){
    	List<Database.SaveResult> dbErrorList;
	    dbErrorList = dbCheckResult(Database.Insert(accountShareList, false),dbErrorList);
	    return dbErrorList;
    }

    public static List<Database.SaveResult> insertOpportunityShare(List<OpportunityShare> opportunityShareList){
    	List<Database.SaveResult> dbErrorList;
	    dbErrorList = dbCheckResult(Database.Insert(opportunityShareList, false),dbErrorList);
	    return dbErrorList;
    }

    /** 
    Update session 
    **/

    /* For Refactor Review  */
    public static List<Database.SaveResult> updateSObject(List<sObject> sObjectList, Boolean showErrorIfAsync){
        List<Database.SaveResult> dbErrorList;

        if((System.isBatch() || System.isFuture() || System.isQueueable()) && !showErrorIfAsync ){
            dbErrorList = dbCheckResult(Database.update(sObjectList, false),dbErrorList);
        }else{
            update sObjectList;
        }
        return dbErrorList;
    }

    public static List<Database.SaveResult> updateSObjectWithBypass(List<sObject> sObjectList, Boolean showErrorIfAsync){
        List<Database.SaveResult> dbErrorList;

        if(GlobalUtility.getType(sObjectList.get(0)) == 'Contact'){
            TriggerHandler.bypass('ContactTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Opportunity'){
            TriggerHandler.bypass('OpportunityTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Call_Report__c'){
            TriggerHandler.bypass('CallReportTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Team_Structure__c'){
            TriggerHandler.bypass('TeamStructureTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Customer_Ownership_Request__c'){
            TriggerHandler.bypass('CustomerOwnershipRequestTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Customer_Business_Code__c'){
            TriggerHandler.bypass('CustomerBusinessCodeTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'AccountTriggerHandler'){
            TriggerHandler.bypass('AccountTriggerHandler');
        }

        if((System.isBatch() || System.isFuture() || System.isQueueable()) && !showErrorIfAsync ){
            dbErrorList = dbCheckResult(Database.update(sObjectList, false),dbErrorList);
        }else{
            update sObjectList;
        }

        if(GlobalUtility.getType(sObjectList.get(0)) == 'Contact'){
            TriggerHandler.clearBypass('ContactTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Opportunity'){
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Call_Report__c'){
            TriggerHandler.clearBypass('CallReportTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Team_Structure__c'){
            TriggerHandler.clearBypass('TeamStructureTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Customer_Ownership_Request__c'){
            TriggerHandler.clearBypass('CustomerOwnershipRequestTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'Customer_Business_Code__c'){
             TriggerHandler.clearBypass('CustomerBusinessCodeTriggerHandler');
        }else if(GlobalUtility.getType(sObjectList.get(0)) == 'AccountTriggerHandler'){
             TriggerHandler.clearBypass('AccountTriggerHandler');
        }

        return dbErrorList;
    }
    /*-----------------------*/

    public static List<Database.SaveResult> updateCustomerOwnershipRequest(List<Customer_Ownership_Request__c> customerOwnershipRequestUpdateList){
    	List<Database.SaveResult> dbErrorList;
	    dbErrorList = dbCheckResult(Database.update(customerOwnershipRequestUpdateList, false),dbErrorList);
	    return dbErrorList;
    }

    public static List<Database.SaveResult> updateCallReport(List<Call_Report__c> callReportUpdateList){
    	List<Database.SaveResult> dbErrorList;
	    dbErrorList = dbCheckResult(Database.update(callReportUpdateList, false),dbErrorList);
	    return dbErrorList;
    }

    public static List<Database.SaveResult> updateOpportunity(List<Opportunity> opportunityUpdateList){
        List<Database.SaveResult> dbErrorList;
        dbErrorList = dbCheckResult(Database.update(opportunityUpdateList, false),dbErrorList);
        return dbErrorList;
    }

    public static List<Database.SaveResult> updateContact(List<Contact> contactUpdateList){
        List<Database.SaveResult> dbErrorList;
        dbErrorList = dbCheckResult(Database.update(contactUpdateList, false),dbErrorList);
        return dbErrorList;
    }

    public static List<Database.SaveResult> updateTeamStructure(List<Team_Structure__c> teamStructureUpdateList){
        List<Database.SaveResult> dbErrorList;
        dbErrorList = dbCheckResult(Database.update(teamStructureUpdateList, false),dbErrorList);
        return dbErrorList;
    }
    
    public static List<Database.SaveResult> updateCallReportWithBypass(List<Call_Report__c> callReportUpdateList){
    	List<Database.SaveResult> dbErrorList;
    	TriggerHandler.bypass('CallReportTriggerHandler');
	    dbErrorList = dbCheckResult(Database.update(callReportUpdateList, false),dbErrorList);
	    TriggerHandler.clearBypass('CallReportTriggerHandler');
	    return dbErrorList;
    }

    public static List<Database.SaveResult> updateOpportunityWithBypass(List<Opportunity> opportunityUpdateList){
    	List<Database.SaveResult> dbErrorList;
    	TriggerHandler.bypass('OpportunityTriggerHandler');
	    dbErrorList = dbCheckResult(Database.update(opportunityUpdateList, false),dbErrorList);
	    TriggerHandler.clearBypass('OpportunityTriggerHandler');
	    return dbErrorList;
    }     

    public static List<Database.SaveResult> updateContactWithBypass(List<Contact> contactUpdateList){
    	List<Database.SaveResult> dbErrorList;
    	TriggerHandler.bypass('ContactTriggerHandler');
	    dbErrorList = dbCheckResult(Database.update(contactUpdateList, false),dbErrorList);
	    TriggerHandler.clearBypass('ContactTriggerHandler');
	    return dbErrorList;
    }

    public static List<Database.SaveResult> updateTeamStructureWithBypass(List<Team_Structure__c> teamStructureUpdateList){
        List<Database.SaveResult> dbErrorList;
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        dbErrorList = dbCheckResult(Database.update(teamStructureUpdateList, false),dbErrorList);
        TriggerHandler.clearBypass('TeamStructureTriggerHandler');
        return dbErrorList;
    }

    public static List<Database.SaveResult> updateTargetListStructure(List<Target_List__c> targetListStructureUpdateList){
        List<Database.SaveResult> dbErrorList;
        dbErrorList = dbCheckResult(Database.update(targetListStructureUpdateList, false),dbErrorList);
        return dbErrorList;
    }

    public static List<Database.SaveResult> updateAccount(List<Account> accountUpdateList){
        List<Database.SaveResult> dbErrorList;
        dbErrorList = dbCheckResult(Database.update(accountUpdateList, false),dbErrorList);
        return dbErrorList;
    }

    /** 
    Private session 
    **/
    private static List<Database.SaveResult> dbCheckResult(Database.SaveResult[] result, List<Database.SaveResult> dbErrorList){
    	for (Database.SaveResult each : result) {
	        if (!each.isSuccess()) {
	        	if(dbErrorList == null){
	        		dbErrorList = new List<Database.SaveResult>();
	        	}
	            dbErrorList.add(each);
	        }
	    }
    	return dbErrorList;
    }

}