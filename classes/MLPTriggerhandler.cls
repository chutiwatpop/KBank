public class MLPTriggerhandler extends TriggerHandler{
	public override void beforeInsert() {
		for(Lead_MLP__c eachMLP : (List<Lead_MLP__c>) Trigger.new){
			List<String> prosFieldList = eachMLP.PROSP_NM__c.split('\\|');
			if(eachMLP.Source_System_ID__c == '452' && prosFieldList.size() > 3){
				eachMLP.Mobile_Number__c = prosFieldList[2];
			}
		}
	}
}