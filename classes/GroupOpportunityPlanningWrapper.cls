public with sharing class GroupOpportunityPlanningWrapper {
	public String sum_productName {get;set;}
	public Decimal sum_newLimit {get;set;}
	public Decimal sum_VolumnOutstanding {get;set;}
	public Decimal sum_FronEndFee {get;set;}
	public Decimal sum_Fee	{get;set;}
	public Opportunity addToExistingOpp {get;set;}
	public List<Opportunity_Planning__c> opportunityPlanningList {get;set;}
	public List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList {get;set;}
	public String status {get {return GlobalConstants.OPP_PLAN_WIN_MANDATE;}set;}
	public String remark {get;set;}
	
	public Boolean isAllServicing {get;set;}
	public String allType {get;set;}


	public GroupOpportunityPlanningWrapper(List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList) {
		this.allType = null;
		this.opportunityPlanningList = new List<Opportunity_Planning__c>();
		this.addToExistingOpp = new Opportunity();
		this.oppPlanningWrapperList = oppPlanningWrapperList;
		for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : this.oppPlanningWrapperList){
			if(!String.isBlank(this.sum_productName)){
				this.sum_productName += ', ';
			}
			for(Opportunity_Planning_Line_Item__c oppPlanningLineItem : eachOppPlanningWrapper.oppPlanningLineItems){
				if(String.isBlank(this.sum_productName)){
					this.sum_productName =  oppPlanningLineItem.Product_Name__c;
				}else{
					this.sum_productName +=  ' '+oppPlanningLineItem.Product_Name__c;
				}
			}
			opportunityPlanningList.add(eachOppPlanningWrapper.opportunityPlanning);
			eachOppPlanningWrapper.isGrouped = true;
			eachOppPlanningWrapper.isChecked = false;
			eachOppPlanningWrapper.addToExistingOpportunity = null;
			eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c = null;
		}
		calculateGroup();
	}

	public void calculateGroup(){
		this.sum_newLimit = 0;
		this.sum_VolumnOutstanding = 0;
		this.sum_FronEndFee = 0;
		this.sum_Fee = 0;
		for(Opportunity_Planning__c eachOppplanning : this.opportunityPlanningList){

			if(eachOppplanning.New_Limit__c != null){
				this.sum_newLimit += eachOppplanning.New_Limit__c;
			}
			if(eachOppplanning.Volume_Outstanding__c != null){
				this.sum_VolumnOutstanding += eachOppplanning.Volume_Outstanding__c;
			}
			if(eachOppplanning.Front_End_Fee__c != null){
				this.sum_FronEndFee += eachOppplanning.Front_End_Fee__c;
			}
			if(eachOppplanning.Fee__c != null){
				this.sum_Fee += eachOppplanning.Fee__c;
			}

		}

	}


	public void unGroupedFromCBSCallReport(){
		for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : this.oppPlanningWrapperList){
			eachOppPlanningWrapper.isGrouped = false;
		}
	}


//page opp planing
	public List<Opportunity_Custom_Controller.OppPlanningWrapper> oppPlanningPageWrapperList {get;set;}
	public Boolean isGroup = true;
	public GroupOpportunityPlanningWrapper(List<Opportunity_Custom_Controller.OppPlanningWrapper> oppPlanningWrapperList) {
		this.oppPlanningPageWrapperList = oppPlanningWrapperList;
		this.opportunityPlanningList = new List<Opportunity_Planning__c>();
		for(Opportunity_Custom_Controller.OppPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList){
			opportunityPlanningList.add(eachOppPlanningWrapper.newOppPlanning);
			if(String.isBlank(this.sum_productName)){
				this.sum_productName =  eachOppPlanningWrapper.productName;
			}else{
				this.sum_productName +=  ', '+eachOppPlanningWrapper.productName;
			}
			eachOppPlanningWrapper.isGrouped = true;
			eachOppPlanningWrapper.canEdit = false;
			eachOppPlanningWrapper.newOppPlanning.Add_to_Existing_Opportunity__c = null;
		}
		calculateGroup();
	}

	public void unGroupedFromOppPlanning(Boolean editable){
		for(Opportunity_Custom_Controller.OppPlanningWrapper eachOppPlanningWrapper : this.oppPlanningPageWrapperList){
			eachOppPlanningWrapper.isGrouped = false;
			eachOppPlanningWrapper.isChecked = false;
			eachOppPlanningWrapper.canEdit = editable;
		}
		isGroup = false;
	}
}