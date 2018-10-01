@isTest
private class SME_UpdateAccountNationality_Batch_Test {


    @testSetup static void setupUser(){
      
    }

 
    @isTest static void positiveCaseNationalityMatchSharePercentage(){
    

        Account targetAccount = new Account(name='11111');
          targetAccount.CIS__c = '11111';
          targetAccount.Is_createby_Integration__c = true;
          insert targetAccount;
        Account targetAccount2 = new Account(name='22222');
          targetAccount2.CIS__c = '22222';
          targetAccount2.Is_createby_Integration__c = true;
          insert targetAccount2;
  
        List<Corp_Link_Enlite__c>  corpLinkList = new List<Corp_Link_Enlite__c>{
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Share__c  = 15.0,
                Shareholders_nationality__c = 'ZH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Share__c  = 15.0,
                Shareholders_nationality__c = 'TH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Share__c  = 20.00,
                Shareholders_nationality__c  = 'JP'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Share__c  = 3.0,
                Shareholders_nationality__c  = 'CN'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Share__c  = 10.0,
                Shareholders_nationality__c  = 'TH'
            ),
            /////////// other account ///////////
                new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Share__c  = 20.0,
                Shareholders_nationality__c = 'TH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Share__c  = 20.0,
                Shareholders_nationality__c = 'TH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Share__c  = 20.00,
                Shareholders_nationality__c  = 'TH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Share__c  = 20.0,
                Shareholders_nationality__c  = 'TH'
            ),
            new Corp_Link_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Share__c  = 20.0,
                Shareholders_nationality__c  = 'TH'
            )
        };
        
        insert corpLinkList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Corp_Link_Enlite__c',-1));
       // Database.executeBatch(new SME_UpdateAccountNationality_Batch());
        Test.stopTest();

        String expectedStr = 'TH 25.00 %';
        String expectedStr2 = 'TH 100.00 %';
        Account acc1 = [SELECT Id,Major_Shareholder_Nationality__c,CIS__c FROM Account WHERE Id = :targetAccount.Id];
        Account acc2 = [SELECT Id,Major_Shareholder_Nationality__c,CIS__c FROM Account WHERE Id = :targetAccount2.Id];
        System.assertEquals(expectedStr,acc1.Major_Shareholder_Nationality__c);
        System.assertEquals(expectedStr2,acc2.Major_Shareholder_Nationality__c);

    }

    
 
    
   
}