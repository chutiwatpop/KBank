public class ProductUsageConfig implements IProductUsageConfig {

    public List<ProductUsageController.ProductUsageField> getColumnHeaders(String productCode, Integer level) {
        String labelField = getLabelField();
        List<ProductUsageController.ProductUsageField> columnHeaders = new List<ProductUsageController.ProductUsageField>();
        List<Product_Usage_Config__c> columnHeaderConfig = [SELECT Column_Code__c, TH_Label__c, EN_Label__c, Data_Type__c, Visible__c, Next_Level_Column_Index__c FROM Product_Usage_Config__c WHERE Product_Code__c = :productCode AND Level__c =:level ORDER BY Order__c];
        for(Product_Usage_Config__c eachConfig : columnHeaderConfig) {
            ProductUsageController.ProductUsageField columnHeader = new ProductUsageController.ProductUsageField(
                (String) eachConfig.get(labelField),
                eachConfig.Data_Type__c,
                eachConfig.Next_Level_Column_Index__c,
                eachConfig.Visible__c
            );
            columnHeaders.add(columnHeader);
        }
        return columnHeaders;
    }

    public ProductUsageController.SiteMapModel getSiteMaps(String productCode) {
        String labelField = getLabelField();
        ProductUsageController.SiteMapModel siteMapModel = new ProductUsageController.SiteMapModel();
        Map<String, ProductUsageController.SiteMapDetail> siteMaps = new Map<String, ProductUsageController.SiteMapDetail>();
        List<Product_Usage_Site_Map__c> siteMapConfig = [SELECT Level__c, TH_Label__c, EN_Label__c, Column_Index__c FROM Product_Usage_Site_Map__c WHERE Product_Code__c = :productCode ORDER BY Level__c];
        for(Product_Usage_Site_Map__c eachConfig : siteMapConfig) {
            String level = String.valueOf(eachConfig.Level__c.stripTrailingZeros());
            ProductUsageController.SiteMapDetail siteMap = new ProductUsageController.SiteMapDetail(
                level,
                (String) eachConfig.get(labelField),
                eachConfig.Column_Index__c
            );
            siteMaps.put(level, siteMap);
        }
        siteMapModel.siteMaps = siteMaps;
        return siteMapModel;
    }

    private String getLabelField() {
        String fieldName = 'EN_Label__c';
        if(UserInfo.getLanguage() == 'th') {
            fieldName = 'TH_Label__c';
        }
        return fieldName;
    }
}