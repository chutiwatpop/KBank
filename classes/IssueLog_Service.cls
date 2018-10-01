global without sharing class IssueLog_Service {

	@future
	public static void sendEmails(String issueLogMapString, String oldIssueLogMapString, String userIdsString) {
		Map<Id, Issue_Log__c> issueLogMap = (Map<Id, Issue_Log__c>) JSON.deserialize(issueLogMapString, Map<Id, Issue_Log__c>.class);
		
		Map<Id, Issue_Log__c> oldIssueLogMap = new Map<Id, Issue_Log__c>();
		if(String.isNotEmpty(oldIssueLogMapString)) {
			oldIssueLogMap = (Map<Id, Issue_Log__c>) JSON.deserialize(oldIssueLogMapString, Map<Id, Issue_Log__c>.class);	
		}
		Set<Id> userIds = new Set<Id>();
		if(String.isNotEmpty(userIdsString)) {
			userIds = (Set<Id>) JSON.deserialize(userIdsString, Set<Id>.class);
		}
		Map<Id, User> internalUserMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN :userIds]);
        System.debug('internalUserMap>>>:' + internalUserMap);

		List<CBS_Issue_Log_Management__c> issueLogExternalUser = [SELECT Name, PM_Email__c FROM CBS_Issue_Log_Management__c];
		Map<String, String> exUserEmailMapByName = new Map<String, String>();
		for(CBS_Issue_Log_Management__c eachExUser : issueLogExternalUser) {
			exUserEmailMapByName.put(eachExUser.Name, eachExUser.PM_Email__c);
		}
        System.debug('exUserEmailMapByName>>>:' + exUserEmailMapByName);

		Set<String> template = new Set<String>{
            GlobalConstants.ISSUE_LOG_UPDATE_TEMPLATE, GlobalConstants.ISSUE_LOG_ESCALATE_TEMPLATE, GlobalConstants.ISSUE_LOG_NEW_TEMPLATE,GlobalConstants.ISSUE_LOG_RECALL_TEMPLATE,GlobalConstants.ISSUE_LOG_REJECT_TEMPLATE,GlobalConstants.ISSUE_LOG_CANCEL_TEMPLATE
        };

        Map<String,EmailTemplate> emailTemplateMapByDevName = new Map<String,EmailTemplate>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName IN: template]);
        for(EmailTemplate eachTemplate : emailTemplateList){
            emailTemplateMapByDevName.put(eachTemplate.DeveloperName,eachTemplate);
        }

        List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>();
        Issue_Log__c oldIssue;
        User eachUser;
        for(Issue_Log__c eachIssue : issueLogMap.values()) {
        	String toAddress = '';
        	String toCCAddress = null;
        	EmailTemplate issueEmailTemplate = null;
	        if(!oldIssueLogMap.isEmpty() && oldIssueLogMap.containsKey(eachIssue.Id)) {
	        	oldIssue = oldIssueLogMap.get(eachIssue.Id);
	        	if(eachIssue.Status__c != oldIssue.Status__c) {
	        		if(eachIssue.Status__c == GlobalConstants.RECALLED) {
	        			// Send to assigned
	        			if(eachIssue.Assigned_Internal_Lookup__c != null && internalUserMap.containsKey(eachIssue.Assigned_Internal_Lookup__c)) {
                            toAddress = internalUserMap.get(eachIssue.Assigned_Internal_Lookup__c).Email;
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_RECALL_TEMPLATE);
                        } else if(exUserEmailMapByName.containsKey(eachIssue.Assigned_Team_Person_Text__c)) {
                            toAddress = exUserEmailMapByName.get(eachIssue.Assigned_Team_Person_Text__c);
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_RECALL_TEMPLATE);
                        }
	        		} else if(eachIssue.Status__c == GlobalConstants.REJECTED) {
                        if(internalUserMap.containsKey(eachIssue.Issue_Log_Owner__c)) {
                            toAddress = internalUserMap.get(eachIssue.Issue_Log_Owner__c).Email;
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_REJECT_TEMPLATE);
                        }
	        		} else if(eachIssue.Status__c == GlobalConstants.CBS_ISSUELOG_CANCELLED) {
                        //GlobalConstants.ISSUE_LOG_CANCEL_TEMPLATE
                        if(eachIssue.Assigned_Internal_Lookup__c != null && internalUserMap.containsKey(eachIssue.Assigned_Internal_Lookup__c)) {
                            toAddress = internalUserMap.get(eachIssue.Assigned_Internal_Lookup__c).Email;
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_CANCEL_TEMPLATE);
                        } else if(exUserEmailMapByName.containsKey(eachIssue.Assigned_Team_Person_Text__c)) {
                            toAddress = exUserEmailMapByName.get(eachIssue.Assigned_Team_Person_Text__c);
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_CANCEL_TEMPLATE);
                        }                        
                    } 
                    else {
                        if(internalUserMap.containsKey(eachIssue.Issue_Log_Owner__c)) {
                            toAddress = internalUserMap.get(eachIssue.Issue_Log_Owner__c).Email;
                            issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_UPDATE_TEMPLATE);
                        }
                    }

                    // Add Email
                    if(issueEmailTemplate != null && String.isNotEmpty(toAddress)) {
                        emailToSendList.add(setEmail(issueEmailTemplate, eachIssue, toAddress, toCCAddress));  
                        issueEmailTemplate = null;
                        toAddress = '';
                    }
				}
	    		// Owner Change <= owner not changed any more
				/*if(eachIssue.Issue_Log_Owner__c != oldIssue.Issue_Log_Owner__c) {
					if(internalUserMap.containsKey(eachIssue.Issue_Log_Owner__c)) {
						toAddress = internalUserMap.get(eachIssue.Issue_Log_Owner__c).Email;
						issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_ESCALATE_TEMPLATE);
					}

                    // Add Email
                    if(issueEmailTemplate != null && String.isNotEmpty(toAddress)) {
                        emailToSendList.add(setEmail(issueEmailTemplate, eachIssue, toAddress, toCCAddress));  
                        issueEmailTemplate = null;
                        toAddress = '';
                    }				
				}*/
				// Assigned Change
				if(eachIssue.Assigned_Team_Person_Text__c != oldIssue.Assigned_Team_Person_Text__c || eachIssue.Assigned_Internal_Lookup__c != oldIssue.Assigned_Internal_Lookup__c) {
					if(eachIssue.Assigned_Internal_Lookup__c != null && internalUserMap.containsKey(eachIssue.Assigned_Internal_Lookup__c)) {
						toAddress = internalUserMap.get(eachIssue.Assigned_Internal_Lookup__c).Email;
						issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_NEW_TEMPLATE);
					} else if(exUserEmailMapByName.containsKey(eachIssue.Assigned_Team_Person_Text__c)) {
						toAddress = exUserEmailMapByName.get(eachIssue.Assigned_Team_Person_Text__c);
						issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_NEW_TEMPLATE);
					}

                    // Add Email
                    if(issueEmailTemplate != null && String.isNotEmpty(toAddress)) {
                        emailToSendList.add(setEmail(issueEmailTemplate, eachIssue, toAddress, toCCAddress));  
                        issueEmailTemplate = null;
                        toAddress = '';
                    }
				}
			} else {
				// Create New Issue Send Email to Assined User
				if(eachIssue.Assigned_Internal_Lookup__c != null && internalUserMap.containsKey(eachIssue.Assigned_Internal_Lookup__c)) {
					toAddress = internalUserMap.get(eachIssue.Assigned_Internal_Lookup__c).Email;
					issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_NEW_TEMPLATE);
				} else if(exUserEmailMapByName.containsKey(eachIssue.Assigned_Team_Person_Text__c)) {
					toAddress = exUserEmailMapByName.get(eachIssue.Assigned_Team_Person_Text__c);
					issueEmailTemplate = emailTemplateMapByDevName.get(GlobalConstants.ISSUE_LOG_NEW_TEMPLATE);
				}

                if(issueEmailTemplate != null && String.isNotEmpty(toAddress)) {
                    emailToSendList.add(setEmail(issueEmailTemplate, eachIssue, toAddress, toCCAddress));   
                }
			}
        }
        System.debug('emailToSendList>>>:' + emailToSendList);
        if(!emailToSendList.isEmpty()) {
        	sendEmails(emailToSendList);
        }
	}

	private static Messaging.SingleEmailMessage setEmail(EmailTemplate emailTemplate, Issue_Log__c eachIssueObj, String toAddress, String toCCAddress) {
        Messaging.SingleEmailMessage emailObj = setEmailTemplateBodyAndSubject(eachIssueObj , emailTemplate);
        emailObj.setToAddresses(new List<String>{toAddress});
        emailObj.setUseSignature(false);
        emailObj.setSaveAsActivity(false);
        if(toCCAddress != null) emailObj.setCCAddresses(new List<String>{toCCAddress});
        
        return emailObj;
    }

    public static Messaging.SingleEmailMessage setEmailTemplateBodyAndSubject(Issue_Log__c eachIssue, EmailTemplate emailTemplate){
    	Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();

        String fullTemplateBody = emailTemplate.Body;
        String emailSubjectSent = emailTemplate.Subject;

        Map<String, Schema.SObjectField> issueLogFields = Schema.SObjectType.Issue_Log__c.fields.getMap();
        
        Integer index;
        String replaceText;
        String fieldString;
        String target;
        String createTime;
        Datetime createDateTime;
        for(Schema.SObjectField fieldName : issueLogFields.values()) {
        	replaceText = '';
            fieldString = '{!Issue_Log__c.' + String.valueOf(fieldName)+'}';
            if(fullTemplateBody.contains(fieldString)){
                index = fullTemplateBody.indexOf(fieldString);
                target = fullTemplateBody.substring(index, (index + fieldString.length()));
                if(String.valueOf(eachIssue.get(String.valueOf(fieldName))) != null) {
                    if(fieldString == '{!Issue_Log__c.CreatedDate}'){
                        createDateTime = eachIssue.CreatedDate;
                        createTime = createDateTime.format('yyyy-MM-dd HH:mm');
                        String[] splitedTime = createTime.split(' ');
                        replaceText = splitedTime[0] + ' ' + splitedTime[1];
                    } else if(fieldString == '{!Issue_Log__c.Subject__c}'){
                        replaceText = eachIssue.Subject__c;
                    } else if(fieldString == '{!Issue_Log__c.Name}'){
                        replaceText = eachIssue.Name;
                    } else if(fieldString == '{!Issue_Log__c.Status__c}'){
                        replaceText = eachIssue.Status__c;
                    } else if(fieldString == '{!Issue_Log__c.Customer_Name__c}'){
                        replaceText = eachIssue.Customer_Name__c;
                    } else if(fieldString == '{!Issue_Log__c.CIS_ID_or_Prospect_Name__c}'){
                        replaceText = eachIssue.CIS_ID_or_Prospect_Name__c;
                    } else if(fieldString == '{!Issue_Log__c.Division_Formula__c}'){
                        replaceText = eachIssue.Division_Formula__c;
                    } else if(fieldString == '{!Issue_Log__c.Product_Formula__c}'){
                        replaceText = eachIssue.Product_Formula__c;
                    } else if(fieldString == '{!Issue_Log__c.Product_Text__c}'){
                        replaceText = eachIssue.Product_Text__c;
                    } else if(fieldString == '{!Issue_Log__c.Category_Formula__c}'){
                        replaceText = eachIssue.Category_Formula__c;
                    } else if(fieldString == '{!Issue_Log__c.Category_Specify__c}'){
                        replaceText = eachIssue.Category_Specify__c;
                    } else if(fieldString == '{!Issue_Log__c.Sub_Category_Formula__c}'){
                        replaceText = eachIssue.Sub_Category_Formula__c;
                    } else if(fieldString == '{!Issue_Log__c.Sub_Category_Specify__c}'){
                        replaceText = eachIssue.Sub_Category_Specify__c;
                    } else if(fieldString == '{!Issue_Log__c.Id}'){
                        replaceText = URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachIssue.Id;
                    } else if(String.valueOf(eachIssue.get(fieldName)) != null){
                    	replaceText = String.valueOf(eachIssue.get(fieldName));
                    }

                    if(String.isNotEmpty(replaceText)) {
                    	fullTemplateBody = fullTemplateBody.replace(target,replaceText);
                    }
                } else {
                    fullTemplateBody = fullTemplateBody.replace(target,'');
                }
            }

            if(emailSubjectSent.contains(fieldString)){
                index = emailSubjectSent.indexOf(fieldString);
                target = emailSubjectSent.substring(index, (index + fieldString.length()));
                if(String.valueOf(eachIssue.get(String.valueOf(fieldName))) != null) {
                    if(fieldString == '{!Issue_Log__c.Subject__c}'){
                        replaceText = eachIssue.Subject__c;
                    } else if(fieldString == '{!Issue_Log__c.Name}'){
                        replaceText = eachIssue.Name;
                    } else if(fieldString == '{!Issue_Log__c.Status__c}'){
                        replaceText = eachIssue.Status__c;
                    } else if(String.valueOf(eachIssue.get(fieldName)) != null){
                    	replaceText = String.valueOf(eachIssue.get(fieldName));
                    }

                    if(String.isNotEmpty(replaceText)) {
                    	emailSubjectSent = emailSubjectSent.replace(target,replaceText);
                    }
                } else {
                    emailSubjectSent = emailSubjectSent.replace(target,'');
                }
            }
        }
        fullTemplateBody = fullTemplateBody.replace('{!Issue_Log__c.Link}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachIssue.Id);
        System.debug('fullTemplateBody : ' + fullTemplateBody);
        System.debug('emailSubjectSent : ' + emailSubjectSent);

        emailObj.setPlainTextBody(fullTemplateBody);
        emailObj.setSubject(emailSubjectSent);
        return emailObj;
    }

	public static void sendEmails(List<Messaging.SingleEmailMessage> emailToSendList){
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailToSendList);
        for(Messaging.SendEmailResult eachResult : emailResults){
            if(!eachResult.IsSuccess()){
                System.debug(eachResult.getErrors()+'');
            }
        }
    }

    public static void setIssueCreator(Issue_Log__c eachIssue, User ownerUser) {
		Id tlUserId = null;
		Id fsvpUserId = null;

        if(ownerUser.ManagerId != null && ownerUser.Manager.IsActive) {
            if(ownerUser.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Profile.Name == GlobalConstants.SME_NH) {
                tlUserId = ownerUser.ManagerId;
            } else if(ownerUser.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
                fsvpUserId = ownerUser.ManagerId;
            }
        }

		if(ownerUser.Manager.ManagerId != null && ownerUser.Manager.Manager.IsActive) {
            if(tlUserId == null && ownerUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                tlUserId = ownerUser.Manager.ManagerId;
            } else if(fsvpUserId == null && ownerUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
                fsvpUserId = ownerUser.Manager.ManagerId;
            }
        }

		if(ownerUser.Manager.Manager.ManagerId != null && ownerUser.Manager.Manager.Manager.IsActive) {
            if(tlUserId == null && ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                tlUserId = ownerUser.Manager.Manager.ManagerId;
            } else if(fsvpUserId == null && ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
                fsvpUserId = ownerUser.Manager.Manager.ManagerId;
            }
        }

        if(ownerUser.Manager.Manager.Manager.ManagerId != null && ownerUser.Manager.Manager.Manager.Manager.IsActive) {
            if(tlUserId == null && ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                tlUserId = ownerUser.Manager.Manager.Manager.ManagerId;
            } else if(fsvpUserId == null && ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
                fsvpUserId = ownerUser.Manager.Manager.Manager.ManagerId;
            }
        }

		eachIssue.IssueLog_Creator__c = eachIssue.Issue_Log_Owner__c;
		eachIssue.IssueLog_Creator_TL__c = tlUserId;
		eachIssue.IssueLog_Creator_FSVP__c = fsvpUserId;
	}

    public static void escalateOwner(Issue_Log__c issueLogObj){
        User ownerUser = new User();
        ownerUser = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name FROM User WHERE Id = :issueLogObj.Assigned_Internal_Lookup__c LIMIT 1];
        if(ownerUser == null) {
        	throw new IssueLogException('Cannot found owner User');
        }

        Id managerId = null;
		if(ownerUser.ManagerId != null && ownerUser.Manager.IsActive && ownerUser.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
			//(ownerUser.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Profile.Name == GlobalConstants.SME_NH || ownerUser.Manager.Profile.Name == GlobalConstants.CBS_FSVP)) {
			managerId = ownerUser.ManagerId;
		}

		if(ownerUser.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.IsActive && ownerUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
			//(ownerUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || ownerUser.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP)) {
			managerId = ownerUser.Manager.ManagerId;
		}

		if(ownerUser.Manager.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.Manager.IsActive && ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
			//(ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || ownerUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP)) {
			managerId = ownerUser.Manager.Manager.ManagerId;
		}

		if(ownerUser.Manager.Manager.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.Manager.IsActive && ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP) {
			//(ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_TL || ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH || ownerUser.Manager.Manager.Manager.Manager.Profile.Name == GlobalConstants.CBS_FSVP)) {
			managerId = ownerUser.Manager.Manager.Manager.ManagerId;
		}

		if(managerId != null) {
            issueLogObj.Re_Assign_Reason__c = null;
        	issueLogObj.Assigned_Internal_Lookup__c = managerId;
            issueLogObj.Status__c = GlobalConstants.ON_PROCESS_BY_FSVP;
		} else {
			throw new IssueLogException('Cannot escalate!! Not found CBS-TL or CBS-FSVP');
		}

        update issueLogObj;
    }

    public static Id getManagerFromUserWithManagerProfile(User ownerUser, String managerProfile){
        Set<String> managerProfileSet = new Set<String>();
        managerProfileSet.add(managerProfile);
        if(managerProfile == GlobalConstants.CBS_TL) {
            managerProfileSet.add(GlobalConstants.SME_NH);
        }

        Id managerId = null;
        if(ownerUser.ManagerId != null && ownerUser.Manager.IsActive && managerProfileSet.contains(ownerUser.Manager.Profile.Name)) {
            managerId = ownerUser.ManagerId;
        }

        if(ownerUser.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.IsActive && managerProfileSet.contains(ownerUser.Manager.Manager.Profile.Name)) {
            managerId = ownerUser.Manager.ManagerId;
        }

        if(ownerUser.Manager.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.Manager.IsActive && managerProfileSet.contains(ownerUser.Manager.Manager.Manager.Profile.Name)) {
            managerId = ownerUser.Manager.Manager.ManagerId;
        }

        if(ownerUser.Manager.Manager.Manager.ManagerId != null && managerId == null && ownerUser.Manager.Manager.Manager.IsActive && managerProfileSet.contains(ownerUser.Manager.Manager.Manager.Manager.Profile.Name)) {
            managerId = ownerUser.Manager.Manager.Manager.ManagerId;
        }

        return managerId;
    }

    public static Assignment_History_CBS__c createAssignmentHistory(Issue_Log__c eachIssue) {
		Assignment_History_CBS__c assignHistory = new Assignment_History_CBS__c();
		assignHistory.Name__c = eachIssue.Assigned_Team_Person__c;
        assignHistory.Issue_Log_Number__c = eachIssue.Id;
        if(eachIssue.Status__c == GlobalConstants.STATUS_DONE){
            assignHistory.Released_As__c = eachIssue.Status__c;
            assignHistory.Released_Date__c = eachIssue.Date_Time_Closed__c;
            assignHistory.Assigned_Date__c = eachIssue.Date_Time_Opened__c;
        }
        else{
            assignHistory.Assigned_Date__c = System.now();
        }
		return assignHistory;
	}

    public static Assignment_History_CBS__c updateAssignmentHistory(Issue_Log__c eachIssue, String releaseAs, Assignment_History_CBS__c assignHistory) {
        assignHistory.Released_As__c = releaseAs;
        assignHistory.Released_Date__c = System.now();
        if(eachIssue.Status__c != GlobalConstants.RECALLED && eachIssue.Status__c != GlobalConstants.REJECTED) {
            assignHistory.Re_Assign_Notes__c = eachIssue.Re_Assign_Reason__c;
        }
        
        return assignHistory;
    }

    public static Account getSelectAccount(Id accountId) {
        return [SELECT Id, Name, Name_TH__c, Group__c, Sub_Group__c FROM Account WHERE Id = :accountId];
    }

    //public static Issue_Log__c setParentValueSet(Issue_Log__c eachIssue, Id parentId, Id recTypeId) {
    //    eachIssue.Parent_Issue__c = parentId;
    //    eachIssue.RecordTypeId = recTypeId;
    //}
    public static void cancelIssueLogFromOwnerChange(Set<Id> cisIdSet,Map<Id,Id> accountOwnerMapByCISId){
        Map<Id, String> recordTypeDevNameMapById;
        Map<String, Id> recordTypeIdMapByDevName;
        System.debug('cancelIssueLogFromOwnerChange 1'+ cisIdSet);
        System.debug('cancelIssueLogFromOwnerChange 2'+ accountOwnerMapByCISId);
        if(recordTypeIdMapByDevName == null) {
            recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
        }
        if(recordTypeDevNameMapById == null) {
            recordTypeDevNameMapById = GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Issue_Log__c');
        }
         
        List<Issue_Log__c> toUpdateIssueLog = new List<Issue_Log__c>();
        List<Issue_Log__c> relatedIssueLog = [SELECT Id,Status__c,RecordTypeId,OwnerId,CIS_ID_or_Prospect_Name__c FROM Issue_Log__c WHERE CIS_ID_or_Prospect_Name__c IN :cisIdSet];
        if(relatedIssueLog.size() != 0){
            for(Issue_Log__c eachIssueLog : relatedIssueLog){
                String eachIssueLogRecordType = recordTypeDevNameMapById.get(eachIssueLog.RecordTypeId);
                System.debug('eachIssueLogRecordType>>>>>'+eachIssueLogRecordType);
                if(eachIssueLogRecordType == GlobalConstants.CBS_OPEN_ISSUE_NORMAL_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_NORMAL_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_NORMAL_NO_RATING_REC){
                    eachIssueLog.RecordTypeId =  recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_NORMAL_READ_ONLY_REC);
                }
                else if(eachIssueLogRecordType == GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_PARENT_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_PARENT_NO_RATING_REC){
                    eachIssueLog.RecordTypeId =  recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_PARENT_READ_ONLY_REC);
                }
                else if(eachIssueLogRecordType == GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_SECOND_REC || eachIssueLogRecordType == GlobalConstants.CBS_CLOSED_ISSUE_SECOND_NO_RATING_REC){
                    eachIssueLog.RecordTypeId =  recordTypeIdMapByDevName.get(GlobalConstants.CBS_CLOSED_ISSUE_SECOND_READ_ONLY_REC);
                }
                if(eachIssueLog.Status__c != GlobalConstants.CBS_ISSUELOG_DONE && eachIssueLog.Status__c != GlobalConstants.CBS_ISSUELOG_REJECT && eachIssueLog.Status__c != GlobalConstants.CBS_ISSUELOG_CLOSE && eachIssueLog.Status__c != GlobalConstants.CBS_ISSUELOG_CLOSE_WON && eachIssueLog.Status__c != GlobalConstants.CBS_ISSUELOG_CLOSE_LOST){
                    eachIssueLog.Status__c = GlobalConstants.CBS_ISSUELOG_CANCELLED;    
                }                
                eachIssueLog.OwnerId = accountOwnerMapByCISId.get(eachIssueLog.CIS_ID_or_Prospect_Name__c);
                //eachIssueLog.OwnerId = eachIssueLog.CIS_ID_or_Prospect_Name__r.OwnerId;
                toUpdateIssueLog.add(eachIssueLog);
            }
            System.debug('toUpdateIssueLog List'+toUpdateIssueLog);
            update toUpdateIssueLog;    
        }        
    }
    global class IssueLogException extends Exception{}
}