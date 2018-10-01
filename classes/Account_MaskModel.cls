/**
* @author komsan.wi@beryl8.com
* @12/07/2015 createddate
* @12/10/2017 INC000000796035 delete opportunity share
*/
public class Account_MaskModel {
    public Account accObj;
    public User ownerUser;
    public Id temporaryNewOwnerUserId;
    public Id temporaryPreviousOwnerUserId;
    public User previousOwnerUser;
    public Id previousOwnerId{
        get{
            return accObj.OwnerId;
        }
    }
    public Boolean ownerInActive{
        get{
            return !ownerUser.IsActive;
        }
    }
    public Boolean managerOfOwnerActive{
        get{
            return ownerUser.ManagerId!=null && ownerUser.Manager.IsActive;
        }
    }
    public Boolean managerOfManagerOfOwnerActive{
        get{
            return ownerUser.ManagerId!=null && ownerUser.Manager.ManagerId!=null && ownerUser.Manager.Manager.IsActive;
        }
    }
    public Boolean isPoolAccount{
        get{
            return accObj.Port_Pool__c == GlobalConstants.POOL;
        }
    }
    public Boolean isPortAccount{
        get{
            return accObj.Port_Pool__c == GlobalConstants.PORT;
        }
    }
    //INC000000796035
    public Boolean haveToDeletedSharingRule{
        get{
            return 
                Account_Util.isProfile(GlobalConstants.SME_RM,ownerUser) || Account_Util.isProfile(GlobalConstants.SME_TM,ownerUser) ||
                Account_Util.isProfile(GlobalConstants.SME_NH,ownerUser) || Account_Util.isProfile(GlobalConstants.SME_AH,ownerUser) || 

                Account_Util.isProfile(GlobalConstants.CBS_RM,ownerUser) || Account_Util.isProfile(GlobalConstants.CBS_TM,ownerUser) ||
                Account_Util.isProfile(GlobalConstants.CBS_TL,ownerUser) ||

                Account_Util.isProfile(GlobalConstants.AN_RM,ownerUser)  || Account_Util.isProfile(GlobalConstants.AN_TM,ownerUser)  ||
                Account_Util.isProfile(GlobalConstants.AN_AH,ownerUser)  || Account_Util.isProfile(GlobalConstants.AN_NH,ownerUser);
        }
    }
    public Boolean profileIsNHAndAH{
        get{
            return ownerUser.ProfileId!=null && (ownerUser.Profile.Name==GlobalConstants.SME_NH || ownerUser.Profile.Name==GlobalConstants.SME_AH);
        }
    }
    public Boolean haveToDeletedManualSharing{
        get{
            return profileIsNHAndAH;
        }
    }
    public Boolean haveToUpdateRelatedObject{
        get{
            return accObj.Port_Pool__c == null || accObj.Port_Pool__c == GlobalConstants.PORT || accObj.Port_Pool__c == GlobalConstants.POOL || Account_Util.isProfile(GlobalConstants.SME_ADMIN,ownerUser) || Account_Util.isProfile(GlobalConstants.SME_ADMIN,previousOwnerUser);
        }
    }
    public Boolean haveReleaseFlag {
        get{
            return accObj.Customer_Owner_Release_Flag__c;
        }
    }
    // Add for (CBS-Ongoing) 18/01/17
    public Boolean isCBSCustomer{
        get{
            return GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accObj.Primary_Segment_Code__c) ;
        }
    }
    public Account_MaskModel(Account accObj){
        this.accObj = accObj;
    }
    public Account_MaskModel setOwner(User ownerUser){
        this.ownerUser = ownerUser;
        return this;
    }
    public Account_MaskModel setPreviousOwner(User previousOwnerUser){
        this.previousOwnerUser = previousOwnerUser;
        return this;
    }
}