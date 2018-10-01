/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class SME_RestReturnResultsWebservice_Test {
    @isTest static void test_RestReturnResultConvertProspect_True() {
    	Account tempAccount = new Account();
		tempAccount.Name = '457397';
		tempAccount.Is_createby_Integration__c = true;
		insert tempAccount;

		RestResponseModel.convertProspectResponse_model convertProspect = new RestResponseModel.convertProspectResponse_model();
		RestResponseModel.accountInformation_model accountInfo = new RestResponseModel.accountInformation_model();
		List<RestResponseModel.accountInformation_model> accountInfoList = new List<RestResponseModel.accountInformation_model>();
		convertProspect.api_name = 'CI02_JDBC_Batch_ConvertProspect';
		convertProspect.ci_job_id = '1234';
		convertProspect.finish_dt = '';
		convertProspect.object_name = 'Account';
		convertProspect.retry_num = '1';
		convertProspect.start_dt = '';

		accountInfo.cis_id = String.valueOf(tempAccount.Name);
		accountInfo.sfdc_id = String.valueOf(tempAccount.Id);
		accountInfo.success = 'TRUE';

		accountInfoList.add(accountInfo);
		convertProspect.returnResults = accountInfoList;

		SME_RestReturnResultsWebservice.doReturnResults(convertProspect);
		System.debug('convertProspect'+convertProspect);

	}

	@isTest static void test_RestReturnResultConvertProspect_False() {
    	Account tempAccount = new Account();
		tempAccount.Name = '457397';
		tempAccount.Is_createby_Integration__c = true;
		insert tempAccount;

		RestResponseModel.convertProspectResponse_model convertProspect = new RestResponseModel.convertProspectResponse_model();
		RestResponseModel.accountInformation_model accountInfo = new RestResponseModel.accountInformation_model();
		List<RestResponseModel.accountInformation_model> accountInfoList = new List<RestResponseModel.accountInformation_model>();
		convertProspect.api_name = 'CI02_JDBC_Batch_ConvertProspect';
		convertProspect.ci_job_id = '1234';
		convertProspect.finish_dt = '';
		convertProspect.object_name = 'Account';
		convertProspect.retry_num = '1';
		convertProspect.start_dt = '';

		accountInfo.cis_id = String.valueOf(tempAccount.Name);
		accountInfo.sfdc_id = String.valueOf(tempAccount.Id);
		accountInfo.success = 'FALSE';

		accountInfoList.add(accountInfo);
		convertProspect.returnResults = accountInfoList;

		SME_RestReturnResultsWebservice.doReturnResults(convertProspect);
		System.debug('convertProspect'+convertProspect);

	}
}