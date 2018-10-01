public without sharing class CBS_Site_IssueLog_Controller {

    public Id refId {get;set;}
    public Issue_Log__c issue {get;set;}
    public Boolean resultRender {get;set;}
    public List<SelectOption> statusItems {get;set;}
    public List<String> avlCloseStatus;
    public Boolean unEditable {get;set;}

    public Boolean warningRender{get;set;}
    public String warningMessage{get;set;}

    public Boolean reasonRender{get;set;}

    public Boolean infoRender{get;set;}
    public String infoMessage{get;set;}

    public Boolean closeDateRender{get;set;}

    public String statusHelpText {get;set;}

    public CBS_Site_IssueLog_Controller() {
        issue = new Issue_Log__c();
        resultRender = false;
        avlCloseStatus = new List<String>();
        unEditable = false;
        warningRender = false;
        warningMessage ='';
        reasonRender = false;
        infoRender = false;
        infoMessage = '';
        closeDateRender = false;
        statusHelpText = '';
    }
    public PageReference getIssue(){
        warningRender = false;
        resultRender = false;
        infoRender = false;
        closeDateRender = false;
        statusItems = new List<SelectOption>();
        Id issueId = refId;
        try{
            Issue_Log__c issueLog = [SELECT Issue_Master__c,Issue_Master__r.Available_Closed_Status__c,Id,Subject__c,Name,Date_Time_Opened__c,Date_Time_Closed__c,Status__c,Reject_Reason__c,CIS_ID_or_Prospect_Name_Text__c,Customer_Name__c,Issue_Log_Creator_Text__c,Division_Formula__c,Product_Formula__c,Product_Text__c,Category_Formula__c,Category_Specify__c,Sub_Category_Formula__c,Sub_Category_Specify__c,Issue_Description__c,Progress_Solution__c, Parent_Issue__c, Need_Long_Term_Solution__c FROM Issue_Log__c WHERE Id =:issueId LIMIT 1];
            if(issueLog != null){
                resultRender = true;
                issue = issueLog;
                if(issueLog.Issue_Master__c != null && issueLog.Issue_Master__r.Available_Closed_Status__c != null) {
                        avlCloseStatus = issueLog.Issue_Master__r.Available_Closed_Status__c.split(';');
                        if(avlCloseStatus.size() > 0){
                            statusItems.add(new SelectOption(issueLog.Status__c,issueLog.Status__c));
                            for(String eachStatus: avlCloseStatus){
                                statusItems.add(new SelectOption(eachStatus,eachStatus));
                            }
                            statusItems.add(new SelectOption('Rejected','Rejected'));
                        } 
                        else {
                            statusItems.add(new SelectOption('None','N/A'));
                        }
                        avlCloseStatus.add('Rejected');
                    }
                closeDateRender = CheckClose();
                unEditable = CheckStatus(issueLog.Status__c); 
                renderStatusHelpText();
            }
            else{
                warningRender = true;
                warningMessage = System.Label.CBSServicing_Invalid_Salesforce_ID_error;
                resultRender = false;
                return null;
            }
            if(issueLog.Status__c == 'Rejected'){
                reasonRender = true;
            }
            else{
                reasonRender = false;
            }
            avlCloseStatus.add('Recalled');
            for(String eachCloseStatus : avlCloseStatus){
               if(issueLog.Status__c == eachCloseStatus){
                    closeDateRender = true;
               } 
            }
        }
        catch(Exception e){
            resultRender = false;
            warningRender = true;
            warningMessage = System.Label.CBSServicing_Invalid_Salesforce_ID_error;
            return null;
        }
        

        return null;
    }

    public Boolean CheckStatus(String currentStatus){
        Boolean lockStatus = false;
        avlCloseStatus.add('Recalled');
        for(String eachCloseStatus : avlCloseStatus){
           if(currentStatus == eachCloseStatus){
                lockStatus = true;
           } 
        }       
        return lockStatus;
    }
    public PageReference CheckStatusReject(){
        String status = issue.Status__c;
        if(status == 'Rejected'){
            reasonRender = true;
        }
        else{
            reasonRender = false;
        }
        renderStatusHelpText();
        return null;
    }
    public Boolean CheckClose(){
        Boolean isClose = false;
        for(String eachStatus : avlCloseStatus){
            if(issue.Status__c == eachStatus){
                isClose = true;
            }
        }
        return isClose;
    }
    public PageReference Submit(){
        try{
            List<Issue_Log__c> issueLogUpdateList = new List<Issue_Log__c>();
            Set<String> closeStatusSet = new Set<String>{GlobalConstants.REJECTED, GlobalConstants.STATUS_DONE, GlobalConstants.CLOSED, GlobalConstants.CLOSED_WON, GlobalConstants.CLOSE_LOST};

            warningRender = false;
            warningMessage = '';
            infoRender = false;
            infoMessage = '';

            for(String eachCloseStatus : avlCloseStatus){
               if(issue.Status__c == eachCloseStatus && issue.Status__c != 'New' && issue.Status__c != 'Recalled'){
                    issue.Date_Time_Closed__c = System.now();
               } 
            }
            
            if(issue.Status__c == 'Rejected' && issue.Reject_Reason__c == null){
                throw new IssueLogException('Please input Reject Reason');
            } else{
                if(issue.Parent_Issue__c != null) {
                    Issue_Log__c parentIssue = [SELECT Id, Current_Child_Issue_Log__c, Previous_Closed_Issue_Log_Group__c FROM Issue_Log__c WHERE Id = :issue.Parent_Issue__c];
                    issueLogUpdateList.add(parentIssue);
                }
                issueLogUpdateList.add(issue);
                update issueLogUpdateList;
                infoRender = true; 
                infoMessage = 'Update Complete';
                resultRender = false;
                refId = null;
            }           
        }
        catch(Exception e){
            warningRender = true;
            warningMessage = e.getMessage();
        }

        return null;
    }
    public void renderStatusHelpText(){
        String selectStatus = issue.Status__c;
        if(selectStatus == GlobalConstants.STATUS_NEW){
            statusHelpText = '';
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_DONE){
            statusHelpText = Label.CBSIssueLog_Status_Done;
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_CLOSE){
            statusHelpText = Label.CBSIssueLog_Status_Closed;
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_CLOSE_LOST){
            statusHelpText = Label.CBSIssueLog_Status_Closed_Lost;
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_CLOSE_WON){
            statusHelpText = Label.CBSIssueLog_Status_Closed_Won;
        }
        else if(selectStatus == GlobalConstants.CBS_ISSUELOG_REJECT){
            statusHelpText = Label.CBSIssueLog_Status_Rejected;
        }
        else{
            statusHelpText = '';
        }
    }
    public class IssueLogException extends Exception{}
}