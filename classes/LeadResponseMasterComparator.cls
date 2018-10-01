public class LeadResponseMasterComparator implements Comparable{
	public Lead_Response_Master__c leadResponseMaster;
	private String message;
	private Integer messageIndex;
	public LeadResponseMasterComparator(Lead_Response_Master__c leadResponseMaster) {
		this.leadResponseMaster = leadResponseMaster;
		this.message = leadResponseMaster.Message__c;
		this.messageIndex = getMessageIndex(leadResponseMaster.Message__c);
	}

	public Integer compareTo(Object compareTo) {
		Integer compareResult;
		LeadResponseMasterComparator compareToObj = (LeadResponseMasterComparator)compareTo;
		Integer compareToMessageIndex = getMessageIndex(compareToObj.leadResponseMaster.Message__c);
		
		if (messageIndex < compareToMessageIndex) compareResult = -1;
		if (messageIndex == compareToMessageIndex) compareResult = 0;
        if (messageIndex > compareToMessageIndex) compareResult = 1;

        return compareResult;
	}

	private Integer getMessageIndex(String inputMessage){
		Integer index = 0;
		try{
			if(inputMessage.contains('.') && inputMessage.contains(' ')){
				String stringIndex = inputMessage.substringBefore(' ').replace('.','');
				index = Integer.valueOf(stringIndex);
			}
		}catch(Exception e){}
		return index;
	} 
}