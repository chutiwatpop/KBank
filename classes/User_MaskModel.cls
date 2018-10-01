public without sharing class User_MaskModel {
	public Id userId;
	public User userObj;
	public User newUserObj;
	public User_Extension__c userEx;
	public Boolean isReCalculateOwnership {
		set;
		get {
			return isReCalculateOwnership == null ? false : isReCalculateOwnership;	
		}
	}
	public Boolean isChangeTeamHierachy {
		get {
			return (this.isChangeJobCode || this.isChangeRCCode || this.isChangeArea || this.isChangeNetwork);	
		}
	}
	public Boolean isChangeJobCode {
		get {
			return (this.newJobCode != this.previousJobCode);	
		}
	}
	public Boolean isChangeRCCode {
		get {
			return (this.newRCCode != this.previousRCCode);
		}
	}
	public Boolean isChangeArea {
		get {
			return (this.newAHRCCode != this.previousAHRCCode);	
		}
	}
	public Boolean isChangeNetwork {
		get {
			return (this.newNHRCCode != this.previousNHRCCode);	
		}
	}
	public String previousRCCode {
		get{
			return userObj.RC_Code__c;
		}
	}
	public String previousAHRCCode{
		get{
			return userObj.AH_RC_Code__c;
		}
	}
	public String previousNHRCCode{
		get{
			return userObj.NH_RC_Code__c;
		}
	}
	public String previousJobCode{
		get{
			return userObj.Job_Code__c;
		}
	}
	public String newRCCode{
		get{
			return newUserObj.RC_Code__c;
		}
	}
	public String newAHRCCode{
		get{
			return newUserObj.AH_RC_Code__c;
		}
	}
	public String newNHRCCode{
		get{
			return newUserObj.NH_RC_Code__c;
		}
	}
	public String newJobCode{
		get{
			return newUserObj.Job_Code__c;
		}
	}

	public Boolean isChangeToInactive {	
		get{ 
			return (newUserObj.IsActive == false) && userObj.IsActive; 
		}
	}
	public Boolean isChangeToActive {	
		get{ 
			return newUserObj.IsActive && (userObj.IsActive == false); 
		}
	}
	public Boolean isChangeSegment {	
		get{ 
			return newUserObj.Segment__c != userObj.Segment__c; 
		}
	}
	public Boolean isChangeName {	
		get{ 
			return newUserObj.FirstName != userObj.FirstName || newUserObj.LastName != userObj.LastName; 
		}
	}

	public String getProfileName() {
		if(this.profileName == null) {
			if(userObj.ProfileId != null) {
				Map<Id, Profile> profileMap = GlobalUtility.getProfileMap();

				if(profileMap.containsKey(userObj.ProfileId)) {
					this.profileName = profileMap.get(userObj.ProfileId).Name;
				}
			} else {
				if(User_Service.getJobCodeMapByName().containsKey(userObj.Job_Code__c)) {
					this.profileName = User_Service.getJobCodeMapByName().get(userObj.Job_Code__c).Profile_Name__c;
				}
			}
		}
		return this.profileName;
	}
	public String profileName;

	public Boolean isOldSMEProfile {get {return GlobalConstants.PROFILE_SME_SET.contains(getProfileName());}}
	public Boolean isOldCBSProfile {get {return GlobalConstants.PROFILE_CBS_SET.contains(getProfileName());}}
	public Boolean isOldRBSProfile {get {return GlobalConstants.PROFILE_RBS_SET.contains(getProfileName());}}
	public Boolean isOldAFProfile  {get {return GlobalConstants.PROFILE_AF_SET.contains(getProfileName());}}
	
	public User_MaskModel() {
	}

    public User getOldUser(){
        return this.userObj;
    }

    public User getNewUser(){
        return this.newUserObj;
    }

    public void setNewUser(User newUser){
        //this.newUserObj = newUser.clone(true, true, false, false);
        this.newUserObj = new User();
        this.newUserObj.FirstName		= newUser.FirstName;
        this.newUserObj.LastName		= newUser.LastName;
        this.newUserObj.Segment__c		= newUser.Segment__c;
        this.newUserObj.ProfileId 		= newUser.ProfileId;
        this.newUserObj.RC_Code__c 		= newUser.RC_Code__c;
		this.newUserObj.AH_RC_Code__c	= newUser.AH_RC_Code__c;
		this.newUserObj.NH_RC_Code__c	= newUser.NH_RC_Code__c;
		this.newUserObj.Job_Code__c 	= newUser.Job_Code__c;
		this.newUserObj.IsActive 		= newUser.IsActive;
		System.debug('setNewUser:' + this.newUserObj);
    }

    public void setOldUser(User oldUser){
        //this.userObj = oldUser.clone(true, true, false, false);
        this.userObj = new User();
        this.userObj.FirstName		= oldUser.FirstName;
        this.userObj.LastName		= oldUser.LastName;
        this.userObj.Segment__c		= oldUser.Segment__c;
        this.userObj.ProfileId 		= oldUser.ProfileId;
        this.userObj.RC_Code__c 	= oldUser.RC_Code__c;
		this.userObj.AH_RC_Code__c	= oldUser.AH_RC_Code__c;
		this.userObj.NH_RC_Code__c	= oldUser.NH_RC_Code__c;
		this.userObj.Job_Code__c 	= oldUser.Job_Code__c;
		this.userObj.IsActive 		= oldUser.IsActive;
		System.debug('setOldUser:' + this.userObj);
    }

    public void setNewUserField(User_Structure__c userStructure) {
    	if(this.newUserObj == null) {
    		this.newUserObj = new User();
    	}
		this.newUserObj.RC_Code__c 		= userStructure.RC_Code__c;
		this.newUserObj.AH_RC_Code__c	= userStructure.AH_RC_Code__c;
		this.newUserObj.NH_RC_Code__c	= userStructure.NH_RC_Code__c;
		this.newUserObj.Job_Code__c 	= userStructure.Job_Code__c;
		this.newUserObj.IsActive 		= userStructure.IsActive__c;
	}
	public void setOldUserField(User_Structure__c userStructure) {
		if(this.userObj == null) {
    		this.userObj = new User();
    	}
		this.userObj.RC_Code__c 	= userStructure.Previous_RC_Code__c;
		this.userObj.AH_RC_Code__c	= userStructure.Previous_AH_RC_Code__c;
		this.userObj.NH_RC_Code__c	= userStructure.Previous_NH_RC_Code__c;
		this.userObj.Job_Code__c 	= userStructure.Previous_Job_Code__c;
		this.userObj.IsActive 		= userStructure.Previous_IsActive__c;
	}
}