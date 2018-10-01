public with sharing class BottomUp_Section_Controller {
    private Account acc;    
    public List<Bottom_Up_Annualized__c> bottomUpList;
    public String errorMessage {get;set;}
    public Boolean errorRender {get;set;}
    public List<BottomUpWrapper> bottomUpWrapperList{get;set;}

    public BottomUp_Section_Controller(ApexPages.StandardController stdController) {
        bottomUpList = new List<Bottom_Up_Annualized__c>();
        errorRender = false;
        this.acc = (Account)stdController.getRecord();
        System.debug('acc>>>>>'+acc);
        Id customerId = acc.Id;
        System.debug('customerId>>>>>'+customerId);
        getBottomUp(customerId);

    }
    public void getBottomUp(Id customerID){
        Date dateToday = Date.today();
        System.debug('Today>>>'+dateToday);
        Integer yearInt = GlobalUtility.getYearInChristianCalendar(dateToday);
        //Integer yearInt = dateToday.year();
        //if(yearInt>2005){
        //    yearInt = yearInt-543;
        //}
        String currentYear = String.valueOf(yearInt);
        System.debug('currentYear>>>'+currentYear);

        bottomUpWrapperList = new List<BottomUpWrapper>();
        List<Bottom_Up_Annualized__c> bottomUp = new List<Bottom_Up_Annualized__c>();
        bottomUp = [SELECT Id,BottomUp_TF__c,BottomUp_FX__c,BottomUp_LI__c,BottomUp_SS__c,Total_Deal_Base_Fee_Bottom_Up__c,BottomUp_Float__c,BottomUp_Cash__c,BottomUp_KA__c,Total_Main_Operating_Bank_Bottom_Up__c,BottomUp_Front_End__c,BottomUp_Derivative__c,BottomUp_IBB__c,BottomUp_Investment_Fee__c,BottomUp_BA__c,Total_Transaction_Fee_Bottom_Up__c,CIS_ID__c FROM Bottom_Up_Annualized__c WHERE CIS_ID__c =: customerID AND Year__c =: currentYear];
        System.debug('bottomUp.size()>>>>>'+bottomUp.size());
        for(Bottom_Up_Annualized__c eachBottomUp : bottomUp){
            BottomUpWrapper bottomUpWrapper = new BottomUpWrapper();
            bottomUpWrapper.bottomUpRecord = eachBottomUp;

            //bottomUpWrapper.totalTransactionFee = (eachBottomUp.BottomUp_TF__c + eachBottomUp.BottomUp_FX__c + eachBottomUp.BottomUp_LI__c + eachBottomUp.BottomUp_SS__c).intValue();
            //bottomUpWrapper.totalMainOperatingBank = (eachBottomUp.BottomUp_Float__c + eachBottomUp.BottomUp_Cash__c + eachBottomUp.BottomUp_KA__c).intValue();
            //bottomUpWrapper.totalDealBaseFee = (eachBottomUp.BottomUp_Front_End__c + eachBottomUp.BottomUp_Derivative__c +eachBottomUp.BottomUp_IBB__c + eachBottomUp.BottomUp_Investment_Fee__c + eachBottomUp.BottomUp_BA__c).intValue();

            bottomUpWrapper.totalTransactionFee = checkNull(eachBottomUp.Total_Transaction_Fee_Bottom_Up__c);
            bottomUpWrapper.totalMainOperatingBank = checkNull(eachBottomUp.Total_Main_Operating_Bank_Bottom_Up__c);
            bottomUpWrapper.totalDealBaseFee = checkNull(eachBottomUp.Total_Deal_Base_Fee_Bottom_Up__c);

            bottomUpWrapperList.add(bottomUpWrapper);
        }
        if(bottomUpWrapperList.size() == 0){
            errorMessage = Label.Warning_No_records;
            errorRender = true;
        }
        else{
            errorRender = false;
        }
    }
    public Integer checkNull(Decimal decimalInput){
        System.debug('decimalInput>>>>>'+decimalInput);
        if(decimalInput == null){
            return 0;
        }
        else{
            return Integer.valueOf(decimalInput);
        }
    }
    public class BottomUpWrapper{
        public Bottom_Up_Annualized__c bottomUpRecord {get;set;}
        public Integer totalTransactionFee {get;set;}
        public Integer totalMainOperatingBank {get;set;}
        public Integer totalDealBaseFee {get;set;}
    }
}