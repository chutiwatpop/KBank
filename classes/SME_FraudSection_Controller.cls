// Created Date 01-06-2017
public with sharing class SME_FraudSection_Controller {
	private final sObject mysObject;
    private String exitFraud;

    public Id accountId;
    public Boolean isShowFraud {get;set;}
    public String colorCode {get;set;}
    public String fraudStatus;
    public String fraudMessage {get;set;}

	public SME_FraudSection_Controller(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        accountId = (Id)this.mysObject.get('Id');
        fraudMessage = '';
    }

	public void init() {
        Account thisAccount =  [SELECT Id, CIS__c, Exit__c FROM Account WHERE Id = :accountId LIMIT 1];
        this.isShowFraud = false;
        try{
            calloutWebservice(thisAccount);
            fraudMessage = Label.FRAUD_ALERT;
            System.debug('Exit__c:' + thisAccount.Exit__c);
            colorCode = Account_Service.calculateFraud(thisAccount.Exit__c, fraudStatus);
            this.isShowFraud = (colorCode != 'Other');
        }catch(CIWebserviceException e){
            fraudMessage = GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage());
        }catch(Exception e){
            fraudMessage = e.getMessage();
        }
    }

    public void calloutWebservice(Account accountObj) {
        GetFraud_Webservice webserviceInstance = GetFraud_Webservice.getInstance();
        webserviceInstance.cisId = accountObj.CIS__c;
        GetFraud_Webservice.ResponseModel responseModel = webserviceInstance.calloutWebservice();
        // Handle Response
        List<GetFraud_Webservice.CustomerFraud> respCustomers = responseModel.customerModel;
        if(respCustomers != null && respCustomers.size() > 0 && respCustomers[0].IP_ID == accountObj.CIS__c) {
            fraudStatus = respCustomers[0].BLIST_TP_CD;
        } else {
            throw new CIWebserviceException('Customer color group cannot found');
        }
    }
}