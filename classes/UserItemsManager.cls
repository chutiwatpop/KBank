public with sharing class UserItemsManager {
	private List<User> newUsers;
	private List<User> oldUsers;
	private List<User_MaskModel> userMasks;
	private IOwnershipAssignment ownershipAssigner;

	public UserItemsManager(List<User_MaskModel> userMasks) {
		this.userMasks = userMasks;
	}

	private void setUpUserMaskModels(){

	}

	private void getRelatedOpportunity(List<Id> ownerIds){
		List<Opportunity> opps = [SELECT Id,OwnerId From Opportunity WHERE OwnerId IN :ownerIds];
	}

	//private void getRelatedOpportunityProduct(List<Id> ownerIds){
	//	List<OpportunityLineItem > oppListItems = [SELECT Id,OwnerId From OpportunityLineItem ];
	//}

	private void getRelatedEvent(List<Id> ownerIds){
		List<Event> events = [SELECT Id,OwnerId From Event WHERE OwnerId IN :ownerIds];
	}

	private void getRelatedTargetList(List<Id> onwerIds){

	}



}