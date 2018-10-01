public with sharing class QueryBuilder {
	public Schema.SObjectType table {get; private set;}
	private Set<String> fields;
	private String conditionExpression;
	private Integer limitCount;

	private Boolean sortSelectFields = true;

	private Map<Schema.ChildRelationship, QueryBuilder> subselectQueryMap;

	public QueryBuilder(Schema.SObjectType table) {
		this.table = table;
		this.fields = new Set<String>();
	}

	public QueryBuilder selectField(String fieldName){ 		
		this.fields.add(fieldName);
		return this;
	}

	public QueryBuilder selectField(Schema.SObjectField field){
		this.fields.add(field.getDescribe().getName());
		return this;
	}

	public QueryBuilder selectFields(Set<String> fieldNames){
		for(String fieldName:fieldNames)
			this.fields.add(fieldName);
		return this;
	}

	public QueryBuilder selectFields(List<String> fieldNames){
		for(String fieldName:fieldNames)
			this.fields.add(fieldName);
		return this;
	}
	
	public QueryBuilder selectFields(List<Schema.SObjectField> fields){
		for(Schema.SObjectField field:fields){
			if(field.getDescribe().isAccessible()) {
				this.fields.add(field.getDescribe().getName());	
			}
		}
		return this;
	}

	public QueryBuilder setSortSelectFields(Boolean doSort){
		this.sortSelectFields = doSort;
		return this;
	}

	public QueryBuilder setCondition(String conditionExpression){
		this.conditionExpression = conditionExpression;
		return this;
	}

	public QueryBuilder setLimit(Integer limitCount){
		this.limitCount = limitCount;
		return this;
	}

	public String toSOQL(){
		String result = 'SELECT ';
		if (fields.size() == 0){
			result += 'Id';
		}else {
			List<String> fieldsToQuery = new List<String>(fields);
			if(sortSelectFields){
				fieldsToQuery.sort(); 
			}	
		
			result += String.join(fieldsToQuery,', ');
		}
		
		if(subselectQueryMap != null && !subselectQueryMap.isEmpty()){
			for (QueryBuilder childRow : subselectQueryMap.values()){
				result += ', (' + childRow.toSOQL() + ') ';
			}	
		}
		result += ' FROM ' +  table.getDescribe().getName();
		if(conditionExpression != null)
			result += ' WHERE '+conditionExpression;

		if(limitCount != null)
			result += ' LIMIT '+limitCount;

		return result;
	}
}