@isTest
private class InitialBusinessCodeText_Batch_Test {
	public static String userRMSE_FirstName = 'userSE_FirstName';
	public static String userRMSE_LastName = 'userSE_LastName';
	public static String userRMSE_EmpId = '999999991';

	public static String accountNameRMSE = 'accountNameRMSE';
	public static String accountRMSECIS = '111222333';

	public static String businessCodeText1 = '12345';
	public static String riskyControl_FL = 'riskyControl_FL';
	@testSetup static void setUpData(){
		Test.startTest();
			List<User> userList = new List<User>();

			Profile rmProfile = [SELECT Id From Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
			User useRMSE = Mockup_Test.newUser(userRMSE_FirstName,userRMSE_LastName,userRMSE_EmpId,true,rmProfile.id,null,null);
			useRMSE.Segment__c = GlobalConstants.SEGMENT_SE;
			userList.add(useRMSE);
			insert userList;

			String recoedTypeIdAccountCustomer = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER);
			System.runAs(useRMSE){
				Account accountOwnerRMSE = Mockup_Test.newAccountWithSegment(accountNameRMSE,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
				accountOwnerRMSE.CIS__c = InitialBusinessCodeText_Batch_Test.accountRMSECIS;
				insert accountOwnerRMSE;
			}

			List<Business_Code__c> businessCodeList = new List<Business_Code__c>();
			Business_Code__c businessCode = new Business_Code__c(Name=businessCodeText1,Segment__c=GlobalConstants.SEGMENT_SE,External_ID__c=businessCodeText1+':'+GlobalConstants.SEGMENT_SE,
																Risky_Control_FL__c = InitialBusinessCodeText_Batch_Test.riskyControl_FL);
			businessCodeList.add(businessCode);
			insert businessCodeList;
		Test.stopTest();
	}
	
	@isTest static void testStamBusinessCodeTextInCallReport() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :InitialBusinessCodeText_Batch_Test.accountNameRMSE LIMIT 1];
        User useRMSE = [SELECT Id FROM User WHERE Firstname=:InitialBusinessCodeText_Batch_Test.userRMSE_FirstName LIMIT 1];
       	Business_Code__c businessCode = [SELECT Id,Name From Business_Code__c WHERE Name = :InitialBusinessCodeText_Batch_Test.businessCodeText1];
       	Contact con = new Contact();
        System.runAs(useRMSE){
            con.LastName = 'lastname';
            con.Contact_Firstname__c = 'Firstname';
            con.AccountId = targetAccount.Id;
            con.Phone_Number__c = '023450789';
            insert con;
        }

