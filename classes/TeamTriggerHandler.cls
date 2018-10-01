/**
* @author Panachai Reinthavorn
*/
public class TeamTriggerHandler extends TriggerHandler{

    public override void afterUpdate(){
        List<Team_Target__c> teamTargetsAfterUpdate = Trigger.new;
        List<Team_Target__c> errorTeamTargets = new List<Team_Target__c>();
        boolean enableNotification = [SELECT Enable_Notification__c FROM BottomUp_Notification_Settings__c LIMIT 1].Enable_Notification__c;
        if(enableNotification){
            for(Team_Target__c teamTarget : teamTargetsAfterUpdate){
                Double transactionFeeTargetSum = teamTarget.Transaction_Fee_Target_Sum__c!=null?teamTarget.Transaction_Fee_Target_Sum__c:0;
                Double dealBaseFeeTargetSum = teamTarget.Deal_Base_Fee_Target_Sum__c!=null?teamTarget.Deal_Base_Fee_Target_Sum__c:0;
                Double mainOperatingBankTargetSum = teamTarget.Main_Operating_Bank_Target_Sum__c!=null?teamTarget.Main_Operating_Bank_Target_Sum__c:0;

                boolean enteredTeamTargetSummaryIsLowerThanUploadedTeamTargetSummary = 
                    ((transactionFeeTargetSum < teamTarget.Transaction_Fee_Team_Target__c)||
                    (dealBaseFeeTargetSum < teamTarget.Deal_Base_Fee_Team_Target__c)||
                    (mainOperatingBankTargetSum < teamTarget.Main_Operating_Bank_Team_Target__c));
                if(enteredTeamTargetSummaryIsLowerThanUploadedTeamTargetSummary){
                    errorTeamTargets.add(teamTarget);
                }
            }

            if(!errorTeamTargets.isEmpty()){
                Set<String>allowProfileName = new Set<String>{GlobalConstants.CBS_TL,GlobalConstants.CBS_ADMIN,GlobalConstants.SME_NH};
                List<User> users = [SELECT Id,RC_Code__c,Profile.Name,Employee_ID__c FROM User WHERE Profile.Name IN: allowProfileName AND IsActive = true];
                Map<string,Team_Structure__c>teamRCCodeTeamStructureMap = getTeamStructureMap(errorTeamTargets);
                Map<String,User_Mirror_Management__c> cbs_NHTL_Mgmts = getCBSNHTLMgmts(errorTeamTargets);
                Map<String,List<String>>teamRCCodeRecipientsIDsMap = getRecipientIDs(users,errorTeamTargets,teamRCCodeTeamStructureMap,cbs_NHTL_Mgmts);
                
                List<Task>toInsertTasks = new List<Task>();
                for(Team_Target__c teamTarget:errorTeamTargets){
                    if(!teamRCCodeRecipientsIDsMap.isEmpty()){
                        List<String>taskOwnerIDs = teamRCCodeRecipientsIDsMap.get(teamTarget.Team_RC_Code__c);
                        if(taskOwnerIDs!=null && !taskOwnerIDs.isEmpty()){
                            String teamName = teamRCCodeTeamStructureMap.get(teamTarget.Team_RC_Code__c).Name;
                            List<Task> tasks = createReminderTaskForTL(taskOwnerIDs,teamName);
                            toInsertTasks.addAll(tasks);     
                        }
                    }
                }
                insert toInsertTasks;
                
                String templateApiName = 'Team Target Notification Template';
                EmailTemplate emailTemplate;
                try {
                    emailTemplate = [select Id,name,body,subject from EmailTemplate where developername =: GlobalConstants.TEAM_TARGET_NOTIFICATION_TEMPLATE LIMIT 1];
                } catch (Exception e) {
                    e.setMessage('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + 
                                         ' refer to Setup | Communications Templates ' + templateApiName);
                    throw e;
                }
                List<Messaging.SingleEmailMessage>emails = new List<Messaging.SingleEmailMessage>();
                for(Team_Target__c teamTarget:errorTeamTargets){
                    List<String>emailRecipientIDs = teamRCCodeRecipientsIDsMap.get(teamTarget.Team_RC_Code__c);
                    if(emailRecipientIDs != null && !emailRecipientIDs.isEmpty()){
                        String teamName = teamRCCodeTeamStructureMap.get(teamTarget.Team_RC_Code__c).Name;
                        Messaging.SingleEmailMessage email = createEmail(emailRecipientIDs,emailTemplate,teamName);
                        emails.add(email);
                    }
                }
                sendRemindEmailToTL(emails);
            }
        }
        
    }
    private List<User> getTLUsers(List<User> allUsers,String teamRCCode,String profileName){
        List<User> filteredUsers = new List<User>();
        for(User user:allUsers){
            String userTeamRCCode = user.RC_Code__c;
            String userProfileName = user.Profile.Name;
            boolean isCBSAdmin = (userProfileName.equalsIgnoreCase(GlobalConstants.CBS_ADMIN));
            if(!isCBSAdmin && !String.isBlank(userTeamRCCode) &&userTeamRCCode.equalsIgnoreCase(teamRCCode) && userProfileName.equalsIgnoreCase(profileName)){
                filteredUsers.add(user);
            }
        }
        return filteredUsers;            
    }
    private List<User> getNHTLUsers(List<User> allUsers,String employeeID){
        List<User> filteredUsers = new List<User>();
        for(User user:allUsers){
            String userEmployeeID = user.Employee_ID__c;
            if(userEmployeeID.equalsIgnoreCase(employeeID)){
                filteredUsers.add(user);
            }
        }
        return filteredUsers; 
    }
    private List<User> getCBSAdminUsers(List<User>allUsers){
        List<User> filteredUsers = new List<User>();
        for(User user:allUsers){
            String userProfileName = user.Profile.Name;
            if(userProfileName.equalsIgnoreCase(GlobalConstants.CBS_ADMIN)){
                filteredUsers.add(user);
            }
        }
        return filteredUsers; 
    }

