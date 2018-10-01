public with sharing class QuickApplicationHistoryController  {
    private static Set<String> CBSFieldSetList = new Set<String>{'CBS_Application_Information', 'CBS_Application_App_Info1', 'CBS_Application_App_Info2','CBS_Application_App_Info3','CBS_Application_Product_Program','CBS_Application_SO_UW_Information','CBS_Application_SLA','CBS_Application_System_Information'};
    private static Set<String> SMEFieldSetList = new Set<String>{'SME_Application_Information', 'SME_Application_App_Num', 'SME_Application_App_Type','SME_Application_Application_RM','SME_Application5_App_Info','SME_Application6_SLA','SME_Application_Product','SME_Application_SO_UW_SO_UW_Informatio'};
    private static Set<String> CBSSectionLabel = new Set<String>{
        'Information',
        'App Info : กรอกฝั่งซ้ายเพื่อให้ Sales Smart Gen เลข App',
        'App Info : เลขApp',
        'App info : อื่นๆ (กรณี DLA กรอกให้ครบ)',
        'Product Program',
        'SO/UW Information',
        'SLA',
        'System Information'
    };
    private static Set<String> SMESectionLabel = new Set<String>{
        'Information',
        'หมายเลข Application (Application Number)',
        'ประเภท Application (Application Type)',
        'ข้อมูล Application (RM) [Application Information (RM)]',
        'ข้อมูล Application (Application Information)',
        'ข้อมูล SLA',
        'Product Program',
        'ข้อมูล SO/UW (SO/UW Information)'
    };
    private static Map<String, String> helpTextList = new Map<String, String>();
    
    @AuraEnabled
    public static FieldSetForm getForm(Application_History__c appRecord) {
        FieldSetForm form = new FieldSetForm();
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        String profileName = currentUser.Profile.Name;
        try {
            System.debug(appRecord);
            if(appRecord == null){
                appRecord = new Application_History__c();
            }

            List<StandardFieldSet>  allField = new List<StandardFieldSet>();
            Map<String, List<StandardFieldSet>> allFieldMap = getFieldsMap(profileName);
            form.SectionLabel = getSectionLabel(profileName);
            form.Fields = allFieldMap;
            for(String eachKey : allFieldMap.keySet()){
                allField.addAll(allFieldMap.get(eachKey));
            }

            form.FieldsList = allField;
            form.HelpTextList = helpTextList;
            if(appRecord !=null && appRecord.OppName__c !=null){
                System.debug('appRecord.OppName__c :'+appRecord.OppName__c);
                form.Job = [SELECT Id, Name FROM Opportunity WHERE Id = :appRecord.OppName__c];
            }

            if(appRecord !=null && appRecord.Business_Code__c !=null){
                form.BusinessCode = [SELECT Id, Name FROM Business_Code__c WHERE Id = :appRecord.Business_Code__c];
            }

            if(appRecord !=null && appRecord.LPM_Customer__c !=null){
                form.LpmCustomer = [SELECT Id, Name, LPM__r.Name, CIS__r.CIS__c FROM LPM_Customer__c WHERE Id = :appRecord.LPM_Customer__c];
            }
            //Id jobId = Id.valueOf('0060l000004KyN0AAK');
            //Id businessCodeId = Id.valueOf('0060l000004KyN0AAK');
            
            
            //newApp.OppName__c = jobId;
            //newApp.App_Num_CMAS__c = '000000000123123';
            form.ApplicationHistory = appRecord;
            form.isError = false;
        } catch(Exception e) {
            form.isError = true;
            form.ErrorText = e.getStackTraceString();
        }
        return form;
    }

    public static Set<String> getSectionLabel(String profileName) {
        Set<String> SectionLabelList = new Set<String>();
        if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) {
            SectionLabelList = CBSSectionLabel;
        } else {
            SectionLabelList = SMESectionLabel;
        }
        return SectionLabelList;
    }

    public static Set<String> getFieldSetList(String profileName) {
        Set<String> fieldSetList = new Set<String>();
        if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) {
            fieldSetList = CBSFieldSetList;
        } else {
            fieldSetList = SMEFieldSetList;
        }
        return fieldSetList;
    }

    public static Map<String, List<StandardFieldSet>> getFieldsMap(String profileName) {
        Set<String> fieldSetList = getFieldSetList(profileName);
        if(fieldSetList == null || fieldSetList.isEmpty()) {
            return new Map<String, List<StandardFieldSet>>();
        }

        Map<String, List<StandardFieldSet>> fieldList = new Map<String, List<StandardFieldSet>>();
        Schema.sObjectType appObjectType = Application_History__c.sObjectType;
        Schema.DescribeSObjectResult objectDescribe = appObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Integer index = 0;

        for(String fieldSetName : fieldSetList) {
            index++;
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
            List<StandardFieldSet> fields = new List<StandardFieldSet>();
            for(Schema.FieldSetMember eachFieldSetMember : fieldSetMembers) {
                StandardFieldSet field = new StandardFieldSet(eachFieldSetMember);
                Schema.DescribeFieldResult fieldResult = fieldMap.get(field.APIName).getDescribe();
                if(fieldResult.getType().name() == 'Picklist' && fieldResult.isUpdateable()){
                    field.isPicklist = true;
                    field.picklistValues = new Map<String,String>();
                    Map<String,String> tempMapPickListValue = new Map<String,String>();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    tempMapPickListValue.put('','');
                    for( Schema.PicklistEntry eachValue : ple) {
                        if(GlobalConstants.PROFILE_CBS_SET.contains(profileName) && eachValue.getLabel() == 'แก้ไขหนี้') continue;
                        if(eachValue.isActive()) tempMapPickListValue.put(eachValue.getValue(),eachValue.getLabel());
                    }
                    field.picklistValues = tempMapPickListValue;
                } else if(fieldResult.isCalculated() || !fieldResult.isUpdateable()) {
                    field.Type = 'FORMULA';
                }
                fields.add(field);

                String helpText = fieldResult.getInlineHelpText();
                if(!String.isBlank(helpText)) {
                    helpTextList.put(field.APIName,helpText);
                }
            }

            fieldList.put('section'+index, fields);
        }

        return fieldList;
    }
        
    @AuraEnabled
    public static ResultResponse save(Application_History__c applicationHistory) {
        ResultResponse response = new ResultResponse();
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        String profileName = currentUser.Profile.Name;
        try {
            Schema.DescribeSObjectResult objectDescribe = Application_History__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
            List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();

            for(String fieldSetName : getFieldSetList(profileName)) {
                Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
                fieldSetMembers.addAll(fieldSet.getFields());
            }

            Application_History__c resultAppHist = new Application_History__c();
            for(Schema.FieldSetMember eachFieldSetMember : fieldSetMembers) {
                String APIName = eachFieldSetMember.fieldPath;
                Schema.DescribeFieldResult fieldResult = fieldMap.get(APIName).getDescribe();
                if(!fieldResult.isCalculated() && fieldResult.isUpdateable() && applicationHistory.get(APIName) != null) {
                    resultAppHist.put(APIName, applicationHistory.get(APIName));
                }
            }
            if(!fieldSetMembers.isEmpty()) {
                insert resultAppHist;
            }
            response.isSuccess = true;
            response.applicationHistory = [SELECT Id, Name, App_Num_Selected__c FROM Application_History__c WHERE Id = :resultAppHist.Id];
        } catch(Exception e) {
            response.isSuccess = false;
            if(e.getMessage().toLowerCase().contains('insufficient access')){
                response.message = Label.Not_Allow_to_update_record;
            }else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                response.message = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',': [');
            }else{
                response.message = e.getMessage();
            }
        }
        return response;
    }

    public class FieldSetForm {
        @AuraEnabled
        public Map<String, List<StandardFieldSet>> Fields { get; set; }

        @AuraEnabled
        public List<StandardFieldSet> FieldsList { get; set; }

        @AuraEnabled
        public Map<String, String> HelpTextList { get; set; }

        @AuraEnabled
        public Set<String> SectionLabel { get; set; }

        @AuraEnabled
        public Opportunity Job { get; set; }

        @AuraEnabled
        public Business_Code__c BusinessCode { get; set; }

        @AuraEnabled
        public Application_History__c ApplicationHistory { get; set; }

        @AuraEnabled
        public LPM_Customer__c LpmCustomer { get; set; }

        @AuraEnabled
        public Boolean isError { get; set; }

        @AuraEnabled
        public String ErrorText { get; set; }
        
        public FieldSetForm() {
            Fields = new Map<String, List<StandardFieldSet>>();
        }
    }

    public class ResultResponse {
        @AuraEnabled
        public String message;

        @AuraEnabled
        public Boolean isSuccess;

        @AuraEnabled
        public Application_History__c applicationHistory;

        public ResultResponse() {
            message = null;
            isSuccess = true;
            applicationHistory = new Application_History__c();
        }
    }
}