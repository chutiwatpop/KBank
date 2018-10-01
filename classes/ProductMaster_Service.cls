public with sharing class ProductMaster_Service {
    public static String recommendProducts;
    public static String product_separator = '\n';
    public ProductMaster_Service() {}

    public static List<Product_List_Master__c> getProductListMasterWithCallResultsByRecodTypeName(String recordTypeName){
        List<Product_List_Master__c> productList =  [SELECT Id,Name,Product_Name__c,Is_Active__c,Priority__c,External_ID__c,
        (SELECT Id,Call_Result__c,Reason__c,Required_Remark__c,Remark_Placeholder__c From Call_Result_Non_Credit_Master__r ORDER BY Cross_Selling_Products__c, Id ASC, Reason__c ASC )
        From Product_List_Master__c
        WHERE RecordType.DeveloperName = :recordTypeName AND Is_Active__c = true
        ORDER By Priority__c ASC NULLS LAST,Product_Name__c ASC];
        return productList;
    }

    public static String getRecommendProductForCallReport(){
        String recommendProducts;
        List<Product_List_Master__c> productList =  [SELECT Id,Name,Priority__c,Product_Name__c From Product_List_Master__c 
        WHERE Is_Active__c = true AND RecordType.DeveloperName = :GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_SME AND Priority__c != null
        ORDER BY Priority__c ASC,Product_Name__c ASC];
        for(Product_List_Master__c eachProduct : productList){
            if(recommendProducts == null){
                recommendProducts = eachProduct.Product_Name__c;
            }else{
                recommendProducts += product_separator+eachProduct.Product_Name__c;
            }
        }
        return recommendProducts;
    }

    @future 
    public static void updateProductListMasterFuture(String productList) {
        List<Product_List_Master__c> productListMaster = (List<Product_List_Master__c>) JSON.deserialize(productList,List<Product_List_Master__c>.class );
        update productListMaster;
    }


}