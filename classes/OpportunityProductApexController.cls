public with sharing class OpportunityProductApexController {
    public static Set<String> manualPicklistFields = new Set<String>{
        Schema.SObjectType.OpportunityLineItem.fields.Product_Results__c.getName(),
        Schema.SObjectType.OpportunityLineItem.fields.Reasons__c.getName()
    };

    public class Response{
        @Auraenabled
        public String recordId;
        @Auraenabled
        public Boolean success;
        @Auraenabled
        public String msg;
    }

    public class LightningTable {
        public LightningTable(String lnLabel, String lnFieldName, String lnType, Boolean lnIsRequired) {
            this.lnLabel     = lnLabel;
            this.lnFieldName = lnFieldName;
            this.lnType      = lnType;
            this.lnIsRequired = lnIsRequired;
        }
        
        @AuraEnabled
        public String lnLabel;
        @AuraEnabled
        public String lnFieldName;
        @AuraEnabled
        public String lnType;
        @AuraEnabled
        public Boolean lnIsRequired;
    }

    public class OpportunityProductWrapper {
        @AuraEnabled
        public OpportunityLineItem oppLineItem;
        @AuraEnabled
        public Application_History__c application;
        @AuraEnabled
        public Product2 Product2;
    }

    public class OpportunityProductComponent {
        public OpportunityProductComponent(String objectName) {
            this.fields     = new List<StandardFieldSet>();
            this.lightningTables = new List<LightningTable>();
            this.isError    = false;
            this.objectName = objectName;
            this.isMobile   = UserInfo.getUiThemeDisplayed() == 'Theme4t' ? true : false;
        }
        
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public List<StandardFieldSet> fields;
        @AuraEnabled
        public List<LightningTable> lightningTables;
        @AuraEnabled
        public Boolean isMobile;
        @AuraEnabled
        public List<OpportunityProductWrapper> oppWrapperList;
        @AuraEnabled
        public Product2 existingProduct;
        @AuraEnabled
        public Application_History__c existingApplication;
        @AuraEnabled
        public List<Product2> products;
        @AuraEnabled
        public String queryCondition;
        @AuraEnabled
        public Boolean isError;
        @AuraEnabled
        public String errorMessage;
    }

    @AuraEnabled
    public static Boolean checkIsMobile() {
        Boolean isMobile = UserInfo.getUiThemeDisplayed() == 'Theme4t' ? true : false;
        return isMobile;
    }

    @AuraEnabled
    public static OpportunityProductComponent initialEditProduct(String jobId) {
        User currentUser = UserService.getCurrentUserInfo();
        String fieldSetName = getFieldSetNameByProfile(currentUser.Profile.Name);

        OpportunityProductComponent oppProductComponent = new OpportunityProductComponent('OpportunityLineItem');
        getFields(oppProductComponent, fieldSetName);
        oppProductComponent.oppWrapperList = getOpportunityWrappers(jobId, oppProductComponent);
        return oppProductComponent;
    }

    @AuraEnabled
    public static OpportunityProductComponent initialProductList() {
        User currentUser = UserService.getCurrentUserInfo();
        String fieldSetName = getFieldSetNameByProfile(currentUser.Profile.Name);
        String queryCondition = getQueryConditionByProfile(currentUser.Profile.Name);

        OpportunityProductComponent oppProductComponent = new OpportunityProductComponent('Product2');
        getFields(oppProductComponent, fieldSetName);
        if(!String.isEmpty(queryCondition)) {
            oppProductComponent.queryCondition = 'Product_Segment__c includes (\'' + queryCondition + '\')';
        }
        oppProductComponent.products = getRecord(oppProductComponent);
        return oppProductComponent;
    }

    @AuraEnabled
    public static OpportunityProductComponent initialProductResult() {
        User currentUser = UserService.getCurrentUserInfo();
        String fieldSetName = getFieldSetNameByProfile(currentUser.Profile.Name);

        OpportunityProductComponent oppProductComponent = new OpportunityProductComponent('OpportunityLineItem');
        getFields(oppProductComponent, fieldSetName);
        return oppProductComponent;
    }

    @AuraEnabled
    public static OpportunityProductComponent initialProductResultRow(String opportunityProduct) {
        User currentUser = UserService.getCurrentUserInfo();
        String fieldSetName = getFieldSetNameByProfile(currentUser.Profile.Name);
        OpportunityLineItem mOpportunityProduct = (OpportunityLineItem) JSON.deserialize(opportunityProduct, OpportunityLineItem.class);

        OpportunityProductComponent oppProductComponent = new OpportunityProductComponent('OpportunityLineItem');
        getFields(oppProductComponent, fieldSetName);
        oppProductComponent.existingProduct         = getProductFromOppLineItem(mOpportunityProduct);
        oppProductComponent.existingApplication     = getAppFromOppLineItem(mOpportunityProduct);
        return oppProductComponent;
    }

    @AuraEnabled
    public static SObject[] getProductFromInput(String inputSearch, String queryCondition, String lightningTables) {
        List<LightningTable> lnTables = (List<LightningTable>) JSON.deserialize(lightningTables, List<LightningTable>.class);
        List<String> queryFields = new List<String>();
        for(LightningTable lnTable : lnTables) {
            queryFields.add(lnTable.lnFieldName);
        }
        addQueryField(queryFields, 'Product_Keywords__c');
        String inputSearchCondition = getConditionFromInputSearch(queryFields, inputSearch);
        addQueryField(queryFields, 'Id');
        addQueryField(queryFields, 'Product_Code__c');

        Map<Id, sObject> mapSObject = new Map<Id, sObject>();
        String recordSOQL = 'SELECT (SELECT Id, IsActive FROM PriceBookEntries), ' + String.join(queryFields, ',') + 
        ' FROM Product2 WHERE IsActive = true AND (' + inputSearchCondition + ')';
        if(queryCondition != '') {
            recordSOQL = recordSOQL + ' AND ' + queryCondition;
        }
        recordSOQL = recordSOQL + ' ORDER BY Name ASC';
        List<Product2> newResult = (List<Product2>) Database.query(recordSOQL);
        for(Product2 eachProduct : newResult) {
            if(eachProduct.PriceBookEntries != null && eachProduct.PriceBookEntries.size() > 0) {
                for(PriceBookEntry eachPriceBook : eachProduct.PriceBookEntries) {
                    if(eachPriceBook.IsActive) {
                        mapSObject.put(eachProduct.Id, eachProduct);
                        break;
                    }
                }
            }
        }
        return mapSObject.values();
    }

    @AuraEnabled
    public static List<Global_Master_Data__c> getProductSettings(String productCode) {
        return [SElECT ProductResult_Product_Result__c, ProductResult_Reason__c, ProductResult_Require_Reason__c, ProductResult_Require_Remark__c, ProductResult_Product_Code__c FROM Global_Master_Data__c WHERE ProductResult_Product_Code__c = :productCode AND RecordType.DeveloperName='ProductResult'];
    }

    @AuraEnabled
    public static Response saveOpportunityProduct(String oppProductWrapper) {
        List<OpportunityProductWrapper> oppProductWrapperList = (List<OpportunityProductWrapper>) JSON.deserialize(oppProductWrapper, List<OpportunityProductWrapper>.class);
        
        Response res = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
            for(OpportunityProductWrapper eachWrapper : oppProductWrapperList) {
                oppProductList.add(eachWrapper.oppLineItem);
            }
            res.success = true;
            insert oppProductList;
        } catch (DmlException dmlEx) {
            Database.rollback(sp);
            res.success = false;
            res.msg = dmlEx.getDmlMessage(0);
        } catch(Exception ex){
            Database.rollback(sp);
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }

    @AuraEnabled
    public static Response deleteApplication(String applicationIds) {
        Response res = new Response();
        List<String> applicationIdList = (List<String>) JSON.deserialize(applicationIds, List<String>.class);
        try {
            if(!applicationIdList.isEmpty()) {
                delete [SELECT Id FROM Application_History__c WHERe Id IN :applicationIdList];
            }
            res.success = true;
        } catch (DmlException dmlEx) {
            res.success = false;
            res.msg = dmlEx.getDmlMessage(0);
        } catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }

    @AuraEnabled
    public static Response updateOpportunityProduct(String oppProductWrapper, String jobId) {
        List<OpportunityProductWrapper> oppProductWrapperList = (List<OpportunityProductWrapper>) JSON.deserialize(oppProductWrapper, List<OpportunityProductWrapper>.class);

        Response res = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            Map<Id, OpportunityLineItem> allOppProductMap = new Map<Id, OpportunityLineItem>();
            for(OpportunityProductWrapper eachWrapper : oppProductWrapperList) {
                allOppProductMap.put(eachWrapper.oppLineItem.Id, eachWrapper.oppLineItem);
            }

            // Check is updateable
            User currentUser = UserService.getCurrentUserInfo();
            String fieldSetName = getFieldSetNameByProfile(currentUser.Profile.Name);
            OpportunityProductComponent oppProductComponent = new OpportunityProductComponent('OpportunityLineItem');
            getFields(oppProductComponent, fieldSetName);
            List<StandardFieldSet> fields = oppProductComponent.fields;
            List<OpportunityLineItem> existingOppProducts = getExistingOpportunityProducts(jobId, oppProductComponent);
            List<OpportunityLineItem> updatedOppProduct = new List<OpportunityLineItem>();
            for(OpportunityLineItem existingRecord : existingOppProducts) {
                OpportunityLineItem eachOppProduct = allOppProductMap.get(existingRecord.Id);
                if(isUpdateRecord(eachOppProduct, existingRecord, fields)) {
                    updatedOppProduct.add(eachOppProduct);
                }
            }

            res.success = true;
            update updatedOppProduct;
        } catch (DmlException dmlEx) {
            Database.rollback(sp);
            res.success = false;
            res.msg = dmlEx.getDmlMessage(0);
        } catch(Exception ex){
            Database.rollback(sp);
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }

    private static String getConditionFromInputSearch(List<String> queryFields, String inputSearch) {
        String queryCondition = '';
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Product2.fields.getMap();
        for (Integer i = 0; i < queryFields.size(); i++) {
            String queryField = queryFields.get(i);
            Schema.SObjectField field = fieldsMap.get(queryField);

            if(field.getDescribe().getType() == Schema.DisplayType.MultiPicklist) {
                if(i == 0) {
                    queryCondition += (queryField + ' INCLUDES (\'' + inputSearch +'\')');
                } else {
                    queryCondition += (' OR ' + queryField + ' INCLUDES (\'' + inputSearch +'\')');
                }
            } else if(field.getDescribe().getType() == Schema.DisplayType.String ||
                field.getDescribe().getType() == Schema.DisplayType.Picklist ||
                field.getDescribe().getType() == Schema.DisplayType.TextArea
                ){
                if(i == 0) {
                    queryCondition += (queryField + ' LIKE \'%' + inputSearch +'%\'');
                } else {
                    queryCondition += (' OR ' + queryField + ' LIKE \'%' + inputSearch +'%\'');
                }
            }
        }

        return queryCondition;
    }

    private static Boolean isUpdateRecord(OpportunityLineItem checkRecord, OpportunityLineItem existingRecord, List<StandardFieldSet> fields) {
        Boolean isUpdated = false;
        for(StandardFieldSet eachField : fields) {
            Boolean newValueIsNull = false;
            Boolean existingValueIsNull = false;
            if(checkRecord.get(eachField.APIName) == null || checkRecord.get(eachField.APIName) == '') {
                newValueIsNull = true;
            }
            if(existingRecord.get(eachField.APIName) == null || existingRecord.get(eachField.APIName) == '') {
                existingValueIsNull = true;
            }
            if(newValueIsNull && existingValueIsNull) {
                continue;
            }
            if(checkRecord.get(eachField.APIName) != existingRecord.get(eachField.APIName)) {
                isUpdated = true;
                break;
            }
        }
        return isUpdated;
    }

    private static void addQueryField(List<String> queryFields, String newField) {
        if(!queryFields.contains(newField)) {
            queryFields.add(newField);
        }
    }

    private static void getFields(OpportunityProductComponent oppProductComponent, String fieldSetName) {
        Schema.SObjectType objectType = null;
        List<LightningTable> lightningTables = new List<LightningTable>();
        
        if (String.isNotBlank(oppProductComponent.objectName)) {
            objectType = Schema.getGlobalDescribe().get(oppProductComponent.objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<StandardFieldSet> fieldSetList = new List<StandardFieldSet>();
        if(fieldSet != null) {
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
            
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                StandardFieldSet eachFieldSet = new StandardFieldSet(fieldSetMember);
                lightningTables.add(new LightningTable(eachFieldSet.Label, eachFieldSet.APIName, 'text', fieldSetMember.getRequired()));
                Schema.DescribeFieldResult fieldResult = fieldMap.get(eachFieldSet.APIName).getDescribe();
                if(fieldResult.getType().name() == 'Picklist'){
                    eachFieldSet.isPicklist = true;
                    eachFieldSet.picklistValues = new Map<String,String>();
                    Map<String,String> tempMapPickListValue = new Map<String,String>();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    tempMapPickListValue.put('','');
                    for( Schema.PicklistEntry eachValue : ple){
                        if(eachValue.isActive()) {
                            tempMapPickListValue.put(eachValue.getValue(),eachValue.getLabel());
                            if(eachValue.isDefaultValue()) {
                                eachFieldSet.DefaultValue = eachValue.getValue();
                            }
                        }
                    }
                    eachFieldSet.picklistValues = tempMapPickListValue;
                }
                if(manualPicklistFields.contains(eachFieldSet.APIName)){
                    eachFieldSet.isManualPicklist = true;
                } 

                fieldSetList.add(eachFieldSet);
            }
        }
        oppProductComponent.fields = fieldSetList;
        oppProductComponent.lightningTables = lightningTables;
    }

    public static List<OpportunityProductWrapper> getOpportunityWrappers(String jobId, OpportunityProductComponent oppProductComponent) {
        List<OpportunityProductWrapper> oppWrapperList = new List<OpportunityProductWrapper>();
        if (!String.isEmpty(jobId)) {
            List<OpportunityLineItem> records = getExistingOpportunityProducts(jobId, oppProductComponent);
            for(OpportunityLineItem oppLineItem : records) {
                OpportunityProductWrapper eachWrapper = new OpportunityProductWrapper();
                eachWrapper.oppLineItem = oppLineItem;
                oppWrapperList.add(eachWrapper);
            }
        } 
        return oppWrapperList;
    }

    private static List<OpportunityLineItem> getExistingOpportunityProducts(String jobId, OpportunityProductComponent oppProductComponent) {
        List<String> fieldsToQuery = new List<String>();
        for (StandardFieldSet f : oppProductComponent.fields) {
            fieldsToQuery.add(f.APIName);
        }
        addQueryField(fieldsToQuery, 'Id');
        addQueryField(fieldsToQuery, 'Status__c');
        addQueryField(fieldsToQuery, 'Status_CBS__c');

        String recordSOQL = 'SELECT ' + String.join(fieldsToQuery, ',') +
                            ' FROM ' + oppProductComponent.objectName +
                            ' WHERE OpportunityId = :jobId';
        List<OpportunityLineItem> records = (List<OpportunityLineItem>) Database.query(recordSOQL);
        return records;
    }

    public static Product2 getProductFromOppLineItem(OpportunityLineItem oppLineItem) {
        Product2 targetProduct = new Product2();
        if (oppLineItem.Product2Id != null) {
            targetProduct = [SELECT Id, Name, Product_Code__c FROM Product2 WHERE Id = :oppLineItem.Product2Id];
        } 
        return targetProduct;
    }

    public static Application_History__c getAppFromOppLineItem(OpportunityLineItem oppLineItem) {
        Application_History__c targetApp = new Application_History__c();
        if (oppLineItem.Application_CBS__c != null) {
            targetApp = [SELECT Id, Name, OppName__c FROM Application_History__c WHERE Id = :oppLineItem.Application_CBS__c];
        }  else if(oppLineItem.Application__c != null) {
            targetApp = [SELECT Id, Name, OppName__c FROM Application_History__c WHERE Id = :oppLineItem.Application__c];
        }
        return targetApp;
    }

    public static List<Product2> getRecord(OpportunityProductComponent oppProductComponent) {
        List<Product2> records = new List<Product2>();
        List<String> fieldsToQuery = new List<String>();
        for (StandardFieldSet f : oppProductComponent.fields) {
            fieldsToQuery.add(f.APIName);
        }
        addQueryField(fieldsToQuery, 'Product_Code__c');
        addQueryField(fieldsToQuery, 'Id');

        String recordSOQL = 'SELECT ' + String.join(fieldsToQuery, ',') + ',(SELECT Id, IsActive FROM PriceBookEntries) FROM Product2 WHERE IsActive = true';
        if(!String.isEmpty(oppProductComponent.queryCondition)) {
            recordSOQL += ' AND ' + oppProductComponent.queryCondition;
        }
        recordSOQL += ' ORDER BY Name ASC';
        List<Product2> queryResults = (List<Product2>) Database.query(recordSOQL);
        for(Product2 eachProduct : queryResults) {
            if(eachProduct.PriceBookEntries != null && eachProduct.PriceBookEntries.size() > 0) {
                for(PriceBookEntry eachPriceBook : eachProduct.PriceBookEntries) {
                    if(eachPriceBook.IsActive) {
                        records.add(eachProduct);
                        break;
                    }
                }
            }
        }
        return records;
    }

    private static String getFieldSetNameByProfile(String profileName) {
        String fieldSetName = 'SME_Field_Set';
        if(GlobalConstants.PROFILE_SME_SET.contains(profileName)) {
            fieldSetName = 'SME_Field_Set';
        } else if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) {
            fieldSetName = 'CBS_Field_Set';
        } else if(GlobalConstants.PROFILE_RBS_SET.contains(profileName) || GlobalConstants.PROFILE_AF_SET.contains(profileName)) {
            fieldSetName = 'RBS_Field_Set';
        }

        return fieldSetName;
    }

    private static String getQueryConditionByProfile(String profileName) {
        String queryCondition = '';
        if(GlobalConstants.PROFILE_SME_SET.contains(profileName)) {
            queryCondition = 'SME';
        } else if(GlobalConstants.PROFILE_CBS_SET.contains(profileName)) {
            queryCondition = 'CBS';
        } else if(GlobalConstants.PROFILE_RBS_SET.contains(profileName) || GlobalConstants.PROFILE_AF_SET.contains(profileName)) {
            queryCondition = 'RBS';
        }

        return queryCondition;
    }
}