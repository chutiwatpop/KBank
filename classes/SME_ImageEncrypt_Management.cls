/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
public class SME_ImageEncrypt_Management {
    private String encryptKey = 'Test1234 Exameod';
    public void updateEncryptFields(List<sObject> scope) {
        List<Account> updateAccount = new List<Account>();
        for(sObject each : scope){
            Account eachAccount = new Account();
            String cis = String.valueOf(each.get('CIS__c'));
            String sfdcID = String.valueOf(each.get('Id'));
        
            String encryptTitleTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_TTL.gif');
            String encryptTitleEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_TTL.gif');
            String encryptSurnameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_SURNM.gif');
            String encryptSurnameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_SURNM.gif');
            String encryptNameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_FRST_NM.gif');
            String encryptNameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_FRST_NM.gif');
            //String encrypt_Middle_Name_TH__c = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/'+fieldName+'.gif');
            //String encrypt_Middle_Name_EN__c = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/'+fieldName+'.gif');
            String encryptIdentificationNo = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/IDENT_NO.gif');
            String encryptFullNameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/en/'+cis+'/FULL_NAME.gif');
            String encryptFullNameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/FULL_NAME.gif');

            eachAccount.CIS__c = cis;
            eachAccount.Id = sfdcID;
            if(encryptTitleTH != null || encryptTitleTH != ''){
                eachAccount.Encrypt_Title_TH__c = encryptTitleTH;
            }else{
                eachAccount.Encrypt_Title_TH__c = String.valueOf(each.get('Encrypt_Title_TH__c'));
            }
            if(encryptTitleEN != null || encryptTitleEN != ''){
                eachAccount.Encrypt_Title_EN__c = encryptTitleEN;
            }else{
                eachAccount.Encrypt_Title_EN__c = String.valueOf(each.get('Encrypt_Title_EN__c'));
            }
            if(encryptSurnameTH != null || encryptSurnameTH != ''){
                eachAccount.Encrypt_Surname_TH__c = encryptSurnameTH;
            }else{
                eachAccount.Encrypt_Surname_TH__c = String.valueOf(each.get('Encrypt_Surname_TH__c'));
            }
            if(encryptSurnameEN != null || encryptSurnameEN != ''){
                eachAccount.Encrypt_Surname_EN__c = encryptSurnameEN;
            }else{
                eachAccount.Encrypt_Surname_EN__c = String.valueOf(each.get('Encrypt_Surname_EN__c'));
            }
            if(encryptNameTH != null || encryptNameTH != ''){
                eachAccount.Encrypt_Name_TH__c = encryptNameTH;
            }else{
                eachAccount.Encrypt_Name_TH__c = String.valueOf(each.get('Encrypt_Name_TH__c'));
            }
            if(encryptNameEN != null || encryptNameEN != ''){
                eachAccount.Encrypt_Name_EN__c = encryptNameEN;
            }else{
                eachAccount.Encrypt_Name_EN__c = String.valueOf(each.get('Encrypt_Name_EN__c'));
            }
            if(encryptIdentificationNo != null || encryptIdentificationNo != ''){
                eachAccount.Encrypt_Identification_No__c = encryptIdentificationNo;
            }else{
                eachAccount.Encrypt_Identification_No__c = String.valueOf(each.get('Encrypt_Identification_No__c'));
            }
            if(encryptFullNameEN != null || encryptFullNameEN != ''){
                eachAccount.Encrypt_Fullname_EN__c = encryptFullNameEN;
            }else{
                eachAccount.Encrypt_Fullname_EN__c = String.valueOf(each.get('Encrypt_Fullname_EN__c'));
            }
            if(encryptFullNameTH != null || encryptFullNameTH != ''){
                eachAccount.Encrypt_Fullname_TH__c = encryptFullNameTH;
            }else{
                eachAccount.Encrypt_Fullname_TH__c = String.valueOf(each.get('Encrypt_Fullname_TH__c'));
            }
            updateAccount.add(eachAccount);
        }
        if(updateAccount.size() > 0){
            update updateAccount;
        }
    }

    public Account updateEncryptFields(Account eachAccount) {
        String cis = eachAccount.CIS__c;
    
        String encryptTitleTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_TTL.gif');
        String encryptTitleEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_TTL.gif');
        String encryptSurnameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_SURNM.gif');
        String encryptSurnameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_SURNM.gif');
        String encryptNameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/TH_FRST_NM.gif');
        String encryptNameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/EN_FRST_NM.gif');
        //String encrypt_Middle_Name_TH__c = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/'+fieldName+'.gif');
        //String encrypt_Middle_Name_EN__c = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/'+fieldName+'.gif');
        String encryptIdentificationNo = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/IDENT_NO.gif');
        String encryptFullNameEN = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/en/'+cis+'/FULL_NAME.gif');
        String encryptFullNameTH = GlobalUtility.getEncryptedDataWithTransform(encryptKey,'customer/th/'+cis+'/FULL_NAME.gif');

        if(encryptTitleTH != null || encryptTitleTH != ''){
            eachAccount.Encrypt_Title_TH__c = encryptTitleTH;
        }
        if(encryptTitleEN != null || encryptTitleEN != ''){
            eachAccount.Encrypt_Title_EN__c = encryptTitleEN;
        }
        if(encryptSurnameTH != null || encryptSurnameTH != ''){
            eachAccount.Encrypt_Surname_TH__c = encryptSurnameTH;
        }
        if(encryptSurnameEN != null || encryptSurnameEN != ''){
            eachAccount.Encrypt_Surname_EN__c = encryptSurnameEN;
        }
        if(encryptNameTH != null || encryptNameTH != ''){
            eachAccount.Encrypt_Name_TH__c = encryptNameTH;
        }
        if(encryptNameEN != null || encryptNameEN != ''){
            eachAccount.Encrypt_Name_EN__c = encryptNameEN;
        }
        if(encryptIdentificationNo != null || encryptIdentificationNo != ''){
            eachAccount.Encrypt_Identification_No__c = encryptIdentificationNo;
        }
        if(encryptFullNameEN != null || encryptFullNameEN != ''){
            eachAccount.Encrypt_Fullname_EN__c = encryptFullNameEN;
        }
        if(encryptFullNameTH != null || encryptFullNameTH != ''){
            eachAccount.Encrypt_Fullname_TH__c = encryptFullNameTH;
        }

        return eachAccount;
    }
}