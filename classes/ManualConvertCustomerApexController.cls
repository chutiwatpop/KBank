public with sharing class ManualConvertCustomerApexController {
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    
    public class ResultResponse{
        public Account convertedCustomer;
        public String result;
        public String message;
        public List<String> errors;
        public ResultResponse() {
            result = SUCCESS;
        }
    }

    @AuraEnabled
    public static String searchCustomerByCriteria(String cisNumber,String identification,String birthDateStr){
        Account existingAccount = new Account();
        ResultResponse resp = new ResultResponse();
        Date birthDate = null;
            try{
                if(birthDateStr != null){
                    birthDate = Date.valueOf(birthDateStr);
                }
                Account accObj = Prospect_Service.getExistingCustomerFromCISOrIdNoAndBirthDate(cisNumber,identification,birthDate);
                if(accObj == null) {
                    existingAccount.CIS__c                           = cisNumber;
                    existingAccount.Encrypt_Identification_No__c     = identification;
                    existingAccount.Birthdate_Registration_Date__c   = birthDate;
                } else {
                    existingAccount = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE Id = :accObj.Id];
                }

                CreateProspect_Webservice.ResponseModel responseModel = Prospect_Service.callWebservice(existingAccount);
                CreateProspect_Webservice.CustomerInfo respCustomerInfo = responseModel.customerModel;    
                if(respCustomerInfo != null) {
                    fixedAccountEncryptField(existingAccount, respCustomerInfo,resp);
                }
                resp.convertedCustomer = existingAccount;
            }catch(Exception e){
                resp.result = ERROR;
                resp.message = e.getMessage();
            }
         return JSON.serialize(resp);
    }

    @AuraEnabled
    public static String repairCustomerWithAccount(String accountObj) {
        ResultResponse resp = new ResultResponse();
        Account existingAccount = new Account();
        try {
            if(accountObj != null){
                existingAccount = (Account) JSON.deserialize(accountObj, Account.class);
                update existingAccount;
            }
            resp.convertedCustomer = existingAccount;
        }catch (Exception e) {
            resp.result = ERROR;
            resp.message = e.getMessage();
        }
        return JSON.serialize(resp);
    }

    @TestVisible
    private static void fixedAccountEncryptField(Account existingAccount, CreateProspect_Webservice.CustomerInfo customerInfo,ResultResponse resp) {
        if(customerInfo.IP_ID != null){
            existingAccount.CIS__c 						    = customerInfo.IP_ID;
        }    
        existingAccount.Customer_Type_Code__c           = customerInfo.IP_TP_CD;
        existingAccount.Document_Type_Code__c           = customerInfo.DOC_ITM_CD;

        existingAccount.Customer_Status__c 			    = customerInfo.PRVN_F;
        existingAccount.Status__c 						= customerInfo.IP_PERF_ST_CD;
        existingAccount.Customer_Segment_Code__c 		= customerInfo.PRIM_SEG_CD;
        existingAccount.Primary_Segment_Code__c         = customerInfo.PRIM_SEG_CD;
        existingAccount.Primary_Sub_Segment_Code__c	    = customerInfo.PRIM_SUB_SEG_CD;
        existingAccount.Dual_Segment_Code__c 			= customerInfo.DUAL_SEG_CD;
        existingAccount.Dual_Sub_Segment_Code__c		= customerInfo.DUAL_SUB_SEG_CD;
        existingAccount.Customer_s_Business_Code__c		= customerInfo.KBNK_IDY_CL_CD;
        existingAccount.Industry_Classification_Code__c	= customerInfo.CO_IDY_CL_CD;

        existingAccount.Encrypt_Title_EN__c              = customerInfo.EN_TTL;
        existingAccount.Encrypt_Title_TH__c              = customerInfo.TH_TTL;
        existingAccount.Encrypt_Name_EN__c               = customerInfo.EN_FRST_NM;
        existingAccount.Encrypt_Name_TH__c               = customerInfo.TH_FRST_NM;
        existingAccount.Encrypt_Middle_Name_EN__c        = customerInfo.EN_MDL_NM;
        existingAccount.Encrypt_Middle_Name_TH__c        = customerInfo.TH_MDL_NM;
        existingAccount.Encrypt_Surname_EN__c            = customerInfo.EN_SURNM;
        existingAccount.Encrypt_Surname_TH__c            = customerInfo.TH_SURNM;
        existingAccount.Encrypt_Identification_No__c     = customerInfo.IDENT_NO;
        existingAccount.Birthdate_Registration_Date__c   = GlobalUtility.parseStringToDate(customerInfo.BRTH_ESTB_DT);
        // Masking Ident
        if(existingAccount.Encrypt_Identification_No__c != null) {
            existingAccount.Identification_No_Mask__c    = maskingIdent(existingAccount.Encrypt_Identification_No__c);    
        }

        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        String individualCustomer = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
        String individualProspect = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
        String organizationProspect = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        String organizationCustomer = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
        if(existingAccount.Customer_Type_Code__c == 'I') {
            if(existingAccount.RecordTypeId != individualCustomer && existingAccount.RecordTypeId != individualProspect) {
                resp.message = Label.Customer_type_mismatch;
                // throw new Prospect_Service.ProspectException(Label.Customer_type_mismatch);  
            } 
                existingAccount.Salutation = existingAccount.Encrypt_Title_TH__c != null ? existingAccount.Encrypt_Title_TH__c : existingAccount.Encrypt_Title_EN__c; 
                existingAccount.FirstName = existingAccount.Encrypt_Name_TH__c != null ? existingAccount.Encrypt_Name_TH__c : existingAccount.Encrypt_Name_EN__c;
                existingAccount.LastName = existingAccount.Encrypt_Surname_TH__c != null ? existingAccount.Encrypt_Surname_TH__c : existingAccount.Encrypt_Surname_EN__c;
                existingAccount.Partial_Surname__c = (existingAccount.LastName.length() > 3) ? existingAccount.LastName.substring(0,3) : existingAccount.LastName;

                existingAccount.RecordTypeId = individualCustomer;
            
        } else if(existingAccount.Customer_Type_Code__c == 'O') {
            if(existingAccount.RecordTypeId != organizationCustomer && existingAccount.RecordTypeId != organizationProspect) {
                resp.message = Label.Customer_type_mismatch;
                // throw new Prospect_Service.ProspectException(Label.Customer_type_mismatch);  
            }
                existingAccount.RecordTypeId = organizationCustomer;
                existingAccount.Name = GlobalUtility.convertStringNulltoBlank(existingAccount.Encrypt_Title_TH__c) +' '+ GlobalUtility.convertStringNulltoBlank(existingAccount.Encrypt_Name_TH__c);
                existingAccount.Name = existingAccount.Name.trim();
                if(String.isBlank(existingAccount.Name)) {
                    existingAccount.Name = GlobalUtility.convertStringNulltoBlank(existingAccount.Encrypt_Name_EN__c) +' '+ GlobalUtility.convertStringNulltoBlank(existingAccount.Encrypt_Title_EN__c);
                    existingAccount.Name = existingAccount.Name.trim();
                }
            
        }
    }

    private static String maskingIdent(String oldIdent) {
        if(oldIdent.length() < 5) {
            return oldIdent;
        }

        String toReplace = '';
        for(Integer i=0; i<oldIdent.length()-5; i++) {
            toReplace = toReplace + 'x';
        }
        return toReplace + oldIdent.substring(oldIdent.length()-5, oldIdent.length());
    }
}