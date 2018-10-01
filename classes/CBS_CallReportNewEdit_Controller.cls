public with sharing class CBS_CallReportNewEdit_Controller {

//    public String myCallReportId{get;set;}
//    private String myCallReportAccountId = '';
//    private Call_Report__c myCallPlanCallReport;
//    public String callReportRedirectURL {get;set;}
//    private Map<String,RecordType> callReportRecordTypesMap = new Map<String,Recordtype>();
//    private Map<String,List<Lead_To_Do_Response__c>> leadName_LeadToDoResponsesMap;
//    private Map<id,CBS_CallReportWrapper.LeadWrapper> targetListId_LeadWrapperMap;
//    private Boolean hasCISID{get;set;}
//    public Boolean hasCallReportID{get;set;}
    
//    public Call_Report__c callReportForCISLookUpInputField{get;set;}
//    public CBS_CallReportWrapper.CallReportWrapper myCallReport{get;set;}
//    public List<CBS_CallReportWrapper.NewContactWrapper> newContacts{get;set;}
//    public List<CBS_CallReportWrapper.ExistingContactWrapper> existingContacts{get;set;}
//    public List<CBS_CallReportWrapper.LeadWrapper> leads{get;set;}

//    public Boolean hasErrorMessage{get;set;}
//    public Boolean hasLeads {get;set;}


//    public Boolean isCallPlanNoReport{get;set;}
//    public List<String> savedOpptyIds{get;set;}
//    public String savedOpptyIdsJSON {get;set;}
//    public String savedCallReportId{get;set;}
//    private Account account;
//    public Account accountForLookup{get;set;}
//    private Account beforeSaveAccount;


//    private Call_Report__c toUpsertCallReport;

//    //INC000000662593
//    public List<SelectOption> stageOppPlanning {get;set;}

//    //New CR
//    public Map<String,Boolean> shouldRenderOppPlanningGroupMapByProductGroupName {get;set;}
//    public Map<String,List<CBS_OpportunityPlanningWrapper>> oppPlanningMapByproductGroup {get;set;}
//    public List<GroupOpportunityPlanningWrapper> groupOppPlanningList {get;set;}

//    public CBS_CallReportWrapper.CallReportProductModal callReportProductModal {get;set;}

//    public  List<SelectOption> productTypeList {get;set;}
//    public Integer groupOppPlanningIndex {get;set;}
//    public String  editGroupName {get;set;}
//    public Integer editGroupIndex {get;set;}
//    public String  editProductCode {get;set;}

//    public Map<String,Opportunity_Planning_Type__c> oppPlanningCSMapByOppPlanType {get;set;}
//    public Set<String> oppPlaningTypeSetNotAllowEditAmount;
//    public Set<String> oppPlaningTypeSetAllowGrouping;

//        public static String getCustomerName(String accountId){
//            String customerURL = '';
//            List<Account> accs = Account_Service.getAccountByID(accountId);
//            if(!accs.isEmpty()){
//                Account account = accs.get(0);
//                if(String.isBlank(account.Encrypt_Fullname_TH__c)){
//                    customerURL = Label.MashupUrl + account.Encrypt_Fullname_EN__c;
//                }else{
//                    customerURL = Label.MashupUrl + account.Encrypt_Fullname_TH__c;
//                }
                
//            }
//            return customerURL;
//        }
//        public CBS_CallReportNewEdit_Controller(ApexPages.StandardController stdController) {
//            this.myCallReportId = '';
//            this.callReportRedirectURL = '';
            
//            this.hasCallReportID = false;
//            this.hasCISID = false;
  
//            this.oppPlanningCSMapByOppPlanType = CBS_Utility.getOppPlanningTypeCustomSettingMapByType();
//            setOppPlanType_AllowEditAmount_Grouping();

//            this.callReportRecordTypesMap = CBS_Utility.getCallReportRecordTypesMap();
//            this.beforeSaveAccount = null;
//            this.account = new Account();
//            this.callReportForCISLookUpInputField = new Call_Report__c();
//            this.toUpsertCallReport = new Call_Report__c();
//            this.accountForLookup = new Account();
//            this.leads = new List<CBS_CallReportWrapper.LeadWrapper>();
//            this.leadName_LeadToDoResponsesMap = new Map<String,List<Lead_To_Do_Response__c>>();
//            this.targetListId_LeadWrapperMap = new Map<id,CBS_CallReportWrapper.LeadWrapper>();

//            //New CR
//            this.callReportProductModal = new CBS_CallReportWrapper.CallReportProductModal();

//            this.groupOppPlanningList = new List<GroupOpportunityPlanningWrapper>();
            
//            //INC000000662593
//            this.stageOppPlanning = new List<SelectOption>();
//            Schema.DescribeFieldResult statusFieldDescription = Opportunity_Planning__c.Status__c.getDescribe();
//            for(Schema.Picklistentry picklistEntry:statusFieldDescription.getPicklistValues()){
//                if(pickListEntry.getValue()!=null && pickListEntry.getValue() != GlobalConstants.NOT_INTERESTED){
//                    stageOppPlanning.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
//                }
//            }

//            this.productTypeList = new List<SelectOption>();
//            this.productTypeList.add(new SelectOption(GlobalConstants.NONE,GlobalConstants.NONE));
//            for(Schema.Picklistentry picklistEntry: Opportunity_Planning__c.Product_Type__c.getDescribe().getPicklistValues()){
//                if(pickListEntry.getValue()!=null ){
//                    this.productTypeList.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
//                }
//            }

//            Map<String, String> parameterFromPageReferenceMap = ApexPages.currentpage().getparameters();
//            Boolean isParameterFromPageReferenceMapEmpty = parameterFromPageReferenceMap.isEmpty();
//            if(!isParameterFromPageReferenceMapEmpty){
//                String cisIDFromPageReference = parameterFromPageReferenceMap.get('accountId');
//                Boolean isCISIDFromPageBlank = String.isBlank(cisIDFromPageReference);
//                if(!isCISIDFromPageBlank){
//                    List<Account> accs = Account_Service.getAccountByID(cisIDFromPageReference);
//                    Account acc = accs[0];
//                    callReportForCISLookUpInputField.CIS_ID__c = acc.Id;
//                    this.myCallReportAccountId = acc.Id;
//                    this.hasCISID = true;
//                }else{
//                    this.hasCISID = false;
//                }
//                String idFromPageReference = parameterFromPageReferenceMap.get('recid');
//                Boolean isIDFromPageBlank = String.isBlank(idFromPageReference);
//                if(!isIDFromPageBlank){
//                    this.myCallReportId = idFromPageReference;
//                    this.hasCallReportID = true;
//                }else{
//                    this.hasCallReportID = false;
//                }
//            }else{
//                this.hasCISID = false;
//            }

//            Boolean createCallReportWithCallPlan = this.hasCallReportID && this.hasCISID;
//            Boolean createCallReportFromCustomerInfo = !this.hasCallReportID && this.hasCISID;
//            Boolean createEmptyCallReportWithNoPlan = !this.hasCallReportID && !this.hasCISID ;
//            this.hasLeads = false;
//            if(createCallReportWithCallPlan){
//                accountForLookup = Account_Service.getAccountByID(this.callReportForCISLookUpInputField.CIS_ID__c)[0];
//                fetchCallPlan();
//                fetchOpportunityPlannings();
//                fetchAccountWithCIS();
//                setUpLeadName_LeadToDoResponsesMapANDLeadsANDtargetListId_LeadWrapperMap();
//                this.isCallPlanNoReport = false;
//            }else if(createCallReportFromCustomerInfo){
//                createBlankCallReport();
//                accountForLookup =  Account_Service.getAccountByID(this.callReportForCISLookUpInputField.CIS_ID__c)[0];
//                this.myCallReport.cisName = getCustomerName(this.myCallReportAccountId);
//                fetchOpportunityPlannings();
//                fetchAccountWithCIS();
//                setUpLeadName_LeadToDoResponsesMapANDLeadsANDtargetListId_LeadWrapperMap();
//                this.isCallPlanNoReport = true;
//            }else if(createEmptyCallReportWithNoPlan){
//                createBlankCallReport();
//                this.isCallPlanNoReport = true;
//            }
//            createDefaultExistingContacts();
//            createDefaultNewContacts();
//            this.hasErrorMessage = false;
//            this.savedOpptyIds = new List<String>();
//        }
//        private void createBlankCallReport(){
//            Call_Report__c defaultCallReport = new Call_Report__c(
//                                                Visit_Objective_CBS__c = '',
//                                                Status__c = GlobalConstants.DEFAULT_CBS_CALLREPORT_STATUS,
//                                                Actual_Visit_Date__c = System.today(),
//                                                Contact_Channel__c = '',
//                                                Customer_Important_Note_CBS__c = '');

//            this.myCallPlanCallReport = defaultCallReport;
//            this.myCallPlanCallReport.RecordTypeId = this.callReportRecordTypesMap.get(GlobalConstants.CBS_CALL_REPORT_NO_PLAN_DEVNAME).Id;
//            this.myCallReport = new CBS_CallReportWrapper.CallReportWrapper(this.myCallPlanCallReport);
//            if(this.hasCISID){
//                List<Account> accs = Account_Service.getAccountByID(this.myCallReportAccountId);
//                Account relatedCISAccount = accs[0];
//                this.myCallReport.cisName = relatedCISAccount.Name; 
//            }
//        }
//        private void clearContactList(){
//            this.existingContacts.clear();
//            this.newContacts.clear();
//            createDefaultExistingContacts();
//            createDefaultNewContacts();
//        }
//        private void fetchCallPlan(){
//            String callPlanRecordTypeId = this.callReportRecordTypesMap.get(GlobalConstants.CBS_CALL_PLAN_DEVNAME).Id;
//            List<Call_Report__c> callPlans = CBS_CallPlanCallReport_Service.fetchCallPlan(this.myCallReportId,callPlanRecordTypeId);
//            Boolean isCallPlansEmpty = callPlans.isEmpty();
//            if(!isCallPlansEmpty){
//                this.myCallPlanCallReport = callPlans[0];
//                this.myCallPlanCallReport.Status__c = GlobalConstants.DEFAULT_CBS_CALLREPORT_STATUS;
//                this.myCallPlanCallReport.RecordTypeId = this.callReportRecordTypesMap.get(GlobalConstants.CBS_CALL_REPORT_DEVNAME).Id;
//                if(!String.isBlank(callPlans[0].Planned_Product_CBS__c)){
//                    this.myCallPlanCallReport.Product_Service__c = callPlans[0].Planned_Product_CBS__c;
//                }
//                if(!String.isBlank(callPlans[0].Planned_Visit_Objective_CBS__c)){
//                    this.myCallPlanCallReport.Visit_Objective_CBS__c = callPlans[0].Planned_Visit_Objective_CBS__c;
//                }
//                this.myCallPlanCallReport.Actual_Visit_Date__c = System.today();
//                this.myCallReport = new CBS_CallReportWrapper.CallReportWrapper(this.myCallPlanCallReport);
//                this.myCallReport.cisName = getCustomerName(callPlans[0].CIS_ID__c);
//                this.myCallReportAccountId = callPlans[0].CIS_ID__c;
//            }else{
//                createBlankCallReport();
//            }
//        }
//        public void fetchPreviousCallReport(){
//            this.toUpsertCallReport = new Call_Report__c();
//            String callReportForCISLookUpInputFieldCISID = ApexPages.currentPage().getParameters().get('callReportForCISLookUpInputFieldCISID');
//            this.callReportForCISLookUpInputField.CIS_ID__c = callReportForCISLookUpInputFieldCISID;
//            accountForLookup =  Account_Service.getAccountByID(this.callReportForCISLookUpInputField.CIS_ID__c)[0];
//            Boolean isValidCIS = validateCIS();
//            if(isValidCIS){
//                String assignedCallReportForCISLookUpInputField = this.callReportForCISLookUpInputField.CIS_ID__c;
//                Boolean isAssignedCallReportForCISLookUpInputFieldBlank = String.isBlank(assignedCallReportForCISLookUpInputField);
//                if(!isAssignedCallReportForCISLookUpInputFieldBlank){
//                    this.myCallReportAccountId = assignedCallReportForCISLookUpInputField;
//                    this.hasCISID = true;
//                }else{
//                    this.hasCISID = false;
//                }
//                this.myCallReport.cisName = getCustomerName(assignedCallReportForCISLookUpInputField);
//                if(this.hasCISID){
//                    fetchOpportunityPlannings();
//                    setUpLeadName_LeadToDoResponsesMapANDLeadsANDtargetListId_LeadWrapperMap();
//                }
//                clearContactList();
//                fetchAccountWithCIS();
//            }else{
//                String cisNumber = Account_Service.getAccountByID(this.callReportForCISLookUpInputField.CIS_ID__c)[0].CIS__c;
//                String errorMessage = String.format(label.CBSCallReport_Insufficient_privilege_to_access_customer,new LIST<String>{cisNumber});
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMessage));
//                this.callReportForCISLookUpInputField = new Call_Report__c();
//            }
//        }
//        private void fetchOpportunityPlannings(){
//            List<Opportunity_Planning__c> fetchOppPlannings = CBS_CallPlanCallReportWOS_Service.getOpportunityPlannings(this.myCallReportAccountId);
//            this.oppPlanningMapByproductGroup = new Map<String,List<CBS_OpportunityPlanningWrapper>>();
//            for(String productGroup : callReportProductModal.productGroupList){
//                oppPlanningMapByproductGroup.put(productGroup,new List<CBS_OpportunityPlanningWrapper>());
//            }
//            if(!fetchOppPlannings.isEmpty()){
//                for(Opportunity_Planning__c oppPlan:fetchOppPlannings){
//                    String productGroup = oppPlan.Opportunity_Planning_Line_Items__r.get(0).Call_Report_Product_List_Master__r.Product_Group__c;
//                    if(!String.isBlank(productGroup ) && this.oppPlanningMapByproductGroup.containsKey(productGroup)){
//                        CBS_OpportunityPlanningWrapper oppPlanningWrapper = new CBS_OpportunityPlanningWrapper(oppPlan,oppPlan.Opportunity_Planning_Line_Items__r);
//                        oppPlanningWrapper.oppPlaningTypeSetNotAllowEditAmount = this.oppPlaningTypeSetNotAllowEditAmount;
//                        oppPlanningWrapper.allowGrouping = this.oppPlanningCSMapByOppPlanType.containsKey(oppPlan.Product_Type__c) ? this.oppPlanningCSMapByOppPlanType.get(oppPlan.Product_Type__c).Allow_Grouping__c : false;
//                        oppPlanningWrapper.allowAddToExistingOpportunity = oppPlanningWrapper.allowGrouping;
//                        this.oppPlanningMapByproductGroup.get(productGroup).add(oppPlanningWrapper);
//                    }
//                }

