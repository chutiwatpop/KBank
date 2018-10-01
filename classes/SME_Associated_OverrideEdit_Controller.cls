/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
public without sharing class SME_Associated_OverrideEdit_Controller {

    public SME_Associated_OverrideEdit_Controller(ApexPages.StandardController stdController) {
    }

    public PageReference redirectToNewCallReportPage() {
        CallPlanCallReportField__c callPlanCallReportField = CallPlanCallReportField__c.getOrgDefaults();
        PageReference pageRef;
        
        String callReportIdString = ApexPages.currentPage().getParameters().get('callReportId');
        String callReportCISIDString = '';
        String callReportActualVisitDateString = ApexPages.currentPage().getParameters().get('callReportActualVisitDate');

        Associated_Customer__c getAssociatedDetails = new Associated_Customer__c();
        
        try{
            // Get data from call report
            getAssociatedDetails = [SELECT Id, Borrower_Type__c, Call_Plan_Call_Report__c, Call_Plan_Call_Report__r.Name, Customer__r.Name, Customer__c FROM Associated_Customer__c where Call_Plan_Call_Report__c =:callReportIdString ORDER BY CreatedDate DESC limit 1];
            // Add more feature to create duplicate call reports without plan on this scenario
            System.debug('getAssociatedDetails:'+ getAssociatedDetails);
            if(getAssociatedDetails.Borrower_Type__c == 'Main Borrower'){
                // Main borrower Pass value to create new call report
                System.debug('In Main:');
                callReportCISIDString = getAssociatedDetails.Customer__r.Name;
                pageRef = new PageReference('/'+CallPlanCallReportField.CallReportObjectId__c+'/e?');//+'apex/CallReport_OverrideEdit?accountId=/'+getAssociatedDetails.Customer__c);//callPlanCallReportField.CallReportObjectId__c+'/e?');
                pageRef.getParameters().put(callPlanCallReportField.OfferInterestFieldId__c, 'Interest and can apply');
                pageRef.getParameters().put(callPlanCallReportField.ContactChannelFieldId__c, 'Face to Face');
                pageRef.getParameters().put(callPlanCallReportField.CISFieldId__c, callReportCISIDString);
                pageRef.getParameters().put(callPlanCallReportField.ActualVisitDateFieldId__c, callReportActualVisitDateString);
                pageRef.getParameters().put(callPlanCallReportField.OfferCreditProductFieldId__c, '1');
                //pageRef.getParameters().put(callPlanCallReportField.PrimaryCallPlanCallReportFieldId__c,getAssociatedDetails.Call_Plan_Call_Report__r.Name);
                //pageRef.getParameters().put(callPlanCallReportField.PrimaryCallReportFieldId__c,'0');

                pageRef.getParameters().put('RecordType', callPlanCallReportField.SecondaryCallReportRecordTypeId__c);
                pageRef.getParameters().put('ent', callPlanCallReportField.Entity_Id__c);
                pageRef.getParameters().put('nooverride', '1');
                pageRef.getParameters().put('saveURL','/apex/CallReport_OverrideEdit?accountId='+getAssociatedDetails.Customer__c+'&primaryFlag=0&primaryCallReportId='+getAssociatedDetails.Call_Plan_Call_Report__c+'&associatedId='+getAssociatedDetails.Id);
                pageRef.setRedirect(true);
                return pageRef;
            }else{
                // Co borrower
                System.debug('In Co:'+callReportIdString);
                pageRef = new PageReference('/'+callReportIdString);
                pageRef.getParameters().put('nooverride', '1');
                pageRef.setRedirect(true);
                return pageRef;
            }
        }catch(Exception e){
            System.debug('Exception:'+callReportIdString+e);
        }
        System.debug('In Co:'+callReportIdString);
        pageRef = new PageReference('/'+callReportIdString);
        pageRef.getParameters().put('nooverride', '1');
        pageRef.setRedirect(true);
        return pageRef;
    }
}