public with sharing class CBS_CallReportWrapper {
    public class ExistingContactWrapper{
        public Call_Report_Contact__c existingContact{get;set;}
        public Contact  existingContactInfo{get;set;}
        public ExistingContactWrapper(Call_Report_Contact__c callReportContact){
            this.existingContact = callReportContact;
        }
        public ExistingContactWrapper(Contact contact){
            this.existingContactInfo = contact;
        }
    }
    public class NewContactWrapper{
        public Contact contact{get;set;}
        public String lastName{get;set;}
        public boolean showOtherContactPosition{get;set;}
        public NewContactWrapper(Contact contact){
            this.contact = contact;
            this.lastName = '';
            this.showOtherContactPosition = true;
        }
    }
    public class LeadWrapper{
        public Target_List__c targetList{get;set;}
        public List<SelectOption> responseLevel1Options{get;set;}
        public List<SelectOption> responseLevel2Options{get;set;}
        public String responseLevel1{get;set;}
        public String responseLevel2{get;set;}
        public boolean isRequiredMemo{get;set;}
        public Boolean ableToAnswerLvl1 {get;set;}
        public boolean isRequiredLevel2{get;set;}
        public LeadWrapper(Target_List__c targetList,
                            List<SelectOption> responseLevel1Options,
                            List<SelectOption> responseLevel2Options
                            ){
            this.targetList = targetList;
            this.responseLevel1 = targetList.Response_Level_1__c;
            this.responseLevel2 = targetList.Response_Level_2__c;
            this.responseLevel1Options = responseLevel1Options;
            this.responseLevel2Options = responseLevel2Options;
            this.isRequiredMemo = false;
            this.isRequiredLevel2 = false;
        }
    }
    public class CallReportWrapper{
        public Call_Report__c callReport{get;set;}
        public String planDate{get;set;}
        public String cisName{get;set;}
        public String importantNote{get;set;}
        public CallReportWrapper(Call_Report__c callReport){
            this.callReport = callReport;
            this.planDate = getDateStringFromDateTime(callReport.Plan_Date__c);
            //this.cisName = CBS_CallReportNewEdit_Controller.getCustomerName(callReport.CIS_ID__r.Id);
        }
        private String getDateStringFromDateTime(Datetime myDateTime){
            boolean isMyDateTimeNull = myDateTime == null;
            String convertedMyDate;
            if(!isMyDateTimeNull){
                Date myDate = myDateTime.date();
                convertedMyDate = String.valueOf(myDate);
            }else{
                convertedMyDate = '';
            }
            return convertedMyDate;
        }
    }
    //CR008
    public class ProductWrapper{
        public String name{get;set;}

        public Boolean interest{get;set;}
        public Boolean isSelected{get;set;}

        public String remark{get;set;}

        //INC000000662593

        //New CR
        public List<SelectOption> productTypeList {get;set;}
        public String productType {get;set;}
        public String productCode{get;set;}
        public String newLimit{get;set;}
        public String outstanding{get;set;}
        public String frontEndFee{get;set;}
        public String fee{get;set;}

        public String errMsg_productType {get;set;}
        public String errMsg_NewLimit{get;set;}
        public String errMsg_Outstanding{get;set;}
        public String errMsg_FrontEndFee{get;set;}
        public String errMsg_Fee{get;set;}

        public String help_text{get;set;}
        public Boolean isFixedProductType {get;set;} 

        public String cisId{get;set;}
        public ProductWrapper(String name){
            this.name = name;
            this.isSelected = false;
        }
        public ProductWrapper(String name,String code,List<SelectOption> productTypeList){
            this.name = name;
            this.productCode = code;
            this.isSelected = false;
            this.productTypeList = productTypeList;
            this.isFixedProductType = false;
        }

        public ProductWrapper(String name,String code,List<SelectOption> productTypeList,String productType,Boolean isFixedProductType){
            this.name = name;
            this.productCode = code;
            this.isSelected = false;
            this.productTypeList = productTypeList;
            this.productType = productType;
            this.isFixedProductType = isFixedProductType;
        }
    }

    public class CallReportProductModal{
        public Set<String> productGroupList {get;set;}
        public List<String> productActiveGroupList {get;set;}

        public Map<String,List<ProductWrapper>> productWrapperMapByProductGroup {get;set;}
        public Map<String,Boolean> productWrapperCollapseMapByProductGroup {get;set;}
        public Map<String,Product_List_Master__c> cbsProductConfigMapByName {get;set;}
        public List<SelectOption> productTypeList {get;set;}
        public CallReportProductModal(){
            this.productWrapperMapByProductGroup = new Map<String,List<ProductWrapper>>();
            this.productWrapperCollapseMapByProductGroup = new Map<String,Boolean>();
            this.cbsProductConfigMapByName = CBS_Utility.getCBSProductConfigMapByProductCode();
            this.productGroupList = new Set<String>();
            this.productActiveGroupList = new List<String>();
            setUpProductConfig();

            this.productTypeList = new List<SelectOption>();
            Schema.DescribeFieldResult statusFieldDescription = Opportunity_Planning__c.Product_Type__c.getDescribe();
            for(Schema.Picklistentry picklistEntry:statusFieldDescription.getPicklistValues()){
                if(pickListEntry.getValue()!=null ){
                    this.productTypeList.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
                }
            }
        }

        private void setUpProductConfig(){
            for(Product_List_Master__c cbsProductConfig : cbsProductConfigMapByName.values()){
                if(cbsProductConfig.Is_Active__c){
                    if(!this.productWrapperMapByProductGroup.containsKey(cbsProductConfig.Product_Group__c)){
                        List<ProductWrapper> productWrapperList = new List<ProductWrapper>();
                        this.productWrapperMapByProductGroup.put(cbsProductConfig.Product_Group__c,productWrapperList);
                        if(this.productWrapperCollapseMapByProductGroup.isEmpty()){
                            this.productWrapperCollapseMapByProductGroup.put(cbsProductConfig.Product_Group__c,false);
                        }else{
                            this.productWrapperCollapseMapByProductGroup.put(cbsProductConfig.Product_Group__c,true);
                        }
                        this.productActiveGroupList.add(cbsProductConfig.Product_Group__c);
                    }
                    ProductWrapper productWrapper;
                    if(cbsProductConfig.Default_Type__c != null){
                        productWrapper = new ProductWrapper(cbsProductConfig.Product_Name__c,cbsProductConfig.Name,this.productTypeList,cbsProductConfig.Default_Type__c,cbsProductConfig.Fixed_Type__c);
                    }else{
                        productWrapper = new ProductWrapper(cbsProductConfig.Product_Name__c,cbsProductConfig.Name,this.productTypeList);
                    }
                    productWrapper.help_text = cbsProductConfig.help_text__c;
                    this.productWrapperMapByProductGroup.get(cbsProductConfig.Product_Group__c).add(productWrapper);
                }
                this.productGroupList.add(cbsProductConfig.Product_Group__c);
            }
        }

        public String getJsonMapProductConfig(){
            String replacement = ' ';
            return ((JSON.serialize(cbsProductConfigMapByName)).replace('\\r\\n',replacement)).replace('\\n',replacement);
        }

        public String getJsonproductWrapperCollapseMapByProductGroup(){
            if(this.productWrapperCollapseMapByProductGroup != null){
                return JSON.serialize(this.productWrapperCollapseMapByProductGroup);
            }
            return '{}';
        }


        public void resetModal(){
            for(String productWrapperListKey : this.productWrapperMapByProductGroup.keySet()){
                productWrapperCollapseMapByProductGroup.put(productWrapperListKey,true);
                for(ProductWrapper eachProductWrapper : productWrapperMapByProductGroup.get(productWrapperListKey)){
                    eachProductWrapper.isSelected = false;
                    eachProductWrapper.interest = false;
                    if(!eachProductWrapper.isFixedProductType){
                        eachProductWrapper.productType = GlobalConstants.NONE;
                    }
                    eachProductWrapper.newLimit = null;
                    eachProductWrapper.outstanding = null;
                    eachProductWrapper.frontEndFee = null;
                    eachProductWrapper.fee = null;
                    eachProductWrapper.errMsg_productType = null;
                    eachProductWrapper.errMsg_NewLimit = null;
                    eachProductWrapper.errMsg_Outstanding = null;
                    eachProductWrapper.errMsg_FrontEndFee = null;
                    eachProductWrapper.errMsg_Fee = null;
                }
            }
            if(!this.productActiveGroupList.isEmpty()){
                String firstProductGroup = productActiveGroupList.get(0);
                this.productWrapperCollapseMapByProductGroup.put(firstProductGroup,false);
            }
        }
    }
}