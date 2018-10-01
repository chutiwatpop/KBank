global with sharing class SME_Performance_Util {
    private List<Call_Report__c> callReportList;
    private Map<String,List<String>> userExIdMapTeam;
    private Map<String,User_Extension__c> userExMap;
    private Map<String,Team_Structure__c> teamMap;
    private Map<String,User_Extension__c> userMapExt;
    private Map<String,Monthly_Performance__c> monthlyMap;
    private Boolean runMontly = false;

    private Date todayDateFromNow;
    private Integer currentYear;

    global SME_Performance_Util(Map<String,User_Extension__c> userExMap,Map<String,Team_Structure__c> teamMap){

        this.userExMap = userExMap;
        this.teamMap = teamMap;
        this.mappingUser();
        this.initialValue();

        DateTime dT = System.now();

        //start cr019 penetrate report
        if(isLoadRecordLastYear()){
            todayDateFromNow = date.newinstance(dT.year()-1, dT.month(), dT.day());
        }else{
            todayDateFromNow = date.newinstance(dT.year(), dT.month(), dT.day());
        }
        //end cr019 penetrate report
        currentYear = GlobalUtility.getYearInBuddhistCalendar(todayDateFromNow);
    }
    
    //start cr019 penetrate report
    private Boolean isLoadRecordLastYear(){
        if(Label.Last_Year_Performance != null && Label.Last_Year_Performance.equalsIgnoreCase('true') && !Test.isRunningTest()){
            return true;
        }
        return false;
    }
    //end cr019 penetrate report

    private void mappingUser(){
        userMapExt = new Map<String,User_Extension__c>();
        for(User_Extension__c eachExt : userExMap.values()){
            userMapExt.put(eachExt.User__c, eachExt);
        }
    }
    private void initialValue(){
        
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Contacted_Customer_Other__c = 0;
            eachExt.Contacted_Customer_Pool__c = 0;
            eachExt.Contacted_Customer_Port__c = 0;
            eachExt.Customer_Other__c = 0;
            eachExt.Customer_Pool__c = 0;
            eachExt.Customer_Port__c = 0;
            eachExt.Total_visited_Customer__c = 0;
            eachExt.Contacted_Customer_Other_My_Penetrate__c = 0;
            eachExt.Contacted_Customer_Pool_My_Penetrate__c = 0;
            eachExt.Contacted_Customer_Port_My_Penetrate__c = 0;
            
            //start cr019 penetrate report
            eachExt.Contacted_Other_CustCall__c = 0;
            eachExt.Contacted_Other_CustF2F__c = 0;
            eachExt.Contacted_Pool_CustCall__c = 0;
            eachExt.Contacted_Pool_CustF2F__c = 0;
            eachExt.Contacted_Port_CustCall__c = 0;
            eachExt.Contacted_Port_CustF2F__c = 0;
            eachExt.My_Penetrate_Contacted_Other_CustCall__c = 0;
            eachExt.My_Penetrate_Contacted_Other_CustF2F__c = 0;
            eachExt.My_Penetrate_Contacted_Pool_CustCall__c = 0;
            eachExt.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
            eachExt.My_Penetrate_Contacted_Port_CustCall__c = 0;
            eachExt.My_Penetrate_Contacted_Port_CustF2F__c = 0;
            //end cr019 penetrate report
        }
        for(Team_Structure__c eachStructure : teamMap.values()){
            eachStructure.Contacted_Customer_Other__c = 0;
            eachStructure.Contacted_Customer_Pool__c = 0;
            eachStructure.Contacted_Customer_Port__c = 0;
            eachStructure.Customer_Other__c = 0;
            eachStructure.Customer_Pool__c = 0;
            eachStructure.Customer_Port__c = 0;
            eachStructure.Total_visited_Customer__c = 0;
            eachStructure.Contacted_Customer_Other_My_Penetrate__c = 0;
            eachStructure.Contacted_Customer_Pool_My_Penetrate__c = 0;
            eachStructure.Contacted_Customer_Port_My_Penetrate__c = 0;
            
            //start cr019 penetrate report
            eachStructure.Contacted_Other_CustCall__c = 0;
            eachStructure.Contacted_Other_CustF2F__c = 0;
            eachStructure.Contacted_Pool_CustCall__c = 0;
            eachStructure.Contacted_Pool_CustF2F__c = 0;
            eachStructure.Contacted_Port_CustCall__c = 0;
            eachStructure.Contacted_Port_CustF2F__c = 0;
            eachStructure.My_Penetrate_Contacted_Other_CustCall__c = 0;
            eachStructure.My_Penetrate_Contacted_Other_CustF2F__c = 0;
            eachStructure.My_Penetrate_Contacted_Pool_CustCall__c = 0;
            eachStructure.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
            eachStructure.My_Penetrate_Contacted_Port_CustCall__c = 0;
            eachStructure.My_Penetrate_Contacted_Port_CustF2F__c = 0;
            //end cr019 penetrate report
        }
    }
    public void setCallReportList(List<Call_Report__c> callReportList){
        this.callReportList = callReportList;
    }
    public void setMonthlyMap(Map<String,Monthly_Performance__c> monthly_Map){
        this.runMontly = true;
        this.monthlyMap = monthly_Map;
        String exKey;
        Monthly_Performance__c tmpModel;

        for(Monthly_Performance__c eachMonthly : this.monthlyMap.values()){
            eachMonthly.Contacted_Customer_Other__c = 0;
            eachMonthly.Contacted_Customer_Pool__c = 0;
            eachMonthly.Contacted_Customer_Port__c = 0;
            eachMonthly.Customer_Other__c = 0;
            eachMonthly.Customer_Pool__c = 0;
            eachMonthly.Customer_Port__c = 0;
            eachMonthly.Total_visited_Customer__c = 0;
            eachMonthly.Contacted_Customer_Other_My_Penetrate__c = 0;
            eachMonthly.Contacted_Customer_Pool_My_Penetrate__c = 0;
            eachMonthly.Contacted_Customer_Port_My_Penetrate__c = 0;
            
            //start cr019 penetrate report
            eachMonthly.Contacted_Other_CustCall__c = 0;
            eachMonthly.Contacted_Other_CustF2F__c = 0;
            eachMonthly.Contacted_Pool_CustCall__c = 0;
            eachMonthly.Contacted_Pool_CustF2F__c = 0;
            eachMonthly.Contacted_Port_CustCall__c = 0;
            eachMonthly.Contacted_Port_CustF2F__c = 0;
            eachMonthly.My_Penetrate_Contacted_Other_CustCall__c = 0;
            eachMonthly.My_Penetrate_Contacted_Other_CustF2F__c = 0;
            eachMonthly.My_Penetrate_Contacted_Pool_CustCall__c = 0;
            eachMonthly.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
            eachMonthly.My_Penetrate_Contacted_Port_CustCall__c = 0;
            eachMonthly.My_Penetrate_Contacted_Port_CustF2F__c = 0;
            //end cr019 penetrate report
        }
        for(Team_Structure__c eachStructure : teamMap.values()){
            exKey = eachStructure.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            if(!monthlyMap.containsKey(exKey) && eachStructure.RC_Code__c!=null){
                tmpModel = new Monthly_Performance__c();
                tmpModel.External_ID__c = exKey;
                tmpModel.Contacted_Customer_Other__c = 0;
                tmpModel.Contacted_Customer_Pool__c = 0;
                tmpModel.Contacted_Customer_Port__c = 0;
                tmpModel.Customer_Other__c = 0;
                tmpModel.Customer_Pool__c = 0;
                tmpModel.Customer_Port__c = 0;
                tmpModel.Total_visited_Customer__c = 0;
                tmpModel.Contacted_Customer_Other_My_Penetrate__c = 0;
                tmpModel.Contacted_Customer_Pool_My_Penetrate__c = 0;
                tmpModel.Contacted_Customer_Port_My_Penetrate__c = 0;
                
                //start cr019 penetrate report
                tmpModel.Contacted_Other_CustCall__c = 0;
                tmpModel.Contacted_Other_CustF2F__c = 0;
                tmpModel.Contacted_Pool_CustCall__c = 0;
                tmpModel.Contacted_Pool_CustF2F__c = 0;
                tmpModel.Contacted_Port_CustCall__c = 0;
                tmpModel.Contacted_Port_CustF2F__c = 0;
                tmpModel.My_Penetrate_Contacted_Other_CustCall__c = 0;
                tmpModel.My_Penetrate_Contacted_Other_CustF2F__c = 0;
                tmpModel.My_Penetrate_Contacted_Pool_CustCall__c = 0;
                tmpModel.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
                tmpModel.My_Penetrate_Contacted_Port_CustCall__c = 0;
                tmpModel.My_Penetrate_Contacted_Port_CustF2F__c = 0;
                //end cr019 penetrate report
                monthlyMap.put(exKey, tmpModel);
            }

            if(eachStructure.AH_Name__c!=null){
                exKey = eachStructure.AH_Name__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(!monthlyMap.containsKey(exKey)){
                    tmpModel = new Monthly_Performance__c();
                    tmpModel.External_ID__c = exKey;
                    tmpModel.Contacted_Customer_Other__c = 0;
                    tmpModel.Contacted_Customer_Pool__c = 0;
                    tmpModel.Contacted_Customer_Port__c = 0;
                    tmpModel.Customer_Other__c = 0;
                    tmpModel.Customer_Pool__c = 0;
                    tmpModel.Customer_Port__c = 0;
                    tmpModel.Total_visited_Customer__c = 0;
                    tmpModel.Contacted_Customer_Other_My_Penetrate__c = 0;
                    tmpModel.Contacted_Customer_Pool_My_Penetrate__c = 0;
                    tmpModel.Contacted_Customer_Port_My_Penetrate__c = 0;
                    
                    //start cr019 penetrate report
                    tmpModel.Contacted_Other_CustCall__c = 0;
                    tmpModel.Contacted_Other_CustF2F__c = 0;
                    tmpModel.Contacted_Pool_CustCall__c = 0;
                    tmpModel.Contacted_Pool_CustF2F__c = 0;
                    tmpModel.Contacted_Port_CustCall__c = 0;
                    tmpModel.Contacted_Port_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Other_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Other_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Pool_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Port_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Port_CustF2F__c = 0;
                    //end cr019 penetrate report
                    monthlyMap.put(exKey, tmpModel);
                }
            }
            if(eachStructure.NH_Name__c!=null){
                exKey = eachStructure.NH_Name__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(!monthlyMap.containsKey(exKey)){
                    tmpModel = new Monthly_Performance__c();
                    tmpModel.External_ID__c = exKey;
                    tmpModel.Contacted_Customer_Other__c = 0;
                    tmpModel.Contacted_Customer_Pool__c = 0;
                    tmpModel.Contacted_Customer_Port__c = 0;
                    tmpModel.Customer_Other__c = 0;
                    tmpModel.Customer_Pool__c = 0;
                    tmpModel.Customer_Port__c = 0;
                    tmpModel.Total_visited_Customer__c = 0;
                    tmpModel.Contacted_Customer_Other_My_Penetrate__c = 0;
                    tmpModel.Contacted_Customer_Pool_My_Penetrate__c = 0;
                    tmpModel.Contacted_Customer_Port_My_Penetrate__c = 0;
                    
                    //start cr019 penetrate report
                    tmpModel.Contacted_Other_CustCall__c = 0;
                    tmpModel.Contacted_Other_CustF2F__c = 0;
                    tmpModel.Contacted_Pool_CustCall__c = 0;
                    tmpModel.Contacted_Pool_CustF2F__c = 0;
                    tmpModel.Contacted_Port_CustCall__c = 0;
                    tmpModel.Contacted_Port_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Other_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Other_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Pool_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
                    tmpModel.My_Penetrate_Contacted_Port_CustCall__c = 0;
                    tmpModel.My_Penetrate_Contacted_Port_CustF2F__c = 0;
                    //end cr019 penetrate report
                    monthlyMap.put(exKey, tmpModel);
                }
                
            }
        }
    }
    public Map<String,User_Extension__c> getUserExt(){
        return this.userMapExt;
    }
    public List<User_Extension__c> getFinalUserExt(){
        return this.userMapExt.values();
    }
    public List<Team_Structure__c> getFinalTeam(){
        return this.teamMap.values();
    }
    public List<Monthly_Performance__c> getMonthly(){
        return this.monthlyMap.values();
    }

    public Map<String,String> mappingOwner(List<Call_Report__c> callReportList){
        Map<String,String> callReportMapOwner = new Map<String,String>();
        for(Call_Report__c eachCallReport : callReportList){
            if(eachCallReport.CIS_ID__c!=null && eachCallReport.CIS_ID__r.OwnerId==eachCallReport.Current_Owner_Extension__r.User__c && !callReportMapOwner.containsKey(eachCallReport.CIS_ID__c+''+eachCallReport.CIS_ID__r.OwnerId+''+eachCallReport.Current_Owner_Extension__c))
                callReportMapOwner.put(eachCallReport.CIS_ID__c+''+eachCallReport.CIS_ID__r.OwnerId+''+eachCallReport.Current_Owner_Extension__c,'');
        }

        return callReportMapOwner;
    }
    private void mappingTeam(){
        userExIdMapTeam = new Map<String,List<String>>();
        for(User_Extension__c eachExt : userExMap.values()){
            if(!userExIdMapTeam.containsKey(eachExt.Team_Structure__c))
                userExIdMapTeam.put(eachExt.Team_Structure__c,new List<String>());
            userExIdMapTeam.get(eachExt.Team_Structure__c).add(eachExt.Id);

            if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null){
                if(! userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).AH_Name__c))
                    userExIdMapTeam.put(teamMap.get(eachExt.Team_Structure__c).AH_Name__c,new List<String>());
            
                userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).add(eachExt.Id);
            }

            if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null){
                if(! userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).NH_Name__c))
                    userExIdMapTeam.put(teamMap.get(eachExt.Team_Structure__c).NH_Name__c,new List<String>());
            
                userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).add(eachExt.Id);
            }
            
        }
    }

    public void executeAccount(Account accountObj,Boolean runMontly,Map<String,String> callReportMapOwner){
        String exKey;
        User_Extension__c userExtObj;
        User_Extension__c userExtServiceRmObj;
        Team_Structure__c teamStrucObj;
        Team_Structure__c teamStrucServiceRmObj;
        userExtObj = userMapExt.get(accountObj.OwnerId);
        userExtServiceRmObj = userMapExt.get(accountObj.Service_RM__c);
        teamStrucObj = teamMap.get(userExtObj.Team_Structure__c);
        if(userExtServiceRmObj != null){
            teamStrucServiceRmObj = teamMap.get(userExtServiceRmObj.Team_Structure__c);
        }
                
        if(runMontly){
            exKey = userExtObj.User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;

            if(monthlyMap.containsKey(exKey) && monthlyMap.get(exKey).User__c!=null){
                if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && accountObj.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || (accountObj.Owner.Profile.Name==GlobalConstants.SME_AH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.AH_RC_Code__c) || (accountObj.Owner.Profile.Name==GlobalConstants.SME_NH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.NH_RC_Code__c)) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM)
                    this.stampingMonthly(accountObj,monthlyMap.get(exKey),monthlyMap.get(userMapExt.get(accountObj.Service_RM__c).User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear),callReportMapOwner);
                else this.stampingMonthly(accountObj,monthlyMap.get(exKey),null,callReportMapOwner);
            }
        }

        // start cr019 penetrate report
        if(accountObj.Port_Pool__c != null && accountObj.Port_Pool__c.equalsIgnoreCase(GlobalConstants.PORT)){
            if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                userExtObj.Contacted_Port_CustF2F__c++;
                teamStrucObj.Contacted_Port_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                userExtObj.Contacted_Port_CustCall__c++;
                teamStrucObj.Contacted_Port_CustCall__c++;
            }

            if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                userExtObj.My_Penetrate_Contacted_Port_CustF2F__c++;
                teamStrucObj.My_Penetrate_Contacted_Port_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                userExtObj.My_Penetrate_Contacted_Port_CustCall__c++;
                teamStrucObj.My_Penetrate_Contacted_Port_CustCall__c++;
            }   
        }else if(accountObj.Port_Pool__c != null && accountObj.Port_Pool__c.equalsIgnoreCase(GlobalConstants.POOL)){
            if(accountObj.Service_RM__c != null){
                if(accountObj.OwnerId != accountObj.Service_RM__c && accountObj.Service_RM__r.Profile.Name == GlobalConstants.SME_RM
                    && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || (accountObj.Owner.Profile.Name==GlobalConstants.SME_AH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.AH_RC_Code__c) || (accountObj.Owner.Profile.Name==GlobalConstants.SME_NH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.NH_RC_Code__c)) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                    
                    if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                        userExtServiceRmObj.Contacted_Pool_CustF2F__c++;
                        if(teamStrucServiceRmObj != null){
                            teamStrucServiceRmObj.Contacted_Pool_CustF2F__c++;
                        }
                    }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                        userExtServiceRmObj.Contacted_Pool_CustCall__c++;
                        if(teamStrucServiceRmObj != null){
                            teamStrucServiceRmObj.Contacted_Pool_CustCall__c++;
                        }
                    }

                    if(accountObj.Count_Contacted_CR_My_Pen_Service_F2F__c > 0){
                        userExtServiceRmObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                        userExtServiceRmObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        if(teamStrucServiceRmObj != null){
                            teamStrucServiceRmObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                            teamStrucServiceRmObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        }
                    }else if(accountObj.Count_Contacted_CR_My_Pen_Service_Call__c > 0){
                        userExtServiceRmObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                        userExtServiceRmObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        if(teamStrucServiceRmObj != null){
                            teamStrucServiceRmObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                            teamStrucServiceRmObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        }
                    }
                }else {
                    if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                        userExtObj.Contacted_Pool_CustF2F__c++;
                        teamStrucObj.Contacted_Pool_CustF2F__c++;
                    }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                        userExtObj.Contacted_Pool_CustCall__c++;
                        teamStrucObj.Contacted_Pool_CustCall__c++;
                    }

                    if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                        userExtObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                        teamStrucObj.My_Penetrate_Contacted_Pool_CustF2F__c++;

                        userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;

                    }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                        userExtObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                        teamStrucObj.My_Penetrate_Contacted_Pool_CustCall__c++;

                        userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    }
                }
            }else{
                if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                    userExtObj.Contacted_Pool_CustF2F__c++;
                    teamStrucObj.Contacted_Pool_CustF2F__c++;
                }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                    userExtObj.Contacted_Pool_CustCall__c++;
                    teamStrucObj.Contacted_Pool_CustCall__c++;
                }

                if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                    userExtObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                    teamStrucObj.My_Penetrate_Contacted_Pool_CustF2F__c++;

                    userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    
                }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                    userExtObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                    teamStrucObj.My_Penetrate_Contacted_Pool_CustCall__c++;

                    userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;
                }
            }
        }else if(accountObj.Port_Pool__c==null || accountObj.Port_Pool__c==''){
            if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                userExtObj.Contacted_Other_CustF2F__c++;
                teamStrucObj.Contacted_Other_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                userExtObj.Contacted_Other_CustCall__c++;
                teamStrucObj.Contacted_Other_CustCall__c++;
            }

            if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                userExtObj.My_Penetrate_Contacted_Other_CustF2F__c++;
                teamStrucObj.My_Penetrate_Contacted_Other_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                userExtObj.My_Penetrate_Contacted_Other_CustCall__c++;
                teamStrucObj.My_Penetrate_Contacted_Other_CustCall__c++;
            }
        }
        // end cr019 penetrate report

        if(accountObj.Count_Contacted_Call_Report__c > 0 && accountObj.Number_of_Visited__c!=null && accountObj.Number_of_Visited__c > 0){
            userExtObj.Total_visited_Customer__c++;
            teamStrucObj.Total_visited_Customer__c++;
        }

        if(accountObj.Port_Pool__c== GlobalConstants.PORT && accountObj.Ownership_Text__c== GlobalConstants.OWNERSHIP_PERMANENT){
            userExtObj.Customer_Port__c++;
            teamStrucObj.Customer_Port__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                userExtObj.Contacted_Customer_Port__c++;
                teamStrucObj.Contacted_Customer_Port__c++;

                if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
                    userExtObj.Contacted_Customer_Port_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Port_My_Penetrate__c++;
                }
            }
        }
        if(accountObj.Port_Pool__c== GlobalConstants.POOL && (accountObj.Owner.Profile.Name==GlobalConstants.SME_TM || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH || (accountObj.Owner.Profile.Name==GlobalConstants.SME_RM && accountObj.Ownership_Text__c==GlobalConstants.OWNERSHIP_TEMPORARY))){
            
            if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && accountObj.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || (accountObj.Owner.Profile.Name==GlobalConstants.SME_AH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.AH_RC_Code__c) || (accountObj.Owner.Profile.Name==GlobalConstants.SME_NH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.NH_RC_Code__c)) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                userMapExt.get(accountObj.Service_RM__c).Customer_Pool__c++;
                teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Customer_Pool__c++;
            }else {
                userExtObj.Customer_Pool__c++;
                teamStrucObj.Customer_Pool__c++;
            }

            if(accountObj.Count_Contacted_Call_Report__c > 0){
                if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && accountObj.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || (accountObj.Owner.Profile.Name==GlobalConstants.SME_AH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.AH_RC_Code__c) || (accountObj.Owner.Profile.Name==GlobalConstants.SME_NH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.NH_RC_Code__c)) && accountObj.Count_Contacted_Call_Report__c > 0 && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                    userMapExt.get(accountObj.Service_RM__c).Contacted_Customer_Pool__c++;
                    teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Contacted_Customer_Pool__c++;

                }else {
                    userExtObj.Contacted_Customer_Pool__c++;
                    teamStrucObj.Contacted_Customer_Pool__c++;
                }
            }
        }
        if(accountObj.Port_Pool__c==null && ((accountObj.Ownership_Text__c==null) || (accountObj.Ownership_Text__c== GlobalConstants.OWNERSHIP_TEMPORARY))){
            userExtObj.Customer_Other__c++;
            teamStrucObj.Customer_Other__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                userExtObj.Contacted_Customer_Other__c++;
                teamStrucObj.Contacted_Customer_Other__c++;

                if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
                    userExtObj.Contacted_Customer_Other_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Other_My_Penetrate__c++;
                }
            }
        }
    }
    public void finalTeamTask(){
        
        for(Team_Structure__c eachTeam : teamMap.values()){
            if(eachTeam.NH_Name__c!=null){
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Other__c += eachTeam.Contacted_Customer_Other__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Pool__c += eachTeam.Contacted_Customer_Pool__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Port__c += eachTeam.Contacted_Customer_Port__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Other__c += eachTeam.Customer_Other__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Pool__c += eachTeam.Customer_Pool__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Port__c += eachTeam.Customer_Port__c;
                teamMap.get(eachTeam.NH_Name__c).Total_visited_Customer__c += eachTeam.Total_visited_Customer__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Other_My_Penetrate__c += eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Pool_My_Penetrate__c += eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Port_My_Penetrate__c += eachTeam.Contacted_Customer_Port_My_Penetrate__c;
                
                //start cr019 penetrate report
                teamMap.get(eachTeam.NH_Name__c).Contacted_Other_CustCall__c += eachTeam.Contacted_Other_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Other_CustF2F__c += eachTeam.Contacted_Other_CustF2F__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Pool_CustCall__c += eachTeam.Contacted_Pool_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Pool_CustF2F__c += eachTeam.Contacted_Pool_CustF2F__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Port_CustCall__c += eachTeam.Contacted_Port_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Port_CustF2F__c += eachTeam.Contacted_Port_CustF2F__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Other_CustCall__c += eachTeam.My_Penetrate_Contacted_Other_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Other_CustF2F__c += eachTeam.My_Penetrate_Contacted_Other_CustF2F__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Pool_CustCall__c += eachTeam.My_Penetrate_Contacted_Pool_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Pool_CustF2F__c += eachTeam.My_Penetrate_Contacted_Pool_CustF2F__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Port_CustCall__c += eachTeam.My_Penetrate_Contacted_Port_CustCall__c;
                teamMap.get(eachTeam.NH_Name__c).My_Penetrate_Contacted_Port_CustF2F__c += eachTeam.My_Penetrate_Contacted_Port_CustF2F__c;
                //end cr019 penetrate report
            }
        }
        for(Team_Structure__c eachTeam : teamMap.values()){
            if(eachTeam.AH_Name__c!=null){
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Other__c += eachTeam.Contacted_Customer_Other__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Pool__c += eachTeam.Contacted_Customer_Pool__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Port__c += eachTeam.Contacted_Customer_Port__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Other__c += eachTeam.Customer_Other__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Pool__c += eachTeam.Customer_Pool__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Port__c += eachTeam.Customer_Port__c;
                teamMap.get(eachTeam.AH_Name__c).Total_visited_Customer__c += eachTeam.Total_visited_Customer__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Other_My_Penetrate__c += eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Pool_My_Penetrate__c += eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Port_My_Penetrate__c += eachTeam.Contacted_Customer_Port_My_Penetrate__c;
                
                //start cr019 penetrate report
                teamMap.get(eachTeam.AH_Name__c).Contacted_Other_CustCall__c += eachTeam.Contacted_Other_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Other_CustF2F__c += eachTeam.Contacted_Other_CustF2F__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Pool_CustCall__c += eachTeam.Contacted_Pool_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Pool_CustF2F__c += eachTeam.Contacted_Pool_CustF2F__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Port_CustCall__c += eachTeam.Contacted_Port_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Port_CustF2F__c += eachTeam.Contacted_Port_CustF2F__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Other_CustCall__c += eachTeam.My_Penetrate_Contacted_Other_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Other_CustF2F__c += eachTeam.My_Penetrate_Contacted_Other_CustF2F__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Pool_CustCall__c += eachTeam.My_Penetrate_Contacted_Pool_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Pool_CustF2F__c += eachTeam.My_Penetrate_Contacted_Pool_CustF2F__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Port_CustCall__c += eachTeam.My_Penetrate_Contacted_Port_CustCall__c;
                teamMap.get(eachTeam.AH_Name__c).My_Penetrate_Contacted_Port_CustF2F__c += eachTeam.My_Penetrate_Contacted_Port_CustF2F__c;
                //end cr019 penetrate report
            }
        }

        if(runMontly){
            String exKey;
            for(Team_Structure__c eachTeam : teamMap.values()){
                exKey = eachTeam.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(monthlyMap.containsKey(exKey) && monthlyMap.get(exKey).Team__c!=null){
                    monthlyMap.get(exKey).Contacted_Customer_Other__c = eachTeam.Contacted_Customer_Other__c;
                    monthlyMap.get(exKey).Contacted_Customer_Pool__c = eachTeam.Contacted_Customer_Pool__c;
                    monthlyMap.get(exKey).Contacted_Customer_Port__c = eachTeam.Contacted_Customer_Port__c;
                    monthlyMap.get(exKey).Customer_Other__c = eachTeam.Customer_Other__c;
                    monthlyMap.get(exKey).Customer_Pool__c = eachTeam.Customer_Pool__c;
                    monthlyMap.get(exKey).Customer_Port__c = eachTeam.Customer_Port__c;
                    monthlyMap.get(exKey).Total_visited_Customer__c = eachTeam.Total_visited_Customer__c;
                    monthlyMap.get(exKey).Contacted_Customer_Other_My_Penetrate__c = eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                    monthlyMap.get(exKey).Contacted_Customer_Pool_My_Penetrate__c = eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                    monthlyMap.get(exKey).Contacted_Customer_Port_My_Penetrate__c = eachTeam.Contacted_Customer_Port_My_Penetrate__c;
                    
                    //start cr019 penetrate report
                    monthlyMap.get(exKey).Contacted_Other_CustCall__c = eachTeam.Contacted_Other_CustCall__c;
                    monthlyMap.get(exKey).Contacted_Other_CustF2F__c = eachTeam.Contacted_Other_CustF2F__c;
                    monthlyMap.get(exKey).Contacted_Pool_CustCall__c = eachTeam.Contacted_Pool_CustCall__c;
                    monthlyMap.get(exKey).Contacted_Pool_CustF2F__c = eachTeam.Contacted_Pool_CustF2F__c;
                    monthlyMap.get(exKey).Contacted_Port_CustCall__c = eachTeam.Contacted_Port_CustCall__c;
                    monthlyMap.get(exKey).Contacted_Port_CustF2F__c = eachTeam.Contacted_Port_CustF2F__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Other_CustCall__c = eachTeam.My_Penetrate_Contacted_Other_CustCall__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Other_CustF2F__c = eachTeam.My_Penetrate_Contacted_Other_CustF2F__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Pool_CustCall__c = eachTeam.My_Penetrate_Contacted_Pool_CustCall__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Pool_CustF2F__c = eachTeam.My_Penetrate_Contacted_Pool_CustF2F__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Port_CustCall__c = eachTeam.My_Penetrate_Contacted_Port_CustCall__c;
                    monthlyMap.get(exKey).My_Penetrate_Contacted_Port_CustF2F__c = eachTeam.My_Penetrate_Contacted_Port_CustF2F__c;
                    //end cr019 penetrate report
                }
            }
        }
    }
    public void stampingMonthly(Account accountObj,Monthly_Performance__c monthlyObj,Monthly_Performance__c monthlyServiceObj,Map<String,String> callReportMapOwner){
        if(accountObj.Count_Contacted_Call_Report__c > 0 && accountObj.Number_of_Visited__c!=null && accountObj.Number_of_Visited__c > 0)
            monthlyObj.Total_visited_Customer__c++;

        if(accountObj.Port_Pool__c==GlobalConstants.PORT && accountObj.Ownership_Text__c==GlobalConstants.OWNERSHIP_PERMANENT){
            monthlyObj.Customer_Port__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                monthlyObj.Contacted_Customer_Port__c++;

                if(monthlyObj.User__c!=null){
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+monthlyObj.User__c))
                        monthlyObj.Contacted_Customer_Port_My_Penetrate__c++;
                }
            }
        }
       
        if(accountObj.Port_Pool__c== GlobalConstants.POOL){
                if(monthlyServiceObj!=null){
                    monthlyServiceObj.Customer_Pool__c++;
                }else monthlyObj.Customer_Pool__c++;

                if(accountObj.Count_Contacted_Call_Report__c > 0){
                    
                    if(monthlyServiceObj!=null){
                        monthlyServiceObj.Contacted_Customer_Pool__c++;
                    }else {
                        monthlyObj.Contacted_Customer_Pool__c++;
                    }
                    if(monthlyObj.User__c!=null ){
                            if(monthlyServiceObj!=null && (accountObj.Count_Contacted_CR_My_Pen_Service_Call__c > 0 || accountObj.Count_Contacted_CR_My_Pen_Service_F2F__c > 0)){
                                monthlyServiceObj.Contacted_Customer_Pool_My_Penetrate__c++;
                            }else if(monthlyServiceObj == null && (accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0 || accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0)){
                                monthlyObj.Contacted_Customer_Pool_My_Penetrate__c++;
                            }
                    }
                }
        }
        if(accountObj.Port_Pool__c==null && ((accountObj.Ownership_Text__c==null) || (accountObj.Ownership_Text__c==GlobalConstants.OWNERSHIP_TEMPORARY))){
            monthlyObj.Customer_Other__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                monthlyObj.Contacted_Customer_Other__c++;

                if(monthlyObj.User__c!=null){
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+monthlyObj.User__c))
                        monthlyObj.Contacted_Customer_Other_My_Penetrate__c++;
                }
            }
        }
        
        // start cr019 penetrate report
        if(accountObj.Port_Pool__c != null && accountObj.Port_Pool__c.equalsIgnoreCase(GlobalConstants.PORT)){
            if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                monthlyObj.Contacted_Port_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                monthlyObj.Contacted_Port_CustCall__c++;
            }

            if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                monthlyObj.My_Penetrate_Contacted_Port_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                monthlyObj.My_Penetrate_Contacted_Port_CustCall__c++;
            }
        }else if(accountObj.Port_Pool__c != null && accountObj.Port_Pool__c.equalsIgnoreCase(GlobalConstants.POOL)){
            if(accountObj.Service_RM__c != null && accountObj.Service_RM__c!=accountObj.OwnerId && accountObj.Service_RM__r.Profile.Name == GlobalConstants.SME_RM && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || (accountObj.Owner.Profile.Name==GlobalConstants.SME_AH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.AH_RC_Code__c) || (accountObj.Owner.Profile.Name==GlobalConstants.SME_NH && accountObj.Owner.RC_Code__c == accountObj.Service_RM__r.NH_RC_Code__c)) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                    if(monthlyServiceObj!=null && accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                        monthlyServiceObj.Contacted_Pool_CustF2F__c++;
                    }else if(monthlyServiceObj!=null && accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                        monthlyServiceObj.Contacted_Pool_CustCall__c++;
                    }

                    if(monthlyServiceObj!=null && accountObj.Count_Contacted_CR_My_Pen_Service_F2F__c > 0){
                        monthlyServiceObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                    }else if(monthlyServiceObj!=null && accountObj.Count_Contacted_CR_My_Pen_Service_Call__c > 0){
                        monthlyServiceObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                    }
                //}
            }else{
                if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                    monthlyObj.Contacted_Pool_CustF2F__c++;
                }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                    monthlyObj.Contacted_Pool_CustCall__c++;
                }

                if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                    monthlyObj.My_Penetrate_Contacted_Pool_CustF2F__c++;
                }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                    monthlyObj.My_Penetrate_Contacted_Pool_CustCall__c++;
                }
            }
        }else if(accountObj.Port_Pool__c==null || accountObj.Port_Pool__c==''){
            if(accountObj.Count_Contacted_Call_Report_F2F__c > 0){
                monthlyObj.Contacted_Other_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_Phone_Call__c > 0){
                monthlyObj.Contacted_Other_CustCall__c++;
            }

            if(accountObj.Count_Contacted_Call_Report_My_Pen_F2F__c > 0){
                monthlyObj.My_Penetrate_Contacted_Other_CustF2F__c++;
            }else if(accountObj.Count_Contacted_Call_Report_My_Pen_Call__c > 0){
                monthlyObj.My_Penetrate_Contacted_Other_CustCall__c++;
            }
        }
        // end cr019 penetrate report
    }    
}