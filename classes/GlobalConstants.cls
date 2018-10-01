/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global constants class for the project

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class GlobalConstants {

    public static final String DEBUG_LOG = 'DEBUG';
    public static final String ERROR_LOG = 'ERROR';
    public static final String INFO_LOG = 'INFO';
    public static final String WARN_LOG = 'WARN';
    public static final String WARNING_LOG = 'WARNING';

    public static final String STOCK_NEGOTIATION = 'Stock Negotiation';
    public static final String CREDIT_WRITE_UP = 'Credit Write Up'; 
    public static final String WAITING_FOR_CREDIT_APPROVAL = 'Waiting for Credit Approval';
    public static final String CREDIT_APPROVAL_PROCESS = 'Credit Approval Process';
    public static final String CASE_IS_REJECT = 'Case is Rejected';
    public static final String WAITING_FOR_CREDIT_SETUP = 'Waiting for Credit Setup';
    public static final String PARTIAL_LOAN_SETUP = 'Partial Loan Setup';
    public static final String ALL_LOAN_SETUP = 'All Loan Setup';
    public static final String CLOSE_LOST = 'Closed Lost';
    public static final String CLOSED_WON = 'Closed Won';
    public static final String AUTO_CLOSED = 'Auto Closed';
    public static final String NEW_OPPORTUNITY = 'New Opportunity';
    public static final String REGISTERED = 'Registered';
    public static final String NOT_REGISTER = 'Not Register';
    public static final String FINISHED = 'Finished';
    public static final String FINISHED_DOT = 'Finished.';
    public static final String CANCELLED = 'Cancelled';
    public static final String REOPEN = 'Reopen';

    public static final String CANNOT_INSERT_CAMMEM = 'Invited Guest is not Target Customer for this Event';

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_DONE = 'Done';
    public static final String STATUS_GO = 'Going';
    public static final String STATUS_SHOW_UP = 'Show Up';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_CHANGED_OWNER = 'Changed Owner';
    public static final String DELETED_OPPORTUNITY = 'Deleted Opportunity';
    public static final Set<String> OPP_STAGE_COMPLETE_WIN = new Set<String>{ALL_LOAN_SETUP,STATUS_CHANGED_OWNER};
    public static final Set<String> OPP_STAGE_COMPLETE_LOST = new Set<String>{CLOSE_LOST,AUTO_CLOSED,DELETED_OPPORTUNITY};
    public static final Set<String> OPP_STAGE_CLOSE_JOB = new Set<String>{'All Loan Setup','Closed Lost','Auto Closed','Deleted Opportunity','Closed Won'};
    public static final Set<String> OPP_STAGE_NOTCLOSE_JOB = new Set<String>{'Stock Negotiation','Create Write Up','Waiting for Credit Approval','Case is Rejected','Waiting for Credit Setup','Partial Loan Setup','New Opportunity'};

    public static final String CUSTOMER_INTERESTED = 'Customer Interested';
    public static final String NOT_INTERESTED_THIS_TIME = 'Not Interested This Time';
    public static final String NOT_INTERESTED = 'Not interested';
    public static final String APP_IN = 'App In';

    public static final String CANNOT_APPLY = 'Cannot apply';
    public static final String FACE_TO_FACE = 'Face to Face';
    public static final String PHONE_CALL = 'Phone Call';
    public static final String NOT_INTEREST = 'Not interest';
    public static final String INTEREST_AND_CAN_APPLY = 'Interest and can apply';
    public static final String INTEREST_WITH_CONDITION = 'Interest with condition';
    
    public static final String OFFER_INTEREST_AND_CAN_APPLY   = 'Interest and can apply';
    public static final String OFFER_INTEREST_WITH_CONDITION  = 'Interest with condition';
    public static final String OFFER_NOT_INTEREST             = 'Not interest';
    public static final String OFFER_CANNOT_APPLY             = 'Cannot apply';
    public static final String OFFER_CUSTOMER_INTERESTED      = 'Customer interested';
    public static final String OFFER_CUSTOMER_NOT_INTERESTED  = 'Customer not interested';

    public static final String READ = 'Read';
    public static final String PLAN = 'Plan';
    public static final String PLANNED = 'Planned';
    public static final String CANCEL = 'Cancel';
    public static final String ACTIVE = 'Active';
    public static final String EVENT = 'Event';
    public static final String INVITATION = 'Invitation';
    public static final String POOL = 'Pool';
    public static final String PORT = 'Port';
    public static final String RELATIONSHIP_MANAGER = 'Relationship Manager';
    public static final String ASSIGN_TO_SUBJECT = '{0} : {1}';
    public static final String CHANGE_DATE_SUBJECT = 'Change Call Plan/Call Report Date : {0}';
    public static final String OPP_PRODUCT_WORK_IN_PROCESS = 'Work in Process';
    public static final String OPP_PRODUCT_PRE_APPROVED = 'Pre Approved';
    public static final String OPP_PRODUCT_FINAL_APPROVED = 'Final Approved';
    public static final String OPP_PRODUCT_APP_IN = 'APP IN';
    public static final Set<String> OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB = new Set<String>{'On Process',OPP_PRODUCT_APP_IN,'Return',OPP_PRODUCT_WORK_IN_PROCESS,'Rejected',OPP_PRODUCT_PRE_APPROVED,OPP_PRODUCT_FINAL_APPROVED,'Not Interested','',null};
    public static final Set<String> OPP_PRODUCT_STATUS_CANNOT_CLOSEJOB_RBS = new Set<String>{'On Process',OPP_PRODUCT_APP_IN,'Return',OPP_PRODUCT_WORK_IN_PROCESS,OPP_PRODUCT_PRE_APPROVED,'Not Interested','',null};
    public static final Set<String> OPP_PRODUCT_STATUS_FOR_UPDATE_OPPPRODUCT = new Set<String>{'Completed','Cancelled','Closed Won','Closed Lost'};
    public static final Set<String> APP_HISTORY_STATUS_FOR_UPDATE_APPHISTORY = new Set<String>{'Cancelled','Closed Won','Closed Lost'};

    public static final String ROLE = 'Role';
    public static final String ROLE_AND_SUBORDINATE = 'RoleAndSubordinates';

    public static final Set<String> RM_JOB_CODE = new Set<String>{'ME4A','ME4B','ME3D','SE4A'};
    public static final Set<String> TM_JOB_CODE = new Set<String>{'ME3A','SE3A'};
    public static final Set<String> AH_JOB_CODE = new Set<String>{'ME2A','SE2A'};
    public static final Set<String> NH_JOB_CODE = new Set<String>{'ME1A','SE1A'};

    public static final String SYSTEM_ADMIN = 'System Administrator';
    public static final String SME_RM = 'SME-RM';
    public static final String SME_TM = 'SME-TM';
    public static final String SME_NH = 'SME-NH';
    public static final String SME_AH = 'SME-AH';
    public static final String SME_SUPER_USER = 'SME-Super User';
    public static final String SME_ADMIN = 'SME-Admin';
    public static final String SME_CAMPAIGN = 'SME-Campaign';
    public static final String SME_EVENT = 'SME-Event';
    public static final String SME_EVENT_NON_TARGET = 'SME-Event (Non-Targeted)';
    public static final String SME_LEAD_CAMPAIGN_DEVNAME = 'SME_Lead_Campaign';
    public static final String SME_EVENT_NON_TARGET_DEVNAME = 'SME_Event_Non_Targeted';
    public static final String SME_EVENT_DEVNAME = 'SME_Event';
    public static final String SME_FRANCHISE = 'แฟรนไชส์';
    public static final String TELESALES_CAMPAIGN_DEVNAME = 'Telesales_Kbank';

    public static final String RBS_LEAD_DEVNAME = 'RBS_Lead';
    public static final String RBS_EVENT_NON_TARGETED_DEVNAME = 'RBS_Event_Non_Targeted';
    public static final String RBS_EVENT_DEVNAME = 'RBS_Event';
    public static final String RBS_CAMPAIGN_MEMBER_DEVNAME = 'RBS_Campaign_Member';
    
    public static final String RBS_RM_ABM = 'RBS-ABM';
    public static final String RBS_RM_BAR = 'RBS-BAR';
    public static final String RBS_TM = 'RBS-BM';
    public static final String RBS_AH = 'RBS-ZM';
    public static final String RBS_NH = 'RBS-NH';
    public static final String RBS_ADMIN = 'RBS-Admin';
    public static final String RBS_BUDGET_ADMIN = 'RBS-Budget Admin';

    public static final String SME_EMAIL_TEMPLATE_NEW_EVENT = 'SME_New_Event';
    public static final String SME_EMAIL_TEMPLATE_MODIFIED_EVENT = 'SME_Modified_Event';
    public static final String SME_EMAIL_TEMPLATE_CANCEL_EVENT = 'SME_Cancel_Event';

    public static final String SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL = 'SME_New_Event_for_External_User';
    public static final String SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL = 'SME_Modified_Event_for_External_User';
    public static final String SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL = 'SME_Cancel_Event_for_External_User';

    public static final String CBS_LEAD_DEVNAME = 'CBS_Lead';

    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';

    public static final String AH_SUMMITED = 'AH Submitted';
    public static final String SUBMITTED = 'Submitted';
    
    public static final String REQUEST_OWNERSHIP = 'Request Ownership';
    public static final String REFER_OUT = 'Refer Out';
    public static final String BRANCH_CLOSENESS = 'Branch Closeness';
    public static final String BRANCH_CLOSENESS_RELEASE = 'Branch Closeness Release';
    public static final String BRANCH_CLOSENESS_REQUEST = 'Branch Closeness Request';
    public static final String RELEASE_OWNERSHIP = 'Release Ownership';
    public static final String RELEASE_OWNERSHIP_DEVNAME = 'Release_Ownership';
    public static final String RELEASE_OWNERSHIP_DEVNAME_CBS = 'Release_Ownership_CBS';
    public static final String YEAR_END_ASSIGNMENT = 'Year End Assignment';
    public static final String CLOSED = 'Closed';
    public static final String CONTACTED = 'Contacted';
    public static final String CALLREPORT_CLOSED = 'Closed / Cancelled Call Plan';
    //public static final String SME_PROSPECT = 'SME-Prospect';
    //public static final String SME_CUSTOMER = 'SME-Customer';
    
    public static final String ORGANIZATION_PROSPECT = 'Organization Prospect';
    public static final String ORGANIZATION_CUSTOMER = 'Organization Customer';
    public static final String INDIVIDUAL_PROSPECT = 'Individual Prospect';
    public static final String CALL_REPORT = 'Call Report';
    public static final String CALL_REPORT_NO_PLAN = 'Call Report (No Plan)';
    public static final String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN = 'Secondary Call Report Main Borrower (No plan)';
    public static final String CALL_PLAN = 'Call Plan';
    public static final String CLOSE_WON = 'Close Won';
    public static final String OPP = 'Opp';

    public static final String CREDIT_OPPORTUNITY               = 'Credit Opportunity';
    public static final String NON_CREDIT_OPPORTUNITY           = 'Non-Credit Opportunity';
    
    public static final String NEW_CALL_PLAN = 'New Call Plan';
    public static final String LEAD_FOR_SALES = 'Lead For Sales';
    public static final String LEAD_FOR_SALES_2 = 'Lead for Sales';
    public static final String LEAD_TO_DO = 'Lead To Do';
    public static final String LEAD_TO_INFORM = 'Lead To Inform';
    public static final String LEAD_FOR_FEEDBACK = 'Lead for Feedback';
    public static final String LEAD_FOR_ACTION_WITH_CUSTOMER = 'Lead for Action with Customer';

    public static final String CAMPAIGN_REC = 'SME- Lead / Campaign';
    public static final String CAMPAIGN_CBS_REC = 'CBS - Lead';

    public static final String INTEGRATION_USER = 'KBANK-Integration';
    public static final String PROFILE_SOLAR = 'Solar';
    public static final String PROFILE_ITID = 'KBANK-ITID';
    
    public static final String CREATE_WRITE_UP = 'Create Write Up';
    public static final String ON_PROCESS = 'On Process';
    public static final String CMAS = 'CMAS';
    public static final String NON_CMAS = 'Non CMAS';
    public static final String NO_RC_CODE = 'NORCCODE';

    public static final String BAD = 'Bad';
    public static final String DEAD = 'Dead';
    public static final String CLOSED_BUSINESS = 'Closed Business';
    public static final String AMLO_LIST = 'AMLO List';
    public static final String EXIT_PLAN = 'Exit Plan';
    public static final String CRIMINAL_OFFENSE = 'Criminal Offense';
    public static final String OTHER_SEGMENT = 'Other Segment';
    public static final String REJECT = 'Reject';
    public static final String CLOSED_BY_SYSTEM = 'Closed by System';

    public static final String CAMPAIGN = 'Campaign';
    public static final String CANCEL_CAMPAIGN = 'Cancel Campaign';
    public static final String CANCEL_PROCESS = 'Cancelling Process';
    public static final String EXPIRE_PROCESS = 'Expiry Process';
    public static final Set<String> CAMPAIGN_FIELDSTRACKING =  new Set<String>{'StartDate','EndDate','Effective_Date__c','Status','Type__c','Sharing__c'};

    public static final String CANCEL_LEAD = 'Cancel Lead';
    public static final String EXPIRED = 'Expired';
    public static final String LEAD_EXPIRED = 'Lead Expired';
    public static final String TG_EXPIRED = 'TG Expired';
 
    public static final String VOUCHER = 'Voucher';
    public static final String CASHBACK = 'Cashback';


    public static final String ORGANIZATION = Label.Create_Prospect_Organization;
    public static final String INDIVIDUAL = Label.Create_Prospect_Individual;

    public static final String INDIVIDUAL_PROSPECT_DEVNAME = 'Individual_Prospect';
    public static final String ORGANIZATION_PROSPECT_DEVNAME = 'Organization_Prospect';
    public static final String INDIVIDUAL_BOL_DEVNAME = 'Individual_BOL';
    public static final String ORGANIZATION_BOL_DEVNAME = 'Organization_BOL';
    public static final String INDIVIDUAL_CUSTOMER_DEVNAME = 'Individual_Customer';
    public static final String ORGANIZATION_CUSTOMER_DEVNAME = 'Organization_Customer';
    public static final String INDUSTRIESHOUSEHOLD_DEVNAME = 'IndustriesHousehold';
    public static final String INDUSTRIESBUSINESS_DEVNAME = 'IndustriesBusiness';
    public static final String PERSONACCOUNT_DEVNAME = 'PersonAccount';

    public static final String SME_CALL_REPORT_SECONDARY_DEVNAME            = 'SME_Call_Report_Secondary';
    public static final String SME_CALL_REPORT_READ_ONLY_DEVNAME            = 'SME_Call_Plan_Call_Report_Read_Only';
    public static final String SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME = 'SME_Call_Report_without_Plan_Read_Only';
    public static final String SME_CALL_PLAN_DEVNAME                        = 'SME_Call_Plan';
    public static final String SME_CALL_PLAN_READ_ONLY_DEVNAME              = 'SME_Call_Plan_Read_Only';
    public static final String SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME   = 'SME_Call_Plan_Call_Report_Editable';
    public static final String SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME         = 'SME_Call_Report_without_Plan';

    public static final String CBS_CALL_PLAN_DEVNAME                            = 'CBS_Call_Plan';
    public static final String CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME    = 'CBS_Call_Report_without_Plan_Editable';
    public static final String CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME       = 'CBS_Call_Plan_Call_Report_Editable';
    public static final String CBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME      = 'CBS_Call_Plan_Call_Report_Read_Only';
    public static final String CBS_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME   = 'CBS_Call_Report_without_Plan_Read_Only';
    public static final String CBS_CALL_PLAN_READ_ONLY_DEVNAME                  = 'CBS_Call_Plan_Read_Only';

    public static final String RBS_CALL_PLAN_DEVNAME                        = 'RBS_Call_Plan';
    public static final String RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME       = 'RBS_Call_Plan_Call_Report_Editable';
    public static final String RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME       = 'RBS_Call_Plan_Call_Report_Read_Only';
    public static final String RBS_CALL_PLAN_READ_ONLY_DEVNAME       = 'RBS_Call_Plan_Read_Only';
    public static final String RBS_CALL_PLAN_FOR_APPROVE_DEVNAME       = 'RBS_Call_Plan_for_Approve';

    public static final Set<String> CALL_PLAN_CALL_REPORT_NEWABLE_SET = new Set<String>{SME_CALL_REPORT_SECONDARY_DEVNAME,SME_CALL_PLAN_DEVNAME,CBS_CALL_PLAN_DEVNAME,RBS_CALL_PLAN_DEVNAME,SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME,CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME,RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME};
    public static final Set<String> CALL_PLAN_CALL_REPORT_SME_DEVNAME_SET = new Set<String>{SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME,SME_CALL_REPORT_READ_ONLY_DEVNAME,SME_CALL_REPORT_SECONDARY_DEVNAME,SME_CALL_PLAN_READ_ONLY_DEVNAME,SME_CALL_PLAN_DEVNAME,SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME,SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME};
    public static final Set<String> CALL_PLAN_CALL_REPORT_RBS_DEVNAME_SET = new Set<String>{RBS_CALL_PLAN_DEVNAME,RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME,RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME,RBS_CALL_PLAN_READ_ONLY_DEVNAME,RBS_CALL_PLAN_FOR_APPROVE_DEVNAME};
    public static final Set<String> CALL_REPORT_SME_DEVNAME_SET = new Set<String>{SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME,SME_CALL_REPORT_READ_ONLY_DEVNAME,SME_CALL_REPORT_SECONDARY_DEVNAME,SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME,SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME};
    public static final Set<String> CALL_REPORT_RBS_DEVNAME_SET = new Set<String>{RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME,RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME};


    public static final String JOB_DEVNAME           = 'Job';
    public static final String CLOSED_JOB_DEVNAME           = 'Closed_Job';
    /***** Deprecated Recordtype *****/
    public static final String CALL_PLAN_DEVNAME                        = 'CallPlan';
    public static final String CLOSED_CANCELLED_CALLPLAN_DEVNAME        = 'ClosedCancelledCallPlan';
    public static final String NEW_CALL_PLAN_DEVNAME                    = 'New_Call_Plan';
    public static final String CBS_CLOSED_CANCELLED_CALLPLAN_DEVNAME    = 'CBS_Closed_Cancelled_Call_Plan';
    public static final String CALL_REPORT_DEVNAME                      = 'CallReport';
    public static final String CALL_REPORT_NO_PLAN_DEVNAME              = 'CallReportNoPlan';
    public static final String CLOSED_CANCELLED_CALLREPORT_DEVNAME      = 'ClosedCancelledCallReport';
    public static final String CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME = 'ClosedCancelledCallReportNoPlan';
    public static final String CONTACTED_CALLREPORT_NO_P_E_DEVNAME      = 'Closed_Contacted_Call_Report_No_Plan_Editable';
    public static final String CONTACTED_CALLREPORT_E_DEVNAME           = 'Closed_Contacted_Call_Report_Editable';
    public static final String CONTACTED_CALLREPORT_E_LEAD_DEVNAME      = 'Closed_Contacted_Call_Report_Editable_Lead';
    public static final String CONTACTED_CALLREPORT_NO_P_LAYOUT_DEVNAME = 'Closed_Contacted_Secondary_Call_Report_No_Plan_Layout';
    public static final String CONTACTED_SECONDARY_MAIN_BORROWER_NO_P_DEVNAME = 'Closed_Contacted_Secondary_Call_Report_Main_Borrower_No_plan';
    public static final String SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME    = 'Secondary_Call_Report_No_plan';
    public static final String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME = 'Secondary_Call_Report_Main_Borrower_No_plan';

    public static final String CBS_CALL_REPORT_DEVNAME                      = 'CBS_Call_Report';
    public static final String CBS_CALL_REPORT_NO_PLAN_DEVNAME              = 'CBS_Call_Report_No_Plan';
    public static final String CBS_CLOSED_CANCELLED_CALLREPORT_DEVNAME      = 'CBS_Closed_Cancelled_Call_Report';
    public static final String CBS_CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME = 'CBS_Closed_Cancelled_Call_Report_No_Plan';
    public static final String CBS_CONTACTED_CALLREPORT_NO_P_E_DEVNAME      = 'CBS_Closed_Contacted_Call_Report_No_Plan_Editable';
    public static final String CBS_CONTACTED_CALLREPORT_E_LEAD_DEVNAME      = 'CBS_Closed_Contacted_Call_Report_Editable';
    
    public static final String CREDIT_OPPORTUNITY_DEVNAME               = 'Credit_Opportunity';
    public static final String NON_CREDIT_OPPORTUNITY_DEVNAME           = 'Non_Credit_Opportunity';
    public static final String SERVICING_OPPORTUNITY_DEVNAME           = 'Servicing_Opportunity';
    /***** End Deprecated Recordtype *****/

    public static final String OWNERSHIP_PERMANENT = 'Permanent';
    public static final String OWNERSHIP_TEMPORARY = 'Temporary';

    public static final String POOL_TEMPORARY = 'Pool (Temporary)';
    public static final String REASON_OTHER_TEAM = 'Other Team';
    public static final String REASON_WRONG_AREA = 'Wrong Area';
    public static final String REASON_CBS_WRONG_AREA = 'Wrong Area(CBS)';
    public static final String REASON_NOT_SME = 'Not SME Segment';
    public static final String REASON_NATIONALITY = 'Nationality';
    public static final String REASON_NOT_CBS = 'Not CBS segment';
    public static final String REASON_COMPANY_RELATED = 'Company Related';
    public static final String LOW_POTENTIAL = 'Low Potential';
    public static final String SPECIAL_INDUSTRY = 'Special Industry';
    public static final String REASON_OTHER_SEGMENT = 'Other Segment';
    public static final String REASON_TM_POOL = 'TM Pool';

    public static final String OWNERSHIP_REQUEST_POOL_DEVNAME = 'Request_Ownership_Pool_Temporary';
    public static final String OWNERSHIP_REQUEST_PORT_DEVNAME = 'Request_Ownership_Port';
    public static final String OWNERSHIP_REQUEST_RBS_DEVNAME = 'Request_Ownership_RBS';
    public static final String OWNERSHIP_RELEASE_RBS_DEVNAME = 'Release_Ownership_RBS';
    public static final String OWNERSHIP_REQUEST_RBS_READONLY_DEVNAME = 'Request_Ownership_RBS_Read_Only';
    public static final String OWNERSHIP_RELEASE_RBS_READONLY_DEVNAME = 'Release_Ownership_RBS_Read_Only';
    //public static final String OWNERSHIP_REQUEST_PORT_DEVNAME_CBS = 'Request_Ownership_CBS_Port';

    public static final String PRIMARY_SEGMENT_CODE_LM = 'LM';
    public static final String PRIMARY_SEGMENT_CODE_LR = 'LR';
    public static final String PRIMARY_SEGMENT_CODE_SM = 'SM';
    public static final String PRIMARY_SEGMENT_CODE_SR = 'SR';
    public static final String PRIMARY_SEGMENT_CODE_UM = 'UM';
    public static final String PRIMARY_SEGMENT_CODE_UR = 'UR';
    public static final String PRIMARY_SEGMENT_CODE_XS = 'XS';
    public static final String PRIMARY_SEGMENT_CODE_MI = 'MI';
    public static final String PRIMARY_SEGMENT_CODE_PC = 'PC';
    public static final String PRIMARY_SEGMENT_CODE_TC = 'TC';

    public static final String PRIMARY_SEGMENT_CODE_CB = 'CB';
    public static final String PRIMARY_SEGMENT_CODE_MB = 'MB';

    public static final String PRIMARY_SEGMENT_CODE_IR = 'IR';
    public static final String PRIMARY_SEGMENT_CODE_XR = 'XR';
    public static final String PRIMARY_SEGMENT_CODE_PR = 'PR';
    public static final String PRIMARY_SEGMENT_CODE_TR = 'TR';
    public static final String PRIMARY_SEGMENT_CODE_SO = 'SO';
    public static final String PRIMARY_SEGMENT_CODE_RO = 'RO';
    public static final String PRIMARY_SEGMENT_CODE_OT = 'OT';

    public static final Set<String> OT_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_OT};
    public static final Set<String> AF_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_PC};
    public static final Set<String> CBS_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_CB,PRIMARY_SEGMENT_CODE_MB};
    public static final Set<String> RBS_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_RO,PRIMARY_SEGMENT_CODE_MI,PRIMARY_SEGMENT_CODE_TC};
    public static final Set<String> SME_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_LM,PRIMARY_SEGMENT_CODE_SM,PRIMARY_SEGMENT_CODE_UM,PRIMARY_SEGMENT_CODE_XS,PRIMARY_SEGMENT_CODE_SO};
    public static final Set<String> SE_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_SM};
    public static final Set<String> ME_PRIMARY_SEGMENT_CODE_SET = new Set<String>{PRIMARY_SEGMENT_CODE_UM,PRIMARY_SEGMENT_CODE_LM};

    public static final String SEGMENT_SE = 'SE';
    public static final String SEGMENT_ME = 'ME';
    public static final String SEGMENT_CB = 'CB';
    public static final String SEGMENT_MB = 'MB';
    public static final String SEGMENT_BN = 'BN';
    public static final String SEGMENT_AF = 'AF';
    public static final String SEGMENT_PC = 'PC';
    public static final Set<String> SME_SEGMENT_CODE_SET = new Set<String>{SEGMENT_SE,SEGMENT_ME};
    public static final Set<String> CBS_SEGMENT_CODE_SET = new Set<String>{SEGMENT_CB,SEGMENT_MB};
    public static final Set<String> RBS_SEGMENT_CODE_SET = new Set<String>{SEGMENT_CB,SEGMENT_MB};
    public static final Set<String> AF_SEGMENT_CODE_SET = new Set<String>{SEGMENT_CB,SEGMENT_MB};

    public static final String CBS = 'CBS';
    public static final String CBS_FSVP     = 'CBS-FSVP';
    public static final String CBS_TM       = 'CBS-TM';
    public static final String CBS_TL       = 'CBS-TL';
    public static final String CBS_RM       = 'CBS-RM';
    public static final String CBS_ADMIN    = 'CBS-Admin';
    public static final String CBS_MIDDLE_OFFICE = 'CBS-Middle Office';
    public static final String CBS_EVP     = 'KBank-EVP';
    public static final String CBS_NHTL     = 'CBS-NHTL';//not real profile name

    public static final String LEAD_SUB_TYPE_DPD = 'DPD';
    public static final String LEAD_SUB_TYPE_OFFER_CUSTOMER = 'เพื่อนำเสนอลูกค้า';
    public static final String LEAD_SUB_TYPE_TO_INFORM = 'เพื่อทราบ';
    public static final String LEAD_SUB_TYPE_FOLLOW_UP_RM = 'เพื่อติดตาม RM';
    public static final String LEAD_SUB_TYPE_STRONG_FORMULA = 'Strong Formula';
    public static final String LEAD_SUB_TYPE_STRONG_HYBRID = 'Strong Hybrid';
    public static final String LEAD_SUB_TYPE_REFINANCE = 'Refinance';
    public static final String LEAD_SUB_TYPE_CHEQUE = 'Cheque';
    public static final String LEAD_SUB_TYPE_REFER = 'Refer';
    public static final String LEAD_SUB_TYPE_BA = 'BA';
    public static final String LEAD_SUB_TYPE_LI = 'LI';
    public static final String LEAD_SUB_TYPE_ACCOUNT_PLAN = 'Account Plan';
    public static final String LEAD_SUB_TYPE_VALUE_CHAIN = 'Value Chain';

    public static final String LEAD_SUB_TYPE_PN_UN_USED = 'PN Unused';
    public static final String LEAD_SUB_TYPE_CLOSE = 'ปิดสาขา';
    public static final String LEAD_SUB_TYPE_EDC = 'EDC';
    public static final String LEAD_SUB_TYPE_VALUE_CHAIN_CHAIN = 'Value Chain_Chain';
    public static final String LEAD_SUB_TYPE_STRATEGIC_PROVINCE = 'Strategic Province';
    public static final String LEAD_SUB_TYPE_ACCOUNT_PLANNING_HUB = 'Account Planning_Hub';
    public static final String LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST = 'Trade_ลดดอกเบี้ย';
    public static final String LEAD_SUB_TYPE_TRADE_DECREASE_FEE = 'Trade_ลดค่าธรรมเนียม';
    public static final String LEAD_SUB_TYPE_TRADE_INCREASE_LOAN = 'Trade_เพิ่มวงเงิน';
    public static final String LEAD_SUB_TYPE_TRADE_RELATIONSHIP = 'Trade_สร้างความสัมพันธ์';
    public static final String LEAD_SUB_TYPE_INACTIVE = 'Inactive';
    public static final String LEAD_SUB_TYPE_REFUND_FEE = 'ขอคืนค่าธรรมเนียม';

    public static final String  CAMP_TYPE_NON_TARGET = 'Non-Targeted';
    public static final String  CAMP_TYPE_TARGET = 'Targeted';

    public static final String  LEAD_HOT = 'Hot';
    public static final String  LEAD_WARM = 'Warm';
    public static final String  LEAD_COLD = 'Cold';

    public static final String  LEADMOBILE_ON_SFDC_KPLUS = '03 Sales Smart and KPLUS SME';

    public static final String LEAD_RESPONSE_BAD_LEAD = '1. Lead ไม่ถูกต้อง';

    public static final String WS_TIME_OUT_CASE = 'Read timed out';
    public static final String WS_SERVICE_CANNOT_CONNECT = '500';
    public static final String WS_SERVICE_UNAVAILABLE_CASE = '503';
    public static final String WS_DATABASE_UNAVAILABLE_CASE = '504';//1906503
    public static final String WS_INCORRECT_USER_PASS_CASE = '401';
    public static final String WS_URI_UNAVAILABLE_CASE = '404';

    public static final Integer SEGMENT_SE_MAX_SALE_SIZE = 40000000;
    public static final Double SEGMENT_CB_MIN_SALE_SIZE = 400000000.00;
    public static final Double SEGMENT_CB_MAX_SALE_SIZE = 5000000000.00;
    public static final Double SEGMENT_MB_MIN_SALE_SIZE = 5000000000.00;

    public static final String NORMAL_TASK = 'NormalTask';
    public static final String COMPLETED_TASK = 'Completed_Task';
    public static final String LEAD_TASK = 'Lead_Task';
    public static final Set<String> CBS_BKK_HUBLIST = new Set<String>{'กทม.','นครนายก','นครปฐม','นนทบุรี','ปทุมธานี','สมุทรปราการ','สมุทรสงคราม','สมุทรสาคร','พระนครศรีอยุทยา'};
    public static final String TARGET_LIST_TYPE = 'Target_List__c';


    public static final String OPP_PLAN_CREDIT = 'Credit';
    public static final String OPP_PLAN_NON_CREDIT = 'Non-Credit';
    public static final String OPP_PLAN_EXPLORE = 'Explore';
    public static final String OPP_PLAN_WORK_IN_PROCESS = 'Work in Process';
    public static final String OPP_PLAN_PITCHING = 'Pitching';
    public static final String OPP_PLAN_NEGOTIATION = 'Negotiation';
    public static final String OPP_PLAN_WIN_MANDATE = 'Win/Mandate';
    public static final String OPP_PLAN_LOST = 'Lost';
    public static final String OPP_PLAN_CANCELLED = 'Cancelled by Customer';
    public static final String OPP_PLAN_REJECTED = 'Rejected by KBank';
    public static final String OPP_PLAN_NOT_INTEREST = 'Not Interested';

    public static final String NONE = '--None--';
    public static final String INTERESTED_RESPONSE = '1.สนใจ';
    public static final String OPP_PLAN_CREDITANDNONCREDIT = 'Credit & Non-Credit';

    /*Panachai Reinthavorn CBS_CallReportNewEdit_Controller Constants*/
    //public static final Set<String> LIMIT_AMOUNT_INCOME_BANK = new Set<String>{'Trade','FX','Deposit'};
    //public static final Set<String> LIMIT_AMOUNT = new Set<String>{'EDC'};
    //public static final Set<String> INCOME_BANK = new Set<String>{'Cash'};
    //public static final String OPP_PLAN_CREDITANDNONCREDIT = 'Credit & Non-Credit';
    //public static final Set<String> CREDIT_PRODUCT_NAMESET = new Set<String>{'OD/PN/LI','LC/TR/PC/DLC','Long Term','KL/KF&E','FXDE','PO/SPO/PP/Advisory/IFF','SBLC','M&A','REIT','IPO','Syndicated Loan','Debenture'};
    //public static final Set<String> NONCREDIT_PRODUCT_NAMESET = new Set<String>{'Trade','FX','Deposit','EDC','Cash'};
    public static final String DEFAULT_CBS_CALLREPORT_STATUS = 'Contacted';
    public static final String DEFAULT_CBS_NEW_CONTACT_CONTACTPOSITION = 'อื่นๆ โปรดระบุ';
    public static final String DEFAULT_CBS_OPPORTUNITYPLANNING_STATUS = 'Explore';
    public static final String DEFAULT_CBS_CONTACT_CONTACTPOSITION_OTHER = 'อื่นๆ โปรดระบุ';
    
    public static final String CANCEL_BY_ADMIN = 'Cancel by Admin';
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_PENDING = 'Pending';
    public static final String APPROVAL_IN_PROGRESS = 'Approval In Progress';
    public static final String WAITING_FOR_APPROVAL = 'Waiting for Approval';
    public static final String RECALLED = 'Recalled';
    public static final String COMPLETE = 'Complete';
    public static final String PROCESSING = 'Processing';
    public static final String UW_APPROVE = 'UW Approve';
    public static final String WAITING_TO_COMPLETE = 'Waiting to Complete';

    public static final String ON_PROCESS_BY_SC = 'On process by SC';
    public static final String ON_PROCESS_BY_TL = 'On process by TL';
    public static final String ON_PROCESS_BY_FSVP = 'On process by FSVP';
    public static final String ON_PROCESS_BY_PM = 'On process by PM';
    public static final String ON_PROCESS_BY_SP = 'On process by SP';
    public static final String ESCALATE_REASSIGNED = 'Escalated/Reassigned';

    public static final String CBS_OPEN_ISSUE_NORMAL_REC = 'CBS_Open_Issue_Normal';
    public static final String CBS_OPEN_ISSUE_PARENT_REC = 'CBS_Open_Issue_Parent';
    public static final String CBS_OPEN_ISSUE_SECOND_REC = 'CBS_Open_Issue_Secondary';
    public static final String CBS_CLOSED_ISSUE_NORMAL_REC = 'CBS_Closed_Rejected_Issue_Normal';
    public static final String CBS_CLOSED_ISSUE_PARENT_REC = 'CBS_Closed_Rejected_Issue_Parent';
    public static final String CBS_CLOSED_ISSUE_SECOND_REC = 'CBS_Closed_Rejected_Issue_Secondary';
    public static final String CBS_CLOSED_ISSUE_NORMAL_NO_RATING_REC = 'CBS_Closed_Rejected_Issue_Normal_No_Rating';
    public static final String CBS_CLOSED_ISSUE_PARENT_NO_RATING_REC = 'CBS_Closed_Rejected_Issue_Parent_No_Rating';
    public static final String CBS_CLOSED_ISSUE_SECOND_NO_RATING_REC = 'CBS_Closed_Rejected_Issue_Secondary_No_Rating';
    public static final String CBS_CLOSED_ISSUE_NORMAL_READ_ONLY_REC = 'CBS_Closed_Rejected_Issue_Normal_Read_Only';
    public static final String CBS_CLOSED_ISSUE_PARENT_READ_ONLY_REC = 'CBS_Closed_Rejected_Issue_Parent_Read_Only';
    public static final String CBS_CLOSED_ISSUE_SECOND_READ_ONLY_REC = 'CBS_Closed_Rejected_Issue_Secondary_Read_Only';

    public static final String CBS_ISSUELOG_CANCELLED = 'Cancelled';
    public static final String CBS_ISSUELOG_DONE = 'Done';
    public static final String CBS_ISSUELOG_REJECT = 'Rejected';
    public static final String CBS_ISSUELOG_CLOSE_WON = 'Closed Won';
    public static final String CBS_ISSUELOG_CLOSE_LOST = 'Closed Lost';
    public static final String CBS_ISSUELOG_CLOSE = 'Closed';

    public static final String ISSUE_LOG_ESCALATE_TEMPLATE = 'Issue_Log_Escalate_Issue_Log_CBS';
    public static final String ISSUE_LOG_NEW_TEMPLATE = 'Issue_Log_New_Issue_Log_CBS';
    public static final String ISSUE_LOG_RECALL_TEMPLATE = 'Issue_Log_Recall_Issue_Log_CBS';
    public static final String ISSUE_LOG_REJECT_TEMPLATE = 'Issue_Log_Reject_Issue_Log_CBS';
    public static final String ISSUE_LOG_UPDATE_TEMPLATE = 'Issue_Log_Issue_Log_Status_Updated_CBS';
    public static final String ISSUE_LOG_CANCEL_TEMPLATE = 'Issue_Log_Changed_Customer_Owner_CBS';
    public static final String ISSUE_LOG_DAT = '-';

    /*Panachai Reinthavorn email*/
    public static final String TEAM_TARGET_NOTIFICATION_TEMPLATE = 'Team_Target_Notification_Template';
    public static final String GROUP_CBS_SP = 'CBS - SP';
    public static final String GROUP_CBS_SC = 'CBS - SC';
    public static final String CBS_SP = 'CBS-SP';
    public static final String CBS_SC = 'CBS-SC';
    public static final String CBS_PM = 'PM';

    public static final String USER_MIRROR_TYPE_RC_CODE = 'RC_Code';

    public static final String REJECT_REASON_OTHERS = 'อื่นๆ(โปรดระบุ)'; 
    public static final String REQUEST_REASON_OTHERS = 'อื่นๆ (โปรดระบุ)'; 

    /*-- CR023 Ownership Bad --*/
    public static final String AN_TEAM_NAME = 'AN Team';
    public static final String AN_TEAM_DEV_NAME = 'AN_Team';

    public static final String AN_RM = 'AN-RM';
    public static final String AN_TM = 'AN-TM';
    public static final String AN_AH = 'AN-AH';
    public static final String AN_NH = 'AN-NH';
    public static final String AN_ADMIN = 'AN-Admin';


    public static final String AF_RM = 'AF-RM';
    public static final String AF_TM = 'AF-TM';
    public static final String AF_AH = 'AF-Head of Sales';
    public static final String AF_NH = 'AF-Head of Dept';
    public static final String AF_FSVP = 'AF-FSVP';

    public static final String KBANK_PROCESS_TEAM_ALL = 'KBANK-Process Team All';
    public static final String KBANK_PROCESS_TEAM = 'KBANK-Process Team';
    public static final String KBANK_BIU = 'KBANK-BIU';

