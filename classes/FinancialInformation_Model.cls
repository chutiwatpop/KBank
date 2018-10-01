/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
xx/xx/2015  xxx                 First Create
14/03/2016  Charnun.T           Refactor
------------------------------------------------------------*/
public class FinancialInformation_Model {
  public final String SAVING = 'Saving';
  public final String CURRENT = 'Current';
  public final String FIXED = 'Fixed Deposit';
  public final String TAWEESUP = 'Taweesup';
  public final String MUTUALFUND = 'Mutual Fund';
  public final String CREDITCARD = 'CC';
  public final String KEC = 'KEC';
  public final String FCD = 'FCD';

  public Map<String, List<String>> creditData {get; private set;}
  public Map<String, List<String>> nonCreditData {get; private set;}
  public List<String> creditProductList {get; private set;}
  public List<String> nonCreditProductList {get; private set;}
  public String cis;

  public Map<String, List<String>> creditDetailHeader {get; private set;}
  public Map<String, List<List<String>>> creditDetailData {get; private set;}

  public Map<String, List<String>> nonCreditDetailHeader {get; private set; }
  public Map<String, List<List<String>>> nonCreditDetailData {get; private set;}

  public String accountLimit {get;private set;}
  public String accountOutstanding {get;private set;}

  public String language;
  private Integer langType;
  public Map<String,List<String>> fieldsMapAPI;
  public Map<String,List<String>> fcdfieldLabelMapAPIName;

  public FinancialInformation_Model(String cis,String language) {

    this.cis = cis;
    creditProductList = new List<String>{'LN', 'OD', 'PN', 'TF', 'LI', 'HL', CREDITCARD,KEC};
    nonCreditProductList = new List<String> {SAVING, 'Current', FIXED, TAWEESUP, MUTUALFUND,FCD};

    this.language = language;
    fieldsMapAPI = new Map<String,List<String>>();
    List<accounts__c> fieldsList = [SELECT Name,EN__c,TH__c From accounts__c];
      for(accounts__c field : fieldsList){
      List<String> fieldName = new List<String>{field.EN__c,field.TH__c};
      fieldsMapAPI.put( field.Name,fieldName );
    }
    this.langType = this.language == 'th' ? 1 : 0 ;
    this.accountLimit = fieldsMapAPI.get('Limit')[langType];
    this.accountOutstanding = fieldsMapAPI.get('Outstanding')[langType];
    //fcd 
    List<FinancialInfoFCD__c> fieldsListFCD = [SELECT Name,EN__c,TH__c From FinancialInfoFCD__c];
    fcdfieldLabelMapAPIName = new Map<String,List<String>>();
    System.debug('Debug fcdfieldLabelMapAPIName ::'+fcdfieldLabelMapAPIName);
    for(FinancialInfoFCD__c field : fieldsListFCD){
      fcdfieldLabelMapAPIName.put( field.Name,new List<String>{field.EN__c,field.TH__c} );
    }
    setupCreditData();
    setupNonCreditData();
  }

  public Map<String, String> getCreditLimitDataMap() {
    Map<String, String> dataMap = new Map<String, String>();
    List<Financial_Information__c> financialList = [SELECT Id, CC_Limit__c, HL_Limit__c, LI_Limit__c, LN_Limit__c, OD_Limit__c, PN_Limit__c, POD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c=:cis LIMIT 1];
    if(!financialList.isEmpty()) {
      Financial_Information__c financial = financialList.get(0);
        for(String creditProduct : creditProductList) {
          if( creditProduct != KEC && creditProduct != CREDITCARD){
            String limitField = creditProduct+'_Limit__c';
            dataMap.put(creditProduct+'_Limit', GlobalUtility.toCurrency(financial.get(limitField)));
          }
        }
      }
    return dataMap;
  }