//            }
//            calculateShouldRenderOppPlanningGroupMapByProductGroupName();
//        }
//        public PageReference fetchExistingContactInformation(){
//            Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('rowToFetchIndex'));
//            if( this.existingContacts.get(indexVal).existingContact.Contact_Name__c != null){
//                String contactId = this.existingContacts.get(indexVal).existingContact.Contact_Name__c;
//               this.existingContacts.get(indexVal).existingContactInfo = CBS_CallPlanCallReport_Service.getContact(contactId);
//            }
//            return null;
//        }
//        public void fetchAccountWithCIS(){
//            String accountId = this.callReportForCISLookUpInputField.CIS_ID__c;
//            this.account =  Account_Service.getAccountInformation(accountId);
//        }
//        private void createDefaultNewContacts(){
//            this.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>{new CBS_CallReportWrapper.NewContactWrapper(new Contact(Contact_Position__c = GlobalConstants.DEFAULT_CBS_NEW_CONTACT_CONTACTPOSITION))};
//        }
//        private void createDefaultExistingContacts(){
//            this.existingContacts = new List<CBS_CallReportWrapper.ExistingContactWrapper>();
//            this.existingContacts.add(new CBS_CallReportWrapper.ExistingContactWrapper(new Call_Report_Contact__c()));
//        }
//        //@TODO change fetch related target list condition
//        private void setUpLeadName_LeadToDoResponsesMapANDLeadsANDtargetListId_LeadWrapperMap(){
//            List<Target_List__c> fetchTargetLists = CBS_CallPlanCallReportWOS_Service.fetchTargetLists(this.myCallReportAccountId);
//            List<Target_List__c> targetListsWithCondition = new List<Target_List__c>();
//            Set<String> callPlanCallReportStatus = new Set<String>{GlobalConstants.STATUS_NEW, GlobalConstants.PLAN, GlobalConstants.CONTACTED};
//            Set<String> leadForFeedbackStatus = new Set<String>{GlobalConstants.STATUS_NEW};
//            for(Target_List__c eachTargetList : fetchTargetLists){
//                if(eachTargetList.Lead_Type__c.equals(GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER)){
//                    Boolean isTargetListStatusAllow = callPlanCallReportStatus.contains(eachTargetList.Status__c);
//                    if(isTargetListStatusAllow)
//                    {
//                        targetListsWithCondition.add(eachTargetList);
//                    }
//                }
//                else if(eachTargetList.Lead_Type__c.equals(GlobalConstants.LEAD_FOR_FEEDBACK)){
//                    Boolean isTargetListStatusAllow = leadForFeedbackStatus.contains(eachTargetList.Status__c);
//                    if(isTargetListStatusAllow)
//                    {
//                        targetListsWithCondition.add(eachTargetList);
//                    }
//                }
//                else{
//                    targetListsWithCondition.add(eachTargetList);
//                }
//            }
//            fetchTargetLists.clear();
//            fetchTargetLists.addAll(targetListsWithCondition);
//            Set<String> leadCampaignIDs = new Set<String>();
//            for(Target_List__c targetList:fetchTargetLists){
//                leadCampaignIDs.add(targetList.Lead_Campaign__c);
//            }
//            List<Campaign> fetchLeadCampaigns = CBS_CallPlanCallReport_Service.getCampaigns(leadCampaignIDs);
//            Set<String> leadSubtypes = new Set<String>();
//            for(Campaign campaign:fetchLeadCampaigns){
//                leadSubtypes.add(campaign.Sub_Type_CBS__c);
//            }
//            List<Lead_To_Do_Response__c> fetchLeadToResponses = CBS_CallPlanCallReport_Service.getLeadToDoResponses(leadSubtypes);
//            for(Lead_To_Do_Response__c leadToDoResponse:fetchLeadToResponses){
//                String leadToDoResponseType = leadToDoResponse.Type__c;
//                Boolean isNewKey = !(this.leadName_LeadToDoResponsesMap.containsKey(leadToDoResponseType));
//                if(isNewKey){
//                    this.leadName_LeadToDoResponsesMap.put(leadToDoResponseType,new List<Lead_To_Do_Response__c>());
//                }
//                List<Lead_To_Do_Response__c> relateLeadToDoResponses = this.leadName_LeadToDoResponsesMap.get(leadToDoResponseType);
//                relateLeadToDoResponses.add(leadToDoResponse);
//            }
//            for(String leadName:this.leadName_LeadToDoResponsesMap.keySet()){
//                List<Lead_To_Do_Response__c> leadToDoResponses = this.leadName_LeadToDoResponsesMap.get(leadName);
//                for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                    Boolean requiredLevel2isTrue = leadToDoResponse.Required_Level_2__c;
//                    if(requiredLevel2isTrue){
//                        for(Lead_To_Do_Response__c leadToDoResponseToSet:leadToDoResponses){
//                            Boolean isTypeMatch = leadToDoResponse.Type__c.equalsIgnoreCase(leadToDoResponseToSet.Type__c);
//                            Boolean isResponseLevel1Match = leadToDoResponse.Response_Level_1__c.equalsIgnoreCase(leadToDoResponseToSet.Response_Level_1__c);
//                            if(isTypeMatch && isResponseLevel1Match){
//                                leadToDoResponseToSet.Required_Level_2__c = true;   
//                            }
//                        }
//                        break;
//                    }
//                }
//            }

