/**
* @author komsan.wi@beryl8.com
* @17/09/2015 create new
*/
global without sharing class YearEndAssignment_Webservice {
    global class CustomerObject{
        webservice String year_id;
        webservice String customer_id;
        webservice String cis_id;
        webservice Decimal selected_count;
        webservice String name;
        webservice String segment;
        webservice String high_value;
        webservice String flag_port;
        webservice String credit_status;
        webservice String existing_rm_name;
        webservice String team;
        webservice String tm_name;
        webservice String ah_name;
        webservice String nh_name;
        webservice String approval_status;
        global CustomerObject(Year_End_Assignment__c eachYearEnd,String approvalStatus){
            System.debug('YearendObject');
            System.debug(eachYearEnd);
            year_id = eachYearEnd.Id;
            customer_id = eachYearEnd.CIS_ID__r.Id;
            cis_id = eachYearEnd.CIS_ID_Unique__c;
            selected_count = eachYearEnd.Selected_Count__c;
            name = eachYearEnd.Customer_Name__c;
            segment = eachYearEnd.Segment_Original__c;
            high_value = eachYearEnd.High_Value_Flag__c;
            //flag_port = eachYearEnd.Port_Pool__c;
            credit_status = eachYearEnd.Credit_Status__c;
            existing_rm_name = eachYearEnd.RM_Name__c;
            team = eachYearEnd.Team__c;
            tm_name = eachYearEnd.TM_Name__c;
            ah_name = eachYearEnd.AH_Name__c;
            nh_name = eachYearEnd.NH_Name__c;
            approval_status = approvalStatus;
        }
    }
    global class CustomerResponse {
        webservice Boolean success;
        webservice String errorMessage;
        webservice List<YearEndAssignment_Webservice.CustomerObject> records;
        global CustomerResponse() {
            success = true;
            records = new List<YearEndAssignment_Webservice.CustomerObject>();
        }
    }
    global class SelectedName {
        webservice String selectedbyNameRequestpanel;
        webservice String portPoolRequestpanel;
        webservice String serviceRMRequestpanel;
    }
    webService static YearEndAssignment_Webservice.CustomerResponse createRequestYearEnd(String selectNameString,List<String> yearlist) {
        YearEndAssignment_Webservice.CustomerResponse resp = new YearEndAssignment_Webservice.CustomerResponse();
        YearEndAssignment_Webservice.SelectedName selectName = (YearEndAssignment_Webservice.SelectedName)JSON.deserialize(selectNameString, YearEndAssignment_Webservice.SelectedName.class);
        Savepoint sp = Database.setSavepoint();
        try{
            List<Year_End_Ownership_Request__c> ownerRequestList = new List<Year_End_Ownership_Request__c>();
            List<Year_End_Ownership_Request__c> currentRequest = new List<Year_End_Ownership_Request__c>();
            List<Year_End_Assignment_Selection__c> selectionList = new List<Year_End_Assignment_Selection__c>();

            Year_End_Sales_Structure__c currentUserStruc = [SELECT Id,AH_RC_Code__c,Segment__c,Employee_Id__c,RC_Code__c,Role__c,Submitted_Flag__c,Manager__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];

            String currentRequestName = (selectName!=null && selectName.selectedbyNameRequestpanel!=null)?selectName.selectedbyNameRequestpanel:currentUserStruc.Id;

            currentRequest = [SELECT Id,Year_End_Assignment__c,Approval_Status__c FROM Year_End_Ownership_Request__c WHERE Year_End_Assignment__c IN :yearlist AND Requester__c =:currentRequestName AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC];

            Map<String,Year_End_Assignment__c> yearEndMap = new Map<String,Year_End_Assignment__c>([SELECT Id,CIS_ID__c,RM_Employee_ID__c,OwnerId,AH_RC_Code__c,TM_RC_Code__c FROM Year_End_Assignment__c WHERE Id in :yearlist]);

            if(currentRequest!=null && currentRequest.size() > 0){
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'You have already make a request to this records';
                return resp;
            }

            Set<String> ahRcSet = new Set<String>();
            for(Year_End_Assignment__c eachYearEnd : yearEndMap.values()){
                if(eachYearEnd.AH_RC_Code__c!=null) ahRcSet.add(eachYearEnd.AH_RC_Code__c);
            }

            List<Year_End_Sales_Structure__c> yearStrucAhList = [select id,RC_Code__c from Year_End_Sales_Structure__c where Role__c IN ('AH','TL') AND RC_Code__c in :ahRcSet];
            Map<String,String> ahRcCodeMapUserId = new Map<String,String>();
            for(Year_End_Sales_Structure__c eachYearStruc : yearStrucAhList){
                ahRcCodeMapUserId.put(eachYearStruc.RC_Code__c,eachYearStruc.Id);
            }

            for(Year_End_Assignment__c eachYearEnd : yearEndMap.values()){
                if(ahRcCodeMapUserId.containsKey(yearEndMap.get(eachYearEnd.Id).AH_RC_Code__c))
                    selectionList.add(new Year_End_Assignment_Selection__c(
                        Selected_By_Next_Year__c = (selectName!=null && selectName.selectedbyNameRequestpanel!=null && selectName.selectedbyNameRequestpanel!='')?selectName.selectedbyNameRequestpanel:currentUserStruc.Id,
                        Refer_Out__c = false,
                        Year_End_Assignment__c = eachYearEnd.Id,
                        Need_Approval__c = true,
                        Selected_By_SVM_Next_Year__c = (selectName!=null && selectName.serviceRMRequestpanel!=null && selectName.serviceRMRequestpanel!='')?selectName.serviceRMRequestpanel:null,
                        Selected_Port_Pool__c = (selectName!=null && selectName.portPoolRequestpanel!=null && selectName.portPoolRequestpanel!='')?selectName.portPoolRequestpanel:'Port'
                    ));
            }

            if(resp.success && selectionList.size() > 0){
                insert selectionList;
            }
            
            for(Year_End_Assignment_Selection__c eachYearEndSel : selectionList){
                if(ahRcCodeMapUserId.containsKey(yearEndMap.get(eachYearEndSel.Year_End_Assignment__c).AH_RC_Code__c))
                    ownerRequestList.add(new Year_End_Ownership_Request__c(
                        Year_End_Assignment__c = eachYearEndSel.Year_End_Assignment__c,
                        Year_End_Assignment_Selection__c = eachYearEndSel.Id,
                        Requester__c = (selectName!=null && selectName.selectedbyNameRequestpanel!=null && selectName.selectedbyNameRequestpanel!='')?selectName.selectedbyNameRequestpanel:currentUserStruc.Id,
                        Service_RM__c = (selectName!=null && selectName.serviceRMRequestpanel!=null && selectName.serviceRMRequestpanel!='')?selectName.serviceRMRequestpanel:null,
                        Assigned_Port_Pool__c = (selectName!=null && selectName.portPoolRequestpanel!=null && selectName.portPoolRequestpanel!='')?selectName.portPoolRequestpanel:'Port',
                        Type__c = GlobalConstants.REQUEST_OWNERSHIP,
                        Requester_TM_RC_Code__c = currentUserStruc.RC_Code__c,
                        Requester_AH_RC_Code__c = (currentUserStruc.Role__c =='TL' || currentUserStruc.Role__c =='AH')?currentUserStruc.RC_Code__c:currentUserStruc.AH_RC_Code__c,
                        Requester_AH__c = (currentUserStruc.Role__c =='TL' || currentUserStruc.Role__c =='AH')?currentUserStruc.Id:currentUserStruc.Manager__c,
                        Approver__c = ahRcCodeMapUserId.get(yearEndMap.get(eachYearEndSel.Year_End_Assignment__c).AH_RC_Code__c),
                        Approver_AH_RC_Code__c = yearEndMap.get(eachYearEndSel.Year_End_Assignment__c).AH_RC_Code__c,
                        Requester_Manager_Approve_Flag__c =((currentUserStruc.Segment__c == 'CB' || currentUserStruc.Segment__c =='MB') && currentUserStruc.Role__c !='TL')?false:true
                    ));
            }
            if(resp.success && ownerRequestList.size() > 0){
                insert ownerRequestList;
            }
            
        }catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            Database.rollback(sp);
        }
        return resp;
    }
    
    webService static YearEndAssignment_Webservice.CustomerResponse getCustomers(String cis) { 
        YearEndAssignment_Webservice.CustomerResponse resp = new YearEndAssignment_Webservice.CustomerResponse();
        try{
            System.debug('UserInfo.getUserId():'+UserInfo.getUserId());
            List<Year_End_Assignment__c> yearEndList = new List<Year_End_Assignment__c>();
            Year_End_Sales_Structure__c currentUserStruc = [SELECT Id,AH_RC_Code__c,Segment__c,Employee_Id__c,RC_Code__c,Role__c,Submitted_Flag__c FROM Year_End_Sales_Structure__c WHERE User__c=:UserInfo.getUserId() LIMIT 1];
            

            String ahRcCode;
            if(currentUserStruc.Role__c =='TL'){
                ahRcCode = currentUserStruc.RC_Code__c;
            }else{
                ahRcCode = currentUserStruc.AH_RC_Code__c;
            }
             
            if(ahRcCode == null){
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'No Records found.';
            }
            System.debug('ahRcCode :'+ahRcCode);
            //yearEndList = Database.query('SELECT Id,Selected_Count__c,CIS_ID__r.Id,CIS_ID_Unique__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,RM_Name__c,Team__c,TM_Name__c,AH_Name__c,NH_Name__c FROM Year_End_Assignment__c WHERE CIS_ID__r.CIS__c = \''+cis+'\' AND Status__c=\'New\' AND AH_RC_Code__c!=:ahRcCode');
            yearEndList = Database.query('SELECT Id,Selected_Count__c,CIS_ID__r.Id,CIS_ID_Unique__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Credit_Status__c,RM_Name__c,Team__c,TM_Name__c,AH_Name__c,NH_Name__c FROM Year_End_Assignment__c WHERE CIS_ID__r.CIS__c = \''+cis+'\' AND Status__c=\'New\' AND AH_RC_Code__c!=:ahRcCode');
            if(yearEndList!=null && yearEndList.size() > 0){
                Map<Id,Year_End_Assignment__c> yearEndMap = new Map<Id,Year_End_Assignment__c>(yearEndList);
                Set<Id> availiableIds = new Set<Id>();
        
                Map<String,String> requestMap = new Map<String,String>();
                List<Year_End_Ownership_Request__c> currentRequest = new List<Year_End_Ownership_Request__c>();
                currentRequest = [SELECT Id,Year_End_Assignment__c,Approval_Status__c FROM Year_End_Ownership_Request__c WHERE Year_End_Assignment__r.AH_RC_Code__c!=:currentUserStruc.AH_RC_Code__c AND Requester_TM_RC_Code__c =:currentUserStruc.RC_Code__c AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC LIMIT 1];

                System.debug('currentRequest.size :'+ currentRequest.size());
                if(currentRequest.size() >0){
                    for(Year_End_Ownership_Request__c eachRequest : currentRequest){
                        requestMap.put(eachRequest.Year_End_Assignment__c,eachRequest.Approval_Status__c);
                    }
                }
                
                for(Year_End_Assignment__c eachYearEnd : yearEndList){
                    resp.records.add(new YearEndAssignment_Webservice.CustomerObject(eachYearEnd,(requestMap!=null && requestMap.containsKey(eachYearEnd.Id))?requestMap.get(eachYearEnd.Id):null));
                }
                if(resp.records.size() > 0){
                    resp.success = true;
                    System.debug('have record');
                }else {
                    resp.success = false;
                    resp.records = null;
                    resp.errorMessage = 'No Records found.';
                }
            }else {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'No Records found.';
            }
        }catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
        }
        return resp;
    }
}