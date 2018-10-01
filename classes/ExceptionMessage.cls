/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A exception message class for the project

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class ExceptionMessage {
    
    public static String ERROR_HEADER = '[Error] : ';
    public static String ADMIN_VALUE = 'Please contact Admin.';

    // Database Error
    public static String CANNOT_INSERT_TRANSACTION = ERROR_HEADER + 'Can\'t insert data on system.' + ADMIN_VALUE;
    public static String CANNOT_UPDATE_TRANSACTION = ERROR_HEADER + 'Can\'t update data on system.' + ADMIN_VALUE;
    public static String CANNOT_UPSERT_TRANSACTION = ERROR_HEADER + 'Can\'t upsert data on system.' + ADMIN_VALUE;
    public static String CANNOT_DELETE_TRANSACTION = ERROR_HEADER + 'Can\'t delete data on system.' + ADMIN_VALUE;
    public static String CANNOT_ROOLBACK_TRANSACTION = ERROR_HEADER + 'Can\'t rollback data on system.' + ADMIN_VALUE;

    // Batch Error

    
    // Trigger Error
    public static String THIS_REQUEST_HAS_NO_CIS = 'This Request has no CIS.';
    public static String CUSTOMER_ALREADY_IN_YOUR_PORT = 'Customer already in your port';
    public static String OTHER_CUSTOMER_CANNOT_ASSIGN_TO_PORT = 'Other Customer cannot assign to Port';
    public static String CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP = 'Customer must be in your port to release ownership';
    public static String CANNOT_REQUEST_CUSTOMER_WHEN_POOL_ADMIN = 'Cannot request customer when ownership is pool and owner is SME Admin';

    // Query Error
    public static String QUERY_TIMEOUT = '' + ADMIN_VALUE;

    // REST Satisfaction Survey
    public static String NO_SGID_ACCOUNT = ERROR_HEADER + 'This error began when didn\'t found SFIG account. ';
    public static String NO_CONTACT_WITH_THIS_PHONE = ERROR_HEADER + 'This error began when didn\'t found Contact according phone number :';

    // Class Error
    public static String COMPANY_CODE_IS_NULL = ERROR_HEADER + 'Please provide Company Code' + ADMIN_VALUE;
    public static String ADDRESS_INFORMATION_IS_NULL = ERROR_HEADER + 'Please provide address information' + ADMIN_VALUE;
    public static String NO_AUTHORIZATION_USER = 'No authorization to change user information';
    public static String NO_AUTHORIZATION_JOB = 'No authorization to create jobs';
    public static String NO_AUTHORIZATION_UPDATEJOB = 'No authorization to finish jobs';


    // CustomerSearchController
    public static String ALREADY_SUBMMITTED = 'This Customer already submitted for ownership request, cannot re-submit';
    public static String ALL_PARAM_ARE_NULL = 'One search field must be entered';
    public static String ALL_PARAM_ARE_NULL_TH = 'ระบุเงื่อนไขในการค้นหา';
    public static String TIME_OUT = 'Time out, please try again.';
    public static String NO_MATCH_RECORD = 'No matching record found';
    public static String NO_MATCH_RECORD_TH = 'ไม่พบข้อมูล';
    public static String UNEXPECTED_ERROR = 'Unexpected Error has occurred.';
    public static String SORT_FAILED = 'Failed to sort data';
    public static String SEARCH_FAILED = 'Failed to search data';
    // HTTP Call 
    public static String BACKEND_ERROR = 'Found Error from the backend';
    public static String INVALID_RESPONSE = 'Got Invalid format response from the backend:';
    public static String HTTP_CONNECTION_FAILED = 'Connection problem occurred:';
    public static String CI_RESPONSE_ERROR = 'Found error message from CI Webservice:';
    public static String PARSE_FAILED = 'Failed to parse the invalid format response:';

    public static String APPLICATION_SERVER_NOT_AVAILABLE = 'Application server is not available';
    public static String APPLICATION_TIMEOUT = 'Application Time Out';
    public static String DATABASE_NOT_AVAILABLE = Label.Prospect_DIH_Error;
    public static String DATABASE_CONNECTION_FAILED = 'Database connection Fail';
    public static String ADAPTER_NOT_AVAILABLE = Label.Prospect_CI_Error;
    public static String HOST_NOT_AVAILABLE = 'Host is not available';
    public static String HOST_TIMEOUT = 'Host Time Out';
    public static String HOST_EXCEPTION = 'Host Connection Exception';
    public static String AUTHENTICATION_FAILED = 'Authentication is possible but has failed';

    //CustomerBusinessCode
    public static String TOTAL_RATIO_MORE_THAN_100 = 'Ratio ทั้งหมดของทุก Business Code รวมกันจะต้องไม่เกิน 100';
    public static String NO_BUSINESSCODE_MATCH_IN_SYSTEM = 'ไม่พบ Business Code ที่ตรงกับ Segment อยู่ในระบบ';
    public static String REQUIRE_BUSINESS_CODE ='โปรดระบุ Business Code';

    //CBS Call Report
    public static String THIS_FIELD_IS_REQUIRED = 'This field is required';
    public static String ZERO_IS_NOT_ALLOWED = '0 is not allowed';

    //CallReport-Product
    public static String SR_NUMBER_CHARACTERS_LIMIT = 'SR Number must be between 11-14 characters';
    public static String NO_PRODUCT_IN_PRODUCTLISTMASTER = 'No Product found';

    // CR099 for temporary use for oneteam
    public static String NOT_OWNER_CANNOT_CREATE_CREDIT_PL = 'ไม่สามารถสร้างโอกาส เมื่อ Esitimate Credit Model มีค่าเป็น PL';

    //Closed Jobs
    public static String CANNOT_CLOSEJOB_CALLPLAN = 'ไม่สามารถปิด Job ได้ เนื่องจากมี Call Plan ค้างอยู่';
    public static String CANNOT_CLOSEJOB_OPPPRODUCT = 'ไม่สามารถปิด Job ได้ เนื่องจาก Opp Product ยังไม่ Complete';
    public static String CANNOT_CLOSEJOB_APPRESULT = 'ไม่สามารถปิด Job ได้ เนื่องจาก App Result = Work In Progress';

    //Opportunity Product
    public static String OTHERSEGMENT_CANNOT_EDITPRODUCT = 'ไม่อนุญาตให้แก้ไข Opp Product ที่สร้างโดยทีมขายต่างสายงาน   ';
}