//            this.leads = new List<CBS_CallReportWrapper.LeadWrapper>();
//            for(Target_List__c targetList:fetchTargetLists){
//                String targetListLeadSubtype = targetList.Lead_Subtype_CBS__c;
//                String targetListResponseLevel1 = targetList.Response_Level_1__c!=null?targetList.Response_Level_1__c:'';
//                List<SelectOption> responseLevel1s = getResponseLevel1ByTargetListLeadSubtype(targetListLeadSubtype);
//                List<SelectOption> responseLevel2s = getResponseLevel2ByTargetListLeadANDResponseLevel1(targetListLeadSubtype,targetListResponseLevel1);
//                CBS_CallReportWrapper.LeadWrapper lead = new CBS_CallReportWrapper.LeadWrapper(targetList,responseLevel1s,responseLevel2s);
//                String leadToDoReponseType = targetList.Lead_Subtype_CBS__c;
//                String targetListResponseLevel2 = targetList.Response_Level_2__c!=null?targetList.Response_Level_2__c:'';
//                Boolean isRequiredLevel2 = false;
//                lead.ableToAnswerLvl1 = TargetList_Service.ableToEditResponseLvl1(targetList);
//                if(responseLevel1s.isEmpty()){
//                    lead.ableToAnswerLvl1 = false;
//                }
//                List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(leadToDoReponseType);
//                if(leadToDoResponses != null && !leadToDoResponses.isEmpty()){
//                    for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                        Boolean isThisLeadToDoResponseEqualsResponseLevel1 = (leadToDoResponse.Response_Level_1__c).equalsIgnoreCase(targetListResponseLevel1);
//                        if(isThisLeadToDoResponseEqualsResponseLevel1){
//                            if(leadToDoResponse.Required_Level_2__c){
//                                isRequiredLevel2 = true;
//                                break;
//                            }
//                        }
//                    }
//                    if(!isRequiredLevel2){
//                        lead.isRequiredMemo = isResponseLevel1RequireMemo(leadToDoReponseType,targetListResponseLevel1);
//                    }else{
//                        lead.isRequiredLevel2 = true;
//                        lead.isRequiredMemo = isResponseLevel2RequireMemo(leadToDoReponseType,targetListResponseLevel1,targetListResponseLevel2);
//                    }
//                }else{
//                    lead.isRequiredMemo = false;
//                }
//                targetListId_LeadWrapperMap.put(targetList.Id,lead);
//                this.leads.add(lead);
//            }
//            if(this.leads.isEmpty()){
//                this.hasLeads = false;
//            }else{
//                this.hasLeads = true;
//            }
//        }
//        private List<SelectOption> getResponseLevel1ByTargetListLeadSubtype(String targetListLeadSubtype){
//            List<String> responseLevel1s;
//            Set<String> responseLevel1Set = new Set<String>();
//            List<Lead_To_Do_Response__c> leadToDoResponses = this.leadName_LeadToDoResponsesMap.get(targetListLeadSubtype)!=null?this.leadName_LeadToDoResponsesMap.get(targetListLeadSubtype):new List<Lead_To_Do_Response__c>();
//            Boolean leadToDoResponsesNotFound = leadToDoResponses.isEmpty();
//            if(!leadToDoResponsesNotFound){
//                responseLevel1Set.add(GlobalConstants.NONE);
//                for(Lead_To_Do_Response__c leadToDeoResponse:leadToDoResponses){
//                    responseLevel1Set.add(leadToDeoResponse.Response_Level_1__c);
//                }
//            }
//            responseLevel1s = new List<String>(responseLevel1Set);
//            responseLevel1s.sort();
//            List<SelectOption> responseLevel1SelectOptions = GlobalUtility.createSelectOptionsFromStrings(responseLevel1s);
//            return responseLevel1SelectOptions;
//        }
//        public void updateResponseLevel2ByPickedResponseLevel1(){
//            String targetListId = apexpages.currentpage().getParameters().get('targetListId');
//            CBS_CallReportWrapper.LeadWrapper toUpdateLead =  targetListId_LeadWrapperMap.get(targetListId);
//            String targetListCampaignName = toUpdateLead.targetList.Lead_Subtype_CBS__c;
//            String responseLevel1 = toUpdateLead.responseLevel1;
//            toUpdateLead.responseLevel2Options = getResponseLevel2ByTargetListLeadANDResponseLevel1(targetListCampaignName,responseLevel1);
//            Boolean isRequiredLevel2 = false;
//            List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(targetListCampaignName);

//            if(leadToDoResponses != null && !leadToDoResponses.isEmpty()){
//                for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                    Boolean isThisLeadToDoResponseEqualsResponseLevel1 = (leadToDoResponse.Response_Level_1__c).equalsIgnoreCase(responseLevel1);
//                    if(isThisLeadToDoResponseEqualsResponseLevel1){
//                        if(leadToDoResponse.Required_Level_2__c){
//                            isRequiredLevel2 = true;
//                            break;
//                        }
//                    }
//                }
//            }
//            toUpdateLead.isRequiredLevel2 = isRequiredLevel2;
//            updateRequiredMemoByPickedResponseLevel1();
//        }
//    //Fix INC000000629787
//        public void updateRequiredMemoByPickedResponseLevel1(){
//            String targetListId = apexpages.currentpage().getParameters().get('targetListId');
//            CBS_CallReportWrapper.LeadWrapper toUpdateLead =  targetListId_LeadWrapperMap.get(targetListId);
//            String leadToDoReponseType = toUpdateLead.targetList.Lead_Subtype_CBS__c;
//            String responseLevel1 = toUpdateLead.responseLevel1;
//            Boolean isRequiredLevel2 = false;
//            List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(leadToDoReponseType);
//            String responseLevel2 = '';
//            for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                Boolean isThisLeadToDoResponseEqualsResponseLevel1 = (leadToDoResponse.Response_Level_1__c).equalsIgnoreCase(responseLevel1);
//                if(isThisLeadToDoResponseEqualsResponseLevel1){
//                    if(leadToDoResponse.Required_Level_2__c){
//                        isRequiredLevel2 = true;
//                        if(isRequiredLevel2){
//                            responseLevel2 = leadToDoResponse.Response_Level_2__c;
//                            break;
//                        }
//                    }
//                }
//            }
//            if(isRequiredLevel2){
//                if(responseLevel2!=null){
//                    toUpdateLead.isRequiredMemo = isResponseLevel2RequireMemo(leadToDoReponseType,responseLevel1,responseLevel2);
//                }else{
//                    if(toUpdateLead.responseLevel2Options.size()!=0){
//                        responseLevel2 = toUpdateLead.responseLevel2Options[0].getvalue();
//                        toUpdateLead.isRequiredMemo = isResponseLevel2RequireMemo(leadToDoReponseType,responseLevel1,responseLevel2);
//                        toUpdateLead.targetList.Memo__c = '';
//                    }else{
//                        toUpdateLead.isRequiredMemo = false;
//                        toUpdateLead.targetList.Memo__c = '';
//                    }
//                }
//            }else{
//                toUpdateLead.isRequiredMemo = isResponseLevel1RequireMemo(leadToDoReponseType,responseLevel1);
//                if(!toUpdateLead.isRequiredMemo){
//                    toUpdateLead.targetList.Memo__c = '';
//                }
//            }
//        }
//        private Boolean isResponseLevel1RequireMemo(String leadToDoReponseType,String responseLevel1Answer){
//            Boolean isRequire = false;
//            List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(leadToDoReponseType);
//            if(leadToDoResponses!= null && !leadToDoResponses.isEmpty()){
//                for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                    Boolean isMatch = responseLevel1Answer.equalsIgnoreCase(leadToDoResponse.Response_Level_1__c);
//                    if(isMatch){
//                        isRequire = leadToDoResponse.Required_Memo__c;
//                        break;
//                    }
//                }
//            }
//            return isRequire;
//        }
//        public void updateRequiredMemoByPickedResponseLevel2(){
//            String targetListId = apexpages.currentpage().getParameters().get('targetListId');
//            CBS_CallReportWrapper.LeadWrapper toUpdateLead =  targetListId_LeadWrapperMap.get(targetListId);
//            String leadToDoReponseType = toUpdateLead.targetList.Lead_Subtype_CBS__c;
//            String responseLevel1 = toUpdateLead.responseLevel1;
//            String responseLevel2 = toUpdateLead.responseLevel2;
//            toUpdateLead.isRequiredMemo = isResponseLevel2RequireMemo(leadToDoReponseType,responseLevel1,responseLevel2);
//        }
//        private Boolean isResponseLevel2RequireMemo(String leadToDoReponseType,String responseLevel1Answer,String responseLevel2Answer){
//            Boolean isRequire = false;
//            List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(leadToDoReponseType);
//            if(leadToDoResponses!= null && !leadToDoResponses.isEmpty()){
//                for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                    Boolean isLevel1Match = responseLevel1Answer.equalsIgnoreCase(leadToDoResponse.Response_Level_1__c);
//                    Boolean isLevel2Match = responseLevel2Answer.equalsIgnoreCase(leadToDoResponse.Response_Level_2__c);
//                    if(isLevel1Match && isLevel2Match){
//                        isRequire = leadToDoResponse.Required_Memo__c;
//                    }
//                }
//            }
//            return isRequire;
//        }
//        private List<SelectOption> getResponseLevel2ByTargetListLeadANDResponseLevel1(String targetListCampaignSubtype,String responseLevel1){
//            List<String> responseLevel2s;
//            Set<String> responseLevel2Set = new Set<String>();
//            List<Lead_To_Do_Response__c> leadToDoResponses = this.leadName_LeadToDoResponsesMap.get(targetListCampaignSubtype)!=null?this.leadName_LeadToDoResponsesMap.get(targetListCampaignSubtype):new List<Lead_To_Do_Response__c>();
//            Boolean isTargetListCampaignNameFound = !leadToDoResponses.isEmpty();
//            if(isTargetListCampaignNameFound){
//                for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                    String leadToDoResponseResponseLevel1 = leadToDoResponse.Response_Level_1__c;
//                    Boolean isRelatedResponseLevel1 = leadToDoResponseResponseLevel1.equalsIgnoreCase(responseLevel1);
//                    String leadToDoResponseResponseLevel2 = leadToDoResponse.Response_Level_2__c;
//                    Boolean isResponseLevel2NotNull = leadToDoResponseResponseLevel2 != null;
//                    if(isRelatedResponseLevel1 && isResponseLevel2NotNull){
//                        responseLevel2Set.add(leadToDoResponseResponseLevel2);  
//                    }
//                }
//            }
//            responseLevel2s = new List<String>(responseLevel2Set);
//            responseLevel2s.sort();
//            List<SelectOption> responseLevel2SelectOptions = GlobalUtility.createSelectOptionsFromStrings(responseLevel2s);
//            return responseLevel2SelectOptions;
//        }

