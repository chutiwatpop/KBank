@isTest
private class GroupSubGroup_Service_Test {
    public static final String accountname = 'Account1';
    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        User userTM = [SELECT Id FROM User WHERE FirstName=:Mockup_Test.userFirstNameCBTM LIMIT 1];
        Account accountCBS;
        Campaign mockLeadToDo;
        System.runAs(userTM){
            Group__c group1 = new Group__c(
                Group_Name__c = 'group1',
                External_ID__c = 'g1',
                Number_of_Group__c = 1
            );
            insert group1;
            Sub_Group__c subGroup1 = new Sub_Group__c(
                Sub_Group_Name__c = 'subGroup1',
                External_ID__c = 'sg1',
                Number_of_Sub_Group__c = 1,
                Team_Lead_Name__c = userTM.Id
            );
            insert subGroup1;
            Group_Sub_Group__c groupSubGroup = new Group_Sub_Group__c(
                Group_Lookup__c = group1.Id,
                Sub_Group_Lookup__c = subGroup1.Id,
                Group__c = 'g1',
                Sub_Group__c = 'sb1'
            );
            insert groupSubGroup;

            accountCBS = new Account(
                Name = GroupSubGroup_Service_Test.accountName,
                Port_Pool__c = GlobalConstants.PORT,
                RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
                Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                OwnerId = userTM.Id,
                Primary_Segment_Code__c = 'CB',
                Customer_Segment_Code__c = 'CB',
                OwnerChangeExecutedByTrigger__c = true,
                Is_createby_Integration__c = true,
                Group_Sub_Group__c = groupSubGroup.Id
            );
            insert accountCBS;

            List<Customer_Group_Sub_Group__c> customerGSubGList = [SELECT Id FROM Customer_Group_Sub_Group__c WHERE Customer__c = :accountCBS.Id LIMIT 1];

            Group_Sub_Group_Transaction__c gSubGTran = new Group_Sub_Group_Transaction__c();
            gSubGTran.CIS_ID__c = accountCBS.Id;
            gSubGTran.Group_Lookup__c = group1.Id;
            gSubGTran.Sub_Group_Lookup__c = subGroup1.Id;
            gSubGTran.Group_Sub_Group_Lookup__c = groupSubGroup.Id;
            gSubGTran.Customer_Group_Sub_Group__c = customerGSubGList[0].Id;
            insert gSubGTran;

            mockLeadToDo = new Campaign();
            mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
            mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
            mockLeadToDo.Sub_Type__c = 'เพื่อทราบ';
            mockLeadToDo.Name = 'leadToDo';
            mockLeadToDo.Status = GlobalConstants.ACTIVE;
            mockLeadToDo.IsActive = true;
            mockLeadToDo.StartDate = System.today() - 1;
            mockLeadToDo.EndDate = System.Today() + 1;
            mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
            TriggerHandler.bypass('CampaignTriggerHandler');
            insert mockLeadToDo;
            TriggerHandler.clearBypass('CampaignTriggerHandler');

            //insert new User_Management__c(Allow_to_Create_Target_List__c = True);

            

            Opportunity opp1 = Mockup_Test.newOpportunityWithAppHis(accountCBS.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
        }
        Target_List__c targetList = new Target_List__c();
            targetList.Lead_Campaign__c = mockLeadToDo.Id;
            targetList.CIS_ID_Prospect_Name__c = accountCBS.Id;
            targetList.Status__c = GlobalConstants.STATUS_NEW;
            insert targetList;
    }
    @isTest static void addValueForCreateAccount() {
        Test.startTest();
            Account testAcc = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c');
            List<Account> finalAccount = new List<Account>();
            finalAccount.add(testAcc);
            List<Account> accountlist = GroupSubGroup_Service.assignValuesForToCreateAccount(finalAccount);
            System.assertEquals(1,accountlist.size());
        Test.stopTest();
    }
    @isTest static void updateGSubG() {
        Test.startTest();
            Account testAcc = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c,OwnerId');
            User userTM = [SELECT Id, FirstName, LastName FROM User WHERE FirstName=:Mockup_Test.userFirstNameCBTM LIMIT 1];
            List<Account> finalAccount = new List<Account>();
            finalAccount.add(testAcc);
            Group__c group2;
            Sub_Group__c subGroup2;
            Group_Sub_Group__c groupSubGroup2;
            System.runAs(userTM){
                group2 = new Group__c(
                    Group_Name__c = 'group2',
                    External_ID__c = 'g1',
                    Number_of_Group__c = 1
                );
                insert group2;
                subGroup2 = new Sub_Group__c(
                    Sub_Group_Name__c = 'subGroup2',
                    External_ID__c = 'sg1',
                    Number_of_Sub_Group__c = 1,
                    Team_Lead_Name__c = userTM.Id
                );
                insert subGroup2;
                groupSubGroup2 = new Group_Sub_Group__c(
                    Group_Lookup__c = group2.Id,
                    Sub_Group_Lookup__c = subGroup2.Id,
                    Group__c = 'g1',
                    Sub_Group__c = 'sb1'
                );
                insert groupSubGroup2;
                for(Account account:finalAccount){
                    account.Group_Sub_Group__c = groupSubGroup2.Id;
                }
            }
            AccountTriggerHandler.profileMapByName = GlobalUtility.getProfileMapNameKey();
            AccountTriggerHandler.allUserMap = User_Service.getAllUserMap();
            update finalAccount;
            Map<Id,Account> accountMap = New Map<Id,Account>([SELECT Id,Group_Sub_Group__c,Primary_Segment_Code__c,OwnerId FROM Account WHERE Id=:testAcc.Id LIMIT 1]);
            Map<Id, Account> newAccountMapById = new Map<Id, Account>(finalAccount);
            GroupSubGroup_Service.updateCustomerGroupSubGroup(newAccountMapById,accountMap);
            //then
            Customer_Group_Sub_Group__c customerGroupSubGroup =  [SELECT ID,Group_Sub_Group__c,Group_Sub_Group__r.Group_Lookup__c,Group_Sub_Group__r.Sub_Group_Lookup__c From Customer_Group_Sub_Group__c WHERE Customer__c = :finalAccount  LIMIT 1];
            Group_Sub_Group_Transaction__c groupSubgroupTransaction = [SELECT Id,Group_Lookup__c,Sub_Group_Lookup__c,Group_Sub_Group_Lookup__c From Group_Sub_Group_Transaction__c WHERE Customer_Group_Sub_Group__c =:customerGroupSubGroup.id LIMIT 1];
            System.assertEquals(groupSubgroupTransaction.Group_Sub_Group_Lookup__c,groupSubGroup2.id);
            System.assertEquals(groupSubgroupTransaction.Group_Lookup__c,groupSubGroup2.Group_Lookup__c);
            System.assertEquals(groupSubgroupTransaction.Sub_Group_Lookup__c,groupSubGroup2.Sub_Group_Lookup__c);

            Account updatedAccount = [SELECT Id, Group__c, Sub_Group__c, Group_SubGroup_TeamLeadName__c FROM Account WHERE Id = :testAcc.Id LIMIT 1];
            System.assertEquals(groupSubGroup2.Group__c, updatedAccount.Group__c);
            System.assertEquals(groupSubGroup2.Sub_Group__c, updatedAccount.Sub_Group__c);
            System.assertEquals('' + userTM.FirstName + ' ' + userTM.LastName, updatedAccount.Group_SubGroup_TeamLeadName__c);
            
        Test.stopTest();
    }
    @isTest static void updateGSubGUserNullFirstName() {
        Test.startTest();
            Account testAcc = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c,OwnerId');
            User userTM = [SELECT Id, FirstName, LastName FROM User WHERE FirstName=:Mockup_Test.userFirstNameCBTM LIMIT 1];
            userTM.FirstName = null;
            update userTM;
            List<Account> finalAccount = new List<Account>();
            finalAccount.add(testAcc);
            Group__c group2;
            Sub_Group__c subGroup2;
            Group_Sub_Group__c groupSubGroup2;
            System.runAs(userTM){
                group2 = new Group__c(
                    Group_Name__c = 'group2',
                    External_ID__c = 'g1',
                    Number_of_Group__c = 1
                );
                insert group2;
                subGroup2 = new Sub_Group__c(
                    Sub_Group_Name__c = 'subGroup2',
                    External_ID__c = 'sg1',
                    Number_of_Sub_Group__c = 1,
                    Team_Lead_Name__c = userTM.Id
                );
                insert subGroup2;
                groupSubGroup2 = new Group_Sub_Group__c(
                    Group_Lookup__c = group2.Id,
                    Sub_Group_Lookup__c = subGroup2.Id,
                    Group__c = 'g1',
                    Sub_Group__c = 'sb1'
                );
                insert groupSubGroup2;
                for(Account account:finalAccount){
                    account.Group_Sub_Group__c = groupSubGroup2.Id;
                }
                AccountTriggerHandler.profileMapByName = GlobalUtility.getProfileMapNameKey();
                AccountTriggerHandler.allUserMap = User_Service.getAllUserMap();
                update finalAccount;
            }

            Account updatedAccount = [SELECT Id, Group__c, Sub_Group__c, Group_SubGroup_TeamLeadName__c FROM Account WHERE Id = :testAcc.Id LIMIT 1];
            System.assertEquals(groupSubGroup2.Group__c, updatedAccount.Group__c);
            System.assertEquals(groupSubGroup2.Sub_Group__c, updatedAccount.Sub_Group__c);
            System.assertEquals('' + userTM.LastName, updatedAccount.Group_SubGroup_TeamLeadName__c);
            
        Test.stopTest();
    }
    @isTest static void updateGSubGToAccountNullGSubG() {
        Test.startTest();
            User userTM = [SELECT Id, FirstName, LastName FROM User WHERE FirstName=:Mockup_Test.userFirstNameCBTM LIMIT 1];
            Group__c group2;
            Sub_Group__c subGroup2;
            Group_Sub_Group__c groupsubGroup2;
            Account accountCBS;
            Account finalAccount;
            System.runAs(userTM){
                group2 = new Group__c(
                    Group_Name__c = 'group2',
                    External_ID__c = 'g1',
                    Number_of_Group__c = 1
                );
                insert group2;
                subGroup2 = new Sub_Group__c(
                    Sub_Group_Name__c = 'subGroup2',
                    External_ID__c = 'sg1',
                    Number_of_Sub_Group__c = 1,
                    Team_Lead_Name__c = userTM.Id
                );
                insert subGroup2;
                groupSubGroup2 = new Group_Sub_Group__c(
                    Group_Lookup__c = group2.Id,
                    Sub_Group_Lookup__c = subGroup2.Id,
                    Group__c = 'g1',
                    Sub_Group__c = 'sb1'
                );
                insert groupSubGroup2;
                accountCBS = new Account(
                    Name = 'account2',
                    Port_Pool__c = GlobalConstants.PORT,
                    RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
                    Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                    OwnerId = userTM.Id,
                    Primary_Segment_Code__c = 'CB',
                    Is_createby_Integration__c = true,
                    OwnerChangeExecutedByTrigger__c = true
                );
                insert accountCBS;
                accountCBS.Group_Sub_Group__c = groupSubGroup2.Id;
                update accountCBS;
            }

            Account updatedAccount = [SELECT Id, Group__c, Sub_Group__c, Group_SubGroup_TeamLeadName__c FROM Account WHERE Id = :accountCBS.Id LIMIT 1];
            System.assertEquals(groupSubGroup2.Group__c, updatedAccount.Group__c);
            System.assertEquals(groupSubGroup2.Sub_Group__c, updatedAccount.Sub_Group__c);
            System.assertEquals('' + userTM.FirstName + ' ' + userTM.LastName, updatedAccount.Group_SubGroup_TeamLeadName__c);
            
        Test.stopTest();
    }
    @isTest static void updateGSubGSameBefore() {
        Test.startTest();
            List<Account> finalAccount = new List<Account>();
            Account testAccount = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c,OwnerId');
            List<Group_Sub_Group__c> groupSubGroupList = [SELECT Id FROM Group_Sub_Group__c WHERE Group__c = 'g1' AND Sub_Group__c = 'sb1' LIMIT 1];
            finalAccount.add(testAccount);
            for(Account account:finalAccount){
                account.Group_Sub_Group__c = groupSubGroupList[0].Id;
            }
            AccountTriggerHandler.profileMapByName = GlobalUtility.getProfileMapNameKey();
            AccountTriggerHandler.allUserMap = User_Service.getAllUserMap();
            update finalAccount;

        Test.stopTest();
    }
    @isTest static void updateGSubGAccountToNull() {
        Test.startTest();
            Account testAcc = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c,OwnerId');
            List<Account> finalAccount = new List<Account>();
            finalAccount.add(testAcc);
            for(Account account:finalAccount){
                account.Group_Sub_Group__c = null;
            }
            AccountTriggerHandler.profileMapByName = GlobalUtility.getProfileMapNameKey();
            AccountTriggerHandler.allUserMap = User_Service.getAllUserMap();
            update finalAccount;

            Customer_Group_Sub_Group__c customerGroupSubGroup =  [SELECT ID,Group_Sub_Group__c,Group_Sub_Group__r.Group_Lookup__c,Group_Sub_Group__r.Sub_Group_Lookup__c From Customer_Group_Sub_Group__c WHERE Customer__c = :finalAccount  LIMIT 1];
            Group_Sub_Group_Transaction__c groupSubgroupTransaction = [SELECT Id,Group_Lookup__c,Sub_Group_Lookup__c,Group_Sub_Group_Lookup__c From Group_Sub_Group_Transaction__c WHERE Customer_Group_Sub_Group__c =:customerGroupSubGroup.id LIMIT 1];
            System.assertEquals(null, groupSubgroupTransaction.Group_Sub_Group_Lookup__c);
            System.assertEquals(null, groupSubgroupTransaction.Group_Lookup__c);
            System.assertEquals(null, groupSubgroupTransaction.Sub_Group_Lookup__c);

            Account updatedAccount = [SELECT Id, Group__c, Sub_Group__c, Group_SubGroup_TeamLeadName__c FROM Account WHERE Id = :testAcc.Id LIMIT 1];
            System.assertEquals(null, updatedAccount.Group__c);
            System.assertEquals(null, updatedAccount.Sub_Group__c);
            System.assertEquals(null, updatedAccount.Group_SubGroup_TeamLeadName__c);

        Test.stopTest();
    }
    @isTest static void testSetFlagAccountInsertTargetList() {
        Test.startTest();
            Account finalAccount = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c');
            List<Target_List__c> targetList = [SELECT Id,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :finalAccount.Id];
            //List<Account> accountlist = GroupSubGroup_Service.modifyAccountThatRelatedToTargetLists(targetList);
            List<Account> accountlist = GroupSubGroup_Service.setAccountGroupSubGroupUpdate(targetList);
            System.assertEquals(1,accountlist.size());
        Test.stopTest();
    }

    @isTest static void testSetFlagAccountInsertOpportunity() {
        Test.startTest();
            Account finalAccount = Mockup_Test.getFirstAccountFromName(GroupSubGroup_Service_Test.accountName, 'Id,Group_Sub_Group__c,Primary_Segment_Code__c');
            List<Opportunity> opportunityList = [SELECT Id,AccountId FROM Opportunity WHERE AccountId = :finalAccount.Id LIMIT 1];
            List<Account> accountlist = GroupSubGroup_Service.setAccountGroupSubGroupUpdate(opportunityList);
            System.assertEquals(1,accountlist.size());
        Test.stopTest();
    }
}