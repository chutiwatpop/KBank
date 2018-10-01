// Created Date 01-06-2017
public without sharing class SME_FraudWarning_Controller {
	private final sObject mysObject;
    private String exitFraud;

    public Boolean isShowFraud {get;set;}
    public String colorCode {get;set;}
    public String fraudStatus;
    public String fraudMessage {get;set;}

    @TestVisible
    private Id accountId;
    private String redirectNewPage;

	public SME_FraudWarning_Controller() {
		this.accountId = ApexPages.currentPage().getParameters().get('existingId');
        String tempNewPage = ApexPages.currentPage().getParameters().get('redirectNewPage');
        if(tempNewPage != null) this.redirectNewPage = EncodingUtil.urlDecode(tempNewPage, 'UTF-8');
	}

	public PageReference init() {
        Account thisAccount =  [SELECT Id, CIS__c, Exit__c FROM Account WHERE Id = :accountId LIMIT 1];
        this.isShowFraud = false;
        try{
            calloutWebservice(thisAccount);
            fraudMessage = Label.FRAUD_ALERT;
            colorCode = Account_Service.calculateFraud(thisAccount.Exit__c, fraudStatus);
            if(colorCode == GlobalConstants.FRAUD_COLOR_BLUE) {
                return new PageReference(this.redirectNewPage);
            } else {
                this.isShowFraud = (colorCode != 'Other');    
            }
        }catch(CIWebserviceException e){
            fraudMessage = GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage());
        }catch(Exception e){
            fraudMessage = e.getMessage();
        }
        return null;
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

    public PageReference redirectNewPage() {
    	PageReference pageRef = new PageReference(this.redirectNewPage);
    	return pageRef;
    }
}