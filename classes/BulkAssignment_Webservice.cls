global without sharing class BulkAssignment_Webservice {
	global class CustomerResponse {
        webservice Boolean success;
        webservice String errorMessage;
        webservice List<Account> records;
        public Integer total;
        global CustomerResponse() {
            success = true;
            records = new List<Account>();
        }
    }

	webService static BulkAssignment_Webservice.CustomerResponse getCustomers(String cisNo) { 
		BulkAssignment_Webservice.CustomerResponse resp = new BulkAssignment_Webservice.CustomerResponse();
		try{
			List<Account> accountList = Database.query('SELECT Id,CIS__c,Identification_No__c,Name,NameSurnameTHCompanyName_Formula__c,Primary_Segment_Code__c,Secondary_Segment_Code__c,AF_Port_Pool_Formula__c,AF_Port2__c,AF_Owner_Formula__c,AF_Team_Formula__c,RecordType.DeveloperName,Owner.Profile.Name,Owner.Name,Dual_RM_Name__r.Name,Dual_RM_Name__r.Profile.Name,AF_Temporary_Customer__r.Name,Max_Wealth_Branch__r.Name,RBS_Branch_Closeness__r.Name  FROM Account WHERE Primary_Segment_Code__c !=\'HN\' and RecordType.DeveloperName IN (\'Individual_Customer\',\'Organization_Customer\') AND CIS__c =\''+cisNo+'\'');
			//List<Account> accountList = Database.query('SELECT Id,CIS__c,Identification_No__c,Name,NameSurnameTHCompanyName_Formula__c,Primary_Segment_Code__c,Secondary_Segment_Code__c,Port_Pool__c,AF_Port2__c,AF_Owner_Formula__c,AF_Team_Formula__c FROM Account WHERE Primary_Segment_Code__c !=\'HN\' and RecordType.DeveloperName =\'Individual_Customer\' LIMIT 1');
			
			if(accountList!=null && accountList.size() > 0){
			    for(Account eachAccount : accountList){
			        resp.records.add(eachAccount);
			    }
			    if(resp.records.size() > 0){
			        resp.success = true;
			        //resp.errorMessage = 'Displaying records 1 - 1 of 1';
			        resp.total = 1;
			    }else {
			        resp.success = false;
			        resp.records = null;
			        resp.errorMessage = 'No Records found.';
			    }
			}else {
			    resp.success = false;
			    resp.records = null;
			    resp.errorMessage = 'No Records found.';
			}
		}catch (Exception e) {
			resp.success = false;
			resp.records = null;
			resp.errorMessage = e.getMessage();
		}
		return resp;
	}
}