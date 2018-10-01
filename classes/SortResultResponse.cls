public class SortResultResponse {
	public SortResultResponse() {
		
	}

	public class SortResponse {
		public List<String> cis_id;
		public String errorMessage;
	}

	public SortResponse sortResponse;

	public static SortResultResponse parse(String json) {
		return (SortResultResponse) System.JSON.deserialize(json, SortResultResponse.class);
	}

}