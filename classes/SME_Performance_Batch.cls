/**
 * @author komsan.wi@beryl8.com
 * @04/04/2016 create new
 */
global class SME_Performance_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private String query;

    private Boolean runMontly = false;
    private Boolean initialMonthly = false;
    private Boolean shouldRunMontly = true;
    private Boolean runSummaryAtTheEnd = false;
    private Boolean resetStatement = false;

    private Boolean resetValue = false;

    private Map<String,User_Extension__c> userExMap;
    private Map<String,Team_Structure__c> teamMap;

    //private List<User_Extension__c> userExUpdateList;
    //private List<Team_Structure__c> teamUpdateList;
    private Map<String,Monthly_Performance__c> monthlyMap;
    private String completeStatement;
    private String completeStatementMonthly;
    private Date monthlyStart;
    private Date monthlyEnd;

    private Integer monthTarget;
    private Performance_Config__c perfConfig;
    
    //private Map<String,List<String>> userExIdMapTeam;
    @TestVisible
    private Date todayDateFromNow;
    private Integer minusMonthly = 0;
    @TestVisible
    private Integer currentYear;
    global SME_Performance_Batch(Integer minusMonthly) {
        this.minusMonthly = minusMonthly;
        this.init(true);
    }
    global SME_Performance_Batch(){
        this.init(false);
    }
    global SME_Performance_Batch(Boolean isMonthly){
        this.init(isMonthly);
    }
    global void init(Boolean isMonthly) {
        //start cr019 penetrate report
        perfConfig = Performance_Config__c.getOrgDefaults();
        if(isLoadRecordLastYear()){
            this.query = 'SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.Team_Structure__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Visit_Objective__c,Contact_Channel__c,Completed__c,Current_Owner_Extension__r.User__r.isActive,Current_Owner_Extension__r.User__r.Employee_Id__c,Current_Owner_Extension__r.User__r.RC_Code__c,Actual_Visit_Date__c,Offer_Credit_Product__c,Collect_Documents__c,Negotiation__c,Pain__c,Servicing__c,Customer_Insight__c,Non_Credit__c,No_Change__c,DPD__c,Gift__c FROM Call_Report__c WHERE Primary_Call_Report__c=true AND Actual_Visit_Date__c = LAST_YEAR AND Current_Owner_Extension__r.User__r.Employee_Id__c!=null AND Current_Owner_Extension__r.Team_Structure__c!=null AND Current_Owner_Extension__c!=null';
        }else{
            this.query = 'SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.Team_Structure__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Visit_Objective__c,Contact_Channel__c,Completed__c,Current_Owner_Extension__r.User__r.isActive,Current_Owner_Extension__r.User__r.Employee_Id__c,Current_Owner_Extension__r.User__r.RC_Code__c,Actual_Visit_Date__c,Offer_Credit_Product__c,Collect_Documents__c,Negotiation__c,Pain__c,Servicing__c,Customer_Insight__c,Non_Credit__c,No_Change__c,DPD__c,Gift__c FROM Call_Report__c WHERE Primary_Call_Report__c=true AND Actual_Visit_Date__c = THIS_YEAR AND Current_Owner_Extension__r.User__r.Employee_Id__c!=null AND Current_Owner_Extension__r.Team_Structure__c!=null AND Current_Owner_Extension__c!=null';
        }
        //end cr019 penetrate report

        completeStatement = ' AND Completed__c=false';
        completeStatementMonthly = '';

        DateTime dT = System.now();

        if(isLoadRecordLastYear()){
            todayDateFromNow = date.newinstance(dT.year()-1, dT.month()-minusMonthly, dT.day());
        }else{
            todayDateFromNow = date.newinstance(dT.year(), dT.month()-minusMonthly, dT.day());
        }
        
        currentYear = GlobalUtility.getYearInBuddhistCalendar(todayDateFromNow);
        userExMap = new Map<String,User_Extension__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__r.ProfileId,User__r.Profile.Name,User__r.Employee_Id__c,User__r.RC_Code__c,Number_of_RM_under_Team__c,Last_Month_Stamp__c,User__r.IsActive,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,User__c,User__r.ManagerId,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c!=null]);

        teamMap = new Map<String,Team_Structure__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Name,AH_Name__c,NH_Name__c,RC_Code__c,Number_of_RM_under_Team__c,AH_RC_Code__c,NH_RC_Code__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM Team_Structure__c]);
        // Add For INC000000570851
        if(!isMonthly && perfConfig.Reset_Date__c != null &&  dT.day() == perfConfig.Reset_Date__c.day() &&  dT.month() == perfConfig.Reset_Date__c.month() ){
            noFlag();
        }

        //if(!isMonthly){
            Map<String,List<String>> userExIdMapTeam = new Map<String,List<String>>();

            //reset
            for(User_Extension__c eachExt : userExMap.values()){
                eachExt.Number_of_RM_under_Team__c = 0;
                teamMap.get(eachExt.Team_Structure__c).Number_of_RM_under_Team__c = 0;
                
                if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null) 
                    teamMap.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).Number_of_RM_under_Team__c = 0;
                
                if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null) 
                    teamMap.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).Number_of_RM_under_Team__c = 0;

                if(!userExIdMapTeam.containsKey(eachExt.Team_Structure__c))
                    userExIdMapTeam.put(eachExt.Team_Structure__c,new List<String>());
                userExIdMapTeam.get(eachExt.Team_Structure__c).add(eachExt.Id);
            }
            for(Team_Structure__c eachTeam : teamMap.values()){
                eachTeam.Months__c = todayDateFromNow.month();
            }
            for(User_Extension__c eachExt : userExMap.values()){
                eachExt.Months__c = todayDateFromNow.month();
            }
            //recount
            for(User_Extension__c eachExt : userExMap.values()){
                if(Account_Util.isProfile(GlobalConstants.SME_RM,eachExt) && eachExt.User__r.isActive){
                    teamMap.get(eachExt.Team_Structure__c).Number_of_RM_under_Team__c++;
                    //eachExt.Number_of_RM_under_Team__c++;

                    for(String exId : userExIdMapTeam.get(eachExt.Team_Structure__c)){
                        userExMap.get(exId).Number_of_RM_under_Team__c++;
                    }

                    if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null){
                        teamMap.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).Number_of_RM_under_Team__c++;
                        if(userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).AH_Name__c))
                            for(String exId : userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c)){
                                userExMap.get(exId).Number_of_RM_under_Team__c++;
                            }
                    }
                    if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null){
                        teamMap.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).Number_of_RM_under_Team__c++;
                        if(userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).NH_Name__c))
                            for(String exId : userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c)){
                                userExMap.get(exId).Number_of_RM_under_Team__c++;
                            }
                    }
                }
            }
        //}
    }
    global SME_Performance_Batch noFlag(){
        //set everything to zero;
        completeStatement = '';
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Call_Report__c = 0;
            eachExt.Call_Report_Customer_Port__c = 0;
            eachExt.Call_Report_Customer_Pool__c = 0;
            eachExt.Call_Report_Customer_Others__c = 0;
            eachExt.Call_Report_for_Sales__c = 0;
            eachExt.Call_Report_for_Relationship__c = 0;
            eachExt.Face_to_Face__c = 0;
            eachExt.Phone_Call__c = 0;
        }
        for(Team_Structure__c eachTeam : teamMap.values()){
            eachTeam.Call_Report__c = 0;
            eachTeam.Call_Report_Customer_Port__c = 0;
            eachTeam.Call_Report_Customer_Pool__c = 0;
            eachTeam.Call_Report_Customer_Others__c = 0;
            eachTeam.Call_Report_for_Sales__c = 0;
            eachTeam.Call_Report_for_Relationship__c = 0;
            eachTeam.Face_to_Face__c = 0;
            eachTeam.Phone_Call__c = 0;
        }
        return this;
    }
    global SME_Performance_Batch noFlagMonthly(){
        //set everything to zero;
        completeStatementMonthly = '';
        resetStatement = true;
        return this;
    }
    global SME_Performance_Batch noMontly(){
        shouldRunMontly = false;
        return this;
    }
    global SME_Performance_Batch runSummaryAtTheEnd(){
        runSummaryAtTheEnd = true;
        return this;
    }
    global SME_Performance_Batch setResetStatement(Boolean resetStatement){
        this.resetStatement = resetStatement;
        return this;
    }

    global SME_Performance_Batch runMontly(Boolean initial, Integer monthTarget){
        this.monthTarget = monthTarget;

        initialMonthly = initial;
        //set everything to zero;
        runMontly = true;
        if(initial) resetStatement = true;
        //if(!initial)
        monthlyMap = new Map<String,Monthly_Performance__c>();
            
        monthlyStart = Date.newInstance(todayDateFromNow.year(),1,1);

        //monthlyEnd = todayDateFromNow;

        this.query += ' AND Actual_Visit_Date__c >= :monthlyStart AND CALENDAR_MONTH(Actual_Visit_Date__c) = :monthTarget';
        //if(!initial) this.completeStatementMonthly += ' AND Complete_Monthly__c=false';

        this.completeStatement = '';
        Integer numberOfDays = Date.daysInMonth(todayDateFromNow.year(), monthTarget);
        String exKey;
        String teamKey;
        Monthly_Performance__c tmpModel;
        for(User_Extension__c eachExt : userExMap.values()){
            if(eachExt.User__r.isActive || initial || resetStatement){
                exKey = eachExt.User__r.Employee_Id__c + ' ' + monthTarget + ' ' + currentYear;
                teamKey = eachExt.User__r.RC_Code__c + ' ' + monthTarget + ' ' + currentYear;
                if(!monthlyMap.containsKey(exKey)){
                    tmpModel = new Monthly_Performance__c();
                    tmpModel.External_ID__c = exKey;
                    tmpModel.Name = GlobalConstants.monthThaiNameList.get(monthTarget-1) +' '+currentYear;
                    tmpModel.User__c = eachExt.Id;
                    tmpModel.Date__c = Date.newInstance(todayDateFromNow.year(), monthTarget, numberOfDays);

                    tmpModel.Call_Report__c = 0;
                    tmpModel.Call_Report_Customer_Port__c = 0;
                    tmpModel.Call_Report_Customer_Pool__c = 0;
                    tmpModel.Call_Report_Customer_Others__c = 0;
                    tmpModel.Call_Report_for_Sales__c = 0;
                    tmpModel.Call_Report_for_Relationship__c = 0;
                    tmpModel.Face_to_Face__c = 0;
                    tmpModel.Phone_Call__c = 0;
                    tmpModel.Total_visited_Customer__c = 0;

                    monthlyMap.put(exKey, tmpModel);
                }
                if(!monthlyMap.containsKey(teamKey)){
                    tmpModel = new Monthly_Performance__c();
                    tmpModel.External_ID__c = teamKey;
                    tmpModel.Name = GlobalConstants.monthThaiNameList.get(monthTarget-1) +' '+currentYear;
                    tmpModel.Team__c = eachExt.Team_Structure__c;
                    tmpModel.Date__c = Date.newInstance(todayDateFromNow.year(), monthTarget, numberOfDays);
                    tmpModel.Months__c = monthTarget;

                    tmpModel.Call_Report__c = 0;
                    tmpModel.Call_Report_Customer_Port__c = 0;
                    tmpModel.Call_Report_Customer_Pool__c = 0;
                    tmpModel.Call_Report_Customer_Others__c = 0;
                    tmpModel.Call_Report_for_Sales__c = 0;
                    tmpModel.Call_Report_for_Relationship__c = 0;
                    tmpModel.Face_to_Face__c = 0;
                    tmpModel.Phone_Call__c = 0;
                    tmpModel.Total_visited_Customer__c = 0;

                    monthlyMap.put(teamKey, tmpModel);
                }
            }
        }
        

        return this;
    }
    private String limitStatement='';
    global SME_Performance_Batch setLimit(){
        //set everything to zero;
        limitStatement = ' LIMIT 100';
        return this;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) { return Database.getQueryLocator(query+completeStatement +completeStatementMonthly+limitStatement); }
    
    global void execute(Database.BatchableContext BC, List<Call_Report__c> callreportList) {
        User_Extension__c userExtObj;
        Team_Structure__c teamStrucObj;

        String exKey;
        String teamKey;
        Integer numberOfDays;
        Integer currentInYear;
        Monthly_Performance__c tmpModel;
        for(Call_Report__c eachCallreport : callreportList){
            if(eachCallreport.Current_Owner_Extension__c!=null && userExMap.containsKey(eachCallreport.Current_Owner_Extension__c)){
                userExtObj = userExMap.get(eachCallreport.Current_Owner_Extension__c);
                teamStrucObj = teamMap.get(userExtObj.Team_Structure__c);
                //system.assertEquals('teamStrucObj',teamStrucObj+'');
                if(eachCallreport.Current_Owner_Extension__r.Team_Structure__c!=null){
                    // && eachCallreport.Current_Owner_Extension__r && eachCallreport.Current_Owner_Extension__r.User__r.Employee_Id__c!=null
                    if(runMontly && eachCallreport.Actual_Visit_Date__c!=null){
                        //if(!initialMonthly)
                            //eachCallreport.Complete_Monthly__c = true;

                        currentInYear = GlobalUtility.getYearInBuddhistCalendar(eachCallreport.Actual_Visit_Date__c); 

                        exKey = eachCallreport.Current_Owner_Extension__r.User__r.Employee_Id__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                        teamKey = teamStrucObj.RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                        numberOfDays = Date.daysInMonth(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month());
                        if(!monthlyMap.containsKey(exKey)){
                            tmpModel = new Monthly_Performance__c();
                            tmpModel.External_ID__c = exKey;
                            tmpModel.Name = GlobalConstants.monthThaiNameList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear;
                            tmpModel.User__c = eachCallreport.Current_Owner_Extension__c;
                            tmpModel.Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays);
                            tmpModel.Months__c = eachCallreport.Actual_Visit_Date__c.month();

                            tmpModel.Call_Report__c = 0;
                            tmpModel.Call_Report_Customer_Port__c = 0;
                            tmpModel.Call_Report_Customer_Pool__c = 0;
                            tmpModel.Call_Report_Customer_Others__c = 0;
                            tmpModel.Call_Report_for_Sales__c = 0;
                            tmpModel.Call_Report_for_Relationship__c = 0;
                            tmpModel.Face_to_Face__c = 0;
                            tmpModel.Phone_Call__c = 0;
                            tmpModel.Total_visited_Customer__c = 0;

                            monthlyMap.put(exKey, tmpModel);
                        }
                        if(!monthlyMap.containsKey(teamKey)){
                            tmpModel = new Monthly_Performance__c();
                            tmpModel.External_ID__c = teamKey;
                            tmpModel.Name = GlobalConstants.monthThaiNameList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear;
                            tmpModel.Team__c = eachCallreport.Current_Owner_Extension__r.Team_Structure__c;
                            tmpModel.Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays);
                            tmpModel.Months__c = eachCallreport.Actual_Visit_Date__c.month();

                            tmpModel.Call_Report__c = 0;
                            tmpModel.Call_Report_Customer_Port__c = 0;
                            tmpModel.Call_Report_Customer_Pool__c = 0;
                            tmpModel.Call_Report_Customer_Others__c = 0;
                            tmpModel.Call_Report_for_Sales__c = 0;
                            tmpModel.Call_Report_for_Relationship__c = 0;
                            tmpModel.Face_to_Face__c = 0;
                            tmpModel.Phone_Call__c = 0;
                            tmpModel.Total_visited_Customer__c = 0;

                            monthlyMap.put(teamKey, tmpModel);
                        }


                        //stamp by ext
                        if(monthlyMap.containsKey(exKey)){
                            this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));
                        }
                        //stamp by team
                        exKey = teamStrucObj.RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;
                        if(monthlyMap.containsKey(exKey)){
                            this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));
                        }

                        //team section

                        //loglist.add(new Application_Log__c(Source__c='SME_Performance_Batch',Message__c='teamStrucObj ' + teamStrucObj)); 
                        if(teamStrucObj.AH_Name__c!=null){
                            exKey = teamStrucObj.AH_RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;
                            if(!monthlyMap.containsKey(exKey)){

                                tmpModel = new Monthly_Performance__c();
                                tmpModel.External_ID__c = exKey;
                                tmpModel.Name = GlobalConstants.monthThaiNameList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear;
                                tmpModel.Team__c = teamStrucObj.AH_Name__c;
                                tmpModel.Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays);
                                tmpModel.Months__c = eachCallreport.Actual_Visit_Date__c.month();

                                tmpModel.Call_Report__c = 0;
                                tmpModel.Call_Report_Customer_Port__c = 0;
                                tmpModel.Call_Report_Customer_Pool__c = 0;
                                tmpModel.Call_Report_Customer_Others__c = 0;
                                tmpModel.Call_Report_for_Sales__c = 0;
                                tmpModel.Call_Report_for_Relationship__c = 0;
                                tmpModel.Face_to_Face__c = 0;
                                tmpModel.Phone_Call__c = 0;
                                tmpModel.Total_visited_Customer__c = 0;

                                monthlyMap.put(exKey, tmpModel);
                            }
                            this.stampingMonthly(eachCallreport, monthlyMap.get(exKey));

                        }

                        if(teamStrucObj.NH_Name__c!=null){
                            exKey = teamStrucObj.NH_RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                            if(!monthlyMap.containsKey(exKey)){

                                tmpModel = new Monthly_Performance__c();
                                tmpModel.External_ID__c = exKey;
                                tmpModel.Name = GlobalConstants.monthThaiNameList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear;
                                tmpModel.Team__c = teamStrucObj.NH_Name__c;
                                tmpModel.Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays);
                                tmpModel.Months__c = eachCallreport.Actual_Visit_Date__c.month();

                                tmpModel.Call_Report__c = 0;
                                tmpModel.Call_Report_Customer_Port__c = 0;
                                tmpModel.Call_Report_Customer_Pool__c = 0;
                                tmpModel.Call_Report_Customer_Others__c = 0;
                                tmpModel.Call_Report_for_Sales__c = 0;
                                tmpModel.Call_Report_for_Relationship__c = 0;
                                tmpModel.Face_to_Face__c = 0;
                                tmpModel.Phone_Call__c = 0;
                                tmpModel.Total_visited_Customer__c = 0;

                                monthlyMap.put(exKey, tmpModel);
                            }
                            
                            this.stampingMonthly(eachCallreport, monthlyMap.get(exKey));
                        }

                    }
                    if(!runMontly){
                        eachCallreport.Completed__c = true; // flag
                        userExtObj.Call_Report__c = (userExtObj.Call_Report__c!=null)?userExtObj.Call_Report__c+1:1;
                        teamStrucObj.Call_Report__c = (teamStrucObj.Call_Report__c!=null)?teamStrucObj.Call_Report__c+1:1;

                        if(eachCallreport.Port_Pool__c == 'Port'){
                            userExtObj.Call_Report_Customer_Port__c = (userExtObj.Call_Report_Customer_Port__c!=null)?userExtObj.Call_Report_Customer_Port__c+1:1;
                            teamStrucObj.Call_Report_Customer_Port__c = (teamStrucObj.Call_Report_Customer_Port__c!=null)?teamStrucObj.Call_Report_Customer_Port__c+1:1;
                            
                        }else if(eachCallreport.Port_Pool__c == 'Pool'){
                            userExtObj.Call_Report_Customer_Pool__c = (userExtObj.Call_Report_Customer_Pool__c!=null)?userExtObj.Call_Report_Customer_Pool__c+1:1;
                            teamStrucObj.Call_Report_Customer_Pool__c = (teamStrucObj.Call_Report_Customer_Pool__c!=null)?teamStrucObj.Call_Report_Customer_Pool__c+1:1;
                            
                        }else if(eachCallreport.Port_Pool__c == null && (eachCallreport.Ownership__c==null || eachCallreport.Ownership__c=='' || eachCallreport.Ownership__c=='Temporary')){
                            userExtObj.Call_Report_Customer_Others__c = (userExtObj.Call_Report_Customer_Others__c!=null)?userExtObj.Call_Report_Customer_Others__c+1:1;
                            teamStrucObj.Call_Report_Customer_Others__c = (teamStrucObj.Call_Report_Customer_Others__c!=null)?teamStrucObj.Call_Report_Customer_Others__c+1:1;
                        }

                        //if(eachCallreport.Visit_Objective__c=='Sell'){
                        if(eachCallreport.Offer_Credit_Product__c || eachCallreport.Collect_Documents__c || eachCallreport.Negotiation__c){

                            userExtObj.Call_Report_for_Sales__c = (userExtObj.Call_Report_for_Sales__c!=null)?userExtObj.Call_Report_for_Sales__c+1:1;
                            teamStrucObj.Call_Report_for_Sales__c = (teamStrucObj.Call_Report_for_Sales__c!=null)?teamStrucObj.Call_Report_for_Sales__c+1:1;
                          
                        //}else if(eachCallreport.Visit_Objective__c=='Relationship'){
                        }else{
                            userExtObj.Call_Report_for_Relationship__c = (userExtObj.Call_Report_for_Relationship__c!=null)?userExtObj.Call_Report_for_Relationship__c+1:1;
                            teamStrucObj.Call_Report_for_Relationship__c = (teamStrucObj.Call_Report_for_Relationship__c!=null)?teamStrucObj.Call_Report_for_Relationship__c+1:1;
                        }
                        
                        if(eachCallreport.Contact_Channel__c=='Face to Face'){
                            userExtObj.Face_to_Face__c = (userExtObj.Face_to_Face__c!=null)?userExtObj.Face_to_Face__c+1:1;
                            teamStrucObj.Face_to_Face__c = (teamStrucObj.Face_to_Face__c!=null)?teamStrucObj.Face_to_Face__c+1:1;
                        }else if(eachCallreport.Contact_Channel__c=='Phone Call'){
                            userExtObj.Phone_Call__c = (userExtObj.Phone_Call__c!=null)?userExtObj.Phone_Call__c+1:1;
                            teamStrucObj.Phone_Call__c = (teamStrucObj.Phone_Call__c!=null)?teamStrucObj.Phone_Call__c+1:1;
                        }
                    }
                }
            }
        }
        if(!initialMonthly && !runMontly){
            
            TriggerHandler.bypass('CallReportTriggerHandler');
            update callreportList;
        }
    }

    //start cr019 penetrate report
    private Boolean isLoadRecordLastYear(){
        if(Label.Last_Year_Performance != null && Label.Last_Year_Performance.equalsIgnoreCase('true') && !Test.isRunningTest()){
            return true;
        }
        return false;
    }
    //end cr019 penetrate report

    private void stampingMonthly(Call_Report__c callReport,Monthly_Performance__c monthlyObj){
        monthlyObj.Call_Report__c++;
        if(callReport.Port_Pool__c == 'Port'){
            monthlyObj.Call_Report_Customer_Port__c += 1;
        }else if(callReport.Port_Pool__c == 'Pool'){
            monthlyObj.Call_Report_Customer_Pool__c += 1;
        }else if(callReport.Port_Pool__c == null && (callReport.Ownership__c==null || callReport.Ownership__c=='' || callReport.Ownership__c=='Temporary')){
            monthlyObj.Call_Report_Customer_Others__c += 1;
        }

        //if(callReport.Visit_Objective__c=='Sell'){
        if(callReport.Offer_Credit_Product__c || callReport.Collect_Documents__c || callReport.Negotiation__c){
            monthlyObj.Call_Report_for_Sales__c += 1;
        //}else if(callReport.Visit_Objective__c=='Relationship'){
        }else{
            monthlyObj.Call_Report_for_Relationship__c += 1;
        }
        
        if(callReport.Contact_Channel__c=='Face to Face'){
            monthlyObj.Face_to_Face__c += 1;
        }else if(callReport.Contact_Channel__c=='Phone Call'){
            monthlyObj.Phone_Call__c += 1;
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(runMontly){
            String exKey;
            String teamKey;
            for(User_Extension__c eachExt : userExMap.values()){
                exKey = eachExt.User__r.Employee_Id__c + ' ' + monthTarget + ' ' + currentYear;
                teamKey = eachExt.User__r.RC_Code__c + ' ' + monthTarget + ' ' + currentYear;
                if(monthlyMap.containsKey(exKey)){
                    monthlyMap.get(exKey).Number_of_RM_under_Team__c = eachExt.Number_of_RM_under_Team__c;
                }
                if(monthlyMap.containsKey(teamKey))
                    monthlyMap.get(teamKey).Number_of_RM_under_Team__c = eachExt.Number_of_RM_under_Team__c;
            }
            if(monthTarget != todayDateFromNow.month())
                Database.executeBatch(new SME_Monthly_DML_Batch(monthlyMap.values()),2000);

            // List<Monthly_Performance__c> partialToUpdateList = new List<Monthly_Performance__c>();
            // for(Monthly_Performance__c eachPartial : monthlyMap.values()){
            //     partialToUpdateList.add(new Monthly_Performance__c(
            //         External_ID__c = eachPartial.External_ID,
            //         Name = eachPartial.MName,
            //         User__c = eachPartial.MUser,
            //         Team__c = eachPartial.MTeam,
            //         Call_Report__c = eachPartial.Call_Report,
            //         Call_Report_Customer_Port__c = eachPartial.Call_Report_Customer_Port,
            //         Call_Report_Customer_Pool__c = eachPartial.Call_Report_Customer_Pool,
            //         Call_Report_Customer_Others__c = eachPartial.Call_Report_Customer_Others,
            //         Call_Report_for_Sales__c = eachPartial.Call_Report_for_Sales,
            //         Call_Report_for_Relationship__c = eachPartial.Call_Report_for_Relationship,
            //         Face_to_Face__c = eachPartial.Face_to_Face,
            //         Phone_Call__c = eachPartial.Phone_Call,
            //         Total_visited_Customer__c = eachPartial.Total_visited_Customer,
            //         Contacted_Customer_Other__c = eachPartial.Contacted_Customer_Other,
            //         Contacted_Customer_Pool__c = eachPartial.Contacted_Customer_Pool,
            //         Contacted_Customer_Port__c = eachPartial.Contacted_Customer_Port,
            //         Customer_Other__c = eachPartial.Customer_Other,
            //         Customer_Pool__c = eachPartial.Customer_Pool,
            //         Customer_Port__c = eachPartial.Customer_Port,
            //         Contacted_Customer_Other_My_Penetrate__c = eachPartial.Contacted_Customer_Other_My_Penetrate,
            //         Contacted_Customer_Pool_My_Penetrate__c = eachPartial.Contacted_Customer_Pool_My_Penetrate,
            //         Contacted_Customer_Port_My_Penetrate__c = eachPartial.Contacted_Customer_Port_My_Penetrate,
            //         Date__c = eachPartial.MDate,
            //         Months__c = eachPartial.MMonths
            //     ));
            // }
            // upsert partialToUpdateList External_ID__c;
        }else{
            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.NH_Name__c!=null){
                    teamMap.get(eachTeam.NH_Name__c).Call_Report__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Phone_Call__c = 0;
                }
                if(eachTeam.AH_Name__c!=null){
                    teamMap.get(eachTeam.AH_Name__c).Call_Report__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Phone_Call__c = 0;
                }
            }
            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.NH_Name__c!=null){
                    teamMap.get(eachTeam.NH_Name__c).Call_Report__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report__c+eachTeam.Call_Report__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c+eachTeam.Call_Report_Customer_Port__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c+eachTeam.Call_Report_Customer_Pool__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c+eachTeam.Call_Report_Customer_Others__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c+eachTeam.Call_Report_for_Sales__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c+eachTeam.Call_Report_for_Relationship__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c = (teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c!=null)?teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c+eachTeam.Face_to_Face__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Phone_Call__c = (teamMap.get(eachTeam.NH_Name__c).Phone_Call__c!=null)?teamMap.get(eachTeam.NH_Name__c).Phone_Call__c+eachTeam.Phone_Call__c:1;
                }
            }

            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.AH_Name__c!=null){
                    teamMap.get(eachTeam.AH_Name__c).Call_Report__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report__c+eachTeam.Call_Report__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c+eachTeam.Call_Report_Customer_Port__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c+eachTeam.Call_Report_Customer_Pool__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c+eachTeam.Call_Report_Customer_Others__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c+eachTeam.Call_Report_for_Sales__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c+eachTeam.Call_Report_for_Relationship__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c = (teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c!=null)?teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c+eachTeam.Face_to_Face__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Phone_Call__c = (teamMap.get(eachTeam.AH_Name__c).Phone_Call__c!=null)?teamMap.get(eachTeam.AH_Name__c).Phone_Call__c+eachTeam.Phone_Call__c:1;
                }
            }

            update userExMap.values();
            update teamMap.values();//need change
        }

        if(!runMontly && shouldRunMontly){
            //Performance_Config__c perfConfig = Performance_Config__c.getOrgDefaults();
                //specific day
            if((perfConfig.Date__c != null && todayDateFromNow.day() == perfConfig.Date__c) || 
                (perfConfig.Date__c==null && todayDateFromNow.day() == todayDateFromNow.addMonths(1).toStartofMonth().addDays(-1).day())){

                for(Integer monthSelected = 1; monthSelected < todayDateFromNow.month() ; monthSelected++){
                    Database.executeBatch(new SME_Performance_Batch(0).setResetStatement(resetStatement).runMontly(false, monthSelected));
                }
                Database.executeBatch(new SME_Performance_Batch(0).setResetStatement(resetStatement).runMontly(false, todayDateFromNow.month()).runSummaryAtTheEnd());

                
            }else Database.executeBatch(new SME_Performance_All_Batch());
        }
        if(runSummaryAtTheEnd) Database.executeBatch(new SME_Performance_All_Batch().runMontly(monthlyMap, resetStatement, initialMonthly));
    }
}