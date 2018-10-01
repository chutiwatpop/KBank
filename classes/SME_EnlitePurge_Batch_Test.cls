@isTest
public class SME_EnlitePurge_Batch_Test {
     @testSetup static void setupUser(){
      
    }

    @isTest static void positiveCaseFinancialRatioPurge(){
        Account targetAccount = new Account(name='accname');
       targetAccount.CIS__c = '11111';
       targetAccount.Is_createby_Integration__c = true;
       insert targetAccount;
    
        List<Financial_Ratio_Enlite__c> fncRTOList = new List<Financial_Ratio_Enlite__c>{
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1995'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1996'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1994 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1994'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1997 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1997'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1992'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1991'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '2000 DEC 31',
                External_ID__c = targetAccount.CIS__c + '2000'
            )
        };
        insert fncRTOList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Financial_Ratio_Enlite__c',5) );
      //  Database.executeBatch(new SME_EnlitePurge_Batch('Financial_Ratio_Enlite__c',5));
        Test.stopTest();

        List<Financial_Ratio_Enlite__c> newfncRTOList = [SELECT Name FROM Financial_Ratio_Enlite__c WHERE CIS_ID__c = :targetAccount.Id ORDER BY External_ID__c DESC];
        System.assertEquals(5,newfncRTOList.size());
        System.assertEquals('2000 DEC 31',newfncRTOList.get(0).Name);
        System.assertEquals('1997 DEC 31',newfncRTOList.get(1).Name);
        System.assertEquals('1994 DEC 31',newfncRTOList.get(4).Name);

    }

    @isTest static void positiveCaseBalanceSheetPurge(){
        Account targetAccount = new Account(name='accname');
       targetAccount.CIS__c = '11111';
       targetAccount.Is_createby_Integration__c = true;
       insert targetAccount;
       List<BalanceSheetEnlite__c> balSheetList = new List<BalanceSheetEnlite__c>{
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1995'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1996'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1994 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1994'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1997 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1997'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1992'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1991'
            ),
            new BalanceSheetEnlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '2000 DEC 31',
                External_ID__c = targetAccount.CIS__c + '2000'
            )
        };
        insert balSheetList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('BalanceSheetEnlite__c',5));
     //   Database.executeBatch(new SME_EnlitePurge_Batch('BalanceSheetEnlite__c',5));
        Test.stopTest();

        List<BalanceSheetEnlite__c> newBalSheetList = [SELECT Name FROM BalanceSheetEnlite__c WHERE CIS_ID__c = :targetAccount.Id ORDER BY External_ID__c DESC];
        System.assertEquals(5,newBalSheetList.size());
        System.assertEquals('2000 DEC 31',newBalSheetList.get(0).Name);
        System.assertEquals('1997 DEC 31',newBalSheetList.get(1).Name);
        System.assertEquals('1994 DEC 31',newBalSheetList.get(4).Name);

    }
    @isTest static void positiveCaseIncomeStatementPurge(){
        Account targetAccount = new Account(name='accname');
       targetAccount.CIS__c = '11111';
       targetAccount.Is_createby_Integration__c = true;
       insert targetAccount;
       List<Income_Statement_Enlite__c> incstmList = new List<Income_Statement_Enlite__c>{
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1995'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1996'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1994 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1994'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1997 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1997'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1992'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1991'
            ),
            new Income_Statement_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '2000 DEC 31',
                External_ID__c = targetAccount.CIS__c + '2000'
            )
        };
        insert incstmList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Income_Statement_Enlite__c',5));
      //  Database.executeBatch(new SME_EnlitePurge_Batch('Income_Statement_Enlite__c',5));
        Test.stopTest();

        List<Income_Statement_Enlite__c> newincstmList = [SELECT Name FROM Income_Statement_Enlite__c WHERE CIS_ID__c = :targetAccount.Id ORDER BY External_ID__c DESC];
        System.assertEquals(5,newincstmList.size());
        System.assertEquals('2000 DEC 31',newincstmList.get(0).Name);
        System.assertEquals('1997 DEC 31',newincstmList.get(1).Name);
        System.assertEquals('1994 DEC 31',newincstmList.get(4).Name);

    }

    @isTest static void positiveCaseFinancialRatioPurgeMapMorethanOneIndex(){
        Account targetAccount = new Account(name='11111');
        targetAccount.CIS__c = '11111';
        targetAccount.Is_createby_Integration__c = true;
        insert targetAccount;

        Account targetAccount2 = new Account(name='22222');
        targetAccount2.CIS__c = '22222';
        targetAccount2.Is_createby_Integration__c = true;
        insert targetAccount2;
    
        List<Financial_Ratio_Enlite__c> fncRTOList = new List<Financial_Ratio_Enlite__c>{
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1995'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1996'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1994 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1994'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1997 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1997'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1992'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1991'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '2000 DEC 31',
                External_ID__c = targetAccount.CIS__c + '2000'
            ),
            ////////////// another account////////////////////
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1995'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1996'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1994 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1994'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1997 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1997'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1992'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '1991'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount2.Id,
                Name = '2000 DEC 31',
                External_ID__c = targetAccount2.CIS__c + '2000'
            )
        };
        insert fncRTOList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Financial_Ratio_Enlite__c',5) );
      //  Database.executeBatch(new SME_EnlitePurge_Batch('Financial_Ratio_Enlite__c',5));
        Test.stopTest();

        List<Financial_Ratio_Enlite__c> newfncRTOList = [SELECT Name FROM Financial_Ratio_Enlite__c WHERE CIS_ID__c = :targetAccount.Id ORDER BY External_ID__c DESC];
         List<Financial_Ratio_Enlite__c> newfncRTOList2 = [SELECT Name FROM Financial_Ratio_Enlite__c WHERE CIS_ID__c = :targetAccount2.Id ORDER BY External_ID__c DESC];
        System.assertEquals(5,newfncRTOList.size());
        System.assertEquals('2000 DEC 31',newfncRTOList.get(0).Name);
        System.assertEquals('1997 DEC 31',newfncRTOList.get(1).Name);
        System.assertEquals('1994 DEC 31',newfncRTOList.get(4).Name);

        System.assertEquals(5,newfncRTOList2.size());
        System.assertEquals('2000 DEC 31',newfncRTOList2.get(0).Name);
        System.assertEquals('1997 DEC 31',newfncRTOList2.get(1).Name);
        System.assertEquals('1994 DEC 31',newfncRTOList2.get(4).Name);
    }




    @isTest static void negativeCaseFinancialRatioPurgeExternalDayIsNotTheSame(){
        Account targetAccount = new Account(name='accname');
       targetAccount.CIS__c = '11111';
       targetAccount.Is_createby_Integration__c = true;
       insert targetAccount;
    
        List<Financial_Ratio_Enlite__c> fncRTOList = new List<Financial_Ratio_Enlite__c>{
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1995 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1995'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1996 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1996'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1994 JAN 20',
                External_ID__c = targetAccount.CIS__c + '1994'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1997 FEB 5',
                External_ID__c = targetAccount.CIS__c + '1997'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1992 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1992'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '1991 DEC 31',
                External_ID__c = targetAccount.CIS__c + '1991'
            ),
            new Financial_Ratio_Enlite__c(
                CIS_ID__c = targetAccount.Id,
                Name = '2000 MAR 1',
                External_ID__c = targetAccount.CIS__c + '2000'
            )
        };
        insert fncRTOList;
        Test.startTest();
        Database.executeBatch(new SME_DistinctAccountIDForEnlite_Batch('Financial_Ratio_Enlite__c',5));
       // Database.executeBatch(new SME_EnlitePurge_Batch('Financial_Ratio_Enlite__c',5));
        Test.stopTest();

        List<Financial_Ratio_Enlite__c> newfncRTOList = [SELECT Name FROM Financial_Ratio_Enlite__c WHERE CIS_ID__c = :targetAccount.Id ORDER BY External_ID__c  DESC];
        System.assertEquals(5,newfncRTOList.size());
        System.assertEquals('2000 MAR 1',newfncRTOList.get(0).Name);
        System.assertEquals('1997 FEB 5',newfncRTOList.get(1).Name);
        System.assertEquals('1994 JAN 20',newfncRTOList.get(4).Name);

    }

}