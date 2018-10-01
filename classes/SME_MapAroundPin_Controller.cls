public with sharing class SME_MapAroundPin_Controller {
    public static Around_Pin_Config__c aroundPinConfig;

    public SME_MapAroundPin_Controller() {
    }

    @RemoteAction
    public static List<AddressWrapper> getAllAddress(Decimal currentLat, Decimal currentLng, Integer limitDistance, String filterValue, String searchString){
    	String queryString = 'SELECT Id, Sales_Smart_Address__c, CIS_ID__c, CIS_ID__r.Name, CIS_ID__r.Last_Visited_Datetime__c, CIS_ID__r.Encrypt_Fullname_TH__c, CIS_ID__r.Encrypt_Fullname_EN__c, CIS_ID__r.RecordType.DeveloperName, House_Number_Encrypt__c, Address__c, Address_Type_SalesSmart__c, Place__c, Pin_Location__Latitude__s, Pin_Location__Longitude__s FROM Address__c';
        String condition = ' WHERE Pin_Location__Latitude__s != null AND Pin_Location__Longitude__s != null';
        User_Extension__c currentUserExtension = null;
        try {
            currentUserExtension = [SELECT Id, User__c, User__r.ManagerId FROM User_Extension__c WHERE User__c = :UserInfo.getUserId()];
        } catch (Exception ex) {
            throw new PageException('No User Extension for User : ' + UserInfo.getUserId());
        }
        
        List<String> relatedUsers = new List<String>();
        if(currentUserExtension.User__c != null) {
            relatedUsers.add(currentUserExtension.User__c);
        }
        if(currentUserExtension.User__r.ManagerId != null) {
            relatedUsers.add(currentUserExtension.User__r.ManagerId);
        }

        List<String> accountIds = new List<String>();
        System.debug('filterValue:' + filterValue);
        if(filterValue == 'Port') {
            condition = condition + ' AND CIS_ID__r.OwnerId = \'' + currentUserExtension.User__c + '\' AND CIS_ID__r.Port_Pool__c = \'' + filterValue + '\'';
    	} else if(filterValue == 'Pool') {
            condition = condition + ' AND (CIS_ID__r.Owner.ManagerId = \'' + currentUserExtension.User__c + '\' OR CIS_ID__r.OwnerId IN (\'' + String.join(relatedUsers,'\',\'') + '\')) AND CIS_ID__r.Port_Pool__c = \'' + filterValue + '\'';
        } else if(filterValue == 'CIS') {
            searchString = searchString.trim();
            accountIds = getAllAccountIdString(searchString);
            condition = condition + ' AND CIS_ID__c IN (\'' + String.join(accountIds,'\',\'') + '\')';
        } else if(filterValue == 'Temporary') {
            condition = condition + ' AND (CIS_ID__r.Ownership_Text__c = \'Temporary\' OR CIS_ID__r.RecordType.DeveloperName = \'Organization_Prospect\' OR CIS_ID__r.RecordType.DeveloperName = \'Individual_Prospect\') AND (CIS_ID__r.OwnerId = \'' + currentUserExtension.User__c + '\' OR CIS_ID__r.SME_Temporary_Customer__c = \'' + currentUserExtension.Id + '\')';
    	} else if(filterValue == 'cisId') {
            condition = condition + ' AND CIS_ID__c = \'' + searchString + '\'';
        }
        if(limitDistance != -1) {
            condition = condition + ' AND DISTANCE(Pin_Location__c, GEOLOCATION('+currentLat+','+currentLng+'), \'km\') < '+limitDistance;
        }
        System.debug('condition:' + condition);
    	queryString = queryString + condition + ' ORDER BY Sales_Smart_Address__c DESC LIMIT 49000';
    	List<Address__c> addressList = Database.query(queryString);
    	List<AddressWrapper> addressWrapperList = new List<AddressWrapper>();
    	for(Address__c eachAddress : addressList){
			addressWrapperList.add(new AddressWrapper(eachAddress, false));
		}

        if(addressList.isEmpty()) {
            if(filterValue == 'CIS' && accountIds.size() == 0) {
                throw new PageException(Label.NO_CUSTOMER_FOUND);
            } else {
                throw new PageException(Label.NO_PIN_LOCATION_FOUND);
            }
        }

		return addressWrapperList;
    }

    public static List<String> getAllAccountIdString(String searchKeyWord){
        List<Account> queryResults = new List<Account>();
        if(GlobalUtility.isNumberAlphabet(searchKeyWord)) {
            queryResults = [SELECT Id FROM Account WHERE CIS__c = :searchKeyWord];
        } else {
            String sQuery = 'FIND \''+searchKeyWord+'\' IN Name FIELDS RETURNING Account(Id LIMIT 1500)';
            List<List<sObject>> results = Search.query(sQuery);
            if(!results.isEmpty()) {
                queryResults = (List<Account>) results[0];
            }
        }

        List<String> accountIds = new List<String>();
        for(Account eachAccount : queryResults) {
            accountIds.add(eachAccount.Id);
        }
        
        return accountIds;
    }

    // INC000000910860
    @RemoteAction
    public static AddressWrapper getAddressDetail(String addressId) {
        AddressWrapper addressWrapper;
        if(addressId != null) {
            try {
                Address__c targetAddress = [SELECT Id, Sales_Smart_Address__c, CIS_ID__c, CIS_ID__r.Name, CIS_ID__r.Last_Visited_Datetime__c, CIS_ID__r.Encrypt_Fullname_TH__c, CIS_ID__r.Encrypt_Fullname_EN__c, CIS_ID__r.RecordType.DeveloperName, House_Number_Encrypt__c, Address__c, Address_Type_SalesSmart__c, Place__c, Pin_Location__Latitude__s, Pin_Location__Longitude__s FROM Address__c WHERE Id = :addressId];
                addressWrapper = new AddressWrapper(targetAddress, true);
                return addressWrapper;
            } catch (Exception e) {
                throw new PageException(e.getMessage());
            }
        } else {
            throw new PageException('Something went wrong!');
        }
    }

    @RemoteAction
    public static List<Contact> getContacts(String accountId) {
    	List<Contact> returnContacts = new List<Contact>();
        List<Contact> contactList = new List<Contact>();
    	contactList = [SELECT Name, Phone_Numbers__c, Ext_CBS__c FROM Contact WHERE AccountId = :accountId];
        for(Contact eachContact : contactList) {
            if(eachContact.Phone_Numbers__c != null) {
                returnContacts.add(eachContact);    
            }
        }
    	return returnContacts;
    }

    @RemoteAction
    public static FraudResponse getFraudStatus(String accountID) {
        FraudResponse resp = new FraudResponse();
        Account requestAccount;
        if(accountId != null) 
        requestAccount = [Select Id, OwnerId, CIS__c, Exit__c, Port_Pool__c, RC_Code__c, Primary_Segment_Code__c, Permanent_Owner_Extension__c,RecordType.Name,Owner.Segment__c,Owner.Profile.Name,Owner.Name,Owner.RBS_User__c,Owner.SME_User__c,Owner.CBS_User__c,Is_RBS__c,Is_SME_Customer__c,Is_CBS_Customer__c From Account Where Id =: accountID];
        if(requestAccount != null) {
            if(requestAccount.RecordType.Name == GlobalConstants.ORGANIZATION_PROSPECT) {
                resp.isShowFraud = false;
            }
            try{
                GetFraud_Webservice webserviceInstance = GetFraud_Webservice.getInstance();
                webserviceInstance.cisId = requestAccount.CIS__c;
                GetFraud_Webservice.ResponseModel responseModel = webserviceInstance.calloutWebservice();
                List<GetFraud_Webservice.CustomerFraud> respCustomers = responseModel.customerModel;
                if(respCustomers != null && respCustomers.size() > 0) {
                    resp.colorCode = Account_Service.calculateFraud(requestAccount.Exit__c, respCustomers[0].BLIST_TP_CD);
                }
                resp.fraudMessage = Label.FRAUD_ALERT;
                if(resp.colorCode == GlobalConstants.FRAUD_COLOR_BLUE) {
                    resp.isShowFraud = false;
                } else {
                    resp.isShowFraudColor = (resp.colorCode != 'Other');    
                }
            }catch(CIWebserviceException e){
                resp.fraudMessage = GlobalUtility.getCallOutExceptionErrorMsg(e.getMessage());
            }catch(Exception e){
                resp.fraudMessage = e.getMessage();
            }
        }
        return resp;
    }

    @RemoteAction
    public static Account getAccountFromId(String accountID) {
        Account targetAccount;
        if(accountID != null) {
            try {
                targetAccount = [SELECT Id, Name, OwnerId, Owner_Profile__c, Lead_Sharing_Expired_Date__c, Sharing_Status__c, Share_With__c, Customer_s_Business_Code__c FROM Account WHERE Id = :accountID LIMIT 1];    
                return targetAccount;
            } catch (Exception e) {
                throw new PageException(e.getMessage());
            }
        } else {
            throw new PageException('Something went wrong!');
        }
    }

    public class AddressWrapper {
        private Boolean isSFDCAddress;
    	private String customerId;
    	private String recordType;
    	private String customerName;
    	private String customerImage;
    	private String addressId;
    	private String addressName;
    	private String addressType;
    	private String addressLong;
    	private String iconColor;
    	private Decimal lat;
    	private Decimal lng;

    	public AddressWrapper() {}

    	public AddressWrapper(Address__c address, Boolean isGetDetail) {
            addressId = address.Id;
            customerName = address.CIS_ID__r.Name;
            lat = address.Pin_Location__Latitude__s;
            lng = address.Pin_Location__Longitude__s;

            Integer yellowRange;
            Integer redRange;
            Integer greenRange;
    		try {
    			if(SME_MapAroundPin_Controller.aroundPinConfig == null) {
    				SME_MapAroundPin_Controller.aroundPinConfig = Around_Pin_Config__c.getOrgDefaults();
    			}
	    		greenRange = Integer.valueOf(SME_MapAroundPin_Controller.aroundPinConfig.Green_Pin__c);
	    		yellowRange = Integer.valueOf(SME_MapAroundPin_Controller.aroundPinConfig.Yellow_Pin__c);
	    		redRange = Integer.valueOf(SME_MapAroundPin_Controller.aroundPinConfig.Red_Pin__c);
	    	} catch (Exception ex) {
	    		greenRange = 0;
	    		yellowRange = 31;
	    		redRange = 61;
	    	}
            
    		if(address.CIS_ID__r.Last_Visited_Datetime__c != null) {
    			Date todayDate = System.today();
                Date lastVisitDate = System.today();
                if(address.CIS_ID__r.Last_Visited_Datetime__c != null) {
                    lastVisitDate = date.newinstance(address.CIS_ID__r.Last_Visited_Datetime__c.year(), address.CIS_ID__r.Last_Visited_Datetime__c.month(), address.CIS_ID__r.Last_Visited_Datetime__c.day());
                }
    			Integer dateRange = lastVisitDate.daysBetween(todayDate);
    			if(dateRange >= redRange) {
    				iconColor = 'red';
				} else if(dateRange >= yellowRange) {
					iconColor = 'yellow';
				} else {
					iconColor = 'green';
				}
    		} else iconColor = 'red';

            // INC000000910860
            if(isGetDetail == true) {
                customerId = address.CIS_ID__c;
                customerName = address.CIS_ID__r.Name;

                isSFDCAddress = (address.Sales_Smart_Address__c == true);
                addressType = String.isBlank(address.Address_Type_SalesSmart__c)?'-':address.Address_Type_SalesSmart__c;
                addressName = String.isBlank(address.Place__c)?'-':address.Place__c;
                addressLong = ((address.House_Number_Encrypt__c==null)?'':address.House_Number_Encrypt__c) + ' ' + ((address.Address__c==null)?'':address.Address__c);
                if(String.isBlank(addressLong)) addressLong = '-';
                if(address.CIS_ID__r.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
                    address.CIS_ID__r.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME) {
                    recordType = 'RECORDTYPE_CUSTOMER';
                    //recordType = GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME;
                    //if(!String.isBlank(address.CIS_ID__r.Encrypt_Fullname_TH__c)) {
                    //    customerImage = Label.MashupUrl + address.CIS_ID__r.Encrypt_Fullname_TH__c;
                    //} else if(!String.isBlank(address.CIS_ID__r.Encrypt_Fullname_EN__c)) {
                    //    customerImage = Label.MashupUrl + address.CIS_ID__r.Encrypt_Fullname_EN__c;
                    //} else {
                    //    customerImage = null;
                    //}
                } else {
                    //recordType = GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME;
                    recordType = 'RECORDTYPE_PROSPECT';
                }
            }
    	}
    }

    public class FraudResponse {
        public Boolean isShowFraud;
        public Boolean isShowFraudColor;
        public String colorCode;
        public String fraudStatus;
        public String fraudMessage;

        public FraudResponse() {
            isShowFraud = true;
            isShowFraudColor = false;
        }
    }

    public class PageException extends Exception{}
}