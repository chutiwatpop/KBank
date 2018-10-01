/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   
Test Class:    
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
01/24/2017  Charnun.T           Fixed INC000000488038 Recall Request Ownership ไม่ได้: Change solution
------------------------------------------------------------*/
global class SME_ReleaseTemporaryOwnership_Batch implements Database.Batchable<sObject>{
    String query;
    String defaultLabelLimit = '90';
    Integer minimumLabelLimit = 90;
    Map<String,Boolean> checkReleaseOwnership = new Map<String,Boolean>{
                                                        'checkReleaseProspectOwnershipSE' => true,
                                                        'checkReleaseProspectOwnershipME' => true,
                                                        'checkReleaseProspectOwnershipForCallPlanCallReportSE' => true,
                                                        'checkReleaseProspectOwnershipForCallPlanCallReportME' => true,
                                                        'checkReleaseCustomerOwnershipForCallPlanCallReportSE' => true,
                                                        'checkReleaseCustomerOwnershipForCallPlanCallReportME' => true
                                                    };
    Map<String,String> limitOfReleaseOwnership = new Map<String,String>{
                                                        'checkReleaseProspectOwnershipSE' => Label.Release_Prospect_Ownership_SE,
                                                        'checkReleaseProspectOwnershipME' => Label.Release_Prospect_Ownership_ME,
                                                        'checkReleaseProspectOwnershipForCallPlanCallReportSE' => Label.Release_Prospect_Ownership_for_Call_Plan_Call_Report_SE,
                                                        'checkReleaseProspectOwnershipForCallPlanCallReportME' => Label.Release_Prospect_Ownership_for_Call_Plan_Call_Report_ME,
                                                        'checkReleaseCustomerOwnershipForCallPlanCallReportSE' => Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_SE,
                                                        'checkReleaseCustomerOwnershipForCallPlanCallReportME' => Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_ME
                                                    };

    private List<Id> queryOwnerIds;

    private static string mainQuery = 'SELECT OwnerId, CreatedDate, SME_Temporary_Customer__c, SME_Temporary_Customer__r.User__c, SME_Temporary_Customer__r.User__r.Segment__c, Customer_Owner_Release_Flag__c, Last_CallReprt_Opty_Updated_Date__c, Owner.Segment__c, RecordType.DeveloperName, Primary_Segment_Code__c, Ownership_Text__c, Sharing_Status__c FROM Account WHERE SME_Temporary_Customer__c != null ';
    
    global SME_ReleaseTemporaryOwnership_Batch(){
        getMinLimitDateAndCheckIfLabelNull();
        this.query =    mainQuery;
    }

    global SME_ReleaseTemporaryOwnership_Batch(Set<Id> accountIdSet){
        getMinLimitDateAndCheckIfLabelNull();
        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(accountIdSet);
        String queryJoinSet = String.join(queryOwnerIds,'\',\'');
        this.query =    mainQuery   + ' AND id IN (\''+queryJoinSet+'\')';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList){
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        Datetime accountCreatedDatetime;
        Date accountCreatedDate;
        Date today = System.today();
        Integer dateDifference = 0;
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        for(Account account: accountList){
            account.Customer_Owner_Release_Flag__c = false;
            if(account.Last_CallReprt_Opty_Updated_Date__c == null){
                accountCreatedDatetime = account.CreatedDate;
                accountCreatedDate = Date.newInstance(accountCreatedDatetime.year(), accountCreatedDatetime.month(), accountCreatedDatetime.day());
                dateDifference = accountCreatedDate.daysBetween(today);
                if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseProspectOwnershipSE')){
                    if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipSE'))){
                        accountToUpdate.put(account.Id, account);
                    }
                }
                else if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseProspectOwnershipME')){
                    if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipME'))){
                        accountToUpdate.put(account.Id, account);
                    }
                }

            }else{
                accountCreatedDatetime = account.Last_CallReprt_Opty_Updated_Date__c;
                accountCreatedDate = Date.newInstance(accountCreatedDatetime.year(), accountCreatedDatetime.month(), accountCreatedDatetime.day());
                dateDifference = accountCreatedDate.daysBetween(today);

                if(account.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || account.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME){
                    account.OwnerId = userAdmin.SME_User_Id__c;
                    if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseProspectOwnershipSE')){  //INC000000887539
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipSE'))){
                            accountToUpdate.put(account.Id, account);
                        }
                    }
                    if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseProspectOwnershipME')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipME'))){
                            accountToUpdate.put(account.Id, account);
                        }
                    }
                }else if(account.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || account.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME){
                    if(account.SME_Temporary_Customer__r.User__c == account.OwnerId) {
                        setOwnerToAdmin(account, userAdmin);
                    }
                    if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportSE')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportSE'))){
                            accountToUpdate.put(account.Id, account);
                        }
                    }else if(account.SME_Temporary_Customer__r.User__r.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportME')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportME'))){
                            accountToUpdate.put(account.Id, account);
                        }
                    }
                }
            }
        }

        //INC000000488038 Waiting for test 31/03/2017
        if(accountToUpdate.size() > 0){
            ApprovalProcess_Service.approvedCustomerOwnershipRequest(accountToUpdate);
        }

        for(Account eachAccount : accountToUpdate.values()){
            eachAccount.SME_Temporary_Customer__c = null;
        }
        Database.update(accountToUpdate.values(),false);
    }

    global void finish(Database.BatchableContext BC){

    }

    private void setOwnerToAdmin(Account eachAccount, User_Admin__c userAdmin) {
        if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
            eachAccount.OwnerId = userAdmin.SME_User_ID__c;
        } else if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
            eachAccount.OwnerId = userAdmin.CBS_User_ID__c;
        } else if(GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c) || GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET.contains(eachAccount.Primary_Segment_Code__c)) {
            eachAccount.OwnerId = userAdmin.RBS_User_ID__c;
        }
    }

    public void getMinLimitDateAndCheckIfLabelNull(){
        for(String label:limitOfReleaseOwnership.keySet()){
            
            if(limitOfReleaseOwnership.get(label) == null){
                checkReleaseOwnership.put(label,false);
            }
            else if(Integer.valueOf(limitOfReleaseOwnership.get(label)) == 0){
                limitOfReleaseOwnership.put(label,defaultLabelLimit);
                if(Integer.valueOf(limitOfReleaseOwnership.get(label)) < minimumLabelLimit){
                    minimumLabelLimit = Integer.valueOf(limitOfReleaseOwnership.get(label));
                }
            }
        }
    }
}