public interface IProductUsageConfig {
    List<ProductUsageController.ProductUsageField> getColumnHeaders(String productCode, Integer level);
    ProductUsageController.SiteMapModel getSiteMaps(String productCode);
}