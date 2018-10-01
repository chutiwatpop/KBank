public with sharing class OpportunityOverrideController {
    public class ResultResponse{
        public String result;
        public String message;
        public Account account;
        public ResultResponse() {
            result = 'SUCCESS';
        }
    }

	@AuraEnabled
    public static String getAccountInformation(String CustomerId){
        ResultResponse resp = new ResultResponse();
        try {
            Account cus = [SELECT Id,Name,Customer_s_Business_Code__c from Account where Id=:CustomerId];
            System.debug('DataCustomer : '+cus);
            resp.account = cus;
        } catch (Exception e) {
            resp.result = 'ERROR';
            resp.message = e.getMessage();
        }
        return JSON.serialize(resp);
    }
}