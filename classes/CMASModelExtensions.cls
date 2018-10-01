public with sharing class CMASModelExtensions {
	
	//Request CI-136 Model
	public class CreditWriteUpModel{
		public CMASModelExtensions.CreditWriteUpModelDetail TFB0186a01;
	}
	public class CreditWriteUpModelDetail{
		public CMASModelExtensions.EAIHeader EAIHeader;
		public CMASModelExtensions.CMSCCreditWriteUpModel CMSCCreditWriteUp;
		public CMASModelExtensions.CRMCustomers CRMCustomers;
		public CMASModelExtensions.CRMCustomerSale CRMCustomer;
	}

	public class EAIHeader{
		public String serviceId;
		public String beginTimestamp;
		public String endTimestamp;
		public String transactionId;
		public String sourceTransactionId;
		public String sourceSystem;
		public String userId;
		public String password;
		public String status;
		public String reasonCode;
		public String reasonDesc;
	}

	public class CMSCCreditWriteUpModel{
		public String CRMRefNum;
		public String origEmpNum;
		public String origUnitCode;
		public String origHubCode;
		public String createdDate;
		public String cobrwLPMCustNum;
		public String docNum;
		public CMASModelExtensions.OpportFacilsObj opportFacilsObj;
	}
	public class OpportFacilsObj{
		public  CMASModelExtensions.OpportFacilsVect opportFacilsVect;
	}
	public class OpportFacilsVect{
		public CMASModelExtensions.CMSCOpportFacil CMSCOpportFacil;
	}
	public class CMSCOpportFacil{
		public String num;
		public String facilCode;
		public String facilLimitAmt;
	}
	public class CRMCustomers{
		public CMASModelExtensions.CustomersVect customersVect;
	}

	public class CRMCustomer{
		public String num;
		public String LPMCustNum; 
		public String CISCustNum;
		public String brwRelTypeCode;
		public String prospectFlag;
		public String CISTypeCode;
		public String docNum;
		public String svcBrchCode;
		public String ITCCode;
		public String indtryCde;
		public String occCode;
		public String salutationCode;
	}

	public class CRMCustomerSale{
		public String num;
		public String LPMCustNum; 
		public String CISCustNum;
		public String brwRelTypeCode;
		public CMASModelExtensions.SalesTeamObj salesTeamObj;
	}

	public class CustomersVect{
		public CMASModelExtensions.CRMCustomer CRMCustomer;
	}

	public class SalesTeamObj{
		public CMASModelExtensions.SalesEmpsVect salesEmpsVect;
	}

	public class SalesEmpsVect{
		public List<CMASModelExtensions.CRMSalesEmployee> CRMSalesEmployee;
	}
	public class CRMSalesEmployee{
		public String empNum;
		public String salesTypeCode;
		public String empName;
		public String email;
		public CMASModelExtensions.Phone phObj;
		public CMASModelExtensions.Phone mobilePhObj;
	}
	public class Phone{
		public String phoneNum;
		public String extNum;
	}

	//End request CI-136 Model


	//public class CMSCCreditWriteUp{
	//	public String exstAmt;
	//	public String peakAmt;
	//	public String exstPct;
	//	public String peakPct;
	//	public String estAmt;
	//	public String normAmt;
	//	public String normPct;
	//	public String chngeAmt;
	//}

	//public class OperationObjDetail{
	//	public String exstAmt;
	//	public String peakAmt;
	//	public String exstPct;
	//	public String peakPct;
	//	public String estAmt;
	//	public String normAmt;
	//	public String normPct;
	//	public String chngeAmt;
	//}

	//public class OperationObj{
	//	public OperationObjDetail avrgObj;
	//	public OperationObjDetail domeObj;
	//	public OperationObjDetail domeCashObj;
	//	public OperationObjDetail domeCrObj;
	//	public OperationObjDetail domeApDaysObj;
	//	public OperationObjDetail imObj;
	//	public OperationObjDetail imCashObj;
	//	public OperationObjDetail imCrObj;
	//	public OperationObjDetail imApDaysObj;
	//	public OperationObjDetail domeArDaysObj;
	//	public OperationObjDetail exObj;
	//	public OperationObjDetail exCashObj;
	//	public OperationObjDetail exCrObj;
	//	public OperationObjDetail exArDaysObj;
	//	public OperationObjDetail expLcPct;
	//}
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

	//FOR CI138-CRM0189I01
	public class TFB_SO_CUST_INFO{
		public String component;
		public String datetime_added;
		public String cust_id;
		public String lpm_no;
		public String cust_stat;
		public String tfb_cis_id;
		public String cust_type;
		public String id_no;
		public String first_name;
		public String last_name;
		public String eng_first_nm;
		public String eng_last_nm;
		public String branch_cd;
		public String itc_cd;
		public String biz_reg_dt;
		public String biz_reg_tp;
		public String tax_id;
		public String off_phone_no;
		public String off_phone_ext;
		public String mobile_phone_no;
		public String mobile_phone_ext;
		public String home_phone_no;
		public String home_phone_ext;
		public String cust_since_dt;
		public String cust_opr_dt;
		public String country_cd;
		public String spouse_first_nm;
		public String spouse_last_nm;
		public String marital_stat;
		public String biz_nature;
		public String industry_id;
		public String employer;
		public String occupation;
		public String salutation_cd;
		public String fax_no;
		public String fax_ext;
		public String trade_name;
		public String regis_capt;
		public String paid_up_capt;
		public String num_of_emp;
		public String industry_grp;
	}



}