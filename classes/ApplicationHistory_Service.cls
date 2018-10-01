//all bypass in this class for prevent limit too many soql
public without sharing class ApplicationHistory_Service {
    public static Boolean byPassValidateOpportunityProduct = false;
    public static Boolean byPassStampUserExtensionWhenInsert = false;
        public static void upsertOpportunityProductNonCMAS(List<Application_History__c> listAppHis){
            Map<String,Application_History__c> mapAppHisByAppNo = new Map<String,Application_History__c>();
            Map<String,TransactBP__c> mapTransactByAppNo = new Map<String,TransactBP__c>();
            List<Credit_Info__c> listNewOppProduct = new List<Credit_Info__c>();
            Set<ID> relatedAppID = new Set<ID>();
            for(Application_History__c eachNewApp : listAppHis){
                if(eachNewApp.RMSubmitChannel__c == GlobalConstants.NON_CMAS && eachNewApp.RMCreditModel__c != GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA && eachNewApp.AppNum_NonCMAS__c != '' && eachNewApp.AppNum_NonCMAS__c != null && eachNewApp.RMSubmitIssue__c == GlobalConstants.NEW_CREDIT){ 
                    if(eachNewApp.App_Result__c == GlobalConstants.WORK_IN_PROGRESS){
                        mapAppHisByAppNo.put(eachNewApp.AppNum_NonCMAS__c,eachNewApp);
                    }
                    relatedAppID.add(eachNewApp.Id);
                }
            }

            if(!mapAppHisByAppNo.values().isEmpty()){
                List<TransactBP__c> listRelatedTransact = [SELECT Id,Application_No_From_BP_SF__c,Application_History__c,Customer_Option_A__c,Customer_Option_B__c,Customer_Option_C__c,Customer_Option_D__c,CR_1_Category__c,CR_2_Category__c,CR_3_Category__c,CR_4_Category__c,CR_5_Category__c,CR_1_Amount_Requested__c,CR_2_Amount_Requested__c,CR_3_Amount_Requested__c,CR_4_Amount_Requested__c,CR_5_Amount_Requested__c,UW_Recommend_Amount_Credit_Request_1__c,UW_Recommend_Amount_Credit_Request_2__c,UW_Recommend_Amount_Credit_Request_3__c,UW_Recommend_Amount_Credit_Request_4__c,UW_Recommend_Amount_Credit_Request_5__c,SM_P1_Offer_Amount_B__c,SM_P2_Offer_Amount_B__c,SM_P3_Offer_Amount_B__c,SM_P4_Offer_Amount_B__c,SM_P5_Offer_Amount_B__c,SM_P1_Offer_Amount_C__c,SM_P2_Offer_Amount_C__c,SM_P3_Offer_Amount_C__c,SM_P4_Offer_Amount_C__c,SM_P5_Offer_Amount_C__c FROM TransactBP__c WHERE Application_No_From_BP_SF__c IN :mapAppHisByAppNo.keySet()];
                for(TransactBP__c eachRelatedTransact : listRelatedTransact){
                    Application_History__c relatedAppHis = mapAppHisByAppNo.get(eachRelatedTransact.Application_No_From_BP_SF__c);
                    eachRelatedTransact.Application_History__c = relatedAppHis.Id;
                    mapTransactByAppNo.put(eachRelatedTransact.Application_No_From_BP_SF__c, eachRelatedTransact);
                }

                TriggerHandler.bypass('TransactTriggerHandler');
                update listRelatedTransact;
                TriggerHandler.clearbypass('TransactTriggerHandler');
                for(Application_History__c eachNewApp : listAppHis){
                    if(mapTransactByAppNo.containsKey(eachNewApp.AppNum_NonCMAS__c)){
                        TransactBP__c relatedTransact = mapTransactByAppNo.get(eachNewApp.AppNum_NonCMAS__c);
                        listNewOppProduct.addAll(createOppProductMap(relatedTransact,eachNewApp).values());
                    }
                }
            }
            
            if(!relatedAppID.isEmpty()){
                delete [SELECT Id FROM Credit_Info__c WHERE Application_History__c =:relatedAppID];
            }

            if(!listNewOppProduct.isEmpty()){
                System.debug('listNewOppProduct = '+listNewOppProduct);
                upsert listNewOppProduct Application_Number__c;
            }
        }

        private static void createOppProduct(Map<String,Credit_Info__c> mapOppProductByProductName,Id appId,String productName,String requestedAmount,String approvedAmount){
            if(productName != null && productName != ''){
                if(mapOppProductByProductName.containsKey(productName)){
                    Credit_Info__c existOppProduct = mapOppProductByProductName.get(productName);
                    existOppProduct.Requested_Amount__c = existOppProduct.Requested_Amount__c + GlobalUtility.toDecimal(requestedAmount);
                    existOppProduct.Approved_Amount__c = existOppProduct.Approved_Amount__c + GlobalUtility.toDecimal(approvedAmount);
                }else{
                    Credit_Info__c newOppProduct = new Credit_Info__c();
                    newOppProduct.Application_History__c = appId;
                    newOppProduct.Application_Number__c = appId+':'+productName;
                    newOppProduct.Product_Name__c = productName;
                    newOppProduct.Requested_Amount__c = GlobalUtility.toDecimal(requestedAmount);
                    newOppProduct.Approved_Amount__c = GlobalUtility.toDecimal(approvedAmount);
                    mapOppProductByProductName.put(newOppProduct.Product_Name__c, newOppProduct);
                }
            }
        }

        private static Map<String,Credit_Info__c> createOppProductMap(TransactBP__c relatedTransact,Application_History__c appHis){
            Map<String,Credit_Info__c> mapOppProductByProductName = new Map<String,Credit_Info__c>();
            //order by user priority D>A>B>C
            if(relatedTransact.Customer_Option_D__c != null && relatedTransact.Customer_Option_D__c.equalsIgnoreCase('Y')){
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_1_Category__c,relatedTransact.CR_1_Amount_Requested__c,relatedTransact.UW_Recommend_Amount_Credit_Request_1__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_2_Category__c,relatedTransact.CR_2_Amount_Requested__c,relatedTransact.UW_Recommend_Amount_Credit_Request_2__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_3_Category__c,relatedTransact.CR_3_Amount_Requested__c,relatedTransact.UW_Recommend_Amount_Credit_Request_3__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_4_Category__c,relatedTransact.CR_4_Amount_Requested__c,relatedTransact.UW_Recommend_Amount_Credit_Request_4__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_5_Category__c,relatedTransact.CR_5_Amount_Requested__c,relatedTransact.UW_Recommend_Amount_Credit_Request_5__c);
            }else if(relatedTransact.Customer_Option_A__c != null && relatedTransact.Customer_Option_A__c.equalsIgnoreCase('Y')){
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_1_Category__c,relatedTransact.CR_1_Amount_Requested__c,relatedTransact.CR_1_Amount_Requested__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_2_Category__c,relatedTransact.CR_2_Amount_Requested__c,relatedTransact.CR_2_Amount_Requested__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_3_Category__c,relatedTransact.CR_3_Amount_Requested__c,relatedTransact.CR_3_Amount_Requested__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_4_Category__c,relatedTransact.CR_4_Amount_Requested__c,relatedTransact.CR_4_Amount_Requested__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_5_Category__c,relatedTransact.CR_5_Amount_Requested__c,relatedTransact.CR_5_Amount_Requested__c);
            }else if(relatedTransact.Customer_Option_B__c != null && relatedTransact.Customer_Option_B__c.equalsIgnoreCase('Y')){
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_1_Category__c,relatedTransact.CR_1_Amount_Requested__c,relatedTransact.SM_P1_Offer_Amount_B__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_2_Category__c,relatedTransact.CR_2_Amount_Requested__c,relatedTransact.SM_P2_Offer_Amount_B__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_3_Category__c,relatedTransact.CR_3_Amount_Requested__c,relatedTransact.SM_P3_Offer_Amount_B__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_4_Category__c,relatedTransact.CR_4_Amount_Requested__c,relatedTransact.SM_P4_Offer_Amount_B__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_5_Category__c,relatedTransact.CR_5_Amount_Requested__c,relatedTransact.SM_P5_Offer_Amount_B__c);
            }else if(relatedTransact.Customer_Option_C__c != null && relatedTransact.Customer_Option_C__c.equalsIgnoreCase('Y')){
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_1_Category__c,relatedTransact.CR_1_Amount_Requested__c,relatedTransact.SM_P1_Offer_Amount_C__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_2_Category__c,relatedTransact.CR_2_Amount_Requested__c,relatedTransact.SM_P2_Offer_Amount_C__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_3_Category__c,relatedTransact.CR_3_Amount_Requested__c,relatedTransact.SM_P3_Offer_Amount_C__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_4_Category__c,relatedTransact.CR_4_Amount_Requested__c,relatedTransact.SM_P4_Offer_Amount_C__c);
                createOppProduct(mapOppProductByProductName,appHis.Id,relatedTransact.CR_5_Category__c,relatedTransact.CR_5_Amount_Requested__c,relatedTransact.SM_P5_Offer_Amount_C__c);
            }
            return mapOppProductByProductName;
        }


        public static Target_List__c createNewBookingLead(Campaign campaignNewBooking,Application_History__c eachAppHis,  Id targetRecordTypeId) {
            Target_List__c tlNewBooking = new Target_List__c();
            tlNewBooking.Lead_Campaign__c = campaignNewBooking.Id;
            tlNewBooking.Application_History__c = eachAppHis.Id;
            tlNewBooking.CIS_ID_Prospect_Name__c = eachAppHis.OppName__r.AccountId;
            tlNewBooking.Status__c = GlobalConstants.STATUS_NEW;
            //tlNewBooking.Approved_Amount__c = eachAppHis.Approved_Amount__c;
            tlNewBooking.Setup_Amount__c = eachAppHis.Setup_Amount__c;
            tlNewBooking.RecordTypeId = targetRecordTypeId; 
            if(System.today().addMonths(1) > campaignNewBooking.EndDate) {
                tlNewBooking.Expiry_Date__c = campaignNewBooking.EndDate;
            } else {
                tlNewBooking.Expiry_Date__c = System.today().addMonths(1);
            }
            return tlNewBooking;
        }
}