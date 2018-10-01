@isTest
private class ApprovalManager_Test
{
	public static final String SME_RM_PORT = 'SME_RM_PORT';

	public static final String RC_CODE    = '88881';
  public static final String AH_RC_CODE = '88882';
  public static final String NH_RC_CODE = '88883';

  public static final String SME_RC_CODE    = '88884';
  public static final String SME_AH_RC_CODE = '88885';
  public static final String SME_NH_RC_CODE = '88886';

	public static final String RBS_BM_EMP 		 = '7000000002';
  public static final String RBS_BM_FIRST_NAME = 'RBSFirstName1';
	public static final String RBS_BM_LAST_NAME  = 'RBSLastName1';

	public static final String RBS_BM_EMP_2 	   = '7000000012';
  public static final String RBS_BM_FIRST_NAME_2 = 'RBSFirstName2';
	public static final String RBS_BM_LAST_NAME_2  = 'RBSLastName2';

	public static final String RBS_RM_EMP 		 = '7000000001';
  public static final String RBS_RM_FIRST_NAME = 'RBSFirstName';
	public static final String RBS_RM_LAST_NAME  = 'RBSLastName';

	public static final String SME_NH_EMP 		 = '6000000004';
  public static final String SME_NH_FIRST_NAME = 'NHFirstName';
	public static final String SME_NH_LAST_NAME  = 'NHLastName';
	public static final String SME_AH_EMP 		 = '6000000003';
  public static final String SME_AH_FIRST_NAME = 'AHFirstName';
	public static final String SME_AH_LAST_NAME  = 'AHLastName';
	public static final String SME_TM_EMP 		 = '6000000002';
  public static final String SME_TM_FIRST_NAME = 'TMFirstName';
	public static final String SME_TM_LAST_NAME  = 'TMLastName';
	public static final String SME_RM_EMP 		 = '6000000001';
  public static final String SME_RM_FIRST_NAME = 'RMFirstName';
	public static final String SME_RM_LAST_NAME  = 'RMLastName';

  public static String ACCOUNT_RBS_BM_CIS = '000000001';
  public static String ACCOUNT_RBS_RM_CIS = '000000002';
  public static String ACCOUNT_SME_RM_CIS = '000000003';

  private static Account createCustomer(String name, String portPool, String recordTypeDevName, String customerSegment,String cis) {
  	Id recordTypeId = GlobalUtility.getRecordTypeId('Account', recordTypeDevName);
  	Account newAccount = new Account(
          Port_Pool__c = portPool,
          RecordTypeId = recordTypeId,
          Primary_Segment_Code__c 	= customerSegment,
          Customer_Segment_Code__c 	= customerSegment,
          Is_createby_Integration__c 	= true,
          CIS__c = cis
      );
      if(recordTypeDevName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME || 
      	recordTypeDevName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
          newAccount.LastName = name;
      } else if(recordTypeDevName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
      	recordTypeDevName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) {
          newAccount.Name = name;
      }

      return newAccount;
	}

    private static Map<Id,User_MaskModel> mockUserMaskModel(List<User> userList,List<User> oldUsers) {
  		Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
  		Integer count = 0;
  		for(User eachUser : userList) {
  			User_MaskModel userMask = new User_MaskModel();
        userMask.userId = eachUser.Id;
        userMask.profileName = eachUser.Profile.Name;
        userMask.setNewUser(eachUser);
        userMask.setOldUser(oldUsers.get(count));
        userMaskMapByUserId.put(eachUser.Id, userMask);
        count++;
		  }
		  return userMaskMapByUserId;
	}

  @TestSetup
  public static void setupInfo(){
    setupRBS();
    setUpSME();
  }

  public static void setupRBS(){
    String RC_CODE_2    = '81404';
    String AH_RC_CODE_2 = '81400';
    String NH_RC_CODE_2 = '81201';

    // Given
    UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
    User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
    UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);

    UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
    User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
    UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);

    Database.insert(new User[]{RBS_BM,RBS_BM_2});

    User RBS_RM = UserManagementMockupTest.createNewUser(RBS_RM_EMP, RBS_RM_FIRST_NAME, RBS_RM_LAST_NAME, true, RBS_BM.id);
    UserManagementMockupTest.setUserAdditionalInfo(RBS_RM, UserManagementMockupTest.JOB_CODE_RBS_RM_ABM_1, 'RC', RC_CODE);
    
    Database.insert(new User[]{RBS_RM});

    Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
    currentClosnessBranch.OwnerId = RBS_BM.Id;

    Team_Structure__c previousClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
    previousClosnessBranch.OwnerId = RBS_BM_2.Id;
    
    System.runAs(new User(Id=UserInfo.getUserId())){
      update previousClosnessBranch;
      update currentClosnessBranch;
    }

    Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI,ACCOUNT_RBS_BM_CIS);
    I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
    I_CUSTOMER_PORT.RBS_Previous_Branch_Closeness__c = previousClosnessBranch.Id;

    Account I_RM_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI,ACCOUNT_RBS_RM_CIS);
    System.runAs(RBS_RM){
      insert I_RM_CUSTOMER_PORT;
    }

    System.runAs(RBS_BM){
      insert I_CUSTOMER_PORT;
      User currentUser = ReleaseOwnershipService.getCurrentUserManager();
      // When
      Test.startTest();
      Account targetAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
      RBSReleaseOwnership rbsRelease = new RBSReleaseOwnership();
      Customer_Ownership_Request__c newRequest = rbsRelease.createCustomerOwnershipRequest(targetAccount, currentUser);
      insert newRequest;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(newRequest.id);
        Approval.ProcessResult processResult = Approval.process(req);
      Test.stopTest();

    }
  }

  private static void setUpSME(){
    UserManagementMockupTest.init(SME_NH_RC_CODE, SME_AH_RC_CODE, SME_RC_CODE, GlobalConstants.SEGMENT_SE);

    User SME_AH = UserManagementMockupTest.createNewUser(SME_AH_EMP, SME_AH_FIRST_NAME, SME_AH_LAST_NAME, true, null);
    UserManagementMockupTest.setUserAdditionalInfo(SME_AH, UserManagementMockupTest.JOB_CODE_SME_AH_1, 'RC', SME_AH_RC_CODE);
    insert SME_AH;
    User SME_TM = UserManagementMockupTest.createNewUser(SME_TM_EMP, SME_TM_FIRST_NAME, SME_TM_LAST_NAME, true,SME_AH.id);
    UserManagementMockupTest.setUserAdditionalInfo(SME_TM, UserManagementMockupTest.JOB_CODE_SME_TM_1, 'RC', SME_RC_CODE);
    insert SME_TM;
    User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, SME_TM.id);
    UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', SME_RC_CODE);
    insert SME_RM;

    Team_Structure__c teamTM = UserManagementMockupTest.mapTeamByRCCode.get(SME_RC_CODE);
    teamTM.OwnerId = SME_TM.Id;

    Team_Structure__c teamAH = UserManagementMockupTest.mapTeamByRCCode.get(SME_AH_RC_CODE);
    teamAH.OwnerId = SME_AH.Id;
    
    Database.update(new Team_Structure__c[]{teamAH,teamTM},false);
   
    System.runAs(SME_RM){
      Account I_RM_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM,ACCOUNT_SME_RM_CIS);
      insert I_RM_CUSTOMER_PORT;
    }    
  }
  /*///////////////////////////////////
      RBS
  *////////////////////////////////////
	@isTest static void rejectCustomerRequestWhenRequestorRBSinActive() {
      //Given
      User RBS_BM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP Limit 1];
      
      //When
      Test.startTest();
        User NEW_RBS_BM = RBS_BM.clone(true, true, false, false);
        NEW_RBS_BM.isActive = false;
        Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_BM},new List<User>{RBS_BM});
        ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
        approvalManager.initObjectReAssigner();
        approvalManager.reAssignProcessInstance();
        approvalManager.updateAllWork();
      Test.stopTest();

      //Then
      Customer_Ownership_Request__c req = [SELECT Id,Approval_Status__c From Customer_Ownership_Request__c WHERE OwnerId = :RBS_BM.id Limit 1];
      ProcessInstance approvalP = [SELECT Id,Status,(select id,Comments from Steps Order by CreatedDate DESC Limit 1) From ProcessInstance WHERE TargetObjectId = :req.id];
      System.assertEquals(GlobalConstants.REJECTED,req.Approval_Status__c);
      System.assertEquals(GlobalConstants.REJECTED,approvalP.Status);
      System.assertEquals(Label.ClosenessBranchRequestorIsInactive,approvalP.Steps[0].Comments);
  }

  @isTest static void rejectCustomerRequestWhenApproverRBSinActive() {
      //Given
      User RBS_BM_2 =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP_2 Limit 1];
      
      //When
      Test.startTest();
         User NEW_RBS_BM_2 = RBS_BM_2.clone(true, true, false, false);
        NEW_RBS_BM_2.isActive = false;
        Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_BM_2},new List<User>{RBS_BM_2});
        ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
        approvalManager.initObjectReAssigner();
        approvalManager.reAssignProcessInstance();
        approvalManager.updateAllWork();
      Test.stopTest();

      //Then
      Customer_Ownership_Request__c req = [SELECT Id,Approval_Status__c From Customer_Ownership_Request__c WHERE Approver__c = :RBS_BM_2.id Limit 1];
      ProcessInstance approvalP = [SELECT Id,Status,(select id,Comments from Steps Order by CreatedDate DESC Limit 1) From ProcessInstance WHERE TargetObjectId = :req.id];
      System.assertEquals(GlobalConstants.REJECTED,req.Approval_Status__c);
      System.assertEquals(GlobalConstants.REJECTED,approvalP.Status);
      System.assertEquals(Label.ClosenessBranchApproverIsInactive,approvalP.Steps[0].Comments);
  }

  @isTest static void rejectJobApprovalWhenRequestorRBSinActive(){
    //Given
    Account targetAccount = [SELECT id From Account WHERE CIS__c = :ACCOUNT_RBS_BM_CIS Limit 1];
    Opportunity opp = Mockup_Test.newOpportunity(targetAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
    User RBS_BM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP Limit 1];
    
    System.runAs(RBS_BM){
      insert opp;
    }
    System.runAs(RBS_BM){
      opp.StageName = GlobalConstants.FINISHED;
      // Process Builder will summit for approval if Resubmit_Approval__c = true
      opp.Resubmit_Approval__c = true;
      update opp;
    }
    //When
    Test.startTest();
      User NEW_RBS_BM = RBS_BM.clone(true, true, false, false);
      NEW_RBS_BM.isActive = false;
      Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_BM},new List<User>{RBS_BM});
      ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
      approvalManager.initObjectReAssigner();
      approvalManager.reAssignProcessInstance();
      approvalManager.updateAllWork();
    Test.stopTest();
    //Then
    opp = [SELECT Id,StageName,Resubmit_Approval__c From Opportunity WHERE Id = :opp.id Limit 1];
    ProcessInstance approvalP = [SELECT Id,Status,(select id,Comments from Steps Order by CreatedDate DESC Limit 1) From ProcessInstance WHERE TargetObjectId = :opp.id];
    System.assertEquals(GlobalConstants.FINISHED, opp.StageName);
    System.assertEquals(false, opp.Resubmit_Approval__c);
    System.assertEquals(GlobalConstants.REJECTED, approvalP.Status);
    System.assertEquals(Label.ReopenJobRequestorIsInactive,approvalP.Steps[0].Comments);
  }

  @isTest static void rejectJobApprovalWhenApproverRBSinActive(){
    //Given
    Account targetAccount = [SELECT id From Account WHERE CIS__c = :ACCOUNT_RBS_RM_CIS Limit 1];
    Opportunity opp = Mockup_Test.newOpportunity(targetAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
    User RBS_RM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_RM_EMP Limit 1];
    User RBS_BM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP Limit 1];
    System.runAs(RBS_RM){
      insert opp;
    }
  
    System.runAs(RBS_RM){
      opp.StageName = GlobalConstants.FINISHED;
      // Process Builder will summit for approval if Resubmit_Approval__c = true
      opp.Resubmit_Approval__c = true;
      update opp;
    }

    //When
    Test.startTest();
      User NEW_RBS_BM = RBS_BM.clone(true, true, false, false);
      NEW_RBS_BM.isActive = false;
      Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_BM},new List<User>{RBS_BM});
      ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
      approvalManager.initObjectReAssigner();
      approvalManager.reAssignProcessInstance();
      approvalManager.updateAllWork();
    Test.stopTest();
    //Then
    opp = [SELECT Id,StageName,Resubmit_Approval__c From Opportunity WHERE Id = :opp.id Limit 1];
    ProcessInstance approvalP = [SELECT Id,Status,(select id,Comments from Steps Order by CreatedDate DESC Limit 1) From ProcessInstance WHERE TargetObjectId = :opp.id];
    System.assertEquals(GlobalConstants.FINISHED, opp.StageName);
    System.assertEquals(false, opp.Resubmit_Approval__c);
    System.assertEquals(GlobalConstants.REJECTED, approvalP.Status);
    System.assertEquals(Label.ReopenJobApproverIsInactive,approvalP.Steps[0].Comments);
  }

  @isTest static void reAssignLeadApproverWhenApproverRBSinActive(){
    //Given
    Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
    User RBS_RM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_RM_EMP Limit 1];
    User RBS_BM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP Limit 1];
    Lead lead = new Lead(
      LastName = 'Test',
      Status = GlobalConstants.STATUS_OPEN,
      RecordTypeID = recordTypeMapByDevName.get(GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL_READ_ONLY),
      Submit_for_Approval__c = true,
      Refer_To_User__c = RBS_RM.id
    );
    System.runAs(RBS_BM){
      insert lead;
      Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
      req.setObjectId(lead.id);
      Approval.ProcessResult processResult = Approval.process(req);
    }
    //When
    Test.startTest();
      User NEW_RBS_RM = RBS_RM.clone(true, true, false, false);
      NEW_RBS_RM.isActive = false;
      Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_RM},new List<User>{RBS_RM});
      ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
      approvalManager.initObjectReAssigner();
      approvalManager.reAssignProcessInstance();
      approvalManager.updateAllWork();
    Test.stopTest();
    //Then
    ProcessInstanceWorkitem workItem = [SELECT Id,ActorId From ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :lead.id Limit 1];
    System.assertEquals(RBS_BM.id,workItem.ActorId);
  }

  /*///////////////////////////////////
      END RBS
  *////////////////////////////////////

  /*///////////////////////////////////
      SME
  *////////////////////////////////////
  @isTest static void reAssignJobApproverWhenApproverSMEinActive(){
    //Given
    Account targetAccount = [SELECT id From Account WHERE CIS__c = :ACCOUNT_SME_RM_CIS Limit 1];
    Opportunity opp = Mockup_Test.newOpportunity(targetAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
    User SME_RM =  [SELECT Id,Sme_user__c,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :SME_RM_EMP Limit 1];
    User SME_TM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :SME_TM_EMP Limit 1];
    User SME_AH =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :SME_AH_EMP Limit 1];
    System.runAs(SME_RM){
      insert opp;
    }
    System.debug('Debug -- SME_RM ::'+SME_RM.Sme_user__c);
    System.runAs(SME_RM){
      opp.StageName = GlobalConstants.FINISHED;
      // Process Builder will summit for approval if Resubmit_Approval__c = true
      opp.Resubmit_Approval__c = true;
      update opp;
    }
    // Change opp approver
    System.runAs(new User(Id=UserInfo.getUserId())){
      SME_RM.Current_Opportunity_Approval__c = SME_AH.id;
      TriggerHandler.bypass('UserTriggerHandler');
        update SME_RM;
      TriggerHandler.clearbypass('UserTriggerHandler');
    }
    //When
    Test.startTest();
      User NEW_SME_TM = SME_TM.clone(true, true, false, false);
      NEW_SME_TM.isActive = false;
      Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_SME_TM},new List<User>{SME_TM});
      ApprovalManager approvalManager = new ApprovalManager(userMaskMapByUserId);
      approvalManager.initObjectReAssigner();
      approvalManager.reAssignProcessInstance();
      approvalManager.updateAllWork();
    Test.stopTest();
    //Then
    System.debug('Debug -- opp ::'+opp.id);
    System.debug('Debug -- SELECT Id,ActorId From ProcessInstanceWorkitem ::'+[SELECT Id,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type From ProcessInstanceWorkitem]);
    System.debug('Debug -- TargetObjectId ::'+[SELECT Id,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type From ProcessInstanceWorkitem][0].ProcessInstance.TargetObjectId);
    ProcessInstanceWorkitem workItem = [SELECT Id,ActorId From ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.id Limit 1];
    System.assertEquals(SME_RM.Current_Opportunity_Approval__c,workItem.ActorId);
  }
  /*///////////////////////////////////
      END SME
  *////////////////////////////////////
  @isTest static void testApprovalAssignmentQueue(){
    User RBS_BM =  [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :RBS_BM_EMP Limit 1];
    User NEW_RBS_BM = RBS_BM.clone(true, true, false, false);
    NEW_RBS_BM.isActive = false;

    Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{NEW_RBS_BM},new List<User>{RBS_BM});

    ApprovalAssignmentQueue.doChainJob = false;
    System.enqueueJob(new ApprovalAssignmentQueue(userMaskMapByUserId));
  }
}