//        public PageReference addExistingContact(){
//            CBS_CallReportWrapper.ExistingContactWrapper existContact = new CBS_CallReportWrapper.ExistingContactWrapper(new Call_Report_Contact__c());
//            this.existingContacts.add(existContact);
//            return null;
//        }
//        public PageReference addNewContact(){
//            CBS_CallReportWrapper.NewContactWrapper newContact = new CBS_CallReportWrapper.NewContactWrapper(new Contact(
//                                                                    Contact_Position__c = GlobalConstants.DEFAULT_CBS_NEW_CONTACT_CONTACTPOSITION
//                                                                    ));
//            this.newContacts.add(newContact);
//            return null;
//        }
//        public PageReference deleteThisNewContact(){
//            Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('rowToRemoveIndex'));
//            this.newContacts.remove(indexVal);   
//            return null;
//        }
//        public PageReference deleteThisExistingContact(){
//            Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('rowToRemoveIndex')); 
//            this.existingContacts.remove(indexVal);  
//            return null;
//        }


//        public PageReference newOpportunityPlanning(){
    
//            this.hasErrorMessage = false;
//            if(!isPassvalidateProduct()){
//                this.hasErrorMessage = true;
//            }
//            if(!this.hasErrorMessage){
//                createOppPlanningProduct();
//                this.callReportProductModal.resetModal();
//            }
//            return null;
//        }
//        public void createOppPlanningProduct(){
    
//            for(String productGroup : callReportProductModal.productWrapperMapByProductGroup.keySet()){

//                List<CBS_CallReportWrapper.ProductWrapper> productWrapperList = callReportProductModal.productWrapperMapByProductGroup.get(productGroup);
//                for(CBS_CallReportWrapper.ProductWrapper eachProductWrapper :productWrapperList){
//                    if(eachProductWrapper.isSelected){

//                        Opportunity_Planning__c oppPlanning = new Opportunity_Planning__c(CIS_ID__c = this.accountForLookup.id);
//                        if(eachProductWrapper.productType == GlobalConstants.NONE){
//                            oppPlanning.Product_Type__c = null; 
//                        }else{
//                            oppPlanning.Product_Type__c = eachProductWrapper.productType;     
//                        }

                        
//                        if(eachProductWrapper.interest){   
//                            oppPlanning.Status__c =  GlobalConstants.OPP_PLAN_EXPLORE;
//                        }else{
//                            oppPlanning.Status__c = GlobalConstants.OPP_PLAN_NOT_INTEREST;
//                        }

//                        oppPlanning.New_Limit__c = toDecimal(eachProductWrapper.newLimit);
//                        oppPlanning.Volume_Outstanding__c = toDecimal(eachProductWrapper.outstanding);
//                        oppPlanning.Front_End_Fee__c = toDecimal(eachProductWrapper.frontEndFee);
//                        oppPlanning.Fee__c = toDecimal(eachProductWrapper.fee);

//                        Product_List_Master__c eachProductConfig = this.callReportProductModal.cbsProductConfigMapByName.get(eachProductWrapper.productCode);
     
//                        List<Opportunity_Planning_Line_Item__c> oppPlanningLineItemList = new List<Opportunity_Planning_Line_Item__c>();
//                        oppPlanningLineItemList.add(new Opportunity_Planning_Line_Item__c(Product_Name__c = eachProductWrapper.name,Call_Report_Product_List_Master__r =eachProductConfig,Call_Report_Product_List_Master__c=eachProductConfig.id));
                        
//                        CBS_OpportunityPlanningWrapper oppPlanningWrapper = new CBS_OpportunityPlanningWrapper(oppPlanning,oppPlanningLineItemList);
//                        oppPlanningWrapper.oppPlaningTypeSetNotAllowEditAmount = this.oppPlaningTypeSetNotAllowEditAmount;
//                        oppPlanningWrapper.allowGrouping = this.oppPlanningCSMapByOppPlanType.containsKey(oppPlanning.Product_Type__c) ? this.oppPlanningCSMapByOppPlanType.get(oppPlanning.Product_Type__c).Allow_Grouping__c : false;
//                        oppPlanningWrapper.allowAddToExistingOpportunity = oppPlanningWrapper.allowGrouping;
//                        this.oppPlanningMapByproductGroup.get(productGroup).add(oppPlanningWrapper);
         
               
//                    }
//                }
//            }
//        }

//        public Boolean isPassvalidateProduct(){
//            Boolean isPass = true;
//            for(String productGroup : callReportProductModal.productWrapperMapByProductGroup.keySet()){
//                callReportProductModal.productWrapperCollapseMapByProductGroup.put(productGroup,true);
//                List<CBS_CallReportWrapper.ProductWrapper> productWrapperList = callReportProductModal.productWrapperMapByProductGroup.get(productGroup);
//                for(CBS_CallReportWrapper.ProductWrapper eachProductWrapper :productWrapperList){
//                    if(eachProductWrapper.isSelected){
//                        callReportProductModal.productWrapperCollapseMapByProductGroup.put(productGroup,false);
//                        if(callReportProductModal.cbsProductConfigMapByName.containsKey(eachProductWrapper.productCode)){
//                            Product_List_Master__c eachProductConfig = callReportProductModal.cbsProductConfigMapByName.get(eachProductWrapper.productCode);
                            
//                            if(eachProductWrapper.interest && eachProductWrapper.productType.equalsIgnoreCase(GlobalConstants.NONE)){
//                                eachProductWrapper.errMsg_productType = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                                isPass = false;
//                            }else{
//                                eachProductWrapper.errMsg_productType = null;
//                            }

//                            if(eachProductWrapper.interest && !this.oppPlaningTypeSetNotAllowEditAmount.contains(eachProductWrapper.productType)){
//                                if(eachProductConfig.Is_Required_New_Limit__c && String.isBlank(eachProductWrapper.newLimit)){
//                                    eachProductWrapper.errMsg_NewLimit = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                                    isPass = false;
//                                }else if(!String.isBlank(eachProductWrapper.newLimit) && eachProductConfig.Is_not_Allow_0_New_Limit__c && !(toDecimal(eachProductWrapper.newLimit) > 0) ){
//                                    eachProductWrapper.errMsg_NewLimit = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                                    isPass = false;
//                                }else{
//                                    eachProductWrapper.errMsg_NewLimit = null;
//                                }

//                                if(eachProductConfig.Is_Required_Volume_Outstanding__c && String.isBlank(eachProductWrapper.outstanding)){
//                                    eachProductWrapper.errMsg_Outstanding = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                                    isPass = false;
//                                }else if(!String.isBlank(eachProductWrapper.outstanding) && eachProductConfig.Is_not_Allow_0_Volume_Outstanding__c && !(toDecimal(eachProductWrapper.outstanding) > 0)){
//                                    eachProductWrapper.errMsg_Outstanding = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                                    isPass = false;
//                                }else{
//                                    eachProductWrapper.errMsg_Outstanding = null;
//                                }

//                                if(eachProductConfig.Is_Required_Front_End_Fee__c && String.isBlank(eachProductWrapper.frontEndFee)){
//                                    eachProductWrapper.errMsg_FrontEndFee = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                                    isPass = false;
//                                }else if(!String.isBlank(eachProductWrapper.frontEndFee) && eachProductConfig.Is_not_Allow_0_Front_End_Fee__c && !(toDecimal(eachProductWrapper.frontEndFee) > 0)){
//                                    eachProductWrapper.errMsg_FrontEndFee = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                                    isPass = false;
//                                }else{
//                                    eachProductWrapper.errMsg_FrontEndFee = null;
//                                }

