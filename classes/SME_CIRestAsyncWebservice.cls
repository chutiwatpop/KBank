/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Convert prospect callout with Async 

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T           First Create
08/08/2015  Charnun.T           Add more logic about convert with CIS 
01/02/2017  Charnun.T           Re-factor code to improve performance 
15/03/2017  Chutiwat.S          Add Application Log (Log Request JSON String) for CI Convert Prospect INC000000466203
27/03/2017  Charnun.T           Fixed Prospect INC000000466203 With change type Integer to Long
------------------------------------------------------------*/
global class SME_CIRestAsyncWebservice {

    public static final String CALLOUT_URL = CustomSettingUtil.getEndpointByName('KbankURL');
    public static String CONVERTPROSPECT_ENDPOINT = CALLOUT_URL + 'SMEConvertProspect';
    public static String CONVERTPROSPECTWITHCIS_ENDPOINT = CALLOUT_URL + 'SMEConvertProspectWithCIS';
    public static String CONVERTPROSPECT_STATUS_ENDPOINT = CALLOUT_URL + 'SMEConvertProspectStatus';
    public static String CONVERTPROSPECTWITHCIS_STATUS_ENDPOINT = CALLOUT_URL + 'SMEConvertProspectWithCISStatus';
    public static String CLASS_NAME = 'SMECIRestAsyncWebservice';
    public static Integer CONVERT_PROSPECT_LIMIT_PER_ROUND = Integer.valueOf(Label.CONVERT_PROSPECT_LIMIT_PER_ROUND);

    public static void convertProspectRequest(List<sObject> convertList) {
        List<sObject> convertProspectList = new List<sObject>();
        List<Account> updateAccountConvertProspect = new List<Account>();
        //List<sObject> convertProspectProblemList = new List<sObject>();
        // Create Application Log (Log Request JSON String) for CI Convert Prospect INC000000466203 05-04-2017
        //List<String> allJSONRequestString = new List<String>();

        for(sObject convert : convertList){
            if(convert.get('Birthdate_Registration_Date__c') != null && convert.get('Encrypt_Identification_No__c') != null){
                Account tempAccount = new Account();
                tempAccount.Id = Id.valueOf(convert.Id);
                tempAccount.Convert_Prospect_Date__c = System.today();
                updateAccountConvertProspect.add(tempAccount);

                convertProspectList.add(convert);
                if(convertProspectList.size() >= CONVERT_PROSPECT_LIMIT_PER_ROUND){
                    String jsonConvertedProspect = SME_JSONGenerator.convertProspectJSONGenerator(convertProspectList,false);
                    //allJSONRequestString.add(jsonConvertedProspect); // INC000000466203 05-04-2017
                    SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECT_ENDPOINT,jsonConvertedProspect);
                    convertProspectList.clear();
                }
            }
            //else{
            //    convertProspectProblemList.add(convert);
            //}
        }

        if(convertProspectList.size() > 0){
            String jsonConvertedProspect = SME_JSONGenerator.convertProspectJSONGenerator(convertProspectList,false);
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECT_ENDPOINT,jsonConvertedProspect);
        }
        
        if(updateAccountConvertProspect.size()>0){
            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccountConvertProspect;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
        //if(convertProspectProblemList.size() > 0){
        //    GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequest',null,null,'Convert prospect error :'+convertProspectProblemList,null,null,null);
        //}
        // INC000000466203 05-04-2017
        //if(!allJSONRequestString.isEmpty()) {
        //    GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequest','INC000000466203','JSON Convert Prospect Request String','JSON:' + allJSONRequestString,null,null,null);    
        //}
    }

    public static void convertProspectRequestWithCIS(List<sObject> convertList) {
        List<sObject> convertProspectListWithCIS = new List<sObject>();
        List<Account> updateAccountConvertProspect = new List<Account>();
        //List<sObject> convertProspectProblemList = new List<sObject>();
        // Create Application Log (Log Request JSON String) for CI Convert Prospect INC000000466203 15-03-2017
        //List<String> allJSONRequestString = new List<String>();

        for(sObject convert : convertList){
            if((GlobalUtility.isNumberAlphabet(String.valueOf(convert.get('CIS__c')))) && ((String.valueOf(convert.get('CIS__c'))).length() <= 10) && Integer.valueOf(convert.get('CIS__c')) < 2000000000){
                Account tempAccount = new Account();
                tempAccount.Id = Id.valueOf(convert.Id);
                tempAccount.Convert_Prospect_Date__c = System.today();
                //FSC Name cannot write
                //tempAccount.Name = String.valueOf(Long.valueOf(String.valueOf(convert.get('Name'))));
                updateAccountConvertProspect.add(tempAccount);

                convertProspectListWithCIS.add(convert);

                if(convertProspectListWithCIS.size() >= CONVERT_PROSPECT_LIMIT_PER_ROUND){
                    String jsonConvertedProspect = SME_JSONGenerator.convertProspectWithCISJSONGenerator(convertProspectListWithCIS,false);
                    //allJSONRequestString.add(jsonConvertedProspect); // INC000000466203 15-03-2017
                    SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECTWITHCIS_ENDPOINT, jsonConvertedProspect);
                    convertProspectListWithCIS.clear();
                }
            }
            //else{
            //    convertProspectProblemList.add(convert);
            //}
        }

        if(convertProspectListWithCIS.size() > 0){
            String jsonConvertedProspect = SME_JSONGenerator.convertProspectWithCISJSONGenerator(convertProspectListWithCIS,false);
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECTWITHCIS_ENDPOINT,jsonConvertedProspect);
            //allJSONRequestString.add(jsonConvertedProspect); // INC000000466203 15-03-2017
        }
        
        if(updateAccountConvertProspect.size()>0){
            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccountConvertProspect;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
        //if(convertProspectProblemList.size() > 0){
        //    GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequestWithCIS','INC000000466203',null,'Convert prospect error :'+convertProspectProblemList,null,null,null);
        //}

        // INC000000466203 15-03-2017
        //if(!allJSONRequestString.isEmpty()) {
        //    GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequestWithCIS','INC000000466203','JSON Convert Prospect Request String','JSON:' + allJSONRequestString,null,null,null);    
        //}
    }
    
    public static void convertProspectWithZeroRecord(String convertFunction){
        if(convertFunction == 'WithIdentification'){
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECT_STATUS_ENDPOINT,'{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }else if(convertFunction == 'WithCIS'){
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECTWITHCIS_STATUS_ENDPOINT,'{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }
    }
}