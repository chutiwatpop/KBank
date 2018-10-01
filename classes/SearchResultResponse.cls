public class SearchResultResponse {

	public class SearchResponse {
		public List<String> cis_id;
		public String errorMessage;
	}

	public SearchResponse searchResponse;

	
	public static SearchResultResponse parse(String json) {
		return (SearchResultResponse) System.JSON.deserialize(json, SearchResultResponse.class);
	}
	

}