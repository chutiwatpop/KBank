public class CheckDeleteCampaignController {
   private ApexPages.StandardController stdCtrl;

   public CheckDeleteCampaignController(ApexPages.Standardcontroller std)
   {
      stdCtrl = std;
   }

   public PageReference checkDelete()
   {
      Campaign campaign = (Campaign) stdctrl.getRecord();
      Campaign campaignWithInfo = [SELECT Id,IsActive,Status,Sharing__c,(SELECT Id FROM Campaign_Members_Leads__r) FROM Campaign WHERE Id = :campaign.Id LIMIT 1];
      if(campaignWithInfo.IsActive && campaignWithInfo.Status == GlobalConstants.ACTIVE && campaignWithInfo.Sharing__c == GlobalConstants.LEAD_SHARING && campaignWithInfo.Campaign_Members_Leads__r.size() > 0){
         return null;
      }else{
         delete campaign;
         return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
      }
   }
}