/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
public class CustomSettingUtil {

	public static Map<String,String> endPointMap;
	public static Map<String,String> connAttributeMap;
	public static final String TIMEOUT_KEY = 'CITimeout';
	public static final String HTTP_USERNAME_KEY = 'httpUsername';
	public static final String HTTP_PASSWORD_KEY = 'httpPassword';

	public static void readEndpointCustomSettingMap() {
		Map<String,Kbank_Endpoint__c> customSettingMap = Kbank_Endpoint__c.getAll();
		endPointMap = new Map<String,String>();
		System.debug('customSettingMap:'+customSettingMap);
        for (Kbank_Endpoint__c eachEndpoint : customSettingMap.values()) {
       		endPointMap.put(eachEndpoint.Name__c,eachEndpoint.Endpoint__c);
        }
	}

	public static String getEndpointByName(String endPointName) {
		if (endPointMap == null){
			readEndpointCustomSettingMap();
		}
		return endPointMap.get(endPointName);
	}

	public static String getConnectionAttributeByName(String attrKey) {
		if (connAttributeMap == null){
			readConnectionAttributeValue();
		} 
		return connAttributeMap.get(attrKey);
	}


	public static Integer getTimeout() {
		Integer timeout = 5000;
		try{
			System.debug('ConnAttributeMap:'+connAttributeMap);
			timeout = Integer.valueOf(getConnectionAttributeByName(TIMEOUT_KEY));
		} catch(Exception e){
			System.debug(e.getStackTraceString());
		}

		return timeout;
	}

	public static String getHttpUsername() {
		return getConnectionAttributeByName(HTTP_USERNAME_KEY);
	}

	public static String getHttpPassword() {
		return getConnectionAttributeByName(HTTP_PASSWORD_KEY);
	}

	public static void readConnectionAttributeValue() {
		Map<String,ConnectionAttribute__c> customSettingMap = ConnectionAttribute__c.getAll();
		connAttributeMap = new Map<String,String>();
        for (ConnectionAttribute__c eachAttr : customSettingMap.values()) {
       		connAttributeMap.put(eachAttr.Name__c,eachAttr.AttributeValue__c);
		}
		System.debug(connAttributeMap);
	}

	public static String getPurgeTime() {
		return getCustomSettingPurgeDays();
	}

	public static String getCustomSettingPurgeDays() {
		String purgeDays = '30';
		System_Settings__c systemSetting = System_Settings__c.getInstance();
		if(systemSetting.Log_Purge_Days__c != null && systemSetting.Log_Purge_Days__c != 0){
			purgeDays = String.valueOf(Integer.valueOf(systemSetting.Log_Purge_Days__c));
		}

		return purgeDays;
	}

	public static Integer getSearchResults() {
		return getCustomSettingNumberOfSearchResults();
	}

	public static Integer getCustomSettingNumberOfSearchResults() {
		Integer numberOfSearchResults = 30;
		System_Settings__c systemSetting = System_Settings__c.getInstance();
		if(systemSetting.Search_Results__c != null && systemSetting.Search_Results__c != 0){
			numberOfSearchResults = Integer.valueOf(systemSetting.Search_Results__c);
		}

		return numberOfSearchResults;
	}

    //public static Map<String,CBS_NHTL_Management__c> getNHTLCustomSettingByNHRcCode(){
    //	Map<String,CBS_NHTL_Management__c> nHTLMapByRcCode = new Map<String,CBS_NHTL_Management__c>();
    //	List<CBS_NHTL_Management__c> nHTLList = new List<CBS_NHTL_Management__c>();
    //	nHTLList = [SELECT NH_RC_Code__c,AH_RC_Code__c From CBS_NHTL_Management__c];
    //	if(!nHTLList.isEmpty()){
    //		for(CBS_NHTL_Management__c nhtl : nHTLList){
	   // 		nHTLMapByRcCode.put(nhtl.NH_RC_Code__c,nhtl);
	   // 	}
    //	}
    	
    //	return nHTLMapByRcCode;
    //}

    //public static Map<String,CBS_NHTL_Management__c> getNHTLCustomSettingByTLRcCode(){
    //	Map<String,CBS_NHTL_Management__c> nHTLMapByTLRcCode = new Map<String,CBS_NHTL_Management__c>();
    //	for(CBS_NHTL_Management__c nhtl : [SELECT NH_RC_Code__c,AH_RC_Code__c, Employee_ID__c From CBS_NHTL_Management__c]){
    //		nHTLMapByTLRcCode.put(nhtl.AH_RC_Code__c,nhtl);
    //	}
    //	return nHTLMapByTLRcCode;
    //}

    //public static Map<String,CBS_NHTL_Management__c> getNHTLCustomSettingByRcCode(){
    //	Map<String,CBS_NHTL_Management__c> nHTLMapByTLRcCode = new Map<String,CBS_NHTL_Management__c>();
    //	for(CBS_NHTL_Management__c nhtl : [SELECT NH_RC_Code__c,AH_RC_Code__c,Employee_ID__c From CBS_NHTL_Management__c]){
    //		nHTLMapByTLRcCode.put(nhtl.NH_RC_Code__c,nhtl);
    //		nHTLMapByTLRcCode.put(nhtl.AH_RC_Code__c,nhtl);
    //	}
    //	return nHTLMapByTLRcCode;
    //}

    public static Map<String,User_Mirror_Management__c> getMirrorSettingByUserRcCode(){
    	Map<String,User_Mirror_Management__c> userMirrorMapByUserRcCode = new Map<String,User_Mirror_Management__c>();
    	for(User_Mirror_Management__c eachMirrorUser : [SELECT User_Value__c,Mirror_Value__c,Employee_ID__c From User_Mirror_Management__c WHERE Mirror_Type__c = :GlobalConstants.USER_MIRROR_TYPE_RC_CODE]){
    		userMirrorMapByUserRcCode.put(eachMirrorUser.User_Value__c,eachMirrorUser);
    	}
    	return userMirrorMapByUserRcCode;
    }

    public static Map<String,User_Mirror_Management__c> getMirrorSettingByMirrorUserRcCode(){
    	Map<String,User_Mirror_Management__c> userMirrorMapByUserRcCode = new Map<String,User_Mirror_Management__c>();
    	for(User_Mirror_Management__c eachMirrorUser : [SELECT User_Value__c,Mirror_Value__c,Employee_ID__c From User_Mirror_Management__c WHERE Mirror_Type__c = :GlobalConstants.USER_MIRROR_TYPE_RC_CODE]){
    		userMirrorMapByUserRcCode.put(eachMirrorUser.Mirror_Value__c,eachMirrorUser);
    	}
    	return userMirrorMapByUserRcCode;
    }

    public static Map<String,User_Mirror_Management__c> getMirrorSettingMapByUserAndMirrorRcCode(){
    	Map<String,User_Mirror_Management__c> userMirrorMapByUserRcCode = new Map<String,User_Mirror_Management__c>();
    	for(User_Mirror_Management__c eachMirrorUser : [SELECT User_Value__c,Mirror_Value__c,Employee_ID__c From User_Mirror_Management__c WHERE Mirror_Type__c = :GlobalConstants.USER_MIRROR_TYPE_RC_CODE]){
    		userMirrorMapByUserRcCode.put(eachMirrorUser.User_Value__c,eachMirrorUser);
    		userMirrorMapByUserRcCode.put(eachMirrorUser.Mirror_Value__c,eachMirrorUser);
    	}
    	return userMirrorMapByUserRcCode;
    }

}