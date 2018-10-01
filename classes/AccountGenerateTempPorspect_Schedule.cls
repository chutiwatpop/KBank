/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Class for Generate Temporary prospect
Test Class:    AccountGenerateTempPorspect_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
06/03/2018  Charnun.T           First Create
------------------------------------------------------------*/
global class AccountGenerateTempPorspect_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        Temporary_Customer__mdt noOfTemporaryCustomer = [SELECT id, Number_of_Temporary_Customer__c from Temporary_Customer__mdt];
        Integer count_Config = noOfTemporaryCustomer.Number_of_Temporary_Customer__c.intValue();
        Integer count_O_Prospect= database.countQuery('SELECT COUNT() FROM account WHERE RecordType.DeveloperName = \'' + GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME + '\' and Temporary_Customer__c = True');
        integer count_I_Prospect= database.countQuery('SELECT COUNT() FROM account WHERE RecordType.DeveloperName = \'' + GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME + '\' and Temporary_Customer__c = True');

        List<SObject> tempCreateAccount = new List<SObject>();
        generateAccountTemp(tempCreateAccount, count_Config, count_O_Prospect, GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME);
        generateAccountTemp(tempCreateAccount, count_Config, count_I_Prospect, GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME);
        List<Database.SaveResult>response = DB_Service.insertsObject(tempCreateAccount);
    }

    private List<SObject> generateAccountTemp(List<SObject> tempCreateAccount, Integer count_Config, Integer count_Prospect, String recordTypeDevName) {
        if( count_Config > count_Prospect){
            Integer count = 1;
            Integer untilNo = count_Config - count_Prospect;
            Id recordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', recordTypeDevName);
            do {
                tempCreateAccount.add(this.newAccountObj(recordTypeId, recordTypeDevName));
                count++;
                if(count > 50){
                    DB_Service.insertsObject(tempCreateAccount);
                    tempCreateAccount.clear();
                    untilNo = (untilNo - count) + 1;
                    count = 1;
                }
            } while (count < untilNo);
        }
        return tempCreateAccount;
    }

    private Account newAccountObj(Id recordTypeId, String recordTypeDevName) {
        if(recordTypeDevName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME){
            return new Account(
                Name = 'Temporary Customer Record',
                RecordTypeId = recordTypeId,
                Temporary_Customer__c = True
            );
        }else{
            return new Account(
                LastName = 'Temporary Customer Record',
                RecordTypeId = recordTypeId,
                Temporary_Customer__c = True
            );
        }
    }
}