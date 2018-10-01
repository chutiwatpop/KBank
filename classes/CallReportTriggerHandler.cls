/**
* @author komsan.wi@beryl8.com
* @08/07/2015 auto create event
* @17/07/2015 change handlerEvent parameters from boolean to enum to support update case, move map account to function, remove max recursive
* @22/09/2015 Update Target_List__c.Status__c base on Call_Report__c.Status__c or Call_Report__c.Offer_Interest__c
* @3/10/2015 optimize code
* @27/01/2016 Add Temporary_Ownership_Flag__c = true on case create call plan / call report from pool (UAT-RMS-00415)
* @09/02/2016 Add UW logic
* @31/05/2016 Add new condition to support new record type
* @21/06/2016 Nareerat.wo@kbtg.tech   Add code for Call Report that Offer Interest equal to Interest with condition, then create Task Reminder to RM.
* @21/06/2016 Chumphon K. CR008 Update field First Visited Date this Year
* @16/01/2017 INC000000517417 for check condition before save records
* @19/01/2017 INC000000504518 check only SME callreport to validateVisitActivity
* @30/01/2017 Re-factor Code and clean comment.
* @07/02/2017 Remove static variable 
* @09/02/2017 Re-factor Code to CallReport Service 
* @15/02/2017 INC000000549652 Fix error Too many SOQL queries: 101
* @17/02/2017 Chumphon K., ISCR073 UpdateContactOfLeadCustSat - to add phone extension
* @19/12/2017 INC000000903826 fix call_report_lead not bind relation when convert callplan to callreport
* @29/01/2018 INC000000947272 secondary callreport should not require customer businesscode
*/
public class CallReportTriggerHandler extends TriggerHandler{
    private String CALL_REPORT_NO_PLAN;
    private String CALL_PLAN;
    private String NEW_CALL_PLAN;
    private String CALL_REPORT;
    private String SME_PROSPECT;
    private String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN;
    private String SECONDARY_CALL_REPORT_NO_PLAN;
    private String CREDIT_OPPORTUNITY;
    private String NON_CREDIT_OPPORTUNITY;
    private Map<String, String> recordTypeDevNameMapById;

    private User currentUser;

    private Map<String, Id> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;

    private List<Event> eventInsertList;
    private List<Event> eventUpdateList;
    private List<Call_Report_Lead__c> callReportLeadList;
    private Map<String,List<Opportunity>> opportunityInsertListMapByCallReport;
    
    private Set<Id> eventDeleteSet;
    private String eventSubject;
    private Map<String,Account> accountUpdateMap;
    private Map<String,Account> accountUpdateChangeOwnMap;
    private enum EventContext{E_CREATE, E_UPDATE, E_DELETE}

    private final Integer contactsSizeLimit = 4;
    private final Integer numberOfHoursAddedInEndDateTime = 1;
    private static Map<Id,Contact> existingContactMap; // Add by Chumphon K., ISCR073

    private Set<Id> customerBusinessCodeIdList;

    public override void init() {
        
        recordTypeDevNameMapById = new Map<String, String>();
        if(CallReport_Service.accountMapByCallReportCustomer == null)
            CallReport_Service.accountMapByCallReportCustomer = CallReport_Service.getAccountMapByCallReportCustomer(Trigger.new);
       
        //PCR061
        if(ProductMaster_Service.recommendProducts == null){
            ProductMaster_Service.recommendProducts = ProductMaster_Service.getRecommendProductForCallReport();
        }
        // Modified for fix INC000000549652 
        Map<String, Id> callRepRecIdMapByDev = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Call_Report__c');
        Map<String, Id> oppRecIdMapByDev = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Opportunity');
        Map<String, Id> customerRecIdMapByDev = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');

        if(callRepRecIdMapByDev.containsKey(GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME))
            CALL_REPORT_NO_PLAN = callRepRecIdMapByDev.get(GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME);
        if(callRepRecIdMapByDev.containsKey(GlobalConstants.CALL_PLAN_DEVNAME))
            CALL_PLAN = callRepRecIdMapByDev.get(GlobalConstants.CALL_PLAN_DEVNAME);
        if(callRepRecIdMapByDev.containsKey(GlobalConstants.NEW_CALL_PLAN_DEVNAME))
            NEW_CALL_PLAN = callRepRecIdMapByDev.get(GlobalConstants.NEW_CALL_PLAN_DEVNAME);
        if(callRepRecIdMapByDev.containsKey(GlobalConstants.CALL_REPORT_DEVNAME))
            CALL_REPORT = callRepRecIdMapByDev.get(GlobalConstants.CALL_REPORT_DEVNAME);
        if(callRepRecIdMapByDev.containsKey(GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME))
            SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN = callRepRecIdMapByDev.get(GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME);
        if(callRepRecIdMapByDev.containsKey(GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME))
            SECONDARY_CALL_REPORT_NO_PLAN = callRepRecIdMapByDev.get(GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME);
        if(oppRecIdMapByDev.containsKey(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME))
            CREDIT_OPPORTUNITY = oppRecIdMapByDev.get(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME);
        if(oppRecIdMapByDev.containsKey(GlobalConstants.NON_CREDIT_OPPORTUNITY_DEVNAME))
            NON_CREDIT_OPPORTUNITY = oppRecIdMapByDev.get(GlobalConstants.NON_CREDIT_OPPORTUNITY_DEVNAME);
        if(customerRecIdMapByDev.containsKey(GlobalConstants.SME_PROSPECT_DEVNAME))
            SME_PROSPECT = customerRecIdMapByDev.get(GlobalConstants.SME_PROSPECT_DEVNAME);
    }

    public override void allBefore() {
        // [Start] Add by Chumphon K., ISCR073 to add phone extension
        if(existingContactMap == null){
            Set<Id> accountIds = new Set<Id>();
            for(Call_Report__c eachCallReport : (List<Call_Report__c>) Trigger.new){
                accountIds.add(eachCallReport.CIS_ID__c);
            }
            existingContactMap = new Map<Id,Contact>([Select Id, AccountId, FirstName, LastName, Phone_Number__c, Ext_CBS__c From Contact Where AccountId in :accountIds Order by Primary_Contact__c DESC, Id]);
        }
        // [End] Add by Chumphon K., ISCR073 to add phone extension

        // INC000000517417 for check condition before save records
        if(Trigger.new.size() == 1){
            Call_Report__c tempCallReport = (Call_Report__c)Trigger.new[0];
            Datetime expected;
            if(UserInfo.getLanguage() == 'TH'){
                expected = Datetime.newInstance(2559, 8, 5);
            }else{
                expected = Datetime.newInstance(2016, 8, 5);
            }
            if(tempCallReport.CreatedDate > expected || tempCallReport.CreatedDate == null){
                // INC000000504518 check only SME callreport to validateVisitActivity
                if(!tempCallReport.IsCBS_CBS__c){ 
                    if(validateVisitActivity(tempCallReport)){
                        tempCallReport.addError('At least 1 Visit Activity field must be entered.');
                    }else if((tempCallReport.Negotiation__c == true || tempCallReport.Collect_Documents__c == true || tempCallReport.Offer_Credit_Product__c == true) && tempCallReport.Offer_Interest__c == null){
                        tempCallReport.addError(System.Label.Require_Offer_Interest_and_Reason);
                    }
                }
            }
        }
        if(currentUser == null){
            currentUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, UserRole.Name,Segment__c, Profile.Name, SME_User__c, RBS_User__c FROM User WHERE Id = :UserInfo.getUserId()];
        }
        accountUpdateMap = new Map<String,Account>();
        accountUpdateChangeOwnMap = new Map<String,Account>();
        mappingContactPhone((List<Call_Report__c>)Trigger.new);

        Set<Id> accountOwnerSet = new Set<Id>();
        Set<String> accountOwnerRcCode = new Set<String>();

        accountOwnerSet.add(UserInfo.getUserId());
        accountOwnerRcCode.add(currentUser.RC_Code__c);
        accountOwnerRcCode.add(currentUser.AH_RC_Code__c);
        accountOwnerRcCode.add(currentUser.NH_RC_Code__c);

