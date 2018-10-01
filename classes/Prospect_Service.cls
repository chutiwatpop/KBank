public class Prospect_Service {
    public static Account getExistingCustomerFromCIS(String checkCIS) {
        List<Account> queryAccount = new List<Account>();
        if(checkCIS != null && !String.isEmpty(checkCIS)) {
            queryAccount = [SELECT Id FROM Account WHERE CIS__c = :checkCIS LIMIT 1];
        }

        if(!queryAccount.isEmpty()){
            return queryAccount[0];
        }else{
            return null;
        }
    }

    public static Account getExistingCustomerFromCISOrIdNoAndBirthDate(String checkCIS, String ident, Date birthDate) {
        List<Account> queryAccount = new List<Account>();

        if(checkCIS != null) {
            queryAccount = [SELECT Id FROM Account WHERE CIS__c = :checkCIS LIMIT 1];
            if(!queryAccount.isEmpty()){
                return queryAccount[0];
            }else{
                return null;
            }
        }

        if(ident != null && birthDate != null) {
            ident = '\"'+ident+'\"';
            queryAccount = [FIND :ident IN ALL FIELDS RETURNING Account(Id, Encrypt_Identification_No__c, Birthdate_Registration_Date__c)][0];
            for(Account eachAccount : queryAccount) {
                if(eachAccount.Birthdate_Registration_Date__c == birthDate) {
                    return eachAccount;
                }
            }
        }

        return null;
    }

    public static Account startConvertProspect(Account prospectRecord, String customerType) {
        Account convertedCustomer;
        // If Input CIS or ID No. + Birth Date then Call Webservice to DIH
        if(GlobalUtility.isNumberAlphabet(prospectRecord.CIS__c) || (prospectRecord.Birthdate_Registration_Date__c != null && prospectRecord.Encrypt_Identification_No__c != null)) {
            CreateProspect_Webservice.ResponseModel responseModel = Prospect_Service.callWebservice(prospectRecord);    
            CreateProspect_Webservice.CustomerInfo respCustomerInfo = responseModel.customerModel;
            List<CreateProspect_Webservice.CustomerAddress> responseAddressList = new List<CreateProspect_Webservice.CustomerAddress>(responseModel.customerAddresses);
            
            // Check Existing in SFDC Again after get CIS
            if(respCustomerInfo != null) {
                convertedCustomer = Prospect_Service.getExistingCustomerFromCIS(respCustomerInfo.IP_ID);
                if(convertedCustomer != null) {
                    return convertedCustomer;
                }
            }

            Account temporaryAccount = Prospect_Service.getTemporaryAndCloneProspectField(prospectRecord, customerType);
            convertedCustomer = Prospect_Service.addAllCustomerInfoField(temporaryAccount, respCustomerInfo);
            update convertedCustomer;

            if(responseAddressList != null && !responseAddressList.isEmpty()) {
                Prospect_Service.createRelatedAddressed(convertedCustomer, responseAddressList);    
            }
        } else {
            convertedCustomer = Prospect_Service.getTemporaryAndCloneProspectField(prospectRecord, customerType);
            update convertedCustomer;
        }
        return convertedCustomer;
    }
	
	public static Account addAllCustomerInfoField(Account temporaryAccount, CreateProspect_Webservice.CustomerInfo customerInfo) {
        if(customerInfo != null && customerInfo.IP_ID != null) {
            temporaryAccount.CIS__c 						= customerInfo.IP_ID;
            temporaryAccount.Customer_Status__c 			= customerInfo.PRVN_F;
            temporaryAccount.Status__c 						= customerInfo.IP_PERF_ST_CD;
            temporaryAccount.Customer_Segment_Code__c 		= customerInfo.PRIM_SEG_CD;
            temporaryAccount.Primary_Segment_Code__c        = customerInfo.PRIM_SEG_CD;
            temporaryAccount.Primary_Sub_Segment_Code__c	= customerInfo.PRIM_SUB_SEG_CD;
            temporaryAccount.Dual_Segment_Code__c 			= customerInfo.DUAL_SEG_CD;
            temporaryAccount.Dual_Sub_Segment_Code__c		= customerInfo.DUAL_SUB_SEG_CD;
            temporaryAccount.Customer_Type_Code__c			= customerInfo.IP_TP_CD;
            temporaryAccount.Document_Type_Code__c 			= customerInfo.DOC_ITM_CD;
            temporaryAccount.Customer_s_Business_Code__c		= customerInfo.KBNK_IDY_CL_CD;
            temporaryAccount.Industry_Classification_Code__c	= customerInfo.CO_IDY_CL_CD;
            
            temporaryAccount.Encrypt_Title_EN__c              = customerInfo.EN_TTL;
            temporaryAccount.Encrypt_Title_TH__c              = customerInfo.TH_TTL;
    		temporaryAccount.Encrypt_Name_EN__c               = customerInfo.EN_FRST_NM;
    		temporaryAccount.Encrypt_Name_TH__c               = customerInfo.TH_FRST_NM;
            temporaryAccount.Encrypt_Middle_Name_EN__c        = customerInfo.EN_MDL_NM;
            temporaryAccount.Encrypt_Middle_Name_TH__c        = customerInfo.TH_MDL_NM;
    		temporaryAccount.Encrypt_Surname_EN__c            = customerInfo.EN_SURNM;
            temporaryAccount.Encrypt_Surname_TH__c            = customerInfo.TH_SURNM;
    		temporaryAccount.Encrypt_Identification_No__c     = customerInfo.IDENT_NO;

            // Masking Ident
            if(temporaryAccount.Encrypt_Identification_No__c != null) {
                temporaryAccount.Identification_No_Mask__c    = maskingIdent(temporaryAccount.Encrypt_Identification_No__c);    
            }
            temporaryAccount.Birthdate_Registration_Date__c   = GlobalUtility.parseStringToDate(customerInfo.BRTH_ESTB_DT);
            setAccountRecordTypeAndName(temporaryAccount);

            // Remove Prospect Field
            temporaryAccount.Fax							= null;
            temporaryAccount.Phone							= null;
            temporaryAccount.Business_Email__c              = null;
            temporaryAccount.Mobile_Phone__c				= null;
        }
        return temporaryAccount;
    }

    public static void createRelatedAddressed(Account temporaryAccount, List<CreateProspect_Webservice.CustomerAddress> responseAddressList) {
        List<Address__c> newAddressList = new List<Address__c>();
        for(CreateProspect_Webservice.CustomerAddress customerAddress : responseAddressList) {
            Address__c newAddress = Prospect_Service.mappingAddressField(customerAddress, temporaryAccount);
            newAddressList.add(newAddress);
        }
        if(!newAddressList.isEmpty()) insert newAddressList;
    }

    public static Address__c mappingAddressField(CreateProspect_Webservice.CustomerAddress customerAddress, Account thisAccount) {
        Address__c newAddress = new Address__c();
        newAddress.CIS_ID__c 				= thisAccount.Id;
        newAddress.External_ID__c			= thisAccount.CIS__c;
        if(customerAddress.ADR_ID != null){
            newAddress.External_ID__c = newAddress.External_ID__c + '-' + customerAddress.ADR_ID;
        }
        if(customerAddress.ADR_USE_TP_CD != null){
            newAddress.External_ID__c = newAddress.External_ID__c + '-' + customerAddress.ADR_USE_TP_CD;
        }
        newAddress.Address_Type__c 			= customerAddress.ADR_USE_TP_CD;
        newAddress.Place__c 				= customerAddress.WRKPLC_NM;
        newAddress.Box_Number__c 			= customerAddress.BOX_NO;
        newAddress.House_Number_Encrypt__c 	= customerAddress.HS_NO;
        newAddress.Village_Number__c 		= customerAddress.VILL_NO;
        newAddress.Village__c 				= customerAddress.VILL;
        newAddress.Building__c 				= customerAddress.BLD_NM;
        newAddress.Room__c 					= customerAddress.ROOM_NO;
        newAddress.Floor__c 				= customerAddress.FLR_NO;
        newAddress.Alley__c 				= customerAddress.ALY;
        newAddress.Street__c 				= customerAddress.STR_NM;
        newAddress.Sub_District__c 			= customerAddress.SUBDSTC;
        newAddress.District__c 				= customerAddress.DSTC;
        newAddress.Province__c 				= customerAddress.PROV;
        newAddress.Original_Code_from_CIS__c = customerAddress.CIS_SRC_STM_CD;
        newAddress.Postcode__c 				= customerAddress.PSTCD_AREA_CD;
        newAddress.Country_code__c 			= customerAddress.CTY_CD;
        return newAddress;
    }

    public static Account getTemporaryAndCloneProspectField(Account targetAccount, String customerType) {
        String recordTypeDevName = '';
        if(customerType == GlobalConstants.INDIVIDUAL) {
            recordTypeDevName = GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME;
        } else if(customerType == GlobalConstants.ORGANIZATION) {
            recordTypeDevName = GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME;
        }

        Account temporaryAccount = [SELECT Id, PersonContactId, PersonContact.FirstName, PersonContact.LastName, RecordTypeId, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = :recordTypeDevName AND Temporary_Customer__c = true LIMIT 1];
        temporaryAccount.Temporary_Customer__c = false;
        temporaryAccount.CIS__c                          = targetAccount.CIS__c;
        temporaryAccount.Birthdate_Registration_Date__c  = targetAccount.Birthdate_Registration_Date__c;
        temporaryAccount.Encrypt_Identification_No__c    = targetAccount.Encrypt_Identification_No__c;
        temporaryAccount.Document_Type_Prospect__c       = targetAccount.Document_Type_Prospect__c;
        temporaryAccount.Title__c                        = targetAccount.Title__c;
        setOwnershipField(temporaryAccount);

        // Set Required Field
        if(customerType == GlobalConstants.INDIVIDUAL) {
            if(!String.isBlank(targetAccount.Salutation)) {
                temporaryAccount.Salutation = targetAccount.Salutation;    
            }
            temporaryAccount.FirstName      = targetAccount.FirstName;
            temporaryAccount.LastName       = targetAccount.LastName;
        } else if(customerType == GlobalConstants.ORGANIZATION) {
            temporaryAccount.Name = targetAccount.Name;
        }
        return temporaryAccount;
    }

    private static void setOwnershipField(Account temporaryAccount) {
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        if(GlobalConstants.PROFILE_RBS_SET.contains(UserService.getCurrentUserInfo().Profile.Name)) {
            temporaryAccount.OwnerId = userAdmin.RBS_User_ID__c;
        } else if(GlobalConstants.PROFILE_AF_SET.contains(UserService.getCurrentUserInfo().Profile.Name)) {
            temporaryAccount.OwnerId = userAdmin.RBS_User_ID__c;
            User_Extension__c currentUserEx = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
            if(currentUserEx != null) temporaryAccount.AF_Temporary_Customer__c = currentUserEx.Id;
        } else {
            temporaryAccount.OwnerId = UserInfo.getUserId();
            User_Extension__c currentUserEx = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
            if(GlobalConstants.PROFILE_SME_SET.contains(UserService.getCurrentUserInfo().Profile.Name)) {
                if(currentUserEx != null) temporaryAccount.SME_Temporary_Customer__c = currentUserEx.Id;
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

    public static CreateProspect_Webservice.ResponseModel callWebservice(Account requestAccount) {
        CreateProspect_Webservice webServiceInstance = CreateProspect_Webservice.getInstance();
        webServiceInstance.setRequestParamFromAccount(requestAccount);

        CreateProspect_Webservice.ResponseModel responseModel = webServiceInstance.calloutWebservice();
        if(responseModel.error != null && responseModel.error.message != null) {
            throw new CIWebserviceException(responseModel.error.message);
        }
        return responseModel;
    }

    private static void setAccountRecordTypeAndName(Account temporaryAccount) {
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        if(temporaryAccount.Customer_Type_Code__c == 'I') {
            if(temporaryAccount.RecordType.DeveloperName != GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
                throw new ProspectException(Label.Customer_type_mismatch);  
            } else {
                setIndividualAccountFieldName(temporaryAccount);
                temporaryAccount.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
            }
        } else if(temporaryAccount.Customer_Type_Code__c == 'O') {
            if(temporaryAccount.RecordType.DeveloperName != GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) {
                throw new ProspectException(Label.Customer_type_mismatch);  
            } else {
                setOrganizationAccountFieldName(temporaryAccount);
                temporaryAccount.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
            }
        }
    }

    private static void setIndividualAccountFieldName(Account temporaryAccount) {
        temporaryAccount.Salutation = temporaryAccount.Encrypt_Title_TH__c != null ? temporaryAccount.Encrypt_Title_TH__c : temporaryAccount.Encrypt_Title_EN__c; 
        temporaryAccount.FirstName  = temporaryAccount.Encrypt_Name_TH__c != null ? temporaryAccount.Encrypt_Name_TH__c : temporaryAccount.Encrypt_Name_EN__c;
        temporaryAccount.LastName   = temporaryAccount.Encrypt_Surname_TH__c != null ? temporaryAccount.Encrypt_Surname_TH__c : temporaryAccount.Encrypt_Surname_EN__c;
        temporaryAccount.Partial_Surname__c = (temporaryAccount.LastName.length() > 3) ? temporaryAccount.LastName.substring(0,3) : temporaryAccount.LastName;
    }

    private static void setOrganizationAccountFieldName(Account temporaryAccount) {
        temporaryAccount.Name = GlobalUtility.convertStringNulltoBlank(temporaryAccount.Encrypt_Title_TH__c) +' '+ GlobalUtility.convertStringNulltoBlank(temporaryAccount.Encrypt_Name_TH__c);
        temporaryAccount.Name = temporaryAccount.Name.trim();
        if(String.isBlank(temporaryAccount.Name)) {
            temporaryAccount.Name = GlobalUtility.convertStringNulltoBlank(temporaryAccount.Encrypt_Name_EN__c) +' '+ GlobalUtility.convertStringNulltoBlank(temporaryAccount.Encrypt_Title_EN__c);
            temporaryAccount.Name = temporaryAccount.Name.trim();
        }
    }

    public class ProspectException extends Exception {}
}