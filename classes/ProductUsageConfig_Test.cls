@isTest
private class ProductUsageConfig_Test {
    private static final String productCode01 = 'P01';
    private static final String productCode02 = 'P02';

    @testSetup static void setupMockData() {
        List<Product_Usage_Config__c> columnHeaderConfig = new List<Product_Usage_Config__c>();
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-01',
            Product_Code__c = productCode01,
            Column_Code__c = 'col01',
            TH_Label__c = 'Column 01',
            EN_Label__c = 'Column 01',
            Data_Type__c = 'string',
            Level__c = 1,
            Order__c = 1,
            Visible__c = true
        ));
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-02',
            Product_Code__c = productCode01,
            Column_Code__c = 'col02',
            TH_Label__c = 'Column 02',
            EN_Label__c = 'Column 02',
            Data_Type__c = 'date',
            Level__c = 1,
            Order__c = 2,
            Visible__c = true
        ));
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-03',
            Product_Code__c = productCode01,
            Column_Code__c = 'col03',
            TH_Label__c = 'Column 03',
            EN_Label__c = 'Column 03',
            Data_Type__c = 'string',
            Level__c = 1,
            Order__c = 3,
            Visible__c = true
        ));

        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-04',
            Product_Code__c = productCode02,
            Column_Code__c = 'col01',
            TH_Label__c = 'Column 01',
            EN_Label__c = 'Column 01',
            Data_Type__c = 'string',
            Level__c = 1,
            Order__c = 1,
            Visible__c = true
        ));
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-05',
            Product_Code__c = productCode02,
            Column_Code__c = 'col02',
            TH_Label__c = 'Column 02',
            EN_Label__c = 'Column 02',
            Data_Type__c = 'string',
            Level__c = 1,
            Order__c = 2,
            Visible__c = true
        ));

        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-06',
            Product_Code__c = productCode02,
            Column_Code__c = 'colsub01',
            TH_Label__c = 'Column Sub 01',
            EN_Label__c = 'Column Sub 01',
            Data_Type__c = 'string',
            Level__c = 2,
            Order__c = 1,
            Visible__c = true
        ));
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-078',
            Product_Code__c = productCode02,
            Column_Code__c = 'colsub02',
            TH_Label__c = 'Column Sub 02',
            EN_Label__c = 'Column Sub 02',
            Data_Type__c = 'string',
            Level__c = 2,
            Order__c = 2,
            Visible__c = true
        ));
        columnHeaderConfig.add(new Product_Usage_Config__c(
            Name = 'PH-TEST-08',
            Product_Code__c = productCode02,
            Column_Code__c = 'col03',
            TH_Label__c = 'Column Sub 03',
            EN_Label__c = 'Column Sub 03',
            Data_Type__c = 'currency',
            Level__c = 2,
            Order__c = 3,
            Visible__c = true
        ));
        insert columnHeaderConfig;

        List<Product_Usage_Site_Map__c> siteMapConfig = new List<Product_Usage_Site_Map__c>();
        siteMapConfig.add(new Product_Usage_Site_Map__c(
            Name = 'PS-TEST-01',
            Product_Code__c = productCode01,
            TH_Label__c = 'Product 1',
            EN_Label__c = 'Product 1',
            Level__c = 1
        ));
        siteMapConfig.add(new Product_Usage_Site_Map__c(
            Name = 'PS-TEST-02',
            Product_Code__c = productCode02,
            TH_Label__c = 'Product 2',
            EN_Label__c = 'Product 2',
            Level__c = 1
        ));
        siteMapConfig.add(new Product_Usage_Site_Map__c(
            Name = 'PS-TEST-03',
            Product_Code__c = productCode02,
            TH_Label__c = 'Sub Product 1',
            EN_Label__c = 'Sub Product 1',
            Level__c = 2
        ));
        insert siteMapConfig;
    }

    @isTest static void test_getColumnHeaders_product1Level() {
        User tester = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
        if(tester.LanguageLocaleKey != 'th') {
            tester.LanguageLocaleKey = 'th';
            update tester;
        }
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        List<ProductUsageController.ProductUsageField> columnHeaders = productUsageConfig.getColumnHeaders(productCode01, 1);
        system.assertEquals(3, columnHeaders.size());
        system.assertEquals('date', columnHeaders.get(1).type);
        system.assertEquals('Column 03', columnHeaders.get(2).text);
    }

    @isTest static void test_getColumnHeaders_product2Level() {
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        List<ProductUsageController.ProductUsageField> columnHeaders = productUsageConfig.getColumnHeaders(productCode02, 1);
        system.assertEquals(2, columnHeaders.size());
        system.assertEquals('string', columnHeaders.get(0).type);
        system.assertEquals('Column 02', columnHeaders.get(1).text);

        columnHeaders = productUsageConfig.getColumnHeaders(productCode02, 2);
        system.assertEquals(3, columnHeaders.size());
        system.assertEquals('currency', columnHeaders.get(2).type);
        system.assertEquals('Column Sub 01', columnHeaders.get(0).text);
    }

    @isTest static void test_getColumnHeaders_noItem() {
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        List<ProductUsageController.ProductUsageField> columnHeaders = productUsageConfig.getColumnHeaders(productCode01, 2);
        system.assertEquals(0, columnHeaders.size());
    }

    @isTest static void test_getSiteMaps_product1Level() {
        User tester = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
        if(tester.LanguageLocaleKey != 'th') {
            tester.LanguageLocaleKey = 'th';
            update tester;
        }
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        ProductUsageController.SiteMapModel siteMapModel = productUsageConfig.getSiteMaps(productCode01);
        system.assertEquals(1, siteMapModel.siteMaps.size());
        system.assertEquals('Product 1', siteMapModel.siteMaps.get('1').label);
        system.assertEquals('1', siteMapModel.siteMaps.get('1').level);
    }

    @isTest static void test_getSiteMaps_product2Level() {
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        ProductUsageController.SiteMapModel siteMapModel = productUsageConfig.getSiteMaps(productCode02);
        system.assertEquals(2, siteMapModel.siteMaps.size());
        system.assertEquals('Product 2', siteMapModel.siteMaps.get('1').label);
        system.assertEquals('1', siteMapModel.siteMaps.get('1').level);
        system.assertEquals('Sub Product 1', siteMapModel.siteMaps.get('2').label);
        system.assertEquals('2', siteMapModel.siteMaps.get('2').level);
    }

    @isTest static void test_getSiteMaps_noItem() {
        IProductUsageConfig productUsageConfig = new ProductUsageConfig();
        ProductUsageController.SiteMapModel siteMapModel = productUsageConfig.getSiteMaps('P00');
        system.assertEquals(0, siteMapModel.siteMaps.size());
    }
}