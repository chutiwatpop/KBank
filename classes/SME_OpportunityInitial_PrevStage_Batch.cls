global class SME_OpportunityInitial_PrevStage_Batch implements Database.Batchable<sObject> {
    
    String query;
    List<Opportunity> updateOppList = new List<Opportunity>();
    
    global SME_OpportunityInitial_PrevStage_Batch () {
        this.query ='SELECT ID,Amount,Update_Stage_by_Close_Won__c,Approval_Status__c,Application_Number__c,Previous_Stage__c,StageName,Setup_Amount__c,Approved_Amount__c,Approval_Workout_Date__c,First_Application_SO_Receive_Date__c ,Tentative_Application_Submit_Date__c ,Amount_Report__c ,Actual_Visit_Date__c  FROM Opportunity WHERE Previous_Stage__c=null AND (StageName=\''+GlobalConstants.ALL_LOAN_SETUP +'\' OR StageName=\''+GlobalConstants.CLOSE_LOST+'\' OR StageName=\''+GlobalConstants.AUTO_CLOSED+'\')';
        System.debug(this.query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitylist) {
       System.debug('In Execute');
        for(Opportunity eachOpp : opportunitylist){

            System.debug('Setup_Amount__c :'+ eachOpp.Setup_Amount__c);
            System.debug('Approval_Status__c : '+ eachOpp.Approval_Status__c);

            if(eachOpp.Approval_Status__c =='Final Approved' && eachOpp.Setup_Amount__c >0){
                eachOpp.Previous_Stage__c = GlobalConstants.PARTIAL_LOAN_SETUP;
            }else if(eachOpp.Approval_Status__c  !=null && eachOpp.Approval_Status__c =='Final Approved'){
                eachOpp.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
            }else if(eachOpp.Approval_Status__c  !=null && eachOpp.Approval_Status__c =='Work in progress'){
                eachOpp.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
            }else if(eachOpp.Approval_Status__c ==null && eachOpp.Application_Number__c  !=null){
                eachOpp.Previous_Stage__c = GlobalConstants.CREATE_WRITE_UP;
            }else if(eachOpp.Approval_Status__c ==null && eachOpp.Application_Number__c  ==null){
                eachOpp.Previous_Stage__c = GlobalConstants.STOCK_NEGOTIATION;
            }else if(eachOpp.Approval_Status__c  =='Lapse' || eachOpp.Approval_Status__c =='Decline'){
                eachOpp.Previous_Stage__c = GlobalConstants.CASE_IS_REJECT;
            }else{
                eachOpp.Previous_Stage__c = GlobalConstants.STOCK_NEGOTIATION;
                System.debug('Opportunity ID : '+eachOpp.Id+ ' not Match Condition');
            }
            updateOppList.add(eachOpp);
            System.debug('============End Loop ===============');
        }

        update updateOppList;
        System.debug('End execute');
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}