public with sharing class CBS_OpptPlanningCallReport_Controller {

	public Call_Report__c callRep;
    public String cisId;

    public Map<String,List<opportunityPlanningWrapper>> oppPlanningMapByproductGroup {get;set;}
    public Map<String,Boolean> shouldRenderOppPlanningGroupMapByProductGroupName {get;set;}
    public Map<String,Product_List_Master__c> cbsProductConfigMapByName {get;set;}
    public Set<String> productGroupList {get;set;}
    public Boolean haveOpportunityPlanning {get;set;}

    public class opportunityPlanningWrapper{

        public List<Opportunity_Planning_Line_Item__c> oppPlanningLineItems{get;set;}
        public Opportunity_Planning__c opportunityPlanning{get;set;}


        public opportunityPlanningWrapper(Opportunity_Planning__c oppPlanning,List<Opportunity_Planning_Line_Item__c> productline,String oldStatus){
            this.opportunityPlanning = oppPlanning;
            this.oppPlanningLineItems = productline;

        }

    }
    
    public CBS_OpptPlanningCallReport_Controller(ApexPages.StandardController stdController) {
        this.callRep = (Call_Report__c)stdController.getRecord();
        this.oppPlanningMapByproductGroup = new Map<String,List<opportunityPlanningWrapper>>();
        this.shouldRenderOppPlanningGroupMapByProductGroupName = new Map<String,Boolean>();
        this.cbsProductConfigMapByName = CBS_Utility.getCBSProductConfigMapByProductCode();
        this.haveOpportunityPlanning = false;
        cisId = getCISId();
    
        setUpProductConfig();
        List<Opportunity_Planning__c> fetchOppPlannings = CBS_CallPlanCallReportWOS_Service.getOpportunityPlannings(cisId);
        
        if(!fetchOppPlannings.isEmpty()){
            haveOpportunityPlanning = true;
            for(Opportunity_Planning__c oppPlan:fetchOppPlannings){
                String productGroup = oppPlan.Opportunity_Planning_Line_Items__r.get(0).Call_Report_Product_List_Master__r.Product_Group__c;
                if(!String.isBlank(productGroup )){
                    if(!this.oppPlanningMapByproductGroup.containsKey(productGroup)){
                        shouldRenderOppPlanningGroupMapByProductGroupName.put(productGroup,true);
                        oppPlanningMapByproductGroup.put(productGroup,new List<opportunityPlanningWrapper>());
                    }
                    opportunityPlanningWrapper oppPlaningWrapper = new opportunityPlanningWrapper(oppPlan,oppPlan.Opportunity_Planning_Line_Items__r,oppPlan.Status__c);
                    this.oppPlanningMapByproductGroup.get(productGroup).add(oppPlaningWrapper);
                }      
            }
        }
    }

    private void setUpProductConfig(){
        this.productGroupList = new Set<String>();
        for(Product_List_Master__c cbsProductConfig : cbsProductConfigMapByName.values()){
            productGroupList.add(cbsProductConfig.Product_Group__c);
        }

        for(String eachProduchGroup : productGroupList){
            shouldRenderOppPlanningGroupMapByProductGroupName.put(eachProduchGroup,false);
        }
    }

    public Id getCISId(){
        Call_Report__c dummyCallRep = [SELECT CIS_ID__r.Id FROM Call_Report__c WHERE Id =: callRep.Id];
        return dummyCallRep.CIS_ID__r.Id;
    }
    
}