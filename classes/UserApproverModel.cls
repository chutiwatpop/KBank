public class UserApproverModel {
	public Id userId;
	public String profileName;
	public Boolean hasManager;
	public Boolean isActive;
	public UserApproverModel manager;

	public UserApproverModel(Id userId, String profileName, Boolean isActive, UserApproverModel manager) {
		this.userId 		= userId;
		this.profileName 	= profileName;
		this.isActive 		= isActive;
		
		if(manager == null || manager.userId == null) {
			this.manager = null;
			this.hasManager = false;
		} else {
			this.manager = manager;
			this.hasManager = true;
		}
	}

	public Id getApproverIdFromProfile(Set<String> profileSet) {
		if(profileSet.contains(profileName) && this.isActive) {
			return userId;
		} else if(hasManager) {
			return manager.getApproverIdFromProfile(profileSet);
		} else {
			return null;
		}
	}

	public static UserApproverModel getUserApproverHierachy(User currentUser) {
		UserApproverModel nhUser         = new UserApproverModel(currentUser.Manager.Manager.ManagerId, currentUser.Manager.Manager.Manager.Profile.Name, currentUser.Manager.Manager.Manager.IsActive, null);
        UserApproverModel ahUser         = new UserApproverModel(currentUser.Manager.ManagerId, currentUser.Manager.Manager.Profile.Name, currentUser.Manager.Manager.IsActive, nhUser);
        UserApproverModel tmUser         = new UserApproverModel(currentUser.ManagerId, currentUser.Manager.Profile.Name, currentUser.Manager.IsActive, ahUser);
        UserApproverModel userApprover   = new UserApproverModel(currentUser.Id, currentUser.Profile.Name, currentUser.IsActive, tmUser);
        return userApprover;
	}
}