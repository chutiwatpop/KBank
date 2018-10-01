@isTest
public class FieldSetControllerTest {
    public static String typeName = 'Contact';
    public static String fsName = 'lightningFormContactFields';
	@isTest
    public static void neverWriteTestMethodLikeThis(){
        FieldSetController.getFields(typeName, fsName);
        FieldSetController.getFieldSetNames(typeName);
        FieldSetController.getTypeNames();
        FieldSetController.hasFieldSets(typeName);
    }
}