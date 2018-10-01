//27/04/2016  Natthanan.K    Update by add Primary_Segment_Desc__c field for show Segment Information
//01/11/2016  Charnun.T      INC000000454462 Change customer serach criteria
//26/04/2018  Wongsakorn.S   Delete unused field Name_EN_Prospect__c, Surname_TH_Prospect__c, Surname_EN_Prospect__c
public virtual class CustomerSearch_Management {
    protected Account getAccountFromId(String accountID){
        Account tempAccount = [Select Id, OwnerId, CIS__c, Exit__c, Port_Pool__c, RC_Code__c, Primary_Segment_Code__c, Permanent_Owner_Extension__c,RecordType.Name,RecordType.DeveloperName,Owner.Segment__c,Owner.Profile.Name,Owner.Name,Owner.RBS_User__c,Owner.SME_User__c,Owner.CBS_User__c,Is_RBS__c,Is_SME_Customer__c,Is_CBS_Customer__c From Account Where Id =: accountID];
        return tempAccount;
    }

    protected User getUserFromId(Id userID){
        User tempUser = [Select Id, RC_Code__c, ManagerId,Profile.Name,Segment__c,RBS_User__c,CBS_User__c,SME_User__c From User Where Id =: userID];
        return tempUser;
    }

    @TestVisible
    protected List<List<sObject>> searchCISValue(String inputCIS){
        String inputValue = '';
        if(inputCIS != null && inputCIS.trim() != ''){
            inputValue = 'WHERE CIS__c = \'' + inputCIS.trim()+'\' AND IsActive__c = true ';
            return queryAllSOQLValue(inputValue);
        }
        return null;
    }

    // INC000000454462 Change customer serach criteria
    @TestVisible
    protected List<List<sObject>> searchAllValue(String inputID, String inputCIS, String inputFirstName, String inputLastName){
        String inputValue = '';

        if(inputID != null && inputID.trim() != ''){
            inputValue = inputID.trim();
            return queryAllIDSOSLValue(inputValue);
        }

        if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputFirstName.trim()+'*';
        }else if(inputFirstName != null && inputFirstName.trim() != ''){
            inputValue = inputFirstName.trim()+'*';
        }
        if(inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputLastName.trim()+'*';
        }else if(inputLastName != null && inputLastName.trim() != ''){
            inputValue = inputLastName.trim()+'*';
        }

        if(inputValue != ''){
            return queryAllSOSLValue(inputValue,'NAME');
        }
        return null;
    }
    @TestVisible
    protected List<List<sObject>> searchAllValue(String inputID, String inputCIS, String inputFirstName, String inputLastName, Boolean isSOQL){
        String inputValue = '';
        //TODO We will refactor it at next sprint
        if(isSOQL){
            if(inputID != null && inputID.trim() != ''){
                inputValue = 'WHERE Encrypt_Identification_No__c = \'' + inputID.trim()+'\' ';
                return queryAllSOQLValue(inputValue);
            }
            if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != '' && inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
                inputValue = inputValue + ' OR (Name like \'' + inputFirstName.trim() + '%\' AND Name like \'%' + inputLastName.trim() + '\')';
                return queryAllSOQLValue(inputValue);
            }else if(inputFirstName != null && inputFirstName.trim() != '' && inputLastName != null && inputLastName.trim() != ''){
                inputValue = 'WHERE (Name like \'' + inputFirstName.trim() + '%\' AND Name like \'%' + inputLastName.trim() + '\')';
                return queryAllSOQLValue(inputValue);
            }
            if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != ''){
                inputValue = inputValue + ' OR Name like \'' + inputFirstName.trim() + '%\' ';
            }else if(inputFirstName != null && inputFirstName.trim() != ''){
                inputValue = 'WHERE Name like \'' + inputFirstName.trim() + '%\' ';
            }
            if(inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
                inputValue = inputValue + ' OR Name like \'%' + inputLastName.trim() + '\' ';
            }else if(inputLastName != null && inputLastName.trim() != ''){
                inputValue = 'WHERE Name like \'%' + inputLastName.trim() + '\' ';
            }
            
            if(inputValue != ''){
                return queryAllSOQLValue(inputValue);
            }
        }
        return null;
    }
    @TestVisible
    protected List<List<sObject>> sortAllValue(String inputID, String inputCIS, String inputFirstName, String inputLastName,String direction){
        String inputValue = '';
        List<List<sObject>> result = new List<List<SObject>>();
        if(inputCIS != null && inputCIS.trim() != ''){
            inputValue = 'WHERE CIS__c = \'' + inputCIS.trim()+'\' AND IsActive__c = true';
            return queryAllSOQLValue(inputValue);
        }
        if(inputID != null && inputID.trim() != ''){
            inputValue = inputID.trim();
            return queryAllIDSOSLValue(inputValue);
        }
        if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputFirstName.trim()+'*';
        }else if(inputFirstName != null && inputFirstName.trim() != ''){
            inputValue = inputFirstName.trim()+'*';
        }
        if(inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputLastName.trim()+'*';
        }else if(inputLastName != null && inputLastName.trim() != ''){
            inputValue = inputLastName.trim()+'*';
        }
        
        if(inputValue != ''){
            result = queryAllSOSLValue(inputValue,'NAME');
        }
        return result;
    }
    @TestVisible
    protected List<List<sObject>> queryAllSOQLValue(String inputValue){

        List<List<SObject>> returnResult = new List<List<sObject>>();
        List<sObject> tempAccountList = new List<sObject>();
        String searchQuery = 'SELECT Id,FirstName,LastName,Max_Wealth_Branch__r.Name,Name_Surname_TH__c,Name_Surname_EN__c,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,'+
                                    'Document_Type__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,IsActive__c,'+
                                    'Birthdate_Registration_Date__c,Port_Pool__c,'+
                                    'Encrypt_Identification_No__c, Identification_No_Mask__c,Document_Type_Prospect__c,Is_SME_Customer__c ,Is_CBS_Customer__c,Owner.Profile.Name FROM Account '+ inputValue +
                                    'LIMIT 100';
        tempAccountList = Database.query(searchQuery);
        if(tempAccountList.size() > 0 && tempAccountList != null){
            returnResult.add(tempAccountList);
        }else{
            return null;
        }
        return returnResult;
    }
    @TestVisible
    protected List<List<sObject>> queryAllSOSLValue(String inputValue, String level){

        List<List<SObject>> returnResult = new List<List<sObject>>();
        //Natthanan add Primary_Segment_Desc__c field for show Segment Information
        String searchQuery = 'FIND \'' + inputValue + '\' IN '+level+' FIELDS RETURNING Account(Id,FirstName,LastName,Max_Wealth_Branch__r.Name,Name_Surname_TH__c,Name_Surname_EN__c,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,'+
                                    'Document_Type__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,'+
                                    'Birthdate_Registration_Date__c,Port_Pool__c,Is_SME_Customer__c ,Is_CBS_Customer__c,Owner.Profile.Name,'+
                                    'Encrypt_Identification_No__c, Identification_No_Mask__c,Document_Type_Prospect__c,IsActive__c) LIMIT 100';                           
        
        returnResult = search.query(searchQuery);       
        return returnResult;
    }

    @TestVisible
    protected List<List<sObject>> queryAllIDSOSLValue(String inputValue){

        List<List<SObject>> returnResult = new List<List<sObject>>();
        //Natthanan add Primary_Segment_Desc__c field for show Segment Information
        String searchQuery = 'FIND \'' + inputValue + '\' IN ALL FIELDS RETURNING Account(Id,FirstName,LastName,Max_Wealth_Branch__r.Name,Name_Surname_TH__c,Name_Surname_EN__c,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,Primary_Segment_Desc__c,'+
                                    'Document_Type__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,'+
                                    'Birthdate_Registration_Date__c,Port_Pool__c,Is_SME_Customer__c ,Is_CBS_Customer__c,Owner.Profile.Name,'+
                                    'Document_Type_Prospect__c,Encrypt_Identification_No__c, Identification_No_Mask__c where CIS__C != \'' + inputValue + '\' AND IsActive__c = true) LIMIT 100';                           
        returnResult = search.query(searchQuery);
        return returnResult;
    }

    protected Map<String,sObject> queryMapAddress(List<String> cisIdList){
        
        Map<String,sObject> mapAddress = new Map<String,sObject>();
        mapAddress = GlobalUtility.toMapLookup('CIS_ID__r','CIS__c', [SELECT Id,CIS_ID__c,CIS_ID__r.CIS__c,District__c,Province__c
                                    FROM Address__c WHERE CIS_ID__r.CIS__c IN :cisIdList AND Address_Type__c = 'Contact']);
        return mapAddress;
    }
}