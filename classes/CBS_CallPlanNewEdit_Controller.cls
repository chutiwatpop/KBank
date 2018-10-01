public with sharing class CBS_CallPlanNewEdit_Controller {

    private final sObject mysObject;
    public String mode {get; private set;}
    public String subTitle {get; private set;}
    public Call_Report__c myCallPlan {get; set;}
    public List<Target_List__c> leadList {get; set;}
    public Boolean hasLeads {get; set;}
    public Account accountForLookup{get;set;}
    public boolean hasCallReportID{get;set;}
    public Boolean hasErrorMessage{get;set;}

    public CBS_CallPlanNewEdit_Controller(ApexPages.StandardController stdController) {
        
        this.myCallPlan = (Call_Report__c)stdController.getRecord();
        this.accountForLookup = new Account();
        this.hasCallReportID = false;
        this.hasErrorMessage = true;

        if(this.myCallPlan.Id == null){
            mode = 'new';
            subTitle = 'New Call Plan';
            this.hasCallReportID = false;

            Map<String, String> parameterFromPageReferenceMap = ApexPages.currentpage().getparameters();
            boolean isParameterFromPageReferenceMapEmpty = parameterFromPageReferenceMap.isEmpty();

            if(!isParameterFromPageReferenceMapEmpty){
                String cisIDFromPageReference = parameterFromPageReferenceMap.get('accountId');
                
                if(!String.isBlank(cisIDFromPageReference)){
                    this.myCallPlan.CIS_ID__c = cisIDFromPageReference;
                    accountForLookup =  Account_Service.getAccountByIDUseInCallPlan(this.myCallPlan.CIS_ID__c)[0];
                }
            }
        }
        else{
            this.hasCallReportID = true;
            this.myCallPlan = CallReport_Service.getCallPlanForEditPage(this.myCallPlan.Id)[0];

            mode = 'edit';
            subTitle = this.myCallPlan.Name;
            
            if(this.myCallPlan.CIS_ID__c != null){
                accountForLookup =  Account_Service.getAccountByIDUseInCallPlan(this.myCallPlan.CIS_ID__c)[0];
            }
        }
        
        setUpLeadForShow();
    }

    private void setUpLeadForShow(){
        leadList = new List<Target_List__c>();
        hasLeads = false;

        if(this.myCallPlan.CIS_ID__c != null){
            List<Target_List__c> fetchTargetLists = CBS_CallPlanCallReportWOS_Service.fetchTargetLists(this.myCallPlan.CIS_ID__c);
            Set<String> callPlanCallReportStatus = new Set<String>{GlobalConstants.STATUS_NEW, GlobalConstants.PLAN, GlobalConstants.CONTACTED};
            Set<String> leadForFeedbackStatus = new Set<String>{GlobalConstants.STATUS_NEW};
            for(Target_List__c eachTargetList : fetchTargetLists){
                if(eachTargetList.Lead_Type__c.equals(GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER)){
                    Boolean isTargetListStatusAllow = callPlanCallReportStatus.contains(eachTargetList.Status__c);
                    if(isTargetListStatusAllow){
                        leadList.add(eachTargetList);
                    }
                }
                else if(eachTargetList.Lead_Type__c.equals(GlobalConstants.LEAD_FOR_FEEDBACK)){
                    Boolean isTargetListStatusAllow = leadForFeedbackStatus.contains(eachTargetList.Status__c);
                    if(isTargetListStatusAllow){
                        leadList.add(eachTargetList);
                    }
                }
                else{
                    leadList.add(eachTargetList);
                }
            }
        }
        
        if(leadList.isEmpty()){
            hasLeads = false;
        }
        else{
            hasLeads = true;
        }
    }

    public void fetchPreviousCallReport(){
        String callReportForCISLookUpInputFieldCISID = ApexPages.currentPage().getParameters().get('callReportForCISLookUpInputFieldCISID');
        this.myCallPlan.CIS_ID__c = callReportForCISLookUpInputFieldCISID;
        accountForLookup =  Account_Service.getAccountByIDUseInCallPlan(this.myCallPlan.CIS_ID__c)[0];

        setUpLeadForShow();
    }

    public pageReference save(){
        String errMessage;
        
        if(String.isBlank(this.myCallPlan.CIS_ID__c)){
            hasErrorMessage = true;
            errMessage = label.CBSCallReport_Require_CIS_ID;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
        }
        Account checkOwnerAccount;
        if(!String.isEmpty(this.myCallPlan.CIS_ID__c)){
            checkOwnerAccount = Account_Service.getAccountByID(this.myCallPlan.CIS_ID__c)[0];
            String ownerAccountId = checkOwnerAccount.OwnerID;
            String userId = UserInfo.getUserId();

            if(!ownerAccountId.equals(userId)){
                hasErrorMessage = true;
                errMessage = label.CBSCallReport_Require_Same_Owner;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
                
            }
            else{
                try{
                    hasErrorMessage = false;
                    if(mode.equals('new')){
                        insert myCallPlan;
                    }
                    else if(mode.equals('edit')){
                        update myCallPlan;
                    }
                }catch(System.DMLException e){
                    hasErrorMessage = true;
                    ApexPages.addMessages(e);
                    return null;
                }  
            }
        }
        PageReference callPlanPage = new ApexPages.StandardController(myCallPlan).view();

        if(checkOwnerAccount != null && checkOwnerAccount.CIS__c != null) {
            // Add redirect CR024 Fraud
            String isCheckFraud = ApexPages.currentPage().getParameters().get('isCheckFraud');
            if(isCheckFraud != null && isCheckFraud == '0') {
                return callPlanPage;
            }
            String pageRefString = callPlanPage.getUrl();
            pageRefString = EncodingUtil.urlEncode(pageRefString, 'UTF-8');

            callPlanPage = new PageReference('/apex/SME_FraudWarning_Page');
            callPlanPage.getParameters().put('existingId', this.myCallPlan.CIS_ID__c);
            callPlanPage.getParameters().put('redirectNewPage', pageRefString);
        }
            

        return callPlanPage;
    }

}