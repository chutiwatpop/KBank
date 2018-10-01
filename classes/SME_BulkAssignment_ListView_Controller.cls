public without sharing class SME_BulkAssignment_ListView_Controller {

    public Boolean hasError{get;set;}
    public Integer rows{get{return Integer.valueOf(Label.Page_Size);}}
    

    //CBS
    public Set<String> rcCodes;
    public Boolean nhActAsTL {get;set;}
    public Boolean run {get;set;}
    public Map<String,User_Mirror_Management__c> nHTLCustomSettingByUserRCCode;
    public Boolean selectedNHTLChoice {get;set;}
    public String year{get;set;}

    @TestVisible
    private String staticPrefix = 'extjs_reassign_data';

    public SME_BulkAssignment_ListView_Controller() {
        hasError = false;

        nhActAsTL = false;
        run = true;
        nHTLCustomSettingByUserRCCode =  CustomSettingUtil.getMirrorSettingByUserRcCode();
        selectedNHTLChoice = false;
        //year = String.valueOf(System.today().year() - 543);
        year = String.valueOf( GlobalUtility.getYearInChristianCalendar(System.today()) );
    }

    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse queryPickListOfObj(ModelExtensions.QueryPickListObj qobj){
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sobj = objTypeMap.get(qobj.sobjname);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();

        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();

        try{
            Schema.DescribeFieldResult fieldResult = fieldMap.get(qobj.field).getDescribe();

            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();

            for( Schema.PicklistEntry value : pickListValues)
            {
               resp.records.add(new ModelExtensions.PicklistByFilterKey(value.getValue(),value.getLabel(),value.getValue()));
            } 

        } catch(Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        System.debug('resp : '+resp);
        return resp;
    }

    // AH name under correct NH role
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedAHByNH(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        try {
            List<UserRole> userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :currentUser.UserRoleId ORDER BY DeveloperName];
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(UserRole eachUserRole : userRoleList){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUserRole.Id+'',eachUserRole.Name+'',eachUserRole.DeveloperName.replace('RC', '')+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // TM name under correct AH role
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedTMByAH(ModelExtensions.QueryPickListObj qobj) {
        System.debug('qobj::'+qobj);
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        try {
            List<UserRole> userRoleNHList;
            List<UserRole> userRoleList;
            if(qobj.scope!=null){
                userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :qobj.scope ORDER BY DeveloperName];
            }else{
                userRoleNHList = [SELECT Id FROM UserRole WHERE ParentRoleId = :currentUser.UserRoleId];
                userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId IN:userRoleNHList ORDER BY DeveloperName];
            }
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(UserRole eachUserRole : userRoleList){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUserRole.Id+'',eachUserRole.Name+'',eachUserRole.DeveloperName.replace('RC', '').replace('RM', '')+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // Get All The team names
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedByTeamName(ModelExtensions.QueryPickListObj qobj){
        System.debug('qobj::'+qobj);
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();

        Set<String> cbsSegment = new Set<String>{'CB','MB'};
        
        try{
            List<Team_Structure__c> finalResult = new List<Team_Structure__c>();
            if(qobj.rccodes != null){
                String rcCodesStringForQuery = qobj.rccodes.replaceAll('\\s+','').substringBetween('[',']');
                Set<String> rcCodesForQuery = new Set<String>(rcCodesStringForQuery.split(','));
                
                finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null AND Segment__c IN: cbsSegment AND RC_Code__c IN: rcCodesForQuery ORDER BY Name];
            }else{
                finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null AND Segment__c IN: cbsSegment ORDER BY Name];
            }
            

            if(qobj.extra!=null){
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            }

            if(currentUser.Profile.Name == GlobalConstants.CBS_ADMIN){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(GlobalConstants.CBS_ADMIN,GlobalConstants.CBS_ADMIN,GlobalConstants.CBS_ADMIN));
            }

            for(Team_Structure__c eachTeam : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachTeam.Id+'',eachTeam.Name+'',eachTeam.RC_Code__c+''));
            }

        }catch (Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // AF Get Team
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse queryTeamNameByRC(ModelExtensions.QueryPickListObj qobj){
        System.debug('qobj::'+qobj);
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
    
        try{
            List<Team_Structure__c> finalResult = new List<Team_Structure__c>();
            if(qobj.isAH !=null && qobj.isAH == true){
                if(qobj.rccodes != null){
                    finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND AH_RC_Code__c =: qobj.rccodes AND Segment__c ='AF' ORDER BY Name];
                }
            }else if(qobj.isNH !=null && qobj.isNH == true){
                if(qobj.ahLevel !=null && qobj.ahLevel == true){
                    finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND NH_RC_Code__c !=NULL AND NH_RC_Code__c =: qobj.rccodes AND AH_RC_Code__c =null AND Segment__c ='AF'  ORDER BY Name];
                }else{
                    if(qobj.scope !=null){
                        finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND NH_RC_Code__c =: qobj.rccodes AND AH_RC_Code__c =:qobj.scope AND Segment__c ='AF' ORDER BY Name];
                    }else{
                        finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND NH_RC_Code__c =: qobj.rccodes AND AH_RC_Code__c !=null  AND Segment__c ='AF' ORDER BY Name];
                    }   
                }
            }else if(qobj.isAdmin !=null && qobj.isAdmin == true){
                if(qobj.ahLevel !=null && qobj.ahLevel == true){
                    finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND NH_RC_Code__c !=NULL AND AH_RC_Code__c =NULL AND Segment__c ='AF'  ORDER BY Name];
                }else{
                    if(qobj.scope !=null){
                        finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND AH_RC_Code__c =:qobj.scope AND Segment__c ='AF' ORDER BY Name];
                    }else{
                        finalResult = [SELECT Id, Name__c, Name, RC_Code__c FROM Team_Structure__c WHERE Name != null  AND AH_RC_Code__c !=null  AND Segment__c ='AF' ORDER BY Name];
                    }   
                }
            }
            
            resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(Team_Structure__c eachTeam : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachTeam.Name+'',eachTeam.Name+'',eachTeam.RC_Code__c+''));
            }

        }catch (Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // AF Get Team
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse queryRMNameByTeam(ModelExtensions.QueryPickListObj qobj){
        
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        try{
            List<User> finalResult = new List<User>();

            if(qobj.scope != null){
                finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND Team_Name__c =: qobj.scope ORDER BY Name];
            }else if(qobj.ahRCcode !=null){
                finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND AH_RC_Code__c =: qobj.ahRCcode ORDER BY Name];
            }else{
                User userStrucObj = [SELECT Id,Name,Profile.Name,RC_Code__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
                if(userStrucObj.Profile.Name == GlobalConstants.AF_NH){
                    finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND NH_RC_Code__c =: userStrucObj.RC_Code__c ORDER BY Name];
                }else if(userStrucObj.Profile.Name == GlobalConstants.AF_AH){   
                    finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND AH_RC_Code__c =: userStrucObj.RC_Code__c ORDER BY Name];
                }else if(userStrucObj.Profile.Name == GlobalConstants.AF_TM){
                    finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND RC_Code__c =: userStrucObj.RC_Code__c ORDER BY Name];
                }else if(userStrucObj.Profile.Name == GlobalConstants.RBS_ADMIN){
                    finalResult = [SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND Profile.Name LIKE 'AF%' ORDER BY Name];
                }
            }

            if(qobj.blankInclude != null && qobj.blankInclude){
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            }

            for(User eachUser : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUser.Id+'',eachUser.Name+' ('+eachUser.Profile.Name+')'+'',eachUser.Id+''));
            }

        }catch (Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedByUserByTeam(ModelExtensions.QueryPickListObj qobj){
        System.debug('qobj::'+qobj);

        Map<String,User_Mirror_Management__c> nHTLCustomSettingByMirrorUserRCCode =  CustomSettingUtil.getMirrorSettingByMirrorUserRcCode();
        Map<String,User_Mirror_Management__c> nHTLCustomSettingByUserRCCode =  CustomSettingUtil.getMirrorSettingByUserRcCode();

        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();

        try{
            List<User> finalResult = new List<User>();

            if(qobj.extra!=null){
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            }
            
            if(qobj.scope != null && qobj.scope != GlobalConstants.CBS_ADMIN){

                if(nHTLCustomSettingByMirrorUserRCCode.containsKey(qobj.scope) && qobj.isActive == true){
                    User_Mirror_Management__c nhtlManage = nHTLCustomSettingByMirrorUserRCCode.get(qobj.scope);
                    User nhtl = [SELECT Id, Name, Profile.Name FROM User WHERE Employee_Id__c =: nhtlManage.Employee_ID__c];
                    resp.records.add(new ModelExtensions.PicklistByFilterKey(nhtl.Id+'',nhtl.Name+' ('+nhtl.Profile.Name+')',nhtl.Name+''));
                }

                if(qobj.isActive != null){
                    finalResult = [SELECT Id, Profile.Name, Name FROM User WHERE RC_Code__c =: qobj.scope AND IsActive =: qobj.IsActive];
                }else{
                    finalResult = [SELECT Id, Profile.Name, Name FROM User WHERE RC_Code__c =: qobj.scope];
                }
            }else if(qobj.scope != null && qobj.scope == GlobalConstants.CBS_ADMIN){
                finalResult = [SELECT Id, Profile.Name, Name FROM User WHERE Profile.Name =: qobj.scope];
            }else if(qobj.rccodes != null){
                String rcCodesStringForQuery = qobj.rccodes.replaceAll('\\s+','').substringBetween('[',']');
                Set<String> rcCodesForQuery = new Set<String>(rcCodesStringForQuery.split(','));

                if(qobj.isActive != null){
                    finalResult = [SELECT Id, Profile.Name, Name FROM User WHERE RC_Code__c IN: rcCodesForQuery AND IsActive =: qobj.isActive];
                }else{
                    finalResult = [SELECT Id, Profile.Name, Name FROM User WHERE RC_Code__c IN: rcCodesForQuery];
                }

                
            }

            for(User eachUser : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUser.Id+'',eachUser.Name+' ('+eachUser.Profile.Name+')',eachUser.Name+''));
            }

        }catch (Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // Same NH level
    // Want to add more filter about only AH
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedBy(ModelExtensions.QueryPickListObj qobj) {
        System.debug('qobj::'+qobj);
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        System.debug(currentUser);


        try {
            List<User> finalResult = new List<User>();
            User thisUser;
            if(qobj.scope != null){
                if(qobj.subScope == 'AHLevel'){
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRoleId = :qobj.scope LIMIT 1];
                }else if(qobj.subScope == 'AHLevelServiceRM'){
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRoleId = :qobj.scope LIMIT 1];
                }else{
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRole.ParentRoleId = :qobj.scope LIMIT 1];
                }
            }else{
                thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE Id = :currentUser.Id LIMIT 1];
            }
            String roleIdQueryString = thisUser.UserRole.ParentRoleId;
            if(qobj.subScope == 'TMLevel' || qobj.subScope == 'TMLevelServiceRM'){
                roleIdQueryString = thisUser.UserRoleId;
            }

            //got ah level or all tm level
            List<User> userSameLevelList;
            if(qobj.subScope == 'ServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND UserRole.ParentRoleId =\''+roleIdQueryString+'\'');
            }else if(qobj.subScope == 'AHLevelServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND UserRole.ParentRoleId =\''+roleIdQueryString+'\'');
            }else if(qobj.subScope == 'AHLevel'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRoleId '+' =\''+roleIdQueryString+'\' OR UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }else if(qobj.subScope == 'TMLevelServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }else{
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRoleId '+' =\''+roleIdQueryString+'\' OR UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }
            if(qobj.selfInclude==null){
                finalResult.addAll(userSameLevelList);
            }

            if(qobj.extra!=null){
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            }
            for(User eachUser : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUser.Id+'',eachUser.Name+' ('+eachUser.Profile.Name+')'+'',eachUser.Profile.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.AccountBottomUpSumResponse queryAccountBottomUpSum(ModelExtensions.QueryPickListObj qobj){
        ModelExtensions.AccountBottomUpSumResponse resp = new ModelExtensions.AccountBottomUpSumResponse();
        List<Bottom_Up_Annualized__c> bottomUpAccounts = new List<Bottom_Up_Annualized__c>(); 

        if(qobj.bulkQueueId != null){
            List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
            bulkAssignList = [SELECT Id, CIS_Id__c FROM Bulk_Assignment__c WHERE BulkAssignmentQueue__c =: qobj.bulkQueueId];
            qobj.accIds = new List<String>();

            for(Bulk_Assignment__c eachBulk : bulkAssignList){
                qobj.accIds.add(eachBulk.CIS_Id__c);
            }
        }

        bottomUpAccounts = [SELECT Id, CIS_Id__c, Total_Transaction_Fee_Bottom_Up__c, Total_Main_Operating_Bank_Bottom_Up__c, Total_Deal_Base_Fee_Bottom_Up__c FROM Bottom_Up_Annualized__c WHERE CIS_Id__c IN: qobj.accIds];
        
        try{
            Decimal totalTransActionFee = 0;
            Decimal totalMainOperatingBank = 0;
            Decimal totalDealBaseFee = 0;
            Decimal totalBottomUp = 0;
            if(!bottomUpAccounts.isEmpty()){
                for(Bottom_Up_Annualized__c eachBottomUp : bottomUpAccounts){
                    totalTransActionFee += eachBottomUp.Total_Transaction_Fee_Bottom_Up__c;
                    totalMainOperatingBank += eachBottomUp.Total_Main_Operating_Bank_Bottom_Up__c;
                    totalDealBaseFee += eachBottomUp.Total_Deal_Base_Fee_Bottom_Up__c;
                }
                totalBottomUp = totalTransActionFee+totalMainOperatingBank+totalDealBaseFee;
            }
            resp.records.add(new ModelExtensions.AccountBottomUpSum(totalTransActionFee,totalMainOperatingBank,totalDealBaseFee,totalBottomUp));
            resp.success = true;


        } catch(Exception e){
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        System.debug('resp : '+resp);
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.SavingResponse saveBulkAssignment(SME_BulkAssignment_Model.SavingRequest svobj) {
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        System.debug('saveBulkAssignment::svobj::'+svobj);
        User currentUser = checkMirrorUser();
        System.debug('aaaa');
        try {
            List<Bulk_Assignment__c> bulkAssignmentSelectedList = new List<Bulk_Assignment__c>();
            Boolean confirmValid = true;
            String bulkAssignmentUserId;
            String ownership;
            String portPool;
            String assignmentOwner;
            String currentOwner;
            String assignedTeamName = '-';
            String serviceRM;
            String temporaryRM;
            String SMETemporaryCustomer = null;
            User userData = new User();
            if(svobj.contx=='SAVE_BULK'){
                System.debug('Save Bulk');
                //referOut
                List<Bulk_Assignment__c> finalList = new List<Bulk_Assignment__c>();
                bulkAssignmentUserId = (svobj.selectName!=null && svobj.selectName.selectedByRMName!=null)?svobj.selectName.selectedByRMName:currentUser.Id;
                portPool = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null)?svobj.selectName.portPoolpanel:'Port';
                serviceRM = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null)?svobj.selectName.serviceRMpanel:null;
                temporaryRM = (svobj.selectName!=null && svobj.selectName.temporaryRMpanel!=null)?svobj.selectName.temporaryRMpanel:null;
                userData = Database.query('SELECT Id,Name,RC_Code__c,Profile.Name FROM User WHERE IsActive=true AND Id = \''+ bulkAssignmentUserId + '\'');

                System.debug('bulkAssignmentUserId :'+bulkAssignmentUserId);
                System.debug('portPool :'+portPool);
                System.debug('svobj.fromAF :'+ svobj.fromAF);

                if(userData!=null && bulkAssignmentUserId!=null && bulkAssignmentUserId != '' && portPool!=null && portPool != ''){
                    
                    // Create Queue
                    Bulk_Assignment_Queue__c bulkAssignmentQueue = new Bulk_Assignment_Queue__c();
                    bulkAssignmentQueue.StartTime__c = System.now();
                    bulkAssignmentQueue.Status__c = 'Create';
                    insert bulkAssignmentQueue;

                    if(confirmValid && svobj.fromCBS == null && svobj.fromAF == null){
                         System.debug('is SME Bulk');
                        currentOwner = bulkAssignmentUserId;
                        if(userData.Profile.Name == 'SME-RM' && svobj.gridName == 'reAssignPermanenceGrid'){
                            ownership = 'Permanent';
                            portPool = 'Port';
                            assignmentOwner = bulkAssignmentUserId;
                            currentOwner = bulkAssignmentUserId;
                            serviceRM = null;
                            temporaryRM = null;
                            SMETemporaryCustomer = null;
                        }else if(svobj.gridName == 'reAssignTemporaryGrid'){
                            ownership = 'Temporary';
                            portPool = 'Pool';
                            SMETemporaryCustomer = bulkAssignmentUserId;
                            assignmentOwner = null;
                            currentOwner = null;
                            serviceRM = null;
                            temporaryRM = null;
                        }else{
                            if(portPool == 'Port'){
                                ownership = 'Permanent';
                                assignmentOwner = bulkAssignmentUserId;
                            }else{
                                if(serviceRM != null){
                                    ownership = 'Permanent';
                                    assignmentOwner = bulkAssignmentUserId;
                                }else if(temporaryRM != null){
                                    ownership = 'Temporary';
                                    assignmentOwner = temporaryRM;
                                }else{
                                    ownership = 'Permanent';
                                    assignmentOwner = bulkAssignmentUserId;
                                }
                            }
                        }
                        for(String eachCISId : svobj.bulkCISlist){
                            Bulk_Assignment__c tempBulkAssignment = new Bulk_Assignment__c();
                            tempBulkAssignment.Ownership__c = ownership;
                            tempBulkAssignment.Port_Pool__c = portPool;
                            tempBulkAssignment.AssignmentOwner__c = assignmentOwner;
                            tempBulkAssignment.Permanent_Owner__c = currentOwner;
                            tempBulkAssignment.Service_RM__c = serviceRM;
                            tempBulkAssignment.CIS_ID__c = eachCISId;
                            tempBulkAssignment.Status__c = 'New';
                            tempBulkAssignment.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
                            tempBulkAssignment.Process__c = true;
                            tempBulkAssignment.SME_Temporary_Customer__c = SMETemporaryCustomer;
                            tempBulkAssignment.Created_Source__c = 'BulkSME';
                            finalList.add(tempBulkAssignment);
                        }
                        System.debug('finalList::'+finalList);
                        insert finalList;

                        Bulk_Assignment_Queue__c bulkAssignmentQueueUpdate = new Bulk_Assignment_Queue__c(Id=bulkAssignmentQueue.Id);
                        bulkAssignmentQueueUpdate.Status__c = 'Execute';
                        update bulkAssignmentQueueUpdate;
                    }else if(confirmValid && svobj.fromAF == null  && svobj.fromCBS!=null  && svobj.fromCBS ){
                        System.debug('is CBS Bulk');
                        Map<Id,Team_Structure__c> cbsTeamStructure = new Map<Id,Team_Structure__c>([SELECT Id, Name, RC_Code__c FROM Team_Structure__c WHERE Segment__c IN (:GlobalConstants.SEGMENT_CB,:GlobalConstants.SEGMENT_MB)]);
                        Map<String,Team_Structure__c> cbsTeamStructureMapByRC = User_Service.getAllTeamStructureMapByRCCBS();


                        bulkAssignmentUserId = svobj.selectName.selectedByUserId;
                        if(bulkAssignmentUserId == GlobalConstants.CBS_ADMIN){
                            bulkAssignmentUserId = String.valueOf([SELECT Id FROM User WHERE Profile.Name =: GlobalConstants.CBS_ADMIN LIMIT 1].Id);
                        }
                        userData = Database.query('SELECT Id,Name,RC_Code__c,Profile.Name FROM User WHERE IsActive=true AND Id = \''+ bulkAssignmentUserId + '\'');
                        ownership = 'Permanent';
                        portPool = 'Port';
                        assignmentOwner = bulkAssignmentUserId;
                        currentOwner = bulkAssignmentUserId;

                        System.debug('assigned team : '+svobj.selectName.selectedByTeamRCCode);

                        if(svobj.selectName.selectedByTeamRCCode != null){
                            if(svobj.selectName.selectedByTeamRCCode == GlobalConstants.CBS_ADMIN){
                                assignedTeamName = GlobalConstants.CBS_ADMIN;
                            }else{
                                Id teamId = Id.valueOf(svobj.selectName.selectedByTeamRCCode);
                                assignedTeamName = cbsTeamStructure.get(teamId).Name;
                            }
                            
                        }else{
                            System.debug('user data : '+userData);
                            assignedTeamName = cbsTeamStructureMapByRC.get(userData.RC_Code__c).Name;
                        }

                        
                        Map<Id,Customer_Ownership_Request__c> ongoingMap = new Map<Id,Customer_Ownership_Request__c>();
                        ongoingMap = new Map<Id,Customer_Ownership_Request__c>([SELECT Id, CIS_ID__c, CIS_ID_Text__c, Approval_Status__c FROM Customer_Ownership_Request__c WHERE CIS_Id__c IN: svobj.bulkCISlist AND Approval_Status__c =: GlobalConstants.APPROVAL_IN_PROGRESS]);


                        if(!ongoingMap.isEmpty()){
                            List<ProcessInstanceWorkitem> ongoingInApprovalList = new List<ProcessInstanceWorkitem>();
                            ongoingInApprovalList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: ongoingMap.keySet()];

                            if(!ongoingInApprovalList.isEmpty()){
                                List<Approval.ProcessWorkitemRequest> workItemRequestList = new List<Approval.ProcessWorkitemRequest>();

                                for(ProcessInstanceWorkitem eachWorkItem : ongoingInApprovalList){
                                    Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
                                    workItemRequest.setComments('Rejected because customer owner was changed by Bulk Assignment');
                                    workItemRequest.setAction('Reject');
                                    workItemRequest.setWorkitemId(eachWorkItem.Id);
                                    workItemRequestList.add(workItemRequest);
                                }

                                if(!workItemRequestList.isEmpty()){
                                    Approval.ProcessResult[] result =  Approval.process(workItemRequestList);
                                }
                            }
                        }
                        
                        Map<Id,Account> accountMapOfSelectedCIS = new Map<Id,Account>([SELECT Id, Current_Owner_Extension__r.User__c FROM Account WHERE Id IN: svobj.bulkCISlist]);
                        

                        Bulk_Assignment_Queue__c bulkAssignmentQueueUpdate = new Bulk_Assignment_Queue__c(Id=bulkAssignmentQueue.Id);
                        
                        if(currentUser.Profile.Name == GlobalConstants.CBS_ADMIN){
                            for(String eachCISId : svobj.bulkCISlist){
                                Bulk_Assignment__c tempBulkAssignment = new Bulk_Assignment__c();
                                tempBulkAssignment.Ownership__c = ownership;
                                tempBulkAssignment.Port_Pool__c = portPool;
                                tempBulkAssignment.AssignmentOwner__c = assignmentOwner;
                                tempBulkAssignment.Assigned_Owner_Team_Name__c = assignedTeamName;
                                tempBulkAssignment.Permanent_Owner__c = currentOwner;
                                tempBulkAssignment.CurrentOwner__c =  accountMapOfSelectedCIS.get(eachCISId).Current_Owner_Extension__r.User__c;
                                tempBulkAssignment.CIS_ID__c = eachCISId;
                                tempBulkAssignment.Status__c = GlobalConstants.STATUS_NEW;
                                tempBulkAssignment.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
                                tempBulkAssignment.Created_Source__c = 'BulkCBS';
                                tempBulkAssignment.Process__c = true;
                                finalList.add(tempBulkAssignment);
                            }
                            System.debug('finalList::'+finalList);
                            insert finalList;

                            bulkAssignmentQueueUpdate.Status__c = 'Execute';
                            update bulkAssignmentQueueUpdate;
                        }else if(svobj.gridName == 'reAssignCBSAdminGrid' || svobj.gridName == 'reAssignPermanenceGrid'){
                            bulkAssignmentQueueUpdate.CBS_Admin_To_Approve__c = true;
                            bulkAssignmentQueueUpdate.Request_Reason_Picklist__c = svobj.selectName.requestReason;
                            bulkAssignmentQueueUpdate.Request_Reason_Text__c = (svobj.selectName.requestReasonText == null)?'':svobj.selectName.requestReasonText;
                            update bulkAssignmentQueueUpdate;

                            List<Bulk_Assignment_Sale_Target__c> listofBulkSales = new List<Bulk_Assignment_Sale_Target__c>();

                            if(svobj.salesTargets != null){
                                for(SME_BulkAssignment_Model.SalesTarget eachSalesTarget : svobj.salesTargets){
                                    Bulk_Assignment_Sale_Target__c tempBulkSales = new Bulk_Assignment_Sale_Target__c();
                                    tempBulkSales.Bulk_Assignment_Queue__c = bulkAssignmentQueueUpdate.Id;
                                    tempBulkSales.Sales_Name__c = eachSalesTarget.salesTargetId;



                                    if(eachSalesTarget.transactionFeeNewTarget != ''){
                                        tempBulkSales.Transaction_Fee_New_Target__c = Decimal.valueOf(eachSalesTarget.transactionFeeNewTarget);
                                    }else{
                                        tempBulkSales.Transaction_Fee_New_Target__c = null;
                                    }

                                    if(eachSalesTarget.mainOperatingBankNewTarget != ''){
                                        tempBulkSales.Main_Operating_Bank_New_Target__c = Decimal.valueOf(eachSalesTarget.mainOperatingBankNewTarget);
                                    }else{
                                        tempBulkSales.Main_Operating_Bank_New_Target__c = null;
                                    }
                                    
                                    if(eachSalesTarget.dealBaseFeeNewTarget != ''){
                                        tempBulkSales.Deal_Base_Fee_New_Target__c = Decimal.valueOf(eachSalesTarget.dealBaseFeeNewTarget);
                                    }else{
                                        tempBulkSales.Deal_Base_Fee_New_Target__c = null;
                                    }
                                    
                                    
                                    listofBulkSales.add(tempBulkSales);
                                }
                            }

                            for(String eachCISId : svobj.bulkCISlist){
                                Bulk_Assignment__c tempBulkAssignment = new Bulk_Assignment__c();
                                tempBulkAssignment.Created_Source__c = 'BulkCBS';
                                tempBulkAssignment.Ownership__c = ownership;
                                tempBulkAssignment.Port_Pool__c = portPool;
                                tempBulkAssignment.AssignmentOwner__c = assignmentOwner;
                                tempBulkAssignment.Assigned_Owner_Team_Name__c = assignedTeamName;
                                tempBulkAssignment.Permanent_Owner__c = currentOwner;
                                tempBulkAssignment.CurrentOwner__c =  accountMapOfSelectedCIS.get(eachCISId).Current_Owner_Extension__r.User__c;
                                tempBulkAssignment.CIS_ID__c = eachCISId;
                                tempBulkAssignment.Status__c = GlobalConstants.STATUS_NEW;
                                tempBulkAssignment.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
                                finalList.add(tempBulkAssignment);
                            }
                            insert listOfBulkSales;
                            insert finalList;
                        }
                        
                    }else if(confirmValid && svobj.fromCBS == null && svobj.fromAF !=null && svobj.fromAF){
                        System.debug('is AF Bulk');
                        List<Account> accountList = [SELECT Id,CIS__c,AF_Owner_ID_Formula__c ,Owner.Profile.Name FROM Account WHERE ID  =:svobj.bulkCISlist];
                        Map<Id,Account> accountMap = new Map<ID,Account>();
                        for(Account eachAccount : accountList){
                            accountMap.put(eachAccount.ID ,eachAccount);
                        }

                        for(String eachCISId : svobj.bulkCISlist){
                            
                            if(accountMap.containsKey(eachCISId)){
                                Bulk_Assignment__c tempBulkAssignment = new Bulk_Assignment__c();
                                Account accountRecord = accountMap.get(eachCISId);
                                String portPoolFlag = '';
                                Boolean port2Flag = false;
                                if(portPool == 'Port'){
                                    portPoolFlag = GlobalConstants.PORT;
                                    port2Flag = false;
                                }else if(portPool == 'Port2'){
                                    portPoolFlag = GlobalConstants.PORT;
                                    port2Flag = true;
                                }else if(portPool == 'Pool'){
                                    portPoolFlag = GlobalConstants.POOL;
                                    port2Flag = false;
                                }

                                if(GlobalConstants.PROFILE_AF_SET.contains(accountRecord.Owner.Profile.Name) || accountRecord.Owner.Profile.Name == GlobalConstants.RBS_ADMIN ){
                                    tempBulkAssignment.AssignmentOwner__c = bulkAssignmentUserId;
                                    tempBulkAssignment.Permanent_Owner__c = bulkAssignmentUserId;
                                    tempBulkAssignment.Port_Pool__c = portPoolFlag;
                                    tempBulkAssignment.AF_Port2__c = port2Flag;
                                }else{
                                    tempBulkAssignment.Assignment_Dual_Owner__c = bulkAssignmentUserId;
                                    tempBulkAssignment.Port_Pool_Dual_RM__c = portPoolFlag;
                                    tempBulkAssignment.AF_Port2__c = port2Flag;
                                }
                                tempBulkAssignment.CurrentOwner__c = accountRecord.AF_Owner_ID_Formula__c;
                                tempBulkAssignment.Created_Source__c = 'BulkAF';
                                tempBulkAssignment.CIS_ID__c = accountRecord.Id;
                                tempBulkAssignment.Status__c = 'New';
                                tempBulkAssignment.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
                                tempBulkAssignment.Process__c = true;
                                finalList.add(tempBulkAssignment);
                            }
                        }

                        insert finalList;

                        Bulk_Assignment_Queue__c bulkAssignmentQueueUpdate = new Bulk_Assignment_Queue__c(Id=bulkAssignmentQueue.Id);
                        bulkAssignmentQueueUpdate.Status__c = 'Execute';
                        update bulkAssignmentQueueUpdate;
                    }
                }else{
                    confirmValid = false;
                }
            }
            if(!confirmValid){
                resp.success = false;
                resp.duplicate = true;
                resp.errorMessage = Label.Cannotprocessyourrequest;
            }
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.SavingResponse handleBulkApproval(SME_BulkAssignment_Model.SavingRequest svobj){
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        try{    
            List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
            bulkAssignList = [SELECT Id,Status__c,BulkAssignmentQueue__c,BulkAssignmentQueue__r.Request_Reason_Picklist__c,Rejected_Reason__c,Rejected_Reason_Text__c FROM Bulk_Assignment__c WHERE Id IN: svobj.approvalIdList];

            if(bulkAssignList.get(0).BulkAssignmentQueue__r.Request_Reason_Picklist__c != GlobalConstants.REQUEST_REASON_OTHERS){
                Set<Id> bulkQueueIds = new Set<Id>();
                for(Bulk_Assignment__c eachBulk : bulkAssignList){
                    bulkQueueIds.add(eachBulk.BulkAssignmentQueue__c);
                }
                bulkAssignList = [SELECT Id,Status__c,BulkAssignmentQueue__c,BulkAssignmentQueue__r.Request_Reason_Picklist__c,Rejected_Reason__c,Rejected_Reason_Text__c FROM Bulk_Assignment__c WHERE BulkAssignmentQueue__c IN: bulkQueueIds];
            }

            for(Bulk_Assignment__c eachBulk : bulkAssignList){
                if(eachBulk.Status__c != GlobalConstants.WAITING_FOR_APPROVAL){
                    resp.success = false;
                    resp.duplicate = true;
                    resp.errorMessage = Label.Cannotprocessyourrequest;
                    return resp;
                }
            }

            for(Bulk_Assignment__c eachBulk : bulkAssignList){
                eachBulk.Status__c = GlobalConstants.PROCESSING;
                if(svobj.contx == 'REJECT'){
                    eachBulk.Rejected_Reason__c = svobj.selectName.rejectReason;
                    eachBulk.Rejected_Reason_Text__c = svobj.selectName.rejectReasonText;
                }        
            }

            update bulkAssignList;

            List<ProcessInstanceWorkitem> pendingBulkToApproveList = new List<ProcessInstanceWorkitem>();
            pendingBulkToApproveList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: svobj.approvalIdList];
            
            if(!pendingBulkToApproveList.isEmpty()){
                String pendingBulkToSendToFuture = JSON.serialize(pendingBulkToApproveList);
                ApprovalProcessResult_Service.processWorkItems(pendingBulkToSendToFuture,svobj.contx);
            }
            resp.success = true;
            return resp;
        }catch(Exception e){
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
    }

    public static User checkMirrorUser(){
        User currentUser = [SELECT Id,Name,Profile.Name,UserRoleId,RC_Code__c,Employee_ID__c,AH_RC_Code__c,Segment__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('currentUser::'+currentUser);
        if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,currentUser) || Account_Util.isProfile(GlobalConstants.SYSTEM_ADMIN,currentUser) || Account_Util.isProfile('Solar',currentUser)){
            String mirrorUserId = Label.BulkAssign_MirrorUser;
            System.debug('mirrorUserId::'+mirrorUserId);
            if(mirrorUserId != null && mirrorUserId != '' && mirrorUserId != '0'){
                User mirrorUser;
                try{
                    mirrorUser = [SELECT Id,Profile.Name,UserRoleId,RC_Code__c,Employee_ID__c,AH_RC_Code__c,Segment__c FROM User WHERE Id = :mirrorUserId LIMIT 1];
                }catch(Exception e){
                    System.debug('Exception::'+e.getMessage());
                }
                if(mirrorUser != null && mirrorUser.Id != null){
                    currentUser = mirrorUser;
                }
            }
        }
        System.debug('currentUser::2::'+currentUser);
        return currentUser;
    }

    public String getSelectedResource(){
        User currentUser = checkMirrorUser();

        String subfix = '';
        if(Account_Util.isProfile(GlobalConstants.SME_TM,currentUser)){
            subfix = '_tm';
        }else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUser) || Account_Util.isProfile(GlobalConstants.OT_AH_SALES,currentUser)){
            subfix = '_ah';
        }else if(Account_Util.isProfile(GlobalConstants.SME_NH,currentUser) || Account_Util.isProfile(GlobalConstants.OT_NH_SALES,currentUser) ){
            
            if(nhActAsTL == true){
                rcCodes = getrcCodes();
                if(rcCodes.size() == 1){
                    subfix = '_cbs_tl';
                }else{
                    subfix = '_cbs_nh_tl';
                }
            }else{
                subfix = '_nh';
            }
            
        }else if(Account_Util.isProfile(GlobalConstants.CBS_TL,currentUser)){
            rcCodes = getrcCodes();
            
            if(rcCodes.size() == 1){
                subfix = '_cbs_tl';
            }else{
                subfix = '_cbs_nh_tl';
            }
        }else if(Account_Util.isProfile(GlobalConstants.CBS_ADMIN,currentUser)){
            subfix = '_cbs_admin';
        }else if(Account_Util.isProfile(GlobalConstants.AF_NH,currentUser)){
            subfix = '_af_nh';
        }else if(Account_Util.isProfile(GlobalConstants.AF_AH,currentUser)){
            subfix = '_af_ah';
        }else if(Account_Util.isProfile(GlobalConstants.AF_TM,currentUser)){
            subfix = '_af_tm';
        }else if(Account_Util.isProfile(GlobalConstants.RBS_ADMIN,currentUser)){
            subfix = '_rbs_admin';
        }
        return staticPrefix + subfix;
    }

    public Set<String> getrcCodes(){
        User currentUser = checkMirrorUser();

        if(Account_Util.isProfile(GlobalConstants.SME_NH,currentUser)){
            if(nhActAsTL == true){
                List<User> userList = new List<User>();
                Set<String> cbsSegment = new Set<String>{'CB','MB'};
                userList = [SELECT Id, RC_Code__c FROM User WHERE Manager.Id =: currentUser.Id AND Segment__c IN: cbsSegment];

                String tlRCCode= nHTLCustomSettingByUserRCCode.get(currentUser.RC_Code__c).Mirror_Value__c;
                
                rcCodes = new Set<String>();
                rcCodes.add(tlRCCode);
                
                for(User eachUser : userList){
                    rcCodes.add(eachUser.RC_Code__c);
                }
            }
        }else if(Account_Util.isProfile(GlobalConstants.CBS_TL,currentUser)){
            List<User> userList = new List<User>();
            userList = [SELECT Id, RC_Code__c FROM User WHERE Manager.RC_Code__c =: currentUser.RC_Code__c AND Manager.Profile.Name =: GlobalConstants.CBS_TL];

            rcCodes = new Set<String>();
            rcCodes.add(currentUser.RC_Code__c);
            
            for(User eachUser : userList){
                rcCodes.add(eachUser.RC_Code__c);
            }
        }  
            
        return rcCodes;

    }

    public String getSelectedCountFields(){
        return 'Id,RM_Name__c,Team__c,Final_Team__c,TM_Name__c,Selected_By_Name__c,Selected_By_Team__c';
    }
    
    //Add more
    public String getReAssignPermanenceFields(){
        return 'Id,SME_Temporary_Customer__r.Name,CIS__c,CIS_Number__c,Owner.Name,NameSurnameTHCompanyName_Formula__c,Credit_Flag__c,Primary_Segment_Code__c,(SELECT District__c,Province__c FROM Addresses__r ORDER BY Name DESC),High_Value__c,Port_Pool__c,Customer_Status__c, Ownership__c,Ownership_Text__c,Current_Owner__c,Current_Owner_Extension__r.Name,Current_Team_Name__r.Name,Permanent_Owner_Extension__r.Name,Permanent_Team_Name__r.Name,Previous_Owner__r.Name,Previous_Owner_Extension__r.Name,Previous_Team_Name__r.Name,Service_RM__r.Name,Customer_s_Business_Code__c,Business_Code_Name_EN__c,Business_Code_Name_TH__c,Status__c,Income_to_Bank_This_Year_Range__c,Income_to_Bank_Last_Year_Range__c,Total_SME_Limit_Range__c,Total_SME_Out_Range__c,Total_SME_Exposure_Range__c,Wallet_Size_Credit_Limit_Range__c,Wallet_Size_Credit_Outstanding_Range__c,Wallet_Size_Credit_Exposure_Range__c,SOW_Exposure__c,Trade_Turn_Range__c,Last_Visited_Date__c,Last_Visited_By__c,Last_Setup_Date__c,Last_Setup_By__c,Owner.RC_Code__c,Owner.AH_RC_Code__c,Owner.NH_RC_Code__c,Permanent_Team_Name__r.RC_Code__c,Permanent_Team_Name__r.AH_RC_Code__c,Permanent_Team_Name__r.NH_RC_Code__c,(SELECT CIS_ID__c,Status__c FROM Bulk_Assignments__r ORDER BY Name DESC LIMIT 1)';
        // Old value -> return 'Id,SME_Temporary_Customer__r.Name,CIS__c,CIS_Number__c,Owner.Name,Name_Report__c,Credit_Flag__c,Primary_Segment_Code__c,(SELECT District__c,Province__c FROM Addresses__r ORDER BY Name DESC),High_Value__c,Port_Pool__c,Customer_Status__c,Ownership__c,Ownership_Text__c,Current_Owner__c,Current_Owner_Extension__r.Name,Current_Team_Name__r.Name,Permanent_Owner_Extension__r.Name,Permanent_Team_Name__r.Name,Previous_Owner__r.Name,Previous_Owner_Extension__c,Previous_Team_Name__r.Name,Service_RM__r.Name,Customer_s_Business_Code__c,Business_Code_Name_EN__c,Business_Code_Name_TH__c,Status__c,Income_To_Bank_Last_1_Month__c,Income_to_Bank_This_Year__c,Income_to_Bank_Last_Year__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,Wallet_Size_Exposure__c,SOW_Exposure__c,Last_Visited_Date__c,Number_of_Visited__c,Last_Visited_By__c,Last_Setup_Date__c,Last_Setup_By__c,Current_Activity__c,Current_Activity_By__c,Owner.RC_Code__c,Owner.AH_RC_Code__c,Owner.NH_RC_Code__c,Permanent_Team_Name__r.RC_Code__c,Permanent_Team_Name__r.AH_RC_Code__c,Permanent_Team_Name__r.NH_RC_Code__c,(SELECT CIS_ID__c,Status__c FROM Bulk_Assignments__r ORDER BY Name DESC LIMIT 1),(SELECT CIS__c,SME_Score__c,Name FROM Behaviour_Scores__r ORDER BY Name)';
    }
    public String getReAssignTemporaryFields(){
        return getReAssignPermanenceFields();
    }
    public String getReAssignOwnedByOtherFields(){
        return getReAssignPermanenceFields();
    }

    public String getReAssignPermanenceFieldsForDes() {
        return 'Id,SME_Temporary_Customer__c,CIS__c,CIS_Number__c,NameSurnameTHCompanyName_Formula__c,Primary_Segment_Code__c,Credit_Flag__c,High_Value__c,Port_Pool__c,Customer_Status__c,Ownership__c,Ownership_Text__c,Current_Owner__c,Current_Owner_Extension__c,Current_Team_Name__c,Permanent_Owner_Extension__c,Permanent_Team_Name__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Service_RM__c,Customer_s_Business_Code__c,Business_Code_Name_EN__c,Business_Code_Name_TH__c,Status__c,Income_to_Bank_This_Year_Range__c,Income_to_Bank_Last_Year_Range__c,Total_SME_Limit_Range__c,Total_SME_Out_Range__c,Total_SME_Exposure_Range__c,Wallet_Size_Credit_Limit_Range__c,Wallet_Size_Credit_Outstanding_Range__c,Wallet_Size_Credit_Exposure_Range__c,SOW_Exposure__c,Trade_Turn_Range__c,Last_Visited_Date__c,Last_Visited_By__c,Last_Setup_Date__c,Last_Setup_By__c';
    }
    public String getReAssignTemporaryFieldsForDes(){
        return getReAssignPermanenceFieldsForDes();
    }
    public String getReAssignOwnedByOtherFieldsForDes(){
        return getReAssignPermanenceFieldsForDes();
    }

    // CBS Fields
    public String getReAssignPermanenceFieldsForCBS(){
        return 'Id,CIS__c,RC_Code__c,CIS_Number__c,Name_Report__c,Primary_Segment_Code__c,Group__c,Sub_Group__c,Current_Owner__c,Current_Owner_Extension__r.Name,Current_Team_Name__r.Name,Current_Team_Name__r.RC_Code__c,Status__c,Previous_Owner__r.Name,Previous_Owner_Extension__c,Previous_Team_Name__r.Name,Income_to_Bank_This_Year__c, Owner.IsActive ,Owner.Profile.Name,(SELECT CIS_ID__c,Status__c FROM Bulk_Assignments__r ORDER BY Name DESC LIMIT 1)';
    }

    public String getReAssignPermanenceFieldsDesForCBS(){
        return 'Id,CIS__c,RC_Code__c,CIS_Number__c,Name_Report__c,Primary_Segment_Code__c,Group__c,Sub_Group__c,Ownership__c,Current_Owner__c,Current_Owner_Extension__c,Current_Team_Name__c,Status__c,Income_to_Bank_This_Year__c';
        
    }

    public String getApprovalBulkAssignFieldsForCBS(){
        return 'Id,Assigned_Owner_Team_Name__c,Status__c,BulkAssignmentQueue__c,BulkAssignmentQueue__r.OwnerId,BulkAssignmentQueue__r.Submit_Date__c,BulkAssignmentQueue__r.Request_Reason_Picklist__c,BulkAssignmentQueue__r.Request_Reason_Text__c,BulkAssignmentQueue__r.Owner.Name,BulkAssignmentQueue__r.Name,BulkAssignmentQueue__r.CBS_Admin_To_Approve__c,Name,CIS_ID__r.CIS__c,CIS_ID__r.CIS_Number__c,CIS_ID__r.Name_Report__c,CIS_Id__r.Primary_Segment_Code__c,CIS_ID__r.Group__c,CIS_ID__r.Sub_Group__c,CIS_ID__r.Owner.Name,CIS_ID__r.Current_Team_Name__r.Name,AssignmentOwner__r.Name,AssignmentOwner__r.Team_Name__c,CIS_ID__r.Status__c,CIS_ID__r.Income_to_Bank_This_Year__c,Rejected_Reason__c,Rejected_Reason_Text__c';
    }

    public String getApprovalBulkAssignFieldsDesForCBS(){
        return 'Id,Status__c,Name,BulkAssignmentQueue__c,CIS_ID__c,Rejected_Reason__c,Rejected_Reason_Text__c';
    }

    public String getSalesTargetFieldsForCBS(){
        return 'Id, Is_Active__c, Year__c, Name__r.Name, Transaction_Fee_Target__c, Transaction_Fee_Bottom_Up_Sum__c, Main_Operating_Bank_Target__c, Main_Operating_Bank_Bottom_Up_Sum__c, Deal_Base_Fee_Target__c, Deal_Base_Fee_Bottom_Up_Sum__c,Total_Bottom_Up__c, Team_Target__r.Team_Name__r.RC_Code__c,Team_Target__r.Transaction_Fee_Team_Target__c, Team_Target__r.Main_Operating_Bank_Team_Target__c, Team_Target__r.Deal_Base_Fee_Team_Target__c, (SELECT Id,Transaction_Fee_New_Target__c,Main_Operating_Bank_New_Target__c,Deal_Base_Fee_New_Target__c FROM Bulk_Assignments_Sales_target__r ORDER BY CreatedDate DESC LIMIT 1)';
    }

    public String getSalesTargetFieldsDesForCBS(){
        return 'Id';
    }

    public String getBulkSalesTargetFieldsForCBS(){
        return 'Id,Processed__c,Bulk_Assignment_Queue__r.OwnerId,Bulk_Assignment_Queue__c,Sales_Name__r.Name__r.Name,Transaction_Fee_New_Target__c,Sales_Name__r.Transaction_Fee_Target__c,Sales_Name__r.Transaction_Fee_Bottom_Up_Sum__c,Main_Operating_Bank_New_Target__c,Sales_Name__r.Main_Operating_Bank_Target__c,Sales_Name__r.Main_Operating_Bank_Bottom_Up_Sum__c,Deal_Base_Fee_New_Target__c,Sales_Name__r.Deal_Base_Fee_Target__c,Sales_Name__r.Deal_Base_Fee_Bottom_Up_Sum__c,Sales_Name__r.Team_Target__r.Transaction_Fee_Team_Target__c,Sales_Name__r.Team_Target__r.Main_Operating_Bank_Team_Target__c,Sales_Name__r.Team_Target__r.Deal_Base_Fee_Team_Target__c';
    }

    public String getBulkSalesTargetFieldsDesForCBS(){
        return 'Id';
    }

    //AF
    public String getBulkAssignFieldsForAF(){
        return 'Id,CIS__c,Owner.Id,Owner.Name,Name,NameSurnameTHCompanyName_Formula__c,Primary_Segment_Code__c,Secondary_Segment_Code__c,Port_Pool__c,AF_Port2__c,AF_Owner_Formula__c,AF_Team_Formula__c,Max_Wealth_Branch__r.Name,RBS_Branch_Closeness__r.Name,AF_Owner_ID_Formula__c,AF_AH_RC_Code__c, AF_Temporary_Customer__c,AF_Temporary_Customer__r.Name,AF_Port_Pool_Formula__c';
    }

    public String getBulkAssignFieldsDescForAF(){
        return 'Id,CIS__c,Name,Primary_Segment_Code__c,Secondary_Segment_Code__c,Port_Pool__c,AF_Port2__c,AF_Owner_Formula__c,AF_Team_Formula__c';
    }

    public Boolean getCheckNHTL(){
        User currentUser = checkMirrorUser();
        if(selectedNHTLChoice == false){
            if(nHTLCustomSettingByUserRCCode.containsKey(currentUser.RC_Code__c)){
                run = false;
                return true;
            }else{
                run = true;
                return false;
            }
        }else{
            return false;
        }
    }

    public void setNHActAsTLFalse(){
        nhActAsTL = false;
        run = true;
        selectedNHTLChoice = true;
    }

    public void setNHActAsTLTrue(){
        nhActAsTL = true;
        run = true;
        selectedNHTLChoice = true;
    }
}