/**
 * @author chutiwat.s@beryl8.com
 * @15/09/2015 created date
 */
public class YearEndAssignmentTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        //Owner = Query ID from User where Employee_ID__c = Owner_Employee_ID__c
        List<String> userEmpId = new List<String>();
        Map<String, Id> userMapByEmpId = new Map<String, Id>();

        for(Year_End_Assignment__c eachYearEnd : (List<Year_End_Assignment__c>) Trigger.new){
            if(eachYearEnd.Owner_Employee_ID__c!=null) userEmpId.add(eachYearEnd.Owner_Employee_ID__c);
        }
        List<User> userList = new List<User>();
        userList = [SELECT Id, Employee_ID__c FROM User WHERE Employee_ID__c IN :userEmpId];
        if (userList!=null && userList.size() > 0) {
            for (User eachUser : userList) {
               userMapByEmpId.put(eachUser.Employee_ID__c, eachUser.Id);
            }
        }

        if (userMapByEmpId.size() > 0) {
            for (Year_End_Assignment__c eachYearEndAssignment : (List<Year_End_Assignment__c>) Trigger.new) {
                if (eachYearEndAssignment.Owner_Employee_ID__c!=null && userMapByEmpId!=null && userMapByEmpId.containsKey(eachYearEndAssignment.Owner_Employee_ID__c)) {
                    eachYearEndAssignment.OwnerId = userMapByEmpId.get(eachYearEndAssignment.Owner_Employee_ID__c);
                }else{
                    System.debug('Not Found Owner_Employee_ID__c : ' +eachYearEndAssignment.Owner_Employee_ID__c);
                }
            }
        }
        
    }
}