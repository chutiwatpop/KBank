public with sharing class CustomLookUpController {
	@AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String objectName, String queryCondition, String queryField, String searchField) {
        List <sObject> returnList = new List <sObject> ();
        String sQuery =  '';
        if(String.isEmpty(queryField)) queryField = 'Id, Name';
        if(String.isEmpty(searchField)) searchField = 'Name';
        if(String.isEmpty(searchKeyWord)) {
            sQuery += 'SELECT ' + queryField + ' FROM ' + objectName;
            if(!String.isEmpty(queryCondition)) {
                sQuery += ' WHERE ' + queryCondition;
            }
            sQuery = sQuery + ' ORDER BY LastViewedDate DESC LIMIT 10';
            returnList = Database.query(sQuery);
        } else {
            if(objectName.toLowerCase() == 'account' || objectName.toLowerCase() == 'contact') { // Support Platform Encrypt
                sQuery =  'FIND \''+searchKeyWord+'\' IN Name FIELDS RETURNING ' + objectName + '(' + queryField;
                if(!String.isEmpty(queryCondition)) {
                    sQuery = sQuery + ' WHERE ' + queryCondition;
                }
                sQuery = sQuery + ' ORDER BY LastViewedDate DESC) LIMIT 100';
                List<List<sObject>> results = Search.query(sQuery);
                returnList = results[0];
            } else if(objectName != null) {
                searchKeyWord = searchKeyWord + '%';
                String searchCondition = createSearchCondition(searchField);
                sQuery = 'SELECT '+ queryField + ' FROM ' + objectName + ' WHERE (' + searchCondition + ')';
                if(!String.isEmpty(queryCondition)) {
                    sQuery = sQuery + ' AND ' + queryCondition;
                }
                sQuery = sQuery + ' ORDER BY LastViewedDate DESC LIMIT 10'; 
                returnList = Database.query(sQuery);
            }
        }
        System.debug('sQuery = '+sQuery);
        return returnList;
    }

    private static String createSearchCondition(String fields) {
        List<String> searchFieldList = fields.split(',');
        String searchCondition = '';
        for(Integer i = 0;i < searchFieldList.size();i++) {
            String eachField = searchFieldList.get(i);
            searchCondition = searchCondition + eachField + ' LIKE :searchKeyWord';
            if(i < searchFieldList.size()-1) {
                searchCondition = searchCondition + ' OR ';
            }
        }
        return searchCondition;
    }
}