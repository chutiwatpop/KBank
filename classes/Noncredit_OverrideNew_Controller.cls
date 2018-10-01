public with sharing class Noncredit_OverrideNew_Controller {
	public static String CALLREPORTID_PARAM = 'CallReportId';
	public static String OPPID_PARAM = 'OpportunityId';

	private Id opportunityId;
	public List<Call_Report__c> callreport {get;set;}
	public List<ProductWrapper> productWrapperList {get;set;}

	public List<Product_List_Master__c> recommendProductList{get;set;}
	private List<Product_List_Master__c> allSMEProductMasterList{get;set;}
	private Map<String,Product_List_Master__c> allproductMasterMapByProductName {get;set;}

	public Map<String,Set<String>> callResultsByProductId {get;set;}
	public Map<String,Set<String>> reasonSetMapByProductIdCallResult {get;set;}
	public Map<String,Boolean> isRequiredRemarkMapByProductIdCallResultReason {get;set;}

	public String searched_ProductName {get;set;}
	public String errorMsg_CreateProduct {get;set;}
	public Set<String> selected_Products {get;set;}
	public Set<String> remain_Products {get;set;}

	public Boolean isNoCallReport {get;set;}
	public Boolean allow_newNonCredit {get;set;}

	public Noncredit_OverrideNew_Controller() {
		this.selected_Products = new Set<String>();
		this.remain_Products = new Set<String>();
		String callReportId = ApexPages.currentPage().getParameters().get(Noncredit_OverrideNew_Controller.CALLREPORTID_PARAM);
		this.opportunityId = ApexPages.currentPage().getParameters().get(Noncredit_OverrideNew_Controller.OPPID_PARAM);
		this.callreport = [SELECT Id,Name,Recommend_Product__c,Allow_New_Non_Credit__c,Non_Credit__c,CIS_ID__r.CIS__c,CreatedBy.Employee_ID__c,CIS_ID__c,
			(SELECT Id,Name,Call_Result__c,Reason__c,Remark__c,SR_Number__c,External_ID__c,Product_Name1__r.id,Product_Name1__r.Product_Name__c 
			From Cross_Selling_Products__r) 
			From Call_Report__c WHERE Id = :callReportId LIMIT 1];
		if(this.callreport.isEmpty() || !this.callreport.get(0).Non_Credit__c){
			this.isNoCallReport = true;
		}else{
			this.isNoCallReport = false;
			this.allow_newNonCredit = this.callreport.get(0).Allow_New_Non_Credit__c;
			init();
		}
		
	}


	public void init(){
		this.allSMEProductMasterList = ProductMaster_Service.getProductListMasterWithCallResultsByRecodTypeName(GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_SME);
		this.allproductMasterMapByProductName = new Map<String,Product_List_Master__c>();
		for(Product_List_Master__c eachProduct : this.allSMEProductMasterList){
			allproductMasterMapByProductName.put(eachProduct.Product_Name__c,eachProduct);
		}

		initialAnswer();
		setUpDefaultRecommendProduct();
		setUpProductListWrapper();
	}

	public void initialAnswer(){
		this.callResultsByProductId = new Map<String,Set<String>>();
		this.reasonSetMapByProductIdCallResult = new Map<String,Set<String>>();
		this.isRequiredRemarkMapByProductIdCallResultReason = new Map<String,Boolean>();
		for(Product_List_Master__c eachProduct : this.allSMEProductMasterList){
			if(!callResultsByProductId.containsKey(eachProduct.id)){
				this.callResultsByProductId.put(eachProduct.id,new Set<String>());
			}
			for(Call_Result_Non_Credit_Master__c eachCallResult : eachProduct.Call_Result_Non_Credit_Master__r){
				if(!String.isBlank(eachCallResult.Call_Result__c)){
					this.callResultsByProductId.get(eachProduct.id).add(eachCallResult.Call_Result__c);
					String reason_Key = eachProduct.id+':'+eachCallResult.Call_Result__c;
					if(!this.reasonSetMapByProductIdCallResult.containsKey(reason_Key)){
						this.reasonSetMapByProductIdCallResult.put(reason_Key,new Set<String>());
					}
					if(!String.isBlank(eachCallResult.Reason__c)){
						this.reasonSetMapByProductIdCallResult.get(reason_Key).add(eachCallResult.Reason__c);
						String requiredRemark_Key = reason_Key+':'+eachCallResult.Reason__c;

						this.isRequiredRemarkMapByProductIdCallResultReason.put(requiredRemark_Key,eachCallResult.Required_Remark__c);
					}

				}
			}

		}
	}

	public void setUpDefaultRecommendProduct(){
		Set<String> recommendProductListFromCallPlan = new Set<String>();
		this.recommendProductList = new List<Product_List_Master__c>();
		if(!String.isBlank( this.callreport.get(0).Recommend_Product__c)){
			recommendProductListFromCallPlan = new Set<String>(this.callreport.get(0).Recommend_Product__c.split(ProductMaster_Service.product_separator));
		}

		//Recommend Products From CallPlan
		for(String productName : recommendProductListFromCallPlan){
			if(this.allproductMasterMapByProductName.containsKey(productName)){
				Product_List_Master__c product = this.allproductMasterMapByProductName.get(productName);
				this.recommendProductList.add(product);
			}
		}
		//Recommend Products From Product List Master
		for(Product_List_Master__c eachProduct : allSMEProductMasterList){
			if(eachProduct.Priority__c != null && !recommendProductListFromCallPlan.contains(eachProduct.Product_Name__c)){
				this.recommendProductList.add(eachProduct);
			}
		}
	}

	public void setUpProductListWrapper(){
		this.productWrapperList = new List<ProductWrapper>();
		if( this.callreport.get(0).Cross_Selling_Products__r.isEmpty() ){
			for(Product_List_Master__c eachProduct : this.recommendProductList){
				ProductWrapper productWrapper = newProductWrapper(eachProduct,null);
				this.productWrapperList.add(productWrapper);
			}
		}else{
			for(Cross_Selling_Products__c eachNoncreditProduct : this.callreport.get(0).Cross_Selling_Products__r){
				Product_List_Master__c eachProduct;
				if(this.allproductMasterMapByProductName.containsKey(eachNoncreditProduct.Product_Name1__r.Product_Name__c)){
					eachProduct = this.allproductMasterMapByProductName.get(eachNoncreditProduct.Product_Name1__r.Product_Name__c);
					ProductWrapper productWrapper = newProductWrapper(eachProduct,eachNoncreditProduct);
					
					String reason_Key = productWrapper.productMaster.id+':'+productWrapper.nonCreditProduct.Call_Result__c;
					if(this.reasonSetMapByProductIdCallResult.containsKey(reason_Key)){
						Set<String> reasonSet = this.reasonSetMapByProductIdCallResult.get(reason_Key);
						List<SelectOption> reasonOptions =  new List<SelectOption>();
						reasonOptions.add(new SelectOption(GlobalConstants.NONE,GlobalConstants.NONE));
						for(String eachReason : reasonSet){
							reasonOptions.add(new SelectOption(eachReason,eachReason));
						}
						productWrapper.reasonOptions = reasonOptions;

					}
					String requiredRemark_Key = reason_Key+':'+productWrapper.nonCreditProduct.Reason__c;
					if(this.isRequiredRemarkMapByProductIdCallResultReason.containsKey(requiredRemark_Key)){
						Boolean isrequiredRemark = this.isRequiredRemarkMapByProductIdCallResultReason.get(requiredRemark_Key);
						productWrapper.isRequired_remark = isrequiredRemark;
					}
					this.productWrapperList.add(productWrapper);
				}
			}
		}
	}

	public ProductWrapper newProductWrapper(Product_List_Master__c productMaster,Cross_Selling_Products__c nonCreditProduct){
		List<SelectOption> callResultOptions = new List<SelectOption>();
		callResultOptions.add(new SelectOption(GlobalConstants.NONE,GlobalConstants.NONE));
		if(this.callResultsByProductId.containsKey(productMaster.id)){
			Set<String> callResultSet = this.callResultsByProductId.get(productMaster.id);
			for(String eachCallResult : callResultSet){
				callResultOptions.add(new SelectOption(eachCallResult, eachCallResult));
			}
		}
		ProductWrapper productWrapper = new ProductWrapper(productMaster,callResultOptions,this.callreport.get(0),nonCreditProduct);
		this.selected_Products.add(productMaster.Product_Name__c);
		return productWrapper;

	}

	public void onChangeCallResult(){
		Integer index = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
		ProductWrapper productWrapper = this.productWrapperList.get(index);
		productWrapper.clearErrorMsg();
		String reasonSetMapByProductIdCallResult_Key = productWrapper.productMaster.id+':'+productWrapper.nonCreditProduct.Call_Result__c;
		List<SelectOption> reasonOptions =  new List<SelectOption>();
		if(productWrapper.nonCreditProduct.Call_Result__c != GlobalConstants.NONE && this.reasonSetMapByProductIdCallResult.containsKey(reasonSetMapByProductIdCallResult_Key)){
			Set<String> reasonSet = this.reasonSetMapByProductIdCallResult.get(reasonSetMapByProductIdCallResult_Key);
			reasonOptions.add(new SelectOption(GlobalConstants.NONE,GlobalConstants.NONE));
			for(String eachReason : reasonSet){
				reasonOptions.add(new SelectOption(eachReason,eachReason));
			}
		}
		productWrapper.reasonOptions = reasonOptions;
		productWrapper.isRequired_remark = false;
		productWrapper.placeHolder_remark = null;

	}

	public void onChangeReason(){
		Integer index = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
		ProductWrapper productWrapper = this.productWrapperList.get(index);
		productWrapper.clearErrorMsg();
		////
		String callResult = productWrapper.nonCreditProduct.Call_Result__c;
		String reason = productWrapper.nonCreditProduct.Reason__c;
		List<Call_Result_Non_Credit_Master__c> callresultList = [SELECT Id,Required_Remark__c,Remark_Placeholder__c From Call_Result_Non_Credit_Master__c WHERE Cross_Selling_Products__c =:productWrapper.productMaster.id AND Call_Result__c = :callResult AND Reason__c = :reason LIMIT 1];
		if(!callresultList.isEmpty()){
			productWrapper.isRequired_remark = callresultList.get(0).Required_Remark__c;
			productWrapper.placeHolder_remark = callresultList.get(0).Remark_Placeholder__c;
		}
	}

	public void createProduct(){
		ProductWrapper productWrapper;
		if(!this.allproductMasterMapByProductName.containsKey(this.searched_ProductName)){
			this.errorMsg_CreateProduct = ExceptionMessage.NO_PRODUCT_IN_PRODUCTLISTMASTER;
		}else{
			Product_List_Master__c productMaster = this.allproductMasterMapByProductName.get(this.searched_ProductName);
			productWrapper = newProductWrapper(productMaster,null);
			this.productWrapperList.add(productWrapper);
			clearAddProductModal();
		}
	}

	public void clearAddProductModal(){
		this.searched_ProductName = null;
		this.remain_Products = null;
		this.errorMsg_CreateProduct = null;
	}
	public void addProduct(){
		setAutoCompleteProductList();
	}

	public void removeProduct(){
		Integer removed_index = Integer.valueOf(apexpages.currentpage().getparameters().get('removed_index'));
		ProductWrapper product = this.productWrapperList.get(removed_index);
		this.selected_Products.remove(product.productMaster.Product_Name__c);
		this.productWrapperList.remove(removed_index);
	}

	public void setAutoCompleteProductList(){
		this.remain_Products = new Set<String>();
		for(Product_List_Master__c eachProduct : this.allSMEProductMasterList){
			this.remain_Products.add(eachProduct.Product_Name__c);
		}
		this.remain_Products.removeAll(this.selected_Products);
	}

	private Boolean validateBeforeSave(){
		Boolean isPass = true;
		for(ProductWrapper eachProduct : this.productWrapperList){
			if( isBlankOrNoneSelect( eachProduct.nonCreditProduct.Call_Result__c)){
				eachProduct.errorMsg_CallResult = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
				eachProduct.errorMsg_Reason = null;
				isPass = false;
			}else{
				eachProduct.errorMsg_CallResult = null;

				if(isBlankOrNoneSelect(eachProduct.nonCreditProduct.Reason__c)){
				eachProduct.errorMsg_Reason = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
				isPass = false;
				}else{
					eachProduct.errorMsg_Reason = null;
				}
			}
			String requiredRemark_Key = eachProduct.productMaster.id+':'+eachProduct.nonCreditProduct.Call_Result__c+':'+eachProduct.nonCreditProduct.Reason__c;
			Boolean isRequired_remark = this.isRequiredRemarkMapByProductIdCallResultReason.containsKey(requiredRemark_Key) ? this.isRequiredRemarkMapByProductIdCallResultReason.get(requiredRemark_Key) : false;
			if(isRequired_remark && isBlankOrNoneSelect(eachProduct.nonCreditProduct.Remark__c)){
				eachProduct.errorMsg_Remark = ExceptionMessage.THIS_FIELD_IS_REQUIRED;
				isPass = false;
			}else{
				eachProduct.errorMsg_Remark = null;
			}
			if(!String.isBlank(eachProduct.nonCreditProduct.SR_Number__c) &&
				(eachProduct.nonCreditProduct.SR_Number__c.length() < 11 || eachProduct.nonCreditProduct.SR_Number__c.length() > 14)
			){
				eachProduct.errorMsg_SRNumber = ExceptionMessage.SR_NUMBER_CHARACTERS_LIMIT;
				isPass = false;
			}else{
				eachProduct.errorMsg_SRNumber = null;
			}
		}
		return isPass;
	}

	public PageReference save(){
		PageReference pagereference = null;
		if(validateBeforeSave()){
			List<Cross_Selling_Products__c> callReportProductList = new List<Cross_Selling_Products__c>();
			for(ProductWrapper eachProduct : this.productWrapperList){
				//if(eachProduct.isRecordEditable){
					callReportProductList.add(eachProduct.nonCreditProduct);
				//}
			}
			Savepoint sp = Database.setSavepoint();
			try{
				if(!callReportProductList.isEmpty()){

					upsert callReportProductList;

					Call_Report__c callReportToUpdate = this.callreport.get(0);
					callReportToUpdate.Allow_New_Non_Credit__c = false;
					update callReportToUpdate;

					if(this.opportunityId != null){
						pagereference =  new PageReference('/'+opportunityId);
					}else{
						pagereference =  new PageReference('/'+callReportToUpdate.id);
					}
				}
			}catch(Exception ex){
				String errorMessage = ex.getMessage();
				if(!String.isBlank(errorMessage) && errorMessage.contains('DUPLICATE_VALUE')){
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'SR Number is duplicated');
					ApexPages.addMessage(myMsg);
				}
				Database.rollback(sp);
			}
		}
		return pagereference;
	}

	/**
	Product Wrapper
	**/
	public class ProductWrapper{
		public Product_List_Master__c productMaster {get;set;}
		public Cross_Selling_Products__c  nonCreditProduct{get;set;}
		public List<SelectOption> callResultOptions {get;set;}
		public List<SelectOption> reasonOptions {get;set;}
		public Boolean isRequired_remark {get;set;}
		public String placeHolder_remark {get;set;}
		public Boolean isRecordEditable {get;set;}

		public String errorMsg_CallResult {get;set;}
		public String errorMsg_Reason {get;set;}
		public String errorMsg_Remark {get;set;}
		public String errorMsg_SRNumber {get;set;}

		public Boolean isExsitingProduct {get;set;}

		public ProductWrapper(Product_List_Master__c productMaster,List<SelectOption> callResultOptions,Call_Report__c callReport,Cross_Selling_Products__c nonCreditProduct){
			this.productMaster = productMaster;
			this.callResultOptions = callResultOptions;
			if(nonCreditProduct == null){
				this.nonCreditProduct = CallReport_Product_Service.newCallReportNonCreditProduct(callReport, this.productMaster);
				this.isRecordEditable = true;
				this.isExsitingProduct = false;

			}else{
				this.nonCreditProduct = nonCreditProduct;
				this.isExsitingProduct = true;
				this.isRecordEditable = callReport.Allow_New_Non_Credit__c;
			}
			isRequired_remark = false;
		}

		public Boolean getRenderReasonColumn(){
			Boolean isRender = !isBlankOrNoneSelect(this.nonCreditProduct.Call_Result__c);
			return isRender;
		}

		public void clearErrorMsg(){
			this.errorMsg_CallResult = null;
			this.errorMsg_Reason = null;
			this.errorMsg_Remark = null;
		}

	}

	/**
	helper
	**/
	public static Boolean isBlankOrNoneSelect(String str){
		Boolean isBlank = ( String.isBlank(str) || str == GlobalConstants.NONE );
		return isBlank;
	}


}