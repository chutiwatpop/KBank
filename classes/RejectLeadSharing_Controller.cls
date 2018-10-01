global without sharing class RejectLeadSharing_Controller {
    global class Response{
        webservice String recordId{get;set;}
        webservice Boolean success{get;set;}
        webservice String msg{get;set;}
    }
	webservice static Response deleteAccountShare(String shareUserId,String accId){
        Response res = new Response();
        try{
            List<Target_List__c> listTargetListSharing = [SELECT Id,Status__c,Sharing_Status__c,Share_With__c,External_ID__c,Sharing_Remark__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :accId AND Lead_Campaign__r.IsActive = true AND Lead_Campaign__r.Status = :GlobalConstants.ACTIVE AND ((Sharing_Completed__c = true AND Sharing_Status__c = :GlobalConstants.SHARING_WITH_AN AND Share_With__c = :shareUserId) OR (Status__c =:GlobalConstants.REJECTED))];
            User rejectingUser = [Select Name,Employee_ID__c From User Where Id = :UserInfo.getUserId() LIMIT 1];
            for(Target_List__c eachSharingTargetList : listTargetListSharing){
                if(eachSharingTargetList.Status__c == GlobalConstants.REJECTED){
                    eachSharingTargetList.Status__c = GlobalConstants.STATUS_NEW;
                }
                eachSharingTargetList.Sharing_Remark__c = rejectingUser.Name +' ('+rejectingUser.Employee_ID__c +') '+ Label.LeadSharing_AN_reject_lead;
                eachSharingTargetList.Sharing_Status__c = null;
            }

            update listTargetListSharing;

            Account updateAccount = new Account();
            updateAccount.Id = accId;
            updateAccount.Share_With__c = null;
            updateAccount.Sharing_Status__c = null;
            updateAccount.Lead_Sharing_Expired_Date__c = null;

            List<Contact> listChangeContact = ManageSharing_Service.getListChangeContactOwner(new List<Account>{updateAccount},new Set<String>{shareUserId},true);
            update listChangeContact;

            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccount;
            TriggerHandler.clearbypass('AccountTriggerHandler');
        	
            delete [SELECT Id,AccountId FROM AccountShare WHERE UserOrGroupId = :shareUserId AND AccountId = :accId AND RowCause = 'Manual'];

            res.success = true;
        }catch(Exception ex){
            System.debug('ex = '+ex);
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }
}