public class FieldSetController {

    @AuraEnabled
    public static List<String> getTypeNames() {
        Map<String, Schema.SObjectType> types = Schema.getGlobalDescribe();
        List<String> typeNames = new List<String>();
        String typeName = null;
        List<String> fsNames;
        for (String name : types.keySet()) {
            if (hasFieldSets(name)) {
                typeNames.add(name);        
            }
        }
        return typeNames;
    }

    @AuraEnabled
    public static Boolean hasFieldSets(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        return !fsMap.isEmpty();
    }

    @AuraEnabled
    public static List<String> getFieldSetNames(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        List<String> fsNames = new List<String>();
        for (String name : fsMap.keySet()) {
            fsNames.add(name);
        }
        return fsNames;
    }

    @AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
        return fset;
    }
}