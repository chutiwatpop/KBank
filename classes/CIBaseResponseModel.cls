global virtual class CIBaseResponseModel {
	public Boolean success;
	public JobInfo jobinfo;
	public ErrorResponse error;

	public CIBaseResponseModel() {
		
	}

	global class ErrorResponse {
		global ErrorResponse() {}
		public String code;
		public String message;
		public JobInfo details;
	}

	global class JobInfo {
		global JobInfo() {}
		public String jobstarttime;
		public String jobid;
		public String faulttime;
		public String activityname;
		public String orchestration;
		public String cihostname;
		public String sfId;
	}
}