/**
* @author komsan.wi@beryl8.com
* @07/07/2015 createddate
*/
public without sharing class CallReport_OverrideEdit_Controller {
    public Boolean isAlertSuccess {get; set;}
    public Boolean isRedirectToListView {get; set;}

    public CallReport_OverrideEdit_Controller(ApexPages.StandardController stdController) {
    }

    public CallReport_OverrideEdit_Controller() {
    }

    public PageReference redirectToNewPage() {
        CallPlanCallReportField__c callPlanCallReportField = CallPlanCallReportField__c.getOrgDefaults();

        PageReference pageRef = new PageReference('/'+callPlanCallReportField.CallReportObjectId__c+'/e?');
        pageRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        pageRef.getParameters().put('save_new_url', ApexPages.currentPage().getParameters().get('save_new_url'));
        pageRef.getParameters().put('scontrolCaching', ApexPages.currentPage().getParameters().get('scontrolCaching'));

        if(isCurrentUserCBS()){
            pageRef.getParameters().put('RecordType', callPlanCallReportField.CBSCallPlanRecordTypeId__c);
        }else{
            pageRef.getParameters().put('RecordType', callPlanCallReportField.NewCallPlanRecordTypeId__c);
        }
        pageRef.getParameters().put('nooverride', '1');

       pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference redirect(){
        String newidString = ApexPages.currentPage().getParameters().get('newid');
        String accountIdString = ApexPages.currentPage().getParameters().get('accountId');
        String primaryFlagString = ApexPages.currentPage().getParameters().get('primaryFlag');
        String primaryCallReportIdString = ApexPages.currentPage().getParameters().get('primaryCallReportId');
        String associatedIdString = ApexPages.currentPage().getParameters().get('associatedId');
        String shareWithStringBeforeUpdate = ApexPages.currentPage().getParameters().get('shareWith');
        String recordType = ApexPages.currentPage().getParameters().get('RecordType');
        PageReference pageRef;

        List<Call_Report__c> callReportObj = new List<Call_Report__c>();
        callReportObj = [SELECT Id,Offer_Interest__c,Expected_Credit_Amount__c,Primary_Call_Report__c,Status__c,Non_Credit__c FROM Call_Report__c WHERE Id = :newidString LIMIT 1];
        if(callReportObj!=null && callReportObj.size() > 0){
            if(primaryCallReportIdString != null && primaryCallReportIdString != '' && primaryFlagString != null && primaryFlagString == '0' && callReportObj.get(0).Primary_Call_Report__c != false){
                Call_Report__c updateCallReport = new Call_Report__c(Id=callReportObj.get(0).Id);
                updateCallReport.Primary_Call_Report__c = false;
                updateCallReport.Primary_Call_Plan_Call_Report__c = Id.valueOf(primaryCallReportIdString);
                update updateCallReport;
                if(associatedIdString != null && associatedIdString != ''){
                    Associated_Customer__c tempAssociated = new Associated_Customer__c(Id=Id.valueOf(associatedIdString));
                    tempAssociated.Secondary_Call_Plan_Call_Report__c = Id.valueOf(newidString);

                    update tempAssociated;
                }

            }
            List<Call_Report_Opportunity__c> currentOpportunity = new List<Call_Report_Opportunity__c>();
            currentOpportunity = [SELECT Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c =:newidString ORDER BY CreatedDate DESC LIMIT 1];

            id id1 = userinfo.getProfileId();
            String profileName = [SELECT Name FROM Profile WHERE Id = :id1][0].Name;
            Account accountInfo;
            if(accountIdString != '' && accountIdString != null){
                accountInfo = [SELECT Id,Share_With__c FROM Account WHERE Id = :accountIdString LIMIT 1];

            }
            

            if((GlobalConstants.PROFILE_AN_SET.contains(profileName) || profileName == 'AN-Sales Management') && (accountInfo != null) && (accountInfo.Share_With__c == null)){
                if(shareWithStringBeforeUpdate != 'null' && shareWithStringBeforeUpdate != null && shareWithStringBeforeUpdate != ''){
                    isAlertSuccess = true;
                    isRedirectToListView = true;
                    return null;
                }
            }
            //PCR061
            if(callReportObj.get(0).Status__c == GlobalConstants.CONTACTED && callReportObj.get(0).Non_Credit__c){
                pageRef = new PageReference('/apex/Noncredit_OverrideNew_Page?');
                pageRef.getParameters().put(Noncredit_OverrideNew_Controller.CALLREPORTID_PARAM, callReportObj.get(0).id);
                if(currentOpportunity!=null && currentOpportunity.size() > 0){
                    pageRef.getParameters().put(Noncredit_OverrideNew_Controller.OPPID_PARAM, currentOpportunity.get(0).Opportunity_Name__c);
                }
            }else if(currentOpportunity!=null && currentOpportunity.size() > 0){
                pageRef = new PageReference('/'+currentOpportunity.get(0).Opportunity_Name__c);
            }
            else if(primaryCallReportIdString!=null){
                pageRef = new PageReference('/'+primaryCallReportIdString);
            }
            else if(newidString!=null){
                pageRef = new PageReference('/'+newidString);
            }
        }else if(newidString!=null){
            pageRef = new PageReference('/'+newidString);
        }
        return pageRef;
    }
    public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Call_Report__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }

    private String getCurrentUserSegment(){
        String currentUserSegment = '';
        String currentUserId = UserInfo.getUserId();
        List<User> currentUsers = [SELECT Id,Segment__c FROM User WHERE Id =: currentUserId];
        boolean currentUsersIsNotEmpty = !currentUsers.isEmpty();
        if(currentUsersIsNotEmpty){
            User currentUser = currentUsers[0];
            currentUserSegment = (String.isNotBlank(currentUser.Segment__c))?currentUser.Segment__c:'';    
        }
        return currentUserSegment;
    }

    private boolean isCurrentUserCBS(){
        Set<String> cbsSegments = new Set<String>{'CB','MB'};
        String currentUserSegment = getCurrentUserSegment();
        return cbsSegments.contains(currentUserSegment);
    }
}