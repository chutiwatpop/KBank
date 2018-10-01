/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/12/2016  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_YearEndContactChangeOwner_Batch implements Database.Batchable<sObject> {
    
    public String query(){
        return  'SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE AccountId IN (SELECT CIS_ID__c FROM Year_End_Assignment__c where Final_Assigned_Next_Year__c != \'\' and Status__c=\'Submitted\' and CIS_ID__c != null)';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query());
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            System.debug('scope::'+scope);
            List<Contact> tempContactList = new List<Contact>();
            for(sObject each : scope){
                // Add logic to update contact data.
                if(each.get('OwnerId') != each.getsObject('Account').get('OwnerId')){
                    Contact tempContact = new Contact(Id=Id.valueOf(String.valueOf(each.get('Id'))));
                    tempContact.OwnerId = Id.valueOf(String.valueOf(each.getsObject('Account').get('OwnerId')));
                    tempContactList.add(tempContact);
                }
            }

            // Update Contact Owner List
            if(tempContactList.size() > 0){
                GlobalUtility.accounFromYearend = true;
                System.debug('tempContactList::Size'+tempContactList.size()+'Data::'+tempContactList);
                update tempContactList;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}