//                                if(eachProductConfig.Is_Required_Fee__c && String.isBlank(eachProductWrapper.fee)){
//                                    eachProductWrapper.errMsg_Fee = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                                    isPass = false;
//                                }else if(!String.isBlank(eachProductWrapper.fee) && eachProductConfig.Is_not_Allow_0_Fee__c && !(toDecimal(eachProductWrapper.fee) > 0)){
//                                    eachProductWrapper.errMsg_Fee = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                                    isPass = false;
//                                }else{
//                                    eachProductWrapper.errMsg_Fee = null;
//                                }
//                            }else{
//                                eachProductWrapper.errMsg_NewLimit = null;
//                                eachProductWrapper.errMsg_Outstanding  = null;
//                                eachProductWrapper.errMsg_FrontEndFee = null;
//                                eachProductWrapper.errMsg_Fee = null;
//                            }
//                        }
//                    }else{
//                        eachProductWrapper.errMsg_productType = null;
//                        eachProductWrapper.errMsg_NewLimit = null;
//                        eachProductWrapper.errMsg_Outstanding  = null;
//                        eachProductWrapper.errMsg_FrontEndFee = null;
//                        eachProductWrapper.errMsg_Fee = null;
//                    }

//                }
//            }
//            return isPass;
//        }

//        public void editOpportunityPlanning(){
//            this.editGroupName = apexpages.currentpage().getparameters().get('groupName');
//            this.editGroupIndex = Integer.valueOf(apexpages.currentpage().getparameters().get('indexInGroup'));
//            CBS_OpportunityPlanningWrapper toEditOpportunityPlanning = this.oppPlanningMapByproductGroup.get(editGroupName).get(editGroupIndex);
//            toEditOpportunityPlanning.setStateBeforeEdit();
//            this.editProductCode =  toEditOpportunityPlanning.oppPlanningLineItems.get(0).Call_Report_Product_List_Master__r.Name;

//        }
//        public void saveEditOpportunityPlanning(){
//            this.hasErrorMessage = false;
//            if(!isPassValidateEditOppPlanning()){
//                this.hasErrorMessage = true;
//            }
//        }

//        public void cancelEditOpportunityPlanning(){
//            this.oppPlanningMapByproductGroup.get(editGroupName).get(editGroupIndex).reSetState();
//        }

//        public Boolean isPassValidateEditOppPlanning(){
//            CBS_OpportunityPlanningWrapper editOpportunityPlanning = this.oppPlanningMapByproductGroup.get(this.editGroupName).get(this.editGroupIndex);
//            Product_List_Master__c eachProductConfig = callReportProductModal.cbsProductConfigMapByName.get(this.editProductCode);
//            Boolean isPass = true;

//            if(eachProductConfig.Is_Required_New_Limit__c && String.isBlank(String.valueOf(editOpportunityPlanning.opportunityPlanning.New_Limit__c))){
//                editOpportunityPlanning.errMsg_NewLimit = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                isPass = false;
//            }else if(eachProductConfig.Is_not_Allow_0_New_Limit__c && !((editOpportunityPlanning.opportunityPlanning.New_Limit__c) > 0) ){
//                editOpportunityPlanning.errMsg_NewLimit = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                isPass = false;
//            }else{
//                editOpportunityPlanning.errMsg_NewLimit = null;
//            }

//            if(eachProductConfig.Is_Required_Volume_Outstanding__c && String.isBlank(String.valueOf(editOpportunityPlanning.opportunityPlanning.Volume_Outstanding__c))){
//                editOpportunityPlanning.errMsg_Outstanding = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                isPass = false;
//            }else if(eachProductConfig.Is_not_Allow_0_Volume_Outstanding__c && !((editOpportunityPlanning.opportunityPlanning.Volume_Outstanding__c) > 0)){
//                editOpportunityPlanning.errMsg_Outstanding = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                isPass = false;
//            }else{
//                editOpportunityPlanning.errMsg_Outstanding = null;
//            }

//            if(eachProductConfig.Is_Required_Front_End_Fee__c && String.isBlank(String.valueOf(editOpportunityPlanning.opportunityPlanning.Front_End_Fee__c))){
//                editOpportunityPlanning.errMsg_FrontEndFee = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                isPass = false;
//            }else if(eachProductConfig.Is_not_Allow_0_Front_End_Fee__c && !((editOpportunityPlanning.opportunityPlanning.Front_End_Fee__c) > 0)){
//                editOpportunityPlanning.errMsg_FrontEndFee = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                isPass = false;
//            }else{
//                editOpportunityPlanning.errMsg_FrontEndFee = null;
//            }

//            if(eachProductConfig.Is_Required_Fee__c && String.isBlank(String.valueOf(editOpportunityPlanning.opportunityPlanning.Fee__c))){
//                editOpportunityPlanning.errMsg_Fee = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
//                isPass = false;
//            }else if(eachProductConfig.Is_not_Allow_0_Fee__c && !((editOpportunityPlanning.opportunityPlanning.Fee__c) > 0)){
//                editOpportunityPlanning.errMsg_Fee = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
//                isPass = false;
//            }else{
//                editOpportunityPlanning.errMsg_Fee = null;
//            }
//            return isPass;
//        }

//        public PageReference groupOpportunityPlanning(){
//            List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperToGroup = new List<CBS_OpportunityPlanningWrapper>(); 
//            for(String productGroup : oppPlanningMapByproductGroup.keySet()){
//                List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = oppPlanningMapByproductGroup.get(productGroup);
//                for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
//                    if(eachOppPlanningWrapper.isChecked && !eachOppPlanningWrapper.isGrouped){
//                        eachOppPlanningWrapper.addToExistingOpportunity = null;
//                        oppPlanningWrapperToGroup.add(eachOppPlanningWrapper);
//                    }
//                }
//            }

//            if(!oppPlanningWrapperToGroup.isEmpty()){
//                GroupOpportunityPlanningWrapper groupOppplanningWrapper = new GroupOpportunityPlanningWrapper(oppPlanningWrapperToGroup);
//                this.groupOppPlanningList.add(groupOppplanningWrapper);
//            }
//            return null;
//        }

//        public void unGroupOpportunityPlanning(){
//            if(this.groupOppPlanningIndex != null){
//                Integer index = this.groupOppPlanningIndex;
//                this.groupOppPlanningList.get(index).unGroupedFromCBSCallReport();
//                this.groupOppPlanningList.remove(index);
//            }
            
//        }

//        public void calculateShouldRenderOppPlanningGroupMapByProductGroupName(){
//            this.shouldRenderOppPlanningGroupMapByProductGroupName = new Map<String,Boolean>();
//            Set<String> productActiveGroupSet = new Set<String>(this.callReportProductModal.productActiveGroupList);
//            for(String productGroupName : this.oppPlanningMapByproductGroup.keySet()){
//                 if(productActiveGroupSet.contains(productGroupName) ){
//                    shouldRenderOppPlanningGroupMapByProductGroupName.put(productGroupName,true);
//                }else{
//                    if(this.oppPlanningMapByproductGroup.containsKey(productGroupName) && !this.oppPlanningMapByproductGroup.get(productGroupName).isEmpty()){
//                        shouldRenderOppPlanningGroupMapByProductGroupName.put(productGroupName,true);
//                    }else{
//                        shouldRenderOppPlanningGroupMapByProductGroupName.put(productGroupName,false);
//                    }
//                }
//            }
//        }

//        public Boolean validateProspectStatusBeforeSave(){
//            Boolean isAllvalid = true;
//            String errMessage;
//            if(!this.oppPlanningMapByproductGroup.isEmpty()){
//                for(List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList : oppPlanningMapByproductGroup.values()){
//                    for(CBS_OpportunityPlanningWrapper eachOppplanningWrapper : oppPlanningWrapperList){
//                        if(this.account.RecordType.Name == GlobalConstants.ORGANIZATION_PROSPECT && eachOppplanningWrapper.opportunityPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE){
//                            if(this.account.Encrypt_Identification_No__c == null || this.account.Birthdate_Registration_Date__c == null ){
//                                isAllvalid = false;
//                                errMessage = label.CBSCallReport_Cannot_create_opportunity_for_prospect;
//                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                                break;
//                            }
//                        }
//                    }
//                }
//            }

//            return isAllvalid;
//        }

//        public Decimal toDecimal(Object str){
//            String value = String.valueOf(str);
//            Decimal result;
//            if(String.isBlank(value)){
//                result = null;
//            }else{
//                value = value.replace(',', '');
//                result = GlobalUtility.toDecimal(value);
//            }
//            return result;
//        }
//        private Boolean upsertCallReport(){
//            this.toUpsertCallReport = this.myCallReport.callReport;
//            Id toUpsertCallReportRecordTypeId = toUpsertCallReport.RecordTypeId;
//            RecordType toUpsertCallReportRecordType = CBS_CallPlanCallReport_Service.getRecordTypeById(toUpsertCallReportRecordTypeId);
//            String toUpsertCallReportRecordTypeDevName = toUpsertCallReportRecordType.DeveloperName;
//            Boolean isCallReportRecordType = toUpsertCallReportRecordTypeDevName.equalsIgnoreCase(GlobalConstants.CBS_CALL_REPORT_DEVNAME);
//            Boolean isCallReportNoPlanRecordType = toUpsertCallReportRecordTypeDevName.equalsIgnoreCase(GlobalConstants.CBS_CALL_REPORT_NO_PLAN_DEVNAME);
//            Boolean isClosedContactedCallReportNoPlanRecordType = toUpsertCallReportRecordTypeDevName.equalsIgnoreCase(GlobalConstants.CBS_CONTACTED_CALLREPORT_NO_P_E_DEVNAME);
//            if(isCallReportRecordType){
//                toUpsertCallReport.RecordTypeId = this.callReportRecordTypesMap.get(GlobalConstants.CBS_CONTACTED_CALLREPORT_E_LEAD_DEVNAME).Id;
//            }else if(isCallReportNoPlanRecordType){
//                toUpsertCallReport.RecordTypeId = this.callReportRecordTypesMap.get(GlobalConstants.CBS_CONTACTED_CALLREPORT_NO_P_E_DEVNAME).Id;
//                toUpsertCallReport.CIS_ID__c = this.myCallReportAccountId;
//            }else if(isClosedContactedCallReportNoPlanRecordType){
//                toUpsertCallReport.CIS_ID__c = this.myCallReportAccountId;
//            }

