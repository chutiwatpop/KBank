/**
 * @author komsan.wi@beryl8.com
 * @16/07/2015 create new
 * @17/09/2015 update
 * @25/09/2015 remove stateful, change static variable to constants
 * @27/01/2015 Add Temporary_Ownership_Flag__c = false
 * @16/05/2016 change bussiness logic
 */

global class YearEndAssignment_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.Stateful {
    private List<Account> accountList;
    private SME_Admin__c sa = new SME_Admin__c();
    private Year_End_Config__c yearEndConfig;
    private List<Id> yearendNotUpdateList;
    private Map<String,Year_End_Ownership_Request__c> yearEndOwnerRequestApprovedMap;
    private Set<Id> relatedUpdateSet;
    private Set<Id> yearendRelatedSet;
    private Map<String,String> userChangeOpportunityOwnerMap;
    private Map<String,Year_End_Assignment__c> yearEndCompanyRelatedMap;

    global YearEndAssignment_Batch(){
        //initData();
    }
    global YearEndAssignment_Batch(Set<Id> yearEndSetID){
        //yearendRelatedSet = yearEndSetID;// Change related For Heap Size
        //initData();    
    }
    /*private void initData(){
        accountList = new List<Account>();
        sa = SME_Admin__c.getOrgDefaults();
        relatedUpdateSet = new Set<Id>();
        userChangeOpportunityOwnerMap = new Map<String,String>();
        yearEndConfig = Year_End_Config__c.getOrgDefaults();
        yearendNotUpdateList = new List<Id>();
        yearEndCompanyRelatedMap = new Map<String,Year_End_Assignment__c>();

        List<Year_End_Ownership_Request__c> yearEndOwnerRequestApproved = [SELECT Approval_Status__c,CIS_ID__c,Name,Refer_Out_To__c,Refer_Out_To__r.User__c,Year_End_Assignment__c FROM Year_End_Ownership_Request__c where Approval_Status__c = 'Approved'];
        yearEndOwnerRequestApprovedMap = new Map<String,Year_End_Ownership_Request__c>();
        if(yearEndOwnerRequestApproved.size() > 0){
            for(Year_End_Ownership_Request__c eachOwnerRequest : yearEndOwnerRequestApproved){
                yearEndOwnerRequestApprovedMap.put(eachOwnerRequest.Year_End_Assignment__c, eachOwnerRequest);
            }
        }

        List<String> cisRelateList = new List<String>();
        List<Year_End_Assignment__c> yearendRelatedList = [SELECT ID,Company_Related_Text__c FROM Year_End_Assignment__c WHERE Refer_Out_Reason__c=:GlobalConstants.REASON_COMPANY_RELATED AND Company_Related_Text__c !=null  AND Final_Assigned_Next_Year__r.Segment__c IN ('CB','MB') ];
        System.debug('yearendRelatedList.size()'+yearendRelatedList.size());
        if(yearendRelatedList.size() > 0){
            for(Year_End_Assignment__c eachYearEndRelate : yearendRelatedList){
                cisRelateList.add(eachYearEndRelate.Company_Related_Text__c);
            }
            List<Year_End_Assignment__c> yearendRelatedToList = [SELECT ID,CIS_ID_Unique__c,CBS_Group__c,CBS_Sub_Group__c FROM Year_End_Assignment__c WHERE CIS_ID_Unique__c=:cisRelateList ];
            if(yearendRelatedToList.size() > 0){
                for(Year_End_Assignment__c eachYearEndRelateTo : yearendRelatedToList){
                    yearEndCompanyRelatedMap.put(eachYearEndRelateTo.CIS_ID_Unique__c,eachYearEndRelateTo);
                }
            }
        }
    }*/

    public String query(){
        /*String query = 'SELECT Id,CIS_ID__c,CIS_ID__r.OwnerId,Final_Assigned_RM__c,Segment_Proposed__c,Final_Refer_Out__c,Final_Port_Pool__c,Final_Service_RM__c,Refer_Out_Reason__c,Refer_Out_Segment__c,CIS_ID_Unique__c,CIS_ID__r.Owner.Profile.Name,Final_Assigned_Next_Year__c,Final_Assigned_Next_Year__r.User__c,Final_Assigned_Next_Year__r.Role__c,Final_SVM_Next_Year__c,Final_SVM_Next_Year__r.User__c,Final_SVM_Next_Year__r.Role__c,Sales_Size__c,Final_Assigned_Next_Year__r.User__r.Segment__c,CBS_Group__c,CBS_Sub_Group__c,CIS_ID__r.Previous_Owner__c,Company_Related_Text__c FROM Year_End_Assignment__c WHERE  Status__c=\'Submitted\' and CIS_ID__c != null ';
        if(yearendRelatedSet!=null){
            query +=' AND ID IN:yearendRelatedSet';
        }
        return query;*/
        return '';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query());
    }

    global void execute(Database.BatchableContext BC, List<Year_End_Assignment__c> yearEnd){
        /*accountList = new List<Account>();
        for(Year_End_Assignment__c eachYearEnd : yearEnd){
            if(eachYearEnd.CIS_ID__c != null){
                relatedUpdateSet.add(eachYearEnd.CIS_ID__c); 
                if(yearEndOwnerRequestApprovedMap.containsKey(eachYearEnd.Id) && yearEndOwnerRequestApprovedMap.get(eachYearEnd.Id) != null && yearEndOwnerRequestApprovedMap.get(eachYearEnd.Id).Refer_Out_To__c != null && yearEndOwnerRequestApprovedMap.get(eachYearEnd.Id).Refer_Out_To__r.User__c != null){
                    userChangeOpportunityOwnerMap.put(eachYearEnd.CIS_ID__c, yearEndOwnerRequestApprovedMap.get(eachYearEnd.Id).Refer_Out_To__r.User__c);
                }else if(eachYearEnd.Final_Assigned_Next_Year__c != null && eachYearEnd.Final_Assigned_Next_Year__r.User__c != null){
                    userChangeOpportunityOwnerMap.put(eachYearEnd.CIS_ID__c, eachYearEnd.Final_Assigned_Next_Year__r.User__c);
                }
            }
            
            if(eachYearEnd.CIS_ID__r.OwnerId == eachYearEnd.Final_Assigned_Next_Year__r.User__c){
                yearendNotUpdateList.add(eachYearEnd.Id);
            }
            
            String customerSegment;
            if(eachYearEnd.Final_Assigned_Next_Year__r.User__r.Segment__c == GlobalConstants.SEGMENT_CB ){
                customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_CB;
            }else if(eachYearEnd.Final_Assigned_Next_Year__r.User__r.Segment__c == GlobalConstants.SEGMENT_MB ){
                customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_MB;
            }else if(eachYearEnd.Final_Assigned_Next_Year__r.User__r.Segment__c == GlobalConstants.SEGMENT_SE ){
                customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_SM;
            }else if(eachYearEnd.Final_Assigned_Next_Year__r.User__r.Segment__c == GlobalConstants.SEGMENT_ME ){
                if(eachYearEnd.Sales_Size__c < 100000000 ){
                    customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_LM;
                }else if(eachYearEnd.Sales_Size__c >= 100000000){
                    customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_UM;
                }else{
                    customerSegment = GlobalConstants.PRIMARY_SEGMENT_CODE_LM; // Add case Salesize null
                }
            }

            if (!eachYearEnd.Final_Refer_Out__c) {
                if(sa != null && ((eachYearEnd.Final_Port_Pool__c != null && eachYearEnd.Final_Assigned_Next_Year__r.User__c!=null && eachYearEnd.Final_Assigned_Next_Year__r.User__c!= sa.User_Record_ID__c) || eachYearEnd.Final_Assigned_Next_Year__r.User__c == sa.User_Record_ID__c)){
                    accountList.add(new Account (
                        Id = eachYearEnd.CIS_ID__c,
                        OwnerId = eachYearEnd.Final_Assigned_Next_Year__r.User__c,
                        Service_RM__c = (eachYearEnd.Final_SVM_Next_Year__r.User__c!=null)?eachYearEnd.Final_SVM_Next_Year__r.User__c:null,
                        Port_Pool__c = (eachYearEnd.Final_Assigned_Next_Year__r.User__c!=sa.User_Record_ID__c)?eachYearEnd.Final_Port_Pool__c:null,
                        Previous_Owner__c = (eachYearEnd.Final_Assigned_Next_Year__r.User__c != eachYearEnd.CIS_ID__r.OwnerId)?eachYearEnd.CIS_ID__r.OwnerId:eachYearEnd.CIS_ID__r.Previous_Owner__c,
                        Trash_Pool_Flag__c = false,
                        Group__c = (eachYearEnd.Refer_Out_Reason__c==GlobalConstants.REASON_COMPANY_RELATED && yearEndCompanyRelatedMap.containsKey(eachYearEnd.Company_Related_Text__c))?yearEndCompanyRelatedMap.get(eachYearEnd.Company_Related_Text__c).CBS_Group__c:null,
                        Sub_Group__c = (eachYearEnd.Refer_Out_Reason__c==GlobalConstants.REASON_COMPANY_RELATED && yearEndCompanyRelatedMap.containsKey(eachYearEnd.Company_Related_Text__c))?yearEndCompanyRelatedMap.get(eachYearEnd.Company_Related_Text__c).CBS_Sub_Group__c:null,
                        Primary_Segment_Code__c = customerSegment,
                        Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT
                    ));
                }
            }else if (eachYearEnd.Final_Refer_Out__c && eachYearEnd.Final_Assigned_Next_Year__r.User__c!=null) { // ได้จาก Referout
                if(eachYearEnd.Refer_Out_Reason__c == GlobalConstants.REASON_WRONG_AREA || eachYearEnd.Refer_Out_Reason__c== GlobalConstants.REASON_OTHER_TEAM ){
                    if(eachYearEnd.CIS_ID__r.OwnerId != eachYearEnd.Final_Assigned_Next_Year__r.User__c){
                        accountList.add(new Account (
                            Id = eachYearEnd.CIS_ID__c,
                            OwnerId = eachYearEnd.Final_Assigned_Next_Year__r.User__c,
                            Service_RM__c = (eachYearEnd.Final_SVM_Next_Year__r.User__c!=null)?eachYearEnd.Final_SVM_Next_Year__r.User__c:null,
                            Port_Pool__c = eachYearEnd.Final_Port_Pool__c,
                            Previous_Owner__c = (eachYearEnd.Final_Assigned_Next_Year__r.User__c != eachYearEnd.CIS_ID__r.OwnerId)?eachYearEnd.CIS_ID__r.OwnerId:eachYearEnd.CIS_ID__r.Previous_Owner__c,
                            Primary_Segment_Code__c = customerSegment,
                            Trash_Pool_Flag__c = false,
                            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT
                        ));
                    }
                }else if(eachYearEnd.Refer_Out_Reason__c== GlobalConstants.REASON_COMPANY_RELATED || eachYearEnd.Refer_Out_Reason__c== GlobalConstants.REASON_OTHER_SEGMENT || eachYearEnd.Refer_Out_Reason__c== GlobalConstants.REASON_NATIONALITY){
                   if(eachYearEnd.CIS_ID__r.OwnerId !=eachYearEnd.Final_Assigned_Next_Year__r.User__c){
                        
                        accountList.add(new Account (   
                            Id = eachYearEnd.CIS_ID__c,
                            OwnerId = eachYearEnd.Final_Assigned_Next_Year__r.User__c,
                            Service_RM__c = (eachYearEnd.Final_SVM_Next_Year__r.User__c!=null)?eachYearEnd.Final_SVM_Next_Year__r.User__c:null,
                            Port_Pool__c = eachYearEnd.Final_Port_Pool__c,
                            Primary_Segment_Code__c = customerSegment,
                            Trash_Pool_Flag__c = false,
                            Previous_Owner__c = (eachYearEnd.Final_Assigned_Next_Year__r.User__c != eachYearEnd.CIS_ID__r.OwnerId)?eachYearEnd.CIS_ID__r.OwnerId:eachYearEnd.CIS_ID__r.Previous_Owner__c,
                            Group__c = (eachYearEnd.Refer_Out_Reason__c==GlobalConstants.REASON_COMPANY_RELATED && yearEndCompanyRelatedMap.containsKey(eachYearEnd.Company_Related_Text__c))?yearEndCompanyRelatedMap.get(eachYearEnd.Company_Related_Text__c).CBS_Group__c:null,
                            Sub_Group__c = (eachYearEnd.Refer_Out_Reason__c==GlobalConstants.REASON_COMPANY_RELATED && yearEndCompanyRelatedMap.containsKey(eachYearEnd.Company_Related_Text__c))?yearEndCompanyRelatedMap.get(eachYearEnd.Company_Related_Text__c).CBS_Sub_Group__c:null,
                            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT
                        ));
                    }
                }else{
                    if(eachYearEnd.CIS_ID__r.OwnerId!=sa.User_Record_ID__c){
                        accountList.add(
                            new Account(
                                Id = eachYearEnd.CIS_ID__c,
                                OwnerId = eachYearEnd.Final_Assigned_Next_Year__r.User__c,
                                Service_RM__c =  (eachYearEnd.Final_SVM_Next_Year__r.User__c!=null)?eachYearEnd.Final_SVM_Next_Year__r.User__c:null,
                                Port_Pool__c = GlobalConstants.POOL,
                                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                                Previous_Owner__c = (eachYearEnd.Final_Assigned_Next_Year__r.User__c != eachYearEnd.CIS_ID__r.OwnerId)?eachYearEnd.CIS_ID__r.OwnerId:eachYearEnd.CIS_ID__r.Previous_Owner__c,
                                Trash_Pool_Flag__c = true
                            )
                        );
                    }
                }
            }
        }
        clearance();*/
    }

    /*protected override void clearance(){
        if(accountList!=null && accountList.size() > 0){
            Account_Service.forceUnloadRelatedObject = true;
            Account_Service.callingFromYearEndBatch = true;
            update accountList;
        }
        super.clearance();
    }*/

    global void finish(Database.BatchableContext BC){
        //Database.executeBatch(new SME_YearEndOpportunityChangeOwner_Batch(relatedUpdateSet,userChangeOpportunityOwnerMap));
        //Database.executeBatch(new SME_YearEndContactChangeOwner_Batch());
        //Database.executeBatch(new SME_YearEndCloseCallReport_Batch(yearendNotUpdateList,relatedUpdateSet));
    }
}