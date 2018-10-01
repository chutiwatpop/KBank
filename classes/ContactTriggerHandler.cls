/***********************************************************************************
* @author noppawit.h@beryl8.com
* @28/09/2015 created new
* @17/01/2016 Fixed INC000000500904 for update phone on Call Reports
* @30/01/2017 Re-factor code and clean debug log
* @15/02/2017 Chumphon K., ISCR073 UpdateContactOfLeadCustSat
* @04/07/2018 Worrapol A., Create relationship the inserted contact and input contact
* @10/07/2018 Worrapol A., Edit UpdateContactOfLeadCustSat
*
*************************************************************************************/
public class ContactTriggerHandler extends TriggerHandler{
    public static String CLASS_NAME = 'ContactTriggerHandler';
    Public static Map<Id,String> callReportPhoneChange = new Map<Id,String>();
    Public static Map<Id,String> callReportExtensionChange = new Map<Id,String>(); // Add by Chumphon K., ISCR073

    // [Start] Add by Chumphon K., ISCR073
    // [Start] Edit by Worrapol A.
    public override void beforeUpdate() {
        //Declare variable
        String strLeadCustSatCode = System.label.LeadCustSat;
        String strIncorrectPhoneNumber = System.label.IncorrectPhoneNumber;
        String strIncorrectContactName = System.label.IncorrectContactName;

        //Query the needed old version of Contact, edited Contact , Acccount, and Target list
        Set<Id> customerIdSet = new Set<Id>();
        for (Contact eachContact : (List<Contact>) Trigger.new) {
            if(eachContact.AccountId != null) {
                customerIdSet.add(eachContact.AccountId);
            }else if(eachContact.CIS__c != null) {
                customerIdSet.add(eachContact.CIS__c);
            }
        }
        String code = '%' + strLeadCustSatCode + '%';
        Map<Id, Target_List__c> mapAccountToTargetList = new Map<Id, Target_List__c>();
        for (Target_List__c eachTarget : [
            SELECT Id, Lead_Campaign__r.Status, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Personalised_Message__c, CIS_ID_Prospect_Name__c, Contact_Name__c, Customer_Contact_Number__c 
            FROM Target_List__c 
            WHERE Lead_Campaign__r.Status = 'Active' AND CIS_ID_Prospect_Name__c IN :customerIdSet AND Lead_Campaign__r.Lead_Campaign_Event_Code__c LIKE :code
            ]){
            if(eachTarget.CIS_ID_Prospect_Name__c != null) {
                mapAccountToTargetList.put(eachTarget.CIS_ID_Prospect_Name__c, eachTarget);
            }
        }

        //Validate the edited contact with target list
        System.debug('beforeUpdate ContactTriggerHandler');
        List<Account> updatedAccount = new List<Account>();
        for (Contact eachContact : (List<Contact>) Trigger.new){
            Boolean isChangePhoneNumber = false;
            Boolean isChangeContactName = false;
            Contact oldContact = (Contact) Trigger.oldMap.get(eachContact.Id);
            if(eachContact.Phone_Numbers__c != oldContact.Phone_Numbers__c || eachContact.Ext_CBS__c != oldContact.Ext_CBS__c) {
                isChangePhoneNumber = true;
            }
            if(eachContact.FirstName != oldContact.FirstName || eachContact.LastName != oldContact.LastName){
                isChangeContactName = true;
            }

            Id customerId;
            if(eachContact.AccountId != null) {
                customerId = eachContact.AccountId;
            }else if(eachContact.CIS__c != null) {
                customerId = eachContact.CIS__c;
            }
            
            if(mapAccountToTargetList.containsKey(customerId)){
                Account eachAccount = new Account(Id=customerId);
                Target_List__c eachTarget = mapAccountToTargetList.get(customerId);
                if(eachTarget.Personalised_Message__c.contains(strIncorrectPhoneNumber) 
                && isChangePhoneNumber){
                    eachAccount.Incorrect_Phone_Number__c = 'Done';
                    updatedAccount.add(eachAccount);
                }else if(eachTarget.Personalised_Message__c.contains(strIncorrectContactName) 
                && (isChangePhoneNumber || isChangeContactName)){
                    eachAccount.Incorrect_Name__c = 'Done';
                    eachAccount.Incorrect_Phone_Number__c = 'Done';
                    updatedAccount.add(eachAccount);
                }
            }
        }
        if(updatedAccount.size() > 0){
            TriggerHandler.bypass('AccountTriggerHandler');
            update updatedAccount;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    // [End] Add by Chumphon K., ISCR073
    // [End] Add by Worrapol A.

    public override void allBefore() {
        checkContactPrimary();
    }

    // Fixed INC000000500904 for update phone on Call Reports
    public override void allFinally() {
       // checkUpdatePhoneCallReport();
    }

    public override void afterUpdate(){
        if(!Account_Service.updateContactPrefOnce) {
            Account_Service.updateContactPrefOnce = true;
            String contactJSON = SME_JSONGenerator.contactPrefJSONGenerator(Trigger.new);
            if(!system.isBatch()){
                ContactTriggerHandler.futureUpdateContactPrefRequest(contactJSON);
            }
        }
    }

    // [Start] Add by Worrapol A., create relationship the inserted contact and input contact.
    // public override void afterInsert(); {
    //     //Retrive the default reciprocalRole from migrationConfig
    //     MigrationConfig__c migrationConfig = [SELECT ContactRelation__c FROM MigrationConfig__c];
    //     //Create list for create relationship and select the role from database
    //     List<FinServ__ContactContactRelation__c> relateList = new List<FinServ__ContactContactRelation__c>();
    //     List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name From FinServ__ReciprocalRole__c where Id = :migrationconfig.ContactRelation__c];
    //     List<contact> contList = [SELECT Id, CIS__r.PersonContactId FROM Contact WHERE Id IN :Trigger.New];
        
    //     //Create relationships
    //     for(Contact cont : contList){
    //         if(cont.CIS__c != null){
    //             FinServ__ContactContactRelation__c relate = new FinServ__ContactContactRelation__c(
    //                 FinServ__Contact__c = cont.Id, 
    //                 FinServ__RelatedContact__c = cont.CIS__r.PersonContactId, 
    //                 FinServ__Role__c = reciprocalRoleList[0].Id,
    //                 Is_Createby_Integration__c = false
    //             );
    //             relateList.add(relate);
    //         }
    //     }
    //     System.debug(relateList.size());
    //     //Insert the list
    //     insert relateList;
    // }
    // [End] Add by Worrapol A. for, create relationship the inserted contact and input contact.

    private static void updateContactPrefRequest(String contactJSON){
        String functionName = 'afterUpdate';
        String errorMessage;
        SME_UpdateContactPrefResultResponse responseValue;
        try{
            responseValue = SME_CIRestWebservice.updateContactPrefRequest(contactJSON);
        }
        catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+responseValue;
            GlobalUtility.logMessage(GlobalConstants.ERROR_LOG,CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        }
    }

    @future (callout=true)
    private static void futureUpdateContactPrefRequest(String contactJSON){
        if(contactJSON != null){
            ContactTriggerHandler.updateContactPrefRequest(contactJSON);
        }
    }

    private void checkContactPrimary() {
        Set<Id> accountIds = new Set<Id>();
        for (Contact eachCon : ((List<Contact>) Trigger.new)) {
            if (eachCon.AccountId != null && eachCon.Primary_Contact__c != null && eachCon.Primary_Contact__c == true) {
                accountIds.add(eachCon.AccountId);
            }
            if(eachCon.Id != null && eachCon.Phone_Numbers__c != null && eachCon.Phone_Numbers__c != ''){
                callReportPhoneChange.put(Id.valueOf(eachCon.Id), String.valueOf(eachCon.Phone_Numbers__c));
                callReportExtensionChange.put(eachCon.Id, eachCon.Ext_CBS__c); // Add by Chumphon K., ISCR073
            }
        }

        List<Contact> allContactList = new List<Contact>();
        allContactList = [SELECT Id, AccountId, Primary_Contact__c FROM Contact WHERE AccountId IN :accountIds AND Primary_Contact__c = true];
        Set<Id> hasPrimaryConAccount = new Set<Id>();
        for (Contact eachCon : allContactList) {
            hasPrimaryConAccount.add(eachCon.AccountId);    
        }

        for (Contact eachCon : ((List<Contact>) Trigger.new)) {
            if (hasPrimaryConAccount.contains(eachCon.AccountId)) {
                if (Trigger.oldMap == null || ((Contact)Trigger.oldMap.get(eachCon.Id)).Primary_Contact__c != eachCon.Primary_Contact__c) {
                    eachCon.addError(System.Label.PrimaryContactErrorMessage);
                }
            }   
        }
    }

    // Fixed INC000000500904 for update phone on Call Reports
    // private void checkUpdatePhoneCallReport(){
    //     List<Call_Report__c> updateCallReportList = new List<Call_Report__c>();
    //     if(callReportPhoneChange.size() > 0){
    //         // [Start] Add by Chumphon K., ISCR073
    //         Boolean isChangePhone;
    //         String PhoneExtension;
    //         List<Call_Report__c> allCallReportList = [SELECT Id, Phone_Number__c, Phone_Extension__c, Contact__c FROM Call_Report__c WHERE Contact__c IN :callReportPhoneChange.keySet()];
    //         if(allCallReportList.size() > 0){
    //             for(Call_Report__c eachCallReport : allCallReportList){
    //                 isChangePhone = false;
    //                 if(String.valueOf(eachCallReport.Phone_Number__c) != String.valueOf(callReportPhoneChange.get(eachCallReport.Contact__c))){
    //                     eachCallReport.Phone_Number__c = String.valueOf(callReportPhoneChange.get(eachCallReport.Contact__c));
    //                     isChangePhone = true;
    //                 }
    //                 PhoneExtension = callReportExtensionChange.get(eachCallReport.Contact__c);
    //                 if(eachCallReport.Phone_Extension__c != PhoneExtension){
    //                     eachCallReport.Phone_Extension__c = PhoneExtension;
    //                     isChangePhone = true;
    //                 }
    //                 if(isChangePhone){
    //                     updateCallReportList.add(eachCallReport);
    //                 }
    //             }
    //         }
    //         // [End] Add by Chumphon K., ISCR073
    //     }
    //     if(updateCallReportList.size() > 0){
    //         TriggerHandler.bypass('CallReportTriggerHandler');
    //         update updateCallReportList;
    //         TriggerHandler.clearBypass('CallReportTriggerHandler');
    //     }
    // }
}