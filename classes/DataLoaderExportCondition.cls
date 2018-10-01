global class DataLoaderExportCondition {//implements TxnSecurity.PolicyCondition {
    public boolean evaluate(TxnSecurity.Event e) {
        Integer numberOfRecords = Integer.valueOf(e.data.get('NumberOfRecords'));
        Long executionTimeMillis = Long.valueOf(e.data.get('ExecutionTime'));
        String entityName = e.data.get('EntityName');
        String exportQeury = e.data.get('Query');
        String apiType = e.data.get('ApiType');
        Boolean isApi = Boolean.valueOf(e.data.get('IsApi'));

        if(('Account'.equals(entityName) || 'Contact'.equals(entityName)) && isApi && (apiType == 'REST' || apiType == 'SOAP Partner')){
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(entityName);
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map <String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            String queryField = exportQeury.toLowerCase().substringBetween('select','from');
            queryField = ','+queryField.replace(' ','')+',';
            for(String key : fieldMap.keySet()){
                Schema.DescribeFieldResult objFieldDesc = fieldMap.get(key).getDescribe();  
                String eachFieldName = objFieldDesc.getName().toLowerCase();
                System.debug('objFieldDesc.getReferenceTo() = '+objFieldDesc.getReferenceTo());
                if(objFieldDesc.isEncrypted() && (queryField.contains(','+eachFieldName) ||  queryField.contains(eachFieldName+','))){
                    //return true;
                }
            }
        }
        return false;
    }
}