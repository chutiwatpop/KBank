/**
* @author komsan.wi@beryl8.com
* @21/07/2015 create new
* @08/09/2015 move model to new class, remove description field
* @02/12/2015 split query due to offset limitation remove comment
*/
public without sharing class YearEndAssignment_ListView_Controller {
    public Boolean hasError{get;set;}
    public Integer rows{get{return Integer.valueOf(Year_End_Config__c.getOrgDefaults().Page_Size__c);}}
    public User currentUser{get;set;}
    public Year_End_Sales_Structure__c currentUserStruc{get;set;}
    public String userId {get {return currentUserStruc.Id+'';}}
    public String userAhRcCode {get {return (currentUserStruc.Role__c!='AH')?(currentUserStruc.AH_RC_Code__c+''):currentUserStruc.RC_Code__c;}}
    public String userEmpId {get {return currentUserStruc.Employee_Id__c+'';}}
    public String userRcCode {get {return currentUserStruc.RC_Code__c+'';}}
    public String userTeamName {get {return currentUserStruc.Team_Name__c+'';}}
    public String userUserLookup {get {return currentUserStruc.User__c+'';}}
    public Boolean userSubmitFlag {get {return currentUserStruc.Submitted_Flag__c;}}
    public static final String YEAR_REC='Year-End';

    public String userStrucLowerSet {get{
        List<Year_End_Sales_Structure__c> userList = new List<Year_End_Sales_Structure__c>();
        userList = [SELECT Id FROM Year_End_Sales_Structure__c WHERE Manager__r.User__c = :UserInfo.getUserId()];
        Map<String,Year_End_Sales_Structure__c> userMap = new Map<String,Year_End_Sales_Structure__c>(userList);
        return JSON.serialize(userMap.keySet());
    }}

    @TestVisible
    private String staticPrefix = 'extjs_data';
    public YearEndAssignment_ListView_Controller() {

        hasError = false;
        List<Year_End_Sales_Structure__c> userStrucList = [SELECT Id,Team_Name__c,AH_RC_Code__c,Employee_Id__c,RC_Code__c,Role__c,Submitted_Flag__c,Segment__c,User__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId()];
        if(userStrucList.size() == 0){
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This user has no record on Sales Structure object.'));
        }else currentUserStruc = userStrucList.get(0);
    }

    @RemoteAction
    public static ModelExtensions.PicklistResponse queryTeamMaster(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            Year_End_Sales_Structure__c currentUserStruc = [SELECT Id,AH_RC_Code__c,Employee_Id__c,RC_Code__c,Role__c,Team_Name__c,Submitted_Flag__c,Manager__c,Segment__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
            Map<String,ModelExtensions.Picklist> resultMap = new Map<String,ModelExtensions.Picklist>();
            String key;
            String val;
            List<Team_Structure__c> filterTeamList = new List<Team_Structure__c>();
            Boolean hasFilterTeam = false;
            String conditionOtherSegment ='';
            if(qobj.reason==GlobalConstants.REASON_OTHER_SEGMENT || qobj.reason==GlobalConstants.REASON_NATIONALITY){
                if(currentUserStruc.Segment__c =='CB' ||currentUserStruc.Segment__c =='MB'){
                    conditionOtherSegment  = ' AND Segment__c IN (\'ME\',\'SE\') ';
                }else{
                    if(qobj.percentShare !='' && qobj.language !=''){
                        hasFilterTeam = true;
                        filterTeamList = Ownership_Service.selectTeamReferOutSegment(qobj.percentShare.unescapeHtml4(),qobj.language,qobj.province,qobj.businessCode,qobj.saleSize);
                        
                    }else{
                        resp.success = false;
                        resp.records = null;
                        resp.errorMessage = 'percentShare & language have null';
                        return resp;
                    }
                    conditionOtherSegment  = ' AND Segment__c IN (\'CB\',\'MB\') ';
                }
            }else if(qobj.reason == GlobalConstants.REASON_COMPANY_RELATED){

                hasFilterTeam = true;
                List<Year_End_Assignment__c> relateYearEndList = new List<Year_End_Assignment__c>();
                List<Year_End_Sales_Structure__c> saleStructureList = new List<Year_End_Sales_Structure__c>();
                if(currentUserStruc.Segment__c =='CB' || currentUserStruc.Segment__c =='MB'){
                    relateYearEndList = [SELECT Id,TM_RC_Code__c FROM Year_End_Assignment__c where CIS_ID_Unique__c =: qobj.cisRelated AND Segment_Original__c IN('LM','SM','SE','ME','UM') LIMIT 1];
                }else{
                    relateYearEndList = [SELECT Id,TM_RC_Code__c FROM Year_End_Assignment__c where CIS_ID_Unique__c =: qobj.cisRelated AND Segment_Original__c IN ('CB','MB') LIMIT 1];
                }
                if(qobj.cisRelated !=''){
                    if(relateYearEndList.size() > 0){
                        saleStructureList = [SELECT Team__c FROM Year_End_Sales_Structure__c WHERE  RC_Code__c =: relateYearEndList.get(0).TM_RC_Code__c];
                        if(saleStructureList.size() >0){
                            List<ID> teamIDList = new List<ID>();
                            for(Year_End_Sales_Structure__c eachSaleStruc : saleStructureList){
                                teamIDList.add(eachSaleStruc.Team__c);
                            }
                            filterTeamList = [SELECT ID,Name FROM Team_Structure__c WHERE ID=:teamIDList];
                        }else{
                            resp.success = false;
                            resp.records = null;
                            resp.errorMessage = 'ไม่มี ค่า TM_RC_Code__c ใน CIS นี้';
                            return resp;
                        }
                    }else{
                        resp.success = false;
                        resp.records = null;
                        resp.errorMessage = 'ไม่สามารถดำเนินการโอนลูกค้าได้เนื่องจากเลข CIS ไม่มีความสัมพันธ์กับทีมที่ท่าน Released ไป';
                        return resp;
                    }
                }
            }

            for (List<SObject> rlit : Database.query('SELECT Id,Province_Name__c,Segment__c,Name,Team_Structure__c,Team_Structure__r.YearEnd_Team_Name__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c!=null AND RecordType.Name=\''+YearEndAssignment_ListView_Controller.YEAR_REC+'\''+((qobj.segment!=null)?(' AND Segment__c=\''+qobj.segment+'\''):'')+((qobj.province!=null)?(' AND Province_Name__c=\''+qobj.province+'\''):'') + conditionOtherSegment +' ORDER BY Province_Name__c,Segment__c,Team_Structure__r.Name')) {
                for (SObject rit : rlit) {
                    if(qobj.scope=='Province'){
                        val = rit.get('Province_Name__c')+'';
                        key = rit.get('Province_Name__c')+'';
                    }else if(qobj.scope=='Segment'){
                        val = rit.get('Segment__c')+'';
                        key = rit.get('Segment__c')+'';
                    }else if(qobj.scope=='Team'){
                        //check has filter team
                        if(hasFilterTeam){
                            if(filterTeamList.size() >0){
                                for(Team_Structure__c eachTeam : filterTeamList){
                                    if(eachTeam.ID == rit.get('Team_Structure__c')){
                                        val = rit.getSObject('Team_Structure__r').get('YearEnd_Team_Name__c')+'';
                                        key = rit.get('Team_Structure__c')+'';
                                    }
                                }
                            }
                        }else{
                            val = rit.getSObject('Team_Structure__r').get('YearEnd_Team_Name__c')+'';
                            key = rit.get('Team_Structure__c')+'';
                        }
                    }
                    if(!resultMap.containsKey(key))
                        resultMap.put(key,new ModelExtensions.Picklist(key,val));
                }
            }
            
            //if(qobj.scope!='Team') resultMap.put('',new ModelExtensions.Picklist('--','   '));
            resp.records.addAll(resultMap.values());
        } catch (Exception e) { 
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.PicklistResponse queryLocation(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            for (List<SObject> rlit : Database.query('SELECT Id,Area_Name__c FROM Master_Map__c WHERE Type__c=\''+qobj.scope+'\' '+((qobj.extra!=null)?(' AND Depend_On_Object__r.Area_Name__c=\''+qobj.extra+'\''):'')+' ORDER BY Area_Name__c')) {
                for (SObject rit : rlit) {
                    resp.records.add(new ModelExtensions.Picklist(rit.get('Area_Name__c')+'',rit.get('Area_Name__c')+''));
                }
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
    public static ModelExtensions.PicklistResponse querySelectedByTeam(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            //List<UserRole> userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :UserInfo.getUserRoleId()];
            List<Year_End_Sales_Structure__c> userStruc = [SELECT Id,RC_Code__c,Team_Name__c FROM Year_End_Sales_Structure__c WHERE Manager__r.User__c=:UserInfo.getUserId() Order by ID];
            Map<String,String> mappingTeam = new Map<String,String>();
            for(Year_End_Sales_Structure__c eachStruc : userStruc){
                if(eachStruc.RC_Code__c !=null && !mappingTeam.containsKey(eachStruc.RC_Code__c))
                    mappingTeam.put(eachStruc.RC_Code__c,eachStruc.Team_Name__c);
            }
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.Picklist('',Label.YearEnd_ShowAll));
            for(String rcCode : mappingTeam.keySet()){
                resp.records.add(new ModelExtensions.Picklist(rcCode,mappingTeam.get(rcCode)));
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
    public static ModelExtensions.PicklistResponse querySelectedBy(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            List<Year_End_Sales_Structure__c> finalResult = [SELECT Id,User__c,Manager__c,RC_Code__c,Name FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() OR Manager__r.User__c=:UserInfo.getUserId() Order by ID];

            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.Picklist('',qobj.extra));
            for(Year_End_Sales_Structure__c eachUser : finalResult){
                resp.records.add(new ModelExtensions.Picklist(eachUser.Id+'',eachUser.Name+''));
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
    public static ModelExtensions.PicklistResponse querySelectedByAH(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            Year_End_Sales_Structure__c userStrucObj = [SELECT Id,Name,AH_RC_Code__c,Segment__c,Employee_Id__c,RC_Code__c,Role__c,User__c,Submitted_Flag__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
            List<Year_End_Sales_Structure__c> finalResult = Database.query('SELECT Id,Name,Segment__c,Employee_Id__c,RC_Code__c,User__c FROM Year_End_Sales_Structure__c WHERE AH_RC_Code__c = \''+userStrucObj.RC_Code__c+'\'' +((qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):'') + 'Order by ID');
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.Picklist('',qobj.extra));
            if(qobj.selfInclude== true){
                resp.records.add(new ModelExtensions.Picklist(userStrucObj.User__c,userStrucObj.Name));
            }
            for(Year_End_Sales_Structure__c eachUser : finalResult){
                if(qobj.subScope =='User__c'){
                     resp.records.add(new ModelExtensions.Picklist(eachUser.User__c+'',eachUser.Name+''));
                }else if(qobj.subScope !='' && qobj.subScope==eachUser.RC_Code__c){
                     resp.records.add(new ModelExtensions.Picklist(eachUser.Id+'',eachUser.Name+''));
                }else{
                    resp.records.add(new ModelExtensions.Picklist(eachUser.Id+'',eachUser.Name+''));
                }
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
    public static ModelExtensions.PicklistResponse querySelectedByOnlyRM(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            Year_End_Sales_Structure__c userStrucObj = [SELECT Id,AH_RC_Code__c,Segment__c,Employee_Id__c,RC_Code__c,Role__c,Submitted_Flag__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
            String additionString = '';
            if(qobj.selfInclude!=null) additionString += '(';
            additionString += 'Manager__c =\''+((qobj.extra!=null)?qobj.extra:userStrucObj.Id)+'\'';
            if(qobj.selfInclude!=null) additionString += ' OR Id = \''+userStrucObj.Id+'\')';
            List<Year_End_Sales_Structure__c> userList = Database.query('SELECT Id,Segment__c,AH_RC_Code__c,RC_Code__c,Name,User__c FROM Year_End_Sales_Structure__c WHERE ' +additionString +((qobj.isAH==null && qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):'') +' Order by ID');

            if(qobj.selfInclude!=null)
                resp.records.add(new ModelExtensions.Picklist('','All'));
            else resp.records.add(new ModelExtensions.Picklist('','None'));
            for(Year_End_Sales_Structure__c eachUser : userList){
                resp.records.add(new ModelExtensions.Picklist(eachUser.User__c+'',eachUser.Name+''));
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
    public static ModelExtensions.PicklistResponse queryAHSelectedByOnlyRM(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            Year_End_Sales_Structure__c userStrucObj = [SELECT Id,AH_RC_Code__c,Segment__c,Employee_Id__c,RC_Code__c,Role__c,Submitted_Flag__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
            String additionString = '';
            if(qobj.selfInclude!=null) additionString += '(';
            additionString += 'Manager__c =\''+((qobj.extra!=null)?qobj.extra:userStrucObj.Id)+'\'';
            if(qobj.selfInclude!=null) additionString += ' OR Id = \''+userStrucObj.Id+'\')';
            List<Year_End_Sales_Structure__c> userList = Database.query('SELECT Id,Segment__c,AH_RC_Code__c,RC_Code__c,Name,User__c FROM Year_End_Sales_Structure__c WHERE ' +additionString +((qobj.isAH==null && qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):'') +' Order by ID');

            if(qobj.selfInclude!=null)
                resp.records.add(new ModelExtensions.Picklist('','All'));
            else resp.records.add(new ModelExtensions.Picklist('','None'));
            for(Year_End_Sales_Structure__c eachUser : userList){
                resp.records.add(new ModelExtensions.Picklist(eachUser.Id+'',eachUser.Name+''));
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
    public static ModelExtensions.PicklistResponse queryPicklist(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            for (Schema.PicklistEntry rit : Schema.getGlobalDescribe().get('Year_End_Assignment__c').newSObject().getSObjectType().getDescribe().fields.getMap().get(qobj.scope).getDescribe().getPicklistValues()) {
                resp.records.add(new ModelExtensions.Picklist(rit.getValue(),rit.getLabel()));
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
    public static ModelExtensions.PicklistResponse querySegment(ModelExtensions.QueryPickListObj qobj) {
       ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            if(qobj.scope =='SME'){
                if(qobj.subScope == GlobalConstants.REASON_NATIONALITY || qobj.subScope == GlobalConstants.REASON_OTHER_SEGMENT){
                    resp.records.add(new ModelExtensions.Picklist('CBS','CBS'));
                }else if(qobj.subScope == GlobalConstants.REASON_WRONG_AREA || qobj.subScope == GlobalConstants.REASON_OTHER_TEAM){
                    resp.records.add(new ModelExtensions.Picklist('SE','SE'));
                    resp.records.add(new ModelExtensions.Picklist('ME','ME'));
                }
            }else if(qobj.scope=='CBS'){
                resp.records.add(new ModelExtensions.Picklist('SE','SE'));
                resp.records.add(new ModelExtensions.Picklist('ME','ME'));
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
    public static ModelExtensions.PicklistResponse queryReason(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistResponse resp = new ModelExtensions.PicklistResponse();
        try {
            List<YearEndReasonConfig__c> reasonList = [SELECT Reason_EN__c,Reason_TH__c FROM YearEndReasonConfig__c WHERE SegmentType__c =:qobj.scope and IsActive__c = true ORDER BY Order__c asc];
            for(YearEndReasonConfig__c  eachConfig : reasonList){
                if(String.valueOf(UserInfo.getLanguage()) == 'th'){
                    resp.records.add(new ModelExtensions.Picklist(eachConfig.Reason_EN__c,eachConfig.Reason_TH__c));
                }else{
                    resp.records.add(new ModelExtensions.Picklist(eachConfig.Reason_EN__c,eachConfig.Reason_EN__c));
                }
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
    public static ModelExtensions.SavingResponse saveYearEnd(YearEndModel.SavingRequest svobj) {
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        Year_End_Sales_Structure__c currentUserStruc = [SELECT Id,AH_RC_Code__c,Employee_Id__c,RC_Code__c,Role__c,Team_Name__c,Submitted_Flag__c,Manager__c,Segment__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
        Savepoint sp = Database.setSavepoint();
        try {
            List<Year_End_Assignment__c> checkYearList = new List<Year_End_Assignment__c>();
            List<Year_End_Assignment_Selection__c> checkYearSelList = new List<Year_End_Assignment_Selection__c>();
            List<Year_End_Assignment_Selection__c> checkYearSelSameTeamList = new List<Year_End_Assignment_Selection__c>();
            Boolean confirmValid = true;
            String selNameId;
            if(svobj.contx=='REFER_OUT'){
                //referOut
                List<Year_End_Assignment_Selection__c> finalList = new List<Year_End_Assignment_Selection__c>();
                List<Year_End_Ownership_Request__c> currentRequest = new List<Year_End_Ownership_Request__c>();
                List<Year_End_Ownership_Request__c> ownerRequestList = new List<Year_End_Ownership_Request__c>();

               checkYearList = [SELECT Id,TM_RC_Code__c,AH_RC_Code__c,OwnerId FROM Year_End_Assignment__c WHERE Final_Assigned_Next_Year__c = null AND Id IN :svobj.yearlist];

                if(currentUserStruc.Role__c == 'TM' || currentUserStruc.Role__c == 'AH'){
                    checkYearSelSameTeamList = [SELECT Id,Selected_By_Next_Year__r.RC_Code__c,Selected_By_Next_Year__r.AH_RC_Code__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist];
                    for(Year_End_Assignment_Selection__c eachSelection : checkYearSelSameTeamList){
                        if(currentUserStruc.Role__c == 'TM' && eachSelection.Selected_By_Next_Year__r.RC_Code__c == currentUserStruc.RC_Code__c){
                            resp.success = false;
                            resp.duplicate = true;
                            resp.errorMessage = 'your list was not up to date , there was someone picking account before';
                            return resp;
                        }
                        else if(currentUserStruc.Role__c == 'AH' && eachSelection.Selected_By_Next_Year__r.AH_RC_Code__c == currentUserStruc.RC_Code__c){
                            resp.success = false;
                            resp.duplicate = true;
                            resp.errorMessage = 'your list was not up to date , there was someone picking account before';
                            return resp;
                        }
                    }
                }
                Map<String,Year_End_Assignment__c> yearEndMapId;
                Boolean sameAH = false;
                String ahRcCodeMapUserId;
                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size()){
                    if(confirmValid){
                        Year_End_Sales_Structure__c teamObj = new Year_End_Sales_Structure__c();
                        List<Year_End_Sales_Structure__c> teamList = new List<Year_End_Sales_Structure__c>();
                        
                        if(svobj.referOut.referoutTeam!=null){
                            teamList = [SELECT Id,RC_Code__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c,Manager__c,Segment__c,Role__c FROM Year_End_Sales_Structure__c where Team__c =: svobj.referOut.referoutTeam LIMIT 1];
                            if(teamList!=null && teamList.size() > 0){
                                teamObj = teamList.get(0);
                                if(teamObj.AH_RC_Code__c == '' || teamObj.AH_RC_Code__c ==null){
                                    if(teamObj.Submitted_Flag__c){
                                        resp.success = false;
                                        resp.errorMessage = 'Can not Request/Refer out due to destination branch has already submitted.';
                                        return resp;
                                    }
                                }else{
                                    List<Year_End_Sales_Structure__c> ahTeamList = new List<Year_End_Sales_Structure__c>();
                                    ahTeamList =[SELECT Id,RC_Code__c,Segment__c,Team_Name__c,AH_RC_Code__c,Submitted_Flag__c FROM Year_End_Sales_Structure__c where Role__c IN ('AH','TL')  AND RC_Code__c =:teamObj.AH_RC_Code__c LIMIT 1];
                                    if(ahTeamList!=null && ahTeamList.size() > 0){
                                        if(ahTeamList.get(0).Submitted_Flag__c){
                                            resp.success = false;
                                            resp.errorMessage = 'Can not Request/Refer out due to destination branch has already submitted.';
                                            return resp;
                                        }
                                    }
                                }
                            }
                            else{
                                resp.success = false;
                                resp.errorMessage = 'This Team was not belong on Year End Team Structure';
                                return resp;
                            }

                        }

                        //if(teamObj.Submitted_Flag__c){
                        //    resp.success = false;
                        //    resp.errorMessage = 'Can not Request/Refer out due to destination branch has already submitted.';
                        //    return resp;
                        //}
                        String currentAH_RC_Code = '';
                        String targetAH_RC_Code = '';
                        if(currentUserStruc.Role__c == 'AH' || currentUserStruc.Role__c =='TL'){
                            currentAH_RC_Code = currentUserStruc.RC_Code__c;
                        }else{
                            currentAH_RC_Code = currentUserStruc.AH_RC_Code__c;
                        }

                        if(teamObj.Role__c == 'AH' || teamObj.Role__c =='TL'){
                            targetAH_RC_Code = teamObj.RC_Code__c;
                        }else{
                            targetAH_RC_Code = teamObj.AH_RC_Code__c;
                        }

                        if(currentAH_RC_Code==targetAH_RC_Code){
                            sameAH = true;
                        }
                        String currentRequestName;
                        String ahRc;
                        if(svobj.referOut.referoutReason=='Other Team' || svobj.referOut.referoutReason=='Wrong Area' || svobj.referOut.referoutReason==GlobalConstants.REASON_COMPANY_RELATED || svobj.referOut.referoutReason==GlobalConstants.REASON_OTHER_SEGMENT || svobj.referOut.referoutReason==GlobalConstants.REASON_NATIONALITY){
                            currentRequestName = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:currentUserStruc.Id;

                            yearEndMapId = new Map<String,Year_End_Assignment__c>(checkYearList);

                            currentRequest = [SELECT Id,Year_End_Assignment__c,Approval_Status__c FROM Year_End_Ownership_Request__c WHERE Year_End_Assignment__c IN :svobj.yearlist AND Requester__c =:currentRequestName AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC];

                            if(currentUserStruc.RC_Code__c==teamObj.RC_Code__c){
                                resp.success = false;
                                resp.errorMessage = 'Can not Request/Refer out to same Team';
                                return resp;
                            }

                            for(Year_End_Assignment__c eachYearCheck : checkYearList){
                                if(eachYearCheck.TM_RC_Code__c==teamObj.RC_Code__c){
                                    resp.success = false;
                                    resp.errorMessage = 'Can not Request/Refer out to old Team';
                                    return resp;       
                                }
                            }

                            if(currentRequest!=null && currentRequest.size() > 0){
                                resp.success = false;
                                resp.errorMessage = 'You have already make a request to this records';
                                return resp;
                            }
                            if(svobj.referOut.referoutTeam!=null && teamObj!=null ){
                                if((teamObj.Role__c == 'AH' || teamObj.Role__c == 'TL') && teamObj.RC_Code__c !=null){
                                    ahRc = teamObj.RC_Code__c;
                                }else if((teamObj.Role__c == 'RM' || teamObj.Role__c == 'TM') && teamObj.AH_RC_Code__c !=null){
                                    ahRc = teamObj.AH_RC_Code__c;
                                }
                            }
                            if(svobj.referOut.referoutReason=='Other Team' || svobj.referOut.referoutReason=='Wrong Area' || svobj.referOut.referoutReason==GlobalConstants.REASON_COMPANY_RELATED || svobj.referOut.referoutReason==GlobalConstants.REASON_OTHER_SEGMENT){
                                if(teamObj.Team_Name__c == 'เป็นพื้นที่ฝากสาขาไม่มีนโยบายฝากเพิ่มเติม(กรุณาดูแลต่อ)'){
                                    resp.success = false;
                                    resp.errorMessage = 'Please select other team';
                                    return resp;
                                }
                            }
                            List<Year_End_Sales_Structure__c> yearStrucAhList = [SELECT id,RC_Code__c FROM Year_End_Sales_Structure__c WHERE Role__c IN ('AH','TL') AND RC_Code__c =:ahRc];
                            if(yearStrucAhList!=null && yearStrucAhList.size() > 0) ahRcCodeMapUserId = yearStrucAhList.get(0).Id;
                        }
                        List<Id> ownerIdList = new List<Id>();
                        for(Year_End_Assignment__c eachYearCheck : checkYearList){
                             ownerIdList.add(eachYearCheck.OwnerId);
                        }

                        yearEndMapId = new Map<String,Year_End_Assignment__c>(checkYearList);
                        List<Year_End_Sales_Structure__c> ownerYearEndlist = new List<Year_End_Sales_Structure__c>();
                        Map<Id,Year_End_Sales_Structure__c> saleStructureList =new Map<Id,Year_End_Sales_Structure__c>();
                        ownerYearEndlist = [SELECT ID,Role__c,User__c,Manager__c FROM Year_End_Sales_Structure__c WHERE User__c =: ownerIdList ];
                        if(ownerYearEndlist.size() >0){
                            for(Year_End_Sales_Structure__c eachSaleStruc : ownerYearEndlist){
                                saleStructureList.put(eachSaleStruc.User__c,eachSaleStruc);
                            }
                        }
                        //Create Selection
                        for(String eachYearEndId : svobj.yearlist){

                            Id selected_By_Next_Year;
                            Boolean need_Approval;
                            String port_pool;

                            if(svobj.referOut.referoutReason=='Other Team' || svobj.referOut.referoutReason=='Wrong Area'){
                                if(ahRcCodeMapUserId==null){
                                    resp.success = false;
                                    resp.errorMessage = 'Target Team does not have AH';
                                    return resp;
                                }
                                selected_By_Next_Year = teamObj.Id;
                                need_Approval = false;
                                port_pool = GlobalConstants.POOL;
                            }else if(svobj.referOut.referoutReason== GlobalConstants.REASON_OTHER_SEGMENT ||  svobj.referOut.referoutReason== GlobalConstants.REASON_NATIONALITY || svobj.referOut.referoutReason==GlobalConstants.REASON_COMPANY_RELATED){
                                if(ahRcCodeMapUserId==null){
                                    resp.success = false;
                                    resp.errorMessage = 'Target Team does not have AH';
                                    return resp;
                                }
                                
                                if(teamObj.Role__c =='RM'){
                                    selected_By_Next_Year = teamObj.Manager__c;
                                }else if(teamObj.Role__c == 'TM' && (teamObj.Segment__c == 'CB' || teamObj.Segment__c =='MB')){
                                    selected_By_Next_Year = teamObj.Manager__c;
                                }else{
                                    selected_By_Next_Year = teamObj.Id;
                                }
                                need_Approval = true;
                                port_pool = GlobalConstants.PORT;
                            }else{//BAD DEAD
                                if(yearEndMapId.containsKey(eachYearEndId)){
                                    if(saleStructureList.containsKey(yearEndMapId.get(eachYearEndId).OwnerId)){
                                        if(saleStructureList.get(yearEndMapId.get(eachYearEndId).OwnerId).Role__c =='TM'){
                                            selected_By_Next_Year = saleStructureList.get(yearEndMapId.get(eachYearEndId).OwnerId).Id;
                                        }else if(saleStructureList.get(yearEndMapId.get(eachYearEndId).OwnerId).Role__c =='RM'){
                                            selected_By_Next_Year = saleStructureList.get(yearEndMapId.get(eachYearEndId).OwnerId).Manager__c;
                                        }else{
                                            resp.success = false;
                                            resp.errorMessage = 'YearEnd Record Owner is not TM or RM';
                                            return resp;
                                        }
                                    }else{// Edit for incident 19/12/2016  RM Promote to TM  Other Team
                                        selected_By_Next_Year = currentUserStruc.Id;
                                    }
                                }else{
                                    selected_By_Next_Year = currentUserStruc.Id;
                                }
                                need_Approval = false;
                                port_pool = GlobalConstants.POOL;
                            }

                            finalList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out_Reason__c = svobj.referOut.referoutReason,
                                Refer_Out_Segment__c = svobj.referOut.referoutSegment,
                                Language__c = (svobj.referOut.referoutLanguage!=null)?svobj.referOut.referoutLanguage:null,
                                Percent_Shareholder__c = (svobj.referOut.referoutPercentShare!=null)?svobj.referOut.referoutPercentShare.unescapeHtml4():null,
                                Company_Related_Text__c = (svobj.referOut.referoutrelateCIS!=null)?svobj.referOut.referoutrelateCIS:null,
                                Refer_Out_Province__c = svobj.referOut.referoutProvince,
                                Selected_Port_Pool__c = port_pool,
                                Refer_Out_Team__c = (teamObj!=null)?teamObj.Team_Name__c:null,
                                Refer_Out__c = true,
                                Need_Approval__c = need_Approval,
                                Selected_By_Next_Year__c = selected_By_Next_Year//svobj.referOut.referoutTeam
                            ));
                        }

                        insert finalList;
                        //Create YearEnd Ownership_Request
                        if(!sameAH && (svobj.referOut.referoutReason=='Other Team' || svobj.referOut.referoutReason=='Wrong Area' || svobj.referOut.referoutReason==GlobalConstants.REASON_COMPANY_RELATED || svobj.referOut.referoutReason==GlobalConstants.REASON_OTHER_SEGMENT || svobj.referOut.referoutReason==GlobalConstants.REASON_NATIONALITY )){  
                            for(Year_End_Assignment_Selection__c eachYearEndSel : finalList){
                                if(ahRcCodeMapUserId!=null){
                                    ownerRequestList.add(new Year_End_Ownership_Request__c(
                                        Year_End_Assignment__c = eachYearEndSel.Year_End_Assignment__c,
                                        Requester__c = currentRequestName,
                                        Type__c = GlobalConstants.REFER_OUT,
                                        Refer_Out_Reason__c = svobj.referOut.referoutReason,
                                        Refer_Out_From__c = currentUserStruc.Id,
                                        Refer_Out_To__c =  (teamObj.Role__c =='RM' ||(teamObj.Role__c == 'TM' && (teamObj.Segment__c == 'CB' || teamObj.Segment__c =='MB')))?teamObj.Manager__c:teamObj.Id,
                                        Year_End_Assignment_Selection__c = eachYearEndSel.Id,
                                        Requester_AH__c = (currentUserStruc.Role__c == 'TL' || currentUserStruc.Role__c == 'AH')?currentUserStruc.Id:currentUserStruc.Manager__c,
                                        Approver__c = ahRcCodeMapUserId,
                                        Approver_TM_RC_Code__c = teamObj.RC_Code__c,
                                        Approver_AH_RC_Code__c = ahRc,
                                        Requester_Manager_Approve_Flag__c = ((currentUserStruc.Segment__c == 'CB' || currentUserStruc.Segment__c =='MB') && currentUserStruc.Role__c !='TL' )?false:true
                                    ));
                                }else{
                                    resp.success = false;
                                    resp.errorMessage = 'Target Team does not have AH2';
                                    return resp;
                                }
                            }
                            if(ownerRequestList.size() > 0){
                                insert ownerRequestList;
                            }
                        }
                    }
                }else{
                    confirmValid = false;
                }
            }else if(svobj.contx=='SELECTED'){
                List<Year_End_Assignment_Selection__c> selectedList = new List<Year_End_Assignment_Selection__c>();
                selNameId = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:currentUserStruc.Id;

                //need to check TM and AH
                if(currentUserStruc.Role__c == 'TM' || currentUserStruc.Role__c == 'AH'){
                    checkYearSelSameTeamList = [SELECT Id,Selected_By_Next_Year__r.RC_Code__c,Selected_By_Next_Year__r.AH_RC_Code__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist];
                    for(Year_End_Assignment_Selection__c eachSelection : checkYearSelSameTeamList){
                        if(currentUserStruc.Role__c == 'TM' && eachSelection.Selected_By_Next_Year__r.RC_Code__c == currentUserStruc.RC_Code__c){
                            resp.success = false;
                            resp.duplicate = true;
                            resp.errorMessage = 'your list was not up to date , there was someone picking account before';
                            return resp;
                        }
                        else if(currentUserStruc.Role__c == 'AH' && eachSelection.Selected_By_Next_Year__r.AH_RC_Code__c == currentUserStruc.RC_Code__c){
                            resp.success = false;
                            resp.duplicate = true;
                            resp.errorMessage = 'your list was not up to date , there was someone picking account before';
                            return resp;
                        }
                    }
                }
                
                checkYearSelList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist AND Selected_By_Next_Year__c = :selNameId];
                checkYearList = [SELECT Id FROM Year_End_Assignment__c WHERE Final_Assigned_Next_Year__c = null AND Id IN :svobj.yearlist];

                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size() && (checkYearSelList==null || (checkYearSelList!=null && checkYearSelList.size()==0))){
                    
                    if(confirmValid){
                        for(String eachYearEndId : svobj.yearlist){
                            selectedList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out__c = false,
                                Selected_By_Next_Year__c = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:currentUserStruc.Id,
                                Selected_By_SVM_Next_Year__c = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null && svobj.selectName.serviceRMpanel!='')?svobj.selectName.serviceRMpanel:null,
                                Selected_Port_Pool__c = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null && svobj.selectName.portPoolpanel!='')?svobj.selectName.portPoolpanel:'Port'
                            ));
                        }
                        insert selectedList;
                    }
                }else{
                    confirmValid = false;
                }
            }else if(svobj.contx=='CONFIRM'){ // select to port
                List<Year_End_Assignment__c> confirmList = new List<Year_End_Assignment__c>();
                List<Year_End_Assignment_Selection__c> selConfirmList = new List<Year_End_Assignment_Selection__c>();
                selConfirmList = [SELECT Id,Selected_By_Next_Year__c,Year_End_Assignment__c,Refer_Out_Reason__c,Refer_Out_Segment__c,Refer_Out_Team__c,Refer_Out_Amphur__c,Refer_Out_Province__c,Refer_Out_Tumbon__c,Refer_Out__c,Selected_Count__c,Year_End_Assignment__r.Final_Assigned_Next_Year__c,Selected_Port_Pool__c,Selected_By_SVM_Next_Year__c FROM Year_End_Assignment_Selection__c WHERE Id in :svobj.yearlist];

                if(selConfirmList!=null && svobj.yearlist.size()==selConfirmList.size()){
                    for(Year_End_Assignment_Selection__c eachYearEndSel : selConfirmList){

                        if(eachYearEndSel.Selected_Count__c!=1 || eachYearEndSel.Year_End_Assignment__r.Final_Assigned_Next_Year__c!=null){
                            confirmValid = false;
                            break;
                        }
                        confirmList.add(new Year_End_Assignment__c(
                            Id = eachYearEndSel.Year_End_Assignment__c,
                            Final_Assigned_Next_Year__c = eachYearEndSel.Selected_By_Next_Year__c,
                            Refer_Out_Reason__c = eachYearEndSel.Refer_Out_Reason__c,
                            Refer_Out_Segment__c = eachYearEndSel.Refer_Out_Segment__c,
                            Refer_Out_Team__c = eachYearEndSel.Refer_Out_Team__c,
                            Refer_Out_Amphur__c = eachYearEndSel.Refer_Out_Amphur__c,
                            Refer_Out_Province__c = eachYearEndSel.Refer_Out_Province__c,
                            Refer_Out_Tumbon__c = eachYearEndSel.Refer_Out_Tumbon__c,
                            Final_Refer_Out__c = eachYearEndSel.Refer_Out__c,
                            Final_SVM_Next_Year__c = eachYearEndSel.Selected_By_SVM_Next_Year__c,
                            Final_Port_Pool__c = eachYearEndSel.Selected_Port_Pool__c
                        ));
                    }
                    if(confirmValid){
                        update confirmList;
                    }
                }else{confirmValid = false;}
            }else if(svobj.contx=='SUBMITTED'){ //rm,tm Submit
                if(currentUserStruc.Role__c == 'TM'){
                    List<Year_End_Assignment_Selection__c> yealSelListChecking = new List<Year_End_Assignment_Selection__c>();
                    yealSelListChecking = [select Id,Year_End_Assignment__c from Year_End_Assignment_Selection__c where Selected_Count__c > 1 and CreatedBy.RC_Code__c =:currentUserStruc.RC_Code__c];

                    Set<String> countingDuplicate = new Set<String>();
                    for(Year_End_Assignment_Selection__c eachSel : yealSelListChecking){
                        if(!countingDuplicate.contains(eachSel.Year_End_Assignment__c)) 
                            countingDuplicate.add(eachSel.Year_End_Assignment__c);
                        else{
                            resp.success = false;
                            resp.errorMessage = 'มี record ที่ dup อยู่ submit ไม่ได้';
                            Database.rollback(sp);
                            return resp;    
                        }
                    }
                    currentUserStruc.Submitted_Flag__c = true;
                    update currentUserStruc;
                }else{
                    currentUserStruc.Submitted_Flag__c = true;
                    update currentUserStruc;
                }
            }else if(svobj.contx=='SUBMITTED_AH'){ // ah,tl submit
                //Check Have Request
                List<Year_End_Assignment__c> yearEndSelectionToSubmitted = new List<Year_End_Assignment__c>();
                Integer countRemainOwner = [select count() from Year_End_Ownership_Request__c where (Requester__r.AH_RC_Code__c=:currentUserStruc.RC_Code__c OR Approver__c = :currentUserStruc.Id) AND Approval_Status__c = 'Approval In Progress'];
                if(countRemainOwner != 0){
                    resp.success = false;
                    resp.errorMessage = 'มี record ที่รอ approve อยู่ submit ไม่ได้';
                    return resp;
                }
                if(currentUserStruc.Role__c == 'TL'){
                    List<Year_End_Assignment__c> noSelectList = new List<Year_End_Assignment__c>();
                    List<Year_End_Assignment_Selection__c> insertSelectionList = new List<Year_End_Assignment_Selection__c>();
                    List<Year_End_Sales_Structure__c> saleStructureList = new List<Year_End_Sales_Structure__c>();
                    Map<String, Id> userMapByEmpId = new Map<String, Id>();
                    noSelectList = [SELECT Id,Owner_Employee_ID__c FROM Year_End_Assignment__c WHERE Selected_Count__c < 1 AND AH_RC_Code__c =:currentUserStruc.RC_Code__c];
                    
                    if(noSelectList.size() >0){
                        //Create MapUser
                        saleStructureList = [SELECT ID,Employee_Id__c FROM Year_End_Sales_Structure__c];
                        if(saleStructureList !=null && saleStructureList.size() >0){
                            for(Year_End_Sales_Structure__c eachSaleStruc:saleStructureList){
                                userMapByEmpId.put(eachSaleStruc.Employee_Id__c, eachSaleStruc.Id);
                            }
                        }
                        for(Year_End_Assignment__c eachYearEnd : noSelectList){
                            insertSelectionList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEnd.Id,
                                Refer_Out__c = false,
                                Selected_By_Next_Year__c = userMapByEmpId.get(eachYearEnd.Owner_Employee_ID__c),
                                Selected_Port_Pool__c = 'Port'
                            ));
                        }
                        insert insertSelectionList;
                    }
                }

                Integer countPossible = [SELECT count() FROM Year_End_Assignment__c WHERE Selected_Count__c < 1 AND AH_RC_Code__c =:currentUserStruc.RC_Code__c];
                if(countPossible==0){
                    yearEndSelectionToSubmitted = [SELECT Id,Status__c,(SELECT Id,Year_End_Assignment__c,Refer_Out_Reason__c,Refer_Out_Segment__c,Refer_Out_Amphur__c,Refer_Out_Province__c,Refer_Out_Tumbon__c,Refer_Out_Team__c,Refer_Out__c,Selected_By_Next_Year__c,Selected_By_SVM_Next_Year__c,Selected_Port_Pool__c,Language__c,Percent_Shareholder__c,Company_Related_Text__c FROM Year_End_Assignment_Selections__r LIMIT 1) FROM Year_End_Assignment__c WHERE AH_RC_Code__c =:currentUserStruc.RC_Code__c];
                    for(Year_End_Assignment__c eachSelection : yearEndSelectionToSubmitted){
                        if(eachSelection.Year_End_Assignment_Selections__r!=null && eachSelection.Year_End_Assignment_Selections__r.size() > 0){
                            eachSelection.Status__c = GlobalConstants.SUBMITTED;
                            eachSelection.Final_Assigned_Next_Year__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Selected_By_Next_Year__c;
                            eachSelection.Refer_Out_Reason__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Reason__c;
                            eachSelection.Refer_Out_Segment__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Segment__c;
                            eachSelection.Language__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Language__c;
                            eachSelection.Percent_Shareholder__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Percent_Shareholder__c;
                            eachSelection.Company_Related_Text__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Company_Related_Text__c;
                            eachSelection.Refer_Out_Team__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Team__c;
                            eachSelection.Refer_Out_Amphur__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Amphur__c;
                            eachSelection.Refer_Out_Province__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Province__c;
                            eachSelection.Refer_Out_Tumbon__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out_Tumbon__c;
                            eachSelection.Final_Refer_Out__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Refer_Out__c;
                            eachSelection.Final_SVM_Next_Year__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Selected_By_SVM_Next_Year__c;
                            eachSelection.Final_Port_Pool__c = eachSelection.Year_End_Assignment_Selections__r.get(0).Selected_Port_Pool__c;
                        }
                    }
                    if(yearEndSelectionToSubmitted!=null && yearEndSelectionToSubmitted.size() > 0){
                        List<Year_End_Assignment__c> updateYearendList = new List<Year_End_Assignment__c>();
                        Integer count=0;
                        for(Year_End_Assignment__c eachYearendAssign : yearEndSelectionToSubmitted){
                            count++;
                            updateYearendList.add(eachYearendAssign);
                            if(count==5000){
                                 //update Fix incident AH Submit more than 10000 record
                                 updateYearendAssignmentList(JSON.serialize(updateYearendList));
                                 updateYearendList.clear();
                                 count = 0;
                            }
                        }
                        if(updateYearendList.size()>0){
                            update updateYearendList;
                        }
                    }
                    currentUserStruc.Submitted_Flag__c = true;
                    update currentUserStruc;
                }else{
                    resp.success = false;
                    resp.errorMessage = Label.YearEnd_TheListisnotcompleted_cannotsubmit;
                    Database.rollback(sp);
                    return resp;
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
            Database.rollback(sp);
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.SavingResponse deleteYearEndSel(YearEndModel.SavingRequest svobj) {
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        try {
            List<Year_End_Assignment_Selection__c> yearSelList = [SELECT Id,Year_End_Assignment__c,Year_End_Assignment__r.Final_Assigned_Next_Year__c,Need_Approval__c FROM Year_End_Assignment_Selection__c WHERE Id in :svobj.yearlist];
            
            if(svobj.deleteFinalAssign!=null && svobj.deleteFinalAssign){
                List<Year_End_Assignment__c> updateList = new List<Year_End_Assignment__c>();
                for(Year_End_Assignment_Selection__c eachYearSel : yearSelList){
                    updateList.add(new Year_End_Assignment__c(
                        Id = eachYearSel.Year_End_Assignment__c,
                        Final_Refer_Out__c = false,
                        Status__c = GlobalConstants.STATUS_NEW,
                        Final_Assigned_Next_Year__c = null,
                        Refer_Out_Reason__c = null,
                        Refer_Out_Segment__c = null,
                        Refer_Out_Team__c = null,
                        Refer_Out_Amphur__c = null,
                        Refer_Out_Province__c = null,
                        Refer_Out_Tumbon__c = null,
                        Final_SVM_Next_Year__c = null,
                        Final_Port_Pool__c = null
                    ));
                }
                update updateList;
            }else {
                Boolean deleteValid = true;
                if(yearSelList.size() != svobj.yearlist.size()){
                    deleteValid = false;
                    resp.success = false;
                    resp.duplicate = false;
                    resp.errorMessage = Label.Cannotprocessyourrequest;
                }else{
                    Year_End_Sales_Structure__c currentUserStruc = [SELECT Id FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
                    Set<String> rejectSet = new Set<String>();
                    for(Year_End_Assignment_Selection__c eachSel : yearSelList){
                        if(eachSel.Year_End_Assignment__r.Final_Assigned_Next_Year__c!=null){
                            deleteValid = false;
                            resp.success = false;
                            resp.duplicate = false;
                            resp.errorMessage = Label.Cannotprocessyourrequest;
                            break;
                        }
                        //if(eachSel.Need_Approval__c) 
                        rejectSet.add(eachSel.Id);
                    }
                    List<Year_End_Ownership_Request__c> ownerShipList = new List<Year_End_Ownership_Request__c>();
                    ownerShipList = [select id,Approval_Status__c,Requester__c from Year_End_Ownership_Request__c where Year_End_Assignment_Selection__c in :rejectSet];
                    if(ownerShipList!=null && ownerShipList.size() > 0){
                        for(Year_End_Ownership_Request__c eachRequest : ownerShipList){
                            if(eachRequest.Requester__c == currentUserStruc.Id){
                                eachRequest.Approval_Status__c = 'Rejected';
                            }else{
                                eachRequest.Approval_Status__c = 'Recalled';
                            }
                            
                        }
                        update ownerShipList;
                    }
                }
                if(deleteValid){
                    delete yearSelList;
                }
            }
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction // Use by tm,ah,TL
    public static ModelExtensions.SavingResponse changeStatusYearStruc(YearEndModel.SavingRequest svobj) {
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        Savepoint sp = Database.setSavepoint();
        try {
            List<Year_End_Ownership_Request__c> yearReqList = [SELECT Id,CIS_Id__c,Year_End_Assignment__c,Year_End_Assignment__r.Final_Assigned_Next_Year__c,Requester__c,Requester__r.User__c,Requester__r.Employee_Id__c,Requester_TM_RC_Code__c,Requester__r.Manager__r.User__c,Requester_AH_RC_Code__c,Assigned_Port_Pool__c,Service_RM__c,Requester_AH__c,Type__c,Approver_TM_RC_Code__c,Approver_AH_RC_Code__c,Year_End_Assignment_Selection__c,Requester_Manager_Approve_Flag__c,Requester__r.Segment__c,Year_End_Assignment__r.Sales_Size__c,Requester_AH__r.Segment__c,Refer_Out_To__r.Segment__c,Refer_Out_To__r.User__c,Refer_Out_To__r.Employee_Id__c FROM Year_End_Ownership_Request__c WHERE Id in :svobj.yearlist];

            Map<String,String> checkDuplicate = new Map<String,String>();
            for(Year_End_Ownership_Request__c eachYearSel : yearReqList){
                if(!checkDuplicate.containsKey(eachYearSel.CIS_Id__c))
                    checkDuplicate.put(eachYearSel.CIS_Id__c,'');
                else {
                    resp.success = false;
                    resp.duplicate = true;
                    resp.errorMessage = 'ไม่สามารถ '+svobj.approveStatus+' หลาย requester ใน 1 cis ได้';
                    return resp;
                }
            }
            List<Year_End_Assignment__c> updateList = new List<Year_End_Assignment__c>();
            List<Year_End_Assignment_Selection__c> yearEndSelList = new List<Year_End_Assignment_Selection__c>();
            List<Year_End_Assignment_Selection__c> yearEndSelDelList = new List<Year_End_Assignment_Selection__c>();
            
            if(svobj.approveStatus=='Rejected'){
                Set<String> yearSelectionList = new Set<String>();
                for(Year_End_Ownership_Request__c eachYearReq : yearReqList){
                    eachYearReq.Approval_Status__c = 'Rejected';
                    yearSelectionList.add(eachYearReq.Year_End_Assignment_Selection__c);
                    eachYearReq.Year_End_Assignment_Selection__c = null;
                }
                update yearReqList;
                delete [select id from Year_End_Assignment_Selection__c where id in:yearSelectionList];
            }else if(svobj.approveStatus=='Recalled'){
                Set<String> yearSelectionList = new Set<String>();
                for(Year_End_Ownership_Request__c eachYearReq : yearReqList){
                    eachYearReq.Approval_Status__c = 'Recalled';
                    if(eachYearReq.Requester_AH__r.Segment__c == 'CB' || eachYearReq.Requester_AH__r.Segment__c == 'MB'){
                        eachYearReq.Requester_Manager_Approve_Flag__c = false;
                    }
                    yearSelectionList.add(eachYearReq.Year_End_Assignment_Selection__c);
                    eachYearReq.Year_End_Assignment_Selection__c = null;
                }
                update yearReqList;
                delete [select id from Year_End_Assignment_Selection__c where id in:yearSelectionList];
            }else {//Approve
                Set<String> tmRCSet = new Set<String>();
                for(Year_End_Ownership_Request__c eachYearReq : yearReqList){
                    if(eachYearReq.Type__c==GlobalConstants.REFER_OUT && eachYearReq.Approver_AH_RC_Code__c!=null){
                        tmRCSet.add(eachYearReq.Approver_AH_RC_Code__c);
                    }
                }
                Map<String,String> rcMapTM = new Map<String,String>();
                for(Year_End_Sales_Structure__c eachTM : [select id,RC_Code__c,User__c from Year_End_Sales_Structure__c where RC_Code__c in :tmRCSet]){
                    rcMapTM.put(eachTM.RC_Code__c,eachTM.User__c);
                }
                for(Year_End_Ownership_Request__c eachYearReq : yearReqList){
                    if(eachYearReq.Type__c!=GlobalConstants.REFER_OUT || (eachYearReq.Type__c==GlobalConstants.REFER_OUT && rcMapTM.containsKey(eachYearReq.Approver_AH_RC_Code__c))){
                        if(eachYearReq.Requester_Manager_Approve_Flag__c == false && (eachYearReq.Requester__r.Segment__c == 'CB' || eachYearReq.Requester__r.Segment__c == 'MB') ){
                            eachYearReq.Requester_Manager_Approve_Flag__c = true;
                        }else{
                            eachYearReq.Approval_Status__c = 'Approved';
                            updateList.add(new Year_End_Assignment__c(
                                Id = eachYearReq.Year_End_Assignment__c,
                                Final_Refer_Out__c = false,
                                Status__c = GlobalConstants.STATUS_NEW,
                                Final_Assigned_Next_Year__c = null,
                                Refer_Out_Reason__c = null,
                                Refer_Out_Segment__c = null,
                                Refer_Out_Team__c = null,
                                Refer_Out_Amphur__c = null,
                                Refer_Out_Province__c = null,
                                Refer_Out_Tumbon__c = null,
                                Final_SVM_Next_Year__c = null,
                                Final_Port_Pool__c = null,
                                //Segment_Original__c = customerSegment,
                                OwnerId = (eachYearReq.Type__c!=GlobalConstants.REFER_OUT)?eachYearReq.Requester__r.User__c:eachYearReq.Refer_Out_To__r.User__c,
                                Owner_Employee_ID__c = (eachYearReq.Type__c!=GlobalConstants.REFER_OUT)?eachYearReq.Requester__r.Employee_Id__c:eachYearReq.Refer_Out_To__r.Employee_Id__c,
                                AH_RC_Code__c = (eachYearReq.Type__c!=GlobalConstants.REFER_OUT)?eachYearReq.Requester_AH_RC_Code__c:eachYearReq.Approver_AH_RC_Code__c,
                                TM_RC_Code__c = (eachYearReq.Type__c!=GlobalConstants.REFER_OUT)?eachYearReq.Requester_TM_RC_Code__c:eachYearReq.Approver_TM_RC_Code__c
                            ));
                            
                            Year_End_Assignment_Selection__c selObj = new Year_End_Assignment_Selection__c(
                                Id = eachYearReq.Year_End_Assignment_Selection__c,
                                Need_Approval__c = false,
                                Refer_Out__c = false
                            );
                            //if(eachYearReq.Type__c==GlobalConstants.REFER_OUT){selObj.Selected_Port_Pool__c = GlobalConstants.PORT;}
                            yearEndSelList.add(selObj);
                        }
                    }else{
                        resp.success = false;
                        resp.errorMessage = 'Approver Team has no TM';
                        Database.rollback(sp);
                    }
                }
                if(updateList!=null && updateList.size() > 0){
                    update updateList;
                }
                if(!yearEndSelList.isEmpty()){
                    update yearEndSelList;
                }
                update yearReqList;

                ////Delete refer_out_to CBS
                //if(!yearEndSelDelList.isEmpty()){
                //    delete yearEndSelDelList;
                //}
            }
            //approveStatus
            //yearlist
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            Database.rollback(sp);
            return resp;
        }
        return resp;
    }

    public String getSelectedResource(){
        //User currentUser = [SELECT Id,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String subfix = '_rm';
        if(currentUserStruc.Role__c=='RM' && (currentUserStruc.Segment__c =='SE' ||  currentUserStruc.Segment__c =='ME')){//if(Account_Util.isProfile(GlobalConstants.SME_RM,currentUserStruc)){
            subfix = '_rm';
        }else if(currentUserStruc.Role__c=='TM' && (currentUserStruc.Segment__c =='SE' ||  currentUserStruc.Segment__c =='ME')){//}else if(Account_Util.isProfile(GlobalConstants.SME_TM,currentUserStruc)){
            subfix = '_tm';
        }else if(currentUserStruc.Role__c=='AH' &&  (currentUserStruc.Segment__c =='SE' ||  currentUserStruc.Segment__c =='ME')){//}else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUserStruc)){
            subfix = '_ah';
        }else if((currentUserStruc.Role__c=='RM' || currentUserStruc.Role__c=='TM') &&  (currentUserStruc.Segment__c =='CB' ||  currentUserStruc.Segment__c =='MB')){//}else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUserStruc)){
            subfix = '_rm_cbs';
        }else if(currentUserStruc.Role__c=='TL' &&  (currentUserStruc.Segment__c =='CB' ||  currentUserStruc.Segment__c =='MB')){//}else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUserStruc)){
            subfix = '_tl_cbs';
        }
        return staticPrefix + subfix;
    }

    //FIX Incident Case AH Submit more than 10000 record
    @future
    public static void updateYearendAssignmentList(String yearEndStringList) {
        List<Year_End_Assignment__c> yearEndAssignList = (List<Year_End_Assignment__c>) JSON.deserialize(yearEndStringList, List<Year_End_Assignment__c>.class);
        update yearEndAssignList;
    }

    public String getSelectedCountFields(){
        return 'Id,RM_Name__c,Team__c,Final_Team__c,TM_Name__c,Selected_By_Name__c,Selected_By_Team__c';
    }

    public String getCustomerOwnerRequestFields(){
        return 'Id,Name,CIS_ID_Text__c,CIS_ID__r.CIS__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool_YearEnd__c,Credit_Status__c,Owner.Name,Team__c,TM_Name__c,AH_Name__c,NH_Name__c,RM_Name__c,Approval_Status__c,Assigned_Port_Pool__c,Port_Pool__c, Service_RM_User__r.Name, Year_End_Assignment__r.Selected_Count__c';
    }
    public String getCustomerOwnerRequestFieldsForDes(){
        return 'Id,Name,CIS_ID_Text__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool_YearEnd__c,Credit_Status__c,Team__c,TM_Name__c,AH_Name__c,NH_Name__c,RM_Name__c,Approval_Status__c,Assigned_Port_Pool__c,Port_Pool__c,Refer_Out_To_Team__c,Requester_Team__c,Service_RM__c,Service_RM_Name_Text__c,Requester_Name_Text__c,Type__c,Refer_Out_From_Team__c';
    }

    public String getYearRequestFieldsFields(){
        return 'Id,CIS_ID__c,Customer_Name__c,Selected_Count__c,Port_Pool__c,RM_Name__c,TM_Name__c,AH_Name__c,Team__c,Segment_Original__c,High_Value_Flag__c,Credit_Status__c,Approval_Status__c,Requester__c,Assigned_Port_Pool__c,Requester_TM_RC_Code__c,Approver__c,Requester__r.Id,Requester__r.Name,Service_RM__c,Service_RM_Name_Text__c,Requester_Name_Text__c,Type__c,Requester_Team__c,Refer_Out_Reason__c,Refer_Out_From__r.Name,Refer_Out_From_Team__c,Refer_Out_To__r.Name,Refer_Out_To_Team__c,Approver__r.Name,Service_RM__r.Name,Refer_Out_To_Name__c,Approver_Name__c,Refer_Out_From_Name__c,Year_End_Assignment_Selection__r.Language__c,Requester_Manager_Approve_Flag__c,Requester_AH_Name__c';
    }
    public String getYearRequestFieldsForDes(){
        return 'Id,CIS_ID__c,Customer_Name__c,Selected_Count__c,Port_Pool__c,RM_Name__c,TM_Name__c,AH_Name__c,Team__c,Segment_Original__c,High_Value_Flag__c,Credit_Status__c,Approval_Status__c,Requester__c,Assigned_Port_Pool__c,Requester_TM_RC_Code__c,Approver__c,Service_RM_Name_Text__c,Requester_Name_Text__c,Refer_Out_To_Name__c,Approver_Name__c,Refer_Out_From_Name__c,Type__c,Requester_Team__c,Refer_Out_Reason__c,Refer_Out_From_Team__c,Refer_Out_To_Team__c,Requester_Manager_Approve_Flag__c';
    }

    public String getYearEndFields(){
        return 'Id,CIS_ID__c,CIS_ID_Unique__c,CIS_Number__c,Court_Case_Current_Year__c,Final_SVM_Next_Year__c,Final_SVM_Next_Year__r.Name,Final_Service_RM_Text__c,SME_Limit_LI__c,SME_Limit_TF__c,Customer_Name__c,Segment_Original__c,Final_Team__c,toLabel(Refer_Out_Reason__c),Refer_Out_Detail__c,RM_Name__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,Team__c,TM_Name__c,Final_Assigned_Next_Year__c,Final_Refer_Out__c,Final_Assigned_SelectedBy_Text__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Status__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,BOL_Last_2_Years__c,BOL_Last_Year__c,(SELECT Selected_By_Team__c,Selected_By_Next_Year__c,Refer_Out__c,CreatedBy.Employee_ID__c,CreatedBy.RC_Code__c,CreatedBy.Name,Selected_By_Name__c,Refer_Out_Reason__c FROM Year_End_Assignment_Selections__r),Able_Refer_To_RBS__c,Sales_Size__c,CBS_Sub_Group__c,CBS_Group__c';
    }
    public String getYearEndFieldsForDes(){
        return 'Id,CIS_ID__c,CIS_ID_Unique__c,Court_Case_Current_Year__c,Final_SVM_Next_Year__c,Final_Service_RM_Text__c,SME_Limit_LI__c,SME_Limit_TF__c,Customer_Name__c,Segment_Original__c,Final_Team__c,Refer_Out_Reason__c,Refer_Out_Detail__c,RM_Name__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,Team__c,TM_Name__c,Final_Assigned_Next_Year__c,Final_Refer_Out__c,Final_Assigned_SelectedBy_Text__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Status__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,CBS_Sub_Group__c,CBS_Group__c';
    }

    public String getYearEndSelFields(){
         return 'Id,CIS_ID__c,RM_Name__c,Final_Team__c,Customer_Name__c,Final_SVM_Next_Year__c,Court_Case_Current_Year__c,Segment_Original__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Credit_Status__c,Team__c,TM_Name__c,TM_EmpID__c,Selected_By_Name__c,Selected_By_Team__c,Port_Pool__c,Refer_Out__c,toLabel(Refer_Out_Reason__c),Refer_Out_Team__c,Refer_Out_Detail__c,SME_Limit_LI__c,SME_Limit_TF__c,Service_RM_Name__c,Final_Assigned_Next_Year__c,Final_Refer_Out__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Selected_By_Next_Year__c,Selected_By_Next_Year__r.RC_Code__c,Year_End_Assignment__c,Final_Refer_Out_Reason__c,Final_Refer_Out_Reason_Detail__c,Selected_Port_Pool__c,Selected_By_SVM_Next_Year__c,Selected_By_Service_RM_Text__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Type__c,CBS_Group__c,CBS_Sub_Group__c,Sales_Size__c,Refer_Province__c,Year_End_Assignment__r.Status__c,Year_End_Assignment__r.OwnerId,CreatedBy.Employee_ID__c,CreatedBy.RC_Code__c,CreatedBy.AH_RC_Code__c,CreatedBy.Name';
    }
    public String getYearEndSelFieldsForDes(){
        return 'Id,CIS_ID__c,Customer_Name__c,Final_SVM_Next_Year__c,Court_Case_Current_Year__c,Segment_Original__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Credit_Status__c,RM_Name__c,Team__c,TM_Name__c,TM_EmpID__c,Selected_By_Name__c,Selected_By_Team__c,Port_Pool__c,Final_Team__c,Refer_Out__c,Refer_Out_Reason__c,Refer_Out_Team__c,Refer_Out_Detail__c,SME_Limit_LI__c,SME_Limit_TF__c,Service_RM_Name__c,Final_Assigned_Next_Year__c,Final_Refer_Out__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Selected_By_Next_Year__c,Year_End_Assignment__c,Final_Refer_Out_Reason__c,Final_Refer_Out_Reason_Detail__c,Selected_Port_Pool__c,Selected_By_SVM_Next_Year__c,Selected_By_Service_RM_Text__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Type__c,CBS_Group__c,CBS_Sub_Group__c,Sales_Size__c,Refer_Province__c,Year_End_Assignment__c';
    }
}