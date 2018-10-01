global class SME_Initial_ContactedAccount_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;
    private Map<String, User_Extension__c> userExtMapByUserId;
    private Set<String> userIds{get{return userExtMapByUserId.keySet();}}

    global SME_Initial_ContactedAccount_Batch() {
        Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>([SELECT Id, User__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__r.SME_User__c = true]);

        userExtMapByUserId = new Map<String, User_Extension__c>();
        for(User_Extension__c eachExt : userExtMap.values()){
            userExtMapByUserId.put(eachExt.User__c, eachExt);
        }
        this.query = 'SELECT Id,Name, Count_Contacted_Call_Report__c, Count_Call_Report_RM__c FROM Account WHERE OwnerId IN :userIds';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> accountList) {
        Map<String,Decimal> accountMapCount = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountRM = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountCallRepF2F = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountPhoneCall = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountMyPenF2F = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountMyPenCall = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountMyPenServiceF2F = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountMyPenServiceCall = new Map<String,Decimal>();
        
        List<String> queryRecordType = new List<String>(GlobalConstants.CALL_PLAN_CALL_REPORT_SME_DEVNAME_SET);
        List<Event> callReportList = [SELECT Id, WhatId, OwnerId, ActivityDate, Contact_Channel__c, Status__c, Job__r.AccountId, Job__r.Account.OwnerId, Job__r.Account.Service_RM__c FROM Event WHERE RecordType.DeveloperName IN :queryRecordType AND Job__r.AccountId IN :accountList AND ActivityDate = THIS_YEAR];

        for(Event eachCallReport : callReportList){
            Id accountId;
            if(eachCallReport.Job__r.AccountId == null) {
                continue;
            } else {
                accountId = eachCallReport.Job__r.AccountId;
            }
            if(!accountMapCount.containsKey(accountId))
                accountMapCount.put(accountId, 0);

            if(!accountMapCountRM.containsKey(accountId))
                accountMapCountRM.put(accountId, 0);

            if(!accountMapCountCallRepF2F.containsKey(accountId))
                accountMapCountCallRepF2F.put(accountId, 0);

            if(!accountMapCountPhoneCall.containsKey(accountId))
                accountMapCountPhoneCall.put(accountId, 0);

            if(!accountMapCountMyPenF2F.containsKey(accountId))
                accountMapCountMyPenF2F.put(accountId, 0);

            if(!accountMapCountMyPenCall.containsKey(accountId))
                accountMapCountMyPenCall.put(accountId, 0);

            if(!accountMapCountMyPenServiceF2F.containsKey(accountId))
                accountMapCountMyPenServiceF2F.put(accountId, 0);

            if(!accountMapCountMyPenServiceCall.containsKey(accountId))
                accountMapCountMyPenServiceCall.put(accountId, 0);

            if(isActualVisitDateThisYear(eachCallReport)){
                if(isServiceRmIsNotNullAndCallRepOwnerEqualAccountOwnerService(eachCallReport)){
                    accountMapCountRM.put(accountId, accountMapCountRM.get(accountId)+1);
                }

                accountMapCount.put(accountId, accountMapCount.get(accountId)+1);
            }

            if(isCallRepStatusContactedOrClosedAndActualVisitDateThisYear(eachCallReport)){
                if(eachCallReport.Contact_Channel__c != NULL && eachCallReport.Contact_Channel__c.equalsIgnoreCase(GlobalConstants.FACE_TO_FACE)) {
                    accountMapCountCallRepF2F.put(accountId, accountMapCountCallRepF2F.get(accountId)+1);
                    if(isCallRepOwnerEqualAccountOwner(eachCallReport)){
                        accountMapCountMyPenF2F.put(accountId, accountMapCountMyPenF2F.get(accountId)+1);
                    }
                    if(isServiceRmIsNotNullAndCallRepOwnerEqualAccountOwnerService(eachCallReport)){
                        accountMapCountMyPenServiceF2F.put(accountId, accountMapCountMyPenServiceF2F.get(accountId)+1);
                    }
                } else if(eachCallReport.Contact_Channel__c != NULL && eachCallReport.Contact_Channel__c.equalsIgnoreCase(GlobalConstants.PHONE_CALL)) {
                    accountMapCountPhoneCall.put(accountId, accountMapCountPhoneCall.get(accountId)+1);
                    
                    if(isCallRepOwnerEqualAccountOwner(eachCallReport)){
                        accountMapCountMyPenCall.put(accountId, accountMapCountMyPenCall.get(accountId)+1);
                    }
                    if(isServiceRmIsNotNullAndCallRepOwnerEqualAccountOwnerService(eachCallReport)){
                        accountMapCountMyPenServiceCall.put(accountId, accountMapCountMyPenServiceCall.get(accountId)+1);
                    }
                }
            }
        }
        List<Contacted_Account__c> listInsertContactedAccount = new List<Contacted_Account__c>();
        for(Account eachAccount : accountList){
            Contacted_Account__c newContactedAccount = new Contacted_Account__c();
            newContactedAccount.Name = eachAccount.Id;
            newContactedAccount.Lookup_Customer__c = eachAccount.Id;
            newContactedAccount.Count_Contacted_Call_Report__c = (accountMapCount.containsKey(eachAccount.Id))?accountMapCount.get(eachAccount.Id):0;
            newContactedAccount.Count_Call_Report_RM__c = (accountMapCountRM.containsKey(eachAccount.Id))?accountMapCountRM.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_Call_Report_F2F__c = (accountMapCountCallRepF2F.containsKey(eachAccount.Id))?accountMapCountCallRepF2F.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_Call_Report_Phone_Call__c = (accountMapCountPhoneCall.containsKey(eachAccount.Id))?accountMapCountPhoneCall.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c = (accountMapCountMyPenF2F.containsKey(eachAccount.Id))?accountMapCountMyPenF2F.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c = (accountMapCountMyPenCall.containsKey(eachAccount.Id))?accountMapCountMyPenCall.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c = (accountMapCountMyPenServiceF2F.containsKey(eachAccount.Id))?accountMapCountMyPenServiceF2F.get(eachAccount.Id):0;
            newContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c = (accountMapCountMyPenServiceCall.containsKey(eachAccount.Id))?accountMapCountMyPenServiceCall.get(eachAccount.Id):0;
            listInsertContactedAccount.add(newContactedAccount);
        }
        //TriggerHandler.bypass('AccountTriggerHandler');
        //update accountList;
        Database.insert(listInsertContactedAccount, false);
        //TriggerHandler.clearBypass('AccountTriggerHandler');
    }

    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new CalculatePerformanceFromAccount_Batch());
    }

    private Boolean isActualVisitDateThisYear(Event eachCallReport){
        Integer actualVisitYear = eachCallReport.ActivityDate.year();
        Integer thisYear;
        if(isLoadRecordLastYear()){
            thisYear = System.now().year() - 1;
        }else{
            thisYear = System.now().year();
        }

        if(actualVisitYear == thisYear){
            return true;
        }
        return false;
    }

    private Boolean isCallRepStatusContactedOrClosedAndActualVisitDateThisYear(Event eachCallReport){
        if(eachCallReport.Status__c != null
            && isActualVisitDateThisYear(eachCallReport)
            && (eachCallReport.Status__c.equalsIgnoreCase(GlobalConstants.CONTACTED) || eachCallReport.Status__c.equalsIgnoreCase(GlobalConstants.CLOSED)) ){

            return true;
        }
        return false;
    }

    private Boolean isServiceRmIsNullAndCallRepOwnerEqualAccountOwner(Event eachCallReport){
        if(isServiceRmIsNull(eachCallReport) && isCallRepOwnerEqualAccountOwner(eachCallReport)){
            return true;
        }
        return false;
    }

    private Boolean isServiceRmIsNotNullAndCallRepOwnerEqualAccountOwnerService(Event eachCallReport){
        if(!isServiceRmIsNull(eachCallReport) && isCallRepOwnerEqualAccountOwnerService(eachCallReport)){
            return true;
        }
        return false;
    }

    private Boolean isCallRepOwnerEqualAccountOwner(Event eachCallReport){
        if(eachCallReport.Job__r.Account.OwnerId == eachCallReport.OwnerId){
            return true;
        }
        return false;
    }

    private Boolean isCallRepOwnerEqualAccountOwnerService(Event eachCallReport){
        if(eachCallReport.Job__r.Account.Service_RM__c == eachCallReport.OwnerId){
            return true;
        }
        return false;
    }

    private Boolean isServiceRmIsNull(Event eachCallReport){
        if(eachCallReport.Job__r.Account.Service_RM__c == null){
            return true;
        }
        return false;
    }

    private Boolean isLoadRecordLastYear(){
        if(Label.Last_Year_Performance != null && Label.Last_Year_Performance.equalsIgnoreCase('true') && !Test.isRunningTest()){
            return true;
        }
        return false;
    }
}