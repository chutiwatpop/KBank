/**
* @author charnun.t@beryl8.com
* @06/06/2016 createddate
*/
@isTest
private class SME_BulkAssignment_ListView_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameNH = 'nhCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String contactNameTM = 'tmCreatedContactName';
    public static String contactNameNH = 'nhCreatedContactName';
    public static String contactNameAH = 'ahCreatedContactName';

    public static String lastNameTM = 'tmCreatedLastName';
    public static String lastNameNH = 'nhCreatedLastName';
    public static String lastNameAH = 'ahCreatedLastName';
    @testSetup static void setupUser(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
        TriggerHandler.clearBypass('UserTriggerHandler');
        Integer pagesize = 150;
        SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_tm');
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameNH,contactNameNH,lastNameNH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_nh');
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameAH,contactNameAH,lastNameAH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            System.assertEquals(reassignController.getSelectedResource(), reassignController.staticPrefix + '_ah');
        }
    }
    static testMethod void staticMethod(){
        SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        System.assertNotEquals('', reassignController.getSelectedCountFields());
        System.assertNotEquals('', reassignController.getReAssignPermanenceFields());
        System.assertNotEquals('', reassignController.getReAssignTemporaryFields());
        System.assertNotEquals('', reassignController.getReAssignOwnedByOtherFields());

        System.assertNotEquals('', reassignController.getReAssignPermanenceFieldsForDes());
        System.assertNotEquals('', reassignController.getReAssignTemporaryFieldsForDes());
        System.assertNotEquals('', reassignController.getReAssignOwnedByOtherFieldsForDes());

        ModelExtensions.SavingResponse se = new ModelExtensions.SavingResponse();
        ModelExtensions.CRUDResponse ce = new ModelExtensions.CRUDResponse();
        ModelExtensions.Picklist pt = new ModelExtensions.Picklist('','');
        ModelExtensions.PicklistResponse pe = new ModelExtensions.PicklistResponse();
        ModelExtensions.QueryObj qj = new ModelExtensions.QueryObj();
        ModelExtensions.QueryPickListObj qjm = new ModelExtensions.QueryPickListObj();
        ModelExtensions.FieldInfo fo = new ModelExtensions.FieldInfo();

        SME_BulkAssignment_Model.SelectedName sn = new SME_BulkAssignment_Model.SelectedName();
        SME_BulkAssignment_Model.SavingRequest svr = new SME_BulkAssignment_Model.SavingRequest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            List<ModelExtensions.FieldInfo> reassignInfoList = RemoterExtensions.describeFields('Bulk_Assignment__c',new List<String>{'Id'});
            System.assertNotEquals(0, reassignInfoList.size());
        }
    }
    @isTest static void testPicklist(){
        SME_BulkAssignment_ListView_Controller reassignController = new SME_BulkAssignment_ListView_Controller();
        Test.startTest();
        Map<String,User> mapUserMapByFirstName = new Map<String,User>();
        for(User eachUser : [SELECT Id,FirstName FROM User]){
            mapUserMapByFirstName.put(eachUser.FirstName, eachUser);
        }

        Bulk_Assignment_Queue__c reassignQueueObj = new Bulk_Assignment_Queue__c(
            Status__c = 'Create'
        );
        insert reassignQueueObj;
        Account account = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id');
        Bulk_Assignment__c reassignObj = new Bulk_Assignment__c(
            Status__c = GlobalConstants.STATUS_NEW,
            CIS_ID__c = account.Id,
            Permanent_Owner__c = mapUserMapByFirstName.get(Mockup_Test.userFirstNameTM).Id,//[SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0].Id,
            AssignmentOwner__c = mapUserMapByFirstName.get(Mockup_Test.userFirstNameAH).Id,//[SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0].Id,
            BulkAssignmentQueue__c = reassignQueueObj.Id
        );
        insert reassignObj;
        Test.stopTest();
        //System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
        System.runAs(mapUserMapByFirstName.get(Mockup_Test.userFirstNameTM)){

            List<String> assignmentFieldList = new List<String>();
            String[] bulkAssignmentFieldArray = reassignController.getReAssignPermanenceFieldsForDes().split(',');

            for(Integer i =0,bulkAssignmentSize = bulkAssignmentFieldArray.size(); i < bulkAssignmentSize; ++i)
                assignmentFieldList.add(bulkAssignmentFieldArray[i]);

            Map<String,String> resultMap = RemoterExtensions.describeMapFields('Account', assignmentFieldList);

            System.assert(resultMap.size() > 0);

            ModelExtensions.QueryObj qo = new ModelExtensions.QueryObj();
            qo.sobjname = 'Account';
            qo.fields = reassignController.getReAssignPermanenceFields();
            qo.filter = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id !','value'=>'null'}};
            qo.start = 0;
            qo.recordCount = 10;
            qo.sortParams = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id','direction'=>'ASC'}};

            ModelExtensions.CRUDResponse assignmentResults = RemoterExtensions.query(qo);
            System.assertEquals(true,assignmentResults.success);
            System.assertEquals(1,assignmentResults.records.size());
            System.assertEquals(1,assignmentResults.total);

            ModelExtensions.QueryPickListObj qpo = new ModelExtensions.QueryPickListObj();

            ModelExtensions.PicklistByFilterKeyResponse picklistAHResults = SME_BulkAssignment_ListView_Controller.querySelectedAHByNH(qpo);

            System.assertEquals(true,picklistAHResults.success);
            System.assert(picklistAHResults.records.size()>0);
            System.assertEquals(null,picklistAHResults.total);

            ModelExtensions.PicklistByFilterKeyResponse picklistAllAHResults = SME_BulkAssignment_ListView_Controller.querySelectedAHByNH(qpo);

            qpo.extra ='All';
            System.assertEquals(true,picklistAllAHResults.success);
            System.assert(picklistAllAHResults.records.size()>0);
            System.assertEquals(null,picklistAllAHResults.total);

            ModelExtensions.PicklistByFilterKeyResponse picklistTMResults = SME_BulkAssignment_ListView_Controller.querySelectedTMByAH(qpo);

            System.assertEquals(true,picklistTMResults.success);
            System.assertEquals(null,picklistTMResults.total);

            ModelExtensions.PicklistByFilterKeyResponse picklistResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistResults.success);

            qpo.subScope = 'TMLevel';
            ModelExtensions.PicklistByFilterKeyResponse picklistSubScopeTMLevelResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistSubScopeTMLevelResults.success);

            qpo.subScope = 'ServiceRM';
            ModelExtensions.PicklistByFilterKeyResponse picklistSubScopeServiceRMResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistSubScopeServiceRMResults.success);

            qpo.subScope = 'AHLevelServiceRM';
            ModelExtensions.PicklistByFilterKeyResponse picklistSubScopeAHLevelServiceRMResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistSubScopeAHLevelServiceRMResults.success);

            qpo.subScope = 'AHLevel';
            ModelExtensions.PicklistByFilterKeyResponse picklistSubScopeAHLevelResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistSubScopeAHLevelResults.success);

            qpo.subScope = 'TMLevelServiceRM';
            ModelExtensions.PicklistByFilterKeyResponse picklistSubScopeTMLevelServiceRMResults = SME_BulkAssignment_ListView_Controller.querySelectedBy(qpo);

            System.assertEquals(true,picklistSubScopeTMLevelServiceRMResults.success);

            SME_BulkAssignment_Model.SelectedName sln = new SME_BulkAssignment_Model.SelectedName();
            //sln.selectedByRMName = String.valueOf([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0].Id);
            sln.selectedByRMName = String.valueOf(mapUserMapByFirstName.get(Mockup_Test.userFirstNameAH).Id);
            
            sln.serviceRMpanel = sln.selectedByRMName;
            sln.portPoolpanel = 'Pool';
            List<String> cisList = new List<String>();
            
            cisList.add(String.valueOf(account.Id));
            SME_BulkAssignment_Model.SavingRequest svobj = new SME_BulkAssignment_Model.SavingRequest();
            svobj.contx = 'SAVE_BULK';
            svobj.gridName = 'reAssignPermanenceGrid';
            svobj.selectName = sln;
            svobj.bulkCISlist = cisList;
            ModelExtensions.SavingResponse savingPermanenceGridForPoolServiceRMResponseResults = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);

            sln.serviceRMpanel = null;
            sln.temporaryRMpanel = sln.selectedByRMName;
            svobj.selectName = sln;
            ModelExtensions.SavingResponse savingPermanenceGridForPoolTempResponseResults = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);

            sln.temporaryRMpanel = null;
            svobj.selectName = sln;
            ModelExtensions.SavingResponse savingPermanenceGridForPoolResponseResults = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);

            sln.portPoolpanel = 'Port';
            svobj.selectName = sln;
            ModelExtensions.SavingResponse savingPermanenceGridForPortResponseResults = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);

            svobj.gridName = 'reAssignTemporaryGrid';
            ModelExtensions.SavingResponse savingTempGridResponseResults = SME_BulkAssignment_ListView_Controller.saveBulkAssignment(svobj);

        }
    }
}