@isTest
private class TelesalesController_Test {
	
	@testSetup static void setupLead(){

        Test.startTest();        
        Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead');
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Status = 'Open';
        lead.Company = 'Test Test';
        lead.Email = 'Test@test.com';
        lead.RecordTypeID = recordTypeMapByDevName.get('Referral');
        insert lead;

        Map<String, Id> recordTypeMapByDevNameTeleSale = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Telesales_Lead_Flow__c');
        Telesales_Lead_Flow__c question = new Telesales_Lead_Flow__c();
        question.Name = 'Question 1';
        question.Script__c = 'Test_Question 1';
        question.Q_First_Question__c = true;
        question.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Question');
        insert question;

        Telesales_Lead_Flow__c question2 = new Telesales_Lead_Flow__c();
        question2.Name = 'Question 2';
        question2.Script__c = 'Test_Question 2';
        question2.Q_First_Question__c = false;
        question2.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Question');
        insert question2;

        Telesales_Lead_Flow__c question3 = new Telesales_Lead_Flow__c();
        question3.Name = 'Question 3';
        question3.Script__c = 'Test_Question 3';
        question3.Q_First_Question__c = false;
        question3.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Question');
        insert question3;

        Telesales_Lead_Flow__c answer = new Telesales_Lead_Flow__c();
        answer.Name = 'Answer 1';
        answer.Script__c = 'Answer_Test_Question 1';
        answer.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer;

        Telesales_Lead_Flow__c answer1 = new Telesales_Lead_Flow__c();
        answer1.Name = 'Answer 1.1';
        answer1.Script__c = 'Answer_Test_Question 1';
        answer1.A_Field__c = 'Age_Year_of_operation__c';
        answer1.A_Object__c = 'customer';
        answer1.A_Operation__c = 'มากกว่า';
        answer1.A_Value__c = '10';
        answer1.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer1;
        
        Telesales_Lead_Flow__c answer1_2 = new Telesales_Lead_Flow__c();
        answer1_2.Name = 'Answer 1.2';
        answer1_2.Script__c = 'Answer_Test_Question 1';
        answer1_2.A_Field__c = 'Age_Year_of_operation__c';
        answer1_2.A_Object__c = 'customer';
        answer1_2.A_Operation__c = 'เท่ากับ';
        answer1_2.A_Value__c = '10';
        answer1_2.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer1_2;
		
        Telesales_Lead_Flow__c answer1_3 = new Telesales_Lead_Flow__c();
        answer1_3.Name = 'Answer 1.3';
        answer1_3.Script__c = 'Answer_Test_Question 1';
        answer1_3.A_Field__c = 'Age_Year_of_operation__c';
        answer1_3.A_Object__c = 'customer';
        answer1_3.A_Operation__c = 'น้อยกว่า';
        answer1_3.A_Value__c = '10';
        answer1_3.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer1_3;
        
        Telesales_Lead_Flow__c answer2 = new Telesales_Lead_Flow__c();
        answer2.Name = 'Answer 2';
        answer2.Script__c = 'Answer_Test_Question 2';
        answer2.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer2;

        Telesales_Lead_Flow__c answer2_1 = new Telesales_Lead_Flow__c();
        answer2_1.Name = 'Answer 2.1';
        answer2_1.Script__c = 'Answer_Test_Question 2';
        answer2_1.A_Field__c = 'OD_Util__c';
        answer2_1.A_Object__c = 'Lead';
        answer2_1.A_Operation__c = 'น้อยกว่า';
        answer2_1.A_Value__c = '10';
        answer2_1.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Answer');
        insert answer2_1;
         

        Telesales_Lead_Flow__c flow = new Telesales_Lead_Flow__c();
        flow.Name = 'Flow 1';
        flow.F_Question__c = question.Id;
        flow.F_Answer__c = answer.Id;
        flow.F_Next_Question__c = question2.Id;
        flow.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow;

        Telesales_Lead_Flow__c flow1 = new Telesales_Lead_Flow__c();
        flow1.Name = 'Flow 1.1';
        flow1.F_Question__c = question.Id;
        flow1.F_Answer__c = answer1.Id;
        flow1.F_Next_Question__c = question2.Id;
        flow1.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow1;
        
        Telesales_Lead_Flow__c flow1_2 = new Telesales_Lead_Flow__c();
        flow1_2.Name = 'Flow 1.2';
        flow1_2.F_Question__c = question.Id;
        flow1_2.F_Answer__c = answer1_2.Id;
        flow1_2.F_Next_Question__c = question2.Id;
        flow1_2.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow1_2;
        
        Telesales_Lead_Flow__c flow1_3 = new Telesales_Lead_Flow__c();
        flow1_3.Name = 'Flow 1.3';
        flow1_3.F_Question__c = question.Id;
        flow1_3.F_Answer__c = answer1_3.Id;
        flow1_3.F_Next_Question__c = question2.Id;
        flow1_3.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow1_3;

        Telesales_Lead_Flow__c flow2 = new Telesales_Lead_Flow__c();
        flow2.Name = 'Flow 2';
        flow2.F_Question__c = question2.Id;
        flow2.F_Answer__c = answer2.Id;
        flow1.F_Next_Question__c = question3.Id;
        flow2.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow2;

        Telesales_Lead_Flow__c flow2_1 = new Telesales_Lead_Flow__c();
        flow2_1.Name = 'Flow 2.1';
        flow2_1.F_Question__c = question2.Id;
        flow2_1.F_Answer__c = answer2_1.Id;
        flow2_1.F_Next_Question__c = question3.Id;
        flow2_1.RecordTypeID = recordTypeMapByDevNameTeleSale.get('Flow');
        insert flow2_1;
        Test.stopTest();

	}

