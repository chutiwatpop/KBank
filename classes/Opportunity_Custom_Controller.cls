public with sharing class Opportunity_Custom_Controller {

    private static final String ALL = 'All';
    public List<OppPlanningWrapper> oppPlanningWrapperList {get;set;}
    public Boolean isWin;
    public Boolean editable {get;set;}
    public String errorMessage {get;set;}
    public Boolean errorRender {get;set;}
    public String warningMessage {get;set;}
    public String changedStatus {get;set;}
    public Integer countOppPlanningResult;
    public Integer pageSize;
    public Integer startIndex;
    public Integer pointerIndex;
    public Integer endIndex;
    public List<Id> allOppPlanningWrapper;
    public String currentRangePage{get;set;}
    public Boolean nextRender{get;set;}
    public Boolean prevRender{get;set;}
    public String imageStringNext{get;set;}
    public String imageStringPrev{get;set;}
    public Integer pageOf;
    public Integer totalPage;
    public String pageIndex{get;set;}
    public Boolean sendStatus;
    public Set<Id> returnedOppIdSet{get;set;}
    public List<String> oppIdStringList{get;set;}
    public Boolean teamFilterRender {get;set;}
    public List<SelectOption> teamItems {get;set;}
    public String selectedTeam {get;set;}
    public String teamName;
    public Boolean ownerFilterDisable {get;set;}
    public Boolean ownerFilterRender {get;set;}
    public List<SelectOption> ownerItems {get;set;}
    public String selectedOwner {get;set;}
    public List<SelectOption> productTypeItems {get;set;}
    public String selectedProduct {get;set;}
    public List<SelectOption> productGroupItems {get;set;}
    public String selectedProductGroup {get;set;}
    public List<SelectOption> statusItems {get;set;}
    public String selectedStatus {get;set;}
    public List<SelectOption> stageItems {get;set;}
    public String selectedStage {get;set;}
    public List<SelectOption> stageLineItems {get;set;}
    public String profileName {get;set;}
    public Boolean teamView;
    public Boolean ownerView;
    public Boolean productView;
    public Boolean productGroupView;
    public Boolean statusView;
    public Boolean stageView;
    public Boolean hasChangeBeforeNext {get;set;}
    public Boolean hasChangeBeforePrev {get;set;}
    public Boolean hasChangeBeforeGo {get;set;}
    public String cbsRCCode;
    public String cisId {get;set;}
    public Boolean isUserNH;
    public Boolean renderTableFilterCis {get;set;}
    public String oldSelectedOwner {get;set;}
    public String oldSelectedTeam {get;set;}
    public String oldSelectedStage {get;set;}
    public String oldSelectedStatus {get;set;}
    public String oldSelectedProduct {get;set;}
    public String oldSelectedProductGroup {get;set;}
    public String oldCisId {get;set;}
    public Integer countChecked {get;set;}
    public Set<Id> oppPlanningOld;

    public Map<String,Opportunity_Planning_Type__c> oppPlanningCSMapByOppPlanType;

    public Opportunity_Custom_Controller() {
        this.oppPlanningCSMapByOppPlanType = CBS_Utility.getOppPlanningTypeCustomSettingMapByType();
        teamView = false;
        ownerView = false;
        productView = false;
        productGroupView = false;
        statusView = false;
        stageView = false;
        renderTableFilterCis = false;
        teamFilterRender = false;

        ownerFilterDisable = true;
        ownerFilterRender = false;

        allOppPlanningWrapper = new List<Id>();
        pageSize = Integer.valueOf(System.Label.Display_Opp_Planning_Record);

        countOppPlanningResult = 0;
        currentRangePage = '';
        pageOf = 0;
        pointerIndex = 0;
        endIndex = pageSize;
        imageStringNext = '/img/search_nextarrow.gif';
        imageStringPrev = '/img/search_prevarrow.gif';
        pageIndex = '';        
        totalPage = 0;
        startIndex = 0;
        groupNo = 1;
        countChecked = 0;

        teamItems = new List<SelectOption>();
        ownerItems = new List<SelectOption>();
        statusItems = new List<SelectOption>();
        productTypeItems = new List<SelectOption>();
        productGroupItems = new List<SelectOption>();
        stageItems = new List<SelectOption>();

        stageLineItems = new List<SelectOption>();
        mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
        ownerItems.add(new SelectOption(ALL,'--All Owner--'));
        productTypeItems.add(new SelectOption(ALL,'--All--'));
        productGroupItems.add(new SelectOption(ALL,'--All--'));
        statusItems.add(new SelectOption('Active','Active'));
        stageItems.add(new SelectOption(ALL,'--All Stage--'));

        User currentUser = [SELECT Id,Name,Profile.Name,UserRoleId,RC_Code__c,Employee_ID__c,AH_RC_Code__c,Segment__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        Map<String,User_Mirror_Management__c> nHTLCustomSettingByUserRCCode = CustomSettingUtil.getMirrorSettingByUserRcCode();
        isUserNH = false;
        
        Boolean checkKeyMap = false;
        checkKeyMap = nHTLCustomSettingByUserRCCode.containsKey(currentUser.RC_Code__c);
        if(checkKeyMap){
            cbsRCCode = nHTLCustomSettingByUserRCCode.get(currentUser.RC_Code__c).Mirror_Value__c;   
        }

        profileName = checkProfile();
        profileHandler(profileName);
        FilterOpp();
        editable = false;
        errorRender = false;

        hasChangeBeforeNext = false;
        hasChangeBeforePrev = false;
        hasChangeBeforeGo = false;
    }
    public String checkProfile(){
        String proName;
        Id profileId = userinfo.getProfileId();
        proName = [SELECT Id,Name from Profile where Id=:profileId].Name;
        return proName;
    }
    public void profileHandler(String userProfile){
        CBS_OppPlanning_Filter_View__c filterView = CBS_OppPlanning_Filter_View__c.getInstance(userinfo.getProfileId());
        teamView = filterView.All_Team__c;
        ownerView = filterView.All_Owner__c;
        productView = filterView.All_Product__c;
        productGroupView = filterView.All_Product_Group__c;
        statusView = filterView.All_Status__c;
        stageView = filterView.All_Stage__c;

        if(cbsRCCode!=null){
            isUserNH = true;
        }

        if(teamView == true){
            teamFilterRender = true;
            getAllTeamName('All_Team');
            selectedTeam = ALL;
        }
        if(teamView == false){
            teamFilterRender = false;
            ownerFilterDisable = false;
        }
        if(ownerView == true ){
            ownerFilterRender = true;
            selectedOwner = ALL;
            if(teamView == false && !isUserNH){
                Id userId = UserInfo.getUserId();
                User_Extension__c teamMember = [SELECT Id,Name,Segment__c,Position__c,Team_Name__c,Team_Structure__c,Team_Structure__r.Name,User__c FROM User_Extension__c WHERE (Segment__c = :GlobalConstants.SEGMENT_CB OR Segment__c = :GlobalConstants.SEGMENT_MB) AND User__c =:userId LIMIT 1];
                selectedTeam = teamMember.Team_Structure__c;
                teamName = teamMember.Team_Structure__r.Name;
            }else if(teamView == false && isUserNH){
                selectedTeam = TeamStructure_Service.getTeamStructureIdByRcCode(cbsRCCode);
            }
            getTeamMember();
        }
        if(ownerView == false){
            ownerFilterRender = false;
        }
        if(productView == true){
            getAllProductType();
            selectedProduct = ALL;
            if(teamView == false && ownerView == false){
                Id userId = UserInfo.getUserId(); 
                User_Extension__c teamMember = [SELECT Id,Name,Segment__c,Position__c,Team_Name__c,Team_Structure__c,Team_Structure__r.Name,User__c FROM User_Extension__c WHERE (Segment__c = :GlobalConstants.SEGMENT_CB OR Segment__c = :GlobalConstants.SEGMENT_MB) AND User__c =:userId LIMIT 1];
                selectedTeam = teamMember.Team_Structure__c;
                teamName = teamMember.Team_Structure__r.Name;
                selectedOwner = userId;
            }
        }
        if(productGroupView == true){
            getAllProductGroup();
            selectedProductGroup = ALL;
        }
        if(statusView == true){
            getAllStatus();
            selectedStatus = 'Active';
            doStatusGroup();
        }
        if(stageView == true){
            getStageLineItem();
            selectedStage = ALL;
        }

        oldSelectedTeam = selectedTeam;
        oldSelectedOwner = selectedOwner;
        oldSelectedStage = selectedStage;
        oldSelectedStatus = selectedStatus;
        oldSelectedProduct = selectedProduct;
        oldSelectedProductGroup = selectedProductGroup;
    }
    public void getAllTeamName(String position){
        if(position == 'All_Team'){
            List<Team_Structure__c> teamList = [SELECT Id,Name,RC_Short_Name__c,Segment__c, RC_Code__c FROM Team_Structure__c WHERE Segment__c = :GlobalConstants.SEGMENT_MB OR Segment__c = :GlobalConstants.SEGMENT_CB ORDER BY Segment__c,RC_Code__c ASC];
            teamItems.add(new SelectOption(ALL,'--All Team--'));
            for(Team_Structure__c eachTeam : teamList){
                teamItems.add(new SelectOption(eachTeam.Id,eachTeam.Name));
            }
        }    
    }
    public void getTeamMember(){
        ownerFilterDisable = false;
        ownerItems = new List<SelectOption>();
        ownerItems.add(new SelectOption(ALL,'--All Owner--'));

        List<User_Extension__c> teamMember = OpportunityPlanning_Service.getUserExByTeamStructureId(selectedTeam);
        for(User_Extension__c eachMember : teamMember){
            String displayOwner = eachMember.Name +' - '+eachMember.Position__c;
            ownerItems.add(new SelectOption(eachMember.User__c,displayOwner));
        }
    }
    public void getAllProductType(){
        List<Schema.PicklistEntry> pickListValue = Opportunity_Planning__c.Product_Type__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry eachValue : pickListValue){
            productTypeItems.add(new SelectOption(eachValue.getLabel(), eachValue.getValue()));
        }       
    }

    public void getAllProductGroup(){
        List<Product_List_Master__c> listAllProductGroup = CBS_Utility.getCBSProductConfigList();
        Set<String> setAllProductGroup = new Set<String>();
        for(Product_List_Master__c eachProductGroup : listAllProductGroup){
            if(eachProductGroup.Is_Active__c){
                setAllProductGroup.add(eachProductGroup.Product_Group__c);
            }
        }

        List<AggregateResult> listOppPlanLineItemWithProductGroup = [SELECT Call_Report_Product_List_Master__r.Product_Group__c productGroup FROM Opportunity_Planning_Line_Item__c WHERE Opportunity_Planning__r.CIS_ID__r.OwnerId = :UserInfo.getUserId() And Call_Report_Product_List_Master__c != null GROUP BY Call_Report_Product_List_Master__r.Product_Group__c];
        for(AggregateResult eachOppPlanLineItem : listOppPlanLineItemWithProductGroup){
            setAllProductGroup.add(String.valueOf(eachOppPlanLineItem.get('productGroup')));
        }

        for(String eachProductGroup : setAllProductGroup){
            productGroupItems.add(new SelectOption(eachProductGroup,eachProductGroup));
        }
    }

    public void getAllStatus(){
        statusItems.add(new SelectOption('Inactive','Inactive'));
        statusItems.add(new SelectOption(ALL,'--All--'));
    }
    public void doStatusGroup(){
        stageItems = new List<SelectOption>();
        stageItems.add(new SelectOption(ALL,'--All Stage--'));
        if(selectedStatus == ALL){
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_EXPLORE,GlobalConstants.OPP_PLAN_EXPLORE));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WORK_IN_PROCESS,GlobalConstants.OPP_PLAN_WORK_IN_PROCESS));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_PITCHING,GlobalConstants.OPP_PLAN_PITCHING));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_NEGOTIATION,GlobalConstants.OPP_PLAN_NEGOTIATION));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WIN_MANDATE,GlobalConstants.OPP_PLAN_WIN_MANDATE));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_LOST,GlobalConstants.OPP_PLAN_LOST));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_REJECTED,GlobalConstants.OPP_PLAN_REJECTED));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_CANCELLED,GlobalConstants.OPP_PLAN_CANCELLED));            
            stageItems.add(new SelectOption('Not Interested','Not Interested'));
        }
        if(selectedStatus == 'Active'){
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_EXPLORE,GlobalConstants.OPP_PLAN_EXPLORE));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WORK_IN_PROCESS,GlobalConstants.OPP_PLAN_WORK_IN_PROCESS));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_PITCHING,GlobalConstants.OPP_PLAN_PITCHING));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_NEGOTIATION,GlobalConstants.OPP_PLAN_NEGOTIATION));
        }
        if(selectedStatus == 'Inactive'){
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WIN_MANDATE,GlobalConstants.OPP_PLAN_WIN_MANDATE));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_LOST,GlobalConstants.OPP_PLAN_LOST));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_REJECTED,GlobalConstants.OPP_PLAN_REJECTED));
            stageItems.add(new SelectOption(GlobalConstants.OPP_PLAN_CANCELLED,GlobalConstants.OPP_PLAN_CANCELLED));            
            stageItems.add(new SelectOption('Not Interested','Not Interested'));
        }
    }

    public List<SelectOption> getStatusItems(){
        List<SelectOption> statusOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =  Opportunity_Planning__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : picklistValues){
            statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return statusOptions;
    }
    public void getStageLineItem(){
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_EXPLORE,GlobalConstants.OPP_PLAN_EXPLORE));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WORK_IN_PROCESS,GlobalConstants.OPP_PLAN_WORK_IN_PROCESS));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_PITCHING,GlobalConstants.OPP_PLAN_PITCHING));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_NEGOTIATION,GlobalConstants.OPP_PLAN_NEGOTIATION));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_WIN_MANDATE,GlobalConstants.OPP_PLAN_WIN_MANDATE));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_LOST,GlobalConstants.OPP_PLAN_LOST));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_REJECTED,GlobalConstants.OPP_PLAN_REJECTED));
        stageLineItems.add(new SelectOption(GlobalConstants.OPP_PLAN_CANCELLED,GlobalConstants.OPP_PLAN_CANCELLED));
    }
    public void checkBeforeFilter(){
        for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperList){
            if(checkChange(eachOppPlan) && !eachOppPlan.isGrouped){
                hasChangeBeforeGo = true;
                break;
            }
        }
        oldSelectedTeam = selectedTeam;
        oldSelectedOwner = selectedOwner;
        oldSelectedStage = selectedStage;
        oldSelectedStatus = selectedStatus;
        oldSelectedProduct = selectedProduct;
        oldSelectedProductGroup = selectedProductGroup;
        oldCisId = cisId;
        if(hasChangeBeforeGo == false){
            FilterOpp(); 
        }
    }
    public void FilterOpp(){

        countOppPlanningResult = 0;
        currentRangePage = '';
        startIndex = 0;
        pointerIndex = 0;
        endIndex = pageSize;
       
        oppPlanningOld = new Set<Id>();

        oppPlanningOld = getOppPlanning(oldSelectedTeam,oldSelectedOwner,oldSelectedProduct,oldSelectedProductGroup,oldSelectedStatus,oldSelectedStage,oldCisId);
  
        oppPlanningWrapperList = PageHandler(oppPlanningOld);
        hasChangeBeforeGo = false;

        errorRender = false;
        countingChecked();
    }
    public Set<Id> getOppPlanning(String team, String owner,String productType,String productGroup, String status, String stage,String inputCisId){
        try{
            Set<String> stageActiveSet = new Set<String>{GlobalConstants.OPP_PLAN_EXPLORE,GlobalConstants.OPP_PLAN_WORK_IN_PROCESS,GlobalConstants.OPP_PLAN_PITCHING,GlobalConstants.OPP_PLAN_NEGOTIATION};
            Set<String> stageInactiveSet = new Set<String>{GlobalConstants.OPP_PLAN_LOST,GlobalConstants.OPP_PLAN_REJECTED,GlobalConstants.OPP_PLAN_CANCELLED,GlobalConstants.OPP_PLAN_WIN_MANDATE,'Not Interested'};
            Set<String> productTypeSet = new Set<String>{GlobalConstants.OPP_PLAN_CREDIT,GlobalConstants.OPP_PLAN_NON_CREDIT};
            Set<String> statusSet = new Set<String>{'Active','Inactive'};
            Map<Id, Opportunity_Planning__c> oppPlan = new Map<Id, Opportunity_Planning__c>();

            Set<Id> teamMemberIdSet = new Set<Id>();

            Set<String> querySet = new Set<String>();
            String initialQuery = 'SELECT ID FROM Opportunity_Planning__c WHERE ';

            String conditionString = '';
            String teamOwnerCondition = '';
            String productCondition = '';
            String stageCondition = '';
            String endQuery = ' ORDER BY CIS_ID__r.CIS__c ASC';
            renderTableFilterCis = false;
            if(team != ALL){
                List<User_Extension__c> teamMember = new List<User_Extension__c>();
                if(!isUserNH){
                    teamMember = [SELECT Name,Segment__c,Position__c,Team_Name__c,Team_Structure__c,User__c FROM User_Extension__c WHERE (Segment__c = :GlobalConstants.SEGMENT_CB OR Segment__c = :GlobalConstants.SEGMENT_MB) AND Team_Structure__c =:team];
                }else{
                    teamMember = OpportunityPlanning_Service.getUserExByTeamStructureId(team);
                }
                for(User_Extension__c eachMember : teamMember){
                    teamMemberIdSet.add(eachMember.User__c);
                }
                teamOwnerCondition = 'CIS_ID__r.Owner.Id IN :teamMemberIdSet ';
                querySet.add(teamOwnerCondition);
            }
            if(owner != ALL){
                teamOwnerCondition = 'CIS_ID__r.Owner.Id =: owner ';
                querySet.add(teamOwnerCondition);
            }
            if(productType != ALL){
                productCondition = 'Product_Type__c =: productType ';
                querySet.add(productCondition);
            }
            if(productGroup != ALL){
                productCondition = 'Id IN (SELECT Opportunity_Planning__c FROM Opportunity_Planning_Line_Item__c WHERE Call_Report_Product_List_Master__r.Product_Group__c =: productGroup) ';
                querySet.add(productCondition);
            }
            if(status == ALL){
                stageCondition = '(Status__c IN :stageActiveSet OR Status__c IN :stageInactiveSet) ';
                querySet.add(stageCondition);
            }
            if(status == 'Active'){
                stageCondition = 'Status__c IN :stageActiveSet ';
                querySet.add(stageCondition);
            }
            if(status == 'Inactive'){
                stageCondition = 'Status__c IN :stageInactiveSet ';
                querySet.add(stageCondition);
            }
            if(stage != ALL){
                stageCondition = 'Status__c =: stage ';
                querySet.add(stageCondition);
            }

            if(inputCisId != null && inputCisId != ''){
                stageCondition = 'CIS_ID__r.CIS__c =: inputCisId ';
                querySet.add(stageCondition);
                renderTableFilterCis = true;
            }

            Integer countQueryList = 0;
            Integer querySetCount = querySet.size();
            for(String eachString: querySet){
                if(countQueryList == querySetCount-1){
                    conditionString += eachString;
                }
                else{
                    conditionString += eachString+' AND ';
                }
                countQueryList++;
            }

            String queryCondition = initialQuery+conditionString+endQuery;
            List<Opportunity_Planning__c> oppPlanLists = Database.query(queryCondition);
            
            oppPlan = new Map<Id, Opportunity_Planning__c>(oppPlanLists);

            Set<Id> l=new Set<Id>();
            for(Id eachOppPlanId : oppPlan.keySet()){
                    l.add(eachOppPlanId);
            }
            return l;
        }
        catch(Exception e){
            errorRender = true;
            errorMessage = e.getMessage();
            System.debug('Error ::: ' + e.getStackTraceString());
            return null;
        }        
    }
    public List<Opportunity_Planning__c> additionalQuery(Set<Id> opIdSet){
        return [SELECT ID,CIS_ID__r.Customer_s_Business_Code__c,CIS_ID__r.CIS__c,New_Limit__c,Volume_Outstanding__c,Front_End_Fee__c,Fee__c,CIS_ID__r.Encrypt_Fullname_TH__c,CIS_ID__r.Encrypt_Fullname_EN__c,CIS_ID__r.Name,Customer_Owner__c,LastModifiedDate,Call_Report_CBS__c,Call_Report_CBS__r.Name,Expected_Income_to_KBank__c,Product_List_CBS__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,CreatedById,(SELECT Id,Product_Name__c,Opportunity_Planning__c,Call_Report_Product_List_Master__r.Is_Active__c,Call_Report_Product_List_Master__r.Is_Active_Fee__c,Call_Report_Product_List_Master__r.Is_Active_Front_End_Fee__c,Call_Report_Product_List_Master__r.Is_Active_New_Limit__c,Call_Report_Product_List_Master__r.Is_Active_Volume_Outstanding__c,Call_Report_Product_List_Master__r.Is_not_Allow_0_Fee__c,Call_Report_Product_List_Master__r.Is_not_Allow_0_Front_End_Fee__c,Call_Report_Product_List_Master__r.Is_not_Allow_0_New_Limit__c,Call_Report_Product_List_Master__r.Is_not_Allow_0_Volume_Outstanding__c,Call_Report_Product_List_Master__r.Is_Required_Fee__c,Call_Report_Product_List_Master__r.Is_Required_Front_End_Fee__c,Call_Report_Product_List_Master__r.Is_Required_New_Limit__c,Call_Report_Product_List_Master__r.Is_Required_Volume_Outstanding__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id IN:opIdSet ORDER BY CIS_ID__r.CIS__c ASC];
    }   

    public List<OppPlanningWrapper> createWrapper(List<Opportunity_Planning__c> oldOppPlanList){
        List<OppPlanningWrapper> oppWrapperList = new List<OppPlanningWrapper>();
        for(Opportunity_Planning__c oldOppPlan : oldOppPlanList){
            OppPlanningWrapper oppWrapper = new OppPlanningWrapper();
            Opportunity_Planning__c newOppPlan = new Opportunity_Planning__c();
            newOppPlan.ID = oldOppPlan.ID;
            newOppPlan.Product_Type__c = oldOppPlan.Product_Type__c;

            if(oldOppPlan.CIS_ID__r.Encrypt_Fullname_TH__c != null) {
                oldOppPlan.Customer_Name__c = Label.MashupUrl + oldOppPlan.CIS_ID__r.Encrypt_Fullname_TH__c;    
            } else {
                oldOppPlan.Customer_Name__c = Label.MashupUrl + oldOppPlan.CIS_ID__r.Encrypt_Fullname_EN__c;
            }

            newOppPlan.Customer_Name__c = oldOppPlan.Customer_Name__c;            
            newOppPlan.Call_Report_CBS__c = oldOppPlan.Call_Report_CBS__c;
            newOppPlan.Expected_Income_to_KBank__c = oldOppPlan.Expected_Income_to_KBank__c;
            newOppPlan.Expected_LimitVolume_Amount__c = oldOppPlan.Expected_LimitVolume_Amount__c;
            newOppPlan.Project_Size__c = oldOppPlan.Project_Size__c;
            newOppPlan.Status__c = oldOppPlan.Status__c;
            newOppPlan.Remark__c = oldOppPlan.Remark__c;
            newOppPlan.Add_to_Existing_Opportunity__c = oldOppPlan.Add_to_Existing_Opportunity__c;
            newOppPlan.Product_Type__c = oldOppPlan.Product_Type__c;
            newOppPlan.Product_List_CBS__c = oldOppPlan.Product_List_CBS__c;

            newOppPlan.Fee__c = oldOppPlan.Fee__c;
            newOppPlan.New_Limit__c = oldOppPlan.New_Limit__c;
            newOppPlan.Front_End_Fee__c = oldOppPlan.Front_End_Fee__c;
            newOppPlan.Volume_Outstanding__c = oldOppPlan.Volume_Outstanding__c;
            newOppPlan.Add_to_Existing_Opportunity__c = oldOppPlan.Add_to_Existing_Opportunity__c;
            oppWrapper.oldOppPlanning = oldOppPlan;
            oppWrapper.newOppPlanning = newOppPlan;
            oppWrapper.targetAccount = new Account(Id = oldOppPlan.CIS_ID__c, Name = oldOppPlan.CIS_ID__r.Name);

            List<Opportunity_Planning_Line_Item__c> oppPlanLineItems = oldOppPlan.Opportunity_Planning_Line_Items__r;
            oppWrapper.opportunityPlanningLineItem = oppPlanLineItems;
            oppPlanLineItems.sort();

            String allProductName ='';
            Integer countProductStringList = 0;
            Integer porductListCount = oppPlanLineItems.size();
            for(Opportunity_Planning_Line_Item__c eachLineItem: oppPlanLineItems){
                if(countProductStringList == porductListCount-1){
                    allProductName += eachLineItem.Product_Name__c;
                }
                else{
                    allProductName += eachLineItem.Product_Name__c+', ';
                }
                countProductStringList++;
            }

            oppWrapper.isProductListMasterActive = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Active__c;
            oppWrapper.isActiveNewLimit = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Active_New_Limit__c;
            oppWrapper.isActiveVolOut = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Active_Volume_Outstanding__c;
            oppWrapper.isActiveFrontEndFee = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Active_Front_End_Fee__c;
            oppWrapper.isActiveFee = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Active_Fee__c;

            oppWrapper.isRequiredNewLimit = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Required_New_Limit__c;
            oppWrapper.isRequiredVolOut = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Required_Volume_Outstanding__c;
            oppWrapper.isRequiredFrontEndFee = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Required_Front_End_Fee__c;
            oppWrapper.isRequiredFee = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_Required_Fee__c;

            oppWrapper.isNewLimitNotAllow0 = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_not_Allow_0_New_Limit__c;
            oppWrapper.isVolOutNotAllow0 = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_not_Allow_0_Volume_Outstanding__c;
            oppWrapper.isFrontEndFeeNotAllow0 = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_not_Allow_0_Front_End_Fee__c;
            oppWrapper.isFeeNotAllow0 = oppPlanLineItems[0].Call_Report_Product_List_Master__r.Is_not_Allow_0_Fee__c;

            oppWrapper.productName = allProductName;

            oppWrapper.isWin = false;            
            oppWrapper.callReportNo = oldOppPlan.Call_Report_CBS__r.Name;

            String userFName = UserInfo.getName();
            if(editable == true && oldOppPlan.Customer_Owner__c == userFName && (oldOppPlan.Status__c == GlobalConstants.OPP_PLAN_EXPLORE ||oldOppPlan.Status__c == GlobalConstants.OPP_PLAN_WORK_IN_PROCESS ||oldOppPlan.Status__c == GlobalConstants.OPP_PLAN_PITCHING ||oldOppPlan.Status__c == GlobalConstants.OPP_PLAN_NEGOTIATION)){
                oppWrapper.canEdit = true;
            }else{
                oppWrapper.canEdit = false;
            }
            if(oldOppPlan.Add_to_Existing_Opportunity__c != null){
                oppWrapper.hasExistOpp = true;
            }else{
                oppWrapper.hasExistOpp = false;
            }

            if(mapAllGroupedOppPlanning.containsKey(oppWrapper.newOppPlanning.Id)){
                oppWrapper.isGrouped = true;
                oppWrapper.isChecked = true;
                oppWrapper.canEdit = false;
                oppWrapper.newOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
                apexpages.currentpage().getParameters().put('clickedId',oppWrapper.newOppPlanning.Id);
                checkWin();
            }else{
                oppWrapper.isChecked = false;
                oppWrapper.isGrouped = false;
            }

            if(this.oppPlanningCSMapByOppPlanType.containsKey(oppWrapper.newOppPlanning.Product_Type__c)){
                Opportunity_Planning_Type__c oppPlanCS = oppPlanningCSMapByOppPlanType.get(oppWrapper.newOppPlanning.Product_Type__c);
                oppWrapper.allowEditAmont = oppPlanCS.Allow_Edit_Amount__c;
                oppWrapper.allowGrouping = oppPlanCS.Allow_Grouping__c;
                oppWrapper.allowAddtoExistingOpp = oppWrapper.allowGrouping;
            }

            oppWrapperList.add(oppWrapper);
        }
        return oppWrapperList;
    } 
    public void editAll(){
        editable = true;
        String userFullName = UserInfo.getName();
        for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperList){
            String eachOppPlanStatus = eachOppPlan.oldOppPlanning.Status__c;
            if(eachOppPlan.oldOppPlanning.Customer_Owner__c == userFullName && (eachOppPlanStatus == GlobalConstants.OPP_PLAN_EXPLORE ||eachOppPlanStatus == GlobalConstants.OPP_PLAN_WORK_IN_PROCESS ||eachOppPlanStatus == GlobalConstants.OPP_PLAN_PITCHING||eachOppPlanStatus == GlobalConstants.OPP_PLAN_NEGOTIATION)){
                eachOppPlan.canEdit = true;
            }else{
                eachOppPlan.canEdit = false;
            }
        }
    }
    public PageReference saveAll(){
        editable = true;
        sendStatus = true;
        errorRender = false;

        returnedOppIdSet = new Set<Id>();
        oppIdStringList = new List<String>();

        try{
            Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>();
            Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>();
            Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>();
            List<Opportunity_Planning__c> toUpdateOppPlanList = new List<Opportunity_Planning__c>();
            Map<Id,OppPlanningWrapper> oppPlanningWrapperIncludeGroupMapByOppPlanId = new Map<Id,OppPlanningWrapper>();
            
            for(OppPlanningWrapper eachOppPlanWrap : oppPlanningWrapperList){
                oppPlanningWrapperIncludeGroupMapByOppPlanId.put(eachOppPlanWrap.newOppPlanning.Id,eachOppPlanWrap);
            }
            for(Integer index : mapGroupingOppPlanningService.keySet()){
                if(mapGroupingOppPlanningService.get(index).isGroup){
                    Id addExistingOppId = mapGroupingOppPlanningService.get(index).oppPlanningPageWrapperList[0].newOppPlanning.Add_to_Existing_Opportunity__c;
                    for(OppPlanningWrapper eachOppPlanWrap : mapGroupingOppPlanningService.get(index).oppPlanningPageWrapperList){
                        eachOppPlanWrap.newOppPlanning.Add_to_Existing_Opportunity__c = addExistingOppId;
                        oppPlanningWrapperIncludeGroupMapByOppPlanId.put(eachOppPlanWrap.newOppPlanning.Id,eachOppPlanWrap);
                    }
                }
            }

            for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperIncludeGroupMapByOppPlanId.values()){
                if(eachOppPlan.isChecked && !eachOppPlan.isGrouped){
                    errorRender = true;
                    errorMessage = System.Label.Opp_Plan_Not_Grouped_Warning_Message;
                    sendStatus = false;
                }
            }

            Map<String,String> mapBusinessCodeByOppPlanId = new Map<String,String>();
            for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperIncludeGroupMapByOppPlanId.values()){
                Opportunity_Planning__c toUpdateOppPlan = new Opportunity_Planning__c();
                Opportunity_Planning__c oldOppPlanning = new Opportunity_Planning__c();

                toUpdateOppPlan = eachOppPlan.newOppPlanning;
                oldOppPlanning = eachOppPlan.oldOppPlanning;

                Boolean isValidatePass = validateWithProductListMaster(eachOppPlan);
                if(!isValidatePass){
                    sendStatus = false;
                }
                if(isValidatePass){
                    if(checkChange(eachOppPlan)) {
                        toUpdateOppPlanList.add(toUpdateOppPlan);
                    }

                    if(toUpdateOppPlan.Status__c != oldOppPlanning.Status__c){
                        if(toUpdateOppPlan.Call_Report_CBS__c != null) {
                            if(!oppPlanningMapByCallReport.containsKey(toUpdateOppPlan.Call_Report_CBS__c))
                                oppPlanningMapByCallReport.put(toUpdateOppPlan.Call_Report_CBS__c, new List<Opportunity_Planning__c>());

                            oppPlanningMapByCallReport.get(toUpdateOppPlan.Call_Report_CBS__c).add(toUpdateOppPlan);
                            oppLineItemMapByOppPlanning.put(toUpdateOppPlan.Id, eachOppPlan.opportunityPlanningLineItem);
                            accountNameMapByOppPlanning.put(toUpdateOppPlan.Id, eachOppPlan.targetAccount);
                            mapBusinessCodeByOppPlanId.put(toUpdateOppPlan.Id, oldOppPlanning.CIS_ID__r.Customer_s_Business_Code__c);
                        }
                        else{
                            errorRender = true;
                            errorMessage = 'This Opportunity ('+ toUpdateOppPlan.Id + ') Planning requires Call Report Number';
                            sendStatus = false; 
                        }    
                    }
                }             
            }

            if(!oppPlanningMapByCallReport.isEmpty() && sendStatus){
                returnedOppIdSet = OpportunityPlanning_Service.createOpportunityFromOpportunityTab(oppPlanningMapByCallReport, oppLineItemMapByOppPlanning, accountNameMapByOppPlanning, mapAllGroupedOppPlanning, mapGroupingOppPlanningService,mapBusinessCodeByOppPlanId);
            }

            if(sendStatus){
                update toUpdateOppPlanList;
                for(Id eachOppId : returnedOppIdSet){
                    oppIdStringList.add(eachOppId);
                }
                editable = false;
                FilterOpp();
            }
            mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
            mapAllGroupedOppPlanning = new Map<String,OppPlanningWrapper>();
            return null;
        }catch(Exception e){
            System.debug('Exception ='+e.getStackTraceString());
            errorRender = true;
            errorMessage = e.getMessage();
            return null;
        }
    }
    public Boolean validateWithProductListMaster(OppPlanningWrapper eachOppWrapper){
        Boolean isValidatePass = true;
        String msgRequiredField = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
        String msgMoreValueField = ExceptionMessage.ZERO_IS_NOT_ALLOWED;
        String productNameforCheck = eachOppWrapper.productName;
        Opportunity_Planning__c newEachOppPlanning = eachOppWrapper.newOppPlanning;
        Opportunity_Planning__c oldEachOppPlanning = eachOppWrapper.oldOppPlanning;
        String productTypeforCheck = newEachOppPlanning.Product_Type__c;

        eachOppWrapper.errorMsgNewLimit = '&nbsp;';
        eachOppWrapper.errorMsgVolOut = '&nbsp;';
        eachOppWrapper.errorMsgFronEndFee = '&nbsp;';
        eachOppWrapper.errorMsgFee = '&nbsp;';

        if(eachOppWrapper.allowEditAmont){
            if(eachOppWrapper.isActiveNewLimit && eachOppWrapper.isRequiredNewLimit && newEachOppPlanning.New_Limit__c == null){
                isValidatePass = false;
                eachOppWrapper.errorMsgNewLimit = msgRequiredField;
            }else if(eachOppWrapper.isActiveNewLimit && eachOppWrapper.isNewLimitNotAllow0 && newEachOppPlanning.New_Limit__c == 0){
                isValidatePass = false;
                eachOppWrapper.errorMsgNewLimit = msgMoreValueField;
            }

            if(eachOppWrapper.isActiveVolOut && eachOppWrapper.isRequiredVolOut  && newEachOppPlanning.Volume_Outstanding__c == null){
                isValidatePass = false;
                eachOppWrapper.errorMsgVolOut = msgRequiredField;
            }else if(eachOppWrapper.isActiveVolOut && eachOppWrapper.isVolOutNotAllow0 && newEachOppPlanning.Volume_Outstanding__c == 0){
                isValidatePass = false;
                eachOppWrapper.errorMsgVolOut = msgMoreValueField;
            }

            if(eachOppWrapper.isActiveFrontEndFee && eachOppWrapper.isRequiredFrontEndFee  && newEachOppPlanning.Front_End_Fee__c == null){
                isValidatePass = false;
                eachOppWrapper.errorMsgFronEndFee = msgRequiredField;
            }else if(eachOppWrapper.isActiveFrontEndFee && eachOppWrapper.isFrontEndFeeNotAllow0 && newEachOppPlanning.Front_End_Fee__c == 0){
                isValidatePass = false;
                eachOppWrapper.errorMsgFronEndFee = msgMoreValueField;
            }

            if(eachOppWrapper.isActiveFee && eachOppWrapper.isRequiredFee  && newEachOppPlanning.Fee__c == null){
                isValidatePass = false;
                eachOppWrapper.errorMsgFee = msgRequiredField;
            }else if(eachOppWrapper.isActiveFee && eachOppWrapper.isFeeNotAllow0 && newEachOppPlanning.Fee__c == 0){
                isValidatePass = false;
                eachOppWrapper.errorMsgFee = msgMoreValueField;
            }
        }

        if(!isValidatePass){
            eachOppWrapper.hasError = true;
        }else{
            eachOppWrapper.hasError = false;
        }
        return isValidatePass;
    }
    public Boolean checkChange(OppPlanningWrapper eachOppWrapper){
        Opportunity_Planning__c newEachOppPlanning = new Opportunity_Planning__c();
        Opportunity_Planning__c oldEachOppPlanning = new Opportunity_Planning__c();
        newEachOppPlanning = eachOppWrapper.newOppPlanning;
        oldEachOppPlanning = eachOppWrapper.oldOppPlanning;

        if(newEachOppPlanning.Status__c != oldEachOppPlanning.Status__c)
            return true;
        if(newEachOppPlanning.Add_to_Existing_Opportunity__c != oldEachOppPlanning.Add_to_Existing_Opportunity__c)
            return true;
        if(newEachOppPlanning.Remark__c != oldEachOppPlanning.Remark__c)
            return true;
        if(newEachOppPlanning.New_Limit__c != oldEachOppPlanning.New_Limit__c)
            return true;
        if(newEachOppPlanning.Volume_Outstanding__c != oldEachOppPlanning.Volume_Outstanding__c)
            return true;
        if(newEachOppPlanning.Front_End_Fee__c != oldEachOppPlanning.Front_End_Fee__c)
            return true;
        if(newEachOppPlanning.Fee__c != oldEachOppPlanning.Fee__c)
            return true;
        return false;
    }
    public void cancel(){
        editable = false;

        countOppPlanningResult = 0;
        currentRangePage = '';
        startIndex = 0;
        pointerIndex = 0;
        endIndex = pageSize;

        unGroupAllOppPlanning();
        FilterOpp();
        editable = false;
        errorRender = false;
        countingChecked();
    }

    public List<OppPlanningWrapper> PageHandler(Set<Id> oppPlanIdSet){
        List<OppPlanningWrapper> returnedPortionOppPlanWrapper = new List<OppPlanningWrapper>();
        countOppPlanningResult = oppPlanningOld.size();
        allOppPlanningWrapper = new List<Id>(oppPlanIdSet);
        if(endIndex > allOppPlanningWrapper.size()){
            endIndex = allOppPlanningWrapper.size();
        }
        if(!renderTableFilterCis){
            Set<Id> newSetOp = new Set<Id>();
            for(Integer i = 0; i < endIndex ; i++){
                newSetOp.add(allOppPlanningWrapper[i]);
            }
            returnedPortionOppPlanWrapper = createWrapper(additionalQuery(newSetOp));

            currentRangePage = '1'+'-'+endIndex+' of '+oppPlanIdSet.size();
            if(countOppPlanningResult <= pageSize){
                nextRender = false;
                prevRender = false;
                endIndex = countOppPlanningResult;
                currentRangePage = '1'+'-'+endIndex+' of '+oppPlanIdSet.size();
            }else{
                nextRender = true;
                prevRender = false;  
            }
            
            if(allOppPlanningWrapper.size() == 0){
                currentRangePage = '0 of 0';
            }
            pageOf = 1;
            if((allOppPlanningWrapper.size()/pageSize == 0 || allOppPlanningWrapper.size()/pageSize == 1) && allOppPlanningWrapper.size()<= pageSize){
                totalPage = 1;
            }
            else{
                totalPage = (Integer)((allOppPlanningWrapper.size()/Decimal.valueOf(pageSize)).round(System.RoundingMode.CEILING));
            }        
            pageIndex = 'Page '+pageOf+' of '+totalPage;
        }else{
            returnedPortionOppPlanWrapper = createWrapper(additionalQuery(new Set<Id>(allOppPlanningWrapper)));
        }
        return returnedPortionOppPlanWrapper;
    }
    public void checkBeforeNext(){
        for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperList){
            if(checkChange(eachOppPlan) && !eachOppPlan.isGrouped){
                hasChangeBeforeNext = true;
                break;
            }
        }
        if(hasChangeBeforeNext == false){
            Next();  
        }
    }
    public void Next(){
        hasChangeBeforeNext = false;
        pointerIndex = pointerIndex + pageSize;
        startIndex = startIndex + pageSize;
        endIndex = endIndex + pageSize;
        Integer startPage = startIndex+1;
        currentRangePage = startPage+'-'+endIndex+' of '+allOppPlanningWrapper.size();
        if(startIndex < countOppPlanningResult){
            if(countOppPlanningResult < endIndex){
                endIndex = countOppPlanningResult;
                nextRender = false;
                currentRangePage = startPage+'-'+endIndex+' of '+endIndex;
            }
            if(countOppPlanningResult == endIndex){
                nextRender = false;
            }
            Set<Id> newSetOp = new Set<Id>();
            for(Integer i = startIndex ; i < endIndex ; i++){
                newSetOp.add(allOppPlanningWrapper[i]);
            }
            prevRender = true;
            oppPlanningWrapperList = createWrapper(additionalQuery(newSetOp));
        }
        pageOf++;
        pageIndex = 'Page '+pageOf+' of '+totalPage;
        errorRender = false;
    }
    public void checkBeforePrev(){
        for(OppPlanningWrapper eachOppPlan : oppPlanningWrapperList){
            if(checkChange(eachOppPlan) && !eachOppPlan.isGrouped){
                hasChangeBeforePrev = true;
                break;
            }
        }
        if(hasChangeBeforePrev == false){
            Prev();  
        }
    }
    public void Prev(){
        hasChangeBeforePrev = false;
        
        pointerIndex = pointerIndex - pageSize;
        startIndex = pointerIndex;
        endIndex = startIndex + pageSize;
        Integer startPage = startIndex+1;
        currentRangePage = startPage+'-'+endIndex+' of '+allOppPlanningWrapper.size();
        if(startIndex == 0){
            prevRender = false;            
        }
        Set<Id> newSetOp = new Set<Id>();
        for(Integer i = startIndex ; i < endIndex ; i++){
            newSetOp.add(allOppPlanningWrapper[i]);
        }
        nextRender = true;
        pageOf--;
        pageIndex = 'Page '+pageOf+' of '+totalPage;
        oppPlanningWrapperList = createWrapper(additionalQuery(newSetOp));

        errorRender = false;
    }
    public void cancelChange(){
        hasChangeBeforePrev = false;
        hasChangeBeforeNext = false;
        hasChangeBeforeGo = false;
    }
    public void checkWin(){
        errorRender = false;
        String clickedId = apexpages.currentpage().getParameters().get('clickedId');
        OppPlanningWrapper selectedRecord;
        for(OppPlanningWrapper eachWrapper : oppPlanningWrapperList){
            if(eachWrapper.oldOppPlanning.Id == clickedId){
                selectedRecord = eachWrapper;
                break;
            }
        }
        if(selectedRecord!=null){
            String currentStatus = selectedRecord.newOppPlanning.Status__c;
            if(currentStatus == GlobalConstants.OPP_PLAN_WIN_MANDATE){
                selectedRecord.isWin = true;
            }else{
                selectedRecord.isWin = false;
                selectedRecord.isChecked = false;
                selectedRecord.newOppPlanning.Add_to_Existing_Opportunity__c = null;
            }
        }
    }
    public class OppPlanningWrapper{
        public Opportunity_Planning__c oldOppPlanning {get;set;}
        public Opportunity_Planning__c newOppPlanning {get;set;}
        public Boolean isWin {get;set;}
        public String productName {get;set;}
        public Account targetAccount {get;set;}
        public List<Opportunity_Planning_Line_Item__c> opportunityPlanningLineItem {get;set;}
        public String callReportNo {get;set;}
        public String errorMsgNewLimit {get;set;}
        public String errorMsgVolOut {get;set;}
        public String errorMsgFronEndFee {get;set;}
        public String errorMsgFee {get;set;}
        
        public Boolean hasError {get;set;}
        public Boolean canEdit {get;set;}
        public Boolean hasExistOpp {get;set;}
        public Boolean isChecked {get;set;}
        public Boolean isGrouped {get;set;}

        public Boolean isProductListMasterActive {get;set;}
        public Boolean isActiveNewLimit {get;set;}
        public Boolean isActiveVolOut {get;set;}
        public Boolean isActiveFrontEndFee {get;set;}
        public Boolean isActiveFee {get;set;}

        public Boolean isNewLimitNotAllow0 {get;set;}
        public Boolean isVolOutNotAllow0 {get;set;}
        public Boolean isFrontEndFeeNotAllow0 {get;set;}
        public Boolean isFeeNotAllow0 {get;set;}

        public Boolean isRequiredNewLimit {get;set;}
        public Boolean isRequiredVolOut {get;set;}
        public Boolean isRequiredFrontEndFee {get;set;}
        public Boolean isRequiredFee {get;set;}


        public Boolean allowEditAmont {get;set;}
        public Boolean allowAddtoExistingOpp {get;set;}
        public Boolean allowGrouping {get;set;}

        public Boolean getRenderCheckBox(){
            if(canEdit && newOppPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE && allowGrouping){
                return true;
            }
            return false; 
        }

        public Boolean getRenderNewLimit(){
            if(canEdit && isActiveNewLimit && allowEditAmont){
                return true;
            }
            return false;
        }

        public Boolean getRenderVolumeOutstanding(){
            if(canEdit && isActiveVolOut && allowEditAmont){
                return true;
            }
            return false;
        }
        public Boolean getRenderFrontEndFee(){
            if(canEdit && isActiveFrontEndFee && allowEditAmont){
                return true;
            }
            return false;
        }
        public Boolean getRenderIncome(){
            if(canEdit && isActiveFee && allowEditAmont){
                return true;
            }
            return false;
        }

        public Boolean getRenderAddtoExistingOppInPutField(){
            if(isWin && !isGrouped && allowAddtoExistingOpp){
                return true;
            }
            return false;
        }

        public Boolean getRenderAddtoExistingOppInPutText(){
            if((!hasExistOpp && !isWin && !isGrouped) || !allowAddtoExistingOpp) {
                return true;
            }
            return false;
        }

    }

    public Integer groupNo {get;set;}
    public Integer groupSize {get{
            return mapGroupingOppPlanningService.values().size();
        } set;}
    public Integer groupIndex {get;set;}
    public Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService {get{
            for(Integer groupKey : mapGroupingOppPlanningService.keySet()){
                if(!mapGroupingOppPlanningService.get(groupKey).isGroup){
                    mapGroupingOppPlanningService.remove(groupKey);
                }
            }
            return mapGroupingOppPlanningService;
        } set;}
    public Map<String,OppPlanningWrapper> mapAllGroupedOppPlanning = new Map<String,OppPlanningWrapper>();

    public void groupOppPlanning(){
        Map<String,OppPlanningWrapper> mapGroupingOppPlanning = new Map<String,OppPlanningWrapper>();
        Boolean isPassCheckDataWithConfig = true;
        for(OppPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
            if(eachOppPlanningWrapper.isChecked && !eachOppPlanningWrapper.isGrouped){
                if(!validateWithProductListMaster(eachOppPlanningWrapper)){
                    isPassCheckDataWithConfig = false;
                }
            }
        }

        if(isPassCheckDataWithConfig){
            for(OppPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
                if(eachOppPlanningWrapper.isChecked && !eachOppPlanningWrapper.isGrouped){
                    mapGroupingOppPlanning.put(eachOppPlanningWrapper.newOppPlanning.Id, eachOppPlanningWrapper);
                    mapAllGroupedOppPlanning.put(eachOppPlanningWrapper.newOppPlanning.Id, eachOppPlanningWrapper);
                }
            }

            if(!mapGroupingOppPlanning.isEmpty()){
                GroupOpportunityPlanningWrapper groupService = new GroupOpportunityPlanningWrapper(mapGroupingOppPlanning.values());
                mapGroupingOppPlanningService.put(groupNo, groupService);
                groupNo++;
            }
        }
    }

    public void unGroupOppPlanning(){
        GroupOpportunityPlanningWrapper groupService = mapGroupingOppPlanningService.get(groupIndex);
        groupService.unGroupedFromOppPlanning(editable);
        Map<Id,OppPlanningWrapper> mapTempOppPlanningWrapper = new Map<Id,OppPlanningWrapper>();
        for(OppPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
            mapTempOppPlanningWrapper.put(eachOppPlanningWrapper.newOppPlanning.Id, eachOppPlanningWrapper);
        }
        for(OppPlanningWrapper eachOppPlanningWrapper : groupService.oppPlanningPageWrapperList){
            if(mapAllGroupedOppPlanning.containsKey(eachOppPlanningWrapper.newOppPlanning.Id)){
                mapAllGroupedOppPlanning.remove(eachOppPlanningWrapper.newOppPlanning.Id);
            }

            if(mapTempOppPlanningWrapper.containsKey(eachOppPlanningWrapper.newOppPlanning.Id)){
                mapTempOppPlanningWrapper.get(eachOppPlanningWrapper.newOppPlanning.Id).isGrouped = false;
                mapTempOppPlanningWrapper.get(eachOppPlanningWrapper.newOppPlanning.Id).canEdit = true;
                mapTempOppPlanningWrapper.get(eachOppPlanningWrapper.newOppPlanning.Id).isChecked = false;
            }
        }
        countingChecked();
    }

    public void unGroupAllOppPlanning(){
        for(Integer eachGroupKey : mapGroupingOppPlanningService.keySet()){
            groupIndex = eachGroupKey;
            unGroupOppPlanning();
        }
    }

    public void countingChecked(){
        countChecked = 0;
        for(OppPlanningWrapper eachOppPlanningWrapperList : oppPlanningWrapperList){
            if(eachOppPlanningWrapperList.isChecked && !eachOppPlanningWrapperList.isGrouped){
                countChecked++;
            }
        }
    }
}