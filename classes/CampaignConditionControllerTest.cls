@isTest
private class CampaignConditionControllerTest
{   
    public static string strNewBooking='NEWBOOKING';
    public static string strThankyou='THANKYOU';
    @testSetup static void setUpTest()
    {
        Test.startTest();
        CampaignConditionControllerTest.setupData();
        Test.stopTest();
    }

    public static void setupData(){
        Campaign_Setting__c campaignSetting = new Campaign_Setting__c();
        campaignSetting.NewBooking_Code__c= strNewBooking;
        campaignSetting.ThankYou_Code__c= strThankyou;
        campaignSetting.Register_Period__c=30;
        insert campaignSetting;
    }

    @isTest static void insertNewConditonNoNewRowME(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = null;
        smeCamController.conditionList.clear();
        smeCamController.save();

        List<Campaign_Setting__c> newCamSettingList = [SELECT NewBooking_Code__c FROM Campaign_Setting__c WHERE NewBooking_Code__c ='NEWBOOKING1'];
        System.assertEquals(newCamSettingList.size(),1);
    }
    @isTest static void insertNewConditonNoNewRowSE(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'SE';
        smeCamController.campaignConditionString = null;
        smeCamController.conditionList.clear();
        smeCamController.save();

        List<Campaign_Setting__c> newCamSettingList = [SELECT NewBooking_Code__c FROM Campaign_Setting__c WHERE NewBooking_Code__c ='NEWBOOKING1'];
        System.assertEquals(newCamSettingList.size(),1);
    }
    @isTest static void insertNewConditonNoNewRowNoBookingCode(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = null;
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = null;
        smeCamController.conditionList.clear();
        smeCamController.save();

        List<Campaign_Setting__c> newCamSettingList = [SELECT NewBooking_Code__c FROM Campaign_Setting__c WHERE NewBooking_Code__c =:strNewBooking];
        System.assertEquals(newCamSettingList.size(),1);
    }
    @isTest static void insertNewConditonNoNewRowAddConditionText(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = '1';
        smeCamController.conditionList.clear();
        smeCamController.save();

        List<Campaign_Setting__c> newCamSettingList = [SELECT NewBooking_Code__c FROM Campaign_Setting__c WHERE NewBooking_Code__c =:strNewBooking];
        System.assertEquals(newCamSettingList.size(),1);
    }
    @isTest static void insertNewConditonAddNewRow(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1';
        camConditonWrapper.campaignExpression.Segment__c = 'ME';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.setType();
        smeCamController.save();
        Boolean checkType = false;
        checkType = CampaignConditionController.isNumeric(camConditonWrapper.campaignExpression.Value__c);
        
    }
    @isTest static void insertNewConditonAddNewRowWrongFieldType(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1.a';
        camConditonWrapper.campaignExpression.Segment__c = 'ME';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.setType();
        smeCamController.save();

    }
    @isTest static void insertNewConditonAddNewRowAndDelete(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1';
        camConditonWrapper.campaignExpression.Segment__c = 'ME';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.deleteRow();
        smeCamController.save();

    }
    @isTest static void insertNewConditonAddNewRowOldRecordME(){
        
        Campaign_Expression__c campaignExpression1 = new Campaign_Expression__c();
        campaignExpression1.Field__c = 'APP2__c';
        campaignExpression1.Field_Type__c = 'String';
        campaignExpression1.Operator__c = 'Operator__c';
        campaignExpression1.Value__c = '1';
        campaignExpression1.Segment__c = 'ME';
        campaignExpression1.Name = 'ME_1111';
        
        Test.startTest();
        insert campaignExpression1;
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'ME';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1';
        camConditonWrapper.campaignExpression.Segment__c = 'ME';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.setType();
        smeCamController.save();
        Boolean checkType = false;
        checkType = CampaignConditionController.isNumeric(camConditonWrapper.campaignExpression.Value__c);

        Test.stopTest();
    }
    @isTest static void insertNewConditonAddNewRowSE(){
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.init();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'SE';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1';
        camConditonWrapper.campaignExpression.Segment__c = 'SE';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.setType();
        smeCamController.save();
        Boolean checkType = false;
        checkType = CampaignConditionController.isNumeric(camConditonWrapper.campaignExpression.Value__c);

    }
    @isTest static void insertNewConditonAddNewRowOldRecordSE(){
        
        Campaign_Expression__c campaignExpression1 = new Campaign_Expression__c();
        campaignExpression1.Field__c = 'APP2__c';
        campaignExpression1.Field_Type__c = 'String';
        campaignExpression1.Operator__c = 'Operator__c';
        campaignExpression1.Value__c = '1';
        campaignExpression1.Segment__c = 'SE';
        campaignExpression1.Name = 'SE_1111';
        
        Test.startTest();
        insert campaignExpression1;
        CampaignConditionController smeCamController = new CampaignConditionController();
        smeCamController.bookingCode = 'NEWBOOKING1';
        smeCamController.campaignSegment = 'SE';
        smeCamController.campaignConditionString = '1';
        
        List<SelectOption> fieldSelectOptionList = smeCamController.fieldSelectOption;
        Map<String, String> fieldsTypesMap = smeCamController.fieldsTypeMap;
        CampaignConditionController.CampaignCondition camConditonWrapper = new CampaignConditionController.CampaignCondition(smeCamController.indexRow,fieldSelectOptionList,fieldsTypesMap);

        System.debug('Test camConditonWrapper ='+camConditonWrapper);
        camConditonWrapper.campaignExpression.Field__c = 'Probability';
        camConditonWrapper.campaignExpression.Field_Type__c = 'Percent';
        camConditonWrapper.campaignExpression.Operator__c = 'Operator__c';
        camConditonWrapper.campaignExpression.Value__c = '1';
        camConditonWrapper.campaignExpression.Segment__c = 'SE';

        smeCamController.conditionList.clear();
        smeCamController.conditionList.add(camConditonWrapper);

        smeCamController.addRow();
        smeCamController.setType();
        smeCamController.save();
        Boolean checkType = false;
        checkType = CampaignConditionController.isNumeric(camConditonWrapper.campaignExpression.Value__c);

        Test.stopTest();
    }

}