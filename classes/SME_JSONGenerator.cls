/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   JSON Generator.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
14/03/2016  Charnun.T         	First Create
------------------------------------------------------------*/
public with sharing class SME_JSONGenerator {
	public static String leadStatusJSONGenerator(List<Target_List__c> updateLeadStatusSpilt){
		//requestStr = 'IP_ID='+cisID+'&SFDC_ID='+sfdcID+'&STATUS='+leadStatus;
		//Transform to JSON format
		/*
		{"updateLeadStatus": {"targetList":[
			{"SFDC_ID": "xxxxxxx",
			"IP_ID": "457397",
			"STATUS": "2"},

			{"SFDC_ID": "yyyyyyy",
			"IP_ID": "847393",
			"STATUS": "5"}
		]}}
		*/
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('updateLeadStatus');
        gen.writeStartObject();
        gen.writeFieldName('targetList');
        gen.writeStartArray();
        //for each attendee create a JSON object
        for(Target_List__c targetListObject : updateLeadStatusSpilt){
            gen.writeStartObject();        
            gen.writeStringField('SFDC_ID', String.valueOf(targetListObject.Id));
            gen.writeStringField('IP_ID', String.valueOf(targetListObject.CIS_ID_Prospect_Name__r.Name));
            gen.writeStringField('STATUS_ID', String.valueOf('0'));
            gen.writeStringField('LEAD_ID', String.valueOf(targetListObject.Lead_Campaign__r.Name));
            gen.writeStringField('UPDATE_DT', GlobalUtility.toExportDateFormat(System.today()));
            gen.writeStringField('UPDATE_USER', String.valueOf(UserInfo.getName()));
            //gen.writeStringField('STATUS_ID', String.valueOf(targetListObject.Status__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static String contactPrefJSONGenerator(List<Contact> updateContactPrefSpilt){

        /*
        {   "updateCustomerPref" : 
            {       "jobrequest" : 
                [{           "IP_ID" : "32354",
                            "CTC_PSN_ID" : "str12",             
                            "TH_TTL" : "str1234",           
                            "TH_FRST_NM" : "str1234",           
                            "TH_MDL_NM" : "str1234",  

                            "TH_SURNM" : "str1234",             
                            "EN_TTL" : "str1234",           
                            "EN_FRST_NM" : "str1234",           
                            "EN_MDL_NM" : "str1234",            
                            "EN_SURNM" : "str1234", 

                            "NCK" : "str1234",          
                            "POS" : "str1234",          
                            "PSN_EMAIL" : "str1234",            
                            "BSN_EMAIL" : "str1234",            
                            "MBL_NO" : "str1234",   

                            "LINE_ID" : "str1234",          
                            "FB_ID" : "str1234",            
                            "IG_ID" : "str1234",            
                            "PRIM_CTC_F" : "t",             
                            "DOB" : "",  

                            "CTC_RPRT_TP_CD" : "s1",            
                            "PREF_CTC_MTH" : "str1234",             
                            "ACTV_F" : "I",             
                            "FAV_FOOD_TP_CD" : "str1234",           
                            "ALG_FOOD_TP_CD" : "str1234", 

                            "LS_TP_CD" : "str1234",             
                            "LS_SUB_TP_CD" : "str1234",             
                            "FAV_BRND" : "str1234",             
                            "FAV_RSTRN" : "str1234",            
                            "FAV_SPORT" : "str1234",   

                            "MOST_INTD_TOPC" : "str1234",           
                            "SPK_LNG" : "str1234",          
                            "INT_IVSM_EV" : "str1234",          
                            "INT_GNL_EV" : "str1234",           
                            "FAV_MGZ" : "str1234",   

                            "COLL" : "str1234",             
                            "SOC_PSN_F" : "str1234",            
                            "OTHR_CHAR_INFO" : "str1234",           
                            "EFF_DT" : "",          
                            "END_DT" : "",    

                            "LAST_VRSN_F" : "2",            
                            "CRT_DT" : "",          
                            "CRT_USR" : "str1234",          
                            "UDT_DT" : "",          
                            "UDT_USR" : "str1234"       
                }]  
            } 
        }
        */

        /*Contact:{Id=003N000000XxlRLIAZ, IsDeleted=false, MasterRecordId=null, AccountId=001N000000av6tYIAQ, Salutation=นาย, 
        FirstName=ชนัญญ์, LastName=ทวีธรรมวิทยา, RecordTypeId=01228000000TZ5EAAW, OtherStreet=null, OtherCity=null, OtherState=null, 
        OtherPostalCode=null, OtherCountry=null, OtherLatitude=null, OtherLongitude=null, OtherGeocodeAccuracy=null, 
        MailingStreet=null, MailingCity=null, MailingState=null, MailingPostalCode=null, MailingCountry=null, MailingLatitude=null, 
        MailingLongitude=null, MailingGeocodeAccuracy=null, Phone=null, Fax=null, MobilePhone=null, HomePhone=null, OtherPhone=null, 
        AssistantPhone=null, ReportsToId=null, Email=null, Title=GB1, Department=null, AssistantName=null, LeadSource=null, 
        Birthdate=null, Description=null, OwnerId=005N00000027hI1IAI, HasOptedOutOfEmail=false, HasOptedOutOfFax=false, 
        DoNotCall=false, CreatedDate=2016-02-18 07:55:46, CreatedById=005N00000027hI1IAI, LastModifiedDate=2016-02-19 07:15:51, 
        LastModifiedById=005N00000027hI1IAI, SystemModstamp=2016-02-19 07:15:51, LastActivityDate=null, LastCURequestDate=null, 
        LastCUUpdateDate=null, LastViewedDate=null, LastReferencedDate=null, EmailBouncedReason=null, EmailBouncedDate=null, 
        IsEmailBounced=false, PhotoUrl=null, Jigsaw=null, JigsawContactId=null, Active_Contact__c=false, Allergy_to_Food__c=null, 
        Birthdate__c=null, Business_Email__c=********************, CIS_ID__c=439081, Channel_to_Deliver__c=null, Character__c=false, 
        Collection__c=null, Contact_Firstname__c=null, Contact_Owner__c=Charnun Thaweethamwitthaya, Contact_Position__c=อื่นๆ โปรดระบุ, 
        Contact_Preference_Communication__c=null, Contact_Preference_Last_Modified_By__c=null, 
        Contact_Preference_Last_Modified_Date__c=null, Contact_Representative_Type__c=null, 
        Customer_Name__c=_IM1_https://172.30.132.137/encrypt/_IM2_ _IM3_, External_Id__c=999988483728, 
        Facebook_ID__c=null, Favorite_Food__c=null, Favourite_Brand__c=null, Favourite_Magazine__c=null, Favourite_Restaurant__c=null, 
        Favourite_Sport__c=null, Generation__c=null, Health_body_Life_Style__c=แบตมินตัน, Health_mind_Life_Style__c=ทำบุญไหว้พระ, 
        Instagram_ID__c=null, Interested_Event_General__c=null, Interested_Event_Investment__c=null, Interested__c=null, 
        Interesting_Story_Topic__c=null, Langauge_Spoken__c=null, Life_Style_Details__c=null, Life_Style__c=null, Line_ID__c=null, 
        Most_Interested_Topic__c=null, Nickname__c=Ben, Other_Info_about_Character__c=null, Other_Life_Style_Detail__c=null, 
        Personal_Email__c=*******************, Phone_Numbers__c=**********, Picture__c=null, Presentation_Skill__c=null, 
        Primary_Contact__c=false, Recreation_Life_Style__c=รับประทานอาหาร, Social_Network_Type__c=null, Travel_Life_Style__c=ทะเล}*/
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('updateCustomerPref');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();

        //for each attendee create a JSON object
        for(Contact contactPrefsObject:updateContactPrefSpilt){
    
            gen.writeStartObject();        
            gen.writeStringField('IP_ID', toValue(contactPrefsObject.CIS_ID__c));
            gen.writeStringField('CTC_PSN_ID',toValue(contactPrefsObject.ID));
            gen.writeStringField('TH_TTL',toValue(contactPrefsObject.Salutation));
            gen.writeStringField('TH_FRST_NM',toValue(contactPrefsObject.FirstName));

            gen.writeStringField('TH_SURNM', toValue(contactPrefsObject.LastName));
            gen.writeStringField('NCK', toValue(contactPrefsObject.Nickname__c));
            gen.writeStringField('POS',toValue(contactPrefsObject.Contact_Position__c));
            gen.writeStringField('PSN_EMAIL',toValue(contactPrefsObject.Personal_Email__c));
            gen.writeStringField('BSN_EMAIL',toValue(contactPrefsObject.Business_Email__c));
            gen.writeStringField('MBL_NO',toValue(contactPrefsObject.Phone_Numbers__c));

            gen.writeStringField('LINE_ID', toValue(contactPrefsObject.Line_ID__c));
            gen.writeStringField('FB_ID',toValue(contactPrefsObject.Facebook_ID__c));
            gen.writeStringField('IG_ID',toValue(contactPrefsObject.Instagram_ID__c));
            //gen.writeStringField('PRIM_CTC_F',toValue(contactPrefsObject.Primary_Contact__c));
            //gen.writeStringField('DOB',toValue(contactPrefsObject.Birthdate__c));
            gen.writeStringField('DOB',toValue(contactPrefsObject.Birthdate));
            gen.writeStringField('INT_IVSM_EV','');
            gen.writeStringField('OTHR_LS','');
            gen.writeStringField('CHAR','');
            gen.writeStringField('EFF_DT','');
            gen.writeStringField('END_DT','');

            //gen.writeStringField('CTC_RPRT_TP_CD', toValue(contactPrefsObject.Contact_Representative_Type__c));
            gen.writeStringField('PREF_CTC_MTH',toValue(contactPrefsObject.Contact_Preference_Communication__c));
            //gen.writeStringField('ACTV_F',toValue(contactPrefsObject.Active_Contact__c));

            gen.writeStringField('LS_TP_CD', toValue(contactPrefsObject.Life_Style__c));
            gen.writeStringField('LS_SUB_TP_CD',toValue(contactPrefsObject.Life_Style_Details__c));
            //gen.writeStringField('INT_GNL_EV',toValue(contactPrefsObject.Other_Life_Style_Detail__c));
            gen.writeStringField('SOC_PSN_F',toValue(contactPrefsObject.Character__c));
            gen.writeStringField('OTHR_CHAR_INFO',toValue(contactPrefsObject.Other_Info_about_Character__c));

            gen.writeStringField('CRT_DT',toValue(contactPrefsObject.CreatedDate));
            gen.writeStringField('CRT_USR',toValue(contactPrefsObject.CreatedById));
            gen.writeStringField('UDT_DT',toValue(Datetime.now()));
            gen.writeStringField('UDT_USR',toValue(contactPrefsObject.LastModifiedById));

            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static String convertProspectJSONGenerator(List<sObject> convertListSpilt, Boolean isLasted){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('convertProspect');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();
        if(convertListSpilt != null){
        //for each attendee create a JSON object
            for(sObject convertsObject:convertListSpilt){
                Date tempDate = Date.valueOf(convertsObject.get('Birthdate_Registration_Date__c'));
                String tempYear = String.valueOf(tempDate.year());
                if(String.valueOf(UserInfo.getLocale()) == 'th_TH'){
                    tempYear = String.valueOf(Integer.valueOf(tempDate.year())-543);
                }
                gen.writeStartObject();        
                gen.writeStringField('SFDC_ID', String.valueOf(convertsObject.get('Id')));
                gen.writeStringField('IDENT_NO', String.valueOf(convertsObject.get('Encrypt_Identification_No__c')));
                gen.writeStringField('BRTH_ESTB_DT', String.valueOf(tempYear)+'-'+String.valueOf('0'+String.valueOf(tempDate.month())).right(2)+'-'+String.valueOf('0'+String.valueOf(tempDate.day())).right(2));
                String customerType = String.valueOf(convertsObject.get('RecordTypeId')) == GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) ? 'I' : 'O';
                gen.writeStringField('CUSTOMER_TYPE', customerType);
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeFieldName('LASTED');
        gen.writeString(String.valueOf(isLasted));
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static String convertProspectWithCISJSONGenerator(List<sObject> convertListSpilt, Boolean isLasted){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('convertProspect');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();
        if(convertListSpilt != null){
            //for each attendee create a JSON object
            for(sObject convertsObject:convertListSpilt){
                gen.writeStartObject();        
                gen.writeStringField('SFDC_ID', String.valueOf(convertsObject.get('Id')));
                gen.writeStringField('IP_ID', String.valueOf(convertsObject.get('CIS__c')));
                String customerType = String.valueOf(convertsObject.get('RecordTypeId')) == GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) ? 'I' : 'O';
                gen.writeStringField('CUSTOMER_TYPE', customerType);
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeFieldName('LASTED');
        gen.writeString(String.valueOf(isLasted));
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static String toValue(String fieldValue) {
        return fieldValue != null ? fieldValue : '';
    }

    public static String toValue(Boolean fieldValue) {
        if(fieldValue != null) {
            return fieldValue ? 'Y' : 'N';
        }
        return '';
    }

    public static String toValue(Datetime fieldValue) {
        if(fieldValue != null){
            return fieldValue.format('YYYY-MM-dd');
        }
        else{
            return '';
        }      
    }

    public static String toValue(Date fieldValue) {
        if(fieldValue != null){
            DateTime tempDateTime = Datetime.newInstance(fieldValue.year(), fieldValue.month(), fieldValue.day());
            return toValue(tempDateTime);
        }
        else{
            return '';
        }      
    }
}