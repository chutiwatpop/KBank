/** Possible Parameter 
		START_DATE =2017-05-1 00:00:00&END_DATE =2017-05-30 00:00:00
		INITIAL_BATCH = True
*/
global class Upsert_BusinessCode_Schedule implements Schedulable{

	private String initial_batch;
	private String startDate;
	private String endDate;
	global Upsert_BusinessCode_Schedule(){}
	global Upsert_BusinessCode_Schedule(String initial_batch){
		this.initial_batch = initial_batch;
	}

	global Upsert_BusinessCode_Schedule(String startDate,String endDate){
		this.startDate = startDate;
		this.endDate = endDate;
	}

	global void execute(SchedulableContext sc) {
		run();
	}

	public void run(){
		String str = setCallOutParameterUpsertBusinessCode();
		upsertBusinessCode(str);
	}

	@future(callout=true)
	public static void upsertBusinessCode(String requestStr){
        HTTPResponse httpresponse = SME_CIRestWebservice.sendHTTPRequest(SME_CIRestWebservice.UPSERT_BUSINESS_CODE,requestStr);
    }

    public String setCallOutParameterUpsertBusinessCode(){
    	String str = '';
    	if(initial_batch != null && initial_batch == 'True'){
    		str ='INITIAL_BATCH=True';
    	}
    	else if(startDate != null && endDate != null){
    		str = 'START_DATE='+startDate +'&'+'END_DATE='+endDate;
    	}
    	return str;
    }
}