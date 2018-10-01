/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
public without sharing class AssociatedCustomerTriggerHandler extends TriggerHandler{
	public override void afterInsert() {
        List<Associated_Customer__c> associatedCustomerList = Trigger.new;


        if(associatedCustomerList.size() == 1){
            Account accountToUpdateTrashPool = [SELECT Id, CIS__c, Trash_Pool_Flag__c FROM Account WHERE Id =: associatedCustomerList.get(0).Customer__c];
            accountToUpdateTrashPool.Trash_Pool_Flag__c = false;
            update accountToUpdateTrashPool;
            // Get data from call report
            Call_Report__c newCallReport;
            Call_Report__c getCallReportDetails = [SELECT Industry_Risk_Rating__c,Ratio__c,Industry_Room_Left__c,Keyword__c,Description__c,Estimate_Credit_Model__c,Risky_Control__c,Exception__c,Business_Code_Text__c,Actual_Visit_Date__c,Id FROM Call_Report__c where Id =:associatedCustomerList.get(0).Call_Plan_Call_Report__c];
            if(associatedCustomerList.get(0).RecordTypeId == GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Interested')){
            	// Add more feature to create duplicate call reports without plan on this scenario
            	if(associatedCustomerList.get(0).Borrower_Type__c == 'Co Borrower'){
            		// Co borrower
                    newCallReport = new Call_Report__c();
                    newCallReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
                    newCallReport.Contact_Channel__c = 'Face to Face';
                    newCallReport.CIS_ID__c = associatedCustomerList.get(0).Customer__c;
                    newCallReport.Actual_Visit_Date__c = getCallReportDetails.Actual_Visit_Date__c;
                    newCallReport.Offer_Credit_Product__c = true;
                    newCallReport.Co_Borrower__c = true;
                    newCallReport.Status__c = 'Contacted';
                    newCallReport.Primary_Call_Report__c = false;
                    newCallReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c','Secondary_Call_Report_No_plan');
                    newCallReport.Primary_Call_Plan_Call_Report__c = getCallReportDetails.Id;
                    //industry data
                    newCallReport.Estimate_Credit_Model__c = getCallReportDetails.Estimate_Credit_Model__c;
                    newCallReport.Risky_Control__c = getCallReportDetails.Risky_Control__c;
                    newCallReport.Exception__c = getCallReportDetails.Exception__c;
                    newCallReport.Business_Code_Text__c = getCallReportDetails.Business_Code_Text__c;
                    newCallReport.Description__c = getCallReportDetails.Description__c;
                    newCallReport.Keyword__c = getCallReportDetails.Keyword__c;
                    newCallReport.Industry_Room_Left__c = getCallReportDetails.Industry_Room_Left__c;
                    newCallReport.Ratio__c = getCallReportDetails.Ratio__c;
                    newCallReport.Industry_Risk_Rating__c = getCallReportDetails.Industry_Risk_Rating__c;
          
                    try{
                        insert newCallReport;
                    }catch(Exception e){
                        System.debug('System Error when try to insert Second Call Plan/Call Report from Associated Customer');
                    }
            	}

            
            }else if(associatedCustomerList.get(0).RecordTypeId == GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Not_Interested')){
                newCallReport = new Call_Report__c();

                newCallReport.Offer_Interest__c = GlobalConstants.OFFER_NOT_INTEREST;
                newCallReport.Contact_Channel__c = 'Face to Face';
                newCallReport.CIS_ID__c = associatedCustomerList.get(0).Customer__c;
                newCallReport.Actual_Visit_Date__c = getCallReportDetails.Actual_Visit_Date__c;
                newCallReport.Offer_Credit_Product__c = true;
                newCallReport.Status__c = 'Contacted';
                newCallReport.Reason__c = '4.5 อื่น ๆ (โปรดระบุ)';
                newCallReport.Memo__c = 'Associated Customer ลูกค้าไม่สนใจ';
                newCallReport.Primary_Call_Report__c = false;
                newCallReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c','Secondary_Call_Report_No_plan');
                newCallReport.Primary_Call_Plan_Call_Report__c = getCallReportDetails.Id;

                try{
                    insert newCallReport;
                }catch(Exception e){
                    System.debug('System Error when try to insert Second Call Plan/Call Report from Associated Customer');
                }
            }
            if(newCallReport != null){
                // Add Second Call Report to Associated Customer
                Associated_Customer__c tempAssociated = new Associated_Customer__c(Id=associatedCustomerList.get(0).Id);
                tempAssociated.Secondary_Call_Plan_Call_Report__c = newCallReport.Id;
                try{
                    update tempAssociated;
                }catch(Exception e){
                    System.debug('System Error when try to update Second Call Plan/Call Report in Associated Customer');
                }
            }
        }
    }
}