/**
* @author komsan.wi@beryl8.com
* @25/03/2015 create new
*/
public with sharing class ModelExtensions {
	public class SavingResponse {
        public Boolean success;
        public Boolean duplicate;
        public String errorMessage;
        public SavingResponse() {
            success = true;
            duplicate = false;
        }
    }
    public virtual class CRUDResponse {
        public Boolean success;
        public String errorMessage;
        public List<SObject> records;
        public Integer total;
        public CRUDResponse() {
            records = new List<SObject>();
            success = true;
        }
    }
    public class Picklist {
        public String pvalue;
        public String pname;
        public Picklist(String pvalue,String pname){
            this.pvalue = pvalue;
            this.pname = pname;
        }
    }
    public class PicklistByFilterKey {
        public String pvalue;
        public String pname;
        public String pkey;
        public PicklistByFilterKey(String pvalue,String pname,String pkey){
            this.pvalue = pvalue;
            this.pname = pname;
            this.pkey = pkey;
        }
    }

    public class AccountBottomUpSum{
        public String summary;
        public Decimal totalTransActionFee;
        public Decimal totalMainOperatingBank;
        public Decimal totalDealBaseFee;
        public Decimal totalBottomUp;
        public AccountBottomUpSum(Decimal totalTransActionFee,Decimal totalMainOperatingBank,Decimal totalDealBaseFee, Decimal totalBottomUp){
            summary = 'Summary';
            this.totalTransActionFee = totalTransActionFee;
            this.totalMainOperatingBank = totalMainOperatingBank;
            this.totalDealBaseFee = totalDealBaseFee;
            this.totalBottomUp = totalBottomUp;
        }
    }

    public class AccountBottomUpSumResponse{
        public Boolean success;
        public String errorMessage;
        public List<AccountBottomUpSum> records;
        public Integer total;
        public AccountBottomUpSumResponse() {
            records = new List<AccountBottomUpSum>();
            success = true;
        }
    }

    public class PicklistResponse {
        public Boolean success;
        public String errorMessage;
        public List<Picklist> records;
        public Integer total;
        public PicklistResponse() {
            records = new List<Picklist>();
            success = true;
        }
    }
    public class PicklistByFilterKeyResponse {
        public Boolean success;
        public String errorMessage;
        public List<PicklistByFilterKey> records;
        public Integer total;
        public PicklistByFilterKeyResponse() {
            records = new List<PicklistByFilterKey>();
            success = true;
        }
    }
    public class MapsResponse {
        public Boolean success;
        public String errorMessage;
        public Map<String,Map<String, String>> records;
        public Integer total;
        public MapsResponse() {
            records = new Map<String,Map<String, String>>();
            success = true;
        }
    }
    public class QueryObj {
        public String sobjname;
        public String extraquery;
        public String fields;
        public String filter_en;
        public List<Map<String, String>> filter;
        public Integer start;
        public Integer recordCount;
        public List<Map<String, String>> sortParams;
        public Map<String, String> groupy;
    }
    public class QueryPickListObj {
        //public Integer limit;
        public String scope;
        public String subScope;
        public Boolean isAH;
        public Boolean selfInclude;
        public String query;
        public Integer start;
        public String extra;
        public String segment;
        public String province;
        public String team;
        public String cisRelated;
        public String percentShare;
        public String language;
        public String reason;
        public String businessCode;
        public Decimal saleSize;
        public String cisID;

        // Added For Bulk
        public String sobjname;
        public String field;
        public String rccodes;
        public Boolean isActive;
        public List<String> accIds;
        public String bulkQueueId;
        public String fsvpID;
        public String teamRCCode;
        public String userEmployeeID;
        public boolean isTL;
        public boolean isNH;
        public boolean isAdmin;
        public String ahRCcode;
        public boolean ahLevel;
        public boolean blankInclude;
    }
    public class FieldInfo {
        public String name;
        public Boolean modifiable;
        public Boolean sortable;
        public Boolean nillable;
        public String fieldType;
        public String label;
        public Boolean locked;
        public List<List<String> > picklistValues;
    }
    public class DescribeException extends Exception {}

    //pan rein
    public static String name_sort = 'targetName';
    public static String transactionFeeTarget_sort = 'transactionFeeTarget';
    public static String transactionFeeBottomUp_sort = 'transactionFeeBottomUp';
    public static String mainOperatingBankTarget_sort = 'mainOperatingBankTarget';
    public static String mainOperatingBankBottomUp_sort = 'mainOperatingBankBottomUp';
    public static String dealBaseFeeTarget_sort = 'dealBaseFeeTarget';
    public static String dealBaseFeeBottomUp_sort = 'dealBaseFeeBottomUp';
    public static String totalBottomUp_sort = 'totalBottomUp';
    public static String totalMiracle_sort = 'totalMiracle';
    public static String SORT_BY = name_sort;

    public class targetTableRecord implements Comparable{
        public String targetName;
        public String Id;
        public Decimal transactionFeeTarget;
        public Decimal transactionFeeBottomUp;
        public Decimal mainOperatingBankTarget;
        public Decimal mainOperatingBankBottomUp;
        public Decimal dealBaseFeeTarget;
        public Decimal dealBaseFeeBottomUp;
        public Decimal transactionFeeTeamTarget;
        public Decimal mainOperatingBankTeamTarget;
        public Decimal dealBaseFeeTeamTarget;
        public String teamName;
        public Decimal totalBottomUp;
        public Decimal totalMiracle;

        public targetTableRecord(String targetName,
                                String targetId,
                                Decimal transactionFeeTarget,
                                Decimal transactionFeeBottomUp,
                                Decimal mainOperatingBankTarget,
                                Decimal mainOperatingBankBottomUp,
                                Decimal dealBaseFeeTarget,
                                Decimal dealBaseFeeBottomUp){
            this.targetName = targetName;
            this.Id = targetId;
            this.transactionFeeTarget = transactionFeeTarget;
            this.transactionFeeBottomUp = transactionFeeBottomUp;
            this.mainOperatingBankTarget = mainOperatingBankTarget;
            this.mainOperatingBankBottomUp = mainOperatingBankBottomUp;
            this.dealBaseFeeTarget = dealBaseFeeTarget;
            this.dealBaseFeeBottomUp = dealBaseFeeBottomUp;
        }
        public targetTableRecord(String targetName,
                                String targetId,
                                Decimal transactionFeeTarget,
                                Decimal transactionFeeBottomUp,
                                Decimal mainOperatingBankTarget,
                                Decimal mainOperatingBankBottomUp,
                                Decimal dealBaseFeeTarget,
                                Decimal dealBaseFeeBottomUp,
                                Decimal totalBottomUp,
                                Decimal totalMiracle){
            this.targetName = targetName;
            this.Id = targetId;
            this.transactionFeeTarget = transactionFeeTarget;
            this.transactionFeeBottomUp = transactionFeeBottomUp;
            this.mainOperatingBankTarget = mainOperatingBankTarget;
            this.mainOperatingBankBottomUp = mainOperatingBankBottomUp;
            this.dealBaseFeeTarget = dealBaseFeeTarget;
            this.dealBaseFeeBottomUp = dealBaseFeeBottomUp;
            this.totalBottomUp = totalBottomUp;
            this.totalMiracle = totalMiracle;
        }
        //Team Level
        public targetTableRecord(String targetName,
                                String targetId,
                                Decimal transactionFeeTarget,
                                Decimal transactionFeeBottomUp,
                                Decimal mainOperatingBankTarget,
                                Decimal mainOperatingBankBottomUp,
                                Decimal dealBaseFeeTarget,
                                Decimal dealBaseFeeBottomUp,
                                Decimal transactionFeeTeamTarget,
                                Decimal mainOperatingBankTeamTarget,
                                Decimal dealBaseFeeTeamTarget,
                                Decimal totalBottomUp,
                                Decimal totalMiracle
                                ){
            this.targetName = targetName;
            this.Id = targetId;
            this.transactionFeeTarget = transactionFeeTarget;
            this.transactionFeeBottomUp = transactionFeeBottomUp;
            this.mainOperatingBankTarget = mainOperatingBankTarget;
            this.mainOperatingBankBottomUp = mainOperatingBankBottomUp;
            this.dealBaseFeeTarget = dealBaseFeeTarget;
            this.dealBaseFeeBottomUp = dealBaseFeeBottomUp;
            this.transactionFeeTeamTarget = transactionFeeTeamTarget;
            this.mainOperatingBankTeamTarget = mainOperatingBankTeamTarget;
            this.dealBaseFeeTeamTarget = dealBaseFeeTeamTarget;
            this.totalBottomUp = totalBottomUp;
            this.totalMiracle = totalMiracle;
        }
        private Integer sortByName(targetTableRecord targetTableRec){
            System.debug('sortByName >>> ');
            if(this.targetName > targetTableRec.targetName){
                return 1;
            }
            if(this.targetName == targetTableRec.targetName){
                return 0;
            }
            return -1;
        }
        private Integer sortByTransactionFeeTarget(targetTableRecord targetTableRec){
            System.debug('sortByTransactionFeeTarget >>> ');
            System.debug('this.transactionFeeTarget >>'+this.transactionFeeTarget);
            System.debug('targetTableRec.transactionFeeTarget >>'+targetTableRec.transactionFeeTarget);
            //Double currentTransactionFeeTarget = Double.valueOf(this.transactionFeeTarget);
            //Double nextTransactionFeeTarget = Double.valueOf(targetTableRec.transactionFeeTarget);
            if(this.transactionFeeTarget > targetTableRec.transactionFeeTarget){
                System.debug('sort more >>>>>>>>>');
                return 1;
            }
            if(this.transactionFeeTarget == targetTableRec.transactionFeeTarget){
                System.debug('sort equal >>>>>>>>>');
                return 0;
            }
            System.debug('sort less >>>>>>>>>');
            return -1;
        }
        private Integer sortByTransactionFeeBottomUp(targetTableRecord targetTableRec){
            if(this.transactionFeeBottomUp > targetTableRec.transactionFeeBottomUp){
                return 1;
            }
            if(this.transactionFeeBottomUp == targetTableRec.transactionFeeBottomUp){
                return 0;
            }
            return -1;
        }
        private Integer sortByMainOperatingBankTarget(targetTableRecord targetTableRec){
            if(this.mainOperatingBankTarget > targetTableRec.mainOperatingBankTarget){
                return 1;
            }
            if(this.mainOperatingBankTarget == targetTableRec.mainOperatingBankTarget){
                return 0;
            }
            return -1;
        }
        private Integer sortByMainOperatingBankBottomUp(targetTableRecord targetTableRec){
            if(this.mainOperatingBankBottomUp > targetTableRec.mainOperatingBankBottomUp){
                return 1;
            }
            if(this.mainOperatingBankBottomUp == targetTableRec.mainOperatingBankBottomUp){
                return 0;
            }
            return -1;
        }
        private Integer sortByDealBaseFeeTarget(targetTableRecord targetTableRec){
            if(this.dealBaseFeeTarget > targetTableRec.dealBaseFeeTarget){
                return 1;
            }
            if(this.dealBaseFeeTarget == targetTableRec.dealBaseFeeTarget){
                return 0;
            }
            return -1;
        }
        private Integer sortByDealBaseFeeBottomUp(targetTableRecord targetTableRec){
            if(this.dealBaseFeeBottomUp > targetTableRec.dealBaseFeeBottomUp){
                return 1;
            }
            if(this.dealBaseFeeBottomUp == targetTableRec.dealBaseFeeBottomUp){
                return 0;
            }
            return -1;
        }
        private Integer sortByTotalBottomUp(targetTableRecord targetTableRec){
            if(this.totalBottomUp > targetTableRec.totalBottomUp){
                return 1;
            }
            if(this.totalBottomUp == targetTableRec.totalBottomUp){
                return 0;
            }
            return -1;
        }
        private Integer sortByTotalMiracle(targetTableRecord targetTableRec){
            if(this.totalMiracle > targetTableRec.totalMiracle){
                return 1;
            }
            if(this.totalMiracle == targetTableRec.totalMiracle){
                return 0;
            }
            return -1;
        }
        public Integer compareTo(Object obj){
            targetTableRecord targetTableRec = (targetTableRecord)(obj);
            if (SORT_BY == name_sort) {
                return sortByName(targetTableRec);
            }
            if (SORT_BY == transactionFeeTarget_sort) {
                return sortByTransactionFeeTarget(targetTableRec);
            }
            if (SORT_BY == transactionFeeBottomUp_sort) {
                return sortByTransactionFeeBottomUp(targetTableRec);
            }
            if (SORT_BY == mainOperatingBankTarget_sort) {
                return sortByMainOperatingBankTarget(targetTableRec);
            }
            if (SORT_BY == mainOperatingBankBottomUp_sort) {
                return sortByMainOperatingBankBottomUp(targetTableRec);
            }
            if (SORT_BY == dealBaseFeeTarget_sort) {
                return sortByDealBaseFeeTarget(targetTableRec);
            }
            if (SORT_BY == dealBaseFeeBottomUp_sort) {
                return sortByDealBaseFeeBottomUp(targetTableRec);
            }
            if (SORT_BY == totalBottomUp_sort) {
                return sortByTotalBottomUp(targetTableRec);
            }
            if (SORT_BY == totalMiracle_sort) {
                return sortByTotalMiracle(targetTableRec);
            }
            return 0;
        }
    }
    public class CRUDCustomBottomUpAnnualizedResponse {
        public Boolean success;
        public String errorMessage;
        public List<ModelExtensions.targetTableRecord> records;
        public Integer total;
        public CRUDCustomBottomUpAnnualizedResponse() {
            records = new List<ModelExtensions.targetTableRecord>();
            success = true;
        }
    }
    public class savingSalesTargetRequest{
        public String salesTargetId;
        public Double transactionFeeTarget;
        public Double mainOperatingBankTarget;
        public Double dealBaseFeeTarget;
    }
    public class savingSalesTargetsRequests{
        public List<savingSalesTargetRequest> salesTargetRequests;
    }
    public class savingBottomUpAnnualizedRequest{
        public String bottomUpAnnualizedId;
        public Double transactionFeeTF;
        public Double transactionFeeFX;
        public Double transactionFeeLI;
        public Double transactionFeeSS;
        public Double mainOperatingBankFloat;
        public Double mainOperatingBankCash;
        public Double mainOperatingBankKA;
        public Double dealBaseFeeFrontEnd;
        public Double dealBaseFeeDeriverative;
        public Double dealBaseFeeIBB;
        public Double dealBaseFeeInvestmentFee;
        public Double dealBaseFeeBA;
        public String businessClosed;
    }
    public class savingBottomUpAnnualizedRequests{
        public List<savingBottomUpAnnualizedRequest> bottomUpAnnualizedRequests;
    }
    //pan rein

    public class TFBsoAppBvw {
        public String tier;
        public String rate_type;
        public String sign;
        public String spread;
        public String tier_tenure;
        public String tier_tenure_type;
    }

    public class TFBsoAppAvw{
        public String opportunity_id;
        public String facility_cd;
        public String facility_limit;
        public String facility_status;
        public String facility_tenure;
        public String facility_tenure_type;
        public List<TFBsoAppBvw> tfb_so_opp_b_vw;
    }

    public class CMASmodelRS{
        public String batch_Name;
        public String component;
        public String createdate;
        public String cwu_ref_no;
        public String cwu_status;
        public String opportunity_id;
        public String email_addr;
        public String notification;
        public String cust_id;
        public String datetime_added;
        public List<TFBsoAppAvw> tfb_so_app_a_vw;
        public List<TFB_SO_TEAM_VW> tfb_so_team_vw;
        public List<TFB_SO_CADDR_VW> tfb_so_caddr_vw;
    }

    public class DetailMessage{
        public String type;
        public String messagesetnumber;
        public String messagenumber;
        public String messagetext;
        public String explaintext;
    }
    
    public class CMASmodelRSfail{
        public String batch_Name;
        public String faultcode;
        public String faultstring;
        public String runcode;
        public String detail;
        public String detail_keyinformation;
        public String detail_keyinformation_id;
        public List<DetailMessage> detail_message;
    }


    public class CreditWriteUpModel{
        public ModelExtensions.CreditWriteUpModelDetail TFB0186a01;
    }

    public class CreditWriteUpModelDetail{
        public ModelExtensions.EAIHeader EAIHeader;
        public ModelExtensions.CMSCCreditWriteUpModel CMSCCreditWriteUp;
        public ModelExtensions.CRMCustomers CRMCustomers;
        public ModelExtensions.CRMCustomer CRMCustomer;
    }

    public class EAIHeader{
        public String sourceTransactionId;
    }

    public class CMSCCreditWriteUpModel{
        public String CRMRefNum;
        public String origEmpNum;
        public String origUnitCode;
        public String origHubCode;
        public String createdDate;
        public String cobrwLPMCustNum;
        public String opportFacilsObj;
        public String docNum;
    }
    public class CRMCustomers{
        public ModelExtensions.CustomersVect customersVect;
    }
    public class CustomersVect{
        public ModelExtensions.CRMCustomer CRMCustomer;
    }
    public class CRMCustomer{
        public String num;
        public String LPMCustNum; 
        public String CISCustNum;
        public String brwRelTypeCode;
        public String ITCCode;
        public String docNum;
    }

    public class TFB_SO_TEAM_VW {
        public String primary_sale;
        public String primary_ps;
        public String emplid;
        public String sales_role_cd;
        public String sales_nm;
        public String email_addr;
        public String phone;
        public String extension;
        public String mobile;
        public String mobile_ext;
    }

    public class OpportFacilsObj{

    }

    public class CMSCOpportFacil{
        public String num;
        public String facilCode;
    }

    public class TFB_SO_CADDR_VW{
        public String addr_type;
        public String country_cd;
        public String moo_ban;
        public String building;
        public String soi;
        public String road;
        public String amphur;
        public String num;
        public String moo;
        public String floor;
        public String contact_dept;
        public String district;
        public String province;
        public String postal;
    }

}