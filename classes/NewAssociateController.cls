public with sharing class NewAssociateController {
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    
    @TestVisible
    public class ResultResponse{
        public String result;
        public String message;
        public Event newEvent;
        public List<String> errors;
        public ResultResponse() {
            result = SUCCESS;
        }
    }

	@AuraEnabled
	public static String saveRecord(String accountString, String mainEventId, String associateType, String borrowerType) {
        ResultResponse resp = new ResultResponse();
        try {
            Boolean isShowEvent = false;
            Account accountObj = (Account) JSON.deserialize(accountString, Account.class);
            Event mainEvent = [SELECT Id, Contact_Channel__c, StartDateTime, EndDateTime, Offer_Credit_Product__c, Visit_Objective__c FROM Event WHERE Id = :mainEventId];
            SME_Associate_Conditions__c associateDefault = SME_Associate_Conditions__c.getOrgDefaults();
            
            Date currentDate    = System.today();
            Integer year        = currentDate.year();
            Integer month       = currentDate.month();
            Integer day         = currentDate.day();
            String stringMonth;
            if(month < 10){
                stringMonth = '0'+month;
            }

            Opportunity newOpportunity = new Opportunity(
                Name                    = year + '/' + stringMonth + '/' + day + '_' + accountObj.Name + '_Asso',
                AccountId               = accountObj.Id,
                StageName               = GlobalConstants.FINISHED,
                JobStage__c             = GlobalConstants.FINISHED,
                Update_from_Asso__c     = true,
                CloseDate               = System.today()
            );

            Event newEvent = new Event(
                OwnerId                     = UserInfo.getUserId(),
                Secondary_Call_Report__c    = true,
                Offer_Credit_Product__c     = true,
                Primary_Call_Report_Id__c   = mainEvent.Id,
                Visit_Objective__c          = mainEvent.Visit_Objective__c,
                StartDateTime               = mainEvent.StartDateTime,
                EndDateTime                 = mainEvent.EndDateTime,
                Status__c                   = GlobalConstants.CONTACTED,
                Contact_Channel__c          = mainEvent.Contact_Channel__c,
                RecordTypeId                = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME)
            );
            
            if(associateType == 'สนใจ') {
                if(borrowerType == 'Main Borrower') {
                    newOpportunity.StageName            = GlobalConstants.CONTACTED;
                    newOpportunity.JobStage__c          = GlobalConstants.CONTACTED;
                    newOpportunity.Update_from_Asso__c  = false;
                    newOpportunity.CloseDate            = System.today().addDays(Integer.valueOf(Label.Default_Job_CloseDate));
                    newEvent.RecordTypeId               = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_SECONDARY_DEVNAME);
                    isShowEvent                         = true;
                }
                newEvent.Offer_Interest__c  = associateDefault.Interest__c;
                newEvent.Borrower_Type__c   = borrowerType;
            } else {
                newEvent.Offer_Interest__c  = associateDefault.Not_Interest__c;
                newEvent.Memo__c            = associateDefault.Not_Interest_Memo__c;
                newEvent.Reason__c          = associateDefault.Not_Interest_Reason__c;
            }
            insert newOpportunity;
            newEvent.WhatId = newOpportunity.Id;
            if(!isShowEvent) {
                insert newEvent;
            }
            resp.newEvent = newEvent;
        } catch (System.DmlException dmlEx) {
            resp.result = ERROR;
            resp.errors = new List<String>();
            for (Integer i=0; i < dmlEx.getNumDml();i++) {
                resp.errors.add(dmlEx.getDmlMessage(i) + ' ' + dmlEx.getDmlFieldNames(i));
            }
        } catch (Exception e) {
            resp.result = ERROR;
            resp.message = e.getMessage();
        }
        return Json.serialize(resp);
	}

    @AuraEnabled
    public static String validateMainEvent(String mainEventId) {
        Event mainEvent = [SELECT Id, Secondary_Call_Report__c, Secondary_Call_Report_ID1__c, Secondary_Call_Report_ID2__c FROM Event WHERE Id = :mainEventId];
        return Json.serialize(mainEvent);
    }

    @AuraEnabled
    public static String getAssociateTypes() {
        return Json.serialize(new List<String>{'สนใจ','ไม่สนใจ'});
    }

    @AuraEnabled
    public static String getBorrowerTypes() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event.Borrower_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry eachVal: picklistVal) {
            options.add(eachVal.getLabel());
        }
        return Json.serialize(options);
    }


}