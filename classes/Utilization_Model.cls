public class Utilization_Model {

    public class ProductUtilization {
        public String productName {get; private set;}
        public List<String> outstandingList {get; private set;}
        public List<String> limitList {get; private set;}
        public List<String> outstandingValueList {get; private set;}
        public List<String> limitValueList {get; private set;}
        public List<String> utilizationList {get; private set;}

        public ProductUtilization(String productName) {
            this.productName = productName;
            outstandingList = new List<String>();
            outstandingValueList = new List<String>();
            limitList = new List<String>();
            limitValueList = new List<String>();
            utilizationList = new List<String>();
        }
    }

    public List<String> headerList {get; private set;}

    public List<String> utilizationNameList {get; private set;}
    public Map<String, ProductUtilization> utilizationMap {get; private set;}

    public String cis {get; private set;}
    public Utilization_Model(String cis) {
        utilizationNameList = new List<String> {'OD', 'PN', 'TF'};
        headerList = new List<String>();
        utilizationMap = new Map<String, ProductUtilization>();
        for(String utilizationName : utilizationNameList) {
            utilizationMap.put(utilizationName, new ProductUtilization(utilizationName));
        }

        List<Utilization__c> utilizationList = [SELECT Id, Name, OD_Limit__c, OD_AVG_OUT__c, OD_Utilization__c, PN_Limit__c, PN_AVG_OUT__c, PN_Utilization__c, TF_Limit__c, TF_AVG_OUT__c, TF_Utilization__c FROM Utilization__c WHERE CIS_ID__r.CIS__c=:cis AND Name != null ORDER BY Name ASC];
        Map<String, sObject> utilizationMapByMonth = GlobalUtility.toMap('Name', utilizationList);
        System.debug('utilizationMapByMonth :'+utilizationMapByMonth);

        Date todayDate = System.today();

        for(Integer i=1; i<=12; i++) {
            Date thisDate = date.newinstance(todayDate.year(), todayDate.month() - i, 1);
            Integer year = GlobalUtility.getYearInChristianCalendar(thisDate); 
           // Integer year = thisDate.year() > 2400 ? thisDate.year() - 543 : thisDate.year();
            String yearStr = String.valueOf(year).substring(2);
            String monthHeader = GlobalUtility.MONTH_STR_MAP.get(thisDate.month())+'-'+yearStr;
            headerList.add(monthHeader);

            Utilization__c utilization;
            String key = i > 9 ? String.valueOf(i) : '0'+String.valueOf(i);
            if(utilizationMapByMonth.containsKey(key))      utilization = (Utilization__c)utilizationMapByMonth.get(key);
            else                                            utilization = new Utilization__c();

            for(String utilizationName : utilizationNameList) {
                String outstandingField = utilizationName+'_AVG_OUT__c';
                String outstandingValue = utilization.get(outstandingField) != null ? 
                                            GlobalUtility.toCurrency(utilization.get(outstandingField)) :
                                            '';

                utilizationMap.get(utilizationName).outstandingList.add(outstandingValue);
                utilizationMap.get(utilizationName).outstandingValueList.add(utilization.get(outstandingField) != null ? String.valueOf(utilization.get(outstandingField)) : '0');

                String limitField = utilizationName+'_Limit__c';
                String limitValue = utilization.get(limitField) != null ? 
                                        GlobalUtility.toCurrency(utilization.get(limitField)) :
                                        '';
                utilizationMap.get(utilizationName).limitList.add(limitValue);
                utilizationMap.get(utilizationName).limitValueList.add(utilization.get(limitField) != null ? String.valueOf(utilization.get(limitField)) : '0');

                String utilizationField = utilizationName+'_Utilization__c';
                String utilizationValue = utilization.get(utilizationField) != null ?
                                            GlobalUtility.toCurrency(utilization.get(utilizationField)) :
                                            '';
                utilizationMap.get(utilizationName).utilizationList.add(utilizationValue);
            }
        }
    }

    public List<String> getLimitList(String productName) {
        return utilizationMap.get(productName).limitList;
    }

    public List<String> getLimitValueList(String productName) {
        return utilizationMap.get(productName).limitValueList;
    }

    public List<String> getOutstandingValueList(String productName) {
        return utilizationMap.get(productName).outstandingValueList;
    }

    public List<String> getOutstandingList(String productName) {
        return utilizationMap.get(productName).outstandingList;
    }
}