//            for(List<CBS_OpportunityPlanningWrapper> oppPlanningList : this.oppPlanningMapByproductGroup.values()){
//                for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningList){
//                    if(String.isBlank(eachOppPlanningWrapper.opportunityPlanning.id) && eachOppPlanningWrapper.oppPlanningLineItems.get(0).Call_Report_Product_List_Master__r.Call_Report_Field_API_Name__c != null){
//                        String callReportAPIName = eachOppPlanningWrapper.oppPlanningLineItems.get(0).Call_Report_Product_List_Master__r.Call_Report_Field_API_Name__c;
//                        this.toUpsertCallReport.put(callReportAPIName,true);
//                    }
//                }
       
//            }

//            GlobalUtility.databaseSaveResults upsertCallReportResult = CBS_CallPlanCallReport_Service.insertNewCallReportOrUpdateCallPlanToCallReport(toUpsertCallReport);
//            upsertCallReportResult.print();
//            if(upsertCallReportResult.isAllSuccess()){
//                this.myCallReportId = upsertCallReportResult.databaseSaveResultList[0].getObjectId();
//            }else{
//    //Fix INC000000618309
//                String errorMsg = upsertCallReportResult.databaseSaveResultList[0].errorMessage;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
//            }
//            return upsertCallReportResult.isAllSuccess();
//        }
//        private void updateTargetList(){
//            List<Target_List__c>toUpdateTargetLists = new List<Target_List__c>();
//            for(CBS_CallReportWrapper.LeadWrapper lead:this.leads){
//                Target_List__c targetList = new Target_List__c(Id=lead.targetList.Id);
//                targetList.Response_Level_1__c = (String.isBlank(lead.responseLevel1) || (lead.responseLevel1).equals(GlobalConstants.NONE))?'':lead.responseLevel1;
//                targetList.Response_Level_2__c = (String.isBlank(lead.responseLevel2))?'':lead.responseLevel2;
//                targetList.Memo__c = (String.isBlank(lead.targetList.Memo__c))?'':lead.targetList.Memo__c;
//                if((lead.targetList.Lead_Type__c).equals(GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER)){
//                    targetList.IsRespLeadToDo__c = true;
//                }
//                if(lead.isRequiredLevel2 == false){
//                    lead.responseLevel2 = '';
//                    targetList.Response_Level_2__c = '';
//                }
//                if(lead.isRequiredMemo == false){
//                    targetList.Memo__c = '';
//                }
//                String newStatus;

//                if((lead.targetList.Lead_Type__c).equals(GlobalConstants.LEAD_FOR_FEEDBACK)){
//                    if(String.isBlank(lead.responseLevel1) || ( (lead.responseLevel1).equals(GlobalConstants.NONE) )){
//                        newStatus = GlobalConstants.STATUS_NEW;
//                    }else{
//                        newStatus = (!String.isBlank(lead.responseLevel2))?lead.responseLevel2:lead.responseLevel1;
//                    }
//                }else{
//                    if(String.isBlank(lead.responseLevel1)){
//                        newStatus = GlobalConstants.NONE;
//                    }else{
//                        newStatus = (!String.isBlank(lead.responseLevel2))?lead.responseLevel2:lead.responseLevel1;
//                    }
//                }
//                if(newStatus.equals(GlobalConstants.NONE)){
//                    newStatus = GlobalConstants.CONTACTED;
//                }
                
//                String oldStatus = lead.targetList.Status__c;
//                if(TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_CALL_PLAN_CALL_REPORT,newStatus,oldStatus)){
                    
//                    targetList.Status__c = newStatus;
//                }else{
//                    targetList.Status__c = oldStatus;
//                }
//                if(targetList.Lead_Campaign__r.Status == GlobalConstants.EXPIRED){
//                    targetList.Status__c = oldStatus;
//                }
//                toUpdateTargetLists.add(targetList);
//            } 
//            GlobalUtility.databaseSaveResults updateTargetListResult = CBS_CallPlanCallReport_Service.updateTargetList(toUpdateTargetLists);
//            updateTargetListResult.print();
//            List<Call_Report_Lead__c> queryCallReportLeads = CBS_CallPlanCallReport_Service.getCallReportLeads(this.myCallReportId);
//            Map<String,Target_List__c> targetListMap = new Map<String,Target_List__c>();
//            for(Target_List__c targetList:toUpdateTargetLists){
//                targetListMap.put(targetList.Id,targetList);
//            }
//            List<Call_Report_Lead__c> toUpdateCallReportLeads = new List<Call_Report_Lead__c>();
//            for(Call_Report_Lead__c callReportLead:queryCallReportLeads){
//                Call_Report_Lead__c toUpdateCallReportLead = new Call_Report_Lead__c(Id=callReportLead.Id);
//                Target_List__c targetList = targetListMap.get(callReportLead.Target_List__c);
//                if(targetList != null){
//                    toUpdateCallReportLead.Memo__c = targetList.Memo__c;
//                }
//                toUpdateCallReportLeads.add(toUpdateCallReportLead);
//            }
//            GlobalUtility.databaseSaveResults updateCallReportLeadsResult = CBS_CallPlanCallReport_Service.updateCalLreportLead(toUpdateCallReportLeads);
//            updateCallReportLeadsResult.print();
//        }
//        private void insertNewContactsThenInsertCallReportContactsForAllContacts(){
//            List<Contact> newContactsToInsert = new List<Contact>();
//            for(CBS_CallReportWrapper.NewContactWrapper newContact:this.newContacts){
//                Contact newContactToInsert = newContact.contact;
//                newContactToInsert.AccountId = this.myCallReportAccountId;
//                newContactToInsert.lastName = newContact.lastName;
//                newContactsToInsert.add(newContactToInsert);
//            }
//            GlobalUtility.databaseSaveResults insertNewContactsResult = CBS_CallPlanCallReport_Service.insertNewContacts(newContactsToInsert);
//            insertNewContactsResult.print();
//            List<Id>newContactIdsToInsertCallReportContacts = insertNewContactsResult.getAllSuccessId();
//            Set<Id> contactIdsToInsertCallReportContacts = new Set<Id>();
//            for(CBS_CallReportWrapper.ExistingContactWrapper existContact : this.existingContacts){
//                Id existingContactId = existContact.existingContact.Contact_Name__c;
//                contactIdsToInsertCallReportContacts.add(existingContactId);
//            }
//            for(Id newContactId : newContactIdsToInsertCallReportContacts){
//                contactIdsToInsertCallReportContacts.add(newContactId);
//            }
//            Map<Id,Contact> savedContactsMap = CBS_CallPlanCallReport_Service.getSavedContactMap(contactIdsToInsertCallReportContacts);
//            List<Call_Report_Contact__c> callReportContacts = new List<Call_Report_Contact__c>();
//            for(String contactId:contactIdsToInsertCallReportContacts){
//                if(!String.isBlank(contactId)){
//                    Call_Report_Contact__c callReportContact = new Call_Report_Contact__c();
//                    callReportContact.Contact_Name__c = contactId;
//                    callReportContact.Call_Plan_Call_Report__c = this.myCallReportId;
//                    callReportContact.Phone_Number_Text__c = savedContactsMap.get(contactId).Phone_Number__c;
//                    callReportContact.Business_Email_Text__c = savedContactsMap.get(contactId).Business_Email__c;
//                    callReportContacts.add(callReportContact);
//                }           
//            }
//            GlobalUtility.databaseSaveResults insertCallReportContactsResult = CBS_CallPlanCallReport_Service.insertCallReportContacts(callReportContacts);
//            insertCallReportContactsResult.print();
//        }
//        private void insertOpportunityProduct(){
//            Account targetAccount = beforeSaveAccount;
//            if(targetAccount == null) {
//                targetAccount = Account_Service.getAccountByID(this.myCallReportAccountId)[0];
//            }
//            Call_Report__c targetCallReport = new Call_Report__c(Id = this.myCallReportId);

//            List<CBS_OpportunityPlanningWrapper> allOppPlanningWrapperList = new List<CBS_OpportunityPlanningWrapper>();
//            for(List<CBS_OpportunityPlanningWrapper> opportunityList : this.oppPlanningMapByproductGroup.values()){
//                for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : opportunityList){
//                    if(eachOppPlanningWrapper.opportunityPlanning.Original_Call_Report__c == null){
//                        eachOppPlanningWrapper.opportunityPlanning.Original_Call_Report__c = this.myCallReportId;
//                    }
//                    if(eachOppPlanningWrapper.opportunityPlanning.Status__c != eachOppPlanningWrapper.oldStatus || eachOppPlanningWrapper.opportunityPlanning.Id == null){
//                        eachOppPlanningWrapper.opportunityPlanning.Call_Report_CBS__c = this.myCallReportId;
//                    }
//                    if(String.valueOf(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c) == ''){
//                        eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c = null;
//                    }
//                    eachOppPlanningWrapper.opportunityPlanning.Product_List_CBS__c = eachOppPlanningWrapper.oppPlanningLineItems[0].Product_Name__c;
//                }
//                allOppPlanningWrapperList.addAll(opportunityList);
//            }
//            Set<Id> allOpplanningIds = OpportunityPlanning_Service.createOpportunityFromCallReport(targetAccount,targetCallReport,allOppPlanningWrapperList,this.groupOppPlanningList);
//            for(Id oppPlanningId:allOpplanningIds){
//                this.savedOpptyIds.add(String.valueOf(oppPlanningId));
//            }
//        }
//        private Boolean validateCallPlanBeforeSave(){
//            String errMessage;
//            Boolean isAllvalid = true;
//            Call_Report__c toValidateCallReport = this.myCallReport.callReport;
            