/*

public static final String RBS_RM_ABM = 'RBS-ABM';
    public static final String RBS_RM_BAR = 'RBS-BAR';
    public static final String RBS_TM = 'RBS-BM';
    public static final String RBS_AH = 'RBS-ZM';
    public static final String RBS_ADMIN = 'RBS-Admin';
    */


    public static final Set<String> PROFILE_AN_SET = new Set<String>{GlobalConstants.AN_RM,GlobalConstants.AN_TM,GlobalConstants.AN_AH,GlobalConstants.AN_NH};
    public static final Set<String> PROFILE_RBS_CREATE_PORT = new Set<String>{GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_RM_BAR,GlobalConstants.RBS_TM,GlobalConstants.AF_RM,GlobalConstants.AF_RM};
    public static final Set<String> PROFILE_RBS_SET = new Set<String>{GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_ADMIN,GlobalConstants.RBS_AH,GlobalConstants.RBS_RM_BAR,GlobalConstants.RBS_TM,GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_NH};
    public static final Set<String> PROFILE_RBS_SALE_SET = new Set<String>{GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_RM_BAR,GlobalConstants.RBS_TM};
    public static final Set<String> PROFILE_AF_SET = new Set<String>{GlobalConstants.AF_FSVP,GlobalConstants.AF_NH,GlobalConstants.AF_AH,GlobalConstants.AF_TM,GlobalConstants.AF_RM};
    public static final Set<String> PROFILE_SME_SET = new Set<String>{GlobalConstants.SME_ADMIN,GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM,GlobalConstants.SME_RM,GlobalConstants.AN_RM,GlobalConstants.AN_TM,GlobalConstants.AN_AH,GlobalConstants.AN_NH};
    public static final Set<String> PROFILE_CBS_SET = new Set<String>{GlobalConstants.CBS_ADMIN,GlobalConstants.CBS_RM,GlobalConstants.CBS_TL,GlobalConstants.CBS_TM};
    public static final Set<String> PROFILE_KBANK_ADMIN_SET = new Set<String>{GlobalConstants.KBANK_PROCESS_TEAM,GlobalConstants.KBANK_PROCESS_TEAM_ALL,GlobalConstants.SME_ADMIN,GlobalConstants.CBS_ADMIN,GlobalConstants.RBS_ADMIN,GlobalConstants.AN_ADMIN,GlobalConstants.PROFILE_SOLAR,GlobalConstants.SYSTEM_ADMIN};
    public static final Set<String> PROFILE_PROCESS_TEAM_SET = new Set<String>{GlobalConstants.KBANK_PROCESS_TEAM,GlobalConstants.KBANK_PROCESS_TEAM_ALL};
    public static final Set<String> PROFILE_ADMIN_SEGMENT_TEAM_SET = new Set<String>{GlobalConstants.SME_ADMIN,GlobalConstants.CBS_ADMIN,GlobalConstants.RBS_ADMIN,GlobalConstants.AN_ADMIN};
    public static final Set<String> PROFILE_SME_SALE_SET = new Set<String>{GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM,GlobalConstants.SME_RM};
    public static final Set<String> PROFILE_CBS_SALE_SET = new Set<String>{GlobalConstants.CBS_RM,GlobalConstants.CBS_TL,GlobalConstants.CBS_TM};
    public static final Set<String> PROFILE_ADMIN_SET = new Set<String>{GlobalConstants.SYSTEM_ADMIN,GlobalConstants.PROFILE_SOLAR,GlobalConstants.INTEGRATION_USER};
    public static final Set<String> PROFILE_SME_AND_ADMIN_SET = new Set<String>{GlobalConstants.SME_ADMIN,GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM,GlobalConstants.SME_RM,GlobalConstants.AN_RM,GlobalConstants.AN_TM,GlobalConstants.AN_AH,GlobalConstants.AN_NH,GlobalConstants.KBANK_PROCESS_TEAM,GlobalConstants.KBANK_PROCESS_TEAM_ALL,GlobalConstants.SME_ADMIN,GlobalConstants.CBS_ADMIN,GlobalConstants.RBS_ADMIN,GlobalConstants.AN_ADMIN,GlobalConstants.PROFILE_SOLAR,GlobalConstants.SYSTEM_ADMIN};
    public static final Set<String> PROFILE_RBS_ADMIN_SET = new Set<String>{GlobalConstants.RBS_ADMIN};
    public static final Set<String> PROFILE_AF_HEAD_SET = new Set<String>{GlobalConstants.AF_FSVP,GlobalConstants.AF_NH,GlobalConstants.AF_AH,GlobalConstants.AF_TM};

    public static final Set<String> PROFILE_RM_SME_CBS_SET = new Set<String>{GlobalConstants.SME_RM,GlobalConstants.CBS_TL,GlobalConstants.CBS_TM,GlobalConstants.CBS_RM};
    public static final Set<String> SYSTEM_ADMIN_SET = new Set<String>{GlobalConstants.SYSTEM_ADMIN,'ผู้ดูแลระบบ',GlobalConstants.PROFILE_SOLAR};
    public static final String LEAD_SHARING = 'Sharing';
    public static final String SHARING_WITH_AN = 'Sharing with AN';

    public static final List<String> monthThaiNameList = new List<String>{'มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'};

    //Application_History 
    public static final String NEW_CREDIT = 'New Credit';
    public static final String APPROVED_WITH_CONDITION = 'Approved with Condition';
    public static final String APPROVED_BUT_REDUCE_AMOUNT = 'Approved but reduce amount';
    public static final String APPROVED_BUT_EXTEND_TERM = 'Approved but extend term';
    
    public static final String WORK_IN_PROGRESS = 'Work In Progress';
    public static final String DECLINE = 'Decline';
    public static final String FINAL_APPROVE = 'Final Approve';
    public static final String SETUP = 'Setup';
    public static final String CANCEL_JOB= 'Cancel Job';
    public static final String APP_ST_COMPLETE= 'Complete';

    public static final String FINAL_DECISION_PA = 'PA';
    public static final String FINAL_DECISION_LP = 'LP';
    public static final String FINAL_DECISION_DC = 'DC';
    public static final String FINAL_DECISION_FA = 'FA';

    public static final String ESTIMATE_CREDIT_MODEL_FL = 'FL';
    public static final String ESTIMATE_CREDIT_MODEL_HPL = 'HPL';
    public static final String ESTIMATE_CREDIT_MODEL_PL = 'PL';
    public static final String ESTIMATE_CREDIT_MODEL_DLA = 'DLA';
    public static final String OT_AH_SALES = 'OneTeam-AH(Sales)';
    public static final String OT_NH_SALES = 'OneTeam-NH';

    public static final String FRAUD_COLOR_BROWN = '#612f02';
    public static final String FRAUD_COLOR_BLUE = '#0501ea';
    public static final String FRAUD_COLOR_PINK = '#ff5ac8';

    public static final String SERVICING = 'Servicing';
    public static final String RENEW_SERVICING = 'Renew';
    public static final String CREDIT_TYPE_OTHERS = 'Others';
    public static final String OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING = 'เข้า UW/DLA - New Booking';
    public static final String OPP_PLAN_PRODUCT_TYPE_UW_DLA_RENEW = 'เข้า UW/DLA - ต่ออายุวงเงิน';
    public static final String OPP_PLAN_PRODUCT_TYPE_UW_DLA_CHANGE_CONDITION = 'เข้า UW/DLA - ปรับเงื่อนไข';
    public static final Set<String> OPP_PLAN_PRODUCT_SERVICING_LIST = new Set<String>{OPP_PLAN_PRODUCT_TYPE_UW_DLA_RENEW,OPP_PLAN_PRODUCT_TYPE_UW_DLA_CHANGE_CONDITION};

    public static final String EMAIL_NOTIFICATION = 'rmtools_system@kasikornbank.com';
    public static final String CMAS_STATUS_PENDING = 'Waiting For Response';
    public static final String CMAS_STATUS_ERROR = 'Send to CMAS ERROR';
    public static final String CMAS_STATUS_SUCCESS = 'Send to CMAS Success';

    public static final String CMAS_WF_ST_CREATED = 'Created';
    public static final String CMAS_WF_ST_COMPLETE = 'Completed';
    public static final String CMAS_WF_ST_APPROVED = 'Approved';
    public static final String CMAS_WF_ST_WITHDRAWN = 'Withdrawn';
    public static final String CMAS_WF_ST_CANCEL = 'Cancelled';
    public static final String CMAS_WF_ST_REJECTED = 'Rejected';
    public static final String CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL = 'Pending Superior Approval';
    public static final String CMAS_WF_ST_PENDING_RESUBMIT = 'Pending  Resubmit';
    public static final String CMAS_WF_ST_APPROVED_WITH_CONDITION = 'Approved with Condition';
    public static final String CMAS_WF_ST_PENDING_VERIFICATION = 'Pending Verification';
    public static final String CMAS_WF_ST_APPLICATION_RETURNED = 'Application Returned';
    public static final String CMAS_WF_ST_CUSTOMER_ACCEPTED = 'Customer Accepted';
    public static final String CMAS_WF_ST_CUSTOMER_DECLINED = 'Customer Declined';
    public static final String CMAS_WF_ST_PENDING_UW_APPROVAL = 'Pending UW Approval';
    public static final String CMAS_WF_ST_PENDING_CONCLUSION = 'Pending Conclusion';
    public static final String CMAS_WF_ST_SIGN_OFF = 'Sign Off';
    
    public static final String CMAS_APP_TYPE_NEW = '01';
    public static final String CMAS_APP_TYPE_SERVICING= '04';

    public static final String RECORDTYPE_DEVNAME_PRODUCT_MASTER_SME = 'For_SME';
    public static final String RECORDTYPE_DEVNAME_PRODUCT_MASTER_CBS = 'For_CBS';

    public static final String VISIT_OBJECTIVE_SELL_NONCREDIT = 'Sell (Non-Credit)';
    public static final String VISIT_OBJECTIVE_SELL_CREDIT_NONCREDIT = 'Sell (Credit + Non-Credit)';
    public static final Set<String> RECOMMEND_PRODUCT_VISIT_OBJECTIVE_SET = new Set<String>{VISIT_OBJECTIVE_SELL_NONCREDIT,VISIT_OBJECTIVE_SELL_CREDIT_NONCREDIT};
    public static final Set<String> SET_CAMPAING_RECORD_EVENT_DEV_NAME = new Set<String>{SME_EVENT_DEVNAME,SME_EVENT_NON_TARGET_DEVNAME,RBS_EVENT_NON_TARGETED_DEVNAME,RBS_EVENT_DEVNAME};

    public static final String SME = 'SME';
    public static final String RBS = 'RBS';

    public static final String CALL_REPORT_FOR_SALE = 'เพื่อขาย';

    public static final Set<String> REFEROUT_BAD_REASON = new Set<String>{BAD,DEAD,CLOSED_BUSINESS,AMLO_LIST,EXIT_PLAN,CRIMINAL_OFFENSE};
    public static final Set<String> REFEROUT_CBS_REASON = new Set<String>{REASON_NOT_SME,REASON_NATIONALITY,REASON_COMPANY_RELATED};
    public static final Set<String> REFEROUT_NOT_SME_CBS_REASON = new Set<String>{REASON_NOT_SME,REASON_NATIONALITY,REASON_NOT_CBS,REASON_COMPANY_RELATED};
    public static final Set<String> REFEROUT_RELEASE_REASON = new Set<String>{REASON_OTHER_TEAM,REASON_WRONG_AREA,REASON_NOT_SME,REASON_NATIONALITY,REASON_NOT_CBS,REASON_COMPANY_RELATED};

    public static final String KNOWN_ERR_CC_CODE_1 = 'Contact101';
    public static final String KNOWN_ERR_CC_MSG_1 = 'Contact and Related Contact must be different entities';
    public static final String KNOWN_ERR_CC_CODE_2 = 'Contact102';
    public static final String KNOWN_ERR_CC_MSG_2 = 'Cannot find CIS id subject or object in Account object';
    public static final String KNOWN_ERR_CC_CODE_3 = 'Contact103';
    public static final String KNOWN_ERR_CC_MSG_3 = 'There is no person contact id for subject or object';
    public static final String KNOWN_ERR_CC_CODE_4 = 'Contact104';
    public static final String KNOWN_ERR_CC_MSG_4 = 'There is no person contact id for account';
    public static final String KNOWN_ERR_CC_CODE_5 = 'Contact105';
    public static final String KNOWN_ERR_CC_MSG_5 = 'There is no customer information at object side of the relation';

    public static final String LEAD_RECORDTYPE_REFERRAL ='Referral';
    public static final String LEAD_RECORDTYPE_LEAD_REFERRAL ='Lead_Referral';
    public static final String LEAD_RECORDTYPE_LEAD_REFERRAL_READ_ONLY ='Lead_Referral_Read_Only';
    public static final String LEAD_RECORDTYPE_LEAD_REFERRAL_CONVERTED ='Lead_Referral_Converted';
    public static final String LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME ='Telesales_Lead_MLP';
    public static final String LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME ='Telesales_Lead_MLP_Read_Only';
    public static final String LEAD_RECORDTYPE_TELESALES_LEAD_DEVNAME ='Telesales';
    public static final String LEAD_RECORDTYPE_TELESALES_SCRIPT_LEAD_DEVNAME ='Telesales_Script';
    public static final String EVENT_RECORDTYPE_TELESALES_DEVNAME ='Telesales';

    public static final String ACCRESS_ACCOUNT_DETAIL = 'รายละเอียด';
    public static final String ACCRESS_ACCOUNT_SEARCH = 'ค้นหา';
    public static final String ACCRESS_PRODUCT_USAGE = 'Product Usage';
    public static final String ACCRESS_ACCOUNT_EXPORT = 'Export ข้อมูล';

    public static final String TRANSFER_BUDGET_DEVNAME = 'Transfer_Budget';
    public static final String TRANSFER_BUDGET_READ_ONLY_DEVNAME = 'Transfer_Budget_Read_Only';
    public static final String TRANSFER_BUDGET_APPROVE_DEVNAME = 'Transfer_Budget_Approve';
    public static final String REQUEST_BUDGET_DEVNAME = 'Request_Budget';
    public static final String REQUEST_BUDGET_READ_ONLY_DEVNAME = 'Request_Budget_Read_Only';
    public static final String REQUEST_BUDGET_APPROVE_DEVNAME = 'Request_Budget_Approve';
    public static final String DECREASE_BUDGET_ITEM_DEVNAME = 'Decrease_Budget_Item';
    public static final String INCREASE_BUDGET_ITEM_DEVNAME = 'Increase_Budget_Item';
    public static final String REQUEST_BUDGET_ITEM_DEVNAME = 'Request_Budget_Item';
    public static final String VETO_IQM_DEVNAME = 'Veto_IQM';
    public static final String VETO_MSYTERY_SHOPPING_DEVNAME = 'Veto_Msytery_Shopping';
    public static final String VETO_PAYROLL_CLOSE_DEVNAME = 'Veto_Payroll_Close';
    public static final String VETO_PAYROLL_DEVNAME = 'Veto_Payroll';
    public static final String VETO_PICKLIST_CLOSE_DEVNAME = 'Veto_Picklist_Close';
    public static final String VETO_SQM_DEVNAME = 'Veto_SQM';

    public static final String BUDGET_OPEN = 'Open';
    public static final String BUDGET_CANCELLED = 'Cancelled';
    public static final String BUDGET_WAITING_FOR_APPROVE = 'Waiting for Approve';
    public static final String BUDGET_WITH_IN_PROCESS = 'With In Process';
    public static final String BUDGET_INCORRECT = 'Incorrect';
    public static final String BUDGET_APPROVED = 'Approved';
    public static final String BUDGET_REJECTED = 'Rejected';
    public static final String BUDGET_COLLECT_DOCUMENT = 'Collect Document';
    public static final String BUDGET_CONTACT_BUDGET_ADMIN = 'Contact Budget Admin';
    public static final String BUDGET_COMPLETE = 'Complete';
    
    public static final String BUDGET_APPROVE_REFUSE = 'ไม่ดำเนินการ';
    public static final String BUDGET_APPROVE_PROCESSED = 'ดำเนินการแล้ว';
    public static final String BUDGET_APPROVE_REQUIRE_DOCUMENT = 'ขอเอกสารเพิ่ม';

    public static final String BULKASSIGNMENT_SOURCE_HRIS = 'HRIS';
    public static final String BULKASSIGNMENT_SOURCE_SME = 'BulkSME';
    public static final String BULKASSIGNMENT_SOURCE_CBS = 'BulkCBS';
    public static final String BULKASSIGNMENT_SOURCE_AF = 'BulkAF';
    
    public static final String DO_NOT_CONTACT_TEXT = 'ห้ามติดต่อ';
}