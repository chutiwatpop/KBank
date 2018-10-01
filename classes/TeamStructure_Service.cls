public without sharing class TeamStructure_Service {
    public static Map<Id,Team_Structure__c> teamStructureMap;
    public static Map<String,Team_Structure__c> teamMapByRCCode;
    public static Map<String,Team_Structure__c> teamStructureMapByRCCode;

    public static List<User> getUserListFromProfile(Set<String> profileSet) {
        return [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Province__c, Profile.Name, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name FROM User WHERE Profile.Name IN :profileSet ORDER BY IsActive DESC, LastModifiedDate DESC];
    }

    public static List<User> getUserListFromProfile(Set<String> profileSet, String RCCode) {
        return [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Province__c, Profile.Name, Manager.Profile.Name, Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name FROM User WHERE Profile.Name IN :profileSet AND RC_Code__c = :RCCode ORDER BY Isactive DESC, LastModifiedDate DESC];
    }

    public static Map<Id,Team_Structure__c> getTeamStructureMap(){
        if(TeamStructure_Service.teamStructureMap == null) {
            TeamStructure_Service.teamStructureMap = new Map<Id, Team_Structure__c>([SELECT Id, RC_Code__c, OwnerId, Owner.IsActive, External_ID__c, Type__c, Name, Segment__c, AH_RC_Code__c, NH_RC_Code__c, AH_Name__c, NH_Name__c, Branch_Code__c, Branch_Name__c, RC_Short_Name__c, AH_Short_Name__c, NH_Short_Name__c FROM Team_Structure__c]);
        }
            
        return TeamStructure_Service.teamStructureMap;
    }

    public static Map<String,Team_Structure__c> getTeamStructureMapByRCCode(){
        if(TeamStructure_Service.teamStructureMapByRCCode == null){
            getTeamStructureMap();
            TeamStructure_Service.teamStructureMapByRCCode = new Map<String,Team_Structure__c>();
            for(Team_Structure__c eachTeam : TeamStructure_Service.teamStructureMap.values()){
                TeamStructure_Service.teamStructureMapByRCCode.put(eachTeam.RC_Code__c, eachTeam);
            }
        }
        return TeamStructure_Service.teamStructureMapByRCCode;
    }

    public static Map<String,Id> getAllTeamStructureMapByRCTeamId() {
        Map<String,Team_Structure__c> teamStructureMapTemp = TeamStructure_Service.getTeamStructureMapByRCCode();
        Map<String,Id> teamMapByRc = new Map<String,Id>();
        for(Team_Structure__c eachTeam : teamStructureMapTemp.values()) {
            if(eachTeam.RC_Code__c != null) {
                teamMapByRc.put(eachTeam.RC_Code__c, eachTeam.Id);
            } else if(eachTeam.External_ID__c != null) {
                teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
            }
        }
        return teamMapByRc;
    }

    public static Map<String,Team_Structure__c> getTeamStructureMapByRCCodeWithRC(Set<String> rcCodes) {
        List<Team_Structure__c> teamStructureList = [SELECT Id,RC_Code__c,OwnerId,Owner.IsActive,External_ID__c,Type__c,Name,Segment__c,NH_RC_Code__c FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
        Map<String,Team_Structure__c> teamStructureMapByRCCodeWithRC = new Map<String,Team_Structure__c>();
        for(Team_Structure__c eachTeam : teamStructureList) {
            if(eachTeam.RC_Code__c != null) {
                teamStructureMapByRCCodeWithRC.put(eachTeam.RC_Code__c, eachTeam);
            } else if(eachTeam.External_ID__c != null) {
                teamStructureMapByRCCodeWithRC.put(eachTeam.External_ID__c, eachTeam);
            }
        }
        return teamStructureMapByRCCodeWithRC;
    }

    public static void reassignOwner(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser, Map<Id, User> newUserMap) {
        List<Team_Structure__c> updateTeamList = [SELECT Id, OwnerId, RC_Code__c FROM Team_Structure__c WHERE OwnerId IN:assignMapByCurrentUser.keyset()];
        for(Team_Structure__c eachTeam : updateTeamList) {
            if(newUserMap.containsKey(eachTeam.OwnerId)) {
                User eachNewUser = newUserMap.get(eachTeam.OwnerId);
                if(eachNewUser != null && assignMapByCurrentUser.containsKey(eachTeam.OwnerId) && (eachNewUser.Isactive == false || eachNewUser.RC_Code__c != eachTeam.RC_Code__c)) {
                    eachTeam.OwnerId = assignMapByCurrentUser.get(eachTeam.OwnerId).AssignmentOwner__c;
                }
            }
        }
        if(updateTeamList.size() > 0) DB_Service.updateTeamStructure(updateTeamList);
    }

    @future
    public static void updateTeamStructure(String teamStringList) {
        List<Team_Structure__c> updateTeamList = (List<Team_Structure__c>) JSON.deserialize(teamStringList, List<Team_Structure__c>.class);
        DB_Service.updateTeamStructure(updateTeamList);
    }
    // CR008
    public static Id getTeamStructureIdByRcCode(String rcCode){
        String teamStructureId = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :rcCode LIMIT 1].Id;
        return teamStructureId;
    }

    public static Map<String, List<User>> getListUserMapByRCCode(List<User> listUser) {
        Map<String, List<User>> listUsersMapByRCCode = new Map<String, List<User>>();
        for(User eachUser : listUser) {
            if(eachUser.RC_Code__c != null) {
                if(!listUsersMapByRCCode.containsKey(eachUser.RC_Code__c)) {
                    listUsersMapByRCCode.put(eachUser.RC_Code__c, new List<User>());
                }
                listUsersMapByRCCode.get(eachUser.RC_Code__c).add(eachUser);
            }
        }
        return listUsersMapByRCCode;
    }

    public static Map<String, User> getOwnerUserMapByRCCode(List<User> listUser, Set<String> managerProfile) {
        Map<String, User> ownerUserMapByRCCode = new Map<String, User>();
        for(User eachUser : listUser) {
            if(eachUser.RC_Code__c != null && managerProfile.contains(eachUser.Profile.Name)) {
                if(!ownerUserMapByRCCode.containsKey(eachUser.RC_Code__c)) {
                    ownerUserMapByRCCode.put(eachUser.RC_Code__c, eachUser);
                }
            }
        }
        return ownerUserMapByRCCode;
    }

    //public static List<Team_Structure__c> updateInitialTeamOwner(List<Team_Structure__c> listTeam, Map<String, User> ownerUserMapByRCCode, Map<Id, User> userMapById, Id adminId) {
    //    List<Team_Structure__c> updateTeamList = new List<Team_Structure__c>();
    //    for(Team_Structure__c eachTeam : listTeam) {
    //        if(ownerUserMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
    //            User eachUser = ownerUserMapByRCCode.get(eachTeam.RC_Code__c);
    //            if(eachUser.IsActive) {
    //                eachTeam.OwnerId = eachUser.Id;
    //                eachTeam.Owner_Name__c = userMapById.get(eachUser.Id).Name;
    //                eachTeam.Owner_Phone__c = userMapById.get(eachUser.Id).Phone;
    //            } else if(eachUser.Manager != null && eachUser.Manager.IsActive) {
    //                eachTeam.OwnerId = eachUser.ManagerId;
    //                eachTeam.Owner_Name__c = userMapById.get(eachUser.ManagerId).Name;
    //                eachTeam.Owner_Phone__c = userMapById.get(eachUser.ManagerId).Phone;
    //            } else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive) {
    //                eachTeam.OwnerId = eachUser.Manager.ManagerId;
    //                eachTeam.Owner_Name__c = userMapById.get(eachUser.Manager.ManagerId).Name;
    //                eachTeam.Owner_Phone__c = userMapById.get(eachUser.Manager.ManagerId).Phone;
    //            } else {
    //                eachTeam.OwnerId = adminId;
    //            }
    //        } else if(eachTeam.AH_Name__c != null) {
    //            eachTeam.OwnerId = eachTeam.AH_Name__r.OwnerId;
    //            eachTeam.Owner_Name__c = userMapById.get(eachTeam.AH_Name__r.OwnerId).Name;
    //            eachTeam.Owner_Phone__c = userMapById.get(eachTeam.AH_Name__r.OwnerId).Phone;
    //        } else if(eachTeam.NH_Name__c != null) {
    //            eachTeam.OwnerId = eachTeam.NH_Name__r.OwnerId;
    //            eachTeam.Owner_Name__c = userMapById.get(eachTeam.NH_Name__r.OwnerId).Name;
    //            eachTeam.Owner_Phone__c = userMapById.get(eachTeam.NH_Name__r.OwnerId).Phone;
    //        } else {
    //            eachTeam.OwnerId = adminId;
    //        }
    //        updateTeamList.add(eachTeam);
    //    }
    //    return updateTeamList;
    //}

    public static List<Team_Structure__c> updateInitialTeamOwner(List<Team_Structure__c> listTeam, Map<String, User> ownerUserMapByRCCode, Map<Id, User> userMapById, Id adminId, Set<String> managerProfile) {
        List<Team_Structure__c> updateTeamList = new List<Team_Structure__c>();
        for(Team_Structure__c eachTeam : listTeam) {
            if(ownerUserMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
                User eachUser = ownerUserMapByRCCode.get(eachTeam.RC_Code__c);
                UserApproverModel currentUserWrapper = UserApproverModel.getUserApproverHierachy(eachUser);
                eachTeam.OwnerId = currentUserWrapper.getApproverIdFromProfile(managerProfile);
                if(eachTeam.OwnerId != null) {
                    eachTeam.Owner_Name__c = userMapById.get(eachTeam.OwnerId).Name;
                    eachTeam.Owner_Phone__c = userMapById.get(eachTeam.OwnerId).Phone;
                } else {
                    eachTeam.OwnerId = adminId;
                }
                /*if(eachUser.IsActive) {
                    eachTeam.OwnerId = eachUser.Id;
                    eachTeam.Owner_Name__c = userMapById.get(eachUser.Id).Name;
                    eachTeam.Owner_Phone__c = userMapById.get(eachUser.Id).Phone;
                } else if(eachUser.Manager != null && eachUser.Manager.IsActive) {
                    eachTeam.OwnerId = eachUser.ManagerId;
                    eachTeam.Owner_Name__c = userMapById.get(eachUser.ManagerId).Name;
                    eachTeam.Owner_Phone__c = userMapById.get(eachUser.ManagerId).Phone;
                } else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive) {
                    eachTeam.OwnerId = eachUser.Manager.ManagerId;
                    eachTeam.Owner_Name__c = userMapById.get(eachUser.Manager.ManagerId).Name;
                    eachTeam.Owner_Phone__c = userMapById.get(eachUser.Manager.ManagerId).Phone;
                } else {
                    eachTeam.OwnerId = adminId;
                }*/
            } else if(eachTeam.AH_Name__c != null) {
                eachTeam.OwnerId = eachTeam.AH_Name__r.OwnerId;
                eachTeam.Owner_Name__c = userMapById.get(eachTeam.AH_Name__r.OwnerId).Name;
                eachTeam.Owner_Phone__c = userMapById.get(eachTeam.AH_Name__r.OwnerId).Phone;
            } else if(eachTeam.NH_Name__c != null) {
                eachTeam.OwnerId = eachTeam.NH_Name__r.OwnerId;
                eachTeam.Owner_Name__c = userMapById.get(eachTeam.NH_Name__r.OwnerId).Name;
                eachTeam.Owner_Phone__c = userMapById.get(eachTeam.NH_Name__r.OwnerId).Phone;
            } else {
                eachTeam.OwnerId = adminId;
            }
            updateTeamList.add(eachTeam);
        }
        return updateTeamList;
    }

    public static Map<Id, User> getUserMapById(List<User> listUser, List<Team_Structure__c> listTeam) {
        Set<Id> userSetId = new Set<Id>();
        for(User eachUser : listUser) {
            userSetId.add(eachUser.Id);
            if(eachUser.Manager != null) {
                userSetId.add(eachUser.ManagerId);
            }
            if(eachUser.Manager.Manager != null) {
                userSetId.add(eachUser.Manager.ManagerId);
            }
        }
        for(Team_Structure__c eachTeam : listTeam) {
            if(eachTeam.AH_Name__c != null) {
                userSetId.add(eachTeam.AH_Name__r.OwnerId);
            }
            if(eachTeam.NH_Name__c != null) {
                userSetId.add(eachTeam.NH_Name__r.OwnerId);
            }
        }
        Map<Id, User> userMapById = new Map<Id, User>([SELECT Id, Name, Phone FROM User WHERE Id IN :userSetId]);
        return userMapById;
    }

    /*public static List<User> updateMemberProvince(List<Team_Structure__c> listTeam, Map<String, List<User>> listUsersMapByRCCode) {
        List<User> updateUserList = new List<User>();
        for(Team_Structure__c eachTeam : listTeam) {
            if(listUsersMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
                for(User updateUser : listUsersMapByRCCode.get(eachTeam.RC_Code__c)) {
                    updateUser.Province__c = eachTeam.Province__c;
                    updateUserList.add(updateUser);
                }
            }
        }
        return updateUserList;
    }*/
}