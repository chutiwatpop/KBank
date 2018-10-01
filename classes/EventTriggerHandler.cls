public with sharing class EventTriggerHandler extends TriggerHandler{
	public override void beforeInsert() {
		EventService.updateEventTeamHierachy((List<Event>) Trigger.new);
		EventService.stampUserExtension((List<Event>) Trigger.new);
		EventService.validateSecondaryCallreport((List<Event>) Trigger.new);
		EventService.stampRecordTypeAndConvertDate((List<Event>) Trigger.new);
		EventService.autoGenerateSubject((List<Event>) Trigger.new);
		EventService.validateCreateEventPermission((List<Event>) Trigger.new);
		EventService.validateCreateEventTelesalesPermission((List<Event>) Trigger.new);
	}
	public override void allBefore(){
		EventService.stampCBSSecondarycallReport((List<Event>) Trigger.new);
		EventService.stampJobAndPlanDate((List<Event>) Trigger.new, (Map<Id, Event>) Trigger.oldMap);
	}

	public override void beforeUpdate() {
		EventService.validateEditPermission((List<Event>) Trigger.new);
		EventService.updateRecordTypeAndConvertDate((List<Event>) Trigger.new, (Map<Id, Event>) Trigger.oldMap);
	}

	public override void afterInsert() {
		EventService.updatePrimaryCallreport((List<Event>) Trigger.new);
		EventService.validateContactThatUpsertCallReport((Map<Id, Event>) Trigger.newMap);
		EventService.notifyCreateCBSEvent((List<Event>) Trigger.new);
	}

	public override void allAfter() {
		EventService.updateAccountInfo((Map<Id,Event>)Trigger.oldMap,(List<Event>) Trigger.new);
		EventService.updateJobInfo((Map<Id,Event>)Trigger.oldMap,(List<Event>) Trigger.new);
	}

	public override void afterUpdate() {
		EventService.validateContactThatUpsertCallReport((Map<Id, Event>) Trigger.newMap);
	}
	
    public override void afterFinally(){
		EventService.updateTelesalesLeadStatus((List<Event>) Trigger.new);
	}
}