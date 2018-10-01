/**
 * @author chutiwat.s@beryl8.com
 * @14/09/2015 created date
 */
public class UsersStructureUpdateUsers {

    public String rcCode;
    public String ahRcCode;
    public String nhRcCode;

    public UsersStructureUpdateUsers(User_Structure__c userStructure, String currentTIER) {
        if (currentTIER == GlobalConstants.SME_RM) {
            rcCode = userStructure.RC_Code__c;
            ahRcCode = userStructure.AH_RC_Code__c;
            nhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentTIER == GlobalConstants.SME_TM) {
            rcCode = userStructure.RC_Code__c;
            ahRcCode = userStructure.AH_RC_Code__c;
            nhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentTIER == GlobalConstants.SME_AH) {
            rcCode = userStructure.RC_Code__c;
            ahRcCode = userStructure.RC_Code__c;
            nhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentTIER == GlobalConstants.SME_NH) {
            rcCode = userStructure.RC_Code__c;
            ahRcCode = null;
            nhRcCode = userStructure.RC_Code__c;
        }
    }

    // Sort Data to NH > AH > TM > RM
    public static Map<Id, User_Structure__c> sort(Map<Id, User_Structure__c> deltaUserStructureMap, Map<String, String> jobCodeMapByName) {
        Map<Id, User_Structure__c> sortUserStructureMap = new  Map<Id, User_Structure__c>();

        for (User_Structure__c eachUserStruc : deltaUserStructureMap.values()) {
            if (jobCodeMapByName.containsKey(eachUserStruc.Job_Code__c) && jobCodeMapByName.get(eachUserStruc.Job_Code__c) == GlobalConstants.SME_NH) {
                sortUserStructureMap.put(eachUserStruc.Id, eachUserStruc);
                deltaUserStructureMap.remove(eachUserStruc.Id);
            }
        }
        for (User_Structure__c eachUserStruc : deltaUserStructureMap.values()) {
            if (jobCodeMapByName.containsKey(eachUserStruc.Job_Code__c) && jobCodeMapByName.get(eachUserStruc.Job_Code__c) == GlobalConstants.SME_AH) {
                sortUserStructureMap.put(eachUserStruc.Id, eachUserStruc);                
                deltaUserStructureMap.remove(eachUserStruc.Id);
            }
        }
        for (User_Structure__c eachUserStruc : deltaUserStructureMap.values()) {
            if (jobCodeMapByName.containsKey(eachUserStruc.Job_Code__c) && jobCodeMapByName.get(eachUserStruc.Job_Code__c) == GlobalConstants.SME_TM) {
                sortUserStructureMap.put(eachUserStruc.Id, eachUserStruc);                
                deltaUserStructureMap.remove(eachUserStruc.Id);
            }
        }
        for (User_Structure__c eachUserStruc : deltaUserStructureMap.values()) {
            if (jobCodeMapByName.containsKey(eachUserStruc.Job_Code__c) && jobCodeMapByName.get(eachUserStruc.Job_Code__c) == GlobalConstants.SME_RM) {
                sortUserStructureMap.put(eachUserStruc.Id, eachUserStruc);                
                deltaUserStructureMap.remove(eachUserStruc.Id);
            }
        }
        sortUserStructureMap.putAll(deltaUserStructureMap);

        return sortUserStructureMap;
    }

    // Check License
    public static Integer getActiveUser() {
        Integer numberOfActiveUser = [SELECT count() FROM User WHERE Profile.UserLicense.Name = 'salesforce' AND IsActive = true];

        Decimal userCount = decimal.valueOf(numberOfActiveUser);

        return userCount.intValue();
    }

    //public static Integer getLicenseMaxUser() {
    //    Organization orgDetails = [SELECT Id FROM Organization LIMIT 1];
    //    Id orgId = orgDetails.Id;
    //    String result;

    //    PageReference pr = new PageReference('/'+orgId);
    //    String rawData;

    //    if (Test.IsRunningTest()) rawData=Blob.valueOf('UNIT.TEST').toString();
    //    else rawData = pr.getContent().toString();

    //    String licRow = '>Salesforce</th><td class=" dataCell  ">Active</td><td class=" dataCell  numericalColumn">';
    //    Integer licLen = licRow.length();
    //    Integer pos = rawData.indexOf(licRow);

    //    if (-1!=pos){
    //        Integer licStart = pos + licLen;
    //        result = rawData.substring(licStart, licStart + 3);
    //    }

    //    Decimal lic = (!Test.IsRunningTest())?Decimal.valueOf(result):0;

    //    return lic.intValue();
    //}

    public static Integer getLicenseMaxUser() {
        UserLicense userLicenseObj = [SELECT LicenseDefinitionKey,TotalLicenses,UsedLicenses FROM UserLicense WHERE LicenseDefinitionKey='SFDC' LIMIT 1];
        return userLicenseObj.TotalLicenses;
    }

}