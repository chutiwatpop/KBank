/*
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
21/12/2016  Charnun.T           send mail error to admin
*/
public without sharing class SME_BulkAssignment_Service {
    public static Map<Id,Account> updateTempAccountMap;

    public static void bulkAssignment(List<Bulk_Assignment__c> bulkAssignList) {
        Account eachAccount;
        List<Id> userIdList = new List<Id>();
        List<Account> accountList = new List<Account>();
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        Map<Id, Bulk_Assignment_Queue__c> updateBulkQueueMap = new Map<Id, Bulk_Assignment_Queue__c>();
        Map<Id,User_Extension__c> userExtensionMapWithUserId = new Map<Id,User_Extension__c>();
        updateTempAccountMap = new Map<Id,Account>();
        for(Bulk_Assignment__c eachAssignment : bulkAssignList) {
            userIdList.add(eachAssignment.SME_Temporary_Customer__c);
        }
        userExtensionMapWithUserId = UserExtension_Service.getUserExtensionMapByUserId(userIdList);

        for(Bulk_Assignment__c eachAssignment : bulkAssignList) {
            if(eachAssignment.Process__c && (eachAssignment.Status__c == GlobalConstants.STATUS_NEW || eachAssignment.Status__c == GlobalConstants.APPROVED)){
                if(eachAssignment.AssignmentOwner__c != null){
                    eachAccount = new Account (
                        Id = eachAssignment.CIS_ID__c,
                        OwnerChangeExecutedByTrigger__c = true,
                        OwnerId = eachAssignment.AssignmentOwner__c,
                        Permanent_Owner__c = eachAssignment.Permanent_Owner__c,
                        is_from_Bulk_Reassign__c = ((eachAssignment.Ownership__c != null && eachAssignment.Ownership__c != '')),
                        Ownership_Text__c = eachAssignment.Ownership__c,
                        Service_RM__c = eachAssignment.Service_RM__c
                    );
                }else{
                    eachAccount = new Account (
                        Id = eachAssignment.CIS_ID__c,
                        OwnerChangeExecutedByTrigger__c = true,
                        SME_Temporary_Customer__c = userExtensionMapWithUserId.get(eachAssignment.SME_Temporary_Customer__c).Id,
                        is_from_Bulk_Reassign__c = ((eachAssignment.Ownership__c != null && eachAssignment.Ownership__c != '')),
                        Ownership_Text__c = eachAssignment.Ownership__c
                    );
                    updateTempAccountMap.put(eachAccount.Id, eachAccount);
                }
                

                Set<String> cbsSegments = new Set<String>{GlobalConstants.SEGMENT_CB, GlobalConstants.SEGMENT_MB}; 
                if(cbsSegments.contains(eachAssignment.AssignmentOwner__r.Segment__c) && eachAssignment.AssignmentOwner__c != null){
                    eachAccount.Primary_Segment_Code__c = eachAssignment.AssignmentOwner__r.Segment__c;
                }
                
                if(eachAssignment.Permanent_Owner__c != null){
                    eachAccount.Port_Pool__c = eachAssignment.Port_Pool__c;
                }
                if(eachAssignment.Status__c == GlobalConstants.STATUS_NEW){
                    eachAssignment.Status__c = 'Complete';
                }
                accountList.add(eachAccount);
            }
            if(!updateBulkQueueMap.containsKey(eachAssignment.BulkAssignmentQueue__c)){
                updateBulkQueueMap.put(eachAssignment.BulkAssignmentQueue__c, new Bulk_Assignment_Queue__c(Id = eachAssignment.BulkAssignmentQueue__c, Status__c = 'Complete', FinishTime__c = System.now()));
            }   
            eachAssignment.Process__c = false;
        }
        if(updateBulkQueueMap.size() > 0){
            update updateBulkQueueMap.values();
        }

        List<Bulk_Assignment_Sale_Target__c> bulkSalesTargetList = new List<Bulk_Assignment_Sale_Target__c>();
        bulkSalesTargetList = [SELECT Id, Bulk_Assignment_Queue__c, Sales_Name__c, Transaction_Fee_New_Target__c, Main_Operating_Bank_New_Target__c, Deal_Base_Fee_New_Target__c FROM Bulk_Assignment_Sale_Target__c WHERE Bulk_Assignment_Queue__c IN: updateBulkQueueMap.keySet()];
        
        if(!bulkSalesTargetList.isEmpty()){
            List<Sales_Target__c> salesTargetListToUpdate = new List<Sales_Target__c>();

            for(Bulk_Assignment_Sale_Target__c eachBulkSales : bulkSalesTargetList){
                Sales_Target__c tempSalesTarget = new Sales_Target__c();
                tempSalesTarget.Id = eachBulkSales.Sales_Name__c;
                tempSalesTarget.Transaction_Fee_Target__c = eachBulkSales.Transaction_Fee_New_Target__c;
                tempSalesTarget.Main_Operating_Bank_Target__c = eachBulkSales.Main_Operating_Bank_New_Target__c;
                tempSalesTarget.Deal_Base_Fee_Target__c = eachBulkSales.Deal_Base_Fee_New_Target__c;
                salesTargetListToUpdate.add(tempSalesTarget);
                eachBulkSales.Processed__c = true;
            }

            if(!salesTargetListToUpdate.isEmpty()){
                update salesTargetListToUpdate;
            }
            update bulkSalesTargetList;
        }
       
        // INC000000477174 Update accounts, one of which missing a required field and send mail to admin
        if(accountList.size() > 0){
            String errorMessage = '';
            try{
                Database.SaveResult[] srList = Database.update(accountList, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = errorMessage + String.valueOf(err.getMessage()) + '\n';
                        }
                    }
                }
                if(errorMessage != ''){
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
            if(updateTempAccountMap != null && !updateTempAccountMap.isEmpty()){
                Map<Id,Id> userExtensionToUserId = new Map<Id,Id>();
                AccountChangeOwner accountService = new AccountChangeOwner();
                List<Account> mapAccountList = [SELECT Id,SME_Temporary_Customer__c,SME_Temporary_Customer__r.User__c FROM Account WHERE Id IN:updateTempAccountMap.keySet()];
                for(Account eachMapAccount : mapAccountList){
                    userExtensionToUserId.put(eachMapAccount.SME_Temporary_Customer__c, eachMapAccount.SME_Temporary_Customer__r.User__c);
                }
                for(Account eachUpdateTempAccount : updateTempAccountMap.values()){
                    eachUpdateTempAccount.OwnerId = userExtensionToUserId.get(eachUpdateTempAccount.SME_Temporary_Customer__c);
                }
                System.debug('updateTempAccountMap');
                System.debug(updateTempAccountMap);
                accountService.closeTempOwnerEvent(updateTempAccountMap);
                accountService.changeAllOpenJob(updateTempAccountMap, null);
            }
        }
        
        TriggerHandler.bypass('BulkAssignmentTriggerHandler');
        update bulkAssignList;
        TriggerHandler.clearBypass('BulkAssignmentTriggerHandler');
        SME_BulkAssignment_Service.finish();
    }

    public static void finish() {
        Integer bulkQueueCount = [SELECT Count() FROM Bulk_Assignment_Queue__c WHERE Status__c = 'Execute'];
        if(bulkQueueCount > 0) {
            SME_CalculateOwnershipAssignment_Service.executeBulkAssignmentBatch();
        }
    }

    @future
    public static void rejectBulkAssignment(Set<Id> userIds){
        Map<Id,Bulk_Assignment__c> pendingBulkToRejectMap = new Map<Id,Bulk_Assignment__c>();
        pendingBulkToRejectMap = new Map<Id,Bulk_Assignment__c>([SELECT Id FROM Bulk_Assignment__c WHERE AssignmentOwner__c IN: userIds AND Status__c =: GlobalConstants.WAITING_FOR_APPROVAL]);
        String comments = 'Reject because user inactive';

        for(Bulk_Assignment__c eachBulk : pendingBulkToRejectMap.values()){
            eachBulk.Rejected_Reason__c = GlobalConstants.REJECT_REASON_OTHERS;
            eachBulk.Rejected_Reason_Text__c = comments;
        }
        update pendingBulkToRejectMap.values();

        List<ProcessInstanceWorkitem> pendingBulkToApproveList = new List<ProcessInstanceWorkitem>();
        pendingBulkToApproveList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: pendingBulkToRejectMap.keySet()];

        String bulkToSendToFuture = JSON.serialize(pendingBulkToApproveList);
        ApprovalProcessResult_Service.processWorkItems(bulkToSendToFuture,'REJECT',comments);
    }
}