  public void setupCreditData() {
    creditDetailHeader = new Map<String, List<String>>();
    creditData = new Map<String, List<String>>();
    creditDetailData = new Map<String, List<List<String>>>();
    for(String creditProduct : creditProductList) {
      creditData.put(creditProduct, new List<String>());
      creditDetailHeader.put(creditProduct, new List<String>());
      creditDetailData.put(creditProduct, new List<List<String>>());
    }

    List<Financial_Information__c> financialList = [SELECT Id, CC_Limit__c, HL_Limit__c, LI_Limit__c, LN_Limit__c, OD_Limit__c, PN_Limit__c, POD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c=:cis];
    for(Financial_Information__c financial : financialList) {
      for(String creditProduct : creditProductList) {
          if( creditProduct != KEC && creditProduct != CREDITCARD){
          String limitField = creditProduct+'_Limit__c';
          creditData.get(creditProduct).add(GlobalUtility.toCurrency(financial.get(limitField)));
        }
      }
    }

    //setupLNData();
    //setupODData();
    //setupPNData();
    //setupTFData();
    //setupLIData();
    //setupHLData();
    //setupPODData();
    setupCCData();
    setupKECData();

    ////Mock////
    Integer value = 100;
    for(String creditProduct : creditProductList) {
        setupMockCreditData(creditProduct,value);
        setupMockCreditDetailData(creditProduct);
        value += 100;
    }
     ////Mock////
  }

  public void setupMockCreditDetailData(String creditProduct) {
    creditDetailData.get(creditProduct).add( new List<String>{'441770******1943'});
    creditDetailData.get(creditProduct).add( new List<String>{'Platinum'});
    creditDetailData.get(creditProduct).add( new List<String>{'07/12/2554'});
    creditDetailData.get(creditProduct).add( new List<String>{'85,000.00'});
    creditDetailData.get(creditProduct).add( new List<String>{'85,000.67'});
    creditDetailData.get(creditProduct).add( new List<String>{'-0.67'});
    creditDetailData.get(creditProduct).add( new List<String>{'25/01/2560'});
    creditDetailData.get(creditProduct).add( new List<String>{'บัตรหลัก'});
    creditDetailData.get(creditProduct).add( new List<String>{'ก.ค.-17'});
    creditDetailData.get(creditProduct).add( new List<String>{'INACTIVE-ACCOUNT'});
    creditDetailData.get(creditProduct).add( new List<String>{'441770******1943'});
    creditDetailData.get(creditProduct).add( new List<String>{'441770******1943'});
  }

  public void setupMockCreditData(String creditProduct, Integer value) {
    creditData.get(creditProduct).add(GlobalUtility.toCurrency(value));
  }

  //public void setupODData() {
  //  creditDetailHeader.get('OD').add('Type of Product');
  //  creditDetailHeader.get('OD').add('Account Number / Sub');
  //  creditDetailHeader.get('OD').add('Limit (บาท)');
  //  creditDetailHeader.get('OD').add('Outstanding (บาท)');
  //  creditDetailHeader.get('OD').add('อัตราดอกเบี้ย');
  //  creditDetailHeader.get('OD').add('วันเปิดบัญชี');
  //  creditDetailHeader.get('OD').add('วันครบกำหนด');
  //  creditDetailHeader.get('OD').add('จำนวนงวด (เดือน)');
  //  creditDetailHeader.get('OD').add('ผ่อนต่องวด (บาท)');
  //  creditDetailHeader.get('OD').add('Status');
  //}

  //public void setupPNData() {
  //  creditDetailHeader.get('PN').add('Type of Product');
  //  creditDetailHeader.get('PN').add('Account Number / Sub');
  //  creditDetailHeader.get('PN').add('Limit (บาท)');
  //  creditDetailHeader.get('PN').add('Outstanding (บาท)');
  //  creditDetailHeader.get('PN').add('อัตราดอกเบี้ย');
  //  creditDetailHeader.get('PN').add('วันเปิดบัญชี');
  //  creditDetailHeader.get('PN').add('วันครบกำหนด');
  //  creditDetailHeader.get('PN').add('จำนวนงวด (เดือน)');
  //  creditDetailHeader.get('PN').add('ผ่อนต่องวด (บาท)');
  //  creditDetailHeader.get('PN').add('Status');
  //}

