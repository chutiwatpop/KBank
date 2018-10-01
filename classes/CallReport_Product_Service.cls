public with sharing class CallReport_Product_Service {
    public CallReport_Product_Service() {}

    public static Cross_Selling_Products__c newCallReportNonCreditProduct(Call_Report__c callReport,Product_List_Master__c productMaster){
        Cross_Selling_Products__c nonCreditProduct = new Cross_Selling_Products__c(Product_Name1__c = productMaster.id,Call_Plan_Call_Report__c = callReport.id,CIS_ID__c=callReport.CIS_ID__c);
        nonCreditProduct.External_Id__c = getExternalIdForNonCredit(callReport,productMaster);
        return nonCreditProduct;
    }

    public static String getExternalIdForNonCredit(Call_Report__c callReport,Product_List_Master__c productMaster){
        String productName = productMaster.Product_Name__c.left(20);
        String externalId = productName+':'+callReport.CIS_ID__r.CIS__c+':'+callReport.CreatedBy.Employee_ID__c+':'+callReport.Name;
        return externalId.left(50);
    }

    public static List< Database.UpsertResult> upsertCallReportProduct(List<Cross_Selling_Products__c> callReportproductList){
        Database.UpsertResult[] upsertResult  = Database.upsert(callReportproductList,Cross_Selling_Products__c.External_Id__c, true);
        return upsertResult;
    }
}