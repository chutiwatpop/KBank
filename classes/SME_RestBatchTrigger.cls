/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Restful API to send result status and error exception back to SFDC

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/30/2015  Charnun.T           First Create
13/09/2015  Anan.B              Edit for Enlite Request Triiger From CI
------------------------------------------------------------*/
@RestResource(urlMapping='/BatchTrigger/*')
global class SME_RestBatchTrigger 
{   
    @HttpPost
    global static void doBatchTrigger(RestResponseModel.batchTrigger_model jsonResponse)
    {
        System.debug('jsonResponse::'+jsonResponse);
        if(jsonResponse.batch_Name == 'HRIS'){
            Database.executeBatch(new UserStructure_Batch());
            Database.executeBatch(new FlagInactiveUser_Batch());
        }else if(jsonResponse.batch_Name == 'ConvertProspect'){
            Database.executeBatch(new SME_ConvertProspect_Batch());
        }else if(jsonResponse.batch_Name == 'ConvertProspectWithCIS'){
            //Database.executeBatch(new SME_ConvertProspectWithCIS_Batch());
        }else if(jsonResponse.batch_Name == SME_PurgeEnliteBatch_Controller.FNCRTO){
            SME_PurgeEnliteBatch_Controller batch = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.FNCRTO);
            batch.executeBatch();
        }else if(jsonResponse.batch_Name == SME_PurgeEnliteBatch_Controller.BALSHEET){
            SME_PurgeEnliteBatch_Controller batch = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.BALSHEET);
            batch.executeBatch();
        }else if(jsonResponse.batch_Name == SME_PurgeEnliteBatch_Controller.INCSTM){
            SME_PurgeEnliteBatch_Controller batch = new SME_PurgeEnliteBatch_Controller(SME_PurgeEnliteBatch_Controller.INCSTM);
            batch.executeBatch();
        }else if(jsonResponse.batch_Name == 'SME_UpdateAccountNationality_Batch'){
            Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Corp_Link_Enlite__c',0));
        }else if(jsonResponse.batch_Name == 'CreateLeadMLP_Batch'){
            Database.executeBatch(new CreateLeadMLP_Batch());
        }
    }
}