        for(Account eachAccount : CallReport_Service.accountMapByCallReportCustomer.values()){
            accountOwnerSet.add(eachAccount.OwnerId);
        }

        if(CallReport_Service.userExtList == null) {
            CallReport_Service.userExtList = new List<User_Extension__c>();
            CallReport_Service.userExtList = [SELECT Id, Employee_Id__c FROM User_Extension__c WHERE User__c IN :accountOwnerSet];
        }
        if(CallReport_Service.teamStructureList == null) {
            CallReport_Service.teamStructureList = new List<Team_Structure__c>();
            CallReport_Service.teamStructureList = [SELECT Id, RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :accountOwnerRcCode];
        }
    
        teamMapByRc = new Map<String, Id>();
        userExtMapByEmpId = new Map<String, Id>();

        for(Team_Structure__c eachTeam : CallReport_Service.teamStructureList) {
            teamMapByRc.put(eachTeam.RC_Code__c, eachTeam.Id);
        }

        for(User_Extension__c eachUserExt : CallReport_Service.userExtList) {
            userExtMapByEmpId.put(eachUserExt.Employee_Id__c, eachUserExt.Id);
        }

        customerBusinessCodeIdList = new Set<Id>();
    }

    private void mappingContactPhone(List<Call_Report__C> callReportList){
        Set<Id> contactIds = new Set<Id>();
        for(Call_Report__c eachCallReport : callReportList) {
            if (eachCallReport.Contact__c != null) {
                contactIds.add(eachCallReport.Contact__c);
            }
        }
        if(contactIds.size() > 0){
            // Change by Chumphon K., ISCR073 to change contactMap to existingContactMap, and add phone extension
            // Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Phone_Number__c FROM Contact WHERE Id IN :contactIds]);
            for(Call_Report__c eachCallReport : callReportList) {
                if (eachCallReport.Contact__c != null && existingContactMap.get(eachCallReport.Contact__c) != null) {
                    eachCallReport.Phone_Number__c = existingContactMap.get(eachCallReport.Contact__c).Phone_Number__c;
                    eachCallReport.Phone_Extension__c = existingContactMap.get(eachCallReport.Contact__c).Ext_CBS__c;
                }
            }
        }
    }

    public override void beforeInsert() {
        if(!Account_Service.triggerInitialCall){
            Boolean toUpdate;
            Boolean isChangeOwner;

            for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new) {
                if((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && eachCallReport.Status__c != GlobalConstants.CONTACTED) {
                    eachCallReport.Status__c = GlobalConstants.CONTACTED;
                }
                //PCR061
                if(eachCallReport.Status__c == GlobalConstants.PLAN){
                    eachCallReport.Recommend_Product__c = ProductMaster_Service.recommendProducts;
                }
                eachCallReport.Who__c = UserInfo.getUserId();
                toUpdate = false;
                isChangeOwner = false;
                if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                    //Create Take Temp
                    Account accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                    if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)){
                        if(accountRecord.Port_Pool__c!=GlobalConstants.PORT && accountRecord.OwnerId != UserInfo.getUserId()){
                        accountRecord.OwnerId = UserInfo.getUserId();
                        accountRecord.Temp_Owner_Changed_Date__c = System.Today();
                        accountRecord.OwnerChangeExecutedByTrigger__c = true;
                        accountRecord.Temporary_Ownership_Flag__c = true;
                        //Account_Service.temporaryOwnershipFlag = true;
                        isChangeOwner = true;
                        toUpdate = true;
                        }
                    }

                    // Re-Validate case is passed Validation Rule
                    // INC000000504518 check only SME callreport to validateVisitActivity
                    if(!eachCallReport.IsCBS_CBS__c){
                        if(validateVisitActivity(eachCallReport)) {
                            eachCallReport.addError('At least 1 Visit Activity field must be entered.');
                        }
                    }
                    
                    if(eachCallReport.RecordTypeId == CALL_PLAN && eachCallReport.Actual_Visit_Date__c != null){
                        eachCallReport.RecordTypeId = CALL_REPORT;
                    }
                    if(eachCallReport.Customer_Important_Note__c!=null && eachCallReport.Customer_Important_Note__c!=''){
                        accountRecord.Customer_Importance_Note__c = eachCallReport.Customer_Important_Note__c;
                        toUpdate = true;
                    }
                    if((eachCallReport.RecordTypeId == CALL_REPORT || eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && accountRecord.Current_Activity__c != GlobalConstants.CALL_REPORT){
                        accountRecord.Current_Activity__c = GlobalConstants.CALL_REPORT;
                        toUpdate = true;
                    }
                    else if((eachCallReport.RecordTypeId == CALL_PLAN || eachCallReport.RecordTypeId == NEW_CALL_PLAN) && accountRecord.Current_Activity__c != GlobalConstants.CALL_PLAN){
                        accountRecord.Current_Activity__c = GlobalConstants.CALL_PLAN;
                        toUpdate = true;
                    }
                    if(accountRecord.Current_Activity_By__c != UserInfo.getName()){
                        accountRecord.Current_Activity_By__c = UserInfo.getName();
                        toUpdate = true;
                    }
                    if(eachCallReport.Status__c == GlobalConstants.CONTACTED ) {
                        accountRecord.Last_Visited_By__c = UserInfo.getName();
                        toUpdate = true;
                    }
                    //industry data
                    if(checkOfferInterestMustSelectCustomerBusinessCode(eachCallReport) && eachCallReport.Customer_Business_Code__c != null){
                        customerBusinessCodeIdList.add(eachCallReport.Customer_Business_Code__c);
                    }
                    
                    if(toUpdate){
                        if(isChangeOwner){
                            accountUpdateChangeOwnMap.put(accountRecord.Id,accountRecord);
                        }else{
                            accountUpdateMap.put(accountRecord.Id,accountRecord);//always add if insert last Call/Opty
                        }
                    }

                    // Set User Extension and Team
                    if(teamMapByRc.containsKey(accountRecord.RC_Code__c) && !isChangeOwner && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)) {                        
                        eachCallReport.Current_Team_Name__c = teamMapByRc.get(accountRecord.RC_Code__c);
                    } else {
                        if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE){
                            eachCallReport.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);    
                        }
                    }
                    if(teamMapByRc.containsKey(accountRecord.AH_RC_Code__c)  && !isChangeOwner && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)) {
                        eachCallReport.Current_AH_Name__c = teamMapByRc.get(accountRecord.AH_RC_Code__c);
                    } else {
                        if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE){
                            eachCallReport.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                        }
                    }
                    if(teamMapByRc.containsKey(accountRecord.NH_RC_Code__c)  && !isChangeOwner && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)) {
                        eachCallReport.Current_NH_Name__c = teamMapByRc.get(accountRecord.NH_RC_Code__c);
                    } else {
                        if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE){
                            eachCallReport.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);    
                        }
                    }
                    if(userExtMapByEmpId.containsKey(accountRecord.Owner_Emp_ID__c)  && !isChangeOwner && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)) {
                        eachCallReport.Current_Owner_Extension__c = userExtMapByEmpId.get(accountRecord.Owner_Emp_ID__c);
                    } else {
                        if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE){
                            eachCallReport.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);    
                        }
                    }
                    eachCallReport.Port_Pool__c = accountRecord.Port_Pool__c;
                    eachCallReport.Ownership__c = accountRecord.Ownership_Text__c;
                }
            }
            UW_Service.setUW((List<Call_Report__c>)Trigger.new);
            if(!customerBusinessCodeIdList.isEmpty()){
                CallReport_Service.setBusinessCodeSnapshotInCallReport((List<Call_Report__c>)Trigger.new,customerBusinessCodeIdList);
            }
        }
    }

    public override void beforeUpdate() {
        Boolean accountToBeUpdate;
        Call_Report__c callReportOldRecord;
        List<Call_Report__c> updatedCallReportUW = new List<Call_Report__c>();
        Account accountRecord;
        for(Call_Report__c eachCallReport : ((List<Call_Report__c>) Trigger.new)) {
            callReportOldRecord = (Call_Report__c)Trigger.oldMap.get(eachCallReport.Id);
            accountToBeUpdate = false;
            if(eachCallReport.RecordTypeId == CALL_PLAN && eachCallReport.Actual_Visit_Date__c != null){
                eachCallReport.RecordTypeId = CALL_REPORT;
            }

            // Re-Validate case is passed Validation Rule
            // INC000000504518 check only SME callreport to validateVisitActivity
            if(!eachCallReport.IsCBS_CBS__c){
                if(validateVisitActivity(eachCallReport)) {
                    eachCallReport.addError('At least 1 Visit Activity field must be entered.');
                }
            }

            if(callReportOldRecord.RecordTypeId == CALL_PLAN && eachCallReport.RecordTypeId == CALL_REPORT && eachCallReport.Status__c != GlobalConstants.CONTACTED){
                eachCallReport.Status__c = GlobalConstants.CONTACTED;
                if(checkOfferInterestMustSelectCustomerBusinessCode(eachCallReport) && eachCallReport.Customer_Business_Code__c != null){
                    customerBusinessCodeIdList.add(eachCallReport.Customer_Business_Code__c);
                    updatedCallReportUW.add(eachCallReport);
                }

            }
            if(!Account_Service.triggerInitialCall && CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                if(currentUser.UserRole.Name != GlobalConstants.SME_FRANCHISE && !GlobalConstants.PROFILE_AN_SET.contains(currentUser.Profile.Name)){
                    accountRecord.Temporary_Ownership_Flag__c = true;
                    Account_Service.temporaryOwnershipFlag = true;
                }

                if(eachCallReport.Customer_Important_Note__c!=null && eachCallReport.Customer_Important_Note__c != callReportOldRecord.Customer_Important_Note__c && eachCallReport.Customer_Important_Note__c!=''){
                    accountRecord.Customer_Importance_Note__c = eachCallReport.Customer_Important_Note__c;
                    accountToBeUpdate = true;
                }

                if(((callReportOldRecord.RecordTypeId != CALL_REPORT && eachCallReport.RecordTypeId == CALL_REPORT) || (callReportOldRecord.RecordTypeId != CALL_REPORT_NO_PLAN && eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN) || (callReportOldRecord.RecordTypeId != SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN && eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN)) && accountRecord.Current_Activity__c != GlobalConstants.CALL_REPORT){
                    accountRecord.Current_Activity__c = GlobalConstants.CALL_REPORT;
                    accountToBeUpdate = true;
                }else if(((callReportOldRecord.RecordTypeId != CALL_PLAN && eachCallReport.RecordTypeId == CALL_PLAN) || (callReportOldRecord.RecordTypeId != NEW_CALL_PLAN && eachCallReport.RecordTypeId == NEW_CALL_PLAN)) && accountRecord.Current_Activity__c != GlobalConstants.CALL_PLAN){
                    accountRecord.Current_Activity__c = GlobalConstants.CALL_PLAN;
                    accountToBeUpdate = true;
                }

                if(accountRecord.Current_Activity_By__c != UserInfo.getName()){
                    accountRecord.Current_Activity_By__c = UserInfo.getName();
                    accountToBeUpdate = true;
                }
                if(callReportOldRecord.Status__c != GlobalConstants.CONTACTED && eachCallReport.Status__c == GlobalConstants.CONTACTED) {
                    accountRecord.Last_Visited_By__c = UserInfo.getName();
                    accountToBeUpdate = true;
                }

                if(accountToBeUpdate){
                    accountUpdateMap.put(accountRecord.Id,accountRecord);
                }

                
            }

            if(callReportOldRecord.Plan_Date__c != eachCallReport.Plan_Date__c){
                if (eachCallReport.Number_of_Reschedule__c != null){
                    eachCallReport.Number_of_Reschedule__c++;
                } else {
                    eachCallReport.Number_of_Reschedule__c = 1;
                }
            }

            //if(eachCallReport.Business_Code__c != callReportOldRecord.Business_Code__c) {
            //    updatedCallReportUW.add(eachCallReport);
            //}
            
        }
        
        if(!updatedCallReportUW.isEmpty()) {
            UW_Service.setUW(updatedCallReportUW);    
        }
        if(!customerBusinessCodeIdList.isEmpty()){
            CallReport_Service.setBusinessCodeSnapshotInCallReport((List<Call_Report__c>)Trigger.new,customerBusinessCodeIdList);
        }
    }

    public override void beforeFinally() {
        if(!Account_Service.triggerInitialCall && !accountUpdateMap.isEmpty()){
            Account_Service.callReportTriggerList = (List<Call_Report__c>)Trigger.new;
            TriggerHandler.bypass('AccountTriggerHandler');
            update accountUpdateMap.values();
            TriggerHandler.clearBypass('AccountTriggerHandler');

            Account_Service.callReportTriggerList = null;
        }

        if(!Account_Service.triggerInitialCall && !accountUpdateChangeOwnMap.isEmpty()){
            Account_Service.callReportTriggerList = (List<Call_Report__c>)Trigger.new;
            Account_Service.triggerInitialCall = true;
            update accountUpdateChangeOwnMap.values();
            //Account_Service.callReportTriggerList = null;
        }


        if(CallReport_Service.userExtList != null) CallReport_Service.userExtList = null;
        if(CallReport_Service.teamStructureList != null) CallReport_Service.teamStructureList = null;
    }

    public override void allAfter() {
        eventDeleteSet = new Set<Id>();
        eventInsertList = new List<Event>();
        eventUpdateList = new List<Event>();
        callReportLeadList = new List<Call_Report_Lead__c>();
        opportunityInsertListMapByCallReport = new Map<String,List<Opportunity>>();
        customerBusinessCodeIdList = new Set<Id>();
    }

    public override void afterInsert() {
        if(currentUser == null)
            currentUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, UserRole.Name,Segment__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(CallReport_Service.userMapByCallReportCreateby == null){
            CallReport_Service.userMapByCallReportCreateby = new Map<Id,User>();
            CallReport_Service.userMapByCallReportCreateby = CallReport_Service.getUserMapByCallReportCreateby(Trigger.new);
        }

        Account accountRecord;
        List<Call_Report__c> toCreateNextFollowUpDateCallReports = new List<Call_Report__c>();
        for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
            if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);

                if(eachCallReport.Status__c == GlobalConstants.PLAN && eachCallReport.Plan_Date__c!=null){
                    boolean isCurrentUserSegmentCBorMB = (currentUser != null) && (currentUser.Segment__c != null) && (GlobalConstants.CBS_SEGMENT_CODE_SET.contains(currentUser.Segment__c));
                    if(isCurrentUserSegmentCBorMB){
                        eventSubject = String.format(GlobalConstants.ASSIGN_TO_SUBJECT,new String[]{eachCallReport.Planned_Visit_Objective_CBS__c,(accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name});    
                    }else{
                        eventSubject = String.format(GlobalConstants.ASSIGN_TO_SUBJECT,new String[]{eachCallReport.Visit_Objective__c,(accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name});    
                    }
                    this.handlerEvent(eachCallReport, accountRecord, null, EventContext.E_CREATE);
                }
            }
            if(eachCallReport.Customer_Business_Code__c != null){
                customerBusinessCodeIdList.add(eachCallReport.Customer_Business_Code__c);
            }
            toCreateNextFollowUpDateCallReports.add(eachCallReport);
        }
        createNextFollowUpDate(toCreateNextFollowUpDateCallReports);

        // ISCR028 Code
        // INC000000903826
        CampaignLead_Service.createORconvertCallReportUpdateAndCreateLeadStatus((Map<Id, Call_Report__c>)Trigger.newMap);
    }

    public override void afterFinally() {
        if(!Account_Service.callReportRunOnce){
            insertingContact();
            Account accountRecord;
            Account_Service.callReportRunOnce = true;
            Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById;

            if(!customerBusinessCodeIdList.isEmpty()){
                customerBusinessCodeMapById = new Map<Id,Customer_Business_Code__c>([SELECT Business_Code__r.Name,Business_Code__c From Customer_Business_Code__c WHERE Id IN :customerBusinessCodeIdList]);
            }

            for(Call_Report__c eachCallReport : ((List<Call_Report__c>) Trigger.new)) {
                if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                    accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                    //Condition Create Opp & CallreportOpp
                    //Start INC000000947933
                    if((eachCallReport.Number_of_Opp__c == null || eachCallReport.Number_of_Opp__c == 0) && !(accountRecord.RecordTypeId == SME_PROSPECT && (accountRecord.Birthdate_Registration_Date__c==null || accountRecord.Identification_No__c==null))){
                    //End INC000000947933
                        if((eachCallReport.RecordTypeId == CALL_REPORT) || (eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN) || (eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN)){
                            if(eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY && (Trigger.old==null || (Trigger.old!=null && Trigger.oldMap.get(eachCallReport.Id).get('Offer_Interest__c') != GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY))){
                                if(!opportunityInsertListMapByCallReport.containsKey(eachCallReport.Id)){
                                    opportunityInsertListMapByCallReport.put(eachCallReport.Id,new List<Opportunity>());
                                }
                                Opportunity opp = new Opportunity(
                                    Name = (accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name,
                                    AccountId = accountRecord.Id,
                                    CloseDate = System.today(),
                                    StageName = GlobalConstants.STOCK_NEGOTIATION,
                                    Amount = eachCallReport.Expected_Credit_Amount__c,
                                    Head_of_UW_Name__c = eachCallReport.Head_of_UW_Name__c,
                                    Senior_UW_Name__C = eachCallReport.Senior_UW_Name__C,
                                    IsConvertFromCallReport__c = true,
                                    Submit_Issue__c = GlobalConstants.NEW_CREDIT
                                );
                                if(eachCallReport.Customer_Business_Code__c != null && customerBusinessCodeMapById.containsKey(eachCallReport.Customer_Business_Code__c)){
                                    opp.Business_Code__c =  customerBusinessCodeMapById.get(eachCallReport.Customer_Business_Code__c).Business_Code__c;
                                    opp.Business_Code_Text__c =  customerBusinessCodeMapById.get(eachCallReport.Customer_Business_Code__c).Business_Code__r.Name;
                                    opp.Credit_Model__c = eachCallReport.Estimate_Credit_Model__c;
                                }
        
                                opportunityInsertListMapByCallReport.get(eachCallReport.Id).add(opp);
                            }else if(eachCallReport.Servicing__c || eachCallReport.Renew_Servicing__c){
                                if(!opportunityInsertListMapByCallReport.containsKey(eachCallReport.Id)){
                                    opportunityInsertListMapByCallReport.put(eachCallReport.Id,new List<Opportunity>());
                                }
                                Opportunity oppServicing = new Opportunity(
                                    Name = (accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name,
                                    AccountId = accountRecord.Id,
                                    CloseDate = System.today(),
                                    StageName = GlobalConstants.STOCK_NEGOTIATION,
                                    Amount = eachCallReport.Expected_Credit_Amount__c,
                                    Head_of_UW_Name__c = eachCallReport.Head_of_UW_Name__c,
                                    Senior_UW_Name__C = eachCallReport.Senior_UW_Name__C,
                                    IsConvertFromCallReport__c = true,
                                    Submit_Issue__c = eachCallReport.Servicing__c?GlobalConstants.SERVICING:GlobalConstants.RENEW_SERVICING 
                                );
                                if(eachCallReport.Customer_Business_Code__c != null && customerBusinessCodeMapById.containsKey(eachCallReport.Customer_Business_Code__c)){
                                    oppServicing.Business_Code__c =  customerBusinessCodeMapById.get(eachCallReport.Customer_Business_Code__c).Business_Code__c;
                                    oppServicing.Business_Code_Text__c =  customerBusinessCodeMapById.get(eachCallReport.Customer_Business_Code__c).Business_Code__r.Name;
                                    oppServicing.Credit_Model__c = eachCallReport.Estimate_Credit_Model__c;
                                }
        
                                opportunityInsertListMapByCallReport.get(eachCallReport.Id).add(oppServicing);
                            }
                        }
                    }
                }
            }
            
            //Create CallReport/Oppty Junction 
            if(opportunityInsertListMapByCallReport!=null && !opportunityInsertListMapByCallReport.values().isEmpty()){
                List<Call_Report_Opportunity__c> callReportOppInsertList = new List<Call_Report_Opportunity__c>();
                List<Opportunity> opportunityFinalInsertList = new List<Opportunity>();
                for(List<Opportunity> eachOpportunityList : opportunityInsertListMapByCallReport.values()){
                    opportunityFinalInsertList.addAll(eachOpportunityList);
                }
                insert opportunityFinalInsertList;
                for(String eachCallReportId : opportunityInsertListMapByCallReport.keySet()){
                    List<Opportunity> opportunityListByCallReport = opportunityInsertListMapByCallReport.get(eachCallReportId);
                    for(Opportunity eachInsertOpp : opportunityListByCallReport){
                        callReportOppInsertList.add(new Call_Report_Opportunity__c(
                            Call_Plan_Call_Report__c = eachCallReportId,
                            Opportunity_Name__c = eachInsertOpp.Id
                        ));
                    }
                }
                if(callReportOppInsertList.size() > 0) insert callReportOppInsertList;
            }
        }

        // Modified 02-Jun-2017 by Chutiwat.s decrease soql query state ment and fix INC000000633648
        Set<Id> accountSet = new Set<Id>();
        for(Call_Report__C eachCallReport : (List<Call_Report__C>)Trigger.new){
            accountSet.add(eachCallReport.CIS_ID__c);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>();
        accountMap = new Map<Id,Account>([SELECT Id, CIS__c, OwnerId, First_Visited_Date__c FROM Account WHERE Id IN :accountSet]);

        //Added By Nareerat.wo@kbtg.tech 21-Jun-2016 Add code for Call Report that Offer Interest equal to Interest with condition, then create Task Reminder to RM.
        insertingTask_InterestWithCondition(accountMap);
        // Added by Chumphon K. 21-Jun-2016, CR008 Update field First Visited Date this Year
        update_FirstVisitedDate(accountMap);
        // End of Modified 02-Jun-2017

        //CR023 Sharing Bad Bank
        if(opportunityInsertListMapByCallReport == null || opportunityInsertListMapByCallReport.values().isEmpty()){
            ManageSharing_Service.updateCallPlanCallReportThenCheckStopSharingCondition((List<Call_Report__c>) Trigger.new);
        }
    }

    public override void afterUpdate() {
        if(!Account_Service.callReportRunOnce){
            List<Call_Report_Lead__c> existingCallReportLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c IN :Trigger.newMap.keySet()];
            List<Event> eventList = [SELECT Call_Plan_Call_Report__c FROM Event WHERE Call_Plan_Call_Report__c in:Trigger.newMap.keySet()];
            List<Call_Report_Lead__c> updateCallReportLeadList = new List<Call_Report_Lead__c>();
            List<Call_Report__c>toUpdateNextFollowUpDateCallReports = new List<Call_Report__c>();


            Map<Id, Call_Report__c> newAndConvertedCallReportMap = new Map<Id, Call_Report__c>();
            Map<Id, Call_Report__c> updatedCallReportMap = new Map<Id, Call_Report__c>();
            Map<Id, Call_Report_Lead__c> callReportLeadMapByCallReport = new Map<Id, Call_Report_Lead__c>();
            Map<Id, List<Call_Report_Lead__c>> listCallReportLeadMapByCallReport = new Map<Id, List<Call_Report_Lead__c>>();
            Map<Id, List<Call_Report_Lead__c>> listTargetListMapByCallReport = new Map<Id, List<Call_Report_Lead__c>>();
            Map<Id,Target_List__c> updateTargetList = new Map<Id,Target_List__c>();
            Set<Id> callReportIdSet = new Set<Id>();
            Set<Id> callRepSetForCheckOpp = new Set<Id>();

            for(Call_Report_Lead__c eachCallRepLead : existingCallReportLead) {
                callReportLeadMapByCallReport.put(eachCallRepLead.Call_Plan_Call_Report__c, eachCallRepLead);
                if(!listCallReportLeadMapByCallReport.containsKey(eachCallRepLead.Call_Plan_Call_Report__c)){
                    listCallReportLeadMapByCallReport.put(eachCallRepLead.Call_Plan_Call_Report__c,new List<Call_Report_Lead__c>());
                }
                if(!listTargetListMapByCallReport.containsKey(eachCallRepLead.Call_Plan_Call_Report__c)){
                    listTargetListMapByCallReport.put(eachCallRepLead.Call_Plan_Call_Report__c,new List<Call_Report_Lead__c>());
                }
                listCallReportLeadMapByCallReport.get(eachCallRepLead.Call_Plan_Call_Report__c).add(eachCallRepLead);
                listTargetListMapByCallReport.get(eachCallRepLead.Call_Plan_Call_Report__c).add(eachCallRepLead);
            }

            List<Event> thisCallReportEvent;
            Boolean isChangeToSLACount;
            for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
                Call_Report__c oldCallReport = (Call_Report__c)Trigger.oldMap.get(eachCallReport.Id);
                
                //if(!callReportLeadMapByCallReport.containsKey(eachCallReport.Id) || 
                //    (eachCallReport.Primary_Call_Plan_Call_Report__c != null && eachCallReport.Primary_Call_Plan_Call_Report__c != oldCallReport.Primary_Call_Plan_Call_Report__c)) {
                //    //Added to fix INC000000530997
                //    if(eachCallReport.Status__c != GlobalConstants.CANCEL && eachCallReport.Status__c != GlobalConstants.CLOSED){
                //        newAndConvertedCallReportMap.put(eachCallReport.Id, eachCallReport);
                //    }
                //    //End fix INC000000530997
                //} else if(
                //    (oldCallReport.RecordTypeId != CALL_REPORT && eachCallReport.RecordTypeId == CALL_REPORT) || 
                //    (oldCallReport.RecordTypeId != CALL_REPORT_NO_PLAN && eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN) || 
                //    (oldCallReport.Offer_Interest__c != eachCallReport.Offer_Interest__c) ||
                //    (oldCallReport.Offer_Credit_Product__c != eachCallReport.Offer_Credit_Product__c) ||
                //    (oldCallReport.Negotiation__c != eachCallReport.Negotiation__c) ||
                //    (oldCallReport.Collect_Documents__c != eachCallReport.Collect_Documents__c) ||
                //    (oldCallReport.Servicing__c != eachCallReport.Servicing__c) ||
                //    (oldCallReport.Customer_Insight__c != eachCallReport.Customer_Insight__c) ||
                //    (oldCallReport.Non_Credit__c != eachCallReport.Non_Credit__c) ||
                //    (oldCallReport.No_Change__c != eachCallReport.No_Change__c) ||
                //    (oldCallReport.Pain__c != eachCallReport.Pain__c) ||
                //    (oldCallReport.Gift__c != eachCallReport.Gift__c) ||
                //    (oldCallReport.DPD__c != eachCallReport.DPD__c)) {
                //    updatedCallReportMap.put(eachCallReport.Id, eachCallReport);
                //}


                if( (oldCallReport.Status__c == GlobalConstants.PLAN && eachCallReport.Status__c == GlobalConstants.CONTACTED) ||
                    (oldCallReport.Offer_Interest__c != eachCallReport.Offer_Interest__c) ||
                    (oldCallReport.Offer_Interest__c != eachCallReport.Offer_Interest__c) ||
                    (oldCallReport.Offer_Credit_Product__c != eachCallReport.Offer_Credit_Product__c) ||
                    (oldCallReport.Negotiation__c != eachCallReport.Negotiation__c) ||
                    (oldCallReport.Collect_Documents__c != eachCallReport.Collect_Documents__c) ||
                    (oldCallReport.Servicing__c != eachCallReport.Servicing__c) ||
                    (oldCallReport.Customer_Insight__c != eachCallReport.Customer_Insight__c) ||
                    (oldCallReport.Non_Credit__c != eachCallReport.Non_Credit__c) ||
                    (oldCallReport.No_Change__c != eachCallReport.No_Change__c) ||
                    (oldCallReport.Pain__c != eachCallReport.Pain__c) ||
                    (oldCallReport.Gift__c != eachCallReport.Gift__c) ||
                    (oldCallReport.DPD__c != eachCallReport.DPD__c) ||
                    (eachCallReport.Primary_Call_Plan_Call_Report__c != null && eachCallReport.Primary_Call_Plan_Call_Report__c != oldCallReport.Primary_Call_Plan_Call_Report__c)
                ){
                    //if(eachCallReport.Status__c != GlobalConstants.CANCEL && eachCallReport.Status__c != GlobalConstants.CLOSED){
                        newAndConvertedCallReportMap.put(eachCallReport.Id, eachCallReport);
                    //}
                }
                isChangeToSLACount = oldCallReport.IsSLACount__c == false && eachCallReport.IsSLACount__c == true;

                if(isChangeToSLACount) {
                    callReportIdSet.add(eachCallReport.Id);
                }

                if((eachCallReport.Head_of_UW_Name__c != oldCallReport.Head_of_UW_Name__c || eachCallReport.Senior_UW_Name__c != oldCallReport.Senior_UW_Name__c)) {
                    callRepSetForCheckOpp.add(eachCallReport.Id);
                }

                if(eachCallReport.Status__c == GlobalConstants.CANCEL || eachCallReport.Status__c == GlobalConstants.CLOSED){
                    if(callReportLeadMapByCallReport.containsKey(eachCallReport.Id)){
                        //Added for fix INC000000477174
                        for(Call_Report_Lead__c eachCallReportLeadTargetList : (List<Call_Report_Lead__c>)listTargetListMapByCallReport.get(eachCallReport.Id)){
                            if(eachCallReportLeadTargetList.Target_List__r.Status__c == GlobalConstants.PLAN){
                                Target_List__c targetListToUpdate = new Target_List__c();
                                targetListToUpdate.Id =  Id.valueOf(String.valueOf(eachCallReportLeadTargetList.Target_List__c));
                                targetListToUpdate.Status__c = GlobalConstants.STATUS_NEW;    
                                updateTargetList.put(targetListToUpdate.Id,targetListToUpdate);
                            }
                        }
                        //Ended for fix INC000000477174
                        if(eachCallReport.Status__c == GlobalConstants.CANCEL){
                            for(Call_Report_Lead__c eachCallreportLead : (List<Call_Report_Lead__c>)listCallReportLeadMapByCallReport.get(eachCallReport.Id)){
                                eachCallreportLead.Call_Report_Lead_Status__c = GlobalConstants.CANCEL;
                                updateCallReportLeadList.add(eachCallreportLead);
                            }
                        }
                    }
                    this.handlerEvent(eachCallReport, null, null, EventContext.E_DELETE);
                }else if(eachCallReport.Plan_Date__c!=null && eachCallReport.Plan_Date__c!=((Call_Report__c)Trigger.oldMap.get(eachCallReport.Id)).Plan_Date__c){
                    thisCallReportEvent = new List<Event>();
                    for(Event eachEvent : eventList){
                        if(eachEvent.Call_Plan_Call_Report__c == eachCallReport.Id){
                            thisCallReportEvent.add(eachEvent);
                            break;
                        }
                    }
                    this.handlerEvent(eachCallReport, null, thisCallReportEvent, EventContext.E_UPDATE);
                }
                toUpdateNextFollowUpDateCallReports.add(eachCallReport);
                if(eachCallReport.Customer_Business_Code__c != null){
                    customerBusinessCodeIdList.add(eachCallReport.Customer_Business_Code__c);
                }
            }
            updateNextFollowUpDate(toUpdateNextFollowUpDateCallReports);


            Set<Id> oppIdSetForUpdateAcutalVisitDate = new Set<Id>();
            Map<Id, Call_Report__c> callRepMapByOpp = new Map<Id, Call_Report__c>();

            //Edit CR023 Refactor
            if(!callReportIdSet.isEmpty()) {
                List<Call_Report_Opportunity__c> callOpptyList = CallReport_Service.getCallReportOpptyRelationByCRID(Trigger.newMap.keySet());
                for(Call_Report_Opportunity__c callReportOpp : callOpptyList) {
                    if(callReportIdSet.contains(callReportOpp.Call_Plan_Call_Report__c)){
                        oppIdSetForUpdateAcutalVisitDate.add(callReportOpp.Opportunity_Name__c);
                    }
                }
            }

            if(!callRepSetForCheckOpp.isEmpty()) {
                List<Call_Report_Opportunity__c> callOpptyList = CallReport_Service.getCallReportOpptyRelationByCRID(Trigger.newMap.keySet());
                for(Call_Report_Opportunity__c callReportOpp : callOpptyList) {
                    if(callRepSetForCheckOpp.contains(callReportOpp.Call_Plan_Call_Report__c)){
                        //oppIdSetForUpdateAcutalVisitDate.add(callReportOpp.Opportunity_Name__c);
                        callRepMapByOpp.put(callReportOpp.Opportunity_Name__c, (Call_Report__c)Trigger.newMap.get(callReportOpp.Call_Plan_Call_Report__c));
                    }
                }
            }
            UW_Service.updateOppUW(callRepMapByOpp);
            CallReport_Service.updateActualVisitDateOfOpp(oppIdSetForUpdateAcutalVisitDate);

            if(updateTargetList.size() > 0) update updateTargetList.values();

            // ISCR028
            // INC000000903826
            if(!newAndConvertedCallReportMap.isEmpty()){
                CampaignLead_Service.createORconvertCallReportUpdateAndCreateLeadStatus(newAndConvertedCallReportMap);
            }
            //if(!updatedCallReportMap.isEmpty())
            //    CampaignLead_Service.updateCallReportUpdateLeadStatus(updatedCallReportMap);
        }
    }
    
    private void handlerEvent(Call_Report__c callReportEvent, Account accountObj, List<Event> eventList,EventContext ec){
        if(ec == EventContext.E_CREATE){
            eventInsertList.add(new Event(
                EndDateTime = callReportEvent.Plan_Date__c.addHours(1),
                StartDateTime = callReportEvent.Plan_Date__c,
                Subject = eventSubject,
                WhatID = accountObj.Id,
                Call_Plan_Call_Report__c = callReportEvent.Id,
                OwnerId = (Trigger.old!=null)?callReportEvent.CreatedById:UserInfo.getUserId()
            ));
        }
        else if(ec == EventContext.E_UPDATE && eventList!=null && eventList.size() > 0){
            for(Event eachEvent : eventList){
                eventUpdateList.add(new Event(
                    Id = eachEvent.Id,
                    EndDateTime = callReportEvent.Plan_Date__c.addHours(1),
                    StartDateTime = callReportEvent.Plan_Date__c
                ));
            }
        }
        else if(ec == EventContext.E_DELETE){
            eventDeleteSet.add(callReportEvent.Id);
        }
    }

    private Boolean validateVisitActivity(Call_Report__c eachCallReport) {
        // Re-Validate case is passed Validation Rule
        boolean isCurrentUserSegmentSEorME = (currentUser != null) && !String.isBlank(currentUser.Segment__c) &&
        (GlobalConstants.SME_SEGMENT_CODE_SET.contains(currentUser.Segment__c) || currentUser.Segment__c.equalsIgnoreCase('AN')) &&
        (currentUser.SME_User__c || currentUser.RBS_User__c || currentUser.Segment__c.equalsIgnoreCase('AN'));

        if(eachCallReport.Actual_Visit_Date__c != null && 
            eachCallReport.Offer_Credit_Product__c != true && 
            eachCallReport.Collect_Documents__c != true &&
            eachCallReport.Negotiation__c != true &&
            eachCallReport.Pain__c != true &&
            eachCallReport.Servicing__c != true &&
            eachCallReport.Renew_Servicing__c != true &&
            eachCallReport.Customer_Insight__c != true &&
            eachCallReport.Non_Credit__c != true &&
            eachCallReport.No_Change__c != true &&
            eachCallReport.Gift__c != true &&
            eachCallReport.DPD__c != true &&
            eachCallReport.Home_loan__c != true &&
            eachCallReport.Car_Loan__c != true &&
            eachCallReport.Personal_Loan__c != true &&
            eachCallReport.K_Plus_SME__c != true &&
            eachCallReport.EDC_mPOS__c != true &&
            eachCallReport.Prompt_Pay__c != true &&
            eachCallReport.WeChat_Ali_Pay__c != true &&
            eachCallReport.Deposit__c != true &&
            eachCallReport.Fund__c != true &&
            eachCallReport.Cash__c != true &&
            eachCallReport.BA_Protection__c != true &&
            eachCallReport.BA_Pro_Saving__c != true &&
            isCurrentUserSegmentSEorME) {
            return true;
        }
        return false;
    }

    public override void afterInsertFinally(){
        if(eventInsertList.size() > 0){
            CallReport_Service.insertEvent(eventInsertList);
            List<EventRelation> eventRelationList = new List<EventRelation>();
            Call_Report__c callReportByMap;
            for(Event eachInsertEvent : eventInsertList){
                callReportByMap = ((Map<Id,Call_Report__c>)Trigger.newMap).get(eachInsertEvent.Call_Plan_Call_Report__c);
                if(CallReport_Service.userMapByCallReportCreateby.get(UserInfo.getUserId()).ManagerId!=null)
                    eventRelationList.add(new EventRelation(
                        EventId = eachInsertEvent.Id,
                        RelationId = CallReport_Service.userMapByCallReportCreateby.get(UserInfo.getUserId()).ManagerId
                    ));
            }
            if(eventRelationList.size() > 0) CallReport_Service.insertEvent(eventRelationList);
        }
        if(callReportLeadList.size() > 0){
            insert callReportLeadList;
        }
    }

    public override void afterUpdateFinally() {

        if(eventUpdateList.size() > 0)
            CallReport_Service.updateEvent(eventUpdateList);
        if(eventDeleteSet.size() > 0)
            CallReport_Service.deleteEvent(eventDeleteSet);
    }

    private boolean isAvailableToInsertContacts(){
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<Id,Profile> profileIDMap = GlobalUtility.getProfileMapIDKey();
        if(profileIDMap.containsKey(currentUserProfileId)){
            return profileIDMap.get(currentUserProfileId).Name.contains('Solar') 
                    || profileIDMap.get(currentUserProfileId).Name.contains('System Administrator')
                    || profileIDMap.get(currentUserProfileId).Name.contains('SME')
                    || profileIDMap.get(currentUserProfileId).Name.contains('AN');
        }else{
            return false;
        }
    }

    private boolean isSystemAdmin(){
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<Id,Profile> profileIDMap = GlobalUtility.getProfileMapIDKey();
        if(profileIDMap.containsKey(currentUserProfileId)){
            return profileIDMap.get(currentUserProfileId).Name.contains('Solar') || profileIDMap.get(currentUserProfileId).Name.contains('System Administrator');
        }else{
            return false;
        }
    }

    private boolean isCurrentUserSME(){
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<Id,Profile> profileIDMap = GlobalUtility.getProfileMapIDKey();
        if(profileIDMap.containsKey(currentUserProfileId)){
            return profileIDMap.get(currentUserProfileId).Name.contains('SME');
        }else{
            return false;
        }
    }

    private boolean isCurrentUserAN(){
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<Id,Profile> profileIDMap = GlobalUtility.getProfileMapIDKey();
        if(profileIDMap.containsKey(currentUserProfileId)){
            return profileIDMap.get(currentUserProfileId).Name.contains('AN');
        }else{
            return false;
        }
    }

    private boolean isCurrentUserCBS(){
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<Id,Profile> profileIDMap = GlobalUtility.getProfileMapIDKey();
        if(profileIDMap.containsKey(currentUserProfileId)){
            return profileIDMap.get(currentUserProfileId).Name.contains('CBS');
        }else{
            return false;
        }
    }

    private void insertingContact(){
        List<Call_Report__c> callReportUpdateList = new List<Call_Report__c>();
        List<Contact> existContactList = new List<Contact>();
        Map<String,Contact> contactMap = new Map<String,Contact>();
        Boolean isFoundExistingContact; // Add by Chumphon K., ISCR073
        
        for(Call_Report__c eachCallReport : (List<Call_Report__c>) Trigger.new) {
            if ((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == CALL_REPORT || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && eachCallReport.Contact__c == null) {
                // [Start] Add by Chumphon K., ISCR073 to add phone extension
                /* Comment by Chumphon K., ISCR073 - to check existing contact
                Contact contactObj = new Contact();
                Account accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                contactObj.FirstName = eachCallReport.Contact_Firstname__c;
                contactObj.LastName = eachCallReport.Contact_Lastname__c;
                contactObj.Phone_Number__c = eachCallReport.Contact_Phone__c;
                contactObj.AccountId = accountRecord.Id;
                contactMap.put(eachCallReport.Id , contactObj);
                */
                isFoundExistingContact = false;
                for(Contact eachContact : existingContactMap.values()){
                    if(eachContact.AccountId == eachCallReport.CIS_ID__c && eachContact.FirstName == eachCallReport.Contact_Firstname__c && eachContact.LastName == eachCallReport.Contact_Lastname__c){
                        isFoundExistingContact = true;
                        eachContact.Phone_Number__c = eachCallReport.Contact_Phone__c;
                        eachContact.Ext_CBS__c = eachCallReport.Contact_Phone_Extension__c;
                        contactMap.put(eachCallReport.Id , eachContact);
                        break;
                    }
                }
                if(!isFoundExistingContact){
                    Contact contactObj = new Contact();
                    Account accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                    contactObj.FirstName = eachCallReport.Contact_Firstname__c;
                    contactObj.LastName = eachCallReport.Contact_Lastname__c;
                    contactObj.Phone_Number__c = eachCallReport.Contact_Phone__c;
                    contactObj.AccountId = accountRecord.Id;
                    contactObj.Ext_CBS__c = eachCallReport.Contact_Phone_Extension__c; // Add by Chumphon K., ISCR073 to add phone extension
                    contactMap.put(eachCallReport.Id , contactObj);
                }
                // [End] Add by Chumphon K., ISCR073 to add phone extension
            }
        }

        Boolean hasError = false;
        try{
            Id currentUserProfileId = UserInfo.getProfileId();

            boolean isCurrentUserSME = isCurrentUserSME();
            boolean isSystemAdmin = isSystemAdmin();
            boolean isCurrentUserAN = isCurrentUserAN();
            boolean isCurrentUserCBS = isCurrentUserCBS();

            if(isCurrentUserSME || isSystemAdmin || isCurrentUserAN){
                upsert contactMap.values(); // Add by Chumphon K., ISCR073 to add phone extension
            }
        }catch(Exception ex){
            hasError = true;
            String errorMessage = ex.getMessage();
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                Trigger.new.get(0).addError('Contact Error: '+errorMessage.split(',')[1].split(':')[0]);
            }else Trigger.new.get(0).addError('Contact Error: '+errorMessage);
        }
        if(!hasError){
            if(contactMap!=null && contactMap.size()!=null){
                // Update by Chumphon K., ISCR073 to update field Phone_Extension__c and clear Contact_Phone_Extension__c
                for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
                    if(contactMap.containsKey(eachCallReport.Id)){
                        callReportUpdateList.add(new Call_Report__c(
                        Id = eachCallReport.Id,
                        Contact__c = contactMap.get(eachCallReport.Id).Id,
                        Phone_Number__c = eachCallReport.Contact_Phone__c,
                        Phone_Extension__c = eachCallReport.Contact_Phone_Extension__c,
                        Contact_Firstname__c =null,
                        Contact_Lastname__c=null,
                        Contact_Phone__c=null,
                        Contact_Phone_Extension__c = null
                        ));
                    }
                }
            }
            if(callReportUpdateList!=null && callReportUpdateList.size() > 0){
                TriggerHandler.bypass('CallReportTriggerHandler'); //consider?
                try{
                    update callReportUpdateList;
                }catch(Exception ex){
                    String errorMessage = ex.getMessage();
                    if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        Trigger.new.get(0).addError(errorMessage.split(',')[1].split(':')[0]);
                    }else Trigger.new.get(0).addError(errorMessage);
                }
                TriggerHandler.clearBypass('CallReportTriggerHandler');
            }
        }
    }

    private void insertingTask_InterestWithCondition(Map<Id, Account> accountMap)
    {
        /*
         * Created by: nareerat.wo@kbtg.tech
         * Created date: 21-Jun-2016
         * Description: CR For Call Report that Offer Interest equal to Interest with condition, then create Task Reminder to RM.
        */
        boolean isInsertNewTask=false;
        integer intNumOfDays;
        String strTaskSubject;
        decimal decNumOfDays;
        datetime dteReminderDate;
        String strTimeReminder;
        integer intHoursRemindSetting;
        integer intMinuteRemindSetting;
        integer intHoursUserTimeZone;
        List<task> insertNewTask = new List<task>();

        for(Call_Report__C eachCallReport : (List<Call_Report__C>)Trigger.new){
            if (eachCallReport.Offer_Interest__c == GlobalConstants.INTEREST_WITH_CONDITION){
                if(trigger.isInsert){
                    isInsertNewTask=true; }
                if(trigger.isupdate){
                    Call_Report__C oldCallReport = (Call_Report__C) Trigger.oldMap.get(eachCallReport.Id);
                    if (eachCallReport.Offer_Interest__c <> oldCallReport.Offer_Interest__c){
                        isInsertNewTask = true; 
                    }
                }
                    
                if (isInsertNewTask==true) {
                    //Get custom setting
                    CallReport_Task_Setting__c TaskSetting = CallReport_Task_Setting__c.getOrgDefaults();
                    strTaskSubject = TaskSetting.ReminderTask_Subject__c;    
                    decNumOfDays =  TaskSetting.ReminderTask_NumOfDays__c;   
                    strTimeReminder = TaskSetting.ReminderTask_TimeReminder__c;
                    if (decNumOfDays != null) {
                        intNumOfDays =  decNumOfDays.intvalue(); 
                    }
                    if (strTimeReminder != null) {                            
                        intHoursRemindSetting =  integer.valueof(strTimeReminder.substringBefore(':'));
                        intMinuteRemindSetting =  integer.valueof(strTimeReminder.substringAfter(':'));
                    }

                    if (strTaskSubject == null) strTaskSubject='โปรดติดตามลูกค้า';
                    if (intNumOfDays == null) intNumOfDays=30;        
                    if (intHoursRemindSetting == null) intHoursRemindSetting=8;
                    if (intMinuteRemindSetting == null) intMinuteRemindSetting=0;                       

                    Account accountRecord = accountMap.get(eachCallReport.CIS_ID__c);

                    task NewTask = new task();
                    NewTask.OwnerId = accountRecord.OwnerId;
                    NewTask.WhatId = eachCallReport.id;
                    NewTask.Subject = strTaskSubject;
                    NewTask.Status = 'In Progress';
                    NewTask.priority = 'Normal';
                    NewTask.description= eachCallReport.memo__c;
                    NewTask.ActivityDate = system.today()+intNumOfDays;
                    dteReminderDate = system.today()+intNumOfDays;                        

                    //Check TimeZone of User
                    TimeZone tz = UserInfo.getTimeZone();                        
                    intHoursUserTimeZone=(tz.getOffset(DATE.valueof(dteReminderDate)))/60/60/1000;
                    dteReminderDate = dteReminderDate.addhours(intHoursRemindSetting-intHoursUserTimeZone);

                    if(intMinuteRemindSetting > 0) {
                        dteReminderDate = dteReminderDate.addMinutes(intMinuteRemindSetting);
                    }

                    NewTask.ReminderDateTime = Datetime.valueof(dteReminderDate);
                    NewTask.IsReminderSet = true;

                    insertNewTask.add(NewTask);     
                }       
            }
        }
        if(insertNewTask.size() > 0){
            insert insertNewTask;
        }
    }

    private void update_FirstVisitedDate(Map<Id,Account> accountMap)
    {
        /*
         * Created by: chumphon.k@kbtg.tech
         * Created date: 21-Jun-2016
         * Description: CR008 Update field First Visited Date this Year
        */
        

        List<Account> updateAccount = new List<Account>();
        boolean isChangeVisitedDate = false;
        for(Call_Report__C eachCallReport : (List<Call_Report__C>)Trigger.new){
            if(trigger.isInsert){
                isChangeVisitedDate = true;
            } else if(trigger.isUpdate){
                Call_Report__C oldCallReport = (Call_Report__C) Trigger.oldMap.get(eachCallReport.Id);
                if(eachCallReport.Actual_Visit_Date__c != oldCallReport.Actual_Visit_Date__c){
                    isChangeVisitedDate = true;
                }
            }

            if(isChangeVisitedDate){
                Date ActualVisitedDate = eachCallReport.Actual_Visit_Date__c;
                Integer VisitedYear = (ActualVisitedDate != null) ? ActualVisitedDate.Year() : 0;
                Integer CurrentYear = System.Today().Year();
                if(VisitedYear == CurrentYear){
                    Account accountRecord = accountMap.get(eachCallReport.CIS_ID__c);
                    Date FirstVisitedDate = accountRecord.First_Visited_Date__c;
                    if(FirstVisitedDate == null || ActualVisitedDate < FirstVisitedDate || FirstVisitedDate.Year() < CurrentYear){
                        accountRecord.First_Visited_Date__c = ActualVisitedDate;
                        updateAccount.add(accountRecord);
                    }
                }
            }
        }
        if(updateAccount.size() > 0){
            //TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccount;
            //TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }

    /* Panachai Reinthavorn
    createNextFollowUpDate()
    updateNextFollowUpDate()
    createNextFollowUpDateEventRelation()
    */
    private void updateNextFollowUpDate(List<Call_Report__c> callReports){
        Set<Id> callReportIDs = new Set<Id>();
        for(Call_Report__c callReport:callReports){
            callReportIDs.add(callReport.Id);
        }
        /* Check if there's old event records related to these given callreports]*/
        List<Event> eventsForUpdateOrDelete = [SELECT Id,WhatId,Call_Plan_Call_Report__c,Call_Plan_Call_Report__r.Next_Follow_up_Date_CBS__c,IsChild FROM Event WHERE Call_Plan_Call_Report__c IN: callReportIDs AND Subject='Next Follow Up Item'];
        
        Set<Id> callReportForUpdateOrDeleteIDs = new Set<Id>();
        for(Event event:eventsForUpdateOrDelete){
            callReportForUpdateOrDeleteIDs.add(event.Call_Plan_Call_Report__c);
        }

        Set<Id> callReportForCreatingNewEventIDs = callReportIDs;
        callReportForCreatingNewEventIDs.removeAll(callReportForUpdateOrDeleteIDs);
        List<Call_Report__c> callReportToCreateNewEvents = new List<Call_Report__c>();
        for(Call_Report__c callReport:callReports){
            if(callReportForCreatingNewEventIDs.contains(callReport.Id)){
                callReportToCreateNewEvents.add(callReport);
            }
        }
        
        boolean eventsIsNotEmpty = !eventsForUpdateOrDelete.isEmpty();
        if(eventsIsNotEmpty){
            List<Event> toUpdateEvents = new List<Event>();
            List<Event> toDeleteEvents = new List<Event>();
            for(Event event:eventsForUpdateOrDelete){
                Event newEventToUpdate = new Event(Id=event.Id);
                boolean isNextFollowUpDateTimeBlank = event.Call_Plan_Call_Report__r.Next_Follow_up_Date_CBS__c == null;
                boolean isNotChild = !event.isChild;
                if(!isNextFollowUpDateTimeBlank && isNotChild){
                    Datetime nextFollowUPDate = event.Call_Plan_Call_Report__r.Next_Follow_up_Date_CBS__c;
                    newEventToUpdate.StartDateTime = nextFollowUPDate;
                    newEventToUpdate.EndDateTime = nextFollowUPDate.addHours(numberOfHoursAddedInEndDateTime);
                    toUpdateEvents.add(newEventToUpdate);
                }else{
                    /*In case,User enter blank next follow up date*/
                    toDeleteEvents.add(newEventToUpdate);
                }
            }
            try{
                if(!toUpdateEvents.isEmpty()){
                    update toUpdateEvents;
                }
                if(!toDeleteEvents.isEmpty()){
                    delete toDeleteEvents;
                }
            }catch(Exception e){
                System.debug('Error Update New Event >> '+ e.getMessage() + ' : ' +e.getStackTraceString());
            } 
        }
        
        boolean callReportToCreateNewEventsIsNotEmpty = !callReportToCreateNewEvents.isEmpty();
        if(callReportToCreateNewEventsIsNotEmpty){
            createNextFollowUpDate(callReportToCreateNewEvents);    
        }
    }
    
    private void createNextFollowUpDate(List<Call_Report__c> callReports){  
        List<Event> toCreateEvents = new List<Event>();
        for(Call_Report__c callReport:callReports){
            boolean isNextFollowUpDateNotNull = (callReport.Next_Follow_up_Date_CBS__c != null);
            if(isNextFollowUpDateNotNull){
                Event newEvent = new Event();
                newEvent.Subject = 'Next Follow Up Item';
                newEvent.WhatId = callReport.CIS_ID__c ;
                newEvent.Call_Plan_Call_Report__c = callReport.Id;
                newEvent.OwnerId = (callReport != null)?callReport.CreatedById:UserInfo.getUserId();
                Datetime nextFollowUPDate = callReport.Next_Follow_up_Date_CBS__c;
                newEvent.StartDateTime = nextFollowUPDate;
                newEvent.EndDateTime = nextFollowUPDate.addHours(numberOfHoursAddedInEndDateTime);
                toCreateEvents.add(newEvent);
            }
        }
        try{
            if(toCreateEvents.size() > 0){
                insert toCreateEvents;
                createNextFollowUpDateEventRelation(toCreateEvents);
            }
        }catch(Exception e){
            System.debug('Error Insert New Event >> '+ e.getMessage() + ' : ' +e.getStackTraceString());
        }   
    }
    
    private void createNextFollowUpDateEventRelation(List<Event> events){
        List<EventRelation> toCreateEventRelations = new List<EventRelation>();
        Set<Id> eventOwnerIDs = new Set<Id>();
        for(Event event:events){
            eventOwnerIDs.add(event.OwnerId);
        }
        List<User> users = [SELECT Id,ManagerId FROM User WHERE Id IN: eventOwnerIDs];
        Map<String,User> userMap = new Map<String,User>();
        for(User user:users){
            userMap.put(user.Id,user);
        }
        for(Event event:events){
            if(event.OwnerId != null){
                String eventManagerId = userMap.get(event.OwnerId).ManagerId;
                if(eventManagerId != null){
                    EventRelation newEventRelation = new EventRelation(
                        EventId = event.Id,
                        RelationId = eventManagerId
                    );
                    toCreateEventRelations.add(newEventRelation);
                }
            }  
        }

        try{
            if(toCreateEventRelations.size() > 0) insert toCreateEventRelations;
        }catch(Exception e){
            System.debug('Error Insert newEventRelation >> ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }  
    }
    //industry data
    //INC000000947272
    private Boolean checkOfferInterestMustSelectCustomerBusinessCode(Call_Report__c eachCallReport){
        Boolean isPass = true;
        if(eachCallReport.Primary_Call_Report__c && 
            (eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY || eachCallReport.Servicing__c || eachCallReport.Renew_Servicing__c) ){
            if(eachCallReport.Customer_Business_Code__c == null || eachCallReport.Estimate_Credit_Model__c == null){
                eachCallReport.addError(System.Label.Business_Code_Should_not_be_NULL);
                isPass = false;
            }
        }
        return isPass;
    }
}