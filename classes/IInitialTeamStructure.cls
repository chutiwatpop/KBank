global interface IInitialTeamStructure {
    String getQuery();
    
    void calculateInitialTeamStructure(List<Team_Structure__c> listTeamStructure);
    void calculateTeamOwner(List<Team_Structure__c> listTeamStructure);
    void calculateRelatedObject();
    
    Boolean excuteUpdateTeam();
    void executeOtherObject(DML_Queueable dmlQueue);
    
    Boolean setTeamOwner();
    Boolean setUserProvince(DML_Queueable dmlQueue);
}