//            if(!String.isEmpty(this.myCallReportAccountId)){
//                Account checkOwnerAccount = beforeSaveAccount;
//                if(checkOwnerAccount == null) {
//                    checkOwnerAccount = Account_Service.getAccountByID(this.myCallReportAccountId)[0];    
//                }
//                String ownerAccountId = checkOwnerAccount.OwnerID;
//                String userId = UserInfo.getUserId();

//                if(!ownerAccountId.equals(userId)){
//                    errMessage = label.CBSCallReport_Require_Same_Owner;
//                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                    isAllvalid = false;
//                }
//            }

//            if(String.isBlank(this.myCallReportAccountId)){
//                errMessage = label.CBSCallReport_Require_CIS_ID;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }
//            if(String.isBlank(toValidateCallReport.Visit_Objective_CBS__c)){
//                errMessage = label.CBSCallReport_Require_Actual_Visit_Objective;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }

//            if(toValidateCallReport.Actual_Visit_Date__c == null){
//                errMessage = label.CBSCallReport_Require_Actual_Visit_Date;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }
//            if(toValidateCallReport.Contact_Channel__c.equals(GlobalConstants.NONE)){
//                errMessage = label.CBSCallReport_Require_Contact_Channel;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }
//            if(toValidateCallReport.Actual_Visit_Date__c > System.today()){
//                errMessage = label.CBSCallReport_Actual_Visit_Date_must_not_be_further_than_today;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }
//            if(toValidateCallReport.Next_Follow_up_Date_CBS__c < System.today()){
//                errMessage = label.CBSCallReport_Next_Follow_Up_Date_must_not_be_less_than_today;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                isAllvalid = false;
//            }
//            return isAllvalid;
//        }
//        private Boolean validateOpportunityPlanningBeforeSave(){
//            Boolean isAllvalid = true;
//            for(String productGroup : oppPlanningMapByproductGroup.keySet()){
//                List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = oppPlanningMapByproductGroup.get(productGroup);
//                for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
//                    if(eachOppPlanningWrapper.isChecked){
//                        String errMessage = Label.Opp_Plan_Not_Grouped_Warning_Message;
//                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errMessage));
//                        isAllvalid = false;
//                        break;
//                    }
//                }
//            }
//            return isAllvalid;
//        }

//        private Boolean validateContactBeforeSave(){
//            String errMessage;
//            Boolean isAllvalid;
//            Boolean isMissingSomeNewContactField = false;
//            Boolean isAllNewContactBlank = true;
//            Boolean isPhoneFormat = true;
//            Boolean isEmailFormat = true;
//            Boolean isExtFormat = true;
//            Boolean isNotPhoneFormat = false;
//            Boolean isNotEmailFormat = false;
//            Boolean isNotExtFormat = false;
//            Boolean isMissingContactPostionExt = false;
//            Contact newContact;
//            String newContactLastName;
//            Boolean isFirstNameBlank;
//            Boolean isLastNameBlank;
//            Boolean isPhoneNumberBlank;
//            Boolean isContactPositionBlank;
//            Boolean isContactPostionOtherIsPickedAndContactPositionExtIsNotBlank;
//            Boolean isRepresentativeTypeBlank;
//            Boolean isExtBlank;
//            Boolean isEmailBlank;
//            Boolean isContactPostionOtherIsPicked;

//            List<CBS_CallReportWrapper.NewContactWrapper> toValidateNewContacts = this.newContacts;
//            if(!toValidateNewContacts.isEmpty()){
//                for(CBS_CallReportWrapper.NewContactWrapper toValidateNewContact:toValidateNewContacts){

//                    newContact = toValidateNewContact.contact;
//                    newContactLastName = toValidateNewContact.lastName;
//                    isFirstNameBlank = String.isBlank(newContact.FirstName);
//                    isLastNameBlank = String.isBlank(newContactLastName);
//                    isPhoneNumberBlank = String.isBlank(newContact.Phone_Number__c);
//                    isContactPositionBlank = !(String.isBlank(newContact.Contact_Position__c))&&(newContact.Contact_Position__c != GlobalConstants.DEFAULT_CBS_CONTACT_CONTACTPOSITION_OTHER);
//                    isContactPostionOtherIsPickedAndContactPositionExtIsNotBlank = (newContact.Contact_Position__c == GlobalConstants.DEFAULT_CBS_CONTACT_CONTACTPOSITION_OTHER) && !(String.isBlank(newContact.Title));
//                    isRepresentativeTypeBlank = String.isBlank(newContact.Contact_Representative_Type__c);
//                    isExtBlank = String.isBlank(newContact.Ext_CBS__c);
//                    isEmailBlank = String.isBlank(newContact.Business_Email__c);
//                    isContactPostionOtherIsPicked = newContact.Contact_Position__c == GlobalConstants.DEFAULT_CBS_CONTACT_CONTACTPOSITION_OTHER;

//                    if(!isFirstNameBlank && 
//                        !isLastNameBlank && 
//                        !isPhoneNumberBlank 
//                        ){
//                            if(!isPhoneNumberBlank){
//                                isPhoneFormat = GlobalUtility.isPhoneNumber(newContact.Phone_Number__c);
//                                if(!isPhoneFormat){
//                                    isNotPhoneFormat = true;
//                                }
//                            }
//                            if(!isEmailBlank){
//                                isEmailFormat = GlobalUtility.isEmailValid(newContact.Business_Email__c);
//                                if(!isEmailFormat){
//                                    isNotEmailFormat = true;
//                                }
//                            }
//                            if(!isEXTBlank){
//                                isExtFormat = GlobalUtility.isUnlimitedNumber(newContact.Ext_CBS__c);
//                                if(!isExtFormat){
//                                    isNotExtFormat = true;
//                                }
//                            }

//                            if(isContactPostionOtherIsPicked){
//                                if(String.isBlank(newContact.Title)){
//                                    isMissingContactPostionExt = true;
//                                }
//                            }

//                            isAllNewContactBlank = false;
//                            continue;
//                        }
//                    if(!isFirstNameBlank){
//                        if(isLastNameBlank || 
//                            isPhoneNumberBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(!isLastNameBlank){
//                        if(isFirstNameBlank || 
//                            isPhoneNumberBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(!isPhoneNumberBlank){
//                        if(isLastNameBlank || 
//                            isFirstNameBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(isContactPostionOtherIsPickedAndContactPositionExtIsNotBlank || isContactPositionBlank){
//                        if(isLastNameBlank || 
//                            isPhoneNumberBlank ||
//                            isFirstNameBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(!isRepresentativeTypeBlank){
//                        if(isLastNameBlank || 
//                            isPhoneNumberBlank ||
//                            isFirstNameBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(!isExtBlank){
//                        if(isLastNameBlank || 
//                            isPhoneNumberBlank ||
//                            isFirstNameBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
//                    if(!isEmailBlank){
//                        if(isLastNameBlank || 
//                            isPhoneNumberBlank ||
//                            isFirstNameBlank
//                            ){
//                            isMissingSomeNewContactField = true;
//                        }
//                    }
                            
//                }
//            }
//            Boolean isAllExistingContactsBlank = true;
//            List<CBS_CallReportWrapper.ExistingContactWrapper> toValidateExistingContacts = this.existingContacts;
//            if(!toValidateExistingContacts.isEmpty()){
//                for(CBS_CallReportWrapper.ExistingContactWrapper toValidateExistingContact:toValidateExistingContacts){
//                    Call_Report_Contact__c existingContact = toValidateExistingContact.existingContact;
//                    if(existingContact != null && !String.isBlank(existingContact.Contact_Name__c) ){
//                        isAllExistingContactsBlank = false;
//                        break;
//                    }
//                }
//            }
//            Boolean isContactsEmpty = isAllExistingContactsBlank && isAllNewContactBlank;
//            if(isContactsEmpty){
//                errMessage = label.CBSCallReport_Contact_person_must_be_specified;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            isAllvalid = !isContactsEmpty;
//            if(isMissingSomeNewContactField){
//                isAllvalid = false;
//                errMessage = label.CBSCallReport_Invalid_new_contact_information;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            if(isNotPhoneFormat){
//                isAllvalid = false;
//                errMessage = label.CBSCallReport_Invalid_Phone_Number_format;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            if(isNotEmailFormat){
//                isAllvalid = false;
//                errMessage = label.CBSCallReport_Invalid_email_format;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            if(isNotExtFormat){
//                isAllvalid = false;
//                errMessage = label.CBSCallReport_EXT_must_be_numeric;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            if(isMissingContactPostionExt){
//                isAllvalid = false;
//                errMessage = label.CBSCallReport_Contact_Position_in_Contact_Position;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//            }
//            return isAllvalid;
//        }
//        private Boolean validateTargetListBeforeSave(){
//            Boolean isValid = true;
//            String errorMsg;
//            Set<String> allRequiredProductNames = new Set<String>();
//            Set<String> campaignIds = new Set<String>();
//            String errMessage;
//            if(!this.leads.isEmpty() && this.leads!=null){
//                for(CBS_CallReportWrapper.LeadWrapper lead:this.leads){
//                    Target_List__c targetList = lead.targetList;
//                    String leadToDoReponseType = targetList.Lead_Campaign__r.Sub_Type_CBS__c;
//                    String responseLevel1Answer = lead.responseLevel1;
//                    String responseLevel2Answer = lead.responseLevel2;
//                    Boolean isAbleResponseLvl1 = lead.ableToAnswerLvl1;
//                    if(isRequiredProduct(leadToDoReponseType,responseLevel1Answer,responseLevel2Answer,isAbleResponseLvl1)){
//                        String campaignId = targetList.Lead_Campaign__c;
//                        campaignIds.add(campaignId);
//                    }
//                    if(lead.isRequiredMemo){
//                        Boolean isTargetListMemoBlank = String.isBlank(lead.targetList.Memo__c);
//                        if(isTargetListMemoBlank){
//                            isValid = false;
//                            errMessage = label.CBSCallReport_Lead_require_reason;
//                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMessage));
//                        }
//                    }
//                }   
//            }
//            if(!campaignIds.isEmpty()){
//                List<Campaign> campaigns = CBS_CallPlanCallReport_Service.getCampaigns(campaignIds);
//                for(Campaign camp:campaigns){
//                    if(!String.isBlank(camp.Product_List_CBS__c )){
//                        List<String> productsFromCampaign = CBS_Utility.disjoin(camp.Product_List_CBS__c,';');
//                        allRequiredProductNames.addAll(productsFromCampaign);   
//                    }
//                }
//            }else{
//                return isValid;
//            }
//            Set<String> allSelectedProductNames = new Set<String>();


