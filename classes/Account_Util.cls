/**
* @author komsan.wi@beryl8.com
* @14/07/2015 createddate
*/
public class Account_Util {
    public static Boolean isProfile(String profileName,User user){
        return user.ProfileId!=null && user.Profile.Name==profileName;
    }
    public static Boolean isProfile(String profileName,User_Extension__c user){
        return user.User__r.ProfileId!=null && user.User__r.Profile.Name==profileName;
    }
}