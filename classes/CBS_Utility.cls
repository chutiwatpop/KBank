public with sharing class CBS_Utility {
	public static Map<String,RecordType> getCallReportRecordTypesMap(){
        List<RecordType> recTypes = CBS_CallPlanCallReport_Service.getCallplanCallReportRecordTypes();
        Map<String,RecordType> resultCallReportsMap = new Map<String,RecordType>();
        for(RecordType recType:recTypes){
            resultCallReportsMap.put(recType.DeveloperName,recType);
        }
        return resultCallReportsMap;
    }
    public static List<String> disjoin(String toDisjoinString,String separator){
        List<String> disjointList;
        Boolean isToDisjoinStringNotBlank = !String.isBlank(toDisjoinString);
        if(isToDisjoinStringNotBlank){
            disjointList = toDisjoinString.split(separator);
        }else{
            disjointList = new List<String>();
        }
        return disjointList;
    }


    public static List<Product_List_Master__c> getCBSProductConfigList(){
        List<Product_List_Master__c> cbsProductList =  [SELECT Id,Name,Product_Group_Order__c,Order_In_Group__c,Product_Group__c,Product_Name__c,Call_Report_Field_API_Name__c, Help_Text__c,Is_Active__c,Is_Active_Fee__c,Is_Active_Front_End_Fee__c,Is_Active_New_Limit__c,Is_Active_Volume_Outstanding__c,
        Is_not_Allow_0_Fee__c,Is_not_Allow_0_Front_End_Fee__c,Is_not_Allow_0_New_Limit__c,Is_not_Allow_0_Volume_Outstanding__c,Is_Required_Fee__c,Is_Required_Front_End_Fee__c,Is_Required_New_Limit__c,
        Is_Required_Volume_Outstanding__c,Fixed_Type__c,Default_Type__c
        From Product_List_Master__c
        WHERE RecordType.DeveloperName = :GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_CBS
        ORDER By Product_Group_Order__c,Order_In_Group__c];
        return cbsProductList;
    }

 

    public static Map<String,Product_List_Master__c> getCBSProductConfigMapByProductCode(){
        List<Product_List_Master__c> cbsProductList =  CBS_Utility.getCBSProductConfigList();
        Map<String,Product_List_Master__c> cbsProductMapByName = new Map<String,Product_List_Master__c>();
        for(Product_List_Master__c productConfig : cbsProductList){
            cbsProductMapByName.put(productConfig.Name,productConfig);
        }
        return cbsProductMapByName;
    }

    public static List<Opportunity_Planning_Type__c> getOppPlanningTypeCustomSetting(){
        List<Opportunity_Planning_Type__c> oppPlanningCustomSettingList = [SELECT id,Type__c,To_Opportunity_Amount__c,Submit_Issue_in_Opportunity__c,Opportunity_Type__c,Allow_Grouping__c,Allow_Edit_Amount__c 
                                                                            From Opportunity_Planning_Type__c];
        return oppPlanningCustomSettingList;
    }

    public static Map<String,Opportunity_Planning_Type__c> getOppPlanningTypeCustomSettingMapByType(){
        Map<String,Opportunity_Planning_Type__c> oppPlanningCSMapByType = new Map<String,Opportunity_Planning_Type__c>();
        List<Opportunity_Planning_Type__c> oppPlanningCustomSettingList = getOppPlanningTypeCustomSetting();
        for(Opportunity_Planning_Type__c eachOppPlaningCS : oppPlanningCustomSettingList){
            oppPlanningCSMapByType.put(eachOppPlaningCS.Type__c,eachOppPlaningCS);
        }
        return oppPlanningCSMapByType;
    }

}