public class TransformationFixedMock implements IProductUsageTransformation {
	private String cisId;
	private String productCode;
	private IProductUsageConfig productUsageConfig;
	private final String typeId = '74';
	private Map<String, List<String>> columnHeaderLabelConfig;

	public TransformationFixedMock(String cisId, String productCode, IProductUsageConfig productUsageConfig) {
		this.cisId = cisId;
		this.productCode = productCode;
		this.productUsageConfig = productUsageConfig;
	}

	public ProductUsageController.ProductUsageModel transform() {
		ProductUsageController.ProductUsageModel productUsageModel = new ProductUsageController.ProductUsageModel();

		setProductUsageSiteMap(productUsageModel);
        setProductUsageTable(productUsageModel);

		return productUsageModel;
	}

	private void setProductUsageSiteMap(ProductUsageController.ProductUsageModel productUsageModel) {
        productUsageModel.siteMap = productUsageConfig.getSiteMaps(productCode);
    }

	private void setProductUsageTable(ProductUsageController.ProductUsageModel productUsageModel) {
		// HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT,'CIS_ID=' + cisId + '&SCR_STM_CD=' +typeId);
		// CustomerWealthModel customerWealth = (CustomerWealthModel) JSON.deserialize(resp.getBody(), CustomerWealthModel.class);

		// productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		// setProductUsageDetail(customerWealth, productUsageTable);

		// productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
		setFirstLevel(productUsageModel);
		setSecondLevel(productUsageModel);
	}

	private void setFirstLevel(ProductUsageController.ProductUsageModel productUsageModel) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
		List<List<String>> details = new List<List<String>>();

		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 1);
		details.add(setProductUsageDetailFirstLevel('xxx-x-x6465-x', '0001', 'สาขาสำนักสีลม', 'Fixed Deposit (KB)', 'แช่มชูศรี ปัญจะศิลา', 'บัญชีเดี่ยว', 'FIXMOCK_xxx-x-x6465-x_2_1'));
		details.add(setProductUsageDetailFirstLevel('xxx-x-x0140-x', '0070', 'สาขาบางเขน', 'Fixed Deposit (KB)', 'แช่มชูศรี ปัญจะศิลา', 'บัญชีเดี่ยว', 'FIXMOCK_xxx-x-x0140-x_2_1'));
		details.add(setProductUsageDetailFirstLevel('xxx-x-x1234-x', '0001', 'สาขาสำนักสีลม', 'Fixed Deposit (KB)', 'แช่มชูศรี ปัญจะศิลา', 'บัญชีเดี่ยว', ''));
		productUsageTable.body = details;
		productUsageModel.productUsageTables.put(productCode + '_0', productUsageTable);
	}

	private List<String> setProductUsageDetailFirstLevel(String arId, String branchNo, String branchName, 
	String pdDesc, String arName, String arTypeCode, String nextLevelKey) {
		List<String> detailColumns = new List<String>();

		detailColumns.add(arId); // เลขที่บัญชี
		detailColumns.add(branchNo); // รหัสสาขา
		detailColumns.add(branchName); // ชื่อสาขา
		detailColumns.add(pdDesc); // ผลิตภัณฑ์
		detailColumns.add(arName); // ชื่อบัญชี
		detailColumns.add(arTypeCode); // ประเภทบัญชี
		detailColumns.add(nextLevelKey); // nextLevelKey

		return detailColumns;
	}

	private void setSecondLevel(ProductUsageController.ProductUsageModel productUsageModel) {
		ProductUsageController.ProductUsageTable productUsageTable = new ProductUsageController.ProductUsageTable();
		List<List<String>> details = new List<List<String>>();

		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 2);
		details.add(setProductUsageDetailFirstLevel('001','12M','204536.72','200000','1.3%','','2017/10/27','2018/10/27','2015/10/27','3003851'));
		details.add(setProductUsageDetailFirstLevel('002','12M','817777.68','800000','1.3%','','2018/03/29','2019/03/29','2016/03/29','3003851'));
		productUsageTable.body = details;
		productUsageModel.productUsageTables.put('FIXMOCK_xxx-x-x6465-x_2_1', productUsageTable);

		details = new List<List<String>>();
		productUsageTable = new ProductUsageController.ProductUsageTable();
		productUsageTable.columnHeaders = productUsageConfig.getColumnHeaders(productCode, 2);
		details.add(setProductUsageDetailFirstLevel('001','3M','130734.42','120000','0.9%','','2018/07/15','2018/10/15','2015/07/15','3003851'));
		details.add(setProductUsageDetailFirstLevel('002','6M','88622.65','80000','','1.15%','2018/08/18','2019/02/18','2015/02/18','3003851'));
		productUsageTable.body = details;
		productUsageModel.productUsageTables.put('FIXMOCK_xxx-x-x0140-x_2_1', productUsageTable);
	}

	private List<String> setProductUsageDetailFirstLevel(String subAr, String subArTerm, String crnBal, String holdBal, String subEffRate, String subEffRateType,
	String effDate, String endDate, String arOpenDate, String ipId) {
		List<String> detailColumns = new List<String>();

		detailColumns.add(subAr); // เลขที่บัญชีระดับ Sub
		detailColumns.add(subArTerm); // ระยะเวลาฝาก
		detailColumns.add(crnBal); // ยอดคงเหลือ (Outstanding)
		detailColumns.add(holdBal); // Hold Balance Amount
		detailColumns.add(subEffRate); // อัตราดอกเบี้ยปัจจุบัน
		detailColumns.add(subEffRateType); // ประเภทอัตราดอกเบี้ย
		detailColumns.add(effDate); // วันที่อัตราดอกเบี้ยมีผล
		detailColumns.add(endDate); // วันที่อัตราดอกเบี้ยสิ้นสุด
		detailColumns.add(arOpenDate); // วันเปิดบัญชี
		detailColumns.add(ipId); // CIS_ID

		return detailColumns;
	}

}