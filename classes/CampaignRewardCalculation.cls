// CR040 Refactor all logic
public class CampaignRewardCalculation {
    public static void insertTargetList(Map<String, Set<String>> completeOppIdsMapBySegment, String RECORDTYPE_TARGETLIST_STANDARD) {
        Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
        String conditionCampaignSE = campaignSetting.New_Booking_Condition_SE__c;
        String conditionCampaignME = campaignSetting.New_Booking_Condition_ME__c;
        String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        Campaign campaignNewBooking;
        System.debug('CampaignRewardCalculation insertTargetList');
        System.debug(campaignSetting.Error_Message__c);
        List<String> completedOppSE = new List<String>();
        List<String> completedOppME = new List<String>();
        if(completeOppIdsMapBySegment.containsKey('SE')) completedOppSE = new List<String>(completeOppIdsMapBySegment.get('SE'));
        if(completeOppIdsMapBySegment.containsKey('ME')) completedOppME = new List<String>(completeOppIdsMapBySegment.get('ME'));

        List<Target_List__c> insertTargetLists = new List<Target_List__c>();
        List<Campaign_Expression__c> expressionList = [SELECT Id, Name, Field__c, Field_Type__c, Object__c, Operator__c, Segment__c, Value__c FROM Campaign_Expression__c];

        try {
            campaignNewBooking = [Select Id, EndDate FROM Campaign WHERE Status = :GlobalConstants.ACTIVE AND Lead_Campaign_Event_Code__c = :campaignNewBookingCode LIMIT 1];
        } catch (Exception e) {
            return;
        }
        String queryStringSE;
        String queryStringME;
    
        if(conditionCampaignSE != null && completedOppSE.size() >  0) {
            String conditionReplaced = getConditionQueryString(conditionCampaignSE, expressionList, 'SE');
            if(conditionReplaced != null){
                queryStringSE = 'SELECT Id, OppName__r.AccountId, Approved_Amount__c, Setup_Amount__c  FROM Application_History__c WHERE Id IN (\'' + String.join(completedOppSE,'\',\'') + '\') AND '+'('+ conditionReplaced +')';     
            }
        }
        if(conditionCampaignME != null && completedOppME.size() > 0) {
            String conditionReplaced = getConditionQueryString(conditionCampaignME, expressionList, 'ME');
            if(conditionReplaced != null){
                queryStringME = 'SELECT Id, OppName__r.AccountId, Approved_Amount__c, Setup_Amount__c  FROM Application_History__c WHERE Id IN (\'' + String.join(completedOppME,'\',\'') + '\') AND '+'('+ conditionReplaced +')';        
            }
        }
        System.debug('queryStringSE :'+queryStringSE);
        System.debug('queryStringME :'+queryStringME);
        List<Application_History__c> appHistoryList = new List<Application_History__c>();
        try {
            if(!String.isEmpty(queryStringSE)){
                appHistoryList.addAll((List<Application_History__c>) Database.query(queryStringSE));
            }
            if(!String.isEmpty(queryStringME)){
                appHistoryList.addAll((List<Application_History__c>) Database.query(queryStringME));
            }            
        } catch (Exception e) {

            Trigger.new[0].addError(campaignSetting.Error_Message__c);
        }
        for(Application_History__c eachApplication : appHistoryList) {
            System.debug('eachApplication Id :'+eachApplication.Id);
            insertTargetLists.add(ApplicationHistory_Service.createNewBookingLead(campaignNewBooking, eachApplication, RECORDTYPE_TARGETLIST_STANDARD));
        }
        if(!insertTargetLists.isEmpty()) insert insertTargetLists;
    }

    public static String getConditionQueryString(String formulaCondition, List<Campaign_Expression__c> expressionList, String segment) {
        String regExp = '[0-9]{1,}';
        String fomattedFormula = formulaCondition.replaceAll(regExp, '\"$0\"');

        for(Campaign_Expression__c eachExpression : expressionList) {
            String[] nameSplit = eachExpression.Name.split('_', 2);
            String expression = eachExpression.Field__c + eachExpression.Operator__c;
            if(eachExpression.Field_Type__c != null && eachExpression.Field_Type__c.equalsIgnoreCase('Number') 
                || eachExpression.Field_Type__c.equalsIgnoreCase('Currency') 
                || eachExpression.Field_Type__c.equalsIgnoreCase('Double') 
                || eachExpression.Field_Type__c.equalsIgnoreCase('Percent')
                || eachExpression.Field_Type__c.equalsIgnoreCase('Boolean')) {
                expression = expression + eachExpression.Value__c;
            } else {
                expression = expression + '\'' + eachExpression.Value__c + '\'';
            }
            if(nameSplit[0] != null && nameSplit[0] == segment) {
                fomattedFormula = fomattedFormula.replace('\"'+nameSplit[1]+'\"', expression);
            }
        }
        return fomattedFormula;
    }

    public static Boolean validateQueryString(String queryObject, String queryCondition) {
        String queryStr ='SELECT Id FROM ' + queryObject + ' WHERE ' + queryCondition + ' LIMIT 1';
        try {
            Database.query(queryStr);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public class CampaignRewardCalculationException extends Exception {}
}