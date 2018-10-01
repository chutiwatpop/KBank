public with sharing class CBS_OpportunityPlanningWrapper{
	public List<Opportunity_Planning_Line_Item__c> oppPlanningLineItems{get;set;}

    public Opportunity_Planning__c opportunityPlanning{get;set;}

    public String oldStatus{get;set;}
    public Opportunity addToExistingOpportunity{get;set;}

    //New CR

    public Boolean isChecked {get;set;}
    public Boolean isGrouped {get;set;}
    public double old_NewLimit {get;set;}
    public double old_Outstanding {get;set;}
    public double old_FrontEndFee {get;set;}
    public double old_Fee {get;set;}
    public String errMsg_NewLimit{get;set;}
    public String errMsg_Outstanding{get;set;}
    public String errMsg_FrontEndFee{get;set;}
    public String errMsg_Fee{get;set;}
 
    public Set<String> oppPlaningTypeSetNotAllowEditAmount;
    public Boolean allowGrouping;
    public Boolean allowAddToExistingOpportunity;

    public CBS_OpportunityPlanningWrapper(Opportunity_Planning__c oppPlanning,List<Opportunity_Planning_Line_Item__c> productline){
        this.opportunityPlanning = oppPlanning;
        this.oppPlanningLineItems = productline;
   
        this.oldStatus = oppPlanning.Status__c;
        this.addToExistingOpportunity = new Opportunity();

        this.isGrouped = false;
        this.isChecked = false;

        this.oppPlaningTypeSetNotAllowEditAmount = new Set<String>();

    }



    public void setStateBeforeEdit(){
        this.old_NewLimit = this.opportunityPlanning.New_Limit__c;
        this.old_Outstanding = this.opportunityPlanning.Volume_Outstanding__c;
        this.old_FrontEndFee = this.opportunityPlanning.Front_End_Fee__c;
        this.old_Fee = this.opportunityPlanning.Fee__c;
    }

    public void reSetState(){
        this.opportunityPlanning.New_Limit__c = this.old_NewLimit;
        this.opportunityPlanning.Volume_Outstanding__c = this.old_Outstanding;
        this.opportunityPlanning.Front_End_Fee__c = this.old_FrontEndFee;
        this.opportunityPlanning.Fee__c = this.old_Fee;

        this.old_NewLimit = null;
        this.old_Outstanding = null;
        this.old_FrontEndFee = null;
        this.old_Fee = null;
        this.errMsg_NewLimit = null;
        this.errMsg_Outstanding = null;
        this.errMsg_FrontEndFee = null;
        this.errMsg_Fee = null;
    }

    public Boolean getIsOppPlanningWrapperEditable(){
        Boolean isEditable = true;
        if(this.isGrouped || opportunityPlanning.Status__c == GlobalConstants.NOT_INTERESTED ||
            this.oppPlaningTypeSetNotAllowEditAmount.contains(opportunityPlanning.Product_Type__c)){
            isEditable = false;
        }
        return isEditable;
    }

    public Boolean getrenderGroupOppPlanningWrapper(){
        Boolean render;
        if(this.allowGrouping && !this.isGrouped){
             render = true;
        }else{
            render = false;
        }
        return render;
    }

    public Boolean getrenderAddtoExistingOpportunity(){
        Boolean render;
        if(!this.isGrouped && this.allowAddToExistingOpportunity){
            render = true;
        }else{
            render = false;
        }
        return render;
    }
}