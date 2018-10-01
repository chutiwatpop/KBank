public with sharing class CampaignConditionController {

    public Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    public String bookingCode {get; set;}
    public static final String selectedObject = 'Application_History__c';
    public String campaignSegment {get; set;}
    public String campaignConditionString {get; set;}
    public String errorMsgBookingCode {get; set;}
    public static Integer toSetTypeIdent {get; set;}
    public static Integer toDelIdent {get; set;}
    public Boolean isShowError {get; set;}

    public List<CampaignCondition> conditionList {get;set;}
    public Integer indexRow;
    public Map<String, String> fieldsTypeMap {get; set;}
    
    public List<SelectOption> fieldSelectOption;
    public List<Campaign_Setting__c> campaignSettingList;
    public List<Campaign_Expression__c> campaignExpressionList;
    public List<Campaign_Expression__c> campaignExpressionForDeleteList;

    public CampaignConditionController() {
        fieldsTypeMap = new Map<String, String>();
        fieldSelectOption = new List<SelectOption>();
        getSegmentSelectOption();
        getOperatorSelectOption();
        setupFieldsListAndType();
        init();
    }

    public void init() {
        isShowError = false;
        indexRow = 1;
        errorMsgBookingCode = null;
        campaignConditionString = null;
        bookingCode = null;
        
        campaignSettingList = new List<Campaign_Setting__c>();
        campaignSettingList = [SELECT Id,Amount_SendByRM__c,IsDeleted,Name,NewBooking_Code__c,New_Booking_Condition_ME__c,New_Booking_Condition_SE__c,Register_Period__c,ThankYou_Code__c FROM Campaign_Setting__c];

        if(!campaignSettingList.isEmpty()){
            if(campaignSegment.equals('ME')){
                campaignConditionString = campaignSettingList[0].New_Booking_Condition_ME__c;
            }else if(campaignSegment.equals('SE')){
                campaignConditionString = campaignSettingList[0].New_Booking_Condition_SE__c;
            }
            bookingCode = campaignSettingList[0].NewBooking_Code__c;
        }

        campaignExpressionList = new List<Campaign_Expression__c>();
        campaignExpressionList = [SELECT Id,Field_Type__c,Field__c,IsDeleted,Name,Object__c,Operator__c,Segment__c,Value__c FROM Campaign_Expression__c ORDER BY Name];
        conditionList = new List<CampaignCondition>();
        campaignExpressionForDeleteList = new List<Campaign_Expression__c>();

        if(!campaignExpressionList.isEmpty()){
            for(Campaign_Expression__c campaignExpression :campaignExpressionList){
                if(campaignExpression.Segment__c.equals('ME')&&campaignSegment.equals('ME')){
                    conditionList.add(new CampaignCondition(campaignExpression,fieldSelectOption));
                    campaignExpressionForDeleteList.add(campaignExpression);
                }else if(campaignExpression.Segment__c.equals('SE')&&campaignSegment.equals('SE')){
                    conditionList.add(new CampaignCondition(campaignExpression,fieldSelectOption));
                    campaignExpressionForDeleteList.add(campaignExpression);
                }
            }
            if(conditionList.isEmpty()){
                conditionList.add(new CampaignCondition(indexRow,fieldSelectOption,fieldsTypeMap));
            }
            indexRow = conditionList.size();
        }else{
            conditionList.add(new CampaignCondition(indexRow,fieldSelectOption,fieldsTypeMap));
        }
    }

    public List<SelectOption> getSegmentSelectOption() {
        List<SelectOption> segmentSelectOption = new List<SelectOption>();
        segmentSelectOption.add(new SelectOption('ME', 'ME'));
        segmentSelectOption.add(new SelectOption('SE', 'SE'));

        campaignSegment = segmentSelectOption[0].getValue();
        return segmentSelectOption;
    }

    public List<SelectOption> getOperatorSelectOption() {
        List<SelectOption> operatorSelectOption = new List<SelectOption>();
        operatorSelectOption.add(new SelectOption('=', 'Equal'));
        operatorSelectOption.add(new SelectOption('!=', 'Not Equal to'));
        operatorSelectOption.add(new SelectOption('<', 'Less Than'));
        operatorSelectOption.add(new SelectOption('>', 'Greater Than'));
        operatorSelectOption.add(new SelectOption('<=', 'Less Or Equal'));
        operatorSelectOption.add(new SelectOption('>=', 'Greater Or Equal'));
        return operatorSelectOption;
    }

    public void setupFieldsListAndType(){
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
        
        for(Schema.SObjectField allField :fieldMap.values()){
            Schema.describefieldresult dfield = allField.getDescribe();
            String labelName = dfield.getLabel()+' ['+dfield.getname()+']';
            fieldSelectOption.add(new SelectOption(dfield.getname(), labelName));

            fieldsTypeMap.put(dfield.getname(),String.valueOf(dfield.getType()));
        }
        fieldSelectOption.sort();
    }
    public void setType(){
        if(!conditionList.isEmpty()){
            for(CampaignCondition camCondition:conditionList){
                if(camCondition.indexOfRec == toSetTypeIdent){
                    camCondition.campaignExpression.Field_Type__c = fieldsTypeMap.get(camCondition.campaignExpression.Field__c);
                    break;
                }  
            }
        }
    }

    public void addRow(){
        if(!conditionList.isEmpty()){
            if(indexRow < 10){
                conditionList.add(new CampaignCondition(++indexRow,fieldSelectOption,fieldsTypeMap));
            }else if(indexRow == 10){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Limit_of_Condition));
            }
        }else{
            indexRow = 1;
            conditionList.add(new CampaignCondition(indexRow,fieldSelectOption,fieldsTypeMap));
        }
    }

    public void deleteRow(){
        Integer toDelPos=-1;
        for (Integer idx=0; idx<conditionList.size(); idx++)
        {
            if(conditionList[idx].indexOfRec==toDelIdent){
                toDelPos=idx;
            }
        }
        if(-1!=toDelPos){
            conditionList.remove(toDelPos);
            Integer intForResetIndex = 1;

            for(CampaignCondition resetIndexOfRec :conditionList){
                resetIndexOfRec.indexOfRec = intForResetIndex;
                indexRow = intForResetIndex; 
                intForResetIndex++;
            }
        }
    }
    
    public PageReference save(){
        isShowError = true;
        Boolean validateValue = true;
        errorMsgBookingCode = null;
        String errMessage;
        List<Campaign_Expression__c> newCampaignExpresList = new List<Campaign_Expression__c>();
           
        //String linkPage = '/apex/SME_CampaignCondition';
        //PageReference nextPage = new PageReference(linkPage);

        if(String.isEmpty(bookingCode)){
            errMessage = 'New Booking Code: You must enter a value';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMessage));
        }else{
            if(!conditionList.isEmpty()){
                for(CampaignCondition camCondition:conditionList){
                    camCondition.errorMsgValue = null;
                    String fieldType = camCondition.campaignExpression.Field_Type__c;

                    if(camCondition.campaignExpression.Field_Type__c.equals('CURRENCY')||camCondition.campaignExpression.Field_Type__c.equals('PERCENT')||camCondition.campaignExpression.Field_Type__c.equals('DOUBLE')){
                        
                        if(!isNumeric(camCondition.campaignExpression.Value__c)){
                            camCondition.errorMsgValue = Label.Field_Type_Is_String;
                            validateValue = false;
                        }
                    }
                    if(validateValue){
                        Campaign_Expression__c objCampaignExpress = new Campaign_Expression__c();
                        //objCampaignExpress = camCondition.campaignExpression;
                        //objCampaignExpress.Id = null;
                        objCampaignExpress.Segment__c = campaignSegment;
                        objCampaignExpress.Name = campaignSegment+'_'+camCondition.indexOfRec;
                        objCampaignExpress.Field__c = camCondition.campaignExpression.Field__c;
                        objCampaignExpress.Field_Type__c = camCondition.campaignExpression.Field_Type__c;
                        objCampaignExpress.Operator__c = camCondition.campaignExpression.Operator__c;
                        objCampaignExpress.Object__c = camCondition.campaignExpression.Object__c;
                        objCampaignExpress.Value__c = camCondition.campaignExpression.Value__c;

                        newCampaignExpresList.add(objCampaignExpress);
                    }
                }
                if(!newCampaignExpresList.isEmpty()){
                    String conditionQueryString = null;
                    Boolean validateQuery = false;
                    if(!String.isEmpty(campaignConditionString)){
                        conditionQueryString = CampaignRewardCalculation.getConditionQueryString(campaignConditionString,newCampaignExpresList,campaignSegment);
                        validateQuery = CampaignRewardCalculation.validateQueryString(selectedObject,conditionQueryString);
                        if(validateQuery){
                            delete campaignExpressionForDeleteList;

                            insert newCampaignExpresList;

                            updeteCampaignSetting();

                            //nextPage.setRedirect(true);
                            //return nextPage;
                            isShowError = false;
                        }else{
                            errMessage = Label.Please_Check_Condition;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMessage));
                        }
                    }else{
                        errMessage = Label.Condition_Is_Null;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMessage));
                    }
                    
                }
            }else{
                if(String.isEmpty(campaignConditionString)){
                    //Delete record
                    //delete campaignExpressionList;
                    delete campaignExpressionForDeleteList;
                    updeteCampaignSetting();

                    //nextPage.setRedirect(true);
                    //return nextPage;
                    isShowError = false;
                }else{
                    errMessage = Label.Condition_Is_Null;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMessage));
                }
            }
        }
        return null;
    }
    public void updeteCampaignSetting(){
        for(Campaign_Setting__c camSet :campaignSettingList){
            camSet.NewBooking_Code__c = bookingCode;
            if(campaignSegment.equals('SE')){
                camSet.New_Booking_Condition_SE__c = (campaignConditionString==null) ? null : campaignConditionString.toUpperCase();
            }else if(campaignSegment.equals('ME')){
                camSet.New_Booking_Condition_ME__c = (campaignConditionString==null) ? null : campaignConditionString.toUpperCase();
            }
        }
        update campaignSettingList;
    }
    public static Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE;
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }

    public class CampaignCondition {
        public Integer indexOfRec {get;set;}
        public String errorMsgValue {get; set;}

        public List<SelectOption> fieldSelectOption{get;set;}
        public Campaign_Expression__c campaignExpression {get; set;}

        public CampaignCondition(Integer indexCam,List<SelectOption> addFields,Map<String,String> fieldTypes){
            indexOfRec = indexCam;
            fieldSelectOption = addFields;
            errorMsgValue = null;

            campaignExpression = new Campaign_Expression__c();
            campaignExpression.Field__c = addFields[0].getValue();
            campaignExpression.Operator__c = '=';
            campaignExpression.Object__c = CampaignConditionController.selectedObject;
            campaignExpression.Field_Type__c = fieldTypes.get(campaignExpression.Field__c);
        }
        public CampaignCondition(Campaign_Expression__c camExpres,List<SelectOption> addFields){
            indexOfRec = Integer.valueOf(camExpres.name.substring(3));
            fieldSelectOption = addFields;
            errorMsgValue = null;
            
            campaignExpression = new Campaign_Expression__c();
            campaignExpression = camExpres;
        }
    }
}