    private Map<String,List<String>> getRecipientIDs(List<User>users,List<Team_Target__c> teamTargets,Map<string,Team_Structure__c>teamRCCodeTeamStructureMap,Map<String,User_Mirror_Management__c> cbs_NHTL_Mgmts){
        Map<String,List<String>> teamRCCodeRecipientsIDs = new Map<String,List<String>>();
        for(Team_Target__c teamTarget:teamTargets){
            String teamRCCode = teamTarget.Team_RC_Code__c;
            List<String> recipientIDs = new List<String>();
            List<User> tlUsrs = getTLUsers(users,teamRCCode,GlobalConstants.CBS_TL);
            if(!tlUsrs.isEmpty()){
                recipientIDs.add(tlUsrs[0].Id);
                teamRCCodeRecipientsIDs.put(teamRCCode,recipientIDs);
                continue;
            }

            Team_Structure__c sTLteamStructure = teamRCCodeTeamStructureMap.get(teamRCCode);
            if(sTLteamStructure != NULL && String.isNotBlank(STLteamStructure.AH_Name__r.RC_Code__c)){
               String stlRCCode = STLteamStructure.AH_Name__r.RC_Code__c;
                List<User> stlUsrs = getTLUsers(users,stlRCCode,GlobalConstants.CBS_TL);
                if(!stlUsrs.isEmpty()){
                    recipientIDs.add(stlUsrs[0].Id);
                    teamRCCodeRecipientsIDs.put(teamRCCode,recipientIDs);
                    continue;
                } 
            }
            User_Mirror_Management__c cbsNHTLMgmt = cbs_NHTL_Mgmts.get(teamRCCode);
            if(cbsNHTLMgmt != NULL && String.isNotBlank(cbsNHTLMgmt.Employee_ID__c)){
                String cbsNHTLEmployeeID = cbsNHTLMgmt.Employee_ID__c;
                List<User>nhtlUsers = getNHTLUsers(users,cbsNHTLEmployeeID);
                if(!nhtlUsers.isEmpty()){
                    recipientIDs.add(nhtlUsers[0].Id);
                    teamRCCodeRecipientsIDs.put(teamRCCode,recipientIDs);
                    continue;
                }
            }
        }
        return teamRCCodeRecipientsIDs;
    }
    private Map<string,Team_Structure__c> getTeamStructureMap(List<Team_Target__c>teamTargets){
        Set<String>teamStructureIDs = new Set<String>();
        for(Team_Target__c teamTarget:teamTargets){
            teamStructureIDs.add(teamTarget.Team_Name__c);
        }
        Map<string,Team_Structure__c> teamRCCodeTeamStructure = new Map<string,Team_Structure__c>();
        List<Team_Structure__c> teamStructures = [SELECT Id,Name,RC_Code__c,AH_Name__r.RC_Code__c FROM Team_Structure__c WHERE ID IN: teamStructureIDs];
        for(Team_Structure__c teamStructure:teamStructures){
            teamRCCodeTeamStructure.put(teamStructure.RC_Code__c,teamStructure);
        }
        return teamRCCodeTeamStructure;
    }
    private List<Task> createReminderTaskForTL(List<String> taskOwnerIDs,String teamName){
        List<Task>reminderTasks = new List<Task>();
        for(String taskOwnerID:taskOwnerIDs){
            Task reminderTask = new Task();
            reminderTask.OwnerId = taskOwnerID;
            reminderTask.ReminderDateTime = System.now();
            String cbsBottomUpTaskDescription = System.label.CBSBottomUp_Task_Description;
            reminderTask.Description = cbsBottomUpTaskDescription.replace('{!Team_Target__c.Team_Name__c}',teamName);
            reminderTask.IsReminderSet = true;
            reminderTask.Subject = 'Team Target has been changed.';
            reminderTasks.add(reminderTask);
        }
        return reminderTasks;
    } 
    private Messaging.SingleEmailMessage createEmail(List<String>recipientIDs,EmailTemplate emailTemplate,String teamTargetName){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String>emailList = getEmailFromRecipientIDs(recipientIDs);
        email.setToAddresses(emailList);
        String emailBody = emailTemplate.Body;
        String emailSubject = emailTemplate.Subject;
        emailBody = emailBody.replace('{!Team_Target__c.Team_Name__c}',teamTargetName);
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);
        email.setTemplateId(emailTemplate.Id);
        return email;
    }
    private void sendRemindEmailToTL(List<Messaging.SingleEmailMessage> emails){
        Messaging.sendEmail(emails);
    }
    private List<String> getEmailFromRecipientIDs(List<String> receipientIDs){
        List<String> receipientIDEmails = new List<String>();
        Set<String> receipientEmailSet = new Set<String>(receipientIDs);
        List<User>users = [SELECT Id,Email FROM User WHERE Id IN: receipientEmailSet];
        for(User user:users){
            receipientIDEmails.add(user.Email);
        }
        return receipientIDEmails;
    }
    private Map<String,User_Mirror_Management__c> getCBSNHTLMgmts(List<Team_Target__c>teamTargets){
        Map<String,User_Mirror_Management__c> teamRCcbsUserMirrorMgmts = new Map<String,User_Mirror_Management__c>();
        Set<String> teamRCCodes = new Set<String>();
        for(Team_Target__c teamTarget:teamTargets){
            teamRCCodes.add(teamTarget.Team_RC_Code__c);
        }
        List<User_Mirror_Management__c>cbsUserMirrorMgmts = [SELECT Mirror_Value__c,Employee_ID__c FROM User_Mirror_Management__c WHERE Mirror_Value__c IN: teamRCCodes AND Mirror_Type__c = 'RC_Code'];
        for(User_Mirror_Management__c cbsUserMirrorMgmt:cbsUserMirrorMgmts){
            teamRCcbsUserMirrorMgmts.put(cbsUserMirrorMgmt.Mirror_Value__c,cbsUserMirrorMgmt);
        }
        return teamRCcbsUserMirrorMgmts;
    }
    
}