		List<Call_Report__c> callReportList = new List<Call_Report__c>();
	    Call_Report__c callreportObj = new Call_Report__c(
            Collect_Documents__c = true,
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.CONTACTED,
            Contact__c = con.Id,
            Expected_Credit_Amount__c = 500000,
            RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
            Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION,
            Business_Code__c = businessCode.id
        );
        callReportList.add( callreportObj);
	    System.runAs(useRMSE){
	    	insert callReportList;
		}
		Test.startTest();
			Database.executeBatch(new InitialBusinessCodeText_Batch(),200);
		Test.stopTest();
		callreportObj = [SELECT Id,Business_Code_Text__c From Call_Report__c WHERE id = :callreportObj.id LIMIT 1];
		System.assertEquals(businessCode.Name,callreportObj.Business_Code_Text__c);
	}

	@isTest static void testStampBusinessCodeTextInOpportunity() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :InitialBusinessCodeText_Batch_Test.accountNameRMSE LIMIT 1];
        User useRMSE = [SELECT Id FROM User WHERE Firstname=:InitialBusinessCodeText_Batch_Test.userRMSE_FirstName LIMIT 1];
       	Business_Code__c businessCode = [SELECT Id,Name From Business_Code__c WHERE Name = :InitialBusinessCodeText_Batch_Test.businessCodeText1];
       
       	Opportunity opp1;
       	System.runAs(useRMSE){
			opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			opp1.Business_Code__c = businessCode.id;
			insert opp1;	
		}

		Test.startTest();
			Database.executeBatch(new InitialBusinessCodeText_Batch(),200);
		Test.stopTest();
		opp1 = [SELECT Id,Business_Code_Text__c From Opportunity WHERE Id = :opp1.id LIMIT 1];
		System.assertEquals(businessCode.Name,opp1.Business_Code_Text__c);
	}

	@isTest static void testInitialCustomerBusinessCodeFromCallReport(){
		Account targetAccount = [SELECT Id,CIS__c FROM Account WHERE Name = :InitialBusinessCodeText_Batch_Test.accountNameRMSE LIMIT 1];
        User useRMSE = [SELECT Id,Segment__c FROM User WHERE Firstname=:InitialBusinessCodeText_Batch_Test.userRMSE_FirstName LIMIT 1];
       	Business_Code__c businessCode = [SELECT Id,Name,External_ID__c From Business_Code__c WHERE Name = :InitialBusinessCodeText_Batch_Test.businessCodeText1];
       	//Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c(CIS__c=targetAccount.id,Business_Code__c=businessCode.id,External__c=targetAccount.CIS__c+':'+businessCode.External_ID__c);
       	Contact con = new Contact();
        System.runAs(useRMSE){
            con.LastName = 'lastname';
            con.Contact_Firstname__c = 'Firstname';
            con.AccountId = targetAccount.Id;
            con.Phone_Number__c = '023450789';
            insert con;
            //insert customerBusinessCode;
        }

		List<Call_Report__c> callReportList = new List<Call_Report__c>();
	    Call_Report__c callreportObj = new Call_Report__c(
            Collect_Documents__c = true,
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.CONTACTED,
            Contact__c = con.Id,
            Expected_Credit_Amount__c = 500000,
            RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
            Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION,
            //Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
            Business_Code_Text__c = businessCode.Name
            //Customer_Business_Code__c = customerBusinessCode.id
        );
        callReportList.add( callreportObj);
        System.runAs(useRMSE){
	    	insert callReportList;
		}

		Test.startTest();
			Database.executeBatch(new CustomerBusinessCode_Initial_Batch(),200);
		Test.stopTest();
		String customerBusinessCodeExternalId = Customer_BusinessCode_Service.generateExternalId(targetAccount, businessCode.External_ID__c);
		List<Customer_Business_Code__c> customerBusinessCodeList = [SELECT Id,CIS__c,Business_Code__c,Business_Code__r.Name,Risky_Control_FL__c From Customer_Business_Code__c WHERE External__c = :customerBusinessCodeExternalId LIMIT 1];
		System.assertEquals(targetAccount.id,customerBusinessCodeList.get(0).CIS__c);
		System.assertEquals(businessCode.id,customerBusinessCodeList.get(0).Business_Code__c);

		callreportObj = [SELECT id,Business_Code_Text__c,Risky_Control__c From Call_Report__c WHERE Id =:callreportObj.id LIMIT 1];
		System.assertEquals(callreportObj.Business_Code_Text__c,customerBusinessCodeList.get(0).Business_Code__r.Name);
	}

	@isTest static void testInitialCustomerBusinessCodeFromOpporunity(){
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :InitialBusinessCodeText_Batch_Test.accountNameRMSE LIMIT 1];
        User useRMSE = [SELECT Id,Segment__c FROM User WHERE Firstname=:InitialBusinessCodeText_Batch_Test.userRMSE_FirstName LIMIT 1];
       	Business_Code__c businessCode = [SELECT Id,Name,External_ID__c,Segment__c From Business_Code__c WHERE Name = :InitialBusinessCodeText_Batch_Test.businessCodeText1];
       
       	Opportunity opp1;
       	System.runAs(useRMSE){
			opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			opp1.Business_Code__c = businessCode.id;
			opp1.Business_Code_Text__c = businessCode.Name;
			opp1.Owner_Segment_Business_Code__c = useRMSE.Segment__c;
			insert opp1;	
		}

		Test.startTest();
			Database.executeBatch(new CustomerBusinessCode_Initial_Batch(),200);
		Test.stopTest();
		opp1 = [SELECT Id,Business_Code__c,Account.CIS__c From Opportunity WHERE Id = :opp1.id LIMIT 1];
		System.assertEquals(businessCode.id,opp1.Business_Code__c);

		String customerBusinessCodeExternalId = Customer_BusinessCode_Service.generateExternalId(opp1, businessCode.External_ID__c);
		List<Customer_Business_Code__c> customerBusinessCode = [SELECT Id,CIS__c,Business_Code__c,Business_Code__r.Name,Risky_Control_FL__c From Customer_Business_Code__c WHERE External__c = :customerBusinessCodeExternalId LIMIT 1];
		System.assertEquals(targetAccount.id,customerBusinessCode.get(0).CIS__c);
		System.assertEquals(businessCode.id,customerBusinessCode.get(0).Business_Code__c);
	}

	
}