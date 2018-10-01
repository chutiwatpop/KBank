/**
 * @author chutiwat.s@beryl8.com
 * @5/09/2015 created date
 * @28/01/2016 komsan.wi add group recursive
 */
public without sharing class UserRoleUtils {
    
    public List<User> userList {get;set;}
    private static UserRoleUtils instance = null;
    public static Map<Id, List<Id>> userRoleMapByParentId;
    public static Map<Id, List<User>> userMapByUserRoleParentId;
    public static Map<Id, Group> allGroupMap;
    public static Map<Id, User> allUserMap;
    public static Map<Id, List<Id>> groupMembersMapByGroup;
    public static Map<Id, List<Id>> userMapByRole;

    public static UserRoleUtils getInstance(){
        if(instance == null){ 
            instance = new UserRoleUtils();

            User currentUser = [SELECT Id, UserRoleId, UserRole.ParentRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            instance.userList = new List<User>{currentUser};
            instance.userList.addAll(UserRoleUtils.getAllSubRoleUsers(instance.userList));

        }
        return instance;
    }

    public static Map<Id, List<Id>> getUserRoleMapByParentId() {
        System.debug('getUserRoleMapByParentId');
        List<UserRole> userRoleList = [select Id, ParentRoleId FROM UserRole WHERE ParentRoleID != null limit 40000];
        Map<Id, List<Id>> userRoleMapByParent = new Map<Id, List<Id>>();
        if(userRoleList.size() > 0) {
            for(UserRole eachRole : userRoleList) {
                if(userRoleMapByParent.containsKey(eachRole.ParentRoleId)) {
                    userRoleMapByParent.get(eachRole.ParentRoleId).add(eachRole.Id);
                } else {
                    userRoleMapByParent.put(eachRole.ParentRoleId, new List<Id>{eachRole.Id});
                }
            }
        }

        return userRoleMapByParent;
    }
    //
    public static Map<Id, List<User>> getAllUserMapByParentRole() {
        System.debug('getAllUserMapByParentRole');
        List<User> allUserList = [select Id, UserRoleId, UserRole.ParentRoleId FROM User WHERE Isactive = true LIMIT 40000];
        Map<Id, List<User>> allUserMapByParentRole = new Map<Id, List<User>>();
        for(User eachUser : allUserList) {
            if(eachUser.UserRole.ParentRoleId != null) {
                if(allUserMapByParentRole.containsKey(eachUser.UserRole.ParentRoleId)) {
                    allUserMapByParentRole.get(eachUser.UserRole.ParentRoleId).add(eachUser);
                } else {
                    allUserMapByParentRole.put(eachUser.UserRole.ParentRoleId, new List<User>{eachUser});
                }
            }   
        }
        return allUserMapByParentRole;
    }

    public static Map<Id, Group> getAllGroupMap() {
        System.debug('getAllGroupMap');
        return new Map<Id, Group>([Select Id, Type, RelatedId From Group LIMIT 40000]);
    }

    public static Map<Id, User> getAllUserMap() {
        return new Map<Id, User>([Select Id, IsActive From User LIMIT 40000]);
    }
    //
    public static Map<Id, List<Id>> getAllUserMapByRole() {
        System.debug('getAllUserMapByRole');
        List<User> allUserList = [select Id, UserRoleId FROM User WHERE Isactive = true LIMIT 40000];
        Map<Id, List<Id>> allUserMapByRole = new Map<Id, List<Id>>();
        for(User eachUser : allUserList) {
            if(allUserMapByRole.containsKey(eachUser.UserRoleId)) {
                allUserMapByRole.get(eachUser.UserRoleId).add(eachUser.Id);
            } else {
                allUserMapByRole.put(eachUser.UserRoleId, new List<Id>{eachUser.Id});
            }
        }
        return allUserMapByRole;
    }

    public static Map<Id, List<Id>> getAllGroupMemberMapByGroup() {
        System.debug('getAllGroupMemberMapByGroup');
        List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember LIMIT 40000];
        Map<Id, List<Id>> memberMapByGroup = new Map<Id, List<Id>>();
        for(GroupMember eachmember : groupMemberList) {
            if(memberMapByGroup.containsKey(eachmember.GroupId)) {
                memberMapByGroup.get(eachmember.GroupId).add(eachmember.UserOrGroupId);
            } else {
                memberMapByGroup.put(eachmember.GroupId, new List<Id>{eachmember.UserOrGroupId});
            }
        }
        return memberMapByGroup;
    }

    public static List<User> getAllSubRoleUsers(List<User> userList) {
        if(UserRoleUtils.userMapByUserRoleParentId == null) {
            UserRoleUtils.userMapByUserRoleParentId = UserRoleUtils.getAllUserMapByParentRole();
        }
        List<User> currentUsers = new List<User>();
        //Set<ID> currentRoleIds = new Set<ID>();
        
        // get all of the roles underneath the passed roles
        for (User eachUser : userList) {
            if(eachUser.UserRoleId != null) {
                //currentRoleIds.add(eachUser.UserRoleId);
                if(UserRoleUtils.userMapByUserRoleParentId.containsKey(eachUser.UserRoleId))
                    currentUsers.addAll(UserRoleUtils.userMapByUserRoleParentId.get(eachUser.UserRoleId));
            }
        }

        // get all of the roles underneath the passed roles
        //for(User eachUser :[SELECT Id, Name, UserRoleId, UserRole.ParentRoleId FROM User 
        //    WHERE UserRole.ParentRoleId IN :currentRoleIds AND UserRole.ParentRoleId != null]) {
        //    currentUsers.add(eachUser);
        //}

        // go fetch some more rolls!
        if(currentUsers.size() > 0) {
            currentUsers.addAll(getAllSubRoleUsers(currentUsers));
        }

        return currentUsers;
    }
     public static Set<id> GetUserIdsFromGroup(Set<Id> userOrGroupIds)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        for(Id m : userOrGroupIds)
        {
            // If the user or group id is a user
            if(((String)m).startsWith(userType))
            {
                result.add(m);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(m);
                
            }
        }
        if(groupIdProxys.size() > 0)
        {    
            Set<id> groupId = new set<id>();
            Set<id> roleId = new set<id>();
            Set<id> roleAndSubId = new set<Id>();
            Set<id> subGroupId = new set<Id>();

            if(UserRoleUtils.allGroupMap == null) {
                UserRoleUtils.allGroupMap = UserRoleUtils.getAllGroupMap();
            }
            Group g2;
            for(Id eachGroupId : groupIdProxys){
                g2 = UserRoleUtils.allGroupMap.get(eachGroupId);
                if(g2.Type == 'Role'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'RoleAndSubordinates'){
                    roleAndSubId.add(g2.relatedId);    
                }
                else if(g2.Type== 'PRMOrganization'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'Regular'){
                    groupId.add(g2.id);    
                }
            }
            if(roleAndSubId.size()>0){
                roleId.addAll(getAllSubRoleIds(roleAndSubId));
            }
            if(roleId.size()>0){
                if(UserRoleUtils.userMapByRole == null) {
                    UserRoleUtils.userMapByRole = UserRoleUtils.getAllUserMapByRole();
                }
                for(Id eachUserRoleId : roleId) {
                    if(UserRoleUtils.userMapByRole.containsKey(eachUserRoleId)) {
                        result.addAll(UserRoleUtils.userMapByRole.get(eachUserRoleId));
                    }
                }
                //for(User u: [select id from user where UserRoleId IN: roleId]){
                //    result.add(u.id);
                //}
            }
            if(groupId.size()>0){
                result.addAll(getAllGroupIds(groupId));
            }
        }
        if(result.size() > 0) {
            if(UserRoleUtils.allUserMap == null) {
                UserRoleUtils.allUserMap = UserRoleUtils.getAllUserMap();
            }
            User eachuser;
            for(Id eachId : result) {
                if(UserRoleUtils.allUserMap.containsKey(eachId)) {
                    eachuser = UserRoleUtils.allUserMap.get(eachId);
                    if(eachuser.Isactive == false)
                        result.remove(eachId);
                }
            }
        }
        return result;  
    }
    public static Set<ID> getAllGroupIds(Set<ID> groupIdSet) {
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<ID> userIds = new Set<ID>();
        Set<id> groupIds = new set<Id>();

        if(UserRoleUtils.groupMembersMapByGroup == null) {
            UserRoleUtils.groupMembersMapByGroup = UserRoleUtils.getAllGroupMemberMapByGroup();
        } 
        List<Id> groupMembers;
        for(Id eachGroupId : groupIdSet) {
            if(UserRoleUtils.groupMembersMapByGroup.containsKey(eachGroupId)) {
                groupMembers = UserRoleUtils.groupMembersMapByGroup.get(eachGroupId);
                for(Id eachGroupMemberID : groupMembers) {
                    if(((String)eachGroupMemberID).startsWith(groupType)) 
                        groupIds.addAll(groupMembers);
                    else 
                        userIds.addAll(groupMembers);
                }
            }
        }

        //for(GroupMember gm : [select id, UserOrGroupId from GroupMember where GroupId IN: groupIdSet]){
        //    if(((String)gm.UserOrGroupId).startsWith(groupType)) groupIds.add(gm.UserOrGroupId);
        //    else userIds.add(gm.UserOrGroupId);
        //}

        if(groupIds.size() > 0)
            userIds.addAll(GetUserIdsFromGroup(groupIds));
        return userIds;
    }
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    
        Set<ID> currentRoleIds = new Set<ID>();
    
        if(UserRoleUtils.userRoleMapByParentId == null) {
            UserRoleUtils.userRoleMapByParentId = UserRoleUtils.getUserRoleMapByParentId();
        }

        List<UserRole> filteredUserRoleList = new List<UserRole>();
        for(ID eachRoleId : roleIds) {
            if(UserRoleUtils.userRoleMapByParentId.containsKey(eachRoleId)) {
                currentRoleIds.addAll(UserRoleUtils.userRoleMapByParentId.get(eachRoleId));
            }
        }

        //// get all of the roles underneath the passed roles
        //for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null limit 40000])
        //    currentRoleIds.add(userRole.Id);
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;
    
    }
}