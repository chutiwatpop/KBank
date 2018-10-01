public with sharing class IssueLogController {
	public IssueLogController() {
		
	}

	  @AuraEnabled 
    public static String getProfileUser(){
     // query current user information  
      User oUser = [select id,Name,Profile.name FROM User Where id =: userInfo.getUserId()];

       return oUser.Profile.name;
    }

    @AuraEnabled 
    public static Issue_Log__c getIssueLogs(Id logId){
     // query current user information  
      Issue_Log__c logs = [select Id, OwnerId, Assigned_Internal_Lookup__c, IsSaveDraft__c, Status__c, Comment__c, Rating__c FROM Issue_Log__c Where id =: logId];

      return logs;
    }

    @auraenabled
    public static void updateIssueLog(Issue_Log__c log){
        system.debug('LogData : ' + log);
        update log;
    }

   @AuraEnabled 
    public static List<String> getRatingValue(){
     List<String> options = new List<String>();
      Schema.DescribeFieldResult fieldResult = Issue_Log__c.Rating__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry f: ple) {
          options.add(f.getLabel());
      }

      return options;
    } 

    @AuraEnabled 
    public static Map<boolean, String> getUrlReOpen(Id logId, Id userId){
      Map<boolean, String> dataUrlOrAlertMsg = new Map<boolean, String>(); 

      String currentStatus;
      Id parentId;
      Issue_Log__c logs = [select Id, Parent_Issue__c, Status__c, OwnerId,Current_Status_Formula__c FROM Issue_Log__c Where id =: logId limit 1];
      if(logs.Parent_Issue__c != null){
        List<Issue_Log__c> logsStatus =  [SELECT Id, Current_Status_Formula__c FROM Issue_Log__c WHERE Id =: logs.Parent_Issue__c];
        currentStatus = logsStatus[0].Current_Status_Formula__c;
        parentId = logs.Parent_Issue__c;
      }else{
        parentId = logs.Id;
        currentStatus = logs.Current_Status_Formula__c;
        if(currentStatus == null){
          currentStatus = logs.Status__c;
        }
      }

      if(parentId != null) {      
       if(String.valueOf(userId).substring(0, 15) == String.valueOf(logs.OwnerId).substring(0, 15)) {
        List<Issue_Log__c> recalledChildIssue = [SELECT Id FROM Issue_Log__c WHERE Parent_Issue__c =: parentId AND Status__c = 'Recalled'];
        if((recalledChildIssue == null || recalledChildIssue.size() == 0 ) && (currentStatus == 'Done' || 
            currentStatus == 'Rejected' || currentStatus == 'Closed Won' || currentStatus == 'Closed Lost' || currentStatus == 'Closed')) {

          String url = '/apex/CBS_NewIssueLog_Page?&parentId='+parentId+'&nooverride=1';
          system.debug('Data Url : ' + url);
          dataUrlOrAlertMsg.put(true, url);
       }else {
          dataUrlOrAlertMsg.put(false, Label.CBSIssueLog_NotAllowToReOpen);
        }
      }else {
          dataUrlOrAlertMsg.put(false, Label.CBSIssueLog_OnlyOwnerAllowToReOpen);
        }       
    }else{
        dataUrlOrAlertMsg.put(false, 'Cannot find Parent Id');
      }
      system.debug('DataResult : ' + dataUrlOrAlertMsg);
    return dataUrlOrAlertMsg;
  }
}