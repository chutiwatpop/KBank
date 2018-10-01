public with sharing class HouseHoldManager {
    private static HouseHoldManager instance = null;
    private List<String> houseHoldCodeList;
    private Map<String, String> relationMaster;

    public HouseHoldManager() {
		houseHoldCodeList = new List<String>();
        relationMaster = new Map<String, String>();

        List<SLL_Relationship_Code__mdt> relationCodeList = [SELECT MasterLabel,SLL_Description__c,Is_Household__c FROM SLL_Relationship_Code__mdt ORDER BY MasterLabel];
        for (SLL_Relationship_Code__mdt relationCodeItem : relationCodeList) {
            relationMaster.put(relationCodeItem.MasterLabel, relationCodeItem.SLL_Description__c);
            if (relationCodeItem.Is_Household__c == true) {
                houseHoldCodeList.add(relationCodeItem.MasterLabel);
            }
        }
	}

	public Boolean isHouseHoldCode(String code) {
        return houseHoldCodeList.contains(code);
	}

    public String getRelationDescription(String relationCode) {
        return relationMaster.get(relationCode);
    }

    public Boolean hasExistRole(String roleCode){
        return relationMaster.containsKey(roleCode);
    }

    // a static method that returns the instance of the record type
    public static HouseHoldManager getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null) instance = new HouseHoldManager();
        return instance;
    }
}