	@isTest static void test_getAllQuestions() {

		Lead data = [Select Id, Name, Email from Lead where Email = 'Test@test.com' limit 1];

		String result =  TelesalesController.getAllQuestions(data.Id);
		//System.debug('result : ' +result);
		System.assertEquals(false, String.isBlank(result));
	}
	
	@isTest static void test_saveTeleSale() {

		Lead data = [Select Id, Name, Email from Lead where Email = 'Test@test.com' limit 1];
		List<Telesales_Lead_Flow__c> leadFlow = [select Id, Name, Script__c from Telesales_Lead_Flow__c where Name = 'Question 1' or Name = 'Answer 1'];
        TelesalesController.DataTeleSaleLead obj = new TelesalesController.DataTeleSaleLead();
        obj.leadId = String.valueOf(data.Id);
        obj.questions = new String[]{leadFlow[0].Id};
        obj.answers = new String[]{leadFlow[1].Id};
        obj.contactDate = new String[]{''};
        obj.notes = new String[]{'data123'};
        obj.numbers = new String[]{'5000'};
        obj.statusLead = new String[]{'Contacted'};
        obj.onlineStatus = new String[]{''};
        obj.questionNames = new String[]{''};

		String result =  TelesalesController.save(JSON.serialize(obj));
		//System.debug('result : ' +result);
        Lead resultLead = [Select Id, Status from Lead where Id =: data.Id limit 1]; 
		System.assertEquals(false, String.isBlank(result));
		Map<String,Object> statusSave = (Map<String, Object>)JSON.deserializeUntyped(result);
		System.assertEquals('SUCCESS', statusSave.get('result').toString());
        System.assertEquals('Contacted', resultLead.Status);
	}

    @isTest static void test_saveTeleSaleWithClearFlag() {

        Lead data = [Select Id, Name, Email from Lead where Email = 'Test@test.com' limit 1];
        List<Telesales_Lead_Flow__c> leadFlow = [select Id, Name, Script__c from Telesales_Lead_Flow__c where Name = 'Question 1' or Name = 'Answer 1'];
        TelesalesController.DataTeleSaleLead obj = new TelesalesController.DataTeleSaleLead();
        obj.leadId = String.valueOf(data.Id);
        obj.questions = new String[]{leadFlow[0].Id};
        obj.answers = new String[]{leadFlow[1].Id};
        obj.contactDate = new String[]{''};
        obj.notes = new String[]{'data123'};
        obj.numbers = new String[]{'5000'};
        obj.statusLead = new String[]{''};
        obj.onlineStatus = new String[]{''};
        obj.questionNames = new String[]{''};
        TelesalesController.save(JSON.serialize(obj));

        String result =  TelesalesController.save(JSON.serialize(obj));
        List<Telesales_Lead_Historical__c> resultTeleLead = [Select Id, Lead__c, Latest__c from Telesales_Lead_Historical__c where Lead__c =: data.Id order by Latest__c]; 
        System.assertEquals(false, String.isBlank(result));
        System.assertEquals(2, resultTeleLead.size());
        System.assertEquals(false, resultTeleLead[0].Latest__c);
        System.assertEquals(true, resultTeleLead[1].Latest__c);
    }

        @isTest static void test_getAllQuestionsWithHaveCondition() {

                Lead data = [Select Id, Name, Email,OD_Util__c from Lead where Email = 'Test@test.com' limit 1];
                data.OD_Util__c = 8;
                update data;

                String result =  TelesalesController.getAllQuestions(data.Id);
                //System.debug('result : ' +result);
                System.assertEquals(false, String.isBlank(result));
        }

        @isTest static void test_getAllQuestionsWithHaveConditionLookUp() {

                Account acc = new Account(
                    Name = 'testTeleSaleAccount',
                    Port_Pool__c = GlobalConstants.POOL,
                    RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
                    Is_createby_Integration__c = true,
                    Age_Year_of_operation__c = '60'

                );
                insert acc;

                Lead data = [Select Id, Name, Email,OD_Util__c from Lead where Email = 'Test@test.com' limit 1];
                data.Customer__c = acc.Id;
                update data;

                String result =  TelesalesController.getAllQuestions(data.Id);
                System.assertEquals(false, String.isBlank(result));
        }
	
}