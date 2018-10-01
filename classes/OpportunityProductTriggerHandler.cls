public class OpportunityProductTriggerHandler extends TriggerHandler {
	private Map<Id,List<OpportunityLineItem>> possibleOpportunityLineItemMap = null;

	public override void allBefore(){

	}

	public override void allAfter(){
		possibleOpportunityLineItemMap = OpportunityProductService.getMapListOppLineItemByOppId((List<OpportunityLineItem>) Trigger.new);
		OpportunityProductService.updateOpportunityResult((List<OpportunityLineItem>) Trigger.new,(Map<Id,OpportunityLineItem>) Trigger.oldMap);
	}

	public override void beforeInsert() {
		OpportunityProductService.setLastestCallReport((List<OpportunityLineItem>) Trigger.new);
	}

	public override void beforeUpdate(){
		User currentUser = UserService.getCurrentUserInfo();
		OpportunityProductService.checkUpdatePermission((List<OpportunityLineItem>) Trigger.new,currentUser);
		OpportunityProductService.setStatus((List<OpportunityLineItem>) Trigger.new,currentUser);
	}

	public override void afterInsert(){
		JunctionService junction_service = new JunctionService();
		junction_service.initialJunctionWithOpportunityId(possibleOpportunityLineItemMap.keySet());
	}

	public override void afterUpdate(){
		OpportunityProductService.updateApplicationHistoryInfo(((List<OpportunityLineItem>) Trigger.old),((List<OpportunityLineItem>) Trigger.new));
		JunctionService junction_service = new JunctionService();
		junction_service.initialJunctionWithOpportunityId(possibleOpportunityLineItemMap.keySet());
	}
}