global class FinancialInformation_Remote {

    global FinancialInformation_Remote(ApexPages.StandardController stdController) { 

    }

    @RemoteAction
    global static Map<String, String> retrieveInteractionHistory(String cis) {
        Map<String, String> dataMap;
        InteractionHistory_Model interactionHistoryData;
        interactionHistoryData = new InteractionHistory_Model(cis);
        dataMap = interactionHistoryData.getDataMap();
        return dataMap;
    }
}