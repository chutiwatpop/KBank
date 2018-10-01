public with sharing class EditOpportunityProductController {
    private static final Set<String> CBSFieldSetList = new Set<String>{'CBS_Opportunity_Product_Layout', 'CBS_Opportunity_Product_Layout_2', 'CBS_Opportunity_Product_Layout_3'};
    private static final Set<String> RBSFieldSetList = new Set<String>{'RBS_Opportunity_Product_Layout', 'RBS_Opportunity_Product_Layout_2', 'RBS_Opportunity_Product_Layout_3'};
    private static final Set<String> SMEFieldSetList = new Set<String>{'SME_Opportunity_Product_Layout', 'SME_Opportunity_Product_Layout_2', 'SME_Opportunity_Product_Layout_3'};
    //private static final Map<String, Set<String>> fieldSetListMapByProfile = new Map<String, Set<String>>{'CBS'=> CBSFieldSetList, 'RBS'=> RBSFieldSetList, 'SME'=> SMEFieldSetList};
    private static Boolean haveApplicationField = false;
    private static Boolean haveJobField = false;
    private static Boolean haveProductField = false;
    private static Boolean haveCreatedByField = false;
    private static Boolean haveLastModifiedByField = false;
    private static String appAPIName = '';//waiting for migrate

    @AuraEnabled
    public static FieldSetForm getForm(Id recordId) {
        FieldSetForm form = new FieldSetForm();
        try {
            form.Fields = getFields(recordId, getFieldSetList());
            form.Record = getRecord(recordId, form.Fields);
            OpportunityLineItem oppItem = (OpportunityLineItem) form.Record;
            String appId = '';//waiting for migrate
            if(String.isNotBlank(appAPIName)) {
                appId = (String) oppItem.get(appAPIName);
            }
            if(haveApplicationField && String.isNotBlank(appId)) {
                form.Application = [SELECT Id, Name FROM Application_History__c WHERE Id = :appId];
            }
            if(haveJobField) {
                form.Job = [SELECT Id, Name FROM Opportunity WHERE Id = :oppItem.OpportunityId];
            }
            if(haveProductField) {
                form.Product = [SELECT Id, Name, Product_Code__c FROM Product2 WHERE Id = :oppItem.Product2Id];
                getPicklistValue(form.Product.Product_Code__c, form);
            }
            if(haveCreatedByField) {
                form.CreatedBy = [SELECT Id, Name FROM User WHERE Id = :oppItem.CreatedById];
            }
            if(haveLastModifiedByField) {
                form.LastModifiedBy = [SELECT Id, Name FROM User WHERE Id = :oppItem.LastModifiedById];
            }
            form.isError = false;
        } catch(Exception e) {
            form.isError = true;
            form.ErrorText = e.getStackTraceString();
        }
        return form;
    }

    public static Set<String> getFieldSetList() {
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        String profileName = currentUser.Profile.Name;
        Set<String> fieldSetList = new Set<String>();
        if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) {
            fieldSetList = CBSFieldSetList;
        } else if(GlobalConstants.PROFILE_RBS_SET.contains(profileName) || GlobalConstants.PROFILE_AF_SET.contains(profileName) || profileName.startsWith('Telesales -')) {
            fieldSetList = RBSFieldSetList;
        } else {
            fieldSetList = SMEFieldSetList;
        }
        return fieldSetList;
    }

    public static Map<String, List<StandardFieldSet>> getFields(Id recordId, Set<String> fieldSetList) {
        if(recordId == null || fieldSetList == null || fieldSetList.isEmpty()) {
            return new Map<String, List<StandardFieldSet>>();
        }

        Map<String, List<StandardFieldSet>> fieldList = new Map<String, List<StandardFieldSet>>();
        Schema.SObjectType objectType = recordId.getSobjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
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
                if(field.APIName == 'Product_Results__c' || field.APIName == 'Reasons__c') {
                    field.isPicklist = true;
                } else if(fieldResult.getType().name() == 'Picklist' && fieldResult.isUpdateable()){
                    field.isPicklist = true;
                    field.picklistValues = new Map<String,String>();
                    Map<String,String> tempMapPickListValue = new Map<String,String>();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    tempMapPickListValue.put('','');
                    for( Schema.PicklistEntry eachValue : ple) {
                        if(eachValue.isActive()) tempMapPickListValue.put(eachValue.getValue(),eachValue.getLabel());
                    }
                    field.picklistValues = tempMapPickListValue;
                } else if(fieldResult.isCalculated() || !fieldResult.isUpdateable()) {
                    field.Type = 'FORMULA';
                }
                
                if(field.APIName == 'Application__c' || field.APIName == 'Application_CBS__c') {
                    haveApplicationField = true;
                    appAPIName = field.APIName;//waiting for migrate
                } else if(field.APIName == 'OpportunityId') {
                    haveJobField = true;
                } else if(field.APIName == 'Product2Id') {
                    haveProductField = true;
                } else if(field.APIName == 'CreatedById') {
                    haveCreatedByField = true;
                } else if(field.APIName == 'LastModifiedById') {
                    haveLastModifiedByField = true;
                }
                
                fields.add(field);
            }

            fieldList.put('section'+index, fields);
        }

        return fieldList;
    }
    
    public static SObject getRecord(Id recordId, Map<String, List<StandardFieldSet>> fieldList) {
        if(recordId == null || fieldList.isEmpty()) {
            return new OpportunityLineItem();
        }

        List<String> fieldsToQuery = new List<String>();
        for(String key : fieldList.keySet()) {
            List<StandardFieldSet> fields = fieldList.get(key);
            for(StandardFieldSet f : fields) {
                fieldsToQuery.add(f.APIName);
                if(f.APIName == 'CreatedById') {
                    fieldsToQuery.add('CreatedDate');
                }
                if(f.APIName == 'LastModifiedById') {
                    fieldsToQuery.add('LastModifiedDate');
                }
            }
        }
        
        Schema.SObjectType objectType = recordId.getSobjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        String objectAPIName = objectDescribe.getName();
        
        String recordSOQL = 'SELECT ' + String.join(fieldsToQuery, ',') +
                            '  FROM ' + objectAPIName +
                            ' WHERE Id = :recordId';

        SObject record = Database.query(recordSOQL);
        return record;
    }

    public static void getPicklistValue(String productCode, FieldSetForm result) {
        List<PicklistItem> productResultList = new List<PicklistItem>();
        Map<String, List<PicklistItem>> reasonMap = new Map<String, List<PicklistItem>>();
        List<Global_Master_Data__c> resultList = [SELECT ProductResult_Product_Code__c, ProductResult_Product_Result__c, ProductResult_Reason__c, ProductResult_Require_Reason__c, ProductResult_Require_Remark__c FROM Global_Master_Data__c WHERE ProductResult_Product_Code__c = :productCode AND RecordType.DeveloperName='ProductResult' ORDER BY ProductResult_Product_Result__c, ProductResult_Reason__c];

        String latestProductResult = '';
        for(Global_Master_Data__c eachResult : resultList) {
            String resultText = eachResult.ProductResult_Product_Result__c;
            String reasonText = eachResult.ProductResult_Reason__c;
            Boolean requiredReason = eachResult.ProductResult_Require_Reason__c;
            Boolean requiredRemark = eachResult.ProductResult_Require_Remark__c;
            if(latestProductResult != resultText) {
                PicklistItem productResultItem = new PicklistItem();
                productResultItem.Label = resultText;
                productResultItem.Value = resultText;
                productResultItem.requiredReason = requiredReason;
                productResultItem.requiredRemark = requiredRemark;
                productResultList.add(productResultItem);
                latestProductResult = resultText;
            }
            if(!String.isBlank(reasonText)) {
                PicklistItem reasonItem = new PicklistItem();
                reasonItem.Label = reasonText;
                reasonItem.Value = reasonText;
                reasonItem.requiredRemark = requiredRemark;
                if(reasonMap.containsKey(resultText)) {
                    reasonMap.get(resultText).add(reasonItem);
                } else {
                    reasonMap.put(resultText, new List<PicklistItem>{reasonItem});
                }
            }
        }
        result.ProductResultList = productResultList;
        result.ReasonList = reasonMap;
    }
    
    @AuraEnabled
    public static ResultResponse save(OpportunityLineItem opportunityProduct, Application_History__c applicationHistory) {
        ResultResponse response = new ResultResponse();
        try {
            Schema.DescribeSObjectResult objectDescribe = OpportunityLineItem.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
            List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();

            for(String fieldSetName : getFieldSetList()) {
                Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
                fieldSetMembers.addAll(fieldSet.getFields());
            }
            //System.debug('Save OppProduct:'+opportunityProduct);
            OpportunityLineItem resultOppProduct = new OpportunityLineItem();
            resultOppProduct.Id = opportunityProduct.Id;
            for(Schema.FieldSetMember eachFieldSetMember : fieldSetMembers) {
                String APIName = eachFieldSetMember.fieldPath;
                Schema.DescribeFieldResult fieldResult = fieldMap.get(APIName).getDescribe();
                if(!fieldResult.isCalculated() && fieldResult.isUpdateable() && fieldResult.getType().name().toLowerCase() != 'reference') {
                    //System.debug(APIName + ':'+opportunityProduct.get(APIName));
                    resultOppProduct.put(APIName, opportunityProduct.get(APIName));
                } else if(fieldResult.getType().name().toLowerCase() == 'reference' && (APIName == 'Application__c' || APIName == 'Application_CBS__c')) {
                    resultOppProduct.Application__c = applicationHistory.Id;
                    resultOppProduct.Application_CBS__c = applicationHistory.Id;//waiting for migrate
                }
            }
            if(!fieldSetMembers.isEmpty()) {
                update resultOppProduct;
            }
            response.isSuccess = true;
        } catch(Exception e) {
            response.isSuccess = false;
            //System.debug('Save Error:'+e.getMessage());
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

    @AuraEnabled
    public static ResultResponse clearNewApplicationHistory(List<Id> newIdList) {
        ResultResponse response = new ResultResponse();
        try {
            List<Application_History__c> newAppHist = [SELECT Id FROM Application_History__c WHERE Id IN :newIdList];
            //check item before delete
            //end
            delete newAppHist;
            response.isSuccess = true;
        } catch(Exception e) {
            response.isSuccess = false;
            response.message = e.getMessage();
        }
        return response;
    }

    public class FieldSetForm {
        @AuraEnabled
        public Map<String, List<StandardFieldSet>> Fields { get; set; }
        
        @AuraEnabled
        public SObject Record { get; set; }

        @AuraEnabled
        public Application_History__c Application { get; set; }

        @AuraEnabled
        public Opportunity Job { get; set; }

        @AuraEnabled
        public Product2 Product { get; set; }

        @AuraEnabled
        public User CreatedBy { get; set; }

        @AuraEnabled
        public User LastModifiedBy { get; set; }

        @AuraEnabled
        public Boolean isError { get; set; }

        @AuraEnabled
        public String ErrorText { get; set; }

        @AuraEnabled
        public List<PicklistItem> ProductResultList { get; set; }

        @AuraEnabled
        public Map<String, List<PicklistItem>> ReasonList { get; set; }
        
        public FieldSetForm() {
            Fields = new Map<String, List<StandardFieldSet>>();
            ProductResultList = new List<PicklistItem>();
            ReasonList = new Map<String, List<PicklistItem>>();
        }
    }

    public class PicklistItem {
        @AuraEnabled
        public String Label { get; set; }

        @AuraEnabled
        public String Value { get; set; }

        @AuraEnabled
        public Boolean requiredReason { get; set; }

        @AuraEnabled
        public Boolean requiredRemark { get; set; }
    }

    public class ResultResponse {
    	@AuraEnabled
        public String message;

        @AuraEnabled
        public Boolean isSuccess;

        public ResultResponse() {
            message = null;
            isSuccess = true;
        }
    }
}