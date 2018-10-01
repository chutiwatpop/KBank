/**
* @author komsan.wi@beryl8.com
* @08/09/2015 create new
*/
public without sharing class YearEndModel{
    public class ReferOut {
        public String referoutSegment;
        public String referoutReason;
        public String referoutProvince;
        public String referoutAumpur;
        public String referoutTumbon;
        public String referoutTeam;
        public String referoutTeamId;
        public String referoutSegmentPros;
        public String referoutLanguage;
        public String referoutPercentShare;
        public String referoutrelateCIS;
    }
    public class SelectedName {
        public String selectedbyTeampanel;
        public String selectedbyNamepanel;
        public String portPoolpanel;
        public String serviceRMpanel;
        public String selectedbyNameRequestpanel;
        public String portPoolRequestpanel;
        public String serviceRMRequestpanel;
    }
    public class SavingRequest {
        //public Context contx;
        public String contx;
        public Boolean deleteFinalAssign;
        public ReferOut referOut;
        public SelectedName selectName;
        public List<String> yearlist;
        public String approveStatus;
        //public String submitStatus;
    }
    public class SavingResponse {
        public Boolean success;
        public Boolean duplicate;
        public String errorMessage;
        public SavingResponse() {
            success = true;
            duplicate = false;
        }
    }
}