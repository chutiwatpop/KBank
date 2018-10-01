public with sharing class CBS_ViewIssueLog_Controller {
    private static final String LV3PREFIX = 'LV3PREFIX';

	public Issue_Log__c issueLog {get;set;}

    public CBS_ViewIssueLog_Controller(ApexPages.StandardController stdController) {
        this.issueLog = (Issue_Log__c)stdController.getRecord();
        this.issueLog = [SELECT Id, Subject__c, Name, Parent_Issue__c, IsParentIssue__c, Date_Time_Opened__c, Date_Time_Closed__c, Status__c, Time_Used_Days__c, CIS_ID_or_Prospect_Name__c, CIS_ID_or_Prospect_Name__r.Name, CIS_ID_or_Prospect_Name__r.Name_TH__c, Group__c, Sub_Group__c, OwnerId, Assigned_Team_Person__c, IssueLog_Creator__c, Issue_Log_Creator_Phone__c, IssueLog_Creator_TL__c,IssueLog_Creator_TL__r.Name,Issue_Log_Creator_TL_Phone__c, IssueLog_Creator_FSVP__c,IssueLog_Creator_FSVP__r.Name, Issue_Log_Creator_FSVP_Phone__c, Division_Formula__c, Product_Formula__c, Product_Text__c, Category_Formula__c, Category_Specify__c, Sub_Category_Formula__c, Sub_Category_Specify__c, Issue_Description__c, Progress_Solution__c, Call_Plan_Call_Report__c, Opportunity__c, Re_Open_Reason__c, Reject_Reason__c, Owner.Profile.Name, Issue_Master__c,Re_Assign_Reason__c, Issue_Log_Owner__c, Need_Long_Term_Solution__c FROM Issue_Log__c WHERE Id = :issueLog.Id];
        init();
    }

    private void init() {
    }

    public PageReference saveRecallAndRedirect() {
    	PageReference pageRef = new PageReference('/apex/CBS_EditOwnerIssueLog_Page?id=' + (Id)this.issueLog.get('Id'));
    	this.issueLog.Status__c = GlobalConstants.RECALLED;
    	update this.issueLog;

        return pageRef;
    }

    public PageReference cancelEdit() {
        PageReference pageRef = new PageReference('/' + (Id)this.issueLog.get('Id'));
        return pageRef;
    }

    public void showError (String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public class IssueLogException extends Exception{}
}