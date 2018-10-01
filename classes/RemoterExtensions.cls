/**
* @author komsan.wi@beryl8.com
* @25/03/2015 create new
*/
public class RemoterExtensions {
    public User currentUser{get;set;}
    public String rcCode{get{return currentUser.RC_Code__c;}}
    public String empId{get{return currentUser.Employee_ID__c;}}
    public String userLowerSet {get{
        List<User> userList = new List<User>();
        userList = [SELECT Id FROM User WHERE ManagerId = :UserInfo.getUserId()];
        Map<String,User> userMap = new Map<String,User>(userList);
        return JSON.serialize(userMap.keySet());
    }}
    @RemoteAction
    public static List<ModelExtensions.FieldInfo> describeFields(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new ModelExtensions.DescribeException('No SObject named ' + objName + ' found');
        }
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();

        List<ModelExtensions.FieldInfo> result = new List<ModelExtensions.FieldInfo>();
        for (String field : fieldNames) {
            if (!fieldMap.containsKey(field)) {
                throw new ModelExtensions.DescribeException('No field named ' + field + ' found in SObject ' + objName);
            }
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            ModelExtensions.FieldInfo fi = new ModelExtensions.FieldInfo();
            fi.name = field;
            fi.modifiable = dfr.isCreateable() | dfr.isUpdateable();
            fi.sortable = dfr.isSortable();
            fi.nillable = dfr.isNillable();
            fi.fieldType = String.valueOf(dfr.getType()).toLowerCase();
            fi.locked = false;
            fi.label = dfr.getLabel();
            if (dfr.getType() == Schema.DisplayType.Picklist) {
                fi.picklistValues = new List<List<String> >();
                for (Schema.PicklistEntry plv : dfr.getPicklistValues()) {
                    if (plv.isActive()) {
                        fi.picklistValues.add(new String[]{plv.getLabel(), plv.getValue()});
                    }
                }
                if (dfr.isNillable()) {
                    fi.picklistValues.add(new String[]{'', null});
                }
            }
            result.add(fi);
        }
        return result;
    }
    @RemoteAction
    public static Map<String,String> describeMapFields(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new ModelExtensions.DescribeException('No SObject named ' + objName + ' found');
        }
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();
        Map<String,String> result = new Map<String,String>();
        for (String field : fieldNames) {
            if (!fieldMap.containsKey(field)) {
                throw new ModelExtensions.DescribeException('No field named ' + field + ' found in SObject ' + objName);
            }
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            result.put(field,dfr.getLabel());
        }
        return result;
    }
    @RemoteAction
    public static Map<String,ModelExtensions.FieldInfo> describeMapFieldsWithPickList(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new ModelExtensions.DescribeException('No SObject named ' + objName + ' found');
        }
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();
        Map<String,ModelExtensions.FieldInfo> result = new Map<String,ModelExtensions.FieldInfo>();
        for (String field : fieldNames) {
            if (!fieldMap.containsKey(field)) {
                throw new ModelExtensions.DescribeException('No field named ' + field + ' found in SObject ' + objName);
            }
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            ModelExtensions.FieldInfo fi = new ModelExtensions.FieldInfo();
            fi.name = field;
            fi.modifiable = dfr.isCreateable() | dfr.isUpdateable();
            fi.sortable = dfr.isSortable();
            fi.nillable = dfr.isNillable();
            fi.fieldType = String.valueOf(dfr.getType()).toLowerCase();
            fi.locked = false;
            fi.label = dfr.getLabel();
            if (dfr.getType() == Schema.DisplayType.Picklist) {
                fi.picklistValues = new List<List<String> >();
                for (Schema.PicklistEntry plv : dfr.getPicklistValues()) {
                    if (plv.isActive()) {
                        fi.picklistValues.add(new String[]{plv.getLabel(), plv.getValue()});
                    }
                }
                if (dfr.isNillable()) {
                    fi.picklistValues.add(new String[]{'', null});
                }
            }
            result.put(field,fi);
        }
        System.debug(result);
        return result;
    }
    @RemoteAction
    public static ModelExtensions.CRUDResponse query(ModelExtensions.QueryObj qobj) {
        System.debug('Start query');
        ModelExtensions.CRUDResponse resp = new ModelExtensions.CRUDResponse();
        String operate = ' = ';
        String countstr = 'SELECT COUNT() FROM ' + qobj.sobjname;
        System.debug(qobj);
        if (qobj.filter != null) {
            List<Map<String, String>> filter = qobj.filter;
            countstr += ' WHERE ';
            countstr += filter[0].get('property') + (((filter[0].containsKey('operator'))?(' '+filter[0].get('operator')+' '):'= ') + RemoterExtensions.condition(filter[0]));
            for (Integer i = 1; i < filter.size(); i++) {
                countstr += ' AND ' + filter[i].get('property') + (((filter[i].containsKey('operator'))?(' '+filter[i].get('operator')+' '):'= ') + RemoterExtensions.condition(filter[i]));
            }
            if (qobj.extraquery != null) {
                countstr += ' AND '+ qobj.extraquery;
            }
        }else if (qobj.extraquery != null) {
            countstr += ' WHERE ' + qobj.extraquery;
        }
        countstr += ' LIMIT 30000';
        System.debug('countstr::1::'+countstr);
        resp.total = Database.countQuery(countstr);
        System.debug('query qobj start before >> '+qobj.start);
        System.debug('query qobj resp.total >> '+resp.total);
        if(qobj.start >= resp.total){
            qobj.start -= qobj.recordCount;
        }
        System.debug('query qobj start after >> '+qobj.start);
        String qstr = 'SELECT Id FROM ' + qobj.sobjname;
        if (qobj.filter != null) {
            List<Map<String, String>> filter = qobj.filter;
            qstr += ' WHERE ';
            qstr += filter[0].get('property') + (((filter[0].containsKey('operator'))?(' '+filter[0].get('operator')+' '):'= ') + RemoterExtensions.condition(filter[0]));
            for (Integer i = 1; i < filter.size(); i++) {
                qstr += ' AND ' + filter[i].get('property') + (((filter[i].containsKey('operator'))?(' '+filter[i].get('operator')+' '):'= ') + RemoterExtensions.condition(filter[i]));
            }
            if (qobj.extraquery != null) {
                qstr += ' AND '+ qobj.extraquery;
            }
        }else if (qobj.extraquery != null) {
            qstr += ' WHERE ' + qobj.extraquery;
        }
        if (qobj.sortParams != null && qobj.sortParams[0].get('property') != 'NameSurnameTHCompanyName_Formula__c') {
            qstr += ' ORDER BY ';
            qstr += qobj.sortParams[0].get('property');
            qstr += ' ' + qobj.sortParams[0].get('direction') + ((qobj.sortParams[0].get('direction')=='ASC')?' NULLS FIRST':' NULLS LAST');
            
            for (Integer i = 1; i < qobj.sortParams.size(); i++) {
                System.debug('aaaaaa >> '+qobj.sortParams[i].get('property'));
                if(qobj.sortParams[i].get('property') != 'NameSurnameTHCompanyName_Formula__c'){
                    qstr += ',' + qobj.sortParams[i].get('property') + ' '+ qobj.sortParams[i].get('direction') +((qobj.sortParams[i].get('direction')=='ASC')?' NULLS FIRST':' NULLS LAST');    
                }
            }
            if(qobj.sortParams[0].get('property')!='Id') qstr += ',Id ASC';// NULLS LAST';
        }else qstr += ' ORDER BY Id ASC';// NULLS LAST';

        Integer reclimit = qobj.start + qobj.recordCount;
        qstr += ' LIMIT ' + String.valueOf(reclimit);
        Integer current_result = 0;        // initialize with the true offset
        List<String> temporaryId = new List<String>();
        System.debug('qstr::1::'+qstr);
        try {
            for (List<SObject> rlit : Database.query(qstr)) {
                for (SObject rit : rlit) {
                    if ((current_result >= qobj.start) && (current_result < (qobj.start + qobj.recordCount))) {
                        temporaryId.add(rit.get('Id')+'');
                    }
                    current_result++;
                }
            }
            if(temporaryId!=null && temporaryId.size() > 0){
                qstr = 'SELECT ' + qobj.fields.replace('"','\'') + ' FROM ' + qobj.sobjname + ' WHERE Id IN :temporaryId';
                if (qobj.sortParams != null && qobj.sortParams[0].get('property') != 'NameSurnameTHCompanyName_Formula__c') {
                    qstr += ' ORDER BY ';
                    qstr += qobj.sortParams[0].get('property');
                    qstr += ' ' + qobj.sortParams[0].get('direction') + ((qobj.sortParams[0].get('direction')=='ASC')?' NULLS FIRST':' NULLS LAST');
                    for (Integer i = 1; i < qobj.sortParams.size(); i++) {
                        if(qobj.sortParams[i].get('property') != 'NameSurnameTHCompanyName_Formula__c'){
                            qstr += ',' + qobj.sortParams[i].get('property') + ' '+ qobj.sortParams[i].get('direction') +((qobj.sortParams[i].get('direction')=='ASC')?' NULLS FIRST':' NULLS LAST');
                        }
                    }
                    if(qobj.sortParams[0].get('property')!='Id') qstr += ',Id ASC';// NULLS LAST';
                }else qstr += ' ORDER BY Id ASC';
                System.debug('qstr::2::'+qstr);
                for (List<SObject> rlit : Database.query(qstr)) {
                    System.debug('rlit : '+rlit);
                    for (SObject rit : rlit) {
                        System.debug('Add Item:'+rit);
                        resp.records.add(rit);
                    }
                }
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    public static String condition(Map<String, String> filter){
        String prefixString = ((filter.containsKey('operator') && filter.get('operator') == 'like')?'#':'');
        String subfixString = ((filter.containsKey('operator') && filter.get('operator') == 'like')?'%':'');
        String conditionValue = prefixString + filter.get('value') + subfixString + '';
        if(conditionValue.contains('SELECT') || conditionValue.contains('OR')){
            return conditionValue;
        }else if(conditionValue.contains('\'')) return '\'@\'';
        return (filter.get('value').startsWith('['))?filter.get('value').replace('[','(\'').replace(']','\')').replaceAll(', ','\',\''):(((conditionValue.isNumeric())?(Decimal.valueOf(conditionValue)+''):(conditionValue.indexOf('true')!=-1 || conditionValue.indexOf('false')!=-1 || conditionValue.indexOf('null')!=-1)?conditionValue:('\''+conditionValue.replace('#','')+'\' ')));
    }
    public RemoterExtensions() {
        currentUser = [SELECT Id,RC_Code__c,Employee_ID__c,AH_RC_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    }
    public RemoterExtensions(YearEndAssignment_ListView_Controller yearController){
        currentUser = [SELECT Id,RC_Code__c,Employee_ID__c,AH_RC_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    }
    public RemoterExtensions(SME_BulkAssignment_ListView_Controller controller) {
        currentUser = SME_BulkAssignment_ListView_Controller.checkMirrorUser();
    }

    public RemoterExtensions(CBS_BottomUp_Controller cbsButtomUpController){
        currentUser = [SELECT Id,RC_Code__c,Employee_ID__c,AH_RC_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    }
}