  //public void setupTFData() {
  //  creditDetailHeader.get('TF').add('Type of Product');
  //  creditDetailHeader.get('TF').add('Account Number / Sub');
  //  creditDetailHeader.get('TF').add('Limit (บาท)');
  //  creditDetailHeader.get('TF').add('Outstanding (บาท)');
  //  creditDetailHeader.get('TF').add('อัตราดอกเบี้ย');
  //  creditDetailHeader.get('TF').add('วันเปิดบัญชี');
  //  creditDetailHeader.get('TF').add('วันครบกำหนด');
  //  creditDetailHeader.get('TF').add('จำนวนงวด (เดือน)');
  //  creditDetailHeader.get('TF').add('ผ่อนต่องวด (บาท)');
  //  creditDetailHeader.get('TF').add('Status');
  //}

  //public void setupLIData() {
  //  creditDetailHeader.get('LI').add('Type of Product');
  //  creditDetailHeader.get('LI').add('Account Number / Sub');
  //  creditDetailHeader.get('LI').add('Limit (บาท)');
  //  creditDetailHeader.get('LI').add('Outstanding (บาท)');
  //  creditDetailHeader.get('LI').add('อัตราดอกเบี้ย');
  //  creditDetailHeader.get('LI').add('วันเปิดบัญชี');
  //  creditDetailHeader.get('LI').add('วันครบกำหนด');
  //  creditDetailHeader.get('LI').add('จำนวนงวด (เดือน)');
  //  creditDetailHeader.get('LI').add('ผ่อนต่องวด (บาท)');
  //  creditDetailHeader.get('LI').add('Status');
  //}

  //public void setupHLData() {
  //  creditDetailHeader.get('HL').add('Type of Product');
  //  creditDetailHeader.get('HL').add('Account Number / Sub');
  //  creditDetailHeader.get('HL').add('Limit (บาท)');
  //  creditDetailHeader.get('HL').add('Outstanding (บาท)');
  //  creditDetailHeader.get('HL').add('อัตราดอกเบี้ย');
  //  creditDetailHeader.get('HL').add('วันเปิดบัญชี');
  //  creditDetailHeader.get('HL').add('วันครบกำหนด');
  //  creditDetailHeader.get('HL').add('จำนวนงวด (เดือน)');
  //  creditDetailHeader.get('HL').add('ผ่อนต่องวด (บาท)');
  //  creditDetailHeader.get('HL').add('Status');
  //}