//            if(!this.oppPlanningMapByproductGroup.isEmpty()){
//                for(List<CBS_OpportunityPlanningWrapper> oppPlaningWrapperList : this.oppPlanningMapByproductGroup.values()){
//                    for(CBS_OpportunityPlanningWrapper eachOppplanningWrapper : oppPlaningWrapperList){
//                        for(Opportunity_Planning_Line_Item__c oppPlanLineItem : eachOppplanningWrapper.oppPlanningLineItems){
//                            allSelectedProductNames.add(oppPlanLineItem.Product_Name__c);
//                        }
//                    }
//                }
//            }

//            Boolean someSelectProductNamesIsInRequireProductNames = false;
//            for(String selectedProductName:allSelectedProductNames){
//                if(allRequiredProductNames.contains(selectedProductName)){
//                    someSelectProductNamesIsInRequireProductNames = true;
//                    break;
//                }
//            }
            
//            Boolean isAllRequiredProductNamesEmpty = allRequiredProductNames.isEmpty();
//            if(!isAllRequiredProductNamesEmpty && !someSelectProductNamesIsInRequireProductNames){
//                errorMsg = label.CBSCallReport_Lead_not_match_opportunity_plan;
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMsg));
//                isValid = false;
//            }
//            return isValid;
//        }
        
//        private Boolean isRequiredProduct(String leadToDoReponseType,String responseLevel1Answer,String responseLevel2Answer, Boolean isAbleResponseLvl1){
//            if(!isAbleResponseLvl1){
//                return false;
//            }
//            Boolean isRequire = false;
//            if(String.isBlank(leadToDoReponseType)) return isRequire;
//            if(String.isBlank(responseLevel1Answer)) return isRequire;
//            if(responseLevel1Answer.equalsIgnoreCase(GlobalConstants.NONE)){
//                isRequire = false;
//            }else{
//                List<Lead_To_Do_Response__c> leadToDoResponses = leadName_LeadToDoResponsesMap.get(leadToDoReponseType);
//                if(leadToDoResponses!= null && !leadToDoResponses.isEmpty()){
//                    for(Lead_To_Do_Response__c leadToDoResponse:leadToDoResponses){
//                        Boolean isLevel1Match = responseLevel1Answer.equalsIgnoreCase(leadToDoResponse.Response_Level_1__c);
//                        Boolean isLevel2Match = !String.isBlank(responseLevel2Answer) && responseLevel2Answer.equalsIgnoreCase(leadToDoResponse.Response_Level_2__c);
//                        Boolean isRequiredLevel2 = leadToDoResponse.Required_Level_2__c;
//                        if(!isRequiredLevel2 && isLevel1Match){
//                            isRequire = leadToDoResponse.Required_Product_c__c;
//                            break;
//                        }else if(isRequiredLevel2 && isLevel1Match && isLevel2Match){
//                            isRequire = leadToDoResponse.Required_Product_c__c;
//                            break;
//                        }
//                    }
//                }
//            }
//            return isRequire;
//        }


//        public PageReference saveAll(){

//            String productService = this.myCallReport.callReport.Product_Service__c;
//            beforeSaveAccount = Account_Service.getAccountByID(this.myCallReportAccountId)[0];
//            if(
//                validateOpportunityPlanningBeforeSave() &&
//                validateCallPlanBeforeSave() &&
//                validateContactBeforeSave() &&
//                validateTargetListBeforeSave() &&
//                validateProspectStatusBeforeSave()
//            ){
//                if(upsertCallReport()){
//                    updateTargetList();
//                    insertNewContactsThenInsertCallReportContactsForAllContacts();
//                    insertOpportunityProduct();
//                    // Add redirect CR024 Fraud
//                    String isCheckFraud = ApexPages.currentPage().getParameters().get('isCheckFraud');
                
//                    if((isCheckFraud != null && isCheckFraud == '0') || beforeSaveAccount.CIS__c == null) {
//                        this.callReportRedirectURL ='/' + this.myCallReportId;
//                    } else {
//                        String pageRefString = '/'+this.myCallReportId;
//                        pageRefString = EncodingUtil.urlEncode(pageRefString, 'UTF-8');
//                        this.callReportRedirectURL = '/apex/SME_FraudWarning_Page?existingId=' + this.myCallReportAccountId + '&redirectNewPage='+pageRefString;
//                    }
//                    this.callReportRedirectURL = JSON.serialize(this.callReportRedirectURL);
         
//                    this.savedOpptyIdsJSON = JSON.serialize(savedOpptyIds);
//                    this.savedCallReportId = JSON.serialize(this.myCallReportId);
//                }else{
//                    this.hasErrorMessage = true;
//                    String errorMsg =  label.CBSCallReport_Unable_create_call_report;
//                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
//                }
//            }else{
//                this.hasErrorMessage = true;
//            }
//            return null;
//        }
//        public void handleContactPostionChanged(){
//            Integer rowIndex = Integer.valueOf(apexpages.currentpage().getParameters().get('rowToCheckContactPositionIndex'));    
//            CBS_CallReportWrapper.NewContactWrapper changedNewContactWrapper = newContacts[rowIndex];
//            displayOtherContactPostionHandler(changedNewContactWrapper);
//        }
//        private void displayOtherContactPostionHandler(CBS_CallReportWrapper.NewContactWrapper newContactBefore){
//            String newContactBeforeContactPostion = newContactBefore.contact.Contact_Position__c;
//            Boolean isContactPositionBlank = String.isBlank(newContactBeforeContactPostion);
//            if(!isContactPositionBlank){
//                Boolean isContactPostionOther = newContactBeforeContactPostion.equalsIgnoreCase(GlobalConstants.DEFAULT_CBS_CONTACT_CONTACTPOSITION_OTHER);
//                newContactBefore.showOtherContactPosition = isContactPostionOther;
//                if(!isContactPostionOther){
//                    newContactBefore.contact.Title = '';
//                }
//            }else{
//                newContactBefore.showOtherContactPosition = false;
//            }
//            newContactBefore.contact.title = '';
//        }
//        private Boolean validateCIS(){
//            if(callReportForCISLookUpInputField.CIS_ID__c != null){
//                Id callReportAccountID = callReportForCISLookUpInputField.CIS_ID__c;
//                List<Account> validateAccounts = Account_Service.getAccountByID(callReportAccountID);
//                Boolean isValidateAcccounts = validateAccounts.isEmpty();
//                if(isValidateAcccounts){
//                    this.hasErrorMessage = true;
//                    return false;
//                }else{
//                    this.hasErrorMessage = false;
//                    return true;
//                }
//            }else{
//                return false;
//            }
//        }


///**
//helper
//**/  
//    public void setOppPlanType_AllowEditAmount_Grouping(){
//        Set<String> oppPlanTypeNotAllowEditAmountSet = new Set<String>();
//        Set<String> oppPlanTypeAllowGroupingSet = new Set<String>();
//        for(Opportunity_Planning_Type__c eachOppPlanCS : this.oppPlanningCSMapByOppPlanType.values()){
//            if(!eachOppPlanCS.Allow_Edit_Amount__c){
//                oppPlanTypeNotAllowEditAmountSet.add(eachOppPlanCS.Type__c);
//            }
//            if(eachOppPlanCS.Allow_Grouping__c){
//                oppPlanTypeAllowGroupingSet.add(eachOppPlanCS.Type__c);
//            }
//        }
//        this.oppPlaningTypeSetNotAllowEditAmount = oppPlanTypeNotAllowEditAmountSet;
//        this.oppPlaningTypeSetAllowGrouping = oppPlanTypeAllowGroupingSet;

//    }

//    public String getJsonOppPlanTypeNotAllowEditAmount(){
//        return JSON.serialize(this.oppPlaningTypeSetNotAllowEditAmount);
//    }

//    public String getJsonOppPlanTypeSetAllowGrouping(){
//        return JSON.serialize(this.oppPlaningTypeSetAllowGrouping);
//    }

}