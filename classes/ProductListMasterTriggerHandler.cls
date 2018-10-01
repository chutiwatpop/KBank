public class ProductListMasterTriggerHandler extends TriggerHandler{


	public override void afterInsert(){
		List<Product_List_Master__c> productListToUpdate = new List<Product_List_Master__c>();
		for(Product_List_Master__c eachProductMaster : (List<Product_List_Master__c>)Trigger.new){
			
			Product_List_Master__c eachProductListToUpdate = new Product_List_Master__c(Id=eachProductMaster.id,External_ID__c=eachProductMaster.name);
			productListToUpdate.add(eachProductListToUpdate);
	  	}
	  	ProductMaster_Service.updateProductListMasterFuture(JSON.serialize(productListToUpdate));
	}
}