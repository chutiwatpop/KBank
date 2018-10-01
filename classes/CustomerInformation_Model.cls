/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A model class for customer information
Test Class:    
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
06/23/2015  Sorravit.B          Add LPM
------------------------------------------------------------*/
public abstract class CustomerInformation_Model {
    
    public List<String> listFieldToQuery = new List<String>{
        'CIF__r.Id',
            'CIF__r.Salutation',
            'CIF__r.Customer_Name_Thai__c',
            'CIF__r.Customer_Name_English__c',
            'CIF__r.Identification_Number__c',
            'CIF__r.CIF_Prospect__c',
            'CIF__r.IsConverted__c',
            'CIF__r.FirstName',
            'CIF__r.LastName',
            'CIF__r.RecordType.DeveloperName',
            'CIF__r.RecordType.Name',
            'CIF__r.CIF__c',
            'CIF__r.Name',
            'CIF__r.Company_Name_Thai__c',
            'CIF__r.Company_Name_Thai_Encrypted__c',
            'CIF__r.Company_Name_English__c',
            'CIF__r.Company_Name_English_Encrypted__c',
            'CIF__r.Juristic_Id__c',
            'CIF__r.Juristic_ID_Encrypted__c',
            'CIF__r.Tax_ID__c',
            'CIF__r.Tax_ID_Encrypted__c',
            'CIF__r.First_Name_Thai_Encrypted__c',
            'CIF__r.Last_Name_Thai_Encrypted__c',
            'CIF__r.First_Name_English_Encrypted__c',
            'CIF__r.Last_Name_English_Encrypted__c',
            'CIF__r.Mobile_Number_Encrypted__c',
            'CIF__r.Mobile_Number__c',
            'CIF__r.Identification_Number_Encrypted__c'
            };
                
                protected Integer queryLIMIT = 100;
    public String individualCustomer {get;set;}
    public String newProspect {get;set;}
    public String newCorporate {get;set;}
    //    public Id prospectRecordTypeId = Id.valueOf('0');//Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Prospect').GetRecordTypeId();
    //    public Id corporateRecordTypeId = Id.valueOf('1');//Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Corporate Prospect').GetRecordTypeId();
    
    protected String queryOrder = 'CIF__r.LastName NULLS CIF__r.LAST,Last_Name_Th_Partial__c NULLS LAST';
    
    protected Long executeOverAllSearchTime{get; set;}
    protected Long executeQueryTime{get; set;}
    protected Long executeFilterTime{get; set;}
    
    public String likeFirstname = null;
    public String likeLastname = null;
    public String splitCIS = '';
    
    public Integer countFirstname = 0;
    public Integer countLastname = 0;
    
    public String cid10 = null;
    public String idenjuris10 = null;
    
    public String tax10 = null;
    
    public String error {get; set;}
    
    public String type{get; set;}
    public String id{get; set;}
    public String uid{get; set;}
    public String cis{get; set;}
    public String firstname{get; set;}
    public String lastname{get; set;}
    
    //individual variable
    public String individualCIS{get; set;}
    public String individualName{get; set;}
    public String individualJuristic{get; set;}
    public String individualTax{get; set;}
    
    //Add by big
    public String lpm{get; set;}
    
    /*public Util.ExceptionWrapper ex{get; set;}

public List<Customers_Model> newresult{get; set;}
public String json_result {get{
if(this.newresult==null)this.newresult=new List<Customers_Model>();
return JSON.serialize(this.newresult);
}}
*/
    protected String soql='';
    
    public Boolean checkingSwR(sObject obj,String field,String val){
        return obj!=null && 
            obj.get(field)!=null &&
            obj.get(field) == val;
    }
    public Boolean checkingS(sObject obj,String rel,String field,String val){ 
        return obj.getSObject(rel)!=null && 
            obj.getSObject(rel).get(field)!=null &&
            obj.getSObject(rel).get(field) == val;
    }
    public Boolean checkingB(sObject obj,String rel,String field,Boolean val){
        return obj.getSObject(rel)!=null && 
            obj.getSObject(rel).get(field)!=null &&
            obj.getSObject(rel).get(field) == val;
    }
}