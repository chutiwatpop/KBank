public with sharing class GenerateFormPDFApexController {
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    
    public class ResultResponse{
        public String result;
        public String message;
        public List<String> errors;
        public ResultResponse() {
            result = SUCCESS;
        }
    }

    @AuraEnabled 
    public static String validatePermission(String accountId, String formName) {
        ResultResponse resp = new ResultResponse();
        List<Allow_Generate_PromptPay_Form__c> allowGeneratePromptpay = [SELECT Name FROM Allow_Generate_PromptPay_Form__c];
        Set<String> allowNameSet = new Set<String>();
        for(Allow_Generate_PromptPay_Form__c eachAllow : allowGeneratePromptpay) {
            allowNameSet.add(eachAllow.Name);
        }
        try {
            System.debug('allowNameSet:' + allowNameSet);
            List<sObject> sobjList = Database.query('SELECT Id, Customer_Type_Code__c FROM Account WHERE Id = :accountId');
            System.debug('formName:' + formName);
            if(formName == 'Promptpay_Registration_Juristic_PDF' || formName == 'Promptpay_Revision_Juristic_PDF') {
                if(!allowNameSet.contains((String) sobjList[0].get('Customer_Type_Code__c'))) {
                    resp.result = ERROR;
                    resp.message = Label.GeneratePromptPayFormErrorMsg;
                }
            }
        } catch (Exception e) {
            resp.result = ERROR;
            resp.message = e.getMessage();
        }
        return JSON.serialize(resp);
    }

    @AuraEnabled
    public static String getFormNameList() {
        List<Generate_Form_PDF_Setting__mdt> generateFormPDFSettingList = new List<Generate_Form_PDF_Setting__mdt>();
        generateFormPDFSettingList = [SELECT Form_Name__c, Page_Name__c FROM Generate_Form_PDF_Setting__mdt ORDER BY Form_Name__c];
        return JSON.serialize(generateFormPDFSettingList);
        return '';
    }

    @AuraEnabled
    public static String createHistory(String accountId, String formName) {
        ResultResponse resp = new ResultResponse();
        try {
            Generate_Form_History__c pdfHistory = new Generate_Form_History__c(User__c=UserInfo.getUserId(),Date_Time__c=System.now(),CIS__c=accountId,Form_Name__c=formName);
            insert pdfHistory;
        } catch (Exception e) {
            resp.result = ERROR;
            resp.message = e.getMessage();
        }
        return JSON.serialize(resp);
    }
}