public with sharing class Account_BusinessCodeInformation_CTRL {
    public static String SOURCE_TRANSACT = 'Transact';
    public static String SOURCE_CIS = 'CIS';

    private final sObject mysObject;
    private String cis;

    public Id accountId;
    public String customerBusinessCode {get; set;}

    public String sourceData {get;set;}
    public String description {get;set;}
    public String keyWord {get;set;}
    public String industryGroup {get;set;}
    public String industrySubGroup {get;set;}
    public String industryRoomleft {get;set;}
    public String riskyControl_FL {get;set;}
    public String riskyControl_HPL {get;set;}
    public String riskyControl_PL {get;set;}
    public String exception_FL {get;set;}
    public String exception_HPL {get;set;}
    public String exception_PL {get;set;}
    public String gradeIndustry {get;set;}
    public String credit_Incident {get;set;}
    public String subIndustryGroupDesc{get;set;}
    public String industryType {get;set;}

    //public String industryClassificationCode {get; set;}
    //public String businessCodeNameEN {get; set;}
    //public String businessCodeNameTH {get; set;}
    
    public Account_BusinessCodeInformation_CTRL(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        accountId = (Id)this.mysObject.get('Id');
    }

    public void init() {
        Account thisAccount =  [SELECT Id,Owner.Segment__c,CIS__c, Customer_s_Business_Code__c, Business_Code_Name_EN__c, Business_Code_Name_TH__c, Industry_Classification_Code__c FROM Account WHERE Id = :accountId LIMIT 1];
        cis = thisAccount.CIS__c;
        retreiveBusinessCodeRealTime();
        if(customerBusinessCode == null) {
            customerBusinessCode = thisAccount.Customer_s_Business_Code__c;
            sourceData = SOURCE_CIS;
        }
        if(customerBusinessCode != null){
            customerBusinessCode = Customer_BusinessCode_Service.fillPreFixBusinessCode(customerBusinessCode);
        }
        List<Business_Code__c> businessCodeObj = [SELECT Name,Business_Code_Description__c,Keyword__c,X26_Industries_Group__c,Sub_Industry_Group__c,Sub_Industry_Group_Description__c,Room_Left__c,Risky_Control_FL__c,Risky_Control_HPL__c,Risky_Control_PL__c,Exception_FL__c,Exception_PL__c,Exception_HPL__c,Industry_Risk_Rating__c,Credit_Incident__c,Industry_Type__c FROM Business_Code__c where Name = :customerBusinessCode AND Segment__c = :thisAccount.Owner.Segment__c LIMIT 1];
        if(businessCodeObj.size()>0){
            customerBusinessCode = businessCodeObj.get(0).Name;
            setBusinessCodeDataToDisplay(businessCodeObj[0]);  
        } 
        


        //if(businessCodeNameEN == null) businessCodeNameEN = thisAccount.Business_Code_Name_EN__c;
        //if(businessCodeNameTH == null){
        //    List<Business_Code__c> businessCodeObj = [SELECT Business_Code_Description__c,Keyword__c,X26_Industries_Group__c,Sub_Industry_Group__c,Sub_Industry_Group_Description__c,Room_Left__c,Risky_Control_FL__c,Risky_Control_HPL__c,Risky_Control_PL__c,Exception_FL__c,Exception_PL__c,Exception_HPL__c,Industry_Risk_Rating__c,Credit_Incident__c FROM Business_Code__c where Name= :customerBusinessCode AND Segment__c = :thisAccount.Owner.Segment__c LIMIT 1];
        //    if(businessCodeObj.size()>0){
        //        setBusinessCodeDataToDisplay(businessCodeObj[0]);
                
        //        //businessCodeNameTH = businessCodeObj[0].Business_Code_Description__c;    
        //    }            
        //}
        //if(industryClassificationCode == null) industryClassificationCode = thisAccount.Industry_Classification_Code__c; 
    }

    public void retreiveBusinessCodeRealTime() {
        try {
            SME_TransactBPResultResponse response = SME_CIRestWebservice.getTransactBPRequest(this.cis);
            if(response == null || response.returnResponse == null) return;
            if(response.returnResponse.transactBP.size() == 1) {
                SME_TransactBPResultResponse.transactBP_model transactBPModel = response.returnResponse.transactBP[0];
                customerBusinessCode = transactBPModel.BSN_CD;
                sourceData = SOURCE_TRANSACT;
                //businessCodeNameTH = transactBPModel.BSN_NM;
            }   
        } catch (Exception e) {
            GlobalUtility.logMessage(GlobalConstants.WARNING_LOG,'Account_BusinessCodeInformation_CTRL','retreiveBusinessCodeRealTime',null,null,'Retreive Business Code RealTime Error :'+e.getMessage(),null,null,null);
        }
    }


    public void setBusinessCodeDataToDisplay(Business_Code__c businessCode){
        description = businessCode.Business_Code_Description__c;
        keyWord = businessCode.Keyword__c;
        industryGroup = businessCode.X26_Industries_Group__c;
        industrySubGroup = businessCode.Sub_Industry_Group__c;
        industryRoomleft = businessCode.Room_Left__c;
        riskyControl_FL = businessCode.Risky_Control_FL__c;
        riskyControl_HPL = businessCode.Risky_Control_HPL__c;
        riskyControl_PL = businessCode.Risky_Control_PL__c;
        exception_FL = businessCode.Exception_FL__c;
        exception_HPL = businessCode.Exception_HPL__c;
        exception_PL = businessCode.Exception_PL__c;
        gradeIndustry = businessCode.Industry_Risk_Rating__c;
        credit_Incident = businessCode.Credit_Incident__c;
        subIndustryGroupDesc =businessCode.Sub_Industry_Group_Description__c;
        industryType = businessCode.Industry_Type__c;
    }
}