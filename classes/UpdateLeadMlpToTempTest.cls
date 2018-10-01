@isTest
private class UpdateLeadMlpToTempTest {
	
	private static void initialCustomSettingForLeadMLP(){
		List<Telesales_Product_Name_to_Field_Mapping__c> listCustomSetting = new List<Telesales_Product_Name_to_Field_Mapping__c>();
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KEC',Field_API_Name__c= 'KEC__c',Display_Product_Name_As__c = 'KEC'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KPL',Field_API_Name__c= 'KPL__c',Display_Product_Name_As__c = 'KPL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL',Field_API_Name__c= 'HL__c',Display_Product_Name_As__c = 'HL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Refinance',Field_API_Name__c= 'HL_Refinance__c',Display_Product_Name_As__c = 'HL_Refinance'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'HL_Equity',Field_API_Name__c= 'HL_Help__c',Display_Product_Name_As__c = 'HL_ช่วยได้'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KCar',Field_API_Name__c= 'KCar__c',Display_Product_Name_As__c = 'KCar'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'KL',Field_API_Name__c= 'KL__c',Display_Product_Name_As__c = 'KL'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'SME_Loan',Field_API_Name__c= 'SME_Loan__c',Display_Product_Name_As__c = 'SME Loan'));
		listCustomSetting.add(new Telesales_Product_Name_to_Field_Mapping__c(Name = 'CC',Field_API_Name__c= 'CC__c',Display_Product_Name_As__c = 'CC'));
		insert listCustomSetting;
	}

	@isTest static void Given_TempLeadMLP_And_AnswerLead_When_RunBatch_Then_UpdateLeadStatusToTemp() {
		initialCustomSettingForLeadMLP();
		
		List<Lead_MLP__c> listLeadMLP = new List<Lead_MLP__c>();
		Lead_MLP__c leadMlp1 = new Lead_MLP__c(
			Name = 'REFR_ID_00001',
			REFR_ID__c = 'REFR_ID_00001',
			LEAD_ID__c = 'LEAD_ID_00001',
			IP_ID__c = '181172',
			PROSP_NM__c = 'เปี้ยนสีทอง|ยมภูมิ|1234567890',
			IDENT_NO__c = '1234567890123',
			REL_ST__c = 'New',
			PERSZ_MSG__c = 'HL_Equity',
			Is_Sync_Completed__c = true
		);

		Lead_MLP__c leadMlp2 = new Lead_MLP__c(
			Name = 'REFR_ID_00002',
			REFR_ID__c = 'REFR_ID_00002',
			LEAD_ID__c = 'LEAD_ID_00001',
			IP_ID__c = '181172',
			PROSP_NM__c = 'เปี้ยนสีทอง|ยมภูมิ|1234567890',
			IDENT_NO__c = '1234567890123',
			REL_ST__c = 'New',
			PERSZ_MSG__c = 'KPL',
			Is_Sync_Completed__c = true
		);

		Lead_MLP__c leadMlp3 = new Lead_MLP__c(
			Name = 'REFR_ID_00003',
			REFR_ID__c = 'REFR_ID_00003',
			LEAD_ID__c = 'LEAD_ID_00001',
			IP_ID__c = '181172',
			PROSP_NM__c = 'เปี้ยนสีทอง|ยมภูมิ|1234567890',
			IDENT_NO__c = '1234567890123',
			REL_ST__c = 'New',
			PERSZ_MSG__c = 'CC',
			Is_Sync_Completed__c = true
		);

		listLeadMLP.add(leadMlp1);
		listLeadMLP.add(leadMlp2);
		listLeadMLP.add(leadMlp3);
		insert listLeadMLP;

		Lead lead = new Lead(
			Lead_MLP_Reference_Mapping__c = '{"KPL":"REFR_ID_00001","HL_Equity":"REFR_ID_00002","CC":"REFR_ID_00003"}',
			Product_Interest_as_registered__c = 'KPL,HL_Equity',
			CIS_ID__c = '181172',
			Document_Type__c = 'บัตรประชาชน',
			Identification_No__c = '1234567890123',
			KPL__c = true,
			Salutation = 'คุณ',
			FirstName = 'เปี้ยนสีทอง',
			LastName = 'ยมภูมิ',
			Status = 'Not Contacted 1',
			HL_Help__c = true,
			RecordTypeID = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Lead').get(GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME)
		);
		insert lead;
		
		Test.startTest();
			List<Id> listId = new List<Id>{lead.Id};
			Database.executeBatch(new UpdateLeadMlpToTemp_Batch(listId));
		Test.stopTest();

		List<Lead_MLP__c> listResultLeadMLP = [SELECT Id,PERSZ_MSG__c,REFR_ID__c,REL_ST__c,Is_Sync_Completed__c FROM Lead_MLP__c];
		System.assertEquals(3,listResultLeadMLP.size());
		for(Lead_MLP__c eachMLP : listResultLeadMLP){
			if(eachMLP.PERSZ_MSG__c == 'CC'){
				System.assertEquals('Unqualified',eachMLP.REL_ST__c);
			}else if(eachMLP.PERSZ_MSG__c == 'HL_Equity'){
				System.assertEquals('Not Contacted 1',eachMLP.REL_ST__c);
			}else if(eachMLP.PERSZ_MSG__c == 'KPL'){
				System.assertEquals('Not Contacted 1',eachMLP.REL_ST__c);
			}
		}
	}	
}