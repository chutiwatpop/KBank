//CR026 Generate Form Promptpay Registration & Promptpay Revision
public with sharing class Promptpay_Registration_PDF_Controller {
    public Boolean isShowMashUpID {get; set;}
    public Promptpay_Registration_PDF_Controller(ApexPages.StandardController stdController) {
        isShowMashUpID = false;
        List<Generate_Form_Cust_Type__c> generateCustoms = new List<Generate_Form_Cust_Type__c>();
        generateCustoms = [SELECT Name FROM Generate_Form_Cust_Type__c];
        Set<String> customTypes = new Set<String>();
        for(Generate_Form_Cust_Type__c eachCustom : generateCustoms) {
            customTypes.add(eachCustom.Name);
        }
        Account thisAccount = (Account) stdController.getRecord();
        try {
            thisAccount = [SELECT Id, Name, CIS__c, Encrypt_Identification_No__c, Custype_Code__c, Name_Surname_TH__c, Name_Surname_EN__c FROM Account WHERE Id = :thisAccount.Id];
            if(thisAccount.Custype_Code__c != null && customTypes.contains(thisAccount.Custype_Code__c)) {
                isShowMashUpID = true;
            }    
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
        }
    }
}