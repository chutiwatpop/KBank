global class CMASSchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CALLOUT_URL+'UpsertCMAS','');
	}
}