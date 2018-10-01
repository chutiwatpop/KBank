/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Restful API to send result status and error exception back to SFDC

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/30/2015  Charnun.T       First Create
------------------------------------------------------------*/
@RestResource(urlMapping='/ReturnResults/*')
global class SME_RestReturnResultsWebservice 
{   
    @HttpPost
    global static void doReturnResults(RestResponseModel.convertProspectResponse_model jsonResponse)
    {
        System.debug('jsonResponse::'+jsonResponse);
        List<Account> updateAccout = new List<Account>();
        List<RestResponseModel.accountInformation_model> returnResultConvertInfo = jsonResponse.returnResults;
        for(RestResponseModel.accountInformation_model each : returnResultConvertInfo){
            try{
            	Account eachAccount = new Account(Id=Id.valueOf(each.sfdc_id));
    	        if(each.success == 'TRUE'){
    	        	eachAccount.IsConverted__c = true;
    	        	eachAccount.Convert_Prospect_Date__c = System.today();
            	}else{
            		eachAccount.Convert_Prospect_Date__c = System.today();
            	}
            	updateAccout.add(eachAccount);
            }catch(Exception e){
                System.debug('updateConvertProspect with Error :' + e);
            }
        }
        System.debug('updateAccout::'+updateAccout);
        update updateAccout;
    }
}