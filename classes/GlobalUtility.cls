/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global utility class for common functions
Test Class:    GlobalUtility_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
global without sharing class GlobalUtility {
    public static Boolean runOnce = false;
    public static Boolean accounFromYearend = false;
    public static Boolean initialMonthly = false;
    public static Boolean resetStatement = false;

    public static Map<String, Map<String, RecordType>> recordTypeMapMapBySObject;
    public static Map<String,Apex_Class_Config__mdt> mapApexClassConfigByName;
    public static List<Profile> profileList;

    public static final String LEVEL_DEBUG = 'Debug';
    public static final String LEVEL_ERROR = 'Error';
    public static final String LEVEL_INFO = 'Info';
    public static final String LEVEL_WARNING = 'Warning';
    public static final String LOG_NAME_PREFIX = 'ALOG-';
    public static final Map<Integer, String> MONTH_STR_MAP = new Map<Integer, String>{1 =>'Jan', 2=>'Feb', 3=>'Mar',4 =>'Apr', 5=>'May', 6=>'Jun',7 =>'Jul', 8=>'Aug', 9=>'Sep',10 =>'Oct', 11=>'Nov', 12=>'Dec'};
    public static final Map<String, String> MAP_ERROR_CODE_MSG = new Map<String, String>{
        GlobalConstants.KNOWN_ERR_CC_CODE_1 => GlobalConstants.KNOWN_ERR_CC_MSG_1,
        GlobalConstants.KNOWN_ERR_CC_CODE_2 => GlobalConstants.KNOWN_ERR_CC_MSG_2,
        GlobalConstants.KNOWN_ERR_CC_CODE_3 => GlobalConstants.KNOWN_ERR_CC_MSG_3,
        GlobalConstants.KNOWN_ERR_CC_CODE_3 => GlobalConstants.KNOWN_ERR_CC_MSG_4
        };


    global class Response{
        webservice String recordId{get;set;}
        webservice Boolean success{get;set;}
        webservice String msg{get;set;}
    }

    webservice static Response getProfileNameFromUserId(String userId){
        Response res = new Response();
        try{
            User userObj = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            res.recordId = userObj.Id;
            res.success = true;
            res.msg = userObj.Profile.Name;

        }catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }

    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {           
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = null;
        msg.referenceInfo = '';
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage( msg );
    }

    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {  
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage( msg );
    }

    public static void logMessage(ApplicationLogWrapper appLog) {   
        List<ApplicationLogWrapper> appLogs = new List<ApplicationLogWrapper>();

        appLogs.add ( appLog );
        logMessage ( appLogs );
    }

    public static void logMessage(List<ApplicationLogWrapper> appLogs) {
        List<Application_Log__c> insertAppLogs = new List<Application_Log__c>();
        for(ApplicationLogWrapper appLog : appLogs){
            Application_Log__c log = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            log.Name = LOG_NAME_PREFIX+formattedDt;
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Information__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;
            
            if(appLog.ex != null){
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage();
            }
            
            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            if (isValidInsert(appLog.debugLevel)){
                insertAppLogs.add(log);  
            }
        }

        if ( insertAppLogs.size() != 0){
            insert insertAppLogs;
        }
    }

    public static Boolean isValidInsert(String debugLevel){
        Boolean validInsert = false;
        if(debugLevel == LEVEL_DEBUG && System_Settings__c.getInstance().Debug__c){
            validInsert = true;
        }
        if(debugLevel == LEVEL_ERROR && System_Settings__c.getInstance().Error__c){
            validInsert = true;
        }
        if(debugLevel == LEVEL_INFO&& System_Settings__c.getInstance().Info__c){
            validInsert = true;
        }
        if(debugLevel == LEVEL_WARNING && System_Settings__c.getInstance().Warning__c){
            validInsert = true;
        }
        return validInsert;
    }
    public static Boolean isEmailValid(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher resutlMatcher = emailPattern.matcher(email);

        return resutlMatcher.matches();
    }

    public static Boolean isPhoneNumber(String phoneNumber){
        String phoneRegex = '^\\d{9,10}$';
        Pattern phonePattern = Pattern.compile(phoneRegex);
        Matcher resultMatcher = phonePattern.matcher(phoneNumber);

        return resultMatcher.matches();
    }

    public static void sendEmail(String[] toRecipients, String[] ccRecipients, String senderDisplayName, 
                                          String subjectMessage,String bodyMessage){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toRecipients);
        email.setCcAddresses(ccRecipients);
        email.setSenderDisplayName(senderDisplayName);
        email.setSubject(subjectMessage);
        email.setPlainTextBody(bodyMessage);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (EmailException e) {
            throw e;
        }
    }

    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName, 
                                          ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, 
                                          Attachment[] attachList ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        try {
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
        } catch (Exception e) {
            e.setMessage('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + 
                                 ' refer to Setup | Communications Templates ' + templateApiName);
            throw e;
        }
        email.setToAddresses(toRecipients);
        email.setCcAddresses(ccRecipients);
        email.setTargetObjectId(targetObjId);
        email.setWhatId(whatId);
        email.setorgWideEmailAddressId(orgWideEmailId);
        email.setTemplateId(templateId);
        email.setSaveAsActivity(saveAsActivity); // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return;
        } catch (EmailException e) {
            e.setMessage('[U-02] sendTemplatedEmail error. ' + e.getMessage());
            throw e;
        }
    }

    private static Map<String, Map<String, RecordType>> getRecordTypeMapMapBySObject() {
        if(GlobalUtility.recordTypeMapMapBySObject == null) {
            GlobalUtility.recordTypeMapMapBySObject = new Map<String, Map<String, RecordType>>();
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName, SObjectType FROM RecordType]);
            for(RecordType eachRecordType : recordTypeMap.values()) {
                if(GlobalUtility.recordTypeMapMapBySObject.containsKey(eachRecordType.SObjectType)) {
                    GlobalUtility.recordTypeMapMapBySObject.get(eachRecordType.SObjectType).put(eachRecordType.Id, eachRecordType);
                } else {
                    GlobalUtility.recordTypeMapMapBySObject.put(eachRecordType.SObjectType, new Map<String, RecordType>{eachRecordType.Id => eachRecordType});
                }
            }
        }
        return GlobalUtility.recordTypeMapMapBySObject;   
    }

    public static Map<String, Id> getRecordTypeMapByDevNameFromSObject(String sObjectName){
        Map<String, Id> resultsMap = new Map<String, Id>();
        if(getRecordTypeMapMapBySObject().containsKey(sObjectName)) {
            for(RecordType eachRecordType : getRecordTypeMapMapBySObject().get(sObjectName).values()) {
                resultsMap.put(eachRecordType.DeveloperName, eachRecordType.Id);
            }
        }
        return resultsMap;
    }

    public static Map<Id, String> getRecordTypeDevNameMapByIdFromSObject(String sObjectName){
        Map<Id, String> resultsMap = new Map<Id, String>();
        if(getRecordTypeMapMapBySObject().containsKey(sObjectName)) {
            for(RecordType eachRecordType : getRecordTypeMapMapBySObject().get(sObjectName).values()) {
                resultsMap.put(eachRecordType.Id, eachRecordType.DeveloperName);
            }
        }
        return resultsMap;
    }

    public static Id getRecordTypeIdFromSObjectByDevName(String sObjectName,String recordTypeDevName){
        return getRecordTypeMapByDevNameFromSObject(sObjectName).get(recordTypeDevName);
    }
    public static Id getRecordTypeOpportunityIdByName(String name){
        return (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static Id getRecordTypeAccountIdByName(String name){
        return (Schema.SObjectType.Account.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static Id getRecordTypeCampaignIdByName(String name){
        return (Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static String getRecordTypeDevNameById(String recId){
        RecordType recordType = new RecordType();
        recordType = [SELECT DeveloperName FROM RecordType WHERE Id =: recId LIMIT 1];
        String devName = recordType.DeveloperName;
        return devName;
    }

    public static Map<string, sObject> toMap(string field_name, List<sObject> objects){
        Map<string, sObject> result = new Map<string, sObject>();
        for(sObject obj:objects){
            result.put(string.valueOf(obj.get(field_name)), obj);
        }
        return result;
    }

    public static Map<string, sObject> toMapLookup(String field_name, String lookup_name, List<sObject> objects){
        Map<string, sObject> result = new Map<string, sObject>();
        for(sObject obj:objects){
            result.put(string.valueOf(obj.getsObject(field_name).get(lookup_name)), obj);
        }
        return result;
    }

    public static String getEncryptedData(String cryptoKey, String dataToEncrypt){                              
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf(cryptoKey), Blob.valueOf(dataToEncrypt));  
        return EncodingUtil.base64Encode(encryptedData);
    }

    public static String getEncryptedDataWithTransform(String cryptoKey, String dataToEncrypt){
        String encryptImgURL = getEncryptedData(cryptoKey,dataToEncrypt);
        String encodedHex = EncodingUtil.urlEncode(encryptImgURL, 'UTF-8');
        String transformEncodedHex = encodedHex.replace('%', '!');
        return transformEncodedHex;
    }

    public static Boolean isNumberAlphabet(String name){
        Boolean isNumberAlphabet = false;
        if(name != null) {
            String nameRegEx = '(\\d+)';
            Pattern myPattern = Pattern.compile(nameRegEx);
            Matcher myMatcher = myPattern.matcher(name);
            myMatcher.region(0, myMatcher.regionEnd());
            isNumberAlphabet = myMatcher.matches();    
        }
        return isNumberAlphabet;
    }

    public static String toCurrency(Object currencyObj) {
        String currencyStr = String.valueOf(currencyObj);
        Decimal currencyStrDecimal = (Decimal.valueOf(currencyStr==null||currencyStr.trim()==''?'0':currencyStr));
        String s;
        if( currencyStrDecimal >= 0.0 )
            s = (currencyStrDecimal.setScale(2) + 0.001 ).format();
        else
            s = (currencyStrDecimal.setScale(2) - 0.001 ).format();
        return s.substring(0,s.length()-1);
    }

    public static String toAccountType(Object accountObj){
        String accountTypeStr = String.valueOf(accountObj);
        String s;
        if(accountTypeStr == '0' || accountTypeStr == '1' ){
            s = 'บัญชีร่วม';
        }else if(accountTypeStr == '2'){
            s = 'บัญชีเดี่ยว';
        }
        return s;
    }

    public static String toValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }

    public static Decimal toDecimal(String val) {
        return val != null && val.trim() != '' ? Decimal.valueOf(val) : 0;
    }

    public static Decimal toDecimal(Decimal val) {
        return val != null ? val : 0;
    }

    public static String toNumber(Object val) {
        String numberString;
        try {
            numberString = String.valueOf(Integer.valueOf(val));
        } catch (Exception ex) {
            System.debug(ex);
            numberString = '0';
        }
        return val != null ? numberString : '0';
    }

    public static String dropLeadingZero(String passedValue) {
        String return_string = null; //return string for passing back
        if(passedValue != null){ //if the passed value is not null
            return_string = passedValue.trim(); //trim the whitespace from the start and end of the value
            Pattern valid_characters = Pattern.compile('([0-9]+)'); //only numbers
            Matcher check_chars = valid_characters.matcher(return_string); //compare the string to the set of valid characters
            if(check_chars.matches()) { //if we have a somewhat valid number
                if(return_string.startsWith('0') && return_string.length() > 1){ //if the string begins with a 0 and the length is greater than 1
                    boolean keepChecking = true; //create a boolean variable
                    while(keepChecking){ //if boolean is true
                        if(return_string.startsWith('0') && return_string.length() > 1){ //if the string begins with 0 and there is more than 1 character
                            return_string = return_string.substring(1); //drop the first character
                        }else{ //either the string doesn't begin with 0 or the length is less than or equal to 1
                            keepChecking = false; //stop the loop
                        }
                    }
                }
                if(return_string == '0'){ //if the resulting string is now a single '0'
                    return_string = null; //set the string to null
                }
            }else{ //otherwise the value passed was not valid
                return_string = null; //set the string to null
            }
        }
        return return_string; //pass back a value
    }

    public static String toDateFormat(String yearStr, String month, String day) {
        Integer year = Integer.valueOf(yearStr);
        if(year > 2400) year = year - 543;
        Date thisDate = Date.newInstance(year, Integer.valueOf(month), Integer.valueOf(day));
        String monthStr = (thisDate.month() < 10 ? '0' : '') + String.valueOf(thisDate.month());
        String dayStr = (thisDate.day() < 10 ? '0' : '') + String.valueOf(thisDate.day());
        return dayStr + '/' + monthStr + '/' + thisDate.year();
    }

    public static String toExportDateFormat(Date inputDate) {
        String returnDate;
        String tempYear = String.valueOf(inputDate.year());
        if(String.valueOf(UserInfo.getLocale()) == 'th_TH'){
            tempYear = String.valueOf(Integer.valueOf(inputDate.year())-543);
        }
        returnDate = String.valueOf(tempYear)+'-'+String.valueOf('0'+String.valueOf(inputDate.month())).right(2)+'-'+String.valueOf('0'+String.valueOf(inputDate.day())).right(2);

        return returnDate;
    }

    public static  Map<String, String> getLocaleDateMap() {
        Map<String, String> locale_map = new Map<String, String>();
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'M/d/yyyy h:mm a');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        return locale_map;
    }

    public static Boolean isDataOfSetTwoInSetOne(Set<String> mainSet, Set<String> checkSet) {
        for(String eachValue : checkSet) {
            if(mainSet.contains(eachValue))
                return true;
        }
        return false;
    }

    public static Map<String,Profile> getProfileMapNameKey(){
        Map<String,Profile> profileNameMap = new Map<String,Profile>();
        if(GlobalUtility.profileList==null){
            GlobalUtility.profileList = [SELECT Id,Name FROM Profile];
        }
        for(Profile eachProfile : GlobalUtility.profileList){
            profileNameMap.put(eachProfile.Name,eachProfile);
        }
        return profileNameMap;
    }

    public static Map<Id,Profile> getProfileMap(){
        if(GlobalUtility.profileList==null){
            GlobalUtility.profileList = [SELECT Id, Name FROM Profile];
        }
        Map<Id, Profile> profileMap = new Map<Id, Profile>(GlobalUtility.profileList);
        return profileMap;
    }

    public static string getType(sObject obj) {
        if(obj==null) return '';
        return obj.getSObjectType().getDescribe().getName()+'';
    }

    public static Boolean isValidDecimal(String str){
        Boolean result = false;
        if(str != null){
            try{
                str = str.trim();
                str = str.replace(',', '');
                Decimal.valueOf(str);
                result = true;
            }
            catch(TypeException e){
               result = false; 
            }
        }
        return result;
    }

    public static Integer getYearInBuddhistCalendar(Date dateToConvert){
        if(dateToConvert == null) return 0;
        Integer year = dateToConvert.year() <= 2500 ? dateToConvert.year()+543 : dateToConvert.year();
        return year;
    }

    public static Integer getYearInBuddhistCalendar(DateTime dateToConvert){
        return GlobalUtility.getYearInBuddhistCalendar(dateToConvert.date());
    }

    public static Integer getYearInChristianCalendar(Date dateToConvert){
        if(dateToConvert == null) return 0;
        Integer year = dateToConvert.year() >= 2500 ? dateToConvert.year()-543 : dateToConvert.year();
        return year;
    }

    public static Integer getYearInChristianCalendar(DateTime dateToConvert){
        return GlobalUtility.getYearInChristianCalendar(dateToConvert.date());
    }

    //pan rein
    public static Map<String,String> getObjectDescriptionMapByIDPrefix(){
        Map<String,String> objectNameByIDPrefixs = new Map<String,String>();
        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType sObjType : globalDescribe.values()){
            Schema.DescribeSObjectResult describeSObjectResult = sObjType.getDescribe();
            String prefix = describeSObjectResult.getKeyPrefix();
            String objectName = describeSObjectResult.getName();
            objectNameByIDPrefixs.put(prefix,objectName);
        }    
        return objectNameByIDPrefixs;
    }

    public static String getObjectPrefixByAPIName(String objName){
        String prefix;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getName() == objName){
                prefix = objectInstance.getDescribe().getKeyPrefix();
                break;
            }
        }
        return prefix;
    }

    public static String getCallOutExceptionErrorMsg(String errorMessage) {
        if(errorMessage.containsIgnoreCase(GlobalConstants.WS_TIME_OUT_CASE)){
            return (Label.Search_TimeOut);
        } else if(errorMessage.containsIgnoreCase(GlobalConstants.WS_SERVICE_UNAVAILABLE_CASE)){ //503
            return (ExceptionMessage.ADAPTER_NOT_AVAILABLE);
        }else if(errorMessage.containsIgnoreCase(GlobalConstants.WS_DATABASE_UNAVAILABLE_CASE)){ //504
            return (ExceptionMessage.DATABASE_NOT_AVAILABLE);
        }else if(errorMessage.containsIgnoreCase(GlobalConstants.WS_INCORRECT_USER_PASS_CASE)){ //401
            return (ExceptionMessage.HOST_EXCEPTION);
        }else if(errorMessage.containsIgnoreCase(GlobalConstants.WS_URI_UNAVAILABLE_CASE)){ //404
            return (ExceptionMessage.ADAPTER_NOT_AVAILABLE);
        }else if(errorMessage.containsIgnoreCase(GlobalConstants.WS_SERVICE_CANNOT_CONNECT)){ //500
            return (ExceptionMessage.ADAPTER_NOT_AVAILABLE);
        }else{
            return (errorMessage);
        }
    }

    public static String paddLeftChar(String originalStr,Integer totalLength,String strPad){
        return originalStr.leftPad(totalLength-originalStr.length()).replace(' ', strPad);
    }

    public static String randomStringAll(Integer count) {
        Integer[] chars = new Integer[0],
            offsets = new Integer[] { 48, 65, 97 },
                mods = new Integer[] { 10, 26, 26 };

        while(count > chars.size()) {
            Integer cat = Math.abs(Math.mod(Crypto.getRandomInteger(),3));
            chars.add(Math.mod(Math.abs(Crypto.getRandomInteger()), mods[cat])+offsets[cat]);
        }
        return String.fromCharArray(chars);
    }

    public static Date parseStringToDate(String dateString) {
        Date parsedDate;
        if(dateString != null && (!String.isEmpty(dateString))) {
            try{
                parsedDate = Date.parse(dateString);
            }catch(Exception ex){
                parsedDate = Date.valueOf(dateString);
            }
        }
        return parsedDate;
    }

    public static String convertStringNulltoBlank(String convertString) {
        if(convertString == null) {
            return '';
        } else {
            return convertString;
        } 
    }

    public static List<Schema.SObjectField> getAllCreatableSchemaSObjectFields(String objectName){
        List<Schema.SObjectField> sFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField eachField : Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap().values()){
            if(eachField.getDescribe().isAccessible()) {
                sFields.add(eachField); 
            }
        }
        return sFields;
    }

    public static List<Schema.SObjectField> getAllCreatableSchemaSObjectFields(Schema.SObjectType sObjectType){
        List<Schema.SObjectField> sFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField eachField : sObjectType.getDescribe().Fields.getMap().values()){
            if(eachField.getDescribe().isAccessible()) {
                sFields.add(eachField); 
            }
        }
        return sFields;
    }

    public static Boolean isNotNull(String input){
        if(input != null && input != ''){
            return true;
        }
        return false;
    }

    public static void createBellNotification(Id notifyToUserId,Id relateObjectId,String txtMsg){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        mentionSegmentInput.Id =  notifyToUserId; 

        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = txtMsg;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = relateObjectId; 
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }

    public static String isSegmentFromToString(String newUserString, String oldUserString){
        if(GlobalConstants.PROFILE_SME_SET.contains(newUserString) && GlobalConstants.PROFILE_SME_SET.contains(oldUserString)){
            return 'SMEtoSME';
        }else if(GlobalConstants.PROFILE_RBS_SET.contains(newUserString) && GlobalConstants.PROFILE_RBS_SET.contains(oldUserString)){
            return 'RBStoRBS';
        }else if(GlobalConstants.PROFILE_RBS_SET.contains(newUserString) && GlobalConstants.PROFILE_SME_SET.contains(oldUserString)){
            return 'RBStoSME';
        }else if(GlobalConstants.PROFILE_CBS_SET.contains(newUserString) && GlobalConstants.PROFILE_SME_SET.contains(oldUserString)){
            return 'CBStoSME';
        }else if(GlobalConstants.PROFILE_SME_SET.contains(newUserString) && GlobalConstants.PROFILE_CBS_SET.contains(oldUserString)){
            return 'SMEtoCBS';
        }else if(GlobalConstants.PROFILE_AF_SET.contains(newUserString) && GlobalConstants.PROFILE_AF_SET.contains(oldUserString)){
            return 'AFtoAF';
        }else if(GlobalConstants.PROFILE_AF_SET.contains(newUserString) && GlobalConstants.PROFILE_RBS_SET.contains(oldUserString)){
            return 'AFtoRBS';
        }else if(GlobalConstants.PROFILE_AF_SET.contains(newUserString) && GlobalConstants.PROFILE_SME_SET.contains(oldUserString)){
            return 'AFtoSME';
        }else if(GlobalConstants.PROFILE_AF_SET.contains(newUserString) && GlobalConstants.PROFILE_CBS_SET.contains(oldUserString)){
            return 'AFtoCBS';
        }
        return '';
    }

    public static String isSegmentFromTo(User newUser, User oldUser){
        return isSegmentFromToString(newUser.Profile.Name, oldUser.Profile.Name);
    }

    private static void setErrorResultToApplicationLogList(List<Application_Log__c> listErrorLog, Database.Error[] errorlist, String errorId, String sourceClass) {
        for (Database.Error error : errorlist) {
            Application_Log__c aLog = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            aLog.Name = 'ERR-'+formattedDt;
            aLog.Debug_Level__c = 'Error';
            aLog.Message__c = errorId +'::'+ error.getMessage();
            aLog.Source__c = sourceClass;
            listErrorLog.add(aLog);
        }
    }

    public static List<Application_Log__c> generateLogResults(Database.SaveResult[] results, String sourceClass) {
        List<Application_Log__c> listErrorLog = new List<Application_Log__c>();
        List<String> errorList = new List<String>();
        Map<String, List<String>> errorIdsMapByErrorCode = new Map<String, List<String>>();
        Map<String, String> errorMessageMapByErrorCode = new Map<String, String>();
        for(Database.SaveResult eachResult : results) {
            if (!eachResult.isSuccess()){
                setErrorResultToApplicationLogList(listErrorLog, eachResult.getErrors(), (String)eachResult.getId(), sourceClass);
            } 
        }
        return listErrorLog;
    }

    public static List<Application_Log__c> generateLogResults(Database.UpsertResult[] results, String sourceClass) {
        List<Application_Log__c> listErrorLog = new List<Application_Log__c>();
        List<String> errorList = new List<String>();
        Map<String, List<String>> errorIdsMapByErrorCode = new Map<String, List<String>>();
        Map<String, String> errorMessageMapByErrorCode = new Map<String, String>();
        for(Database.UpsertResult eachResult : results) {
            if (!eachResult.isSuccess()){
                setErrorResultToApplicationLogList(listErrorLog, eachResult.getErrors(), (String)eachResult.getId(), sourceClass);
            } 
        }
        return listErrorLog;
    }

    public static List<Application_Log__c> generateLogResults(Database.SaveResult[] results, String sourceClass, String sourceFunction) {
        List<Application_Log__c> listErrorLog = new List<Application_Log__c>();
        List<String> errorList = new List<String>();
        Map<String, List<String>> errorIdsMapByErrorCode = new Map<String, List<String>>();
        Map<String, String> errorMessageMapByErrorCode = new Map<String, String>();
        for(Database.SaveResult eachResult : results) {
            if (!eachResult.isSuccess()){
                for (Database.Error error : eachResult.getErrors()) {
                    String errorCode = '' + error.getStatusCode();
                    
                    if(!errorMessageMapByErrorCode.containsKey(errorCode)) {
                        errorMessageMapByErrorCode.put(errorCode, error.getMessage());
                    }

                    if(!errorIdsMapByErrorCode.containsKey(errorCode)) {
                        errorIdsMapByErrorCode.put(errorCode, new List<String>());
                    }
                    if(!String.isEmpty((String)eachResult.getId())) {
                        errorIdsMapByErrorCode.get(errorCode).add((String)eachResult.getId());    
                    }
                }
            } 
        }
        String errorMessage = '';
        if(!errorIdsMapByErrorCode.isEmpty()) {
            for(String errorCode : errorIdsMapByErrorCode.keySet()) {
                errorMessage = errorMessageMapByErrorCode.get(errorCode) + '::' + String.join(errorIdsMapByErrorCode.get(errorCode),',');
            }
            Application_Log__c aLog = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hh:mm:ss\'Z\'SSS');
            aLog.Name               = 'ERR-'+formattedDt;
            aLog.Debug_Level__c     = 'Error';
            aLog.Message__c         = errorMessage;
            aLog.Source__c          = sourceClass;
            aLog.Source_Function__c = sourceFunction;
            listErrorLog.add(aLog);
        }
        return listErrorLog;
    }

    public static void logSaveResults(Database.SaveResult[] results, String sourceClass, String sourceFunction) {
        List<Application_Log__c> listErrorLog = generateLogResults(results, sourceClass, sourceFunction);
        if(!listErrorLog.isEmpty()){
            System.enqueueJob(new ApplicationLog_Queue(listErrorLog));
        }
    }

    public static Application_Log__c generateKnownErrorLog(Map<String, List<String>> errorIdsMapByErrorCode, String sourceClass) {
        String errorMessage = '';
        for(String errorCode : errorIdsMapByErrorCode.keySet()) {
            errorMessage = MAP_ERROR_CODE_MSG.get(errorCode) + '::' + String.join(errorIdsMapByErrorCode.get(errorCode),',');
        }   
        Application_Log__c aLog = new Application_Log__c();
        Datetime dt = Datetime.now();
        String formattedDt = dt.format('ddMMyyyy\'T\'hh:mm:ss\'Z\'SSS');
        aLog.Name               = 'ERR-'+formattedDt;
        aLog.Debug_Level__c     = 'Error';
        aLog.Message__c         = errorMessage;
        aLog.Source__c          = sourceClass;
        return aLog;
    }

    // Re-design get Record Type method
    public static Id getRecordTypeId(String sObjectName, String recordTypeDevName) {
        // ** getGlobalDescribe return Map<String,Schema.SObjectType>
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(sObjectName);
        // ** getRecordTypeInfosByDeveloperName return Map<String,Schema.RecordTypeInfo>
        Schema.RecordTypeInfo recordTypeInfo = sobjType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName);
        return recordTypeInfo == null ? null : recordTypeInfo.getRecordTypeId();
    }

    // Re-design get Record Type method
    public static Schema.RecordTypeInfo getRecordTypeFromId(String sObjectName, String recordTypeId) {
        // ** getGlobalDescribe return Map<String,Schema.SObjectType>
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(sObjectName);
        // ** getRecordTypeInfosById return Map<Id, Schema.RecordTypeInfo>
        Schema.RecordTypeInfo recordTypeInfo = sobjType.getDescribe().getRecordTypeInfosById().get(recordTypeId);
        return recordTypeInfo;
    }

    public static Map<String,Apex_Class_Config__mdt> getApexClassConfigMapByName(){
        if(mapApexClassConfigByName == null){
            mapApexClassConfigByName = new Map<String,Apex_Class_Config__mdt>();
            List<Apex_Class_Config__mdt> listApexClassConfig = [SELECT Label,IsActive__c FROM Apex_Class_Config__mdt];
            for(Apex_Class_Config__mdt eachApexClassConfig : listApexClassConfig){
                mapApexClassConfigByName.put(eachApexClassConfig.Label,eachApexClassConfig);
            }
        }

        return mapApexClassConfigByName;
    }

    public static Apex_Class_Config__mdt getApexClassConfigMapFromName(String name){
        Apex_Class_Config__mdt apexClassConfig = getApexClassConfigMapByName().get(name);
        return apexClassConfig;
    }

    public static Boolean isApexClassConfigActive(String name){
        Apex_Class_Config__mdt apexClassConfig = getApexClassConfigMapFromName(name);
        if(apexClassConfig == null) return false;
        return apexClassConfig.IsActive__c;
    }

	public static ConnectApi.FeedItemInput createNotifyingChatter(Id relatedRecId, String msgWithMention) {
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		String mentionRegex = '@[A-Za-z0-9]*';
		Pattern mentionPattern = Pattern.compile(mentionRegex);
		String[] sentences = mentionPattern.split(msgWithMention);
		Matcher matchMention = mentionPattern.matcher(msgWithMention);

		for(Integer i = 0; i < sentences.size(); i++) {
			ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
			textSegmentInput.text = sentences[i];
			messageBodyInput.messageSegments.add(textSegmentInput);

			if(matchMention.find()){	
				ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
				String mentionStr = matchMention.group().substring(1);
				Id mentionId = Id.valueOf(mentionStr);
				mentionSegmentInput.Id = mentionId;
				messageBodyInput.messageSegments.add(mentionSegmentInput);
			}
		}

		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = relatedRecId;
		if(!Test.isRunningTest()) {
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
		}
        return feeditemInput;
	}

    public static void autoGenerateScheduleJob(){
        List<Schedule_Job_Config__mdt> listJobConfig = [SELECT Label, Start_Time__c, End_Year__c, Daily_Frequency__c, Schedule_Type__c, Batch_Size__c,Monthly_Frequency__c ,Weekly_Frequency__c,Class_Type__c FROM Schedule_Job_Config__mdt];
        for(Schedule_Job_Config__mdt eachJobConfig : listJobConfig){
            try{
                String batchName = eachJobConfig.Label;
                String scheduleType = eachJobConfig.Schedule_Type__c;
                String dailyFrequency = eachJobConfig.Daily_Frequency__c;
                String weeklyFrequency = eachJobConfig.Weekly_Frequency__c;
                String monthlyFrequency = eachJobConfig.Monthly_Frequency__c;
                Datetime startTime = eachJobConfig.Start_Time__c;
                String scheduleTime;
                if (scheduleType == 'Daily') {
                    if (dailyFrequency == 'EVERY DAY') {
                        scheduleTime = '0 ' + Integer.valueOf(startTime.minute()) + ' ' + Integer.valueOf(startTime.hour()) + ' * * ? ' + Integer.valueOf(eachJobConfig.End_Year__c);
                    } else if (dailyFrequency == 'EVERY WEEKDAY') {
                        scheduleTime = '0 ' + Integer.valueOf(startTime.minute()) + ' ' + Integer.valueOf(startTime.hour()) + ' ? * MON-FRI ' + Integer.valueOf(eachJobConfig.End_Year__c);
                    }
                } else if (scheduleType == 'Weekly')  {
                    if (weeklyFrequency != null) {
                        scheduleTime = '0 ' + Integer.valueOf(startTime.minute()) + ' ' + Integer.valueOf(startTime.hour()) + ' ? * ' + weeklyFrequency + ' ' + Integer.valueOf(eachJobConfig.End_Year__c);
                    }
                } else if (scheduleType == 'Monthly' && monthlyFrequency != null) {
                    if (monthlyFrequency == 'Last Day of Month') {
                        scheduleTime = '0 ' + Integer.valueOf(startTime.minute()) + ' ' + Integer.valueOf(startTime.hour()) + ' L * ? ' + Integer.valueOf(eachJobConfig.End_Year__c);
                    } else {
                        scheduleTime = '0 ' + Integer.valueOf(startTime.minute()) + ' ' + Integer.valueOf(startTime.hour()) + ' ' + monthlyFrequency.split(' ')[1] + ' * ? ' + Integer.valueOf(eachJobConfig.End_Year__c);
                    }
                    
                }

                System.debug('scheduleType = '+scheduleType);
                System.debug('scheduleTime = '+scheduleTime);
                if(scheduleTime != null){
                    if(eachJobConfig.Class_Type__c == 'Batchable'){
                        System.schedule(eachJobConfig.Label + ', ' + scheduleType , scheduleTime, new ScheduledBatchable(eachJobConfig.Label, Integer.valueOf(eachJobConfig.Batch_Size__c)));
                    }else{
                        Type t = Type.forName(batchName);
                        System.schedule(eachJobConfig.Label + ', ' + scheduleType , scheduleTime, (Schedulable)t.newInstance());
                    }
                }
            } catch (Exception e) {}
        }
    }
}