    public void setupKECData() {

      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CARD_NUMBER')[langType] );
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CARD_TYPE')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('ACTIVATED_DATE')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CREDIT_LIMIT')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CREDIT_BALANCE')[langType]);
    
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('SPENDING')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('DUE_DATE')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('PRINCIPLE_CARD_FLAG')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CARD_EXPIRE_DATE')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('CARD_STATUS')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('MAIN_CUSTOMER_NAME')[langType]);
      creditDetailHeader.get(KEC).add(fieldsMapAPI.get('SUPPLEMENTARY NAME')[langType]);
  }

  public void setupCCData() {

      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CARD_NUMBER')[langType] );
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CARD_TYPE')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('ACTIVATED_DATE')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CREDIT_LIMIT')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CREDIT_BALANCE')[langType]);

      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('SPENDING')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('DUE_DATE')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('PRINCIPLE_CARD_FLAG')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CARD_EXPIRE_DATE')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('CARD_STATUS')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('MAIN_CUSTOMER_NAME')[langType]);
      creditDetailHeader.get(CREDITCARD).add(fieldsMapAPI.get('SUPPLEMENTARY NAME')[langType]);
  }

  

  public void setupNonCreditData() {
    nonCreditDetailHeader = new Map<String, List<String>>();
    nonCreditData = new Map<String, List<String>>();
    nonCreditDetailData = new Map<String, List<List<String>>>();
    for(String nonCreditProduct : nonCreditProductList) {
      nonCreditData.put(nonCreditProduct, new List<String>());
      nonCreditDetailHeader.put(nonCreditProduct, new List<String>());
      nonCreditDetailData.put(nonCreditProduct, new List<List<String>>());
    }

    setupSavingDetailData();
    setupCurrentDetailData();
    setupFixDetailData();
    setupTaweesupDetailData();
    setupMutualFundDetailData();
    setupFCD();
  }

  public void setupMutualFundDetailData() {
    nonCreditDetailHeader.get(MUTUALFUND).add('เลขที่บัญชี  /เลขที่อ้างอิง');
    nonCreditDetailHeader.get(MUTUALFUND).add('Sub Account');
    nonCreditDetailHeader.get(MUTUALFUND).add('ชื่อบัญชี');
    nonCreditDetailHeader.get(MUTUALFUND).add('ชื่อย่อกองทุน');
    nonCreditDetailHeader.get(MUTUALFUND).add('ชิ่อกองทุน');
    nonCreditDetailHeader.get(MUTUALFUND).add('จำนวนหน่วยคงเหลือ (Outstanding Unit)');
    nonCreditDetailHeader.get(MUTUALFUND).add('วันที่ NAV');
    nonCreditDetailHeader.get(MUTUALFUND).add('NAV Rate');
    nonCreditDetailHeader.get(MUTUALFUND).add('มูลค่าคงเหลือ');
    nonCreditDetailHeader.get(MUTUALFUND).add('รหัสประเภทบัญชี');
    nonCreditDetailHeader.get(MUTUALFUND).add('บัญชีหลัก / ร่วม');
  }

  public void setupTaweesupDetailData() {
    nonCreditDetailHeader.get(TAWEESUP).add('เลขที่บัญชี');
    nonCreditDetailHeader.get(TAWEESUP).add('sub');
    nonCreditDetailHeader.get(TAWEESUP).add('ชื่อบัญชี');
    nonCreditDetailHeader.get(TAWEESUP).add('ยอดคงเหลือ (Outstanding)');
    nonCreditDetailHeader.get(TAWEESUP).add('วันเปิดบัญชี');
    nonCreditDetailHeader.get(TAWEESUP).add('อัตราดอกเบี้ย');
    nonCreditDetailHeader.get(TAWEESUP).add('ระยะเวลาฝาก (เดือน)');
    nonCreditDetailHeader.get(TAWEESUP).add('Hold Amount');
    nonCreditDetailHeader.get(TAWEESUP).add('ประเภทบัญชี');
  }


  public void setupSavingDetailData() {
    nonCreditDetailHeader.get(SAVING).add('เลขที่บัญชี');
    nonCreditDetailHeader.get(SAVING).add('ชื่อบัญชี');
    nonCreditDetailHeader.get(SAVING).add('ยอดคงเหลือ (Outstanding)');
    nonCreditDetailHeader.get(SAVING).add('Hold Amount');
    nonCreditDetailHeader.get(SAVING).add('ประเภทบัญชี');
  }

  public void setupCurrentDetailData() {
    nonCreditDetailHeader.get('Current').add('เลขที่บัญชี');
    nonCreditDetailHeader.get('Current').add('ชื่อบัญชี');
    nonCreditDetailHeader.get('Current').add('ยอดคงเหลือ (Outstanding)');
    nonCreditDetailHeader.get('Current').add('Hold Amount');
    nonCreditDetailHeader.get('Current').add('ประเภทบัญชี');
  }

  public void setupFixDetailData() {
    nonCreditDetailHeader.get(FIXED).add('เลขที่บัญชี');
    nonCreditDetailHeader.get(FIXED).add('sub');
    nonCreditDetailHeader.get(FIXED).add('ชื่อบัญชี');
    nonCreditDetailHeader.get(FIXED).add('ยอดคงเหลือ (Outstanding)');
    nonCreditDetailHeader.get(FIXED).add('วันเปิดบัญชี');
    nonCreditDetailHeader.get(FIXED).add('อัตราดอกเบี้ย');
    nonCreditDetailHeader.get(FIXED).add('ระยะเวลาฝาก (เดือน)');
    nonCreditDetailHeader.get(FIXED).add('Hold Amount');
    nonCreditDetailHeader.get(FIXED).add('ประเภทบัญชี');
  }

  public void setupFCD(){
    System.debug('Debug - setup FCD ::' +fcdfieldLabelMapAPIName);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Acc_No')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Open_Date')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Closed_Date')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Acc_Type')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Product_Name')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Currency')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Outstanding_CCY')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Outstanding_THB')[langType]);
    nonCreditDetailHeader.get(FCD).add(fcdfieldLabelMapAPIName.get('Status')[langType]);
  }

}