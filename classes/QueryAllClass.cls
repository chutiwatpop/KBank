public class QueryAllClass{
    public void queryAllClass(){
        Integer counting = 0;
        Map<String,String> objectMap = new Map<String,String>();
        
        for(Schema.SObjectType eachObject : Schema.getGlobalDescribe().Values()){
            if(!String.valueOf(eachObject).contains('FinServ__')){
                objectMap.put(String.valueOf(eachObject),String.valueOf(eachObject));
                if(objectMap.Size() == 90){
                    checkCount(objectMap.Values());
                    objectMap.clear();
                }
            }
        }
        checkCount(objectMap.Values());
    }
    
    @future
    public static void checkCount(List<String> objectMap){
        for(String each : objectMap){
            try{
                String query = 'SELECT count() FROM '+each+' WHERE LastModifiedDate > YESTERDAY';
                Integer countNumber = Database.countQuery(query);
                if(countNumber > 0) System.debug(each);
            }catch(Exception e){
                    
            }
        }
    }
}