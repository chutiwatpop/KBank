/**
* @author chutiwat.s@beryl8.com
* @31/08/2015 createddate
*/
trigger CampaignTrigger on Campaign (before insert,before update,after insert,after update, before delete) {
	if(!system.isFuture() ){
		new CampaignTriggerHandler().run();
	}
}